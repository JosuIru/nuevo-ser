import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogo_fitosanitarios.dart';
import '../modelos/cosecha.dart';
import '../modelos/incidencia.dart';
import '../modelos/observacion.dart';
import '../modelos/tratamiento.dart';
import '../utiles/numeros_formulario.dart';
import 'widgets/boton_identificar_ia.dart';

enum TipoEventoNuevo { cosecha, observacion, incidencia, tratamiento }

/// Formulario único reutilizado para los cuatro tipos de evento.
///
/// Modo alta: `eventoExistenteId == null` y `tipo` indica qué crear.
/// Modo edición: `eventoExistenteId` viene con el id de la fila en la
/// tabla del tipo correspondiente; precarga los valores y el guardado
/// hace UPDATE en lugar de INSERT.
class PantallaNuevoEvento extends StatefulWidget {
  final int plantaId;
  final TipoEventoNuevo tipo;
  final int? eventoExistenteId;

  PantallaNuevoEvento({
    super.key,
    required this.plantaId,
    required this.tipo,
    this.eventoExistenteId,
  });

  @override
  State<PantallaNuevoEvento> createState() => _PantallaNuevoEventoState();
}

class _PantallaNuevoEventoState extends State<PantallaNuevoEvento> {
  final _claveFormulario = GlobalKey<FormState>();

  // Campos comunes
  DateTime _fecha = DateTime.now();
  final _controladorNotas = TextEditingController();

  // Cosecha
  final _controladorKilos = TextEditingController();
  final _controladorUnidades = TextEditingController();
  int? _calidad;

  // Observacion
  int? _salud;

  // Incidencia
  String _tipoIncidencia = 'plaga';
  final _controladorDiagnostico = TextEditingController();
  int? _severidad;

  // Tratamiento
  String _tipoTratamiento = 'fitosanitario';
  final _controladorProducto = TextEditingController();
  // Foco del Autocomplete del producto. Lo declaramos como propiedad
  // del state (en lugar de dejarlo a Autocomplete) para que el
  // controller del campo lo inyectemos nosotros vía RawAutocomplete y
  // así eliminar el listener leak que tenía el Autocomplete.fieldViewBuilder
  // (cada rebuild añadía un listener nuevo sin retirar el anterior).
  final _focoProducto = FocusNode();
  final _controladorDosis = TextEditingController();
  final _controladorMotivo = TextEditingController();
  final _controladorPlazoSeguridad = TextEditingController();
  // Cuaderno MAPA (sólo aplica a tratamientos fitosanitarios)
  final _controladorNumeroRegistroFito = TextEditingController();
  final _controladorNifAplicador = TextEditingController();
  final _controladorSuperficieTratada = TextEditingController();

  // Fotos compartidas por todos los tipos. Tratamiento no las usa
  // visualmente pero aceptamos el campo por simetría con los demás
  // (futura BBDD oficial de tratamientos puede pedirlas como prueba).
  List<String> _rutasFotos = [];

  bool _guardando = false;
  bool _cargando = true;
  String _cultivoIdPlanta = 'generico';

  bool get _esEdicion => widget.eventoExistenteId != null;

  @override
  void initState() {
    super.initState();
    _cargarCultivoPlanta();
    _cargarSiEdicion();
  }

  Future<void> _cargarCultivoPlanta() async {
    final planta = await BaseDatosAgro.instancia.obtenerPlanta(widget.plantaId);
    if (!mounted || planta == null) return;
    setState(() => _cultivoIdPlanta = planta.cultivoId);
  }

