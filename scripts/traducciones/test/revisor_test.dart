import 'dart:io';

import 'package:test/test.dart';
import 'package:traducciones/src/hoja_csv.dart';
import 'package:traducciones/src/revisor.dart';

const arbEspanol = r'''{
  "@@locale": "es",
  "nombreApp": "Concejo",
  "@nombreApp": {
    "description": "Nombre visible de la app, con coma, y \"comillas\""
  },
  "saludo": "Hola, {nombre}",
  "@saludo": {
    "placeholders": {
      "nombre": {
        "type": "String"
      }
    }
  },
  "personas": "{cantidad, plural, =1{Una persona} other{{cantidad} personas}}",
  "@personas": {
    "placeholders": {
      "cantidad": {
        "type": "int"
      }
    }
  },
  "ok": "OK",
  "multilinea": "Primera línea\nSegunda \"línea\"",
  "sinTraducir": "Esto no está en euskera",
  "ultima": "Última"
}
''';

const arbEuskera = r'''{
  "@@locale": "eu",
  "nombreApp": "Kontzejua",
  "saludo": "Kaixo, {nombre}",
  "personas": "{cantidad, plural, =1{Pertsona bat} other{{cantidad} pertsona}}",
  "ok": "OK",
  "multilinea": "Lehen lerroa\nBigarren \"lerroa\" é",
  "ultima": "Azkena",
  "soloEnEuskera": "Hau ez dago gaztelaniaz"
}
''';

late Directory directorioTemporal;
late Directory directorioArb;

File archivoArb(String lengua) => File('${directorioArb.path}/app_$lengua.arb');

File archivoCsv(String nombre) => File('${directorioTemporal.path}/$nombre');

/// Reescribe en el CSV la columna `estado` (y opcionalmente el texto) de
/// las filas indicadas.
void editarHoja(File hoja, String lengua,
    Map<String, ({String? texto, String estado})> cambiosPorClave) {
  final filas = leerCsv(decodificarBytesCsv(hoja.readAsBytesSync()));
  final cabecera = filas.first;
  final columnaClave = cabecera.indexOf('clave');
  final columnaTexto = cabecera.indexOf(lengua);
  final columnaEstado = cabecera.indexOf('estado');
  for (final fila in filas.skip(1)) {
    final cambio = cambiosPorClave[fila[columnaClave]];
    if (cambio == null) continue;
    fila[columnaEstado] = cambio.estado;
    if (cambio.texto != null) fila[columnaTexto] = cambio.texto!;
  }
  hoja.writeAsStringSync(escribirCsv(filas));
}

