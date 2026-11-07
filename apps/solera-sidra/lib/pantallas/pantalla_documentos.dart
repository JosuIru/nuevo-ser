import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/campania.dart';
import '../dominio/saldo_kupelas.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_cuaderno_pomarada_pdf.dart';
import '../servicios/generador_libro_elaboracion_pdf.dart';

/// Documentos en PDF por campaña: cuaderno de la pomarada y libro de
/// elaboración y embotellado.
class PantallaDocumentos extends StatelessWidget {
  const PantallaDocumentos({super.key});

  Future<void> _cuaderno(BuildContext context, int campania) {
    final baseDatos = BaseDatosSoleraSidra.instancia;
    final rango = rangoCampania(campania);
    return compartirDocumentoPdf(
      context,
      nombreFichero: 'cuaderno_pomarada_${nombreCampania(campania)}.pdf',
      generar: (tema) async => generarCuadernoPomaradaPdf(
        campania: campania,
        titular: await baseDatos.obtenerTitular(),
        pomaradas: await baseDatos.listarPomaradas(),
        tratamientos: await baseDatos.listarTratamientos(
            desdeMs: rango.desdeMs, hastaMs: rango.hastaMs),
        partidasPropias: (await baseDatos.listarPartidas(
                desdeMs: rango.desdeMs, hastaMs: rango.hastaMs))
            .where((partida) => partida.propia)
            .toList(),
        tema: tema,
      ),
    );
  }

  Future<void> _libro(BuildContext context, int campania) {
    final baseDatos = BaseDatosSoleraSidra.instancia;
    final rango = rangoCampania(campania);
    return compartirDocumentoPdf(
      context,
      nombreFichero: 'libro_elaboracion_${nombreCampania(campania)}.pdf',
      generar: (tema) async {
        final enCampania = (desdeMs: rango.desdeMs, hastaMs: rango.hastaMs);
        final prensados = await baseDatos.listarPrensados();
        final trasiegos = await baseDatos.listarTrasiegos();
        final sesiones = await baseDatos.listarSesionesTxotx();
        final embotellados = await baseDatos.listarEmbotellados();
        bool dentro(int fechaMs) =>
            fechaMs >= enCampania.desdeMs && fechaMs <= enCampania.hastaMs;
        return generarLibroElaboracionPdf(
          titular: await baseDatos.obtenerTitular(),
          datos: DatosLibroElaboracion(
            campania: campania,
            pomaradas: await baseDatos.listarPomaradas(),
            partidas: await baseDatos.listarPartidas(
                desdeMs: rango.desdeMs, hastaMs: rango.hastaMs),
            prensados: prensados.where((p) => dentro(p.fechaMs)).toList(),
            partidasPorPrensado: await baseDatos.partidasPorPrensado(),
            kupelas: await baseDatos.listarKupelas(),
            trasiegos: trasiegos.where((t) => dentro(t.fechaMs)).toList(),
            sesionesTxotx: sesiones.where((s) => dentro(s.fechaMs)).toList(),
            embotellados: embotellados.where((e) => dentro(e.fechaMs)).toList(),
            saldoAlCierre: SaldoKupelas.calcular(
              prensados: prensados,
              trasiegos: trasiegos,
              sesionesTxotx: sesiones,
              embotellados: embotellados,
              hastaMs: rango.hastaMs,
            ),
          ),
          tema: tema,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final actual = campaniaDe(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('sidr.documentos'))),
      body: ListView(
        children: [
          for (final campania in [actual, actual - 1]) ...[
            ListTile(
              title: Text(
                  SoleraL10n.tf(
                      'sidr.temporada', {'campania': nombreCampania(campania)}),
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(SoleraL10n.t('sidr.cuaderno_pomarada')),
              subtitle:
                  Text(SoleraL10n.t('sidr.cuaderno_pomarada_explicacion')),
              onTap: () => _cuaderno(context, campania),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(SoleraL10n.t('sidr.libro_elaboracion')),
              subtitle:
                  Text(SoleraL10n.t('sidr.libro_elaboracion_explicacion')),
              onTap: () => _libro(context, campania),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(SoleraL10n.t('sidr.aviso_documento_provisional'),
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
