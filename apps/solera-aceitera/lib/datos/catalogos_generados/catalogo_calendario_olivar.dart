// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/aceitera/calendario_olivar.csv
// Generado: 2026-11-07
// Filas: 40 (0 firmadas por persona, 40 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR AGRONÓMICAMENTE.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-aceitera && dart run tool/compilar_catalogos.dart

/// Zonas productivas olivareras de la península e islas.
enum ZonaOlivar {
  andaluciaOccidental,
  andaluciaOriental,
  extremadura,
  castillaLaMancha,
  levante,
  nordeste,
  mesetaNorte,
}

class EventoCalendarioOlivar {
  final ZonaOlivar zona;
  final String evento;
  final String nombreEvento;
  /// Meses 1-12 (mes inicial habitual).
  final int mesInicioAprox;
  /// Meses 1-12 (mes final habitual). Si fin < inicio, cruza el año.
  final int mesFinAprox;
  final String notas;

  const EventoCalendarioOlivar({
    required this.zona,
    required this.evento,
    required this.nombreEvento,
    required this.mesInicioAprox,
    required this.mesFinAprox,
    this.notas = '',
  });
}

const List<EventoCalendarioOlivar> calendarioOlivar = [
  EventoCalendarioOlivar(
    zona: ZonaOlivar.andaluciaOccidental,
    evento: 'poda_invierno',
    nombreEvento: 'Poda de invierno',
    mesInicioAprox: 1,
    mesFinAprox: 3,
    notas: 'Poda principal del año en árboles adultos.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.andaluciaOccidental,
    evento: 'abonado_primaveral',
    nombreEvento: 'Abonado primaveral',
    mesInicioAprox: 2,
    mesFinAprox: 4,
    notas: 'Aporte previo al despertar vegetativo.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.andaluciaOccidental,
    evento: 'floracion',
    nombreEvento: 'Floración',
    mesInicioAprox: 4,
    mesFinAprox: 5,
    notas: 'Ventana habitual de floración.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.andaluciaOccidental,
    evento: 'fruto_cuajado',
    nombreEvento: 'Cuajado del fruto',
    mesInicioAprox: 5,
    mesFinAprox: 6,
    notas: 'Caída fisiológica de junio (mayo en zonas tempranas).',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.andaluciaOccidental,
    evento: 'endurecimiento_hueso',
    nombreEvento: 'Endurecimiento del hueso',
    mesInicioAprox: 7,
    mesFinAprox: 8,
    notas: 'Fase crítica para riego deficitario.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.andaluciaOccidental,
    evento: 'envero',
    nombreEvento: 'Envero',
    mesInicioAprox: 9,
    mesFinAprox: 10,
    notas: 'Cambio de color verde a morado.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.andaluciaOccidental,
    evento: 'recoleccion_temprana',
    nombreEvento: 'Recolección temprana (verde)',
    mesInicioAprox: 10,
    mesFinAprox: 11,
    notas: 'Aceites tempranos de gran intensidad.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.andaluciaOccidental,
    evento: 'recoleccion_principal',
    nombreEvento: 'Recolección principal',
    mesInicioAprox: 11,
    mesFinAprox: 1,
    notas: 'Campaña principal de almazara.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.andaluciaOriental,
    evento: 'poda_invierno',
    nombreEvento: 'Poda de invierno',
    mesInicioAprox: 1,
    mesFinAprox: 3,
    notas: 'Poda principal en árboles adultos.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.andaluciaOriental,
    evento: 'abonado_primaveral',
    nombreEvento: 'Abonado primaveral',
    mesInicioAprox: 2,
    mesFinAprox: 4,
    notas: 'Aporte previo al despertar vegetativo.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.andaluciaOriental,
    evento: 'floracion',
    nombreEvento: 'Floración',
    mesInicioAprox: 4,
    mesFinAprox: 5,
    notas: 'Floración ligeramente más tardía que occidental.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.andaluciaOriental,
    evento: 'fruto_cuajado',
    nombreEvento: 'Cuajado del fruto',
    mesInicioAprox: 5,
    mesFinAprox: 6,
    notas: 'Caída fisiológica de junio.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.andaluciaOriental,
    evento: 'endurecimiento_hueso',
    nombreEvento: 'Endurecimiento del hueso',
    mesInicioAprox: 7,
    mesFinAprox: 9,
    notas: 'Fase crítica para riego deficitario.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.andaluciaOriental,
    evento: 'envero',
    nombreEvento: 'Envero',
    mesInicioAprox: 10,
    mesFinAprox: 11,
    notas: 'Cambio de color tardío por altura/microclima.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.andaluciaOriental,
    evento: 'recoleccion_temprana',
    nombreEvento: 'Recolección temprana (verde)',
    mesInicioAprox: 10,
    mesFinAprox: 11,
    notas: 'Aceites de altura tempranos.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.andaluciaOriental,
    evento: 'recoleccion_principal',
    nombreEvento: 'Recolección principal',
    mesInicioAprox: 11,
    mesFinAprox: 2,
    notas: 'Campaña principal de almazara.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.extremadura,
    evento: 'poda_invierno',
    nombreEvento: 'Poda de invierno',
    mesInicioAprox: 1,
    mesFinAprox: 3,
    notas: 'Poda en árboles adultos.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.extremadura,
    evento: 'abonado_primaveral',
    nombreEvento: 'Abonado primaveral',
    mesInicioAprox: 2,
    mesFinAprox: 4,
    notas: 'Aporte previo al despertar.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.extremadura,
    evento: 'floracion',
    nombreEvento: 'Floración',
    mesInicioAprox: 4,
    mesFinAprox: 5,
    notas: 'Ventana habitual de floración.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.extremadura,
    evento: 'fruto_cuajado',
    nombreEvento: 'Cuajado del fruto',
    mesInicioAprox: 5,
    mesFinAprox: 6,
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.extremadura,
    evento: 'envero',
    nombreEvento: 'Envero',
    mesInicioAprox: 9,
    mesFinAprox: 10,
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.extremadura,
    evento: 'recoleccion_principal',
    nombreEvento: 'Recolección principal',
    mesInicioAprox: 10,
    mesFinAprox: 12,
    notas: 'Adelanto significativo para variedades de mesa.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.castillaLaMancha,
    evento: 'poda_invierno',
    nombreEvento: 'Poda de invierno',
    mesInicioAprox: 1,
    mesFinAprox: 3,
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.castillaLaMancha,
    evento: 'abonado_primaveral',
    nombreEvento: 'Abonado primaveral',
    mesInicioAprox: 3,
    mesFinAprox: 4,
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.castillaLaMancha,
    evento: 'floracion',
    nombreEvento: 'Floración',
    mesInicioAprox: 5,
    mesFinAprox: 5,
    notas: 'Floración tardía respecto a Andalucía.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.castillaLaMancha,
    evento: 'fruto_cuajado',
    nombreEvento: 'Cuajado del fruto',
    mesInicioAprox: 6,
    mesFinAprox: 6,
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.castillaLaMancha,
    evento: 'envero',
    nombreEvento: 'Envero',
    mesInicioAprox: 10,
    mesFinAprox: 11,
    notas: 'Envero tardío.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.castillaLaMancha,
    evento: 'recoleccion_principal',
    nombreEvento: 'Recolección principal',
    mesInicioAprox: 11,
    mesFinAprox: 1,
    notas: 'Campaña típica cornicabra.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.levante,
    evento: 'poda_invierno',
    nombreEvento: 'Poda de invierno',
    mesInicioAprox: 2,
    mesFinAprox: 3,
    notas: 'Poda algo más tardía por inviernos suaves.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.levante,
    evento: 'floracion',
    nombreEvento: 'Floración',
    mesInicioAprox: 4,
    mesFinAprox: 5,
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.levante,
    evento: 'envero',
    nombreEvento: 'Envero',
    mesInicioAprox: 10,
    mesFinAprox: 11,
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.levante,
    evento: 'recoleccion_principal',
    nombreEvento: 'Recolección principal',
    mesInicioAprox: 11,
    mesFinAprox: 1,
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.nordeste,
    evento: 'poda_invierno',
    nombreEvento: 'Poda de invierno',
    mesInicioAprox: 2,
    mesFinAprox: 3,
    notas: 'Poda en árboles adultos.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.nordeste,
    evento: 'floracion',
    nombreEvento: 'Floración',
    mesInicioAprox: 5,
    mesFinAprox: 5,
    notas: 'Floración tardía respecto a Andalucía.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.nordeste,
    evento: 'envero',
    nombreEvento: 'Envero',
    mesInicioAprox: 10,
    mesFinAprox: 11,
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.nordeste,
    evento: 'recoleccion_principal',
    nombreEvento: 'Recolección principal',
    mesInicioAprox: 11,
    mesFinAprox: 1,
    notas: 'Campaña típica arbequina.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.mesetaNorte,
    evento: 'poda_invierno',
    nombreEvento: 'Poda de invierno',
    mesInicioAprox: 2,
    mesFinAprox: 3,
    notas: 'Poda tras evitar heladas tardías.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.mesetaNorte,
    evento: 'floracion',
    nombreEvento: 'Floración',
    mesInicioAprox: 5,
    mesFinAprox: 6,
    notas: 'Floración tardía.',
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.mesetaNorte,
    evento: 'envero',
    nombreEvento: 'Envero',
    mesInicioAprox: 10,
    mesFinAprox: 11,
  ),
  EventoCalendarioOlivar(
    zona: ZonaOlivar.mesetaNorte,
    evento: 'recoleccion_principal',
    nombreEvento: 'Recolección principal',
    mesInicioAprox: 11,
    mesFinAprox: 12,
    notas: 'Variedades arróniz / cornicabra del norte peninsular.',
  ),
];

/// Eventos del calendario para una zona, en orden de inicio.
List<EventoCalendarioOlivar> calendarioDeZona(ZonaOlivar zona) {
  final filtrados = calendarioOlivar
      .where((e) => e.zona == zona)
      .toList();
  filtrados.sort((a, b) => a.mesInicioAprox.compareTo(b.mesInicioAprox));
  return filtrados;
}

/// Devuelve los eventos activos en un mes concreto (1-12).
/// Si `mesFin < mesInicio` el evento cruza el año (recolección
/// principal típicamente noviembre-enero).
List<EventoCalendarioOlivar> eventosActivosEn({
  required ZonaOlivar zona,
  required int mes,
}) {
  return calendarioDeZona(zona).where((e) {
    if (e.mesInicioAprox <= e.mesFinAprox) {
      return mes >= e.mesInicioAprox && mes <= e.mesFinAprox;
    }
    return mes >= e.mesInicioAprox || mes <= e.mesFinAprox;
  }).toList();
}
