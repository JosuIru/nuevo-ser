import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_plagas_urbanas.dart';
import '../datos/catalogos_generados/catalogo_tipos_poda.dart';
import '../estado/zona_activa.dart';
import '../modelos/incidencia.dart';
import '../modelos/inspeccion.dart';
import '../modelos/poda.dart';
import '../modelos/tecnico.dart';
import '../modelos/tratamiento.dart';
import '../utiles/numeros_formulario.dart';
import 'widgets/boton_identificar_ia.dart';

/// Tipo de evento que crea esta pantalla. 4 tipos: arbolado urbano no
/// registra cosechas (al revés que viticultura/apícola) pero sí podas.
enum TipoEventoNuevo { inspeccion, poda, tratamiento, incidencia }

class PantallaNuevoEvento extends StatefulWidget {
  final int arbolId;
  final TipoEventoNuevo tipo;

  PantallaNuevoEvento({super.key, required this.arbolId, required this.tipo});

  @override
  State<PantallaNuevoEvento> createState() => _PantallaNuevoEventoState();
}

class _PantallaNuevoEventoState extends State<PantallaNuevoEvento> {
  final _claveFormulario = GlobalKey<FormState>();
  final _persistenciaTecnico = TecnicoActivoPersistido();

  // Comunes
  DateTime _fecha = DateTime.now();
  final _controladorNotas = TextEditingController();
  List<Tecnico> _tecnicosDisponibles = [];
  int? _tecnicoId;

  // Inspección
  String _estadoInspeccion = 'sano';
  int? _riesgoVtaInspeccion;
  final _controladorFenologia = TextEditingController();
  List<String> _rutasFotosInspeccion = [];

  // Poda
  final _controladorTipoPoda = TextEditingController();
  final _controladorVolumenRestos = TextEditingController();
  final _controladorMotivoPoda = TextEditingController();
  List<String> _rutasFotosAntes = [];
  List<String> _rutasFotosDespues = [];

  // Tratamiento
  final _controladorSustancia = TextEditingController();
  final _controladorDosis = TextEditingController();
  final _controladorMotivoPlaga = TextEditingController();
  final _controladorLote = TextEditingController();
  final _controladorFactura = TextEditingController();
  final _controladorPlazoSeguridad = TextEditingController();
  List<String> _rutasFotosTratamiento = [];

  // Incidencia
  String _tipoIncidencia = 'otro';
  final _controladorDescripcion = TextEditingController();
  int? _severidadIncidencia;
  List<String> _rutasFotosIncidencia = [];

  bool _guardando = false;

  /// `true` si la plaga objetivo del tratamiento es de declaración obligatoria.
  bool _consultarPlagaDeclaracionObligatoria(String texto) {
    final consultaNormalizada = texto.trim().toLowerCase();
    if (consultaNormalizada.isEmpty) return false;
    for (final p in catalogoPlagasUrbanas) {
      if (!p.declaracionOficial) continue;
      if (p.nombreComun.toLowerCase() == consultaNormalizada) return true;
      if (p.id == consultaNormalizada) return true;
    }
    return false;
  }

  String _resolverIdTipoPoda(String texto) {
    final consultaNormalizada = texto.trim().toLowerCase();
    if (consultaNormalizada.isEmpty) return '';
    for (final t in catalogoTiposPoda) {
      if (t.id == consultaNormalizada) return t.id;
      if (t.nombreCanonico.toLowerCase() == consultaNormalizada) return t.id;
    }
    return consultaNormalizada;
  }

  String _resolverIdPlaga(String texto) {
    final consultaNormalizada = texto.trim().toLowerCase();
    if (consultaNormalizada.isEmpty) return '';
    for (final p in catalogoPlagasUrbanas) {
      if (p.id == consultaNormalizada) return p.id;
      if (p.nombreComun.toLowerCase() == consultaNormalizada) return p.id;
    }
    return consultaNormalizada;
  }

