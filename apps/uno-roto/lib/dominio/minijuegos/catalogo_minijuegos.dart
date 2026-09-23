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
enum IdMinijuego {
  puentes,
  encaje,
  canales,
  parejas,
  minas,
  serpiente,
  balanza,
  flota,
  salto,
}

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

  /// Cómo se juega, para el botón de ayuda.
  final String comoSeJuega;

  const DefinicionMinijuego({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.lineaRexan,
    required this.habilidades,
    required this.rondasPorPartida,
    required this.comoSeJuega,
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
      comoSeJuega: 'Toca los tablones para ponerlos en el puente; tócalos otra vez para quitarlos. Cuando creas que cubren el hueco justo, pulsa PROBAR EL PUENTE.',
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
      comoSeJuega: 'Arrastra el dedo por el tablero para mover la barra y toca para soltarla. Cada fila llena es una unidad: busca las piezas que completan lo que falta.',
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
      comoSeJuega: 'Desliza el dedo o usa la cruceta. Recoge sólo los números que cumplen la regla y aléjate de las sombras: si te pillan, vuelves a la salida.',
    ),
    DefinicionMinijuego(
      id: IdMinijuego.parejas,
      nombre: 'Parejas',
      descripcion: 'Toca dos cartas que valgan lo mismo, aunque estén '
          'escritas distinto.',
      lineaRexan: 'Un medio, cero coma cinco, cincuenta por ciento. Tres '
          'trajes para la misma persona.',
      habilidades: ['FR.09', 'DEC.08', 'PROP.05'],
      rondasPorPartida: 3,
      comoSeJuega: 'Toca dos cartas que valgan lo mismo aunque estén escritas distinto. Si lo son, se retiran.',
    ),
    DefinicionMinijuego(
      id: IdMinijuego.minas,
      nombre: 'Minas',
      descripcion: 'Abre las casillas seguras y marca las minas. La regla '
          'dice cuáles son.',
      lineaRexan: 'Las minas no se esconden: cumplen la regla. Cada '
          'casilla abierta te dice cuántas tiene alrededor.',
      habilidades: ['DIV.01', 'DIV.03', 'DIV.04', 'DIV.05'],
      rondasPorPartida: 3,
      comoSeJuega: 'Con ABRIR tocas las casillas seguras; con MARCAR (o dejando el dedo) marcas las minas. La regla dice qué números son minas. El número pequeño de cada casilla abierta cuenta las minas vecinas.',
    ),
    DefinicionMinijuego(
      id: IdMinijuego.serpiente,
      nombre: 'Serpiente',
      descripcion: 'Lleva la serpiente hasta el resultado. Los otros números '
          'son las trampas de siempre.',
      lineaRexan: 'Una serpiente que come cuentas. No muere nunca: sólo '
          'tiene hambre.',
      habilidades: ['ARI.01', 'OP.01', 'ARI.02', 'FR.22', 'PROP.04'],
      rondasPorPartida: 3,
      comoSeJuega: 'Desliza el dedo o usa la cruceta. Lleva la serpiente al número que resuelve la cuenta. Los bordes se atraviesan. Desde la segunda ronda hay muros que rodear, y en la tercera los números se mueven.',
    ),
    DefinicionMinijuego(
      id: IdMinijuego.balanza,
      nombre: 'Balanza',
      descripcion: 'Prueba un valor para la x y mira hacia dónde se inclina.',
      lineaRexan: 'Una balanza no miente. Si baja un lado, algo pesa más.',
      habilidades: ['ALG.01', 'ALG.02'],
      rondasPorPartida: 6,
      comoSeJuega: 'Elige un valor para la x con − y + y pulsa PESAR. Si baja un lado, ese pesa más. Con AYÚDAME PASO A PASO ves cómo se despeja.',
    ),
    DefinicionMinijuego(
      id: IdMinijuego.flota,
      nombre: 'La flota',
      descripcion: 'Rexán canta las coordenadas en cálculo. Tú apuntas.',
      lineaRexan: 'Tres barcos escondidos en el Puerto. Yo canto, tú apuntas.',
      habilidades: ['PROP.04', 'FR.22'],
      rondasPorPartida: 2,
      comoSeJuega: 'Calcula la columna y la fila que canta Rexán y toca esa casilla. Hunde los tres barcos.',
    ),
    DefinicionMinijuego(
      id: IdMinijuego.salto,
      nombre: 'Salto',
      descripcion: 'El Fragmento corre solo. Toca para saltar y elige la '
          'puerta del resultado: arriba o abajo.',
      lineaRexan: 'Esta no para. Tú sólo decides cuándo saltar… y por qué '
          'puerta.',
      habilidades: ['ARI.01', 'OP.01', 'ARI.02', 'FR.22', 'PROP.04'],
      rondasPorPartida: 3,
      comoSeJuega: 'Toca para saltar. Esquiva pinchos, cajas y fosos. Antes de cada puerta decide: si la respuesta está arriba, salta a la plataforma; si está abajo, sigue por el suelo. En el último nivel, algunas cuentas usan el resultado de la puerta anterior.',
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
