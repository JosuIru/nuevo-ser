import 'dart:ui' as ui;

import 'package:flutter/services.dart';

/// Escenarios ilustrados de los distritos (`arte/escenarios/`, renders de
/// flavor3d con fondo transparente). Dos versiones por distrito: `off`
/// (pocas ventanas) y `on` (muchas), que el pintor funde según el
/// progreso. Se cargan una vez y quedan en memoria; mientras no están,
/// el escenario se pinta como siempre (montaña y base por código).
class EscenariosIlustrados {
  static final Map<String, ui.Image> _cargadas = {};
  static final Map<String, Future<void>> _enCurso = {};

  static ui.Image? apagado(String idDistrito) => _cargadas['${idDistrito}_off'];
  static ui.Image? encendido(String idDistrito) => _cargadas['${idDistrito}_on'];

  /// Tejados se queda siempre (es el fondo por defecto de los puzzles);
  /// de los demás, sólo el último distrito cargado. Cada imagen
  /// decodificada ocupa ~5 MB: los siete por duplicado serían ~70 MB.
  static const _siempre = 'tejados';

  static Future<void> cargar(String idDistrito) {
    for (final otro in _enCurso.keys.toList()) {
      if (otro == idDistrito || otro == _siempre) continue;
      _enCurso.remove(otro);
      for (final version in ['off', 'on']) {
        _cargadas.remove('${otro}_$version')?.dispose();
      }
    }
    return _enCurso.putIfAbsent(idDistrito, () async {
        for (final version in ['off', 'on']) {
          final clave = '${idDistrito}_$version';
          try {
            final datos = await rootBundle.load('assets/escenarios/$clave.webp');
            final codec =
                await ui.instantiateImageCodec(datos.buffer.asUint8List());
            _cargadas[clave] = (await codec.getNextFrame()).image;
          } catch (_) {
            // Sin ilustración: el pintor usa su versión por código.
          }
        }
      });
  }
}
