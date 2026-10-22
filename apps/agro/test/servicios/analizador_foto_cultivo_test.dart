import 'package:flutter_test/flutter_test.dart';
import 'package:agro/servicios/cliente_anthropic.dart';

void main() {
  test('el JSON de Claude se lee y se cruza con el catálogo de plagas', () {
    final resultado = resultadoDesdeJson({
      'nombre_comun': 'Mosca del olivo',
      'nombre_cientifico': 'Bactrocera oleae',
      'tipo': 'plaga',
      'severidad': 3,
      'confianza': 1.4,
      'manejo_cultural': 'Trampeo masivo.',
      'advertencia': '',
    });
    expect(resultado.tipo, 'plaga');
    expect(resultado.severidad, 3);
    expect(resultado.confianza, 1.0);
    expect(resultado.coincidenciaCatalogo, isNotNull);
  });

  test('un diagnóstico sin datos queda como indeterminado y sin catálogo', () {
    final resultado = resultadoDesdeJson({});
    expect(resultado.tipo, 'indeterminado');
    expect(resultado.confianza, 0);
    expect(resultado.coincidenciaCatalogo, isNull);
  });

  test('solo se envían ficheros con extensión de imagen', () {
    expect(esExtensionDeImagen('/fotos/hoja.JPG'), isTrue);
    expect(esExtensionDeImagen('/fotos/hoja.webp'), isTrue);
    expect(esExtensionDeImagen('/docs/informe.pdf'), isFalse);
  });

  test('la clave de Anthropic se sigue leyendo de la preferencia de siempre', () {
    expect(estadoClaveAnthropicAgro.claveAlmacenamiento, 'agro.anthropic.clave');
  });
}
