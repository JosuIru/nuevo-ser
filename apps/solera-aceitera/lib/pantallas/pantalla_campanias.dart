import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../modelos/campania.dart';
import '../modelos/olivar.dart';

/// Campañas de recolección: la lista (la abierta, arriba con su chip) y
/// el botón para abrir una nueva. Recolecciones, partidas y molturaciones
/// cuelgan de la campaña abierta.
class PantallaCampanias extends StatefulWidget {
  const PantallaCampanias({super.key});

  @override
  State<PantallaCampanias> createState() => _PantallaCampaniasState();
}

class _PantallaCampaniasState extends State<PantallaCampanias> {
  static const _colorIconos = Color(0xFF5C6B3A);
  final _formatoFecha = DateFormat('d/M/yyyy', 'es_ES');
  Olivar? _olivar;
  List<Campania> _campanias = const [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final baseDatos = BaseDatosSoleraAceitera();
    final olivar = await baseDatos.obtenerOlivar();
    final campanias = await baseDatos.listarCampanias();
    if (!mounted) return;
    setState(() {
      _olivar = olivar;
      _campanias = campanias;
      _cargando = false;
    });
  }

  Future<void> _abrirNuevaCampania() async {
    final olivar = _olivar;
    if (olivar?.id == null) return;
    final ahora = DateTime.now();
    await BaseDatosSoleraAceitera().insertarCampania(Campania(
      olivarId: olivar!.id!,
      anyoComercial: ahora.year,
      fechaInicioMs: ahora.millisecondsSinceEpoch,
    ));
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campañas de recolección')),
      floatingActionButton: _olivar?.id == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _abrirNuevaCampania,
              icon: const Icon(Icons.add),
              label: const Text('Nueva campaña'),
            ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 96),
                children: [
                  if (_campanias.isEmpty)
                    const Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Todavía no has abierto ninguna campaña.\n'
                          'Crea una para empezar a registrar recolecciones, '
                          'partidas y molturaciones.',
                        ),
                      ),
                    )
                  else
                    ..._campanias.map((campania) => Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              campania.estaAbierta
                                  ? Icons.local_fire_department
                                  : Icons.history,
                              color: campania.estaAbierta
                                  ? _colorIconos
                                  : Colors.grey,
                            ),
                            title: Text(
                                '${campania.anyoComercial}/${campania.anyoComercial + 1}'),
                            subtitle: Text(
                              'Inicio: ${_formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(campania.fechaInicioMs))}',
                            ),
                            trailing: campania.estaAbierta
                                ? const Chip(label: Text('Abierta'))
                                : null,
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}
