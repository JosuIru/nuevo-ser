// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings
// Compilador de catálogos curados de Larrea Apícola.
//
// Lee los 5 CSVs de `content/apicola/` y genera los ficheros
// `.dart` en `lib/datos/catalogos_generados/`. Reproduce inline el
// parser CSV del `nuevo_ser_core` (mismo algoritmo que csv_io.dart)
// para que el script sea ejecutable con `dart run` sin resolver las
// dependencias Flutter del core.
//
// Ejecución:
//   cd apps/solera-apicola
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

const _rutaContent = '../../content/apicola';
const _rutaSalida = 'lib/datos/catalogos_generados';

void main() async {
  print('Compilando catálogos de Larrea Apícola…\n');
  await _compilarRazasAbeja();
  await _compilarTiposColmena();
  await _compilarSustanciasVarroa();
  await _compilarPlagasApicolas();
  await _compilarCalendarioApicola();
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
  lineas.writeln('// Fuente: content/apicola/$nombreCsv');
  lineas.writeln('// Generado: $fecha');
  lineas.writeln('// Filas: ${csv.totalFilas} (${csv.revisadas} revisadas, ${csv.totalFilas - csv.revisadas} pendientes de revisión)');
  if (csv.todasRevisadas) {
    lineas.writeln('// Estado: ✅ todas las filas revisadas por: ${csv.revisores.join(", ")}');
  } else {
    lineas.writeln('//');
    lineas.writeln('// ⚠ DATOS PROVISIONALES SIN VALIDAR POR VETERINARIO APÍCOLA NI APICULTOR ASESOR.');
    lineas.writeln('// La app muestra un banner mientras este flag siga activo.');
    lineas.writeln('// Para regenerar: cd apps/solera-apicola && dart run tool/compilar_catalogos.dart');
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

// ─── Razas de abeja ────────────────────────────────────────

Future<void> _compilarRazasAbeja() async {
  final csv = await _leer('razas_abeja.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'razas_abeja.csv', csv: csv))
    ..writeln('class RazaAbeja {')
    ..writeln('  final String id;')
    ..writeln('  final String nombreCanonico;')
    ..writeln('  /// Subespecie taxonómica. Vacía para líneas comerciales (Buckfast) e híbridos.')
    ..writeln('  final String subespecie;')
    ..writeln('  final String origenGeografico;')
    ..writeln('  final List<String> sinonimias;')
    ..writeln('  final List<String> caracter;')
    ..writeln('  final String notas;')
    ..writeln()
    ..writeln('  const RazaAbeja({')
    ..writeln('    required this.id,')
    ..writeln('    required this.nombreCanonico,')
    ..writeln('    this.subespecie = \'\',')
    ..writeln('    required this.origenGeografico,')
    ..writeln('    this.sinonimias = const [],')
    ..writeln('    this.caracter = const [],')
    ..writeln('    this.notas = \'\',')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<RazaAbeja> catalogoRazasAbeja = [');
  for (final fila in csv.filas) {
    final id = _campo(csv, fila, 'id');
    final nombre = _campo(csv, fila, 'nombre_canonico');
    final subespecie = _campo(csv, fila, 'subespecie');
    final origen = _campo(csv, fila, 'origen_geografico');
    final sinos = _separarPipe(_campo(csv, fila, 'sinonimias'));
    final caracter = _separarPipe(_campo(csv, fila, 'caracter'));
    final notas = _campo(csv, fila, 'notas');
    buf.writeln('  RazaAbeja(');
    buf.writeln('    id: ${_escapeDart(id)},');
    buf.writeln('    nombreCanonico: ${_escapeDart(nombre)},');
    if (subespecie.isNotEmpty) {
      buf.writeln('    subespecie: ${_escapeDart(subespecie)},');
    }
    buf.writeln('    origenGeografico: ${_escapeDart(origen)},');
    if (sinos.isNotEmpty) {
      buf.writeln('    sinonimias: [${sinos.map(_escapeDart).join(', ')}],');
    }
    if (caracter.isNotEmpty) {
      buf.writeln('    caracter: [${caracter.map(_escapeDart).join(', ')}],');
    }
    if (notas.isNotEmpty) {
      buf.writeln('    notas: ${_escapeDart(notas)},');
    }
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('RazaAbeja? razaAbejaPorId(String id) {')
    ..writeln('  for (final r in catalogoRazasAbeja) {')
    ..writeln('    if (r.id == id) return r;')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Búsqueda fuzzy: id exacto > nombre canónico > subespecie > sinonimias.')
    ..writeln('List<RazaAbeja> buscarRazasAbeja(String texto) {')
    ..writeln('  final consultaNormalizada = _normalizar(texto);')
    ..writeln('  if (consultaNormalizada.isEmpty) return const [];')
    ..writeln('  return catalogoRazasAbeja.where((r) {')
    ..writeln('    if (r.id == consultaNormalizada) return true;')
    ..writeln('    if (_normalizar(r.nombreCanonico).contains(consultaNormalizada)) return true;')
    ..writeln('    if (r.subespecie.isNotEmpty && _normalizar(r.subespecie).contains(consultaNormalizada)) return true;')
    ..writeln('    for (final s in r.sinonimias) {')
    ..writeln('      if (_normalizar(s).contains(consultaNormalizada)) return true;')
    ..writeln('    }')
    ..writeln('    return false;')
    ..writeln('  }).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln(_funcionNormalizar());

  await _escribir('catalogo_razas_abeja.dart', buf.toString());
  print('  ✓ catalogo_razas_abeja.dart  (${csv.totalFilas} razas, ${csv.revisadas} revisadas)');
}

// ─── Tipos de colmena ──────────────────────────────────────

Future<void> _compilarTiposColmena() async {
  final csv = await _leer('tipos_colmena.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'tipos_colmena.csv', csv: csv))
    ..writeln('/// Forma constructiva de la colmena.')
    ..writeln('enum FormatoColmena { fijaHorizontal, verticalAlza, topBar, tronco }')
    ..writeln()
    ..writeln('class TipoColmena {')
    ..writeln('  final String id;')
    ..writeln('  final String nombreCanonico;')
    ..writeln('  final FormatoColmena formato;')
    ..writeln('  /// Cuadros en la cámara de cría — 0 si tronco o top-bar.')
    ..writeln('  final int numeroCuadrosCamara;')
    ..writeln('  final bool apilableAlzas;')
    ..writeln('  final String usoTradicional;')
    ..writeln('  final List<String> ventajas;')
    ..writeln('  final List<String> desventajas;')
    ..writeln('  final String notas;')
    ..writeln()
    ..writeln('  const TipoColmena({')
    ..writeln('    required this.id,')
    ..writeln('    required this.nombreCanonico,')
    ..writeln('    required this.formato,')
    ..writeln('    required this.numeroCuadrosCamara,')
    ..writeln('    required this.apilableAlzas,')
    ..writeln('    this.usoTradicional = \'\',')
    ..writeln('    this.ventajas = const [],')
    ..writeln('    this.desventajas = const [],')
    ..writeln('    this.notas = \'\',')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<TipoColmena> catalogoTiposColmena = [');
  for (final fila in csv.filas) {
    final id = _campo(csv, fila, 'id');
    final nombre = _campo(csv, fila, 'nombre_canonico');
    final formatoTxt = _campo(csv, fila, 'formato');
    final formatoDart = switch (formatoTxt) {
      'fija_horizontal' => 'FormatoColmena.fijaHorizontal',
      'vertical_alza' => 'FormatoColmena.verticalAlza',
      'top_bar' => 'FormatoColmena.topBar',
      'tronco' => 'FormatoColmena.tronco',
      _ => throw Exception('Formato desconocido en tipos_colmena.csv: "$formatoTxt" (id=$id)'),
    };
    final cuadros = int.tryParse(_campo(csv, fila, 'numero_cuadros_camara')) ?? 0;
    final apilableTxt = _campo(csv, fila, 'apilable_alzas');
    final apilable = apilableTxt == 'si';
    final uso = _campo(csv, fila, 'uso_tradicional');
    final ventajas = _separarPipe(_campo(csv, fila, 'ventajas'));
    final desventajas = _separarPipe(_campo(csv, fila, 'desventajas'));
    final notas = _campo(csv, fila, 'notas');
    buf.writeln('  TipoColmena(');
    buf.writeln('    id: ${_escapeDart(id)},');
    buf.writeln('    nombreCanonico: ${_escapeDart(nombre)},');
    buf.writeln('    formato: $formatoDart,');
    buf.writeln('    numeroCuadrosCamara: $cuadros,');
    buf.writeln('    apilableAlzas: $apilable,');
    if (uso.isNotEmpty) buf.writeln('    usoTradicional: ${_escapeDart(uso)},');
    if (ventajas.isNotEmpty) {
      buf.writeln('    ventajas: [${ventajas.map(_escapeDart).join(', ')}],');
    }
    if (desventajas.isNotEmpty) {
      buf.writeln('    desventajas: [${desventajas.map(_escapeDart).join(', ')}],');
    }
    if (notas.isNotEmpty) buf.writeln('    notas: ${_escapeDart(notas)},');
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('TipoColmena? tipoColmenaPorId(String id) {')
    ..writeln('  for (final t in catalogoTiposColmena) {')
    ..writeln('    if (t.id == id) return t;')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln('List<TipoColmena> buscarTiposColmena(String texto) {')
    ..writeln('  final consultaNormalizada = _normalizar(texto);')
    ..writeln('  if (consultaNormalizada.isEmpty) return const [];')
    ..writeln('  return catalogoTiposColmena.where((t) {')
    ..writeln('    return _normalizar(t.id).contains(consultaNormalizada) ||')
    ..writeln('        _normalizar(t.nombreCanonico).contains(consultaNormalizada);')
    ..writeln('  }).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln(_funcionNormalizar());

  await _escribir('catalogo_tipos_colmena.dart', buf.toString());
  print('  ✓ catalogo_tipos_colmena.dart  (${csv.totalFilas} tipos, ${csv.revisadas} revisados)');
}

// ─── Sustancias para varroa ────────────────────────────────

Future<void> _compilarSustanciasVarroa() async {
  final csv = await _leer('sustancias_varroa.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'sustancias_varroa.csv', csv: csv))
    ..writeln('/// Familia química de la sustancia activa.')
    ..writeln('enum FamiliaSustanciaVarroa { organica, sintetica, naturalAceiteEsencial }')
    ..writeln()
    ..writeln('/// Vehículo de aplicación principal. Cada uno requiere material distinto.')
    ..writeln('enum VehiculoSustanciaVarroa { sublimacion, goteo, sandwich, tiraPolimero, nebulizacion }')
    ..writeln()
    ..writeln('/// Eficacia orientativa contra varroa en condiciones ideales.')
    ..writeln('/// ⚠ La eficacia real depende de temperatura, humedad y carga de cría.')
    ..writeln('enum EficaciaSustanciaVarroa { baja, media, alta, muyAlta }')
    ..writeln()
    ..writeln('/// Ventana óptima de aplicación durante el ciclo apícola.')
    ..writeln('enum VentanaAplicacionVarroa { invernada, primavera, otono, sinPostura, conPostura }')
    ..writeln()
    ..writeln('class SustanciaVarroa {')
    ..writeln('  final String id;')
    ..writeln('  final String nombreCanonico;')
    ..writeln('  final FamiliaSustanciaVarroa familia;')
    ..writeln('  final VehiculoSustanciaVarroa vehiculoPrincipal;')
    ..writeln('  final EficaciaSustanciaVarroa eficaciaOrientativa;')
    ..writeln('  /// Plazo de seguridad orientativo en días. ⚠ Verificar etiqueta del producto.')
    ..writeln('  final int plazoSeguridadDias;')
    ..writeln('  final bool autorizadaEcologico;')
    ..writeln('  final VentanaAplicacionVarroa ventanaAplicacion;')
    ..writeln('  final String notas;')
    ..writeln()
    ..writeln('  const SustanciaVarroa({')
    ..writeln('    required this.id,')
    ..writeln('    required this.nombreCanonico,')
    ..writeln('    required this.familia,')
    ..writeln('    required this.vehiculoPrincipal,')
    ..writeln('    required this.eficaciaOrientativa,')
    ..writeln('    required this.plazoSeguridadDias,')
    ..writeln('    required this.autorizadaEcologico,')
    ..writeln('    required this.ventanaAplicacion,')
    ..writeln('    this.notas = \'\',')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<SustanciaVarroa> catalogoSustanciasVarroa = [');
  for (final fila in csv.filas) {
    final id = _campo(csv, fila, 'id');
    final nombre = _campo(csv, fila, 'nombre_canonico');
    final familiaTxt = _campo(csv, fila, 'familia');
    final familiaDart = switch (familiaTxt) {
      'organica' => 'FamiliaSustanciaVarroa.organica',
      'sintetica' => 'FamiliaSustanciaVarroa.sintetica',
      'natural_aceite_esencial' => 'FamiliaSustanciaVarroa.naturalAceiteEsencial',
      _ => throw Exception('Familia desconocida en sustancias_varroa.csv: "$familiaTxt" (id=$id)'),
    };
    final vehiculoTxt = _campo(csv, fila, 'vehiculo_principal');
    final vehiculoDart = switch (vehiculoTxt) {
      'sublimacion' => 'VehiculoSustanciaVarroa.sublimacion',
      'goteo' => 'VehiculoSustanciaVarroa.goteo',
      'sandwich' => 'VehiculoSustanciaVarroa.sandwich',
      'tira_polimero' => 'VehiculoSustanciaVarroa.tiraPolimero',
      'nebulizacion' => 'VehiculoSustanciaVarroa.nebulizacion',
      _ => throw Exception('Vehículo desconocido: "$vehiculoTxt" (id=$id)'),
    };
    final eficaciaTxt = _campo(csv, fila, 'eficacia_orientativa');
    final eficaciaDart = switch (eficaciaTxt) {
      'baja' => 'EficaciaSustanciaVarroa.baja',
      'media' => 'EficaciaSustanciaVarroa.media',
      'alta' => 'EficaciaSustanciaVarroa.alta',
      'muy_alta' => 'EficaciaSustanciaVarroa.muyAlta',
      _ => throw Exception('Eficacia desconocida: "$eficaciaTxt" (id=$id)'),
    };
    final plazo = int.tryParse(_campo(csv, fila, 'plazo_seguridad_dias')) ?? 0;
    final ecologico = _campo(csv, fila, 'autorizada_ecologico') == 'si';
    final ventanaTxt = _campo(csv, fila, 'ventana_aplicacion');
    final ventanaDart = switch (ventanaTxt) {
      'invernada' => 'VentanaAplicacionVarroa.invernada',
      'primavera' => 'VentanaAplicacionVarroa.primavera',
      'otono' => 'VentanaAplicacionVarroa.otono',
      'sin_postura' => 'VentanaAplicacionVarroa.sinPostura',
      'con_postura' => 'VentanaAplicacionVarroa.conPostura',
      _ => throw Exception('Ventana desconocida: "$ventanaTxt" (id=$id)'),
    };
    final notas = _campo(csv, fila, 'notas');
    buf.writeln('  SustanciaVarroa(');
    buf.writeln('    id: ${_escapeDart(id)},');
    buf.writeln('    nombreCanonico: ${_escapeDart(nombre)},');
    buf.writeln('    familia: $familiaDart,');
    buf.writeln('    vehiculoPrincipal: $vehiculoDart,');
    buf.writeln('    eficaciaOrientativa: $eficaciaDart,');
    buf.writeln('    plazoSeguridadDias: $plazo,');
    buf.writeln('    autorizadaEcologico: $ecologico,');
    buf.writeln('    ventanaAplicacion: $ventanaDart,');
    if (notas.isNotEmpty) buf.writeln('    notas: ${_escapeDart(notas)},');
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('SustanciaVarroa? sustanciaVarroaPorId(String id) {')
    ..writeln('  for (final s in catalogoSustanciasVarroa) {')
    ..writeln('    if (s.id == id) return s;')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Filtra sustancias por ventana de aplicación. Útil cuando el apicultor')
    ..writeln('/// abre el formulario en pleno otoño y quiere ver qué sustancias proceden.')
    ..writeln('List<SustanciaVarroa> sustanciasParaVentana(VentanaAplicacionVarroa ventana) {')
    ..writeln('  return catalogoSustanciasVarroa')
    ..writeln('      .where((s) => s.ventanaAplicacion == ventana)')
    ..writeln('      .toList();')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Sólo sustancias autorizadas en producción ecológica.')
    ..writeln('List<SustanciaVarroa> sustanciasEcologico() {')
    ..writeln('  return catalogoSustanciasVarroa.where((s) => s.autorizadaEcologico).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln('List<SustanciaVarroa> buscarSustanciasVarroa(String texto) {')
    ..writeln('  final consultaNormalizada = _normalizar(texto);')
    ..writeln('  if (consultaNormalizada.isEmpty) return const [];')
    ..writeln('  return catalogoSustanciasVarroa.where((s) {')
    ..writeln('    return _normalizar(s.id).contains(consultaNormalizada) ||')
    ..writeln('        _normalizar(s.nombreCanonico).contains(consultaNormalizada);')
    ..writeln('  }).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln(_funcionNormalizar());

  await _escribir('catalogo_sustancias_varroa.dart', buf.toString());
  print('  ✓ catalogo_sustancias_varroa.dart  (${csv.totalFilas} sustancias, ${csv.revisadas} revisadas)');
}

// ─── Plagas y patologías apícolas ──────────────────────────

Future<void> _compilarPlagasApicolas() async {
  final csv = await _leer('plagas_apicolas.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'plagas_apicolas.csv', csv: csv))
    ..writeln('/// Categoría de la incidencia apícola.')
    ..writeln('enum TipoPlagaApicola { parasito, infeccion, plagaFisica, depredador, abiotico }')
    ..writeln()
    ..writeln('class PlagaApicola {')
    ..writeln('  final String id;')
    ..writeln('  final String nombreComun;')
    ..writeln('  final String nombreCientifico;')
    ..writeln('  final TipoPlagaApicola tipo;')
    ..writeln('  final String sintomas;')
    ..writeln('  final String condicionesFavorables;')
    ..writeln('  final String manejoCultural;')
    ..writeln('  /// `true` para enfermedades de declaración obligatoria al servicio veterinario oficial.')
    ..writeln('  final bool declaracionOficial;')
    ..writeln('  final String notas;')
    ..writeln()
    ..writeln('  const PlagaApicola({')
    ..writeln('    required this.id,')
    ..writeln('    required this.nombreComun,')
    ..writeln('    this.nombreCientifico = \'\',')
    ..writeln('    required this.tipo,')
    ..writeln('    this.sintomas = \'\',')
    ..writeln('    this.condicionesFavorables = \'\',')
    ..writeln('    this.manejoCultural = \'\',')
    ..writeln('    this.declaracionOficial = false,')
    ..writeln('    this.notas = \'\',')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<PlagaApicola> catalogoPlagasApicolas = [');
  for (final fila in csv.filas) {
    final id = _campo(csv, fila, 'id');
    final nComun = _campo(csv, fila, 'nombre_comun');
    final nCient = _campo(csv, fila, 'nombre_cientifico');
    final tipoTxt = _campo(csv, fila, 'tipo');
    final tipoDart = switch (tipoTxt) {
      'parasito' => 'TipoPlagaApicola.parasito',
      'infeccion' => 'TipoPlagaApicola.infeccion',
      'plaga_fisica' => 'TipoPlagaApicola.plagaFisica',
      'depredador' => 'TipoPlagaApicola.depredador',
      'abiotico' => 'TipoPlagaApicola.abiotico',
      _ => throw Exception('Tipo desconocido en plagas_apicolas.csv: "$tipoTxt" (id=$id)'),
    };
    final sintomas = _campo(csv, fila, 'sintomas');
    final condiciones = _campo(csv, fila, 'condiciones_favorables');
    final manejo = _campo(csv, fila, 'manejo_cultural');
    final declaracion = _campo(csv, fila, 'declaracion_oficial') == 'si';
    final notas = _campo(csv, fila, 'notas');
    buf.writeln('  PlagaApicola(');
    buf.writeln('    id: ${_escapeDart(id)},');
    buf.writeln('    nombreComun: ${_escapeDart(nComun)},');
    if (nCient.isNotEmpty) {
      buf.writeln('    nombreCientifico: ${_escapeDart(nCient)},');
    }
    buf.writeln('    tipo: $tipoDart,');
    if (sintomas.isNotEmpty) buf.writeln('    sintomas: ${_escapeDart(sintomas)},');
    if (condiciones.isNotEmpty) {
      buf.writeln('    condicionesFavorables: ${_escapeDart(condiciones)},');
    }
    if (manejo.isNotEmpty) buf.writeln('    manejoCultural: ${_escapeDart(manejo)},');
    if (declaracion) buf.writeln('    declaracionOficial: true,');
    if (notas.isNotEmpty) buf.writeln('    notas: ${_escapeDart(notas)},');
    buf.writeln('  ),');
  }
  buf
    ..writeln('];')
    ..writeln()
    ..writeln('PlagaApicola? plagaApicolaPorId(String id) {')
    ..writeln('  for (final p in catalogoPlagasApicolas) {')
    ..writeln('    if (p.id == id) return p;')
    ..writeln('  }')
    ..writeln('  return null;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Mapea una entrada del catálogo al string `tipo` que persiste el modelo')
    ..writeln('/// `IncidenciaApicola`. Combina id concreto + categoría taxonómica:')
    ..writeln('///  - id `polilla_cera` → polilla_cera')
    ..writeln('///  - id `vespa_velutina` → vespa_velutina')
    ..writeln('///  - id `robo` → robo')
    ..writeln('///  - parasito o infeccion → sanitario')
    ..writeln('///  - resto (plagaFisica salvo polilla, depredador salvo vespa, abiotico) → otro')
    ..writeln('String tipoIncidenciaParaBd(PlagaApicola plaga) {')
    ..writeln('  switch (plaga.id) {')
    ..writeln('    case \'polilla_cera\':')
    ..writeln('      return \'polilla_cera\';')
    ..writeln('    case \'vespa_velutina\':')
    ..writeln('      return \'vespa_velutina\';')
    ..writeln('    case \'robo\':')
    ..writeln('      return \'robo\';')
    ..writeln('  }')
    ..writeln('  switch (plaga.tipo) {')
    ..writeln('    case TipoPlagaApicola.parasito:')
    ..writeln('    case TipoPlagaApicola.infeccion:')
    ..writeln('      return \'sanitario\';')
    ..writeln('    case TipoPlagaApicola.plagaFisica:')
    ..writeln('    case TipoPlagaApicola.depredador:')
    ..writeln('    case TipoPlagaApicola.abiotico:')
    ..writeln('      return \'otro\';')
    ..writeln('  }')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Búsqueda fuzzy para validar diagnósticos del modal IA.')
    ..writeln('/// Prueba primero los campos correspondientes (común↔común, científico↔científico)')
    ..writeln('/// y si nada matchea hace fallback cruzado, porque la IA y los apicultores')
    ..writeln('/// tienden a usar el nombre científico en cualquier campo.')
    ..writeln('PlagaApicola? plagaApicolaPorBusquedaFuzzy(String nombreComun, String nombreCientifico) {')
    ..writeln('  final consultaComun = _normalizar(nombreComun);')
    ..writeln('  final consultaCient = _normalizar(nombreCientifico);')
    ..writeln('  if (consultaComun.isEmpty && consultaCient.isEmpty) return null;')
    ..writeln('  // Pasada estricta: campo a campo.')
    ..writeln('  for (final p in catalogoPlagasApicolas) {')
    ..writeln('    if (consultaCient.isNotEmpty && p.nombreCientifico.isNotEmpty &&')
    ..writeln('        _normalizar(p.nombreCientifico).contains(consultaCient)) {')
    ..writeln('      return p;')
    ..writeln('    }')
    ..writeln('    if (consultaComun.isNotEmpty && _normalizar(p.nombreComun).contains(consultaComun)) {')
    ..writeln('      return p;')
    ..writeln('    }')
    ..writeln('  }')
    ..writeln('  // Pasada cruzada: el nombre común podría llevar el binomio latino y viceversa.')
    ..writeln('  for (final p in catalogoPlagasApicolas) {')
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
    ..writeln('List<PlagaApicola> buscarPlagasApicolas(String texto) {')
    ..writeln('  final consultaNormalizada = _normalizar(texto);')
    ..writeln('  if (consultaNormalizada.isEmpty) return const [];')
    ..writeln('  return catalogoPlagasApicolas.where((p) {')
    ..writeln('    return _normalizar(p.nombreComun).contains(consultaNormalizada) ||')
    ..writeln('        _normalizar(p.nombreCientifico).contains(consultaNormalizada) ||')
    ..writeln('        _normalizar(p.id).contains(consultaNormalizada);')
    ..writeln('  }).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Patologías de declaración obligatoria — la app las destaca visualmente.')
    ..writeln('List<PlagaApicola> patologiasDeclaracionObligatoria() {')
    ..writeln('  return catalogoPlagasApicolas.where((p) => p.declaracionOficial).toList();')
    ..writeln('}')
    ..writeln()
    ..writeln(_funcionNormalizar());

  await _escribir('catalogo_plagas_apicolas.dart', buf.toString());
  print('  ✓ catalogo_plagas_apicolas.dart  (${csv.totalFilas} entradas, ${csv.revisadas} revisadas)');
}

// ─── Calendario apícola ────────────────────────────────────

Future<void> _compilarCalendarioApicola() async {
  final csv = await _leer('calendario_apicola.csv');
  if (!csv.todasRevisadas) _todasRevisadasGlobal = false;
  final buf = StringBuffer()
    ..write(_cabeceraDart(nombreCsv: 'calendario_apicola.csv', csv: csv))
    ..writeln('/// Zona climática orientativa peninsular.')
    ..writeln('/// Norte = Galicia/Cantábrica/Vasconia/Pirineos/Norte Castilla.')
    ..writeln('/// Centro = Mesetas/Sistema Central.')
    ..writeln('/// Sur = Andalucía/Extremadura/Murcia/Levante.')
    ..writeln('enum ZonaClimaticaApicola { norte, centro, sur }')
    ..writeln()
    ..writeln('/// Tarea estandarizada del calendario apícola.')
    ..writeln('class TareaCalendarioApicola {')
    ..writeln('  final ZonaClimaticaApicola zona;')
    ..writeln('  final String tareaId;')
    ..writeln('  final String nombreVisible;')
    ..writeln('  final int mes;')
    ..writeln('  /// 1 = días 1-10, 2 = días 11-20, 3 = días 21-fin.')
    ..writeln('  final int decada;')
    ..writeln('  final String notas;')
    ..writeln()
    ..writeln('  const TareaCalendarioApicola({')
    ..writeln('    required this.zona,')
    ..writeln('    required this.tareaId,')
    ..writeln('    required this.nombreVisible,')
    ..writeln('    required this.mes,')
    ..writeln('    required this.decada,')
    ..writeln('    this.notas = \'\',')
    ..writeln('  });')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<TareaCalendarioApicola> calendarioApicola = [');
  for (final fila in csv.filas) {
    final zonaTxt = _campo(csv, fila, 'zona');
    final zonaDart = switch (zonaTxt) {
      'norte' => 'ZonaClimaticaApicola.norte',
      'centro' => 'ZonaClimaticaApicola.centro',
      'sur' => 'ZonaClimaticaApicola.sur',
      _ => throw Exception('Zona desconocida en calendario_apicola.csv: "$zonaTxt"'),
    };
    final tareaId = _campo(csv, fila, 'tarea_id');
    final nombreVisible = _campo(csv, fila, 'nombre_visible');
    final mes = int.parse(_campo(csv, fila, 'mes'));
    final decada = int.parse(_campo(csv, fila, 'decada'));
    final notas = _campo(csv, fila, 'notas');
    buf.writeln('  TareaCalendarioApicola(');
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
    ..writeln('List<TareaCalendarioApicola> tareasDeZona(ZonaClimaticaApicola zona) {')
    ..writeln('  final filtradas = calendarioApicola.where((t) => t.zona == zona).toList();')
    ..writeln('  filtradas.sort((a, b) {')
    ..writeln('    final cmpMes = a.mes.compareTo(b.mes);')
    ..writeln('    if (cmpMes != 0) return cmpMes;')
    ..writeln('    return a.decada.compareTo(b.decada);')
    ..writeln('  });')
    ..writeln('  return filtradas;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Tareas próximas para una zona y fecha — útil para "qué toca esta semana".')
    ..writeln('/// Devuelve hasta `limite` tareas con clave (mes×10+decada) >= clave actual.')
    ..writeln('List<TareaCalendarioApicola> tareasProximas({')
    ..writeln('  required ZonaClimaticaApicola zona,')
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
    ..writeln('  // Si no llegan a `limite` futuras, completar con las del año siguiente.')
    ..writeln('  final restantes = limite - futuras.length;')
    ..writeln('  return [...futuras, ...tareas.take(restantes)];')
    ..writeln('}');

  await _escribir('catalogo_calendario_apicola.dart', buf.toString());
  print('  ✓ catalogo_calendario_apicola.dart  (${csv.totalFilas} tareas, ${csv.revisadas} revisadas)');
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
