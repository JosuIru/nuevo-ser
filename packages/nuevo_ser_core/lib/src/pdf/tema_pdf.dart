import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

pw.ThemeData? _temaCargado;

/// Tema de los PDF con la letra Archivo incrustada desde el core. Sin él
/// el paquete pdf usa Helvetica, que no tiene «€» ni «—» y los deja en
/// blanco: los importes de facturas y extractos salen sin el símbolo.
///
/// Uso: `pw.Document(theme: await temaPdfSolera())` o el parámetro
/// `tema:` de [generarInformePeriodicoPdf].
Future<pw.ThemeData> temaPdfSolera() async {
  final cargado = _temaCargado;
  if (cargado != null) return cargado;
  Future<pw.Font> fuente(String nombre) async => pw.Font.ttf(await rootBundle
      .load('packages/nuevo_ser_core/assets/fuentes/$nombre.ttf'));
  final normal = await fuente('Archivo-Regular');
  final negrita = await fuente('Archivo-Bold');
  final tema = pw.ThemeData.withFont(
    base: normal,
    bold: negrita,
    italic: normal,
    boldItalic: negrita,
  );
  _temaCargado = tema;
  return tema;
}
