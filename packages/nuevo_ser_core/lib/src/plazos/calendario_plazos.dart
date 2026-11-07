/// Cálculo de fechas sobre [PlazoLegal]: próxima ocurrencia, avisos del
/// día y filtro por vertical. Todo trabaja con días naturales sin hora
/// (la hora de la fecha recibida se ignora).
library;

import 'plazo_legal.dart';

/// Devuelve la ocurrencia vigente o la siguiente del [plazo] para la
/// [fecha]: la primera cuyo día límite es igual o posterior a [fecha].
/// El propio día límite cuenta como vigente.
OcurrenciaPlazo proximaOcurrencia(PlazoLegal plazo, DateTime fecha) {
  final dia = _soloDia(fecha);
  return switch (plazo.periodicidad) {
    final PeriodicidadAnual anual => _proximaAnual(anual, dia),
    final PeriodicidadMensual mensual => _proximaMensual(mensual, dia),
    final PeriodicidadTrimestral trimestral =>
      _proximaTrimestral(trimestral, dia),
  };
}

/// Plazos de [plazos] cuya próxima ocurrencia vence dentro de su
/// antelación de aviso contando desde [fecha] (incluido el propio día
/// límite). Ordenados por día límite más cercano; a igualdad, en el
/// orden de [plazos].
List<AvisoPlazo> plazosQueAvisanHoy(List<PlazoLegal> plazos, DateTime fecha) {
  final dia = _soloDia(fecha);
  final avisosConPosicion = <({AvisoPlazo aviso, int posicion})>[];
  for (var posicion = 0; posicion < plazos.length; posicion++) {
    final plazo = plazos[posicion];
    final ocurrencia = proximaOcurrencia(plazo, dia);
    final diasRestantes = _diasEntre(dia, ocurrencia.fin);
    if (diasRestantes <= plazo.antelacionAvisoDias) {
      avisosConPosicion.add((
        aviso: AvisoPlazo(
          plazo: plazo,
          ocurrencia: ocurrencia,
          diasRestantes: diasRestantes,
        ),
        posicion: posicion,
      ));
    }
  }
  // `sort` de Dart no es estable: desempatamos por posición original.
  avisosConPosicion.sort((primero, segundo) {
    final porDias =
        primero.aviso.diasRestantes.compareTo(segundo.aviso.diasRestantes);
    return porDias != 0
        ? porDias
        : primero.posicion.compareTo(segundo.posicion);
  });
  return [for (final elemento in avisosConPosicion) elemento.aviso];
}

/// Plazos de [plazos] que aplican a [vertical] (sin distinguir
/// mayúsculas), en su orden original. Una vertical desconocida devuelve
/// lista vacía.
List<PlazoLegal> plazosDeVertical(List<PlazoLegal> plazos, String vertical) {
  return [
    for (final plazo in plazos)
      if (plazo.aplicaA(vertical)) plazo,
  ];
}

/// Fecha del [dia] del [mes] de [anio], ajustando al último día del mes
/// si no existe (31 de abril → 30; 29 de febrero no bisiesto → 28).
DateTime fechaAjustadaAlMes(int anio, int mes, int dia) {
  final ultimoDiaDelMes = DateTime(anio, mes + 1, 0).day;
  return DateTime(anio, mes, dia > ultimoDiaDelMes ? ultimoDiaDelMes : dia);
}

OcurrenciaPlazo _proximaAnual(PeriodicidadAnual anual, DateTime dia) {
  // La ocurrencia que empezó el año anterior puede seguir abierta si la
  // ventana cruza el fin de año; probamos desde ahí hacia delante.
  for (var anioInicio = dia.year - 1;; anioInicio++) {
    final anioFin = anual.cruzaFinDeAnio ? anioInicio + 1 : anioInicio;
    final ocurrencia = OcurrenciaPlazo(
      inicio: fechaAjustadaAlMes(anioInicio, anual.mesInicio, anual.diaInicio),
      fin: fechaAjustadaAlMes(anioFin, anual.mesFin, anual.diaFin),
    );
    if (!ocurrencia.fin.isBefore(dia)) return ocurrencia;
  }
}

OcurrenciaPlazo _proximaMensual(PeriodicidadMensual mensual, DateTime dia) {
  var ocurrencia = _ocurrenciaDelMes(dia.year, dia.month, mensual.diaLimite);
  if (ocurrencia.fin.isBefore(dia)) {
    ocurrencia = _ocurrenciaDelMes(dia.year, dia.month + 1, mensual.diaLimite);
  }
  return ocurrencia;
}

/// Meses de presentación de los trimestres naturales: enero (4T del año
/// anterior), abril (1T), julio (2T) y octubre (3T).
const _mesesDePresentacionTrimestral = [1, 4, 7, 10];

OcurrenciaPlazo _proximaTrimestral(
    PeriodicidadTrimestral trimestral, DateTime dia) {
  for (var anio = dia.year;; anio++) {
    for (final mes in _mesesDePresentacionTrimestral) {
      final diaLimite = mes == 1
          ? trimestral.diaLimiteCuartoTrimestre ?? trimestral.diaLimite
          : trimestral.diaLimite;
      final ocurrencia = _ocurrenciaDelMes(anio, mes, diaLimite);
      if (!ocurrencia.fin.isBefore(dia)) return ocurrencia;
    }
  }
}

/// Ocurrencia del día 1 al [diaLimite] del [mes] de [anio]. Admite
/// `mes == 13` (enero del año siguiente), como `DateTime`.
OcurrenciaPlazo _ocurrenciaDelMes(int anio, int mes, int diaLimite) {
  final primeroDeMes = DateTime(anio, mes, 1);
  return OcurrenciaPlazo(
    inicio: primeroDeMes,
    fin: fechaAjustadaAlMes(primeroDeMes.year, primeroDeMes.month, diaLimite),
  );
}

DateTime _soloDia(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, fecha.day);

/// Días naturales de [desde] a [hasta]. Calculado en UTC para que un
/// cambio de hora no deje la diferencia en 23 o 25 horas.
int _diasEntre(DateTime desde, DateTime hasta) {
  final desdeUtc = DateTime.utc(desde.year, desde.month, desde.day);
  final hastaUtc = DateTime.utc(hasta.year, hasta.month, hasta.day);
  return hastaUtc.difference(desdeUtc).inDays;
}
