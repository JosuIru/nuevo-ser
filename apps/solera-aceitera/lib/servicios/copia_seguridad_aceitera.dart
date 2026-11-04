import 'package:flutter/foundation.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:sqflite/sqflite.dart';

import '../datos/base_datos.dart';
import '../estado/clave_anthropic_aceitera.dart';

/// Identificador de la app en las copias y en las preferencias (la
/// fecha de la última copia va en `solera_aceitera.backup.ultimo_ms`).
/// No cambiarlo nunca: las copias hechas dejarían de reconocerse.
const String identificadorCopiaSoleraAceitera = prefijoPreferenciasAceitera;

/// Prefijo del nombre del ZIP (`solera-aceitera-copia-<fecha>.zip`).
const String prefijoNombreCopiaSoleraAceitera = 'solera-aceitera-copia';

/// Configuración de la copia de seguridad de Larrea Aceitera: la BD
/// `solera_aceitera.db` y, si existe, la carpeta `fotos/`. No lleva
/// preferencias: así la clave de Anthropic nunca sale en un ZIP que se
/// comparte por correo o mensajería.
ConfiguracionCopiaSeguridad configuracionCopiaSoleraAceitera() =>
    ConfiguracionCopiaSeguridad(
      identificadorApp: identificadorCopiaSoleraAceitera,
      nombreApp: 'Larrea Aceitera',
      nombreFicheroBaseDatos: nombreFicheroBaseDatosAceitera,
      prefijoNombreCopia: prefijoNombreCopiaSoleraAceitera,
      versionEsquemaActual: versionEsquemaSoleraAceitera,
      cerrarBaseDatos: () => BaseDatosSoleraAceitera.instancia.cerrar(),
      reabrirBaseDatos: () async {
        await BaseDatosSoleraAceitera.instancia.basedatos;
      },
      comprobarIntegridad: comprobarIntegridadBaseDatosAceitera,
    );

/// Abre la BD extraída de una copia en solo lectura y pasa
/// `PRAGMA integrity_check`. True solo si SQLite responde «ok».
Future<bool> comprobarIntegridadBaseDatosAceitera(String rutaBaseDatos) async {
  final baseDatos =
      await openReadOnlyDatabase(rutaBaseDatos, singleInstance: false);
  try {
    final filas = await baseDatos.rawQuery('PRAGMA integrity_check');
    return filas.length == 1 &&
        filas.first.values.first?.toString().toLowerCase() == 'ok';
  } finally {
    await baseDatos.close();
  }
}

/// Copia de seguridad de Larrea Aceitera sobre el servicio común del core
/// (valida antes de tocar nada, respalda el estado actual y revierte si
/// algo falla). Una sola instancia para toda la app.
final ServicioCopiaSeguridad servicioCopiaSeguridadAceitera =
    ServicioCopiaSeguridad(configuracionCopiaSoleraAceitera());

/// Explicación para la persona de por qué ha fallado una copia o una
/// restauración. Solo dice que los datos no se han tocado cuando el
/// servicio lo garantiza ([ErrorCopiaSeguridad.datosIntactos]).
String textoErrorCopiaAceitera(ErrorCopiaSeguridad error) {
  final String causa;
  switch (error.motivo) {
    case MotivoErrorCopiaSeguridad.ficheroNoExiste:
      causa = SoleraL10n.t('acei.copia_error_fichero_no_existe');
    case MotivoErrorCopiaSeguridad.noEsZip:
      causa = SoleraL10n.t('acei.copia_error_no_es_zip');
    case MotivoErrorCopiaSeguridad.manifiestoNoValido:
      causa = SoleraL10n.t('acei.copia_error_manifiesto');
    case MotivoErrorCopiaSeguridad.formatoMasNuevo:
    case MotivoErrorCopiaSeguridad.esquemaMasNuevo:
      causa = SoleraL10n.t('acei.copia_error_version_mas_nueva');
    case MotivoErrorCopiaSeguridad.deOtraApp:
      causa = SoleraL10n.t('acei.copia_error_otra_app');
    case MotivoErrorCopiaSeguridad.sinBaseDatos:
      causa = SoleraL10n.t('acei.copia_error_sin_base_datos');
    case MotivoErrorCopiaSeguridad.baseDatosNoValida:
    case MotivoErrorCopiaSeguridad.integridadFallida:
      causa = SoleraL10n.t('acei.copia_error_base_datos_danada');
    case MotivoErrorCopiaSeguridad.rutaPeligrosa:
      causa = SoleraL10n.t('acei.copia_error_ruta_peligrosa');
    case MotivoErrorCopiaSeguridad.respaldoPrevioFallido:
      causa = SoleraL10n.t('acei.copia_error_respaldo_previo');
    case MotivoErrorCopiaSeguridad.sinDatosQueCopiar:
      causa = SoleraL10n.t('acei.copia_error_sin_datos');
    case MotivoErrorCopiaSeguridad.restauracionRevertida:
      causa = SoleraL10n.t('acei.copia_error_restauracion_revertida');
    case MotivoErrorCopiaSeguridad.reversionFallida:
      final respaldo = error.respaldoPrevio;
      causa = respaldo != null
          ? SoleraL10n.tf('acei.copia_error_reversion_fallida_ruta',
              {'ruta': respaldo.path})
          : SoleraL10n.t('acei.copia_error_reversion_fallida');
  }
  if (!error.datosIntactos) return causa;
  return '$causa ${SoleraL10n.t('acei.copia_datos_no_tocados')}';
}

/// Se incrementa tras restaurar una copia: la pantalla principal se
/// reconstruye entera para que ninguna pestaña enseñe datos de antes.
final ValueNotifier<int> generacionDatosAceitera = ValueNotifier<int>(0);
