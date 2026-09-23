import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_roto/dominio/problema_comparacion_distinta.dart';
import 'package:uno_roto/dominio/problema_espejo.dart' show Fraccion;
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/pantalla_comparacion_tarta.dart';

/// "Cortar la tarta" (FR.07 manipulativo): servir cada fracción con un
/// gesto circular y tocar la tarta mayor. 2/3 (izquierda) > 3/5.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget envolver({required void Function(bool?) alCerrar}) {
    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('eu'), Locale('ca')],
      home: Builder(
        builder: (contexto) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async {
                final resultado = await Navigator.of(contexto).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => const PantallaComparacionTarta(
                      problema: ProblemaComparacionDistinta(
                        a: Fraccion(2, 3),
                        b: Fraccion(3, 5),
                      ),
                    ),
                  ),
                );
                alCerrar(resultado);
              },
              child: const Text('ABRIR'),
            ),
          ),
        ),
      ),
    );
  }

  Finder tarta(int indice) => find
      .byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is PintorTarta)
      .at(indice);

  /// Pasa el dedo alrededor de la tarta desde las 12, en sentido
  /// horario, hasta [fraccionDeVuelta].
  Future<void> servir(
      WidgetTester tester, int indice, double fraccionDeVuelta) async {
    final caja = tester.getRect(tarta(indice));
    final radio = caja.shortestSide * 0.3;
    Offset punto(double vuelta) {
      final angulo = -math.pi / 2 + 2 * math.pi * vuelta;
      return caja.center + Offset(math.cos(angulo), math.sin(angulo)) * radio;
    }

    final gesto = await tester.startGesture(punto(0.01));
    const pasos = 24;
    for (var paso = 1; paso <= pasos; paso++) {
      await gesto.moveTo(punto(0.01 + (fraccionDeVuelta - 0.01) * paso / pasos));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesto.up();
    await tester.pump();
  }

  Future<void> abrir(WidgetTester tester, void Function(bool?) alCerrar) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(envolver(alCerrar: alCerrar));
    await tester.tap(find.text('ABRIR'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    // Cierra la demo de la primera vez.
    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('servir las dos y tocar la mayor captura', (tester) async {
    bool? resultado;
    await abrir(tester, (r) => resultado = r);

    await servir(tester, 0, 2 / 3);
    await servir(tester, 1, 3 / 5);
    expect(find.text('2/3'), findsNWidgets(2)); // etiqueta + contador
    expect(find.text('Ahora toca la tarta que tiene más.'), findsOneWidget);

    await tester.tap(tarta(0));
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump(const Duration(milliseconds: 600));
    expect(resultado, isTrue);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('tocar antes de servir no evalúa', (tester) async {
    bool? resultado = false;
    await abrir(tester, (r) => resultado = r);
    await tester.tap(tarta(0));
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(PantallaComparacionTarta), findsOneWidget);
    expect(resultado, isFalse);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('elegir la menor no cierra y deja reintentar', (tester) async {
    bool? resultado;
    await abrir(tester, (r) => resultado = r);
    await servir(tester, 0, 2 / 3);
    await servir(tester, 1, 3 / 5);
    await tester.tap(tarta(1));
    await tester.pump(const Duration(milliseconds: 1700));
    expect(find.byType(PantallaComparacionTarta), findsOneWidget);
    expect(resultado, isNull);

    await tester.tap(tarta(0));
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump(const Duration(milliseconds: 600));
    expect(resultado, isTrue);
    await tester.pump(const Duration(seconds: 5));
  });
}
