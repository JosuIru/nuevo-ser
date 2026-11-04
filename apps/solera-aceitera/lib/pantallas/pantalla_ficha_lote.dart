import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../modelos/analitica.dart';
import '../modelos/lote_aceite.dart';
import '../modelos/movimiento.dart';
import '../utiles/textos_visibles.dart';

/// Ficha de un lote de aceite: datos analíticos + libro de movimientos
/// del lote + analíticas históricas si hay más de una.
class PantallaFichaLote extends StatefulWidget {
  final LoteAceite lote;

  const PantallaFichaLote({super.key, required this.lote});

  @override
  State<PantallaFichaLote> createState() => _PantallaFichaLoteState();
}

class _PantallaFichaLoteState extends State<PantallaFichaLote> {
  final _formatoFecha = DateFormat('d/M/yyyy', 'es_ES');
  List<Movimiento> _movimientos = const [];
  List<Analitica> _analiticas = const [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final bd = BaseDatosSoleraAceitera();
    final ms = await bd.listarMovimientos(loteAceiteId: widget.lote.id);
    final as_ = await bd.listarAnaliticas(loteAceiteId: widget.lote.id);
    if (!mounted) return;
    setState(() {
      _movimientos = ms;
      _analiticas = as_;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lote;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.tf('acei.lote_id', {'lote': l.identificadorLote}))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(SoleraL10n.tf('acei.kilos_netos_valor', {'kg': l.kgNetos.toStringAsFixed(1)})),
                  Text(SoleraL10n.tf('acei.categoria_valor', {'categoria': nombreCategoriaAceite(l.categoria)})),
                  if (l.dopId.isNotEmpty) Text('DOP: ${l.dopId}'),
                  if (l.ubicacionFisica.isNotEmpty)
                    Text(SoleraL10n.tf('acei.ubicacion_valor', {'ubicacion': l.ubicacionFisica})),
                  const Divider(),
                  if (l.acidez != null)
                    Text(SoleraL10n.tf('acei.acidez_valor', {'acidez': l.acidez!.toStringAsFixed(2)})),
                  if (l.peroxidos != null)
                    Text(SoleraL10n.tf('acei.peroxidos_valor', {'peroxidos': l.peroxidos!.toStringAsFixed(1)})),
                  if (l.k232 != null)
                    Text('K232: ${l.k232!.toStringAsFixed(2)}'),
                  if (l.k270 != null)
                    Text('K270: ${l.k270!.toStringAsFixed(2)}'),
                  if (l.polifenolesMgKg != null)
                    Text(SoleraL10n.tf('acei.polifenoles_valor', {'polifenoles': l.polifenolesMgKg!.toStringAsFixed(0)})),
                  if (l.panelTestPuntuacion != null)
                    Text(SoleraL10n.tf('acei.panel_cata_valor', {'puntuacion': l.panelTestPuntuacion!.toStringAsFixed(1)})),
                  if (l.panelTestNotas.isNotEmpty)
                    Text(SoleraL10n.tf('acei.notas_panel_cata_valor', {'notas': l.panelTestNotas}),
                        style: const TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(SoleraL10n.t('acei.movimientos_del_lote'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          if (_movimientos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(SoleraL10n.t('acei.sin_movimientos_registrados')),
            )
          else
            ..._movimientos.map((m) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.swap_horiz,
                        color: Color(0xFF5C6B3A)),
                    title: Text(nombreTipoMovimiento(m.tipo)),
                    subtitle: Text(
                      '${m.kgMovidos.toStringAsFixed(1)} kg'
                      '${m.ubicacionDestino.isEmpty ? "" : " · ${m.ubicacionDestino}"}',
                    ),
                    trailing: Text(
                      _formatoFecha.format(
                          DateTime.fromMillisecondsSinceEpoch(m.fechaMs)),
                    ),
                  ),
                )),
          const SizedBox(height: 16),
          Text(SoleraL10n.t('acei.analiticas'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          if (_analiticas.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(SoleraL10n.t('acei.sin_analiticas_registradas')),
            )
          else
            ..._analiticas.map((a) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.science, color: Color(0xFF5C6B3A)),
                    title: Text(a.laboratorio.isEmpty
                        ? SoleraL10n.t('acei.laboratorio_sin_indicar')
                        : a.laboratorio),
                    subtitle: Text(
                      SoleraL10n.tf('acei.acidez_y_panel', {
                        'acidez': a.acidez?.toStringAsFixed(2) ?? '—',
                        'panel': a.panelTestPuntuacion?.toStringAsFixed(1) ?? '—',
                      }),
                    ),
                    trailing: Text(_formatoFecha.format(
                        DateTime.fromMillisecondsSinceEpoch(a.fechaMs))),
                  ),
                )),
        ],
      ),
    );
  }
}
