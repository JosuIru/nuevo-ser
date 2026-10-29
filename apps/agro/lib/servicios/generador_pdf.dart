import 'dart:io';

import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:pdf/widgets.dart' as pw;

import '../datos/base_datos.dart';
import '../datos/catalogo_cultivos.dart';
import '../modelos/cosecha.dart';
import '../modelos/finca.dart';
import '../modelos/planta.dart';

/// Acumulado de cosechas para una planta dentro de un periodo:
/// kilos totales, unidades totales y nº de registros. Pensado para
/// la tabla "Plantas con cosecha en el periodo" del informe de
/// campaña.
class AcumuladoCosechasPlanta {
  double kilos = 0;
  int unidades = 0;
  int numCosechas = 0;
}

/// Resultado de la agregación: por-planta + totales del periodo.
/// Función pura, testeable sin BD.
class ResumenCosechas {
  final Map<int, AcumuladoCosechasPlanta> porPlanta;
  final double totalKilos;
  final int totalUnidades;
  final int totalCosechas;

  ResumenCosechas({
    required this.porPlanta,
    required this.totalKilos,
    required this.totalUnidades,
    required this.totalCosechas,
  });
}

/// Agrupa una lista de cosechas por su `plantaId`, filtrando por el
/// rango `[inicioMs, finMs)`. Si los límites son `null` no se filtra
/// por fecha (modo histórico). Pura: no toca BD, no toca disco.
ResumenCosechas agruparCosechasPorPlanta({
  required Iterable<Cosecha> cosechas,
  int? inicioMs,
  int? finMs,
}) {
  final porPlanta = <int, AcumuladoCosechasPlanta>{};
  double totalKilos = 0;
  int totalUnidades = 0;
  int totalCosechas = 0;
  for (final c in cosechas) {
    if (inicioMs != null && c.fechaMs < inicioMs) continue;
    if (finMs != null && c.fechaMs >= finMs) continue;
    final acumulado = porPlanta.putIfAbsent(c.plantaId, () => AcumuladoCosechasPlanta());
    acumulado.kilos += c.kilos ?? 0;
    acumulado.unidades += c.unidades ?? 0;
    acumulado.numCosechas++;
    totalKilos += c.kilos ?? 0;
    totalUnidades += c.unidades ?? 0;
    totalCosechas++;
  }
  return ResumenCosechas(
    porPlanta: porPlanta,
    totalKilos: totalKilos,
    totalUnidades: totalUnidades,
    totalCosechas: totalCosechas,
  );
}

/// Genera un PDF de campaña por finca: cabecera con finca + periodo,
/// resumen agregado (nº plantas, total kg/unidades, incidencias
/// abiertas) y tabla por planta con su contribución a la campaña.
///
/// Si `finca` es null genera el reporte global (todas las plantas
/// del usuario, incluidos puntos sueltos). Si `ano` es null incluye
/// todas las cosechas históricas — útil para ver evolución, pero el
/// uso típico es por campaña concreta.
///
/// La maquetación (cabecera, footer paginación, tabla con estilo
/// consistente) la pone `generarInformePeriodicoPdf` del core. Aquí
/// va el dominio: consulta a la BD de Larrea + construcción de las
/// listas de bullets y filas.
Future<File> generarPdfCampana({
  Finca? finca,
  required int? ano,
  required String operador,
}) async {
  final db = BaseDatosAgro.instancia;
  final plantas = await db.listarPlantas(fincaId: finca?.id);
  final inicioMs = ano == null ? null : DateTime(ano, 1, 1).millisecondsSinceEpoch;
  final finMs = ano == null ? null : DateTime(ano + 1, 1, 1).millisecondsSinceEpoch;

  // Agregación de cosechas en el periodo. Recolecta primero todas
  // las cosechas (N+1 consultas — comportamiento histórico, fuera
  // de scope para este refactor) y luego agrupa con la función pura.
  final todasCosechas = <Cosecha>[];
  for (final p in plantas) {
    todasCosechas.addAll(await db.listarCosechasDePlanta(p.id!));
  }
  final resumen = agruparCosechasPorPlanta(
    cosechas: todasCosechas,
    inicioMs: inicioMs,
    finMs: finMs,
  );
  final incidenciasAbiertas = await db.listarIncidenciasAbiertas(fincaId: finca?.id);

  // Bullets del resumen.
  final bullets = <String>[
    'Plantas: ${plantas.length}',
    if (resumen.totalKilos > 0) 'Cosecha total: ${resumen.totalKilos.toStringAsFixed(2)} kg',
    if (resumen.totalUnidades > 0) 'Unidades: ${resumen.totalUnidades}',
    if (resumen.totalCosechas > 0) 'Registros de cosecha: ${resumen.totalCosechas}',
    'Incidencias abiertas: ${incidenciasAbiertas.length}',
  ];

  // Tablas del informe.
  final tablas = <TablaInforme>[
    TablaInforme(
      titulo: 'Plantas con cosecha en el periodo',
      headers: const ['Etiqueta', 'Cultivo', 'Variedad', 'Kg', 'Ud', 'Nº cosechas'],
      filas: _filasCosechasPorPlanta(plantas, resumen),
      mensajeSiVacia: 'Sin cosechas registradas en el periodo.',
      alineamientoCeldas: const {
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
    ),
    if (incidenciasAbiertas.isNotEmpty)
      TablaInforme(
        titulo: 'Incidencias abiertas',
        headers: const ['Fecha', 'Tipo', 'Diagnóstico', 'Severidad'],
        filas: [
          for (final i in incidenciasAbiertas)
            [
              DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(i.fechaMs)),
              i.tipo,
              i.diagnostico,
              i.severidad?.toString() ?? '–',
            ],
        ],
      ),
  ];

  return generarInformePeriodicoPdf(
    tituloCabecera: finca?.nombre ?? 'Todas las fincas',
    subtituloCabecera: ano == null ? 'Histórico' : 'Campaña $ano',
    bulletsResumen: bullets,
    tablas: tablas,
    prefijoNombreFichero: 'agro-${finca?.nombre.replaceAll(RegExp(r'\s+'), '_') ?? 'todas'}-${ano ?? 'historico'}',
    operador: operador,
    tema: await temaPdfSolera(),
  );
}

List<List<String>> _filasCosechasPorPlanta(List<Planta> plantas, ResumenCosechas resumen) {
  return [
    for (final p in plantas)
      if (resumen.porPlanta.containsKey(p.id))
        [
          p.etiqueta.isEmpty ? '#${p.id}' : p.etiqueta,
          cultivoPorId(p.cultivoId).nombreVisible,
          p.variedad,
          resumen.porPlanta[p.id]!.kilos.toStringAsFixed(2),
          resumen.porPlanta[p.id]!.unidades.toString(),
          resumen.porPlanta[p.id]!.numCosechas.toString(),
        ],
  ];
}
