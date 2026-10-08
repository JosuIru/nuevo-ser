import '../l10n/app_localizations.dart';
import '../servicios/cliente_sync_zunbeltz.dart';

/// Lo que se le dice a la persona cuando falla la conexión con el
/// servidor, en su idioma. Cualquier error que no sea de sincronización
/// (un fallo inesperado) se cuenta como respuesta inesperada, para que
/// nunca se quede sin mensaje.
String textoErrorSync(Object error, AppLocalizations textos) {
  if (error is! ErrorSyncZunbeltz) return textos.errorSyncRespuesta;
  return switch (error.motivo) {
    MotivoErrorSync.configuracion => textos.errorSyncConfiguracion,
    MotivoErrorSync.sinConexion => textos.errorSyncSinConexion,
    MotivoErrorSync.token => textos.errorSyncToken,
    MotivoErrorSync.pluginAntiguo => textos.errorSyncPluginAntiguo,
    MotivoErrorSync.servidor => textos.errorSyncServidor(error.codigoHttp ?? 0),
    MotivoErrorSync.respuestaInesperada => textos.errorSyncRespuesta,
  };
}
