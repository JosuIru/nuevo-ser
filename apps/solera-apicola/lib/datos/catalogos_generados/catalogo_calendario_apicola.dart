// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/apicola/calendario_apicola.csv
// Generado: 2026-11-07
// Filas: 36 (0 revisadas, 36 pendientes de revisión)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR POR VETERINARIO APÍCOLA NI APICULTOR ASESOR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-apicola && dart run tool/compilar_catalogos.dart

/// Zona climática orientativa peninsular.
/// Norte = Galicia/Cantábrica/Vasconia/Pirineos/Norte Castilla.
/// Centro = Mesetas/Sistema Central.
/// Sur = Andalucía/Extremadura/Murcia/Levante.
enum ZonaClimaticaApicola { norte, centro, sur }

/// Tarea estandarizada del calendario apícola.
class TareaCalendarioApicola {
  final ZonaClimaticaApicola zona;
  final String tareaId;
  final String nombreVisible;
  final int mes;
  /// 1 = días 1-10, 2 = días 11-20, 3 = días 21-fin.
  final int decada;
  final String notas;

  const TareaCalendarioApicola({
    required this.zona,
    required this.tareaId,
    required this.nombreVisible,
    required this.mes,
    required this.decada,
    this.notas = '',
  });
}

const List<TareaCalendarioApicola> calendarioApicola = [
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.norte,
    tareaId: 'revision_primaveral',
    nombreVisible: 'Revisión primaveral',
    mes: 3,
    decada: 3,
    notas: 'Tras frío atlántico — esperar estabilización de temperatura',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.norte,
    tareaId: 'estimulacion_postura',
    nombreVisible: 'Estímulo de postura',
    mes: 4,
    decada: 1,
    notas: 'Si reservas escasas — jarabe ligero',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.norte,
    tareaId: 'division_enjambre',
    nombreVisible: 'Divisiones / núcleos',
    mes: 5,
    decada: 1,
    notas: 'Antes de la fiebre de enjambrazón natural',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.norte,
    tareaId: 'trashumancia_mielada',
    nombreVisible: 'Trashumancia a brezo o castaño',
    mes: 6,
    decada: 2,
    notas: 'Castaño y brezo en zona atlántica',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.norte,
    tareaId: 'colocacion_alza',
    nombreVisible: 'Colocación de alzas',
    mes: 5,
    decada: 3,
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.norte,
    tareaId: 'cosecha_principal',
    nombreVisible: 'Cosecha principal',
    mes: 7,
    decada: 3,
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.norte,
    tareaId: 'tratamiento_varroa_verano',
    nombreVisible: 'Tratamiento varroa verano',
    mes: 8,
    decada: 1,
    notas: 'Fórmico o aceite esencial — cría presente',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.norte,
    tareaId: 'ultima_cosecha',
    nombreVisible: 'Cosecha tardía (brezo otoñal)',
    mes: 9,
    decada: 3,
    notas: 'Solo si hay brezo — variable por comarca',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.norte,
    tareaId: 'tratamiento_varroa_otono',
    nombreVisible: 'Tratamiento varroa otoño',
    mes: 10,
    decada: 1,
    notas: 'Plazo retirada respetado antes de invernada',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.norte,
    tareaId: 'alimentacion_invernal',
    nombreVisible: 'Alimentación invernal',
    mes: 10,
    decada: 3,
    notas: 'Pesar previa — reservas mínimo 12 kg',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.norte,
    tareaId: 'tratamiento_oxalico_invernada',
    nombreVisible: 'Oxálico sublimado en sin-postura',
    mes: 12,
    decada: 3,
    notas: 'Punto sin cría operculada — ventana corta',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.norte,
    tareaId: 'revision_invernada',
    nombreVisible: 'Revisión externa de invernada',
    mes: 1,
    decada: 2,
    notas: 'Sin abrir — solo escuchar y observar piquera',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.centro,
    tareaId: 'revision_primaveral',
    nombreVisible: 'Revisión primaveral',
    mes: 3,
    decada: 1,
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.centro,
    tareaId: 'estimulacion_postura',
    nombreVisible: 'Estímulo de postura',
    mes: 3,
    decada: 2,
    notas: 'Antes que en el norte — clima continental se calienta más rápido',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.centro,
    tareaId: 'division_enjambre',
    nombreVisible: 'Divisiones / núcleos',
    mes: 4,
    decada: 2,
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.centro,
    tareaId: 'trashumancia_mielada',
    nombreVisible: 'Trashumancia a romero / encina',
    mes: 5,
    decada: 1,
    notas: 'Mielada de romero precoz en interior',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.centro,
    tareaId: 'colocacion_alza',
    nombreVisible: 'Colocación de alzas',
    mes: 4,
    decada: 3,
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.centro,
    tareaId: 'cosecha_principal',
    nombreVisible: 'Cosecha principal',
    mes: 6,
    decada: 3,
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.centro,
    tareaId: 'tratamiento_varroa_verano',
    nombreVisible: 'Tratamiento varroa verano',
    mes: 7,
    decada: 2,
    notas: 'Verano seco — cuidar temperatura del fórmico (>30°C ineficaz)',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.centro,
    tareaId: 'ultima_cosecha',
    nombreVisible: 'Cosecha tardía (espliego/girasol)',
    mes: 8,
    decada: 3,
    notas: 'Solo si hay segunda mielada',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.centro,
    tareaId: 'tratamiento_varroa_otono',
    nombreVisible: 'Tratamiento varroa otoño',
    mes: 9,
    decada: 3,
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.centro,
    tareaId: 'alimentacion_invernal',
    nombreVisible: 'Alimentación invernal',
    mes: 10,
    decada: 2,
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.centro,
    tareaId: 'tratamiento_oxalico_invernada',
    nombreVisible: 'Oxálico sublimado en sin-postura',
    mes: 12,
    decada: 2,
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.centro,
    tareaId: 'revision_invernada',
    nombreVisible: 'Revisión externa de invernada',
    mes: 1,
    decada: 3,
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.sur,
    tareaId: 'revision_primaveral',
    nombreVisible: 'Revisión primaveral',
    mes: 2,
    decada: 2,
    notas: 'Climas mediterráneos — primaveras tempranas',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.sur,
    tareaId: 'estimulacion_postura',
    nombreVisible: 'Estímulo de postura',
    mes: 2,
    decada: 3,
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.sur,
    tareaId: 'division_enjambre',
    nombreVisible: 'Divisiones / núcleos',
    mes: 3,
    decada: 2,
    notas: 'Riesgo de enjambrazón muy temprano',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.sur,
    tareaId: 'trashumancia_mielada',
    nombreVisible: 'Trashumancia a azahar / romero',
    mes: 3,
    decada: 3,
    notas: 'Azahar en Levante y Andalucía',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.sur,
    tareaId: 'colocacion_alza',
    nombreVisible: 'Colocación de alzas',
    mes: 3,
    decada: 2,
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.sur,
    tareaId: 'cosecha_principal',
    nombreVisible: 'Cosecha principal de azahar',
    mes: 5,
    decada: 2,
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.sur,
    tareaId: 'tratamiento_varroa_verano',
    nombreVisible: 'Tratamiento varroa verano',
    mes: 7,
    decada: 1,
    notas: 'Cuidar temperatura — verano andaluz seca y muy caliente',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.sur,
    tareaId: 'ultima_cosecha',
    nombreVisible: 'Cosecha tardía (girasol/algarrobo)',
    mes: 8,
    decada: 2,
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.sur,
    tareaId: 'tratamiento_varroa_otono',
    nombreVisible: 'Tratamiento varroa otoño',
    mes: 9,
    decada: 2,
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.sur,
    tareaId: 'alimentacion_invernal',
    nombreVisible: 'Alimentación invernal',
    mes: 11,
    decada: 1,
    notas: 'Invernada corta — reservas más livianas',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.sur,
    tareaId: 'tratamiento_oxalico_invernada',
    nombreVisible: 'Oxálico sublimado en sin-postura',
    mes: 1,
    decada: 1,
    notas: 'Climas suaves: la sin-postura es muy breve y a veces inexistente',
  ),
  TareaCalendarioApicola(
    zona: ZonaClimaticaApicola.sur,
    tareaId: 'revision_invernada',
    nombreVisible: 'Revisión externa de invernada',
    mes: 12,
    decada: 3,
  ),
];

/// Tareas de una zona ordenadas por fecha (mes/década).
List<TareaCalendarioApicola> tareasDeZona(ZonaClimaticaApicola zona) {
  final filtradas = calendarioApicola.where((t) => t.zona == zona).toList();
  filtradas.sort((a, b) {
    final cmpMes = a.mes.compareTo(b.mes);
    if (cmpMes != 0) return cmpMes;
    return a.decada.compareTo(b.decada);
  });
  return filtradas;
}

/// Tareas próximas para una zona y fecha — útil para "qué toca esta semana".
/// Devuelve hasta `limite` tareas con clave (mes×10+decada) >= clave actual.
List<TareaCalendarioApicola> tareasProximas({
  required ZonaClimaticaApicola zona,
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
  // Si no llegan a `limite` futuras, completar con las del año siguiente.
  final restantes = limite - futuras.length;
  return [...futuras, ...tareas.take(restantes)];
}
