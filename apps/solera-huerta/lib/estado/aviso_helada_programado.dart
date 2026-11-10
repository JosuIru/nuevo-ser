// Recordatorio de helada en el móvil: la víspera a las 20:00, si se prevé
// helada y hay algo sensible plantado al aire libre. Se cancela y se vuelve
// a programar cada vez que Hoy carga la previsión (un único aviso, con id
// estable). Lo activa la persona en Ajustes («Avisarme de heladas»).
//
// La notificación en sí va detrás de [ProgramadorAvisos]: la app no
// depende aquí de ningún plugin y en los tests se usa uno de memoria.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dominio/avisos_tiempo.dart';

const String clavePreferenciaAvisarHeladas = 'solera_huerta.avisar_heladas';

/// Id fijo del recordatorio de helada (uno solo a la vez).
const int idAvisoHeladaHuerta = 41001;

/// Lo que la app necesita de las notificaciones locales programadas.
abstract class ProgramadorAvisos {
  /// Pide permiso si hace falta; false si la persona lo niega.
  Future<bool> pedirPermiso();

  Future<void> programar({
    required int id,
    required DateTime cuando,
    required String titulo,
    required String cuerpo,
  });

  Future<void> cancelar(int id);
}

/// Sin notificaciones (hasta que haya un programador real, y en tests).
class ProgramadorAvisosNulo implements ProgramadorAvisos {
  const ProgramadorAvisosNulo();

  @override
  Future<bool> pedirPermiso() async => false;

  @override
  Future<void> programar({
    required int id,
    required DateTime cuando,
    required String titulo,
    required String cuerpo,
  }) async {}

  @override
  Future<void> cancelar(int id) async {}
}

/// El programador que usa la app (se fija en `main.dart`).
ProgramadorAvisos programadorAvisosHuerta = const ProgramadorAvisosNulo();

/// Interruptor de Ajustes. Por defecto apagado: pide permiso de
/// notificaciones y no todo el mundo lo quiere.
final ValueNotifier<bool> avisarHeladas = ValueNotifier(false);

Future<void> cargarAvisarHeladas() async {
  try {
    final preferencias = await SharedPreferences.getInstance();
    avisarHeladas.value =
        preferencias.getBool(clavePreferenciaAvisarHeladas) ?? false;
  } catch (error) {
    debugPrint('No se pudo leer «avisar de heladas»: $error');
  }
}

/// Enciende o apaga. Al encender pide permiso; si se niega, queda apagado.
/// Al apagar, cancela el aviso que hubiera.
Future<bool> cambiarAvisarHeladas(bool activar) async {
  var activo = activar;
  if (activar) {
    try {
      activo = await programadorAvisosHuerta.pedirPermiso();
    } catch (error) {
      debugPrint('Sin permiso de notificaciones: $error');
      activo = false;
    }
  } else {
    await programadorAvisosHuerta.cancelar(idAvisoHeladaHuerta);
  }
  avisarHeladas.value = activo;
  try {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setBool(clavePreferenciaAvisarHeladas, activo);
  } catch (error) {
    debugPrint('No se pudo guardar «avisar de heladas»: $error');
  }
  return activo;
}

/// Cancela el aviso anterior y, si toca, programa el de [helada]. Devuelve
/// el momento programado o null. Los textos llegan ya traducidos.
Future<DateTime?> reprogramarAvisoHelada({
  required AvisoHeladaHuerta? helada,
  required String Function(AvisoHeladaHuerta helada) titulo,
  required String Function(AvisoHeladaHuerta helada) cuerpo,
  DateTime? ahora,
}) async {
  try {
    await programadorAvisosHuerta.cancelar(idAvisoHeladaHuerta);
    if (!avisarHeladas.value ||
        helada == null ||
        helada.cultivosSensibles.isEmpty) {
      return null;
    }
    final cuando =
        momentoRecordatorioHelada(helada.fecha, ahora ?? DateTime.now());
    if (cuando == null) return null;
    await programadorAvisosHuerta.programar(
      id: idAvisoHeladaHuerta,
      cuando: cuando,
      titulo: titulo(helada),
      cuerpo: cuerpo(helada),
    );
    return cuando;
  } catch (error) {
    debugPrint('No se pudo programar el aviso de helada: $error');
    return null;
  }
}
