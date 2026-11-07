import 'package:concejo/datos/instantanea.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/estado/estado_concejo.dart';
import 'package:concejo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

EstadoConcejo _pueblo(String personaUid, {DateTime? ahora}) =>
    instantaneaDesdeJson(instantaneaAJson(estadoDeEjemplo(hoy: _hoy)),
        personaActualUid: personaUid, reloj: () => ahora ?? _hoy);

Future<void> _abrirTareas(WidgetTester tester, EstadoConcejo estado) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  await tester
      .pumpWidget(AppConcejo(estado: estado, idioma: const Locale('es')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Tareas'));
  await tester.pumpAndSettle();
}

Future<void> _pulsar(WidgetTester tester, String texto) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  final boton = find.text(texto, skipOffstage: false);
  await tester.ensureVisible(boton);
  await tester.pumpAndSettle();
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('una participante ve cuántas manos faltan y se apunta',
      (tester) async {
    final estado = _pueblo('maite');
    await _abrirTareas(tester, estado);
    expect(find.text('Van 3 de 8: faltan 5'), findsOneWidget);
    expect(find.text('Van 1 de 1: completa'), findsOneWidget);
    expect(find.text('Nueva tarea'), findsNothing, reason: 'la crea la mesa');

    await tester.tap(find.text('Auzolan: limpiar el camino del monte'));
    await tester.pumpAndSettle();
    await _pulsar(tester, 'Me apunto');
    expect(estado.tarea('camino').apuntadosUids, contains('maite'));
    expect(find.text('Me borro', skipOffstage: false), findsOneWidget);
  });

  testWidgets('en una completa no hay botón para apuntarse', (tester) async {
    await _abrirTareas(tester, _pueblo('maite'));
    await tester.tap(find.text('Abrir el local vecinal'));
    await tester.pumpAndSettle();
    expect(find.text('Me apunto', skipOffstage: false), findsNothing);
  });

  testWidgets('la mesa crea un turno de cuatro semanas', (tester) async {
    final estado = _pueblo('ane');
    final antes = estado.tareas.length;
    await _abrirTareas(tester, estado);
    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Título'), 'Abrir el local el sábado');
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();
    await tester.tap(find.text('Repetir cada semana (turnos)'));
    await tester.pumpAndSettle();
    await _pulsar(tester, 'Crear');

    final turnos = estado.tareas
        .where((t) => t.titulo == 'Abrir el local el sábado')
        .toList();
    expect(estado.tareas.length, antes + 4);
    expect(turnos.map((t) => t.plazas).toSet(), {1});
    expect(turnos[1].inicio.difference(turnos[0].inicio).inDays, 7);
  });

  testWidgets('desde el día, la mesa la da por hecha con una nota',
      (tester) async {
    final estado = _pueblo('ane', ahora: DateTime(2026, 11, 14, 21));
    await _abrirTareas(tester, estado);
    await tester.tap(find.text('Abrir el local vecinal'));
    await tester.pumpAndSettle();
    await _pulsar(tester, 'Dar por hecha');
    await tester.enterText(find.byType(TextField), 'Vinieron diez');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Dar por hecha').last);
    await tester.pumpAndSettle();
    expect(estado.tarea('local').estaHecha, isTrue);
    expect(find.text('Vinieron diez'), findsOneWidget);
  });
}
