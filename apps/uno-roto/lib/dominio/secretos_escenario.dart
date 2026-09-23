/// Secretos espaciales (doc 16, eje E): puntos tocables NO señalizados
/// en el escenario del cazadero. Nada brilla, nada avisa — el niño que
/// toca el mundo por curiosidad, encuentra. Al descubrir uno se activa
/// un flag que desbloquea su entrada del Cuaderno.
///
/// Reglas:
///
/// - **Cero señalización**: sin glow, sin badge, sin contador de
///   "secretos restantes". Los secretos generan conversación entre
///   niños ("¿tocaste el farolillo del puente?") justo porque el juego
///   no los delata.
/// - Recompensa = conocimiento (entrada del Cuaderno + línea de Sora),
///   nunca esquirlas — la curiosidad no se paga, se honra.
/// - Se descubre una vez por perfil; después la zona deja de escuchar.
class SecretoEscenario {
  /// Identificador estable (se persiste dentro del flag).
  final String id;

  /// Distrito en cuyo cazadero vive el punto.
  final String idDistrito;

  /// Centro de la zona tocable, relativo (0..1) al lienzo del
  /// cazadero. Debe caer sobre un elemento pintado real del distrito
  /// (una ventana del skyline, el puente…) para que el hallazgo tenga
  /// sentido al recordarlo.
  final double xEscena;
  final double yEscena;

  /// Línea de Sora al descubrirlo.
  final String lineaSora;

  const SecretoEscenario({
    required this.id,
    required this.idDistrito,
    required this.xEscena,
    required this.yEscena,
    required this.lineaSora,
  });

  /// Flag narrativo al descubrirlo. Desbloquea la entrada del Cuaderno.
  String get flagDescubierto => 'secreto_${id}_descubierto';
}

class CatalogoSecretos {
  CatalogoSecretos._();

  /// Radio de la zona tocable, en píxeles lógicos. Generoso para
  /// dedos de niño, pequeño para que siga siendo un hallazgo.
  static const double radioToquePx = 26;

  static const List<SecretoEscenario> todos = [
    // La ventana del gato — Tejados, en el skyline de ventanas ámbar.
    SecretoEscenario(
      id: 'ventana_gato',
      idDistrito: 'tejados',
      xEscena: 0.82,
      yEscena: 0.84,
      lineaSora: 'Ahí vive el gato de Irune. No se lo digas a nadie.',
    ),
    // El farolillo apagado — Canales, junto al puente bajo.
    SecretoEscenario(
      id: 'farolillo_apagado',
      idDistrito: 'canales',
      xEscena: 0.34,
      yEscena: 0.42,
      lineaSora: 'Ese farolillo lleva años sin luz. Hasta ahora, parece.',
    ),
  ];

  static List<SecretoEscenario> delDistrito(String idDistrito) =>
      todos.where((s) => s.idDistrito == idDistrito).toList();
}
