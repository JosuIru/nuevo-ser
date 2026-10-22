// Tests del cliente Anthropic — solo lógica pura (parsing JSON +
// matching contra catálogo + tipo de medio de la foto). El método
// que hace HTTP no se ejerce aquí; en F2 entrará un test de
// integración con clave de pruebas o un mock-server.

import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:solera_aceitera/servicios/cliente_anthropic.dart';

void main() {
  group('parsearDiagnosticoPlaga', () {
    test('Parsea respuesta JSON canónica de la IA', () {
      const respuesta = '''
{
  "nombre_comun": "Mosca del olivo",
  "nombre_cientifico": "Bactrocera oleae",
  "tipo": "plaga",
  "severidad": 3,
  "confianza": 0.85,
  "manejo_cultural": "Monitoreo con mosqueros amarillos y adelantar recolección.",
  "advertencia": ""
}
''';
      final r = parsearDiagnosticoPlaga(respuesta);
      expect(r.nombreComun, equals('Mosca del olivo'));
      expect(r.nombreCientifico, equals('Bactrocera oleae'));
      expect(r.tipo, equals('plaga'));
      expect(r.severidad, equals(3));
      expect(r.confianza, closeTo(0.85, 0.001));
      expect(r.manejoCultural, contains('mosqueros'));
      expect(r.advertencia, isEmpty);
    });

    test('Tolera bloque ```json ... ``` aunque el prompt lo prohíba', () {
      const respuesta = '''
```json
{
  "nombre_comun": "Repilo",
  "nombre_cientifico": "Spilocaea oleaginea",
  "tipo": "enfermedad",
  "severidad": null,
  "confianza": 0.7,
  "manejo_cultural": "Aclareo de copa y cosecha higiénica.",
  "advertencia": "Síntoma parcialmente cubierto por sombra."
}
```
''';
      final r = parsearDiagnosticoPlaga(respuesta);
      expect(r.nombreComun, equals('Repilo'));
      expect(r.severidad, isNull);
      expect(r.advertencia, contains('sombra'));
    });

    test('Lanza ErrorClaude si no hay JSON', () {
      expect(
        () => parsearDiagnosticoPlaga('no es json'),
        throwsA(isA<ErrorClaude>().having((e) => e.motivo, 'motivo', MotivoErrorClaude.respuestaRara)),
      );
    });

    test('Clampa confianza fuera de rango', () {
      const respuesta = '{"nombre_comun": "x", "nombre_cientifico": "", '
          '"tipo": "indeterminado", "severidad": null, "confianza": 2.5, '
          '"manejo_cultural": "", "advertencia": ""}';
      final r = parsearDiagnosticoPlaga(respuesta);
      expect(r.confianza, equals(1.0));
    });

    test('Defaults seguros si faltan campos', () {
      const respuesta = '{}';
      final r = parsearDiagnosticoPlaga(respuesta);
      expect(r.nombreComun, equals('Sin diagnóstico'));
      expect(r.tipo, equals('indeterminado'));
      expect(r.confianza, equals(0.0));
    });
  });

  group('parsearIdentificacionVariedad', () {
    test('Parsea respuesta de variedad canónica', () {
      const respuesta = '{"nombre_canonico": "Picual", "confianza": 0.65, '
          '"advertencia": "Variedades picuales similares"}';
      final r = parsearIdentificacionVariedad(respuesta);
      expect(r.nombreCanonico, equals('Picual'));
      expect(r.confianza, closeTo(0.65, 0.001));
      expect(r.advertencia, contains('Variedades'));
    });
  });

  group('matchearPlagaConCatalogo', () {
    test('Encuentra mosca del olivo por nombre científico', () {
      final id = matchearPlagaConCatalogo(
        nombreComun: 'Mosca del olivo',
        nombreCientifico: 'Bactrocera oleae',
      );
      expect(id, equals('mosca_olivo'));
    });

    test('Encuentra repilo por nombre común', () {
      final id = matchearPlagaConCatalogo(
        nombreComun: 'Repilo',
        nombreCientifico: '',
      );
      expect(id, equals('repilo'));
    });

    test('Encuentra Xylella aunque venga con texto extra', () {
      final id = matchearPlagaConCatalogo(
        nombreComun: 'Decaimiento rápido por Xylella',
        nombreCientifico: 'Xylella fastidiosa',
      );
      expect(id, equals('xylella'));
    });

    test('Devuelve cadena vacía si no hay coincidencia', () {
      final id = matchearPlagaConCatalogo(
        nombreComun: 'Patología inexistente xyz',
        nombreCientifico: 'Nada conocido',
      );
      expect(id, isEmpty);
    });

    test('Devuelve cadena vacía con entradas vacías', () {
      final id = matchearPlagaConCatalogo(
        nombreComun: '',
        nombreCientifico: '',
      );
      expect(id, isEmpty);
    });
  });

  group('matchearVariedadConCatalogo', () {
    test('Encuentra picual ignorando mayúsculas', () {
      expect(matchearVariedadConCatalogo('PICUAL'), equals('picual'));
    });

    test('Encuentra hojiblanca por sinonimia "lucentina"', () {
      expect(matchearVariedadConCatalogo('lucentina'), equals('hojiblanca'));
    });

    test('Devuelve cadena vacía si no coincide', () {
      expect(matchearVariedadConCatalogo('variedad inexistente'), isEmpty);
    });
  });

  group('tipo de medio de la foto (core)', () {
    test('Reconoce las extensiones canónicas', () {
      expect(ImagenClaude.tipoMediaPorExtension('foto.jpg'), equals('image/jpeg'));
      expect(ImagenClaude.tipoMediaPorExtension('foto.jpeg'), equals('image/jpeg'));
      expect(ImagenClaude.tipoMediaPorExtension('foto.png'), equals('image/png'));
      expect(ImagenClaude.tipoMediaPorExtension('foto.gif'), equals('image/gif'));
      expect(ImagenClaude.tipoMediaPorExtension('foto.webp'), equals('image/webp'));
    });

    test('Cae a jpeg si la extensión es desconocida', () {
      expect(ImagenClaude.tipoMediaPorExtension('foto.heic'), equals('image/jpeg'));
      expect(ImagenClaude.tipoMediaPorExtension('foto'), equals('image/jpeg'));
    });
  });

  group('flags derivados', () {
    test('esDeclaracionObligatoria=true para Xylella; false para mosca', () {
      final xylella = ResultadoDiagnosticoPlaga(
        nombreComun: 'Xylella',
        nombreCientifico: 'Xylella fastidiosa',
        tipo: 'enfermedad',
        confianza: 0.9,
        manejoCultural: '...',
        idCatalogo: 'xylella',
      );
      final mosca = ResultadoDiagnosticoPlaga(
        nombreComun: 'Mosca del olivo',
        nombreCientifico: 'Bactrocera oleae',
        tipo: 'plaga',
        confianza: 0.9,
        manejoCultural: '...',
        idCatalogo: 'mosca_olivo',
      );
      expect(xylella.esDeclaracionObligatoria, isTrue);
      expect(mosca.esDeclaracionObligatoria, isFalse);
    });

    test('validadoPorCatalogo refleja idCatalogo no vacío', () {
      final con = ResultadoDiagnosticoPlaga(
        nombreComun: 'x',
        nombreCientifico: '',
        tipo: 'plaga',
        confianza: 0.5,
        manejoCultural: '',
        idCatalogo: 'mosca_olivo',
      );
      final sin = ResultadoDiagnosticoPlaga(
        nombreComun: 'x',
        nombreCientifico: '',
        tipo: 'plaga',
        confianza: 0.5,
        manejoCultural: '',
      );
      expect(con.validadoPorCatalogo, isTrue);
      expect(sin.validadoPorCatalogo, isFalse);
    });
  });
}
