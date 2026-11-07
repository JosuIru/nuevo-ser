import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show DialogoConfirmacion, SoleraL10n;

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_denominaciones_pan.dart';
import '../dominio/comprobacion_denominacion.dart';
import '../dominio/composicion_receta.dart';
import '../estado/cambios_datos.dart';
import '../modelos/ingrediente.dart';
import '../modelos/receta.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_ficha_tecnica_pdf.dart';
import '../utiles/textos_obrador.dart';

/// Todo lo que hace falta para calcular composiciones de una vez.
class _Recetario {
  _Recetario(this.recetas, this.lineas, this.ingredientes);

  final Map<int, Receta> recetas;
  final Map<int, List<LineaReceta>> lineas;
  final Map<int, Ingrediente> ingredientes;

  static Future<_Recetario> cargar() async {
    final baseDatos = BaseDatosSoleraObrador.instancia;
    return _Recetario(
      {
        for (final receta in await baseDatos.listarRecetas()) receta.id!: receta
      },
      await baseDatos.lineasPorReceta(),
      {
        for (final ingrediente in await baseDatos.listarIngredientes())
          ingrediente.id!: ingrediente
      },
    );
  }

  /// Null si la receta tiene un error (se contiene a sí misma…).
  ComposicionReceta? composicion(int recetaId) {
    try {
      return ComposicionReceta.calcular(
          recetaId: recetaId,
          recetas: recetas,
          lineasPorReceta: lineas,
          ingredientes: ingredientes);
    } on StateError {
      return null;
    }
  }
}

class PantallaRecetas extends StatefulWidget {
  const PantallaRecetas({super.key});

  @override
  State<PantallaRecetas> createState() => _PantallaRecetasState();
}

class _PantallaRecetasState extends State<PantallaRecetas> {
  late Future<_Recetario> _recetario;

