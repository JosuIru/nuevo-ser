import 'clasificador_responsables.dart';

/// Una entrada de un `BLOQUEOS-PENDIENTES.md`.
class Bloqueo {
  Bloqueo({
    required this.aplicacion,
    required this.titulo,
    required this.grupo,
    required this.cuerpo,
    required this.linea,
    required this.casillasPendientes,
    required this.casillasHechas,
    required this.resuelto,
  }) : responsables = clasificarResponsables(
            '${grupo ?? ''}\n$titulo\n$cuerpo');

  final String aplicacion;
  final String titulo;

  /// Título del `##` que agrupa a este `###`, si lo hay.
  final String? grupo;
  final String cuerpo;

  /// Línea (desde 1) del encabezado en el archivo.
  final int linea;
  final int casillasPendientes;
  final int casillasHechas;
  final bool resuelto;
  final List<Responsable> responsables;
}

final RegExp _encabezado = RegExp(r'^(#{2,3})\s+(.*?)\s*$');
final RegExp _casillaPendiente = RegExp(r'^\s*[-*]\s+\[ \]', multiLine: true);
final RegExp _casillaHecha = RegExp(r'^\s*[-*]\s+\[[xX]\]', multiLine: true);

/// Señales de que algo está cerrado de verdad. «cerrado provisionalmente» o
/// «cierres provisionales» siguen esperando a una persona, así que no cuentan.
final RegExp _marcaResuelto = RegExp(r'✅|\bresuelt[oa]s?\b|\bcerrad[oa]s?\b');
final RegExp _marcaProvisional = RegExp(r'provisional');

bool _tituloIndicaResuelto(String titulo) {
  final normalizado = quitarTildes(titulo);
  return _marcaResuelto.hasMatch(normalizado) &&
      !_marcaProvisional.hasMatch(normalizado);
}

class _SeccionEnBruto {
  _SeccionEnBruto(this.nivel, this.titulo, this.linea);

  final int nivel;
  final String titulo;
  final int linea;
  final List<String> lineasCuerpo = [];
}

/// Trocea el markdown en bloqueos. Un `##` con `###` debajo es un grupo y
/// sus `###` son los bloqueos; un `##` sin hijos es un bloqueo él mismo.
List<Bloqueo> leerBloqueos(String texto, {required String aplicacion}) {
  final secciones = <_SeccionEnBruto>[];
  var dentroDeCodigo = false;
  final lineas = texto.split('\n');
  for (var indice = 0; indice < lineas.length; indice++) {
    final linea = lineas[indice];
    if (linea.trimLeft().startsWith('```')) {
      dentroDeCodigo = !dentroDeCodigo;
    }
    final coincidencia = dentroDeCodigo ? null : _encabezado.firstMatch(linea);
    if (coincidencia != null) {
      secciones.add(_SeccionEnBruto(
          coincidencia.group(1)!.length, coincidencia.group(2)!, indice + 1));
    } else if (secciones.isNotEmpty) {
      secciones.last.lineasCuerpo.add(linea);
    }
  }

  final bloqueos = <Bloqueo>[];
  _SeccionEnBruto? grupoActual;
  for (var indice = 0; indice < secciones.length; indice++) {
    final seccion = secciones[indice];
    if (seccion.nivel == 2) {
      grupoActual = seccion;
      final tieneHijos = indice + 1 < secciones.length &&
          secciones[indice + 1].nivel == 3;
      if (tieneHijos) continue;
      bloqueos.add(_crearBloqueo(seccion, null, aplicacion));
    } else {
      bloqueos.add(_crearBloqueo(seccion, grupoActual, aplicacion));
    }
  }
  return bloqueos;
}

Bloqueo _crearBloqueo(
    _SeccionEnBruto seccion, _SeccionEnBruto? grupo, String aplicacion) {
  final cuerpo = seccion.lineasCuerpo.join('\n').trim();
  final pendientes = _casillaPendiente.allMatches(cuerpo).length;
  final hechas = _casillaHecha.allMatches(cuerpo).length;
  final todasLasCasillasHechas = hechas > 0 && pendientes == 0;
  final resuelto = _tituloIndicaResuelto(seccion.titulo) ||
      (grupo != null && _tituloIndicaResuelto(grupo.titulo)) ||
      todasLasCasillasHechas;
  return Bloqueo(
    aplicacion: aplicacion,
    titulo: seccion.titulo,
    grupo: grupo?.titulo,
    cuerpo: cuerpo,
    linea: seccion.linea,
    casillasPendientes: pendientes,
    casillasHechas: hechas,
    resuelto: resuelto,
  );
}
