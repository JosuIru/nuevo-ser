/// El taller de restauración (doc 16, eje B). La ciudad se recompone
/// pieza a pieza y es el niño quien elige cuál: una farola, unas
/// ventanas, una guirnalda de luces. Las esquirlas dejan de ser un
/// contador abstracto y pasan a ser material con destino.
///
/// Salvaguardas del doc 16 §6 codificadas aquí:
///
/// - **Precios planos**: toda pieza cuesta [CatalogoTaller.precioPlano].
///   Sin escalado, sin piezas "premium", sin escasez artificial. Es un
///   pueblo, no una tienda.
/// - Restaurar **no resta** esquirlas ganadas: los rangos narrativos y
///   los desbloqueos de distrito dependen del total ganado de por
///   vida. Lo gastado se apunta aparte (`RepositorioCiudad`) y lo
///   disponible es `ganadas - gastadas`.
/// - La voz del taller es **Rexán** (doc 04): cálido, sin aspavientos.
enum TipoPiezaVisual {
  /// Una farola de luz cálida con su poste.
  farol,

  /// Una hilera de ventanas que se encienden.
  ventanas,

  /// Una guirnalda de lucecitas colgada.
  guirnalda,
}

/// Una pieza restaurable de un distrito. Inmutable; el estado
/// (restaurada o no) vive en `RepositorioCiudad`, por perfil.
class PiezaCiudad {
  /// Identificador estable, `<distrito>.<pieza>`. Es lo que se
  /// persiste — no cambiarlo una vez publicado.
  final String id;

  /// Distrito al que pertenece (id del [CatalogoDistritos]).
  final String idDistrito;

  /// Nombre visible, en castellano canónico (se traduce en runtime
  /// con `traducirNarrativa`).
  final String nombre;

  /// Qué primitiva pinta el escenario cuando la pieza está
  /// restaurada.
  final TipoPiezaVisual tipoVisual;

  /// Posición relativa (0..1) dentro del escenario del cazadero del
  /// distrito. La franja urbana ocupa la banda inferior, así que las
  /// `y` útiles van de ~0.70 a ~0.90.
  final double xEscena;
  final double yEscena;

  const PiezaCiudad({
    required this.id,
    required this.idDistrito,
    required this.nombre,
    required this.tipoVisual,
    required this.xEscena,
    required this.yEscena,
  });
}

class CatalogoTaller {
  CatalogoTaller._();

  /// Precio único de toda pieza, en esquirlas. Plano a propósito.
  static const int precioPlano = 10;

