import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:las_versiones/datos/repositorio_preguntas_brecha.dart';
import 'package:las_versiones/dominio/brecha.dart';
import 'package:las_versiones/dominio/catalogo_brechas.dart';
import 'package:las_versiones/nucleo/paleta_archivo.dart';
import 'package:las_versiones/vista/fase_formulacion_preguntas.dart';

GestorPerfiles _gestorDePrueba() => GestorPerfiles(
      namespace: 'nuevoser.lasversiones',
      sufijoNombreVisible: 'nombre_jugador',
      clavesGlobalesNoMigrables: const {
        'nuevoser.lasversiones.idioma_app',
        'nuevoser.lasversiones.token_backend',
        'nuevoser.lasversiones.email_backend',
      },
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> bombearFase(
    WidgetTester tester, {
    required Brecha brecha,
    required VoidCallback alAvanzar,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: FaseFormulacionPreguntas(
              brecha: brecha,
              alAvanzarFase: alAvanzar,
              repoPreguntas: RepositorioPreguntasBrecha(
                gestor: _gestorDePrueba(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('escribir 3 preguntas válidas con 2 categorías habilita avance',
      (tester) async {
    var avancesInvocados = 0;
    await bombearFase(
      tester,
      brecha: CatalogoBrechas.brecha11,
      alAvanzar: () => avancesInvocados++,
    );

    // Estado inicial: bloqueado.
    final ctaFinder = find.text('IR A LA RECOLECCIÓN');
    expect(ctaFinder, findsOneWidget);
    var ctaWidget = tester.widget<TextButton>(
      find.ancestor(of: ctaFinder, matching: find.byType(TextButton)),
    );
    expect(ctaWidget.onPressed, isNull,
        reason: 'sin preguntas, el avance está bloqueado');

    Future<void> escribir(String pregunta) async {
      await tester.enterText(find.byType(TextField), pregunta);
      await tester.tap(find.byTooltip('Añadir'));
      await tester.pumpAndSettle();
    }

    await escribir('¿Qué pasó realmente en este lugar?');
    await escribir('¿Por qué se eligió este sitio y no otro?');
    await escribir('¿Cuándo se construyó esto?');

    ctaWidget = tester.widget<TextButton>(
      find.ancestor(of: ctaFinder, matching: find.byType(TextButton)),
    );
    expect(ctaWidget.onPressed, isNotNull,
        reason: '3 válidas + 2 categorías → habilita avance');

    await tester.tap(ctaFinder);
    await tester.pumpAndSettle();
    expect(avancesInvocados, 1);
  });

  testWidgets(
      'tres preguntas todas factuales no desbloquean — exige diversidad',
      (tester) async {
    await bombearFase(
      tester,
      brecha: CatalogoBrechas.brecha11,
      alAvanzar: () {},
    );

    Future<void> escribir(String pregunta) async {
      await tester.enterText(find.byType(TextField), pregunta);
      await tester.tap(find.byTooltip('Añadir'));
      await tester.pumpAndSettle();
    }

    await escribir('¿Qué pasó en este lugar hace tiempo?');
    await escribir('¿Cuándo se construyó este conjunto?');
    await escribir('¿Quién lo levantó realmente?');

    expect(find.textContaining('mismo tipo'), findsOneWidget);
    final cta = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('IR A LA RECOLECCIÓN'),
        matching: find.byType(TextButton),
      ),
    );
    expect(cta.onPressed, isNull);
  });

  testWidgets('preguntas persisten entre reaperturas', (tester) async {
    const brecha = CatalogoBrechas.brecha11;
    await bombearFase(tester, brecha: brecha, alAvanzar: () {});

    await tester.enterText(
      find.byType(TextField),
      '¿Por qué este lugar y no otro cercano?',
    );
    await tester.tap(find.byTooltip('Añadir'));
    await tester.pumpAndSettle();

    // Segunda pumpWidget (simula recargar la pantalla).
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await bombearFase(tester, brecha: brecha, alAvanzar: () {});

    expect(
      find.textContaining('este lugar y no otro'),
      findsOneWidget,
      reason: 'la pregunta persistida debe reaparecer al recargar',
    );
  });

  testWidgets('eliminar una pregunta la quita y devuelve al estado bloqueado',
      (tester) async {
    await bombearFase(
      tester,
      brecha: CatalogoBrechas.brecha11,
      alAvanzar: () {},
    );

    Future<void> escribir(String pregunta) async {
      await tester.enterText(find.byType(TextField), pregunta);
      await tester.tap(find.byTooltip('Añadir'));
      await tester.pumpAndSettle();
    }

    await escribir('¿Qué pasó en este lugar?');
    await escribir('¿Por qué se construyó aquí?');
    await escribir('¿Cuándo se hizo realmente?');

    // Habilitado.
    var cta = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('IR A LA RECOLECCIÓN'),
        matching: find.byType(TextButton),
      ),
    );
    expect(cta.onPressed, isNotNull);

    // Elimino la primera.
    await tester.tap(find.byTooltip('Eliminar').first);
    await tester.pumpAndSettle();

    cta = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('IR A LA RECOLECCIÓN'),
        matching: find.byType(TextButton),
      ),
    );
    expect(cta.onPressed, isNull,
        reason: 'al bajar a 2 preguntas el avance vuelve a bloquearse');
  });

  testWidgets('texto vacío no añade pregunta ni reinicia el campo',
      (tester) async {
    await bombearFase(
      tester,
      brecha: CatalogoBrechas.brecha11,
      alAvanzar: () {},
    );

    await tester.tap(find.byTooltip('Añadir'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Aún no has formulado'), findsOneWidget);
  });

  testWidgets('una afirmación entra como inválida con feedback pedagógico',
      (tester) async {
    await bombearFase(
      tester,
      brecha: CatalogoBrechas.brecha11,
      alAvanzar: () {},
    );

    await tester.enterText(
      find.byType(TextField),
      'Aquí pasaron muchas cosas hace tiempo, según parece.',
    );
    await tester.tap(find.byTooltip('Añadir'));
    await tester.pumpAndSettle();

    expect(find.text('NO ADMITIDA'), findsOneWidget);
    expect(find.textContaining('afirmación'), findsOneWidget);
  });

  testWidgets('los arranques rellenan la caja y bastan para dos tipos distintos',
      (tester) async {
    await bombearFase(tester, brecha: CatalogoBrechas.brecha11, alAvanzar: () {});

    Future<void> preguntar(String arranque, String resto) async {
      await tester.tap(find.text('${arranque.trim()}…'));
      await tester.pump();
      expect(find.text(arranque), findsOneWidget, reason: 'el arranque va a la caja');
      await tester.enterText(find.byType(TextField), '$arranque$resto');
      await tester.tap(find.byTooltip('Añadir'));
      await tester.pumpAndSettle();
    }

    await preguntar('¿Quién ', 'enterró a estas personas?');
    await preguntar('¿Cuándo ', 'se construyó el dolmen?');
    await preguntar('¿Cómo sabemos ', 'la fecha del enterramiento?');

    final cta = tester.widget<TextButton>(find.ancestor(
      of: find.text('IR A LA RECOLECCIÓN'),
      matching: find.byType(TextButton),
    ));
    expect(cta.onPressed, isNotNull);
  });

  testWidgets('el botón de avanzar desactivado se lee (no queda negro)',
      (tester) async {
    await bombearFase(tester, brecha: CatalogoBrechas.brecha11, alAvanzar: () {});
    final cta = tester.widget<TextButton>(find.ancestor(
      of: find.text('IR A LA RECOLECCIÓN'),
      matching: find.byType(TextButton),
    ));
    expect(cta.onPressed, isNull);
    final colorDesactivado =
        cta.style!.foregroundColor!.resolve({WidgetState.disabled});
    expect(colorDesactivado, PaletaArchivo.textoTenue);
  });
}
