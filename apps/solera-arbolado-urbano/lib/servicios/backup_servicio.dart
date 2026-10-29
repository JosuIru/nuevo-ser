import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:sqflite/sqflite.dart';

import '../datos/base_datos.dart';

/// Configuración de la copia de seguridad de Larrea Arbolado Urbano:
/// la BD (`solera_arbolado_urbano.db`) y la carpeta de fotos en un ZIP.
///
/// El identificador es el prefijo de preferencias de siempre, así la
/// fecha de «último backup» (`solera_arbolado_urbano.backup.ultimo_ms`)
/// se conserva, y el nombre del ZIP sigue empezando por
/// `solera-arbolado-backup`. Lee también los ZIP de versiones anteriores.
final ConfiguracionCopiaSeguridad configuracionCopiaSeguridadArbolado =
    ConfiguracionCopiaSeguridad(
  identificadorApp: 'solera_arbolado_urbano',
  nombreApp: 'Larrea Arbolado Urbano',
  nombreFicheroBaseDatos: nombreFicheroBaseDatosArbolado,
  prefijoNombreCopia: 'solera-arbolado-backup',
  versionEsquemaActual: versionEsquemaArbolado,
  cerrarBaseDatos: () => BaseDatosSoleraArbolado.instancia.cerrar(),
  reabrirBaseDatos: () async {
    await BaseDatosSoleraArbolado.instancia.basedatos;
  },
  comprobarIntegridad: comprobarIntegridadBaseDatos,
);

/// Servicio de copia de seguridad de la app (instancia única).
final ServicioCopiaSeguridad servicioCopiaSeguridad =
    ServicioCopiaSeguridad(configuracionCopiaSeguridadArbolado);

/// Abre la BD de una copia en solo lectura y pasa `PRAGMA integrity_check`.
Future<bool> comprobarIntegridadBaseDatos(String rutaBaseDatos) async {
  Database? baseDatos;
  try {
    baseDatos = await openReadOnlyDatabase(rutaBaseDatos);
    final filas = await baseDatos.rawQuery('PRAGMA integrity_check');
    return filas.length == 1 && filas.first.values.first == 'ok';
  } catch (_) {
    return false;
  } finally {
    await baseDatos?.close();
  }
}

/// Texto para la persona según el motivo del error. Solo dice que los
/// datos no se han tocado cuando es verdad ([ErrorCopiaSeguridad.datosIntactos]).
String textoErrorCopiaSeguridad(ErrorCopiaSeguridad error) {
  final String explicacion;
  switch (error.motivo) {
    case MotivoErrorCopiaSeguridad.ficheroNoExiste:
      explicacion = 'El fichero elegido ya no existe.';
    case MotivoErrorCopiaSeguridad.noEsZip:
      explicacion = 'El fichero no es un ZIP válido o está dañado.';
    case MotivoErrorCopiaSeguridad.manifiestoNoValido:
      explicacion = 'La copia está incompleta o dañada.';
    case MotivoErrorCopiaSeguridad.formatoMasNuevo:
    case MotivoErrorCopiaSeguridad.esquemaMasNuevo:
      explicacion =
          'La copia es de una versión más nueva de la app. Actualiza la app y vuelve a intentarlo.';
    case MotivoErrorCopiaSeguridad.deOtraApp:
    case MotivoErrorCopiaSeguridad.sinBaseDatos:
      explicacion = 'La copia no es de Larrea Arbolado Urbano.';
    case MotivoErrorCopiaSeguridad.baseDatosNoValida:
    case MotivoErrorCopiaSeguridad.integridadFallida:
      explicacion = 'La base de datos de la copia está dañada.';
    case MotivoErrorCopiaSeguridad.rutaPeligrosa:
      explicacion = 'La copia contiene rutas no permitidas.';
    case MotivoErrorCopiaSeguridad.respaldoPrevioFallido:
      explicacion =
          'No se pudo guardar antes una copia del estado actual, así que no se ha restaurado nada.';
    case MotivoErrorCopiaSeguridad.sinDatosQueCopiar:
      explicacion = 'Todavía no hay datos que copiar.';
    case MotivoErrorCopiaSeguridad.restauracionRevertida:
      explicacion =
          'La restauración falló a mitad y se ha vuelto al estado anterior.';
    case MotivoErrorCopiaSeguridad.reversionFallida:
      final respaldo = error.respaldoPrevio;
      explicacion =
          'La restauración falló y no se pudo volver del todo al estado anterior. '
          '${respaldo != null ? 'Tu estado anterior está guardado en ${respaldo.path}. ' : ''}'
          'No borres la app y pide ayuda antes de seguir.';
  }
  if (error.datosIntactos &&
      error.motivo != MotivoErrorCopiaSeguridad.sinDatosQueCopiar) {
    return '$explicacion Tus datos no se han tocado.';
  }
  return explicacion;
}
