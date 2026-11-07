import 'dart:io';

import 'package:auditoria/auditoria.dart';
import 'package:pendientes/pendientes.dart';

const String _ayuda = '''
Asistente de auditoría de las verticales Larrea.

  dart run bin/auditoria.dart lista <vertical> [--para <responsable>] [--salida <dir>]
      PDF con la lista de comprobación (una sección por asesor).
  dart run bin/auditoria.dart firmar <archivo.csv> --firma "Nombre (cargo, fecha)" [--ids a,b,c]
      Escribe «asesor: …» en revisado_por. Solo cuando la persona ya ha
      firmado la lista en papel o por escrito.
  dart run bin/auditoria.dart comprobar <vertical>
      Qué falta para poder retirar los sellos PROVISIONAL.

Verticales: aceitera, apicola, arbolado-urbano, quesera, viticultura, agro, zunbeltz
Responsables (--para): asesorFiscal, asesorAgronomo, tecnicoOca, auditorAica,
  veterinario, apicultor, quesero, arborista, …
''';

Future<void> main(List<String> argumentos) async {
  if (argumentos.isEmpty || argumentos.contains('-h') ||
      argumentos.contains('--help')) {
    stdout.write(_ayuda);
    return;
  }
  final directorioPaquete = File.fromUri(Platform.script).parent.parent.path;
  final raiz = _valorDe(argumentos, '--raiz') ??
      Directory('$directorioPaquete/../..')
          .absolute
          .uri
          .normalizePath()
          .toFilePath()
          .replaceAll(RegExp(r'/$'), '');

  try {
    switch (argumentos.first) {
      case 'lista':
        await _lista(argumentos, raiz, directorioPaquete);
      case 'firmar':
        _firmar(argumentos);
      case 'comprobar':
        _comprobar(argumentos, raiz);
      default:
        stderr.writeln('Orden desconocida: ${argumentos.first}\n');
        stdout.write(_ayuda);
        exitCode = 64;
    }
  } on ArgumentError catch (error) {
    stderr.writeln(error.message);
    exitCode = 64;
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 65;
  }
}

Future<void> _lista(
    List<String> argumentos, String raiz, String directorioPaquete) async {
  final vertical = verticalPorNombre(_posicional(argumentos, 1, 'vertical'));
  final nombreResponsable = _valorDe(argumentos, '--para');
  final responsable = nombreResponsable == null
      ? null
      : Responsable.values.firstWhere((r) => r.name == nombreResponsable,
          orElse: () => throw ArgumentError(
              'Responsable desconocido: $nombreResponsable'));
  final lista = construirListaComprobacion(recolectar(raiz), vertical,
      soloResponsable: responsable);
  final bytes = await generarPdfListaComprobacion(lista,
      directorioFuentes: '$raiz/packages/nuevo_ser_core/assets/fuentes');
  final directorioSalida =
      _valorDe(argumentos, '--salida') ?? '$directorioPaquete/salida';
  final sufijo = responsable == null ? '' : '-${responsable.name}';
  final archivo = File('$directorioSalida/'
      'comprobacion-${vertical.carpetaContenido}$sufijo.pdf')
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(bytes);
  for (final seccion in lista.secciones) {
    stdout.writeln('  ${seccion.responsable.nombreVisible}: '
        '${seccion.bloqueos.length} cuestiones, '
        '${seccion.catalogos.length} catálogos, ${seccion.sellos.length} sellos');
  }
  stdout.writeln('PDF: ${archivo.absolute.path}');
}

void _firmar(List<String> argumentos) {
  final ruta = _posicional(argumentos, 1, 'archivo.csv');
  final firma = _valorDe(argumentos, '--firma') ??
      (throw ArgumentError('Falta --firma "Nombre (cargo, fecha)"'));
  final ids = _valorDe(argumentos, '--ids');
  final archivo = File(ruta);
  final resultado = firmarCatalogo(archivo.readAsStringSync(),
      firma: firma,
      identificadores: ids?.split(',').map((id) => id.trim()).toSet());
  archivo.writeAsStringSync(resultado.texto);
  stdout.writeln('${resultado.filasFirmadas} filas firmadas en $ruta');
  if (resultado.identificadoresNoEncontrados.isNotEmpty) {
    stderr.writeln('No encontrados: '
        '${resultado.identificadoresNoEncontrados.join(', ')}');
    exitCode = 1;
  }
  stdout.writeln('Recompila los catálogos de la app (tool/compilar_catalogos.dart) '
      'y revisa el diff antes del commit.');
}

void _comprobar(List<String> argumentos, String raiz) {
  final vertical = verticalPorNombre(_posicional(argumentos, 1, 'vertical'));
  final faltas = comprobarRetiradaDeSellos(recolectar(raiz), vertical);
  if (faltas.isEmpty) {
    stdout.writeln('${vertical.nombreVisible}: todo firmado y sin bloqueos '
        'abiertos. Ya se pueden retirar los sellos PROVISIONAL a mano '
        '(actualiza sello_provisional_test.dart y BLOQUEOS-PENDIENTES.md).');
    return;
  }
  stdout.writeln('${vertical.nombreVisible}: faltan ${faltas.length} cosas '
      'antes de retirar los sellos PROVISIONAL');
  for (final falta in faltas) {
    stdout.writeln('  - $falta');
  }
  exitCode = 1;
}

String _posicional(List<String> argumentos, int posicion, String nombre) {
  if (argumentos.length <= posicion || argumentos[posicion].startsWith('--')) {
    throw ArgumentError('Falta <$nombre>');
  }
  return argumentos[posicion];
}

String? _valorDe(List<String> argumentos, String opcion) {
  final indice = argumentos.indexOf(opcion);
  return indice >= 0 && indice + 1 < argumentos.length
      ? argumentos[indice + 1]
      : null;
}
