import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show
        FuenteFoto,
        GestorFotos,
        ImagenClaude,
        PantallaClaveAnthropic,
        SoleraL10n,
        rellenoInferiorSeguro;

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_ingredientes_base.dart';
import '../estado/cambios_datos.dart';
import '../estado/clave_anthropic_obrador.dart';
import '../modelos/alergenos.dart';
import '../modelos/ingrediente.dart';
import '../modelos/lote_ingrediente.dart';
import '../servicios/lector_etiquetas_ia.dart';
import '../utiles/textos_obrador.dart';
import 'hoja_formulario.dart';

/// Materias primas con sus alérgenos, precio y sal.
class PantallaIngredientes extends StatefulWidget {
  const PantallaIngredientes({super.key});

  @override
  State<PantallaIngredientes> createState() => _PantallaIngredientesState();
}

class _PantallaIngredientesState extends State<PantallaIngredientes> {
  late Future<List<Ingrediente>> _ingredientes;

  @override
  void initState() {
    super.initState();
    _ingredientes = BaseDatosSoleraObrador.instancia.listarIngredientes();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() => setState(() {
        _ingredientes = BaseDatosSoleraObrador.instancia.listarIngredientes();
      });

  Future<void> _editar([Ingrediente? ingrediente]) async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => PantallaEditarIngrediente(ingrediente: ingrediente)),
    );
    if (guardado == true) avisarCambioDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('obra.ingredientes'))),
      floatingActionButton: FloatingActionButton(
        tooltip: SoleraL10n.t('obra.nuevo_ingrediente'),
        onPressed: _editar,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Ingrediente>>(
        future: _ingredientes,
        builder: (context, instantanea) {
          final ingredientes = instantanea.data ?? const [];
          if (instantanea.connectionState == ConnectionState.done &&
              ingredientes.isEmpty) {
            return Center(child: Text(SoleraL10n.t('obra.sin_ingredientes')));
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              for (final ingrediente in ingredientes)
                ListTile(
                  title: Text(ingrediente.nombre),
                  subtitle: Text(ingrediente.alergenos.isEmpty
                      ? SoleraL10n.t('obra.sin_alergenos')
                      : ingrediente.alergenos.map(nombreAlergeno).join(', ')),
                  trailing: Text(
                      '${formatearEuros(ingrediente.precioCentimosPorKg)}/kg'),
                  onTap: () => _editar(ingrediente),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Alta o edición de un ingrediente.
class PantallaEditarIngrediente extends StatefulWidget {
  const PantallaEditarIngrediente({super.key, this.ingrediente});

  final Ingrediente? ingrediente;

  @override
  State<PantallaEditarIngrediente> createState() =>
      _PantallaEditarIngredienteState();
}

class _PantallaEditarIngredienteState extends State<PantallaEditarIngrediente> {
  late final _nombre =
      TextEditingController(text: widget.ingrediente?.nombre ?? '');
  late final _proveedor =
      TextEditingController(text: widget.ingrediente?.proveedor ?? '');
  late final _precio = TextEditingController(
      text: widget.ingrediente == null
          ? ''
          : formatearNumero(widget.ingrediente!.precioCentimosPorKg / 100,
              decimales: 2));
  late final _sal = TextEditingController(
      text: widget.ingrediente == null
          ? ''
          : formatearNumero(widget.ingrediente!.salGramosPor100g));
  late final Set<String> _alergenos = {...?widget.ingrediente?.alergenos};
  late final Set<String> _trazas = {...?widget.ingrediente?.trazas};
  bool _guardando = false;
  bool _desdeCatalogo = false;
  bool _leyendo = false;
  bool _escuchandoNombre = false;

  void _usarIngredienteBase(IngredienteBase base) => setState(() {
        _desdeCatalogo = true;
        _nombre.text = base.nombre;
        _alergenos
          ..clear()
          ..addAll(base.alergenos);
        _trazas
          ..clear()
          ..addAll(base.trazas);
        if (base.salGramosPor100g > 0)
          _sal.text = formatearNumero(base.salGramosPor100g);
      });

  Future<void> _leerEtiqueta() async {
    final mensajero = ScaffoldMessenger.of(context);
    final clave = await estadoClaveObrador.cargar();
    if (!mounted) return;
    if (clave == null || !estadoClaveObrador.hayClave.value) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PantallaClaveAnthropic(
                    estado: estadoClaveObrador,
                    nombreApp: 'Larrea Obrador',
                    queIdentifica: SoleraL10n.t('obra.ia_que_hace'),
                  )));
      return;
    }
    final fuente = await showModalBottomSheet<FuenteFoto>(
      context: context,
      builder: (contexto) => SafeArea(
        child: Wrap(children: [
          ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(SoleraL10n.t('obra.hacer_foto')),
              onTap: () => Navigator.pop(contexto, FuenteFoto.camara)),
          ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(SoleraL10n.t('obra.elegir_foto')),
              onTap: () => Navigator.pop(contexto, FuenteFoto.galeria)),
        ]),
      ),
    );
    if (fuente == null) return;
    final rutas = await GestorFotos.tomarOSeleccionar(
        fuente: fuente, permitirVarias: false);
    if (rutas.isEmpty || !mounted) return;
    setState(() => _leyendo = true);
    try {
      final lectura = await leerEtiquetaConIa(
          claveApi: clave, foto: await ImagenClaude.desdeFichero(rutas.first));
      if (!mounted) return;
      await _mostrarLectura(lectura);
    } catch (error) {
      debugPrint('Lectura de etiqueta fallida: $error');
      mensajero
          .showSnackBar(SnackBar(content: Text(SoleraL10n.t('obra.ia_error'))));
    } finally {
      await GestorFotos.borrarSiExiste(rutas.first);
      if (mounted) setState(() => _leyendo = false);
    }
  }

  Future<void> _mostrarLectura(LecturaEtiqueta lectura) async {
    final usar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text(SoleraL10n.t('obra.ia_propuesta')),
        content: SingleChildScrollView(
          child: Text([
            if (!lectura.legible) SoleraL10n.t('obra.ia_no_legible'),
            if (lectura.nombreProducto.isNotEmpty) lectura.nombreProducto,
            if (lectura.ingredientes.isNotEmpty)
              lectura.ingredientes.join(', '),
            '${SoleraL10n.t('obra.alergenos')}: ${lectura.alergenos.isEmpty ? '—' : lectura.alergenos.map(nombreAlergeno).join(', ')}',
            if (lectura.trazas.isNotEmpty)
              '${SoleraL10n.t('obra.trazas')}: ${lectura.trazas.map(nombreAlergeno).join(', ')}',
            if (lectura.observaciones.isNotEmpty) lectura.observaciones,
            SoleraL10n.t('obra.ia_revisa'),
          ].join('\n\n')),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(contexto, false),
              child: Text(SoleraL10n.t('cancelar'))),
          FilledButton(
              onPressed: () => Navigator.pop(contexto, true),
              child: Text(SoleraL10n.t('obra.ia_usar'))),
        ],
      ),
    );
    if (usar != true) return;
    setState(() {
      _desdeCatalogo = true;
      if (_nombre.text.trim().isEmpty) _nombre.text = lectura.nombreProducto;
      _alergenos
        ..clear()
        ..addAll(lectura.alergenos);
      _trazas
        ..clear()
        ..addAll(lectura.trazas);
    });
  }

  @override
  void dispose() {
    for (final controlador in [_nombre, _proveedor, _precio, _sal]) {
      controlador.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_guardando || _nombre.text.trim().isEmpty) return;
    setState(() {
      _guardando = true;
    });
    await BaseDatosSoleraObrador.instancia.guardarIngrediente(Ingrediente(
      id: widget.ingrediente?.id,
      nombre: _nombre.text.trim(),
      alergenos: _alergenos,
      trazas: _trazas.difference(_alergenos),
      proveedor: _proveedor.text.trim(),
      precioCentimosPorKg: ((leerNumero(_precio.text) ?? 0) * 100).round(),
      salGramosPor100g: leerNumero(_sal.text) ?? 0,
      notas: widget.ingrediente?.notas ?? '',
    ));
    if (mounted) Navigator.pop(context, true);
  }

  Widget _selectorAlergenos(String titulo, Set<String> seleccion) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(titulo, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final alergeno in alergenosObligatorios)
                FilterChip(
                  label: Text(nombreAlergeno(alergeno)),
                  selected: seleccion.contains(alergeno),
                  onSelected: (marcado) => setState(() => marcado
                      ? seleccion.add(alergeno)
                      : seleccion.remove(alergeno)),
                ),
            ],
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          _leyendo
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)))
              : IconButton(
                  tooltip: SoleraL10n.t('obra.ia_leer_etiqueta'),
                  icon: const Icon(Icons.document_scanner_outlined),
                  onPressed: _leerEtiqueta,
                ),
        ],
        title: Text(widget.ingrediente == null
            ? SoleraL10n.t('obra.nuevo_ingrediente')
            : widget.ingrediente!.nombre),
      ),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
        children: [
          if (widget.ingrediente == null)
            Autocomplete<IngredienteBase>(
              optionsBuilder: (valor) => valor.text.trim().length < 2
                  ? const []
                  : catalogoIngredientesBase.where((base) => base.nombre
                      .toLowerCase()
                      .contains(valor.text.trim().toLowerCase())),
              displayStringForOption: (base) => base.nombre,
              onSelected: _usarIngredienteBase,
              fieldViewBuilder: (context, controlador, foco, alEnviar) {
                if (!_escuchandoNombre) {
                  _escuchandoNombre = true;
                  controlador
                      .addListener(() => _nombre.text = controlador.text);
                }
                return TextField(
                  controller: controlador,
                  focusNode: foco,
                  decoration: InputDecoration(
                      labelText: SoleraL10n.t('obra.nombre'),
                      helperText:
                          SoleraL10n.t('obra.ayuda_catalogo_ingredientes')),
                );
              },
            )
          else
            TextField(
              controller: _nombre,
              decoration:
                  InputDecoration(labelText: SoleraL10n.t('obra.nombre')),
            ),
          if (_desdeCatalogo)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(SoleraL10n.t('obra.confirmar_con_proveedor'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          TextField(
            controller: _proveedor,
            decoration:
                InputDecoration(labelText: SoleraL10n.t('obra.proveedor')),
          ),
          TextField(
            controller: _precio,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration:
                InputDecoration(labelText: SoleraL10n.t('obra.precio_kg')),
          ),
          TextField(
            controller: _sal,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration:
                InputDecoration(labelText: SoleraL10n.t('obra.sal_100g')),
          ),
          _selectorAlergenos(SoleraL10n.t('obra.alergenos'), _alergenos),
          _selectorAlergenos(SoleraL10n.t('obra.trazas'), _trazas),
          if (widget.ingrediente?.id != null)
            _SeccionLotes(ingredienteId: widget.ingrediente!.id!),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _guardando ? null : _guardar,
            child: Text(SoleraL10n.t('guardar')),
          ),
        ],
      ),
    );
  }
}

