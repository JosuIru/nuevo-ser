// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings
// Compilador de catálogos curados de Larrea Viticultura.
//
// Lee los 5 CSVs de `content/viticultura/` y genera los ficheros
// `.dart` en `lib/datos/catalogos_generados/`. Reusa el módulo
// `csv_io` del `nuevo_ser_core` para parsear (BOM/delim/quotes/CRLF).
//
// Ejecución:
//   cd apps/solera-viticultura
//   dart run tool/compilar_catalogos.dart
//
// El script:
//  1. Skipea las líneas que empiezan por `#` (cabecera-comentario).
//  2. Lee la cabecera de columnas reales y los datos.
//  3. Cuenta filas revisadas (con `revisado_por` no vacío) vs sin revisar.
//  4. Genera el `.dart` correspondiente con disclaimer + timestamp.
//
// El disclaimer "DATOS PROVISIONALES SIN VALIDAR" se mantiene en el
// `.dart` generado mientras haya >= 1 fila sin revisar. Cuando todas
// las filas tengan `revisado_por` rellenas, el disclaimer cambia a
// "REVISADO POR <listado>" — esto da feedback al asesor sobre el
// progreso.

import 'dart:io';

// Parser CSV inline para que el script sea ejecutable con `dart run`
// sin resolver las dependencias Flutter del core. La lógica es la
// misma que `nuevo_ser_core/lib/src/csv/csv_io.dart` — si la lógica
// del parser cambia ahí, sincronizar aquí. Es ~25 líneas, no merece
// la pena el sobrediseño de un sub-package puro Dart sólo por esto.
typedef _TablaCsv = ({List<String> cabecera, List<List<String>> filas});

_TablaCsv _parsearTablaCsv(String contenido) {
  if (contenido.isEmpty) {
    return (cabecera: const [], filas: const []);
  }
  if (contenido.codeUnitAt(0) == 0xFEFF) {
    contenido = contenido.substring(1);
  }
  final primeraLinea = contenido.split('\n').first;
  final delim = primeraLinea.contains(';') && !primeraLinea.contains(',') ? ';' : ',';
  final filasCrudas = <List<String>>[];
  for (final linea in contenido.split('\n')) {
    final limpia = linea.endsWith('\r') ? linea.substring(0, linea.length - 1) : linea;
    if (limpia.isEmpty) continue;
    filasCrudas.add(_parsearLineaCsv(limpia, delim));
  }
  if (filasCrudas.isEmpty) return (cabecera: const [], filas: const []);
  return (cabecera: filasCrudas.first, filas: filasCrudas.sublist(1));
}

List<String> _parsearLineaCsv(String linea, String delim) {
  final campos = <String>[];
  final actual = StringBuffer();
  var dentroComillas = false;
  for (var i = 0; i < linea.length; i++) {
    final c = linea[i];
    if (c == '"') {
      if (dentroComillas && i + 1 < linea.length && linea[i + 1] == '"') {
        actual.write('"');
        i++;
      } else {
        dentroComillas = !dentroComillas;
      }
    } else if (c == delim && !dentroComillas) {
      campos.add(actual.toString());
      actual.clear();
    } else {
      actual.write(c);
    }
  }
  campos.add(actual.toString());
  return campos;
}

const _rutaContent = '../../content/viticultura';
const _rutaSalida = 'lib/datos/catalogos_generados';

void main() async {
  print('Compilando catálogos de Larrea Viticultura…\n');
  await _compilarVariedades();
  await _compilarPortainjertos();
  await _compilarPlagas();
  await _compilarMateriasActivas();
  await _compilarCalendarioBbch();
  await _escribirFlagRevision();
  if (_todasRevisadasGlobal) {
    print('\n✅ Todas las filas revisadas. El banner "datos provisionales" queda desactivado.');
  } else {
    print('\n⚠ Hay filas sin revisar. La app mostrará el banner "datos provisionales" hasta que el asesor las valide.');
  }
  print('Hecho. Recuerda ejecutar `flutter analyze` y `flutter test`.');
}

// ─── Lectura común ─────────────────────────────────────────

class _CsvLeido {
  final List<String> cabecera;
  final List<List<String>> filas;
  final int totalFilas;
  final int revisadas;

  _CsvLeido(this.cabecera, this.filas, this.totalFilas, this.revisadas);

