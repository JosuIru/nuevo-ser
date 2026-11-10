import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'ejercicio.dart';

/// Paleta de la ficha: el violeta base de Uno Roto (PaletaNeon.violetaBase)
/// como acento, sobre papel blanco. Todo lo demás en grises, que en una
/// fotocopiadora en blanco y negro sigue leyéndose.
class PaletaFicha {
  static const acento = PdfColor.fromInt(0xFF4B2E83);
  static const fondoSuave = PdfColor.fromInt(0xFFF1EDF8);
  static const texto = PdfColor.fromInt(0xFF1F1A2E);
  static const textoTenue = PdfColor.fromInt(0xFF5E5873);
  static const renglon = PdfColor.fromInt(0xFFB9B3C9);
}

/// Letras de la ficha (Roboto, Apache 2.0, la misma que trae Uno Roto).
/// Sin ellas el paquete pdf usa Helvetica, que se come «−», «·» y algunos
/// acentos.
class LetrasFicha {
  final pw.Font normal;
  final pw.Font negrita;
  const LetrasFicha({required this.normal, required this.negrita});

  factory LetrasFicha.desdeBytes(Uint8List normal, Uint8List negrita) => LetrasFicha(
        normal: pw.Font.ttf(normal.buffer.asByteData()),
        negrita: pw.Font.ttf(negrita.buffer.asByteData()),
      );
}

/// «4P» → «4.º Primaria», «1E» → «1.º ESO».
String nombreCurso(String? curso) {
  if (curso == null || curso.length < 2) return '';
  final numero = curso.substring(0, curso.length - 1);
  final etapa = curso.endsWith('E') ? 'ESO' : 'Primaria';
  return '$numero.º $etapa';
}

/// Convierte el marcado `^{...}` en tramos con superíndice.
List<pw.InlineSpan> tramosConSuperindices(String texto, pw.TextStyle estilo) {
  final tramos = <pw.InlineSpan>[];
  final patron = RegExp(r'\^\{([^}]*)\}');
  var posicion = 0;
  final tamano = estilo.fontSize ?? 12;
  for (final coincidencia in patron.allMatches(texto)) {
    if (coincidencia.start > posicion) {
      tramos.add(pw.TextSpan(text: texto.substring(posicion, coincidencia.start), style: estilo));
    }
    tramos.add(pw.TextSpan(
      text: coincidencia.group(1),
      style: estilo.copyWith(fontSize: tamano * 0.62),
      baseline: tamano * 0.38,
    ));
    posicion = coincidencia.end;
  }
  if (posicion < texto.length) {
    tramos.add(pw.TextSpan(text: texto.substring(posicion), style: estilo));
  }
  return tramos;
}

pw.Widget _textoMarcado(String texto, pw.TextStyle estilo) =>
    pw.RichText(text: pw.TextSpan(children: tramosConSuperindices(texto, estilo)));

/// Renglones para escribir a mano que ocupan todo el hueco disponible.
pw.Widget _renglones({double separacion = 9 * PdfPageFormat.mm}) => pw.CustomPaint(
      size: const PdfPoint(double.infinity, double.infinity),
      painter: (lienzo, tamano) {
        lienzo
          ..setStrokeColor(PaletaFicha.renglon)
          ..setLineWidth(0.6);
        // El origen del CustomPaint está abajo a la izquierda.
        for (var altura = tamano.y - separacion; altura > 2; altura -= separacion) {
          lienzo
            ..moveTo(0, altura)
            ..lineTo(tamano.x, altura);
        }
        lienzo.strokePath();
      },
    );

pw.Widget _cabecera(ContenidoFicha ficha, pw.TextStyle base) {
  final detalle = [
    ficha.idHabilidad,
    ficha.nombreDominio,
    nombreCurso(ficha.curso),
  ].where((parte) => parte.isNotEmpty).join(' · ');
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 5),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PaletaFicha.acento, width: 1.2)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Colección Nuevo Ser Kids · Uno Roto',
            style: base.copyWith(
                fontSize: 9.5, color: PaletaFicha.acento, fontWeight: pw.FontWeight.bold)),
        pw.Text(detalle, style: base.copyWith(fontSize: 9, color: PaletaFicha.textoTenue)),
      ],
    ),
  );
}

pw.Widget _numeroEjercicio(String etiqueta, pw.TextStyle base) => pw.Container(
      width: 20,
      height: 20,
      alignment: pw.Alignment.center,
      decoration: const pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        border: pw.Border.fromBorderSide(pw.BorderSide(color: PaletaFicha.acento, width: 1.2)),
      ),
      child: pw.Text(etiqueta,
          style: base.copyWith(
              fontSize: 10, color: PaletaFicha.acento, fontWeight: pw.FontWeight.bold)),
    );

