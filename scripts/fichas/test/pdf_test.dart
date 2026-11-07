import 'dart:convert';

import 'package:fichas_imprimibles/fichas_imprimibles.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:test/test.dart';

void main() {
  final raiz = localizarRaizPaquete()!;
  final catalogo = cargarCatalogo(rutaSkillsPorDefecto(raiz));
  final letras = cargarLetras(raiz);

  test('el PDF de una ficha se genera, empieza por %PDF y no está vacío', () async {
    final ficha = generarContenidoFicha(catalogo, catalogo.porId('FR.10')!);
    final bytes = await generarPdfFichas([ficha], letras);
    expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
    expect(bytes.length, greaterThan(5000));
  });

  test('todas las fichas disponibles se maquetan sin excepción, una por página', () async {
    final fichas = [
      for (final id in plantillasPorHabilidad.keys)
        generarContenidoFicha(catalogo, catalogo.porId(id)!, semilla: 3),
    ];
    final bytes = await generarPdfFichas(fichas, letras);
    final texto = latin1.decode(bytes);
    final paginas = RegExp(r'/Type\s*/Page\b').allMatches(texto).length;
    expect(paginas, fichas.length);
  });

  test('sin fichas no se genera nada', () {
    expect(() => generarPdfFichas([], letras), throwsArgumentError);
  });

  test('nombre de curso legible', () {
    expect(nombreCurso('4P'), '4.º Primaria');
    expect(nombreCurso('2E'), '2.º ESO');
    expect(nombreCurso(null), '');
  });

  test('superíndices: el marcado se parte en tramos', () {
    final tramos = tramosConSuperindices('2^{5} · 2^{3}', const pw.TextStyle(fontSize: 10));
    expect(tramos, hasLength(4));
    expect(tramosConSuperindices('sin marcado', const pw.TextStyle()), hasLength(1));
  });
}
