import 'package:flutter_test/flutter_test.dart';
import 'package:agro/datos/base_datos.dart';
import 'package:agro/servicios/backup_servicio.dart';

void main() {
  test('la copia de seguridad conserva el identificador, la BD y el nombre de siempre', () {
    final configuracion = configuracionCopiaSeguridadAgro;
    // `agro` es el prefijo de preferencias de siempre: así se conserva
    // la fecha de la última copia (`agro.backup.ultimo_ms`).
    expect(configuracion.identificadorApp, 'agro');
    expect(configuracion.nombreFicheroBaseDatos, 'agro.db');
    expect(nombreFicheroBaseDatosAgro, 'agro.db');
    expect(configuracion.prefijoNombreCopia, 'solera-backup');
    expect(configuracion.versionEsquemaActual, versionEsquemaAgro);
    expect(versionEsquemaAgro, 7);
    expect(configuracion.carpetasExtra, contains('fotos'));
    expect(configuracion.comprobarIntegridad, isNotNull);
  });
}