  Future<void> _cargarSiEdicion() async {
    if (!_esEdicion) {
      setState(() => _cargando = false);
      return;
    }
    final db = BaseDatosAgro.instancia;
    final id = widget.eventoExistenteId!;
    switch (widget.tipo) {
      case TipoEventoNuevo.cosecha:
        final c = await db.obtenerCosecha(id);
        if (c != null) {
          _fecha = DateTime.fromMillisecondsSinceEpoch(c.fechaMs);
          if (c.kilos != null) _controladorKilos.text = numeroParaEditar(c.kilos!);
          if (c.unidades != null) _controladorUnidades.text = c.unidades!.toString();
          _calidad = c.calidad;
          _rutasFotos = GestorFotos.decodificar(c.rutasFotosJson);
          _controladorNotas.text = c.notas;
        }
        break;
      case TipoEventoNuevo.observacion:
        final o = await db.obtenerObservacion(id);
        if (o != null) {
          _fecha = DateTime.fromMillisecondsSinceEpoch(o.fechaMs);
          _salud = o.salud;
          _rutasFotos = GestorFotos.decodificar(o.rutasFotosJson);
          _controladorNotas.text = o.notas;
        }
        break;
      case TipoEventoNuevo.incidencia:
        final i = await db.obtenerIncidencia(id);
        if (i != null) {
          _fecha = DateTime.fromMillisecondsSinceEpoch(i.fechaMs);
          _tipoIncidencia = i.tipo;
          _controladorDiagnostico.text = i.diagnostico;
          _severidad = i.severidad;
          _rutasFotos = GestorFotos.decodificar(i.rutasFotosJson);
          _controladorNotas.text = i.notas;
        }
        break;
      case TipoEventoNuevo.tratamiento:
        final t = await db.obtenerTratamiento(id);
        if (t != null) {
          _fecha = DateTime.fromMillisecondsSinceEpoch(t.fechaMs);
          _tipoTratamiento = t.tipo;
          _controladorProducto.text = t.producto;
          _controladorDosis.text = t.dosis;
          _controladorMotivo.text = t.motivo;
          if (t.plazoSeguridadDias != null) {
            _controladorPlazoSeguridad.text = t.plazoSeguridadDias!.toString();
          }
          _controladorNumeroRegistroFito.text = t.numeroRegistroFitosanitario;
          _controladorNifAplicador.text = t.nifAplicador;
          if (t.superficieTratadaHectareas != null) {
            _controladorSuperficieTratada.text = numeroParaEditar(t.superficieTratadaHectareas!);
          }
          _controladorNotas.text = t.notas;
        }
        break;
    }
    if (mounted) setState(() => _cargando = false);
  }

  @override
  void dispose() {
    _controladorNotas.dispose();
    _controladorKilos.dispose();
    _controladorUnidades.dispose();
    _controladorDiagnostico.dispose();
    _controladorProducto.dispose();
    _controladorDosis.dispose();
    _controladorMotivo.dispose();
    _controladorPlazoSeguridad.dispose();
    _controladorNumeroRegistroFito.dispose();
    _controladorNifAplicador.dispose();
    _controladorSuperficieTratada.dispose();
    _focoProducto.dispose();
    super.dispose();
  }

  String get _titulo {
    final prefijo = _esEdicion ? 'Editar' : 'Nueva';
    final prefijoTratamiento = _esEdicion ? 'Editar' : 'Nuevo';
    switch (widget.tipo) {
      case TipoEventoNuevo.cosecha:
        return '$prefijo cosecha';
      case TipoEventoNuevo.observacion:
        return '$prefijo observación';
      case TipoEventoNuevo.incidencia:
        return '$prefijo incidencia';
      case TipoEventoNuevo.tratamiento:
        return '$prefijoTratamiento tratamiento';
    }
  }

