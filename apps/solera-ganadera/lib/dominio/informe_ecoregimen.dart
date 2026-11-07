import '../datos/catalogos_generados/catalogo_parametros_ecoregimen.dart';
import '../modelos/carga_ganadera.dart';
import '../modelos/ganado.dart';
import '../modelos/pieza_pasto.dart';

/// Informe del eco-régimen de pastoreo extensivo (RD 1048/2022, art. 30.2):
/// por pieza (recinto) y campaña, los días con ganado y la carga en UGM/ha
/// de esos días, con avisos si queda por debajo del mínimo o por encima del
/// máximo.
///
/// **Es una ayuda, no una declaración.** La comunidad autónoma calcula las
/// UGM con SITRAN y con las fechas y reducciones de su convocatoria. Aquí:
/// - la ubicación de cada rebaño cada día sale de sus movimientos (el día del
///   movimiento ya cuenta en el destino);
/// - las UGM de un rebaño un día son las de ahora, escaladas por las cabezas
///   que llevaba en su último movimiento con cabezas (la edad de cada animal
///   se toma la de hoy): aproximación;
/// - una pieza es un recinto: si una pieza abarca varios recintos SIGPAC, el
///   informe no los separa.

/// Lo calculado para una pieza en la campaña.
class InformeRecinto {
  const InformeRecinto({
    required this.pieza,
    required this.diasConGanado,
    required this.ugmDiaMedia,
    this.cargaMedia,
    this.cargaMinima,
    this.cargaMaxima,
    this.parametros,
  });

  final PiezaPasto pieza;

  /// Días de la campaña con algún rebaño en la pieza.
  final int diasConGanado;

  /// UGM medias de los días con ganado.
  final double ugmDiaMedia;

  /// UGM/ha media, mínima y máxima de los días con ganado (null sin
  /// superficie o sin días).
  final double? cargaMedia;
  final double? cargaMinima;
  final double? cargaMaxima;

  /// Los del tipo de pasto de la pieza (null si no hay).
  final ParametrosEcoregimen? parametros;

  bool get sinSuperficie =>
      pieza.superficieHa == null || pieza.superficieHa! <= 0;

  bool get pocosDias =>
      parametros != null && diasConGanado < parametros!.diasMinimos;

  bool get cargaPorDebajo =>
      parametros != null &&
      cargaMedia != null &&
      cargaMedia! < parametros!.cargaMinima;

  bool get cargaPorEncima =>
      parametros != null &&
      cargaMaxima != null &&
      cargaMaxima! > parametros!.cargaMaxima;

  bool get hayAvisos => pocosDias || cargaPorDebajo || cargaPorEncima;
}

DateTime _dia(int ms) {
  final fecha = DateTime.fromMillisecondsSinceEpoch(ms);
  return DateTime(fecha.year, fecha.month, fecha.day);
}

/// Los días del periodo [desde, hasta], ambos incluidos, como fechas locales.
Iterable<DateTime> diasDelPeriodo(DateTime desde, DateTime hasta) sync* {
  var dia = DateTime(desde.year, desde.month, desde.day);
  final ultimo = DateTime(hasta.year, hasta.month, hasta.day);
  while (!dia.isAfter(ultimo)) {
    yield dia;
    dia = DateTime(dia.year, dia.month, dia.day + 1);
  }
}

/// Pieza en la que estaba el rebaño el [dia] (null fuera o sin movimientos).
int? piezaDelLoteEnDia(
        List<MovimientoGanado> movimientosDelLote, DateTime dia) =>
    piezaActualDeLote(movimientosDelLote
        .where((movimiento) => !_dia(movimiento.fechaMs).isAfter(dia)));

/// Cabezas que llevaba el rebaño el [dia] según su último movimiento con
/// cabezas; null si no se sabe.
int? cabezasDelLoteEnDia(
    List<MovimientoGanado> movimientosDelLote, DateTime dia) {
  final conCabezas = movimientosDelLote.where((movimiento) =>
      movimiento.cabezas > 0 &&
      movimiento.cambiaUbicacion &&
      !_dia(movimiento.fechaMs).isAfter(dia));
  return ultimoMovimiento(conCabezas)?.cabezas;
}

/// Calcula el informe de la campaña [desde]–[hasta] para las piezas activas.
List<InformeRecinto> calcularInformeEcoregimen({
  required List<PiezaPasto> piezas,
  required List<LoteGanado> lotes,
  required List<Animal> animales,
  required List<MovimientoGanado> movimientos,
  required List<CoeficienteUgm> tabla,
  required List<ParametrosEcoregimen> parametros,
  required DateTime desde,
  required DateTime hasta,
  required DateTime ahora,
}) {
  final porLote =
      <int, ({List<MovimientoGanado> movimientos, double ugm, int cabezas})>{};
  for (final lote in lotes) {
    if (lote.id == null) continue;
    final suyos = animales.where((animal) => animal.loteId == lote.id).toList();
    porLote[lote.id!] = (
      movimientos: movimientos
          .where((movimiento) => movimiento.loteId == lote.id)
          .toList(),
      ugm: ugmDeLote(lote, suyos, ahora, tabla),
      cabezas: cabezasDeLote(lote, suyos),
    );
  }
  final ugmPorPiezaYDia = <int, List<double>>{};
  for (final dia in diasDelPeriodo(desde, hasta)) {
    final ugmDelDia = <int, double>{};
    for (final datos in porLote.values) {
      final pieza = piezaDelLoteEnDia(datos.movimientos, dia);
      if (pieza == null) continue;
      final cabezasDia = cabezasDelLoteEnDia(datos.movimientos, dia);
      final ugm = cabezasDia == null || datos.cabezas == 0
          ? datos.ugm
          : datos.ugm / datos.cabezas * cabezasDia;
      if (ugm <= 0) continue;
      ugmDelDia.update(pieza, (suma) => suma + ugm, ifAbsent: () => ugm);
    }
    ugmDelDia.forEach(
        (pieza, ugm) => ugmPorPiezaYDia.putIfAbsent(pieza, () => []).add(ugm));
  }
  ParametrosEcoregimen? parametrosDe(String tipoPasto) =>
      parametros.where((fila) => fila.tipoPasto == tipoPasto).firstOrNull;
  return [
    for (final pieza in piezas.where((pieza) => pieza.activa))
      () {
        final dias = ugmPorPiezaYDia[pieza.id] ?? const <double>[];
        final superficie = pieza.superficieHa;
        final conSuperficie = superficie != null && superficie > 0;
        final cargas = conSuperficie
            ? dias.map((ugm) => ugm / superficie).toList()
            : const <double>[];
        return InformeRecinto(
          pieza: pieza,
          diasConGanado: dias.length,
          ugmDiaMedia:
              dias.isEmpty ? 0 : dias.reduce((a, b) => a + b) / dias.length,
          cargaMedia: cargas.isEmpty
              ? null
              : cargas.reduce((a, b) => a + b) / cargas.length,
          cargaMinima:
              cargas.isEmpty ? null : cargas.reduce((a, b) => a < b ? a : b),
          cargaMaxima:
              cargas.isEmpty ? null : cargas.reduce((a, b) => a > b ? a : b),
          parametros: parametrosDe(pieza.tipoPasto),
        );
      }(),
  ];
}
