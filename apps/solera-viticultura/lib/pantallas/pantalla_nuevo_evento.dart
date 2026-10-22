import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_plagas_vid.dart';
import '../modelos/cosecha.dart';
import '../modelos/incidencia.dart';
import '../modelos/observacion.dart';
import '../modelos/tratamiento.dart';
import '../utiles/validadores_numero.dart';
import 'widgets/boton_identificar_ia.dart';

/// Tipo de evento que crea esta pantalla. Se elige antes de abrirla
/// (desde la ficha de la cepa o desde el FAB del mapa).
enum TipoEventoNuevo { cosecha, observacion, incidencia, tratamiento }

/// Formulario único reutilizado para los cuatro tipos de evento. Los
/// campos comunes (fecha, fotos, notas) van siempre visibles; los
/// específicos del tipo se muestran condicionados.
///
/// Versión minimalista v0.1: campos free-text para diagnóstico,
/// producto, etc. Cuando entren los catálogos curados (F1-5) y la IA
/// (F1-8), estos se sustituyen por dropdowns + autocomplete.
class PantallaNuevoEvento extends StatefulWidget {
  final int cepaId;
  final TipoEventoNuevo tipo;

  PantallaNuevoEvento({super.key, required this.cepaId, required this.tipo});

  @override
  State<PantallaNuevoEvento> createState() => _PantallaNuevoEventoState();
}

class _PantallaNuevoEventoState extends State<PantallaNuevoEvento> {
  final _claveFormulario = GlobalKey<FormState>();

  // Comunes
  DateTime _fecha = DateTime.now();
  final _controladorNotas = TextEditingController();
  List<String> _rutasFotos = [];

  // Cosecha
  final _controladorKilos = TextEditingController();
  final _controladorUnidades = TextEditingController();
  int? _calidad;

  // Observación
  int? _salud;
  final _controladorEtiquetasObs = TextEditingController();

  // Incidencia
  String _tipoIncidencia = 'enfermedad';
  final _controladorDiagnostico = TextEditingController();
  int? _severidad;

  // Tratamiento
  String _tipoTratamiento = 'fitosanitario';
  final _controladorProducto = TextEditingController();
  final _controladorDosis = TextEditingController();
  final _controladorMotivo = TextEditingController();
  final _controladorPlazoSeguridad = TextEditingController();
  final _controladorNumRegistro = TextEditingController();
  final _controladorNifAplicador = TextEditingController();
  final _controladorSuperficieTratada = TextEditingController();

  bool _guardando = false;

