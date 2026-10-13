import 'apunte_economico.dart';
import 'constantes.dart';
import 'proyecto_test.dart';

/// Inventario de amortizaciones, como la hoja «Listado-amortización» de
/// Zunbeltz (2026-10-13): cada bien con su precio, unidades, IVA y vida
/// útil; cada proyecto marca qué bienes usa y la cuota se calcula sola con
/// los meses del test. Así no se repite a mano en cada Excel (allí se
/// colaban errores: meses que no cuadraban, referencias rotas).
///
/// El mismo cálculo está en el servidor (`szs_cuota_uso_bien`, panel WP).

/// Bien amortizable del espacio (aprisco, corral móvil, abrevaderos…). Lo
/// mantiene coordinación; lo ven todas las personas.
class BienAmortizable {
  BienAmortizable({
    this.id,
    this.nombre = '',
    this.grupo = grupoBienPorDefecto,
    this.especie = '',
    this.precioUnidadCentimos = 0,
    this.unidades = 1,
    this.ivaPorcentaje = 21,
    this.vidaUtilMeses = 72,
    this.notas = '',
  });

  final int? id;
  final String nombre;

  /// Partida del bloque VI: `instalaciones`, `material_ganadero` o
  /// `adecuaciones` (ver `partidasGasto['amortizacion']`).
  final String grupo;

  /// Código de `especiesGanado` si el material es de una especie (manga
  /// de ovino, tolva de pollitos); vacío si sirve para cualquiera.
  final String especie;
  final int precioUnidadCentimos;
  final double unidades;

  /// La hoja de Zunbeltz amortiza sobre el total con IVA; con 0 se amortiza
  /// la base.
  final int ivaPorcentaje;
  final int vidaUtilMeses;
  final String notas;

  /// Precio × unidades + IVA.
  int get totalCentimos =>
      (precioUnidadCentimos * unidades * (100 + ivaPorcentaje) / 100).round();

  /// Total ÷ vida útil. Sin vida útil no se amortiza.
  double get cuotaMensualCentimos =>
      vidaUtilMeses <= 0 ? 0 : totalCentimos / vidaUtilMeses;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'grupo': grupo,
        'especie': especie,
        'precio_unidad_centimos': precioUnidadCentimos,
        'unidades': unidades,
        'iva_porcentaje': ivaPorcentaje,
        'vida_util_meses': vidaUtilMeses,
        'notas': notas,
      };

  factory BienAmortizable.fromMap(Map<String, Object?> mapa) =>
      BienAmortizable(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        grupo: (mapa['grupo'] as String?) ?? grupoBienPorDefecto,
        especie: (mapa['especie'] as String?) ?? '',
        precioUnidadCentimos: (mapa['precio_unidad_centimos'] as num?)?.toInt() ?? 0,
        unidades: (mapa['unidades'] as num?)?.toDouble() ?? 1,
        ivaPorcentaje: (mapa['iva_porcentaje'] as num?)?.toInt() ?? 21,
        vidaUtilMeses: (mapa['vida_util_meses'] as num?)?.toInt() ?? 72,
        notas: (mapa['notas'] as String?) ?? '',
      );
}

const String grupoBienPorDefecto = 'material_ganadero';

/// Un bien del inventario usado por un proyecto de test.
class UsoBien {
  UsoBien({
    this.id,
    required this.proyectoId,
    required this.bienId,
    this.imputacionPorcentaje = 100,
    this.duracionMeses = 0,
    this.notas = '',
  });

  final int? id;
  final int proyectoId;
  final int bienId;

  /// Parte del bien que se carga a este proyecto (uno de dos corrales
  /// móviles = 50 %).
  final int imputacionPorcentaje;

