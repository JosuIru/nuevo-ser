import 'package:flutter_test/flutter_test.dart';
import 'package:solera_ganadera/pantallas/lectura_receta.dart';
import 'package:solera_ganadera/servicios/lector_receta_ia.dart';

void main() {
  test('interpreta la receta y casa la sustancia con el catálogo', () {
    final lectura = interpretarLecturaReceta({
      'medicamento': ' Nombre comercial 10 mg/ml ',
      'sustancias_activas': ['IVERMECTINA', '', 7],
      'cantidad': '1 ml / 50 kg',
      'duracion_dias': 1,
      'espera_carne_dias': 42,
      'espera_leche_dias': -1,
      'veterinario': 'Miren',
      'numero_receta': 'R-2026-15',
      'fecha': '2026-11-03',
      'legible': true,
      'observaciones': '',
    });
    expect(lectura.medicamento, 'Nombre comercial 10 mg/ml');
    expect(lectura.sustanciasLeidas, ['IVERMECTINA']);
    expect(lectura.sustanciaCatalogo?.id, 'ivermectina');
    expect(lectura.sustanciaPropuesta, 'Ivermectina');
    expect(lectura.esperaCarneDias, 42);
    expect(lectura.esperaLecheDias, isNull, reason: '-1 = no aparece');
    expect(lectura.fecha, DateTime(2026, 11, 3));
    expect(lectura.legible, isTrue);
  });

  test('una respuesta incompleta no rompe, no inventa plazos y no es legible',
      () {
    final lectura = interpretarLecturaReceta({});
    expect(lectura.legible, isFalse);
    expect(lectura.esperaCarneDias, isNull);
    expect(lectura.esperaLecheDias, isNull);
    expect(lectura.sustanciaCatalogo, isNull);
    expect(lectura.fecha, isNull);
  });

  test('una sustancia fuera del catálogo se conserva tal cual', () {
    final lectura = interpretarLecturaReceta({
      'sustancias_activas': ['Sustancia rara', 'Otra'],
      'espera_carne_dias': '7',
    });
    expect(lectura.sustanciaCatalogo, isNull);
    expect(lectura.sustanciaPropuesta, 'Sustancia rara + Otra');
    expect(lectura.esperaCarneDias, 7);
    expect(textoLectura(lectura), contains('Sustancia rara'));
  });

  test('el esquema pide todo y no admite campos de más', () {
    expect(esquemaLecturaReceta['additionalProperties'], isFalse);
    expect((esquemaLecturaReceta['required'] as List).toSet(),
        (esquemaLecturaReceta['properties'] as Map).keys.toSet());
  });
}
