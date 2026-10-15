import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:solera_zunbeltz/utiles/edicion_contorno.dart';

void main() {
  const cuadrado = [
    LatLng(0, 0),
    LatLng(0, 1),
    LatLng(1, 1),
    LatLng(1, 0),
  ];

  test('mover una esquina cambia solo esa', () {
    final movido = moverEsquina(cuadrado, 2, const LatLng(2, 2));
    expect(movido, [cuadrado[0], cuadrado[1], const LatLng(2, 2), cuadrado[3]]);
    expect(cuadrado[2], const LatLng(1, 1), reason: 'no toca la lista original');
  });

  test('quitar una esquina, pero nunca por debajo de tres', () {
    final sinUna = quitarEsquina(cuadrado, 0);
    expect(sinUna, [cuadrado[1], cuadrado[2], cuadrado[3]]);
    expect(quitarEsquina(sinUna, 1), sinUna);
    expect(sePuedeQuitarEsquina(cuadrado), isTrue);
    expect(sePuedeQuitarEsquina(sinUna), isFalse);
  });

  test('puntos medios de cada lado, también el que cierra', () {
    expect(puntosMedios(cuadrado), const [
      LatLng(0, 0.5),
      LatLng(0.5, 1),
      LatLng(1, 0.5),
      LatLng(0.5, 0),
    ]);
  });

  test('añadir una esquina en mitad de un lado', () {
    final conUnaMas = insertarEsquinaEnLado(cuadrado, 3);
    expect(conUnaMas, hasLength(5));
    expect(conUnaMas.last, const LatLng(0.5, 0),
        reason: 'el lado 3 va de la última esquina a la primera');
    final enMedio = insertarEsquinaEnLado(cuadrado, 0);
    expect(enMedio[1], const LatLng(0, 0.5));
    expect(posicionEsquinaInsertada(cuadrado.length, 0), 1);
    expect(posicionEsquinaInsertada(cuadrado.length, 3), 4);
  });

  test('índices fuera de rango no rompen nada', () {
    expect(moverEsquina(cuadrado, 9, const LatLng(5, 5)), cuadrado);
    expect(quitarEsquina(cuadrado, -1), cuadrado);
    expect(insertarEsquinaEnLado(cuadrado, 7), cuadrado);
  });
}
