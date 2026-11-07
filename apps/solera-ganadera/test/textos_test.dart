// El test de i18n del core no recorre esta app: este comprueba que toda
// clave `gana.*` escrita en lib/ existe, y que cada código de los catálogos
// tiene su nombre visible.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_ganadera/modelos/apunte_economico.dart';
import 'package:solera_ganadera/modelos/ganado.dart';
import 'package:solera_ganadera/modelos/ganado_ecologico.dart';
import 'package:solera_ganadera/modelos/pieza_pasto.dart';
import 'package:solera_ganadera/modelos/tarea_sanitaria.dart';

void main() {
  test('todas las claves gana.* usadas en lib/ existen', () {
    final usadas = <String, String>{};
    final patron = RegExp(r"'(gana\.[a-z0-9_]+)'");
    for (final fichero in Directory('lib').listSync(recursive: true)) {
      if (fichero is! File || !fichero.path.endsWith('.dart')) continue;
      for (final coincidencia
          in patron.allMatches(fichero.readAsStringSync())) {
        usadas.putIfAbsent(coincidencia.group(1)!, () => fichero.path);
      }
    }
    final faltan = {
      for (final MapEntry(key: clave, value: ruta) in usadas.entries)
        if (!SoleraL10n.clavesDisponibles.contains(clave)) clave: ruta
    };
    expect(faltan, isEmpty);
  });

  test('cada código de catálogo tiene nombre visible', () {
    final grupos = {
      'especie': especiesGanado,
      'sexo': sexosAnimal,
      'estado': estadosAnimal,
      'dispositivo': dispositivosIdentificacion,
      'movimiento': tiposMovimientoGanado,
      'evento': tiposEventoGanado,
      'clase': clasesMedicamento,
      'pasto': tiposPasto,
      'titularidad': titularidadesPieza,
      'tarea': tiposTareaSanitaria,
      'categoria': [...categoriasIngreso, ...categoriasGasto],
    };
    final faltan = [
      for (final MapEntry(key: grupo, value: codigos) in grupos.entries)
        for (final codigo in codigos)
          if (!SoleraL10n.clavesDisponibles.contains('gana.${grupo}_$codigo'))
            'gana.${grupo}_$codigo'
    ];
    expect(faltan, isEmpty);
  });
}
