import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_plagas_apicolas.dart';
import '../datos/catalogos_generados/catalogo_sustancias_varroa.dart';
import '../modelos/apiario.dart';
import '../modelos/cosecha_miel.dart';
import '../modelos/incidencia_apicola.dart';
import '../modelos/movimiento.dart';
import '../modelos/revision.dart';
import '../modelos/tratamiento_varroa.dart';
import '../utiles/etiquetas_visibles.dart';
import 'widgets/boton_identificar_ia.dart';

/// Tipo de evento que crea esta pantalla. Apícola tiene 5 tipos —
/// uno más que viticultura (Movimiento), por la trashumancia que es
/// el evento más característico del oficio.
enum TipoEventoNuevo { revision, cosecha, tratamiento, incidencia, movimiento }

class PantallaNuevoEvento extends StatefulWidget {
  final int colmenaId;
  final TipoEventoNuevo tipo;

  PantallaNuevoEvento({super.key, required this.colmenaId, required this.tipo});

  @override
  State<PantallaNuevoEvento> createState() => _PantallaNuevoEventoState();
}

class _PantallaNuevoEventoState extends State<PantallaNuevoEvento> {
  final _claveFormulario = GlobalKey<FormState>();

  // Comunes
  DateTime _fecha = DateTime.now();
  final _controladorNotas = TextEditingController();
  List<String> _rutasFotos = [];

  // Revisión
  String _presenciaReina = 'no_observada';
  int? _nivelPostura;
  int? _nivelCriaOperculada;
  int? _nivelMiel;
  int? _nivelPolen;
  final _controladorVarroaCaida = TextEditingController();

  // Cosecha de miel
  final _controladorKilosMiel = TextEditingController();
  final _controladorKilosCera = TextEditingController();
  final _controladorKilosPolen = TextEditingController();
  final _controladorKilosPropoleo = TextEditingController();
  final _controladorAlza = TextEditingController();

  // Tratamiento varroa
  String _tipoTratamiento = 'varroa';
  final _controladorSustancia = TextEditingController();
  final _controladorDosis = TextEditingController();
  String _vehiculo = 'sublimacion';
  final _controladorPlazoSeguridad = TextEditingController();
  final _controladorLote = TextEditingController();
  final _controladorFactura = TextEditingController();
  DateTime? _fechaRetirada;

  // Incidencia
  String _tipoIncidencia = 'sanitario';
  final _controladorDiagnostico = TextEditingController();
  int? _severidad;

  // Movimiento
  List<Apiario> _apiariosDisponibles = [];
  int? _apiarioOrigenId;
  int? _apiarioDestinoId;
  String _motivoMovimiento = 'mielada';
  final _controladorNumeroColmenas = TextEditingController(text: '1');

  bool _guardando = false;

  String get _titulo {
    switch (widget.tipo) {
      case TipoEventoNuevo.revision:
        return SoleraL10n.t('api.nueva_revision');
      case TipoEventoNuevo.cosecha:
        return SoleraL10n.t('api.nueva_cosecha');
      case TipoEventoNuevo.tratamiento:
        return SoleraL10n.t('api.nuevo_tratamiento');
      case TipoEventoNuevo.incidencia:
        return SoleraL10n.t('api.nueva_incidencia');
      case TipoEventoNuevo.movimiento:
        return SoleraL10n.t('api.nuevo_movimiento');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.tipo == TipoEventoNuevo.movimiento) {
      _cargarApiarios();
    }
    if (widget.tipo == TipoEventoNuevo.incidencia) {
      // Necesario: RawAutocomplete sólo notifica al padre vía `onSelected`
      // (cuando el usuario PULSA un item del menú), no cuando TECLEA.
      // El banner rojo de declaración obligatoria depende del texto crudo,
      // no de la selección — sin este listener el banner nunca aparece
      // al teclear "loque americana" letra a letra. NO eliminar.
      _controladorDiagnostico.addListener(_alCambiarDiagnostico);
    }
    if (widget.tipo == TipoEventoNuevo.tratamiento) {
      // Auto-rellenar plazo de seguridad cuando el apicultor selecciona una
      // sustancia del catálogo.
      _controladorSustancia.addListener(_alCambiarSustancia);
    }
  }

  void _alCambiarDiagnostico() {
    if (mounted) setState(() {});
  }

