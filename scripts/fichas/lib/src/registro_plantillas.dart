import 'ejercicio.dart';
import 'generadores/decimales.dart';
import 'generadores/fracciones.dart';

/// Todas las plantillas, por id de habilidad. Una habilidad sin plantilla
/// no tiene forma clara de hacerse en papel y se salta (ver
/// [motivosSinPlantilla]).
final Map<String, PlantillaFicha> plantillasPorHabilidad = {
  for (final plantilla in [
    ...plantillasFracciones,
    ...plantillasDecimales,
  ])
    plantilla.idHabilidad: plantilla,
};

/// Habilidades que se saltan a propósito y por qué: necesitan un dibujo
/// (gráfica, ejes, figura) que en v0.1 no se genera.
const Map<String, String> motivosSinPlantilla = {};
