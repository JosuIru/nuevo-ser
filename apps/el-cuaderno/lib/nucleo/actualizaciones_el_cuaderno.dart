import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Releases de El Cuaderno en GitHub: tag `el-cuaderno-<versión>` con
/// el APK `el-cuaderno-<versión>.apk`. Sólo lo usa la entrada
/// «Actualizaciones» de Ajustes: El Cuaderno no sale a la red por su
/// cuenta (todo opt-in del adulto), así que no hay aviso automático al
/// arrancar; se consulta cuando el adulto abre esa pantalla.
final ConfigActualizaciones configActualizacionesElCuaderno =
    configActualizacionesMonorepo('el-cuaderno');

/// Nombre visible de la app en la pantalla de actualizaciones.
const String nombreAppElCuaderno = 'El Cuaderno';