  void _alCambiarSustancia() {
    final sustancia = _resolverSustanciaPorTexto(_controladorSustancia.text);
    if (sustancia != null && _controladorPlazoSeguridad.text.isEmpty) {
      _controladorPlazoSeguridad.text = sustancia.plazoSeguridadDias.toString();
    }
  }

  /// Resuelve una sustancia del catálogo por nombre canónico o id.
  /// Devuelve null para texto libre que no matcha ninguna entrada.
  SustanciaVarroa? _resolverSustanciaPorTexto(String texto) {
    final consultaNormalizada = texto.trim().toLowerCase();
    if (consultaNormalizada.isEmpty) return null;
    for (final s in catalogoSustanciasVarroa) {
      if (s.id == consultaNormalizada) return s;
      if (s.nombreCanonico.toLowerCase() == consultaNormalizada) return s;
    }
    return null;
  }

  /// Resuelve una plaga del catálogo por nombre común o id. Devuelve null
  /// para texto libre.
  PlagaApicola? _resolverPlagaPorTexto(String texto) {
    final consultaNormalizada = texto.trim().toLowerCase();
    if (consultaNormalizada.isEmpty) return null;
    for (final p in catalogoPlagasApicolas) {
      if (p.id == consultaNormalizada) return p;
      if (p.nombreComun.toLowerCase() == consultaNormalizada) return p;
    }
    return null;
  }

  /// `true` si el texto del diagnóstico coincide con una patología del catálogo
  /// que requiere notificación a Servicios Veterinarios oficiales (loque
  /// americana, escarabajo de las colmenas, vespa velutina).
  bool _consultarDeclaracionObligatoria(String texto) {
    final consultaNormalizada = texto.trim().toLowerCase();
    if (consultaNormalizada.isEmpty) return false;
    for (final p in catalogoPlagasApicolas) {
      if (!p.declaracionOficial) continue;
      if (p.nombreComun.toLowerCase() == consultaNormalizada) return true;
      if (p.id == consultaNormalizada) return true;
    }
    return false;
  }

  Future<void> _cargarApiarios() async {
    final ap = await BaseDatosSoleraApicola.instancia.listarApiarios();
    if (!mounted) return;
    setState(() => _apiariosDisponibles = ap);
  }

