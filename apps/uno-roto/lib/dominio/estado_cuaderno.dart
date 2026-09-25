import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Cinco estados visuales del cuaderno del niño. NO son los cinco
/// niveles del [MotorMaestria] tal cual — los reagrupamos en lenguaje
/// que un niño de 9 a 14 años entiende, sin números:
///
///   latente  → aún no la has visto
///   vista    → la has tocado una vez
///   practica → estás aprendiéndola
///   firme    → ya te sale
///   dominada → la dominas
///
/// La pantalla del niño solo necesita esto. La pantalla del tutor
/// añade encima los números crudos (precisión, días, exposiciones).
enum EstadoCuaderno {
  latente,
  vista,
  practica,
  firme,
  dominada,
}

extension NombreEstadoCuaderno on EstadoCuaderno {
  /// Nombre corto en castellano para mostrar al niño. No tiene
  /// connotación de "bien/mal" — describe estado, no juicio.
  String get nombreCorto {
    switch (this) {
      case EstadoCuaderno.latente:
        return 'Aún no';
      case EstadoCuaderno.vista:
        return 'Visto';
      case EstadoCuaderno.practica:
        return 'En práctica';
      case EstadoCuaderno.firme:
        return 'Firme';
      case EstadoCuaderno.dominada:
        return 'Dominada';
    }
  }
}

/// Calcula el estado del cuaderno a partir del estado del motor de
/// maestría. La regla esencial: el motor ya guarda el nivel real
/// (con decaimiento aplicado al jugar). El cuaderno solo lo refleja.
///
/// Caso especial: si el nivel es `inexplorada` pero hay exposiciones,
/// significa que el niño la tocó pero todavía no consolida — se
/// muestra como `vista`, no como `latente`.
EstadoCuaderno estadoCuadernoDe(EstadoHabilidad estado) {
  switch (estado.nivel) {
    case NivelMaestria.inexplorada:
      if (estado.totalExposiciones == 0) return EstadoCuaderno.latente;
      return EstadoCuaderno.vista;
    case NivelMaestria.introducida:
      return EstadoCuaderno.vista;
    case NivelMaestria.enDesarrollo:
      return EstadoCuaderno.practica;
    case NivelMaestria.competente:
      return EstadoCuaderno.firme;
    case NivelMaestria.maestria:
      return EstadoCuaderno.dominada;
  }
}

/// Estado del cuaderno cuando el niño nunca ha tocado la habilidad y
/// por tanto no hay registro en el repositorio. Conveniencia para que
/// la vista no tenga que distinguir entre "no existe registro" y
/// "existe pero vacío".
const EstadoCuaderno estadoCuadernoLatente = EstadoCuaderno.latente;
