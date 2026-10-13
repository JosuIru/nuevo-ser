import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

import '../logos_entidades.dart';

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

/// Logos de los informes: el de Zunbeltz en la cabecera y una franja de
/// entidades al pie ([ficherosLogosPiePdf]).
class LogosPdf {
  const LogosPdf(this.cabecera, this.pie);

  final pw.ImageProvider? cabecera;
  final List<pw.ImageProvider> pie;
}

LogosPdf? _logosCargados;

Future<LogosPdf> logosPdfZunbeltz() async {
  final cargados = _logosCargados;
  if (cargados != null) return cargados;
  Future<pw.ImageProvider?> imagen(String ruta) async {
    try {
      final datos = await rootBundle.load(ruta);
      return pw.MemoryImage(datos.buffer.asUint8List());
    } catch (_) {
      // Sin el fichero, el informe sale sin ese logo antes que fallar.
      return null;
    }
  }

  final pie = <pw.ImageProvider>[];
  for (final fichero in ficherosLogosPiePdf) {
    final logo = await imagen('assets/logos/$fichero.png');
    if (logo != null) pie.add(logo);
  }
  final logos = LogosPdf(await imagen(rutaLogoZunbeltz), pie);
  _logosCargados = logos;
  return logos;
}