pw.Widget _tabla(List<List<String>> filas, pw.TextStyle base) => pw.Table(
      border: pw.TableBorder.all(color: PaletaFicha.textoTenue, width: 0.6),
      defaultColumnWidth: const pw.IntrinsicColumnWidth(),
      tableWidth: pw.TableWidth.min,
      children: [
        for (var indice = 0; indice < filas.length; indice++)
          pw.TableRow(
            decoration: indice == 0 ? const pw.BoxDecoration(color: PaletaFicha.fondoSuave) : null,
            children: [
              for (final celda in filas[indice])
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: pw.Center(
                    child: _textoMarcado(
                        celda,
                        base.copyWith(
                            fontSize: 11,
                            fontWeight: indice == 0 ? pw.FontWeight.bold : null)),
                  ),
                ),
            ],
          ),
      ],
    );

pw.Widget _bloqueEjercicio(int numero, Ejercicio ejercicio, pw.TextStyle base) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _numeroEjercicio('$numero', base),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(top: 3),
              child: _textoMarcado(ejercicio.enunciado, base.copyWith(fontSize: 12)),
            ),
          ),
        ],
      ),
      if (ejercicio.destacado != null)
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 28, top: 6),
          child: _textoMarcado(ejercicio.destacado!,
              base.copyWith(fontSize: 17, fontWeight: pw.FontWeight.bold)),
        ),
      if (ejercicio.tabla != null)
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 28, top: 6),
          child: _tabla(ejercicio.tabla!, base),
        ),
      pw.Expanded(
        child: pw.Padding(
          padding: const pw.EdgeInsets.only(left: 28, top: 2),
          child: _renglones(),
        ),
      ),
    ],
  );
}

pw.Widget _bloqueExplicalo(ContenidoFicha ficha, pw.TextStyle base) => pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(10, 8, 10, 4),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PaletaFicha.acento, width: 0.8),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Explícalo con tus palabras',
              style: base.copyWith(
                  fontSize: 11, color: PaletaFicha.acento, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 3),
          _textoMarcado(ficha.preguntaExplicalo, base.copyWith(fontSize: 12)),
          pw.Expanded(child: _renglones()),
        ],
      ),
    );

pw.Widget _pie(ContenidoFicha ficha, pw.TextStyle base) => pw.Column(
      children: [
        pw.Row(
          children: [
            pw.Text('Nombre: ', style: base.copyWith(fontSize: 12)),
            pw.Expanded(child: _lineaRelleno()),
            pw.SizedBox(width: 16),
            pw.Text('Fecha: ', style: base.copyWith(fontSize: 12)),
            pw.SizedBox(width: 110, child: _lineaRelleno()),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Colección Nuevo Ser Kids · coleccion-nuevo-ser.gailu.net · Contenido CC BY-SA 4.0 · '
          'Ficha ${ficha.idHabilidad}, semilla ${ficha.semilla}',
          style: base.copyWith(fontSize: 7.5, color: PaletaFicha.textoTenue),
        ),
      ],
    );

pw.Widget _lineaRelleno() => pw.Container(
      height: 12,
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PaletaFicha.texto, width: 0.7)),
      ),
    );

/// Una página A4 por ficha. Los huecos para escribir se reparten el alto
/// que quede, así que la ficha cabe siempre en una hoja.
pw.Page paginaFicha(ContenidoFicha ficha, LetrasFicha letras) {
  final base = pw.TextStyle(font: letras.normal, fontBold: letras.negrita, color: PaletaFicha.texto);
  return pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(
        16 * PdfPageFormat.mm, 12 * PdfPageFormat.mm, 16 * PdfPageFormat.mm, 10 * PdfPageFormat.mm),
    theme: pw.ThemeData.withFont(base: letras.normal, bold: letras.negrita),
    build: (contexto) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _cabecera(ficha, base),
        pw.SizedBox(height: 10),
        _textoMarcado(ficha.nombreHabilidad,
            base.copyWith(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PaletaFicha.fondoSuave,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: _textoMarcado(ficha.descripcion, base.copyWith(fontSize: 11.5, lineSpacing: 1.5)),
        ),
        pw.SizedBox(height: 10),
        for (var indice = 0; indice < ficha.ejercicios.length; indice++)
          pw.Expanded(
            flex: 2 + ficha.ejercicios[indice].renglones,
            child: _bloqueEjercicio(indice + 1, ficha.ejercicios[indice], base),
          ),
        pw.SizedBox(height: 4),
        pw.Expanded(flex: 5, child: _bloqueExplicalo(ficha, base)),
        pw.SizedBox(height: 10),
        _pie(ficha, base),
      ],
    ),
  );
}

/// PDF con una ficha por página.
Future<Uint8List> generarPdfFichas(List<ContenidoFicha> fichas, LetrasFicha letras) async {
  if (fichas.isEmpty) throw ArgumentError('No hay fichas que generar');
  final documento = pw.Document(
    title: fichas.length == 1
        ? 'Ficha ${fichas.first.idHabilidad} · Uno Roto'
        : 'Fichas Uno Roto',
    author: 'Colección Nuevo Ser Kids',
    creator: 'fichas_imprimibles',
  );
  for (final ficha in fichas) {
    documento.addPage(paginaFicha(ficha, letras));
  }
  return documento.save();
}