  @override
  void initState() {
    super.initState();
    _recetario = _Recetario.cargar();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() => setState(() {
        _recetario = _Recetario.cargar();
      });

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('obra.recetas'))),
      floatingActionButton: FloatingActionButton(
        tooltip: SoleraL10n.t('obra.nueva_receta'),
        onPressed: () => _abrir(const PantallaEditarReceta()),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<_Recetario>(
        future: _recetario,
        builder: (context, instantanea) {
          final recetario = instantanea.data;
          if (recetario == null)
            return const Center(child: CircularProgressIndicator());
          if (recetario.recetas.isEmpty) {
            return Center(child: Text(SoleraL10n.t('obra.sin_recetas')));
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              for (final receta in recetario.recetas.values)
                Builder(builder: (context) {
                  final composicion = recetario.composicion(receta.id!);
                  return ListTile(
                    leading: Icon(receta.esSubreceta
                        ? Icons.layers_outlined
                        : Icons.bakery_dining_outlined),
                    title: Text(receta.nombre),
                    subtitle: Text(composicion == null
                        ? SoleraL10n.t('obra.error_receta')
                        : composicion.alergenos.isEmpty
                            ? SoleraL10n.t('obra.sin_alergenos')
                            : composicion.alergenos
                                .map(nombreAlergeno)
                                .join(', ')),
                    trailing: composicion == null || receta.esSubreceta
                        ? null
                        : Text(formatearEuros(composicion.costeCentimosPieza)),
                    onTap: () =>
                        _abrir(PantallaFichaReceta(recetaId: receta.id!)),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

/// Ficha técnica: composición calculada de la receta.
class PantallaFichaReceta extends StatefulWidget {
  const PantallaFichaReceta({super.key, required this.recetaId});

  final int recetaId;

  @override
  State<PantallaFichaReceta> createState() => _PantallaFichaRecetaState();
}

class _PantallaFichaRecetaState extends State<PantallaFichaReceta> {
  late Future<_Recetario> _recetario = _Recetario.cargar();

  Future<void> _editar(Receta receta, List<LineaReceta> lineas) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                PantallaEditarReceta(receta: receta, lineas: lineas)));
    setState(() {
      _recetario = _Recetario.cargar();
    });
  }

  Future<void> _borrar(Receta receta) async {
    final confirmado = await DialogoConfirmacion.mostrar(context,
        titulo: SoleraL10n.t('obra.borrar_receta'),
        mensaje: receta.nombre,
        esPeligroso: true);
    if (!confirmado) return;
    try {
      await BaseDatosSoleraObrador.instancia.borrarReceta(receta.id!);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(SoleraL10n.t('obra.receta_en_uso'))));
      }
      return;
    }
    avisarCambioDatos();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Recetario>(
      future: _recetario,
      builder: (context, instantanea) {
        final recetario = instantanea.data;
        final receta = recetario?.recetas[widget.recetaId];
        if (recetario == null || receta == null) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()));
        }
        final composicion = recetario.composicion(receta.id!);
        final estilo = Theme.of(context).textTheme;
        return Scaffold(
          appBar: AppBar(
            title: Text(receta.nombre),
            actions: [
              if (composicion != null)
                IconButton(
                  tooltip: SoleraL10n.t('obra.ficha_tecnica'),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  onPressed: () => compartirDocumentoPdf(
                    context,
                    nombreFichero: 'ficha_${receta.id}.pdf',
                    generar: (tema) async => generarFichaTecnicaPdf(
                      receta: receta,
                      composicion: composicion,
                      ingredientes: recetario.ingredientes,
                      titular: await BaseDatosSoleraObrador.instancia
                          .obtenerTitular(),
                      tema: tema,
                    ),
                  ),
                ),
              IconButton(
                tooltip: SoleraL10n.t('editar'),
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    _editar(receta, recetario.lineas[receta.id] ?? const []),
              ),
              IconButton(
                tooltip: SoleraL10n.t('borrar'),
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _borrar(receta),
              ),
            ],
          ),
          body: composicion == null
              ? Center(child: Text(SoleraL10n.t('obra.error_receta')))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(SoleraL10n.t('obra.alergenos'),
                        style: estilo.titleSmall),
                    Text(composicion.alergenos.isEmpty
                        ? SoleraL10n.t('obra.sin_alergenos')
                        : composicion.alergenos.map(nombreAlergeno).join(', ')),
                    if (composicion.trazas.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(SoleraL10n.t('obra.trazas'),
                          style: estilo.titleSmall),
                      Text(composicion.trazas.map(nombreAlergeno).join(', ')),
                    ],
                    const SizedBox(height: 16),
                    Text(SoleraL10n.t('obra.ingredientes_por_peso'),
                        style: estilo.titleSmall),
                    Text(composicion.ingredientesPorPeso
                        .map((id) => recetario.ingredientes[id]!.nombre)
                        .join(', ')),
                    const Divider(height: 32),
                    _Dato(SoleraL10n.t('obra.piezas_por_masa'),
                        '${composicion.piezas}'),
                    _Dato(SoleraL10n.t('obra.peso_pieza'),
                        '${formatearNumero(composicion.gramosPorPieza, decimales: 0)} g'),
                    if (!receta.esSubreceta)
                      _Dato(SoleraL10n.t('obra.coste_pieza'),
                          formatearEuros(composicion.costeCentimosPieza)),
                    _Dato(SoleraL10n.t('obra.sal_estimada'),
                        '${formatearNumero(composicion.salEstimadaGramosPor100g, decimales: 2)} g / 100 g'),
                    if (denominacionPorId(receta.denominacion)
                        case final denominacion?) ...[
                      const Divider(height: 32),
                      Text(
                          '${denominacion.nombre} (RD 308/2019, ${denominacion.articulo})',
                          style: estilo.titleSmall),
                      Text(denominacion.requisito, style: estilo.bodySmall),
                      if (salSuperaMaximo(composicion, receta.denominacion))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(SoleraL10n.t('obra.aviso_sal_maxima'),
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error)),
                        ),
                    ],
                    const SizedBox(height: 16),
                    Text(SoleraL10n.t('obra.aviso_estimacion'),
                        style: estilo.bodySmall),
                  ],
                ),
        );
      },
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [Expanded(child: Text(etiqueta)), Text(valor)]),
      );
}

/// Alta o edición de una receta con sus líneas.
class PantallaEditarReceta extends StatefulWidget {
  const PantallaEditarReceta({super.key, this.receta, this.lineas = const []});

  final Receta? receta;
  final List<LineaReceta> lineas;

  @override
  State<PantallaEditarReceta> createState() => _PantallaEditarRecetaState();
}

/// Línea en edición: `i<id>` para un ingrediente, `r<id>` para una subreceta.
class _LineaEditable {
  _LineaEditable(this.origen, String gramos)
      : gramos = TextEditingController(text: gramos);

  String? origen;
  final TextEditingController gramos;
}

class _PantallaEditarRecetaState extends State<PantallaEditarReceta> {
  late final _nombre = TextEditingController(text: widget.receta?.nombre ?? '');
  late final _piezas =
      TextEditingController(text: '${widget.receta?.piezasPorMasa ?? 1}');
  late final _merma = TextEditingController(
      text: formatearNumero(widget.receta?.mermaCoccionPorcentaje ?? 0));
  late bool _esSubreceta = widget.receta?.esSubreceta ?? false;
  late String _denominacion = widget.receta?.denominacion ?? '';
  late final List<_LineaEditable> _lineas = [
    for (final linea in widget.lineas)
      _LineaEditable(
          linea.ingredienteId != null
              ? 'i${linea.ingredienteId}'
              : 'r${linea.subrecetaId}',
          formatearNumero(linea.gramos, decimales: 0)),
  ];
  late final Future<_Recetario> _recetario = _Recetario.cargar();
  bool _guardando = false;

