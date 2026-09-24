import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_roto/datos/ajuste_sin_prisas.dart';
import 'package:uno_roto/dominio/minijuegos/canales.dart';
import 'package:uno_roto/dominio/minijuegos/esclusas.dart';
import 'package:uno_roto/dominio/minijuegos/salto.dart';
import 'package:uno_roto/dominio/minijuegos/serpiente.dart';

void main() {
  test('el ajuste empieza apagado, se guarda y se recupera', () async {
    SharedPreferences.setMockInitialValues({});
    await AjusteSinPrisas.cargar();
    expect(AjusteSinPrisas.activo.value, isFalse);
    await AjusteSinPrisas.fijar(true);
    AjusteSinPrisas.activo.value = false;
    await AjusteSinPrisas.cargar();
    expect(AjusteSinPrisas.activo.value, isTrue);
    await AjusteSinPrisas.fijar(false);
    await AjusteSinPrisas.cargar();
    expect(AjusteSinPrisas.activo.value, isFalse);
  });

  test('Esclusas: las barcas se paran antes de la compuerta y no vuelven', () {
    final partida = PartidaEsclusas(nivel: 1, dificultad: 3, sinPrisas: true, azar: math.Random(1));
    for (var i = 0; i < 600; i++) {
      expect(partida.avanzar(0.1), isNot(EventoEsclusas.devuelta));
    }
    expect(partida.posicion, PartidaEsclusas.topeSinPrisas);
    // Sin el ajuste, a esa velocidad ya habrían vuelto.
    final conPrisas = PartidaEsclusas(nivel: 1, dificultad: 3, azar: math.Random(1));
    final eventos = [for (var i = 0; i < 600; i++) conPrisas.avanzar(0.1)];
    expect(eventos, contains(EventoEsclusas.devuelta));
  });

  test('Canales: parado contra un muro, las sombras no se mueven', () {
    final partida = PartidaCanales(
      laberinto: LaberintoCanales(laberintosCanales.first),
      regla: ReglaCanales.para('DIV.01', 1, math.Random(2))!,
      dificultad: 3,
      nivel: 3,
      sinPrisas: true,
      azar: math.Random(2),
    );
    // Sin dirección el Fragmento no se mueve.
    final antes = [...partida.sombras];
    for (var i = 0; i < 30; i++) {
      partida.avanzar();
    }
    expect(partida.sombras, antes);
  });

  test('Serpiente: en el nivel 3 los números se quedan quietos', () {
    final partida = PartidaSerpiente(habilidades: ['ARI.01'], dificultad: 2, sinPrisas: true, azar: math.Random(4));
    partida.cambiarNivel(3);
    final antes = Map.of(partida.numeros);
    for (var i = 0; i < 3; i++) {
      partida.avanzar();
    }
    // Tres pasos: no se come nada (los números están a más de 3 casillas).
    expect(partida.numeros, antes);
    for (var i = 0; i < 5; i++) {
      partida.avanzar();
    }
    expect(partida.numeros.keys.every(antes.containsKey), isTrue);
  });

  test('Salto: más despacio y sin pinchos triples', () {
    final partida = PartidaSalto(habilidades: ['ARI.01'], dificultad: 3, nivel: 3, sinPrisas: true, azar: math.Random(5));
    expect(partida.velocidad, PartidaSalto.velocidadSinPrisas);
    for (final obstaculo in partida.obstaculos) {
      if (obstaculo.tipo == TipoObstaculo.pinchos) expect(obstaculo.ancho, lessThan(3));
    }
  });
}
