/// Lectura de una hoja de cálculo que trae la persona (CSV de Excel o
/// LibreOffice, o un `.xlsx`) como tabla de textos: cabecera y filas, sin
/// interpretar. La interpretación (columnas, fechas, crotales) es cosa de
/// quien la usa (`importar_animales.dart`).
///
/// - CSV: `;` o `,` (lo detecta el core), BOM, LF o CRLF, comillas. Excel en
///   castellano guarda el «CSV (delimitado por comas)» en Windows-1252, no
///   en UTF-8: si los bytes no son UTF-8 válido se leen como Latin-1, para
///   que «Rebaño» no salga como «Reba�o».
/// - XLSX: solo la primera hoja; textos compartidos, en línea y números.
///   Las fechas llegan como el número de serie de Excel (45123): las
///   convierte quien sabe que esa columna es una fecha.
library;

import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:xml/xml.dart';

/// El fichero no es una hoja de cálculo que sepamos leer.
class HojaNoLegible implements Exception {
  const HojaNoLegible(this.motivo);
  final String motivo;
  @override
  String toString() => 'HojaNoLegible: $motivo';
}

/// Lee [bytes] como CSV o XLSX (por la extensión de [nombreFichero] o por
/// la firma `PK` de los zip).
TablaCsv leerTablaDeFichero(String nombreFichero, List<int> bytes) {
  final esZip = bytes.length > 4 && bytes[0] == 0x50 && bytes[1] == 0x4B;
  if (nombreFichero.toLowerCase().endsWith('.xlsx') || esZip) {
    return leerXlsx(bytes);
  }
  if (nombreFichero.toLowerCase().endsWith('.xls')) {
    // Formato binario antiguo de Excel: no se lee.
    throw const HojaNoLegible('xls');
  }
  return parsearTablaCsv(textoDeBytes(bytes));
}

/// UTF-8 si lo es (con o sin BOM); si no, Latin-1 (Windows-1252 en lo que
/// importa: letras acentuadas y eñes).
String textoDeBytes(List<int> bytes) {
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return latin1.decode(bytes);
  }
}

/// Primera hoja de un `.xlsx` como tabla de textos. Las celdas vacías
/// intermedias se rellenan con '' para que cada valor quede bajo su
/// columna.
TablaCsv leerXlsx(List<int> bytes) {
  final Archive zip;
  try {
    zip = ZipDecoder().decodeBytes(bytes);
  } catch (_) {
    throw const HojaNoLegible('zip');
  }
  String? texto(String ruta) {
    final fichero = zip.findFile(ruta);
    if (fichero == null) return null;
    return utf8.decode(fichero.content as List<int>, allowMalformed: true);
  }

  final rutaHoja = _rutaPrimeraHoja(texto) ??
      (zip.files
              .map((fichero) => fichero.name)
              .where((nombre) =>
                  nombre.startsWith('xl/worksheets/') &&
                  nombre.endsWith('.xml'))
              .toList()
            ..sort())
          .firstOrNull;
  final xmlHoja = rutaHoja == null ? null : texto(rutaHoja);
  if (xmlHoja == null) throw const HojaNoLegible('sin hoja');

  final compartidos = <String>[];
  final xmlCompartidos = texto('xl/sharedStrings.xml');
  if (xmlCompartidos != null) {
    for (final elemento
        in XmlDocument.parse(xmlCompartidos).findAllElements('si')) {
      // Un texto con formato viene troceado en varios <r><t>.
      compartidos.add(
          elemento.findAllElements('t').map((t) => t.innerText).join());
    }
  }

  final filas = <List<String>>[];
  for (final fila in XmlDocument.parse(xmlHoja).findAllElements('row')) {
    final valores = <String>[];
    for (final celda in fila.findElements('c')) {
      final referencia = celda.getAttribute('r');
      if (referencia != null) {
        final columna = _indiceColumna(referencia);
        while (valores.length < columna) {
          valores.add('');
        }
      }
      valores.add(_valorCelda(celda, compartidos));
    }
    while (valores.isNotEmpty && valores.last.trim().isEmpty) {
      valores.removeLast();
    }
    if (valores.isNotEmpty) filas.add(valores);
  }
  if (filas.isEmpty) return (cabecera: const [], filas: const []);
  return (cabecera: filas.first, filas: filas.sublist(1));
}

/// La primera hoja según `workbook.xml` y sus relaciones (puede no
/// llamarse `sheet1.xml`).
String? _rutaPrimeraHoja(String? Function(String) texto) {
  final libro = texto('xl/workbook.xml');
  final relaciones = texto('xl/_rels/workbook.xml.rels');
  if (libro == null || relaciones == null) return null;
  final primera = XmlDocument.parse(libro).findAllElements('sheet').firstOrNull;
  final idRelacion = primera?.attributes
      .where((atributo) => atributo.name.local == 'id')
      .firstOrNull
      ?.value;
  if (idRelacion == null) return null;
  for (final relacion
      in XmlDocument.parse(relaciones).findAllElements('Relationship')) {
    if (relacion.getAttribute('Id') != idRelacion) continue;
    final destino = relacion.getAttribute('Target') ?? '';
    if (destino.startsWith('/')) return destino.substring(1);
    return 'xl/$destino';
  }
  return null;
}

/// «C12» → 2 (A = 0).
int _indiceColumna(String referencia) {
  var indice = 0;
  for (final unidad in referencia.codeUnits) {
    if (unidad < 0x41 || unidad > 0x5A) break;
    indice = indice * 26 + (unidad - 0x40);
  }
  return indice - 1;
}

String _valorCelda(XmlElement celda, List<String> compartidos) {
  final tipo = celda.getAttribute('t') ?? 'n';
  if (tipo == 'inlineStr') {
    return celda.findAllElements('t').map((t) => t.innerText).join();
  }
  final valor = celda.getElement('v')?.innerText ?? '';
  switch (tipo) {
    case 's':
      final indice = int.tryParse(valor);
      return indice == null || indice >= compartidos.length
          ? ''
          : compartidos[indice];
    case 'n':
      return _numeroLegible(valor);
    default:
      return valor;
  }
}

/// Un número de Excel como texto sin decimales sobrantes: «12345678901»
/// (no «1.2345678901E10»), «45123», «2.5».
String _numeroLegible(String valor) {
  final numero = double.tryParse(valor);
  if (numero == null) return valor;
  if (numero == numero.truncateToDouble() && numero.abs() < 1e18) {
    return BigInt.from(numero).toString();
  }
  return valor;
}
