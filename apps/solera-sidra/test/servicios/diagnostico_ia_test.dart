import 'package:flutter_test/flutter_test.dart';
import 'package:solera_sidra/datos/catalogos_generados/catalogo_plagas_manzano.dart';
import 'package:solera_sidra/dominio/catalogos.dart';
import 'package:solera_sidra/pantallas/boton_diagnostico_ia.dart';
import 'package:solera_sidra/servicios/diagnostico_plagas_ia.dart';

void main() {
  test('interpreta la respuesta y se queda con lo que está en el catálogo', () {
    final diagnostico = interpretarDiagnosticoPlaga({
      'plaga_id': 'moteado',
      'confianza': 'media',
      'otras_posibles': ['moteado', 'monilia', 'inventada', 3],
      'sintomas_observados': ' Manchas pardas con costra ',
      'foto_valida': true,
      'observaciones': '',
    });
    expect(diagnostico.plagaId, 'moteado');
    expect(diagnostico.plaga!.nombreCientifico, 'Venturia inaequalis');
    expect(diagnostico.otrasPosibles, ['monilia']);
    expect(diagnostico.sintomasObservados, 'Manchas pardas con costra');
    expect(diagnostico.esPlagaDelCatalogo, isTrue);
    // La plaga propuesta tiene sustancias con uso autorizado en el catálogo.
    expect(sustanciasParaPlaga(diagnostico.plagaId), isNotEmpty);
  });

  test('una respuesta rara no rompe: no identificada y confianza baja', () {
    final diagnostico = interpretarDiagnosticoPlaga({'plaga_id': 'mildiu'});
    expect(diagnostico.plagaId, plagaNoIdentificada);
    expect(diagnostico.confianza, 'baja');
    expect(diagnostico.fotoValida, isFalse);
    expect(diagnostico.esPlagaDelCatalogo, isFalse);
    final sana = interpretarDiagnosticoPlaga(
        {'plaga_id': sinPlagaVisible, 'foto_valida': true});
    expect(sana.plaga, isNull);
    expect(sana.esPlagaDelCatalogo, isFalse);
  });

  test('el esquema solo admite plagas del catálogo', () {
    final propiedades = esquemaDiagnosticoPlaga()['properties'] as Map;
    final permitidas = (propiedades['plaga_id'] as Map)['enum'] as List;
    expect(permitidas,
        containsAll(catalogoPlagasManzano.map((plaga) => plaga.id).toList()));
    expect(permitidas, hasLength(catalogoPlagasManzano.length + 2));
  });

  test('el texto avisa del organismo regulado y no habla de productos', () {
    final texto = textoDiagnostico(interpretarDiagnosticoPlaga({
      'plaga_id': 'fuego_bacteriano',
      'confianza': 'alta',
      'otras_posibles': [],
      'sintomas_observados': 'Brotes negros en cayado',
      'foto_valida': true,
      'observaciones': '',
    }));
    expect(texto, contains('Erwinia amylovora'));
    expect(texto, contains('sanidad vegetal'));
    expect(texto.toLowerCase(), isNot(contains('dosis')));
  });
}
