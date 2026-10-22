// El plugin corrige en el servidor las zonas y puntos sembrados que nadie ha
// tocado (wp-plugin/solera-zunbeltz-sync/includes/espacio-sembrado.php):
// renombres, contornos nuevos, lo que se añade y lo que se retira. Lo que
// lleva ese fichero sale de la propia siembra de la app, en el formato en
// que la app lo sube, así que no puede diferir.
//
// Este test falla si el fichero no está al día. Para regenerarlo:
//
//   GENERAR_ESPACIO_PHP=1 flutter test test/espacio_sembrado_php_test.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/datos/esquema_sincronizable.dart';

import 'bd_en_memoria.dart';

const _rutaPhp =
    '../../wp-plugin/solera-zunbeltz-sync/includes/espacio-sembrado.php';
const _tiposCorregibles = {'zona', 'punto'};

/// Lo retirado (content/espacio/retirados.csv) como `tipo` + `uid`.
List<Map<String, String>> _retirados() {
  final lineas = File('content/espacio/retirados.csv')
      .readAsLinesSync()
      .where((linea) => linea.trim().isNotEmpty && !linea.startsWith('#'))
      .skip(1);
  return [
    for (final linea in lineas)
      if (linea.split(';') case [final tipo, final finca, final nombre])
        {'tipo': tipo, 'uid': uidSembrado(tipo, '$finca $nombre')},
  ];
}

Future<String> _phpEsperado() async {
  final bd = await abrirBdEnMemoria();
  await bd.sembrarEspacioRealSiVacia();
  final entidades = [
    for (final entidad in await bd.entidadesPendientesDeSubir(0))
      if (_tiposCorregibles.contains(entidad['tipo']))
        {
          'tipo': entidad['tipo'],
          'uid': entidad['uid'],
          // La fecha de alta es la de cada siembra: se conserva la del
          // servidor. Lo sembrado no trae fotos: las que se pongan después
          // son de quien las pone, y no hay que tocarlas.
          'datos': Map.of(entidad['datos'] as Map<String, Object?>)
            ..remove('fecha_creacion_ms')
            ..remove('fotos'),
        },
  ];
  final retirados = _retirados();
  final uidsSembrados = {for (final e in entidades) e['uid']};
  for (final retirado in retirados) {
    if (uidsSembrados.contains(retirado['uid'])) {
      throw StateError('${retirado['uid']} está sembrado y retirado a la vez');
    }
  }
  final json = const JsonEncoder.withIndent('\t')
      .convert({'entidades': entidades, 'retiradas': retirados});
  return '''<?php
/**
 * GENERADO por apps/solera-zunbeltz/test/espacio_sembrado_php_test.dart
 * (GENERAR_ESPACIO_PHP=1) a partir de content/espacio/*.csv — NO editar a
 * mano.
 *
 * Las zonas y puntos que siembra la app, tal como los sube, y los que
 * sembró antes y ya no. Ver szs_actualizar_espacio_sembrado().
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

function szs_espacio_sembrado_json(): string {
	return <<<'JSON'
$json
JSON;
}
''';
}

void main() {
  test('el fichero del plugin con lo sembrado está al día', () async {
    final esperado = await _phpEsperado();
    final fichero = File(_rutaPhp);
    if (Platform.environment['GENERAR_ESPACIO_PHP'] == '1') {
      fichero.writeAsStringSync(esperado);
    }
    expect(fichero.readAsStringSync(), esperado,
        reason: 'Regenerar: GENERAR_ESPACIO_PHP=1 flutter test '
            'test/espacio_sembrado_php_test.dart');
  });

  test('lo retirado no se confunde con lo sembrado', () async {
    final bd = await abrirBdEnMemoria();
    await bd.sembrarEspacioRealSiVacia();
    final db = await bd.basedatos;
    final uids = {
      for (final tabla in ['zonas_finca', 'puntos_infraestructura'])
        for (final fila in await db.query(tabla, columns: ['uid'])) fila['uid'],
    };
    expect(_retirados(), isNotEmpty);
    for (final retirado in _retirados()) {
      expect(uids, isNot(contains(retirado['uid'])));
    }
    expect(BaseDatosSoleraZunbeltz.marcaSembrado, 1,
        reason: 'el plugin da por intacto lo que tiene actualizado_ms 1');
  });
}
