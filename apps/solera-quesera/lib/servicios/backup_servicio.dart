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
      causa = 'No se encuentra el fichero elegido.';
      break;
    case MotivoErrorCopiaSeguridad.noEsZip:
      causa = 'El fichero no es un ZIP válido o está dañado.';
      break;
    case MotivoErrorCopiaSeguridad.manifiestoNoValido:
      causa = 'La copia está incompleta o no se entiende.';
      break;
    case MotivoErrorCopiaSeguridad.formatoMasNuevo:
    case MotivoErrorCopiaSeguridad.esquemaMasNuevo:
      causa = 'La copia la hizo una versión más nueva de Larrea Quesera. '
          'Actualiza la app y vuelve a intentarlo.';
      break;
    case MotivoErrorCopiaSeguridad.deOtraApp:
      causa = 'La copia es de otra aplicación, no de Larrea Quesera.';
      break;
    case MotivoErrorCopiaSeguridad.sinBaseDatos:
      causa = 'El ZIP no contiene una base de datos de Larrea Quesera.';
      break;
    case MotivoErrorCopiaSeguridad.baseDatosNoValida:
    case MotivoErrorCopiaSeguridad.integridadFallida:
      causa = 'La base de datos de la copia está dañada.';
      break;
    case MotivoErrorCopiaSeguridad.rutaPeligrosa:
      causa = 'La copia contiene rutas no permitidas y se ha rechazado.';
      break;
    case MotivoErrorCopiaSeguridad.respaldoPrevioFallido:
      causa = 'No se ha podido guardar antes una copia de los datos '
          'actuales, así que no se ha restaurado nada.';
      break;
    case MotivoErrorCopiaSeguridad.sinDatosQueCopiar:
      causa = 'Todavía no hay datos que copiar.';
      break;
    case MotivoErrorCopiaSeguridad.restauracionRevertida:
      causa = 'La restauración ha fallado a mitad y se ha vuelto al '
          'estado anterior.';
      break;
    case MotivoErrorCopiaSeguridad.reversionFallida:
      final respaldo = error.respaldoPrevio;
      causa = 'La restauración ha fallado y no se ha podido volver del '
          'todo al estado anterior. No borres nada y pide ayuda'
          '${respaldo != null ? ': tus datos anteriores están en ${respaldo.path}' : ''}.';
      break;
  }
  if (!error.datosIntactos) return causa;
  return '$causa Tus datos no se han tocado.';
}