  /// Meses que se imputan; 0 = lo que dura el test (fechas del proyecto).
  final double duracionMeses;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'proyecto_id': proyectoId,
        'bien_id': bienId,
        'imputacion_porcentaje': imputacionPorcentaje,
        'duracion_meses': duracionMeses,
        'notas': notas,
      };

  factory UsoBien.fromMap(Map<String, Object?> mapa) => UsoBien(
        id: mapa['id'] as int?,
        proyectoId: (mapa['proyecto_id'] as int?) ?? 0,
        bienId: (mapa['bien_id'] as int?) ?? 0,
        imputacionPorcentaje:
            (mapa['imputacion_porcentaje'] as num?)?.toInt() ?? 100,
        duracionMeses: (mapa['duracion_meses'] as num?)?.toDouble() ?? 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Meses entre dos fechas: los de calendario completos más la fracción de
/// días que sobra, sobre 30 (del 1-jun al 1-oct son 4; del 1 al 16 de
/// junio, 0,5). Redondeado a centésimas.
double mesesEntre(DateTime inicio, DateTime fin) {
  if (!fin.isAfter(inicio)) return 0;
  var meses = (fin.year - inicio.year) * 12 + fin.month - inicio.month;
  if (fin.day < inicio.day) meses--;
  // Del 31 de enero, un mes después es el 28 de febrero, no el 3 de marzo.
  final mesDestino = DateTime(inicio.year, inicio.month + meses);
  final ultimoDiaDelMes = DateTime(mesDestino.year, mesDestino.month + 1, 0).day;
  final finMesesEnteros = DateTime(mesDestino.year, mesDestino.month,
      inicio.day > ultimoDiaDelMes ? ultimoDiaDelMes : inicio.day);
  final diasSobrantes = DateTime.utc(fin.year, fin.month, fin.day)
      .difference(DateTime.utc(finMesesEnteros.year, finMesesEnteros.month,
          finMesesEnteros.day))
      .inDays;
  return ((meses + diasSobrantes / 30) * 100).round() / 100;
}

/// Lo que dura el test: del inicio al fin del proyecto; sin fin, hasta
/// [ahora]. Sin inicio, 0.
double mesesDelProyecto(ProyectoTest proyecto, {DateTime? ahora}) {
  final inicioMs = proyecto.fechaInicioMs;
  if (inicioMs == null || inicioMs == 0) return 0;
  final finMs = proyecto.fechaFinMs;
  final fin = finMs == null || finMs == 0
      ? (ahora ?? DateTime.now())
      : DateTime.fromMillisecondsSinceEpoch(finMs);
  return mesesEntre(DateTime.fromMillisecondsSinceEpoch(inicioMs), fin);
}

/// Meses que se imputan por un uso: los suyos o, si no tiene, los del test.
double mesesImputados(UsoBien uso, ProyectoTest proyecto, {DateTime? ahora}) =>
    uso.duracionMeses > 0
        ? uso.duracionMeses
        : mesesDelProyecto(proyecto, ahora: ahora);

/// Cuota de amortización que se carga al proyecto por un uso: cuota
/// mensual × meses × porcentaje.
int cuotaImputadaCentimos(BienAmortizable bien, UsoBien uso,
        ProyectoTest proyecto, {DateTime? ahora}) =>
    (bien.cuotaMensualCentimos *
            mesesImputados(uso, proyecto, ahora: ahora) *
            uso.imputacionPorcentaje /
            100)
        .round();

/// Parte de la cuota que cae en un periodo, repartida por igual entre los
/// días del test. Sin periodo, toda; sin fechas de proyecto, toda (no hay
/// con qué repartir).
int cuotaEnPeriodoCentimos(int cuotaCentimos, ProyectoTest proyecto,
    {int? desdeMs, int? hastaMs, DateTime? ahora}) {
  if (desdeMs == null && hastaMs == null) return cuotaCentimos;
  final inicioMs = proyecto.fechaInicioMs;
  if (inicioMs == null || inicioMs == 0) return cuotaCentimos;
  final finMs = (proyecto.fechaFinMs == null || proyecto.fechaFinMs == 0)
      ? (ahora ?? DateTime.now()).millisecondsSinceEpoch
      : proyecto.fechaFinMs!;
  if (finMs <= inicioMs) return cuotaCentimos;
  final desde = desdeMs == null || desdeMs < inicioMs ? inicioMs : desdeMs;
  final hasta = hastaMs == null || hastaMs > finMs ? finMs : hastaMs;
  if (hasta <= desde) return 0;
  return (cuotaCentimos * (hasta - desde) / (finMs - inicioMs)).round();
}

/// Las cuotas de los usos de un proyecto como apuntes de gasto del bloque
/// VI (no se guardan: se calculan), para que balance, desglose y
/// rentabilidad las cuenten igual que lo apuntado a mano. Las asume
/// Zunbeltz, que es quien pone los bienes.
List<ApunteEconomico> apuntesDeAmortizacion({
  required ProyectoTest proyecto,
  required List<UsoBien> usos,
  required Map<int, BienAmortizable> bienesPorId,
  required int fincaId,
  int? desdeMs,
  int? hastaMs,
  DateTime? ahora,
}) {
  final apuntes = <ApunteEconomico>[];
  for (final uso in usos) {
    final bien = bienesPorId[uso.bienId];
    if (bien == null) continue;
    final cuota = cuotaEnPeriodoCentimos(
        cuotaImputadaCentimos(bien, uso, proyecto, ahora: ahora), proyecto,
        desdeMs: desdeMs, hastaMs: hastaMs, ahora: ahora);
    if (cuota == 0) continue;
    apuntes.add(ApunteEconomico(
      fincaId: fincaId,
      proyectoId: proyecto.id,
      tipo: 'gasto',
      categoria: categoriaAmortizacion,
      partida: bien.grupo,
      concepto: bien.nombre,
      importeCentimos: cuota,
      fechaMs: proyecto.fechaInicioMs ?? 0,
      asumidoPor: asumidoPorZunbeltz,
    ));
  }
  return apuntes;
}
