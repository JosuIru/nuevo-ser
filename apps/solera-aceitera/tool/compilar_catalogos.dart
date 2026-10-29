// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings
// Compilador de catálogos curados de Larrea Aceitera.
//
// Lee los 5 CSVs de `content/aceitera/` y genera los ficheros `.dart`
// en `lib/datos/catalogos_generados/`. El parser CSV está inline para
// que el script sea ejecutable con `dart run` sin resolver las
// dependencias Flutter del core — la lógica es la misma que
// `nuevo_ser_core/lib/src/csv/csv_io.dart` y la análoga de los demás
// forks Larrea (viticultura/apícola/arbolado/quesera).
//
// Ejecución:
//   cd apps/solera-aceitera
//   dart run tool/compilar_catalogos.dart
//
// El script:
//  1. Skipea líneas que empiezan por `#` (cabecera-comentario).
//  2. Lee cabecera de columnas reales y filas.
//  3. Cuenta filas revisadas (`revisado_por` no vacío) vs sin revisar.
//  4. Genera el `.dart` con disclaimer + timestamp.
//
// El disclaimer "DATOS PROVISIONALES SIN VALIDAR" se mantiene mientras
// haya >= 1 fila sin revisar. Cuando todas tengan `revisado_por`
// rellenas, pasa a "REVISADO POR <listado>". Esto da feedback al
// asesor sobre el progreso de validación.

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
  final delim =
      primeraLinea.contains(';') && !primeraLinea.contains(',') ? ';' : ',';
  final filasCrudas = <List<String>>[];
  for (final linea in contenido.split('\n')) {
    final limpia =
        linea.endsWith('\r') ? linea.substring(0, linea.length - 1) : linea;
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

const _rutaContent = '../../content/aceitera';
const _rutaSalida = 'lib/datos/catalogos_generados';

void main() async {
  print('Compilando catálogos de Larrea Aceitera…\n');
  await _compilarVariedades();
  await _compilarPlagas();
  await _compilarFitosanitarios();
  await _compilarDopAceite();
  await _compilarCalendarioOlivar();
  await _escribirFlagRevision();
  if (_todasRevisadasGlobal) {
    print('\n✅ Todas las filas revisadas. El banner "datos provisionales" '
        'queda desactivado.');
  } else {
    print('\n⚠ Hay filas sin revisar. La app mostrará el banner "datos '
        'provisionales" hasta que el asesor agrónomo olivarero las valide.');
  }
  print('Hecho. Recuerda ejecutar `flutter analyze` y `flutter test`.');
}

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
  var revisadas = 0;
  for (final fila in tabla.filas) {
    if (indiceRevisado >= 0 &&
        indiceRevisado < fila.length &&
        fila[indiceRevisado].trim().isNotEmpty) {
      revisadas++;
    }
  }
  return _CsvLeido(
      tabla.cabecera, tabla.filas, tabla.filas.length, revisadas);
}

