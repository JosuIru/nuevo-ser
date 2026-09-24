import 'package:flutter_test/flutter_test.dart';
import 'package:las_versiones/dominio/capa_historica.dart';
import 'package:las_versiones/dominio/catalogo_brechas.dart';
import 'package:las_versiones/nucleo/pigmentos.dart';

void main() {
  test('toda Brecha del catálogo tiene capa principal', () {
    for (final brecha in CatalogoBrechas.todas) {
      expect(capaPrincipalDeBrecha[brecha.id], isNotNull,
          reason: 'la Brecha ${brecha.id} no tiene capa');
    }
  });

  test('cada capa tiene al menos dos acentos', () {
    for (final capa in CapaHistorica.values) {
      expect(PaletaDeCapa.de(capa).acentos.length, greaterThanOrEqualTo(2));
    }
  });
}
