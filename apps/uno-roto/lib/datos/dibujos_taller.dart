import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../dominio/bestiario.dart';
import '../dominio/catalogo_distritos.dart';
import '../dominio/limpiador_dibujo.dart';
import '../dominio/minijuegos/catalogo_minijuegos.dart';
import '../dominio/personajes_taller.dart';
import 'repositorio_progreso.dart';

/// Los dibujos del niño en El taller de dibujo: una colección por tipo
/// de pieza (los monstruos del bestiario, los personajes…). [rutas]
/// tiene los del perfil activo: id → PNG local. Las pantallas lo
/// escuchan para pintar el dibujo en lugar del original.
///
/// Privacidad: los dibujos se quedan en el aparato, en la carpeta de la
/// app, y se guardan por perfil. No se suben a ningún sitio.
class ColeccionDibujos {
  /// Prefijo de la clave por perfil (`dibujo_monstruo.`…).
  final String prefijoClave;

  /// Subcarpeta dentro de `dibujos/<perfil>/`.
  final String carpeta;

  /// Los ids que pueden tener dibujo.
  final Iterable<String> Function() ids;

  final rutas = ValueNotifier<Map<String, String>>(const {});

  ColeccionDibujos({required this.prefijoClave, required this.carpeta, required this.ids});

  /// En la web no hay carpeta de la app donde guardarlos.
  static bool get disponible => !kIsWeb;

  /// Lee los dibujos del perfil activo (los que siguen existiendo).
  Future<void> cargar(RepositorioProgreso repositorio) async {
    if (!disponible) return;
    final encontrados = <String, String>{};
    for (final id in ids()) {
      final ruta = await repositorio.cargarRutaDibujo('$prefijoClave$id');
      if (ruta != null && File(ruta).existsSync()) encontrados[id] = ruta;
    }
    if (!mapEquals(encontrados, rutas.value)) rutas.value = encontrados;
  }

  /// Foto (o galería) → encuadre (si hay [encuadrar]: el niño ajusta
  /// el que propone el juego) → papel fuera → PNG en la carpeta de la
  /// app → ruta en el perfil. Devuelve la ruta nueva, o null si se
  /// canceló. Lanza [DibujoSinContenido] si en la foto no hay dibujo.
  Future<String?> elegir(
    RepositorioProgreso repositorio,
    String id, {
    required bool conCamara,
    Future<ui.Rect?> Function(Uint8List foto, ui.Rect? sugerido)? encuadrar,
  }) async {
    final elegido = await ImagePicker().pickImage(
      source: conCamara ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1400,
      maxHeight: 1400,
      imageQuality: 90,
    );
    if (elegido == null) return null;
    final foto = await elegido.readAsBytes();
    ui.Rect? recorte;
    if (encuadrar != null) {
      recorte = await encuadrar(foto, await encuadreSugerido(foto));
      if (recorte == null) return null;
    }
    final png = await limpiarDibujo(foto, recorte: recorte);
    if (png == null) throw const DibujoSinContenido();
    return guardar(repositorio, id, png);
  }

  /// Guarda un PNG ya limpio como dibujo de [id].
  Future<String> guardar(RepositorioProgreso repositorio, String id, Uint8List png) async {
    final perfil = await repositorio.idPerfilActivo();
    final destinoCarpeta =
        Directory('${(await getApplicationDocumentsDirectory()).path}/dibujos/$perfil/$carpeta');
    destinoCarpeta.createSync(recursive: true);
    final destino = File('${destinoCarpeta.path}/${id}_${DateTime.now().millisecondsSinceEpoch}.png');
    await destino.writeAsBytes(png);
    await _borrarFichero(await repositorio.cargarRutaDibujo('$prefijoClave$id'));
    await repositorio.guardarRutaDibujo('$prefijoClave$id', destino.path);
    rutas.value = {...rutas.value, id: destino.path};
    return destino.path;
  }

  /// Vuelve al original y borra el dibujo del aparato.
  Future<void> quitar(RepositorioProgreso repositorio, String id) async {
    await _borrarFichero(await repositorio.cargarRutaDibujo('$prefijoClave$id'));
    await repositorio.borrarRutaDibujo('$prefijoClave$id');
    rutas.value = {...rutas.value}..remove(id);
  }

  static Future<void> _borrarFichero(String? ruta) async {
    if (ruta == null) return;
    final fichero = File(ruta);
    if (fichero.existsSync()) await fichero.delete();
  }
}

/// Las familias del bestiario (fase 1 del taller).
final dibujosMonstruos = ColeccionDibujos(
  prefijoClave: 'dibujo_monstruo.',
  carpeta: 'monstruos',
  ids: () => [for (final ficha in CatalogoBestiario.todas) ficha.id],
);

/// Los personajes (fase 2 del taller).
final dibujosPersonajes = ColeccionDibujos(
  prefijoClave: 'dibujo_personaje.',
  carpeta: 'personajes',
  ids: () => [for (final personaje in personajesDelTaller) personaje.id],
);

/// Los paisajes de los distritos (fase 3 del taller).
final dibujosDistritos = ColeccionDibujos(
  prefijoClave: 'dibujo_distrito.',
  carpeta: 'distritos',
  ids: () => [for (final distrito in CatalogoDistritos.todos) distrito.identificador],
);

/// Los armarios de las máquinas de Rexán (fase 3 del taller).
final dibujosMaquinas = ColeccionDibujos(
  prefijoClave: 'dibujo_maquina.',
  carpeta: 'maquinas',
  ids: () => [for (final maquina in CatalogoMinijuegos.todos) maquina.id.name],
);

/// Todas las colecciones, para la pared de Rexán (fase 4).
List<ColeccionDibujos> get coleccionesDelTaller =>
    [dibujosMonstruos, dibujosPersonajes, dibujosDistritos, dibujosMaquinas];

/// Carga todas las colecciones del perfil activo.
Future<void> cargarDibujosDelTaller(RepositorioProgreso repositorio) async {
  for (final coleccion in coleccionesDelTaller) {
    await coleccion.cargar(repositorio);
  }
}

/// La foto no tenía nada dibujado (o no se distinguía del papel).
class DibujoSinContenido implements Exception {
  const DibujoSinContenido();
}
