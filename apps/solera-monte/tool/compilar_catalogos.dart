// ignore_for_file: avoid_print
// Compilador de catálogos de Larrea Monte: content/monte/*.csv →
// lib/datos/catalogos_generados/. Lo común está en el core.
//
//   cd apps/solera-monte && dart run tool/compilar_catalogos.dart

import '../../../packages/nuevo_ser_core/tool/catalogos/compilador_catalogos.dart';

final compilador =
    CompiladorCatalogos(carpetaContent: 'monte', carpetaApp: 'solera-monte');

/// Tipo de cada campo generado y cómo se escribe su literal.
enum TipoCampo { texto, lista, decimal }

class Campo {
  const Campo(this.nombreDart, this.columna, [this.tipo = TipoCampo.texto]);

  final String nombreDart;
  final String columna;
  final TipoCampo tipo;

  String get tipoDart => switch (tipo) {
        TipoCampo.texto => 'String',
        TipoCampo.lista => 'List<String>',
        TipoCampo.decimal => 'double?',
      };

  String literal(String valor) => switch (tipo) {
        TipoCampo.texto => escaparDart(valor),
        TipoCampo.lista =>
          '[${separarPipe(valor).map(escaparDart).join(', ')}]',
        TipoCampo.decimal =>
          valor.isEmpty ? 'null' : double.parse(valor).toString(),
      };
}

Future<void> _compilar({
  required String csvNombre,
  required String ficheroDart,
  required String clase,
  required String lista,
  required List<Campo> campos,
}) async {
  final csv = await compilador.leer(csvNombre);
  final salida = StringBuffer()
    ..write(compilador.cabeceraDart(nombreCsv: csvNombre, csv: csv))
    ..writeln('class $clase {')
    ..writeln('  const $clase({')
    ..writeAll(
        campos.map((campo) => '    required this.${campo.nombreDart},\n'))
    ..writeln('  });')
    ..writeln();
  for (final campo in campos) {
    salida.writeln('  final ${campo.tipoDart} ${campo.nombreDart};');
  }
  salida
    ..writeln('}')
    ..writeln()
    ..writeln('const List<$clase> $lista = [');
  for (final fila in csv.filas) {
    final valores = campos
        .map((campo) =>
            '${campo.nombreDart}: ${campo.literal(csv.campo(fila, campo.columna))}')
        .join(', ');
    salida.writeln('  $clase($valores),');
  }
  salida.writeln('];');
  await compilador.escribir(ficheroDart, salida.toString());
  print('  $ficheroDart: ${csv.totalFilas} filas '
      '(${csv.revisadas} con revisión documental, ${csv.firmadas} firmadas)');
}

Future<void> main() async {
  print('Compilando catálogos de Larrea Monte…');
  await _compilar(
    csvNombre: 'especies_forestales.csv',
    ficheroDart: 'catalogo_especies.dart',
    clase: 'EspecieForestal',
    lista: 'catalogoEspecies',
    campos: const [
      Campo('id', 'id'),
      Campo('codigoIfn', 'codigo_ifn'),
      Campo('nombre', 'nombre'),
      Campo('nombreCientifico', 'nombre_cientifico'),
      Campo('grupo', 'grupo'),
      Campo('revisadoPor', 'revisado_por'),
    ],
  );
  await _compilar(
    csvNombre: 'unidades_volumen.csv',
    ficheroDart: 'catalogo_unidades.dart',
    clase: 'UnidadVolumen',
    lista: 'catalogoUnidades',
    campos: const [
      Campo('id', 'id'),
      Campo('nombre', 'nombre'),
      Campo('simbolo', 'simbolo'),
      Campo('m3PorUnidad', 'm3_por_unidad', TipoCampo.decimal),
      Campo('nota', 'nota'),
      Campo('fuente', 'fuente'),
      Campo('revisadoPor', 'revisado_por'),
    ],
  );
  await _compilar(
    csvNombre: 'plagas_forestales.csv',
    ficheroDart: 'catalogo_plagas.dart',
    clase: 'PlagaForestal',
    lista: 'catalogoPlagas',
    campos: const [
      Campo('id', 'id'),
      Campo('nombre', 'nombre'),
      Campo('nombreCientifico', 'nombre_cientifico'),
      Campo('grupo', 'grupo'),
      Campo('generos', 'generos', TipoCampo.lista),
      Campo('especies', 'especies', TipoCampo.lista),
      Campo('organos', 'organos'),
      Campo('sintomas', 'sintomas'),
      Campo('aviso', 'aviso'),
      Campo('revisadoPor', 'revisado_por'),
    ],
  );
  await compilador.escribirFlagRevision(
    descripcionCatalogos: 'los 3 catálogos de Larrea Monte',
    textoBanner: 'datos provisionales sin validar',
  );
  print('catalogosCompletamenteRevisados = ${compilador.todasRevisadas}');
}
