/// Operaciones del revisor: exportar un ARB a hoja, importar la hoja revisada
/// y resumir el estado de las traducciones de un directorio.
library;

import 'dart:io';

import 'archivo_arb.dart';
import 'hoja_csv.dart';
import 'mensaje_icu.dart';

const lenguaDeReferencia = 'es';

const columnaClave = 'clave';
const columnaEstado = 'estado';
const columnaNota = 'nota';
const columnaDescripcion = 'descripcion';

const estadoPendiente = 'pendiente';
const estadoFalta = 'falta';
const estadoIgualQueEspanol = 'igual_que_es';
const estadoRevisado = 'revisado';

/// Los ARB de un directorio: el español y la ruta de cada otra lengua.
class DirectorioArb {
  DirectorioArb._(this.directorio, this.prefijo, this.archivoPorLengua);

  /// Busca `<prefijo>_<lengua>.arb` en [directorio]. Exige que exista el de
  /// español, que fija el prefijo (normalmente `app`).
  factory DirectorioArb.cargar(Directory directorio) {
    if (!directorio.existsSync()) {
      throw ArgumentError('No existe el directorio ${directorio.path}');
    }
    final patronNombre =
        RegExp(r'^(.+)_([A-Za-z]{2,3}(?:_[A-Za-z0-9]+)?)\.arb$');
    final archivosPorPrefijo = <String, Map<String, File>>{};
    for (final elemento in directorio.listSync()) {
      if (elemento is! File) continue;
      final nombreArchivo = elemento.uri.pathSegments.last;
      final coincidencia = patronNombre.firstMatch(nombreArchivo);
      if (coincidencia == null) continue;
      archivosPorPrefijo.putIfAbsent(
          coincidencia.group(1)!, () => {})[coincidencia.group(2)!] = elemento;
    }
    final prefijosConEspanol = [
      for (final MapEntry(key: prefijo, value: archivos)
          in archivosPorPrefijo.entries)
        if (archivos.containsKey(lenguaDeReferencia)) prefijo,
    ];
    if (prefijosConEspanol.isEmpty) {
      throw ArgumentError(
          'No hay ningún *_$lenguaDeReferencia.arb en ${directorio.path}');
    }
    if (prefijosConEspanol.length > 1) {
      throw ArgumentError('Hay varios ARB de español en ${directorio.path}: '
          '${prefijosConEspanol.map((prefijo) => '${prefijo}_es.arb').join(', ')}');
    }
    final prefijo = prefijosConEspanol.single;
    return DirectorioArb._(directorio, prefijo, archivosPorPrefijo[prefijo]!);
  }

  final Directory directorio;
  final String prefijo;
  final Map<String, File> archivoPorLengua;

  ArchivoArb get espanol => _leer(archivoPorLengua[lenguaDeReferencia]!);

  File archivoDe(String lengua) =>
      archivoPorLengua[lengua] ??
      File('${directorio.path}${Platform.pathSeparator}${prefijo}_$lengua.arb');

  /// ARB de [lengua], o uno vacío si aún no existe.
  ArchivoArb leerLengua(String lengua) {
    final archivo = archivoDe(lengua);
    return archivo.existsSync() ? _leer(archivo) : ArchivoArb.vacio(lengua);
  }

  List<String> get lenguasTraducidas => [
        for (final lengua in archivoPorLengua.keys)
          if (lengua != lenguaDeReferencia) lengua,
      ]..sort();

  static ArchivoArb _leer(File archivo) {
    try {
      return ArchivoArb.analizar(archivo.readAsStringSync());
    } on FormatException catch (error) {
      throw FormatException('${archivo.path}: ${error.message}');
    }
  }
}

void _exigirLenguaTraducida(String lengua) {
  if (lengua == lenguaDeReferencia) {
    throw ArgumentError(
        'El ARB de español es la referencia y no se exporta ni se modifica.');
  }
}

String _estadoInicial(String textoEspanol, String? textoTraducido) {
  if (textoTraducido == null || textoTraducido.trim().isEmpty) {
    return estadoFalta;
  }
  if (textoTraducido == textoEspanol) return estadoIgualQueEspanol;
  return estadoPendiente;
}

