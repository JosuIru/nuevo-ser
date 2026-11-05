import 'package:flutter/material.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/datos_notificador.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/amortizacion.dart';
import '../modelos/constantes.dart';
import '../modelos/indicadores_seguimiento.dart' show eurosDesdeCentimos;
import '../modelos/proyecto_test.dart';
import '../utiles/numeros.dart';
import 'widgets/confirmar_borrado.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/proyecto_visual.dart';
import 'widgets/relleno_seguro.dart';

/// Inventario de bienes amortizables del espacio (instalaciones, material
/// ganadero, adecuaciones de finca), como la hoja «Listado-amortización»
/// de Zunbeltz. Coordinación lo mantiene; el resto lo consulta.
///
/// Abierto desde un [proyecto], cada bien lleva una casilla «lo usa este
/// proyecto» (un `UsoBien` al 100 %) y arriba sale la cuota que asume
/// Zunbeltz por los bienes que usa.
class PantallaInventario extends StatefulWidget {
  const PantallaInventario({super.key, this.proyecto});

  final ProyectoTest? proyecto;

  @override
  State<PantallaInventario> createState() => _PantallaInventarioState();
}

class _PantallaInventarioState extends State<PantallaInventario> {
  final _bd = BaseDatosSoleraZunbeltz();
  List<BienAmortizable> _bienes = const [];

  /// Usos del proyecto por bien (vacío sin proyecto).
  Map<int, UsoBien> _usosPorBien = const {};
  bool _cargando = true;