/// Lotes recibidos de un ingrediente, con alta rápida.
class _SeccionLotes extends StatefulWidget {
  const _SeccionLotes({required this.ingredienteId});

  final int ingredienteId;

  @override
  State<_SeccionLotes> createState() => _SeccionLotesState();
}

class _SeccionLotesState extends State<_SeccionLotes> {
  late Future<List<LoteIngrediente>> _lotes = _cargar();

  Future<List<LoteIngrediente>> _cargar() => BaseDatosSoleraObrador.instancia
      .listarLotesIngrediente(ingredienteId: widget.ingredienteId);

  Future<void> _recibir() async {
    final codigo = TextEditingController();
    final kilos = TextEditingController();
    final temperatura = TextEditingController();
    final guardado = await mostrarHojaFormulario(
      context,
      controladores: [codigo, kilos, temperatura],
      titulo: SoleraL10n.t('obra.recibir_lote'),
      construir: (_) => [
        campoTexto(codigo, SoleraL10n.t('obra.codigo_lote')),
        campoNumero(kilos, SoleraL10n.t('obra.cantidad_kg')),
        campoNumero(temperatura, SoleraL10n.t('obra.temperatura_recepcion')),
      ],
      guardar: () async {
        if (codigo.text.trim().isEmpty) return false;
        await BaseDatosSoleraObrador.instancia
            .guardarLoteIngrediente(LoteIngrediente(
          ingredienteId: widget.ingredienteId,
          codigoLote: codigo.text.trim(),
          fechaRecepcionMs: DateTime.now().millisecondsSinceEpoch,
          cantidadKg: leerNumero(kilos.text) ?? 0,
          temperaturaRecepcionC: leerNumero(temperatura.text),
        ));
        return true;
      },
    );
    if (guardado) {
      avisarCambioDatos();
      setState(() {
        _lotes = _cargar();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LoteIngrediente>>(
      future: _lotes,
      builder: (context, instantanea) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(SoleraL10n.t('obra.lotes'),
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              TextButton.icon(
                onPressed: _recibir,
                icon: const Icon(Icons.add),
                label: Text(SoleraL10n.t('obra.recibir_lote')),
              ),
            ],
          ),
          for (final lote in instantanea.data ?? const <LoteIngrediente>[])
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(lote.codigoLote),
              subtitle: Text([
                DateFormat.yMMMd(SoleraL10n.idioma).format(
                    DateTime.fromMillisecondsSinceEpoch(lote.fechaRecepcionMs)),
                if (lote.cantidadKg > 0)
                  '${formatearNumero(lote.cantidadKg)} kg',
                if (lote.temperaturaRecepcionC != null)
                  '${formatearNumero(lote.temperaturaRecepcionC!)} °C',
              ].join(' · ')),
            ),
        ],
      ),
    );
  }
}
