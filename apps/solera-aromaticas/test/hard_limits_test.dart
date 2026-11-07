// Guardarraíl del hard limit de Larrea Aromáticas: **ninguna propiedad
// medicinal ni terapéutica** en ningún texto que la app pueda mostrar,
// imprimir o mandar a la IA (catálogos, traducciones y código).
//
// Busca vocabulario de propiedades de salud. Si salta, no se añade una
// excepción: se reescribe el texto.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Raíces de palabras que solo aparecen al atribuir propiedades de salud.
const List<String> vocabularioProhibido = [
  'terapéut',
  'terapeut',
  'curativ',
  'cicatriz',
  'antiinflam',
  'antisépt',
  'antisept',
  'antibacter',
  'antimicrob',
  'antivír',
  'antivir',
  'antioxid',
  'analgés',
  'analges',
  'sedante',
  'calmante',
  'relajante',
  'digestiv',
  'expectorante',
  'diurétic',
  'diuretic',
  'depurativ',
  'remedio',
  'propiedades medicinales',
  'beneficios para la salud',
  'bueno para',
  'alivia',
  'sanar',
  'indicaciones',
  // eu / ca / gl (borradores)
  'sendagarri',
  'terapèut',
  'curatiu',
  'calmant',
];

List<File> _ficherosRevisados() {
  final raizApp = Directory.current.path;
  final raizRepo = Directory('$raizApp/../..').absolute.path;
  return [
    ...Directory('$raizApp/lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((fichero) => fichero.path.endsWith('.dart')),
    ...Directory('$raizRepo/content/aromaticas')
        .listSync()
        .whereType<File>()
        .where((fichero) => fichero.path.endsWith('.csv')),
    File('$raizRepo/content/solera/traducciones/aromaticas.csv'),
  ];
}

void main() {
  test('ningún texto atribuye propiedades medicinales ni terapéuticas', () {
    final ficheros = _ficherosRevisados();
    expect(ficheros.length, greaterThan(5));
    final hallazgos = <String>[];
    for (final fichero in ficheros) {
      final lineas = fichero.readAsLinesSync();
      for (var numero = 0; numero < lineas.length; numero++) {
        final linea = lineas[numero].toLowerCase();
        for (final palabra in vocabularioProhibido) {
          if (linea.contains(palabra)) {
            hallazgos.add('${fichero.path}:${numero + 1} «$palabra»');
          }
        }
      }
    }
    expect(hallazgos, isEmpty);
  });

  test('no existe el destino «medicamento» en los textos de la app', () {
    final traducciones = File(
            '${Directory.current.path}/../../content/solera/traducciones/aromaticas.csv')
        .readAsLinesSync();
    expect(
        traducciones.where((linea) => linea.startsWith('arom.destino_medic')),
        isEmpty);
  });
}
