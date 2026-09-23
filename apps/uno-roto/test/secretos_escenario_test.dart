import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/catalogo_distritos.dart';
import 'package:uno_roto/dominio/cuaderno.dart';
import 'package:uno_roto/dominio/secretos_escenario.dart';

/// Tests de los secretos espaciales (doc 16, eje E): coherencia del
/// catálogo y payoff garantizado en el Cuaderno.
void main() {
  test('ids únicos, distritos existentes y posiciones dentro del lienzo', () {
    final ids = CatalogoSecretos.todos.map((s) => s.id).toSet();
    expect(ids.length, CatalogoSecretos.todos.length);
    final distritos =
        CatalogoDistritos.todos.map((d) => d.identificador).toSet();
    for (final secreto in CatalogoSecretos.todos) {
      expect(distritos.contains(secreto.idDistrito), isTrue,
          reason: '${secreto.id} apunta a un distrito inexistente');
      expect(secreto.xEscena, inInclusiveRange(0.05, 0.95));
      expect(secreto.yEscena, inInclusiveRange(0.05, 0.95));
    }
  });

  test('cada secreto tiene su entrada del Cuaderno', () {
    final flagsDeEntradas =
        CatalogoCuaderno.todas.map((e) => e.flagDesbloqueo).toSet();
    for (final secreto in CatalogoSecretos.todos) {
      expect(flagsDeEntradas.contains(secreto.flagDescubierto), isTrue,
          reason: '${secreto.id} no desbloquea ninguna entrada — el '
              'hallazgo se quedaría sin registro (doc 16 §2)');
    }
  });

  test('delDistrito filtra bien', () {
    expect(
      CatalogoSecretos.delDistrito('tejados').map((s) => s.id),
      contains('ventana_gato'),
    );
    expect(CatalogoSecretos.delDistrito('mercado'), isEmpty);
  });
}
