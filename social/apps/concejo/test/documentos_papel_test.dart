import 'dart:convert';
import 'dart:io';

import 'package:concejo/documentos/documentos_papel.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // En la app lo hacen las localizaciones de Material; aquí, a mano.
  setUpAll(initializeDateFormatting);
  final estado = estadoDeEjemplo(hoy: DateTime(2026, 11, 10, 12));

  // Un asunto de cada forma de decidir: fiestas (votación), comunal
  // (consentimiento), presupuesto y txoko (elección entre opciones).
  for (final idioma in ['es', 'eu']) {
    final textos = lookupAppLocalizations(Locale(idioma));
    for (final asunto in estado.asuntos) {
      test('${asunto.uid} en $idioma: hoja, papeletas y recuento', () async {
        for (final generar in [hojaDelAsunto, papeletas, hojaDeRecuento]) {
          final bytes = await Function.apply(generar, const [], {
            #nombreEspacio: estado.nombreEspacio,
            #asunto: asunto,
            #textos: textos,
          }) as List<int>;
          expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
          expect(bytes.length, greaterThan(2000));
        }
      });
    }
  }

  test('varias hojas de papeletas', () async {
    final textos = lookupAppLocalizations(const Locale('es'));
    final una = await papeletas(
        nombreEspacio: 'x', asunto: estado.asunto('fiestas'), textos: textos);
    final tres = await papeletas(
        nombreEspacio: 'x',
        asunto: estado.asunto('fiestas'),
        textos: textos,
        paginas: 3);
    expect(tres.length, greaterThan(una.length));
  });

  test('hoja con el código personal', () async {
    final bytes = await hojaDeCodigo(
      nombreEspacio: 'Concejo de Ejemplo',
      nombrePersona: 'Maritxu',
      direccion: 'concejo.ejemplo.eus',
      codigo: 'K7PM-3QXD-9TRA',
      textos: lookupAppLocalizations(const Locale('es')),
    );
    expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
    // Para mirarla a ojo: CONCEJO_PDF=<carpeta> flutter test …
    final carpeta = Platform.environment['CONCEJO_PDF'];
    if (carpeta != null) {
      File('$carpeta/hoja-codigo.pdf').writeAsBytesSync(bytes);
    }
  });
}
