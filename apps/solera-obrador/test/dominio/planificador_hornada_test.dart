import 'package:flutter_test/flutter_test.dart';
import 'package:solera_obrador/datos/catalogos_generados/catalogo_guia_recetas.dart';
import 'package:solera_obrador/dominio/planificador_hornada.dart';
import 'package:solera_obrador/dominio/tiempos_guia.dart';

const _plantillaSencilla = PlantillaTiempos(temperaturaReferenciaC: 24, fases: [
  TiempoFase(FaseHornada.amasado, 10, 20),
  TiempoFase(FaseHornada.primeraFermentacion, 90, 120),
  TiempoFase(FaseHornada.formado, 20, 30),
  TiempoFase(FaseHornada.fermentacionFinal, 60, 60,
      alternativaNevera:
          TiempoFase(FaseHornada.fermentacionFinal, 600, 720, enNevera: true)),
  TiempoFase(FaseHornada.precalentarHorno, 40, 40),
  TiempoFase(FaseHornada.coccion, 40, 40),
  TiempoFase(FaseHornada.enfriado, 60, 60),
]);

void main() {
  group('regla de temperatura', () {
    test('a la temperatura de referencia no cambia nada', () {
      expect(
          factorTemperatura(temperaturaReferenciaC: 24, temperaturaCocinaC: 24),
          1);
    });

    test('9 °C más frío dobla el tiempo; 9 °C más caliente lo divide', () {
      expect(
          factorTemperatura(temperaturaReferenciaC: 25, temperaturaCocinaC: 16),
          closeTo(2, 1e-9));
      expect(
          factorTemperatura(temperaturaReferenciaC: 23, temperaturaCocinaC: 32),
          closeTo(0.5, 1e-9));
    });

    test('fuera de 16-32 °C se acota y se avisa', () {
      expect(
          factorTemperatura(temperaturaReferenciaC: 25, temperaturaCocinaC: 5),
          closeTo(2, 1e-9));
      expect(temperaturaFueraDeLaRegla(5), isTrue);
      expect(temperaturaFueraDeLaRegla(20), isFalse);
    });
  });

  group('planificar hacia atrás', () {
    test(
        'cada fase termina cuando empieza la siguiente; el horno va en '
        'paralelo con la fermentación final', () {
      final listo = DateTime(2026, 11, 12, 9);
      final fases = planificarHaciaAtras(
          plantilla: _plantillaSencilla, listoA: listo, temperaturaCocinaC: 24);
      expect(fases.map((fase) => fase.fase), [
        FaseHornada.amasado,
        FaseHornada.primeraFermentacion,
        FaseHornada.formado,
        FaseHornada.fermentacionFinal,
        FaseHornada.precalentarHorno,
        FaseHornada.coccion,
        FaseHornada.enfriado,
      ]);
      expect(fases.last.fin, listo);
      final coccion = fases[5];
      expect(coccion.inicio, DateTime(2026, 11, 12, 7, 20));
      // Precalentar: 40 min que acaban al empezar la cocción.
      expect(fases[4].fin, coccion.inicio);
      expect(fases[4].inicio, DateTime(2026, 11, 12, 6, 40));
      // La fermentación final acaba también al empezar la cocción.
      expect(fases[3].fin, coccion.inicio);
      expect(fases[3].inicio, DateTime(2026, 11, 12, 6, 20));
      // Punto medio de los rangos: formado 25, primera 105, amasado 15.
      expect(fases[2].inicio, DateTime(2026, 11, 12, 5, 55));
      expect(fases[1].inicio, DateTime(2026, 11, 12, 4, 10));
      expect(fases.first.inicio, DateTime(2026, 11, 12, 3, 55));
      expect(fases[1].minutosMin, 90);
      expect(fases[1].minutosMax, 120);
    });

    test('cruza medianoche: listo a las 7:00 empieza la víspera', () {
      final fases = planificarHaciaAtras(
          plantilla: _plantillaSencilla,
          listoA: DateTime(2026, 11, 13, 1),
          temperaturaCocinaC: 24);
      expect(fases.first.inicio, DateTime(2026, 11, 12, 19, 55));
      expect(fases.first.inicio.day, 12);
      expect(fases.last.fin.day, 13);
    });

    test('cocina fría alarga solo las fermentaciones', () {
      final templada = planificarHaciaAtras(
          plantilla: _plantillaSencilla,
          listoA: DateTime(2026, 11, 12, 9),
          temperaturaCocinaC: 24);
      final fria = planificarHaciaAtras(
          plantilla: _plantillaSencilla,
          listoA: DateTime(2026, 11, 12, 9),
          temperaturaCocinaC: 15);
      // 15 °C queda fuera de la regla: se calcula como 16 °C.
      final factorFrio =
          factorTemperatura(temperaturaReferenciaC: 24, temperaturaCocinaC: 16);
      expect(factorFrio, greaterThan(1.8));
      for (var indice = 0; indice < templada.length; indice++) {
        final factor = templada[indice].fase.esFermentacion ? factorFrio : 1;
        expect(fria[indice].duracion.inMinutes,
            closeTo(templada[indice].duracion.inMinutes * factor, 1),
            reason: templada[indice].fase.name);
      }
    });

    test(
        'fermentación final en nevera de noche: no se ajusta por '
        'temperatura y empieza la tarde anterior', () {
      final fases = planificarHaciaAtras(
          plantilla: _plantillaSencilla,
          listoA: DateTime(2026, 11, 12, 9),
          temperaturaCocinaC: 18,
          fasesEnNevera: {FaseHornada.fermentacionFinal});
      final finalEnNevera = fases[3];
      expect(finalEnNevera.enNevera, isTrue);
      expect(finalEnNevera.duracion, const Duration(minutes: 660));
      expect(finalEnNevera.minutosMin, 600);
      expect(finalEnNevera.inicio, DateTime(2026, 11, 11, 20, 20));
      // El formado y lo de antes, la víspera.
      expect(fases.first.inicio.day, 11);
    });

    test('pedir nevera en una fase sin alternativa no cambia nada', () {
      final sin = planificarHaciaAtras(
          plantilla: _plantillaSencilla,
          listoA: DateTime(2026, 11, 12, 9),
          temperaturaCocinaC: 24);
      final con = planificarHaciaAtras(
          plantilla: _plantillaSencilla,
          listoA: DateTime(2026, 11, 12, 9),
          temperaturaCocinaC: 24,
          fasesEnNevera: {FaseHornada.primeraFermentacion});
      expect(con.first.inicio, sin.first.inicio);
    });

    test('cruza el cambio de hora: las duraciones son reales', () {
      // 25-oct-2026: en Madrid las 3:00 vuelven a ser las 2:00.
      final fases = planificarHaciaAtras(
          plantilla: _plantillaSencilla,
          listoA: DateTime(2026, 10, 25, 9),
          temperaturaCocinaC: 24);
      final total = fases.last.fin.difference(fases.first.inicio);
      expect(total, const Duration(hours: 5, minutes: 5));
    });

    test('avisa si para llegar habría que haber empezado ya', () {
      final fases = planificarHaciaAtras(
          plantilla: _plantillaSencilla,
          listoA: DateTime(2026, 11, 12, 9),
          temperaturaCocinaC: 24);
      expect(empiezaEnElPasado(fases, DateTime(2026, 11, 12, 4)), isTrue);
      expect(empiezaEnElPasado(fases, DateTime(2026, 11, 12, 3)), isFalse);
    });
  });

  group('durante la hornada', () {
    final plan = planificarHaciaAtras(
        plantilla: _plantillaSencilla,
        listoA: DateTime(2026, 11, 12, 9),
        temperaturaCocinaC: 24);

    test('si una fase acaba tarde, las siguientes se mueven', () {
      final retraso = plan[1].fin.add(const Duration(minutes: 30));
      final nuevo = marcarHechaYReplanificar(plan, 1, retraso);
      expect(nuevo[1].hecha, isTrue);
      expect(nuevo[0].inicio, plan[0].inicio);
      for (var indice = 2; indice < plan.length; indice++) {
        expect(nuevo[indice].inicio,
            plan[indice].inicio.add(const Duration(minutes: 30)));
      }
      expect(finDelPlan(nuevo), DateTime(2026, 11, 12, 9, 30));
      expect(siguienteFasePendiente(nuevo)!.fase, FaseHornada.amasado);
    });

    test('marcar el horno (en paralelo) no mueve nada', () {
      final nuevo = marcarHechaYReplanificar(
          plan, 4, plan[4].fin.add(const Duration(minutes: 10)));
      expect(finDelPlan(nuevo), finDelPlan(plan));
    });

    test('las fases se guardan y se leen en JSON', () {
      final hecho = marcarHechaYReplanificar(plan, 0, plan[0].fin);
      final leido = fasesDeJson(fasesAJson(hecho));
      expect(leido.length, plan.length);
      expect(leido.first.hechaEn, plan[0].fin);
      expect(leido[3].inicio, hecho[3].inicio);
      expect(fasesDeJson('no es json'), isEmpty);
    });
  });

  group('plantillas', () {
    test('JSON de ida y vuelta, con nevera', () {
      final leida = PlantillaTiempos.deJson(_plantillaSencilla.aJson())!;
      expect(leida.temperaturaReferenciaC, 24);
      expect(leida.fases.length, _plantillaSencilla.fases.length);
      expect(leida.fases[3].alternativaNevera!.minutosMax, 720);
      expect(leida.admiteNevera, isTrue);
      expect(PlantillaTiempos.deJson('{'), isNull);
    });

    test('refresco con las horas apuntadas de la masa madre', () {
      expect(tiempoRefrescoApuntado([]), isNull);
      final refresco = tiempoRefrescoApuntado([4, 6, 0])!;
      expect(refresco.minutosMedios, 300);
      final plantilla =
          conRefresco(tiemposRecetasGuia['masa_madre']!, refresco);
      expect(plantilla.fases.first.minutosMin, 225);
    });

    test('próximo refresco de la masa madre', () {
      final ahora = DateTime(2026, 11, 10, 12);
      expect(
          proximoRefresco(
              ultimoRefresco: DateTime(2026, 11, 10, 8),
              cadaHoras: 24,
              ahora: ahora),
          DateTime(2026, 11, 11, 8));
      // Si ya tocaba, desde ahora.
      expect(
          proximoRefresco(
              ultimoRefresco: DateTime(2026, 11, 1),
              cadaHoras: 24,
              ahora: ahora),
          DateTime(2026, 11, 11, 12));
      expect(proximoRefresco(cadaHoras: 168, ahora: ahora),
          DateTime(2026, 11, 17, 12));
    });
  });

  group('tiempos de las recetas de la guía', () {
    String rangoComoEnLaGuia(TiempoFase tiempo) {
      String horas(int minutos) {
        final valor = minutos / 60;
        return valor == valor.roundToDouble()
            ? valor.toStringAsFixed(0)
            : valor.toString().replaceAll('.', ',');
      }

      if (tiempo.minutosMin >= 60 && tiempo.minutosMin % 30 == 0) {
        return tiempo.minutosMin == tiempo.minutosMax
            ? '${horas(tiempo.minutosMin)} h'
            : '${horas(tiempo.minutosMin)}-${horas(tiempo.minutosMax)} h';
      }
      return '${tiempo.minutosMin}-${tiempo.minutosMax} min';
    }

    test('hay tiempos para las 10 recetas de la guía', () {
      expect(tiemposRecetasGuia.keys.toSet(),
          catalogoGuiaRecetas.map((receta) => receta.id).toSet());
    });

    test('la temperatura de referencia es la de la masa en la guía', () {
      for (final receta in catalogoGuiaRecetas) {
        expect(tiemposRecetasGuia[receta.id]!.temperaturaReferenciaC,
            receta.temperaturaMasaGrados,
            reason: receta.id);
      }
    });

    test('los rangos de fermentación y cocción salen del texto de la guía', () {
      for (final receta in catalogoGuiaRecetas) {
        final plantilla = tiemposRecetasGuia[receta.id]!;
        for (final tiempo in plantilla.fases) {
          final texto = switch (tiempo.fase) {
            FaseHornada.autolisis => receta.autolisis,
            FaseHornada.primeraFermentacion => receta.primeraFermentacion,
            FaseHornada.fermentacionFinal => receta.fermentacionFinal,
            FaseHornada.coccion => receta.coccion,
            _ => null,
          };
          if (texto == null) continue;
          // Cocciones que suman dos tramos de la guía: brioche (piezas
          // pequeñas 15-20 y molde 30-40) y hogaza en olla (20 tapada +
          // 20-25 destapada).
          if ({'brioche', 'masa_madre'}.contains(receta.id) &&
              tiempo.fase == FaseHornada.coccion) {
            continue;
          }
          for (final rango in [
            tiempo,
            if (tiempo.alternativaNevera != null) tiempo.alternativaNevera!
          ]) {
            expect(texto, contains(rangoComoEnLaGuia(rango)),
                reason: '${receta.id} ${tiempo.fase.name}');
          }
        }
      }
    });

    test('autólisis solo donde la guía la recomienda', () {
      for (final receta in catalogoGuiaRecetas) {
        final tieneAutolisis = tiemposRecetasGuia[receta.id]!
            .fases
            .any((tiempo) => tiempo.fase == FaseHornada.autolisis);
        expect(tieneAutolisis, receta.autolisis.startsWith('Recomendable'),
            reason: receta.id);
      }
    });

    test('llevan refresco las recetas con masa madre (centeno y hogaza)', () {
      expect(
          tiemposRecetasGuia.entries
              .where((entrada) => entrada.value.llevaMasaMadre)
              .map((entrada) => entrada.key)
              .toSet(),
          {'centeno', 'masa_madre'});
    });

    test('todas se pueden planificar y acaban a la hora pedida', () {
      final listo = DateTime(2026, 11, 12, 8);
      for (final plantilla in tiemposRecetasGuia.values) {
        final fases = planificarHaciaAtras(
            plantilla: plantilla, listoA: listo, temperaturaCocinaC: 21);
        expect(fases.last.fin, listo);
        for (final fase in fases) {
          expect(
              fase.inicio.isBefore(fase.fin) || fase.duracion == Duration.zero,
              isTrue);
        }
      }
    });
  });
}
