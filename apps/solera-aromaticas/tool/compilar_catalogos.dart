// ignore_for_file: avoid_print
// Compilador de catálogos de Larrea Aromáticas: content/aromaticas/*.csv →
// lib/datos/catalogos_generados/. Lo común está en el core.
//
//   cd apps/solera-aromaticas && dart run tool/compilar_catalogos.dart

import '../../../packages/nuevo_ser_core/tool/catalogos/compilador_catalogos.dart';

final compilador = CompiladorCatalogos(
    carpetaContent: 'aromaticas', carpetaApp: 'solera-aromaticas');

/// Tipo de cada campo generado y cómo se escribe su literal.
enum TipoCampo { texto, lista, decimal, entero }

class Campo {
  const Campo(this.nombreDart, this.columna, [this.tipo = TipoCampo.texto]);

  final String nombreDart;
  final String columna;
  final TipoCampo tipo;

  String get tipoDart => switch (tipo) {
        TipoCampo.texto => 'String',
        TipoCampo.lista => 'List<String>',
        TipoCampo.decimal => 'double?',
        TipoCampo.entero => 'int?',
      };

  String literal(String valor) => switch (tipo) {
        TipoCampo.texto => escaparDart(valor),
        TipoCampo.lista =>
          '[${separarPipe(valor).map(escaparDart).join(', ')}]',
        TipoCampo.decimal =>
          valor.isEmpty ? 'null' : double.parse(valor).toString(),
        TipoCampo.entero =>
          valor.isEmpty ? 'null' : int.parse(valor).toString(),
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
  print('Compilando catálogos de Larrea Aromáticas…');
  await _compilar(
    csvNombre: 'especies_pam.csv',
    ficheroDart: 'catalogo_especies.dart',
    clase: 'EspecieCatalogo',
    lista: 'catalogoEspecies',
    campos: const [
      Campo('id', 'id'),
      Campo('nombre', 'nombre'),
      Campo('nombreCientifico', 'nombre_cientifico'),
      Campo('familia', 'familia'),
      Campo('parteUsada', 'parte_usada'),
      Campo('mesInicio', 'mes_inicio', TipoCampo.entero),
      Campo('mesFin', 'mes_fin', TipoCampo.entero),
      Campo('origen', 'origen'),
      Campo('proteccion', 'proteccion'),
      Campo('notaProteccion', 'nota_proteccion'),
      Campo('confundibles', 'confundibles', TipoCampo.lista),
      Campo('notas', 'notas'),
      Campo('revisadoPor', 'revisado_por'),
    ],
  );
  await _compilar(
    csvNombre: 'rendimientos_orientativos.csv',
    ficheroDart: 'catalogo_rendimientos.dart',
    clase: 'RendimientoOrientativo',
    lista: 'catalogoRendimientos',
    campos: const [
      Campo('id', 'id'),
      Campo('especieId', 'especie_id'),
      Campo('producto', 'producto'),
      Campo('estadoPlanta', 'estado_planta'),
      Campo('minimo', 'minimo', TipoCampo.decimal),
      Campo('maximo', 'maximo', TipoCampo.decimal),
      Campo('unidad', 'unidad'),
      Campo('fuente', 'fuente'),
      Campo('revisadoPor', 'revisado_por'),
    ],
  );
  await _compilar(
    csvNombre: 'plagas_pam.csv',
    ficheroDart: 'catalogo_plagas.dart',
    clase: 'PlagaCatalogo',
    lista: 'catalogoPlagas',
    campos: const [
      Campo('id', 'id'),
      Campo('especies', 'especies', TipoCampo.lista),
      Campo('nombre', 'nombre'),
      Campo('nombreCientifico', 'nombre_cientifico'),
      Campo('tipo', 'tipo'),
      Campo('sintomas', 'sintomas'),
      Campo('revisadoPor', 'revisado_por'),
    ],
  );
  await _compilar(
    csvNombre: 'guia_especies.csv',
    ficheroDart: 'catalogo_guia.dart',
    clase: 'FichaGuiaEspecie',
    lista: 'catalogoGuia',
    campos: const [
      Campo('id', 'id'),
      Campo('rasgos', 'rasgos', TipoCampo.lista),
      Campo('habitat', 'habitat'),
      Campo('tituloWikipedia', 'titulo_wikipedia'),
      Campo('revisadoPor', 'revisado_por'),
    ],
  );
  await compilador.escribirFlagRevision(
    descripcionCatalogos: 'los 4 catálogos de Larrea Aromáticas',
    textoBanner: 'datos provisionales sin validar',
  );
  print('catalogosCompletamenteRevisados = ${compilador.todasRevisadas}');
}