  bool get _gestiona => politicaEspacioActual.puedeEditarInventario;
  ProyectoTest? get _proyecto => widget.proyecto;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final bienes = await _bd.listarBienes();
      final proyecto = _proyecto;
      final usos = proyecto?.id == null
          ? const <UsoBien>[]
          : await _bd.listarUsosBienes(proyecto!.id!);
      if (!mounted) return;
      setState(() {
        _bienes = bienes;
        _usosPorBien = {for (final uso in usos) uso.bienId: uso};
        _cargando = false;
      });
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _editar([BienAmortizable? bien]) async {
    final guardado = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => FormularioBienAmortizable(bien: bien)));
    if (guardado == true) await _cargar();
  }

  Future<void> _borrar(BienAmortizable bien) async {
    if (!await confirmarBorrado(context)) return;
    await _bd.borrarBien(bien.id!);
    await _cargar();
  }

  /// Marca o desmarca el uso del bien en el proyecto. Si el uso tenía un
  /// porcentaje o unos meses propios, se pregunta antes de quitarlo.
  Future<void> _cambiarUso(BienAmortizable bien, bool usar) async {
    final textos = AppLocalizations.of(context);
    final proyecto = _proyecto;
    if (proyecto?.id == null || bien.id == null) return;
    final uso = _usosPorBien[bien.id];
    if (usar && uso == null) {
      await _bd
          .guardarUsoBien(UsoBien(proyectoId: proyecto!.id!, bienId: bien.id!));
    } else if (!usar && uso?.id != null) {
      final propio = uso!.imputacionPorcentaje != 100 || uso.duracionMeses > 0;
      if (propio) {
        final seguir = await showDialog<bool>(
          context: context,
          builder: (contexto) => AlertDialog(
            content: Text(textos.invQuitarUso),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(contexto, false),
                  child: Text(textos.comunCancelar)),
              FilledButton(
                  onPressed: () => Navigator.pop(contexto, true),
                  child: Text(textos.comunBorrar)),
            ],
          ),
        );
        if (seguir != true) return;
      }
      await _bd.borrarUsoBien(uso.id!);
    }
    avisarCambioDatos();
    await _cargar();
  }

  /// Cuota mensual que se imputa al proyecto por un bien que usa.
  double _cuotaMensualImputada(BienAmortizable bien, UsoBien uso) =>
      bien.cuotaMensualCentimos * uso.imputacionPorcentaje / 100;

  Widget _cabecera(AppLocalizations textos) {
    final proyecto = _proyecto!;
    final estilos = Theme.of(context).textTheme;
    var alMes = 0.0;
    var total = 0;
    for (final bien in _bienes) {
      final uso = _usosPorBien[bien.id];
      if (uso == null) continue;
      alMes += _cuotaMensualImputada(bien, uso);
      total += cuotaImputadaCentimos(bien, uso, proyecto);
    }
    final meses = mesesDelProyecto(proyecto);
    final tintaSuave = Colors.white.withValues(alpha: 0.8);
    final oscuro = context.esquemaZunbeltz.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: oscuro ? const Color(0xFF0E3A2B) : colorCuadroPino,
        borderRadius: bordeDestacadoZunbeltz,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(textos.invCuotaZunbeltz,
            style: estilos.titleSmall?.copyWith(color: tintaSuave)),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 10,
          children: [
            Text('${eurosDesdeCentimos(alMes.round())} €',
                style: estilos.displaySmall?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700)),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(textos.invAlMes,
                  style: estilos.titleMedium?.copyWith(color: tintaSuave)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
            meses > 0
                ? textos.invEnLosMeses(
                    eurosRedondos(total), numeroLegible(meses))
                : textos.invSinFechas,
            style: estilos.bodyMedium?.copyWith(color: tintaSuave)),
      ]),
    );
  }

  Widget _grupo(String grupo, List<BienAmortizable> bienes, String idioma,
      AppLocalizations textos) {
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final (Color fondo, Color tinta, IconData icono) = switch (grupo) {
      'instalaciones' => (
          colorCuadroPino,
          Colors.white,
          Icons.warehouse_outlined
        ),
      'material_ganadero' => (
          colorCuadroSalvia,
          colorSobreCuadroClaro,
          Icons.agriculture_outlined
        ),
      'adecuaciones' => (
          colorCuadroEsmeralda,
          colorSobreCuadroClaro,
          Icons.water_drop_outlined
        ),
      _ => (
          esquema.secondaryContainer,
          esquema.onSecondaryContainer,
          Icons.inventory_2_outlined
        ),
    };
    final conProyecto = _proyecto != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Icon(icono, size: 22, color: tinta),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(etiquetaPartida(categoriaAmortizacion, grupo, idioma),
                style:
                    estilos.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
      Container(
        decoration: BoxDecoration(
          color: esquema.surfaceContainerLow,
          borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          for (var indice = 0; indice < bienes.length; indice++) ...[
            if (indice > 0)
              Divider(
                  height: 1,
                  indent: conProyecto ? 64 : 16,
                  endIndent: 16,
                  color: esquema.outlineVariant),
            _filaBien(bienes[indice], idioma, textos),
          ],
        ]),
      ),
    ]);
  }

  Widget _filaBien(
      BienAmortizable bien, String idioma, AppLocalizations textos) {
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final uso = _usosPorBien[bien.id];
    final conProyecto = _proyecto != null;
    final usado = uso != null;
    final apagado = conProyecto && !usado;
    final cuota =
        usado ? _cuotaMensualImputada(bien, uso) : bien.cuotaMensualCentimos;
    final detalle = [
      textos.invPrecioVidaUtil(
          eurosRedondos(bien.totalCentimos), '${bien.vidaUtilMeses}'),
      if (bien.especie.isNotEmpty)
        buscarOpcion(especiesGanado, bien.especie)?.etiqueta(idioma) ??
            bien.especie,
      if (usado && uso.imputacionPorcentaje != 100)
        textos
            .invParte('${uso.imputacionPorcentaje}')
            .replaceAll(' %', '\u00A0%'),
    ].join(' · ');
    return InkWell(
      onTap: _gestiona ? () => _editar(bien) : null,
      onLongPress: _gestiona ? () => _borrar(bien) : null,
      child: Padding(
        padding: EdgeInsets.fromLTRB(conProyecto ? 8 : 16, 12, 16, 12),
        child: Row(children: [
          if (conProyecto)
            Checkbox(
              value: usado,
              semanticLabel: textos.invLoUsa,
              onChanged: _gestiona
                  ? (valor) => _cambiarUso(bien, valor ?? false)
                  : null,
            ),
          if (conProyecto) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bien.nombre,
                    style: estilos.titleMedium?.copyWith(
                        color: apagado ? esquema.onSurfaceVariant : null)),
                Text(detalle,
                    style: estilos.bodyMedium
                        ?.copyWith(color: esquema.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${eurosDesdeCentimos(cuota.round())} €',
                style: estilos.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: apagado ? esquema.onSurfaceVariant : null)),
            Text(textos.invPorMes,
                style: estilos.bodySmall
                    ?.copyWith(color: esquema.onSurfaceVariant)),
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final grupos = partidasDe(categoriaAmortizacion);
    final proyecto = _proyecto;
    final codigosGrupo = [
      ...grupos.map((opcion) => opcion.codigo),
      // Por si llega un grupo que esta versión no conoce.
      ..._bienes
          .map((bien) => bien.grupo)
          .where((codigo) => buscarOpcion(grupos, codigo) == null)
          .toSet(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(textos.invTitulo),
          if (proyecto != null && proyecto.nombre.isNotEmpty)
            Text(proyecto.nombre,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.esquemaZunbeltz.onSurfaceVariant)),
        ]),
      ),
      floatingActionButton: _gestiona
          ? FloatingActionButton.extended(
              onPressed: () => _editar(),
              icon: const Icon(Icons.add),
              label: Text(textos.invNuevo),
            )
          : null,
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : CuerpoResponsivo(
              child: ListView(
                padding: rellenoSobreBarraSistema(
                    context, const EdgeInsets.fromLTRB(16, 8, 16, 96)),
                children: [
                  if (proyecto != null) ...[
                    _cabecera(textos),
                    const SizedBox(height: 16),
                  ],
                  Text(textos.invIntro,
                      style: Theme.of(context).textTheme.bodyLarge),
                  if (_bienes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(textos.invVacio),
                    ),
                  for (final grupo in codigosGrupo)
                    if (_bienes.any((bien) => bien.grupo == grupo))
                      _grupo(
                          grupo,
                          _bienes.where((bien) => bien.grupo == grupo).toList(),
                          idioma,
                          textos),
                ],
              ),
            ),
    );
  }
}

