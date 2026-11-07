import 'dart:io';

import 'package:auditoria/auditoria.dart';
import 'package:pendientes/pendientes.dart';
import 'package:test/test.dart';

void main() {
  late Directory raiz;

  setUp(() {
    raiz = Directory.systemTemp.createTempSync('auditoria_');
    void escribir(String ruta, String texto) =>
        (File('${raiz.path}/$ruta')..parent.createSync(recursive: true))
            .writeAsStringSync(texto);
    escribir('apps/solera-aceitera/BLOQUEOS-PENDIENTES.md', '''
# Aceitera

## Libro de movimientos del aceite

- [ ] Validar con auditor AICA el formato RD 760/2021.

## Libro económico REAGP

- [ ] Asesor fiscal.

## Branding ✅
''');
    escribir('apps/solera-aceitera/lib/servicios/generador_libro_aceite_pdf.dart',
        "final s = ' · RD 760/2021 + AICA · PROVISIONAL';\n");
    escribir('content/aceitera/variedades_olivo.csv',
        'id,nombre,revisado_por\npicual,Picual,fuente_publica\nhojiblanca,Hojiblanca,asesor: Ana\n');
    escribir('content/apicola/razas.csv', 'id,revisado_por\na,\n');
  });

  tearDown(() => raiz.deleteSync(recursive: true));

  test('verticalPorNombre resuelve app y carpeta de content', () {
    final vertical = verticalPorNombre('aceitera');
    expect(vertical.aplicacion, 'solera-aceitera');
    expect(vertical.carpetaContenido, 'aceitera');
    expect(verticalPorNombre('solera-aceitera').aplicacion, 'solera-aceitera');
    expect(() => verticalPorNombre('inventada'), throwsArgumentError);
  });

  test('la lista agrupa por responsable y añade los catálogos al experto', () {
    final inventario = recolectar(raiz.path);
    final lista =
        construirListaComprobacion(inventario, verticalPorNombre('aceitera'));
    final responsables =
        lista.secciones.map((seccion) => seccion.responsable).toList();
    expect(responsables, containsAll([
      Responsable.auditorAica,
      Responsable.asesorFiscal,
      Responsable.asesorAgronomo,
    ]));
    final agronomo = lista.secciones
        .firstWhere((s) => s.responsable == Responsable.asesorAgronomo);
    expect(agronomo.catalogos.single.nombreArchivo, 'variedades_olivo.csv');
    expect(agronomo.catalogos.single.revisadasPorPersona, 1);
    final aica = lista.secciones
        .firstWhere((s) => s.responsable == Responsable.auditorAica);
    expect(aica.bloqueos.single.titulo, 'Libro de movimientos del aceite');
    expect(aica.sellos.single.ruta, endsWith('generador_libro_aceite_pdf.dart'));
    // Lo resuelto no entra.
    expect(lista.secciones.expand((s) => s.bloqueos).map((b) => b.titulo),
        isNot(contains('Branding ✅')));
  });

  test('filtrar por responsable deja solo esa sección', () {
    final lista = construirListaComprobacion(
        recolectar(raiz.path), verticalPorNombre('aceitera'),
        soloResponsable: Responsable.asesorFiscal);
    expect(lista.secciones.map((s) => s.responsable),
        [Responsable.asesorFiscal]);
  });

  test('comprobarRetiradaDeSellos enumera lo que falta', () {
    final faltas = comprobarRetiradaDeSellos(
        recolectar(raiz.path), verticalPorNombre('aceitera'));
    expect(faltas.join('\n'), contains('variedades_olivo.csv'));
    expect(faltas.join('\n'), contains('Libro de movimientos del aceite'));
  });

  test('genera un PDF no vacío', () async {
    final lista = construirListaComprobacion(
        recolectar(raiz.path), verticalPorNombre('aceitera'));
    final bytes = await generarPdfListaComprobacion(lista,
        directorioFuentes: '${_raizMonorepo()}/packages/nuevo_ser_core/assets/fuentes');
    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}

String _raizMonorepo() =>
    Directory.current.uri.resolve('../..').toFilePath().replaceAll(RegExp(r'/$'), '');
