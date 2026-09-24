import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'package:las_versiones/dominio/ambiente_archivo.dart';
import 'package:las_versiones/dominio/voz_personaje.dart';
import 'package:las_versiones/vista/avatar_personaje.dart';
import 'package:las_versiones/vista/pantalla_cinematica.dart';

void main() {
  group('PantallaCinematica — tap durante PlanoAmbiente', () {
    testWidgets(
      'tap durante un PlanoAmbiente avanza al siguiente plano sin '
      'esperar la duración entera — UX clave en móvil para no obligar '
      'al jugador a esperar 4-7s por plano',
      (tester) async {
        var terminada = false;
        const escena = EscenaCinematica(
          id: 'test_skip_ambiente',
          titulo: 'test',
          flagDeSalida: 'test_visto',
          ambiente: AmbienteArchivo.aticoArchivo,
          planos: [
            PlanoAmbiente(
              duracion: Duration(seconds: 60),
              textoLectura: 'Texto de la primera acotación',
            ),
            PlanoAmbiente(
              duracion: Duration(seconds: 60),
              textoLectura: 'Texto de la segunda acotación',
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp(
          home: PantallaCinematica(
            escena: escena,
            alTerminar: () => terminada = true,
          ),
        ));
        await tester.pump();

        expect(find.text('Texto de la primera acotación'), findsOneWidget);
        expect(find.text('Texto de la segunda acotación'), findsNothing);

        // Tap durante la duración del PlanoAmbiente debe saltar al
        // siguiente sin esperar 60s.
        await tester.tap(find.byType(PantallaCinematica));
        await tester.pump();

        expect(find.text('Texto de la primera acotación'), findsNothing);
        expect(find.text('Texto de la segunda acotación'), findsOneWidget);
        expect(terminada, isFalse);

        // Segundo tap salta el segundo plano y termina la escena.
        await tester.tap(find.byType(PantallaCinematica));
        await tester.pump();
        expect(terminada, isTrue);
      },
    );

    testWidgets(
      'tap durante la pausaPrevia de un PlanoDialogo NO interrumpe '
      'el ritmo — la pausa previa es deliberada y se respeta',
      (tester) async {
        const escena = EscenaCinematica(
          id: 'test_pausa_dialogo',
          titulo: 'test',
          flagDeSalida: 'test_visto',
          ambiente: AmbienteArchivo.aticoArchivo,
          planos: [
            PlanoDialogo(
              voz: VozPersonaje.maren,
              texto: 'Frase con pausa previa.',
              pausaPrevia: Duration(milliseconds: 200),
            ),
            PlanoAmbiente(
              duracion: Duration(milliseconds: 50),
              textoLectura: 'Acotación posterior',
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp(
          home: PantallaCinematica(
            escena: escena,
            alTerminar: () {},
          ),
        ));
        await tester.pump();

        // Tap durante la pausaPrevia (≤200ms) del diálogo no debe avanzar.
        await tester.tap(find.byType(PantallaCinematica));
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text('Acotación posterior'), findsNothing,
            reason: 'la pausa previa del diálogo se respeta');

        // Drenar timers pendientes para que el test termine limpio.
        await tester.pumpAndSettle(const Duration(seconds: 2));
      },
    );
  });

  group('PantallaCinematica — avatar del hablante', () {
    testWidgets(
      'PlanoDialogo con voz nombrada muestra el AvatarPersonaje junto '
      'al nombre del hablante',
      (tester) async {
        const escena = EscenaCinematica(
          id: 'test_avatar_dialogo',
          titulo: 'test',
          flagDeSalida: 'test_visto',
          ambiente: AmbienteArchivo.aticoArchivo,
          planos: [
            PlanoDialogo(
              voz: VozPersonaje.maren,
              texto: 'Hola.',
              pausaPrevia: Duration.zero,
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp(
          home: PantallaCinematica(escena: escena, alTerminar: () {}),
        ));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(find.byType(AvatarPersonaje), findsOneWidget);
        expect(find.text('MAREN'), findsOneWidget);
      },
    );

    testWidgets(
      'PlanoDialogo con voz narrador (sin nombre) no muestra cabecera '
      'de voz — ni avatar ni nombre',
      (tester) async {
        const escena = EscenaCinematica(
          id: 'test_avatar_narrador',
          titulo: 'test',
          flagDeSalida: 'test_visto',
          ambiente: AmbienteArchivo.aticoArchivo,
          planos: [
            PlanoDialogo(
              voz: VozPersonaje.narrador,
              texto: 'Acotación sin atribución.',
              pausaPrevia: Duration.zero,
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp(
          home: PantallaCinematica(escena: escena, alTerminar: () {}),
        ));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(find.byType(AvatarPersonaje), findsNothing);
      },
    );
  });

  group('PantallaCinematica — respuestas y versión corta', () {
    testWidgets('una opción con textoRespuesta muestra la réplica antes de seguir',
        (tester) async {
      final flags = <String>[];
      const escena = EscenaCinematica(
        id: 'test_respuesta',
        titulo: 'test',
        flagDeSalida: 'test_visto',
        ambiente: AmbienteArchivo.aticoArchivo,
        planos: [
          PlanoEleccion(
            voz: VozPersonaje.begona,
            textoPrompt: '¿Qué sabes?',
            opciones: [
              OpcionEleccion(
                textoJugador: 'Poco.',
                textoRespuesta: 'Eso sí se puede decir.',
                vozRespuesta: VozPersonaje.isaura,
                flagsAEstablecer: {'eligio_poco'},
              ),
            ],
          ),
          PlanoAmbiente(duracion: Duration(seconds: 60), textoLectura: 'Después'),
        ],
      );
      await tester.pumpWidget(MaterialApp(
        home: PantallaCinematica(escena: escena, alTerminar: () {}, alEstablecerFlag: flags.add),
      ));
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.text('Poco.'));
      await tester.pump(const Duration(seconds: 2));

      expect(flags, ['eligio_poco']);
      expect(find.text('Eso sí se puede decir.'), findsOneWidget);
      expect(find.text('Después'), findsNothing);

      await tester.tap(find.byType(PantallaCinematica));
      await tester.pump();
      expect(find.text('Después'), findsOneWidget);
    });

    testWidgets('«VER ENTERA» cambia a la escena entera desde el principio',
        (tester) async {
      var terminada = false;
      const corta = EscenaCinematica(
        id: 'x',
        titulo: 'test',
        flagDeSalida: 'x_vista',
        ambiente: AmbienteArchivo.aticoArchivo,
        planos: [PlanoAmbiente(duracion: Duration(seconds: 60), textoLectura: 'Resumen')],
      );
      const entera = EscenaCinematica(
        id: 'x',
        titulo: 'test',
        flagDeSalida: 'x_vista',
        ambiente: AmbienteArchivo.aticoArchivo,
        planos: [
          PlanoAmbiente(duracion: Duration(seconds: 60), textoLectura: 'Primer plano entero'),
          PlanoAmbiente(duracion: Duration(seconds: 60), textoLectura: 'Segundo plano entero'),
        ],
      );
      await tester.pumpWidget(MaterialApp(
        home: PantallaCinematica(
          escena: corta,
          escenaEntera: entera,
          alTerminar: () => terminada = true,
        ),
      ));
      await tester.pump();
      expect(find.text('Resumen'), findsOneWidget);

      await tester.tap(find.text('VER ENTERA'));
      await tester.pump();
      expect(find.text('Primer plano entero'), findsOneWidget);
      expect(find.text('VER ENTERA'), findsNothing);

      await tester.tap(find.byType(PantallaCinematica));
      await tester.pump();
      await tester.tap(find.byType(PantallaCinematica));
      await tester.pump();
      expect(terminada, isTrue);
    });

    testWidgets('sin escena entera no aparece «VER ENTERA»', (tester) async {
      const escena = EscenaCinematica(
        id: 'y',
        titulo: 'test',
        flagDeSalida: 'y_vista',
        ambiente: AmbienteArchivo.aticoArchivo,
        planos: [PlanoAmbiente(duracion: Duration(seconds: 60), textoLectura: 'Algo')],
      );
      await tester.pumpWidget(MaterialApp(home: PantallaCinematica(escena: escena, alTerminar: () {})));
      await tester.pump();
      expect(find.text('VER ENTERA'), findsNothing);
    });
  });
}
