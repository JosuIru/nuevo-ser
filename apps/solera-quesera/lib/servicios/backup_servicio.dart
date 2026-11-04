import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:sqflite/sqflite.dart';

import '../datos/base_datos.dart';

/// Identificador de la app en las copias y en las preferencias. Es el
/// prefijo de siempre (`solera_quesera.backup.ultimo_ms` guarda la fecha
/// de la última copia): no cambiarlo nunca.
const String identificadorCopiaSoleraQuesera = 'solera_quesera';

/// Prefijo del nombre del ZIP, el mismo que usaba la app antes del
/// servicio común (`solera-quesera-backup-<fecha>.zip`).
const String prefijoNombreCopiaSoleraQuesera = 'solera-quesera-backup';

/// Configuración de la copia de seguridad de Larrea Quesera: la BD
/// `solera_quesera.db` y la carpeta `fotos/`.
ConfiguracionCopiaSeguridad configuracionCopiaSoleraQuesera() =>
    ConfiguracionCopiaSeguridad(
      identificadorApp: identificadorCopiaSoleraQuesera,
      nombreApp: 'Larrea Quesera',
      nombreFicheroBaseDatos: nombreFicheroBaseDatosSoleraQuesera,
      prefijoNombreCopia: prefijoNombreCopiaSoleraQuesera,
      versionEsquemaActual: versionEsquemaSoleraQuesera,
      cerrarBaseDatos: () => BaseDatosSoleraQuesera.instancia.cerrar(),
      reabrirBaseDatos: () async {
        await BaseDatosSoleraQuesera.instancia.basedatos;
      },
      comprobarIntegridad: comprobarIntegridadBaseDatos,
    );

/// Abre la BD extraída de una copia en solo lectura y pasa
/// `PRAGMA integrity_check`. True solo si SQLite responde «ok».
Future<bool> comprobarIntegridadBaseDatos(String rutaBaseDatos) async {
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

/// Copia de seguridad de Larrea Quesera sobre el servicio común del core
/// (valida antes de tocar nada, respalda el estado actual y revierte si
/// algo falla). Una sola instancia para toda la app.
class BackupServicioQuesera {
  BackupServicioQuesera._();

  static final ServicioCopiaSeguridad instancia =
      ServicioCopiaSeguridad(configuracionCopiaSoleraQuesera());
}

/// Explicación para la persona de por qué ha fallado una copia o una
/// restauración. Solo dice que los datos no se han tocado cuando el
/// servicio lo garantiza ([ErrorCopiaSeguridad.datosIntactos]).
String textoErrorCopia(ErrorCopiaSeguridad error) {
  final String causa;
  switch (error.motivo) {
    case MotivoErrorCopiaSeguridad.ficheroNoExiste:
      causa = SoleraL10n.t('ques.copia_error_fichero_no_existe');
      break;
    case MotivoErrorCopiaSeguridad.noEsZip:
      causa = SoleraL10n.t('ques.copia_error_no_es_zip');
      break;
    case MotivoErrorCopiaSeguridad.manifiestoNoValido:
      causa = SoleraL10n.t('ques.copia_error_incompleta');
      break;
    case MotivoErrorCopiaSeguridad.formatoMasNuevo:
    case MotivoErrorCopiaSeguridad.esquemaMasNuevo:
      causa = SoleraL10n.t('ques.copia_error_version_mas_nueva');
      break;
    case MotivoErrorCopiaSeguridad.deOtraApp:
      causa = SoleraL10n.t('ques.copia_error_otra_app');
      break;
    case MotivoErrorCopiaSeguridad.sinBaseDatos:
      causa = SoleraL10n.t('ques.copia_error_sin_base_datos');
      break;
    case MotivoErrorCopiaSeguridad.baseDatosNoValida:
    case MotivoErrorCopiaSeguridad.integridadFallida:
      causa = SoleraL10n.t('ques.copia_error_bd_danada');
      break;
    case MotivoErrorCopiaSeguridad.rutaPeligrosa:
      causa = SoleraL10n.t('ques.copia_error_rutas');
      break;
    case MotivoErrorCopiaSeguridad.respaldoPrevioFallido:
      causa = SoleraL10n.t('ques.copia_error_respaldo_previo');
      break;
    case MotivoErrorCopiaSeguridad.sinDatosQueCopiar:
      causa = SoleraL10n.t('ques.copia_error_sin_datos');
      break;
    case MotivoErrorCopiaSeguridad.restauracionRevertida:
      causa = SoleraL10n.t('ques.copia_error_revertida');
      break;
    case MotivoErrorCopiaSeguridad.reversionFallida:
      final respaldo = error.respaldoPrevio;
      causa = respaldo != null
          ? SoleraL10n.tf('ques.copia_error_reversion_fallida_ruta',
              {'ruta': respaldo.path})
          : SoleraL10n.t('ques.copia_error_reversion_fallida');
      break;
  }
  if (!error.datosIntactos) return causa;
  return '$causa ${SoleraL10n.t('ques.datos_no_tocados')}';
}
