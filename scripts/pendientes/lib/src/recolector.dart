import 'dart:io';

import 'clasificador_responsables.dart';
import 'lector_bloqueos.dart';
import 'lector_catalogos.dart';

/// Un archivo de `lib/` que contiene el literal `'PROVISIONAL` (sello en
/// cabecera de PDF u otra salida que espera validación humana).
class SelloProvisional {
  SelloProvisional({
    required this.aplicacion,
    required this.ruta,
    required this.lineasConSello,
    required this.protegidoPorTest,
  }) : responsables = clasificarResponsables([
          ruta.split('/').last.replaceAll('_', ' ').replaceAll('.dart', ''),
          ...lineasConSello,
        ].join('\n'));

  final String aplicacion;
  final String ruta;

  /// Las líneas de código (no comentarios) donde aparece el literal.
  final List<String> lineasConSello;

  /// Algún `test/sello_provisional_test.dart` de la app lo menciona.
  final bool protegidoPorTest;
  final List<Responsable> responsables;
}

class FlagCatalogos {
  FlagCatalogos(this.aplicacion, this.ruta, this.revisados);

  final String aplicacion;
  final String ruta;
  final bool? revisados;
}

/// Todo lo pendiente del monorepo, leído de disco en un momento dado.
class Inventario {
  Inventario({
    required this.raiz,
    required this.generadoEn,
    required this.bloqueos,
    required this.sellos,
    required this.catalogos,
    required this.flags,
  });

  final String raiz;
  final DateTime generadoEn;
  final List<Bloqueo> bloqueos;
  final List<SelloProvisional> sellos;
  final List<EstadoCatalogo> catalogos;
  final List<FlagCatalogos> flags;

  List<Bloqueo> get bloqueosAbiertos =>
      bloqueos.where((bloqueo) => !bloqueo.resuelto).toList();

  /// Bloqueos abiertos agrupados por responsable (uno puede estar en varios).
  Map<Responsable, List<Bloqueo>> get abiertosPorResponsable {
    final agrupados = <Responsable, List<Bloqueo>>{};
    for (final bloqueo in bloqueosAbiertos) {
      for (final responsable in bloqueo.responsables) {
        agrupados.putIfAbsent(responsable, () => []).add(bloqueo);
      }
    }
    final ordenados = agrupados.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    return Map.fromEntries(ordenados);
  }
}

/// Carpetas con apps: `apps/*` y `social/apps/*`.
const List<String> _carpetasDeApps = ['apps', 'social/apps'];

/// Recorre el monorepo en [raiz] y devuelve el inventario.
Inventario recolectar(String raiz, {DateTime? ahora}) {
  final bloqueos = <Bloqueo>[];
  final sellos = <SelloProvisional>[];
  final flags = <FlagCatalogos>[];

  for (final carpeta in _carpetasDeApps) {
    final directorio = Directory('$raiz/$carpeta');
    if (!directorio.existsSync()) continue;
    final apps = directorio.listSync().whereType<Directory>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final app in apps) {
      final nombreApp = app.path.split('/').last;
      final rutaRelativaApp = '$carpeta/$nombreApp';

      final archivoBloqueos = File('${app.path}/BLOQUEOS-PENDIENTES.md');
      if (archivoBloqueos.existsSync()) {
        bloqueos.addAll(leerBloqueos(archivoBloqueos.readAsStringSync(),
            aplicacion: nombreApp));
      }

      sellos.addAll(_buscarSellos(app, nombreApp, rutaRelativaApp));

      final archivoFlag =
          File('${app.path}/lib/datos/catalogos_generados/flag_revision.dart');
      if (archivoFlag.existsSync()) {
        flags.add(FlagCatalogos(
            nombreApp,
            '$rutaRelativaApp/lib/datos/catalogos_generados/flag_revision.dart',
            leerFlagRevision(archivoFlag.readAsStringSync())));
      }
    }
  }

  final catalogos = <EstadoCatalogo>[];
  final contenido = Directory('$raiz/content');
  if (contenido.existsSync()) {
    final csvs = contenido
        .listSync(recursive: true)
        .whereType<File>()
        .where((archivo) => archivo.path.endsWith('.csv'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final csv in csvs) {
      catalogos.add(analizarCatalogo(csv.readAsStringSync(),
          ruta: csv.path.substring(raiz.length + 1)));
    }
  }

  return Inventario(
    raiz: raiz,
    generadoEn: ahora ?? DateTime.now(),
    bloqueos: bloqueos,
    sellos: sellos,
    catalogos: catalogos,
    flags: flags,
  );
}

List<SelloProvisional> _buscarSellos(
    Directory app, String nombreApp, String rutaRelativaApp) {
  final lib = Directory('${app.path}/lib');
  if (!lib.existsSync()) return [];

  final testSello = File('${app.path}/test/sello_provisional_test.dart');
  final textoTestSello =
      testSello.existsSync() ? testSello.readAsStringSync() : '';

  final encontrados = <SelloProvisional>[];
  final archivos = lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((archivo) =>
          archivo.path.endsWith('.dart') &&
          !archivo.path.endsWith('.g.dart') &&
          !archivo.path.contains('/catalogos_generados/') &&
          !archivo.path.split('/').last.startsWith('app_localizations'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final archivo in archivos) {
    final lineas = buscarLineasConSello(archivo.readAsStringSync());
    if (lineas.isEmpty) continue;
    final rutaEnApp = archivo.path.substring(app.path.length + 1);
    encontrados.add(SelloProvisional(
      aplicacion: nombreApp,
      ruta: '$rutaRelativaApp/$rutaEnApp',
      lineasConSello: lineas,
      protegidoPorTest: textoTestSello.contains(rutaEnApp) ||
          textoTestSello.contains(rutaEnApp.split('/').last),
    ));
  }
  return encontrados;
}

final RegExp _literalConSello = RegExp(r"""['"][^'"]*PROVISIONAL""");

/// Líneas de código Dart con `PROVISIONAL` dentro de un literal de texto.
/// Se descartan los comentarios (`//`, `///`), que solo lo mencionan.
List<String> buscarLineasConSello(String fuenteDart) => [
      for (final linea in fuenteDart.split('\n'))
        if (!linea.trimLeft().startsWith('//') &&
            _literalConSello.hasMatch(linea))
          linea.trim(),
    ];
