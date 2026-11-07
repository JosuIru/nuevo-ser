// ignore_for_file: avoid_print
// Compilador de catálogos de Larrea Sagardoa: content/sidra/*.csv →
// lib/datos/catalogos_generados/. Lo común está en el core.
//
//   cd apps/solera-sidra && dart run tool/compilar_catalogos.dart

import '../../../packages/nuevo_ser_core/tool/catalogos/compilador_catalogos.dart';

final compilador =
    CompiladorCatalogos(carpetaContent: 'sidra', carpetaApp: 'solera-sidra');

/// Tipo Dart de cada campo de los catálogos (el resto son `String`).
const Map<String, String> tiposCampos = {
  'plagasObjetivo': 'Set<String>',
  'tiposAccion': 'Set<String>',
  'plazoSeguridadMaxDias': 'int?',
  'ecologico': 'bool',
  'organismoRegulado': 'bool',
  'rendimientoEsLimite': 'bool',
  'gradoMin': 'double?',
  'acidezVolatilMaxGL': 'double?',
  'sulfurosoTotalMaxMgL': 'double?',
  'extractoSecoMinGL': 'double?',
  'densidadMostoMin': 'double?',
  'rendimientoMinPct': 'double?',
  'rendimientoMaxPct': 'double?',
};

String _texto(CsvCatalogo csv, List<String> fila, String columna) =>
    escaparDart(csv.campo(fila, columna));

String _conjunto(CsvCatalogo csv, List<String> fila, String columna) =>
    '{${separarPipe(csv.campo(fila, columna)).map(escaparDart).join(', ')}}';

String _decimal(CsvCatalogo csv, List<String> fila, String columna) {
  final valor = csv.campo(fila, columna);
  return valor.isEmpty ? 'null' : double.parse(valor).toString();
}

String _entero(CsvCatalogo csv, List<String> fila, String columna) {
  final valor = csv.campo(fila, columna);
  return valor.isEmpty ? 'null' : int.parse(valor).toString();
}

String _booleano(CsvCatalogo csv, List<String> fila, String columna) =>
    (csv.campo(fila, columna).toLowerCase() == 'si').toString();

/// Escribe un catálogo: clase con los [campos] (nombre Dart → expresión que
/// lo saca de cada fila) y la lista constante.
Future<void> _compilar({
  required String csvNombre,
  required String ficheroDart,
  required String clase,
  required String lista,
  required Map<String, String Function(CsvCatalogo csv, List<String> fila)>
      campos,
}) async {
  final csv = await compilador.leer(csvNombre);
  final salida = StringBuffer()
    ..write(compilador.cabeceraDart(nombreCsv: csvNombre, csv: csv))
    ..writeln('class $clase {')
    ..writeln('  const $clase({')
    ..writeAll(campos.keys.map((nombre) => '    required this.$nombre,\n'))
    ..writeln('  });')
    ..writeln();
  for (final nombre in campos.keys) {
    salida.writeln('  final ${tiposCampos[nombre] ?? 'String'} $nombre;');
  }
  salida
    ..writeln('}')
    ..writeln()
    ..writeln('const List<$clase> $lista = [');
  final ids = <String>{};
  for (final fila in csv.filas) {
    final id = csv.campo(fila, 'id');
    if (!ids.add(id)) throw Exception('$csvNombre: id repetido «$id»');
    final valores = campos.entries
        .map((campo) => '${campo.key}: ${campo.value(csv, fila)}')
        .join(', ');
    salida.writeln('  $clase($valores),');
  }
  salida.writeln('];');
  await compilador.escribir(ficheroDart, salida.toString());
  print('  $ficheroDart: ${csv.totalFilas} filas '
      '(${csv.revisadas} con revisión documental, ${csv.firmadas} firmadas)');
}

