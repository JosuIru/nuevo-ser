/// Un **anuncio** del tablón: lo que antes se pegaba en la puerta del bar o
/// del local. Un corte de agua, un taller, un plantón que se regala, la
/// excursión del sábado. No se vota ni se debate: se lee.
///
/// Publica cualquier participante. Quien lo publicó lo retira cuando
/// quiere; la mesa también, diciendo por qué, y es la que fija arriba lo
/// importante. Con fecha «hasta», sale solo del tablón pasado ese día.
library;

enum ProblemaAnuncio { faltaTitulo, tituloLargo, textoLargo, hastaPasado }

class Anuncio {
  const Anuncio({
    required this.uid,
    required this.titulo,
    required this.texto,
    required this.autorUid,
    required this.publicado,
    this.hasta,
    this.fijado = false,
    this.retirado = false,
    this.motivoRetirada = '',
  });

  /// Cuentan letras (puntos de código), como `mb_strlen` en el servidor.
  static const largoMaximoTitulo = 120;
  static const largoMaximoTexto = 2000;

  final String uid;
  final String titulo;
  final String texto;
  final String autorUid;
  final DateTime publicado;

  /// Último día en el tablón (incluido). `null`: hasta que se retire.
  final DateTime? hasta;

  /// La mesa lo pone arriba del todo.
  final bool fijado;
  final bool retirado;
  final String motivoRetirada;

  List<ProblemaAnuncio> problemas(DateTime ahora) {
    final limite = hasta;
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    return [
      if (titulo.trim().isEmpty) ProblemaAnuncio.faltaTitulo,
      if (titulo.trim().runes.length > largoMaximoTitulo)
        ProblemaAnuncio.tituloLargo,
      if (texto.trim().runes.length > largoMaximoTexto)
        ProblemaAnuncio.textoLargo,
      if (limite != null &&
          DateTime(limite.year, limite.month, limite.day).isBefore(hoy))
        ProblemaAnuncio.hastaPasado,
    ];
  }

  bool vigenteEn(DateTime ahora) {
    if (retirado) return false;
    final limite = hasta;
    if (limite == null) return true;
    return ahora.isBefore(DateTime(limite.year, limite.month, limite.day + 1));
  }

  Anuncio retirar({required String motivo}) {
    if (retirado) throw StateError('El anuncio ya está retirado');
    return _copiar(
        retirado: true, motivoRetirada: motivo.trim(), fijado: false);
  }

  Anuncio conFijado(bool nuevo) {
    if (retirado) throw StateError('El anuncio está retirado');
    return _copiar(fijado: nuevo);
  }

  Anuncio _copiar({bool? fijado, bool? retirado, String? motivoRetirada}) =>
      Anuncio(
        uid: uid,
        titulo: titulo,
        texto: texto,
        autorUid: autorUid,
        publicado: publicado,
        hasta: hasta,
        fijado: fijado ?? this.fijado,
        retirado: retirado ?? this.retirado,
        motivoRetirada: motivoRetirada ?? this.motivoRetirada,
      );
}
