// ignore_for_file: avoid_print
// Compilador de catálogos de Larrea Obrador: content/obrador/*.csv →
// lib/datos/catalogos_generados/. Lo común está en el core.
//
//   cd apps/solera-obrador && dart run tool/compilar_catalogos.dart

import '../../../packages/nuevo_ser_core/tool/catalogos/compilador_catalogos.dart';

final compilador = CompiladorCatalogos(carpetaContent: 'obrador', carpetaApp: 'solera-obrador');

String _conjunto(String texto) =>
    '{${separarPipe(texto).map(escaparDart).join(', ')}}';

String _numero(String texto) => texto.trim().isEmpty ? 'null' : double.parse(texto).toString();

Future<void> _compilar({
  required String csvNombre,
  required String ficheroDart,
  required String clase,
  required String lista,
  required String campos,
  required String Function(CsvCatalogo csv, List<String> fila) fila,
}) async {
  final csv = await compilador.leer(csvNombre);
  final salida = StringBuffer()
    ..write(compilador.cabeceraDart(nombreCsv: csvNombre, csv: csv))
    ..writeln('class $clase {')
    ..writeln('  const $clase($campos);')
    ..writeln();
  for (final campo in RegExp(r'this\.(\w+)').allMatches(campos)) {
    final nombre = campo.group(1)!;
    final tipo = switch (nombre) {
      'alergenos' || 'trazas' => 'Set<String>',
      'salGramosPor100g' => 'double',
      'salMaximaGramosPor100g' => 'double?',
      _ => 'String',
    };
    salida.writeln('  final $tipo $nombre;');
  }
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

/// Campo de un catálogo de la guía: nombre en Dart, columna del CSV y tipo
/// (`String`, `double`, `bool` —«si»/«no»— o `List<String>` —separada por `|`—).
typedef CampoGuia = ({String dart, String columna, String tipo});

String _valorGuia(String texto, String tipo) => switch (tipo) {
      'double' => double.parse(texto).toString(),
      'bool' => (texto.toLowerCase() == 'si').toString(),
      'List<String>' => '[${separarPipe(texto).map(escaparDart).join(', ')}]',
      _ => escaparDart(texto),
    };

/// Compila un CSV de la guía del obrador. La guía **no cuenta** para el flag
/// de catálogos revisados: tiene su propio aviso fijo en pantalla.
Future<void> _compilarGuia({
  required String csvNombre,
  required String ficheroDart,
  required String clase,
  required String lista,
  required List<CampoGuia> campos,
}) async {
  final revisadasAntes = compilador.todasRevisadas;
  final csv = await compilador.leer(csvNombre);
  compilador.todasRevisadas = revisadasAntes;
  final salida = StringBuffer()
    ..write(compilador.cabeceraDart(nombreCsv: csvNombre, csv: csv))
    ..writeln('class $clase {')
    ..writeln('  const $clase({')
    ..writeAll([for (final campo in campos) '    required this.${campo.dart},\n'])
    ..writeln('  });')
    ..writeln();
  for (final campo in campos) {
    salida.writeln('  final ${campo.tipo} ${campo.dart};');
  }
  salida
    ..writeln('}')
    ..writeln()
    ..writeln('const List<$clase> $lista = [');
  for (final datos in csv.filas) {
    final valores = [
      for (final campo in campos)
        '${campo.dart}: ${_valorGuia(csv.campo(datos, campo.columna), campo.tipo)}'
    ];
    salida.writeln('  $clase(${valores.join(', ')}),');
  }
  salida.writeln('];');
  await compilador.escribir(ficheroDart, salida.toString());
  print('  $ficheroDart: ${csv.totalFilas} filas (guía, fuera del flag)');
}

Future<void> _compilarCatalogosGuia() async {
  await _compilarGuia(
    csvNombre: 'guia_recetas.csv',
    ficheroDart: 'catalogo_guia_recetas.dart',
    clase: 'RecetaGuia',
    lista: 'catalogoGuiaRecetas',
    campos: const [
      (dart: 'id', columna: 'id', tipo: 'String'),
      (dart: 'nombre', columna: 'nombre', tipo: 'String'),
      (dart: 'denominacion', columna: 'denominacion', tipo: 'String'),
      (dart: 'esSubreceta', columna: 'es_subreceta', tipo: 'bool'),
      (dart: 'hidratacionPorcentaje', columna: 'hidratacion_pct', tipo: 'double'),
      (dart: 'temperaturaMasaGrados', columna: 'temperatura_masa_c', tipo: 'double'),
      (dart: 'mermaCoccionPorcentaje', columna: 'merma_coccion_pct', tipo: 'double'),
      (dart: 'autolisis', columna: 'autolisis', tipo: 'String'),
      (dart: 'amasado', columna: 'amasado', tipo: 'String'),
      (dart: 'primeraFermentacion', columna: 'primera_fermentacion', tipo: 'String'),
      (dart: 'formado', columna: 'formado', tipo: 'String'),
      (dart: 'fermentacionFinal', columna: 'fermentacion_final', tipo: 'String'),
      (dart: 'coccion', columna: 'coccion', tipo: 'String'),
      (dart: 'senalHecho', columna: 'senal_hecho', tipo: 'String'),
      (dart: 'notas', columna: 'notas', tipo: 'String'),
      (dart: 'fuente', columna: 'fuente', tipo: 'String'),
      (dart: 'revisadoPor', columna: 'revisado_por', tipo: 'String'),
    ],
  );
  await _compilarGuia(
    csvNombre: 'guia_recetas_ingredientes.csv',
    ficheroDart: 'catalogo_guia_recetas_ingredientes.dart',
    clase: 'IngredienteRecetaGuia',
    lista: 'catalogoGuiaRecetasIngredientes',
    campos: const [
      (dart: 'recetaId', columna: 'receta_id', tipo: 'String'),
      (dart: 'ingredienteId', columna: 'ingrediente_id', tipo: 'String'),
      (dart: 'porcentaje', columna: 'porcentaje', tipo: 'double'),
      (dart: 'nota', columna: 'nota', tipo: 'String'),
      (dart: 'fuente', columna: 'fuente', tipo: 'String'),
      (dart: 'revisadoPor', columna: 'revisado_por', tipo: 'String'),
    ],
  );
  await _compilarGuia(
    csvNombre: 'guia_fichas.csv',
    ficheroDart: 'catalogo_guia_fichas.dart',
    clase: 'FichaGuiaObrador',
    lista: 'catalogoGuiaFichas',
    campos: const [
      (dart: 'id', columna: 'id', tipo: 'String'),
      (dart: 'seccion', columna: 'seccion', tipo: 'String'),
      (dart: 'titulo', columna: 'titulo', tipo: 'String'),
      (dart: 'parrafos', columna: 'texto', tipo: 'List<String>'),
      (dart: 'calculadora', columna: 'calculadora', tipo: 'String'),
      (dart: 'fuente', columna: 'fuente', tipo: 'String'),
      (dart: 'revisadoPor', columna: 'revisado_por', tipo: 'String'),
    ],
  );
}

Future<void> main() async {
  print('Compilando catálogos de Larrea Obrador…');
  await _compilar(
    csvNombre: 'alergenos.csv',
    ficheroDart: 'catalogo_alergenos.dart',
    clase: 'AlergenoCatalogo',
    lista: 'catalogoAlergenos',
    campos: '{required this.id, required this.nombre, required this.ejemplos}',
    fila: (csv, datos) => 'AlergenoCatalogo(id: ${escaparDart(csv.campo(datos, 'id'))}, '
        'nombre: ${escaparDart(csv.campo(datos, 'nombre'))}, '
        'ejemplos: ${escaparDart(csv.campo(datos, 'ejemplos'))})',
  );
  await _compilar(
    csvNombre: 'ingredientes_base.csv',
    ficheroDart: 'catalogo_ingredientes_base.dart',
    clase: 'IngredienteBase',
    lista: 'catalogoIngredientesBase',
    campos: '{required this.id, required this.nombre, required this.alergenos, '
        'required this.trazas, required this.salGramosPor100g}',
    fila: (csv, datos) => 'IngredienteBase(id: ${escaparDart(csv.campo(datos, 'id'))}, '
        'nombre: ${escaparDart(csv.campo(datos, 'nombre'))}, '
        'alergenos: ${_conjunto(csv.campo(datos, 'alergenos'))}, '
        'trazas: ${_conjunto(csv.campo(datos, 'trazas'))}, '
        'salGramosPor100g: ${_numero(csv.campo(datos, 'sal_g_100g'))})',
  );
  await _compilar(
    csvNombre: 'denominaciones_pan.csv',
    ficheroDart: 'catalogo_denominaciones_pan.dart',
    clase: 'DenominacionPan',
    lista: 'catalogoDenominacionesPan',
    campos: '{required this.id, required this.nombre, required this.articulo, '
        'required this.requisito, this.salMaximaGramosPor100g}',
    fila: (csv, datos) => 'DenominacionPan(id: ${escaparDart(csv.campo(datos, 'id'))}, '
        'nombre: ${escaparDart(csv.campo(datos, 'nombre'))}, '
        'articulo: ${escaparDart(csv.campo(datos, 'articulo'))}, '
        'requisito: ${escaparDart(csv.campo(datos, 'requisito'))}, '
        'salMaximaGramosPor100g: ${_numero(csv.campo(datos, 'sal_maxima_g_100g'))})',
  );
  await _compilar(
    csvNombre: 'controles_tipo.csv',
    ficheroDart: 'catalogo_controles_tipo.dart',
    clase: 'ControlTipo',
    lista: 'catalogoControlesTipo',
    campos: '{required this.id, required this.tipo, required this.elemento, '
        'required this.frecuenciaSugerida}',
    fila: (csv, datos) => 'ControlTipo(id: ${escaparDart(csv.campo(datos, 'id'))}, '
        'tipo: ${escaparDart(csv.campo(datos, 'tipo'))}, '
        'elemento: ${escaparDart(csv.campo(datos, 'elemento'))}, '
        'frecuenciaSugerida: ${escaparDart(csv.campo(datos, 'frecuencia_sugerida'))})',
  );
  await _compilarCatalogosGuia();
  await compilador.escribirFlagRevision(
    descripcionCatalogos: 'los 4 catálogos de Larrea Obrador',
    textoBanner: 'datos provisionales sin validar',
  );
  print('catalogosCompletamenteRevisados = ${compilador.todasRevisadas}');
}
