import 'package:flutter_test/flutter_test.dart';
import 'package:solera_obrador/modelos/alergenos.dart';
import 'package:solera_obrador/servicios/lector_etiquetas_ia.dart';

void main() {
  test('interpreta la respuesta y descarta lo que no es uno de los 14', () {
    final lectura = interpretarLecturaEtiqueta({
      'nombre_producto': ' Harina de espelta ',
      'ingredientes': ['harina de espelta', '', 3],
      'alergenos': ['gluten', 'inventado'],
      'trazas': ['gluten', 'sesamo'],
      'legible': true,
      'observaciones': '',
    });
    expect(lectura.nombreProducto, 'Harina de espelta');
    expect(lectura.ingredientes, ['harina de espelta']);
    expect(lectura.alergenos, {'gluten'});
    expect(lectura.trazas, {'sesamo'}); // lo declarado no se repite como traza
    expect(lectura.legible, isTrue);
  });

  test('una respuesta incompleta no rompe y cuenta como no legible', () {
    final lectura = interpretarLecturaEtiqueta({});
    expect(lectura.legible, isFalse);
    expect(lectura.alergenos, isEmpty);
  });

  test('el esquema solo admite los 14 alérgenos', () {
    final propiedades = esquemaLecturaEtiqueta['properties'] as Map;
    expect((propiedades['alergenos'] as Map)['items']['enum'],
        alergenosObligatorios);
  });
}
