import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solera_huerta/datos/base_datos.dart';
import 'package:solera_huerta/estado/perfil_huerta.dart';
import 'package:solera_huerta/main.dart';
import 'package:solera_huerta/pantallas/selector_perfil.dart';

import '../datos/soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();

  setUpAll(initializeDateFormatting);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    perfilHuerta.value = PerfilHuerta.profesional;
    await entorno.preparar();
  });
  tearDown(() async {
    await BaseDatosSoleraHuerta.instancia.cerrar();
    await entorno.limpiar();
  });

  test('sin preferencia, el perfil es profesional; se guarda al cambiarlo',
      () async {
    await cargarPerfilHuerta();
    expect(perfilHuerta.value, PerfilHuerta.profesional);

    await cambiarPerfilHuerta(PerfilHuerta.casa);
    perfilHuerta.value = PerfilHuerta.profesional;
    await cargarPerfilHuerta();
    expect(perfilHuerta.value, PerfilHuerta.casa);
    expect(esHuertoDeCasa, isTrue);
  });

  testWidgets('el selector cambia el perfil', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SelectorPerfilHuerta())));
    await tester.tap(find.text(SoleraL10n.t('huer.perfil_casa')));
    await tester.pumpAndSettle();
    expect(perfilHuerta.value, PerfilHuerta.casa);
    expect(find.text(SoleraL10n.t('huer.perfil_casa_ayuda')), findsOneWidget);
  });

  testWidgets('el huerto de casa no tiene pestaña de cestas', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaPrincipal()));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    final pestanaCestas = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(SoleraL10n.t('huer.cestas')));
    expect(pestanaCestas, findsOneWidget);

    // Desde Ajustes (la última), se sigue en Ajustes al cambiar.
    await tester.tap(find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(SoleraL10n.t('ajustes'))));
    await tester.pump();
    await tester.runAsync(() => cambiarPerfilHuerta(PerfilHuerta.casa));
    await tester.pump();
    expect(pestanaCestas, findsNothing);
    final barra = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(barra.destinations, hasLength(4));
    expect(barra.selectedIndex, 3);
  });
}
