// ignore_for_file: avoid_print
// Compilador de catálogos de Larrea Ganadera: content/ganadera/*.csv →
// lib/datos/catalogos_generados/. Lo común está en el core.
//
//   cd apps/solera-ganadera && dart run tool/compilar_catalogos.dart
//
// Para cada CSV, añade una función _compilarX que lea con
// `compilador.leer('x.csv')`, escriba la cabecera con
// `compilador.cabeceraDart(...)` y la clase del catálogo, y termine con
// `compilador.escribir('catalogo_x.dart', ...)`. Ver
// apps/solera-aceitera/tool/compilar_catalogos.dart como ejemplo completo.

import '../../../packages/nuevo_ser_core/tool/catalogos/compilador_catalogos.dart';

final compilador = CompiladorCatalogos(carpetaContent: 'ganadera', carpetaApp: 'solera-ganadera');

/// Funciones de compilación, una por CSV.
final catalogos = <Future<void> Function()>[];

Future<void> main() async {
  for (final compilarCatalogo in catalogos) {
    await compilarCatalogo();
  }
  // Sin catálogos todavía no hay nada revisado: el banner sigue activo.
  if (catalogos.isEmpty) compilador.todasRevisadas = false;
  await compilador.escribirFlagRevision(
    descripcionCatalogos: 'los catálogos de Larrea Ganadera',
    textoBanner: 'datos provisionales sin validar',
  );
  print('Hecho: catalogosCompletamenteRevisados = ${compilador.todasRevisadas}');
}
