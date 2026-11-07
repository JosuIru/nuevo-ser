import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_cuaderno_tratamientos_pdf.dart';
import '../servicios/generador_pasaporte_pdf.dart';
import '../utiles/textos_vivero.dart';
import 'campos_especie.dart';

/// Documentos en PDF del año en curso y del anterior: cuaderno de
/// tratamientos y registro de pasaportes y trazabilidad. Todos llevan el
/// sello PROVISIONAL. La etiqueta de cada pasaporte sale de la ficha de la
/// salida.
class PantallaDocumentos extends StatelessWidget {
  const PantallaDocumentos({super.key});

  Future<void> _cuaderno(BuildContext context, int anyo) {
    final bd = BaseDatosSoleraVivero.instancia;
    final (desde, hasta) = intervaloAnyo(anyo);
    return compartirDocumentoPdf(
      context,
      nombreFichero: 'cuaderno_tratamientos_$anyo.pdf',
      generar: (tema) async => generarCuadernoTratamientosPdf(
        DatosCuadernoTratamientos(
          anyo: anyo,
          vivero: await bd.obtenerVivero(),
          zonas: await bd.listarZonas(),
          partidas: await bd.listarPartidas(),
          tratamientos:
              await bd.listarTratamientos(desdeMs: desde, hastaMs: hasta),
          inspecciones:
              await bd.listarInspecciones(desdeMs: desde, hastaMs: hasta),
          nombreEspecie: nombreEspecieVisible,
          nombreSustancia: nombreSustanciaVisible,
          nombrePlaga: nombrePlagaVisible,
        ),
        tema: tema,
      ),
    );
  }

  Future<void> _registro(BuildContext context, int anyo) {
    final bd = BaseDatosSoleraVivero.instancia;
    final (desde, hasta) = intervaloAnyo(anyo);
    return compartirDocumentoPdf(
      context,
      nombreFichero: 'registro_pasaportes_$anyo.pdf',
      generar: (tema) async {
        final lotes = (await bd.listarLotesMaterial()).where((lote) =>
            lote.fechaEntradaMs >= desde && lote.fechaEntradaMs <= hasta);
        return generarRegistroPasaportesPdf(
          anyo: anyo,
          vivero: await bd.obtenerVivero(),
          lotesRecibidos: lotes.toList(),
          salidas: await bd.listarSalidas(desdeMs: desde, hastaMs: hasta),
          pasaportes: await bd.listarPasaportes(desdeMs: desde, hastaMs: hasta),
          codigoPartidaPorId: {
            for (final partida in await bd.listarPartidas())
              partida.id!: partida.codigo
          },
          nombreEspecie: nombreEspecieVisible,
          tema: tema,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final anyoActual = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('vive.documentos'))),
      body: ListView(
        children: [
          for (final anyo in [anyoActual, anyoActual - 1])
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(SoleraL10n.t('vive.cuaderno_tratamientos')),
              subtitle: Text('$anyo'),
              onTap: () => _cuaderno(context, anyo),
            ),
          for (final anyo in [anyoActual, anyoActual - 1])
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: Text(SoleraL10n.t('vive.registro_pasaportes')),
              subtitle: Text('$anyo'),
              onTap: () => _registro(context, anyo),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(SoleraL10n.t('vive.aviso_documento_provisional'),
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
