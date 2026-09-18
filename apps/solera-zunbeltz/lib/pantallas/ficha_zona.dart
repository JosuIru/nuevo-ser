import 'package:flutter/material.dart';

import '../datos/base_datos.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/tarea_mantenimiento.dart';
import '../modelos/zona_finca.dart';
import '../utiles/estilos_tarea.dart';
import '../utiles/geodesia.dart';
import 'nueva_tarea.dart';
import 'widgets/tile_tarea.dart';

/// Detalle de una zona dibujada: tipo, estado, superficie, perímetro y sus
/// tareas de mantenimiento. Permite añadir tareas, volver a dibujar el
/// trazado (devuelve `'redibujar'` al mapa) y borrar la zona.
class FichaZona extends StatefulWidget {
  const FichaZona({super.key, required this.zona});

  final ZonaFinca zona;

  @override
  State<FichaZona> createState() => _FichaZonaState();
}

class _FichaZonaState extends State<FichaZona> {
  final _bd = BaseDatosSoleraZunbeltz();
  List<TareaMantenimiento> _tareas = const [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final tareas = await _bd.listarTareas(zonaId: widget.zona.id);
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
          fincaId: widget.zona.fincaId,
          zonaId: widget.zona.id,
        ),
      ),
    );
    if (creada == true) await _cargar();
  }

  Future<void> _borrarZona() async {
    final textos = AppLocalizations.of(context);
    final confirma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(textos.zonaBorrar),
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
    if (confirma != true || widget.zona.id == null) return;
    await _bd.borrarZona(widget.zona.id!);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final zona = widget.zona;
    final tipo = buscarOpcion(tiposZona, zona.tipo)?.etiqueta(idioma) ?? zona.tipo;
    final estado =
        buscarOpcion(estadosZona, zona.estado)?.etiqueta(idioma) ?? zona.estado;
    final titulo = zona.nombre.isEmpty ? tipo : zona.nombre;
    final metrosPerimetro = perimetroMetros(zona.vertices);

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          IconButton(
            tooltip: textos.zonaRedibujar,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).pop('redibujar'),
          ),
          IconButton(
            tooltip: textos.zonaBorrar,
            icon: const Icon(Icons.delete_outline),
            onPressed: _borrarZona,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevaTarea,
        icon: const Icon(Icons.add_task),
        label: Text(textos.zonaNuevaTarea),
      ),
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
                          color: colorEstadoZona(zona.estado),
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
                  leading: const Icon(Icons.crop_square),
                  title: Text(textos.zonaSuperficie),
                  subtitle: Text(zona.tieneSuperficieOficial
                      ? '${zona.superficieHa.toStringAsFixed(2)} ha · SIGPAC'
                      : '${zona.superficieHa.toStringAsFixed(2)} ha · ${textos.zonaOrientativa}'),
                ),
                ListTile(
                  leading: const Icon(Icons.timeline),
                  title: Text(textos.zonaPerimetro),
                  subtitle: Text('${metrosPerimetro.toStringAsFixed(0)} m · '
                      '${textos.dibujoEsquinas(zona.vertices.length)}'),
                ),
                if (zona.recintoSigpac.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.map_outlined),
                    title: Text(textos.zonaRecintoSigpac),
                    subtitle: Text(zona.recintoSigpac),
                  ),
                if (!zona.tieneSuperficieOficial)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Text(
                      textos.zonaAvisoSuperficie,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                if (zona.notas.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Text(zona.notas),
                  ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(textos.zonaTareas,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                if (_tareas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(textos.zonaSinTareas),
                  )
                else
                  for (final tarea in _tareas)
                    TileTarea(tarea: tarea, idioma: idioma),
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}
