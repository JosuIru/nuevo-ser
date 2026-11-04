import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../utiles/textos_visibles.dart';

import '../datos/base_datos.dart';
import '../modelos/parcela.dart';
import 'pantalla_ficha_parcela.dart';
import 'pantalla_nueva_parcela.dart';

/// Listado de todas las parcelas del olivar. Pulsa para ver la ficha,
/// botón flotante para registrar una nueva.
class PantallaListaParcelas extends StatefulWidget {
  const PantallaListaParcelas({super.key});

  @override
  State<PantallaListaParcelas> createState() => _PantallaListaParcelasState();
}

class _PantallaListaParcelasState extends State<PantallaListaParcelas> {
  List<Parcela> _parcelas = const [];
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final bd = BaseDatosSoleraAceitera();
    final ps = await bd.listarParcelas();
    if (!mounted) return;
    setState(() => _parcelas = ps);
  }

  List<Parcela> get _filtradas {
    if (_filtro.isEmpty) return _parcelas;
    final q = _filtro.toLowerCase();
    return _parcelas
        .where((p) =>
            p.nombre.toLowerCase().contains(q) ||
            p.codigoSigpac.toLowerCase().contains(q) ||
            p.variedadMayoritariaId.toLowerCase().contains(q))
        .toList(growable: false);
  }

  Future<void> _abrirNueva() async {
    final olivar = await BaseDatosSoleraAceitera().obtenerOlivar();
    if (!mounted) return;
    if (olivar?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('acei.falta_crear_olivar'))),
      );
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PantallaNuevaParcela(olivarId: olivar!.id!),
    ));
    await _cargar();
  }

  Future<void> _abrirFicha(Parcela p) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PantallaFichaParcela(parcela: p),
    ));
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('acei.parcelas'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: SoleraL10n.t('acei.buscar_parcelas'),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _filtro = v),
            ),
          ),
          Expanded(
            child: _filtradas.isEmpty
                ? Center(
                    child: Text(
                      '${SoleraL10n.t('acei.sin_parcelas')}\n'
                      '${SoleraL10n.t('acei.sin_parcelas_ayuda')}',
                      textAlign: TextAlign.center,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _cargar,
                    child: ListView.builder(
                      itemCount: _filtradas.length,
                      itemBuilder: (_, i) {
                        final p = _filtradas[i];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.park,
                                color: Color(0xFF5C6B3A)),
                            title: Text(p.nombre.isEmpty
                                ? SoleraL10n.t('acei.sin_nombre')
                                : p.nombre),
                            subtitle: Text(
                              '${formatearNumero(p.superficieHa, decimales: 2)} ha · '
                              '${p.variedadMayoritariaId.isEmpty ? SoleraL10n.t('acei.variedad_sin_definir') : p.variedadMayoritariaId} · '
                              '${nombreSistemaRiego(p.sistemaRiego)}',
                            ),
                            onTap: () => _abrirFicha(p),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirNueva,
        child: const Icon(Icons.add),
      ),
    );
  }
}