String _cabeceraDart({
  required String nombreCsv,
  required _CsvLeido csv,
}) {
  final ahora = DateTime.now();
  final fecha =
      '${ahora.year}-${_dosCifras(ahora.month)}-${_dosCifras(ahora.day)}';
  final lineas = StringBuffer();
  lineas.writeln('// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.');
  lineas.writeln('//');
  lineas.writeln('// Fuente: content/aceitera/$nombreCsv');
  lineas.writeln('// Generado: $fecha');
  lineas.writeln(
      '// Filas: ${csv.totalFilas} (${csv.revisadas} revisadas, '
      '${csv.totalFilas - csv.revisadas} pendientes de revisión)');
  if (csv.todasRevisadas) {
    lineas.writeln('// Estado: ✅ todas las filas revisadas por: '
        '${csv.revisores.join(", ")}');
  } else {
    lineas.writeln('//');
    lineas
        .writeln('// ⚠ DATOS PROVISIONALES SIN VALIDAR AGRONÓMICAMENTE.');
    lineas.writeln(
        '// La app muestra un banner mientras este flag siga activo.');
    lineas.writeln('// Para regenerar: cd apps/solera-aceitera && '
        'dart run tool/compilar_catalogos.dart');
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
  return s
      .split('|')
      .map((x) => x.trim())
      .where((x) => x.isNotEmpty)
      .toList();
}

String _campo(_CsvLeido csv, List<String> fila, String nombreColumna) {
  final i = csv.cabecera.indexOf(nombreColumna);
  if (i < 0 || i >= fila.length) return '';
  return fila[i].trim();
}

bool _todasRevisadasGlobal = true;

// ─── Variedades de olivo ───────────────────────────────────

Future<void> _compilarVariedades() async {
  final csv = await _leer('variedades_olivo.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'variedades_olivo.csv', csv: csv))
    ..writeln(
        '/// Color predominante de la aceituna en madurez. Útil para destacar')
    ..writeln('/// variedades de mesa frente a almazara en el formulario.')
    ..writeln('enum ColorAceituna { verde, negra, morada }')
    ..writeln()
    ..writeln(
        '/// Aptitud principal de la variedad. Algunas (manzanilla cacereña,')
    ..writeln('/// hojiblanca, verdial) son de doble aptitud.')
    ..writeln('enum UsoOlivar { almazara, mesa, mesaAlmazara }')
    ..writeln()
    ..writeln('class VariedadOlivo {')
    ..writeln('  final String id;')
    ..writeln('  final String nombreCanonico;')
    ..writeln('  final ColorAceituna color;')
    ..writeln('  final UsoOlivar uso;')
    ..writeln('  final String zonaPrincipal;')
    ..writeln('  final List<String> sinonimias;')
    ..writeln()
    ..writeln('  const VariedadOlivo({')
    ..writeln('    required this.id,')
    ..writeln('    required this.nombreCanonico,')
    ..writeln('    required this.color,')
    ..writeln('    required this.uso,')
    ..writeln('    this.zonaPrincipal = \'\',')
    ..writeln('    this.sinonimias = const [],')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<VariedadOlivo> catalogoVariedadesOlivo = [');
  for (final fila in csv.filas) {
    final id = _campo(csv, fila, 'id');
    final nombre = _campo(csv, fila, 'nombre_canonico');
    final colorTxt = _campo(csv, fila, 'color_aceituna');
    final usoTxt = _campo(csv, fila, 'uso');
    final zona = _campo(csv, fila, 'zona_principal');
    final sinos = _separarPipe(_campo(csv, fila, 'sinonimias'));
    final colorDart = switch (colorTxt) {
      'verde' => 'ColorAceituna.verde',
      'negra' => 'ColorAceituna.negra',
      'morada' => 'ColorAceituna.morada',
      _ => throw Exception(
          'Color desconocido en variedades_olivo.csv: "$colorTxt" (id=$id)'),
    };
    final usoDart = switch (usoTxt) {
      'almazara' => 'UsoOlivar.almazara',
      'mesa' => 'UsoOlivar.mesa',
      'mesa_almazara' => 'UsoOlivar.mesaAlmazara',
      _ => throw Exception(
          'Uso desconocido en variedades_olivo.csv: "$usoTxt" (id=$id)'),
    };
    buf.writeln('  VariedadOlivo(');
    buf.writeln('    id: ${_escapeDart(id)},');
    buf.writeln('    nombreCanonico: ${_escapeDart(nombre)},');
    buf.writeln('    color: $colorDart,');
    buf.writeln('    uso: $usoDart,');
    if (zona.isNotEmpty) {
      buf.writeln('    zonaPrincipal: ${_escapeDart(zona)},');
    }
    if (sinos.isNotEmpty) {
      buf.writeln(
          '    sinonimias: [${sinos.map(_escapeDart).join(', ')}],');
    }
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('VariedadOlivo? variedadOlivoPorId(String id) {')
    ..writeln('  for (final v in catalogoVariedadesOlivo) {')
    ..writeln('    if (v.id == id) return v;')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln(
        '/// Búsqueda fuzzy: id exacto > nombre canónico > sinonimias.')
    ..writeln('List<VariedadOlivo> buscarVariedadesOlivo(String texto) {')
    ..writeln('  final q = _normalizar(texto);')
    ..writeln('  if (q.isEmpty) return const [];')
    ..writeln('  return catalogoVariedadesOlivo.where((v) {')
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

  await _escribir('catalogo_variedades_olivo.dart', buf.toString());
  print('  ✓ catalogo_variedades_olivo.dart  '
      '(${csv.totalFilas} variedades, ${csv.revisadas} revisadas)');
}

// ─── Plagas y enfermedades del olivar ──────────────────────

Future<void> _compilarPlagas() async {
  final csv = await _leer('plagas_olivo.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'plagas_olivo.csv', csv: csv))
    ..writeln('/// Tipo de patología. Para el formulario de incidencia los')
    ..writeln('/// `abiotico` se mapean a `otro` (no hay distinción en BD).')
    ..writeln('enum TipoPatologiaOlivo { plaga, enfermedad, fisiologico, abiotico }')
    ..writeln()
    ..writeln('class PlagaOlivo {')
    ..writeln('  final String id;')
    ..writeln('  final String nombreComun;')
    ..writeln('  final String nombreCientifico;')
    ..writeln('  final TipoPatologiaOlivo tipo;')
    ..writeln('  final String sintomas;')
    ..writeln('  final String condicionesFavorables;')
    ..writeln('  final String manejoCultural;')
    ..writeln('  /// `true` para enfermedades reguladas de declaración obligatoria')
    ..writeln('  /// a Servicios Fitosanitarios CCAA (Xylella, Verticillium en')
    ..writeln('  /// algunas zonas). La app las destaca con banner rojo.')
    ..writeln('  final bool declaracionOficial;')
    ..writeln()
    ..writeln('  const PlagaOlivo({')
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
    ..writeln('const List<PlagaOlivo> catalogoPlagasOlivo = [');
  for (final fila in csv.filas) {
    final id = _campo(csv, fila, 'id');
    final nComun = _campo(csv, fila, 'nombre_comun');
    final nCient = _campo(csv, fila, 'nombre_cientifico');
    final tipoTxt = _campo(csv, fila, 'tipo');
    final tipoDart = switch (tipoTxt) {
      'plaga' => 'TipoPatologiaOlivo.plaga',
      'enfermedad' => 'TipoPatologiaOlivo.enfermedad',
      'fisiologico' => 'TipoPatologiaOlivo.fisiologico',
      'abiotico' => 'TipoPatologiaOlivo.abiotico',
      _ => throw Exception(
          'Tipo desconocido en plagas_olivo.csv: "$tipoTxt" (id=$id)'),
    };
    final sintomas = _campo(csv, fila, 'sintomas');
    final condiciones = _campo(csv, fila, 'condiciones_favorables');
    final manejo = _campo(csv, fila, 'manejo_cultural');
    final declaracion = _campo(csv, fila, 'declaracion_oficial') == 'si';
    buf.writeln('  PlagaOlivo(');
    buf.writeln('    id: ${_escapeDart(id)},');
    buf.writeln('    nombreComun: ${_escapeDart(nComun)},');
    if (nCient.isNotEmpty) {
      buf.writeln('    nombreCientifico: ${_escapeDart(nCient)},');
    }
    buf.writeln('    tipo: $tipoDart,');
    if (sintomas.isNotEmpty) {
      buf.writeln('    sintomas: ${_escapeDart(sintomas)},');
    }
    if (condiciones.isNotEmpty) {
      buf.writeln('    condicionesFavorables: ${_escapeDart(condiciones)},');
    }
    if (manejo.isNotEmpty) {
      buf.writeln('    manejoCultural: ${_escapeDart(manejo)},');
    }
    if (declaracion) buf.writeln('    declaracionOficial: true,');
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('PlagaOlivo? plagaOlivoPorId(String id) {')
    ..writeln('  for (final p in catalogoPlagasOlivo) {')
    ..writeln('    if (p.id == id) return p;')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln(
        '/// Plagas de declaración obligatoria — la app las destaca con banner rojo.')
    ..writeln('List<PlagaOlivo> patologiasDeclaracionObligatoria() {')
    ..writeln(
        '  return catalogoPlagasOlivo.where((p) => p.declaracionOficial).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln('List<PlagaOlivo> buscarPlagasOlivo(String texto) {')
    ..writeln('  final q = _normalizar(texto);')
    ..writeln('  if (q.isEmpty) return const [];')
    ..writeln('  return catalogoPlagasOlivo.where((p) {')
    ..writeln('    return _normalizar(p.nombreComun).contains(q) ||')
    ..writeln('        _normalizar(p.nombreCientifico).contains(q) ||')
    ..writeln('        _normalizar(p.id).contains(q);')
    ..writeln('  }).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln(_funcionNormalizar());

  await _escribir('catalogo_plagas_olivo.dart', buf.toString());
  print('  ✓ catalogo_plagas_olivo.dart  '
      '(${csv.totalFilas} patologías, ${csv.revisadas} revisadas)');
}

// ─── Fitosanitarios (sustancias activas) ───────────────────

Future<void> _compilarFitosanitarios() async {
  final csv = await _leer('fitosanitarios_olivar.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'fitosanitarios_olivar.csv', csv: csv))
    ..writeln('class FitosanitarioOlivar {')
    ..writeln('  final String id;')
    ..writeln('  final String nombreCanonico;')
    ..writeln('  /// IDs de plagas_olivo para las que está autorizada.')
    ..writeln('  final List<String> plagasObjetivo;')
    ..writeln('  /// insecticida / fungicida / acaricida / herbicida / biorracional.')
    ..writeln('  final String tipoAccion;')
    ..writeln('  /// Plazo de seguridad orientativo en días.')
    ..writeln('  /// ⚠ Verificar etiqueta del producto comercial vigente.')
    ..writeln('  final int plazoSeguridadOrientativoDias;')
    ..writeln('  final bool autorizadaEcologico;')
    ..writeln('  final String notas;')
    ..writeln()
    ..writeln('  const FitosanitarioOlivar({')
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
    ..writeln('const List<FitosanitarioOlivar> catalogoFitosanitariosOlivar = [');
  for (final fila in csv.filas) {
    final id = _campo(csv, fila, 'id');
    final nombre = _campo(csv, fila, 'nombre_canonico');
    final plagas = _separarPipe(_campo(csv, fila, 'plagas_objetivo'));
    final tipoAccion = _campo(csv, fila, 'tipo_accion');
    final plazo =
        int.tryParse(_campo(csv, fila, 'plazo_seguridad_orient')) ?? 0;
    final ecologico = _campo(csv, fila, 'ecologico') == 'si';
    final notas = _campo(csv, fila, 'notas');
    buf.writeln('  FitosanitarioOlivar(');
    buf.writeln('    id: ${_escapeDart(id)},');
    buf.writeln('    nombreCanonico: ${_escapeDart(nombre)},');
    if (plagas.isEmpty) {
      buf.writeln('    plagasObjetivo: [],');
    } else {
      buf.writeln(
          '    plagasObjetivo: [${plagas.map(_escapeDart).join(', ')}],');
    }
    buf.writeln('    tipoAccion: ${_escapeDart(tipoAccion)},');
    buf.writeln('    plazoSeguridadOrientativoDias: $plazo,');
    buf.writeln('    autorizadaEcologico: $ecologico,');
    if (notas.isNotEmpty) {
      buf.writeln('    notas: ${_escapeDart(notas)},');
    }
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('FitosanitarioOlivar? fitosanitarioOlivarPorId(String id) {')
    ..writeln('  for (final f in catalogoFitosanitariosOlivar) {')
    ..writeln('    if (f.id == id) return f;')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Filtra sustancias activas autorizadas para una plaga concreta.')
    ..writeln('List<FitosanitarioOlivar> fitosanitariosParaPlaga(String idPlaga) {')
    ..writeln('  return catalogoFitosanitariosOlivar')
    ..writeln('      .where((f) => f.plagasObjetivo.contains(idPlaga))')
    ..writeln('      .toList();')
    ..writeln('}')
    ..writeln()
    ..writeln('List<FitosanitarioOlivar> buscarFitosanitariosOlivar(String texto) {')
    ..writeln('  final q = _normalizar(texto);')
    ..writeln('  if (q.isEmpty) return const [];')
    ..writeln('  return catalogoFitosanitariosOlivar.where((f) {')
    ..writeln('    return _normalizar(f.nombreCanonico).contains(q) ||')
    ..writeln('        _normalizar(f.id).contains(q);')
    ..writeln('  }).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln(_funcionNormalizar());

  await _escribir('catalogo_fitosanitarios_olivar.dart', buf.toString());
  print('  ✓ catalogo_fitosanitarios_olivar.dart  '
      '(${csv.totalFilas} sustancias, ${csv.revisadas} revisadas)');
}

// ─── DOPs aceite ──────────────────────────────────────────

Future<void> _compilarDopAceite() async {
  final csv = await _leer('do_aceite.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'do_aceite.csv', csv: csv))
    ..writeln('class DopAceite {')
    ..writeln('  final String id;')
    ..writeln('  final String nombreCanonico;')
    ..writeln('  final String provincia;')
    ..writeln('  /// IDs de variedades_olivo principales del pliego.')
    ..writeln('  final List<String> variedadesPrincipales;')
    ..writeln('  /// Acidez máxima permitida (grados sobre 100 g de aceite).')
    ..writeln('  final double? acidezMax;')
    ..writeln('  final String notas;')
    ..writeln()
    ..writeln('  const DopAceite({')
    ..writeln('    required this.id,')
    ..writeln('    required this.nombreCanonico,')
    ..writeln('    required this.provincia,')
    ..writeln('    required this.variedadesPrincipales,')
    ..writeln('    this.acidezMax,')
    ..writeln('    this.notas = \'\',')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<DopAceite> catalogoDopAceite = [');
  for (final fila in csv.filas) {
    final id = _campo(csv, fila, 'id');
    final nombre = _campo(csv, fila, 'nombre_canonico');
    final provincia = _campo(csv, fila, 'provincia');
    final variedades = _separarPipe(_campo(csv, fila, 'variedades_principales'));
    final acidezTxt = _campo(csv, fila, 'acidez_max');
    final acidez = double.tryParse(acidezTxt);
    final notas = _campo(csv, fila, 'notas');
    buf.writeln('  DopAceite(');
    buf.writeln('    id: ${_escapeDart(id)},');
    buf.writeln('    nombreCanonico: ${_escapeDart(nombre)},');
    buf.writeln('    provincia: ${_escapeDart(provincia)},');
    if (variedades.isEmpty) {
      buf.writeln('    variedadesPrincipales: [],');
    } else {
      buf.writeln('    variedadesPrincipales: [${variedades.map(_escapeDart).join(', ')}],');
    }
    if (acidez != null) {
      buf.writeln('    acidezMax: $acidez,');
    }
    if (notas.isNotEmpty) {
      buf.writeln('    notas: ${_escapeDart(notas)},');
    }
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('DopAceite? dopAceitePorId(String id) {')
    ..writeln('  for (final d in catalogoDopAceite) {')
    ..writeln('    if (d.id == id) return d;')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln('List<DopAceite> buscarDopAceite(String texto) {')
    ..writeln('  final q = _normalizar(texto);')
    ..writeln('  if (q.isEmpty) return const [];')
    ..writeln('  return catalogoDopAceite.where((d) {')
    ..writeln('    return _normalizar(d.nombreCanonico).contains(q) ||')
    ..writeln('        _normalizar(d.provincia).contains(q) ||')
    ..writeln('        _normalizar(d.id).contains(q);')
    ..writeln('  }).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln(_funcionNormalizar());

  await _escribir('catalogo_dop_aceite.dart', buf.toString());
  print('  ✓ catalogo_dop_aceite.dart  '
      '(${csv.totalFilas} DOPs, ${csv.revisadas} revisadas)');
}

// ─── Calendario olivar ────────────────────────────────────

Future<void> _compilarCalendarioOlivar() async {
  final csv = await _leer('calendario_olivar.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'calendario_olivar.csv', csv: csv))
    ..writeln('/// Zonas productivas olivareras de la península e islas.')
    ..writeln('enum ZonaOlivar {')
    ..writeln('  andaluciaOccidental,')
    ..writeln('  andaluciaOriental,')
    ..writeln('  extremadura,')
    ..writeln('  castillaLaMancha,')
    ..writeln('  levante,')
    ..writeln('  nordeste,')
    ..writeln('  mesetaNorte,')
    ..writeln('}')
    ..writeln()
    ..writeln('class EventoCalendarioOlivar {')
    ..writeln('  final ZonaOlivar zona;')
    ..writeln('  final String evento;')
    ..writeln('  final String nombreEvento;')
    ..writeln('  /// Meses 1-12 (mes inicial habitual).')
    ..writeln('  final int mesInicioAprox;')
    ..writeln('  /// Meses 1-12 (mes final habitual). Si fin < inicio, cruza el año.')
    ..writeln('  final int mesFinAprox;')
    ..writeln('  final String notas;')
    ..writeln()
    ..writeln('  const EventoCalendarioOlivar({')
    ..writeln('    required this.zona,')
    ..writeln('    required this.evento,')
    ..writeln('    required this.nombreEvento,')
    ..writeln('    required this.mesInicioAprox,')
    ..writeln('    required this.mesFinAprox,')
    ..writeln('    this.notas = \'\',')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<EventoCalendarioOlivar> calendarioOlivar = [');
  for (final fila in csv.filas) {
    final zonaTxt = _campo(csv, fila, 'zona');
    final zonaDart = switch (zonaTxt) {
      'andalucia_occidental' => 'ZonaOlivar.andaluciaOccidental',
      'andalucia_oriental' => 'ZonaOlivar.andaluciaOriental',
      'extremadura' => 'ZonaOlivar.extremadura',
      'castilla_la_mancha' => 'ZonaOlivar.castillaLaMancha',
      'levante' => 'ZonaOlivar.levante',
      'nordeste' => 'ZonaOlivar.nordeste',
      'meseta_norte' => 'ZonaOlivar.mesetaNorte',
      _ => throw Exception(
          'Zona desconocida en calendario_olivar.csv: "$zonaTxt"'),
    };
    final evento = _campo(csv, fila, 'evento');
    final nombre = _campo(csv, fila, 'nombre_evento');
    final mesIni = int.parse(_campo(csv, fila, 'mes_inicio_aprox'));
    final mesFin = int.parse(_campo(csv, fila, 'mes_fin_aprox'));
    final notas = _campo(csv, fila, 'notas');
    buf.writeln('  EventoCalendarioOlivar(');
    buf.writeln('    zona: $zonaDart,');
    buf.writeln('    evento: ${_escapeDart(evento)},');
    buf.writeln('    nombreEvento: ${_escapeDart(nombre)},');
    buf.writeln('    mesInicioAprox: $mesIni,');
    buf.writeln('    mesFinAprox: $mesFin,');
    if (notas.isNotEmpty) {
      buf.writeln('    notas: ${_escapeDart(notas)},');
    }
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('/// Eventos del calendario para una zona, en orden de inicio.')
    ..writeln('List<EventoCalendarioOlivar> calendarioDeZona(ZonaOlivar zona) {')
    ..writeln('  final filtrados = calendarioOlivar')
    ..writeln('      .where((e) => e.zona == zona)')
    ..writeln('      .toList();')
    ..writeln('  filtrados.sort((a, b) => a.mesInicioAprox.compareTo(b.mesInicioAprox));')
    ..writeln('  return filtrados;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Devuelve los eventos activos en un mes concreto (1-12).')
    ..writeln('/// Si `mesFin < mesInicio` el evento cruza el año (recolección')
    ..writeln('/// principal típicamente noviembre-enero).')
    ..writeln('List<EventoCalendarioOlivar> eventosActivosEn({')
    ..writeln('  required ZonaOlivar zona,')
    ..writeln('  required int mes,')
    ..writeln('}) {')
    ..writeln('  return calendarioDeZona(zona).where((e) {')
    ..writeln('    if (e.mesInicioAprox <= e.mesFinAprox) {')
    ..writeln('      return mes >= e.mesInicioAprox && mes <= e.mesFinAprox;')
    ..writeln('    }')
    ..writeln('    return mes >= e.mesInicioAprox || mes <= e.mesFinAprox;')
    ..writeln('  }).toList();')
    ..writeln('}');

  await _escribir('catalogo_calendario_olivar.dart', buf.toString());
  print('  ✓ catalogo_calendario_olivar.dart  '
      '(${csv.totalFilas} eventos, ${csv.revisadas} revisados)');
}

// ─── Flag global de revisión ──────────────────────────────

Future<void> _escribirFlagRevision() async {
  final buf = StringBuffer()
    ..writeln('// GENERADO AUTOMÁTICAMENTE por tool/compilar_catalogos.dart.')
    ..writeln('//')
    ..writeln('// Flag global: true si TODAS las filas de los 5 catálogos tienen')
    ..writeln('// `revisado_por` no vacío. La app lo lee para mostrar/ocultar el')
    ..writeln('// banner "datos provisionales sin validar agronómicamente".')
    ..writeln()
    ..writeln('const bool catalogosCompletamenteRevisados = '
        '$_todasRevisadasGlobal;');
  await _escribir('flag_revision.dart', buf.toString());
}

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
