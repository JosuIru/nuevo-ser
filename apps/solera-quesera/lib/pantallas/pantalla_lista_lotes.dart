import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/lote_produccion.dart';
import 'pantalla_ficha_lote.dart';
import 'pantalla_nuevo_lote.dart';

class PantallaListaLotes extends StatefulWidget {
  PantallaListaLotes({super.key, this.barraPestanas});

  /// Pestañas Lotes/Cava bajo la barra superior cuando la pantalla va
  /// dentro de la pestaña Lotes (ver `PantallaLotesYCava`).
  final PreferredSizeWidget? barraPestanas;
  @override
  State<PantallaListaLotes> createState() => _PantallaListaLotesState();
}

class _PantallaListaLotesState extends State<PantallaListaLotes> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  List<LoteProduccion> _lotes = [];
  String? _filtroEstado;
  final _buscador = TextEditingController();
  final _formatter = DateFormat('d MMM yyyy', 'es_ES');

  @override
  void initState() { super.initState(); _recargar(); }

  Future<void> _recargar() async {
    final lotes = await _bd.listarLotes(estado: _filtroEstado);
    if (mounted) setState(() => _lotes = lotes);
  }

  List<LoteProduccion> get _filtrados {
    final q = _buscador.text.toLowerCase().trim();
    if (q.isEmpty) return _lotes;
    return _lotes.where((l) => l.numeroLote.toLowerCase().contains(q) || l.tipoQuesoId.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() { _buscador.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtrados = _filtrados;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('lotes_de_produccion')),
        bottom: widget.barraPestanas,
        actions: [PopupMenuButton<String?>(icon: Icon(Icons.filter_list), onSelected: (e) { setState(() => _filtroEstado = e); _recargar(); },
          itemBuilder: (_) => [
            PopupMenuItem(value: null, child: Text(SoleraL10n.t('todos'))),
            PopupMenuItem(value: 'fresca', child: Text(SoleraL10n.t('fresca'))),
            PopupMenuItem(value: 'enCuracion', child: Text(SoleraL10n.t('en_curacion'))),
            PopupMenuItem(value: 'lista', child: Text(SoleraL10n.t('lista'))),
            PopupMenuItem(value: 'baja', child: Text(SoleraL10n.t('baja'))),
          ]),
        ],
      ),
      body: Column(children: [
        if (_lotes.isNotEmpty) BarraBusqueda(controlador: _buscador, onChanged: (_) => setState(() {}), sugerencia: 'Buscar lote…'),
        Expanded(child: RefreshIndicator(onRefresh: _recargar, child: filtrados.isEmpty && _lotes.isNotEmpty
            ? Center(child: Text('Sin resultados'))
            : _lotes.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: theme.colorScheme.outline),
                    SizedBox(height: 16),
                    Text(SoleraL10n.t('aun_no_hay_lotes'), style: theme.textTheme.titleMedium),
                    SizedBox(height: 8),
                    FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaNuevoLote())), child: Text(SoleraL10n.t('crear_primer_lote'))),
                  ]))
                : ListView.builder(padding: const EdgeInsets.all(8), itemCount: filtrados.length, itemBuilder: (_, i) {
                    final l = filtrados[i];
                    final f = DateTime.fromMillisecondsSinceEpoch(l.fechaMs);
                    return Card(child: ListTile(
                      leading: _IconoEstado(l.estado),
                      title: Text(l.numeroLote, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${l.tipoQuesoId} · ${_formatter.format(f)} · ${l.volumenLecheTotal}L → ${l.pesoTotalObtenido}kg · ${l.numPiezasProducidas} piezas'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaFichaLote(loteId: l.id!))),
                    ));
                  }),
        )),
      ]),
      floatingActionButton: FloatingActionButton(heroTag: 'fab_nuevo_lote', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaNuevoLote())), child: Icon(Icons.add)),
    );
  }
}

Widget _IconoEstado(String estado) {
  switch (estado) {
    case 'fresca': return CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.water_drop, color: Colors.white));
    case 'enCuracion': return CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.schedule, color: Colors.white));
    case 'lista': return CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check, color: Colors.white));
    case 'baja': return CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.block, color: Colors.white));
    default: return CircleAvatar(child: Icon(Icons.help_outline));
  }
}