  /// Recibe el diagnóstico aceptado por el usuario en el modal IA y
  /// rellena tipo/diagnóstico/severidad. Las notas auto se anteponen
  /// a las que el usuario haya tecleado, separadas por línea en
  /// blanco — así puede luego borrarlas o conservarlas.
  void _aplicarSugerenciaIA(DatosIncidenciaIA datos) {
    setState(() {
      _tipoIncidencia = datos.tipo;
      _controladorDiagnostico.text = datos.diagnostico;
      if (datos.severidad != null) _severidad = datos.severidad;
      final notasPrevias = _controladorNotas.text.trim();
      if (datos.notasAuto.isNotEmpty) {
        _controladorNotas.text = notasPrevias.isEmpty
            ? datos.notasAuto
            : '${datos.notasAuto}\n\n$notasPrevias';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Diagnóstico pre-rellenado. Revisa y guarda.')),
    );
  }

  String get _titulo {
    switch (widget.tipo) {
      case TipoEventoNuevo.cosecha:
        return 'Nueva cosecha';
      case TipoEventoNuevo.observacion:
        return 'Nueva observación';
      case TipoEventoNuevo.incidencia:
        return 'Nueva incidencia';
      case TipoEventoNuevo.tratamiento:
        return 'Nuevo tratamiento';
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.tipo == TipoEventoNuevo.incidencia) {
      // Necesario: RawAutocomplete sólo notifica al padre vía `onSelected`
      // (cuando el usuario PULSA un item del menú), no cuando TECLEA. El
      // banner rojo de declaración obligatoria depende del texto crudo
      // — sin este listener el banner nunca aparece al teclear el nombre
      // de la plaga letra a letra. NO eliminar.
      _controladorDiagnostico.addListener(_repintar);
    }
  }

  void _repintar() {
    if (mounted) setState(() {});
  }

  /// `true` si el texto del diagnóstico coincide con una plaga del
  /// catálogo marcada con `declaracion_oficial=si`. Hoy ninguna fila lo
  /// tiene activo — depende del agrónomo asesor (Xylella, Flavescencia
  /// dorada, fuego bacteriano si aplica). Cuando entren, el banner se
  /// enciende automáticamente sin tocar este código.
  bool _diagnosticoEsDeclaracionObligatoria() {
    final consultaNormalizada = _controladorDiagnostico.text.trim().toLowerCase();
    if (consultaNormalizada.isEmpty) return false;
    for (final p in catalogoPlagasVid) {
      if (!p.declaracionOficial) continue;
      if (p.nombreComun.toLowerCase() == consultaNormalizada) return true;
      if (p.id == consultaNormalizada) return true;
    }
    return false;
  }

  @override
  void dispose() {
    if (widget.tipo == TipoEventoNuevo.incidencia) {
      _controladorDiagnostico.removeListener(_repintar);
    }
    _controladorNotas.dispose();
    _controladorKilos.dispose();
    _controladorUnidades.dispose();
    _controladorEtiquetasObs.dispose();
    _controladorDiagnostico.dispose();
    _controladorProducto.dispose();
    _controladorDosis.dispose();
    _controladorMotivo.dispose();
    _controladorPlazoSeguridad.dispose();
    _controladorNumRegistro.dispose();
    _controladorNifAplicador.dispose();
    _controladorSuperficieTratada.dispose();
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
    final db = BaseDatosSoleraViticultura.instancia;
    final fechaMs = _fecha.millisecondsSinceEpoch;
    final fotosJson = GestorFotos.codificar(_rutasFotos);
    final notas = _controladorNotas.text.trim();

    switch (widget.tipo) {
      case TipoEventoNuevo.cosecha:
        await db.guardarCosecha(Cosecha(
          cepaId: widget.cepaId,
          fechaMs: fechaMs,
          kilos: leerNumero(_controladorKilos.text, nullSiAmbiguo: true),
          unidades: int.tryParse(_controladorUnidades.text),
          calidad: _calidad,
          rutasFotosJson: fotosJson,
          notas: notas,
        ));
        break;
      case TipoEventoNuevo.observacion:
        // Etiquetas como lista coma-separada → JSON.
        final etiquetasCrudo = _controladorEtiquetasObs.text.trim();
        final lista = etiquetasCrudo.isEmpty
            ? const <String>[]
            : etiquetasCrudo
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
        final etiquetasJson = GestorFotos.codificar(lista);
        await db.guardarObservacion(Observacion(
          cepaId: widget.cepaId,
          fechaMs: fechaMs,
          salud: _salud,
          etiquetasJson: etiquetasJson,
          rutasFotosJson: fotosJson,
          notas: notas,
        ));
        break;
      case TipoEventoNuevo.incidencia:
        await db.guardarIncidencia(Incidencia(
          cepaId: widget.cepaId,
          fechaMs: fechaMs,
          tipo: _tipoIncidencia,
          diagnostico: _controladorDiagnostico.text.trim(),
          severidad: _severidad,
          rutasFotosJson: fotosJson,
          notas: notas,
        ));
        break;
      case TipoEventoNuevo.tratamiento:
        await db.guardarTratamiento(Tratamiento(
          cepaId: widget.cepaId,
          fechaMs: fechaMs,
          tipo: _tipoTratamiento,
          producto: _controladorProducto.text.trim(),
          dosis: _controladorDosis.text.trim(),
          motivo: _controladorMotivo.text.trim(),
          plazoSeguridadDias: int.tryParse(_controladorPlazoSeguridad.text),
          notas: notas,
          numeroRegistroFitosanitario: _controladorNumRegistro.text.trim(),
          nifAplicador: _controladorNifAplicador.text.trim(),
          superficieTratadaHectareas:
              leerNumero(_controladorSuperficieTratada.text),
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
            Divider(),
            ..._camposEspecificosDelTipo(),
            SizedBox(height: 12),
            if (widget.tipo != TipoEventoNuevo.tratamiento) ...[
              Text('Fotos', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              SelectorFotos(rutas: _rutasFotos, alCambiar: (r) => setState(() => _rutasFotos = r)),
              SizedBox(height: 12),
            ],
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

  List<Widget> _camposEspecificosDelTipo() {
    switch (widget.tipo) {
      case TipoEventoNuevo.cosecha:
        return [
          TextFormField(
            controller: _controladorKilos,
            decoration: InputDecoration(labelText: 'Kilos', border: OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
            validator: validarCantidadOpcional,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorUnidades,
            decoration: InputDecoration(labelText: 'Unidades', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SizedBox(height: 12),
          _selectorNumero1A5(
            etiqueta: 'Calidad',
            valor: _calidad,
            alCambiar: (v) => setState(() => _calidad = v),
          ),
        ];
      case TipoEventoNuevo.observacion:
        return [
          _selectorNumero1A5(
            etiqueta: 'Salud',
            valor: _salud,
            alCambiar: (v) => setState(() => _salud = v),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorEtiquetasObs,
            decoration: InputDecoration(
              labelText: 'Etiquetas (coma-separadas)',
              hintText: 'brotación, floración, envero, vendimia…',
              border: OutlineInputBorder(),
            ),
          ),
        ];
      case TipoEventoNuevo.incidencia:
        return [
          BotonIdentificarIA(
            rutasFotos: _rutasFotos,
            observacionesUsuario: _controladorNotas.text,
            alAceptar: _aplicarSugerenciaIA,
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _tipoIncidencia,
            decoration: InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'plaga', child: Text('Plaga')),
              DropdownMenuItem(value: 'enfermedad', child: Text('Enfermedad')),
              DropdownMenuItem(value: 'estres', child: Text('Estrés')),
              DropdownMenuItem(value: 'fisiologico', child: Text('Fisiológico')),
              DropdownMenuItem(value: 'otro', child: Text('Otro')),
            ],
            onChanged: (v) => setState(() => _tipoIncidencia = v ?? 'otro'),
          ),
          SizedBox(height: 12),
          CampoAutocompleteCatalogo<PlagaVid>(
            controlador: _controladorDiagnostico,
            labelText: 'Diagnóstico',
            hintText: 'mildiu, oídio, botritis, polilla del racimo…',
            opcionesCompletas: catalogoPlagasVid,
            buscar: buscarPlagasVid,
            displayStringForOption: (p) => p.nombreComun,
            validator: (v) => (v ?? '').trim().isEmpty ? 'Indica el diagnóstico' : null,
          ),
          if (_diagnosticoEsDeclaracionObligatoria()) ...[
            SizedBox(height: 8),
            BannerDeclaracionObligatoria(
              texto:
                  'Esta enfermedad es de DECLARACIÓN OBLIGATORIA al servicio fitosanitario oficial.',
            ),
          ],
          SizedBox(height: 12),
          _selectorNumero1A5(
            etiqueta: 'Severidad',
            valor: _severidad,
            alCambiar: (v) => setState(() => _severidad = v),
          ),
        ];
      case TipoEventoNuevo.tratamiento:
        return [
          DropdownButtonFormField<String>(
            initialValue: _tipoTratamiento,
            decoration: InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'fitosanitario', child: Text('Fitosanitario')),
              DropdownMenuItem(value: 'abono', child: Text('Abono')),
              DropdownMenuItem(value: 'riego', child: Text('Riego')),
              DropdownMenuItem(value: 'poda', child: Text('Poda')),
              DropdownMenuItem(value: 'otro', child: Text('Otro')),
            ],
            onChanged: (v) => setState(() => _tipoTratamiento = v ?? 'otro'),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorProducto,
            decoration: InputDecoration(labelText: 'Producto', border: OutlineInputBorder()),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorDosis,
            decoration: InputDecoration(
              labelText: 'Dosis',
              hintText: '150 g/hl, 2 L/ha…',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorMotivo,
            decoration: InputDecoration(
              labelText: 'Motivo',
              hintText: 'Control mildiu preventivo…',
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
          if (_tipoTratamiento == 'fitosanitario') ...[
            SizedBox(height: 16),
            Text('Datos PAC (libro oficial)', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextFormField(
              controller: _controladorNumRegistro,
              decoration: InputDecoration(
                labelText: 'Nº registro fitosanitario',
                hintText: 'BOE/MAPA',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _controladorNifAplicador,
              decoration: InputDecoration(
                labelText: 'NIF aplicador',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _controladorSuperficieTratada,
              decoration: InputDecoration(
                labelText: 'Superficie tratada (ha)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
              validator: validarMedidaOpcional,
            ),
          ],
        ];
    }
  }

  Widget _selectorNumero1A5({
    required String etiqueta,
    required int? valor,
    required ValueChanged<int?> alCambiar,
  }) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(etiqueta)),
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
