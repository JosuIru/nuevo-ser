import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, rellenoInferiorSeguro, separarCampoSolera;

import '../datos/base_datos.dart';
import '../dominio/comprobacion_denominacion.dart';
import '../dominio/composicion_receta.dart';
import '../dominio/etiqueta_venta.dart';
import '../modelos/alergenos.dart';
import '../modelos/hornada.dart';
import '../modelos/ingrediente.dart';
import '../modelos/receta.dart';
import '../modelos/titular.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_etiqueta_venta_pdf.dart';
import '../utiles/textos_obrador.dart';

/// Abre la etiqueta de venta de [receta]. Desde una [hornada] toma su lote
/// y su fecha; desde la receta, deja hueco para escribirlos a mano.
Future<void> abrirEtiquetaVenta(
  BuildContext context, {
  required Receta receta,
  required ComposicionReceta composicion,
  required Map<int, Ingrediente> ingredientes,
  Hornada? hornada,
}) =>
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PantallaEtiquetaVenta(
                receta: receta,
                composicion: composicion,
                ingredientes: ingredientes,
                hornada: hornada)));

class PantallaEtiquetaVenta extends StatefulWidget {
  const PantallaEtiquetaVenta({
    super.key,
    required this.receta,
    required this.composicion,
    required this.ingredientes,
    this.hornada,
  });

  final Receta receta;
  final ComposicionReceta composicion;
  final Map<int, Ingrediente> ingredientes;
  final Hornada? hornada;

  @override
  State<PantallaEtiquetaVenta> createState() => _PantallaEtiquetaVentaState();
}

class _PantallaEtiquetaVentaState extends State<PantallaEtiquetaVenta> {
  final _denominacion = TextEditingController();
  final _cantidadNeta = TextEditingController();
  final _diasDuracion = TextEditingController();
  final _conservacion = TextEditingController();
  final _copias = TextEditingController(text: '1');
  final _nutrientes = {
    for (final clave in [
      'energia_kj',
      'energia_kcal',
      'grasas',
      'saturadas',
      'hidratos',
      'azucares',
      'proteinas',
      'sal'
    ])
      clave: TextEditingController()
  };

