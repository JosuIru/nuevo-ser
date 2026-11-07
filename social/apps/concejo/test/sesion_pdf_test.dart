import 'dart:convert';
import 'dart:io';

import 'package:concejo/documentos/acta_sesion_pdf.dart';
import 'package:concejo/documentos/convocatoria_pdf.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeDateFormatting);
  final hoy = DateTime(2026, 11, 10, 12);

  for (final idioma in ['es', 'eu']) {
    final textos = lookupAppLocalizations(Locale(idioma));
    test('convocatoria y acta de cada asamblea en $idioma', () async {
      final estado = estadoDeEjemplo(hoy: hoy);
      for (final sesion in estado.sesiones) {
        final convocatoria = await convocatoriaDeLaSesion(
            nombreEspacio: estado.nombreEspacio,
            sesion: sesion,
            buscarAsunto: estado.buscarAsunto,
            textos: textos);
        final acta = await actaDeLaSesion(
            nombreEspacio: estado.nombreEspacio,
            sesion: sesion,
            nombreDe: estado.nombreDe,
            ahora: hoy,
            textos: textos);
        expect(ascii.decode(convocatoria.sublist(0, 5)), '%PDF-');
        expect(ascii.decode(acta.sublist(0, 5)), '%PDF-');

        // Para mirarlas a ojo: CONCEJO_PDF=<carpeta> flutter test …
        final carpeta = Platform.environment['CONCEJO_PDF'];
        if (carpeta != null) {
          File('$carpeta/acta-${sesion.uid}-$idioma.pdf')
              .writeAsBytesSync(acta);
          File('$carpeta/convocatoria-${sesion.uid}-$idioma.pdf')
              .writeAsBytesSync(convocatoria);
        }
      }
    });
  }
}
