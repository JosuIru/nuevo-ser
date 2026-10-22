import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:solera_arbolado_urbano/datos/base_datos.dart';
import 'package:solera_arbolado_urbano/servicios/backup_servicio.dart';

void main() {
  group('Configuración de la copia de seguridad', () {
    test('conserva el identificador, la BD y el prefijo de siempre', () {
      final configuracion = configuracionCopiaSeguridadArbolado;
      // El identificador da la clave de «último backup»
      // (`solera_arbolado_urbano.backup.ultimo_ms`).
      expect(configuracion.identificadorApp, 'solera_arbolado_urbano');
      expect(configuracion.nombreFicheroBaseDatos, 'solera_arbolado_urbano.db');
      expect(configuracion.prefijoNombreCopia, 'solera-arbolado-backup');
      expect(configuracion.carpetasExtra, contains('fotos'));
      expect(configuracion.comprobarIntegridad, isNotNull);
    });

    test('la versión de esquema es la que abre la BD', () {
      expect(configuracionCopiaSeguridadArbolado.versionEsquemaActual,
          versionEsquemaArbolado);
      expect(versionEsquemaArbolado, 2);
      expect(nombreFicheroBaseDatosArbolado, 'solera_arbolado_urbano.db');
    });
  });

  group('Texto de los errores de copia', () {
    test('dice que los datos no se han tocado solo si es verdad', () {
      const rechazada = ErrorCopiaSeguridad(
          MotivoErrorCopiaSeguridad.deOtraApp, 'otra app');
      expect(textoErrorCopiaSeguridad(rechazada),
          contains('Tus datos no se han tocado'));

      final sinVueltaAtras = ErrorCopiaSeguridad(
        MotivoErrorCopiaSeguridad.reversionFallida,
        'fallo',
        respaldoPrevio: File('/datos/copias_automaticas/antes.zip'),
      );
      final texto = textoErrorCopiaSeguridad(sinVueltaAtras);
      expect(texto, isNot(contains('no se han tocado')));
      expect(texto, contains('antes.zip'));
    });

    test('cubre todos los motivos', () {
      for (final motivo in MotivoErrorCopiaSeguridad.values) {
        expect(
            textoErrorCopiaSeguridad(ErrorCopiaSeguridad(motivo, '')), isNotEmpty);
      }
    });
  });
}