Future<void> main() async {
  print('Compilando catálogos de Larrea Sagardoa…');
  await _compilar(
    csvNombre: 'variedades_manzana.csv',
    ficheroDart: 'catalogo_variedades_manzana.dart',
    clase: 'VariedadManzana',
    lista: 'catalogoVariedadesManzana',
    campos: {
      'id': (csv, fila) => _texto(csv, fila, 'id'),
      'nombre': (csv, fila) => _texto(csv, fila, 'nombre'),
      'dop': (csv, fila) => _texto(csv, fila, 'dop'),
      'grupo': (csv, fila) => _texto(csv, fila, 'grupo'),
    },
  );
  await _compilar(
    csvNombre: 'variedades_uva_txakoli.csv',
    ficheroDart: 'catalogo_variedades_uva.dart',
    clase: 'VariedadUva',
    lista: 'catalogoVariedadesUva',
    campos: {
      'id': (csv, fila) => _texto(csv, fila, 'id'),
      'nombre': (csv, fila) => _texto(csv, fila, 'nombre'),
      'color': (csv, fila) => _texto(csv, fila, 'color'),
      'bizkaiko': (csv, fila) => _texto(csv, fila, 'bizkaiko'),
      'arabako': (csv, fila) => _texto(csv, fila, 'arabako'),
      'getariako': (csv, fila) => _texto(csv, fila, 'getariako'),
    },
  );
  await _compilar(
    csvNombre: 'plagas_manzano.csv',
    ficheroDart: 'catalogo_plagas_manzano.dart',
    clase: 'PlagaManzano',
    lista: 'catalogoPlagasManzano',
    campos: {
      'id': (csv, fila) => _texto(csv, fila, 'id'),
      'nombre': (csv, fila) => _texto(csv, fila, 'nombre'),
      'nombreCientifico': (csv, fila) => _texto(csv, fila, 'nombre_cientifico'),
      'tipo': (csv, fila) => _texto(csv, fila, 'tipo'),
      'organismoRegulado': (csv, fila) =>
          _booleano(csv, fila, 'organismo_regulado'),
      'sintomas': (csv, fila) => _texto(csv, fila, 'sintomas'),
    },
  );
  await _compilar(
    csvNombre: 'fitosanitarios_manzano.csv',
    ficheroDart: 'catalogo_fitosanitarios_manzano.dart',
    clase: 'SustanciaActivaManzano',
    lista: 'catalogoFitosanitariosManzano',
    campos: {
      'id': (csv, fila) => _texto(csv, fila, 'id'),
      'nombre': (csv, fila) => _texto(csv, fila, 'nombre'),
      'nombreUe': (csv, fila) => _texto(csv, fila, 'nombre_ue'),
      'plagasObjetivo': (csv, fila) => _conjunto(csv, fila, 'plagas_objetivo'),
      'tiposAccion': (csv, fila) => _conjunto(csv, fila, 'tipo_accion'),
      'plazoSeguridadMaxDias': (csv, fila) =>
          _entero(csv, fila, 'plazo_seguridad_max_dias'),
      'ecologico': (csv, fila) => _booleano(csv, fila, 'ecologico'),
      'aprobadaUeHasta': (csv, fila) => _texto(csv, fila, 'aprobada_ue_hasta'),
    },
  );
  await _compilar(
    csvNombre: 'dop_sidra_txakoli.csv',
    ficheroDart: 'catalogo_dop_sidra_txakoli.dart',
    clase: 'ProductoDop',
    lista: 'catalogoProductosDop',
    campos: {
      'id': (csv, fila) => _texto(csv, fila, 'id'),
      'nombre': (csv, fila) => _texto(csv, fila, 'nombre'),
      'dop': (csv, fila) => _texto(csv, fila, 'dop'),
      'producto': (csv, fila) => _texto(csv, fila, 'producto'),
      'gradoMin': (csv, fila) => _decimal(csv, fila, 'grado_min'),
      'acidezVolatilMaxGL': (csv, fila) =>
          _decimal(csv, fila, 'acidez_volatil_max_g_l'),
      'sulfurosoTotalMaxMgL': (csv, fila) =>
          _decimal(csv, fila, 'so2_total_max_mg_l'),
      'extractoSecoMinGL': (csv, fila) =>
          _decimal(csv, fila, 'extracto_seco_min_g_l'),
      'densidadMostoMin': (csv, fila) =>
          _decimal(csv, fila, 'densidad_mosto_min'),
      'rendimientoMinPct': (csv, fila) =>
          _decimal(csv, fila, 'rendimiento_min_pct'),
      'rendimientoMaxPct': (csv, fila) =>
          _decimal(csv, fila, 'rendimiento_max_pct'),
      'rendimientoEsLimite': (csv, fila) =>
          _booleano(csv, fila, 'rendimiento_es_limite'),
      'fuente': (csv, fila) => _texto(csv, fila, 'revisado_por'),
    },
  );
  await compilador.escribirFlagRevision(
    descripcionCatalogos: 'los 5 catálogos de Larrea Sagardoa',
    textoBanner: 'datos provisionales sin validar',
  );
  print('catalogosCompletamenteRevisados = ${compilador.todasRevisadas}');
}
