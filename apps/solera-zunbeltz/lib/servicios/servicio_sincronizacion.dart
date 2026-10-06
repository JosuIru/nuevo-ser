import 'package:flutter/foundation.dart';

import '../datos/base_datos.dart';
import '../estado/ajustes_sincronizacion.dart';
import '../estado/datos_notificador.dart';
import '../estado/sesion_espacio.dart';
import 'cliente_sync_zunbeltz.dart';

/// `true` mientras hay una sincronización en marcha (para que la interfaz
/// muestre que está trabajando y no lance otra a la vez).
final ValueNotifier<bool> sincronizandoEspacio = ValueNotifier<bool>(false);

/// Funciones a las que se avisa tras cada sincronización correcta (p. ej.
/// para lanzar notificaciones de alarmas o peticiones nuevas).
final List<void Function(ResultadoSyncZunbeltz)> oyentesSincronizacion = [];

/// Sincroniza el espacio con el WordPress configurado en Ajustes. Devuelve
/// `null` si no hay sincronización configurada o ya hay una en curso; lanza
/// [ErrorSyncZunbeltz] si falla (sin cobertura, token incorrecto…).
///
/// Refresca la sesión (persona y permisos) y avisa a las pantallas para que
/// recarguen.
Future<ResultadoSyncZunbeltz?> sincronizarEspacio({bool completa = false}) async {
  if (sincronizandoEspacio.value) return null;
  final url = await AjustesSincronizacion.cargarUrl();
  final token = await AjustesSincronizacion.cargarToken();
  if (url.isEmpty || token.isEmpty) return null;

  sincronizandoEspacio.value = true;
  try {
    final resultado = await ClienteSyncZunbeltz(urlBase: url, token: token)
        .sincronizar(BaseDatosSoleraZunbeltz(), completa: completa);
    await guardarSesionEspacio(
        resultado.sesionRemota.sesion, resultado.sesionRemota.personas);
    avisarCambioDatos();
    for (final oyente in List.of(oyentesSincronizacion)) {
      oyente(resultado);
    }
    return resultado;
  } finally {
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
  await BaseDatosSoleraZunbeltz()
      .guardarEstadoSync(ClienteSyncZunbeltz.claveRevision, 0);
}
