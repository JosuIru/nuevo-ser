import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../../tool/compilar_traducciones_solera.dart';

/// Carpetas cuyo código usa `SoleraL10n.t('…')`: las seis apps Larrea y el
/// core. (Zunbeltz tiene su propio sistema de idioma.)
const carpetasConTextosSolera = [
  '../../apps/agro/lib',
  '../../apps/solera-viticultura/lib',
  '../../apps/solera-apicola/lib',
  '../../apps/solera-arbolado-urbano/lib',
  '../../apps/solera-quesera/lib',
  '../../apps/solera-aceitera/lib',
  'lib',
];

final _llamadaConClave = RegExp(r"SoleraL10n\.tf?\(\s*'([^']*)'");

Map<String, String> _clavesUsadas() {
  final primeraAparicion = <String, String>{};
  for (final carpeta in carpetasConTextosSolera) {
    final directorio = Directory(carpeta);
    if (!directorio.existsSync()) continue;
    for (final entidad in directorio.listSync(recursive: true)) {
      if (entidad is! File || !entidad.path.endsWith('.dart')) continue;
      final lineas = entidad.readAsLinesSync();
      for (var numero = 0; numero < lineas.length; numero++) {
        for (final coincidencia in _llamadaConClave.allMatches(lineas[numero])) {
          primeraAparicion.putIfAbsent(
              coincidencia.group(1)!, () => '${entidad.path}:${numero + 1}');
        }
      }
    }
  }
  return primeraAparicion;
}

void main() {
  tearDown(() => SoleraL10n.idioma = 'es');

  test('solera_l10n.dart está al día con content/solera/traducciones.csv', () {
    final csv = leerCsvsDeTraducciones();
    final generado = File(rutaSalida).readAsStringSync();
    expect(generado, generarCodigoSoleraL10n(csv),
        reason: 'Ejecuta: dart run tool/compilar_traducciones_solera.dart');
  });

  test('ninguna clave lleva «\$» (Dart la interpolaría y no se encontraría)', () {
    final conDolar = _clavesUsadas().entries.where((e) => e.key.contains(r'$'));
    expect({for (final e in conDolar) e.key: e.value}, isEmpty);
  });

  test('todas las claves usadas existen (si no, se vería la clave en bruto)', () {
    final faltan = {
      for (final e in _clavesUsadas().entries)
        if (!SoleraL10n.clavesDisponibles.contains(e.key)) e.key: e.value,
    };
    expect(faltan, isEmpty, reason: 'Añádelas a content/solera/traducciones.csv');
  });

  for (final idioma in ['eu', 'ca', 'gl']) {
    test('todas las claves usadas tienen texto en $idioma', () {
      final traducidas = SoleraL10n.clavesTraducidas(idioma);
      final faltan = {
        for (final e in _clavesUsadas().entries)
          if (!traducidas.contains(e.key)) e.key: e.value,
      };
      expect(faltan, isEmpty);
    });
  }

  test('sin traducción en un idioma sale el castellano, no la clave', () {
    final generado = generarCodigoSoleraL10n(
        'clave,es,eu,ca,gl\nsolo_es,Solo en castellano,,,\n');
    expect(generado, contains('default: return _tEs(c);'));
    expect(SoleraL10n.t('guardar', idioma: 'eu'), 'Gorde');
    expect(SoleraL10n.t('no_existe_en_euskera_xyz', idioma: 'eu'),
        SoleraL10n.t('no_existe_en_euskera_xyz', idioma: 'es'));
  });

  test('tf sustituye los marcadores en cualquier idioma', () {
    final generado = generarCodigoSoleraL10n(
        'clave,es,eu,ca,gl\ncolmenas_n,{n} colmenas,{n} erlauntz,{n} ruscs,{n} colmeas\n');
    expect(generado, contains("static String tf("));
    expect(SoleraL10n.tf('clave_inexistente_{n}', {'n': 3}), 'clave_inexistente_3');
  });

  test('los marcadores coinciden en los cuatro idiomas', () {
    final marcador = RegExp(r'\{(\w+)\}');
    Set<String> marcadores(String texto) =>
        marcador.allMatches(texto).map((m) => m.group(1)!).toSet();
    final distintos = <String>[];
    for (final clave in SoleraL10n.clavesDisponibles) {
      final enCastellano = marcadores(SoleraL10n.t(clave, idioma: 'es'));
      for (final idioma in ['eu', 'ca', 'gl']) {
        final enIdioma = marcadores(SoleraL10n.t(clave, idioma: idioma));
        if (!setEquals(enCastellano, enIdioma)) distintos.add('$clave ($idioma)');
      }
    }
    expect(distintos, isEmpty);
  });

  test('el CSV rechaza claves con «\$», repetidas o sin castellano', () {
    expect(() => generarCodigoSoleraL10n('clave,es,eu,ca,gl\nerror_\$e,Error,,,\n'),
        throwsFormatException);
    expect(() => generarCodigoSoleraL10n('clave,es,eu,ca,gl\na,A,,,\na,B,,,\n'),
        throwsFormatException);
    expect(() => generarCodigoSoleraL10n('clave,es,eu,ca,gl\na,,A,,\n'),
        throwsFormatException);
  });
}
