// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/arbolado-urbano/tareas_calendario.csv
// Generado: 2026-11-07
// Filas: 23 (0 revisadas, 23 pendientes de revisión)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR POR INGENIERO TÉCNICO FORESTAL.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-arbolado-urbano && dart run tool/compilar_catalogos.dart

/// Zona climática orientativa peninsular.
/// Norte = Galicia/Cantábrica/Vasconia/Pirineos/Norte Castilla.
/// Centro = Mesetas/Sistema Central.
/// Sur = Andalucía/Extremadura/Murcia/Levante.
enum ZonaClimaticaArbolado { norte, centro, sur }

class TareaCalendarioArbolado {
  final ZonaClimaticaArbolado zona;
  final String tareaId;
  final String nombreVisible;
  final int mes;
  /// 1 = días 1-10, 2 = días 11-20, 3 = días 21-fin.
  final int decada;
  final String notas;

  const TareaCalendarioArbolado({
    required this.zona,
    required this.tareaId,
    required this.nombreVisible,
    required this.mes,
    required this.decada,
    this.notas = '',
  });
}

const List<TareaCalendarioArbolado> calendarioArbolado = [
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.norte,
    tareaId: 'inspeccion_anual_vta',
    nombreVisible: 'Inspección VTA anual',
    mes: 3,
    decada: 3,
    notas: 'Tras los temporales de invierno — antes de la foliación',
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.norte,
    tareaId: 'poda_savia_parada',
    nombreVisible: 'Poda en savia parada',
    mes: 12,
    decada: 2,
    notas: 'De diciembre a febrero — fuera de heladas fuertes',
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.norte,
    tareaId: 'tratamiento_procesionaria_otono',
    nombreVisible: 'Tratamiento procesionaria otoño',
    mes: 9,
    decada: 3,
    notas: 'Antes de que las orugas formen bolsones invernales',
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.norte,
    tareaId: 'destruccion_bolsones',
    nombreVisible: 'Destrucción manual de bolsones',
    mes: 1,
    decada: 2,
    notas: 'Bolsones bien visibles con árbol desnudo',
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.norte,
    tareaId: 'tratamiento_anthracnosis',
    nombreVisible: 'Tratamiento preventivo anthracnosis',
    mes: 4,
    decada: 1,
    notas: 'Antes de la foliación primaveral',
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.norte,
    tareaId: 'riego_estival_jovenes',
    nombreVisible: 'Riego estival árboles jóvenes',
    mes: 7,
    decada: 1,
    notas: 'Cada 7-10 días en olas de calor',
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.norte,
    tareaId: 'retirada_hoja_seca',
    nombreVisible: 'Retirada de hoja seca',
    mes: 11,
    decada: 1,
    notas: 'Tras la caída masiva',
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.centro,
    tareaId: 'inspeccion_anual_vta',
    nombreVisible: 'Inspección VTA anual',
    mes: 3,
    decada: 2,
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.centro,
    tareaId: 'poda_savia_parada',
    nombreVisible: 'Poda en savia parada',
    mes: 12,
    decada: 1,
    notas: 'De diciembre a febrero',
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.centro,
    tareaId: 'tratamiento_procesionaria_otono',
    nombreVisible: 'Tratamiento procesionaria otoño',
    mes: 10,
    decada: 1,
    notas: 'Frecuente en pinos de parques periurbanos de la meseta',
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.centro,
    tareaId: 'destruccion_bolsones',
    nombreVisible: 'Destrucción manual de bolsones',
    mes: 1,
    decada: 3,
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.centro,
    tareaId: 'tratamiento_anthracnosis',
    nombreVisible: 'Tratamiento preventivo anthracnosis',
    mes: 3,
    decada: 3,
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.centro,
    tareaId: 'riego_estival_jovenes',
    nombreVisible: 'Riego estival árboles jóvenes',
    mes: 6,
    decada: 3,
    notas: 'Más crítico que en el norte — verano largo y seco',
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.centro,
    tareaId: 'retirada_hoja_seca',
    nombreVisible: 'Retirada de hoja seca',
    mes: 11,
    decada: 2,
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.centro,
    tareaId: 'destruccion_masas_huevos_lagarta',
    nombreVisible: 'Destrucción masas huevos lagarta',
    mes: 1,
    decada: 2,
    notas: 'En encinas y olmos de parques',
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.sur,
    tareaId: 'inspeccion_anual_vta',
    nombreVisible: 'Inspección VTA anual',
    mes: 2,
    decada: 2,
    notas: 'Climas mediterráneos — VTA antes de la primavera temprana',
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.sur,
    tareaId: 'poda_savia_parada',
    nombreVisible: 'Poda en savia parada',
    mes: 12,
    decada: 1,
    notas: 'Diciembre-enero — savia parada breve en climas suaves',
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.sur,
    tareaId: 'tratamiento_procesionaria_otono',
    nombreVisible: 'Tratamiento procesionaria otoño',
    mes: 10,
    decada: 2,
    notas: 'En pinos de parques litorales y serranos',
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.sur,
    tareaId: 'destruccion_bolsones',
    nombreVisible: 'Destrucción manual de bolsones',
    mes: 2,
    decada: 1,
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.sur,
    tareaId: 'trampeo_picudo_palmeras',
    nombreVisible: 'Trampeo picudo de palmeras',
    mes: 3,
    decada: 1,
    notas: 'Trampeo masivo en zonas con palmeras infectadas — todo el año en focos activos',
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.sur,
    tareaId: 'tratamiento_anthracnosis',
    nombreVisible: 'Tratamiento preventivo anthracnosis',
    mes: 3,
    decada: 1,
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.sur,
    tareaId: 'riego_estival_jovenes',
    nombreVisible: 'Riego estival árboles jóvenes',
    mes: 5,
    decada: 3,
    notas: 'Verano largo — riego de mayo a septiembre',
  ),
  TareaCalendarioArbolado(
    zona: ZonaClimaticaArbolado.sur,
    tareaId: 'retirada_hoja_seca',
    nombreVisible: 'Retirada de hoja seca',
    mes: 11,
    decada: 2,
  ),
];

/// Tareas de una zona ordenadas por fecha (mes/década).
List<TareaCalendarioArbolado> tareasDeZona(ZonaClimaticaArbolado zona) {
  final filtradas = calendarioArbolado.where((t) => t.zona == zona).toList();
  filtradas.sort((a, b) {
    final cmpMes = a.mes.compareTo(b.mes);
    if (cmpMes != 0) return cmpMes;
    return a.decada.compareTo(b.decada);
  });
  return filtradas;
}

/// Tareas próximas para una zona y fecha — útil para "qué toca esta semana".
List<TareaCalendarioArbolado> tareasProximas({
  required ZonaClimaticaArbolado zona,
  required DateTime fecha,
  int limite = 3,
}) {
  final tareas = tareasDeZona(zona);
  if (tareas.isEmpty) return const [];
  final decadaActual = (fecha.day - 1) ~/ 10 + 1;
  final claveActual = fecha.month * 10 + decadaActual.clamp(1, 3);
  final futuras = tareas
      .where((t) => t.mes * 10 + t.decada >= claveActual)
      .toList();
  if (futuras.length >= limite) return futuras.take(limite).toList();
  final restantes = limite - futuras.length;
  return [...futuras, ...tareas.take(restantes)];
}
