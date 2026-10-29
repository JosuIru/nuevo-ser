import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:sqflite/sqflite.dart';

import '../datos/base_datos.dart';

/// Configuración de la copia de seguridad de Larrea Apícola. Mantiene
/// el identificador `solera_apicola` (la fecha de la última copia sigue
/// en `solera_apicola.backup.ultimo_ms`) y el nombre de los ZIP de antes
/// (`solera-apicola-backup-…`), así que las copias ya hechas se leen.
ConfiguracionCopiaSeguridad configuracionCopiaSeguridadApicola() {
  return ConfiguracionCopiaSeguridad(
    identificadorApp: 'solera_apicola',
    nombreApp: 'Larrea Apícola',
    nombreFicheroBaseDatos: nombreFicheroBaseDatosApicola,
    prefijoNombreCopia: 'solera-apicola-backup',
    versionEsquemaActual: versionEsquemaBaseDatosApicola,
    cerrarBaseDatos: () => BaseDatosSoleraApicola.instancia.cerrar(),
    reabrirBaseDatos: () async {
      await BaseDatosSoleraApicola.instancia.basedatos;
    },
    comprobarIntegridad: comprobarIntegridadBaseDatos,
  );
}

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

/// Instancia única del servicio (sus operaciones no se solapan).
final ServicioCopiaSeguridad servicioCopiaSeguridadApicola =
    ServicioCopiaSeguridad(configuracionCopiaSeguridadApicola());
