import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:las_versiones/datos/registro_maestria_archivo.dart';
import 'package:las_versiones/datos/repositorio_evaluacion_fuente.dart';
import 'package:las_versiones/datos/repositorio_recoleccion_fuentes.dart';
import 'package:las_versiones/dominio/brecha.dart';
import 'package:las_versiones/dominio/catalogo_brechas.dart';
import 'package:las_versiones/vista/fase_evaluacion.dart';

GestorPerfiles _gestorDePrueba() => GestorPerfiles(
      namespace: 'nuevoser.lasversiones',
      sufijoNombreVisible: 'nombre_jugador',
      clavesGlobalesNoMigrables: const {
        'nuevoser.lasversiones.idioma_app',
        'nuevoser.lasversiones.token_backend',
        'nuevoser.lasversiones.email_backend',
      },
    );

const String _prefijoFuentes11 =
    'nuevoser.lasversiones.perfil.principal.brecha.1.1.fuente.';
const String _prefijoEvaluaciones11 =
    'nuevoser.lasversiones.perfil.principal.brecha.1.1.evaluacion.';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'nuevoser.lasversiones.perfil_activo_id': 'principal',
      'nuevoser.lasversiones.perfiles_lista': <String>['principal'],
      '${_prefijoFuentes11}restos_oseos_in_situ': true,
      '${_prefijoFuentes11}material_litico_entorno': true,
      '${_prefijoFuentes11}informe_excavacion_antiguo': true,
      '${_prefijoFuentes11}informe_revision_moderno': true,
      '${_prefijoFuentes11}toponimo_local': true,
    });
  });

  Future<void> bombearFase(
    WidgetTester tester, {
    required Brecha brecha,
    required VoidCallback alAvanzar,
    RegistroMaestriaArchivo? registro,
  }) async {
    final gestor = _gestorDePrueba();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: FaseEvaluacion(
              brecha: brecha,
              alAvanzarFase: alAvanzar,
              repoRecoleccion: RepositorioRecoleccionFuentes(gestor: gestor),
              repoEvaluacion: RepositorioEvaluacionFuente(gestor: gestor),
              registro: registro,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
      'arranca con 0 evaluadas y CTA bloqueado cuando no hay respuestas',
      (tester) async {
    await bombearFase(
      tester,
      brecha: CatalogoBrechas.brecha11,
      alAvanzar: () {},
    );

    expect(find.text('Evaluadas: 0 / 5'), findsOneWidget);
    final cta = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('IR A LA RECONSTRUCCIÓN'),
        matching: find.byType(TextButton),
      ),
    );
    expect(cta.onPressed, isNull);
  });

  testWidgets(
      'elegir tipo + sesgo en una fuente cuenta como evaluación completa',
      (tester) async {
    await bombearFase(
      tester,
      brecha: CatalogoBrechas.brecha11,
      alAvanzar: () {},
    );

    final primariaFinder = find.text('Primaria').first;
    await tester.scrollUntilVisible(primariaFinder, 80);
    await tester.tap(primariaFinder);
    await tester.pumpAndSettle();

    final ningunoFinder = find.text('Ninguno').first;
    await tester.scrollUntilVisible(ningunoFinder, 80);
    await tester.tap(ningunoFinder);
    await tester.pumpAndSettle();

    expect(find.text('Evaluadas: 1 / 5'), findsOneWidget);
    expect(find.text('NOTA DEL OFICIO'), findsOneWidget);
    expect(
      find.textContaining('Aciertos en esta fuente: 2 / 2'),
      findsOneWidget,
    );
  });

  testWidgets(
      'evaluar las cinco fuentes desbloquea el CTA "IR A LA RECONSTRUCCIÓN"',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'nuevoser.lasversiones.perfil_activo_id': 'principal',
      'nuevoser.lasversiones.perfiles_lista': <String>['principal'],
      '${_prefijoFuentes11}restos_oseos_in_situ': true,
      '${_prefijoFuentes11}material_litico_entorno': true,
      '${_prefijoFuentes11}informe_excavacion_antiguo': true,
      '${_prefijoFuentes11}informe_revision_moderno': true,
      '${_prefijoFuentes11}toponimo_local': true,
      '${_prefijoEvaluaciones11}restos_oseos_in_situ':
          '{"tipo":"primaria","sesgo":"ninguno"}',
      '${_prefijoEvaluaciones11}material_litico_entorno':
          '{"tipo":"primaria","sesgo":"ninguno"}',
      '${_prefijoEvaluaciones11}informe_excavacion_antiguo':
          '{"tipo":"secundaria","sesgo":"difusionista"}',
      '${_prefijoEvaluaciones11}informe_revision_moderno':
          '{"tipo":"secundaria","sesgo":"ninguno"}',
      '${_prefijoEvaluaciones11}toponimo_local':
          '{"tipo":"secundaria","sesgo":"ninguno"}',
    });

    var avancesInvocados = 0;
    await bombearFase(
      tester,
      brecha: CatalogoBrechas.brecha11,
      alAvanzar: () => avancesInvocados++,
    );

    expect(find.text('Evaluadas: 5 / 5'), findsOneWidget);
    final cta = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('IR A LA RECONSTRUCCIÓN'),
        matching: find.byType(TextButton),
      ),
    );
    expect(cta.onPressed, isNotNull);

    await tester.tap(find.text('IR A LA RECONSTRUCCIÓN'));
    await tester.pumpAndSettle();
    expect(avancesInvocados, 1);
  });

  testWidgets(
      'apunta la primera elección de tipo (HF.02) y de sesgo (HF.09); '
      'cambiarla después no vuelve a contar', (tester) async {
    final repositorio = RepositorioHabilidades(gestor: _gestorDePrueba());
    await bombearFase(
      tester,
      brecha: CatalogoBrechas.brecha11,
      alAvanzar: () {},
      registro: RegistroMaestriaArchivo(repositorio: repositorio),
    );

    // Primera fuente: restos óseos, primaria y sin sesgo.
    for (final opcion in ['Primaria', 'Secundaria', 'Ninguno']) {
      final boton = find.text(opcion).first;
      await tester.scrollUntilVisible(boton, 80);
      await tester.tap(boton);
      await tester.pumpAndSettle();
    }
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));

    final tipo = await tester.runAsync(() => repositorio.cargar('HF.02'));
    expect(tipo!.totalExposiciones, 1);
    expect(tipo.intentosRecientes.single.acierto, isTrue,
        reason: 'contó «Primaria», no el cambio a «Secundaria»');

    final sesgo = await tester.runAsync(() => repositorio.cargar('HF.09'));
    final intento = sesgo!.intentosRecientes.single;
    expect(intento.acierto, isTrue);
    expect(intento.senalEsperada, isFalse, reason: 'la fuente no tiene sesgo');
    expect(intento.clasePredicha, isFalse);
  });
}
