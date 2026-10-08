import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

void main() {
  group('parsearTablaCsv — formato de fichero', () {
    test('contenido vacío devuelve tabla vacía', () {
      final t = parsearTablaCsv('');
      expect(t.cabecera, isEmpty);
      expect(t.filas, isEmpty);
    });

    test('cabecera + una fila con delim ","', () {
      final t = parsearTablaCsv('a,b,c\n1,2,3');
      expect(t.cabecera, ['a', 'b', 'c']);
      expect(t.filas, [
        ['1', '2', '3'],
      ]);
    });

    test('delim ";" auto-detectado cuando no hay ","', () {
      final t = parsearTablaCsv('a;b;c\n1;2;3');
      expect(t.cabecera, ['a', 'b', 'c']);
      expect(t.filas, [
        ['1', '2', '3'],
      ]);
    });

    test('delim "," gana si la primera línea tiene ambos', () {
      final t = parsearTablaCsv('a,b\n"con;punto",2');
      expect(t.cabecera, ['a', 'b']);
      expect(t.filas, [
        ['con;punto', '2'],
      ]);
    });

    test('BOM UTF-8 al inicio se descarta', () {
      final t = parsearTablaCsv('﻿a,b\n1,2');
      expect(t.cabecera, ['a', 'b']);
      expect(t.filas.first, ['1', '2']);
    });

    test('CRLF se acepta como salto de línea', () {
      final t = parsearTablaCsv('a,b\r\n1,2\r\n3,4\r\n');
      expect(t.filas, [
        ['1', '2'],
        ['3', '4'],
      ]);
    });

    test('líneas vacías intermedias se saltan', () {
      final t = parsearTablaCsv('a,b\n1,2\n\n3,4');
      expect(t.filas, [
        ['1', '2'],
        ['3', '4'],
      ]);
    });

    test('campo entrecomillado con coma dentro', () {
      final t = parsearTablaCsv('a,b\n1,"con, coma"');
      expect(t.filas.first, ['1', 'con, coma']);
    });

    test('comillas escapadas dobles dentro de campo entrecomillado', () {
      final t = parsearTablaCsv('a,b\n1,"con ""comillas"" dentro"');
      expect(t.filas.first, ['1', 'con "comillas" dentro']);
    });
  });

  group('indicesDeCabecera', () {
    test('mapea nombre→índice case-insensitive y trim', () {
      final i = indicesDeCabecera(['Cultivo_ID', '  Latitud  ', 'LONGITUD']);
      expect(i['cultivo_id'], 0);
      expect(i['latitud'], 1);
      expect(i['longitud'], 2);
    });

    test('duplicados: el último gana', () {
      final i = indicesDeCabecera(['a', 'b', 'A']);
      expect(i['a'], 2);
      expect(i['b'], 1);
    });

    test('cabecera vacía → mapa vacío', () {
      expect(indicesDeCabecera(const []), isEmpty);
    });
  });

  group('campoEnFila', () {
    test('índice válido devuelve campo trimado', () {
      expect(campoEnFila(['  hola  ', 'mundo'], 0), 'hola');
    });

    test('índice null devuelve ""', () {
      expect(campoEnFila(['hola'], null), '');
    });

    test('índice fuera de rango devuelve ""', () {
      expect(campoEnFila(['hola'], 5), '');
    });
  });

  group('escaparCampoCsv', () {
    test('campo simple no se entrecomilla', () {
      expect(escaparCampoCsv('hola'), 'hola');
    });

    test('campo con coma se entrecomilla', () {
      expect(escaparCampoCsv('a,b'), '"a,b"');
    });

    test('campo con comillas: se entrecomilla y duplica internas', () {
      expect(escaparCampoCsv('a"b'), '"a""b"');
    });

    test('campo con salto de línea se entrecomilla', () {
      expect(escaparCampoCsv('a\nb'), '"a\nb"');
    });

    test('cadena vacía no se entrecomilla', () {
      expect(escaparCampoCsv(''), '');
    });

    test('con «;» como separador, el «;» del campo se entrecomilla', () {
      expect(filaCsvAString(['Pienso; 2 sacos', '12,50'], delim: ';'),
          '"Pienso; 2 sacos";"12,50"');
      expect(escaparCampoCsv('a\rb'), '"a\rb"');
    });
  });

  group('filaCsvAString', () {
    test('campos simples unidos por defecto con ","', () {
      expect(filaCsvAString(['a', 'b', 'c']), 'a,b,c');
    });

    test('delim configurable', () {
      expect(filaCsvAString(['a', 'b', 'c'], delim: ';'), 'a;b;c');
    });

    test('escape correcto en mezcla', () {
      expect(
        filaCsvAString(['simple', 'con,coma', 'con "quote"']),
        'simple,"con,coma","con ""quote"""',
      );
    });
  });

  group('round-trip parsear ↔ filaCsvAString', () {
    test('fila con coma sobrevive', () {
      final original = ['olivo', 'con, coma', '40.5'];
      final linea = filaCsvAString(original);
      final t = parsearTablaCsv('a,b,c\n$linea');
      expect(t.filas.first, original);
    });

    test('fila con comillas sobrevive', () {
      final original = ['olivo', 'con "comillas"', '40.5'];
      final linea = filaCsvAString(original);
      final t = parsearTablaCsv('a,b,c\n$linea');
      expect(t.filas.first, original);
    });
  });
}
