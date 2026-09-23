import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Las máquinas de Rexán: minijuegos clásicos (puentes, tetris,
/// comecocos…) que se resuelven con matemáticas del nivel del niño.
///
/// Salvaguardas del doc 01 codificadas aquí y en cada máquina:
/// - Sin puntos, récords, vidas ni "game over" (principio 3).
/// - Una máquina sólo aparece cuando el niño YA ha practicado alguna de
///   sus habilidades: las máquinas repasan, no enseñan temas nuevos.
/// - La dificultad sale de su nivel real de maestría (principio 5).
/// - Cada partida tiene un número fijo de rondas y termina con un
///   cierre amable de Rexán (principio 7).
enum IdMinijuego { puentes, encaje, canales }

class DefinicionMinijuego {
  final IdMinijuego id;
  final String nombre;

  /// Qué se hace, en una línea (castellano; se traduce con
  /// `traducirNarrativa`).
  final String descripcion;

  /// Lo que dice Rexán al presentar la máquina.
  final String lineaRexan;

  /// Habilidades que la máquina ejercita. Basta con haber practicado
  /// una para que la máquina esté disponible.
  final List<String> habilidades;

  /// Rondas por partida antes del cierre amable.
  final int rondasPorPartida;

  const DefinicionMinijuego({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.lineaRexan,
    required this.habilidades,
    required this.rondasPorPartida,
  });
}

class CatalogoMinijuegos {
  static const todos = <DefinicionMinijuego>[
    DefinicionMinijuego(
      id: IdMinijuego.puentes,
      nombre: 'Puentes',
      descripcion: 'Cubre el hueco con tablones. El carro sólo cruza si '
          'la medida es exacta.',
      lineaRexan: 'Tablones sueltos del Puerto. Si no llegan justos, el '
          'carro no pasa. Mide antes.',
      habilidades: ['FR.14', 'FR.16', 'DEC.04'],
      rondasPorPartida: 5,
    ),
    DefinicionMinijuego(
      id: IdMinijuego.encaje,
      nombre: 'Encaje',
      descripcion: 'Caen trozos de fracción. Cada fila completa es una '
          'unidad entera.',
      lineaRexan: 'Una máquina vieja de los recreativos. Cada fila '
          'llena es un uno. Con eso basta.',
      habilidades: ['FR.09', 'FR.14', 'FR.16'],
      rondasPorPartida: 6,
    ),
    DefinicionMinijuego(
      id: IdMinijuego.canales,
      nombre: 'Canales',
      descripcion: 'Recorre el laberinto y cómete sólo los números que '
          'cumplen la regla.',
      lineaRexan: 'Las sombras de los Canales son lentas. Tú eliges qué '
          'números recoges.',
      habilidades: ['DIV.01', 'DIV.03', 'DIV.05', 'DEC.02', 'FR.03'],
      rondasPorPartida: 3,
    ),
  ];

  static DefinicionMinijuego de(IdMinijuego id) =>
      todos.firstWhere((definicion) => definicion.id == id);
}

class DisponibilidadMinijuego {
  /// Habilidades de la máquina que el niño ya ha practicado.
  final List<String> habilidadesPracticadas;

  /// 1 (introducida o en desarrollo), 2 (competente) o 3 (maestría),
  /// según la mejor de sus habilidades practicadas.
  final int dificultad;

  const DisponibilidadMinijuego({
    required this.habilidadesPracticadas,
    required this.dificultad,
  });

  bool get disponible => habilidadesPracticadas.isNotEmpty;
}

DisponibilidadMinijuego disponibilidadMinijuego(
  DefinicionMinijuego definicion,
  Map<String, EstadoHabilidad?> estadosPorHabilidad,
) {
  final practicadas = <String>[];
  var mejorNivel = NivelMaestria.inexplorada;
  for (final idHabilidad in definicion.habilidades) {
    final estado = estadosPorHabilidad[idHabilidad];
    if (estado == null || estado.nivel == NivelMaestria.inexplorada) continue;
    practicadas.add(idHabilidad);
    if (estado.nivel.index > mejorNivel.index) mejorNivel = estado.nivel;
  }
  final dificultad = switch (mejorNivel) {
    NivelMaestria.maestria => 3,
    NivelMaestria.competente => 2,
    _ => 1,
  };
  return DisponibilidadMinijuego(
    habilidadesPracticadas: practicadas,
    dificultad: dificultad,
  );
}
