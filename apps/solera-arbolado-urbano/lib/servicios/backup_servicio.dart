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
      explicacion = SoleraL10n.t('arb.backup_fichero_no_existe');
    case MotivoErrorCopiaSeguridad.noEsZip:
      explicacion = SoleraL10n.t('arb.backup_no_es_zip');
    case MotivoErrorCopiaSeguridad.manifiestoNoValido:
      explicacion = SoleraL10n.t('arb.backup_incompleta');
    case MotivoErrorCopiaSeguridad.formatoMasNuevo:
    case MotivoErrorCopiaSeguridad.esquemaMasNuevo:
      explicacion = SoleraL10n.t('arb.backup_version_mas_nueva');
    case MotivoErrorCopiaSeguridad.deOtraApp:
    case MotivoErrorCopiaSeguridad.sinBaseDatos:
      explicacion = SoleraL10n.t('arb.backup_de_otra_app');
    case MotivoErrorCopiaSeguridad.baseDatosNoValida:
    case MotivoErrorCopiaSeguridad.integridadFallida:
      explicacion = SoleraL10n.t('arb.backup_bd_danada');
    case MotivoErrorCopiaSeguridad.rutaPeligrosa:
      explicacion = SoleraL10n.t('arb.backup_rutas_no_permitidas');
    case MotivoErrorCopiaSeguridad.respaldoPrevioFallido:
      explicacion = SoleraL10n.t('arb.backup_respaldo_previo_fallido');
    case MotivoErrorCopiaSeguridad.sinDatosQueCopiar:
      explicacion = SoleraL10n.t('arb.backup_sin_datos');
    case MotivoErrorCopiaSeguridad.restauracionRevertida:
      explicacion = SoleraL10n.t('arb.backup_restauracion_revertida');
    case MotivoErrorCopiaSeguridad.reversionFallida:
      final respaldo = error.respaldoPrevio;
      explicacion = [
        SoleraL10n.t('arb.backup_reversion_fallida'),
        if (respaldo != null)
          SoleraL10n.tf('arb.backup_estado_anterior_en', {'ruta': respaldo.path}),
        SoleraL10n.t('arb.backup_no_borres_app'),
      ].join(' ');
  }
  if (error.datosIntactos &&
      error.motivo != MotivoErrorCopiaSeguridad.sinDatosQueCopiar) {
    return '$explicacion ${SoleraL10n.t('arb.backup_datos_intactos')}';
  }
  return explicacion;
}
