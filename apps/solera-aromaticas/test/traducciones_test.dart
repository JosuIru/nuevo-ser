// Los valores cerrados se traducen con claves dinámicas `arom.<grupo>_<id>`
// (utiles/textos_aromaticas.dart), que el test de i18n del core no ve: este
// comprueba que existen todas, en los cuatro idiomas.

import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_aromaticas/modelos/cosecha.dart';
import 'package:solera_aromaticas/modelos/destilacion.dart';
import 'package:solera_aromaticas/modelos/lote_producto.dart';
import 'package:solera_aromaticas/modelos/secado.dart';
import 'package:solera_aromaticas/modelos/tratamiento.dart';
import 'package:solera_aromaticas/modelos/zona_recoleccion.dart';

/// Grupos de valores cerrados y su prefijo de clave.
final Map<String, List<String>> gruposDeValores = {
  'terreno': tiposTerrenoRecoleccion,
  'feno': estadosFenologicosCosecha,
  'secado': metodosSecado,
  'alambique': tiposAlambique,
  'planta': estadosPlantaDestilacion,
  'lote': unidadPorTipoLote.keys.toList(),
  'destino': destinosLote,
  'eficacia': eficaciasTratamiento,
};

void main() {
  test('cada valor cerrado tiene su texto en los cuatro idiomas', () {
    final faltan = <String>[];
    for (final MapEntry(key: grupo, value: valores)
        in gruposDeValores.entries) {
      for (final valor in valores) {
        final clave = 'arom.${grupo}_$valor';
        if (!SoleraL10n.clavesDisponibles.contains(clave)) faltan.add(clave);
        for (final idioma in ['eu', 'ca', 'gl']) {
          if (!SoleraL10n.clavesTraducidas(idioma).contains(clave)) {
            faltan.add('$clave ($idioma)');
          }
        }
      }
    }
    expect(faltan, isEmpty);
  });
}
