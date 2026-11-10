import 'package:flutter/foundation.dart';

import '../../datos_simulados/cargador_pistas_campo.dart';
import '../../dominio/contexto_misterio.dart';
import '../../dominio/eco_temporal.dart';
import '../../dominio/fenologia.dart';
import '../../dominio/geolocalizacion_privacy_first.dart';
import '../../dominio/misterio.dart';
import '../../dominio/observacion.dart';
import '../../dominio/pista_campo.dart';
import '../../dominio/pregunta_del_nino.dart';
import '../../dominio/repositorio_local.dart';
import '../../dominio/seleccion_del_dia.dart';
import '../../dominio/sit_spot.dart';

/// `ChangeNotifier` que mantiene la vista del cuaderno sincronizada
/// con el [RepositorioLocal]. Vanilla — sin Provider, sin Riverpod
/// (decisión de S1 documentada en `CLAUDE.md` del juego).
///
/// Lectura: la pantalla principal hace `cargar()` en su `initState` y
/// se suscribe con `ListenableBuilder`. Escritura: cualquier cambio
/// (nueva observación, sit spot configurado) llama de vuelta a
/// `cargar()` para refrescar.
///
/// **Filtrado fenológico** (biblia §5.3 + doc 06 §4): tras leer los
/// Misterios abiertos del repositorio, el estado los filtra al
/// contexto actual del niño (estación astronómica + región derivada
/// del sit spot). Se inyecta [proveedorAhora] para tests deterministas
/// — los tests fijan la fecha y comprueban qué Misterios sobreviven al
/// filtro. Si el sit spot tiene `coordenadas`, se deriva su region NUTS
/// con [normalizarRegion]; sin coordenadas, no se filtra por región
/// (más amable mostrar el catálogo entero que recortar por una región
/// arbitraria). El filtrado **no toca el repo** — la página de un
/// Misterio sigue accesible vía anclajes históricos del cuaderno.
class EstadoCuaderno extends ChangeNotifier {
  EstadoCuaderno({
    required this.repositorio,
    DateTime Function()? proveedorAhora,
    String? Function(SitSpot? sitSpot)? proveedorRegion,
    Future<List<PistaCampo>> Function()? cargadorPistasCampo,
  })  : _proveedorAhora = proveedorAhora ?? DateTime.now,
        _proveedorRegion = proveedorRegion ?? _regionPorDefecto,
        _cargadorPistasCampo = cargadorPistasCampo ?? cargarCatalogoPistasCampo;

  final RepositorioLocal repositorio;
  final DateTime Function() _proveedorAhora;
  final String? Function(SitSpot? sitSpot) _proveedorRegion;

  /// Cargador del catálogo de pistas de campo. Inyectable para tests
  /// sin asset bundle (los tests pueden devolver una lista hardcoded
  /// o vacía para verificar el comportamiento sin pista). En runtime
  /// se carga una sola vez tras el primer `cargar()` exitoso y se
  /// cachea — las pistas son contenido estático del repositorio, no
  /// cambian entre cargas.
  final Future<List<PistaCampo>> Function() _cargadorPistasCampo;

  bool _cargando = false;
  SitSpot? _sitSpot;
  List<Misterio> _misteriosAbiertos = const [];
  List<Misterio> _misteriosCerrados = const [];
  int _totalMisteriosAbiertosSinFiltro = 0;
  List<Observacion> _ultimasObservaciones = const [];
  Map<String, int> _evidenciasPorMisterio = const {};
  Set<String> _misteriosEnVentanaCaliente = const {};
  List<PreguntaDelNino> _preguntasAbiertas = const [];
  List<PreguntaDelNino> _preguntasCerradas = const [];
  List<Eco> _ecos = const [];
  Estacion? _estacionActual;
  String? _regionActual;
  DateTime? _fechaContexto;
  // Catálogo completo de Misterios abiertos antes del filtro fenológico
  // — necesario como fallback del "Misterio del día" cuando el filtrado
  // queda vacío (más amable proponer algo fuera de temporada que dejar
  // la tarjeta sin contenido).
  List<Misterio> _misteriosAbiertosSinFiltro = const [];
  // Pistas de campo cargadas una sola vez (asset estático).
  List<PistaCampo>? _pistasCampo;

  bool get cargando => _cargando;
  SitSpot? get sitSpot => _sitSpot;
  List<Misterio> get misteriosAbiertos => _misteriosAbiertos;

