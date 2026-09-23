import 'package:flutter/material.dart';

import '../datos/base_datos.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/punto_infraestructura.dart';
import '../modelos/tarea_mantenimiento.dart';
import '../utiles/estilos_tarea.dart';
import 'nueva_tarea.dart';
import 'widgets/acciones_tarea.dart';
import 'widgets/tile_tarea.dart';

/// Detalle de un punto de infraestructura: tipo, estado, coordenadas y la
/// lista de sus tareas de mantenimiento. Permite añadir tareas y borrar el
/// punto.
class FichaPunto extends StatefulWidget {
  const FichaPunto({super.key, required this.punto});

  final PuntoInfraestructura punto;

  @override
  State<FichaPunto> createState() => _FichaPuntoState();
}

class _FichaPuntoState extends State<FichaPunto> {
  final _bd = BaseDatosSoleraZunbeltz();
  List<TareaMantenimiento> _tareas = const [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final tareas = await _bd.listarTareas(puntoId: widget.punto.id);
    if (!mounted) return;
    setState(() {
      _tareas = tareas;
      _cargando = false;
    });
  }

  Future<void> _nuevaTarea() async {
    final creada = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NuevaTarea(
          fincaId: widget.punto.fincaId,
          puntoId: widget.punto.id,
        ),
      ),
    );
    if (creada == true) await _cargar();
  }

  Future<void> _accionesTarea(TareaMantenimiento tarea) async {
    if (await mostrarAccionesTarea(context, tarea)) await _cargar();
  }

  Future<void> _marcarHecha(TareaMantenimiento tarea) async {
    final id = tarea.id;
    if (id == null) return;
    final textos = AppLocalizations.of(context);
    final generoSiguiente = await _bd.marcarTareaHecha(id) != null;
    await _cargar();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(generoSiguiente
            ? textos.tareaSiguienteGenerada
            : textos.tareaGuardada)));
  }

  Future<void> _borrarPunto() async {
    final textos = AppLocalizations.of(context);
    final confirma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(textos.fichaBorrarPunto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(textos.comunCancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(textos.comunBorrar),
          ),
        ],
      ),
    );
    if (confirma != true || widget.punto.id == null) return;
    await _bd.borrarPunto(widget.punto.id!);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final punto = widget.punto;
    final tipo = buscarOpcion(tiposPunto, punto.tipo)?.etiqueta(idioma) ?? punto.tipo;
    final estado =
        buscarOpcion(estadosPunto, punto.estado)?.etiqueta(idioma) ?? punto.estado;
    final titulo = punto.nombre.isEmpty ? tipo : punto.nombre;
    final tieneCoords = punto.latitud != null && punto.longitud != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          IconButton(
            tooltip: textos.fichaRecolocar,
            icon: const Icon(Icons.edit_location_alt_outlined),
            onPressed: () => Navigator.of(context).pop('recolocar'),
          ),
          IconButton(
            tooltip: textos.fichaBorrarPunto,
            icon: const Icon(Icons.delete_outline),
            onPressed: _borrarPunto,
          ),
        ],
      ),
      floatingActionButton: politicaTareasActual.puedeCrear
          ? FloatingActionButton.extended(
              onPressed: _nuevaTarea,
              icon: const Icon(Icons.add_task),
              label: Text(textos.fichaNuevaTarea),
            )
          : null,
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colorEstadoPunto(punto.estado),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$tipo · $estado',
                          style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(textos.fichaCoordenadas),
                  subtitle: Text(tieneCoords
                      ? '${punto.latitud!.toStringAsFixed(6)}, ${punto.longitud!.toStringAsFixed(6)}'
                      : textos.fichaSinCoordenadas),
                ),
                if (punto.notas.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Text(punto.notas),
                  ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(textos.fichaPuntoTareas,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                if (_tareas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(textos.fichaSinTareas),
                  )
                else
                  for (final tarea in _tareas)
                    TileTarea(
                      tarea: tarea,
                      idioma: idioma,
                      onTap: () => _accionesTarea(tarea),
                      onMarcarHecha: politicaTareasActual.puedeEjecutar(tarea)
                          ? () => _marcarHecha(tarea)
                          : null,
                    ),
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}
