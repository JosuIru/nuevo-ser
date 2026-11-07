/// Lectura de ARB conservando la posición exacta de cada valor en el texto,
/// para poder reescribir solo las cadenas cambiadas y dejar intacto todo lo
/// demás (orden, metadatos `@...`, indentación, escapes originales).
library;

import 'dart:convert';

/// Un miembro de primer nivel del objeto JSON del ARB.
class EntradaArb {
  EntradaArb({
    required this.clave,
    required this.valor,
    required this.inicioValor,
    required this.finValor,
  });

  final String clave;

  /// Valor ya decodificado (String para los mensajes, Map para `@clave`).
  final Object? valor;

  /// Posiciones del valor en el texto original: `[inicioValor, finValor)`,
  /// comillas incluidas cuando es una cadena.
  final int inicioValor;
  final int finValor;

  bool get esMetadato => clave.startsWith('@');
}

/// Un ARB leído: su texto original y sus entradas en orden.
class ArchivoArb {
  ArchivoArb._(this.textoOriginal, this.entradas);

  /// Analiza el texto de un ARB. Lanza [FormatException] si no es un objeto
  /// JSON válido o tiene claves repetidas.
  factory ArchivoArb.analizar(String texto) {
    // jsonDecode valida la sintaxis completa con mensajes de error estándar.
    final objetoDecodificado = jsonDecode(texto);
    if (objetoDecodificado is! Map) {
      throw const FormatException('El ARB debe ser un objeto JSON {...}');
    }
    final entradas = _EscanerArb(texto).leerEntradasDePrimerNivel();
    final clavesVistas = <String>{};
    for (final entrada in entradas) {
      if (!clavesVistas.add(entrada.clave)) {
        throw FormatException('Clave repetida en el ARB: ${entrada.clave}');
      }
    }
    return ArchivoArb._(texto, entradas);
  }

  /// ARB vacío para una lengua que aún no tiene archivo.
  factory ArchivoArb.vacio(String lengua) =>
      ArchivoArb.analizar('{\n  "@@locale": ${jsonEncode(lengua)}\n}\n');

  final String textoOriginal;
  final List<EntradaArb> entradas;

  late final Map<String, EntradaArb> _entradaPorClave = {
    for (final entrada in entradas) entrada.clave: entrada,
  };

  String? get lengua => _entradaPorClave['@@locale']?.valor as String?;

  /// Claves de mensaje (sin `@`), en el orden del archivo.
  List<String> get clavesDeMensaje => [
        for (final entrada in entradas)
          if (!entrada.esMetadato) entrada.clave,
      ];

  bool contiene(String clave) => _entradaPorClave.containsKey(clave);

  /// Texto del mensaje [clave], o `null` si no existe o no es una cadena.
  String? mensaje(String clave) {
    final valor = _entradaPorClave[clave]?.valor;
    return valor is String ? valor : null;
  }

  /// `@clave.description`, si existe.
  String? descripcion(String clave) {
    final metadatos = _entradaPorClave['@$clave']?.valor;
    if (metadatos is! Map) return null;
    final descripcion = metadatos['description'];
    return descripcion is String ? descripcion : null;
  }

  /// Devuelve el texto del ARB con [mensajesNuevos] aplicados. Las claves que
  /// ya existen cambian solo su valor (si el texto decodificado no varía se
  /// conservan los bytes originales). Las que no existen se insertan tras la
  /// clave anterior según [ordenDeReferencia] (el orden del español), detrás
  /// de su `@metadato` si lo tiene.
  String conMensajes(Map<String, String> mensajesNuevos,
      {required List<String> ordenDeReferencia}) {
    final ediciones = <_Edicion>[];
    final clavesNuevasPorAncla = <int, List<String>>{};

    for (final MapEntry(key: clave, value: textoNuevo)
        in mensajesNuevos.entries) {
      final entradaExistente = _entradaPorClave[clave];
      if (entradaExistente != null) {
        if (entradaExistente.valor == textoNuevo) continue;
        ediciones.add(_Edicion(entradaExistente.inicioValor,
            entradaExistente.finValor, jsonEncode(textoNuevo)));
      } else {
        clavesNuevasPorAncla
            .putIfAbsent(
                _posicionDeInsercion(clave, ordenDeReferencia), () => [])
            .add(clave);
      }
    }

    final indentacion = _detectarIndentacion();
    final saltoDeLinea = textoOriginal.contains('\r\n') ? '\r\n' : '\n';
    for (final MapEntry(key: posicion, value: clavesNuevas)
        in clavesNuevasPorAncla.entries) {
      clavesNuevas.sort((claveA, claveB) => ordenDeReferencia
          .indexOf(claveA)
          .compareTo(ordenDeReferencia.indexOf(claveB)));
      final textoInsertado = StringBuffer();
      for (final clave in clavesNuevas) {
        textoInsertado
          ..write(',')
          ..write(saltoDeLinea)
          ..write(indentacion)
          ..write(jsonEncode(clave))
          ..write(': ')
          ..write(jsonEncode(mensajesNuevos[clave]));
      }
      ediciones.add(_Edicion(posicion, posicion, textoInsertado.toString()));
    }

    ediciones.sort(
        (edicionA, edicionB) => edicionB.inicio.compareTo(edicionA.inicio));
    var textoResultante = textoOriginal;
    for (final edicion in ediciones) {
      textoResultante = textoResultante.replaceRange(
          edicion.inicio, edicion.fin, edicion.textoNuevo);
    }
    return textoResultante;
  }