  bool _cargado = false;
  Titular _titular = Titular();
  ModoEtiqueta _modo = ModoEtiqueta.envasado;
  FormatoEtiqueta _formato = FormatoEtiqueta.rejilla3x8;
  TipoFechaEtiqueta _tipoFecha = TipoFechaEtiqueta.sinFecha24h;
  final Set<int> _conPorcentaje = {};
  final Set<String> _trazas = {};
  bool _cocidoHaceMasDe24h = false;
  bool _segundoIdioma = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final baseDatos = BaseDatosSoleraObrador.instancia;
    try {
      _titular = await baseDatos.obtenerTitular();
      final datos = await baseDatos.obtenerDatosEtiqueta(widget.receta.id!) ??
          const DatosEtiquetaReceta();
      _denominacion.text = datos.denominacion;
      if (datos.cantidadNetaGramos != null) {
        _cantidadNeta.text =
            formatearNumero(datos.cantidadNetaGramos!, decimales: 0);
      }
      if (datos.diasDuracion != null) {
        _diasDuracion.text = '${datos.diasDuracion}';
      }
      _conservacion.text = datos.conservacion;
      _tipoFecha = datos.tipoFecha;
      _conPorcentaje.addAll(datos.ingredientesConPorcentaje);
      _trazas.addAll(datos.trazasIndicadas);
      final info = datos.infoNutricional;
      if (info != null) {
        info.aMapa().forEach((clave, valor) => _nutrientes[clave]!.text =
            formatearNumero(valor as double, decimales: 2));
      }
    } catch (error) {
      debugPrint('No se pudieron leer los datos de la etiqueta: $error');
    }
    final hornada = widget.hornada;
    if (hornada != null) _copias.text = '${hornada.piezas}';
    if (mounted) setState(() => _cargado = true);
  }

  @override
  void dispose() {
    for (final controlador in [
      _denominacion,
      _cantidadNeta,
      _diasDuracion,
      _conservacion,
      _copias,
      ..._nutrientes.values,
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  InfoNutricional? _leerNutricional() => InfoNutricional.deMapa({
        for (final MapEntry(key: clave, value: controlador)
            in _nutrientes.entries)
          clave: leerNumero(controlador.text),
      });

  DatosEtiquetaReceta _datos() => DatosEtiquetaReceta(
        denominacion: _denominacion.text.trim(),
        cantidadNetaGramos: leerNumero(_cantidadNeta.text),
        tipoFecha: _tipoFecha,
        diasDuracion: int.tryParse(_diasDuracion.text.trim()),
        conservacion: _conservacion.text.trim(),
        ingredientesConPorcentaje: {..._conPorcentaje},
        trazasIndicadas: {..._trazas},
        infoNutricional: _leerNutricional(),
      );

  ContenidoEtiqueta _contenido() {
    final hornada = widget.hornada;
    final otroIdioma = SoleraL10n.idioma;
    return componerEtiqueta(
      modo: _modo,
      receta: widget.receta,
      composicion: widget.composicion,
      ingredientes: widget.ingredientes,
      datos: _datos(),
      titular: _titular,
      fechaElaboracion: hornada == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(hornada.fechaMs),
      codigoLote: hornada?.codigoLote,
      cocidoHaceMasDe24h: _cocidoHaceMasDe24h,
      // RD 126/2015 art. 10: al menos en castellano.
      idioma: 'es',
      segundoIdioma: _segundoIdioma && otroIdioma != 'es' ? otroIdioma : null,
    );
  }

  Future<void> _crearPdf() async {
    final copias = int.tryParse(_copias.text.trim()) ?? 1;
    try {
      await BaseDatosSoleraObrador.instancia
          .guardarDatosEtiqueta(widget.receta.id!, _datos());
    } catch (error) {
      debugPrint('No se pudieron guardar los datos de la etiqueta: $error');
    }
    if (!mounted) return;
    final contenido = _contenido();
    await compartirDocumentoPdf(
      context,
      nombreFichero: 'etiqueta_${widget.receta.id}.pdf',
      generar: (tema) => generarEtiquetaVentaPdf(
          contenido: contenido,
          formato: _formato,
          copias: copias.clamp(1, 999),
          tema: tema),
    );
  }

  String _nombreFormato(FormatoEtiqueta formato) => switch (formato) {
        FormatoEtiqueta.rejilla3x8 => SoleraL10n.t('obra.etiq_formato_3x8'),
        FormatoEtiqueta.rejilla2x4 => SoleraL10n.t('obra.etiq_formato_2x4'),
        FormatoEtiqueta.suelta => SoleraL10n.t('obra.etiq_formato_suelta'),
      };

  String _nombreNutriente(String clave) => switch (clave) {
        'energia_kj' => '${SoleraL10n.t('obra.etiq_l_energia')} (kJ)',
        'energia_kcal' => '${SoleraL10n.t('obra.etiq_l_energia')} (kcal)',
        'grasas' => SoleraL10n.t('obra.etiq_l_grasas'),
        'saturadas' => SoleraL10n.t('obra.etiq_l_saturadas'),
        'hidratos' => SoleraL10n.t('obra.etiq_l_hidratos'),
        'azucares' => SoleraL10n.t('obra.etiq_l_azucares'),
        'proteinas' => SoleraL10n.t('obra.etiq_l_proteinas'),
        'sal' => SoleraL10n.t('obra.etiq_l_sal'),
        _ => clave,
      };

  Widget _campo(TextEditingController controlador, String etiqueta,
          {bool numero = false, String? ayuda}) =>
      separarCampoSolera(TextField(
        controller: controlador,
        keyboardType: numero
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: etiqueta, helperText: ayuda),
      ));

  @override
  Widget build(BuildContext context) {
    if (!_cargado) {
      return Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()));
    }
    final estilo = Theme.of(context).textTheme;
    final contenido = _contenido();
    final avisos = avisosEtiqueta(
      modo: _modo,
      datos: _datos(),
      titular: _titular,
      contenido: contenido,
      formato: _formato,
      tieneFechaYLote: widget.hornada != null,
    );
    final denominacionLegal = denominacionPorId(widget.receta.denominacion);
    final trazasDeIngredientes =
        widget.composicion.trazas.difference(_trazas).isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('obra.etiq_titulo'))),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
        children: [
          Text(widget.hornada == null
              ? widget.receta.nombre
              : '${widget.receta.nombre} · ${SoleraL10n.t('obra.lote')} ${widget.hornada!.codigoLote}'),
          const SizedBox(height: 12),
          SegmentedButton<ModoEtiqueta>(
            segments: [
              ButtonSegment(
                  value: ModoEtiqueta.envasado,
                  label: Text(SoleraL10n.t('obra.etiq_modo_envasado'))),
              ButtonSegment(
                  value: ModoEtiqueta.granel,
                  label: Text(SoleraL10n.t('obra.etiq_modo_granel'))),
            ],
            selected: {_modo},
            onSelectionChanged: (seleccion) => setState(() {
              _modo = seleccion.first;
              if (_modo == ModoEtiqueta.granel &&
                  _formato == FormatoEtiqueta.rejilla3x8) {
                _formato = FormatoEtiqueta.suelta;
              }
            }),
          ),
          const SizedBox(height: 8),
          Text(
              SoleraL10n.t(_modo == ModoEtiqueta.envasado
                  ? 'obra.etiq_modo_envasado_explicacion'
                  : 'obra.etiq_modo_granel_explicacion'),
              style: estilo.bodySmall),
          const SizedBox(height: 12),
          _campo(_denominacion, SoleraL10n.t('obra.etiq_denominacion'),
              ayuda: denominacionLegal == null
                  ? SoleraL10n.t('obra.etiq_denominacion_ayuda')
                  : '${SoleraL10n.t('obra.etiq_denominacion_legal')}: '
                      '${denominacionLegal.nombre} (RD 308/2019, ${denominacionLegal.articulo})'),
          if (_modo == ModoEtiqueta.envasado ||
              esDenominacionDePan(widget.receta.denominacion))
            _campo(
                _cantidadNeta,
                SoleraL10n.t(_modo == ModoEtiqueta.envasado
                    ? 'obra.etiq_cantidad_neta'
                    : 'obra.etiq_peso_pieza'),
                numero: true,
                ayuda:
                    '${SoleraL10n.t('obra.etiq_calculado')}: ${formatearNumero(widget.composicion.gramosPorPieza, decimales: 0)} g'),
          if (_modo == ModoEtiqueta.envasado) ...[
            separarCampoSolera(DropdownButtonFormField<TipoFechaEtiqueta>(
              isExpanded: true,
              initialValue: _tipoFecha,
              decoration:
                  InputDecoration(labelText: SoleraL10n.t('obra.etiq_fecha')),
              items: [
                DropdownMenuItem(
                    value: TipoFechaEtiqueta.consumoPreferente,
                    child: Text(SoleraL10n.t('obra.etiq_fecha_preferente'))),
                DropdownMenuItem(
                    value: TipoFechaEtiqueta.caducidad,
                    child: Text(SoleraL10n.t('obra.etiq_fecha_caducidad'))),
                DropdownMenuItem(
                    value: TipoFechaEtiqueta.sinFecha24h,
                    child: Text(SoleraL10n.t('obra.etiq_fecha_sin_24h'))),
              ],
              onChanged: (valor) => setState(() => _tipoFecha = valor!),
            )),
            if (_tipoFecha != TipoFechaEtiqueta.sinFecha24h)
              _campo(_diasDuracion, SoleraL10n.t('obra.etiq_dias_duracion'),
                  numero: true),
            _campo(_conservacion, SoleraL10n.t('obra.etiq_conservacion'),
                ayuda: SoleraL10n.t('obra.etiq_conservacion_ayuda')),
          ],
          const SizedBox(height: 12),
          Text(SoleraL10n.t('obra.etiq_porcentaje'), style: estilo.titleSmall),
          Text(SoleraL10n.t('obra.etiq_porcentaje_ayuda'),
              style: estilo.bodySmall),
          Wrap(spacing: 6, children: [
            for (final id in widget.composicion.ingredientesPorPeso)
              FilterChip(
                label: Text(widget.ingredientes[id]!.nombre),
                selected: _conPorcentaje.contains(id),
                onSelected: (marcado) => setState(() => marcado
                    ? _conPorcentaje.add(id)
                    : _conPorcentaje.remove(id)),
              ),
          ]),
          const SizedBox(height: 12),
          Text(SoleraL10n.t('obra.etiq_trazas'), style: estilo.titleSmall),
          Text(SoleraL10n.t('obra.etiq_trazas_ayuda'), style: estilo.bodySmall),
          if (trazasDeIngredientes)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () =>
                    setState(() => _trazas.addAll(widget.composicion.trazas)),
                child: Text(SoleraL10n.t('obra.etiq_trazas_de_ingredientes')),
              ),
            ),
          Wrap(spacing: 6, children: [
            for (final alergeno in alergenosObligatorios)
              if (!widget.composicion.alergenos.contains(alergeno))
                FilterChip(
                  label: Text(nombreAlergeno(alergeno)),
                  selected: _trazas.contains(alergeno),
                  onSelected: (marcado) => setState(() => marcado
                      ? _trazas.add(alergeno)
                      : _trazas.remove(alergeno)),
                ),
          ]),
          if (_modo == ModoEtiqueta.granel &&
              widget.receta.denominacion == 'pan_comun')
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(SoleraL10n.t('obra.etiq_cocido_24h')),
              value: _cocidoHaceMasDe24h,
              onChanged: (valor) => setState(() => _cocidoHaceMasDe24h = valor),
            ),
          if (_modo == ModoEtiqueta.envasado)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(SoleraL10n.t('obra.etiq_nutricional')),
              subtitle: Text(SoleraL10n.t('obra.etiq_nutricional_ayuda'),
                  style: estilo.bodySmall),
              children: [
                for (final MapEntry(key: clave, value: controlador)
                    in _nutrientes.entries)
                  _campo(controlador, _nombreNutriente(clave), numero: true),
              ],
            ),
          if (SoleraL10n.idioma != 'es')
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(SoleraL10n.t('obra.etiq_segundo_idioma')),
              subtitle: Text(SoleraL10n.t('obra.etiq_castellano_obligatorio')),
              value: _segundoIdioma,
              onChanged: (valor) => setState(() => _segundoIdioma = valor),
            ),
          const Divider(height: 32),
          separarCampoSolera(DropdownButtonFormField<FormatoEtiqueta>(
            isExpanded: true,
            initialValue: _formato,
            decoration:
                InputDecoration(labelText: SoleraL10n.t('obra.etiq_formato')),
            items: [
              for (final formato in FormatoEtiqueta.values)
                DropdownMenuItem(
                    value: formato, child: Text(_nombreFormato(formato))),
            ],
            onChanged: (valor) => setState(() => _formato = valor!),
          )),
          _campo(_copias, SoleraL10n.t('obra.etiq_copias'), numero: true),
          const SizedBox(height: 12),
          Text(SoleraL10n.t('obra.etiq_vista_previa'),
              style: estilo.titleSmall),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _VistaPrevia(contenido: contenido),
            ),
          ),
          for (final aviso in avisos)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(SoleraL10n.t(aviso),
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 8),
          Text(SoleraL10n.t('obra.etiq_aviso_provisional'),
              style: estilo.bodySmall),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _crearPdf,
            icon: const Icon(Icons.print_outlined),
            label: Text(SoleraL10n.t('obra.etiq_crear_pdf')),
          ),
        ],
      ),
    );
  }
}

/// La etiqueta en pantalla, con los destacados en negrita.
class _VistaPrevia extends StatelessWidget {
  const _VistaPrevia({required this.contenido});

  final ContenidoEtiqueta contenido;

  @override
  Widget build(BuildContext context) {
    const negrita = TextStyle(fontWeight: FontWeight.bold);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(contenido.denominacion,
            style: Theme.of(context).textTheme.titleMedium?.merge(negrita)),
        for (final linea in contenido.lineas)
          Text.rich(TextSpan(children: [
            if (linea.titulo != null) TextSpan(text: '${linea.titulo}: '),
            for (final fragmento in linea.fragmentos)
              TextSpan(
                  text: fragmento.texto,
                  style: fragmento.destacado ? negrita : null),
          ])),
        if (contenido.tablaNutricional.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(contenido.tituloNutricional ?? '', style: negrita),
          for (final (nutriente, valor) in contenido.tablaNutricional)
            Text('$nutriente: $valor'),
        ],
      ],
    );
  }
}