  String get _titulo {
    switch (widget.tipo) {
      case TipoEventoNuevo.inspeccion:
        return 'Nueva inspección';
      case TipoEventoNuevo.poda:
        return 'Nueva poda';
      case TipoEventoNuevo.tratamiento:
        return 'Nuevo tratamiento';
      case TipoEventoNuevo.incidencia:
        return 'Nueva incidencia';
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarTecnicos();
    if (widget.tipo == TipoEventoNuevo.tratamiento) {
      _controladorMotivoPlaga.addListener(_repintar);
    }
    if (widget.tipo == TipoEventoNuevo.poda) {
      _controladorTipoPoda.addListener(_repintar);
    }
  }

  void _repintar() {
    if (mounted) setState(() {});
  }

  Future<void> _cargarTecnicos() async {
    final tecnicos =
        await BaseDatosSoleraArbolado.instancia.listarTecnicos(soloActivos: true);
    final activoId = await _persistenciaTecnico.cargar();
    if (!mounted) return;
    setState(() {
      _tecnicosDisponibles = tecnicos;
      _tecnicoId =
          activoId != null && tecnicos.any((t) => t.id == activoId) ? activoId : null;
    });
  }

  @override
  void dispose() {
    if (widget.tipo == TipoEventoNuevo.tratamiento) {
      _controladorMotivoPlaga.removeListener(_repintar);
    }
    if (widget.tipo == TipoEventoNuevo.poda) {
      _controladorTipoPoda.removeListener(_repintar);
    }
    for (final c in [
      _controladorNotas, _controladorFenologia,
      _controladorTipoPoda, _controladorVolumenRestos, _controladorMotivoPoda,
      _controladorSustancia, _controladorDosis, _controladorMotivoPlaga,
      _controladorLote, _controladorFactura, _controladorPlazoSeguridad,
      _controladorDescripcion,
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

  Future<void> _guardar() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    final db = BaseDatosSoleraArbolado.instancia;
    final fechaMs = _fecha.millisecondsSinceEpoch;
    final notas = _controladorNotas.text.trim();
    if (_tecnicoId != null) {
      await _persistenciaTecnico.guardar(_tecnicoId);
    }

    switch (widget.tipo) {
      case TipoEventoNuevo.inspeccion:
        await db.guardarInspeccion(Inspeccion(
          arbolId: widget.arbolId,
          tecnicoId: _tecnicoId,
          fechaMs: fechaMs,
          estado: _estadoInspeccion,
          riesgoVta: _riesgoVtaInspeccion,
          fenologia: _controladorFenologia.text.trim(),
          rutasFotosJson: GestorFotos.codificar(_rutasFotosInspeccion),
          notas: notas,
        ));
        break;
      case TipoEventoNuevo.poda:
        await db.guardarPoda(Poda(
          arbolId: widget.arbolId,
          tecnicoId: _tecnicoId,
          fechaMs: fechaMs,
          tipoPodaId: _resolverIdTipoPoda(_controladorTipoPoda.text),
          volumenRestosM3:
              medidaDesdeTexto(_controladorVolumenRestos.text),
          motivo: _controladorMotivoPoda.text.trim(),
          rutasFotosAntesJson: GestorFotos.codificar(_rutasFotosAntes),
          rutasFotosDespuesJson: GestorFotos.codificar(_rutasFotosDespues),
          notas: notas,
        ));
        break;
      case TipoEventoNuevo.tratamiento:
        await db.guardarTratamiento(Tratamiento(
          arbolId: widget.arbolId,
          tecnicoId: _tecnicoId,
          fechaMs: fechaMs,
          sustanciaActivaId: _controladorSustancia.text.trim().toLowerCase(),
          dosis: _controladorDosis.text.trim(),
          motivoIdPlaga: _resolverIdPlaga(_controladorMotivoPlaga.text),
          loteProducto: _controladorLote.text.trim(),
          numeroFactura: _controladorFactura.text.trim(),
          plazoSeguridadDias: int.tryParse(_controladorPlazoSeguridad.text),
          rutasFotosJson: GestorFotos.codificar(_rutasFotosTratamiento),
          notas: notas,
        ));
        break;
      case TipoEventoNuevo.incidencia:
        await db.guardarIncidencia(Incidencia(
          arbolId: widget.arbolId,
          tecnicoId: _tecnicoId,
          fechaMs: fechaMs,
          tipo: _tipoIncidencia,
          descripcion: _controladorDescripcion.text.trim(),
          severidad: _severidadIncidencia,
          rutasFotosJson: GestorFotos.codificar(_rutasFotosIncidencia),
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.event),
              title: Text(formatoFecha.format(_fecha)),
              trailing: TextButton(onPressed: _elegirFecha, child: Text('Cambiar')),
            ),
            DropdownButtonFormField<int?>(
              initialValue: _tecnicoId,
              decoration: InputDecoration(
                labelText: 'Técnico que firma',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('— sin firmar (rellenar antes de inspección) —'),
                ),
                for (final t in _tecnicosDisponibles)
                  DropdownMenuItem<int?>(
                    value: t.id,
                    child: Text(t.empresaContratista.isEmpty
                        ? t.nombre
                        : '${t.nombre} (${t.empresaContratista})'),
                  ),
              ],
              onChanged: (v) => setState(() => _tecnicoId = v),
            ),
            Divider(),
            ..._camposEspecificos(),
            SizedBox(height: 12),
            TextFormField(
              controller: _controladorNotas,
              decoration: InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(Icons.check),
              label: Text(SoleraL10n.t('guardar')),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _camposEspecificos() {
    switch (widget.tipo) {
      case TipoEventoNuevo.inspeccion:
        return [
          DropdownButtonFormField<String>(
            initialValue: _estadoInspeccion,
            decoration: InputDecoration(
              labelText: 'Estado observado',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'sano', child: Text('Sano')),
              DropdownMenuItem(value: 'observacion', child: Text('Observación')),
              DropdownMenuItem(value: 'riesgo', child: Text('Riesgo')),
              DropdownMenuItem(value: 'caido', child: Text('Caído / eliminado')),
            ],
            onChanged: (v) => setState(() => _estadoInspeccion = v ?? 'sano'),
          ),
          SizedBox(height: 12),
          _selectorNumero1A5(
            'Riesgo VTA',
            _riesgoVtaInspeccion,
            (v) => setState(() => _riesgoVtaInspeccion = v),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorFenologia,
            decoration: InputDecoration(
              labelText: 'Fenología',
              hintText: 'en hoja, en flor, desnudo, con frutos…',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          Text('Fotos', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          SelectorFotos(
            rutas: _rutasFotosInspeccion,
            alCambiar: (r) => setState(() => _rutasFotosInspeccion = r),
          ),
        ];
      case TipoEventoNuevo.poda:
        return [
          CampoAutocompleteCatalogo<TipoPoda>(
            controlador: _controladorTipoPoda,
            labelText: 'Tipo de poda',
            hintText: 'mantenimiento, saneamiento, refaldado…',
            opcionesCompletas: catalogoTiposPoda,
            buscar: buscarTiposPoda,
            displayStringForOption: (t) =>
                t.controvertida ? '${t.nombreCanonico} ⚠' : t.nombreCanonico,
          ),
          if (_resolverIdTipoPoda(_controladorTipoPoda.text).isNotEmpty &&
              (tipoPodaPorId(_resolverIdTipoPoda(_controladorTipoPoda.text))
                      ?.controvertida ??
                  false)) ...[
            SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.amber, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tipo de poda controvertido — debate técnico activo. '
                      'Justifica la elección en las notas para inspección.',
                      style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorVolumenRestos,
            validator: validarMedidaOpcional,
            decoration: InputDecoration(
              labelText: 'Volumen estimado de restos (m³)',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorMotivoPoda,
            decoration: InputDecoration(
              labelText: 'Motivo',
              hintText: 'limpieza anual, rama caída, despeje vial…',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          Text('Fotos antes', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          SelectorFotos(
            rutas: _rutasFotosAntes,
            alCambiar: (r) => setState(() => _rutasFotosAntes = r),
          ),
          SizedBox(height: 12),
          Text('Fotos después', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          SelectorFotos(
            rutas: _rutasFotosDespues,
            alCambiar: (r) => setState(() => _rutasFotosDespues = r),
          ),
        ];
      case TipoEventoNuevo.tratamiento:
        return [
          TextFormField(
            controller: _controladorSustancia,
            decoration: InputDecoration(
              labelText: 'Sustancia activa',
              hintText: 'Bacillus thuringiensis, abamectina…',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorDosis,
            decoration: InputDecoration(
              labelText: 'Dosis',
              hintText: '1 L/Ha, 2 ml/árbol…',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          CampoAutocompleteCatalogo<PlagaUrbana>(
            controlador: _controladorMotivoPlaga,
            labelText: 'Plaga / enfermedad objetivo',
            hintText: 'procesionaria, picudo, anthracnosis…',
            opcionesCompletas: catalogoPlagasUrbanas,
            buscar: buscarPlagasUrbanas,
            displayStringForOption: (p) => p.nombreComun,
          ),
          if (_consultarPlagaDeclaracionObligatoria(_controladorMotivoPlaga.text)) ...[
            SizedBox(height: 8),
            BannerDeclaracionObligatoria(
              texto:
                  'Esta plaga es de DECLARACIÓN OBLIGATORIA al servicio fitosanitario oficial.',
            ),
          ],
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorLote,
            decoration: InputDecoration(
              labelText: 'Lote del producto',
              hintText: 'Trazabilidad fitosanitaria',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorFactura,
            decoration: InputDecoration(
              labelText: 'Nº factura',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorPlazoSeguridad,
            decoration: InputDecoration(
              labelText: 'Plazo seguridad (días)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SizedBox(height: 12),
          Text('Fotos', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          SelectorFotos(
            rutas: _rutasFotosTratamiento,
            alCambiar: (r) => setState(() => _rutasFotosTratamiento = r),
          ),
        ];
      case TipoEventoNuevo.incidencia:
        return [
          DropdownButtonFormField<String>(
            initialValue: _tipoIncidencia,
            decoration: InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'golpe_vehiculo', child: Text('Golpe de vehículo')),
              DropdownMenuItem(value: 'vandalismo', child: Text('Vandalismo')),
              DropdownMenuItem(value: 'temporal', child: Text('Temporal / viento')),
              DropdownMenuItem(value: 'alcorque_danado', child: Text('Alcorque dañado')),
              DropdownMenuItem(value: 'raices_acera', child: Text('Raíces en acera')),
              DropdownMenuItem(value: 'riesgo_caida', child: Text('Riesgo de caída')),
              DropdownMenuItem(value: 'otro', child: Text('Otro')),
            ],
            onChanged: (v) => setState(() => _tipoIncidencia = v ?? 'otro'),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorDescripcion,
            decoration: InputDecoration(
              labelText: 'Descripción',
              hintText: 'Rama caída por viento sur, golpe de furgoneta…',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v ?? '').trim().isEmpty ? 'Describe la incidencia' : null,
          ),
          SizedBox(height: 8),
          BotonIdentificarIA(
            rutasFotos: _rutasFotosIncidencia,
            observacionesUsuario: _controladorDescripcion.text,
            alAceptar: (datos) {
              setState(() {
                _tipoIncidencia = datos.tipoIncidencia;
                _controladorDescripcion.text = datos.descripcion;
                if (datos.severidad != null) _severidadIncidencia = datos.severidad;
                if (datos.notasAuto.isNotEmpty) {
                  final actual = _controladorNotas.text.trim();
                  _controladorNotas.text = actual.isEmpty
                      ? datos.notasAuto
                      : '${datos.notasAuto}\n\n$actual';
                }
              });
            },
          ),
          SizedBox(height: 12),
          _selectorNumero1A5(
            'Severidad',
            _severidadIncidencia,
            (v) => setState(() => _severidadIncidencia = v),
          ),
          SizedBox(height: 12),
          Text('Fotos', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          SelectorFotos(
            rutas: _rutasFotosIncidencia,
            alCambiar: (r) => setState(() => _rutasFotosIncidencia = r),
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