  /// Misterios que el niño ha cerrado declarando *"ya tengo mi
  /// respuesta"*. Los más recientemente cerrados primero. La pestaña
  /// Misterios los lista en una sección separada bajo los abiertos.
  /// **Sin filtro fenológico**: una vez cerrado el ciclo del niño,
  /// la fecha del cierre y la respuesta son patrimonio del cuaderno
  /// independientemente del calendario.
  List<Misterio> get misteriosCerrados => _misteriosCerrados;

  /// Cuántos Misterios abiertos había en el repo **antes** del filtro
  /// fenológico/regional. Permite a la pestaña Misterios distinguir
  /// dos estados vacíos pedagógicamente distintos: catálogo vacío
  /// ("aún no tienes Misterios abiertos") vs todos filtrados fuera del
  /// contexto del niño ("hoy no hay Misterios para tu lugar y
  /// estación, vuelve a mirar al cambiar el tiempo").
  int get totalMisteriosAbiertosSinFiltro => _totalMisteriosAbiertosSinFiltro;
  List<Observacion> get ultimasObservaciones => _ultimasObservaciones;
  Observacion? get ultimaObservacion =>
      _ultimasObservaciones.isEmpty ? null : _ultimasObservaciones.first;

  /// Estación astronómica calculada en la última carga. Null antes de
  /// la primera. La pantalla la usa para el filtrado de Misterios y
  /// para resolver el tip fenológico contextual.
  Estacion? get estacionActual => _estacionActual;

  /// Region NUTS aproximada del sit spot actual. Null si no hay sit
  /// spot, no tiene coordenadas, o aún no se ha cargado nada. Las
  /// pantallas que muestran texto fenológico tratan null como `'ES'`
  /// (fallback país).
  String? get regionActual => _regionActual;

  /// Fecha usada en la última carga para calcular [estacionActual].
  /// La pantalla la rota como semilla del tip del día — la nota
  /// fenológica que se muestra cambia cada día sin ser aleatoria.
  DateTime? get fechaContexto => _fechaContexto;

  /// Cuántas observaciones tiene el niño anotadas contra cada Misterio
  /// abierto (clave = `Misterio.id`). Se resuelve al cargar y alimenta
  /// el contador "N evidencias anotadas" de la `TarjetaMisterio`. Si
  /// un Misterio no aparece como clave es que no tiene evidencias —
  /// las pantallas tratan ausencia y `0` como equivalentes.
  Map<String, int> get evidenciasPorMisterio => _evidenciasPorMisterio;

  /// Ids de Misterios que acaban de entrar en su estación (aplican
  /// hoy pero no aplicaban hace ~21 días). La `TarjetaMisterio` les
  /// pinta el marcador "estos días" en el footer. Misterios
  /// atemporales (seasons vacía) nunca están aquí — aplican siempre,
  /// el marcador diluiría la información.
  Set<String> get misteriosEnVentanaCaliente => _misteriosEnVentanaCaliente;

  /// Preguntas formuladas por el niño que siguen abiertas. Más
  /// recientemente formuladas primero. Sección "Tus preguntas" de la
  /// pestaña Misterios.
  List<PreguntaDelNino> get preguntasDelNinoAbiertas => _preguntasAbiertas;

  /// Preguntas que el niño ha cerrado declarando *"ya tengo mi
  /// respuesta"*. Cerradas más recientemente primero. Sección "Ya
  /// cerradas" dentro del bloque "Tus preguntas".
  List<PreguntaDelNino> get preguntasDelNinoCerradas => _preguntasCerradas;

  /// Ecos temporales del cuaderno: observaciones de hace ~1 mes / 6
  /// meses / 1 año (±3 días) que el home presenta como ritual
  /// pedagógico — *"si vuelves al mismo sitio, ves cómo cambia"*
  /// (biblia §3.5). La lista llega ya filtrada (sin duplicados) y en
  /// orden de presentación: 1 mes → 6 meses → 1 año. Si una ventana
  /// no tiene candidata, simplemente no aparece — el bloque omite la
  /// fila. Sin presión, sin push.
  List<Eco> get ecos => _ecos;

  /// Misterio "del día" — uno destacado en la cabecera del home,
  /// rotando con la fecha. Prioriza los Misterios filtrados al contexto
  /// (estación + región); cae al catálogo entero abierto si el filtrado
  /// queda vacío. Null sólo si el catálogo entero también está vacío.
  /// El cambio de día es a medianoche local del dispositivo, sin push.
  Misterio? get misterioDelDia {
    final fecha = _fechaContexto;
    if (fecha == null) return null;
    return seleccionarMisterioDelDia(
      candidatosEnContexto: _misteriosAbiertos,
      fallbackEnteroAbierto: _misteriosAbiertosSinFiltro,
      fecha: fecha,
    );
  }

