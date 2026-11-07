import 'dart:io';

import 'package:args/args.dart';
import 'package:fichas_imprimibles/fichas_imprimibles.dart';

const _uso = '''
Fichas imprimibles · Colección Nuevo Ser Kids · Uno Roto

Uso:
  dart run bin/fichas.dart generar <id_habilidad>... [opciones]
  dart run bin/fichas.dart generar --dominio FR [opciones]
  dart run bin/fichas.dart listar

Opciones de «generar»:''';

ArgParser _opcionesGenerar() => ArgParser()
  ..addOption('salida', abbr: 's', help: 'Directorio donde dejar los PDF.', defaultsTo: 'fichas_pdf')
  ..addMultiOption('dominio', abbr: 'd', help: 'Dominio entero (FR, DEC, PROP…). Repetible.')
  ..addOption('semilla', help: 'Misma semilla = mismas fichas.', defaultsTo: '1')
  ..addFlag('un-pdf', help: 'Todas las fichas en un solo PDF (una por página).', negatable: false)
  ..addOption('skills', help: 'Ruta a skills.json (por defecto, el de apps/uno-roto).')
  ..addFlag('ayuda', abbr: 'h', negatable: false);

Future<void> main(List<String> argumentos) async {
  if (argumentos.isEmpty || argumentos.first == '--ayuda' || argumentos.first == '-h') {
    stdout.writeln('$_uso\n${_opcionesGenerar().usage}');
    return;
  }
  final raiz = localizarRaizPaquete();
  if (raiz == null) {
    stderr.writeln('No encuentro scripts/fichas (con fuentes/). Ejecuta desde el monorepo.');
    exitCode = 2;
    return;
  }
  switch (argumentos.first) {
    case 'generar':
      exitCode = await _generar(argumentos.sublist(1), raiz);
    case 'listar':
      exitCode = _listar(raiz);
    default:
      stderr.writeln('Orden desconocida: ${argumentos.first}\n\n$_uso\n${_opcionesGenerar().usage}');
      exitCode = 64;
  }
}

CatalogoHabilidades _catalogo(Directory raiz, String? rutaSkills) =>
    cargarCatalogo(rutaSkills != null ? File(rutaSkills) : rutaSkillsPorDefecto(raiz));

int _listar(Directory raiz) {
  final catalogo = _catalogo(raiz, null);
  var conFicha = 0;
  for (final habilidad in catalogo.habilidades) {
    final tiene = plantillasPorHabilidad.containsKey(habilidad.id);
    if (tiene) conFicha++;
    final marca = tiene ? 'sí' : 'no';
    final motivo = tiene ? '' : '  (${motivosSinPlantilla[habilidad.id] ?? 'sin generador'})';
    stdout.writeln('${habilidad.id.padRight(8)} $marca  ${habilidad.nombre}$motivo');
  }
  stdout.writeln('\n$conFicha de ${catalogo.habilidades.length} habilidades tienen ficha.');
  return 0;
}

Future<int> _generar(List<String> argumentos, Directory raiz) async {
  final ArgResults opciones;
  try {
    opciones = _opcionesGenerar().parse(argumentos);
  } on FormatException catch (error) {
    stderr.writeln('${error.message}\n\n${_opcionesGenerar().usage}');
    return 64;
  }
  if (opciones['ayuda'] as bool) {
    stdout.writeln('$_uso\n${_opcionesGenerar().usage}');
    return 0;
  }
  final semilla = int.tryParse(opciones['semilla'] as String);
  if (semilla == null) {
    stderr.writeln('--semilla tiene que ser un número entero.');
    return 64;
  }
  final ids = opciones.rest;
  final dominios = opciones['dominio'] as List<String>;
  if (ids.isEmpty && dominios.isEmpty) {
    stderr.writeln('Indica al menos un id de habilidad o un --dominio.');
    return 64;
  }

  final catalogo = _catalogo(raiz, opciones['skills'] as String?);
  final seleccion = seleccionarHabilidades(catalogo, ids: ids, dominios: dominios);
  final letras = cargarLetras(raiz);
  final directorioSalida = Directory(opciones['salida'] as String)..createSync(recursive: true);

  final fichas = [
    for (final habilidad in seleccion.conFicha)
      generarContenidoFicha(catalogo, habilidad, semilla: semilla),
  ];
  final generados = <String>[];
  if (fichas.isNotEmpty) {
    if (opciones['un-pdf'] as bool) {
      final nombre = dominios.length == 1 && ids.isEmpty
          ? 'fichas_${dominios.first.toUpperCase()}.pdf'
          : 'fichas.pdf';
      final ruta = '${directorioSalida.path}/$nombre';
      File(ruta).writeAsBytesSync(await generarPdfFichas(fichas, letras));
      generados.add(ruta);
    } else {
      for (final ficha in fichas) {
        final ruta = '${directorioSalida.path}/ficha_${ficha.idHabilidad.replaceAll('.', '_')}.pdf';
        File(ruta).writeAsBytesSync(await generarPdfFichas([ficha], letras));
        generados.add(ruta);
      }
    }
  }

  for (final ruta in generados) {
    stdout.writeln('Generado: $ruta');
  }
  if (seleccion.saltadas.isNotEmpty) {
    stdout.writeln('\nSaltadas (${seleccion.saltadas.length}):');
    for (final saltada in seleccion.saltadas) {
      stdout.writeln('  $saltada');
    }
  }
  return fichas.isEmpty ? 1 : 0;
}