/// «2 × 11.375,42 € · total 27.528,50 € · 382,34 € al mes».
String resumenBien(AppLocalizations textos, BienAmortizable bien) =>
    textos.invResumen(
      numeroLegible(bien.unidades),
      '${eurosDesdeCentimos(bien.precioUnidadCentimos)} €',
      '${eurosDesdeCentimos(bien.totalCentimos)} €',
      '${eurosDesdeCentimos(bien.cuotaMensualCentimos.round())} €',
    );

/// 2 → «2»; 2,5 → «2,5».
String numeroLegible(double numero) => numero == numero.roundToDouble()
    ? numero.toStringAsFixed(0)
    : numero
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll('.', ',');

/// Alta o edición de un bien del inventario.
class FormularioBienAmortizable extends StatefulWidget {
  const FormularioBienAmortizable({super.key, this.bien});

  final BienAmortizable? bien;

  @override
  State<FormularioBienAmortizable> createState() =>
      _FormularioBienAmortizableState();
}

class _FormularioBienAmortizableState extends State<FormularioBienAmortizable> {
  final _bd = BaseDatosSoleraZunbeltz();
  late final _nombre = TextEditingController(text: widget.bien?.nombre ?? '');
  late final _precio = TextEditingController(
      text: widget.bien == null
          ? ''
          : eurosDesdeCentimos(widget.bien!.precioUnidadCentimos));
  late final _unidades =
      TextEditingController(text: numeroLegible(widget.bien?.unidades ?? 1));
  late final _vidaUtil =
      TextEditingController(text: '${widget.bien?.vidaUtilMeses ?? 72}');
  late final _notas = TextEditingController(text: widget.bien?.notas ?? '');
  late String _grupo = widget.bien?.grupo ?? grupoBienPorDefecto;
  late String _especie = widget.bien?.especie ?? '';
  late int _iva = widget.bien?.ivaPorcentaje ?? 21;
  bool _guardando = false;

