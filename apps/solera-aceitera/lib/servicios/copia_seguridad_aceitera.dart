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

/// Configuración de la copia de seguridad de Solera Aceitera: la BD
/// `solera_aceitera.db` y, si existe, la carpeta `fotos/`. No lleva
/// preferencias: así la clave de Anthropic nunca sale en un ZIP que se
/// comparte por correo o mensajería.
ConfiguracionCopiaSeguridad configuracionCopiaSoleraAceitera() =>
    ConfiguracionCopiaSeguridad(
      identificadorApp: identificadorCopiaSoleraAceitera,
      nombreApp: 'Solera Aceitera',
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

/// Copia de seguridad de Solera Aceitera sobre el servicio común del core
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
      causa = 'No se encuentra el fichero elegido.';
    case MotivoErrorCopiaSeguridad.noEsZip:
      causa = 'El fichero no es un ZIP válido o está dañado.';
    case MotivoErrorCopiaSeguridad.manifiestoNoValido:
      causa = 'La copia está incompleta o no se entiende.';
    case MotivoErrorCopiaSeguridad.formatoMasNuevo:
    case MotivoErrorCopiaSeguridad.esquemaMasNuevo:
      causa = 'La copia la hizo una versión más nueva de Solera Aceitera. '
          'Actualiza la app y vuelve a intentarlo.';
    case MotivoErrorCopiaSeguridad.deOtraApp:
      causa = 'La copia es de otra aplicación, no de Solera Aceitera.';
    case MotivoErrorCopiaSeguridad.sinBaseDatos:
      causa = 'El ZIP no contiene una base de datos de Solera Aceitera.';
    case MotivoErrorCopiaSeguridad.baseDatosNoValida:
    case MotivoErrorCopiaSeguridad.integridadFallida:
      causa = 'La base de datos de la copia está dañada.';
    case MotivoErrorCopiaSeguridad.rutaPeligrosa:
      causa = 'La copia contiene rutas no permitidas y se ha rechazado.';
    case MotivoErrorCopiaSeguridad.respaldoPrevioFallido:
      causa = 'No se ha podido guardar antes una copia de los datos '
          'actuales, así que no se ha restaurado nada.';
    case MotivoErrorCopiaSeguridad.sinDatosQueCopiar:
      causa = 'Todavía no hay datos que copiar.';
    case MotivoErrorCopiaSeguridad.restauracionRevertida:
      causa = 'La restauración ha fallado a mitad y se ha vuelto al '
          'estado anterior.';
    case MotivoErrorCopiaSeguridad.reversionFallida:
      final respaldo = error.respaldoPrevio;
      causa = 'La restauración ha fallado y no se ha podido volver del '
          'todo al estado anterior. No borres nada y pide ayuda'
          '${respaldo != null ? ': tus datos anteriores están en ${respaldo.path}' : ''}.';
  }
  if (!error.datosIntactos) return causa;
  return '$causa Tus datos no se han tocado.';
}

/// Se incrementa tras restaurar una copia: la pantalla principal se
/// reconstruye entera para que ninguna pestaña enseñe datos de antes.
final ValueNotifier<int> generacionDatosAceitera = ValueNotifier<int>(0);
