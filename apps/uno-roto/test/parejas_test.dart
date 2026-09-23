import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/parejas.dart';

double _valor(String etiqueta) {
  if (etiqueta.endsWith('%')) {
    return double.parse(etiqueta.replaceAll('%', '').trim()) / 100;
  }
  if (etiqueta.contains('/')) {
    final partes = etiqueta.split('/');
    return int.parse(partes[0]) / int.parse(partes[1]);
  }
  return double.parse(etiqueta.replaceAll(',', '.'));
}

void main() {
  for (final habilidades in [
    ['FR.09'],
    ['DEC.08'],
    ['PROP.05'],
    ['FR.09', 'DEC.08', 'PROP.05'],
  ]) {
    for (final dificultad in [1, 2, 3]) {
      test('$habilidades d$dificultad: parejas del mismo valor, valores únicos',
          () {
        for (var semilla = 0; semilla < 40; semilla++) {
          final tablero = GeneradorParejas(semilla: semilla)
              .generar(habilidades, dificultad: dificultad);
          expect(tablero.cartas.length, dificultad >= 2 ? 16 : 12);
          final porPareja = <int, List<CartaPareja>>{};
          for (final carta in tablero.cartas) {
            porPareja.putIfAbsent(carta.idPareja, () => []).add(carta);
          }
          final valores = <double>{};
          for (final pareja in porPareja.values) {
            expect(pareja, hasLength(2));
            expect(pareja[0].etiqueta, isNot(pareja[1].etiqueta));
            expect(_valor(pareja[0].etiqueta),
                closeTo(_valor(pareja[1].etiqueta), 1e-9));
            // Ninguna carta vale lo mismo que otra pareja.
            expect(valores.add((_valor(pareja[0].etiqueta) * 1e6).round() / 1e6),
                isTrue);
          }
          for (final id in porPareja.keys) {
            expect(habilidades, contains(tablero.habilidadDePareja[id]));
          }
        }
      });
    }
  }

  test('emparejar retira las dos y cuenta los fallos', () {
    final tablero = GeneradorParejas(semilla: 1).generar(['DEC.08']);
    final primera = tablero.cartas[0];
    final companera = tablero.cartas
        .indexWhere((c) => c.idPareja == primera.idPareja && c != primera);
    final otra = tablero.cartas.indexWhere((c) => c.idPareja != primera.idPareja);
    expect(tablero.emparejar(0, otra), isFalse);
    expect(tablero.intentosFallidos, 1);
    expect(tablero.fallosPorHabilidad, {'DEC.08': 1});
    expect(tablero.aciertoPorHabilidad, {'DEC.08': true});
    expect(tablero.acierto, isTrue);
    expect(tablero.emparejar(0, companera), isTrue);
    expect(tablero.retiradas, containsAll([0, companera]));
    expect(tablero.emparejar(0, companera), isFalse); // ya retiradas
    expect(tablero.intentosFallidos, 1);
  });

  test('decimales cortos y porcentajes', () {
    final tablero = GeneradorParejas(semilla: 3).generar(['DEC.08', 'PROP.05']);
    for (final carta in tablero.cartas) {
      expect(carta.etiqueta.endsWith(',50'), isFalse);
    }
  });
}
