/// Lectura y escritura de hojas CSV (RFC 4180) pensadas para abrirse en
/// LibreOffice o Excel.
library;

import 'dart:convert';

/// Marca de orden de bytes UTF-8. Con ella LibreOffice y Excel reconocen la
/// codificación y muestran bien los acentos.
const String marcaBom = '﻿';

/// Convierte filas en texto CSV: BOM al inicio, coma como separador, CRLF
/// entre filas y comillas dobles solo en los campos que las necesitan.
String escribirCsv(List<List<String>> filas) {
  final textoCsv = StringBuffer(marcaBom);
  for (final fila in filas) {
    textoCsv.write(fila.map(_entrecomillarSiHaceFalta).join(','));
    textoCsv.write('\r\n');
  }
  return textoCsv.toString();
}

String _entrecomillarSiHaceFalta(String celda) {
  final necesitaComillas = celda.contains(',') ||
      celda.contains('"') ||
      celda.contains('\n') ||
      celda.contains('\r') ||
      celda.startsWith(' ') ||
      celda.endsWith(' ');
  if (!necesitaComillas) return celda;
  return '"${celda.replaceAll('"', '""')}"';
}

/// Decodifica los bytes de una hoja en UTF-8 estricto. Si la hoja se guardó
/// en otra codificación (p. ej. Windows-1252), lanza un [FormatException] que
/// lo explica en lugar de corromper los acentos.
String decodificarBytesCsv(List<int> bytesCsv) {
  try {
    return utf8.decode(bytesCsv);
  } on FormatException {
    throw const FormatException(
        'La hoja no está guardada en UTF-8. Vuelve a guardarla como '
        '«CSV UTF-8» (Excel) o con el juego de caracteres «Unicode (UTF-8)» '
        '(LibreOffice).');
  }
}

/// Lee texto CSV y devuelve sus filas. Quita el BOM, acepta CRLF o LF, campos
/// entrecomillados con comas, comillas dobladas y saltos de línea. Detecta el
/// separador en la primera línea: punto y coma si aparece y no hay comas
/// (Excel con configuración regional española), coma en otro caso.
List<List<String>> leerCsv(String textoCsv) {
  final texto =
      textoCsv.startsWith(marcaBom) ? textoCsv.substring(1) : textoCsv;
  final separador = _detectarSeparador(texto);

  final filas = <List<String>>[];
  var filaActual = <String>[];
  final celdaActual = StringBuffer();
  var dentroDeComillas = false;
  var posicion = 0;

  void cerrarCelda() {
    filaActual.add(celdaActual.toString());
    celdaActual.clear();
  }

  void cerrarFila() {
    cerrarCelda();
    filas.add(filaActual);
    filaActual = <String>[];
  }

  while (posicion < texto.length) {
    final caracter = texto[posicion];
    if (dentroDeComillas) {
      if (caracter == '"') {
        final siguienteEsComilla =
            posicion + 1 < texto.length && texto[posicion + 1] == '"';
        if (siguienteEsComilla) {
          celdaActual.write('"');
          posicion += 2;
          continue;
        }
        dentroDeComillas = false;
      } else {
        celdaActual.write(caracter);
      }
      posicion++;
      continue;
    }

    if (caracter == '"' && celdaActual.isEmpty) {
      dentroDeComillas = true;
    } else if (caracter == separador) {
      cerrarCelda();
    } else if (caracter == '\r' &&
        posicion + 1 < texto.length &&
        texto[posicion + 1] == '\n') {
      cerrarFila();
      posicion++;
    } else if (caracter == '\n' || caracter == '\r') {
      cerrarFila();
    } else {
      celdaActual.write(caracter);
    }
    posicion++;
  }

  if (dentroDeComillas) {
    throw const FormatException(
        'El CSV tiene unas comillas sin cerrar: revisa la última celda editada.');
  }
  if (celdaActual.isNotEmpty || filaActual.isNotEmpty) cerrarFila();
  return filas;
}

String _detectarSeparador(String texto) {
  final finPrimeraLinea = texto.indexOf(RegExp('[\r\n]'));
  final primeraLinea =
      finPrimeraLinea == -1 ? texto : texto.substring(0, finPrimeraLinea);
  if (primeraLinea.contains(';') && !primeraLinea.contains(',')) return ';';
  return ',';
}
