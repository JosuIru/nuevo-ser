import 'package:pendientes/pendientes.dart';
import 'package:test/test.dart';

void main() {
  group('leerFilasCsv', () {
    test('respeta comillas, comas y comillas dobles escapadas', () {
      final filas = leerFilasCsv('a,b,c\n1,"dos, tres","di ""hola"""\n');
      expect(filas, [
        ['a', 'b', 'c'],
        ['1', 'dos, tres', 'di "hola"'],
      ]);
    });

    test('admite saltos de línea dentro de comillas y CRLF', () {
      final filas = leerFilasCsv('a,b\r\n"x\ny",z\r\n');
      expect(filas, [
        ['a', 'b'],
        ['x\ny', 'z'],
      ]);
    });
  });

  group('analizarCatalogo', () {
    test('cuenta filas por valor de revisado_por e ignora comentarios', () {
      const texto = '''
# Variedades — datos PROVISIONALES.
# Columnas: ...
id,nombre,revisado_por
picual,Picual,fuente_publica
arbequina,Arbequina,
cornicabra,Cornicabra,asesor: Ana Pérez (agrónoma)
hojiblanca,Hojiblanca,MAPA Registro de Variedades 2026
''';
      final catalogo =
          analizarCatalogo(texto, ruta: 'content/aceitera/variedades.csv');
      expect(catalogo.filas, 4);
      expect(catalogo.sinRevisar, 1);
      expect(catalogo.revisadasPorFuentePublica, 2);
      expect(catalogo.revisadasPorPersona, 1);
      expect(catalogo.cabeceraProvisional, isTrue);
      expect(catalogo.tieneColumnaRevision, isTrue);
      expect(catalogo.vertical, 'aceitera');
    });

    test('sin columna revisado_por', () {
      final catalogo = analizarCatalogo('clave,es,eu\nhola,hola,kaixo\n',
          ruta: 'content/solera/traducciones.csv');
      expect(catalogo.tieneColumnaRevision, isFalse);
      expect(catalogo.cabeceraProvisional, isFalse);
      expect(catalogo.filas, 1);
    });
  });

  test('leerFlagRevision lee el booleano generado', () {
    expect(
        leerFlagRevision(
            '// GENERADO\nconst bool catalogosCompletamenteRevisados = false;\n'),
        isFalse);
    expect(
        leerFlagRevision('const bool catalogosCompletamenteRevisados = true;'),
        isTrue);
    expect(leerFlagRevision('nada'), isNull);
  });
}
