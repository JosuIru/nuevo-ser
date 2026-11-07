// ignore_for_file: avoid_print
// Compilador de catálogos de Larrea Ganadera: content/ganadera/*.csv →
// lib/datos/catalogos_generados/. Lo común está en el core.
//
//   cd apps/solera-ganadera && dart run tool/compilar_catalogos.dart

import '../../../packages/nuevo_ser_core/tool/catalogos/compilador_catalogos.dart';

final compilador = CompiladorCatalogos(
    carpetaContent: 'ganadera', carpetaApp: 'solera-ganadera');

String _texto(CsvCatalogo csv, List<String> fila, String columna) =>
    escaparDart(csv.campo(fila, columna));

String _numero(String texto) =>
    texto.trim().isEmpty ? 'null' : double.parse(texto).toString();

String _entero(String texto) =>
    texto.trim().isEmpty ? 'null' : int.parse(texto).toString();

/// Catálogo con su propia clase de campos `String`/`double`/`int`.
Future<void> _compilar({
  required String csvNombre,
  required String ficheroDart,
  required String clase,
  required String lista,
  required Map<String, String> camposConTipo,
  required String Function(CsvCatalogo csv, List<String> fila) fila,
}) async {
  final csv = await compilador.leer(csvNombre);
  final salida = StringBuffer()
    ..write(compilador.cabeceraDart(nombreCsv: csvNombre, csv: csv))
    ..writeln('class $clase {')
    ..writeln('  const $clase({'
        '${camposConTipo.keys.map((campo) => 'required this.$campo').join(', ')}});')
    ..writeln();
  camposConTipo
      .forEach((campo, tipo) => salida.writeln('  final $tipo $campo;'));
  salida
    ..writeln('}')
    ..writeln()
    ..writeln('const List<$clase> $lista = [');
  for (final datos in csv.filas) {
    salida.writeln('  ${fila(csv, datos)},');
  }
  salida.writeln('];');
  await compilador.escribir(ficheroDart, salida.toString());
  print('  $ficheroDart: ${csv.totalFilas} filas (${csv.firmadas} firmadas)');
}

/// La tabla UGM usa la clase del modelo (`CoeficienteUgm`).
Future<void> _compilarTablaUgm() async {
  const csvNombre = 'tabla_ugm.csv';
  final csv = await compilador.leer(csvNombre);
  final salida = StringBuffer()
    ..write(compilador.cabeceraDart(nombreCsv: csvNombre, csv: csv))
    ..writeln("import '../../modelos/carga_ganadera.dart';")
    ..writeln()
    ..writeln('const List<CoeficienteUgm> catalogoCoeficientesUgm = [');
  for (final datos in csv.filas) {
    final sexos = separarPipe(csv.campo(datos, 'sexos'));
    final maximo = csv.campo(datos, 'edad_max_meses');
    salida.writeln('  CoeficienteUgm('
        'tramite: ${_texto(csv, datos, 'tramite')}, '
        'especie: ${_texto(csv, datos, 'especie')}, '
        'sexos: {${sexos.map(escaparDart).join(', ')}}, '
        'edadMinimaMeses: ${_entero(csv.campo(datos, 'edad_min_meses'))}, '
        '${maximo.trim().isEmpty ? '' : 'edadMaximaMeses: ${_entero(maximo)}, '}'
        'ugm: ${_numero(csv.campo(datos, 'ugm'))}, '
        'categoria: ${_texto(csv, datos, 'categoria')}),');
  }
  salida.writeln('];');
  await compilador.escribir('catalogo_tabla_ugm.dart', salida.toString());
  print('  catalogo_tabla_ugm.dart: ${csv.totalFilas} filas');
}

Future<void> main() async {
  print('Compilando catálogos de Larrea Ganadera…');
  await _compilarTablaUgm();
  await _compilar(
    csvNombre: 'parametros_ecoregimen.csv',
    ficheroDart: 'catalogo_parametros_ecoregimen.dart',
    clase: 'ParametrosEcoregimen',
    lista: 'catalogoParametrosEcoregimen',
    camposConTipo: const {
      'tipoPasto': 'String',
      'cargaMinima': 'double',
      'cargaMaxima': 'double',
      'cargaMinimaReducida': 'double',
      'diasMinimos': 'int',
      'diasMinimosReducidos': 'int',
      'articulo': 'String',
    },
    fila: (csv, datos) => 'ParametrosEcoregimen('
        'tipoPasto: ${_texto(csv, datos, 'tipo_pasto')}, '
        'cargaMinima: ${_numero(csv.campo(datos, 'carga_minima'))}, '
        'cargaMaxima: ${_numero(csv.campo(datos, 'carga_maxima'))}, '
        'cargaMinimaReducida: ${_numero(csv.campo(datos, 'carga_minima_reducida'))}, '
        'diasMinimos: ${_entero(csv.campo(datos, 'dias_minimos'))}, '
        'diasMinimosReducidos: ${_entero(csv.campo(datos, 'dias_minimos_reducidos'))}, '
        'articulo: ${_texto(csv, datos, 'articulo')})',
  );
  await _compilar(
    csvNombre: 'especies.csv',
    ficheroDart: 'catalogo_especies.dart',
    clase: 'EspecieCatalogo',
    lista: 'catalogoEspecies',
    camposConTipo: const {
      'id': 'String',
      'nombreCientifico': 'String',
      'dispositivoHabitual': 'String',
    },
    fila: (csv, datos) => 'EspecieCatalogo('
        'id: ${_texto(csv, datos, 'id')}, '
        'nombreCientifico: ${_texto(csv, datos, 'nombre_cientifico')}, '
        'dispositivoHabitual: ${_texto(csv, datos, 'dispositivo_habitual')})',
  );
  await _compilar(
    csvNombre: 'razas.csv',
    ficheroDart: 'catalogo_razas.dart',
    clase: 'RazaCatalogo',
    lista: 'catalogoRazas',
    camposConTipo: const {'especie': 'String', 'nombre': 'String'},
    fila: (csv, datos) => 'RazaCatalogo('
        'especie: ${_texto(csv, datos, 'especie')}, '
        'nombre: ${_texto(csv, datos, 'nombre')})',
  );
  await _compilar(
    csvNombre: 'sustancias_activas.csv',
    ficheroDart: 'catalogo_sustancias_activas.dart',
    clase: 'SustanciaActivaCatalogo',
    lista: 'catalogoSustanciasActivas',
    camposConTipo: const {
      'id': 'String',
      'nombre': 'String',
      'clase': 'String',
      'grupo': 'String',
    },
    fila: (csv, datos) => 'SustanciaActivaCatalogo('
        'id: ${_texto(csv, datos, 'id')}, '
        'nombre: ${_texto(csv, datos, 'nombre')}, '
        'clase: ${_texto(csv, datos, 'clase')}, '
        'grupo: ${_texto(csv, datos, 'grupo')})',
  );
  await compilador.escribirFlagRevision(
    descripcionCatalogos: 'los 5 catálogos de Larrea Ganadera',
    textoBanner: 'datos provisionales sin validar',
  );
  print('catalogosCompletamenteRevisados = ${compilador.todasRevisadas}');
}
