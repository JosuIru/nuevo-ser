// ignore_for_file: avoid_print
// Compilador de catálogos de Larrea Frutal: content/frutal/*.csv →
// lib/datos/catalogos_generados/. Lo común está en el core.
//
//   cd apps/solera-frutal && dart run tool/compilar_catalogos.dart

import '../../../packages/nuevo_ser_core/tool/catalogos/compilador_catalogos.dart';

final compilador = CompiladorCatalogos(
    carpetaContent: 'frutal', carpetaApp: 'solera-frutal');

/// Tipo de cada campo generado y cómo se escribe su literal.
enum TipoCampo { texto, lista, decimal, entero, siNo }

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
        TipoCampo.siNo => 'bool?',
      };

  String literal(String valor) => switch (tipo) {
        TipoCampo.texto => escaparDart(valor),
        TipoCampo.lista =>
          '[${separarPipe(valor).map(escaparDart).join(', ')}]',
        TipoCampo.decimal =>
          valor.isEmpty ? 'null' : double.parse(valor).toString(),
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
  print('Compilando catálogos de Larrea Frutal…');
  await _compilar(
    csvNombre: 'especies_frutal.csv',
    ficheroDart: 'catalogo_especies.dart',
    clase: 'EspecieCatalogo',
    lista: 'catalogoEspecies',
    campos: const [
      Campo('id', 'id'),
      Campo('nombre', 'nombre'),
      Campo('nombreCientifico', 'nombre_cientifico'),
      Campo('tipoFruto', 'tipo_fruto'),
      Campo('polinizacion', 'polinizacion'),
      Campo('colmenasPorHaMinimo', 'colmenas_ha_min', TipoCampo.decimal),
      Campo('colmenasPorHaMaximo', 'colmenas_ha_max', TipoCampo.decimal),
      Campo('notas', 'notas'),
    ],
  );
  await _compilar(
    csvNombre: 'variedades_frutal.csv',
    ficheroDart: 'catalogo_variedades.dart',
    clase: 'VariedadCatalogo',
    lista: 'catalogoVariedades',
    campos: const [
      Campo('id', 'id'),
      Campo('especieId', 'especie_id'),
      Campo('nombre', 'nombre'),
      Campo('autocompatible', 'autocompatible', TipoCampo.siNo),
      Campo('grupoIncompatibilidad', 'grupo_incompatibilidad'),
      Campo('floracion', 'floracion'),
      Campo('polinizadorasHabituales', 'polinizadoras_habituales',
          TipoCampo.lista),
      Campo('origen', 'origen'),
      Campo('notas', 'notas'),
    ],
  );
  await _compilar(
    csvNombre: 'plagas_frutal.csv',
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
      Campo('seguimiento', 'seguimiento'),
      Campo('umbral', 'umbral'),
      Campo('revisadoPor', 'revisado_por'),
    ],
  );
  await _compilar(
    csvNombre: 'fitosanitarios_frutal.csv',
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
      Campo('notas', 'notas'),
    ],
  );
  await _compilar(
    csvNombre: 'fenologia_frutal.csv',
    ficheroDart: 'catalogo_fenologia.dart',
    clase: 'EstadoFenologicoCatalogo',
    lista: 'catalogoFenologia',
    campos: const [
      Campo('id', 'id'),
      Campo('especieId', 'especie_id'),
      Campo('codigo', 'codigo'),
      Campo('estado', 'estado'),
      Campo('mesInicio', 'mes_inicio', TipoCampo.entero),
      Campo('mesFin', 'mes_fin', TipoCampo.entero),
      Campo('sensibleHelada', 'sensible_helada', TipoCampo.siNo),
      Campo('temperaturaCriticaC', 'temperatura_critica_c', TipoCampo.decimal),
    ],
  );
  await compilador.escribirFlagRevision(
    descripcionCatalogos: 'los 5 catálogos de Larrea Frutal',
    textoBanner: 'datos provisionales sin validar',
  );
  print('catalogosCompletamenteRevisados = ${compilador.todasRevisadas}');
}
