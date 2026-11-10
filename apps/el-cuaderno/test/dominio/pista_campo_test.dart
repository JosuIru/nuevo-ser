import 'package:el_cuaderno/datos_simulados/cargador_pistas_campo.dart';
import 'package:el_cuaderno/dominio/pista_campo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PistaCampo', () {
    test('constructor sin traducciones devuelve texto castellano', () {
      const pista = PistaCampo(id: 'p1', texto: 'mira las nubes');
      expect(pista.textoEnLocale('eu'), equals('mira las nubes'));
      expect(pista.textoEnLocale('ca'), equals('mira las nubes'));
      expect(pista.textoEnLocale(null), equals('mira las nubes'));
    });

    test('locale presente devuelve traducción; ausente cae a castellano', () {
      const pista = PistaCampo(
        id: 'p1',
        texto: 'mira las nubes',
        traducciones: {'eu': 'begiratu hodeiei'},
      );
      expect(pista.textoEnLocale('eu'), equals('begiratu hodeiei'));
      expect(pista.textoEnLocale('ca'), equals('mira las nubes'));
    });

    test('JSON round-trip preserva campos', () {
      const original = PistaCampo(
        id: 'p1',
        texto: 'mira',
        traducciones: {'eu': 'begi', 'ca': 'mira-ca'},
      );
      final decodificado = PistaCampo.fromJson(original.toJson());
      expect(decodificado, equals(original));
    });

    test('fromJson sin id lanza FormatException', () {
      expect(
        () => PistaCampo.fromJson({'texto': 'algo'}),
        throwsFormatException,
      );
    });

    test('fromJson sin texto lanza FormatException', () {
      expect(
        () => PistaCampo.fromJson({'id': 'p1'}),
        throwsFormatException,
      );
    });

    test('toJson omite traducciones cuando vacías (compat)', () {
      const pista = PistaCampo(id: 'p1', texto: 'mira');
      expect(pista.toJson().containsKey('traducciones'), isFalse);
    });
  });

  group('parsePistasCampoDesdeJson', () {
    test('parsea catálogo bien formado', () {
      const jsonValido = '''
      {
        "version": "0.1",
        "pistas": [
          {"id": "p1", "texto": "mira las nubes"},
          {"id": "p2", "texto": "escucha un minuto", "traducciones": {"eu": "entzun"}}
        ]
      }
      ''';
      final lista = parsePistasCampoDesdeJson(jsonValido);
      expect(lista, hasLength(2));
      expect(lista[0].id, equals('p1'));
      expect(lista[1].traducciones['eu'], equals('entzun'));
    });

    test('JSON sin clave "pistas" lanza FormatException', () {
      expect(
        () => parsePistasCampoDesdeJson('{"version": "0.1"}'),
        throwsFormatException,
      );
    });

    test('JSON que no es objeto raíz lanza FormatException', () {
      expect(
        () => parsePistasCampoDesdeJson('[]'),
        throwsFormatException,
      );
    });
  });
}
