import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';

/// Gestiona las fotos asociadas a entidades y eventos del usuario
/// (cosechas, observaciones, incidencias, tratamientos, avatares…).
/// Las fotos viven bajo el directorio de documentos de la app
/// (`<documents>/fotos/<año-mes>/<timestamp>.jpg`) para que sobrevivan
/// a actualizaciones de la app pero no compartan directorio público
/// con otras apps. La capa de persistencia de cada juego guarda sólo
/// la ruta como string (típicamente en un campo `rutas_fotos_json`).
///
/// El año/mes en la ruta evita tener miles de ficheros en una única
/// carpeta — ralentiza listados del filesystem en algunos Android
/// antiguos a partir de ~5.000 entradas y complica el backup.
///
/// Extraído de `apps/agro` para uso compartido por la suite Larrea
/// (agro, viticultura, apícola, arbolado) y otras apps del monorepo.
class GestorFotos {
  static final _picker = ImagePicker();

  /// Permite al usuario seleccionar una o varias fotos (cámara o
  /// galería) y las copia al almacenamiento permanente de la app.
  /// Devuelve las rutas absolutas de las fotos guardadas.
  ///
  /// `permitirVarias` activa multi-pick si el origen es galería.
  /// La cámara siempre devuelve una sola foto.
  static Future<List<String>> tomarOSeleccionar({
    required FuenteFoto fuente,
    bool permitirVarias = true,
  }) async {
    final List<XFile> seleccionadas;
    if (fuente == FuenteFoto.camara) {
      final foto = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      seleccionadas = foto != null ? [foto] : const <XFile>[];
    } else {
      seleccionadas = permitirVarias
          ? await _picker.pickMultiImage(imageQuality: 85)
          : await _picker
              .pickImage(source: ImageSource.gallery, imageQuality: 85)
              .then((f) => f != null ? <XFile>[f] : const <XFile>[]);
    }
    if (seleccionadas.isEmpty) return [];
    return _copiarADocuments(seleccionadas);
  }

  static Future<List<String>> _copiarADocuments(List<XFile> seleccionadas) async {
    final docs = await getApplicationDocumentsDirectory();
    final ahora = DateTime.now();
    final subdir = Directory(path_lib.join(
      docs.path,
      'fotos',
      '${ahora.year.toString().padLeft(4, '0')}-${ahora.month.toString().padLeft(2, '0')}',
    ));
    if (!await subdir.exists()) {
      await subdir.create(recursive: true);
    }
    final rutas = <String>[];
    for (final origen in seleccionadas) {
      final extension = path_lib.extension(origen.path).isEmpty ? '.jpg' : path_lib.extension(origen.path);
      final destino = path_lib.join(subdir.path, '${DateTime.now().microsecondsSinceEpoch}$extension');
      await File(origen.path).copy(destino);
      rutas.add(destino);
    }
    return rutas;
  }

  /// Borra una foto del filesystem si existe. Idempotente; los fallos
  /// se ignoran porque "limpiar una foto" nunca debe bloquear al
  /// usuario (la fila de la BD ya se borró antes).
  static Future<void> borrarSiExiste(String ruta) async {
    try {
      final f = File(ruta);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  /// Codifica una lista de rutas como JSON para persistir en el campo
  /// `rutas_fotos_json` de los modelos de eventos. Lista vacía → '[]'.
  static String codificar(List<String> rutas) => jsonEncode(rutas);

  /// Decodifica `rutas_fotos_json`. Auto-curación si el JSON está
  /// corrupto: devuelve lista vacía en lugar de propagar el error.
  /// Patrón heredado del monorepo (los repos del core usan la misma
  /// política): nunca tirar la app por un dato corrupto, sólo perder
  /// las miniaturas de ese evento concreto.
  static List<String> decodificar(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return const [];
      return decoded.whereType<String>().toList();
    } catch (_) {
      return const [];
    }
  }
}

enum FuenteFoto { camara, galeria }
