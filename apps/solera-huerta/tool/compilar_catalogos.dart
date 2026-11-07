// ignore_for_file: avoid_print
// Compilador de catálogos de Larrea Huerta: content/huerta/*.csv →
// lib/datos/catalogos_generados/. Lo común está en el core.
//
//   cd apps/solera-huerta && dart run tool/compilar_catalogos.dart

import '../../../packages/nuevo_ser_core/tool/catalogos/compilador_catalogos.dart';

final compilador = CompiladorCatalogos(
    carpetaContent: 'huerta', carpetaApp: 'solera-huerta');

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
  print('Compilando catálogos de Larrea Huerta…');
  await _compilar(
    csvNombre: 'cultivos_huerta.csv',
    ficheroDart: 'catalogo_cultivos.dart',
    clase: 'CultivoCatalogo',
    lista: 'catalogoCultivos',
    campos: const [
      Campo('id', 'id'),
      Campo('nombre', 'nombre'),
      Campo('nombreCientifico', 'nombre_cientifico'),
      Campo('familiaId', 'familia_id'),
      Campo('cicloDias', 'ciclo_dias', TipoCampo.entero),
      Campo('semanasCosecha', 'semanas_cosecha', TipoCampo.entero),
      Campo('marco', 'marco'),
      Campo('porUnidades', 'por_unidades', TipoCampo.siNo),
      Campo('revisadoPor', 'revisado_por'),
    ],
  );
  await _compilar(
    csvNombre: 'rotacion.csv',
    ficheroDart: 'catalogo_rotacion.dart',
    clase: 'FamiliaRotacionCatalogo',
    lista: 'catalogoRotacion',
    campos: const [
      Campo('familiaId', 'familia_id'),
      Campo('nombre', 'nombre'),
      Campo('aniosMinimos', 'anios_minimos', TipoCampo.entero),
      Campo('ejemplos', 'ejemplos'),
      Campo('revisadoPor', 'revisado_por'),
      Campo('notas', 'notas'),
    ],
  );
  await _compilar(
    csvNombre: 'insumos_ecologicos.csv',
    ficheroDart: 'catalogo_insumos.dart',
    clase: 'CategoriaInsumoCatalogo',
    lista: 'catalogoCategoriasInsumo',
    campos: const [
      Campo('id', 'id'),
      Campo('anexo', 'anexo'),
      Campo('tipo', 'tipo'),
      Campo('nombre', 'nombre'),
      Campo('condiciones', 'condiciones'),
      Campo('revisadoPor', 'revisado_por'),
    ],
  );
  await _compilar(
    csvNombre: 'plagas_huerta.csv',
    ficheroDart: 'catalogo_plagas.dart',
    clase: 'PlagaCatalogo',
    lista: 'catalogoPlagas',
    campos: const [
      Campo('id', 'id'),
      Campo('nombre', 'nombre'),
      Campo('nombreCientifico', 'nombre_cientifico'),
      Campo('tipo', 'tipo'),
      Campo('familias', 'familias', TipoCampo.lista),
      Campo('sintomas', 'sintomas'),
      Campo('seguimiento', 'seguimiento'),
      Campo('revisadoPor', 'revisado_por'),
    ],
  );
  await compilador.escribirFlagRevision(
    descripcionCatalogos: 'los 4 catálogos de Larrea Huerta',
    textoBanner: 'datos provisionales sin validar',
  );
  print('catalogosCompletamenteRevisados = ${compilador.todasRevisadas}');
}
