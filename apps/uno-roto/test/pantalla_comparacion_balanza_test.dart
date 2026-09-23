import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_roto/dominio/fragmento_en_tejado.dart'
    show ModoComparacion;
import 'package:uno_roto/dominio/problema_espejo.dart' show Fraccion;
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/pantalla_comparacion_balanza.dart';

/// Tests del piloto manipulativo (doc 16, eje A — Fase D3): la balanza
/// de comparación. Verifican el contrato de la pantalla: arrastrar el
/// lado correcto captura (pop true), el incorrecto endereza la balanza
/// y permite reintentar, y un gesto tímido no evalúa.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 3/4 (izquierda) vs 1/4 (derecha), mismo denominador: la mayor es
  // la izquierda — sin ambigüedad y sin depender de generadores.
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
                    builder: (_) => const PantallaComparacionBalanza(
                      a: Fraccion(3, 4),
                      b: Fraccion(1, 4),
                      modo: ModoComparacion.mismoDenominador,
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

  Future<void> abrirBalanza(WidgetTester tester) async {
    await tester.tap(find.text('ABRIR'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    // Cierra el overlay de demo si apareció (primera vez).
    final demo = find.byType(GestureDetector);
    expect(demo, findsWidgets);
    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Arrastra verticalmente hacia abajo sobre el lado indicado del
  /// lienzo de la balanza (el CustomPaint que ocupa el Expanded).
  Future<void> arrastrarLado(
    WidgetTester tester, {
    required bool izquierda,
  }) async {
    final lienzo = find.byType(CustomPaint).last;
    final rect = tester.getRect(lienzo);
    final inicio = Offset(
      izquierda ? rect.left + rect.width * 0.25 : rect.left + rect.width * 0.75,
      rect.top + rect.height * 0.4,
    );
    final gesto = await tester.startGesture(inicio);
    // 160 px hacia abajo en pasos: supera de sobra el umbral (0.35
    // de inclinación con sensibilidad delta/140).
    for (var paso = 0; paso < 8; paso++) {
      await gesto.moveBy(const Offset(0, 20));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesto.up();
    await tester.pump();
  }

  testWidgets('arrastrar el lado correcto captura (pop true)',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    bool? resultado;
    await tester.pumpWidget(envolver(alCerrar: (r) => resultado = r));
    await abrirBalanza(tester);
    await arrastrarLado(tester, izquierda: true); // 3/4 es la mayor
    // Espera del cierre diferido (1200 ms) + animación.
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump(const Duration(milliseconds: 600));
    expect(resultado, isTrue);
    // Vacía los timers pendientes (auto-cierre del demo overlay, etc.).
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('arrastrar el lado incorrecto no cierra y permite reintento',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    bool? resultado;
    await tester.pumpWidget(envolver(alCerrar: (r) => resultado = r));
    await abrirBalanza(tester);
    await arrastrarLado(tester, izquierda: false); // 1/4 NO es la mayor
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 600));
    expect(resultado, isNull,
        reason: 'el fallo no cierra la pantalla — la balanza corrige '
            'y el niño reintenta');
    // Reintento con el lado bueno.
    await arrastrarLado(tester, izquierda: true);
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump(const Duration(milliseconds: 600));
    expect(resultado, isTrue);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('un gesto tímido no evalúa', (tester) async {
    SharedPreferences.setMockInitialValues({});
    bool? resultado;
    await tester.pumpWidget(envolver(alCerrar: (r) => resultado = r));
    await abrirBalanza(tester);
    final lienzo = find.byType(CustomPaint).last;
    final rect = tester.getRect(lienzo);
    final gesto = await tester.startGesture(
      Offset(rect.left + rect.width * 0.25, rect.top + rect.height * 0.4),
    );
    await gesto.moveBy(const Offset(0, 15)); // muy por debajo del umbral
    await tester.pump(const Duration(milliseconds: 16));
    await gesto.up();
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 600));
    expect(resultado, isNull);
    expect(find.byType(PantallaComparacionBalanza), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });
}
