import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_cuaderno_explotacion_pdf.dart';
import '../servicios/generador_parte_cosecha_pdf.dart';
import '../utiles/textos_frutal.dart';

/// Documentos en PDF: cuaderno de explotación y parte de cosecha, del año
/// en curso y del anterior. Todos llevan el sello PROVISIONAL.
class PantallaDocumentos extends StatelessWidget {
  const PantallaDocumentos({super.key});

  Future<void> _cuaderno(BuildContext context, int anyo) {
    final baseDatos = BaseDatosSoleraFrutal.instancia;
    final (desde, hasta) = intervaloAnyo(anyo);
    return compartirDocumentoPdf(
      context,
      nombreFichero: 'cuaderno_explotacion_$anyo.pdf',
      generar: (tema) async => generarCuadernoExplotacionPdf(
        DatosCuadernoExplotacion(
          anyo: anyo,
          titular: await baseDatos.obtenerTitular(),
          parcelas: await baseDatos.listarParcelas(),
          tratamientos: await baseDatos.listarTratamientos(
              desdeMs: desde, hastaMs: hasta),
          abonados:
              await baseDatos.listarAbonados(desdeMs: desde, hastaMs: hasta),
          riegos: await baseDatos.listarRiegos(desdeMs: desde, hastaMs: hasta),
          cosechas: await baseDatos.listarCosechas(campania: anyo),
        ),
        tema: tema,
      ),
    );
  }

  Future<void> _parteCosecha(BuildContext context, int campania) {
    final baseDatos = BaseDatosSoleraFrutal.instancia;
    final (desde, hasta) = intervaloAnyo(campania);
    return compartirDocumentoPdf(
      context,
      nombreFichero: 'parte_cosecha_$campania.pdf',
      generar: (tema) async => generarParteCosechaPdf(
        campania: campania,
        titular: await baseDatos.obtenerTitular(),
        parcelas: await baseDatos.listarParcelas(),
        cosechas: await baseDatos.listarCosechas(campania: campania),
        heladas: await baseDatos.listarHeladas(desdeMs: desde, hastaMs: hasta),
        tema: tema,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anyoActual = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('frut.documentos'))),
      body: ListView(
        children: [
          for (final anyo in [anyoActual, anyoActual - 1])
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(SoleraL10n.t('frut.cuaderno_explotacion')),
              subtitle: Text('$anyo'),
              onTap: () => _cuaderno(context, anyo),
            ),
          for (final campania in [anyoActual, anyoActual - 1])
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(SoleraL10n.t('frut.parte_cosecha')),
              subtitle: Text('$campania'),
              onTap: () => _parteCosecha(context, campania),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(SoleraL10n.t('frut.aviso_documento_provisional'),
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
