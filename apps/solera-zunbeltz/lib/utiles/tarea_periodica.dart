import 'dart:convert';

import 'package:crypto/crypto.dart';

/// uid de la instancia que sigue a una tarea periódica. Es siempre el mismo
/// para la misma tarea, aquí y en el servidor (`szs_uid_siguiente_periodica`):
/// si la cierran dos móviles sin cobertura, o la genera el servidor porque
/// la cerró una tester, al sincronizar es una sola tarea y no dos.
String uidSiguientePeriodica(String uidTarea) =>
    'sig-${sha1.convert(utf8.encode(uidTarea)).toString().substring(0, 28)}';

/// Fecha objetivo de la siguiente instancia: [dias] después de hoy, o de la
/// fecha objetivo original si aún no ha llegado. Se suman días de
/// calendario, no tandas de 24 h: con el cambio de hora una fecha a
/// medianoche caería en la víspera.
DateTime fechaSiguientePeriodica(
    {int? fechaObjetivoMs, required int dias, required DateTime ahora}) {
  final base = fechaObjetivoMs != null &&
          fechaObjetivoMs > ahora.millisecondsSinceEpoch
      ? DateTime.fromMillisecondsSinceEpoch(fechaObjetivoMs)
      : ahora;
  return DateTime(base.year, base.month, base.day + dias, base.hour,
      base.minute, base.second, base.millisecond);
}
