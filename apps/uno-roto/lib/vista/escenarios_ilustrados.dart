import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../datos/dibujos_taller.dart';

/// Escenarios ilustrados de los distritos (`arte/escenarios/`, renders de
/// flavor3d con fondo transparente). Dos versiones por distrito: `off`
/// (pocas ventanas) y `on` (muchas), que el pintor funde según el
/// progreso. Se cargan una vez y quedan en memoria; mientras no están,
/// el escenario se pinta como siempre (montaña y base por código).
///
/// Si el niño ha dibujado el distrito (El taller de dibujo), su dibujo
/// hace de versión `on` y el mismo dibujo oscurecido, de `off`: la ciudad
/// se sigue encendiendo con el progreso. Al cambiar el dibujo se recarga.
class EscenariosIlustrados {
  static final Map<String, ui.Image> _cargadas = {};
  static final Map<String, Future<void>> _enCurso = {};

  static ui.Image? apagado(String idDistrito) => _cargadas['${idDistrito}_off'];
  static ui.Image? encendido(String idDistrito) => _cargadas['${idDistrito}_on'];

  /// Tejados se queda siempre (es el fondo por defecto de los puzzles);
  /// de los demás, sólo el último distrito cargado. Cada imagen
  /// decodificada ocupa ~5 MB: los siete por duplicado serían ~70 MB.
  static const _siempre = 'tejados';

  /// Distritos cuyo escenario viene de un dibujo del niño.
  static final Set<String> _deDibujo = {};
  static bool _escuchando = false;

  static bool esDibujo(String idDistrito) => _deDibujo.contains(idDistrito);

  /// Al cambiar un dibujo de distrito, se olvida lo cargado de ese
  /// distrito para que la próxima carga use el nuevo (o el original).
  static void _escucharDibujos() {
    if (_escuchando) return;
    _escuchando = true;
    var anteriores = Map.of(dibujosDistritos.rutas.value);
    dibujosDistritos.rutas.addListener(() {
      final actuales = dibujosDistritos.rutas.value;
      for (final id in {...anteriores.keys, ...actuales.keys}) {
        if (anteriores[id] == actuales[id]) continue;
        _enCurso.remove(id);
        _deDibujo.remove(id);
        for (final version in ['off', 'on']) {
          _cargadas.remove('${id}_$version')?.dispose();
        }
        cargar(id);
      }
      anteriores = Map.of(actuales);
    });
  }

  static Future<void> cargar(String idDistrito) {
    _escucharDibujos();
    for (final otro in _enCurso.keys.toList()) {
      if (otro == idDistrito || otro == _siempre) continue;
      _enCurso.remove(otro);
      for (final version in ['off', 'on']) {
        _cargadas.remove('${otro}_$version')?.dispose();
      }
    }
    return _enCurso.putIfAbsent(idDistrito, () async {
        final dibujo = dibujosDistritos.rutas.value[idDistrito];
        if (dibujo != null) {
          try {
            final codec = await ui.instantiateImageCodec(await File(dibujo).readAsBytes());
            final encendido = (await codec.getNextFrame()).image;
            _cargadas['${idDistrito}_on'] = encendido;
            _cargadas['${idDistrito}_off'] = await _apagar(encendido);
            _deDibujo.add(idDistrito);
            return;
          } catch (_) {
            // Dibujo ilegible: el original.
          }
        }
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

  /// El dibujo de noche: oscuro y azulado, como la ciudad sin restaurar.
  static Future<ui.Image> _apagar(ui.Image imagen) async {
    final grabador = ui.PictureRecorder();
    ui.Canvas(grabador).drawImage(
      imagen,
      ui.Offset.zero,
      ui.Paint()
        ..colorFilter = const ui.ColorFilter.matrix([
          0.22, 0, 0, 0, 8, //
          0, 0.24, 0, 0, 10, //
          0, 0, 0.38, 0, 26, //
          0, 0, 0, 1, 0,
        ]),
    );
    return grabador.endRecording().toImage(imagen.width, imagen.height);
  }
}
