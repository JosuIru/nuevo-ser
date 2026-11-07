// Los valores cerrados se traducen con claves dinámicas `mont.<grupo>_<id>`
// (utiles/textos_monte.dart), que el test de i18n del core no ve: este
// comprueba que existen todas, en los cuatro idiomas.

import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_monte/modelos/actuacion_plan.dart';
import 'package:solera_monte/modelos/apunte_economico.dart';
import 'package:solera_monte/modelos/configuracion_fiscal.dart';
import 'package:solera_monte/modelos/aprovechamiento.dart';
import 'package:solera_monte/modelos/arbol_singular.dart';
import 'package:solera_monte/modelos/incendios.dart';
import 'package:solera_monte/modelos/monte.dart';
import 'package:solera_monte/modelos/rodal.dart';
import 'package:solera_monte/pantallas/pantalla_ayuda.dart';

/// Grupos de valores cerrados y su prefijo de clave.
final Map<String, List<String>> gruposDeValores = {
  'figura': figurasMonte,
  'instrumento': tiposInstrumentoGestion,
  'certificacion': sistemasCertificacion,
  'masa': estadosMasa,
  'actuacion': tiposActuacion,
  'aprov': tiposAprovechamiento,
  'unidad': unidadesAprovechamiento,
  'modalidad': modalidadesAprovechamiento,
  'tramite': tramitesAprovechamiento,
  'infra': tiposInfraestructuraIncendios,
  'revision': estadosRevision,
  'arbol': tiposArbolInventario,
  'categoria': [...categoriasIngreso, ...categoriasGasto],
  'regimen': regimenesFiscalesMonte,
};

void main() {
  test('cada valor cerrado tiene su texto en los cuatro idiomas', () {
    final faltan = <String>[];
    for (final MapEntry(key: grupo, value: valores)
        in gruposDeValores.entries) {
      for (final valor in valores) {
        final clave = 'mont.${grupo}_$valor';
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

  test('cada apartado de la ayuda tiene título y texto en los cuatro idiomas',
      () {
    for (final (titulo, texto) in apartadosAyudaMonte) {
      expect(SoleraL10n.clavesDisponibles, containsAll([titulo, texto]));
      for (final idioma in ['eu', 'ca', 'gl']) {
        expect(
            SoleraL10n.clavesTraducidas(idioma), containsAll([titulo, texto]));
      }
    }
  });
}
