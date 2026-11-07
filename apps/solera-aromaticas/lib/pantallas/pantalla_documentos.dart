import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/trazabilidad.dart';
import '../modelos/lote_producto.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_cuaderno_recoleccion_pdf.dart';
import '../servicios/generador_libro_destilacion_pdf.dart';
import '../servicios/generador_pasaporte_lote_pdf.dart';
import '../utiles/textos_aromaticas.dart';

BaseDatosSoleraAromaticas get _bd => BaseDatosSoleraAromaticas.instancia;

Future<DatosCuadernoRecoleccion> cargarDatosCuadernoRecoleccion(
    int anyo) async {
  final (desde, hasta) = intervaloAnyo(anyo);
  return DatosCuadernoRecoleccion(
    anyo: anyo,
    titular: await _bd.obtenerTitular(),
    parcelas: await _bd.listarParcelas(),
    zonas: await _bd.listarZonasRecoleccion(),
    cosechas: await _bd.listarCosechas(desdeMs: desde, hastaMs: hasta),
    tratamientos: await _bd.listarTratamientos(desdeMs: desde, hastaMs: hasta),
  );
}

Future<DatosLibroDestilacion> cargarDatosLibroDestilacion(int anyo) async {
  final (desde, hasta) = intervaloAnyo(anyo);
  return DatosLibroDestilacion(
    anyo: anyo,
    titular: await _bd.obtenerTitular(),
    destilaciones:
        await _bd.listarDestilaciones(desdeMs: desde, hastaMs: hasta),
    secados: await _bd.listarSecados(desdeMs: desde, hastaMs: hasta),
    lotes: await _bd.listarLotesProducto(desdeMs: desde, hastaMs: hasta),
    cosechas: await _bd.listarCosechas(),
    parcelas: await _bd.listarParcelas(),
    zonas: await _bd.listarZonasRecoleccion(),
  );
}

/// Pasaporte de un lote (desde su ficha).
Future<void> compartirPasaporteLote(
    BuildContext context, LoteProducto lote, OrigenLote origen) {
  return compartirDocumentoPdf(
    context,
    nombreFichero: 'pasaporte_${lote.codigo}.pdf',
    generar: (tema) async => generarPasaporteLotePdf(
      lote: lote,
      titular: await _bd.obtenerTitular(),
      origen: origen,
      tema: tema,
    ),
  );
}

/// Documentos en PDF del año en curso y del anterior: cuaderno de cosechas
/// y recolección, y libro de destilación y lotes. Todos PROVISIONALES.
class PantallaDocumentos extends StatelessWidget {
  const PantallaDocumentos({super.key});

  @override
  Widget build(BuildContext context) {
    final anyoActual = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('arom.documentos'))),
      body: ListView(
        children: [
          for (final anyo in [anyoActual, anyoActual - 1])
            ListTile(
              leading: const Icon(Icons.forest_outlined),
              title: Text(SoleraL10n.t('arom.cuaderno_recoleccion')),
              subtitle: Text('$anyo'),
              onTap: () => compartirDocumentoPdf(
                context,
                nombreFichero: 'cuaderno_recoleccion_$anyo.pdf',
                generar: (tema) async => generarCuadernoRecoleccionPdf(
                    await cargarDatosCuadernoRecoleccion(anyo),
                    tema: tema),
              ),
            ),
          for (final anyo in [anyoActual, anyoActual - 1])
            ListTile(
              leading: const Icon(Icons.water_drop_outlined),
              title: Text(SoleraL10n.t('arom.libro_destilacion')),
              subtitle: Text('$anyo'),
              onTap: () => compartirDocumentoPdf(
                context,
                nombreFichero: 'libro_destilacion_$anyo.pdf',
                generar: (tema) async => generarLibroDestilacionPdf(
                    await cargarDatosLibroDestilacion(anyo),
                    tema: tema),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(SoleraL10n.t('arom.aviso_documento_provisional'),
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