  /// Pista de campo "del día" — invitación corta a observar algo
  /// concreto del lugar. Garantiza que el home tenga siempre algo que
  /// proponer aunque el catálogo de Misterios esté vacío. Null si el
  /// asset no se ha cargado todavía o si la lista carga vacía.
  PistaCampo? get pistaDelDia {
    final fecha = _fechaContexto;
    final pistas = _pistasCampo;
    if (fecha == null || pistas == null) return null;
    return seleccionarPistaDelDia(pistas: pistas, fecha: fecha);
  }

  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();
    try {
      final sitSpotResultado = await repositorio.obtenerSitSpot();
      final misteriosCrudo = await repositorio.obtenerMisteriosAbiertos();
      final cerrados = await repositorio.obtenerMisteriosCerradosPorNino();
      // Cargamos un slice amplio para cubrir los anclajes temporales
      // hasta ~1 año atrás. Las "últimas observaciones" del home son
      // las primeras 5 de esa misma lista (ya viene ordenada
      // descendente por `cuandoOcurrio`), así nos ahorramos una query
      // adicional al repo y mantenemos consistencia entre ambos
      // bloques.
      final observacionesParaContexto =
          await repositorio.obtenerObservaciones(limite: 500);
      final ultimas = observacionesParaContexto.take(5).toList(growable: false);
      final preguntasAbiertas =
          await repositorio.obtenerPreguntasDelNinoAbiertas();
      final preguntasCerradas =
          await repositorio.obtenerPreguntasDelNinoCerradas();
      final ahora = _proveedorAhora();
      final estacionActual = estacionDeFecha(ahora);
      final estacionAnterior = estacionDeFecha(
        ahora.subtract(const Duration(days: 21)),
      );
      final regionActual = _proveedorRegion(sitSpotResultado);
      final misteriosFiltrados = filtrarMisteriosAlContexto(
        misteriosCrudo,
        estacionActual: estacionActual,
        regionActual: regionActual,
      );
      final calientes = <String>{};
      for (final misterio in misteriosFiltrados) {
        if (estaEnVentanaCaliente(
          misterio,
          estacionActual: estacionActual,
          estacionAnterior: estacionAnterior,
          regionActual: regionActual,
        )) {
          calientes.add(misterio.id);
        }
      }
      // Conteo por Misterio: una observación por cada id abierto. La
      // alternativa sería leer `misterio.observacionesIds.length`, pero
      // el query es la fuente de verdad — observacionesIds del modelo
      // puede arrastrar drift si en el futuro alguien guarda una
      // observación bypass del helper de anclar.
      final evidencias = <String, int>{};
      for (final misterio in misteriosFiltrados) {
        final lista =
            await repositorio.obtenerObservaciones(misterioId: misterio.id);
        evidencias[misterio.id] = lista.length;
      }
      final ecos = EcoTemporal.calcular(
        observaciones: observacionesParaContexto,
        ahora: ahora,
      );
      // Pistas: una sola carga en la primera invocación exitosa. Si
      // el asset falla (caso de tests sin bundle), se cachea lista
      // vacía y el getter devuelve null sin romper el home.
      if (_pistasCampo == null) {
        try {
          _pistasCampo = await _cargadorPistasCampo();
        } catch (_) {
          _pistasCampo = const [];
        }
      }
      _sitSpot = sitSpotResultado;
      _misteriosAbiertos = misteriosFiltrados;
      _misteriosAbiertosSinFiltro = misteriosCrudo;
      _misteriosCerrados = cerrados;
      _totalMisteriosAbiertosSinFiltro = misteriosCrudo.length;
      _ultimasObservaciones = ultimas;
      _evidenciasPorMisterio = evidencias;
      _misteriosEnVentanaCaliente = calientes;
      _preguntasAbiertas = preguntasAbiertas;
      _preguntasCerradas = preguntasCerradas;
      _ecos = ecos;
      _estacionActual = estacionActual;
      _regionActual = regionActual;
      _fechaContexto = ahora;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}

/// Default del proveedor de región: si el sit spot tiene coordenadas,
/// las normaliza a un region_code NUTS; si no, devuelve `null` (sin
/// filtro de región). Vive fuera de la clase para que el constructor
/// pueda referenciarla como tear-off; el override en tests es trivial.
String? _regionPorDefecto(SitSpot? sitSpot) {
  final coordenadas = sitSpot?.coordenadas;
  if (coordenadas == null) return null;
  return normalizarRegion(coordenadas);
}
