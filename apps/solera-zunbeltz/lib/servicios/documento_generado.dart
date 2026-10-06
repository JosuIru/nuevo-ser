import 'dart:convert';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Un informe o exportación ya generado, en memoria. No se escribe a disco:
/// así sirve igual en móvil, escritorio y web (donde no hay sistema de
/// ficheros y compartir equivale a descargar).
class DocumentoGenerado {
  final String nombreFichero;
  final Uint8List bytes;
  final String tipoMime;

  const DocumentoGenerado({
    required this.nombreFichero,
    required this.bytes,
    required this.tipoMime,
  });

  factory DocumentoGenerado.pdf(String prefijoNombre, Uint8List bytes) =>
      DocumentoGenerado(
        nombreFichero: '${nombreSeguroFichero(prefijoNombre)}-'
            '${DateTime.now().millisecondsSinceEpoch}.pdf',
        bytes: bytes,
        tipoMime: 'application/pdf',
      );

  /// CSV en UTF-8 con BOM, para que Excel reconozca los acentos.
  factory DocumentoGenerado.csv(String nombreFichero, String contenido) =>
      DocumentoGenerado(
        nombreFichero: nombreFichero,
        bytes: Uint8List.fromList(utf8.encode('﻿$contenido')),
        tipoMime: 'text/csv',
      );

  XFile aXFile() =>
      XFile.fromData(bytes, name: nombreFichero, mimeType: tipoMime);
}

/// Sustituye lo que no sea letra ASCII, número, guion o subrayado por `_`
/// (algunos visores de Android se atragantan con espacios y acentos).
String nombreSeguroFichero(String nombre) =>
    nombre.replaceAll(RegExp(r'[^A-Za-z0-9_\-]+'), '_');

/// Abre la hoja de compartir del sistema con los documentos. En el
/// navegador, si no hay hoja de compartir, `share_plus` los descarga.
Future<void> compartirDocumentos(
  List<DocumentoGenerado> documentos, {
  String? asunto,
  String? texto,
}) async {
  await Share.shareXFiles(
    documentos.map((documento) => documento.aXFile()).toList(),
    fileNameOverrides:
        documentos.map((documento) => documento.nombreFichero).toList(),
    subject: asunto,
    text: texto,
  );
}
