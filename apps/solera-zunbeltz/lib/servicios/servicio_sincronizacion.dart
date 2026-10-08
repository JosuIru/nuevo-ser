import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../datos/base_datos.dart';
import '../estado/ajustes_sincronizacion.dart';
import '../estado/datos_notificador.dart';
import '../estado/sesion_espacio.dart';
import 'cliente_sync_zunbeltz.dart';
import 'sincronizacion_segundo_plano.dart' show claveUltimaSincronizacion;

/// `true` mientras hay una sincronización en marcha (para que la interfaz
/// muestre que está trabajando y no lance otra a la vez).
final ValueNotifier<bool> sincronizandoEspacio = ValueNotifier<bool>(false);

/// Funciones a las que se avisa tras cada sincronización correcta (p. ej.
/// para lanzar notificaciones de alarmas o peticiones nuevas).
final List<Future<void> Function(ResultadoSyncZunbeltz)> oyentesSincronizacion =
    [];

/// Sincroniza el espacio con el WordPress configurado en Ajustes. Devuelve
/// `null` si no hay sincronización configurada o ya hay una en curso; lanza
/// [ErrorSyncZunbeltz] si falla (sin cobertura, token incorrecto…).
///
/// Refresca la sesión (persona y permisos) y avisa a las pantallas para que
/// recarguen.
Future<ResultadoSyncZunbeltz?> sincronizarEspacio(
    {bool completa = false}) async {
  if (sincronizandoEspacio.value) return null;
  final url = await AjustesSincronizacion.cargarUrl();
  final token = await AjustesSincronizacion.cargarToken();
  if (url.isEmpty || token.isEmpty) return null;

  final bd = BaseDatosSoleraZunbeltz();
  // La tarea en segundo plano y otras pestañas no ven `sincronizandoEspacio`.
  if (!await bd.tomarCandadoSync()) return null;
  sincronizandoEspacio.value = true;
  try {
    final cliente = ClienteSyncZunbeltz(urlBase: url, token: token);
    var resultado = await cliente.sincronizar(bd, completa: completa);
    // Proyecto asignado o retirado, o cambio de rol: la completa ya, para
    // no esperar a la próxima vuelta con datos que no tocan.
    if (resultado.cambioVisibilidad) {
      final primera = resultado;
      final completa = await cliente.sincronizar(bd, completa: true);
      // Lo recibido en la primera también tiene que avisar (alarmas…).
      resultado = ResultadoSyncZunbeltz(
        subidas: primera.subidas + completa.subidas,
        bajadas: primera.bajadas + completa.bajadas,
        omitidasFincaDesconocida: completa.omitidasFincaDesconocida,
        rechazadasPorPermisos:
            primera.rechazadasPorPermisos + completa.rechazadasPorPermisos,
        sesionRemota: completa.sesionRemota,
        retiradas: primera.retiradas + completa.retiradas,
        entidadesSubidas: primera.entidadesSubidas + completa.entidadesSubidas,
        entidadesBajadas: primera.entidadesBajadas + completa.entidadesBajadas,
        actividadNueva: [...primera.actividadNueva, ...completa.actividadNueva],
        entidadesNuevasRecibidas: [
          ...primera.entidadesNuevasRecibidas,
          ...completa.entidadesNuevasRecibidas,
        ],
      );
    }
    await guardarSesionEspacio(
        resultado.sesionRemota.sesion, resultado.sesionRemota.personas);
    // La comparte la tarea en segundo plano para no sincronizar a la vez.
    await (await SharedPreferences.getInstance()).setInt(
        claveUltimaSincronizacion, DateTime.now().millisecondsSinceEpoch);
    avisarCambioDatos();
    for (final oyente in List.of(oyentesSincronizacion)) {
      await oyente(resultado);
    }
    return resultado;
  } finally {
    await bd.soltarCandadoSync();
    sincronizandoEspacio.value = false;
  }
}

/// Como [sincronizarEspacio] pero sin errores: para la sincronización
/// automática (al abrir la app, al volver a ella, cada pocos minutos), que
/// no debe molestar si no hay cobertura.
Future<void> sincronizarEspacioEnSilencio() async {
  try {
    await sincronizarEspacio();
  } on ErrorSyncZunbeltz {
    // Sin cobertura o servidor caído: se reintentará en la próxima.
  } catch (_) {
    // Nada de lo automático debe tumbar la app.
  }
}

/// Al cambiar de persona (otro token) o de WordPress, lo que hay en el
/// móvil puede no corresponder a la nueva sesión: la próxima sincronización
/// será completa y retirará lo que ya no se ve.
Future<void> reiniciarCursoresSincronizacion() async {
  final bd = BaseDatosSoleraZunbeltz();
  await bd.guardarEstadoSync(ClienteSyncZunbeltz.claveRevision, 0);
  // Por si había una sincronización en marcha: al terminar guardaría la
  // revisión de la sesión anterior y la completa no llegaría a hacerse.
  await bd.pedirSincronizacionCompleta();
}
