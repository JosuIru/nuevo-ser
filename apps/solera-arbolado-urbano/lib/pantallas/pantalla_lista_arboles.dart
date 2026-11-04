import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../modelos/arbol.dart';
import '../modelos/zona.dart';
import '../utiles/etiquetas_l10n.dart';
import 'pantalla_ficha_arbol.dart';

/// Lista filtrable de árboles por identificador, especie, estado o zona.
/// Es la pestaña «Árboles» de la barra inferior.
class PantallaListaArboles extends StatefulWidget {
  const PantallaListaArboles({super.key, this.avisoRecarga});

  /// Si se da, la lista se relee cada vez que avisa (al volver a la
  /// pestaña tras dar de alta un árbol en el mapa, por ejemplo).
  final Listenable? avisoRecarga;

  @override
  State<PantallaListaArboles> createState() => _PantallaListaArbolesState();
}

class _PantallaListaArbolesState extends State<PantallaListaArboles> {
  List<Arbol> _arboles = [];
  Map<int, Zona> _zonasPorId = {};
  String _busqueda = '';
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    widget.avisoRecarga?.addListener(_cargar);
    _cargar();
  }

  @override
  void dispose() {
    widget.avisoRecarga?.removeListener(_cargar);
    super.dispose();
  }

  Future<void> _cargar() async {
    final db = BaseDatosSoleraArbolado.instancia;
    final arboles = await db.listarArboles();
    final zonas = await db.listarZonas();
    if (!mounted) return;
    setState(() {
      _arboles = arboles;
      _zonasPorId = {for (final z in zonas) z.id!: z};
      _cargando = false;
    });
  }

  List<Arbol> _filtradas() {
    final q = _busqueda.trim().toLowerCase();
    if (q.isEmpty) return _arboles;
    return _arboles.where((a) {
      return a.identificadorMunicipal.toLowerCase().contains(q) ||
          a.especieId.toLowerCase().contains(q) ||
          a.qrPayload.toLowerCase().contains(q) ||
          a.notas.toLowerCase().contains(q);
    }).toList();
  }

  Color _colorEstado(EstadoArbol e, ColorScheme paleta) {
    switch (e) {
      case EstadoArbol.sano:
        return paleta.primary;
      case EstadoArbol.observacion:
        return Colors.amber.shade700;
      case EstadoArbol.riesgo:
        return Colors.red;
      case EstadoArbol.caido:
        return Colors.grey.shade700;
      case EstadoArbol.sustituido:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _filtradas();
    final formatoFecha = DateFormat('dd/MM/yyyy');
    final paleta = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('arb.arboles')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                hintText: SoleraL10n.t('arb.buscar_arboles_hint'),
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
                    _arboles.isEmpty
                        ? SoleraL10n.t('arb.sin_arboles_inventariados')
                        : SoleraL10n.t('arb.sin_resultados'),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ListView.separated(
                  itemCount: filtradas.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final a = filtradas[i];
                    final zona = a.zonaId == null ? null : _zonasPorId[a.zonaId];
                    final fechaCreacion = formatoFecha.format(
                      DateTime.fromMillisecondsSinceEpoch(a.fechaCreacionMs),
                    );
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _colorEstado(a.estado, paleta),
                        child: const Icon(Icons.park, color: Colors.white, size: 18),
                      ),
                      title: Text(a.identificadorMunicipal),
                      subtitle: Text([
                        zona?.nombre ?? SoleraL10n.t('arb.sin_zona'),
                        if (a.especieId.isNotEmpty) a.especieId,
                        etiquetaEstadoArbol(a.estado),
                        if (a.riesgoVta != null) 'VTA ${a.riesgoVta}',
                        SoleraL10n.tf('arb.alta_fecha', {'fecha': fechaCreacion}),
                      ].join(' · ')),
                      onTap: () async {
                        final cambio = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                              builder: (_) => PantallaFichaArbol(arbolId: a.id!)),
                        );
                        if (cambio == true) _cargar();
                      },
                    );
                  },
                ),
    );
  }
}
