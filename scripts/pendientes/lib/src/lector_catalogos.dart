/// Estado de revisión de un CSV de `content/<vertical>/`.
class EstadoCatalogo {
  EstadoCatalogo({
    required this.ruta,
    required this.filas,
    required this.sinRevisar,
    required this.revisadasPorFuentePublica,
    required this.revisadasPorPersona,
    required this.cabeceraProvisional,
    required this.tieneColumnaRevision,
  });

  final String ruta;
  final int filas;
  final int sinRevisar;

  /// `revisado_por` con `fuente_publica` o con una cita bibliográfica:
  /// contrastado con documentación, pero sin firma de una persona experta.
  final int revisadasPorFuentePublica;

  /// `revisado_por` empieza por `persona:` o `asesor:` (convención para la
  /// firma de una persona experta; ver README).
  final int revisadasPorPersona;
  final bool cabeceraProvisional;
  final bool tieneColumnaRevision;

  /// Carpeta inmediata dentro de `content/`.
  String get vertical {
    final partes = ruta.split('/');
    final indice = partes.indexOf('content');
    return indice >= 0 && indice + 1 < partes.length
        ? partes[indice + 1]
        : partes.length > 1
            ? partes[partes.length - 2]
            : '';
  }

  String get nombreArchivo => ruta.split('/').last;

  /// Le falta la firma de una persona experta en alguna fila.
  bool get pendienteDePersona =>
      tieneColumnaRevision && revisadasPorPersona < filas;
}

/// Prefijos que marcan la firma de una persona experta en `revisado_por`.
const List<String> prefijosFirmaPersona = ['persona:', 'asesor:'];

bool esFirmaDePersona(String valor) {
  final normalizado = valor.trim().toLowerCase();
  return prefijosFirmaPersona.any(normalizado.startsWith);
}

/// Parser CSV mínimo (RFC 4180): comillas, comillas dobles escapadas,
/// saltos de línea dentro de comillas y CRLF.
List<List<String>> leerFilasCsv(String texto) {
  final filas = <List<String>>[];
  var filaActual = <String>[];
  final campoActual = StringBuffer();
  var dentroDeComillas = false;
  var indice = 0;

  void cerrarCampo() {
    filaActual.add(campoActual.toString());
    campoActual.clear();
  }

  void cerrarFila() {
    cerrarCampo();
    filas.add(filaActual);
    filaActual = <String>[];
  }

  while (indice < texto.length) {
    final caracter = texto[indice];
    if (dentroDeComillas) {
      if (caracter == '"') {
        if (indice + 1 < texto.length && texto[indice + 1] == '"') {
          campoActual.write('"');
          indice++;
        } else {
          dentroDeComillas = false;
        }
      } else {
        campoActual.write(caracter);
      }
    } else if (caracter == '"') {
      dentroDeComillas = true;
    } else if (caracter == ',') {
      cerrarCampo();
    } else if (caracter == '\r') {
      // Se ignora: el \n siguiente cierra la fila.
    } else if (caracter == '\n') {
      cerrarFila();
    } else {
      campoActual.write(caracter);
    }
    indice++;
  }
  if (campoActual.isNotEmpty || filaActual.isNotEmpty) cerrarFila();
  return filas;
}

/// Analiza un CSV de catálogo con comentarios `#` en cabecera.
EstadoCatalogo analizarCatalogo(String texto, {required String ruta}) {
  final lineas = texto.split('\n');
  final comentarios =
      lineas.where((linea) => linea.trimLeft().startsWith('#')).join('\n');
  final sinComentarios =
      lineas.where((linea) => !linea.trimLeft().startsWith('#')).join('\n');
  final filas = leerFilasCsv(sinComentarios)
      .where((fila) => fila.any((campo) => campo.trim().isNotEmpty))
      .toList();

  final cabecera = filas.isEmpty ? <String>[] : filas.first;
  final datos = filas.length > 1 ? filas.sublist(1) : <List<String>>[];
  final indiceRevision =
      cabecera.indexWhere((columna) => columna.trim() == 'revisado_por');

  var sinRevisar = 0;
  var porFuente = 0;
  var porPersona = 0;
  if (indiceRevision >= 0) {
    for (final fila in datos) {
      final valor =
          indiceRevision < fila.length ? fila[indiceRevision].trim() : '';
      if (valor.isEmpty) {
        sinRevisar++;
      } else if (esFirmaDePersona(valor)) {
        porPersona++;
      } else {
        porFuente++;
      }
    }
  }

  return EstadoCatalogo(
    ruta: ruta,
    filas: datos.length,
    sinRevisar: sinRevisar,
    revisadasPorFuentePublica: porFuente,
    revisadasPorPersona: porPersona,
    cabeceraProvisional: comentarios.toUpperCase().contains('PROVISIONAL'),
    tieneColumnaRevision: indiceRevision >= 0,
  );
}

final RegExp _flagRevision =
    RegExp(r'catalogosCompletamenteRevisados\s*=\s*(true|false)');

/// Lee el `const bool catalogosCompletamenteRevisados` de `flag_revision.dart`.
bool? leerFlagRevision(String fuenteDart) {
  final coincidencia = _flagRevision.firstMatch(fuenteDart);
  return coincidencia == null ? null : coincidencia.group(1) == 'true';
}
