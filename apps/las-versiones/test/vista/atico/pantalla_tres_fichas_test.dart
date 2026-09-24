import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:las_versiones/dominio/atico/oficios_atico.dart';
import 'package:las_versiones/dominio/atico/partida_tres_fichas.dart';
import 'package:las_versiones/dominio/atico/voz_andres_atico.dart';
import 'package:las_versiones/dominio/brecha.dart';
import 'package:las_versiones/dominio/catalogo_brechas.dart';
import 'package:las_versiones/vista/atico/pantalla_atico.dart';
import 'package:las_versiones/vista/atico/pantalla_tres_fichas.dart';

void main() {
  final flags = {
    CatalogoBrechas.brecha11.flagDeCompletado,
    CatalogoBrechas.brecha21.flagDeCompletado,
  };

  setUp(() {
    final vista = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    vista.physicalSize = const Size(1000, 2600);
    vista.devicePixelRatio = 1.0;
  });

  testWidgets('se juega entera tocando bandejas y termina en la balanza',
      (tester) async {
    final partida = PartidaTresFichas.montar(brechasCerradas(flags), semilla: 1)!;
    await tester.pumpWidget(MaterialApp(home: PantallaTresFichas(partida: partida)));

    for (var ronda = 0; ronda < partida.rondas.length; ronda++) {
      for (final tarjeta in partida.rondas[ronda].tarjetas) {
        // La tarjeta de encima se lee entera antes de decidir.
        expect(find.text(tarjeta.afirmacion.texto), findsWidgets);
        if (partida.rondas[ronda].fuentesOcultas) {
          await tester.tap(find.text('Abrir el cajón de las fuentes'));
          await tester.pump();
        }
        await tester.tap(find.text('Sólido').first);
        await tester.pump();
      }
      final siguiente = ronda == partida.rondas.length - 1
          ? 'Que hable la balanza'
          : 'Siguiente caja';
      await tester.tap(find.text(siguiente));
      await tester.pumpAndSettle();
    }

    expect(find.text('Volver al ático'), findsOneWidget);
    expect(find.text(VozAndresAtico.cierre), findsOneWidget);
  });

  testWidgets('sacar la última devuelve la tarjeta a la caja', (tester) async {
    final partida = PartidaTresFichas.montar(brechasCerradas(flags), semilla: 1)!;
    await tester.pumpWidget(MaterialApp(home: PantallaTresFichas(partida: partida)));
    final primera = partida.rondas.first.tarjetas.first;

    await tester.tap(find.text('Probable').first);
    await tester.pump();
    expect(partida.declarado(primera), isNotNull);

    await tester.tap(find.text('sacar la última'));
    await tester.pump();
    expect(partida.declarado(primera), isNull);
  });

  testWidgets('en la ronda de la tarjeta suelta hay que abrir el cajón',
      (tester) async {
    final partida = PartidaTresFichas.montar(brechasCerradas(flags), semilla: 1)!;
    await tester.pumpWidget(MaterialApp(home: PantallaTresFichas(partida: partida)));
    for (var ronda = 0; ronda < partida.rondas.length - 1; ronda++) {
      for (final _ in partida.rondas[ronda].tarjetas) {
        await tester.tap(find.text('Disputado').first);
        await tester.pump();
      }
      await tester.tap(find.text('Siguiente caja'));
      await tester.pumpAndSettle();
    }
    final suelta = partida.rondas.last.tarjetas.first;
    expect(find.text('Abrir el cajón de las fuentes'), findsOneWidget);

    // Sin abrir el cajón, tocar una bandeja no clasifica.
    await tester.tap(find.text('Sólido').first);
    await tester.pump();
    expect(partida.declarado(suelta), isNull);

    await tester.tap(find.text('Abrir el cajón de las fuentes'));
    await tester.pump();
    expect(find.text('Abrir el cajón de las fuentes'), findsNothing);
    await tester.tap(find.text('Sólido').first);
    await tester.pump();
    expect(partida.declarado(suelta), NivelConfianza.solido);
  });

  testWidgets('el ático lista Tres fichas y la abre', (tester) async {
    await tester.pumpWidget(MaterialApp(home: PantallaAtico(flagsActivos: flags)));
    expect(find.text(VozAndresAtico.bienvenida), findsOneWidget);
    await tester.tap(find.text('Tres fichas'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaTresFichas), findsOneWidget);
  });
}
