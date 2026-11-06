/// Las personas de un pueblo o colectivo y sus **roles rotativos con fecha
/// de fin** (`docs/04-concejo.md` §4.1): «roles, no personas».
library;

enum Rol {
  /// Participa: opina, vota, objeta.
  vecina,

  /// Abre asuntos, modera, apunta votos en papel y firma el acta.
  mesa,

  /// Da de alta a la gente y reparte los roles.
  coordinacion,
}

class Persona {
  const Persona({
    required this.uid,
    required this.nombre,
    this.rol = Rol.vecina,
    this.mandatoHasta,
  });

  final String uid;
  final String nombre;
  final Rol rol;

  /// Fin del mandato de [Rol.mesa] o [Rol.coordinacion]. Pasada la fecha,
  /// la persona vuelve a ser vecina hasta que alguien renueve o rote el
  /// rol: nadie se queda en un cargo por olvido.
  final DateTime? mandatoHasta;

  Rol rolEn(DateTime ahora) {
    if (rol == Rol.vecina || mandatoHasta == null) return rol;
    return ahora.isAfter(mandatoHasta!) ? Rol.vecina : rol;
  }

  bool esMesaEn(DateTime ahora) => rolEn(ahora) != Rol.vecina;

  /// Días que quedan de mandato (para avisar de que toca rotar), o `null`
  /// si no tiene cargo o no tiene fecha de fin.
  int? diasDeMandatoEn(DateTime ahora) {
    if (rol == Rol.vecina || mandatoHasta == null) return null;
    final dias = mandatoHasta!.difference(ahora).inDays;
    return dias < 0 ? 0 : dias;
  }
}
