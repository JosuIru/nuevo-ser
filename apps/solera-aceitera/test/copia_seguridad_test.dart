// Configuración de la copia de seguridad: los identificadores no pueden
// cambiar sin que las copias ya hechas (y la fecha de la última) dejen
// de reconocerse, y la clave de Anthropic no debe viajar en el ZIP.

import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:solera_aceitera/datos/base_datos.dart';
import 'package:solera_aceitera/estado/clave_anthropic_aceitera.dart';
import 'package:solera_aceitera/servicios/copia_seguridad_aceitera.dart';

void main() {
  group('configuración de la copia de seguridad', () {
    final configuracion = configuracionCopiaSoleraAceitera();

    test('identificador y nombres de siempre', () {
      expect(configuracion.identificadorApp, 'solera_aceitera');
      expect(configuracion.nombreFicheroBaseDatos, 'solera_aceitera.db');
      expect(configuracion.prefijoNombreCopia, 'solera-aceitera-copia');
    });

    test('la versión de esquema es la que abre la base de datos', () {
      expect(configuracion.versionEsquemaActual, versionEsquemaSoleraAceitera);
      expect(versionEsquemaSoleraAceitera, 2);
    });

    test('comprueba la integridad de la BD antes de restaurar', () {
      expect(configuracion.comprobarIntegridad, isNotNull);
    });

    test('no copia preferencias (la clave de Anthropic se queda)', () {
      expect(configuracion.prefijosPreferencias, isEmpty);
      expect(configuracion.clavesPreferencias, isEmpty);
    });
  });

  group('textos de error', () {
    test('solo dice que los datos están intactos cuando lo están', () {
      final rechazada = textoErrorCopiaAceitera(const ErrorCopiaSeguridad(
          MotivoErrorCopiaSeguridad.deOtraApp, 'otra app'));
      expect(rechazada, contains('no se han tocado'));

      final sinVolver = textoErrorCopiaAceitera(const ErrorCopiaSeguridad(
          MotivoErrorCopiaSeguridad.reversionFallida, 'a medias'));
      expect(sinVolver, isNot(contains('no se han tocado')));
      expect(sinVolver, contains('pide ayuda'));
    });
  });

  test('la clave de Anthropic sigue en la preferencia de siempre', () {
    expect(estadoClaveAnthropicAceitera.claveAlmacenamiento,
        'solera_aceitera.anthropic.clave');
  });
}
