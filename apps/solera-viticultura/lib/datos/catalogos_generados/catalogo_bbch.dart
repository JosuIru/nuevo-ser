// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/viticultura/calendario_bbch.csv
// Generado: 2026-11-07
// Filas: 72 (0 revisadas, 72 pendientes de revisión)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR AGRONÓMICA/ENOLÓGICAMENTE.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-viticultura && dart run tool/compilar_catalogos.dart

/// Zona climática orientativa. Norte = Galicia/Cantábrica/Rioja Alta/
/// Norte de Castilla. Sur = La Mancha/Andalucía/Extremadura/Levante.
enum ZonaClimaticaVid { norte, sur }

/// Estado fenológico BBCH para vid (FAO 1995). El ciclo completo abarca
/// del 00 al 99; aquí guardamos los 9 estados principales que el
/// viticultor reconoce con el ojo.
class EstadoFenologicoBbch {
  final String variedadId;
  final ZonaClimaticaVid zona;
  final int estadoBbch;
  final String nombreEstado;
  final int mes;
  /// 1 = días 1-10, 2 = días 11-20, 3 = días 21-fin de mes.
  final int decada;

  const EstadoFenologicoBbch({
    required this.variedadId,
    required this.zona,
    required this.estadoBbch,
    required this.nombreEstado,
    required this.mes,
    required this.decada,
  });
}

const List<EstadoFenologicoBbch> calendarioFenologicoBbch = [
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 9,
    nombreEstado: 'Brotación',
    mes: 4,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 15,
    nombreEstado: '5 hojas',
    mes: 4,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 53,
    nombreEstado: 'Inflorescencia visible',
    mes: 5,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 65,
    nombreEstado: 'Plena floración',
    mes: 6,
    decada: 2,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 71,
    nombreEstado: 'Cuajado',
    mes: 6,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 75,
    nombreEstado: 'Tamaño guisante',
    mes: 7,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 81,
    nombreEstado: 'Inicio envero',
    mes: 8,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 89,
    nombreEstado: 'Vendimia',
    mes: 10,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 93,
    nombreEstado: 'Caída de hojas',
    mes: 11,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 9,
    nombreEstado: 'Brotación',
    mes: 3,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 15,
    nombreEstado: '5 hojas',
    mes: 4,
    decada: 2,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 53,
    nombreEstado: 'Inflorescencia visible',
    mes: 5,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 65,
    nombreEstado: 'Plena floración',
    mes: 5,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 71,
    nombreEstado: 'Cuajado',
    mes: 6,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 75,
    nombreEstado: 'Tamaño guisante',
    mes: 6,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 81,
    nombreEstado: 'Inicio envero',
    mes: 7,
    decada: 2,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 89,
    nombreEstado: 'Vendimia',
    mes: 9,
    decada: 2,
  ),
  EstadoFenologicoBbch(
    variedadId: 'tempranillo',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 93,
    nombreEstado: 'Caída de hojas',
    mes: 10,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 9,
    nombreEstado: 'Brotación',
    mes: 4,
    decada: 2,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 15,
    nombreEstado: '5 hojas',
    mes: 5,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 53,
    nombreEstado: 'Inflorescencia visible',
    mes: 5,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 65,
    nombreEstado: 'Plena floración',
    mes: 6,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 71,
    nombreEstado: 'Cuajado',
    mes: 7,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 75,
    nombreEstado: 'Tamaño guisante',
    mes: 7,
    decada: 2,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 81,
    nombreEstado: 'Inicio envero',
    mes: 8,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 89,
    nombreEstado: 'Vendimia',
    mes: 10,
    decada: 2,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 93,
    nombreEstado: 'Caída de hojas',
    mes: 11,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 9,
    nombreEstado: 'Brotación',
    mes: 4,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 15,
    nombreEstado: '5 hojas',
    mes: 4,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 53,
    nombreEstado: 'Inflorescencia visible',
    mes: 5,
    decada: 2,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 65,
    nombreEstado: 'Plena floración',
    mes: 6,
    decada: 2,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 71,
    nombreEstado: 'Cuajado',
    mes: 6,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 75,
    nombreEstado: 'Tamaño guisante',
    mes: 7,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 81,
    nombreEstado: 'Inicio envero',
    mes: 7,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 89,
    nombreEstado: 'Vendimia',
    mes: 9,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'garnacha_tinta',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 93,
    nombreEstado: 'Caída de hojas',
    mes: 10,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'monastrell',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 9,
    nombreEstado: 'Brotación',
    mes: 4,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'monastrell',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 15,
    nombreEstado: '5 hojas',
    mes: 4,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'monastrell',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 53,
    nombreEstado: 'Inflorescencia visible',
    mes: 5,
    decada: 2,
  ),
  EstadoFenologicoBbch(
    variedadId: 'monastrell',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 65,
    nombreEstado: 'Plena floración',
    mes: 6,
    decada: 2,
  ),
  EstadoFenologicoBbch(
    variedadId: 'monastrell',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 71,
    nombreEstado: 'Cuajado',
    mes: 6,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'monastrell',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 75,
    nombreEstado: 'Tamaño guisante',
    mes: 7,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'monastrell',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 81,
    nombreEstado: 'Inicio envero',
    mes: 7,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'monastrell',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 89,
    nombreEstado: 'Vendimia',
    mes: 10,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'monastrell',
    zona: ZonaClimaticaVid.sur,
    estadoBbch: 93,
    nombreEstado: 'Caída de hojas',
    mes: 11,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'mencia',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 9,
    nombreEstado: 'Brotación',
    mes: 4,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'mencia',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 15,
    nombreEstado: '5 hojas',
    mes: 4,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'mencia',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 53,
    nombreEstado: 'Inflorescencia visible',
    mes: 5,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'mencia',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 65,
    nombreEstado: 'Plena floración',
    mes: 6,
    decada: 2,
  ),
  EstadoFenologicoBbch(
    variedadId: 'mencia',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 71,
    nombreEstado: 'Cuajado',
    mes: 6,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'mencia',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 75,
    nombreEstado: 'Tamaño guisante',
    mes: 7,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'mencia',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 81,
    nombreEstado: 'Inicio envero',
    mes: 8,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'mencia',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 89,
    nombreEstado: 'Vendimia',
    mes: 9,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'mencia',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 93,
    nombreEstado: 'Caída de hojas',
    mes: 11,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'albariño',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 9,
    nombreEstado: 'Brotación',
    mes: 4,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'albariño',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 15,
    nombreEstado: '5 hojas',
    mes: 4,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'albariño',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 53,
    nombreEstado: 'Inflorescencia visible',
    mes: 5,
    decada: 2,
  ),
  EstadoFenologicoBbch(
    variedadId: 'albariño',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 65,
    nombreEstado: 'Plena floración',
    mes: 6,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'albariño',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 71,
    nombreEstado: 'Cuajado',
    mes: 6,
    decada: 2,
  ),
  EstadoFenologicoBbch(
    variedadId: 'albariño',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 75,
    nombreEstado: 'Tamaño guisante',
    mes: 6,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'albariño',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 81,
    nombreEstado: 'Inicio envero',
    mes: 7,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'albariño',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 89,
    nombreEstado: 'Vendimia',
    mes: 9,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'albariño',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 93,
    nombreEstado: 'Caída de hojas',
    mes: 11,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'verdejo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 9,
    nombreEstado: 'Brotación',
    mes: 4,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'verdejo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 15,
    nombreEstado: '5 hojas',
    mes: 4,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'verdejo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 53,
    nombreEstado: 'Inflorescencia visible',
    mes: 5,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'verdejo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 65,
    nombreEstado: 'Plena floración',
    mes: 6,
    decada: 2,
  ),
  EstadoFenologicoBbch(
    variedadId: 'verdejo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 71,
    nombreEstado: 'Cuajado',
    mes: 6,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'verdejo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 75,
    nombreEstado: 'Tamaño guisante',
    mes: 7,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'verdejo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 81,
    nombreEstado: 'Inicio envero',
    mes: 7,
    decada: 3,
  ),
  EstadoFenologicoBbch(
    variedadId: 'verdejo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 89,
    nombreEstado: 'Vendimia',
    mes: 9,
    decada: 1,
  ),
  EstadoFenologicoBbch(
    variedadId: 'verdejo',
    zona: ZonaClimaticaVid.norte,
    estadoBbch: 93,
    nombreEstado: 'Caída de hojas',
    mes: 10,
    decada: 3,
  ),
];

