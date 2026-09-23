import 'ambiente_cielo.dart';

/// Fragmentos raros de clima (doc 16, eje E). Cada uno solo aparece
/// en UN distrito bajo UN ambiente concreto — el clima deja de ser
/// decorado y pasa a ser información de caza: el niño que lee el Faro
/// y observa el cielo, encuentra.
///
/// Reglas de diseño:
///
/// - **Curiosidad, no escasez comercial** (doc 16 §2): el raro no da
///   más esquirlas ni premios. Su recompensa es conocimiento — al
///   capturarlo se activa un flag y aparece su entrada en el Cuaderno
///   de Irune.
/// - **Se captura una vez** por perfil (la rareza es de colección,
///   no de granja). Después deja de aparecer.
/// - **Sin ansiedad**: si se escapa, vuelve a aparecer en la misma
///   sesión u otro día con el mismo clima. Nada se pierde para
///   siempre.
/// - El puzzle que plantea es uno normal del distrito: la rareza
///   está en el encuentro, no en la dificultad.
class FragmentoDeClima {
  /// Identificador estable (se persiste dentro del flag de captura).
  final String id;

  /// Distrito único donde habita.
  final String idDistrito;

  /// Ambiente del cielo que tiene que tocar ese día en el distrito
  /// ([ClimaDistrito.delDia]) para que aparezca.
  final AmbienteCielo ambienteRequerido;

  /// Nombre propio, en castellano canónico.
  final String nombre;

  /// Línea de Sora cuando el raro aparece en el tejado.
  final String lineaSoraAlAparecer;

  /// Línea de Sora al capturarlo (revela el nombre).
  final String lineaSoraAlCapturar;

  const FragmentoDeClima({
    required this.id,
    required this.idDistrito,
    required this.ambienteRequerido,
    required this.nombre,
    required this.lineaSoraAlAparecer,
    required this.lineaSoraAlCapturar,
  });

  /// Flag narrativo que se activa al capturarlo. Desbloquea la
  /// entrada correspondiente del Cuaderno.
  String get flagCaptura => 'clima_${id}_capturado';
}

class CatalogoFragmentosDeClima {
  CatalogoFragmentosDeClima._();

  static const List<FragmentoDeClima> todos = [
    // Tejados + lluvia: alcanzable en los primeros días de juego —
    // el primer "avistamiento raro" del doc 16 (eje F, sesión 2).
    FragmentoDeClima(
      id: 'la_veleta',
      idDistrito: 'tejados',
      ambienteRequerido: AmbienteCielo.lluviaLigera,
      nombre: 'La Veleta',
      lineaSoraAlAparecer: 'Espera. Ese brillo no es normal. Ve.',
      lineaSoraAlCapturar:
          '«La Veleta». Solo baja cuando llueve en los Tejados. '
          'Irune querrá saberlo — mira el cuaderno.',
    ),
    FragmentoDeClima(
      id: 'el_reflejo',
      idDistrito: 'canales',
      ambienteRequerido: AmbienteCielo.niebla,
      nombre: 'El Reflejo',
      lineaSoraAlAparecer: 'Ahí. En el agua. No parpadees.',
      lineaSoraAlCapturar:
          '«El Reflejo». Vive en la niebla de los Canales. '
          'Casi nadie lo ha visto dos veces. Apúntalo en el cuaderno.',
    ),
    FragmentoDeClima(
      id: 'la_lucerna',
      idDistrito: 'puerto',
      ambienteRequerido: AmbienteCielo.niebla,
      nombre: 'La Lucerna',
      lineaSoraAlAparecer: 'Esa luz entre la niebla no es del faro. Ve.',
      lineaSoraAlCapturar:
          '«La Lucerna». Los del Puerto juran que guía barcos perdidos. '
          'Ahora está en tu cuaderno.',
    ),
    FragmentoDeClima(
      id: 'el_vilano',
      idDistrito: 'afueras',
      ambienteRequerido: AmbienteCielo.lluviaLigera,
      nombre: 'El Vilano',
      lineaSoraAlAparecer: 'Mira. Flota distinto que los demás. Corre.',
      lineaSoraAlCapturar:
          '«El Vilano». Solo se deja ver cuando llueve en las Afueras, '
          'y allí casi nunca llueve. Al cuaderno.',
    ),
  ];

  /// El raro que toca hoy en [idDistrito] con el [ambiente] resuelto,
  /// o `null` si no hay ninguno (distrito sin raro, clima que no
  /// acompaña, o ya capturado en este perfil).
  static FragmentoDeClima? paraHoy({
    required String idDistrito,
    required AmbienteCielo ambiente,
    required Set<String> flagsActivos,
  }) {
    for (final raro in todos) {
      if (raro.idDistrito != idDistrito) continue;
      if (raro.ambienteRequerido != ambiente) continue;
      if (flagsActivos.contains(raro.flagCaptura)) continue;
      return raro;
    }
    return null;
  }
}