/// Genera las filas de la hoja de revisión de [lengua].
List<List<String>> filasDeRevision(
    ArchivoArb espanol, ArchivoArb traducido, String lengua) {
  return [
    [
      columnaClave,
      lenguaDeReferencia,
      lengua,
      columnaEstado,
      columnaNota,
      columnaDescripcion
    ],
    for (final clave in espanol.clavesDeMensaje)
      if (espanol.mensaje(clave) case final textoEspanol?)
        [
          clave,
          textoEspanol,
          traducido.mensaje(clave) ?? '',
          _estadoInicial(textoEspanol, traducido.mensaje(clave)),
          '',
          espanol.descripcion(clave) ?? traducido.descripcion(clave) ?? '',
        ],
  ];
}

/// `exportar`: escribe en [salida] la hoja CSV de revisión de [lengua].
/// Devuelve el número de cadenas exportadas.
int exportarHoja(Directory directorioArb, String lengua, File salida) {
  _exigirLenguaTraducida(lengua);
  final directorio = DirectorioArb.cargar(directorioArb);
  final filas = filasDeRevision(
      directorio.espanol, directorio.leerLengua(lengua), lengua);
  salida.writeAsStringSync(escribirCsv(filas));
  return filas.length - 1;
}

/// Fila de la hoja que no se ha aplicado y por qué.
class RechazoFila {
  RechazoFila(this.clave, this.motivo, {required this.numeroDeFila});
  final String clave;
  final String motivo;

  /// Número de fila en la hoja de cálculo (la cabecera es la 1).
  final int numeroDeFila;

  @override
  String toString() => 'fila $numeroDeFila «$clave»: $motivo';
}

class ResultadoImportacion {
  ResultadoImportacion({
    required this.archivo,
    required this.aplicadas,
    required this.revisadasSinCambios,
    required this.rechazadas,
    required this.filasNoRevisadas,
  });

  final File archivo;

  /// Claves cuyo texto ha cambiado o se ha añadido, en el orden de la hoja.
  final List<String> aplicadas;

  /// Filas revisadas cuyo texto ya coincidía con el ARB.
  final int revisadasSinCambios;
  final List<RechazoFila> rechazadas;

  /// Filas con un estado distinto de `revisado` (se ignoran).
  final int filasNoRevisadas;
}

String _normalizarSaltos(String texto) =>
    texto.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

