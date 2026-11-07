import 'package:concejo/datos/instantanea.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/estado/estado_concejo.dart';
import 'package:concejo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

EstadoConcejo _pueblo(String personaUid) =>
    instantaneaDesdeJson(instantaneaAJson(estadoDeEjemplo(hoy: _hoy)),
        personaActualUid: personaUid, reloj: () => _hoy);

Future<void> _abrirTablon(WidgetTester tester, EstadoConcejo estado) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  await tester
      .pumpWidget(AppConcejo(estado: estado, idioma: const Locale('es')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Tablón'));
  await tester.pumpAndSettle();
}

Future<void> _pulsarPublicar(WidgetTester tester) async {
  // Si el título sigue con el foco, vuelve a ponerse a la vista.
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  final boton = find.text('Publicar', skipOffstage: false);
  await tester.ensureVisible(boton);
  await tester.pumpAndSettle();
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('se ve el tablón, lo fijado arriba y sin lo caducado',
      (tester) async {
    await _abrirTablon(tester, _pueblo('maite'));
    final agua = find.text('Corte de agua por la obra de la calle Mayor');
    final poda = find.text('Taller de poda de frutales');
    expect(agua, findsOneWidget);
    expect(tester.getTopLeft(agua).dy, lessThan(tester.getTopLeft(poda).dy));
    expect(find.text('Fijado'), findsOneWidget);
    expect(find.text('Feria de artesanía en el valle'), findsNothing);
  });

  testWidgets('una participante publica un anuncio y luego lo retira',
      (tester) async {
    final estado = _pueblo('pili');
    await _abrirTablon(tester, estado);

    await tester.tap(find.text('Publicar anuncio'));
    await tester.pumpAndSettle();
    await _pulsarPublicar(tester);
    expect(find.text('Falta el título.'), findsOneWidget);

    final titulo =
        find.widgetWithText(TextField, 'Título', skipOffstage: false);
    await tester.ensureVisible(titulo);
    await tester.pumpAndSettle();
    await tester.enterText(titulo, 'Busco quien me lleve a Iruña');
    await _pulsarPublicar(tester);
    expect(find.text('Busco quien me lleve a Iruña'), findsOneWidget);
    expect(estado.anuncios.last.autorUid, 'pili');

    // Solo su anuncio tiene menú: los de los demás no los toca.
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retirar el anuncio'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Retirar el anuncio'));
    await tester.pumpAndSettle();
    expect(find.text('Busco quien me lleve a Iruña'), findsNothing);
  });

  testWidgets('la mesa fija un anuncio y ve el botón de publicar',
      (tester) async {
    final estado = _pueblo('ane');
    await _abrirTablon(tester, estado);
    expect(find.text('Publicar anuncio'), findsOneWidget);
    await tester.tap(find.descendant(
        of: find.ancestor(
            of: find.text('Taller de poda de frutales'),
            matching: find.byType(Card)),
        matching: find.byIcon(Icons.more_vert)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fijar arriba'));
    await tester.pumpAndSettle();
    expect(find.text('Fijado'), findsNWidgets(2));
  });
}
