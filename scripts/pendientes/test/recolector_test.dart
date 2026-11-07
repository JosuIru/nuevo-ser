import 'dart:io';

import 'package:pendientes/pendientes.dart';
import 'package:test/test.dart';

void main() {
  group('buscarLineasConSello', () {
    test('encuentra el literal con comilla simple o doble', () {
      const fuente = '''
/// El PDF lleva el sello `PROVISIONAL` hasta validación.
final subtitulo = 'Libro del aceite'
    ' · RD 760/2021 + AICA · PROVISIONAL';
const otro = "PROVISIONAL — sin validar";
// 'PROVISIONAL en un comentario no cuenta
''';
      expect(buscarLineasConSello(fuente), [
        "' · RD 760/2021 + AICA · PROVISIONAL';",
        'const otro = "PROVISIONAL — sin validar";',
      ]);
    });

    test('sin literal no hay sello', () {
      expect(buscarLineasConSello('// PROVISIONAL\nfinal a = 1;'), isEmpty);
    });
  });

  test('recolectar lee bloqueos, sellos, flags y catálogos de un árbol', () {
    final raiz = Directory.systemTemp.createTempSync('pendientes_');
    addTearDown(() => raiz.deleteSync(recursive: true));
    void escribir(String ruta, String texto) =>
        (File('${raiz.path}/$ruta')..parent.createSync(recursive: true))
            .writeAsStringSync(texto);

    escribir('apps/solera-x/BLOQUEOS-PENDIENTES.md',
        '# X\n\n## Libro económico\n\nAsesor fiscal.\n\n## Branding ✅\n');
    escribir('apps/solera-x/lib/servicios/generador_libro_aceite_pdf.dart',
        "final s = ' · AICA · PROVISIONAL';\n");
    escribir('apps/solera-x/test/sello_provisional_test.dart',
        "File('lib/servicios/generador_libro_aceite_pdf.dart')");
    escribir('apps/solera-x/lib/datos/catalogos_generados/flag_revision.dart',
        'const bool catalogosCompletamenteRevisados = false;');
    escribir('social/apps/concejo/BLOQUEOS-PENDIENTES.md',
        '## Piloto\n\nBuscar pueblo piloto.\n');
    escribir('content/x/razas.csv', 'id,revisado_por\na,\nb,asesor: Ane\n');

    final inventario = recolectar(raiz.path);
    expect(inventario.bloqueos, hasLength(3));
    expect(inventario.bloqueosAbiertos.map((b) => b.titulo),
        ['Libro económico', 'Piloto']);
    expect(inventario.abiertosPorResponsable.keys,
        containsAll([Responsable.asesorFiscal, Responsable.piloto]));
    expect(inventario.sellos.single.protegidoPorTest, isTrue);
    expect(inventario.sellos.single.responsables,
        contains(Responsable.auditorAica));
    expect(inventario.flags.single.revisados, isFalse);
    expect(inventario.catalogos.single.revisadasPorPersona, 1);
    expect(inventario.catalogos.single.sinRevisar, 1);
    expect(informeTerminal(inventario), contains('Asesor fiscal'));
    expect(informeHtml(inventario), contains('<title>Pendientes del monorepo'));
  });
}
