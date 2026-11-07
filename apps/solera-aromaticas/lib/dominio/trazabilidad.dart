// Trazabilidad hacia atrás de un lote: proceso → cosechas → parcela o zona
// (con su permiso). Lógica pura, sin Flutter.

import '../modelos/cosecha.dart';
import '../modelos/destilacion.dart';
import '../modelos/lote_producto.dart';
import '../modelos/parcela.dart';
import '../modelos/secado.dart';
import '../modelos/zona_recoleccion.dart';

/// De dónde sale un lote.
class OrigenLote {
  OrigenLote({
    this.secado,
    this.destilacion,
    this.cosechas = const [],
    this.parcelas = const [],
    this.zonas = const [],
  });

  final Secado? secado;
  final Destilacion? destilacion;
  final List<Cosecha> cosechas;
  final List<Parcela> parcelas;
  final List<ZonaRecoleccion> zonas;

  bool get tieneProceso => secado != null || destilacion != null;

  /// Hay planta silvestre en el lote.
  bool get incluyeSilvestre => zonas.isNotEmpty;

  /// Primera y última fecha de cosecha; null sin cosechas.
  (int, int)? get intervaloCosecha {
    if (cosechas.isEmpty) return null;
    final fechas = cosechas.map((cosecha) => cosecha.fechaMs).toList()..sort();
    return (fechas.first, fechas.last);
  }

  double get kgFrescosCosechados =>
      cosechas.fold(0, (suma, cosecha) => suma + cosecha.kgFrescos);
}

/// Busca el proceso que generó [lote] y sigue sus cosechas hasta las
/// parcelas y zonas. Si nada lo generó (lote apuntado a mano), origen vacío.
OrigenLote origenDeLote(
  LoteProducto lote, {
  required Iterable<Secado> secados,
  required Iterable<Destilacion> destilaciones,
  required Iterable<Cosecha> cosechas,
  required Iterable<Parcela> parcelas,
  required Iterable<ZonaRecoleccion> zonas,
}) {
  Secado? secado;
  Destilacion? destilacion;
  for (final candidato in secados) {
    if (lote.id != null && candidato.loteProductoId == lote.id) {
      secado = candidato;
    }
  }
  for (final candidato in destilaciones) {
    if (lote.id != null &&
        (candidato.loteAceiteId == lote.id ||
            candidato.loteHidrolatoId == lote.id)) {
      destilacion = candidato;
    }
  }
  final idsCosechas = {
    ...?secado?.cosechasUsadasIds,
    ...?destilacion?.cosechasUsadasIds,
  };
  final usadas = [
    for (final cosecha in cosechas)
      if (idsCosechas.contains(cosecha.id)) cosecha,
  ]..sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
  final idsParcelas = {for (final cosecha in usadas) cosecha.parcelaId};
  final idsZonas = {for (final cosecha in usadas) cosecha.zonaRecoleccionId};
  return OrigenLote(
    secado: secado,
    destilacion: destilacion,
    cosechas: usadas,
    parcelas: [
      for (final parcela in parcelas)
        if (idsParcelas.contains(parcela.id)) parcela,
    ],
    zonas: [
      for (final zona in zonas)
        if (idsZonas.contains(zona.id)) zona,
    ],
  );
}

/// Texto del QR del pasaporte del lote: datos de trazabilidad en texto
/// plano (sin enlaces; el pasaporte común T1 del core lo sustituirá).
/// **Sin ninguna propiedad de uso ni de salud** (hard limit).
String textoQrLote({
  required LoteProducto lote,
  required String nombreEspecie,
  required String nombreCientifico,
  required String titular,
  required OrigenLote origen,
  required String Function(int fechaMs) formatearFecha,
}) {
  final lineas = <String>[
    'Larrea Aromaticas - lote ${lote.codigo}',
    'Producto: ${lote.tipo}',
    'Especie: $nombreEspecie${nombreCientifico.isEmpty ? '' : ' ($nombreCientifico)'}',
    'Fecha: ${formatearFecha(lote.fechaMs)}',
    'Cantidad: ${lote.cantidad} ${lote.unidad}',
    if (titular.isNotEmpty) 'Titular: $titular',
    for (final parcela in origen.parcelas) 'Parcela: ${parcela.nombre}',
    for (final zona in origen.zonas)
      'Recoleccion: ${zona.nombre}'
          '${zona.tienePermiso ? ' (permiso ${zona.numeroPermiso})' : ''}',
    if (origen.intervaloCosecha != null)
      'Cosecha: ${formatearFecha(origen.intervaloCosecha!.$1)}'
          ' - ${formatearFecha(origen.intervaloCosecha!.$2)}',
    'PROVISIONAL',
  ];
  return lineas.join('\n');
}
