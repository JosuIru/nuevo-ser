// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings
// Compilador de catálogos curados de Larrea Arbolado Urbano.
//
// Lee los 5 CSVs de `content/arbolado-urbano/` y genera los ficheros
// `.dart` en `lib/datos/catalogos_generados/`. Reproduce inline el
// parser CSV del `nuevo_ser_core` (mismo algoritmo que csv_io.dart)
// para que el script sea ejecutable con `dart run` sin resolver las
// dependencias Flutter del core.
//
// Ejecución:
//   cd apps/solera-arbolado-urbano
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
// "REVISADO POR <listado>" — feedback al asesor sobre el progreso.

import 'dart:io';

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

const _rutaContent = '../../content/arbolado-urbano';
const _rutaSalida = 'lib/datos/catalogos_generados';

void main() async {
  print('Compilando catálogos de Larrea Arbolado Urbano…\n');
  await _compilarEspeciesArboreas();
  await _compilarPlagasUrbanas();
  await _compilarTiposPoda();
  await _compilarSustratosAlcorque();
  await _compilarCalendarioArbolado();
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
  lineas.writeln('// Fuente: content/arbolado-urbano/$nombreCsv');
  lineas.writeln('// Generado: $fecha');
  lineas.writeln('// Filas: ${csv.totalFilas} (${csv.revisadas} revisadas, ${csv.totalFilas - csv.revisadas} pendientes de revisión)');
  if (csv.todasRevisadas) {
    lineas.writeln('// Estado: ✅ todas las filas revisadas por: ${csv.revisores.join(", ")}');
  } else {
    lineas.writeln('//');
    lineas.writeln('// ⚠ DATOS PROVISIONALES SIN VALIDAR POR INGENIERO TÉCNICO FORESTAL.');
    lineas.writeln('// La app muestra un banner mientras este flag siga activo.');
    lineas.writeln('// Para regenerar: cd apps/solera-arbolado-urbano && dart run tool/compilar_catalogos.dart');
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

// ─── Especies arbóreas ─────────────────────────────────────

Future<void> _compilarEspeciesArboreas() async {
  final csv = await _leer('especies_arboreas.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'especies_arboreas.csv', csv: csv))
    ..writeln('/// Familia botánica simplificada para arbolado urbano.')
    ..writeln('enum FamiliaEspecieArborea { caducifolio, perenneCaducifolio, perenne, palmacea, conifera }')
    ..writeln()
    ..writeln('/// Tolerancia del árbol a la poda — orientativo para programación de actuaciones.')
    ..writeln('enum ToleranciaPoda { alta, media, baja }')
    ..writeln()
    ..writeln('class EspecieArborea {')
    ..writeln('  final String id;')
    ..writeln('  final String nombreCanonico;')
    ..writeln('  final String nombreCientifico;')
    ..writeln('  final FamiliaEspecieArborea familia;')
    ..writeln('  final double alturaMaxMetros;')
    ..writeln('  final String usoUrbanoTipico;')
    ..writeln('  final ToleranciaPoda toleranciaPoda;')
    ..writeln('  final String notas;')
    ..writeln()
    ..writeln('  const EspecieArborea({')
    ..writeln('    required this.id,')
    ..writeln('    required this.nombreCanonico,')
    ..writeln('    required this.nombreCientifico,')
    ..writeln('    required this.familia,')
    ..writeln('    required this.alturaMaxMetros,')
    ..writeln('    this.usoUrbanoTipico = \'\',')
    ..writeln('    required this.toleranciaPoda,')
    ..writeln('    this.notas = \'\',')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<EspecieArborea> catalogoEspeciesArboreas = [');
  for (final fila in csv.filas) {
    final id = _campo(csv, fila, 'id');
    final nombre = _campo(csv, fila, 'nombre_canonico');
    final cient = _campo(csv, fila, 'nombre_cientifico');
    final familiaTxt = _campo(csv, fila, 'familia');
    final familiaDart = switch (familiaTxt) {
      'caducifolio' => 'FamiliaEspecieArborea.caducifolio',
      'perenne_caducifolio' => 'FamiliaEspecieArborea.perenneCaducifolio',
      'perenne' => 'FamiliaEspecieArborea.perenne',
      'palmacea' => 'FamiliaEspecieArborea.palmacea',
      'conifera' => 'FamiliaEspecieArborea.conifera',
      _ => throw Exception('Familia desconocida en especies_arboreas.csv: "$familiaTxt" (id=$id)'),
    };
    final altura = double.tryParse(_campo(csv, fila, 'altura_max_metros')) ?? 0;
    final uso = _campo(csv, fila, 'uso_urbano_tipico');
    final tolPoda = _campo(csv, fila, 'tolerancia_poda');
    final tolDart = switch (tolPoda) {
      'alta' => 'ToleranciaPoda.alta',
      'media' => 'ToleranciaPoda.media',
      'baja' => 'ToleranciaPoda.baja',
      _ => throw Exception('Tolerancia desconocida: "$tolPoda" (id=$id)'),
    };
    final notas = _campo(csv, fila, 'notas');
    buf.writeln('  EspecieArborea(');
    buf.writeln('    id: ${_escapeDart(id)},');
    buf.writeln('    nombreCanonico: ${_escapeDart(nombre)},');
    buf.writeln('    nombreCientifico: ${_escapeDart(cient)},');
    buf.writeln('    familia: $familiaDart,');
    buf.writeln('    alturaMaxMetros: $altura,');
    if (uso.isNotEmpty) buf.writeln('    usoUrbanoTipico: ${_escapeDart(uso)},');
    buf.writeln('    toleranciaPoda: $tolDart,');
    if (notas.isNotEmpty) buf.writeln('    notas: ${_escapeDart(notas)},');
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('EspecieArborea? especiePorId(String id) {')
    ..writeln('  for (final e in catalogoEspeciesArboreas) {')
    ..writeln('    if (e.id == id) return e;')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Búsqueda fuzzy: id exacto > nombre canónico > nombre científico.')
    ..writeln('List<EspecieArborea> buscarEspecies(String texto) {')
    ..writeln('  final consultaNormalizada = _normalizar(texto);')
    ..writeln('  if (consultaNormalizada.isEmpty) return const [];')
    ..writeln('  return catalogoEspeciesArboreas.where((e) {')
    ..writeln('    if (e.id == consultaNormalizada) return true;')
    ..writeln('    if (_normalizar(e.nombreCanonico).contains(consultaNormalizada)) return true;')
    ..writeln('    if (_normalizar(e.nombreCientifico).contains(consultaNormalizada)) return true;')
    ..writeln('    return false;')
    ..writeln('  }).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln(_funcionNormalizar());

  await _escribir('catalogo_especies_arboreas.dart', buf.toString());
  print('  ✓ catalogo_especies_arboreas.dart  (${csv.totalFilas} especies, ${csv.revisadas} revisadas)');
}

// ─── Plagas urbanas ────────────────────────────────────────

Future<void> _compilarPlagasUrbanas() async {
  final csv = await _leer('plagas_urbanas.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'plagas_urbanas.csv', csv: csv))
    ..writeln('/// Categoría de la incidencia urbana.')
    ..writeln('enum TipoPlagaUrbana { plagaInsecto, enfermedadFungica, enfermedadBacteriana, plagaInvasora, trastornoAbiotico }')
    ..writeln()
    ..writeln('class PlagaUrbana {')
    ..writeln('  final String id;')
    ..writeln('  final String nombreComun;')
    ..writeln('  final String nombreCientifico;')
    ..writeln('  final TipoPlagaUrbana tipo;')
    ..writeln('  final List<String> especiesObjetivo;')
    ..writeln('  final String sintomas;')
    ..writeln('  final String ventanaAviso;')
    ..writeln('  final String manejoCultural;')
    ..writeln('  /// `true` para plagas de declaración obligatoria al servicio fitosanitario oficial.')
    ..writeln('  final bool declaracionOficial;')
    ..writeln('  /// `true` si afecta a la salud de viandantes (urticaria, alergias graves).')
    ..writeln('  final bool riesgoSanitarioPublico;')
    ..writeln('  final String notas;')
    ..writeln()
    ..writeln('  const PlagaUrbana({')
    ..writeln('    required this.id,')
    ..writeln('    required this.nombreComun,')
    ..writeln('    this.nombreCientifico = \'\',')
    ..writeln('    required this.tipo,')
    ..writeln('    this.especiesObjetivo = const [],')
    ..writeln('    this.sintomas = \'\',')
    ..writeln('    this.ventanaAviso = \'\',')
    ..writeln('    this.manejoCultural = \'\',')
    ..writeln('    this.declaracionOficial = false,')
    ..writeln('    this.riesgoSanitarioPublico = false,')
    ..writeln('    this.notas = \'\',')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<PlagaUrbana> catalogoPlagasUrbanas = [');
  for (final fila in csv.filas) {
    final id = _campo(csv, fila, 'id');
    final nComun = _campo(csv, fila, 'nombre_comun');
    final nCient = _campo(csv, fila, 'nombre_cientifico');
    final tipoTxt = _campo(csv, fila, 'tipo');
    final tipoDart = switch (tipoTxt) {
      'plaga_insecto' => 'TipoPlagaUrbana.plagaInsecto',
      'enfermedad_fungica' => 'TipoPlagaUrbana.enfermedadFungica',
      'enfermedad_bacteriana' => 'TipoPlagaUrbana.enfermedadBacteriana',
      'plaga_invasora' => 'TipoPlagaUrbana.plagaInvasora',
      'trastorno_abiotico' => 'TipoPlagaUrbana.trastornoAbiotico',
      _ => throw Exception('Tipo desconocido en plagas_urbanas.csv: "$tipoTxt" (id=$id)'),
    };
    final especies = _separarPipe(_campo(csv, fila, 'especies_objetivo'));
    final sintomas = _campo(csv, fila, 'sintomas');
    final ventana = _campo(csv, fila, 'ventana_aviso');
    final manejo = _campo(csv, fila, 'manejo_cultural');
    final declaracion = _campo(csv, fila, 'declaracion_oficial') == 'si';
    final riesgoSanitario = _campo(csv, fila, 'riesgo_sanitario_publico') == 'si';
    final notas = _campo(csv, fila, 'notas');
    buf.writeln('  PlagaUrbana(');
    buf.writeln('    id: ${_escapeDart(id)},');
    buf.writeln('    nombreComun: ${_escapeDart(nComun)},');
    if (nCient.isNotEmpty) buf.writeln('    nombreCientifico: ${_escapeDart(nCient)},');
    buf.writeln('    tipo: $tipoDart,');
    if (especies.isNotEmpty) {
      buf.writeln('    especiesObjetivo: [${especies.map(_escapeDart).join(', ')}],');
    }
    if (sintomas.isNotEmpty) buf.writeln('    sintomas: ${_escapeDart(sintomas)},');
    if (ventana.isNotEmpty) buf.writeln('    ventanaAviso: ${_escapeDart(ventana)},');
    if (manejo.isNotEmpty) buf.writeln('    manejoCultural: ${_escapeDart(manejo)},');
    if (declaracion) buf.writeln('    declaracionOficial: true,');
    if (riesgoSanitario) buf.writeln('    riesgoSanitarioPublico: true,');
    if (notas.isNotEmpty) buf.writeln('    notas: ${_escapeDart(notas)},');
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('PlagaUrbana? plagaUrbanaPorId(String id) {')
    ..writeln('  for (final p in catalogoPlagasUrbanas) {')
    ..writeln('    if (p.id == id) return p;')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Plagas que afectan a una especie concreta. Útil para sugerir actuaciones')
    ..writeln('/// preventivas según el censo del ayuntamiento.')
    ..writeln('List<PlagaUrbana> plagasParaEspecie(String idEspecie) {')
    ..writeln('  return catalogoPlagasUrbanas')
    ..writeln('      .where((p) => p.especiesObjetivo.contains(idEspecie))')
    ..writeln('      .toList();')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Plagas de declaración obligatoria — la app las destaca visualmente.')
    ..writeln('List<PlagaUrbana> patologiasDeclaracionObligatoria() {')
    ..writeln('  return catalogoPlagasUrbanas.where((p) => p.declaracionOficial).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Plagas con riesgo sanitario público (procesionaria, lagarta peluda).')
    ..writeln('List<PlagaUrbana> plagasConRiesgoSanitarioPublico() {')
    ..writeln('  return catalogoPlagasUrbanas.where((p) => p.riesgoSanitarioPublico).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Búsqueda fuzzy con fallback cruzado entre nombre común y científico.')
    ..writeln('PlagaUrbana? plagaUrbanaPorBusquedaFuzzy(String nombreComun, String nombreCientifico) {')
    ..writeln('  final consultaComun = _normalizar(nombreComun);')
    ..writeln('  final consultaCient = _normalizar(nombreCientifico);')
    ..writeln('  if (consultaComun.isEmpty && consultaCient.isEmpty) return null;')
    ..writeln('  for (final p in catalogoPlagasUrbanas) {')
    ..writeln('    if (consultaCient.isNotEmpty && p.nombreCientifico.isNotEmpty &&')
    ..writeln('        _normalizar(p.nombreCientifico).contains(consultaCient)) {')
    ..writeln('      return p;')
    ..writeln('    }')
    ..writeln('    if (consultaComun.isNotEmpty && _normalizar(p.nombreComun).contains(consultaComun)) {')
    ..writeln('      return p;')
    ..writeln('    }')
    ..writeln('  }')
    ..writeln('  for (final p in catalogoPlagasUrbanas) {')
    ..writeln('    if (consultaComun.isNotEmpty && p.nombreCientifico.isNotEmpty &&')
    ..writeln('        _normalizar(p.nombreCientifico).contains(consultaComun)) {')
    ..writeln('      return p;')
    ..writeln('    }')
    ..writeln('    if (consultaCient.isNotEmpty &&')
    ..writeln('        _normalizar(p.nombreComun).contains(consultaCient)) {')
    ..writeln('      return p;')
    ..writeln('    }')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln('List<PlagaUrbana> buscarPlagasUrbanas(String texto) {')
    ..writeln('  final consultaNormalizada = _normalizar(texto);')
    ..writeln('  if (consultaNormalizada.isEmpty) return const [];')
    ..writeln('  return catalogoPlagasUrbanas.where((p) {')
    ..writeln('    return _normalizar(p.nombreComun).contains(consultaNormalizada) ||')
    ..writeln('        _normalizar(p.nombreCientifico).contains(consultaNormalizada) ||')
    ..writeln('        _normalizar(p.id).contains(consultaNormalizada);')
    ..writeln('  }).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln(_funcionNormalizar());

  await _escribir('catalogo_plagas_urbanas.dart', buf.toString());
  print('  ✓ catalogo_plagas_urbanas.dart  (${csv.totalFilas} entradas, ${csv.revisadas} revisadas)');
}

// ─── Tipos de poda ─────────────────────────────────────────

Future<void> _compilarTiposPoda() async {
  final csv = await _leer('tipos_poda.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'tipos_poda.csv', csv: csv))
    ..writeln('/// Intensidad de la poda — orientativa para evaluar el impacto sobre el árbol.')
    ..writeln('enum IntensidadPoda { baja, media, alta, muyAlta, variable }')
    ..writeln()
    ..writeln('class TipoPoda {')
    ..writeln('  final String id;')
    ..writeln('  final String nombreCanonico;')
    ..writeln('  final String descripcion;')
    ..writeln('  final String epocaRecomendada;')
    ..writeln('  final IntensidadPoda intensidad;')
    ..writeln('  /// `true` si la práctica está en debate técnico — el técnico debe justificar su uso.')
    ..writeln('  final bool controvertida;')
    ..writeln('  final String notas;')
    ..writeln()
    ..writeln('  const TipoPoda({')
    ..writeln('    required this.id,')
    ..writeln('    required this.nombreCanonico,')
    ..writeln('    required this.descripcion,')
    ..writeln('    required this.epocaRecomendada,')
    ..writeln('    required this.intensidad,')
    ..writeln('    this.controvertida = false,')
    ..writeln('    this.notas = \'\',')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<TipoPoda> catalogoTiposPoda = [');
  for (final fila in csv.filas) {
    final id = _campo(csv, fila, 'id');
    final nombre = _campo(csv, fila, 'nombre_canonico');
    final descripcion = _campo(csv, fila, 'descripcion');
    final epoca = _campo(csv, fila, 'epoca_recomendada');
    final intensidadTxt = _campo(csv, fila, 'intensidad');
    final intensidadDart = switch (intensidadTxt) {
      'baja' => 'IntensidadPoda.baja',
      'media' => 'IntensidadPoda.media',
      'alta' => 'IntensidadPoda.alta',
      'muy_alta' => 'IntensidadPoda.muyAlta',
      'variable' => 'IntensidadPoda.variable',
      _ => throw Exception('Intensidad desconocida en tipos_poda.csv: "$intensidadTxt" (id=$id)'),
    };
    final controvertida = _campo(csv, fila, 'controvertida') == 'si';
    final notas = _campo(csv, fila, 'notas');
    buf.writeln('  TipoPoda(');
    buf.writeln('    id: ${_escapeDart(id)},');
    buf.writeln('    nombreCanonico: ${_escapeDart(nombre)},');
    buf.writeln('    descripcion: ${_escapeDart(descripcion)},');
    buf.writeln('    epocaRecomendada: ${_escapeDart(epoca)},');
    buf.writeln('    intensidad: $intensidadDart,');
    if (controvertida) buf.writeln('    controvertida: true,');
    if (notas.isNotEmpty) buf.writeln('    notas: ${_escapeDart(notas)},');
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('TipoPoda? tipoPodaPorId(String id) {')
    ..writeln('  for (final t in catalogoTiposPoda) {')
    ..writeln('    if (t.id == id) return t;')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln('List<TipoPoda> tiposPodaNoControvertidos() {')
    ..writeln('  return catalogoTiposPoda.where((t) => !t.controvertida).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln('List<TipoPoda> buscarTiposPoda(String texto) {')
    ..writeln('  final consultaNormalizada = _normalizar(texto);')
    ..writeln('  if (consultaNormalizada.isEmpty) return const [];')
    ..writeln('  return catalogoTiposPoda.where((t) {')
    ..writeln('    return _normalizar(t.id).contains(consultaNormalizada) ||')
    ..writeln('        _normalizar(t.nombreCanonico).contains(consultaNormalizada);')
    ..writeln('  }).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln(_funcionNormalizar());

  await _escribir('catalogo_tipos_poda.dart', buf.toString());
  print('  ✓ catalogo_tipos_poda.dart  (${csv.totalFilas} tipos, ${csv.revisadas} revisados)');
}

// ─── Sustratos / alcorques ─────────────────────────────────

Future<void> _compilarSustratosAlcorque() async {
  final csv = await _leer('sustratos_alcorque.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'sustratos_alcorque.csv', csv: csv))
    ..writeln('enum PermeabilidadAlcorque { alta, media, baja, nula }')
    ..writeln()
    ..writeln('enum FacilidadRiego { directa, indirecta, dificil }')
    ..writeln()
    ..writeln('class SustratoAlcorque {')
    ..writeln('  final String id;')
    ..writeln('  final String nombreCanonico;')
    ..writeln('  final PermeabilidadAlcorque permeabilidad;')
    ..writeln('  final FacilidadRiego facilidadRiego;')
    ..writeln('  final String notas;')
    ..writeln()
    ..writeln('  const SustratoAlcorque({')
    ..writeln('    required this.id,')
    ..writeln('    required this.nombreCanonico,')
    ..writeln('    required this.permeabilidad,')
    ..writeln('    required this.facilidadRiego,')
    ..writeln('    this.notas = \'\',')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<SustratoAlcorque> catalogoSustratosAlcorque = [');
  for (final fila in csv.filas) {
    final id = _campo(csv, fila, 'id');
    final nombre = _campo(csv, fila, 'nombre_canonico');
    final permTxt = _campo(csv, fila, 'permeabilidad');
    final permDart = switch (permTxt) {
      'alta' => 'PermeabilidadAlcorque.alta',
      'media' => 'PermeabilidadAlcorque.media',
      'baja' => 'PermeabilidadAlcorque.baja',
      'nula' => 'PermeabilidadAlcorque.nula',
      _ => throw Exception('Permeabilidad desconocida: "$permTxt" (id=$id)'),
    };
    final riegoTxt = _campo(csv, fila, 'facilidad_riego');
    final riegoDart = switch (riegoTxt) {
      'directa' => 'FacilidadRiego.directa',
      'indirecta' => 'FacilidadRiego.indirecta',
      'dificil' => 'FacilidadRiego.dificil',
      _ => throw Exception('Facilidad de riego desconocida: "$riegoTxt" (id=$id)'),
    };
    final notas = _campo(csv, fila, 'notas');
    buf.writeln('  SustratoAlcorque(');
    buf.writeln('    id: ${_escapeDart(id)},');
    buf.writeln('    nombreCanonico: ${_escapeDart(nombre)},');
    buf.writeln('    permeabilidad: $permDart,');
    buf.writeln('    facilidadRiego: $riegoDart,');
    if (notas.isNotEmpty) buf.writeln('    notas: ${_escapeDart(notas)},');
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('SustratoAlcorque? sustratoAlcorquePorId(String id) {')
    ..writeln('  for (final s in catalogoSustratosAlcorque) {')
    ..writeln('    if (s.id == id) return s;')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln('List<SustratoAlcorque> buscarSustratosAlcorque(String texto) {')
    ..writeln('  final consultaNormalizada = _normalizar(texto);')
    ..writeln('  if (consultaNormalizada.isEmpty) return const [];')
    ..writeln('  return catalogoSustratosAlcorque.where((s) {')
    ..writeln('    return _normalizar(s.id).contains(consultaNormalizada) ||')
    ..writeln('        _normalizar(s.nombreCanonico).contains(consultaNormalizada);')
    ..writeln('  }).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln(_funcionNormalizar());

  await _escribir('catalogo_sustratos_alcorque.dart', buf.toString());
  print('  ✓ catalogo_sustratos_alcorque.dart  (${csv.totalFilas} sustratos, ${csv.revisadas} revisados)');
}

// ─── Calendario arbolado ──────────────────────────────────

Future<void> _compilarCalendarioArbolado() async {
  final csv = await _leer('tareas_calendario.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'tareas_calendario.csv', csv: csv))
    ..writeln('/// Zona climática orientativa peninsular.')
    ..writeln('/// Norte = Galicia/Cantábrica/Vasconia/Pirineos/Norte Castilla.')
    ..writeln('/// Centro = Mesetas/Sistema Central.')
    ..writeln('/// Sur = Andalucía/Extremadura/Murcia/Levante.')
    ..writeln('enum ZonaClimaticaArbolado { norte, centro, sur }')
    ..writeln()
    ..writeln('class TareaCalendarioArbolado {')
    ..writeln('  final ZonaClimaticaArbolado zona;')
    ..writeln('  final String tareaId;')
    ..writeln('  final String nombreVisible;')
    ..writeln('  final int mes;')
    ..writeln('  /// 1 = días 1-10, 2 = días 11-20, 3 = días 21-fin.')
    ..writeln('  final int decada;')
    ..writeln('  final String notas;')
    ..writeln()
    ..writeln('  const TareaCalendarioArbolado({')
    ..writeln('    required this.zona,')
    ..writeln('    required this.tareaId,')
    ..writeln('    required this.nombreVisible,')
    ..writeln('    required this.mes,')
    ..writeln('    required this.decada,')
    ..writeln('    this.notas = \'\',')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<TareaCalendarioArbolado> calendarioArbolado = [');
  for (final fila in csv.filas) {
    final zonaTxt = _campo(csv, fila, 'zona');
    final zonaDart = switch (zonaTxt) {
      'norte' => 'ZonaClimaticaArbolado.norte',
      'centro' => 'ZonaClimaticaArbolado.centro',
      'sur' => 'ZonaClimaticaArbolado.sur',
      _ => throw Exception('Zona desconocida en tareas_calendario.csv: "$zonaTxt"'),
    };
    final tareaId = _campo(csv, fila, 'tarea_id');
    final nombreVisible = _campo(csv, fila, 'nombre_visible');
    final mes = int.parse(_campo(csv, fila, 'mes'));
    final decada = int.parse(_campo(csv, fila, 'decada'));
    final notas = _campo(csv, fila, 'notas');
    buf.writeln('  TareaCalendarioArbolado(');
    buf.writeln('    zona: $zonaDart,');
    buf.writeln('    tareaId: ${_escapeDart(tareaId)},');
    buf.writeln('    nombreVisible: ${_escapeDart(nombreVisible)},');
    buf.writeln('    mes: $mes,');
    buf.writeln('    decada: $decada,');
    if (notas.isNotEmpty) buf.writeln('    notas: ${_escapeDart(notas)},');
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('/// Tareas de una zona ordenadas por fecha (mes/década).')
    ..writeln('List<TareaCalendarioArbolado> tareasDeZona(ZonaClimaticaArbolado zona) {')
    ..writeln('  final filtradas = calendarioArbolado.where((t) => t.zona == zona).toList();')
    ..writeln('  filtradas.sort((a, b) {')
    ..writeln('    final cmpMes = a.mes.compareTo(b.mes);')
    ..writeln('    if (cmpMes != 0) return cmpMes;')
    ..writeln('    return a.decada.compareTo(b.decada);')
    ..writeln('  });')
    ..writeln('  return filtradas;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Tareas próximas para una zona y fecha — útil para "qué toca esta semana".')
    ..writeln('List<TareaCalendarioArbolado> tareasProximas({')
    ..writeln('  required ZonaClimaticaArbolado zona,')
    ..writeln('  required DateTime fecha,')
    ..writeln('  int limite = 3,')
    ..writeln('}) {')
    ..writeln('  final tareas = tareasDeZona(zona);')
    ..writeln('  if (tareas.isEmpty) return const [];')
    ..writeln('  final decadaActual = (fecha.day - 1) ~/ 10 + 1;')
    ..writeln('  final claveActual = fecha.month * 10 + decadaActual.clamp(1, 3);')
    ..writeln('  final futuras = tareas')
    ..writeln('      .where((t) => t.mes * 10 + t.decada >= claveActual)')
    ..writeln('      .toList();')
    ..writeln('  if (futuras.length >= limite) return futuras.take(limite).toList();')
    ..writeln('  final restantes = limite - futuras.length;')
    ..writeln('  return [...futuras, ...tareas.take(restantes)];')
    ..writeln('}');

  await _escribir('catalogo_calendario_arbolado.dart', buf.toString());
  print('  ✓ catalogo_calendario_arbolado.dart  (${csv.totalFilas} tareas, ${csv.revisadas} revisadas)');
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