/// Estados fenológicos para una variedad y zona, ordenados por fecha.
List<EstadoFenologicoBbch> calendarioDe(String variedadId, ZonaClimaticaVid zona) {
  final filtrados = calendarioFenologicoBbch
      .where((e) => e.variedadId == variedadId && e.zona == zona)
      .toList();
  filtrados.sort((a, b) {
    final cmpMes = a.mes.compareTo(b.mes);
    if (cmpMes != 0) return cmpMes;
    return a.decada.compareTo(b.decada);
  });
  return filtrados;
}

/// Estado fenológico esperado para una fecha concreta. Útil para
/// "qué toca esta semana" en la pantalla principal.
EstadoFenologicoBbch? estadoEsperadoEn({
  required String variedadId,
  required ZonaClimaticaVid zona,
  required DateTime fecha,
}) {
  final eventos = calendarioDe(variedadId, zona);
  if (eventos.isEmpty) return null;
  final decadaActual = (fecha.day - 1) ~/ 10 + 1;
  final claveActual = fecha.month * 10 + decadaActual.clamp(1, 3);
  EstadoFenologicoBbch? mejor;
  int mejorClave = -1;
  for (final e in eventos) {
    final clave = e.mes * 10 + e.decada;
    if (clave <= claveActual && clave > mejorClave) {
      mejor = e;
      mejorClave = clave;
    }
  }
  return mejor ?? eventos.last; // fallback: última fenología del año
}