  /// Aplica los datos de un producto fitosanitario del catálogo curado
  /// al formulario de tratamiento: rellena producto, núm registro,
  /// dosis sugerida y plazo de seguridad. El usuario puede editar
  /// cualquiera de los campos antes de guardar — el catálogo es semilla
  /// curada, no fuente de verdad legal.
  void _aplicarFitosanitario(ProductoFitosanitario p) {
    setState(() {
      _controladorProducto.text = p.nombreComercialEjemplo;
      _controladorNumeroRegistroFito.text = p.numeroRegistroEjemplo;
      if (_controladorDosis.text.trim().isEmpty && p.dosisRecomendada.isNotEmpty) {
        _controladorDosis.text = p.dosisRecomendada;
      }
      if (_controladorPlazoSeguridad.text.trim().isEmpty && p.plazoSeguridadDias > 0) {
        _controladorPlazoSeguridad.text = p.plazoSeguridadDias.toString();
      }
    });
    final mensaje = StringBuffer('Producto del catálogo seleccionado.');
    if (!p.autorizadoParaCultivo(_cultivoIdPlanta)) {
      mensaje.write(' Aviso: el cultivo de la planta no figura en los autorizados de este producto — verifica antes de aplicar.');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje.toString()), duration: Duration(seconds: 5)),
    );
  }

  /// Construye el campo Producto con autocompletado contra el
  /// catálogo curado de fitosanitarios. Si el usuario teclea
  /// libremente, el campo guarda lo que tipea (free-text) — el
  /// autocompletar es una ayuda, no una restricción.
  ///
  /// Usa `RawAutocomplete` (no `Autocomplete`) para inyectar
  /// `_controladorProducto` y `_focoProducto` directamente. Así el
  /// texto vive en el controller del state desde el primer pulso de
  /// tecla — sin sincronización por listener (que en `Autocomplete`
  /// causaba listener leak: cada rebuild añadía un listener nuevo).
  Widget _autocompleteProducto() {
    return RawAutocomplete<ProductoFitosanitario>(
      textEditingController: _controladorProducto,
      focusNode: _focoProducto,
      optionsBuilder: (textoEditando) {
        return buscarFitosanitarios(
          texto: textoEditando.text,
          cultivoId: _cultivoIdPlanta,
        );
      },
      displayStringForOption: (p) => p.nombreComercialEjemplo,
      onSelected: _aplicarFitosanitario,
      fieldViewBuilder: (ctx, controlador, foco, alEnviar) {
        return TextFormField(
          controller: controlador,
          focusNode: foco,
          decoration: InputDecoration(
            labelText: 'Producto',
            hintText: 'Empieza a escribir para sugerencias del catálogo',
            border: OutlineInputBorder(),
          ),
        );
      },
      optionsViewBuilder: (ctx, alSeleccionar, opciones) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 280, maxWidth: 360),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: opciones.length,
                itemBuilder: (_, i) {
                  final p = opciones.elementAt(i);
                  final autorizado = p.autorizadoParaCultivo(_cultivoIdPlanta);
                  return ListTile(
                    dense: true,
                    title: Text(p.nombreComercialEjemplo,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${p.materiaActiva} · ${p.tipo.etiqueta}'
                      '${p.ecologico ? " · Ecológico" : ""}',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: autorizado
                        ? Icon(Icons.check_circle, color: Colors.green, size: 18)
                        : Icon(Icons.warning_amber, color: Colors.orange, size: 18),
                    onTap: () => alSeleccionar(p),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Recibe el diagnóstico aceptado por el usuario en el modal IA y
  /// rellena tipo/diagnóstico/severidad. Las notas auto se anteponen
  /// a las que el usuario haya tecleado, separadas por línea en
  /// blanco — así el agricultor puede luego borrarlas o conservarlas.
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

  Future<void> _guardar() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    final fechaMs = _fecha.millisecondsSinceEpoch;
    final db = BaseDatosAgro.instancia;
    final fotosJson = GestorFotos.codificar(_rutasFotos);
    final notas = _controladorNotas.text.trim();
    final id = widget.eventoExistenteId;
    switch (widget.tipo) {
      case TipoEventoNuevo.cosecha:
        final cambios = <String, Object?>{
          'fecha_ms': fechaMs,
          'kilos': leerNumero(_controladorKilos.text, nullSiAmbiguo: true),
          'unidades': int.tryParse(_controladorUnidades.text),
          'calidad': _calidad,
          'rutas_fotos_json': fotosJson,
          'notas': notas,
        };
        if (id != null) {
          await db.actualizarCosecha(id, cambios);
        } else {
          await db.guardarCosecha(Cosecha(
            plantaId: widget.plantaId,
            fechaMs: fechaMs,
            kilos: cambios['kilos'] as double?,
            unidades: cambios['unidades'] as int?,
            calidad: _calidad,
            rutasFotosJson: fotosJson,
            notas: notas,
          ));
        }
        break;
      case TipoEventoNuevo.observacion:
        final cambios = <String, Object?>{
          'fecha_ms': fechaMs,
          'salud': _salud,
          'rutas_fotos_json': fotosJson,
          'notas': notas,
        };
        if (id != null) {
          await db.actualizarObservacion(id, cambios);
        } else {
          await db.guardarObservacion(Observacion(
            plantaId: widget.plantaId,
            fechaMs: fechaMs,
            salud: _salud,
            rutasFotosJson: fotosJson,
            notas: notas,
          ));
        }
        break;
      case TipoEventoNuevo.incidencia:
        final cambios = <String, Object?>{
          'fecha_ms': fechaMs,
          'tipo': _tipoIncidencia,
          'diagnostico': _controladorDiagnostico.text.trim(),
          'severidad': _severidad,
          'rutas_fotos_json': fotosJson,
          'notas': notas,
        };
        if (id != null) {
          await db.actualizarIncidencia(id, cambios);
        } else {
          await db.guardarIncidencia(Incidencia(
            plantaId: widget.plantaId,
            fechaMs: fechaMs,
            tipo: _tipoIncidencia,
            diagnostico: cambios['diagnostico'] as String,
            severidad: _severidad,
            rutasFotosJson: fotosJson,
            notas: notas,
          ));
        }
        break;
      case TipoEventoNuevo.tratamiento:
        final superficieTratada = leerNumero(_controladorSuperficieTratada.text);
        final cambios = <String, Object?>{
          'fecha_ms': fechaMs,
          'tipo': _tipoTratamiento,
          'producto': _controladorProducto.text.trim(),
          'dosis': _controladorDosis.text.trim(),
          'motivo': _controladorMotivo.text.trim(),
          'plazo_seguridad_dias': int.tryParse(_controladorPlazoSeguridad.text),
          'numero_registro_fitosanitario': _controladorNumeroRegistroFito.text.trim(),
          'nif_aplicador': _controladorNifAplicador.text.trim().toUpperCase(),
          'superficie_tratada_hectareas': superficieTratada,
          'notas': notas,
        };
        if (id != null) {
          await db.actualizarTratamiento(id, cambios);
        } else {
          await db.guardarTratamiento(Tratamiento(
            plantaId: widget.plantaId,
            fechaMs: fechaMs,
            tipo: _tipoTratamiento,
            producto: cambios['producto'] as String,
            dosis: cambios['dosis'] as String,
            motivo: cambios['motivo'] as String,
            plazoSeguridadDias: cambios['plazo_seguridad_dias'] as int?,
            numeroRegistroFitosanitario: cambios['numero_registro_fitosanitario'] as String,
            nifAplicador: cambios['nif_aplicador'] as String,
            superficieTratadaHectareas: superficieTratada,
            notas: notas,
          ));
        }
        break;
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        appBar: AppBar(title: Text(_titulo)),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(_titulo)),
      body: AbsorbPointer(
        absorbing: _guardando,
        child: Form(
          key: _claveFormulario,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.calendar_today),
                title: Text('Fecha: ${_fecha.day}/${_fecha.month}/${_fecha.year}'),
                onTap: () async {
                  final pick = await showDatePicker(
                    context: context,
                    initialDate: _fecha,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pick != null) setState(() => _fecha = pick);
                },
              ),
              SizedBox(height: 8),
              ..._camposEspecificos(),
              if (widget.tipo != TipoEventoNuevo.tratamiento) ...[
                SizedBox(height: 16),
                Text('Fotos', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                SelectorFotos(
                  rutas: _rutasFotos,
                  alCambiar: (nuevas) => setState(() => _rutasFotos = nuevas),
                ),
              ],
              SizedBox(height: 12),
              TextFormField(
                controller: _controladorNotas,
                decoration: InputDecoration(labelText: 'Notas', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              FilledButton.icon(
                icon: Icon(Icons.save),
                onPressed: _guardando ? null : _guardar,
                label: Text(SoleraL10n.t('guardar')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _camposEspecificos() {
    switch (widget.tipo) {
      case TipoEventoNuevo.cosecha:
        return [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controladorKilos,
                  decoration: InputDecoration(labelText: 'Kilos', border: OutlineInputBorder()),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
                  validator: (v) => validarNumeroOpcional(v, nullSiAmbiguo: true),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _controladorUnidades,
                  decoration: InputDecoration(labelText: 'Unidades', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _SelectorPuntuacion(
            etiqueta: 'Calidad',
            valor: _calidad,
            alCambiar: (v) => setState(() => _calidad = v),
          ),
        ];
      case TipoEventoNuevo.observacion:
        return [
          _SelectorPuntuacion(
            etiqueta: 'Salud',
            valor: _salud,
            alCambiar: (v) => setState(() => _salud = v),
          ),
        ];
      case TipoEventoNuevo.incidencia:
        return [
          DropdownButtonFormField<String>(
            initialValue: _tipoIncidencia,
            decoration: InputDecoration(labelText: 'Tipo *', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'plaga', child: Text('Plaga')),
              DropdownMenuItem(value: 'enfermedad', child: Text('Enfermedad')),
              DropdownMenuItem(value: 'estres', child: Text('Estrés (hídrico, térmico…)')),
              DropdownMenuItem(value: 'fisiologico', child: Text('Trastorno fisiológico')),
              DropdownMenuItem(value: 'otro', child: Text('Otro')),
            ],
            onChanged: (v) => setState(() => _tipoIncidencia = v ?? 'otro'),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorDiagnostico,
            decoration: InputDecoration(
              labelText: 'Diagnóstico (ej: mosca del olivo)',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          _SelectorPuntuacion(
            etiqueta: 'Severidad',
            valor: _severidad,
            alCambiar: (v) => setState(() => _severidad = v),
          ),
          SizedBox(height: 12),
          BotonIdentificarIA(
            rutasFotos: _rutasFotos,
            cultivoId: _cultivoIdPlanta,
            observacionesUsuario: _controladorDiagnostico.text.trim().isNotEmpty
                ? 'Diagnóstico tentativo del usuario: ${_controladorDiagnostico.text.trim()}'
                : '',
            alAceptar: _aplicarSugerenciaIA,
          ),
        ];
      case TipoEventoNuevo.tratamiento:
        return [
          DropdownButtonFormField<String>(
            initialValue: _tipoTratamiento,
            decoration: InputDecoration(labelText: 'Tipo *', border: OutlineInputBorder()),
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
          _autocompleteProducto(),
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorDosis,
            decoration: InputDecoration(labelText: 'Dosis', border: OutlineInputBorder()),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorMotivo,
            decoration: InputDecoration(labelText: 'Motivo', border: OutlineInputBorder()),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _controladorPlazoSeguridad,
            decoration: InputDecoration(
              labelText: 'Plazo de seguridad (días)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          if (_tipoTratamiento == 'fitosanitario') ...[
            SizedBox(height: 16),
            Text(
              'Cuaderno de Explotación MAPA',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Estos datos son obligatorios para que el tratamiento aparezca en el cuaderno.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _controladorNumeroRegistroFito,
              decoration: InputDecoration(
                labelText: 'Número de registro fitosanitario',
                hintText: 'BBDD MAPA, ej: ES-12345',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _controladorSuperficieTratada,
              decoration: InputDecoration(
                labelText: 'Superficie tratada (ha)',
                hintText: 'Ej: 1,5',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
              validator: validarNumeroOpcional,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _controladorNifAplicador,
              decoration: InputDecoration(
                labelText: 'NIF del aplicador (si distinto del titular)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ];
    }
  }
}

class _SelectorPuntuacion extends StatelessWidget {
  final String etiqueta;
  final int? valor;
  final ValueChanged<int?> alCambiar;
  _SelectorPuntuacion({required this.etiqueta, required this.valor, required this.alCambiar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text('$etiqueta:')),
        for (var i = 1; i <= 5; i++)
          IconButton(
            icon: Icon(
              valor != null && valor! >= i ? Icons.star : Icons.star_border,
              color: valor != null && valor! >= i ? Colors.amber : Colors.grey,
            ),
            onPressed: () => alCambiar(valor == i ? null : i),
          ),
      ],
    );
  }
}
