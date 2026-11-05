import 'package:flutter/widgets.dart';

/// Qué enseñar en el mapa de Fincas: un punto (se centra en él) o una pieza
/// (se elige y sale su hoja).
class DestinoMapa {
  const DestinoMapa({this.puntoId, this.zonaId});
  final int? puntoId;
  final int? zonaId;
}

/// Petición de llevar el mapa a un sitio desde otra pantalla (el botón
/// «Mapa» del tablero de tareas). La pantalla principal cambia a la pestaña
/// de Fincas y el mapa la atiende y la deja en `null`.
final ValueNotifier<DestinoMapa?> peticionVerEnMapa =
    ValueNotifier<DestinoMapa?>(null);

/// Cierra lo que haya abierto encima de las pestañas y pide el mapa.
void verEnMapa(BuildContext context, DestinoMapa destino) {
  Navigator.of(context).popUntil((ruta) => ruta.isFirst);
  peticionVerEnMapa.value = destino;
}
