import 'dart:convert';
import 'dart:io';

import 'package:concejo/datos/instantanea.dart';
import 'package:concejo/documentos/guia_pdf.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/l10n/app_localizations.dart';
import 'package:concejo/main.dart';
import 'package:concejo/pantallas/pantalla_guia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

Future<void> _abrirGuia(WidgetTester tester, String personaUid) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  final estado = instantaneaDesdeJson(
      instantaneaAJson(estadoDeEjemplo(hoy: _hoy)),
      personaActualUid: personaUid,
      reloj: () => _hoy);
  await tester
      .pumpWidget(AppConcejo(estado: estado, idioma: const Locale('es')));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Guía'));
  await tester.pumpAndSettle();
}

void main() {
  test('cada apartado tiene los mismos pasos en castellano y en euskera', () {
    final es = lookupAppLocalizations(const Locale('es'));
    final eu = lookupAppLocalizations(const Locale('eu'));
    List<int> pasos(AppLocalizations textos) => [
          for (final apartado in [
            ...guiaParaTodos(textos),
            ...guiaParaLaMesa(textos),
          ])
            apartado.pasos.length,
        ];
    expect(pasos(eu), pasos(es));
    expect(pasos(es).every((cantidad) => cantidad >= 2), isTrue);
  });

  testWidgets('a una participante le sale primero su parte', (tester) async {
    await _abrirGuia(tester, 'maite');
    expect(tester.getTopLeft(find.text('Para todo el mundo')).dy,
        lessThan(tester.getTopLeft(find.text('Para la mesa')).dy));
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('una dirección y un código personal'),
        findsOneWidget);
  });

  testWidgets('a la mesa, primero la suya', (tester) async {
    await _abrirGuia(tester, 'ane');
    expect(tester.getTopLeft(find.text('Para la mesa')).dy,
        lessThan(tester.getTopLeft(find.text('Para todo el mundo')).dy));
  });

  test('la guía en PDF, en los dos idiomas', () async {
    for (final idioma in ['es', 'eu']) {
      final bytes = await guiaEnPdf(
          nombreEspacio: 'Concejo de Ejemplo',
          textos: lookupAppLocalizations(Locale(idioma)));
      expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
      final carpeta = Platform.environment['CONCEJO_PDF'];
      if (carpeta != null) {
        File('$carpeta/guia-$idioma.pdf').writeAsBytesSync(bytes);
      }
    }
  });
}