  /// Posición del texto tras la cual se inserta [claveNueva]: el final de la
  /// última entrada del grupo (clave + `@clave`) de la clave anterior que ya
  /// exista; si no hay ninguna, tras `@@locale` o tras la primera entrada.
  int _posicionDeInsercion(String claveNueva, List<String> ordenDeReferencia) {
    final indiceEnReferencia = ordenDeReferencia.indexOf(claveNueva);
    for (var indice = indiceEnReferencia - 1; indice >= 0; indice--) {
      final claveAnterior = ordenDeReferencia[indice];
      final entradaAnterior = _entradaPorClave[claveAnterior];
      if (entradaAnterior == null) continue;
      final metadatoAnterior = _entradaPorClave['@$claveAnterior'];
      if (metadatoAnterior != null &&
          metadatoAnterior.finValor > entradaAnterior.finValor) {
        return metadatoAnterior.finValor;
      }
      return entradaAnterior.finValor;
    }
    final entradaLocale = _entradaPorClave['@@locale'];
    if (entradaLocale != null) return entradaLocale.finValor;
    if (entradas.isEmpty) {
      throw StateError('No se puede insertar en un ARB sin ninguna entrada');
    }
    return entradas.first.finValor;
  }

  String _detectarIndentacion() {
    if (entradas.isEmpty) return '  ';
    final inicioClave = textoOriginal.lastIndexOf(
        '"${entradas.first.clave}"', entradas.first.inicioValor);
    final inicioLinea = textoOriginal.lastIndexOf('\n', inicioClave) + 1;
    final indentacion = textoOriginal.substring(inicioLinea, inicioClave);
    return indentacion.trim().isEmpty ? indentacion : '  ';
  }
}

class _Edicion {
  _Edicion(this.inicio, this.fin, this.textoNuevo);
  final int inicio;
  final int fin;
  final String textoNuevo;
}

/// Recorre el JSON (ya validado) anotando dónde empieza y acaba el valor de
/// cada miembro de primer nivel.
class _EscanerArb {
  _EscanerArb(this.texto);

  final String texto;
  int posicion = 0;

  List<EntradaArb> leerEntradasDePrimerNivel() {
    _saltarEspacios();
    _esperar('{');
    final entradas = <EntradaArb>[];
    _saltarEspacios();
    if (texto[posicion] == '}') return entradas;
    while (true) {
      _saltarEspacios();
      final inicioClave = posicion;
      _saltarCadena();
      final clave =
          jsonDecode(texto.substring(inicioClave, posicion)) as String;
      _saltarEspacios();
      _esperar(':');
      _saltarEspacios();
      final inicioValor = posicion;
      _saltarValor();
      final finValor = posicion;
      entradas.add(EntradaArb(
        clave: clave,
        valor: jsonDecode(texto.substring(inicioValor, finValor)),
        inicioValor: inicioValor,
        finValor: finValor,
      ));
      _saltarEspacios();
      if (texto[posicion] == ',') {
        posicion++;
        continue;
      }
      _esperar('}');
      return entradas;
    }
  }

  void _saltarEspacios() {
    while (posicion < texto.length && ' \t\r\n﻿'.contains(texto[posicion])) {
      posicion++;
    }
  }

  void _esperar(String caracter) {
    if (texto[posicion] != caracter) {
      throw FormatException('Se esperaba «$caracter»', texto, posicion);
    }
    posicion++;
  }

  void _saltarCadena() {
    _esperar('"');
    while (texto[posicion] != '"') {
      if (texto[posicion] == r'\') posicion++;
      posicion++;
    }
    posicion++;
  }

  void _saltarValor() {
    final caracter = texto[posicion];
    if (caracter == '"') {
      _saltarCadena();
    } else if (caracter == '{' || caracter == '[') {
      final cierre = caracter == '{' ? '}' : ']';
      posicion++;
      _saltarEspacios();
      if (texto[posicion] == cierre) {
        posicion++;
        return;
      }
      while (true) {
        _saltarEspacios();
        if (caracter == '{') {
          _saltarCadena();
          _saltarEspacios();
          _esperar(':');
          _saltarEspacios();
        }
        _saltarValor();
        _saltarEspacios();
        if (texto[posicion] == ',') {
          posicion++;
          continue;
        }
        _esperar(cierre);
        return;
      }
    } else {
      // Número, true, false o null.
      while (
          posicion < texto.length && !',}] \t\r\n'.contains(texto[posicion])) {
        posicion++;
      }
    }
  }
}
