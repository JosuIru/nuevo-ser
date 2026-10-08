import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

pw.ThemeData? _temaCargado;

/// Fuentes de los PDF de la app: Archivo, la misma de los títulos,
/// incrustada desde `assets/fuentes`. Sin ella el generador usa Helvetica,
/// que no tiene «€» ni «—» y los deja en blanco en todos los importes.
Future<pw.ThemeData> temaPdfZunbeltz() async {
  final cargado = _temaCargado;
  if (cargado != null) return cargado;
  Future<pw.Font> fuente(String nombre) async =>
      pw.Font.ttf(await rootBundle.load('assets/fuentes/$nombre.ttf'));
  final tema = pw.ThemeData.withFont(
    base: await fuente('Archivo-Regular'),
    bold: await fuente('Archivo-Bold'),
    italic: await fuente('Spectral-Italic'),
  );
  _temaCargado = tema;
  return tema;
}