  @override
  void dispose() {
    if (widget.tipo == TipoEventoNuevo.incidencia) {
      _controladorDiagnostico.removeListener(_alCambiarDiagnostico);
    }
    if (widget.tipo == TipoEventoNuevo.tratamiento) {
      _controladorSustancia.removeListener(_alCambiarSustancia);
    }
    for (final c in [
      _controladorNotas, _controladorVarroaCaida,
      _controladorKilosMiel, _controladorKilosCera, _controladorKilosPolen,
      _controladorKilosPropoleo, _controladorAlza,
      _controladorSustancia, _controladorDosis, _controladorPlazoSeguridad,
      _controladorLote, _controladorFactura,
      _controladorDiagnostico, _controladorNumeroColmenas,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (fecha != null) setState(() => _fecha = fecha);
  }

  Future<void> _elegirFechaRetirada() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaRetirada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 90)),
    );
    if (fecha != null) setState(() => _fechaRetirada = fecha);
  }

  Future<void> _guardar() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    final db = BaseDatosSoleraApicola.instancia;
    final fechaMs = _fecha.millisecondsSinceEpoch;
    final fotosJson = GestorFotos.codificar(_rutasFotos);
    final notas = _controladorNotas.text.trim();

    switch (widget.tipo) {
      case TipoEventoNuevo.revision:
        await db.guardarRevision(Revision(
          colmenaId: widget.colmenaId,
          fechaMs: fechaMs,
          presenciaReina: _presenciaReina,
          nivelPostura: _nivelPostura,
          nivelCriaOperculada: _nivelCriaOperculada,
          nivelMiel: _nivelMiel,
          nivelPolen: _nivelPolen,
          varroaCaidaDiaria: int.tryParse(_controladorVarroaCaida.text.trim()),
          rutasFotosJson: fotosJson,
          notas: notas,
        ));
        break;
      case TipoEventoNuevo.cosecha:
        await db.guardarCosechaMiel(CosechaMiel(
          colmenaId: widget.colmenaId,
          fechaMs: fechaMs,
          kilosMiel: leerNumero(_controladorKilosMiel.text, nullSiAmbiguo: true),
          kilosCera: leerNumero(_controladorKilosCera.text, nullSiAmbiguo: true),
          kilosPolen: leerNumero(_controladorKilosPolen.text, nullSiAmbiguo: true),
          kilosPropoleo: leerNumero(_controladorKilosPropoleo.text, nullSiAmbiguo: true),
          numeroAlza: int.tryParse(_controladorAlza.text),
          rutasFotosJson: fotosJson,
          notas: notas,
        ));
        break;
      case TipoEventoNuevo.tratamiento:
        final sustancia = _resolverSustanciaPorTexto(_controladorSustancia.text);
        final idSustancia = sustancia?.id ?? _controladorSustancia.text.trim().toLowerCase();
        await db.guardarTratamientoVarroa(TratamientoVarroa(
          colmenaId: widget.colmenaId,
          fechaAplicacionMs: fechaMs,
          fechaRetiradaMs: _fechaRetirada?.millisecondsSinceEpoch,
          tipo: _tipoTratamiento,
          sustanciaActivaId: idSustancia,
          dosis: _controladorDosis.text.trim(),
          vehiculo: _vehiculo,
          plazoSeguridadDias: int.tryParse(_controladorPlazoSeguridad.text),
          loteProducto: _controladorLote.text.trim(),
          numeroFactura: _controladorFactura.text.trim(),
          notas: notas,
        ));
        break;
      case TipoEventoNuevo.incidencia:
        final plaga = _resolverPlagaPorTexto(_controladorDiagnostico.text);
        final diagnosticoFinal = plaga?.id ?? _controladorDiagnostico.text.trim();
        // Si la plaga del catálogo coincide con un id especial (polilla_cera,
        // vespa_velutina, robo) se respeta el mapeo; para sanitarios el dropdown
        // del usuario manda.
        final tipoFinal = plaga != null && _tipoIncidencia == 'sanitario'
            ? tipoIncidenciaParaBd(plaga)
            : _tipoIncidencia;
        await db.guardarIncidencia(IncidenciaApicola(
          colmenaId: widget.colmenaId,
          fechaMs: fechaMs,
          tipo: tipoFinal,
          diagnostico: diagnosticoFinal,
          severidad: _severidad,
          rutasFotosJson: fotosJson,
          notas: notas,
        ));
        break;
      case TipoEventoNuevo.movimiento:
        await db.guardarMovimiento(Movimiento(
          colmenaId: widget.colmenaId,
          apiarioOrigenId: _apiarioOrigenId,
          apiarioDestinoId: _apiarioDestinoId,
          fechaMovimientoMs: fechaMs,
          motivo: _motivoMovimiento,
          numeroColmenas: int.tryParse(_controladorNumeroColmenas.text) ?? 1,
          notas: notas,
        ));
        break;
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(title: Text(_titulo)),
      body: Form(
        key: _claveFormulario,
        child: CuerpoResponsivoSolera(child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.event),
              title: Text(formatoFecha.format(_fecha)),
              trailing: TextButton(onPressed: _elegirFecha, child: Text(SoleraL10n.t('api.cambiar'))),
            ),
            Divider(),
            ..._camposEspecificos(),
            SizedBox(height: 12),
            if (widget.tipo == TipoEventoNuevo.revision ||
                widget.tipo == TipoEventoNuevo.cosecha ||
                widget.tipo == TipoEventoNuevo.incidencia) ...[
              Text(SoleraL10n.t('api.fotos'), style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              SelectorFotos(rutas: _rutasFotos, alCambiar: (r) => setState(() => _rutasFotos = r)),
              SizedBox(height: 12),
            ],
            TextFormField(
              controller: _controladorNotas,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('api.notas'),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        )),
      ),
      bottomNavigationBar: BarraGuardarSolera(botones: [
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: textoOGuardando(SoleraL10n.t('guardar'), guardando: _guardando),
        ),
      ]),
    );
  }

  List<Widget> _camposEspecificos() {
    switch (widget.tipo) {
      case TipoEventoNuevo.revision:
        return [
          DropdownButtonFormField<String>(
            initialValue: _presenciaReina,
            decoration: InputDecoration(labelText: SoleraL10n.t('api.reina'), border: OutlineInputBorder()),
            items: [
              DropdownMenuItem(value: 'presente', child: Text(etiquetaPresenciaReina('presente'))),
              DropdownMenuItem(value: 'ausente', child: Text(etiquetaPresenciaReina('ausente'))),
              DropdownMenuItem(value: 'no_observada', child: Text(etiquetaPresenciaReina('no_observada'))),
            ],
            onChanged: (v) => setState(() => _presenciaReina = v ?? 'no_observada'),
          ),
          SizedBox(height: 12),
          _selectorNumero1A5(SoleraL10n.t('api.postura'), _nivelPostura, (v) => setState(() => _nivelPostura = v)),
          SizedBox(height: 8),
          _selectorNumero1A5(SoleraL10n.t('api.cria_operculada'), _nivelCriaOperculada, (v) => setState(() => _nivelCriaOperculada = v)),
          SizedBox(height: 8),
          _selectorNumero1A5(SoleraL10n.t('api.reservas_de_miel'), _nivelMiel, (v) => setState(() => _nivelMiel = v)),
          SizedBox(height: 8),
          _selectorNumero1A5(SoleraL10n.t('api.reservas_de_polen'), _nivelPolen, (v) => setState(() => _nivelPolen = v)),
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorVarroaCaida,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('api.varroa_caida_dia'),
              hintText: SoleraL10n.t('api.recuento_en_24_h'),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ];
      case TipoEventoNuevo.cosecha:
        return [
          TextFormField(
            controller: _controladorKilosMiel,
            decoration: InputDecoration(labelText: SoleraL10n.t('api.kilos_de_miel'), border: OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
            validator: (texto) =>
                validarNumeroOpcional(texto, nullSiAmbiguo: true),
          ),
          SizedBox(height: separacionCamposSolera),
          TextFormField(
            controller: _controladorKilosCera,
            decoration: InputDecoration(labelText: SoleraL10n.t('api.kilos_de_cera'), border: OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
            validator: (texto) =>
                validarNumeroOpcional(texto, nullSiAmbiguo: true),
          ),
          SizedBox(height: separacionCamposSolera),
          TextFormField(
            controller: _controladorKilosPolen,
            decoration: InputDecoration(labelText: SoleraL10n.t('api.kilos_de_polen'), border: OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
            validator: (texto) =>
                validarNumeroOpcional(texto, nullSiAmbiguo: true),
          ),
          SizedBox(height: separacionCamposSolera),
          TextFormField(
            controller: _controladorKilosPropoleo,
            decoration: InputDecoration(labelText: SoleraL10n.t('api.kilos_de_propoleo'), border: OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
            validator: (texto) =>
                validarNumeroOpcional(texto, nullSiAmbiguo: true),
          ),
          SizedBox(height: separacionCamposSolera),
          TextFormField(
            controller: _controladorAlza,
            decoration: InputDecoration(labelText: SoleraL10n.t('api.numero_alza_opcional'), border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ];
      case TipoEventoNuevo.tratamiento:
        final formatoFecha = DateFormat('dd/MM/yyyy');
        return [
          DropdownButtonFormField<String>(
            initialValue: _tipoTratamiento,
            decoration: InputDecoration(labelText: SoleraL10n.t('api.tipo'), border: OutlineInputBorder()),
            items: [
              DropdownMenuItem(value: 'varroa', child: Text(etiquetaTipoTratamiento('varroa'))),
              DropdownMenuItem(value: 'nosema', child: Text(etiquetaTipoTratamiento('nosema'))),
              DropdownMenuItem(value: 'sanitario_general', child: Text(etiquetaTipoTratamiento('sanitario_general'))),
              DropdownMenuItem(value: 'otro', child: Text(etiquetaTipoTratamiento('otro'))),
            ],
            onChanged: (v) => setState(() => _tipoTratamiento = v ?? 'otro'),
          ),
          SizedBox(height: separacionCamposSolera),
          CampoAutocompleteCatalogo<SustanciaVarroa>(
            controlador: _controladorSustancia,
            labelText: SoleraL10n.t('api.sustancia_activa'),
            hintText: SoleraL10n.t('api.ejemplos_sustancia_activa'),
            opcionesCompletas: catalogoSustanciasVarroa,
            buscar: buscarSustanciasVarroa,
            displayStringForOption: (s) => s.nombreCanonico,
          ),
          SizedBox(height: separacionCamposSolera),
          TextFormField(
            controller: _controladorDosis,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('api.dosis'),
              hintText: SoleraL10n.t('api.ejemplos_dosis'),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: separacionCamposSolera),
          DropdownButtonFormField<String>(
            initialValue: _vehiculo,
            decoration: InputDecoration(labelText: SoleraL10n.t('api.vehiculo'), border: OutlineInputBorder()),
            items: [
              DropdownMenuItem(value: 'sublimacion', child: Text(SoleraL10n.t('api.vehiculo_sublimacion'))),
              DropdownMenuItem(value: 'goteo', child: Text(SoleraL10n.t('api.vehiculo_goteo'))),
              DropdownMenuItem(value: 'sandwich', child: Text(SoleraL10n.t('api.vehiculo_sandwich'))),
              DropdownMenuItem(value: 'tira', child: Text(SoleraL10n.t('api.vehiculo_tira'))),
              DropdownMenuItem(value: 'placa', child: Text(SoleraL10n.t('api.vehiculo_placa'))),
              DropdownMenuItem(value: 'otro', child: Text(SoleraL10n.t('api.otro'))),
            ],
            onChanged: (v) => setState(() => _vehiculo = v ?? 'otro'),
          ),
          SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.event_busy),
            title: Text(_fechaRetirada == null
                ? SoleraL10n.t('api.sin_fecha_de_retirada')
                : SoleraL10n.tf('api.retirada_fecha', {'fecha': formatoFecha.format(_fechaRetirada!)})),
            trailing: TextButton(
              onPressed: _elegirFechaRetirada,
              child: Text(_fechaRetirada == null ? SoleraL10n.t('api.elegir') : SoleraL10n.t('api.cambiar')),
            ),
          ),
          TextFormField(
            controller: _controladorPlazoSeguridad,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('api.plazo_de_seguridad_dias'),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SizedBox(height: separacionCamposSolera),
          TextFormField(
            controller: _controladorLote,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('api.lote_del_producto'),
              hintText: SoleraL10n.t('api.trazabilidad_sanitaria'),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: separacionCamposSolera),
          TextFormField(
            controller: _controladorFactura,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('api.numero_de_factura'),
              border: OutlineInputBorder(),
            ),
          ),
        ];
      case TipoEventoNuevo.incidencia:
        return [
          DropdownButtonFormField<String>(
            initialValue: _tipoIncidencia,
            decoration: InputDecoration(labelText: SoleraL10n.t('api.tipo'), border: OutlineInputBorder()),
            items: [
              DropdownMenuItem(value: 'sanitario', child: Text(etiquetaTipoIncidencia('sanitario'))),
              DropdownMenuItem(value: 'mortalidad', child: Text(etiquetaTipoIncidencia('mortalidad'))),
              DropdownMenuItem(value: 'enjambrazon', child: Text(etiquetaTipoIncidencia('enjambrazon'))),
              DropdownMenuItem(value: 'robo', child: Text(etiquetaTipoIncidencia('robo'))),
              DropdownMenuItem(value: 'vespa_velutina', child: Text(etiquetaTipoIncidencia('vespa_velutina'))),
              DropdownMenuItem(value: 'polilla_cera', child: Text(etiquetaTipoIncidencia('polilla_cera'))),
              DropdownMenuItem(value: 'otro', child: Text(etiquetaTipoIncidencia('otro'))),
            ],
            onChanged: (v) => setState(() => _tipoIncidencia = v ?? 'otro'),
          ),
          SizedBox(height: separacionCamposSolera),
          CampoAutocompleteCatalogo<PlagaApicola>(
            controlador: _controladorDiagnostico,
            labelText: SoleraL10n.t('api.diagnostico'),
            hintText: SoleraL10n.t('api.ejemplos_diagnostico'),
            opcionesCompletas: catalogoPlagasApicolas,
            buscar: buscarPlagasApicolas,
            displayStringForOption: (p) => p.nombreComun,
            validator: (v) => (v ?? '').trim().isEmpty ? SoleraL10n.t('api.indica_el_diagnostico') : null,
          ),
          SizedBox(height: 8),
          BotonIdentificarIA(
            rutasFotos: _rutasFotos,
            observacionesUsuario: _controladorNotas.text,
            alAceptar: (datos) {
              setState(() {
                _tipoIncidencia = datos.tipo;
                _controladorDiagnostico.text = datos.diagnostico;
                if (datos.severidad != null) _severidad = datos.severidad;
                if (datos.notasAuto.isNotEmpty) {
                  final actual = _controladorNotas.text.trim();
                  _controladorNotas.text =
                      actual.isEmpty ? datos.notasAuto : '${datos.notasAuto}\n\n$actual';
                }
              });
            },
          ),
          if (_consultarDeclaracionObligatoria(_controladorDiagnostico.text)) ...[
            SizedBox(height: 8),
            BannerDeclaracionObligatoria(
              texto: SoleraL10n.t('api.patologia_declaracion_obligatoria_aviso'),
            ),
          ],
          SizedBox(height: 12),
          _selectorNumero1A5(SoleraL10n.t('api.severidad'), _severidad, (v) => setState(() => _severidad = v)),
        ];
      case TipoEventoNuevo.movimiento:
        return [
          DropdownButtonFormField<String>(
            initialValue: _motivoMovimiento,
            decoration: InputDecoration(labelText: SoleraL10n.t('api.motivo'), border: OutlineInputBorder()),
            items: [
              DropdownMenuItem(value: 'mielada', child: Text(etiquetaMotivoMovimiento('mielada'))),
              DropdownMenuItem(value: 'invernada', child: Text(etiquetaMotivoMovimiento('invernada'))),
              DropdownMenuItem(value: 'sanitario', child: Text(etiquetaMotivoMovimiento('sanitario'))),
              DropdownMenuItem(value: 'recogida_enjambre', child: Text(etiquetaMotivoMovimiento('recogida_enjambre'))),
              DropdownMenuItem(value: 'compra', child: Text(etiquetaMotivoMovimiento('compra'))),
              DropdownMenuItem(value: 'venta', child: Text(etiquetaMotivoMovimiento('venta'))),
              DropdownMenuItem(value: 'baja', child: Text(etiquetaMotivoMovimiento('baja'))),
              DropdownMenuItem(value: 'otro', child: Text(etiquetaMotivoMovimiento('otro'))),
            ],
            onChanged: (v) => setState(() => _motivoMovimiento = v ?? 'otro'),
          ),
          SizedBox(height: separacionCamposSolera),
          DropdownButtonFormField<int?>(
            initialValue: _apiarioOrigenId,
            decoration: InputDecoration(labelText: SoleraL10n.t('api.apiario_origen'), border: OutlineInputBorder()),
            items: [
              DropdownMenuItem<int?>(value: null, child: Text(SoleraL10n.t('api.ninguno_alta_captura_compra'))),
              for (final a in _apiariosDisponibles)
                DropdownMenuItem<int?>(value: a.id, child: Text(a.nombre)),
            ],
            onChanged: (v) => setState(() => _apiarioOrigenId = v),
          ),
          SizedBox(height: separacionCamposSolera),
          DropdownButtonFormField<int?>(
            initialValue: _apiarioDestinoId,
            decoration: InputDecoration(labelText: SoleraL10n.t('api.apiario_destino'), border: OutlineInputBorder()),
            items: [
              DropdownMenuItem<int?>(value: null, child: Text(SoleraL10n.t('api.ninguno_baja_venta'))),
              for (final a in _apiariosDisponibles)
                DropdownMenuItem<int?>(value: a.id, child: Text(a.nombre)),
            ],
            onChanged: (v) => setState(() => _apiarioDestinoId = v),
          ),
          SizedBox(height: separacionCamposSolera),
          TextFormField(
            controller: _controladorNumeroColmenas,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('api.numero_de_colmenas_movidas'),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ];
    }
  }

  Widget _selectorNumero1A5(String etiqueta, int? valor, ValueChanged<int?> alCambiar) {
    return Row(
      children: [
        SizedBox(width: 130, child: Text(etiqueta)),
        Expanded(
          child: SegmentedButton<int?>(
            segments: const [
              ButtonSegment(value: null, label: Text('—')),
              ButtonSegment(value: 1, label: Text('1')),
              ButtonSegment(value: 2, label: Text('2')),
              ButtonSegment(value: 3, label: Text('3')),
              ButtonSegment(value: 4, label: Text('4')),
              ButtonSegment(value: 5, label: Text('5')),
            ],
            selected: {valor},
            onSelectionChanged: (s) => alCambiar(s.first),
            showSelectedIcon: false,
          ),
        ),
      ],
    );
  }
}