  bool get todasRevisadas => totalFilas > 0 && revisadas == totalFilas;
  Set<String> get revisores {
    // Asume que la columna `revisado_por` existe; si no, devuelve set vacío.
    final i = cabecera.indexOf('revisado_por');
    if (i < 0) return const {};
    return filas
        .map((f) => i < f.length ? f[i].trim() : '')
        .where((s) => s.isNotEmpty)
        .toSet();
  }
}

Future<_CsvLeido> _leer(String nombre) async {
  final fichero = File('$_rutaContent/$nombre');
  if (!await fichero.exists()) {
    throw Exception('No se encuentra $_rutaContent/$nombre');
  }
  final crudo = await fichero.readAsString();
  // Filtrar líneas que empiezan por `#` (comentarios del CSV).
  final sinComentarios = crudo
      .split('\n')
      .where((l) => !l.trim().startsWith('#'))
      .join('\n');
  final tabla = _parsearTablaCsv(sinComentarios);
  if (tabla.cabecera.isEmpty) {
    throw Exception('CSV vacío: $nombre');
  }
  final indiceRevisado = tabla.cabecera.indexOf('revisado_por');
  int revisadas = 0;
  for (final fila in tabla.filas) {
    if (indiceRevisado >= 0 &&
        indiceRevisado < fila.length &&
        fila[indiceRevisado].trim().isNotEmpty) {
      revisadas++;
    }
  }
  return _CsvLeido(tabla.cabecera, tabla.filas, tabla.filas.length, revisadas);
}

String _cabeceraDart({
  required String nombreCsv,
  required _CsvLeido csv,
}) {
  final ahora = DateTime.now();
  final fecha = '${ahora.year}-${_dosCifras(ahora.month)}-${_dosCifras(ahora.day)}';
  final lineas = StringBuffer();
  lineas.writeln('// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.');
  lineas.writeln('//');
  lineas.writeln('// Fuente: content/viticultura/$nombreCsv');
  lineas.writeln('// Generado: $fecha');
  lineas.writeln('// Filas: ${csv.totalFilas} (${csv.revisadas} revisadas, ${csv.totalFilas - csv.revisadas} pendientes de revisión)');
  if (csv.todasRevisadas) {
    lineas.writeln('// Estado: ✅ todas las filas revisadas por: ${csv.revisores.join(", ")}');
  } else {
    lineas.writeln('//');
    lineas.writeln('// ⚠ DATOS PROVISIONALES SIN VALIDAR AGRONÓMICA/ENOLÓGICAMENTE.');
    lineas.writeln('// La app muestra un banner mientras este flag siga activo.');
    lineas.writeln('// Para regenerar: cd apps/solera-viticultura && dart run tool/compilar_catalogos.dart');
  }
  lineas.writeln();
  return lineas.toString();
}

String _dosCifras(int n) => n.toString().padLeft(2, '0');

