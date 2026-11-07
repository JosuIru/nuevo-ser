import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

const _cabecera = 'identificador,verticales,nombre_visible,norma_citada,'
    'url_fuente,periodicidad,dia_inicio,mes_inicio,dia_fin,mes_fin,'
    'dia_limite,dia_limite_cuarto_trimestre,antelacion_aviso_dias,nota';

/// Ruta del CSV real, relativa al directorio del paquete (donde corre
/// `flutter test`).
const _rutaCsvReal = '../../content/solera/plazos.csv';

void main() {
  group('parsearPlazosCsv', () {
    test('ignora comentarios y líneas en blanco', () {
      final plazos = parsearPlazosCsv('''
# Comentario de cabecera con fuente
#   y otra línea, con comas
$_cabecera

pac,agro|viticultura,Solicitud única,RD 1048/2022 art. 108.2,https://www.boe.es/x,anual,1,2,30,4,,,15,"Nota, con coma"
''');
      expect(plazos, hasLength(1));
      final pac = plazos.single;
      expect(pac.identificador, 'pac');
      expect(pac.verticales, ['agro', 'viticultura']);
      expect(pac.nombreVisible, 'Solicitud única');
      expect(pac.normaCitada, 'RD 1048/2022 art. 108.2');
      expect(pac.urlFuente, 'https://www.boe.es/x');
      expect(pac.antelacionAvisoDias, 15);
      expect(pac.nota, 'Nota, con coma');
      final periodicidad = pac.periodicidad as PeriodicidadAnual;
      expect(periodicidad.diaInicio, 1);
      expect(periodicidad.mesInicio, 2);
      expect(periodicidad.diaFin, 30);
      expect(periodicidad.mesFin, 4);
    });

    test('anual sin inicio usa el día límite como inicio', () {
      final plazos = parsearPlazosCsv('$_cabecera\n'
          'cosecha,viticultura,Cosecha,RD 739/2015,https://www.boe.es/x,'
          'anual,,,10,12,,,30,');
      final periodicidad = plazos.single.periodicidad as PeriodicidadAnual;
      expect(periodicidad.diaInicio, 10);
      expect(periodicidad.mesInicio, 12);
      expect(plazos.single.nota, isEmpty);
    });

    test('mensual y trimestral', () {
      final plazos = parsearPlazosCsv('$_cabecera\n'
          'aica,aceitera,AICA,RD 861/2018,https://www.boe.es/x,mensual,,,,,10,,5,\n'
          'iva,quesera,IVA,RD 1624/1992,https://www.boe.es/x,trimestral,,,,,20,30,10,');
      expect((plazos[0].periodicidad as PeriodicidadMensual).diaLimite, 10);
      final trimestral = plazos[1].periodicidad as PeriodicidadTrimestral;
      expect(trimestral.diaLimite, 20);
      expect(trimestral.diaLimiteCuartoTrimestre, 30);
    });

    test('antelación vacía vale 0', () {
      final plazos = parsearPlazosCsv('$_cabecera\n'
          'aica,aceitera,AICA,RD,https://www.boe.es/x,mensual,,,,,10,,,');
      expect(plazos.single.antelacionAvisoDias, 0);
    });

    test('vertical desconocida es un error de datos', () {
      expect(
          () => parsearPlazosCsv('$_cabecera\n'
              'x,pesca,X,RD,https://www.boe.es/x,mensual,,,,,10,,0,'),
          throwsFormatException);
    });

    test('periodicidad desconocida es un error de datos', () {
      expect(
          () => parsearPlazosCsv('$_cabecera\n'
              'x,agro,X,RD,https://www.boe.es/x,semanal,,,,,10,,0,'),
          throwsFormatException);
    });

    test('fecha imposible es un error de datos', () {
      expect(
          () => parsearPlazosCsv('$_cabecera\n'
              'x,agro,X,RD,https://www.boe.es/x,anual,1,1,31,4,,,0,'),
          throwsFormatException);
      expect(
          () => parsearPlazosCsv('$_cabecera\n'
              'x,agro,X,RD,https://www.boe.es/x,mensual,,,,,32,,0,'),
          throwsFormatException);
    });

    test('url_fuente es obligatoria y debe ser https', () {
      expect(
          () => parsearPlazosCsv('$_cabecera\n'
              'x,agro,X,RD,,mensual,,,,,10,,0,'),
          throwsFormatException);
      expect(
          () => parsearPlazosCsv('$_cabecera\n'
              'x,agro,X,RD,http://www.boe.es/x,mensual,,,,,10,,0,'),
          throwsFormatException);
    });

    test('identificador repetido es un error de datos', () {
      expect(
          () => parsearPlazosCsv('$_cabecera\n'
              'x,agro,X,RD,https://www.boe.es/x,mensual,,,,,10,,0,\n'
              'x,agro,X,RD,https://www.boe.es/x,mensual,,,,,10,,0,'),
          throwsFormatException);
    });

    test('falta una columna obligatoria en la cabecera', () {
      expect(() => parsearPlazosCsv('identificador,verticales\nx,agro'),
          throwsFormatException);
    });
  });

  group('content/solera/plazos.csv', () {
    final contenido = File(_rutaCsvReal).readAsStringSync();

    test('lleva el sello PROVISIONAL en la cabecera', () {
      final cabeceraComentada = contenido
          .split('\n')
          .takeWhile((linea) => linea.startsWith('#'))
          .join('\n');
      expect(cabeceraComentada, contains('PROVISIONAL'));
      expect(cabeceraComentada, contains('pendiente de revisión por asesor'));
    });

    test('se parsea entero y cada plazo cita norma y fuente oficial', () {
      final plazos = parsearPlazosCsv(contenido);
      expect(plazos, isNotEmpty);
      for (final plazo in plazos) {
        expect(plazo.normaCitada, isNotEmpty, reason: plazo.identificador);
        expect(Uri.parse(plazo.urlFuente).host,
            anyOf('www.boe.es', 'sede.agenciatributaria.gob.es'),
            reason: plazo.identificador);
      }
    });

    test('cada vertical de la suite tiene al menos un plazo', () {
      final plazos = parsearPlazosCsv(contenido);
      for (final vertical in verticalesLarrea) {
        expect(plazosDeVertical(plazos, vertical), isNotEmpty,
            reason: vertical);
      }
    });
  });
}
