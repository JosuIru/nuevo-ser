import 'package:pendientes/pendientes.dart';

class ResultadoFirma {
  ResultadoFirma(
      this.texto, this.filasFirmadas, this.identificadoresNoEncontrados);

  final String texto;
  final int filasFirmadas;
  final Set<String> identificadoresNoEncontrados;
}

/// Pone comillas solo si el campo lleva coma, comillas o salto de línea.
String escribirCampoCsv(String campo) {
  if (!campo.contains(RegExp(r'[",\r\n]'))) return campo;
  return '"${campo.replaceAll('"', '""')}"';
}

/// Prefijos que acepta [firmarCatalogo]: firma de asesor, firma de persona
/// (p. ej. el titular que asume la revisión) o revisión de IA.
const List<String> prefijosAdmitidos = [
  'asesor:',
  'persona:',
  prefijoRevisionIa
];

/// Escribe `<prefijo> <firma>` en `revisado_por` de cada fila (o solo de las
/// de [identificadores], por la primera columna). La cita previa se conserva
/// detrás (`; fuente: ...`). Las líneas que no se firman no se tocan, ni las
/// de comentario `#`, para que el diff sea mínimo. Una fila firmada por
/// persona no se vuelve a tocar; una revisión de IA no se repite, pero sí
/// admite encima la firma de una persona.
ResultadoFirma firmarCatalogo(String texto,
    {required String firma,
    String prefijo = 'asesor:',
    Set<String>? identificadores}) {
  if (firma.trim().isEmpty) {
    throw ArgumentError.value(firma, 'firma', 'no puede estar vacía');
  }
  if (!prefijosAdmitidos.contains(prefijo)) {
    throw ArgumentError.value(
        prefijo, 'prefijo', 'debe ser uno de ${prefijosAdmitidos.join(' ')}');
  }
  final anotaRevisionIa = prefijo == prefijoRevisionIa;
  final lineas = texto.split('\n');
  int? indiceRevision;
  var filasFirmadas = 0;
  final encontrados = <String>{};

  for (var indice = 0; indice < lineas.length; indice++) {
    final linea = lineas[indice];
    if (linea.trim().isEmpty || linea.trimLeft().startsWith('#')) continue;
    final campos = leerFilasCsv(linea).firstOrNull ?? const <String>[];
    if (indiceRevision == null) {
      final posicion =
          campos.indexWhere((columna) => columna.trim() == 'revisado_por');
      if (posicion < 0) {
        throw const FormatException('El CSV no tiene columna revisado_por');
      }
      indiceRevision = posicion;
      continue;
    }
    if (campos.isEmpty) continue;
    final identificador = campos.first.trim();
    if (identificadores != null && !identificadores.contains(identificador)) {
      continue;
    }
    encontrados.add(identificador);
    final camposCompletos = [
      ...campos,
      for (var relleno = campos.length; relleno <= indiceRevision; relleno++)
        '',
    ];
    final valorPrevio = camposCompletos[indiceRevision].trim();
    if (esFirmaDePersona(valorPrevio)) continue;
    if (anotaRevisionIa && esRevisionDeIa(valorPrevio)) continue;
    camposCompletos[indiceRevision] = valorPrevio.isEmpty
        ? '$prefijo ${firma.trim()}'
        : '$prefijo ${firma.trim()}; fuente: $valorPrevio';
    final finDeLinea = linea.endsWith('\r') ? '\r' : '';
    lineas[indice] =
        camposCompletos.map(escribirCampoCsv).join(',') + finDeLinea;
    filasFirmadas++;
  }
  if (indiceRevision == null) {
    throw const FormatException('El CSV no tiene columna revisado_por');
  }

  return ResultadoFirma(
    lineas.join('\n'),
    filasFirmadas,
    identificadores == null ? {} : identificadores.difference(encontrados),
  );
}
