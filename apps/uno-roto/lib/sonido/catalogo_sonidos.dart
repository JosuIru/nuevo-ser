import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Mapeo de identificadores lógicos a rutas de asset. Si un archivo no
/// existe todavía (placeholder), el motor sonoro tolera la ausencia y
/// la llamada es silenciosa.
///
/// Ids estables: código de juego invoca por id ("efecto_acierto",
/// "ambient_tejados") y el catálogo decide qué archivo suena. Esto
/// permite cambiar o sustituir assets sin tocar puntos de llamada.
class SonidoCatalogado {
  final String identificador;
  final CapaAudio capa;
  final String rutaAsset;
  final bool enBucle;

  const SonidoCatalogado({
    required this.identificador,
    required this.capa,
    required this.rutaAsset,
    this.enBucle = false,
  });
}

class CatalogoSonidos {
  static const Map<String, SonidoCatalogado> _porIdentificador = {
    // ═══ CAPA 3 · Efectos de interacción ═══
    'efecto_acierto': SonidoCatalogado(
      identificador: 'efecto_acierto',
      capa: CapaAudio.efectos,
      rutaAsset: 'assets/sonido/efectos/acierto.ogg',
    ),
    'efecto_error': SonidoCatalogado(
      identificador: 'efecto_error',
      capa: CapaAudio.efectos,
      rutaAsset: 'assets/sonido/efectos/error.ogg',
    ),
    'efecto_tap': SonidoCatalogado(
      identificador: 'efecto_tap',
      capa: CapaAudio.efectos,
      rutaAsset: 'assets/sonido/efectos/tap.ogg',
    ),
    'efecto_fusion': SonidoCatalogado(
      identificador: 'efecto_fusion',
      capa: CapaAudio.efectos,
      rutaAsset: 'assets/sonido/efectos/fusion.ogg',
    ),
    'efecto_ki_subiendo': SonidoCatalogado(
      identificador: 'efecto_ki_subiendo',
      capa: CapaAudio.efectos,
      rutaAsset: 'assets/sonido/efectos/ki_subiendo.ogg',
    ),
    'efecto_fragmento_disuelto': SonidoCatalogado(
      identificador: 'efecto_fragmento_disuelto',
      capa: CapaAudio.efectos,
      rutaAsset: 'assets/sonido/efectos/fragmento_disuelto.ogg',
    ),
    'efecto_whoosh': SonidoCatalogado(
      identificador: 'efecto_whoosh',
      capa: CapaAudio.efectos,
      rutaAsset: 'assets/sonido/efectos/whoosh.ogg',
    ),

    // Máquinas de Rexán (scripts/sonido/generar_musica_maquinas.py).
    'efecto_fila_completa': SonidoCatalogado(
      identificador: 'efecto_fila_completa',
      capa: CapaAudio.efectos,
      rutaAsset: 'assets/sonido/efectos/fila_completa.ogg',
    ),
    'efecto_tablon': SonidoCatalogado(
      identificador: 'efecto_tablon',
      capa: CapaAudio.efectos,
      rutaAsset: 'assets/sonido/efectos/tablon.ogg',
    ),

    // ═══ CAPA 1 · Ambient por distrito ═══
    'ambient_tejados': SonidoCatalogado(
      identificador: 'ambient_tejados',
      capa: CapaAudio.ambient,
      rutaAsset: 'assets/sonido/ambient/tejados.ogg',
      enBucle: true,
    ),
    'ambient_canales': SonidoCatalogado(
      identificador: 'ambient_canales',
      capa: CapaAudio.ambient,
      rutaAsset: 'assets/sonido/ambient/canales.ogg',
      enBucle: true,
    ),
    'ambient_mercado': SonidoCatalogado(
      identificador: 'ambient_mercado',
      capa: CapaAudio.ambient,
      rutaAsset: 'assets/sonido/ambient/mercado.ogg',
      enBucle: true,
    ),
    'ambient_industria': SonidoCatalogado(
      identificador: 'ambient_industria',
      capa: CapaAudio.ambient,
      rutaAsset: 'assets/sonido/ambient/industria.ogg',
      enBucle: true,
    ),
    'ambient_puerto': SonidoCatalogado(
      identificador: 'ambient_puerto',
      capa: CapaAudio.ambient,
      rutaAsset: 'assets/sonido/ambient/puerto.ogg',
      enBucle: true,
    ),
    'ambient_afueras': SonidoCatalogado(
      identificador: 'ambient_afueras',
      capa: CapaAudio.ambient,
      rutaAsset: 'assets/sonido/ambient/afueras.ogg',
      enBucle: true,
    ),

    // ═══ CAPA 2 · Música por distrito y combate ═══
    // Música de las máquinas de Rexán: bucles sintetizados sin samples
    // (scripts/sonido/generar_musica_maquinas.py), en el tono de su
    // distrito: Puerto, Tejados y Canales.
    'musica_maquina_puentes': SonidoCatalogado(
      identificador: 'musica_maquina_puentes',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_puentes.ogg',
      enBucle: true,
    ),
    'musica_maquina_encaje': SonidoCatalogado(
      identificador: 'musica_maquina_encaje',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_encaje.ogg',
      enBucle: true,
    ),
    'musica_maquina_canales': SonidoCatalogado(
      identificador: 'musica_maquina_canales',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_canales.ogg',
      enBucle: true,
    ),
    'musica_maquina_parejas': SonidoCatalogado(
      identificador: 'musica_maquina_parejas',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_parejas.ogg',
      enBucle: true,
    ),
    'musica_maquina_minas': SonidoCatalogado(
      identificador: 'musica_maquina_minas',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_minas.ogg',
      enBucle: true,
    ),
    'musica_maquina_serpiente': SonidoCatalogado(
      identificador: 'musica_maquina_serpiente',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_serpiente.ogg',
      enBucle: true,
    ),
    'musica_maquina_balanza': SonidoCatalogado(
      identificador: 'musica_maquina_balanza',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_balanza.ogg',
      enBucle: true,
    ),
    'musica_maquina_flota': SonidoCatalogado(
      identificador: 'musica_maquina_flota',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_flota.ogg',
      enBucle: true,
    ),
    'musica_maquina_salto': SonidoCatalogado(
      identificador: 'musica_maquina_salto',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_salto.ogg',
      enBucle: true,
    ),
    'musica_maquina_engranajes': SonidoCatalogado(
      identificador: 'musica_maquina_engranajes',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_engranajes.ogg',
      enBucle: true,
    ),
    'musica_maquina_esclusas': SonidoCatalogado(
      identificador: 'musica_maquina_esclusas',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_esclusas.ogg',
      enBucle: true,
    ),
    'musica_maquina_planos': SonidoCatalogado(
      identificador: 'musica_maquina_planos',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_planos.ogg',
      enBucle: true,
    ),
    'musica_maquina_redes': SonidoCatalogado(
      identificador: 'musica_maquina_redes',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_redes.ogg',
      enBucle: true,
    ),
    'musica_maquina_nivelar': SonidoCatalogado(
      identificador: 'musica_maquina_nivelar',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_nivelar.ogg',
      enBucle: true,
    ),
    'musica_maquina_caja_negra': SonidoCatalogado(
      identificador: 'musica_maquina_caja_negra',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_caja_negra.ogg',
      enBucle: true,
    ),
    'musica_maquina_pozo': SonidoCatalogado(
      identificador: 'musica_maquina_pozo',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_pozo.ogg',
      enBucle: true,
    ),
    'musica_maquina_pinturas': SonidoCatalogado(
      identificador: 'musica_maquina_pinturas',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/maquina_pinturas.ogg',
      enBucle: true,
    ),
    'musica_tejados': SonidoCatalogado(
      identificador: 'musica_tejados',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/tejados.ogg',
      enBucle: true,
    ),
    'musica_canales': SonidoCatalogado(
      identificador: 'musica_canales',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/canales.ogg',
      enBucle: true,
    ),
    'musica_mercado': SonidoCatalogado(
      identificador: 'musica_mercado',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/mercado.ogg',
      enBucle: true,
    ),
    'musica_industria': SonidoCatalogado(
      identificador: 'musica_industria',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/industria.ogg',
      enBucle: true,
    ),
    'musica_puerto': SonidoCatalogado(
      identificador: 'musica_puerto',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/puerto.ogg',
      enBucle: true,
    ),
    'musica_afueras': SonidoCatalogado(
      identificador: 'musica_afueras',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/afueras.ogg',
      enBucle: true,
    ),
    'musica_combate_cotidiano': SonidoCatalogado(
      identificador: 'musica_combate_cotidiano',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/combate_cotidiano.ogg',
      enBucle: true,
    ),
    'musica_combate_kurz': SonidoCatalogado(
      identificador: 'musica_combate_kurz',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/combate_kurz.ogg',
      enBucle: true,
    ),
    'musica_combate_zafran': SonidoCatalogado(
      identificador: 'musica_combate_zafran',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/combate_zafran.ogg',
      enBucle: true,
    ),
    'musica_combate_vorax': SonidoCatalogado(
      identificador: 'musica_combate_vorax',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/combate_vorax.ogg',
      enBucle: true,
    ),
    'musica_ceremonia': SonidoCatalogado(
      identificador: 'musica_ceremonia',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/ceremonia.ogg',
      enBucle: false,
    ),
    'musica_amanecer_final': SonidoCatalogado(
      identificador: 'musica_amanecer_final',
      capa: CapaAudio.musica,
      rutaAsset: 'assets/sonido/musica/amanecer_final.ogg',
      enBucle: false,
    ),

    // ═══ CAPA 2 / Narrativos · Motivos recurrentes ═══
    'motivo_sora': SonidoCatalogado(
      identificador: 'motivo_sora',
      capa: CapaAudio.narrativos,
      rutaAsset: 'assets/sonido/narrativos/motivo_sora.ogg',
    ),
    'motivo_kai': SonidoCatalogado(
      identificador: 'motivo_kai',
      capa: CapaAudio.narrativos,
      rutaAsset: 'assets/sonido/narrativos/motivo_kai.ogg',
    ),
    'motivo_montana': SonidoCatalogado(
      identificador: 'motivo_montana',
      capa: CapaAudio.narrativos,
      rutaAsset: 'assets/sonido/narrativos/motivo_montana.ogg',
    ),
    'motivo_eco': SonidoCatalogado(
      identificador: 'motivo_eco',
      capa: CapaAudio.narrativos,
      rutaAsset: 'assets/sonido/narrativos/motivo_eco.ogg',
    ),

    // ═══ CAPA 4 · Efectos narrativos únicos ═══
    'narrativo_silbido_zafran': SonidoCatalogado(
      identificador: 'narrativo_silbido_zafran',
      capa: CapaAudio.narrativos,
      rutaAsset: 'assets/sonido/narrativos/silbido_zafran.ogg',
    ),
    'narrativo_voz_eco': SonidoCatalogado(
      identificador: 'narrativo_voz_eco',
      capa: CapaAudio.narrativos,
      rutaAsset: 'assets/sonido/narrativos/voz_eco.ogg',
    ),
    'narrativo_mundo_baja': SonidoCatalogado(
      identificador: 'narrativo_mundo_baja',
      capa: CapaAudio.narrativos,
      rutaAsset: 'assets/sonido/narrativos/mundo_baja.ogg',
    ),
  };