/// `importar`: aplica a la lengua [lengua] las filas `revisado` de [entrada].
/// Solo escribe el ARB si alguna fila cambia algo. Nunca toca el español.
ResultadoImportacion importarHoja(
    Directory directorioArb, String lengua, File entrada) {
  _exigirLenguaTraducida(lengua);
  final directorio = DirectorioArb.cargar(directorioArb);
  final espanol = directorio.espanol;
  final traducido = directorio.leerLengua(lengua);
  final filas = leerCsv(decodificarBytesCsv(entrada.readAsBytesSync()));
  if (filas.isEmpty) throw const FormatException('La hoja está vacía.');

  final cabecera = [for (final celda in filas.first) celda.trim()];
  int indiceColumna(String nombreColumna) {
    final indice = cabecera.indexOf(nombreColumna);
    if (indice == -1) {
      throw FormatException(
          'Falta la columna «$nombreColumna» en la cabecera de la hoja.');
    }
    return indice;
  }

  final indiceClave = indiceColumna(columnaClave);
  final indiceEspanol = indiceColumna(lenguaDeReferencia);
  final indiceTraduccion = indiceColumna(lengua);
  final indiceEstado = indiceColumna(columnaEstado);
  String celda(List<String> fila, int indice) =>
      indice < fila.length ? fila[indice] : '';

  final mensajesNuevos = <String, String>{};
  final aplicadas = <String>[];
  final rechazadas = <RechazoFila>[];
  var revisadasSinCambios = 0;
  var filasNoRevisadas = 0;

  for (var indiceFila = 1; indiceFila < filas.length; indiceFila++) {
    final fila = filas[indiceFila];
    if (fila.every((valor) => valor.trim().isEmpty)) continue;
    final estado = celda(fila, indiceEstado).trim().toLowerCase();
    if (estado != estadoRevisado) {
      filasNoRevisadas++;
      continue;
    }
    final clave = celda(fila, indiceClave).trim();
    void rechazar(String motivo) => rechazadas
        .add(RechazoFila(clave, motivo, numeroDeFila: indiceFila + 1));

    final textoEspanolActual = espanol.mensaje(clave);
    if (clave.isEmpty || clave.startsWith('@') || textoEspanolActual == null) {
      rechazar('la clave no existe en el ARB de español');
      continue;
    }
    if (mensajesNuevos.containsKey(clave) || aplicadas.contains(clave)) {
      rechazar('la clave aparece repetida en la hoja');
      continue;
    }
    if (_normalizarSaltos(celda(fila, indiceEspanol)) !=
        _normalizarSaltos(textoEspanolActual)) {
      rechazar('el texto en español ha cambiado desde que se exportó la hoja; '
          'hay que volver a exportarla');
      continue;
    }
    final textoTraducido = _normalizarSaltos(celda(fila, indiceTraduccion));
    if (textoTraducido.trim().isEmpty) {
      rechazar('la traducción está vacía');
      continue;
    }
    final problemaDeEstructura =
        compararEstructuraIcu(textoEspanolActual, textoTraducido);
    if (problemaDeEstructura != null) {
      rechazar(problemaDeEstructura);
      continue;
    }
    if (traducido.mensaje(clave) == textoTraducido) {
      revisadasSinCambios++;
      continue;
    }
    mensajesNuevos[clave] = textoTraducido;
    aplicadas.add(clave);
  }

  final archivo = directorio.archivoDe(lengua);
  if (mensajesNuevos.isNotEmpty) {
    archivo.writeAsStringSync(traducido.conMensajes(mensajesNuevos,
        ordenDeReferencia: espanol.clavesDeMensaje));
  }
  return ResultadoImportacion(
    archivo: archivo,
    aplicadas: aplicadas,
    revisadasSinCambios: revisadasSinCambios,
    rechazadas: rechazadas,
    filasNoRevisadas: filasNoRevisadas,
  );
}

class ResumenLengua {
  ResumenLengua({
    required this.lengua,
    required this.total,
    required this.faltan,
    required this.igualesAlEspanol,
    required this.sobrantes,
    required this.conErrorDeEstructura,
  });

  final String lengua;

  /// Cadenas del español.
  final int total;
  final int faltan;
  final int igualesAlEspanol;

  /// Claves de la lengua que ya no existen en español.
  final int sobrantes;

  /// Traducciones cuyos placeholders o ICU no coinciden con el español.
  final int conErrorDeEstructura;
}

/// `estado`: resumen de cada lengua traducida del directorio.
List<ResumenLengua> resumirDirectorio(Directory directorioArb) {
  final directorio = DirectorioArb.cargar(directorioArb);
  final espanol = directorio.espanol;
  final clavesEspanol = espanol.clavesDeMensaje;
  return [
    for (final lengua in directorio.lenguasTraducidas)
      () {
        final traducido = directorio.leerLengua(lengua);
        var faltan = 0;
        var iguales = 0;
        var conError = 0;
        for (final clave in clavesEspanol) {
          final textoEspanol = espanol.mensaje(clave);
          if (textoEspanol == null) continue;
          final textoTraducido = traducido.mensaje(clave);
          switch (_estadoInicial(textoEspanol, textoTraducido)) {
            case estadoFalta:
              faltan++;
            case estadoIgualQueEspanol:
              iguales++;
          }
          if (textoTraducido != null &&
              textoTraducido.trim().isNotEmpty &&
              compararEstructuraIcu(textoEspanol, textoTraducido) != null) {
            conError++;
          }
        }
        return ResumenLengua(
          lengua: lengua,
          total: clavesEspanol.length,
          faltan: faltan,
          igualesAlEspanol: iguales,
          sobrantes: traducido.clavesDeMensaje
              .where((clave) => !espanol.contiene(clave))
              .length,
          conErrorDeEstructura: conError,
        );
      }(),
  ];
}
