import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart' show distanciaMetros;

import '../modelos/incendios.dart';
import '../modelos/monte.dart';

/// Días antes del inicio de la época de peligro en los que la app empieza a
/// recordar las revisiones. Decisión de la app, no de ninguna norma.
const int diasAvisoAntesEpoca = 45;

/// Longitud de una traza abierta (pista, cortafuegos) en metros: suma de
/// tramos, sin cerrar el anillo.
double longitudTrazaMetros(List<LatLng> puntos) {
  var total = 0.0;
  for (var indice = 1; indice < puntos.length; indice++) {
    total += distanciaMetros(puntos[indice - 1], puntos[indice]);
  }
  return total;
}

/// La declarada si la hay; si no, la de la traza (0 sin ninguna).
double longitudInfraestructuraMetros(
        InfraestructuraIncendios infraestructura) =>
    infraestructura.longitudM ?? longitudTrazaMetros(infraestructura.traza);

/// Estado de una infraestructura para la campaña de [anyo].
enum EstadoCampanyaIncendios { sinRevisar, correcta, conTrabajoPendiente }

/// Una revisión cuenta para la campaña de [anyo] si es de ese año natural.
/// Se mira la más reciente.
EstadoCampanyaIncendios estadoCampanya(InfraestructuraIncendios infraestructura,
    List<RevisionIncendios> revisiones, int anyo) {
  final delAnyo = revisiones
      .where((revision) =>
          revision.infraestructuraId == infraestructura.id &&
          DateTime.fromMillisecondsSinceEpoch(revision.fechaMs).year == anyo)
      .toList()
    ..sort((a, b) => b.fechaMs.compareTo(a.fechaMs));
  if (delAnyo.isEmpty) return EstadoCampanyaIncendios.sinRevisar;
  return delAnyo.first.pideTrabajo
      ? EstadoCampanyaIncendios.conTrabajoPendiente
      : EstadoCampanyaIncendios.correcta;
}

/// Qué recordar en Hoy sobre la época de peligro.
class AvisoEpocaPeligro {
  const AvisoEpocaPeligro({
    required this.inicio,
    required this.diasHastaInicio,
    required this.sinRevisar,
    required this.conTrabajoPendiente,
  });

  final DateTime inicio;

  /// Negativo si ya empezó.
  final int diasHastaInicio;
  final List<InfraestructuraIncendios> sinRevisar;
  final List<InfraestructuraIncendios> conTrabajoPendiente;

  bool get hayPendientes =>
      sinRevisar.isNotEmpty || conTrabajoPendiente.isNotEmpty;
}

/// Aviso si faltan [diasAvisoAntesEpoca] días o menos para la época de
/// peligro (o ya empezó, ese mismo año) y hay infraestructuras activas sin
/// revisar o con trabajo pendiente. null si la fecha no está apuntada o aún
/// es pronto.
AvisoEpocaPeligro? avisoEpocaPeligro({
  required Monte monte,
  required List<InfraestructuraIncendios> infraestructuras,
  required List<RevisionIncendios> revisiones,
  required DateTime hoy,
}) {
  final inicio = monte.inicioEpocaPeligroEn(hoy.year);
  if (inicio == null) return null;
  final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
  final dias = DateTime.utc(inicio.year, inicio.month, inicio.day)
      .difference(
          DateTime.utc(hoySinHora.year, hoySinHora.month, hoySinHora.day))
      .inDays;
  if (dias > diasAvisoAntesEpoca) return null;
  final activas = infraestructuras.where((i) => i.activa).toList();
  final estados = {
    for (final infraestructura in activas)
      infraestructura: estadoCampanya(infraestructura, revisiones, hoy.year)
  };
  return AvisoEpocaPeligro(
    inicio: inicio,
    diasHastaInicio: dias,
    sinRevisar: [
      for (final MapEntry(:key, :value) in estados.entries)
        if (value == EstadoCampanyaIncendios.sinRevisar) key
    ],
    conTrabajoPendiente: [
      for (final MapEntry(:key, :value) in estados.entries)
        if (value == EstadoCampanyaIncendios.conTrabajoPendiente) key
    ],
  );
}
