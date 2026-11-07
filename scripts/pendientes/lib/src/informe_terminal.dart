import 'recolector.dart';

/// Resumen corto para la terminal.
String informeTerminal(Inventario inventario) {
  final salida = StringBuffer();
  final abiertos = inventario.bloqueosAbiertos;
  salida.writeln('Pendientes del monorepo — '
      '${_fecha(inventario.generadoEn)}');
  salida.writeln('${abiertos.length} bloqueos abiertos de '
      '${inventario.bloqueos.length} · '
      '${inventario.sellos.length} sellos PROVISIONAL en código · '
      '${inventario.catalogos.where((c) => c.pendienteDePersona).length} '
      'catálogos sin firma de persona experta');
  salida.writeln();

  salida.writeln('A quién se espera');
  final porResponsable = inventario.abiertosPorResponsable;
  final anchoNombre = porResponsable.keys
      .map((responsable) => responsable.nombreVisible.length)
      .fold<int>(0, (maximo, largo) => largo > maximo ? largo : maximo);
  for (final entrada in porResponsable.entries) {
    final porApp = <String, int>{};
    for (final bloqueo in entrada.value) {
      porApp.update(bloqueo.aplicacion, (cuenta) => cuenta + 1,
          ifAbsent: () => 1);
    }
    final detalle = porApp.entries
        .map((app) => '${app.key} ${app.value}')
        .join(', ');
    salida.writeln('  ${entrada.key.nombreVisible.padRight(anchoNombre)}  '
        '${entrada.value.length.toString().padLeft(3)}  $detalle');
  }
  salida.writeln();

  salida.writeln('Bloqueos abiertos por app');
  final porAplicacion = <String, int>{};
  for (final bloqueo in abiertos) {
    porAplicacion.update(bloqueo.aplicacion, (cuenta) => cuenta + 1,
        ifAbsent: () => 1);
  }
  for (final entrada in porAplicacion.entries) {
    salida.writeln('  ${entrada.key.padRight(24)} ${entrada.value}');
  }
  salida.writeln();

  salida.writeln('Sellos PROVISIONAL');
  for (final sello in inventario.sellos) {
    final proteccion = sello.protegidoPorTest ? 'con test' : 'SIN test';
    salida.writeln('  [$proteccion] ${sello.ruta}');
  }
  salida.writeln();

  salida.writeln('Catálogos (filas: persona / revisión IA / fuente pública / sin revisar)');
  for (final catalogo in inventario.catalogos
      .where((catalogo) => catalogo.tieneColumnaRevision)) {
    salida.writeln('  ${catalogo.ruta.padRight(48)} '
        '${catalogo.revisadasPorPersona}/'
        '${catalogo.revisadasPorIa}/'
        '${catalogo.revisadasPorFuentePublica}/'
        '${catalogo.sinRevisar} de ${catalogo.filas}');
  }
  for (final flag in inventario.flags) {
    salida.writeln('  flag ${flag.aplicacion}: '
        'catalogosCompletamenteRevisados = ${flag.revisados}');
  }
  return salida.toString();
}

String _fecha(DateTime fecha) =>
    '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-'
    '${fecha.day.toString().padLeft(2, '0')}';
