import 'package:flutter_test/flutter_test.dart';
import 'package:solera_sidra/datos/catalogos_generados/catalogo_dop_sidra_txakoli.dart';
import 'package:solera_sidra/datos/catalogos_generados/catalogo_fitosanitarios_manzano.dart';
import 'package:solera_sidra/datos/catalogos_generados/catalogo_plagas_manzano.dart';
import 'package:solera_sidra/datos/catalogos_generados/catalogo_variedades_manzana.dart';
import 'package:solera_sidra/datos/catalogos_generados/catalogo_variedades_uva.dart';
import 'package:solera_sidra/datos/catalogos_generados/flag_revision.dart';
import 'package:solera_sidra/dominio/catalogos.dart';
import 'package:solera_sidra/dominio/comprobacion_dop.dart';
import 'package:solera_sidra/modelos/kupela.dart';
import 'package:solera_sidra/modelos/prensado.dart';

void main() {
  test('el pliego de Euskal Sagardoa da 54 + 138 variedades distintas', () {
    final vascas =
        catalogoVariedadesManzana.where((v) => v.dop == 'euskal_sagardoa');
    expect(vascas.where((v) => v.grupo == 'principal'), hasLength(54));
    // 139 en el pliego, «Txori Sagarra» repetida.
    expect(vascas.where((v) => v.grupo == 'resto'), hasLength(138));
    expect(nombreVariedad('errezila'), 'Errezila');
    expect(nombreVariedad('hondarrabi_zuri'), 'Hondarrabi Zuri');
  });

  test('integridad: las sustancias apuntan a plagas que existen', () {
    final plagas = catalogoPlagasManzano.map((plaga) => plaga.id).toSet();
    for (final sustancia in catalogoFitosanitariosManzano) {
      expect(sustancia.plagasObjetivo, isNotEmpty, reason: sustancia.id);
      expect(plagas.containsAll(sustancia.plagasObjetivo), isTrue,
          reason: sustancia.id);
      expect(
          {'fungicida', 'bactericida', 'insecticida', 'acaricida'}
              .containsAll(sustancia.tiposAccion),
          isTrue,
          reason: sustancia.id);
    }
  });

  test('ninguna sustancia retirada ni con PS de 0 días', () {
    final ids = catalogoFitosanitariosManzano.map((s) => s.id).toSet();
    for (final retirada in [
      'mancozeb',
      'spirotetramat',
      'clorpirifos',
      'metoxifenocida',
      'esfenvalerato',
    ]) {
      expect(ids, isNot(contains(retirada)));
    }
    for (final sustancia in catalogoFitosanitariosManzano) {
      expect(sustancia.plazoSeguridadMaxDias, isNot(0), reason: sustancia.id);
    }
    expect(sustanciaPorId('captan')!.plazoSeguridadMaxDias, 28);
  });

  test('las plagas de la IA tienen al menos una sustancia o se dice', () {
    for (final plaga in ['moteado', 'carpocapsa', 'pulgon_ceniciento']) {
      expect(sustanciasParaPlaga(plaga), isNotEmpty, reason: plaga);
    }
    expect(plagaPorId('fuego_bacteriano')!.organismoRegulado, isTrue);
    expect(sustanciasParaPlaga(''),
        hasLength(catalogoFitosanitariosManzano.length));
  });

  test('cada producto DOP tiene denominación conocida y fuente', () {
    for (final producto in catalogoProductosDop) {
      expect(denominacionesOrigen, contains(producto.dop), reason: producto.id);
      expect(producto.fuente, startsWith('fuente_publica:'));
    }
    for (final dop in denominacionesOrigen) {
      expect(productosDeDenominacion(dop), isNotEmpty, reason: dop);
    }
  });

  test('variedades fuera del pliego', () {
    expect(
        variedadesFueraDelPliego(
            {'errezila', 'ast_blanquina'}, 'euskal_sagardoa'),
        {'ast_blanquina'});
    expect(variedadesFueraDelPliego({'mune_mahatsa'}, 'bizkaiko_txakolina'),
        isEmpty);
    expect(variedadesFueraDelPliego({'mune_mahatsa'}, 'getariako_txakolina'),
        {'mune_mahatsa'});
    expect(variedadesFueraDelPliego({'cualquiera'}, ''), isEmpty);
    expect(catalogoVariedadesUva, isNotEmpty);
  });

  test('avisos DOP: acidez volátil, densidad del mosto y rendimiento', () {
    final vasca = productoDopPorId('euskal_sagardoa')!;
    expect(
        avisosMedicion(
            MedicionKupela(
                kupelaId: 1,
                fechaMs: 1,
                acidezVolatilGL: 2.3,
                gradoAlcoholico: 6),
            vasca),
        [const AvisoDop('acidez_volatil_alta', 2.3, 2.2)]);
    expect(
        avisosMedicion(
            MedicionKupela(kupelaId: 1, fechaMs: 1, acidezVolatilGL: 1), vasca),
        isEmpty);
    expect(
        avisosPrensado(
            Prensado(
                fechaMs: 1,
                kupelaId: 1,
                kilosFruta: 1000,
                litrosMosto: 800,
                densidadMosto: 1040),
            vasca),
        [
          const AvisoDop('densidad_mosto_baja', 1040, 1045),
          const AvisoDop('rendimiento_alto', 80, 75),
        ]);
    expect(
        avisosPrensado(
            Prensado(
                fechaMs: 1, kupelaId: 1, kilosFruta: 1000, litrosMosto: 600),
            vasca),
        isEmpty);
  });

  test('sin firma de persona, el banner de provisionales sigue activo', () {
    expect(catalogosCompletamenteRevisados, isFalse);
  });
}
