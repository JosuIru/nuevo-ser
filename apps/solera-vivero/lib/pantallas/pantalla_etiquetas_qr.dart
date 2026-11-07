import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../modelos/bandeja.dart';
import '../modelos/zona_cultivo.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/etiquetas_qr_bandejas.dart';
import '../utiles/textos_vivero.dart';

/// Elegir bandejas e imprimir sus etiquetas QR (patrón de Arbolado urbano,
/// `pantalla_generar_qr.dart`, con selección y hoja de varias etiquetas).
class PantallaEtiquetasQr extends StatefulWidget {
  const PantallaEtiquetasQr({super.key});

  @override
  State<PantallaEtiquetasQr> createState() => _PantallaEtiquetasQrState();
}

class _PantallaEtiquetasQrState extends State<PantallaEtiquetasQr> {
  List<Bandeja> _bandejas = [];
  Map<int, ZonaCultivo> _zonas = {};
  final Set<int> _elegidas = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final bd = BaseDatosSoleraVivero.instancia;
    final bandejas = await bd.listarBandejas(soloActivas: true);
    final zonas = {for (final zona in await bd.listarZonas()) zona.id!: zona};
    if (!mounted) return;
    setState(() {
      _bandejas = bandejas;
      _zonas = zonas;
      _elegidas.addAll(bandejas.map((bandeja) => bandeja.id!));
      _cargando = false;
    });
  }

  Future<void> _imprimir() {
    final etiquetas = [
      for (final bandeja in _bandejas)
        if (_elegidas.contains(bandeja.id))
          etiquetaDeBandeja(bandeja,
              nombreZona: _zonas[bandeja.zonaId]?.nombre ?? '',
              nombreFormato: nombreFormato(bandeja.formato)),
    ];
    return compartirDocumentoPdf(
      context,
      nombreFichero: 'etiquetas_bandejas.pdf',
      generar: (tema) => generarEtiquetasQrBandejas(etiquetas, tema: tema),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('vive.etiquetas_qr')),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              if (_elegidas.length == _bandejas.length) {
                _elegidas.clear();
              } else {
                _elegidas.addAll(_bandejas.map((bandeja) => bandeja.id!));
              }
            }),
            child: Text('${_elegidas.length}/${_bandejas.length}'),
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _bandejas.isEmpty
              ? Center(child: Text(SoleraL10n.t('vive.sin_bandejas')))
              : ListView(
                  children: [
                    for (final bandeja in _bandejas)
                      CheckboxListTile(
                        dense: true,
                        value: _elegidas.contains(bandeja.id),
                        title: Text(bandeja.codigoQr),
                        subtitle: Text(nombreFormato(bandeja.formato)),
                        onChanged: (valor) => setState(() {
                          if (valor == true) {
                            _elegidas.add(bandeja.id!);
                          } else {
                            _elegidas.remove(bandeja.id);
                          }
                        }),
                      ),
                  ],
                ),
      floatingActionButton: _elegidas.isEmpty
          ? null
          : FloatingActionButton.extended(
              heroTag: 'fab_etiquetas_qr',
              onPressed: _imprimir,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(SoleraL10n.tf(
                  'vive.imprimir_etiquetas_n', {'n': _elegidas.length})),
            ),
    );
  }
}
