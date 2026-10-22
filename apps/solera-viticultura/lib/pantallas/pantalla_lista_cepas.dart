import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../modelos/cepa.dart';
import '../modelos/vinedo.dart';
import 'pantalla_ficha_cepa.dart';

/// Lista filtrable de cepas. Muestra variedad, etiqueta, viñedo (si
/// pertenece a uno) y fecha de creación. Tap → ficha.
///
/// Versión minimalista v0.1: filtro de texto sobre etiqueta + variedad
/// + notas. Sin filtros estructurados por viñedo o variedad — eso se
/// añade cuando entren los catálogos curados (F1-4).
class PantallaListaCepas extends StatefulWidget {
  const PantallaListaCepas({super.key});

  @override
  State<PantallaListaCepas> createState() => _PantallaListaCepasState();
}

class _PantallaListaCepasState extends State<PantallaListaCepas> {
  List<Cepa> _cepas = [];
  Map<int, Vinedo> _vinedosPorId = {};
  String _busqueda = '';
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final db = BaseDatosSoleraViticultura.instancia;
    final cepas = await db.listarCepas();
    final vinedos = await db.listarVinedos();
    if (!mounted) return;
    setState(() {
      _cepas = cepas;
      _vinedosPorId = {for (final v in vinedos) v.id!: v};
      _cargando = false;
    });
  }

  List<Cepa> _cepasFiltradas() {
    final q = _busqueda.trim().toLowerCase();
    if (q.isEmpty) return _cepas;
    return _cepas.where((c) {
      return c.etiqueta.toLowerCase().contains(q) ||
          c.variedadId.toLowerCase().contains(q) ||
          c.notas.toLowerCase().contains(q) ||
          c.portainjertoId.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _cepasFiltradas();
    final formatoFecha = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cepas'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Buscar (etiqueta, variedad, portainjerto, notas)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (v) => setState(() => _busqueda = v),
            ),
          ),
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : filtradas.isEmpty
              ? Center(
                  child: Text(
                    _cepas.isEmpty ? 'Sin cepas registradas todavía.' : 'Sin resultados.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ListView.separated(
                  itemCount: filtradas.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final c = filtradas[i];
                    final v = c.vinedoId == null ? null : _vinedosPorId[c.vinedoId];
                    final etiqueta = c.etiqueta.isEmpty ? '#${c.id}' : c.etiqueta;
                    final fechaCreacion = formatoFecha.format(
                      DateTime.fromMillisecondsSinceEpoch(c.fechaCreacionMs),
                    );
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          etiqueta.substring(0, etiqueta.length.clamp(0, 2)),
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                      title: Text('$etiqueta · ${c.variedadId}'),
                      subtitle: Text([
                        if (v != null) v.nombre else 'Punto suelto',
                        if (c.portainjertoId.isNotEmpty) c.portainjertoId,
                        'Alta $fechaCreacion',
                      ].join(' · ')),
                      onTap: () async {
                        final cambio = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(builder: (_) => PantallaFichaCepa(cepaId: c.id!)),
                        );
                        if (cambio == true) _cargar();
                      },
                    );
                  },
                ),
    );
  }
}