  @override
  void dispose() {
    for (final controlador in [
      _nombre,
      _precio,
      _unidades,
      _vidaUtil,
      _notas
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  /// El bien tal como está escrito (para la vista previa y para guardar).
  BienAmortizable get _bienEscrito => BienAmortizable(
        id: widget.bien?.id,
        nombre: _nombre.text.trim(),
        grupo: _grupo,
        especie: _especie,
        precioUnidadCentimos: centimosDesdeTexto(_precio.text) ?? 0,
        unidades: leerNumero(_unidades.text) ?? 1,
        ivaPorcentaje: _iva,
        vidaUtilMeses: int.tryParse(_vidaUtil.text.trim()) ?? 0,
        notas: _notas.text.trim(),
      );

  void _avisar(String mensaje) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(mensaje)));

  Future<void> _guardar() async {
    if (_guardando) return;
    final textos = AppLocalizations.of(context);
    final bien = _bienEscrito;
    if (bien.nombre.isEmpty) return _avisar(textos.invNombreObligatorio);
    final precio = centimosDesdeTexto(_precio.text);
    if (precio == null || precio <= 0) {
      return _avisar(textos.apuImporteObligatorio);
    }
    if (bien.vidaUtilMeses < 1) return _avisar(textos.invVidaUtilObligatoria);
    setState(() => _guardando = true);
    try {
      if (bien.id == null) {
        await _bd.guardarBien(bien);
      } else {
        await _bd.actualizarBien(bien);
      }
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final vistaPrevia = _bienEscrito;
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.bien == null ? textos.invNuevo : textos.invEditar)),
      body: CuerpoResponsivo(
        child: ListView(
          padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
          children: [
            TextField(
              controller: _nombre,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: textos.invNombre),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue:
                  buscarOpcion(partidasDe(categoriaAmortizacion), _grupo) ==
                          null
                      ? grupoBienPorDefecto
                      : _grupo,
              decoration: InputDecoration(labelText: textos.invGrupo),
              items: [
                for (final opcion in partidasDe(categoriaAmortizacion))
                  DropdownMenuItem(
                      value: opcion.codigo,
                      child: Text(opcion.etiqueta(idioma))),
              ],
              onChanged: (valor) => setState(() => _grupo = valor ?? _grupo),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: buscarOpcion(especiesGanado, _especie) == null
                  ? ''
                  : _especie,
              decoration: InputDecoration(labelText: textos.invEspecie),
              items: [
                DropdownMenuItem(
                    value: '', child: Text(textos.invEspecieComun)),
                for (final especie in especiesGanado)
                  DropdownMenuItem(
                      value: especie.codigo,
                      child: Text(especie.etiqueta(idioma))),
              ],
              onChanged: (valor) => setState(() => _especie = valor ?? ''),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _precio,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: textos.invPrecioUnidad, suffixText: '€'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _unidades,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: textos.invUnidades),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: tiposIva.contains(_iva) ? _iva : 21,
                  decoration: InputDecoration(labelText: textos.apuIva),
                  items: [
                    for (final tipo in tiposIva)
                      DropdownMenuItem(value: tipo, child: Text('$tipo %')),
                  ],
                  onChanged: (valor) => setState(() => _iva = valor ?? _iva),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _vidaUtil,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: textos.invVidaUtil),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(children: [
                  Row(children: [
                    Expanded(child: Text(textos.invTotal)),
                    Text('${eurosDesdeCentimos(vistaPrevia.totalCentimos)} €'),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(child: Text(textos.invCuotaMensual)),
                    Text(
                        '${eurosDesdeCentimos(vistaPrevia.cuotaMensualCentimos.round())} €',
                        style: Theme.of(context).textTheme.titleMedium),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notas,
              maxLines: 2,
              decoration: InputDecoration(labelText: textos.apuNotas),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save),
              label: Text(textos.comunGuardar),
            ),
          ],
        ),
      ),
    );
  }
}
