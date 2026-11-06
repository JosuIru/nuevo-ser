/// Debate con orden, **no un chat** (`docs/04-concejo.md` §4.3): cada
/// aportación se etiqueta y se ven en columnas; las respuestas tienen un
/// solo nivel; no hay «me gusta» ni contadores (apoyar es decir por qué).
library;

enum TipoAportacion { aFavor, enContra, duda, propuestaDeCambio }

enum EstadoModeracion {
  visible,

  /// Anónima a la espera de que la mesa la vea.
  pendiente,

  /// Retirada por la mesa, con motivo. En el debate queda el hueco
  /// («retirada por la mesa: …»), no desaparece sin más.
  retirada,
}

class Aportacion {
  const Aportacion({
    required this.uid,
    required this.asuntoUid,
    required this.autorUid,
    required this.tipo,
    required this.texto,
    required this.creada,
    this.respondeAUid,
    this.anonima = false,
    this.estado = EstadoModeracion.visible,
    this.motivoRetirada = '',
  });

  final String uid;
  final String asuntoUid;

  /// Siempre se guarda (la mesa tiene que poder moderar y evitar abusos);
  /// si es [anonima], no se enseña a nadie más que a la mesa.
  final String autorUid;
  final TipoAportacion tipo;
  final String texto;
  final DateTime creada;

  /// Respuesta a otra aportación. Solo un nivel: no se responde a una
  /// respuesta.
  final String? respondeAUid;
  final bool anonima;
  final EstadoModeracion estado;
  final String motivoRetirada;

  bool get esRespuesta => respondeAUid != null;
}

class Debate {
  const Debate(
      {required this.asuntoUid,
      this.aportaciones = const [],
      this.resumenMesa = ''});

  final String asuntoUid;
  final List<Aportacion> aportaciones;

  /// Resumen del debate que escribe la mesa y se fija arriba.
  final String resumenMesa;

  /// Las anónimas entran pendientes de moderación.
  Debate aportar(Aportacion nueva) {
    if (nueva.texto.trim().isEmpty) {
      throw ArgumentError('Una aportación vacía no aporta');
    }
    if (nueva.respondeAUid != null) {
      final original = aportaciones.where((a) => a.uid == nueva.respondeAUid);
      if (original.isEmpty) {
        throw ArgumentError('No existe la aportación a la que responde');
      }
      if (original.first.esRespuesta) {
        throw ArgumentError('Solo un nivel de respuestas');
      }
    }
    final guardada = nueva.anonima
        ? Aportacion(
            uid: nueva.uid,
            asuntoUid: nueva.asuntoUid,
            autorUid: nueva.autorUid,
            tipo: nueva.tipo,
            texto: nueva.texto,
            creada: nueva.creada,
            respondeAUid: nueva.respondeAUid,
            anonima: true,
            estado: EstadoModeracion.pendiente,
          )
        : nueva;
    return Debate(
      asuntoUid: asuntoUid,
      aportaciones: [...aportaciones, guardada],
      resumenMesa: resumenMesa,
    );
  }

  /// La mesa publica una anónima pendiente o retira una aportación (con
  /// motivo: queda el hueco a la vista, no desaparece sin más).
  Debate moderar(String uid, EstadoModeracion nuevo, {String motivo = ''}) {
    if (nuevo == EstadoModeracion.pendiente) {
      throw ArgumentError('Moderar es publicar o retirar');
    }
    if (nuevo == EstadoModeracion.retirada && motivo.trim().isEmpty) {
      throw ArgumentError('Para retirar una aportación hay que decir por qué');
    }
    if (!aportaciones.any((a) => a.uid == uid)) {
      throw ArgumentError('No existe la aportación $uid');
    }
    return Debate(
      asuntoUid: asuntoUid,
      resumenMesa: resumenMesa,
      aportaciones: [
        for (final a in aportaciones)
          a.uid == uid
              ? Aportacion(
                  uid: a.uid,
                  asuntoUid: a.asuntoUid,
                  autorUid: a.autorUid,
                  tipo: a.tipo,
                  texto: a.texto,
                  creada: a.creada,
                  respondeAUid: a.respondeAUid,
                  anonima: a.anonima,
                  estado: nuevo,
                  motivoRetirada:
                      nuevo == EstadoModeracion.retirada ? motivo.trim() : '',
                )
              : a,
      ],
    );
  }

  Debate conResumen(String resumen) => Debate(
        asuntoUid: asuntoUid,
        aportaciones: aportaciones,
        resumenMesa: resumen.trim(),
      );

  List<Aportacion> get pendientesDeModerar => [
        for (final a in aportaciones)
          if (a.estado == EstadoModeracion.pendiente) a,
      ];

  /// Aportaciones principales (no respuestas) de un tipo, en orden de
  /// llegada. [paraLaMesa] incluye las pendientes de moderación.
  List<Aportacion> columna(TipoAportacion tipo, {bool paraLaMesa = false}) => [
        for (final a in aportaciones)
          if (a.tipo == tipo && !a.esRespuesta && _visiblePara(a, paraLaMesa))
            a,
      ];

  List<Aportacion> respuestasA(String uid, {bool paraLaMesa = false}) => [
        for (final a in aportaciones)
          if (a.respondeAUid == uid && _visiblePara(a, paraLaMesa)) a,
      ];

  bool _visiblePara(Aportacion a, bool paraLaMesa) =>
      a.estado != EstadoModeracion.pendiente || paraLaMesa;
}
