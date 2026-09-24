import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../dominio/bestiario.dart';
import '../dominio/limpiador_dibujo.dart';
import 'repositorio_progreso.dart';

/// Los dibujos del niño para las familias del bestiario (El taller de
/// dibujo). [rutas] tiene los del perfil activo: idFamilia → PNG local.
/// Las máquinas lo escuchan para pintar el monstruo con el dibujo.
///
/// Privacidad: los dibujos se quedan en el aparato, en la carpeta de la
/// app, y se guardan por perfil. No se suben a ningún sitio.
class DibujosMonstruos {
  DibujosMonstruos._();

  static final rutas = ValueNotifier<Map<String, String>>(const {});

  /// En la web no hay carpeta de la app donde guardarlos.
  static bool get disponible => !kIsWeb;

  /// Lee los dibujos del perfil activo (los que siguen existiendo).
  static Future<void> cargar(RepositorioProgreso repositorio) async {
    if (!disponible) return;
    final encontrados = <String, String>{};
    for (final ficha in CatalogoBestiario.todas) {
      final ruta = await repositorio.cargarRutaDibujoMonstruo(ficha.id);
      if (ruta != null && File(ruta).existsSync()) encontrados[ficha.id] = ruta;
    }
    if (!mapEquals(encontrados, rutas.value)) rutas.value = encontrados;
  }

  /// Foto (o galería) → papel fuera → PNG en la carpeta de la app →
  /// ruta en el perfil. Devuelve la ruta nueva, o null si se canceló o
  /// no salió dibujo. [limpiar] se sustituye en los tests.
  static Future<String?> elegir(
    RepositorioProgreso repositorio,
    String idFamilia, {
    required bool conCamara,
    Future<Uint8List?> Function(Uint8List bytes) limpiar = limpiarDibujo,
  }) async {
    final elegido = await ImagePicker().pickImage(
      source: conCamara ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1400,
      maxHeight: 1400,
      imageQuality: 90,
    );
    if (elegido == null) return null;
    final png = await limpiar(await elegido.readAsBytes());
    if (png == null) throw const DibujoSinContenido();
    return guardar(repositorio, idFamilia, png);
  }

  /// Guarda un PNG ya limpio como dibujo de [idFamilia].
  static Future<String> guardar(RepositorioProgreso repositorio, String idFamilia, Uint8List png) async {
    final perfil = await repositorio.idPerfilActivo();
    final carpeta = Directory('${(await getApplicationDocumentsDirectory()).path}/dibujos/$perfil');
    carpeta.createSync(recursive: true);
    final destino = File('${carpeta.path}/${idFamilia}_${DateTime.now().millisecondsSinceEpoch}.png');
    await destino.writeAsBytes(png);
    await _borrarFichero(await repositorio.cargarRutaDibujoMonstruo(idFamilia));
    await repositorio.guardarRutaDibujoMonstruo(idFamilia, destino.path);
    rutas.value = {...rutas.value, idFamilia: destino.path};
    return destino.path;
  }

  /// Vuelve al monstruo original y borra el dibujo del aparato.
  static Future<void> quitar(RepositorioProgreso repositorio, String idFamilia) async {
    await _borrarFichero(await repositorio.cargarRutaDibujoMonstruo(idFamilia));
    await repositorio.borrarRutaDibujoMonstruo(idFamilia);
    rutas.value = {...rutas.value}..remove(idFamilia);
  }

  static Future<void> _borrarFichero(String? ruta) async {
    if (ruta == null) return;
    final fichero = File(ruta);
    if (fichero.existsSync()) await fichero.delete();
  }
}

/// La foto no tenía nada dibujado (o no se distinguía del papel).
class DibujoSinContenido implements Exception {
  const DibujoSinContenido();
}
