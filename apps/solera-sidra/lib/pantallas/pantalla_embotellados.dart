import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/estado_bodega.dart';
import '../utiles/textos_sidra.dart';

/// Lotes embotellados (se embotella desde la ficha de cada kupela).
class PantallaEmbotellados extends StatelessWidget {
  const PantallaEmbotellados({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('sidr.embotellados'))),
      body: FutureBuilder<EstadoBodega>(
        future: EstadoBodega.cargar(),
        builder: (context, instantanea) {
          final estado = instantanea.data;
          if (estado == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (estado.embotellados.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(SoleraL10n.t('sidr.sin_embotellados'),
                    textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            children: [
              for (final embotellado in estado.embotellados)
                ListTile(
                  leading: Icon(embotellado.etiquetasDescuadradas
                      ? Icons.warning_amber_outlined
                      : Icons.liquor_outlined),
                  title: Text(
                      '${embotellado.codigoLote} · ${SoleraL10n.tf('sidr.n_botellas', {
                        'n': embotellado.botellas
                      })}'),
                  subtitle: Text([
                    [
                      formatearFecha(embotellado.fechaMs),
                      estado.etiquetaKupela(embotellado.kupelaId),
                      formatearLitros(embotellado.litros),
                      if (embotellado.destino.isNotEmpty) embotellado.destino,
                    ].join(' · '),
                    if (embotellado.conDop && embotellado.etiquetaDesde != null)
                      SoleraL10n.tf('sidr.contraetiquetas_rango', {
                        'desde': embotellado.etiquetaDesde,
                        'hasta': embotellado.etiquetaHasta ?? '—',
                      }),
                    if (embotellado.etiquetasDescuadradas)
                      SoleraL10n.t('sidr.aviso_etiquetas_descuadradas'),
                  ].join('\n')),
                ),
            ],
          );
        },
      ),
    );
  }
}
