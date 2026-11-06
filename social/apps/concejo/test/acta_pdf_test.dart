import 'dart:convert';
import 'dart:io';

import 'package:concejo/documentos/acta_pdf.dart';
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
    test('acta de cada asunto en $idioma', () async {
      final estado = estadoDeEjemplo(hoy: hoy);
      for (final asunto in estado.asuntos) {
        final bytes = await actaDelAsunto(
            estado: estado, asuntoUid: asunto.uid, textos: textos);
        expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
      }
    });
  }

  test('el acta firmada sale sin la marca de borrador', () async {
    final textos = lookupAppLocalizations(const Locale('es'));
    final estado = estadoDeEjemplo(hoy: hoy);
    final borrador =
        await actaDelAsunto(estado: estado, asuntoUid: 'txoko', textos: textos);
    estado
      ..firmarActa('txoko')
      ..verComo('mikel')
      ..firmarActa('txoko');
    final firmada =
        await actaDelAsunto(estado: estado, asuntoUid: 'txoko', textos: textos);
    expect(firmada, isNot(equals(borrador)));

    // Para mirarlas a ojo: CONCEJO_PDF=<carpeta> flutter test …
    final carpeta = Platform.environment['CONCEJO_PDF'];
    if (carpeta != null) {
      File('$carpeta/acta-borrador.pdf').writeAsBytesSync(borrador);
      File('$carpeta/acta-firmada.pdf').writeAsBytesSync(firmada);
    }
  });
}
