import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../modelos/lote_aceite.dart';
import '../utiles/textos_visibles.dart';
import 'pantalla_ficha_lote.dart';
import 'pantalla_nueva_partida.dart';

/// Listado de lotes de aceite. El botón flotante registra una nueva
/// partida de aceituna en almazara (el flujo natural: recibo aceituna
/// → molturamos → nace el lote). El alta directa de un lote sin
/// molturación es un edge case que cubrirá F1-A4 si hace falta.
class PantallaListaLotes extends StatefulWidget {
  const PantallaListaLotes({super.key});

  @override
  State<PantallaListaLotes> createState() => _PantallaListaLotesState();
}

class _PantallaListaLotesState extends State<PantallaListaLotes> {
  final _formatoFecha = DateFormat('d/M/yyyy', 'es_ES');
  List<LoteAceite> _lotes = const [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final ls = await BaseDatosSoleraAceitera().listarLotesAceite();
    if (!mounted) return;
    setState(() => _lotes = ls);
  }

  Future<void> _registrarPartida() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const PantallaNuevaPartida(),
    ));
    await _cargar();
  }

  Future<void> _abrirFicha(LoteAceite lote) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PantallaFichaLote(lote: lote),
    ));
    await _cargar();
  }

  Color _colorCategoria(String categoria) {
    switch (categoria) {
      case 'virgen_extra':
        return const Color(0xFF5C6B3A);
      case 'virgen':
        return const Color(0xFFA08C2C);
      case 'lampante':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('acei.lotes_de_aceite'))),
      body: _lotes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${SoleraL10n.t('acei.sin_lotes_todavia')}\n\n'
                  '${SoleraL10n.t('acei.sin_lotes_ayuda')}',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView.builder(
                itemCount: _lotes.length,
                itemBuilder: (_, i) {
                  final l = _lotes[i];
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.water_drop,
                          color: _colorCategoria(l.categoria)),
                      title: Text(l.identificadorLote),
                      subtitle: Text(
                        '${l.kgNetos.toStringAsFixed(0)} kg · '
                        '${nombreCategoriaAceite(l.categoria)}'
                        '${l.dopId.isEmpty ? "" : " · DOP ${l.dopId}"}',
                      ),
                      trailing: Text(
                        _formatoFecha.format(
                            DateTime.fromMillisecondsSinceEpoch(
                                l.fechaCreacionMs)),
                      ),
                      onTap: () => _abrirFicha(l),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _registrarPartida,
        icon: const Icon(Icons.add),
        label: Text(SoleraL10n.t('acei.nueva_partida')),
      ),
    );
  }
}
