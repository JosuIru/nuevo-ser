import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:sqflite/sqflite.dart';

import '../datos/base_datos.dart';
import '../estado/clave_ia.dart';

/// Configuración de la copia de seguridad de Solera Viticultura sobre el
/// servicio común del core.
///
/// - `identificadorApp` es el prefijo de preferencias de siempre, así la
///   fecha de «última copia» (`solera_viticultura.backup.ultimo_ms`)
///   sigue valiendo y las copias se reconocen como de esta app.
/// - El ZIP se sigue llamando `solera-viticultura-backup-<fecha>.zip` y
///   lleva la BD y la carpeta `fotos/`. Los ZIP antiguos se leen igual.
/// - No copia preferencias: la clave de Anthropic no debe viajar en un
///   fichero que se comparte por WhatsApp o correo.
ConfiguracionCopiaSeguridad configuracionCopiaSeguridadViticultura() {
  return ConfiguracionCopiaSeguridad(
    identificadorApp: prefijoPreferenciasViticultura,
    nombreApp: 'Solera Viticultura',
    nombreFicheroBaseDatos: nombreFicheroBaseDatosViticultura,
    prefijoNombreCopia: 'solera-viticultura-backup',
    versionEsquemaActual: versionEsquemaBaseDatosViticultura,
    cerrarBaseDatos: () => BaseDatosSoleraViticultura.instancia.cerrar(),
    reabrirBaseDatos: () async {
      await BaseDatosSoleraViticultura.instancia.basedatos;
    },
    comprobarIntegridad: comprobarIntegridadBaseDatos,
  );
}

/// `PRAGMA integrity_check` sobre la BD extraída, abierta en solo lectura
/// (sin migraciones ni escrituras).
Future<bool> comprobarIntegridadBaseDatos(String rutaBaseDatos) async {
  Database? baseDatosCopia;
  try {
    baseDatosCopia = await openReadOnlyDatabase(rutaBaseDatos);
    final filas = await baseDatosCopia.rawQuery('PRAGMA integrity_check');
    return filas.length == 1 && filas.first.values.first == 'ok';
  } catch (_) {
    return false;
  } finally {
    await baseDatosCopia?.close();
  }
}

/// Instancia única del servicio de copia de seguridad de la app.
final ServicioCopiaSeguridad servicioCopiaSeguridadViticultura =
    ServicioCopiaSeguridad(configuracionCopiaSeguridadViticultura());
