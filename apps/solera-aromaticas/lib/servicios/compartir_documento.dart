import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, temaPdfSolera;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Genera un PDF con el tema de la suite y abre la hoja de compartir.
/// Los errores se muestran en un SnackBar, nunca rompen la pantalla.
Future<void> compartirDocumentoPdf(
  BuildContext context, {
  required String nombreFichero,
  required Future<Uint8List> Function(pw.ThemeData tema) generar,
}) async {
  final mensajero = ScaffoldMessenger.of(context);
  try {
    final bytes = await generar(await temaPdfSolera());
    await Printing.sharePdf(bytes: bytes, filename: nombreFichero);
  } catch (error) {
    debugPrint('No se pudo generar $nombreFichero: $error');
    mensajero.showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('arom.error_documento'))));
  }
}
