import 'package:nuevo_ser_avisos/nuevo_ser_avisos.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../dominio/planificador_hornada.dart';
import '../modelos/masa_madre.dart';
import '../modelos/plan_hornada.dart';
import '../utiles/textos_obrador.dart';

/// Avisos del obrador (nuevo_ser_avisos). Sustituible en los tests por un
/// [ServicioAvisosEnMemoria].
ServicioAvisos avisosObrador = ServicioAvisosLocales(ConfiguracionAvisos(
  idCanal: 'obrador_avisos',
  nombreCanal: SoleraL10n.t('avisos.canal_nombre'),
));

/// Programa un aviso al empezar cada fase que falte del [plan] (quita antes
/// los que hubiera). Devuelve cuántos ha programado: 0 si no hay permiso,
/// y la app sigue enseñando las horas en pantalla.
Future<int> programarAvisosPlan(PlanHornada plan,
    {ServicioAvisos? servicio}) async {
  final avisos = servicio ?? avisosObrador;
  final planId = plan.id!;
  await avisos.cancelarGrupo(prefijoAvisosPlan(planId));
  var programados = 0;
  for (final (indice, fase) in plan.fases.indexed) {
    if (fase.hecha) continue;
    final programado = await avisos.programar(
      clave: claveAvisoFase(planId, indice),
      cuando: fase.inicio,
      titulo: '${nombreFaseHornada(fase.fase)} · ${plan.nombre}',
      cuerpo: SoleraL10n.tf('obra.plan_aviso_cuerpo',
          {'duracion': formatearDuracion(fase.duracion)}),
    );
    if (programado) programados++;
  }
  return programados;
}

Future<void> quitarAvisosPlan(int planId, {ServicioAvisos? servicio}) =>
    (servicio ?? avisosObrador).cancelarGrupo(prefijoAvisosPlan(planId));

/// Recordatorio de refresco de [masa] según su `recordatorioHoras` (lo quita
/// si es null). Devuelve la hora programada, o null si no se ha podido.
Future<DateTime?> programarRecordatorioRefresco(
    MasaMadre masa, DateTime? ultimoRefresco,
    {ServicioAvisos? servicio, DateTime? ahora}) async {
  final avisos = servicio ?? avisosObrador;
  final clave = claveAvisoRefresco(masa.id!);
  await avisos.cancelar(clave);
  final cadaHoras = masa.recordatorioHoras;
  if (cadaHoras == null || cadaHoras <= 0) return null;
  final cuando = proximoRefresco(
      ultimoRefresco: ultimoRefresco,
      cadaHoras: cadaHoras,
      ahora: ahora ?? DateTime.now());
  final programado = await avisos.programar(
    clave: clave,
    cuando: cuando,
    titulo: SoleraL10n.tf('obra.plan_aviso_refresco', {'nombre': masa.nombre}),
    cuerpo: SoleraL10n.t('obra.plan_aviso_refresco_cuerpo'),
  );
  return programado ? cuando : null;
}
