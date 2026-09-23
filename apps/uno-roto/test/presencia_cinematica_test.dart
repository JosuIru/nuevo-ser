import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:uno_roto/dominio/voz_personaje.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/pantalla_cinematica.dart';
import 'package:uno_roto/vista/personajes/retratos.dart';

// Kai y Oryn usan los PNG escaneados del concept-art; Sora, su silueta.
const _kai = 'assets/personajes/kai.png';
const _oryn = 'assets/personajes/oryn.png';

Widget _envolver(Widget hijo) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: hijo,
  );
}

void main() {
  testWidgets('voz sora muestra su retrato provisional', (tester) async {
    const escena = EscenaCinematica(
      id: 't.sora',
      titulo: 't', flagDeSalida: 'test',
      planos: [
        PlanoDialogo(voz: VozPersonaje.sora, texto: 'Hola.'),
      ],
    );
    await tester.pumpWidget(_envolver(
      PantallaCinematica(escena: escena, alTerminar: () {}),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(RetratoPersonaje), findsOneWidget);
    expect(find.image(const AssetImage(_kai)), findsNothing);
    expect(find.image(const AssetImage(_oryn)), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('voz kai muestra su retrato del concept-art', (tester) async {
    const escena = EscenaCinematica(
      id: 't.kai',
      titulo: 't', flagDeSalida: 'test',
      planos: [
        PlanoDialogo(voz: VozPersonaje.kai, texto: 'Hola.'),
      ],
    );
    await tester.pumpWidget(_envolver(
      PantallaCinematica(escena: escena, alTerminar: () {}),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.image(const AssetImage(_kai)), findsOneWidget);
  });

  testWidgets('voz oryn muestra su retrato del concept-art', (tester) async {
    const escena = EscenaCinematica(
      id: 't.oryn',
      titulo: 't', flagDeSalida: 'test',
      planos: [
        PlanoDialogo(voz: VozPersonaje.oryn, texto: 'Hola.'),
      ],
    );
    await tester.pumpWidget(_envolver(
      PantallaCinematica(escena: escena, alTerminar: () {}),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.image(const AssetImage(_oryn)), findsOneWidget);
  });

  testWidgets('un maestro sin dibujo sale con retrato; el narrador, sin nada',
      (tester) async {
    const escena = EscenaCinematica(
      id: 't.rexan',
      titulo: 't', flagDeSalida: 'test',
      planos: [PlanoDialogo(voz: VozPersonaje.rexan, texto: 'Hola.')],
    );
    await tester.pumpWidget(_envolver(
      PantallaCinematica(escena: escena, alTerminar: () {}),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(RetratoPersonaje), findsOneWidget);
    expect(tipoRetrato(VozPersonaje.rexan), TipoRetrato.retrato);
    expect(tipoRetrato(VozPersonaje.aprendizNiko), TipoRetrato.silueta);
    expect(tipoRetrato(VozPersonaje.kai), TipoRetrato.dibujo);
    expect(tipoRetrato(VozPersonaje.narrador), TipoRetrato.ninguno);
  });

  testWidgets('todas las siluetas se pintan sin errores a varios tamaños',
      (tester) async {
    for (final rasgos in rasgosPorVoz.values) {
      for (final tamano in const [Size(70, 90), Size(160, 260)]) {
        await tester.pumpWidget(Center(
          child: SizedBox.fromSize(
            size: tamano,
            child: CustomPaint(painter: PintorSilueta(rasgos)),
          ),
        ));
        expect(tester.takeException(), isNull, reason: rasgos.id);
      }
    }
  });
}
