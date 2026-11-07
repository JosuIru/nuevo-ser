import 'package:auditoria/auditoria.dart';
import 'package:test/test.dart';

const String _catalogo = '''
# Variedades — datos PROVISIONALES.
id,nombre,notas,revisado_por
picual,Picual,"dulce, amarga",fuente_publica
arbequina,Arbequina,,
cornicabra,Cornicabra,"di ""sí""",MAPA 2026
''';

void main() {
  group('firmarCatalogo', () {
    test('firma todas las filas y conserva la cita previa', () {
      final resultado = firmarCatalogo(_catalogo,
          firma: 'Ana Pérez (agrónoma, 2026-11-20)');
      expect(resultado.filasFirmadas, 3);
      final lineas = resultado.texto.split('\n');
      expect(lineas[0], '# Variedades — datos PROVISIONALES.');
      expect(lineas[1], 'id,nombre,notas,revisado_por');
      expect(lineas[2],
          'picual,Picual,"dulce, amarga","asesor: Ana Pérez (agrónoma, 2026-11-20); fuente: fuente_publica"');
      expect(lineas[3],
          'arbequina,Arbequina,,"asesor: Ana Pérez (agrónoma, 2026-11-20)"');
      expect(lineas[4],
          'cornicabra,Cornicabra,"di ""sí""","asesor: Ana Pérez (agrónoma, 2026-11-20); fuente: MAPA 2026"');
      expect(resultado.texto.endsWith('\n'), isTrue);
    });

    test('solo las filas pedidas por id; el resto queda byte a byte igual', () {
      final resultado = firmarCatalogo(_catalogo,
          firma: 'Ana', identificadores: {'arbequina'});
      expect(resultado.filasFirmadas, 1);
      expect(resultado.identificadoresNoEncontrados, isEmpty);
      final original = _catalogo.split('\n');
      final nuevo = resultado.texto.split('\n');
      expect(nuevo[2], original[2]);
      expect(nuevo[3], 'arbequina,Arbequina,,asesor: Ana');
      expect(nuevo[4], original[4]);
    });

    test('avisa de ids que no existen', () {
      final resultado = firmarCatalogo(_catalogo,
          firma: 'Ana', identificadores: {'picual', 'inventada'});
      expect(resultado.identificadoresNoEncontrados, {'inventada'});
    });

    test('no vuelve a firmar una fila ya firmada por persona', () {
      final firmado = firmarCatalogo(_catalogo, firma: 'Ana').texto;
      final otra = firmarCatalogo(firmado, firma: 'Bea');
      expect(otra.filasFirmadas, 0);
      expect(otra.texto, firmado);
    });

    test('firma como persona: o anota una revisión de IA', () {
      final comoPersona = firmarCatalogo(_catalogo,
          firma: 'Josu (titular)', prefijo: 'persona:', identificadores: {'arbequina'});
      expect(comoPersona.texto.split('\n')[3],
          'arbequina,Arbequina,,persona: Josu (titular)');

      final revisado = firmarCatalogo(_catalogo,
          firma: 'Claude, 2026-11-07', prefijo: 'revision-ia:',
          identificadores: {'picual'});
      expect(revisado.texto.split('\n')[2],
          'picual,Picual,"dulce, amarga","revision-ia: Claude, 2026-11-07; fuente: fuente_publica"');

      // Una revisión de IA no se repite, pero la firma humana va encima.
      expect(firmarCatalogo(revisado.texto,
              firma: 'otra', prefijo: 'revision-ia:', identificadores: {'picual'})
          .filasFirmadas, 0);
      final firmado = firmarCatalogo(revisado.texto,
          firma: 'Ana', identificadores: {'picual'});
      expect(firmado.texto.split('\n')[2],
          'picual,Picual,"dulce, amarga","asesor: Ana; fuente: revision-ia: Claude, 2026-11-07; fuente: fuente_publica"');
    });

    test('rechaza un prefijo desconocido', () {
      expect(() => firmarCatalogo(_catalogo, firma: 'Ana', prefijo: 'yo:'),
          throwsA(isA<ArgumentError>()));
    });

    test('falla si no hay columna revisado_por', () {
      expect(() => firmarCatalogo('id,nombre\na,b\n', firma: 'Ana'),
          throwsA(isA<FormatException>()));
    });

    test('rechaza una firma vacía', () {
      expect(() => firmarCatalogo(_catalogo, firma: '  '),
          throwsA(isA<ArgumentError>()));
    });
  });

  test('quitarMarcasMarkdown deja texto plano', () {
    expect(quitarMarcasMarkdown('**Estado**: `flag` listo\n- [ ] Validar\n  * sub'),
        'Estado: flag listo\n– Validar\n  – sub');
  });

  test('escribirCampoCsv solo pone comillas cuando hace falta', () {
    expect(escribirCampoCsv('simple'), 'simple');
    expect(escribirCampoCsv('a, b'), '"a, b"');
    expect(escribirCampoCsv('di "x"'), '"di ""x"""');
    expect(escribirCampoCsv(''), '');
  });
}
