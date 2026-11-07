// ignore_for_file: avoid_print
// Piezas comunes de los compiladores de catálogos de la suite Larrea
// (CSV curados en `content/<vertical>/` → `.dart` generados en la app).
//
// Dart puro (solo `dart:io`): se importa con una ruta relativa desde el
// `tool/compilar_catalogos.dart` de cada app, para que `dart run` no tenga
// que resolver las dependencias Flutter del core:
//
//   import '../../../packages/nuevo_ser_core/tool/catalogos/compilador_catalogos.dart';
//
// Cada app sigue escribiendo sus funciones `_compilarX` (las clases que
// genera son propias de cada vertical); aquí está lo que antes se copiaba:
// leer el CSV, la cabecera del fichero generado, escapar texto, el flag
// global de revisión y la función de normalización que llevan los
// catálogos generados.

import 'dart:io';

/// Un CSV de catálogo ya leído, sin las líneas de comentario `#`.
class CsvCatalogo {
  CsvCatalogo(this.cabecera, this.filas, this.revisadas);

  final List<String> cabecera;
  final List<List<String>> filas;

  /// Filas con `revisado_por` no vacío.
  final int revisadas;

  int get totalFilas => filas.length;
  bool get todasRevisadas => totalFilas > 0 && revisadas == totalFilas;

  /// Valores distintos de `revisado_por`.
  Set<String> get revisores {
    final indice = cabecera.indexOf('revisado_por');
    if (indice < 0) return const {};
    return filas
        .map((fila) => indice < fila.length ? fila[indice].trim() : '')
        .where((valor) => valor.isNotEmpty)
        .toSet();
  }

  /// Valor de [nombreColumna] en [fila], recortado; vacío si no está.
  String campo(List<String> fila, String nombreColumna) {
    final indice = cabecera.indexOf(nombreColumna);
    if (indice < 0 || indice >= fila.length) return '';
    return fila[indice].trim();
  }
}

/// Lee los CSV de una vertical y escribe sus catálogos generados.
class CompiladorCatalogos {
  CompiladorCatalogos({
    required this.carpetaContent,
    required this.carpetaApp,
    this.rutaSalida = 'lib/datos/catalogos_generados',
    this.avisoProvisional = 'DATOS PROVISIONALES SIN VALIDAR.',
  });

  /// Nombre de la carpeta en `content/` (p. ej. `aceitera`).
  final String carpetaContent;

  /// Nombre de la carpeta de la app en `apps/` (p. ej. `solera-aceitera`).
  final String carpetaApp;

  /// Carpeta de salida, relativa a la app.
  final String rutaSalida;

  /// Línea de aviso de la cabecera mientras quede una fila sin revisar.
  final String avisoProvisional;

  /// Falso en cuanto se lee un CSV con alguna fila sin revisar.
  bool todasRevisadas = true;

  String get rutaContent => '../../content/$carpetaContent';

  /// Lee `content/<carpetaContent>/<nombre>` y actualiza [todasRevisadas].
  Future<CsvCatalogo> leer(String nombre) async {
    final fichero = File('$rutaContent/$nombre');
    if (!await fichero.exists()) {
      throw Exception('No se encuentra $rutaContent/$nombre');
    }
    final sinComentarios = (await fichero.readAsString())
        .split('\n')
        .where((linea) => !linea.trim().startsWith('#'))
        .join('\n');
    final tabla = parsearTablaCsv(sinComentarios);
    if (tabla.cabecera.isEmpty) throw Exception('CSV vacío: $nombre');
    final indiceRevisado = tabla.cabecera.indexOf('revisado_por');
    var revisadas = 0;
    for (final fila in tabla.filas) {
      if (indiceRevisado >= 0 &&
          indiceRevisado < fila.length &&
          fila[indiceRevisado].trim().isNotEmpty) {
        revisadas++;
      }
    }
    final csv = CsvCatalogo(tabla.cabecera, tabla.filas, revisadas);
    if (!csv.todasRevisadas) todasRevisadas = false;
    return csv;
  }

  /// Cabecera «GENERADO AUTOMÁTICAMENTE» con fuente, fecha y estado.
  String cabeceraDart({required String nombreCsv, required CsvCatalogo csv}) {
    final ahora = DateTime.now();
    final fecha = '${ahora.year}-${_dosCifras(ahora.month)}-'
        '${_dosCifras(ahora.day)}';
    final lineas = StringBuffer()
      ..writeln('// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.')
      ..writeln('//')
      ..writeln('// Fuente: content/$carpetaContent/$nombreCsv')
      ..writeln('// Generado: $fecha')
      ..writeln('// Filas: ${csv.totalFilas} (${csv.revisadas} revisadas, '
          '${csv.totalFilas - csv.revisadas} pendientes de revisión)');
    if (csv.todasRevisadas) {
      lineas.writeln('// Estado: ✅ todas las filas revisadas por: '
          '${csv.revisores.join(", ")}');
    } else {
      lineas
        ..writeln('//')
        ..writeln('// ⚠ $avisoProvisional')
        ..writeln('// La app muestra un banner mientras este flag siga activo.')
        ..writeln('// Para regenerar: cd apps/$carpetaApp && '
            'dart run tool/compilar_catalogos.dart');
    }
    lineas.writeln();
    return lineas.toString();
  }