void main() {
  setUp(() {
    directorioTemporal = Directory.systemTemp.createTempSync('traducciones_');
    directorioArb = Directory('${directorioTemporal.path}/l10n')..createSync();
    archivoArb('es').writeAsStringSync(arbEspanol);
    archivoArb('eu').writeAsStringSync(arbEuskera);
  });

  tearDown(() => directorioTemporal.deleteSync(recursive: true));

  group('exportar', () {
    test('genera la hoja con cabecera, estados y descripción', () {
      final hoja = archivoCsv('eu.csv');
      exportarHoja(directorioArb, 'eu', hoja);

      final bytesHoja = hoja.readAsBytesSync();
      expect(bytesHoja.sublist(0, 3), [0xEF, 0xBB, 0xBF]);

      final filas = leerCsv(decodificarBytesCsv(bytesHoja));
      expect(
          filas.first, ['clave', 'es', 'eu', 'estado', 'nota', 'descripcion']);
      final filaPorClave = {for (final fila in filas.skip(1)) fila[0]: fila};

      expect(filaPorClave.keys.toList(), [
        'nombreApp',
        'saludo',
        'personas',
        'ok',
        'multilinea',
        'sinTraducir',
        'ultima',
      ]);
      expect(filaPorClave['nombreApp'], [
        'nombreApp',
        'Concejo',
        'Kontzejua',
        'pendiente',
        '',
        'Nombre visible de la app, con coma, y "comillas"',
      ]);
      expect(filaPorClave['ok']![3], 'igual_que_es');
      expect(filaPorClave['sinTraducir']![2], '');
      expect(filaPorClave['sinTraducir']![3], 'falta');
      expect(
          filaPorClave['multilinea']![2], 'Lehen lerroa\nBigarren "lerroa" é');
    });

    test('si el ARB de la lengua no existe, todo sale como falta', () {
      final hoja = archivoCsv('gl.csv');
      exportarHoja(directorioArb, 'gl', hoja);
      final filas = leerCsv(decodificarBytesCsv(hoja.readAsBytesSync()));
      expect(filas.skip(1).map((fila) => fila[3]).toSet(), {'falta'});
    });
  });

  group('importar', () {
    test('ida y vuelta sin cambios deja el ARB byte a byte igual', () {
      final bytesAntes = archivoArb('eu').readAsBytesSync();
      final hoja = archivoCsv('eu.csv');
      exportarHoja(directorioArb, 'eu', hoja);
      editarHoja(hoja, 'eu', {
        for (final clave in [
          'nombreApp',
          'saludo',
          'personas',
          'ok',
          'multilinea',
          'ultima',
        ])
          clave: (texto: null, estado: 'revisado'),
      });

      final resultado = importarHoja(directorioArb, 'eu', hoja);

      expect(resultado.rechazadas, isEmpty);
      expect(archivoArb('eu').readAsBytesSync(), bytesAntes);
    });

    test('cambiar una cadena y deshacer el cambio deja el ARB igual', () {
      final bytesAntes = archivoArb('eu').readAsBytesSync();
      final hoja = archivoCsv('eu.csv');
      exportarHoja(directorioArb, 'eu', hoja);
      editarHoja(hoja, 'eu', {
        'personas': (
          texto: '{cantidad, plural, other{PRUEBA {cantidad}}}',
          estado: 'revisado'
        ),
      });
      importarHoja(directorioArb, 'eu', hoja);
      expect(archivoArb('eu').readAsBytesSync(), isNot(bytesAntes));

      exportarHoja(directorioArb, 'eu', hoja);
      editarHoja(hoja, 'eu', {
        'personas': (
          texto:
              '{cantidad, plural, =1{Pertsona bat} other{{cantidad} pertsona}}',
          estado: 'revisado'
        ),
      });
      importarHoja(directorioArb, 'eu', hoja);
      expect(archivoArb('eu').readAsBytesSync(), bytesAntes);
    });

    test('solo aplica las filas revisadas', () {
      final hoja = archivoCsv('eu.csv');
      exportarHoja(directorioArb, 'eu', hoja);
      editarHoja(hoja, 'eu', {
        'nombreApp': (texto: 'Kontzeju berria', estado: 'pendiente'),
        'ultima': (texto: 'Azkenekoa', estado: 'revisado'),
      });

      final resultado = importarHoja(directorioArb, 'eu', hoja);

      expect(resultado.aplicadas, ['ultima']);
      final textoNuevo = archivoArb('eu').readAsStringSync();
      expect(textoNuevo, arbEuskera.replaceFirst('"Azkena"', '"Azkenekoa"'));
    });

    test('nunca toca el ARB es', () {
      final bytesEspanol = archivoArb('es').readAsBytesSync();
      final hoja = archivoCsv('eu.csv');
      exportarHoja(directorioArb, 'eu', hoja);
      editarHoja(hoja, 'eu', {
        'ultima': (texto: 'Azkenekoa', estado: 'revisado'),
      });
      importarHoja(directorioArb, 'eu', hoja);
      expect(archivoArb('es').readAsBytesSync(), bytesEspanol);
      expect(
          () => importarHoja(directorioArb, 'es', hoja), throwsArgumentError);
    });

    test('rechaza placeholders erróneos y los lista sin aplicarlos', () {
      final hoja = archivoCsv('eu.csv');
      exportarHoja(directorioArb, 'eu', hoja);
      editarHoja(hoja, 'eu', {
        'saludo': (texto: 'Kaixo, {izena}', estado: 'revisado'),
        'personas': (texto: '{cantidad} pertsona', estado: 'revisado'),
        'nombreApp': (texto: 'Kontzejua {', estado: 'revisado'),
        'ultima': (texto: 'Azkenekoa', estado: 'revisado'),
      });

      final resultado = importarHoja(directorioArb, 'eu', hoja);

      expect(resultado.aplicadas, ['ultima']);
      expect(resultado.rechazadas.map((rechazo) => rechazo.clave),
          ['nombreApp', 'saludo', 'personas']);
      expect(resultado.rechazadas[1].motivo, contains('nombre'));
      final textoNuevo = archivoArb('eu').readAsStringSync();
      expect(textoNuevo, contains('"Kaixo, {nombre}"'));
      expect(textoNuevo, contains('"Azkenekoa"'));
    });

    test('rechaza claves desconocidas y textos vacíos', () {
      final hoja = archivoCsv('eu.csv');
      exportarHoja(directorioArb, 'eu', hoja);
      final filas = leerCsv(decodificarBytesCsv(hoja.readAsBytesSync()));
      filas.add(['inventada', 'x', 'y', 'revisado', '', '']);
      filas[1][2] = '   ';
      filas[1][3] = 'revisado';
      hoja.writeAsStringSync(escribirCsv(filas));

      final resultado = importarHoja(directorioArb, 'eu', hoja);

      expect(resultado.rechazadas.map((rechazo) => rechazo.clave),
          ['nombreApp', 'inventada']);
      expect(archivoArb('eu').readAsStringSync(), arbEuskera);
    });

    test('rechaza la fila si el español cambió desde la exportación', () {
      final hoja = archivoCsv('eu.csv');
      exportarHoja(directorioArb, 'eu', hoja);
      editarHoja(hoja, 'eu', {
        'ultima': (texto: 'Azkenekoa', estado: 'revisado'),
      });
      archivoArb('es').writeAsStringSync(
          arbEspanol.replaceFirst('"Última"', '"Última de verdad"'));

      final resultado = importarHoja(directorioArb, 'eu', hoja);

      expect(resultado.aplicadas, isEmpty);
      expect(resultado.rechazadas.single.motivo, contains('español'));
    });

    test('añade claves que faltaban en el orden del español', () {
      final hoja = archivoCsv('eu.csv');
      exportarHoja(directorioArb, 'eu', hoja);
      editarHoja(hoja, 'eu', {
        'sinTraducir': (texto: 'Hau ez dago "euskaraz"', estado: 'revisado'),
      });

      importarHoja(directorioArb, 'eu', hoja);

      expect(
        archivoArb('eu').readAsStringSync(),
        arbEuskera.replaceFirst(
          r'é",' '\n',
          r'é",' '\n' r'  "sinTraducir": "Hau ez dago \"euskaraz\"",' '\n',
        ),
      );
    });

    test('escapa saltos de línea y comillas como JSON', () {
      final hoja = archivoCsv('eu.csv');
      exportarHoja(directorioArb, 'eu', hoja);
      editarHoja(hoja, 'eu', {
        'multilinea': (texto: 'Bat\nbi "hiru"', estado: 'revisado'),
      });
      importarHoja(directorioArb, 'eu', hoja);
      expect(archivoArb('eu').readAsStringSync(),
          contains(r'"multilinea": "Bat\nbi \"hiru\"",'));
    });

    test('crea el ARB de una lengua nueva', () {
      final hoja = archivoCsv('gl.csv');
      exportarHoja(directorioArb, 'gl', hoja);
      editarHoja(hoja, 'gl', {
        'saludo': (texto: 'Ola, {nombre}', estado: 'revisado'),
        'nombreApp': (texto: 'Concello', estado: 'revisado'),
      });
      importarHoja(directorioArb, 'gl', hoja);
      expect(
        archivoArb('gl').readAsStringSync(),
        '{\n'
        '  "@@locale": "gl",\n'
        '  "nombreApp": "Concello",\n'
        '  "saludo": "Ola, {nombre}"\n'
        '}\n',
      );
    });

    test('acepta la hoja guardada por Excel con punto y coma', () {
      final hoja = archivoCsv('eu.csv');
      exportarHoja(directorioArb, 'eu', hoja);
      final filas = leerCsv(decodificarBytesCsv(hoja.readAsBytesSync()));
      filas.last[2] = 'Azkenekoa';
      filas.last[3] = 'Revisado ';
      final textoPuntoYComa = filas
          .map((fila) => fila
              .map((celda) => celda.contains(RegExp('[;"\n]'))
                  ? '"${celda.replaceAll('"', '""')}"'
                  : celda)
              .join(';'))
          .join('\r\n');
      hoja.writeAsStringSync(textoPuntoYComa);

      final resultado = importarHoja(directorioArb, 'eu', hoja);

      expect(resultado.aplicadas, ['ultima']);
    });
  });

  group('estado', () {
    test('resume total, faltan e iguales por lengua', () {
      final resumenes = resumirDirectorio(directorioArb);
      expect(resumenes.map((resumen) => resumen.lengua), ['eu']);
      final resumenEuskera = resumenes.single;
      expect(resumenEuskera.total, 7);
      expect(resumenEuskera.faltan, 1);
      expect(resumenEuskera.igualesAlEspanol, 1);
      expect(resumenEuskera.sobrantes, 1);
      expect(resumenEuskera.conErrorDeEstructura, 0);
    });
  });
}
