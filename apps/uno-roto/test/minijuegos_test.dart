import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:uno_roto/dominio/minijuegos/catalogo_minijuegos.dart';
import 'package:uno_roto/dominio/minijuegos/puentes.dart';
import 'package:uno_roto/dominio/problema_espejo.dart' show Fraccion;

EstadoHabilidad _estado(String id, NivelMaestria nivel) {
  final inicial = EstadoHabilidad.inicial(id);
  return EstadoHabilidad(
    identificadorHabilidad: id,
    nivel: nivel,
    precision: inicial.precision,
    tiempoMedianoSeg: inicial.tiempoMedianoSeg,
    ultimaPractica: inicial.ultimaPractica,
    sesionesConsecutivasBuenas: inicial.sesionesConsecutivasBuenas,
    totalExposiciones: inicial.totalExposiciones,
    intentosRecientes: inicial.intentosRecientes,
  );
}

void main() {
  group('Catálogo y disponibilidad', () {
    test('ids únicos y habilidades existentes en el formato del catálogo', () {
      final ids = CatalogoMinijuegos.todos.map((d) => d.id).toSet();
      expect(ids.length, CatalogoMinijuegos.todos.length);
      for (final definicion in CatalogoMinijuegos.todos) {
        expect(definicion.habilidades, isNotEmpty);
        expect(definicion.rondasPorPartida, greaterThan(0));
      }
    });

    test('sin práctica, la máquina no está disponible', () {
      final puentes = CatalogoMinijuegos.de(IdMinijuego.puentes);
      expect(disponibilidadMinijuego(puentes, {}).disponible, isFalse);
      expect(
          disponibilidadMinijuego(
                  puentes, {'FR.14': _estado('FR.14', NivelMaestria.inexplorada)})
              .disponible,
          isFalse);
    });

    test('la dificultad sale de la mejor habilidad practicada', () {
      final puentes = CatalogoMinijuegos.de(IdMinijuego.puentes);
      final disponibilidad = disponibilidadMinijuego(puentes, {
        'FR.14': _estado('FR.14', NivelMaestria.competente),
        'FR.16': _estado('FR.16', NivelMaestria.introducida),
      });
      expect(disponibilidad.disponible, isTrue);
      expect(disponibilidad.habilidadesPracticadas, ['FR.14', 'FR.16']);
      expect(disponibilidad.dificultad, 2);
    });
  });

  group('Puentes', () {
    test('probarPuente distingue corto, exacto y largo', () {
      const hueco = Fraccion(5, 6);
      expect(probarPuente(hueco, []), ResultadoPuente.vacio);
      expect(probarPuente(hueco, const [Fraccion(1, 2)]), ResultadoPuente.corto);
      expect(probarPuente(hueco, const [Fraccion(1, 2), Fraccion(1, 3)]),
          ResultadoPuente.exacto);
      expect(probarPuente(hueco, const [Fraccion(1, 2), Fraccion(1, 2)]),
          ResultadoPuente.largo);
    });

    test('sumaExacta simplifica', () {
      final suma = sumaExacta(const [Fraccion(1, 4), Fraccion(1, 4)]);
      expect(suma.numerador, 1);
      expect(suma.denominador, 2);
    });

    for (final modo in ModoPuente.values) {
      for (final dificultad in [1, 2, 3]) {
        test('generador $modo d$dificultad: soluble y sin atajo de un tablón',
            () {
          for (var semilla = 0; semilla < 60; semilla++) {
            final reto = GeneradorPuentes(semilla: semilla)
                .generar(modo, dificultad: dificultad);
            expect(probarPuente(reto.hueco, reto.solucion),
                ResultadoPuente.exacto);
            for (final tablon in reto.solucion) {
              expect(reto.tablones, contains(tablon));
            }
            for (final tablon in reto.tablones) {
              expect(probarPuente(reto.hueco, [tablon]),
                  isNot(ResultadoPuente.exacto));
            }
            if (modo == ModoPuente.distintoDenominador) {
              expect(reto.solucion.map((f) => f.denominador).toSet().length,
                  greaterThan(1));
            }
          }
        });
      }
    }

    for (final modo in [ModoPuente.restaMismoDenominador, ModoPuente.restaDistintoDenominador]) {
      for (final dificultad in [1, 2, 3]) {
        test('puente roto $modo d$dificultad: montado entero sobra; quitando lo que sobra queda justo', () {
          for (var semilla = 0; semilla < 60; semilla++) {
            final reto = GeneradorPuentes(semilla: semilla).generar(modo, dificultad: dificultad);
            expect(probarPuente(reto.hueco, reto.tablones), ResultadoPuente.largo);
            expect(reto.tablones.length, reto.solucion.length + (dificultad >= 2 ? 2 : 1));
            expect(probarPuente(reto.hueco, reto.solucion), ResultadoPuente.exacto);
          }
        });
      }
    }

    test('etiquetas decimales con coma', () {
      expect(etiquetaDecimal(const Fraccion(12, 10)), '1,2');
      expect(etiquetaDecimal(const Fraccion(105, 100)), '1,05');
    });
  });
}