String _escapeDart(String s) {
  return "'" +
      s
          .replaceAll(r'\', r'\\')
          .replaceAll("'", r"\'")
          .replaceAll('\n', r'\n')
          .replaceAll('\r', '') +
      "'";
}

List<String> _separarPipe(String s) {
  if (s.trim().isEmpty) return const [];
  return s.split('|').map((x) => x.trim()).where((x) => x.isNotEmpty).toList();
}

String _campo(_CsvLeido csv, List<String> fila, String nombreColumna) {
  final i = csv.cabecera.indexOf(nombreColumna);
  if (i < 0 || i >= fila.length) return '';
  return fila[i].trim();
}

bool _todasRevisadasGlobal = true;

// ─── Variedades ────────────────────────────────────────────

Future<void> _compilarVariedades() async {
  final csv = await _leer('variedades.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'variedades.csv', csv: csv))
    ..writeln('/// Color visual de la variedad. Las rosadas son raras pero existen.')
    ..writeln('enum ColorVariedad { tinta, blanca, rosada }')
    ..writeln()
    ..writeln('class Variedad {')
    ..writeln('  final String id;')
    ..writeln('  final String nombreCanonico;')
    ..writeln('  final ColorVariedad color;')
    ..writeln('  final List<String> sinonimias;')
    ..writeln()
    ..writeln('  const Variedad({')
    ..writeln('    required this.id,')
    ..writeln('    required this.nombreCanonico,')
    ..writeln('    required this.color,')
    ..writeln('    this.sinonimias = const [],')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<Variedad> catalogoVariedades = [');
  for (final fila in csv.filas) {
    final id = _campo(csv, fila, 'id');
    final nombre = _campo(csv, fila, 'nombre_canonico');
    final colorTxt = _campo(csv, fila, 'color');
    final sinos = _separarPipe(_campo(csv, fila, 'sinonimias'));
    final colorDart = switch (colorTxt) {
      'tinta' => 'ColorVariedad.tinta',
      'blanca' => 'ColorVariedad.blanca',
      'rosada' => 'ColorVariedad.rosada',
      _ => throw Exception('Color desconocido en variedades.csv: "$colorTxt" (id=$id)'),
    };
    buf.writeln('  Variedad(');
    buf.writeln('    id: ${_escapeDart(id)},');
    buf.writeln('    nombreCanonico: ${_escapeDart(nombre)},');
    buf.writeln('    color: $colorDart,');
    if (sinos.isNotEmpty) {
      buf.writeln('    sinonimias: [${sinos.map(_escapeDart).join(', ')}],');
    }
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('Variedad? variedadPorId(String id) {')
    ..writeln('  for (final v in catalogoVariedades) {')
    ..writeln('    if (v.id == id) return v;')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Búsqueda fuzzy: id exacto > nombre canónico > sinonimias > coincidencia parcial.')
    ..writeln('/// Usado por el modal IA para validar diagnósticos contra el catálogo y por')
    ..writeln('/// el `Autocomplete` de la pantalla nueva cepa.')
    ..writeln('List<Variedad> buscarVariedades(String texto) {')
    ..writeln('  final q = _normalizar(texto);')
    ..writeln('  if (q.isEmpty) return const [];')
    ..writeln('  return catalogoVariedades.where((v) {')
    ..writeln('    if (v.id == q) return true;')
    ..writeln('    if (_normalizar(v.nombreCanonico).contains(q)) return true;')
    ..writeln('    for (final s in v.sinonimias) {')
    ..writeln('      if (_normalizar(s).contains(q)) return true;')
    ..writeln('    }')
    ..writeln('    return false;')
    ..writeln('  }).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln(_funcionNormalizar());

  await _escribir('catalogo_variedades.dart', buf.toString());
  print('  ✓ catalogo_variedades.dart  (${csv.totalFilas} variedades, ${csv.revisadas} revisadas)');
}

// ─── Portainjertos ─────────────────────────────────────────

Future<void> _compilarPortainjertos() async {
  final csv = await _leer('portainjertos.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'portainjertos.csv', csv: csv))
    ..writeln('class Portainjerto {')
    ..writeln('  final String id;')
    ..writeln('  final String nombreCanonico;')
    ..writeln('  final String vigor;')
    ..writeln('  final int? toleranciaCalizaActivaPorcentaje;')
    ..writeln('  final String resistenciaSequia;')
    ..writeln('  final String notas;')
    ..writeln()
    ..writeln('  const Portainjerto({')
    ..writeln('    required this.id,')
    ..writeln('    required this.nombreCanonico,')
    ..writeln('    required this.vigor,')
    ..writeln('    this.toleranciaCalizaActivaPorcentaje,')
    ..writeln('    required this.resistenciaSequia,')
    ..writeln('    this.notas = \'\',')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<Portainjerto> catalogoPortainjertos = [');
  for (final fila in csv.filas) {
    final id = _campo(csv, fila, 'id');
    final nombre = _campo(csv, fila, 'nombre_canonico');
    final vigor = _campo(csv, fila, 'vigor');
    final calizaTxt = _campo(csv, fila, 'tolerancia_caliza');
    final caliza = int.tryParse(calizaTxt);
    final sequia = _campo(csv, fila, 'resistencia_sequia');
    final notas = _campo(csv, fila, 'notas');
    buf.writeln('  Portainjerto(');
    buf.writeln('    id: ${_escapeDart(id)},');
    buf.writeln('    nombreCanonico: ${_escapeDart(nombre)},');
    buf.writeln('    vigor: ${_escapeDart(vigor)},');
    if (caliza != null) {
      buf.writeln('    toleranciaCalizaActivaPorcentaje: $caliza,');
    }
    buf.writeln('    resistenciaSequia: ${_escapeDart(sequia)},');
    if (notas.isNotEmpty) {
      buf.writeln('    notas: ${_escapeDart(notas)},');
    }
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('Portainjerto? portainjertoPorId(String id) {')
    ..writeln('  for (final p in catalogoPortainjertos) {')
    ..writeln('    if (p.id == id) return p;')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln('List<Portainjerto> buscarPortainjertos(String texto) {')
    ..writeln('  final q = _normalizar(texto);')
    ..writeln('  if (q.isEmpty) return const [];')
    ..writeln('  return catalogoPortainjertos.where((p) {')
    ..writeln('    return _normalizar(p.id).contains(q) ||')
    ..writeln('        _normalizar(p.nombreCanonico).contains(q);')
    ..writeln('  }).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln(_funcionNormalizar());

  await _escribir('catalogo_portainjertos.dart', buf.toString());
  print('  ✓ catalogo_portainjertos.dart  (${csv.totalFilas} portainjertos, ${csv.revisadas} revisados)');
}

// ─── Plagas ────────────────────────────────────────────────

Future<void> _compilarPlagas() async {
  final csv = await _leer('plagas_vid.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'plagas_vid.csv', csv: csv))
    ..writeln('/// Tipo de incidencia. Coincide con el dropdown del formulario de')
    ..writeln('/// incidencia (`tipo` en la BD) salvo que ese también acepta `estres`')
    ..writeln('/// y `otro` para entradas libres.')
    ..writeln('enum TipoPlagaVid { enfermedad, plaga, fisiologico, abiotico }')
    ..writeln()
    ..writeln('class PlagaVid {')
    ..writeln('  final String id;')
    ..writeln('  final String nombreComun;')
    ..writeln('  final String nombreCientifico;')
    ..writeln('  final TipoPlagaVid tipo;')
    ..writeln('  final String sintomas;')
    ..writeln('  final String condicionesFavorables;')
    ..writeln('  final String manejoCultural;')
    ..writeln('  /// `true` para enfermedades reguladas que requieren notificación a Servicios')
    ..writeln('  /// Fitosanitarios CCAA. Hoy ningún registro lo tiene activo — pendiente de que')
    ..writeln('  /// el agrónomo asesor incluya Xylella, Flavescencia dorada y similares.')
    ..writeln('  final bool declaracionOficial;')
    ..writeln()
    ..writeln('  const PlagaVid({')
    ..writeln('    required this.id,')
    ..writeln('    required this.nombreComun,')
    ..writeln('    this.nombreCientifico = \'\',')
    ..writeln('    required this.tipo,')
    ..writeln('    this.sintomas = \'\',')
    ..writeln('    this.condicionesFavorables = \'\',')
    ..writeln('    this.manejoCultural = \'\',')
    ..writeln('    this.declaracionOficial = false,')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<PlagaVid> catalogoPlagasVid = [');
  for (final fila in csv.filas) {
    final id = _campo(csv, fila, 'id');
    final nComun = _campo(csv, fila, 'nombre_comun');
    final nCient = _campo(csv, fila, 'nombre_cientifico');
    final tipoTxt = _campo(csv, fila, 'tipo');
    final tipoDart = switch (tipoTxt) {
      'enfermedad' => 'TipoPlagaVid.enfermedad',
      'plaga' => 'TipoPlagaVid.plaga',
      'fisiologico' => 'TipoPlagaVid.fisiologico',
      'abiotico' => 'TipoPlagaVid.abiotico',
      _ => throw Exception('Tipo desconocido en plagas_vid.csv: "$tipoTxt" (id=$id)'),
    };
    final sintomas = _campo(csv, fila, 'sintomas');
    final condiciones = _campo(csv, fila, 'condiciones_favorables');
    final manejo = _campo(csv, fila, 'manejo_cultural');
    final declaracion = _campo(csv, fila, 'declaracion_oficial') == 'si';
    buf.writeln('  PlagaVid(');
    buf.writeln('    id: ${_escapeDart(id)},');
    buf.writeln('    nombreComun: ${_escapeDart(nComun)},');
    if (nCient.isNotEmpty) {
      buf.writeln('    nombreCientifico: ${_escapeDart(nCient)},');
    }
    buf.writeln('    tipo: $tipoDart,');
    if (sintomas.isNotEmpty) buf.writeln('    sintomas: ${_escapeDart(sintomas)},');
    if (condiciones.isNotEmpty) buf.writeln('    condicionesFavorables: ${_escapeDart(condiciones)},');
    if (manejo.isNotEmpty) buf.writeln('    manejoCultural: ${_escapeDart(manejo)},');
    if (declaracion) buf.writeln('    declaracionOficial: true,');
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('PlagaVid? plagaPorId(String id) {')
    ..writeln('  for (final p in catalogoPlagasVid) {')
    ..writeln('    if (p.id == id) return p;')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Plagas de declaración obligatoria — la app las destaca con banner rojo.')
    ..writeln('/// Hoy la lista puede estar vacía (depende de la columna `declaracion_oficial`)')
    ..writeln('/// — el agrónomo asesor decide qué activar (Xylella, Flavescencia dorada…).')
    ..writeln('List<PlagaVid> patologiasDeclaracionObligatoria() {')
    ..writeln('  return catalogoPlagasVid.where((p) => p.declaracionOficial).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Mapea el `tipo` enumerado del catálogo al string que espera la BD')
    ..writeln('/// del modelo `Incidencia` (`plaga`, `enfermedad`, `fisiologico`, `otro`).')
    ..writeln('/// Los abióticos se mapean a `otro` porque el formulario no los distingue.')
    ..writeln('String tipoIncidenciaParaBd(TipoPlagaVid tipo) {')
    ..writeln('  switch (tipo) {')
    ..writeln('    case TipoPlagaVid.enfermedad:')
    ..writeln('      return \'enfermedad\';')
    ..writeln('    case TipoPlagaVid.plaga:')
    ..writeln('      return \'plaga\';')
    ..writeln('    case TipoPlagaVid.fisiologico:')
    ..writeln('      return \'fisiologico\';')
    ..writeln('    case TipoPlagaVid.abiotico:')
    ..writeln('      return \'otro\';')
    ..writeln('  }')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Busca por id exacto > nombre común > nombre científico. Usado por')
    ..writeln('/// el modal IA para marcar diagnósticos como "validados por catálogo".')
    ..writeln('PlagaVid? plagaPorBusquedaFuzzy(String nombreComun, String nombreCientifico) {')
    ..writeln('  final qComun = _normalizar(nombreComun);')
    ..writeln('  final qCient = _normalizar(nombreCientifico);')
    ..writeln('  if (qComun.isEmpty && qCient.isEmpty) return null;')
    ..writeln('  for (final p in catalogoPlagasVid) {')
    ..writeln('    if (qCient.isNotEmpty && p.nombreCientifico.isNotEmpty &&')
    ..writeln('        _normalizar(p.nombreCientifico).contains(qCient)) {')
    ..writeln('      return p;')
    ..writeln('    }')
    ..writeln('    if (qComun.isNotEmpty && _normalizar(p.nombreComun).contains(qComun)) {')
    ..writeln('      return p;')
    ..writeln('    }')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln('List<PlagaVid> buscarPlagasVid(String texto) {')
    ..writeln('  final q = _normalizar(texto);')
    ..writeln('  if (q.isEmpty) return const [];')
    ..writeln('  return catalogoPlagasVid.where((p) {')
    ..writeln('    return _normalizar(p.nombreComun).contains(q) ||')
    ..writeln('        _normalizar(p.nombreCientifico).contains(q) ||')
    ..writeln('        _normalizar(p.id).contains(q);')
    ..writeln('  }).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln(_funcionNormalizar());

  await _escribir('catalogo_plagas_vid.dart', buf.toString());
  print('  ✓ catalogo_plagas_vid.dart  (${csv.totalFilas} plagas, ${csv.revisadas} revisadas)');
}

// ─── Materias activas ──────────────────────────────────────

Future<void> _compilarMateriasActivas() async {
  final csv = await _leer('materias_activas.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'materias_activas.csv', csv: csv))
    ..writeln('class MateriaActiva {')
    ..writeln('  final String id;')
    ..writeln('  final String nombreCanonico;')
    ..writeln('  /// IDs de plagas en `catalogo_plagas_vid.dart` para las que está autorizada.')
    ..writeln('  final List<String> plagasObjetivo;')
    ..writeln('  final String tipoAccion;')
    ..writeln('  /// Plazo de seguridad orientativo en días. ⚠ Verificar etiqueta del producto.')
    ..writeln('  final int plazoSeguridadOrientativoDias;')
    ..writeln('  final bool autorizadaEcologico;')
    ..writeln('  final String notas;')
    ..writeln()
    ..writeln('  const MateriaActiva({')
    ..writeln('    required this.id,')
    ..writeln('    required this.nombreCanonico,')
    ..writeln('    required this.plagasObjetivo,')
    ..writeln('    required this.tipoAccion,')
    ..writeln('    required this.plazoSeguridadOrientativoDias,')
    ..writeln('    required this.autorizadaEcologico,')
    ..writeln('    this.notas = \'\',')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<MateriaActiva> catalogoMateriasActivas = [');
  for (final fila in csv.filas) {
    final id = _campo(csv, fila, 'id');
    final nombre = _campo(csv, fila, 'nombre_canonico');
    final plagas = _separarPipe(_campo(csv, fila, 'plagas_objetivo'));
    final tipoAccion = _campo(csv, fila, 'tipo_accion');
    final plazo = int.tryParse(_campo(csv, fila, 'plazo_seguridad_orient')) ?? 0;
    final ecologicoTxt = _campo(csv, fila, 'ecologico');
    final ecologico = ecologicoTxt == 'si';
    final notas = _campo(csv, fila, 'notas');
    buf.writeln('  MateriaActiva(');
    buf.writeln('    id: ${_escapeDart(id)},');
    buf.writeln('    nombreCanonico: ${_escapeDart(nombre)},');
    if (plagas.isEmpty) {
      buf.writeln('    plagasObjetivo: [],');
    } else {
      buf.writeln('    plagasObjetivo: [${plagas.map(_escapeDart).join(', ')}],');
    }
    buf.writeln('    tipoAccion: ${_escapeDart(tipoAccion)},');
    buf.writeln('    plazoSeguridadOrientativoDias: $plazo,');
    buf.writeln('    autorizadaEcologico: $ecologico,');
    if (notas.isNotEmpty) buf.writeln('    notas: ${_escapeDart(notas)},');
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('MateriaActiva? materiaActivaPorId(String id) {')
    ..writeln('  for (final m in catalogoMateriasActivas) {')
    ..writeln('    if (m.id == id) return m;')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Filtra materias activas por plaga objetivo. Útil cuando el viticultor')
    ..writeln('/// abre un tratamiento desde una incidencia concreta y quiere ver qué')
    ..writeln('/// materias están autorizadas para esa plaga.')
    ..writeln('List<MateriaActiva> materiasParaPlaga(String idPlaga) {')
    ..writeln('  return catalogoMateriasActivas')
    ..writeln('      .where((m) => m.plagasObjetivo.contains(idPlaga))')
    ..writeln('      .toList();')
    ..writeln('}');

  await _escribir('catalogo_materias_activas.dart', buf.toString());
  print('  ✓ catalogo_materias_activas.dart  (${csv.totalFilas} materias, ${csv.revisadas} revisadas)');
}

// ─── Calendario BBCH ───────────────────────────────────────

Future<void> _compilarCalendarioBbch() async {
  final csv = await _leer('calendario_bbch.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'calendario_bbch.csv', csv: csv))
    ..writeln('/// Zona climática orientativa. Norte = Galicia/Cantábrica/Rioja Alta/')
    ..writeln('/// Norte de Castilla. Sur = La Mancha/Andalucía/Extremadura/Levante.')
    ..writeln('enum ZonaClimaticaVid { norte, sur }')
    ..writeln()
    ..writeln('/// Estado fenológico BBCH para vid (FAO 1995). El ciclo completo abarca')
    ..writeln('/// del 00 al 99; aquí guardamos los 9 estados principales que el')
    ..writeln('/// viticultor reconoce con el ojo.')
    ..writeln('class EstadoFenologicoBbch {')
    ..writeln('  final String variedadId;')
    ..writeln('  final ZonaClimaticaVid zona;')
    ..writeln('  final int estadoBbch;')
    ..writeln('  final String nombreEstado;')
    ..writeln('  final int mes;')
    ..writeln('  /// 1 = días 1-10, 2 = días 11-20, 3 = días 21-fin de mes.')
    ..writeln('  final int decada;')
    ..writeln()
    ..writeln('  const EstadoFenologicoBbch({')
    ..writeln('    required this.variedadId,')
    ..writeln('    required this.zona,')
    ..writeln('    required this.estadoBbch,')
    ..writeln('    required this.nombreEstado,')
    ..writeln('    required this.mes,')
    ..writeln('    required this.decada,')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<EstadoFenologicoBbch> calendarioFenologicoBbch = [');
  for (final fila in csv.filas) {
    final variedadId = _campo(csv, fila, 'variedad_id');
    final zonaTxt = _campo(csv, fila, 'zona');
    final zonaDart = switch (zonaTxt) {
      'norte' => 'ZonaClimaticaVid.norte',
      'sur' => 'ZonaClimaticaVid.sur',
      _ => throw Exception('Zona desconocida en calendario_bbch.csv: "$zonaTxt"'),
    };
    final bbch = int.parse(_campo(csv, fila, 'estado_bbch'));
    final nombre = _campo(csv, fila, 'nombre_estado');
    final mes = int.parse(_campo(csv, fila, 'mes'));
    final decada = int.parse(_campo(csv, fila, 'decada'));
    buf.writeln('  EstadoFenologicoBbch(');
    buf.writeln('    variedadId: ${_escapeDart(variedadId)},');
    buf.writeln('    zona: $zonaDart,');
    buf.writeln('    estadoBbch: $bbch,');
    buf.writeln('    nombreEstado: ${_escapeDart(nombre)},');
    buf.writeln('    mes: $mes,');
    buf.writeln('    decada: $decada,');
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('/// Estados fenológicos para una variedad y zona, ordenados por fecha.')
    ..writeln('List<EstadoFenologicoBbch> calendarioDe(String variedadId, ZonaClimaticaVid zona) {')
    ..writeln('  final filtrados = calendarioFenologicoBbch')
    ..writeln('      .where((e) => e.variedadId == variedadId && e.zona == zona)')
    ..writeln('      .toList();')
    ..writeln('  filtrados.sort((a, b) {')
    ..writeln('    final cmpMes = a.mes.compareTo(b.mes);')
    ..writeln('    if (cmpMes != 0) return cmpMes;')
    ..writeln('    return a.decada.compareTo(b.decada);')
    ..writeln('  });')
    ..writeln('  return filtrados;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Estado fenológico esperado para una fecha concreta. Útil para')
    ..writeln('/// "qué toca esta semana" en la pantalla principal.')
    ..writeln('EstadoFenologicoBbch? estadoEsperadoEn({')
    ..writeln('  required String variedadId,')
    ..writeln('  required ZonaClimaticaVid zona,')
    ..writeln('  required DateTime fecha,')
    ..writeln('}) {')
    ..writeln('  final eventos = calendarioDe(variedadId, zona);')
    ..writeln('  if (eventos.isEmpty) return null;')
    ..writeln('  final decadaActual = (fecha.day - 1) ~/ 10 + 1;')
    ..writeln('  final claveActual = fecha.month * 10 + decadaActual.clamp(1, 3);')
    ..writeln('  EstadoFenologicoBbch? mejor;')
    ..writeln('  int mejorClave = -1;')
    ..writeln('  for (final e in eventos) {')
    ..writeln('    final clave = e.mes * 10 + e.decada;')
    ..writeln('    if (clave <= claveActual && clave > mejorClave) {')
    ..writeln('      mejor = e;')
    ..writeln('      mejorClave = clave;')
    ..writeln('    }')
    ..writeln('  }')
    ..writeln('  return mejor ?? eventos.last; // fallback: última fenología del año')
    ..writeln('}');

  await _escribir('catalogo_bbch.dart', buf.toString());
  print('  ✓ catalogo_bbch.dart  (${csv.totalFilas} estados, ${csv.revisadas} revisados)');
}

// ─── Marcador global de "todo revisado" ────────────────────

Future<void> _escribirFlagRevision() async {
  final buf = StringBuffer()
    ..writeln('// GENERADO AUTOMÁTICAMENTE por tool/compilar_catalogos.dart.')
    ..writeln('//')
    ..writeln('// Flag global: true si TODAS las filas de los 5 catálogos tienen')
    ..writeln('// `revisado_por` no vacío. La app lo lee para mostrar/ocultar el banner')
    ..writeln('// "datos provisionales sin validar".')
    ..writeln()
    ..writeln('const bool catalogosCompletamenteRevisados = $_todasRevisadasGlobal;');
  await _escribir('flag_revision.dart', buf.toString());
}

// ─── Helpers ───────────────────────────────────────────────

Future<void> _escribir(String nombre, String contenido) async {
  final fichero = File('$_rutaSalida/$nombre');
  await fichero.parent.create(recursive: true);
  await fichero.writeAsString(contenido);
}

String _funcionNormalizar() {
  return '''
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
}
