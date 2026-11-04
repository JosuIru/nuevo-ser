import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../modelos/apiario.dart';
import '../modelos/colmena.dart';
import '../utiles/etiquetas_visibles.dart';
import 'pantalla_ficha_colmena.dart';

/// Lista filtrable de colmenas por matrícula, raza, estado o notas.
class PantallaListaColmenas extends StatefulWidget {
  const PantallaListaColmenas({super.key});

  @override
  State<PantallaListaColmenas> createState() => _PantallaListaColmenasState();
}

class _PantallaListaColmenasState extends State<PantallaListaColmenas> {
  List<Colmena> _colmenas = [];
  Map<int, Apiario> _apiariosPorId = {};
  String _busqueda = '';
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final db = BaseDatosSoleraApicola.instancia;
    final colmenas = await db.listarColmenas();
    final apiarios = await db.listarApiarios();
    if (!mounted) return;
    setState(() {
      _colmenas = colmenas;
      _apiariosPorId = {for (final a in apiarios) a.id!: a};
      _cargando = false;
    });
  }

  List<Colmena> _filtradas() {
    final q = _busqueda.trim().toLowerCase();
    if (q.isEmpty) return _colmenas;
    return _colmenas.where((c) {
      return c.matricula.toLowerCase().contains(q) ||
          c.razaId.toLowerCase().contains(q) ||
          c.tipoColmenaId.toLowerCase().contains(q) ||
          c.notas.toLowerCase().contains(q);
    }).toList();
  }

  Color _colorEstado(EstadoColmena e, ColorScheme paleta) {
    switch (e) {
      case EstadoColmena.viva:
      case EstadoColmena.enjambreNuevo:
        return paleta.primary;
      case EstadoColmena.vacia:
        return Colors.grey.shade500;
      case EstadoColmena.descolmenada:
        return Colors.red.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _filtradas();
    final formatoFecha = DateFormat('dd/MM/yyyy');
    final paleta = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('api.colmenas')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                hintText: SoleraL10n.t('api.buscar_colmenas_pista'),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
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
                    _colmenas.isEmpty ? SoleraL10n.t('api.sin_colmenas_todavia') : SoleraL10n.t('api.sin_resultados'),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ListView.separated(
                  itemCount: filtradas.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final c = filtradas[i];
                    final a = c.apiarioId == null ? null : _apiariosPorId[c.apiarioId];
                    final fechaCreacion = formatoFecha.format(
                      DateTime.fromMillisecondsSinceEpoch(c.fechaCreacionMs),
                    );
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _colorEstado(c.estado, paleta),
                        child: const Icon(Icons.hexagon, color: Colors.white, size: 18),
                      ),
                      title: Text(c.matricula),
                      subtitle: Text([
                        a?.nombre ?? SoleraL10n.t('api.punto_suelto'),
                        if (c.razaId.isNotEmpty) c.razaId,
                        etiquetaEstadoColmena(c.estado),
                        if (c.anoReina != null)
                          SoleraL10n.tf('api.reina_ano_color', {
                            'ano': c.anoReina,
                            'color': etiquetaColorMarcaReina(c.colorMarcaReina),
                          }),
                        SoleraL10n.tf('api.alta_fecha', {'fecha': fechaCreacion}),
                      ].join(' · ')),
                      onTap: () async {
                        final cambio = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(builder: (_) => PantallaFichaColmena(colmenaId: c.id!)),
                        );
                        if (cambio == true) _cargar();
                      },
                    );
                  },
                ),
    );
  }
}
