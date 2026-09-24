import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Un sonido del juego: dónde está y por qué capa suena.
class SonidoArchivo {
  const SonidoArchivo({
    required this.identificador,
    required this.rutaAsset,
    required this.capa,
    this.enBucle = false,
  });

  final String identificador;
  final String rutaAsset;
  final CapaAudio capa;
  final bool enBucle;
}

/// Catálogo de sonidos de Las Versiones.
///
/// Sigue la guía sonora (doc 12): todo es diegético (papel, madera,
/// latón, lluvia), no hay «chime» de acierto y un error no suena. La
/// música no va en bucle nunca: son fragmentos de capa histórica de
/// 15-25 s que suenan una vez al cerrar un oficio (§2.4).
///
/// Los OGG no se versionan (se regeneran con
/// `scripts/sonido/generar_sonidos_archivo.py`). Si falta uno, el
/// servicio lo calla sin romper nada.
class CatalogoSonidosArchivo {
  CatalogoSonidosArchivo._();

  static const _efectos = 'assets/sonido/efectos';
  static const _ambiente = 'assets/sonido/ambiente';
  static const _fragmentos = 'assets/sonido/fragmentos';

  // ─── Efectos de objeto ────────────────────────────────────────────
  static const papelTomar = 'papel_tomar';
  static const papelDejar = 'papel_dejar';
  static const cartulinaEnMimbre = 'cartulina_en_mimbre';
  static const pinzaMadera = 'pinza_madera';
  static const balanzaLaton = 'balanza_laton';
  static const cajaAbrir = 'caja_abrir';

  // ─── Ambiente ─────────────────────────────────────────────────────
  static const ambienteAtico = 'ambiente_atico';

  /// Id del fragmento musical de una capa histórica (`D-NEO` →
  /// `fragmento_d_neo`).
  static String fragmentoDeCapa(String codigoCapa) =>
      'fragmento_${codigoCapa.toLowerCase().replaceAll('-', '_')}';

  static const codigosCapa = <String>[
    'D-PALEO',
    'D-NEO',
    'D-PROTO',
    'D-ROMANA',
    'D-ANTIQ',
    'D-FORM',
    'D-PLENA',
    'D-DINASTIAS',
  ];

  static final Map<String, SonidoArchivo> _porId = {
    for (final id in [
      papelTomar,
      papelDejar,
      cartulinaEnMimbre,
      pinzaMadera,
      balanzaLaton,
      cajaAbrir,
    ])
      id: SonidoArchivo(
        identificador: id,
        rutaAsset: '$_efectos/$id.ogg',
        capa: CapaAudio.efectos,
      ),
    ambienteAtico: const SonidoArchivo(
      identificador: ambienteAtico,
      rutaAsset: '$_ambiente/$ambienteAtico.ogg',
      capa: CapaAudio.ambient,
      enBucle: true,
    ),
    for (final codigo in codigosCapa)
      fragmentoDeCapa(codigo): SonidoArchivo(
        identificador: fragmentoDeCapa(codigo),
        rutaAsset: '$_fragmentos/${fragmentoDeCapa(codigo)}.ogg',
        capa: CapaAudio.musica,
      ),
  };

  static SonidoArchivo? obtener(String identificador) => _porId[identificador];

  static Iterable<SonidoArchivo> get todos => _porId.values;
}
