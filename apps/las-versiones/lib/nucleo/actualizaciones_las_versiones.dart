import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Releases de Las Versiones en GitHub: tag `las-versiones-<versión>`
/// con el APK `las-versiones-<versión>.apk`. Lo usan el aviso de la
/// pantalla de inicio y la entrada «Actualizaciones» del menú.
final ConfigActualizaciones configActualizacionesLasVersiones =
    configActualizacionesMonorepo('las-versiones');

/// Nombre visible de la app en la pantalla de actualizaciones.
const String nombreAppLasVersiones = 'Las Versiones';
