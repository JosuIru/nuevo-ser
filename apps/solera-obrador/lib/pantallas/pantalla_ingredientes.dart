import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/alergenos.dart';
import '../modelos/ingrediente.dart';
import '../utiles/textos_obrador.dart';

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
        title: Text(widget.ingrediente == null
            ? SoleraL10n.t('obra.nuevo_ingrediente')
            : widget.ingrediente!.nombre),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nombre,
            decoration: InputDecoration(labelText: SoleraL10n.t('obra.nombre')),
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