  static SonidoCatalogado? obtener(String identificador) =>
      _porIdentificador[identificador];

  /// Ambient asociado al id de distrito. Devuelve null si no hay
  /// mapeo — el motor lo interpreta como "no cambiar ambient".
  static String? ambientDeDistrito(String idDistrito) {
    const mapa = {
      'tejados': 'ambient_tejados',
      'canales': 'ambient_canales',
      'mercado': 'ambient_mercado',
      'industria': 'ambient_industria',
      'puerto': 'ambient_puerto',
      'afueras': 'ambient_afueras',
    };
    return mapa[idDistrito];
  }

  /// Loop musical del distrito.
  static String? musicaDeDistrito(String idDistrito) {
    const mapa = {
      'tejados': 'musica_tejados',
      'canales': 'musica_canales',
      'mercado': 'musica_mercado',
      'industria': 'musica_industria',
      'puerto': 'musica_puerto',
      'afueras': 'musica_afueras',
    };
    return mapa[idDistrito];
  }

  /// Loop musical del combate, según identificador de desafío nombrado
  /// o null para combate cotidiano.
  static String musicaDeCombate(String? idDesafio) {
    switch (idDesafio) {
      case 'kurz_1':
      case 'kurz_2':
      case 'kurz_3':
        return 'musica_combate_kurz';
      case 'zafran':
        return 'musica_combate_zafran';
      case 'vorax':
        return 'musica_combate_vorax';
      default:
        return 'musica_combate_cotidiano';
    }
  }
}
