// ignore_for_file: avoid_print
// Compilador de catálogos de Larrea Vivero: content/vivero/*.csv →
// lib/datos/catalogos_generados/. Lo común está en el core.
//
//   cd apps/solera-vivero && dart run tool/compilar_catalogos.dart

import '../../../packages/nuevo_ser_core/tool/catalogos/compilador_catalogos.dart';

final compilador = CompiladorCatalogos(
    carpetaContent: 'vivero', carpetaApp: 'solera-vivero');

/// Tipo de cada campo generado y cómo se escribe su literal.
enum TipoCampo { texto, lista, entero, siNo }

class Campo {
  const Campo(this.nombreDart, this.columna, [this.tipo = TipoCampo.texto]);

  final String nombreDart;
  final String columna;
  final TipoCampo tipo;

  String get tipoDart => switch (tipo) {
        TipoCampo.texto => 'String',
        TipoCampo.lista => 'List<String>',
        TipoCampo.entero => 'int?',
        TipoCampo.siNo => 'bool?',
      };

  String literal(String valor) => switch (tipo) {
        TipoCampo.texto => escaparDart(valor),
        TipoCampo.lista =>
          '[${separarPipe(valor).map(escaparDart).join(', ')}]',
        TipoCampo.entero => valor.isEmpty ? 'null' : int.parse(valor).toString(),
        TipoCampo.siNo => switch (valor.toLowerCase()) {
            'si' || 'sí' => 'true',
            'no' => 'false',
            _ => 'null',
          },
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
    ..writeAll(campos.map((campo) => '    required this.${campo.nombreDart},\n'))
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
  print('Compilando catálogos de Larrea Vivero…');
  await _compilar(
    csvNombre: 'especies_vivero.csv',
    ficheroDart: 'catalogo_especies.dart',
    clase: 'EspecieCatalogo',
    lista: 'catalogoEspecies',
    campos: const [
      Campo('id', 'id'),
      Campo('nombre', 'nombre'),
      Campo('nombreBotanico', 'nombre_botanico'),
      Campo('grupo', 'grupo'),
      Campo('grupoFitosanitario', 'grupo_fitosanitario'),
      Campo('plantaPasaporte', 'planta_pasaporte', TipoCampo.siNo),
      Campo('semillaPasaporte', 'semilla_pasaporte', TipoCampo.siNo),
      Campo('anexoXivZonaProtegida', 'anexo_xiv_zp', TipoCampo.siNo),
      Campo('plagasReguladas', 'plagas_reguladas', TipoCampo.lista),
      Campo('notas', 'notas'),
    ],
  );
  await _compilar(
    csvNombre: 'plagas_reguladas_vivero.csv',
    ficheroDart: 'catalogo_plagas_reguladas.dart',
    clase: 'PlagaReguladaCatalogo',
    lista: 'catalogoPlagasReguladas',
    campos: const [
      Campo('id', 'id'),
      Campo('nombre', 'nombre'),
      Campo('nombreCientifico', 'nombre_cientifico'),
      Campo('categoria', 'categoria'),
      Campo('generos', 'generos', TipoCampo.lista),
      Campo('sintomas', 'sintomas'),
    ],
  );
  await _compilar(
    csvNombre: 'plagas_vivero.csv',
    ficheroDart: 'catalogo_plagas.dart',
    clase: 'PlagaCatalogo',
    lista: 'catalogoPlagas',
    campos: const [
      Campo('id', 'id'),
      Campo('nombre', 'nombre'),
      Campo('nombreCientifico', 'nombre_cientifico'),
      Campo('tipo', 'tipo'),
      Campo('sintomas', 'sintomas'),
    ],
  );
  await _compilar(
    csvNombre: 'fitosanitarios_vivero.csv',
    ficheroDart: 'catalogo_fitosanitarios.dart',
    clase: 'SustanciaActivaCatalogo',
    lista: 'catalogoSustanciasActivas',
    campos: const [
      Campo('id', 'id'),
      Campo('nombre', 'nombre'),
      Campo('usos', 'usos', TipoCampo.lista),
      Campo('tipoAccion', 'tipo_accion'),
      Campo('plazoSeguridadMaximoDias', 'plazo_seguridad_max_dias',
          TipoCampo.entero),
      Campo('plazoSeguridadRegistro', 'plazo_seguridad_registro'),
      Campo('estadoUe', 'estado_ue'),
      Campo('candidataSustitucion', 'candidata_sustitucion', TipoCampo.siNo),
    ],
  );
  await compilador.escribirFlagRevision(
    descripcionCatalogos: 'los 4 catálogos de Larrea Vivero',
    textoBanner: 'datos provisionales sin validar',
  );
  print('catalogosCompletamenteRevisados = ${compilador.todasRevisadas}');
}