  @override
  void dispose() {
    for (final controlador in [
      _nombre,
      _piezas,
      _merma,
      for (final linea in _lineas) linea.gramos
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_guardando || _nombre.text.trim().isEmpty) return;
    setState(() {
      _guardando = true;
    });
    final baseDatos = BaseDatosSoleraObrador.instancia;
    final recetaId = await baseDatos.guardarReceta(Receta(
      id: widget.receta?.id,
      nombre: _nombre.text.trim(),
      denominacion: _denominacion,
      piezasPorMasa: int.tryParse(_piezas.text.trim()) ?? 1,
      mermaCoccionPorcentaje: leerNumero(_merma.text) ?? 0,
      esSubreceta: _esSubreceta,
      precioVentaCentimosPieza: widget.receta?.precioVentaCentimosPieza ?? 0,
      notas: widget.receta?.notas ?? '',
    ));
    final lineas = <LineaReceta>[
      for (final linea in _lineas)
        if (linea.origen != null && (leerNumero(linea.gramos.text) ?? 0) > 0)
          LineaReceta(
            recetaId: recetaId,
            ingredienteId: linea.origen!.startsWith('i')
                ? int.parse(linea.origen!.substring(1))
                : null,
            subrecetaId: linea.origen!.startsWith('r')
                ? int.parse(linea.origen!.substring(1))
                : null,
            gramos: leerNumero(linea.gramos.text)!,
          ),
    ];
    await baseDatos.guardarLineasReceta(recetaId, lineas);
    avisarCambioDatos();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receta?.nombre ?? SoleraL10n.t('obra.nueva_receta')),
      ),
      body: FutureBuilder<_Recetario>(
        future: _recetario,
        builder: (context, instantanea) {
          final recetario = instantanea.data;
          if (recetario == null)
            return const Center(child: CircularProgressIndicator());
          final opciones = <DropdownMenuItem<String>>[
            for (final ingrediente in recetario.ingredientes.values)
              DropdownMenuItem(
                  value: 'i${ingrediente.id}', child: Text(ingrediente.nombre)),
            for (final subreceta in recetario.recetas.values.where((receta) =>
                receta.esSubreceta && receta.id != widget.receta?.id))
              DropdownMenuItem(
                  value: 'r${subreceta.id}',
                  child: Text(
                      '${subreceta.nombre} (${SoleraL10n.t('obra.subreceta')})')),
          ];
          final valores = opciones.map((opcion) => opcion.value).toSet();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _nombre,
                decoration:
                    InputDecoration(labelText: SoleraL10n.t('obra.nombre')),
              ),
              TextField(
                controller: _piezas,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: SoleraL10n.t('obra.piezas_por_masa')),
              ),
              TextField(
                controller: _merma,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                    labelText: SoleraL10n.t('obra.merma_coccion')),
              ),
              DropdownButtonFormField<String>(
                initialValue: denominacionPorId(_denominacion) == null
                    ? ''
                    : _denominacion,
                isExpanded: true,
                decoration: InputDecoration(
                    labelText: SoleraL10n.t('obra.denominacion')),
                items: [
                  DropdownMenuItem(
                      value: '',
                      child: Text(SoleraL10n.t('obra.sin_denominacion'))),
                  for (final denominacion in catalogoDenominacionesPan)
                    DropdownMenuItem(
                        value: denominacion.id,
                        child: Text(denominacion.nombre)),
                ],
                onChanged: (valor) =>
                    setState(() => _denominacion = valor ?? ''),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(SoleraL10n.t('obra.es_subreceta')),
                value: _esSubreceta,
                onChanged: (valor) => setState(() => _esSubreceta = valor),
              ),
              const SizedBox(height: 8),
              Text(SoleraL10n.t('obra.lineas'),
                  style: Theme.of(context).textTheme.titleSmall),
              for (final linea in _lineas)
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: valores.contains(linea.origen)
                            ? linea.origen
                            : null,
                        hint: Text(SoleraL10n.t('obra.ingrediente')),
                        items: opciones,
                        onChanged: (valor) =>
                            setState(() => linea.origen = valor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: linea.gramos,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                            suffixText: 'g',
                            hintText: SoleraL10n.t('obra.gramos')),
                      ),
                    ),
                    IconButton(
                      tooltip: SoleraL10n.t('borrar'),
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        _lineas.remove(linea);
                        linea.gramos.dispose();
                      }),
                    ),
                  ],
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () =>
                      setState(() => _lineas.add(_LineaEditable(null, ''))),
                  icon: const Icon(Icons.add),
                  label: Text(SoleraL10n.t('obra.anadir_linea')),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: Text(SoleraL10n.t('guardar')),
              ),
            ],
          );
        },
      ),
    );
  }
}
