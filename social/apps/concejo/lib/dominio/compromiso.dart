/// Lo que queda después de decidir: **qué, quién y para cuándo**
/// (`docs/04-concejo.md` §4.6). Con todos los compromisos del año se hace
/// la página «¿Se ha hecho?», que es la que más confianza da: que la
/// participación no sea teatro.
library;

enum EstadoCompromiso {
  pendiente,
  enMarcha,
  hecho,

  /// Con motivo obligatorio: también es información para el pueblo.
  noSeHara,
}

class Compromiso {
  const Compromiso({
    required this.uid,
    required this.asuntoUid,
    required this.que,
    required this.responsable,
    required this.fechaLimite,
    this.estado = EstadoCompromiso.pendiente,
    this.nota = '',
  });

  final String uid;
  final String asuntoUid;
  final String que;

  /// Persona, comisión o el propio órgano («la junta»). Texto libre: no
  /// siempre es alguien con cuenta en la app.
  final String responsable;
  final DateTime fechaLimite;
  final EstadoCompromiso estado;

  /// Cómo se hizo, o por qué no se hará.
  final String nota;

  bool get cerrado =>
      estado == EstadoCompromiso.hecho || estado == EstadoCompromiso.noSeHara;

  /// Vencido = pasó la fecha y sigue abierto. Se compara por día: un
  /// compromiso para el 15 vence el 16.
  bool vencidoEn(DateTime ahora) {
    if (cerrado) return false;
    final limite =
        DateTime(fechaLimite.year, fechaLimite.month, fechaLimite.day + 1);
    return !ahora.isBefore(limite);
  }

  Compromiso cambiarEstado(EstadoCompromiso nuevo, {String nota = ''}) {
    if (nuevo == EstadoCompromiso.noSeHara && nota.trim().isEmpty) {
      throw ArgumentError('Si no se hará, hay que decir por qué');
    }
    return Compromiso(
      uid: uid,
      asuntoUid: asuntoUid,
      que: que,
      responsable: responsable,
      fechaLimite: fechaLimite,
      estado: nuevo,
      nota: nota.isEmpty ? this.nota : nota,
    );
  }
}

/// Resumen para la página «¿Se ha hecho?».
class BalanceCompromisos {
  BalanceCompromisos(List<Compromiso> compromisos, DateTime ahora)
      : total = compromisos.length,
        hechos =
            compromisos.where((c) => c.estado == EstadoCompromiso.hecho).length,
        noSeHaran = compromisos
            .where((c) => c.estado == EstadoCompromiso.noSeHara)
            .length,
        vencidos = compromisos.where((c) => c.vencidoEn(ahora)).length,
        abiertos = compromisos.where((c) => !c.cerrado).length;

  final int total;
  final int hechos;
  final int noSeHaran;
  final int vencidos;
  final int abiertos;
}
