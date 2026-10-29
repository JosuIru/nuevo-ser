import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show ConfiguracionCopiaSeguridad, ServicioCopiaSeguridad;
import 'package:sqflite/sqflite.dart';

import '../datos/base_datos.dart';

/// Configuración de la copia de seguridad de Larrea (agro): la BD
/// `agro.db` y la carpeta `fotos/`. El identificador `agro` es el
/// prefijo de preferencias de siempre, así se conserva la fecha de la
/// «última copia» (`agro.backup.ultimo_ms`), y el nombre del ZIP sigue
/// empezando por `solera-backup`. Lee también los ZIP hechos antes.
final ConfiguracionCopiaSeguridad configuracionCopiaSeguridadAgro = ConfiguracionCopiaSeguridad(
  identificadorApp: 'agro',
  nombreApp: 'Larrea',
  nombreFicheroBaseDatos: nombreFicheroBaseDatosAgro,
  cerrarBaseDatos: () => BaseDatosAgro.instancia.cerrar(),
  reabrirBaseDatos: () async {
    await BaseDatosAgro.instancia.basedatos;
  },
  prefijoNombreCopia: 'solera-backup',
  versionEsquemaActual: versionEsquemaAgro,
  comprobarIntegridad: comprobarIntegridadBaseDatos,
);

/// Instancia única del servicio de copia de seguridad de la app.
final ServicioCopiaSeguridad servicioCopiaSeguridadAgro =
    ServicioCopiaSeguridad(configuracionCopiaSeguridadAgro);

/// Abre la BD extraída en solo lectura y pasa `PRAGMA integrity_check`.
Future<bool> comprobarIntegridadBaseDatos(String rutaBaseDatos) async {
  final baseDatos = await openReadOnlyDatabase(rutaBaseDatos);
  try {
    final filas = await baseDatos.rawQuery('PRAGMA integrity_check');
    return filas.length == 1 && filas.first.values.first == 'ok';
  } finally {
    await baseDatos.close();
  }
}
