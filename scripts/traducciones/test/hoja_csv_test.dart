import 'dart:convert';

import 'package:test/test.dart';
import 'package:traducciones/src/hoja_csv.dart';

void main() {
  group('escribirCsv', () {
    test('empieza con BOM UTF-8 y separa filas con CRLF', () {
      final textoCsv = escribirCsv([
        ['clave', 'es'],
        ['saludo', 'Hola'],
      ]);
      expect(textoCsv.startsWith(marcaBom), isTrue);
      expect(textoCsv, '${marcaBom}clave,es\r\nsaludo,Hola\r\n');
      final bytesCsv = utf8.encode(textoCsv);
      expect(bytesCsv.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
    });

    test('entrecomilla campos con comas, comillas y saltos de línea', () {
      final textoCsv = escribirCsv([
        ['a,b', 'dice "hola"', 'línea 1\nlínea 2', 'normal'],
      ]);
      expect(
        textoCsv,
        '$marcaBom"a,b","dice ""hola""","línea 1\nlínea 2",normal\r\n',
      );
    });
  });

  group('leerCsv', () {
    test('ida y vuelta con comas, comillas, saltos de línea y acentos', () {
      final filasOriginales = [
        ['clave', 'es', 'eu', 'estado', 'nota', 'descripcion'],
        ['a', 'Uno, dos', 'Bat, bi', 'pendiente', '', ''],
        ['b', 'Dice "sí"', 'Esaten du "bai"', 'revisado', 'ok', 'x'],
        ['c', 'Línea\nsegunda', 'Lerroa\r\nbigarrena', '', '', ''],
        ['d', '', '', '', '', ''],
        ['e', 'ñandú ¿qué? àèç', 'çà', '', '', ''],
      ];
      final filasLeidas = leerCsv(escribirCsv(filasOriginales));
      expect(filasLeidas, filasOriginales);
    });

    test('quita el BOM de la primera celda', () {
      final filasLeidas = leerCsv('${marcaBom}clave,es\r\nx,y\r\n');
      expect(filasLeidas.first.first, 'clave');
    });

    test('acepta saltos LF y la última fila sin salto final', () {
      expect(leerCsv('a,b\nc,d'), [
        ['a', 'b'],
        ['c', 'd'],
      ]);
    });

    test('detecta punto y coma como separador (Excel en castellano)', () {
      expect(leerCsv('${marcaBom}clave;es\r\nx;"uno; dos, tres"\r\n'), [
        ['clave', 'es'],
        ['x', 'uno; dos, tres'],
      ]);
    });

    test('rechaza comillas sin cerrar', () {
      expect(() => leerCsv('a,"sin cerrar\n'), throwsFormatException);
    });
  });

  group('decodificarBytesCsv', () {
    test('decodifica UTF-8 con BOM', () {
      final bytesCsv = [0xEF, 0xBB, 0xBF, ...utf8.encode('clave\r\nñ\r\n')];
      expect(leerCsv(decodificarBytesCsv(bytesCsv)), [
        ['clave'],
        ['ñ'],
      ]);
    });

    test('explica el error si la hoja no se guardó en UTF-8', () {
      // «ñ» en Windows-1252 es 0xF1, que no es UTF-8 válido.
      final bytesLatin1 = [0x61, 0x2C, 0xF1, 0x0A];
      expect(
        () => decodificarBytesCsv(bytesLatin1),
        throwsA(isA<FormatException>().having(
            (error) => error.message, 'mensaje', contains('UTF-8'))),
      );
    });
  });
}
