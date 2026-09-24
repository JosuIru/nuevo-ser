import 'package:flutter_test/flutter_test.dart';
import 'package:las_versiones/dominio/atico/oficios_atico.dart';
import 'package:las_versiones/dominio/atico/partida_tres_fichas.dart';
import 'package:las_versiones/dominio/atico/voz_andres_atico.dart';
import 'package:las_versiones/dominio/brecha.dart';
import 'package:las_versiones/dominio/catalogo_brechas.dart';

void main() {
  final soloPrimera = {CatalogoBrechas.brecha11.flagDeCompletado};
  final variasCapas = {
    CatalogoBrechas.brecha11.flagDeCompletado,
    CatalogoBrechas.brecha13.flagDeCompletado,
    CatalogoBrechas.brecha21.flagDeCompletado,
  };

  void declararTodo(PartidaTresFichas partida,
      NivelConfianza Function(TarjetaAfirmacion) elegir) {
    for (final ronda in partida.rondas) {
      for (final tarjeta in ronda.tarjetas) {
        partida.declarar(tarjeta, elegir(tarjeta));
      }
    }
  }

  group('apertura del ático', () {
    test('cerrado sin Brechas, abierto tras la primera', () {
      expect(aticoAbierto(const {}), isFalse);
      expect(aticoAbierto(soloPrimera), isTrue);
      expect(brechasCerradas(variasCapas).map((b) => b.id), ['1.1', '1.3', '2.1']);
    });

    test('sin Brechas cerradas no hay partida', () {
      expect(PartidaTresFichas.montar(const []), isNull);
    });
  });

  group('montaje', () {
    test('tres rondas; la primera, de una sola Brecha', () {
      final partida =
          PartidaTresFichas.montar(brechasCerradas(variasCapas), semilla: 1)!;
      expect(partida.rondas.map((r) => r.tipo), TipoRondaTresFichas.values);
      final brechasPrimera =
          partida.rondas.first.tarjetas.map((t) => t.brecha.id).toSet();
      expect(brechasPrimera, hasLength(1));
    });

    test('la segunda ronda mezcla capas distintas si las hay', () {
      for (var semilla = 0; semilla < 10; semilla++) {
        final partida = PartidaTresFichas.montar(brechasCerradas(variasCapas),
            semilla: semilla)!;
        final capas = partida.rondas[1].tarjetas.map((t) => t.capa).toSet();
        expect(capas.length, greaterThan(1), reason: 'semilla $semilla');
      }
    });

    test('ninguna tarjeta se repite en la partida', () {
      final partida =
          PartidaTresFichas.montar(brechasCerradas(variasCapas), semilla: 3)!;
      final ids = [
        for (final ronda in partida.rondas)
          for (final tarjeta in ronda.tarjetas) tarjeta.id
      ];
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('las fuentes cosidas son las de anclaje de la afirmación', () {
      final partida =
          PartidaTresFichas.montar(brechasCerradas(soloPrimera), semilla: 2)!;
      for (final tarjeta in partida.rondas.expand((r) => r.tarjetas)) {
        expect(tarjeta.fuentesAnclaje.map((f) => f.id),
            tarjeta.afirmacion.idsFuentesAnclaje);
      }
    });

    test('con una sola Brecha pequeña no revienta', () {
      final partida =
          PartidaTresFichas.montar(brechasCerradas(soloPrimera), semilla: 5)!;
      expect(partida.rondas, isNotEmpty);
    });
  });

  group('cierre', () {
    test('todo en su nivel canónico: equilibrio y sin desviaciones', () {
      final partida =
          PartidaTresFichas.montar(brechasCerradas(variasCapas), semilla: 1)!;
      declararTodo(partida, (t) => t.nivelCanonico);
      final cierre = partida.cerrar();
      expect(cierre.inclinacion, InclinacionBalanza.equilibrio);
      expect(cierre.desviaciones, isEmpty);
      expect(cierre.scoreCalibracion, 1.0);
      expect(cierre.capaParaFragmento, isNotNull);
    });

    test('todo en Sólido se inclina a la sobreconfianza', () {
      final partida =
          PartidaTresFichas.montar(brechasCerradas(variasCapas), semilla: 1)!;
      declararTodo(partida, (_) => NivelConfianza.solido);
      final cierre = partida.cerrar();
      expect(cierre.inclinacion, InclinacionBalanza.sobreconfianza);
      expect(cierre.paraComentar!.pasos, greaterThan(0));
    });

    test('todo en Disputado se inclina a la timidez', () {
      final partida =
          PartidaTresFichas.montar(brechasCerradas(variasCapas), semilla: 1)!;
      declararTodo(partida, (_) => NivelConfianza.disputado);
      expect(partida.cerrar().inclinacion, InclinacionBalanza.timidez);
    });

    test('la ronda de la tarjeta suelta no puntúa', () {
      final partida =
          PartidaTresFichas.montar(brechasCerradas(variasCapas), semilla: 1)!;
      declararTodo(partida, (t) => t.nivelCanonico);
      final suelta = partida.rondas.last;
      expect(suelta.puntua, isFalse);
      for (final tarjeta in suelta.tarjetas) {
        partida.declarar(
            tarjeta,
            tarjeta.nivelCanonico == NivelConfianza.solido
                ? NivelConfianza.disputado
                : NivelConfianza.solido);
      }
      expect(partida.cerrar().desviaciones, isEmpty);
    });

    test('cambiar de bandeja cuenta la última', () {
      final partida =
          PartidaTresFichas.montar(brechasCerradas(soloPrimera), semilla: 1)!;
      final tarjeta = partida.rondas.first.tarjetas.first;
      partida.declarar(tarjeta, NivelConfianza.disputado);
      partida.declarar(tarjeta, tarjeta.nivelCanonico);
      expect(partida.declarado(tarjeta), tarjeta.nivelCanonico);
      expect(partida.rondaCompleta(0), partida.rondas.first.tarjetas.length == 1);
    });
  });

  test('Andrés comenta con datos del catálogo, sin inventar', () {
    final tarjeta = PartidaTresFichas.montar(brechasCerradas(soloPrimera),
            semilla: 1)!
        .rondas
        .first
        .tarjetas
        .first;
    final frase = VozAndresAtico.sobreUnaTarjeta(
        DesviacionTarjeta(tarjeta: tarjeta, declarado: NivelConfianza.solido));
    expect(frase, contains(tarjeta.afirmacion.texto));
    expect(frase, contains(VozAndresAtico.nombreNivel(tarjeta.nivelCanonico)));
  });
}
