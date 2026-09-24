import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:las_versiones/datos/registro_maestria_archivo.dart';
import 'package:las_versiones/datos/repositorio_reconstruccion.dart';
import 'package:las_versiones/dominio/brecha.dart';
import 'package:las_versiones/dominio/catalogo_brechas.dart';
import 'package:las_versiones/vista/fase_reconstruccion.dart';

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
    RegistroMaestriaArchivo? registro,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: FaseReconstruccion(
              brecha: brecha,
              alAvanzarFase: alAvanzar,
              repoReconstruccion: RepositorioReconstruccion(
                gestor: _gestorDePrueba(),
              ),
              registro: registro,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
      'arranque sin declaraciones → CTA bloqueado y mensaje "faltan 3"',
      (tester) async {
    await bombearFase(
      tester,
      brecha: CatalogoBrechas.brecha11,
      alAvanzar: () {},
    );

    final cta = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('AL CONCILIO'),
        matching: find.byType(TextButton),
      ),
    );
    expect(cta.onPressed, isNull);
    expect(find.textContaining('faltan 3'), findsOneWidget);
  });

  testWidgets(
      'declarar tres afirmaciones desbloquea el CTA y guarda en repo',
      (tester) async {
    var avancesInvocados = 0;
    await bombearFase(
      tester,
      brecha: CatalogoBrechas.brecha11,
      alAvanzar: () => avancesInvocados++,
    );

    // Tres taps "Sólido" en las primeras tres tarjetas. Hago scroll
    // para asegurar visibilidad antes de cada tap.
    for (int i = 0; i < 3; i++) {
      final solidoFinder = find.text('Sólido').at(i);
      await tester.scrollUntilVisible(solidoFinder, 80);
      await tester.tap(solidoFinder);
      await tester.pumpAndSettle();
    }

    final cta = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('AL CONCILIO'),
        matching: find.byType(TextButton),
      ),
    );
    expect(cta.onPressed, isNotNull);
    expect(find.textContaining('Sostienes 3'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('AL CONCILIO'), 80);
    await tester.tap(find.text('AL CONCILIO'));
    await tester.pumpAndSettle();
    expect(avancesInvocados, 1);

    // Persistencia: las 3 declaraciones deben estar en prefs.
    final prefs = await SharedPreferences.getInstance();
    final blob = prefs.getString(
      'nuevoser.lasversiones.perfil.principal.brecha.1.1.reconstruccion',
    );
    expect(blob, isNotNull);
    expect(blob, contains('solido'));
  });

  testWidgets('quitar una afirmación devuelve al estado bloqueado',
      (tester) async {
    await bombearFase(
      tester,
      brecha: CatalogoBrechas.brecha11,
      alAvanzar: () {},
    );

    for (int i = 0; i < 3; i++) {
      final solidoFinder = find.text('Sólido').at(i);
      await tester.scrollUntilVisible(solidoFinder, 80);
      await tester.tap(solidoFinder);
      await tester.pumpAndSettle();
    }

    final quitarFinder = find.text('Quitar de mi versión').first;
    await tester.scrollUntilVisible(quitarFinder, 80);
    await tester.tap(quitarFinder);
    await tester.pumpAndSettle();

    final cta = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('AL CONCILIO'),
        matching: find.byType(TextButton),
      ),
    );
    expect(cta.onPressed, isNull, reason: 'al bajar a 2 vuelve a bloquearse');
  });

  testWidgets('declaraciones persistidas reaparecen al abrir la fase',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'nuevoser.lasversiones.perfil_activo_id': 'principal',
      'nuevoser.lasversiones.perfiles_lista': <String>['principal'],
      'nuevoser.lasversiones.perfil.principal.brecha.1.1.reconstruccion':
          '{"es_un_enterramiento":"solido",'
              '"fechado_neolitico":"solido",'
              '"funcion_ritual":"probable"}',
    });
    await bombearFase(
      tester,
      brecha: CatalogoBrechas.brecha11,
      alAvanzar: () {},
    );

    final cta = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('AL CONCILIO'),
        matching: find.byType(TextButton),
      ),
    );
    expect(cta.onPressed, isNotNull);
    expect(find.textContaining('Sostienes 3'), findsOneWidget);
  });

  testWidgets(
      'Brecha con minimoAfirmacionesParaConcilio elevado (5) requiere '
      'declarar 5 antes de poder ir al Concilio — soporte para Brechas '
      'del Arco 2 con catálogos de afirmaciones más amplios', (tester) async {
    final brechaConMinimoAlto = Brecha(
      id: 'test.minimo.alto',
      titulo: 'Brecha de prueba',
      ubicacionVisible: 'TEST',
      habilidadesEjercitadas: const ['AH.03'],
      fuentes: const [],
      flagDeCompletado: 'brecha_test_completada',
      minimoAfirmacionesParaConcilio: 5,
      afirmacionesCanonicas: List.generate(
        7,
        (i) => AfirmacionCanonica(
          id: 'afirmacion_$i',
          texto: 'Afirmación canónica número $i',
          calibracionCorrecta: NivelConfianza.solido,
        ),
      ),
    );

    await bombearFase(
      tester,
      brecha: brechaConMinimoAlto,
      alAvanzar: () {},
    );

    expect(
      find.textContaining('faltan 5'),
      findsOneWidget,
      reason: 'el contador debe leer el mínimo de 5 del modelo Brecha',
    );

    for (int i = 0; i < 4; i++) {
      final solidoFinder = find.text('Sólido').at(i);
      await tester.scrollUntilVisible(solidoFinder, 80);
      await tester.tap(solidoFinder);
      await tester.pumpAndSettle();
    }

    final ctaConCuatro = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('AL CONCILIO'),
        matching: find.byType(TextButton),
      ),
    );
    expect(
      ctaConCuatro.onPressed,
      isNull,
      reason:
          'declarar 4 sigue bloqueado: el mínimo es 5, no el default 3',
    );

    final solidoQuinto = find.text('Sólido').at(4);
    await tester.scrollUntilVisible(solidoQuinto, 80);
    await tester.tap(solidoQuinto);
    await tester.pumpAndSettle();

    final ctaConCinco = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('AL CONCILIO'),
        matching: find.byType(TextButton),
      ),
    );
    expect(
      ctaConCinco.onPressed,
      isNotNull,
      reason: 'al alcanzar el mínimo declarado el CTA se desbloquea',
    );
  });

  testWidgets('ir al Concilio apunta cada afirmación declarada en AH.03 (P4)',
      (tester) async {
    final repositorio = RepositorioHabilidades(gestor: _gestorDePrueba());
    await bombearFase(
      tester,
      brecha: CatalogoBrechas.brecha11,
      alAvanzar: () {},
      registro: RegistroMaestriaArchivo(repositorio: repositorio),
    );
    for (int i = 0; i < 3; i++) {
      final solidoFinder = find.text('Sólido').at(i);
      await tester.scrollUntilVisible(solidoFinder, 80);
      await tester.tap(solidoFinder);
      await tester.pumpAndSettle();
    }
    await tester.scrollUntilVisible(find.text('AL CONCILIO'), 80);
    await tester.tap(find.text('AL CONCILIO'));
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));

    final estado = await tester.runAsync(() => repositorio.cargar('AH.03'));
    expect(estado!.totalExposiciones, 3);
    for (final intento in estado.intentosRecientes) {
      expect(intento.confianzaDeclarada, 1.0, reason: 'declaró Sólido');
      expect(intento.fiabilidadReal, isNotNull);
    }
  });

  testWidgets('«Anclada en» muestra el nombre de las fuentes, no su id',
      (tester) async {
    await bombearFase(tester, brecha: CatalogoBrechas.brecha11, alAvanzar: () {});
    expect(find.textContaining('restos_oseos_in_situ'), findsNothing);
    expect(find.textContaining('Restos óseos en el hueco interior'), findsWidgets);
  });
}