  /// Escribe `flag_revision.dart` con `catalogosCompletamenteRevisados`.
  Future<void> escribirFlagRevision({
    required String descripcionCatalogos,
    required String textoBanner,
  }) async {
    final contenido = StringBuffer()
      ..writeln('// GENERADO AUTOMÁTICAMENTE por tool/compilar_catalogos.dart.')
      ..writeln('//')
      ..writeln('// Flag global: true si TODAS las filas de $descripcionCatalogos'
          ' tienen')
      ..writeln('// `revisado_por` no vacío. La app lo lee para mostrar/ocultar el')
      ..writeln('// banner "$textoBanner".')
      ..writeln()
      ..writeln('const bool catalogosCompletamenteRevisados = '
          '$todasRevisadas;');
    await escribir('flag_revision.dart', contenido.toString());
  }

  Future<void> escribir(String nombre, String contenido) async {
    final fichero = File('$rutaSalida/$nombre');
    await fichero.parent.create(recursive: true);
    await fichero.writeAsString(contenido);
  }
}

String _dosCifras(int numero) => numero.toString().padLeft(2, '0');

/// Literal Dart entre comillas simples.
String escaparDart(String texto) =>
    "'${texto.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll('\n', r'\n').replaceAll('\r', '')}'";

/// Separa un campo `a|b|c` en una lista sin vacíos.
List<String> separarPipe(String texto) {
  if (texto.trim().isEmpty) return const [];
  return texto
      .split('|')
      .map((parte) => parte.trim())
      .where((parte) => parte.isNotEmpty)
      .toList();
}

/// Función `_normalizar` que se copia dentro de cada catálogo generado.
const String funcionNormalizarDart = '''
String _normalizar(String texto) {
  return texto
      .toLowerCase()
      .replaceAll(RegExp(r'[áàä]'), 'a')
      .replaceAll(RegExp(r'[éèë]'), 'e')
      .replaceAll(RegExp(r'[íìï]'), 'i')
      .replaceAll(RegExp(r'[óòö]'), 'o')
      .replaceAll(RegExp(r'[úùü]'), 'u')
      .replaceAll('ñ', 'n')
      .trim();
}
''';

typedef TablaCsv = ({List<String> cabecera, List<List<String>> filas});

/// Parser CSV mínimo (comillas dobles, `;` o `,` según la primera línea,
/// BOM y CRLF). Misma lógica que `src/csv/csv_io.dart`.
TablaCsv parsearTablaCsv(String contenido) {
  if (contenido.isEmpty) return (cabecera: const [], filas: const []);
  if (contenido.codeUnitAt(0) == 0xFEFF) contenido = contenido.substring(1);
  final primeraLinea = contenido.split('\n').first;
  final delimitador =
      primeraLinea.contains(';') && !primeraLinea.contains(',') ? ';' : ',';
  final filasCrudas = <List<String>>[];
  for (final linea in contenido.split('\n')) {
    final limpia =
        linea.endsWith('\r') ? linea.substring(0, linea.length - 1) : linea;
    if (limpia.isEmpty) continue;
    filasCrudas.add(_parsearLineaCsv(limpia, delimitador));
  }
  if (filasCrudas.isEmpty) return (cabecera: const [], filas: const []);
  return (cabecera: filasCrudas.first, filas: filasCrudas.sublist(1));
}

List<String> _parsearLineaCsv(String linea, String delimitador) {
  final campos = <String>[];
  final actual = StringBuffer();
  var dentroComillas = false;
  for (var indice = 0; indice < linea.length; indice++) {
    final caracter = linea[indice];
    if (caracter == '"') {
      if (dentroComillas &&
          indice + 1 < linea.length &&
          linea[indice + 1] == '"') {
        actual.write('"');
        indice++;
      } else {
        dentroComillas = !dentroComillas;
      }
    } else if (caracter == delimitador && !dentroComillas) {
      campos.add(actual.toString());
      actual.clear();
    } else {
      actual.write(caracter);
    }
  }
  campos.add(actual.toString());
  return campos;
}