  static const List<PiezaCiudad> todas = [
    // Tejados del Centro
    PiezaCiudad(
      id: 'tejados.farola_esquina',
      idDistrito: 'tejados',
      nombre: 'La farola de la esquina',
      tipoVisual: TipoPiezaVisual.farol,
      xEscena: 0.16,
      yEscena: 0.80,
    ),
    PiezaCiudad(
      id: 'tejados.ventanas_atico',
      idDistrito: 'tejados',
      nombre: 'Las ventanas del ático',
      tipoVisual: TipoPiezaVisual.ventanas,
      xEscena: 0.64,
      yEscena: 0.76,
    ),
    PiezaCiudad(
      id: 'tejados.guirnalda_patio',
      idDistrito: 'tejados',
      nombre: 'La guirnalda del patio',
      tipoVisual: TipoPiezaVisual.guirnalda,
      xEscena: 0.40,
      yEscena: 0.72,
    ),
    // Barrio de los Canales
    PiezaCiudad(
      id: 'canales.farolillo_puente',
      idDistrito: 'canales',
      nombre: 'El farolillo del puente',
      tipoVisual: TipoPiezaVisual.farol,
      xEscena: 0.20,
      yEscena: 0.78,
    ),
    PiezaCiudad(
      id: 'canales.ventanas_embarcadero',
      idDistrito: 'canales',
      nombre: 'Las ventanas del embarcadero',
      tipoVisual: TipoPiezaVisual.ventanas,
      xEscena: 0.68,
      yEscena: 0.78,
    ),
    PiezaCiudad(
      id: 'canales.luces_canal',
      idDistrito: 'canales',
      nombre: 'Las luces del canal',
      tipoVisual: TipoPiezaVisual.guirnalda,
      xEscena: 0.44,
      yEscena: 0.73,
    ),
    // Mercado de la Luz
    PiezaCiudad(
      id: 'mercado.farol_entrada',
      idDistrito: 'mercado',
      nombre: 'El farol de la entrada',
      tipoVisual: TipoPiezaVisual.farol,
      xEscena: 0.14,
      yEscena: 0.79,
    ),
    PiezaCiudad(
      id: 'mercado.ventanas_almacen',
      idDistrito: 'mercado',
      nombre: 'Las ventanas del almacén',
      tipoVisual: TipoPiezaVisual.ventanas,
      xEscena: 0.70,
      yEscena: 0.77,
    ),
    PiezaCiudad(
      id: 'mercado.guirnalda_toldos',
      idDistrito: 'mercado',
      nombre: 'La guirnalda de los toldos',
      tipoVisual: TipoPiezaVisual.guirnalda,
      xEscena: 0.42,
      yEscena: 0.71,
    ),
    // Zona Industrial
    PiezaCiudad(
      id: 'industria.lampara_taller',
      idDistrito: 'industria',
      nombre: 'La lámpara del taller viejo',
      tipoVisual: TipoPiezaVisual.farol,
      xEscena: 0.18,
      yEscena: 0.81,
    ),
    PiezaCiudad(
      id: 'industria.ventanas_nave',
      idDistrito: 'industria',
      nombre: 'Las ventanas de la nave',
      tipoVisual: TipoPiezaVisual.ventanas,
      xEscena: 0.62,
      yEscena: 0.79,
    ),
    PiezaCiudad(
      id: 'industria.luces_pasarela',
      idDistrito: 'industria',
      nombre: 'Las luces de la pasarela',
      tipoVisual: TipoPiezaVisual.guirnalda,
      xEscena: 0.40,
      yEscena: 0.74,
    ),
    // Puerto Silencioso
    PiezaCiudad(
      id: 'puerto.farol_muelle',
      idDistrito: 'puerto',
      nombre: 'El farol del muelle',
      tipoVisual: TipoPiezaVisual.farol,
      xEscena: 0.22,
      yEscena: 0.80,
    ),
    PiezaCiudad(
      id: 'puerto.ventanas_lonja',
      idDistrito: 'puerto',
      nombre: 'Las ventanas de la lonja',
      tipoVisual: TipoPiezaVisual.ventanas,
      xEscena: 0.66,
      yEscena: 0.77,
    ),
    PiezaCiudad(
      id: 'puerto.luces_espigon',
      idDistrito: 'puerto',
      nombre: 'Las luces del espigón',
      tipoVisual: TipoPiezaVisual.guirnalda,
      xEscena: 0.44,
      yEscena: 0.72,
    ),
    // Afueras
    PiezaCiudad(
      id: 'afueras.farol_sendero',
      idDistrito: 'afueras',
      nombre: 'El farol del sendero',
      tipoVisual: TipoPiezaVisual.farol,
      xEscena: 0.18,
      yEscena: 0.82,
    ),
    PiezaCiudad(
      id: 'afueras.ventanas_granja',
      idDistrito: 'afueras',
      nombre: 'Las ventanas de la granja',
      tipoVisual: TipoPiezaVisual.ventanas,
      xEscena: 0.66,
      yEscena: 0.80,
    ),
    PiezaCiudad(
      id: 'afueras.luces_observatorio',
      idDistrito: 'afueras',
      nombre: 'Las luces del observatorio',
      tipoVisual: TipoPiezaVisual.guirnalda,
      xEscena: 0.42,
      yEscena: 0.75,
    ),
    // La Montaña
    PiezaCiudad(
      id: 'montana.lampara_refugio',
      idDistrito: 'montana',
      nombre: 'La lámpara del refugio',
      tipoVisual: TipoPiezaVisual.farol,
      xEscena: 0.20,
      yEscena: 0.83,
    ),
    PiezaCiudad(
      id: 'montana.ventanas_estacion',
      idDistrito: 'montana',
      nombre: 'Las ventanas de la estación',
      tipoVisual: TipoPiezaVisual.ventanas,
      xEscena: 0.64,
      yEscena: 0.81,
    ),
    PiezaCiudad(
      id: 'montana.luces_senda',
      idDistrito: 'montana',
      nombre: 'Las luces de la senda alta',
      tipoVisual: TipoPiezaVisual.guirnalda,
      xEscena: 0.42,
      yEscena: 0.76,
    ),
  ];

  static List<PiezaCiudad> delDistrito(String idDistrito) =>
      todas.where((p) => p.idDistrito == idDistrito).toList();

  static PiezaCiudad? porId(String id) {
    for (final pieza in todas) {
      if (pieza.id == id) return pieza;
    }
    return null;
  }

  /// La línea de Rexán al restaurar una pieza, por tipo visual. En
  /// castellano canónico — la vista la pasa por `traducirNarrativa`.
  /// Sin euforia: Rexán agradece en voz baja (doc 01, principio 3).
  static String lineaRexanAlRestaurar(TipoPiezaVisual tipo) {
    switch (tipo) {
      case TipoPiezaVisual.farol:
        return 'Una luz más. La ciudad lo nota, aunque no lo diga.';
      case TipoPiezaVisual.ventanas:
        return 'Alguien vive mejor esta noche. Buen trabajo.';
      case TipoPiezaVisual.guirnalda:
        return 'Mira eso. Casi parece fiesta. Casi.';
    }
  }
}
