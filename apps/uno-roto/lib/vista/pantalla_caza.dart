import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nuevo_ser_tutor/nuevo_ser_tutor.dart';
import '../datos/catalogo_habilidades.dart';
import '../datos/config_api.dart';
import '../datos/repositorio_progreso.dart';
import '../dominio/ambiente_cielo.dart';
import '../dominio/bonus_remonte.dart';
import '../dominio/calendario_eventos.dart';
import '../dominio/clima_distrito.dart';
import '../dominio/catalogo_distritos.dart';
import '../dominio/contador_intentos_puzzle.dart';
import '../dominio/distrito.dart';
import '../dominio/encargo_del_dia.dart';
import '../dominio/fragmento_en_tejado.dart';
import '../dominio/fragmentos_de_clima.dart';
import '../dominio/generador_caza.dart';
import '../dominio/mapeo_habilidades_puzzle.dart';
import '../dominio/motor_maestria.dart';
import '../dominio/rango_narrativo.dart';
import '../dominio/respuesta_puzzle.dart';
import '../dominio/secretos_escenario.dart';
import '../dominio/ayuda_puzzle.dart';
import '../dominio/problema_comparacion_decimal.dart';
import '../dominio/problema_comparacion_distinta.dart';
import '../dominio/problema_ordenar_decimales.dart';
import '../dominio/problema_comparacion_unidad.dart';
import '../dominio/problema_decimal.dart';
import '../dominio/problema_divisibilidad.dart';
import '../dominio/problema_divisores.dart';
import '../dominio/problema_fraccion_de_cantidad.dart';
import '../dominio/problema_ordenar_fracciones.dart';
import '../dominio/problema_razon.dart';
import '../dominio/problema_espejo.dart' show Fraccion;
import '../dominio/problema_lectura_decimal.dart';
import '../dominio/problema_lectura_fraccion.dart';
import '../dominio/problema_jerarquia.dart';
import '../dominio/problema_longitud.dart';
import '../dominio/problema_masa_capacidad.dart';
import '../dominio/problema_porcentaje_de.dart';
import '../dominio/problema_aumento_descuento.dart';
import '../dominio/problema_angulo.dart';
import '../dominio/problema_media.dart';
import '../dominio/problema_moda_mediana.dart';
import '../dominio/problema_probabilidad.dart';
import '../dominio/problema_probabilidad_porcentaje.dart';
import '../dominio/problema_escala.dart';
import '../dominio/problema_jerarquia_fracciones.dart';
import '../dominio/problema_operacion_mixta.dart';
import '../dominio/problema_poligono.dart';
import '../dominio/problema_perimetro.dart';
import '../dominio/problema_area_rectangulo.dart';
import '../dominio/problema_area_triangulo.dart';
import '../dominio/problema_circulo.dart';
import '../dominio/problema_volumen.dart';
import '../dominio/problema_simetria.dart';
import '../dominio/problema_grafico_barras.dart';
import '../dominio/problema_grafico_circular.dart';
import '../dominio/problema_superficie.dart';
import '../dominio/problema_tiempo.dart';
import '../dominio/problema_mcm_mcd.dart';
import '../dominio/problema_regla_de_tres.dart';
import '../dominio/problema_primo.dart';
import '../dominio/problema_comparacion_media.dart';
import '../dominio/problema_porcentaje_cantidad.dart';
import '../dominio/problema_mixto_a_impropio.dart'
    show ProblemaMixtoAImpropio;
import '../dominio/problema_redondeo_decimal.dart';
import '../dominio/problema_porcentaje.dart';
import '../dominio/problema_potencia_natural.dart';
import '../dominio/problema_raiz_cuadrada.dart';
import '../dominio/problema_pitagoras.dart';
import '../dominio/problema_ecuacion_lineal.dart';
import '../dominio/problema_ecuacion_ambos_lados.dart';
import '../dominio/problema_entero_signo.dart';
import '../dominio/problema_valor_absoluto.dart';
import '../dominio/problema_sistema_dos_x_dos.dart';
import '../dominio/problema_relacion_lineal.dart';
import '../dominio/selector_habilidades.dart';
import '../l10n/app_localizations.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' hide SelectorHabilidades;
import '../sonido/catalogo_sonidos.dart';
import '../sonido/servicio_sonoro.dart';
import 'escenario.dart';
import 'pantalla_combate_enfoque.dart';
import 'pantalla_comparacion.dart';
import 'pantalla_comparacion_balanza.dart';
import 'pantalla_comparacion_distinta.dart';
import 'pantalla_comparacion_tarta.dart';
import 'pantalla_ordenar_decimales.dart';
import 'pantalla_comparacion_unidad.dart';
import 'pantalla_decimal.dart';
import 'pantalla_dual.dart';
import 'pantalla_espejo.dart';
import 'pantalla_impropio.dart';
import 'pantalla_operacion_decimal.dart';
import 'pantalla_amplificar.dart';
import 'pantalla_suma_basica.dart';
import 'pantalla_ecuacion_lineal.dart';
import 'pantalla_potencia_natural.dart';
import 'pantalla_raiz_cuadrada.dart';
import 'pantalla_ecuacion_ambos_lados.dart';
import 'pantalla_pitagoras.dart';
import 'pantalla_entero_signo.dart';
import 'pantalla_valor_absoluto.dart';
import 'pantalla_sistema_dos_x_dos.dart';
import 'pantalla_relacion_lineal.dart';
import 'pantalla_comparacion_decimal.dart';
import 'pantalla_divisibilidad.dart';
import 'pantalla_divisores.dart';
import 'pantalla_fraccion_de_cantidad.dart';
import 'pantalla_ordenar_fracciones.dart';
import 'pantalla_razon.dart';
import 'pantalla_lectura_decimal.dart';
import 'pantalla_lectura_fraccion.dart';
import 'pantalla_jerarquia.dart';
import 'pantalla_longitud.dart';
import 'pantalla_masa_capacidad.dart';
import 'pantalla_porcentaje_de.dart';
import 'pantalla_aumento_descuento.dart';
import 'pantalla_angulo.dart';
import 'pantalla_angulo_manipulativo.dart';
import 'pantalla_media.dart';
import 'pantalla_moda_mediana.dart';
import 'pantalla_probabilidad.dart';
import 'pantalla_probabilidad_porcentaje.dart';
import 'pantalla_operacion_mixta.dart';
import 'pantalla_poligono.dart';
import 'pantalla_perimetro.dart';
import 'pantalla_area_rectangulo.dart';
import 'pantalla_area_triangulo.dart';
import 'pantalla_circulo.dart';
import 'pantalla_volumen.dart';
import 'pantalla_simetria.dart';
import 'pantalla_grafico_barras.dart';
import 'pantalla_grafico_circular.dart';
import 'pantalla_escala.dart';
import 'pantalla_jerarquia_fracciones.dart';
import 'pantalla_superficie.dart';
import 'pantalla_tiempo.dart';
import 'pantalla_mcm_mcd.dart';
import 'pantalla_regla_de_tres.dart';
import 'pantalla_primo.dart';
import 'pantalla_comparacion_media.dart';
import 'pantalla_porcentaje_cantidad.dart';
import 'pantalla_mixto_a_impropio.dart';
import 'pantalla_redondeo_decimal.dart';
import 'pantalla_porcentaje.dart';
import 'pantalla_proporcional.dart';
import 'pantalla_simplificar.dart';
import 'pantalla_tutor.dart';
import 'pintor_fragmento_tejado.dart';
import 'sora_presencia.dart';

/// El nuevo bucle: un trozo del tejado donde los Fragmentos van
/// apareciendo. El niño decide cuál cazar, cuándo y en qué orden.
/// Si tarda demasiado, el Fragmento se escapa hacia la Montaña. Cada
/// captura deja una esquirla que engorda el contador arriba a la
/// derecha.
class PantallaCaza extends StatefulWidget {
  final RepositorioProgreso repositorio;
  final Distrito distrito;

  /// Si está presente, el cazadero entra en "modo entrenamiento": el
  /// selector adaptativo restringe candidatas al dominio indicado
  /// (FR/DEC/PROP/…) en lugar de a las habilidades del distrito. La UI
  /// añade un badge para que el niño no se desoriente. El distrito sigue
  /// fijando la atmósfera visual y sonora.
  final String? dominioFiltrado;

  /// Etiqueta legible del dominio entrenado (p. ej. "Fracciones"). Se
  /// muestra en el badge. Solo se usa si `dominioFiltrado` no es null.
  final String? nombreDominio;

  const PantallaCaza({
    super.key,
    required this.repositorio,
    required this.distrito,
    this.dominioFiltrado,
    this.nombreDominio,
  });

  @override
  State<PantallaCaza> createState() => _PantallaCazaState();
}

class _PantallaCazaState extends State<PantallaCaza>
    with TickerProviderStateMixin {
  static const int _maxFragmentosEnTejado = 3;
  static const Duration _tickPeriodo = Duration(milliseconds: 120);

  late GeneradorCaza _generador;
  MotorMaestria? _motorMaestria;
  SelectorHabilidades? _selectorHabilidades;
  ServicioTutor? _servicioTutor;
  final List<FragmentoEnTejado> _activos = [];
  final Map<String, DateTime> _instanteAperturaPuzzle = {};

  int _esquirlasTotal = 0;
  int _esquirlasEstaSesion = 0;
  /// Encargo del día vigente (doc 16, eje D). Se resuelve al cargar el
  /// estado inicial con los distritos desbloqueados en ese momento; si
  /// la sesión cruza la medianoche se regenera en la primera captura
  /// del día nuevo.
  EncargoDelDia? _encargoDeHoy;

  /// Piezas del taller ya restauradas (doc 16, eje B) — el escenario
  /// las pinta encendidas. Se cargan una vez al entrar al cazadero.
  Set<String> _piezasRestauradas = const {};

  /// Raro de clima que toca hoy en este distrito (doc 16, eje E), o
  /// null si el clima no acompaña, no hay raro aquí o ya se capturó.
  /// Se resuelve al cargar el estado inicial; se anula al capturarlo.
  FragmentoDeClima? _raroDeClimaHoy;

  /// `true` mientras el raro está flotando en el tejado. Si se
  /// escapa vuelve a `false` — reaparecerá en otro spawn, sin castigo.
  bool _raroEnTejado = false;

  /// Spawns acumulados en esta sesión. El raro no sale de primeras:
  /// espera al menos al tercer spawn para que el niño ya esté cazando.
  int _spawnsEstaSesion = 0;

  /// Flags narrativos activos al entrar (+ los que se activan durante
  /// la sesión). Deciden qué secretos espaciales siguen escuchando y
  /// qué raro de clima puede aparecer.
  Set<String> _flagsAlEntrar = const {};
  // Habilidades que el niño ya remontó esta sesión (bonus dado).
  // Una habilidad solo paga bonus la primera vez que se captura un
  // Fragmento de ella en la sesión actual; los siguientes sin extra.
  final Set<String> _habilidadesRemontadasEstaSesion = <String>{};
  String? _lineaAmbienteSora;
  Set<String> _ayudasPuzzlesVistas = <String>{};
  /// Fallback local de fallos consecutivos cuando no hay tutor backend.
  /// Permite ofrecer ayuda local aunque no haya token de servidor.
  final Map<String, int> _fallosLocalesConsecutivos = {};
  final Set<String> _cooldownAyudaLocal = {};
  Timer? _timerSync;
  /// Guard contra solapamiento: si una llamada a `sincronizar` aún está
  /// en vuelo cuando el Timer.periodic dispara la siguiente (caso raro
  /// pero posible si la red va muy lenta), saltamos esa iteración para
  /// no encadenar dos escrituras de progreso simultáneas.
  bool _syncEnVuelo = false;
  final Map<String, EstadoHabilidad> _estadosCache = {};
  Timer? _temporizadorSpawn;
  Timer? _temporizadorTick;
  Timer? _temporizadorLineaSora;
  DateTime _ahoraRef = DateTime.now();

  late final AnimationController _controladorCielo;
  late final AnimationController _controladorLluvia;

  /// Ambiente atmosférico del cazadero en este día concreto. Resuelto
  /// una vez en `initState` para que las cinco lluvias del distrito
  /// (doc Faro E13) varíen día a día sin parpadear durante una sesión.
  /// Si hoy hay un [EventoCalendario] activo, gana sobre el clima.
  late final AmbienteCielo _ambienteHoy;

  /// Mensaje del evento del calendario activo (si lo hay) pendiente
  /// de mostrarse tras el primer frame. Una vez disparado se queda
  /// en `null` para no repetirse en posteriores `setState`.
  String? _mensajeEventoPendiente;

  @override
  void initState() {
    super.initState();
    _generador = GeneradorCaza(distrito: widget.distrito);
    _controladorCielo = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _controladorLluvia = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    final ahora = DateTime.now();
    final eventoHoy = CalendarioEventos.deHoy(
      ahora: ahora,
      idDistrito: widget.distrito.identificador,
    );
    _ambienteHoy = eventoHoy?.ambiente ??
        ClimaDistrito.delDia(
          idDistrito: widget.distrito.identificador,
          ahora: ahora,
        );
    _mensajeEventoPendiente = eventoHoy?.mensajeAlEntrar;
    _cargarEstadoInicial();
    _inicializarMotorMaestria();
    _inicializarTutor();
    if (_mensajeEventoPendiente != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final mensaje = _mensajeEventoPendiente;
        _mensajeEventoPendiente = null;
        if (mensaje != null) _mostrarLineaAmbienteSora(mensaje);
      });
    }
  }

  /// Construye el `ServicioTutor` solo si hay token de backend
  /// guardado. Sin token no podemos llamar al servidor; en ese caso
  /// dejamos el servicio en null y la pantalla nunca ofrece al niño
  /// llamar a Eco.
  Future<void> _inicializarTutor() async {
    final token = await widget.repositorio.cargarTokenBackend();
    if (token == null || token.isEmpty) return;
    if (!mounted) return;
    _servicioTutor = ServicioTutor(
      cache: CacheTutor(),
      cliente: ClienteTutor(
        urlBase: ConfigApi.urlBase,
        hostOverride: ConfigApi.hostOverride,
        userAgent: 'UnoRoto/1.0 (Android)',
      ),
      estadoTutor: widget.repositorio.estadoTutor,
      proveedorToken: () => token,
    );
    _iniciarSyncPeriodico(token);
  }

  /// Sincroniza el progreso cada 10 minutos si hay token.
  void _iniciarSyncPeriodico(String token) {
    _timerSync?.cancel();
    _timerSync = Timer.periodic(const Duration(minutes: 10), (_) async {
      if (_syncEnVuelo) return;
      _syncEnVuelo = true;
      final api = ClienteApi(
        urlBase: ConfigApi.urlBase,
        hostOverride: ConfigApi.hostOverride,
        userAgent: 'UnoRoto/1.0 (Android)',
      );
      try {
        final p = await widget.repositorio.exportarProgresoParaSync();
        final h = await widget.repositorio.exportarHabilidadesParaSync();
        await api.sincronizar(token: token, progreso: p, habilidades: h);
      } on ExcepcionApi catch (e) {
        // Token caducado o inválido: el servidor lo rechaza con 401.
        // Borramos el token local y paramos el sync — la próxima vez que
        // el niño entre al panel de cuenta podrá reautenticarse. Sin
        // esto, el timer seguía reintentando con el token muerto cada
        // 10 minutos para siempre.
        if (e.codigo == 401) {
          _timerSync?.cancel();
          _timerSync = null;
          await widget.repositorio.borrarTokenBackend();
        } else {
          debugPrint('[uroto.sync] ${e.codigo}: ${e.mensaje}');
        }
      } catch (e) {
        // Red caída, timeout, JSON corrupto… loguear sin romper la
        // sesión del niño. Volveremos a intentar en la siguiente vuelta.
        debugPrint('[uroto.sync] excepción no-API: $e');
      } finally {
        api.cerrar();
        _syncEnVuelo = false;
      }
    });
  }

  Future<void> _inicializarMotorMaestria() async {
    final catalogo = await CatalogoHabilidades.cargar();
    if (!mounted) return;
    _motorMaestria = MotorMaestria(
      catalogo: catalogo,
      cargarEstado: widget.repositorio.cargarEstadoHabilidad,
      guardarEstado: widget.repositorio.guardarEstadoHabilidad,
      alSubirNivel: (idHabilidad, nivel) async {
        // Esperamos al `activarFlagNarrativo` antes de seguir — si la
        // app se cerrara entre el callback y la persistencia (raro pero
        // posible al fondo) el flag de maestría se perdería y la escena
        // que depende de él (p. ej. 1.9 al alcanzar `fr_05_competente`)
        // quedaría latente sin razón aparente.
        await widget.repositorio.activarFlagNarrativo(
          MotorMaestria.flagDeMaestria(idHabilidad, nivel),
        );
        // Celebramos subidas a "competente" o "maestría"
        if (nivel == NivelMaestria.competente) {
          final nombre = catalogo.porId(idHabilidad)?.nombre ?? idHabilidad;
          _mostrarLineaAmbienteSora('«$nombre» — ya la tienes.');
        } else if (nivel == NivelMaestria.maestria) {
          final nombre = catalogo.porId(idHabilidad)?.nombre ?? idHabilidad;
          _mostrarLineaAmbienteSora('«$nombre» — dominada.');
        }
      },
    );
    _selectorHabilidades = SelectorHabilidades(
      catalogo: catalogo,
      cargarEstado: widget.repositorio.cargarEstadoHabilidad,
    );
    // Precargar estados de habilidades en caché — los usan varias
    // ramas (cambio de nivel, oferta de tutor, etc.).
    for (final id in catalogo.habilidades.keys) {
      final estado = await widget.repositorio.cargarEstadoHabilidad(id);
      if (estado != null) _estadosCache[id] = estado;
    }
    // Precargar el set de ayudas-de-puzzle ya vistas para que el dialog
    // de bienvenida pueda decidir sin ir a disco cada vez que el niño
    // toca un Fragmento.
    _ayudasPuzzlesVistas = await widget.repositorio.cargarAyudasPuzzlesVistas();
  }

  Future<void> _cargarEstadoInicial() async {
    final total = await widget.repositorio.cargarEsquirlas();
    final yaVisitado = await widget.repositorio
        .distritoVisitado(widget.distrito.identificador);
    final modoExperto = await widget.repositorio.cargarModoExperto();
    if (!mounted) return;
    if (modoExperto) {
      // Reconstruimos el generador con offset +2 — niños avanzados
      // arrancan unos peldaños más arriba en lugar de recorrer los
      // tiers triviales. Reconstruir es seguro porque el spawn aún
      // no se ha disparado (lo programamos justo después).
      _generador = GeneradorCaza(
        distrito: widget.distrito,
        offsetDificultad: 2,
      );
    }
    final piezas = await widget.repositorio.ciudad.cargarPiezasRestauradas();
    final flags = await widget.repositorio.flagsNarrativosActivos();
    // Raro de clima de hoy: solo en caza ambiental de verdad (el modo
    // entrenamiento reutiliza la atmósfera pero no es el distrito).
    FragmentoDeClima? raroDeHoy;
    if (widget.dominioFiltrado == null) {
      raroDeHoy = CatalogoFragmentosDeClima.paraHoy(
        idDistrito: widget.distrito.identificador,
        ambiente: _ambienteHoy,
        flagsActivos: flags,
      );
    }
    if (!mounted) return;
    setState(() {
      _esquirlasTotal = total;
      _piezasRestauradas = piezas;
      _raroDeClimaHoy = raroDeHoy;
      _flagsAlEntrar = flags;
    });
    _encargoDeHoy = _encargoParaEsquirlas(total, DateTime.now());
    _programarSiguienteSpawn();
    _arrancarTickDeEscapes();
    final saludo = yaVisitado
        ? 'Vamos.'
        : widget.distrito.saludoPrimeraVisita;
    _mostrarLineaAmbienteSora(saludo);
    if (!yaVisitado) {
      await widget.repositorio
          .marcarDistritoComoVisitado(widget.distrito.identificador);
    }
    _arrancarAmbientYMusicaDeDistrito();
  }

  void _arrancarAmbientYMusicaDeDistrito() {
    final idDistrito = widget.distrito.identificador;
    final ambient = CatalogoSonidos.ambientDeDistrito(idDistrito);
    final musica = CatalogoSonidos.musicaDeDistrito(idDistrito);
    if (ambient != null) {
      ServicioSonoro.instancia.reproducirLoop(ambient, msFade: 1500);
    }
    if (musica != null) {
      ServicioSonoro.instancia.reproducirLoop(musica, msFade: 1800);
    }
  }

  @override
  void dispose() {
    _controladorCielo.dispose();
    _controladorLluvia.dispose();
    _temporizadorSpawn?.cancel();
    _temporizadorTick?.cancel();
    _temporizadorLineaSora?.cancel();
    _timerSync?.cancel();
    // Dejamos el ambient sonando pero paramos la música del distrito
    // al volver al mapa — hace que la transición se sienta.
    ServicioSonoro.instancia.detenerCapa(CapaAudio.musica, msFade: 700);
    ServicioSonoro.instancia.detenerCapa(CapaAudio.ambient, msFade: 900);
    super.dispose();
  }

  void _programarSiguienteSpawn() {
    _temporizadorSpawn?.cancel();
    final esperaMs = 2400 + math.Random().nextInt(3000);
    _temporizadorSpawn = Timer(Duration(milliseconds: esperaMs), _intentarSpawn);
  }

  Future<void> _intentarSpawn() async {
    if (!mounted) return;
    if (_activos.length < _maxFragmentosEnTejado) {
      final esquirlas = _esquirlasTotal + _esquirlasEstaSesion;
      final ahora = DateTime.now();
      // Con las 66 habilidades del catálogo cubiertas, el selector
      // adaptativo es la fuente principal de Fragmentos. Si el
      // selector no devuelve candidata (caso de borde) caemos al
      // reparto del distrito.
      var nuevo = _selectorHabilidades != null
          ? await _generarDesdeSelector(esquirlas: esquirlas, ahora: ahora)
          : _generador.siguiente(
              esquirlasAcumuladas: esquirlas,
              ahora: ahora,
            );
      if (!mounted) return;
      _spawnsEstaSesion++;
      // Raro de clima (doc 16, eje E): a partir del tercer spawn de la
      // sesión, el siguiente hueco libre lo ocupa el raro. El puzzle es
      // el normal que tocaba (calibrado por el selector); solo cambia
      // el encuentro.
      final raro = _raroDeClimaHoy;
      if (raro != null && !_raroEnTejado && _spawnsEstaSesion >= 3) {
        nuevo = nuevo.conMarcaDeClima(raro.id);
        _raroEnTejado = true;
        _mostrarLineaAmbienteSora(raro.lineaSoraAlAparecer);
      }
      setState(() => _activos.add(nuevo));
    }
    _programarSiguienteSpawn();
  }

  Future<FragmentoEnTejado> _generarDesdeSelector({
    required int esquirlas,
    required DateTime ahora,
  }) async {
    final selector = _selectorHabilidades!;
    final idHabilidad = await selector.elegirSiguienteHabilidad(
      distrito: widget.distrito,
      dominioFiltrado: widget.dominioFiltrado,
      rangoActual: rangoStringSegunEsquirlas(esquirlas),
    );
    if (idHabilidad == null) {
      return _generador.siguiente(
        esquirlasAcumuladas: esquirlas,
        ahora: ahora,
      );
    }
    return _generador.siguienteParaSkill(
      idHabilidad: idHabilidad,
      esquirlasAcumuladas: esquirlas,
      ahora: ahora,
    );
  }

  void _arrancarTickDeEscapes() {
    _temporizadorTick?.cancel();
    _temporizadorTick = Timer.periodic(_tickPeriodo, (_) {
      if (!mounted) return;
      final ahora = DateTime.now();
      final seEscapanAhora = _activos
          .where((f) => f.seHaEscapado(ahora))
          .toList(growable: false);
      if (seEscapanAhora.isNotEmpty) {
        final seEscapoElRaro = seEscapanAhora.any((f) => f.esDeClima);
        setState(() {
          for (final f in seEscapanAhora) {
            _activos.remove(f);
          }
          _ahoraRef = ahora;
        });
        if (seEscapoElRaro) {
          // Sin castigo: el raro reaparecerá en otro spawn de esta
          // misma sesión (u otro día con este clima).
          _raroEnTejado = false;
          _mostrarLineaAmbienteSora('Se ha ido. Volverá con este cielo.');
        } else {
          _comentarTrasEscape(seEscapanAhora.length);
        }
      } else {
        setState(() => _ahoraRef = ahora);
      }
    });
  }

  Future<void> _alTocarFragmento(FragmentoEnTejado fragmento) async {
    HapticFeedback.selectionClick();
    _instanteAperturaPuzzle[fragmento.identificador] = DateTime.now();
    // Reseteamos el contador para que cada puzzle empiece "a la
    // primera". Cada respuesta incorrecta dentro de la pantalla del
    // puzzle lo incrementa; al volver, [intentosPuzzleActual] nos
    // dice en qué intento acertó el niño y escalamos las esquirlas.
    reiniciarIntentosPuzzle();
    // Y el contador paralelo de fallos para el tutor, que sobrevive al
    // reset del dialog "tras-5-fallos" para que la oferta de Eco se
    // base en lo que de verdad le costó al niño este Fragmento.
    reiniciarFallosParaTutor();
    // La primera vez que el niño abre un puzzle de este tipo en este
    // perfil, le mostramos la instrucción pedagógica como dialog
    // modal — sin presión de tiempo, hasta que toque EMPEZAR. A partir
    // de la segunda captura del mismo tipo el toque lleva directo al
    // puzzle, sin intermedios.
    await _mostrarAyudaPuzzleSiPrimeraVez(fragmento);
    if (!mounted) return;
    final capturado = await _abrirPuzzleSegunTipo(fragmento);
    // Si la pantalla de puzzle no registró su propia respuesta
    // (vía UltimaRespuestaPuzzle), registramos una genérica desde
    // el Fragmento para que el tutor IA tenga contexto.
    if (UltimaRespuestaPuzzle.ultima == null && capturado == true) {
      final (pregunta, _) = _descripcionPuzzle(fragmento);
      UltimaRespuestaPuzzle.registrar(RespuestaPuzzle(
        acertado: true,
        respuestaDelNino: '(no capturada)',
        respuestaCorrecta: '(no disponible)',
        preguntaTexto: pregunta,
        opciones: [],
      ));
    }
    if (!mounted) return;
    final intentos = intentosPuzzleActual;
    // Leemos la precisión histórica ANTES de registrar el nuevo
    // intento — la usamos para decidir si esta captura cuenta como
    // "remonte" de una habilidad que costaba (precisión < 0.5).
    final idHabilidad = idHabilidadPrincipal(fragmento);
    final precisionPrevia =
        (await _motorMaestria?.cargarEstado(idHabilidad))?.precision;
    if (!mounted) return;
    // await crítico: el motor adaptativo lee, muta y guarda el estado
    // de la habilidad. Sin await, dos capturas rápidas de la misma
    // habilidad pueden disparar dos ciclos read-modify-write
    // interleavados y la segunda sobrescribir la primera, perdiendo
    // intentos.
    await _registrarResultadoMaestria(fragmento, capturado == true);
    if (!mounted) return;
    // Registramos los fallos PREVIOS al resultado final para que el
    // contador del tutor refleje cuánto le costó este puzzle, no solo
    // el resultado binario. Así "tres errores aunque al final acertara"
    // puede activar la oferta de Eco igual que "tres Fragmentos
    // seguidos escapados". Usamos [fallosParaTutorPuzzleActual] —no
    // [intentos]— porque el dialog "¿Necesitas ayuda?" tras 5 fallos
    // reinicia [intentosPuzzleActual] (para evitar la regla del
    // descarte) y antes de este cambio nos hacía perder esos 5 fallos
    // a ojos del tutor.
    final fallosPreviosParaTutor = fallosParaTutorPuzzleActual;
    for (var i = 0; i < fallosPreviosParaTutor; i++) {
      await _registrarEnTutor(fragmento, false);
    }
    if (!mounted) return;
    setState(() => _activos.remove(fragmento));
    // La oferta se evalúa con el contador en su pico (antes del
    // acierto final, que lo resetea). Vale tanto para captura
    // difícil como para escape — `_quizasOfrecerTutor` decide por
    // dentro con `deberiaOfrecer` y el cooldown.
    await _quizasOfrecerTutor(fragmento);
    if (!mounted) return;
    // Resultado final: acierto resetea contador; escape suma uno más.
    await _registrarEnTutor(fragmento, capturado == true);
    if (!mounted) return;
    if (capturado == true) {
      final esquirlasBase = switch (fragmento.tipo) {
        TipoFragmentoEnTejado.sumaBasica => 1,
        TipoFragmentoEnTejado.ecuacionLineal => 4,
        TipoFragmentoEnTejado.espejo => 2,
        TipoFragmentoEnTejado.decimal => 2,
        TipoFragmentoEnTejado.porcentaje => 2,
        TipoFragmentoEnTejado.comparacion => 2,
        TipoFragmentoEnTejado.simplificar => 3,
        TipoFragmentoEnTejado.amplificar => 3,
        TipoFragmentoEnTejado.divisibilidad => 1,
        TipoFragmentoEnTejado.multiplos => 1,
        TipoFragmentoEnTejado.comparacionDecimal => 2,
        TipoFragmentoEnTejado.lecturaDecimal => 2,
        TipoFragmentoEnTejado.comparacionUnidad => 2,
        TipoFragmentoEnTejado.lecturaFraccion => 2,
        TipoFragmentoEnTejado.mixtoAImpropio => 3,
        TipoFragmentoEnTejado.redondeoDecimal => 2,
        TipoFragmentoEnTejado.comparacionDistinta => 3,
        TipoFragmentoEnTejado.primo => 1,
        TipoFragmentoEnTejado.reglaDeTres => 3,
        TipoFragmentoEnTejado.ordenarDecimales => 2,
        TipoFragmentoEnTejado.mcmMcd => 3,
        TipoFragmentoEnTejado.jerarquia => 3,
        TipoFragmentoEnTejado.comparacionMedia => 2,
        TipoFragmentoEnTejado.porcentajeCantidad => 3,
        TipoFragmentoEnTejado.divisores => 2,
        TipoFragmentoEnTejado.fraccionDeCantidad => 3,
        TipoFragmentoEnTejado.ordenarFracciones => 3,
        TipoFragmentoEnTejado.razon => 2,
        TipoFragmentoEnTejado.longitud => 2,
        TipoFragmentoEnTejado.masaCapacidad => 2,
        TipoFragmentoEnTejado.porcentajeDe => 3,
        TipoFragmentoEnTejado.tiempo => 2,
        TipoFragmentoEnTejado.aumentoDescuento => 3,
        TipoFragmentoEnTejado.superficie => 3,
        TipoFragmentoEnTejado.jerarquiaFracciones => 4,
        TipoFragmentoEnTejado.escala => 3,
        TipoFragmentoEnTejado.angulo => 1,
        TipoFragmentoEnTejado.media => 2,
        TipoFragmentoEnTejado.modaMediana => 2,
        TipoFragmentoEnTejado.probabilidad => 3,
        TipoFragmentoEnTejado.probabilidadPorcentaje => 3,
        TipoFragmentoEnTejado.operacionMixta => 4,
        TipoFragmentoEnTejado.poligono => 1,
        TipoFragmentoEnTejado.perimetro => 2,
        TipoFragmentoEnTejado.areaRectangulo => 2,
        TipoFragmentoEnTejado.areaTriangulo => 2,
        TipoFragmentoEnTejado.circulo => 3,
        TipoFragmentoEnTejado.volumen => 3,
        TipoFragmentoEnTejado.simetria => 1,
        TipoFragmentoEnTejado.graficoBarras => 2,
        TipoFragmentoEnTejado.graficoCircular => 2,
        TipoFragmentoEnTejado.impropio => 3,
        TipoFragmentoEnTejado.proporcional => 3,
        TipoFragmentoEnTejado.dual => 4,
        TipoFragmentoEnTejado.operacionDecimal => 4,
        TipoFragmentoEnTejado.potenciaNatural => 3,
        TipoFragmentoEnTejado.raizCuadrada => 3,
        TipoFragmentoEnTejado.ecuacionAmbosLados => 5,
        TipoFragmentoEnTejado.pitagoras => 4,
        TipoFragmentoEnTejado.enteroSigno => 2,
        TipoFragmentoEnTejado.valorAbsoluto => 2,
        TipoFragmentoEnTejado.sistemaDosXDos => 6,
        TipoFragmentoEnTejado.relacionLineal => 4,
        TipoFragmentoEnTejado.unitario => fragmento.numerador,
      };
      // Escalado motivacional: acertar a la primera da [esquirlasBase];
      // cada reintento adicional resta una esquirla. Llegar al último
      // intento posible (descarte) da 0. Nunca se pierden esquirlas
      // ya ganadas — solo se gana menos esta vez.
      final esquirlasGanadas = esquirlasSegunIntentos(
        base: esquirlasBase,
        totalOpciones: _totalOpcionesDePuzzle(fragmento.tipo),
      );
      // Bonus de remonte: si la habilidad llevaba precisión < 0.5 y
      // hoy la captura, le sumamos +1. Lógica en `bonus_remonte.dart`.
      final esRemonte = aplicaBonusRemonte(
        esquirlasGanadas: esquirlasGanadas,
        precisionPrevia: precisionPrevia,
        yaRemontada:
            _habilidadesRemontadasEstaSesion.contains(idHabilidad),
      );
      if (esRemonte) {
        _habilidadesRemontadasEstaSesion.add(idHabilidad);
      }
      final bonusRemonte = esRemonte ? 1 : 0;
      final esquirlasFinales = esquirlasGanadas + bonusRemonte;
      setState(() {
        _esquirlasEstaSesion += esquirlasFinales;
        _esquirlasTotal += esquirlasFinales;
      });
      await widget.repositorio.guardarEsquirlas(_esquirlasTotal);
      await _verificarSubidaDeRango();
      if (!mounted) return;
      if (bonusRemonte > 0) {
        _mostrarLineaAmbienteSora('Esta te costaba.');
      } else {
        _comentarTrasCaptura();
      }
      // Feedback honesto del descuento por intentos: solo aparece
      // cuando el niño tardó más de un intento en acertar. Si fue a
      // la primera, el comentario de Sora se queda solo (sin números).
      // No es castigo: es información — "podrías haber ganado más".
      if (intentos > 1) {
        final etiquetaPosibles = traducirNarrativa(
          'posibles',
          Localizations.localeOf(context),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                '+$esquirlasFinales (de $esquirlasBase $etiquetaPosibles)',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: PaletaNeon.textoPrincipal,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
              backgroundColor: PaletaNeon.fondoMedio,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(milliseconds: 1800),
              margin: const EdgeInsets.fromLTRB(60, 0, 60, 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: PaletaNeon.violetaBase.withOpacity(0.6),
                ),
              ),
            ),
          );
      }
      await _registrarCapturaParaEncargo();
      if (fragmento.esDeClima) {
        await _registrarCapturaDeClima(fragmento.idFragmentoDeClima!);
      }
    } else {
      _mostrarLineaAmbienteSora('Ya volverá otro.');
    }
  }

  /// Descubrimiento de un secreto espacial (doc 16, eje E): el niño
  /// tocó el punto exacto sin que nada lo señalara. Flag + línea de
  /// Sora; la entrada del Cuaderno aparecerá al volver al mapa.
  Future<void> _descubrirSecreto(SecretoEscenario secreto) async {
    if (_flagsAlEntrar.contains(secreto.flagDescubierto)) return;
    setState(() {
      _flagsAlEntrar = {..._flagsAlEntrar, secreto.flagDescubierto};
    });
    await widget.repositorio.activarFlagNarrativo(secreto.flagDescubierto);
    if (!mounted) return;
    HapticFeedback.lightImpact();
    _mostrarLineaAmbienteSora(secreto.lineaSora);
  }

  /// Captura de un raro de clima (doc 16, eje E): activa su flag —
  /// que desbloquea la entrada del Cuaderno — y revela el nombre con
  /// la voz de Sora. Va la última para que su línea gane a cualquier
  /// otro comentario de la captura.
  Future<void> _registrarCapturaDeClima(String idRaro) async {
    final raro = CatalogoFragmentosDeClima.todos
        .where((r) => r.id == idRaro)
        .firstOrNull;
    if (raro == null) return;
    await widget.repositorio.activarFlagNarrativo(raro.flagCaptura);
    if (!mounted) return;
    setState(() {
      _raroDeClimaHoy = null;
      _raroEnTejado = false;
    });
    _mostrarLineaAmbienteSora(raro.lineaSoraAlCapturar);
  }

  /// Encargo del día vigente para un niño con [esquirlas]: los
  /// distritos candidatos son los ya desbloqueados en este momento.
  EncargoDelDia _encargoParaEsquirlas(int esquirlas, DateTime ahora) {
    final desbloqueados = CatalogoDistritos.todos
        .where((d) => d.esquirlasParaDesbloquear <= esquirlas)
        .map((d) => d.identificador)
        .toList();
    return GeneradorEncargoDelDia.deHoy(
      ahora: ahora,
      idsDistritosDesbloqueados: desbloqueados,
    );
  }

  /// Avanza el encargo del día si esta captura cuenta (doc 16, eje D).
  /// El cierre es sobrio a propósito: una línea seca de Sora, sin
  /// fanfarria — la mesura es el sabor (doc 01, principio 3).
  Future<void> _registrarCapturaParaEncargo() async {
    var encargo = _encargoDeHoy;
    if (encargo == null) return;
    final ahora = DateTime.now();
    if (encargo.claveFecha != GeneradorEncargoDelDia.claveFechaDe(ahora)) {
      // La sesión cruzó la medianoche: el encargo en memoria es de
      // ayer. Regeneramos para no escribir progreso en la fecha vieja.
      encargo = _encargoParaEsquirlas(_esquirlasTotal, ahora);
      _encargoDeHoy = encargo;
    }
    final cuenta = encargo.cuentaCaptura(
      idDistritoCaptura: widget.distrito.identificador,
      esEntrenamiento: widget.dominioFiltrado != null,
    );
    if (!cuenta) return;
    final estado = await widget.repositorio.encargo.registrarCaptura(
      claveFecha: encargo.claveFecha,
      objetivo: encargo.objetivo,
    );
    if (!mounted) return;
    if (estado.recienCompletado) {
      _mostrarLineaAmbienteSora('El encargo de hoy está hecho. Bien.');
    }
  }

  /// Cuántas tarjetas/botones presenta el puzzle del [tipo] dado. Lo
  /// usa [esquirlasSegunIntentos] para detectar "último intento por
  /// descarte" y devolver 0 esquirlas en ese caso.
  ///
  /// La gran mayoría son de 4 candidatos. Los binarios sí/no son 2.
  /// Tres puzzles de fracciones (FR.03 / FR.04) son de 3 botones.
  ///
  /// Caso especial: el Fragmento unitario (combate de enfoque) no tiene
  /// candidatos discretos — es una mecánica continua de cortar radios
  /// con precisión geométrica. Devolvemos 0 para señalar "sin opciones
  /// finitas", lo que desactiva la regla del descarte en
  /// [esquirlasSegunIntentos]. Sin esto, los fallos acumulados a lo
  /// largo de varios sub-combates llevaban la recompensa a 0 al cerrar.
  int _totalOpcionesDePuzzle(TipoFragmentoEnTejado tipo) {
    return switch (tipo) {
      TipoFragmentoEnTejado.unitario => 0,
      TipoFragmentoEnTejado.primo ||
      TipoFragmentoEnTejado.simetria ||
      TipoFragmentoEnTejado.divisibilidad ||
      TipoFragmentoEnTejado.multiplos =>
        2,
      TipoFragmentoEnTejado.comparacionMedia ||
      TipoFragmentoEnTejado.comparacionUnidad =>
        3,
      _ => 4,
    };
  }

  Future<bool?> _abrirPuzzleSegunTipo(FragmentoEnTejado fragmento) {
    switch (fragmento.tipo) {
      case TipoFragmentoEnTejado.espejo:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaEspejo(
              numerador: fragmento.numerador,
              denominador: fragmento.denominador,
            ),
          ),
        );
      case TipoFragmentoEnTejado.sumaBasica:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaSumaBasica(
              aPredeterminado: fragmento.numerador,
              bPredeterminado: fragmento.denominador,
            ),
          ),
        );
      case TipoFragmentoEnTejado.ecuacionLineal:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaEcuacionLineal(
              problemaPredeterminado: _reconstruirEra3(
                fragmento,
                (semilla, dif) =>
                    GeneradorEcuacionLineal(semilla: semilla).generar(dificultad: dif),
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.potenciaNatural:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaPotenciaNatural(
              problemaPredeterminado: _reconstruirEra3(
                fragmento,
                (semilla, dif) =>
                    GeneradorPotenciaNatural(semilla: semilla).generar(dificultad: dif),
              ),
              dificultad: fragmento.dificultadSugerida ?? 1,
            ),
          ),
        );
      case TipoFragmentoEnTejado.raizCuadrada:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaRaizCuadrada(
              problemaPredeterminado: _reconstruirEra3(
                fragmento,
                (semilla, dif) =>
                    GeneradorRaizCuadrada(semilla: semilla).generar(dificultad: dif),
              ),
              dificultad: fragmento.dificultadSugerida ?? 1,
            ),
          ),
        );
      case TipoFragmentoEnTejado.ecuacionAmbosLados:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaEcuacionAmbosLados(
              problemaPredeterminado: _reconstruirEra3(
                fragmento,
                (semilla, dif) => GeneradorEcuacionAmbosLados(semilla: semilla)
                    .generar(dificultad: dif),
              ),
              dificultad: fragmento.dificultadSugerida ?? 1,
            ),
          ),
        );
      case TipoFragmentoEnTejado.pitagoras:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaPitagoras(
              problemaPredeterminado: _reconstruirEra3(
                fragmento,
                (semilla, dif) =>
                    GeneradorPitagoras(semilla: semilla).generar(dificultad: dif),
              ),
              dificultad: fragmento.dificultadSugerida ?? 1,
            ),
          ),
        );
      case TipoFragmentoEnTejado.enteroSigno:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaEnteroSigno(
              problemaPredeterminado: _reconstruirEra3(
                fragmento,
                (semilla, dif) =>
                    GeneradorEnteroSigno(semilla: semilla).generar(dificultad: dif),
              ),
              dificultad: fragmento.dificultadSugerida ?? 1,
            ),
          ),
        );
      case TipoFragmentoEnTejado.valorAbsoluto:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaValorAbsoluto(
              problemaPredeterminado: _reconstruirEra3(
                fragmento,
                (semilla, dif) =>
                    GeneradorValorAbsoluto(semilla: semilla).generar(dificultad: dif),
              ),
              dificultad: fragmento.dificultadSugerida ?? 1,
            ),
          ),
        );
      case TipoFragmentoEnTejado.sistemaDosXDos:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaSistemaDosXDos(
              problemaPredeterminado: _reconstruirEra3(
                fragmento,
                (semilla, dif) =>
                    GeneradorSistemaDosXDos(semilla: semilla).generar(dificultad: dif),
              ),
              dificultad: fragmento.dificultadSugerida ?? 1,
            ),
          ),
        );
      case TipoFragmentoEnTejado.relacionLineal:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaRelacionLineal(
              problemaPredeterminado: _reconstruirEra3(
                fragmento,
                (semilla, dif) =>
                    GeneradorRelacionLineal(semilla: semilla).generar(dificultad: dif),
              ),
              dificultad: fragmento.dificultadSugerida ?? 1,
            ),
          ),
        );
      case TipoFragmentoEnTejado.decimal:
        final decimalObjetivo = _buscarDecimalConocido(
          fragmento.etiquetaDecimal,
        );
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) =>
                PantallaDecimal(decimalObjetivo: decimalObjetivo),
          ),
        );
      case TipoFragmentoEnTejado.porcentaje:
        final porcentajeObjetivo = _buscarPorcentajeConocido(
          fragmento.etiquetaDecimal,
        );
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) =>
                PantallaPorcentaje(porcentajeObjetivo: porcentajeObjetivo),
          ),
        );
      case TipoFragmentoEnTejado.impropio:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaImpropio(
              numerador: fragmento.numerador,
              denominador: fragmento.denominador,
            ),
          ),
        );
      case TipoFragmentoEnTejado.proporcional:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaProporcional(
              a: fragmento.numerador,
              b: fragmento.denominador,
            ),
          ),
        );
      case TipoFragmentoEnTejado.dual:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaDual(
              numeradorA: fragmento.numerador,
              denominadorA: fragmento.denominador,
              numeradorB: fragmento.numeradorB ?? 1,
              denominadorB: fragmento.denominadorB ?? 2,
              operador: fragmento.operador ?? OperadorAritmetico.suma,
            ),
          ),
        );
      case TipoFragmentoEnTejado.operacionDecimal:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaOperacionDecimal(
              etiquetaA: fragmento.decimalA ?? '0,5',
              etiquetaB: fragmento.decimalB ?? '0,5',
              operador: fragmento.operador ?? OperadorAritmetico.suma,
            ),
          ),
        );
      case TipoFragmentoEnTejado.unitario:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaCombateEnfoque(
              numerador: fragmento.numerador,
              denominador: fragmento.denominador,
            ),
          ),
        );
      case TipoFragmentoEnTejado.comparacion:
        // Piloto del verbo manipulativo (doc 16, eje A — Fase D3):
        // la mitad de los encuentros abren la balanza (arrastrar el
        // platillo) y la otra mitad la pantalla clásica de tarjetas.
        // El reparto es determinista por Fragmento para que el testeo
        // pueda comparar las dos formas con el mismo niño.
        final usaBalanza = fragmento.identificador.hashCode.isEven;
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) {
              final a = Fraccion(fragmento.numerador, fragmento.denominador);
              final b = Fraccion(
                fragmento.numeradorB ?? fragmento.numerador,
                fragmento.denominadorB ?? fragmento.denominador,
              );
              final modo = fragmento.modoComparacion ??
                  ModoComparacion.mismoDenominador;
              return usaBalanza
                  ? PantallaComparacionBalanza(a: a, b: b, modo: modo)
                  : PantallaComparacion(a: a, b: b, modo: modo);
            },
          ),
        );
      case TipoFragmentoEnTejado.simplificar:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaSimplificar(
              numerador: fragmento.numerador,
              denominador: fragmento.denominador,
            ),
          ),
        );
      case TipoFragmentoEnTejado.amplificar:
        // Usamos `denominadorB` como denominador objetivo si vino
        // calculado por el generador; si no, fabricamos uno multiplicando
        // la base por 3 — tolerante a Fragmentos manuales.
        final objetivo = fragmento.denominadorB ?? fragmento.denominador * 3;
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaAmplificar(
              numeradorBase: fragmento.numerador,
              denominadorBase: fragmento.denominador,
              denominadorObjetivo: objetivo,
            ),
          ),
        );
      case TipoFragmentoEnTejado.divisibilidad:
        // numerador → número candidato; denominador → divisor.
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaDivisibilidad(
              problemaPredeterminado: ProblemaDivisibilidad(
                numero: fragmento.numerador,
                divisor: fragmento.denominador,
              ),
              modo: ModoFraseoDivisibilidad.divisible,
            ),
          ),
        );
      case TipoFragmentoEnTejado.multiplos:
        // Misma estructura, fraseado distinto: "¿es múltiplo de M?".
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaDivisibilidad(
              problemaPredeterminado: ProblemaDivisibilidad(
                numero: fragmento.numerador,
                divisor: fragmento.denominador,
              ),
              modo: ModoFraseoDivisibilidad.multiplo,
            ),
          ),
        );
      case TipoFragmentoEnTejado.lecturaDecimal:
        // El texto del decimal viaja en etiquetaDecimal — la pantalla
        // reconstruye el problema con sus distractores curados.
        final textoEnPalabras = fragmento.etiquetaDecimal ?? 'tres décimas';
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaLecturaDecimal(
              problemaPredeterminado:
                  GeneradorLecturaDecimal().generarDesdeTexto(textoEnPalabras),
            ),
          ),
        );
      case TipoFragmentoEnTejado.comparacionDecimal:
        // decimalA/decimalB llevan las dos etiquetas tal cual; si el
        // Fragmento se construyó manualmente sin ellas, fabricamos un
        // par fácil para no dejar al niño en blanco.
        final etiquetaA = fragmento.decimalA ?? '0,3';
        final etiquetaB = fragmento.decimalB ?? '0,7';
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaComparacionDecimal(
              problemaPredeterminado: ProblemaComparacionDecimal(
                etiquetaA: etiquetaA,
                etiquetaB: etiquetaB,
                valorA:
                    double.parse(etiquetaA.replaceAll(',', '.')),
                valorB:
                    double.parse(etiquetaB.replaceAll(',', '.')),
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.comparacionUnidad:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaComparacionUnidad(
              problemaPredeterminado: ProblemaComparacionUnidad(
                fraccion: Fraccion(
                  fragmento.numerador,
                  fragmento.denominador,
                ),
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.lecturaFraccion:
        // El texto viaja en etiquetaDecimal — la pantalla reconstruye
        // el problema con sus distractores curados.
        final textoEnPalabras =
            fragmento.etiquetaDecimal ?? 'tres quintos';
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaLecturaFraccion(
              problemaPredeterminado: GeneradorLecturaFraccion()
                  .generarDesdeTexto(textoEnPalabras),
            ),
          ),
        );
      case TipoFragmentoEnTejado.mixtoAImpropio:
        // numeradorB lleva el entero; numerador/denominador llevan la
        // impropia ya calculada — al reconstruir el mixto, tomamos
        // num original = numerador − entero × denominador.
        final entero = fragmento.numeradorB ?? 1;
        final denominador = fragmento.denominador;
        final numeradorMixto = fragmento.numerador - entero * denominador;
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaMixtoAImpropio(
              problemaPredeterminado: _construirMixtoAImpropio(
                entero: entero,
                numerador: numeradorMixto,
                denominador: denominador,
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.redondeoDecimal:
        final etiquetaOriginal = fragmento.etiquetaDecimal ?? '2,37';
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaRedondeoDecimal(
              problemaPredeterminado: GeneradorRedondeoDecimal()
                  .generarDesdeEtiqueta(etiquetaOriginal),
            ),
          ),
        );
      case TipoFragmentoEnTejado.comparacionDistinta:
        final problemaDistinta = ProblemaComparacionDistinta(
          a: Fraccion(fragmento.numerador, fragmento.denominador),
          b: Fraccion(
            fragmento.numeradorB ?? fragmento.numerador,
            fragmento.denominadorB ?? fragmento.denominador,
          ),
        );
        // Mitad de los Fragmentos se resuelven cortando la tarta (doc
        // 16, eje A), como la balanza en FR.05/06: mismo problema,
        // gesto manipulativo en vez de tarjeta.
        final usaTarta = fragmento.identificador.hashCode.isEven;
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => usaTarta
                ? PantallaComparacionTarta(problema: problemaDistinta)
                : PantallaComparacionDistinta(
                    problemaPredeterminado: problemaDistinta),
          ),
        );
      case TipoFragmentoEnTejado.primo:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaPrimo(
              problemaPredeterminado:
                  ProblemaPrimo(numero: fragmento.numerador),
            ),
          ),
        );
      case TipoFragmentoEnTejado.reglaDeTres:
        // numerador → a, denominador → b, numeradorB → c.
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaReglaDeTres(
              problemaPredeterminado: GeneradorReglaDeTres()
                  .generarDesdeTerminos(
                a: fragmento.numerador,
                b: fragmento.denominador,
                c: fragmento.numeradorB ?? 1,
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.ordenarDecimales:
        // decimalA, decimalB y etiquetaDecimal recomponen los tres
        // decimales presentados (la etiqueta carga los tres
        // separados por '|').
        final partes = (fragmento.etiquetaDecimal ?? '').split('|');
        final trio = partes.length == 3
            ? partes
            : <String>[
                fragmento.decimalA ?? '0,5',
                fragmento.decimalB ?? '0,3',
                '0,8',
              ];
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaOrdenarDecimales(
              problemaPredeterminado: GeneradorOrdenarDecimales()
                  .generarDesdeTrio(trio),
            ),
          ),
        );
      case TipoFragmentoEnTejado.mcmMcd:
        // numerador/denominador → los dos números a calcular.
        // etiquetaDecimal → 'mcm' o 'mcd'.
        final modo = fragmento.etiquetaDecimal == 'mcd'
            ? ModoMcmMcd.mcd
            : ModoMcmMcd.mcm;
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaMcmMcd(
              problemaPredeterminado: GeneradorMcmMcd().generarDesdeTerminos(
                a: fragmento.numerador,
                b: fragmento.denominador,
                modo: modo,
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.jerarquia:
        // numerador → a, denominador → b, numeradorB → c.
        // operador → op2, decimalA → name del op1.
        final op1 = OperadorAritmetico.values.firstWhere(
          (o) => o.name == fragmento.decimalA,
          orElse: () => OperadorAritmetico.suma,
        );
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaJerarquia(
              problemaPredeterminado:
                  GeneradorJerarquia().generarDesdeTerminos(
                a: fragmento.numerador,
                b: fragmento.denominador,
                c: fragmento.numeradorB ?? 1,
                op1: op1,
                op2: fragmento.operador ?? OperadorAritmetico.suma,
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.comparacionMedia:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaComparacionMedia(
              problemaPredeterminado: GeneradorComparacionMedia()
                  .generarDesdeFraccion(
                Fraccion(fragmento.numerador, fragmento.denominador),
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.porcentajeCantidad:
        // numerador → porcentaje, denominador → cantidad.
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaPorcentajeCantidad(
              problemaPredeterminado: GeneradorPorcentajeCantidad()
                  .generarDesdePar(fragmento.numerador, fragmento.denominador),
            ),
          ),
        );
      case TipoFragmentoEnTejado.divisores:
        // numerador → número objetivo.
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaDivisores(
              problemaPredeterminado: GeneradorDivisores()
                  .generarDesdeNumero(fragmento.numerador),
            ),
          ),
        );
      case TipoFragmentoEnTejado.fraccionDeCantidad:
        // numerador → numerador, denominador → denominador, numeradorB → cantidad.
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaFraccionDeCantidad(
              problemaPredeterminado: GeneradorFraccionDeCantidad()
                  .generarDesdeTerminos(
                numerador: fragmento.numerador,
                denominador: fragmento.denominador,
                cantidad: fragmento.numeradorB ?? 1,
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.razon:
        // numerador/denominador → primero/segundo, decimalA/decimalB →
        // etiquetas del contexto.
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaRazon(
              problemaPredeterminado: GeneradorRazon().generarDesdePar(
                primero: fragmento.numerador,
                segundo: fragmento.denominador,
                etiquetaPrimero: fragmento.decimalA ?? 'rojas',
                etiquetaSegundo: fragmento.decimalB ?? 'azules',
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.longitud:
        // numerador → valorOrigen, decimalA/decimalB → símbolos.
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaLongitud(
              problemaPredeterminado:
                  GeneradorLongitud().generarDesdeTerminos(
                valorOrigen: fragmento.numerador,
                unidadOrigen:
                    unidadDesdeSimbolo(fragmento.decimalA ?? 'm'),
                unidadDestino:
                    unidadDesdeSimbolo(fragmento.decimalB ?? 'cm'),
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.probabilidadPorcentaje:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaProbabilidadPorcentaje(
              problemaPredeterminado:
                  GeneradorProbabilidadPorcentaje().generarPorIndice(
                fragmento.numerador,
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.operacionMixta:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaOperacionMixta(
              problemaPredeterminado:
                  GeneradorOperacionMixta().generarPorIndice(
                fragmento.numerador,
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.poligono:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaPoligono(
              problemaPredeterminado:
                  GeneradorPoligono().generarDesdeLados(
                fragmento.numerador,
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.perimetro:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaPerimetro(
              problemaPredeterminado: GeneradorPerimetro()
                  .generarPorIndice(fragmento.numerador),
            ),
          ),
        );
      case TipoFragmentoEnTejado.areaRectangulo:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaAreaRectangulo(
              problemaPredeterminado: GeneradorAreaRectangulo()
                  .generarPorIndice(fragmento.numerador),
            ),
          ),
        );
      case TipoFragmentoEnTejado.areaTriangulo:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaAreaTriangulo(
              problemaPredeterminado: GeneradorAreaTriangulo()
                  .generarPorIndice(fragmento.numerador),
            ),
          ),
        );
      case TipoFragmentoEnTejado.graficoCircular:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaGraficoCircular(
              problemaPredeterminado: GeneradorGraficoCircular()
                  .generarPorIndice(fragmento.numerador),
            ),
          ),
        );
      case TipoFragmentoEnTejado.graficoBarras:
        final modoGrafico = fragmento.denominador == 2
            ? ModoGraficoBarras.total
            : ModoGraficoBarras.valorDeBarra;
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaGraficoBarras(
              problemaPredeterminado: GeneradorGraficoBarras()
                  .generarPorIndiceYModo(fragmento.numerador, modoGrafico),
            ),
          ),
        );
      case TipoFragmentoEnTejado.simetria:
        final formaSimetrica = GeneradorSimetria.formasCuradas[
            fragmento.numerador.clamp(0, GeneradorSimetria.cantidadDeFormas - 1)];
        final ejeSimetria = fragmento.denominador == 2
            ? EjeSimetria.horizontal
            : EjeSimetria.vertical;
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaSimetria(
              problemaPredeterminado: GeneradorSimetria()
                  .generarDesde(formaSimetrica, ejeSimetria),
            ),
          ),
        );
      case TipoFragmentoEnTejado.volumen:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaVolumen(
              problemaPredeterminado: GeneradorVolumen()
                  .generarPorIndice(fragmento.numerador),
            ),
          ),
        );
      case TipoFragmentoEnTejado.circulo:
        final radio = GeneradorCirculo.radiosCurados[
            fragmento.numerador.clamp(0, GeneradorCirculo.cantidadDeRadiosCurados - 1)];
        final modoCirculo = fragmento.denominador == 2
            ? ModoCirculo.area
            : ModoCirculo.perimetro;
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaCirculo(
              problemaPredeterminado:
                  GeneradorCirculo().generarDesde(radio, modoCirculo),
            ),
          ),
        );
      case TipoFragmentoEnTejado.probabilidad:
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaProbabilidad(
              problemaPredeterminado: GeneradorProbabilidad()
                  .generarPorIndice(fragmento.numerador),
            ),
          ),
        );
      case TipoFragmentoEnTejado.modaMediana:
        // numerador → índice; denominador → 1 moda, 2 mediana.
        final modoEst = fragmento.denominador == 2
            ? ModoEstadistico.mediana
            : ModoEstadistico.moda;
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaModaMediana(
              problemaPredeterminado: GeneradorModaMediana()
                  .generarPorIndice(modoEst, fragmento.numerador),
            ),
          ),
        );
      case TipoFragmentoEnTejado.media:
        // numerador → índice del conjunto curado.
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaMedia(
              problemaPredeterminado:
                  GeneradorMedia().generarPorIndice(fragmento.numerador),
            ),
          ),
        );
      case TipoFragmentoEnTejado.angulo:
        // numerador → grados. Piloto manipulativo (doc 16, eje A):
        // la mitad de los encuentros piden PRODUCIR la categoría
        // girando el brazo, en vez de reconocerla entre tarjetas.
        // "Completo" (360°) no se puede formar con el brazo de 0-180
        // — esos caen siempre en la pantalla clásica.
        final objetivoAngulo = clasificarAngulo(fragmento.numerador);
        final usaBrazo = fragmento.identificador.hashCode.isEven &&
            objetivoAngulo != TipoAngulo.completo;
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => usaBrazo
                ? PantallaAnguloManipulativo(objetivo: objetivoAngulo)
                : PantallaAngulo(
                    problemaPredeterminado: GeneradorAngulo()
                        .generarDesdeGrados(fragmento.numerador),
                  ),
          ),
        );
      case TipoFragmentoEnTejado.escala:
        // numerador → denominadorEscala, denominador → valorPlanoCm.
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaEscala(
              problemaPredeterminado: GeneradorEscala().generarDesdeTerminos(
                denominadorEscala: fragmento.numerador,
                valorPlanoCm: fragmento.denominador,
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.jerarquiaFracciones:
        // numerador → índice del caso curado.
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaJerarquiaFracciones(
              problemaPredeterminado: GeneradorJerarquiaFracciones()
                  .generarPorIndice(fragmento.numerador),
            ),
          ),
        );
      case TipoFragmentoEnTejado.superficie:
        // numerador → valorOrigen, decimalA/decimalB → símbolos.
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaSuperficie(
              problemaPredeterminado:
                  GeneradorSuperficie().generarDesdeTerminos(
                valorOrigen: fragmento.numerador,
                unidadOrigen: unidadSuperficieDesdeSimbolo(
                    fragmento.decimalA ?? 'm²'),
                unidadDestino: unidadSuperficieDesdeSimbolo(
                    fragmento.decimalB ?? 'cm²'),
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.aumentoDescuento:
        // numerador → porcentaje, denominador → cantidad,
        // decimalA → 'A' (aumento) o 'D' (descuento).
        final tipoVariacion = (fragmento.decimalA ?? 'A') == 'A'
            ? TipoVariacionPorcentual.aumento
            : TipoVariacionPorcentual.descuento;
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaAumentoDescuento(
              problemaPredeterminado:
                  GeneradorAumentoDescuento().generarDesdeTerminos(
                tipo: tipoVariacion,
                porcentaje: fragmento.numerador,
                cantidad: fragmento.denominador,
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.tiempo:
        // numeradorB > 0 → compuesto (h y min → min). null → simple.
        final problemaTiempo = fragmento.numeradorB != null
            ? GeneradorTiempo().generarCompuestoDesdeTerminos(
                horas: fragmento.numerador,
                minutos: fragmento.numeradorB!,
              )
            : GeneradorTiempo().generarSimpleDesdeTerminos(
                valor: fragmento.numerador,
                origen: unidadTiempoDesdeSimbolo(
                    fragmento.decimalA ?? 'h'),
                destino: unidadTiempoDesdeSimbolo(
                    fragmento.decimalB ?? 'min'),
              );
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaTiempo(
              problemaPredeterminado: problemaTiempo,
            ),
          ),
        );
      case TipoFragmentoEnTejado.porcentajeDe:
        // numerador → parte, denominador → total.
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaPorcentajeDe(
              problemaPredeterminado: GeneradorPorcentajeDe()
                  .generarDesdeTerminos(
                parte: fragmento.numerador,
                total: fragmento.denominador,
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.masaCapacidad:
        // numerador → valorOrigen, decimalA/decimalB → símbolos. La
        // familia se infiere parseando el símbolo de origen.
        final origen = unidadDesdeSimboloMetrica(fragmento.decimalA ?? 'g');
        final destino = unidadDesdeSimboloMetrica(fragmento.decimalB ?? 'mg');
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaMasaCapacidad(
              problemaPredeterminado:
                  GeneradorMasaCapacidad().generarDesdeTerminos(
                familia: origen.familia,
                valorOrigen: fragmento.numerador,
                posicionOrigen: origen.posicion,
                posicionDestino: destino.posicion,
              ),
            ),
          ),
        );
      case TipoFragmentoEnTejado.ordenarFracciones:
        // etiquetaDecimal lleva las tres fracciones separadas por '|'
        // ('3/5|2/3|1/2'). Reconstruimos el trío.
        final partes = (fragmento.etiquetaDecimal ?? '').split('|');
        final fallback = [
          const Fraccion(1, 2),
          const Fraccion(1, 3),
          const Fraccion(1, 4),
        ];
        final trio = partes.length == 3
            ? partes.map((p) {
                final ab = p.split('/');
                return Fraccion(int.parse(ab[0]), int.parse(ab[1]));
              }).toList()
            : fallback;
        return Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaOrdenarFracciones(
              problemaPredeterminado: GeneradorOrdenarFracciones()
                  .generarDesdeTrio(trio),
            ),
          ),
        );
    }
  }

  ProblemaMixtoAImpropio _construirMixtoAImpropio({
    required int entero,
    required int numerador,
    required int denominador,
  }) {
    // Reconstruye el problema FR.13 con los distractores pedagógicos
    // canónicos a partir de un mixto concreto. Los cuatro candidatos
    // siempre incluyen el correcto, la suma errónea, la fracción sola
    // y el producto sin sumar.
    final correcto = Fraccion(entero * denominador + numerador, denominador);
    final propuestos = <Fraccion>[correcto];
    bool yaEsta(Fraccion f) =>
        propuestos.any((p) =>
            p.numerador == f.numerador && p.denominador == f.denominador);
    void anyadirSiNuevo(Fraccion f) {
      if (f.numerador > 0 && !yaEsta(f)) propuestos.add(f);
    }

    anyadirSiNuevo(Fraccion(entero + numerador, denominador));
    anyadirSiNuevo(Fraccion(numerador, denominador));
    anyadirSiNuevo(Fraccion(entero * numerador, denominador));

    var paso = 1;
    while (propuestos.length < 4) {
      anyadirSiNuevo(Fraccion(correcto.numerador + paso, denominador));
      if (propuestos.length < 4) {
        anyadirSiNuevo(Fraccion(correcto.numerador - paso, denominador));
      }
      paso++;
    }

    final indice = propuestos.indexWhere(
      (f) =>
          f.numerador == correcto.numerador &&
          f.denominador == correcto.denominador,
    );
    return ProblemaMixtoAImpropio(
      entero: entero,
      numerador: numerador,
      denominador: denominador,
      candidatos: propuestos,
      indiceCorrecto: indice,
    );
  }

  DecimalConocido? _buscarDecimalConocido(String? etiqueta) {
    if (etiqueta == null) return null;
    for (final d in decimalesConocidos) {
      if (d.etiqueta == etiqueta) return d;
    }
    return null;
  }

  PorcentajeConocido? _buscarPorcentajeConocido(String? etiqueta) {
    if (etiqueta == null) return null;
    for (final p in porcentajesConocidos) {
      if (p.etiqueta == etiqueta) return p;
    }
    return null;
  }

  /// Reconstruye el problema de una pantalla Era 3 desde la semilla
  /// guardada en el Fragmento. Sin esto, la pantalla genera un problema
  /// nuevo aleatorio al abrir y el "7³" del spawn aparece como "2⁵".
  /// Si el Fragmento viene de un test sin semilla, devuelve null y la
  /// pantalla cae a `generar(dificultad)` con su propia semilla.
  T? _reconstruirEra3<T>(
    FragmentoEnTejado fragmento,
    T Function(int semilla, int dificultad) generador,
  ) {
    final semilla = fragmento.semillaProblema;
    if (semilla == null) return null;
    return generador(semilla, fragmento.dificultadSugerida ?? 1);
  }

  /// Comprueba si el total acumulado de esquirlas implica subir de
  /// rango y, si es así, lo persiste y activa el flag narrativo de
  /// **cada rango intermedio** para que las escenas que dependen de
  /// rangos previos no queden latentes. Sin esto, importar progreso
  /// del servidor o un salto grande de esquirlas podía cruzar dos
  /// umbrales en una captura y dejar la 1.13 (requiere Aprendiz II)
  /// huérfana.
  Future<void> _verificarSubidaDeRango() async {
    final actual = await widget.repositorio.cargarRango();
    final segunEsquirlas = rangoSegunEsquirlas(_esquirlasTotal);
    if (segunEsquirlas.valor > actual.valor) {
      await widget.repositorio.guardarRango(segunEsquirlas);
      for (var i = actual.valor + 1; i <= segunEsquirlas.valor; i++) {
        await widget.repositorio
            .activarFlagNarrativo(RangoNarrativo.values[i].flagAlcanzado);
      }
    }
  }

  /// Registra el intento contra el motor de maestría. Silencioso: si
  /// el motor aún no se ha cargado (carga asíncrona), simplemente no
  /// registra; la siguiente partida lo hará.
  Future<void> _registrarResultadoMaestria(
    FragmentoEnTejado fragmento,
    bool acertado,
  ) async {
    final motor = _motorMaestria;
    if (motor == null) return;
    final instanteAbierto =
        _instanteAperturaPuzzle.remove(fragmento.identificador);
    final duracionSeg = instanteAbierto == null
        ? 15
        : DateTime.now().difference(instanteAbierto).inSeconds.clamp(1, 600);
    await motor.registrarResultado(
      idHabilidad: idHabilidadPrincipal(fragmento),
      acierto: acertado,
      dificultad: dificultadEstimadaDelPuzzle(fragmento),
      duracionSegundos: duracionSeg,
    );
  }

  /// Registra el resultado en el contador del tutor (fallos
  /// consecutivos por habilidad). También lleva un conteo local
  /// para ofrecer ayuda aunque no haya backend.
  Future<void> _registrarEnTutor(
    FragmentoEnTejado fragmento,
    bool acertado,
  ) async {
    final id = idHabilidadPrincipal(fragmento);
    // Conteo local (siempre, incluso sin backend)
    if (acertado) {
      _fallosLocalesConsecutivos[id] = 0;
    } else {
      _fallosLocalesConsecutivos[id] =
          (_fallosLocalesConsecutivos[id] ?? 0) + 1;
    }
    // Conteo remoto (solo si hay backend)
    final servicio = _servicioTutor;
    if (servicio == null) return;
    await servicio.registrarResultado(
      idHabilidad: id,
      acierto: acertado,
    );
  }

  /// Si el niño se ha atascado en esta habilidad y la política dice
  /// que toca, le mostramos un dialog cariñoso con la voz de Sora
  /// para que pueda hablar con Eco. Tanto si acepta como si rechaza
  /// arrancamos el cooldown de la oferta — el "no, sigo solo" cuenta
  /// como respuesta válida y no queremos repetir la oferta cada
  /// pocos minutos. Si la sigue necesitando, el contador del tutor
  /// se mantiene: cuando expire el cooldown volverá a ofrecerse.
  Future<void> _quizasOfrecerTutor(FragmentoEnTejado fragmento) async {
    final idHabilidad = idHabilidadPrincipal(fragmento);
    final servicio = _servicioTutor;

    // Fallback local: si no hay tutor backend pero el niño ha fallado
    // 3+ veces, ofrecemos la ayuda local de AyudaPuzzle.
    if (servicio == null) {
      final fallos = _fallosLocalesConsecutivos[idHabilidad] ?? 0;
      if (fallos < 3) return;
      if (_cooldownAyudaLocal.contains(idHabilidad)) return;
      _cooldownAyudaLocal.add(idHabilidad);
      if (!mounted) return;
      await _mostrarAyudaLocal(fragmento);
      return;
    }

    if (!await servicio.deberiaOfrecer(idHabilidad)) return;
    if (!mounted) return;
    final nombreHabilidad = _nombreVisibleDeHabilidad(idHabilidad);

    // Firma sonora de Eco al aparecer la oferta. Capa narrativos
    // → ducking automático sobre ambient/música. Si el asset aún
    // no está, ServicioSonoro lo registra como ausente y prosigue
    // en silencio, sin crash.
    ServicioSonoro.instancia.reproducirEfecto('motivo_eco');

    final textos = AppLocalizations.of(context);
    final acepta = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (contexto) => AlertDialog(
        backgroundColor: PaletaNeon.fondoMedio,
        title: Text(
          textos.tutorOfertaTitulo,
          style: const TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 18,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          textos.tutorOfertaCuerpo(nombreHabilidad.toLowerCase()),
          style: const TextStyle(
            color: PaletaNeon.textoTenue,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: Text(
              textos.tutorOfertaSigoSolo,
              style: const TextStyle(color: PaletaNeon.textoTenue),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: Text(
              textos.tutorOfertaSi,
              style: const TextStyle(color: PaletaNeon.violetaNeon),
            ),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (acepta != true) {
      // Rechazó la oferta. Arrancamos cooldown para no insistir.
      // (Si la hubiera aceptado, PantallaTutor llama a registrarOferta
      // por su cuenta cuando se monta — no duplicamos aquí.)
      await servicio.registrarOferta(idHabilidad);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaTutor(
          servicio: servicio,
          idHabilidad: idHabilidad,
          nombreHabilidad: nombreHabilidad,
          contextoFragmento: _contextoFragmento(fragmento),
        ),
      ),
    );
  }

  /// Muestra ayuda local (sin backend) usando la explicación de
  /// AyudaPuzzle. Se dispara tras 3 fallos consecutivos si no hay
  /// tutor remoto disponible.
  Future<void> _mostrarAyudaLocal(FragmentoEnTejado fragmento) async {
    final (tituloEs, textoEs, transferenciaEs) =
        AyudaPuzzle.paraTipo(fragmento.tipo);
    if (!mounted) return;
    final locale = Localizations.localeOf(context);
    final titulo = traducirNarrativa(tituloEs, locale);
    final texto = traducirNarrativa(textoEs, locale);
    final transferencia = traducirNarrativa(transferenciaEs, locale);
    final etiquetaSeguir = traducirNarrativa('SEGUIR', locale);
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => AlertDialog(
        backgroundColor: PaletaNeon.fondoMedio,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: PaletaNeon.textoTenue.withOpacity(0.2),
          ),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                texto,
                style: const TextStyle(
                  color: PaletaNeon.textoTenue,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              if (transferencia.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PaletaNeon.fondoProfundo.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u{1F4A1} ',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Expanded(
                        child: Text(
                          transferencia,
                          style: const TextStyle(
                            color: PaletaNeon.textoPrincipal,
                            fontSize: 13,
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              etiquetaSeguir,
              style: const TextStyle(
                color: PaletaNeon.violetaNeon,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Si es la primera vez que el niño se enfrenta a esta familia de
  /// puzzle en este perfil, abre un AlertDialog con la explicación
  /// pedagógica de AyudaPuzzle (título + texto + transferencia) y un
  /// botón EMPEZAR. Sin temporizador: el niño dispone del tiempo que
  /// necesite. Tras cerrar, marca la familia como vista y vuelve para
  /// que el flujo de [_alTocarFragmento] abra el puzzle.
  Future<void> _mostrarAyudaPuzzleSiPrimeraVez(
      FragmentoEnTejado fragmento) async {
    final idTipo = fragmento.tipo.name;
    if (_ayudasPuzzlesVistas.contains(idTipo)) return;
    final (tituloEs, textoEs, transferenciaEs) =
        AyudaPuzzle.paraTipo(fragmento.tipo);
    if (!mounted) return;
    final locale = Localizations.localeOf(context);
    final titulo = traducirNarrativa(tituloEs, locale);
    final texto = traducirNarrativa(textoEs, locale);
    final transferencia = traducirNarrativa(transferenciaEs, locale);
    final etiquetaEmpezar = traducirNarrativa('EMPEZAR', locale);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => AlertDialog(
        backgroundColor: PaletaNeon.fondoMedio,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: PaletaNeon.textoTenue.withOpacity(0.2),
          ),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                texto,
                style: const TextStyle(
                  color: PaletaNeon.textoTenue,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              if (transferencia.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PaletaNeon.fondoProfundo.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '\u{1F4A1} ',
                        style: TextStyle(fontSize: 14),
                      ),
                      Expanded(
                        child: Text(
                          transferencia,
                          style: const TextStyle(
                            color: PaletaNeon.textoPrincipal,
                            fontSize: 13,
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              etiquetaEmpezar,
              style: const TextStyle(
                color: PaletaNeon.violetaNeon,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
    await widget.repositorio.marcarAyudaPuzzleVista(idTipo);
    _ayudasPuzzlesVistas = {..._ayudasPuzzlesVistas, idTipo};
  }

  String _nombreVisibleDeHabilidad(String id) {
    final catalogo = _selectorHabilidades?.catalogo;
    if (catalogo == null) return id;
    return catalogo.porId(id)?.nombre ?? id;
  }

  /// Texto descriptivo del Fragmento que el backend recibe como
  /// contexto. No se muestra al niño — sirve a Anthropic para saber
  /// qué tiene delante.
  String _contextoFragmento(FragmentoEnTejado fragmento) {
    final tipo = fragmento.tipo.name;
    final skillId = idHabilidadPrincipal(fragmento);
    final habilidad = _selectorHabilidades?.catalogo.porId(skillId);
    final nombre = habilidad?.nombre ?? skillId;
    final (pregunta, errorTipico) = _descripcionPuzzle(fragmento);
    final intentos = intentosPuzzleActual;
    final acertado = intentos <= 1;

    // Si el puzzle registró la respuesta concreta, la usamos.
    final respuesta = UltimaRespuestaPuzzle.ultima;
    UltimaRespuestaPuzzle.limpiar();

    final respuestaTexto = respuesta != null
        ? '''
Respuesta del niño: ${respuesta.respuestaDelNino}
Respuesta correcta: ${respuesta.respuestaCorrecta}
Opciones: ${respuesta.opciones.join(' | ')}
Pregunta exacta: ${respuesta.preguntaTexto}'''
        : '';

    return '''
Skill: $skillId ($nombre)
Tipo: $tipo n=${fragmento.numerador} d=${fragmento.denominador}
Pregunta: $pregunta
Resultado: ${acertado ? 'acertado a la primera' : 'falló $intentos veces antes de acertar'}
Error típico en esta skill: $errorTipico$respuestaTexto''';
  }

  /// Describe qué pregunta plantea este Fragmento y cuál es el error
  /// más común, para que el tutor IA pueda contextualizar la ayuda.
  (String pregunta, String errorTipico) _descripcionPuzzle(
      FragmentoEnTejado f) {
    switch (f.tipo) {
      case TipoFragmentoEnTejado.unitario:
        return (
          'cortar ${f.numerador}/${f.denominador} en partes iguales',
          'confundir el número de cortes con el número de partes'
        );
      case TipoFragmentoEnTejado.comparacion:
        final esMismoNum = f.modoComparacion == ModoComparacion.mismoNumerador;
        return (
          esMismoNum
              ? '¿qué fracción es mayor? mismo numerador'
              : '¿qué fracción es mayor? mismo denominador',
          esMismoNum
              ? 'creer que denominador mayor = fracción mayor'
              : 'confundir numerador y denominador'
        );
      case TipoFragmentoEnTejado.comparacionDistinta:
        return (
          '¿qué fracción es mayor? sin nada en común',
          'comparar solo numeradores o solo denominadores en vez de multiplicar en cruz'
        );
      case TipoFragmentoEnTejado.comparacionUnidad:
        return (
          '¿${f.numerador}/${f.denominador} es <1, =1 o >1?',
          'creer que numerador < denominador significa <1 (falso si es impropia)'
        );
      case TipoFragmentoEnTejado.comparacionMedia:
        return (
          '¿${f.numerador}/${f.denominador} es <1/2, =1/2 o >1/2?',
          'comparar numerador y denominador directamente sin aplicar 2n > d'
        );
      case TipoFragmentoEnTejado.espejo:
        return (
          'elegir la fracción equivalente a ${f.numerador}/${f.denominador}',
          'multiplicar numerador pero no denominador, o viceversa'
        );
      case TipoFragmentoEnTejado.simplificar:
        return (
          'simplificar ${f.numerador}/${f.denominador} al máximo',
          'no encontrar el MCD o simplificar solo un término'
        );
      case TipoFragmentoEnTejado.amplificar:
        return (
          'completar la fracción equivalente: ${f.numerador}/${f.denominador} = ?/${f.denominadorB ?? 0}',
          'multiplicar por el factor equivocado o sumar en vez de multiplicar'
        );
      case TipoFragmentoEnTejado.decimal:
        return (
          'elegir el decimal que equivale a ${f.numerador}/${f.denominador}',
          'confundir décimas con centésimas'
        );
      case TipoFragmentoEnTejado.porcentaje:
        return (
          'elegir el porcentaje equivalente a la fracción',
          'confundir % con decimal'
        );
      case TipoFragmentoEnTejado.dual:
        final op = f.operador?.simbolo ?? '+';
        return (
          'calcular ${f.numerador}/${f.denominador} $op ${f.numeradorB}/${f.denominadorB}',
          'sumar numeradores sin igualar denominadores o confundir la operación'
        );
      case TipoFragmentoEnTejado.operacionDecimal:
        final op = f.operador?.simbolo ?? '+';
        return (
          'calcular ${f.decimalA ?? ''} $op ${f.decimalB ?? ''}',
          'colocar mal la coma decimal o no alinear cifras'
        );
      case TipoFragmentoEnTejado.jerarquia:
        return (
          'calcular respetando prioridad de × y ÷',
          'operar de izquierda a derecha sin respetar jerarquía'
        );
      case TipoFragmentoEnTejado.jerarquiaFracciones:
        return (
          'calcular con fracciones respetando prioridad de × y ÷',
          'operar izquierda a derecha sin respetar jerarquía ni igualar denominadores'
        );
      case TipoFragmentoEnTejado.operacionMixta:
        return (
          'calcular operación mixta decimal + fracción',
          'convertir mal la fracción a decimal o viceversa'
        );
      case TipoFragmentoEnTejado.divisibilidad:
        final divisor = f.denominador;
        return (
          '¿el número es divisible entre $divisor?',
          'aplicar mal el criterio de divisibilidad o confundir múltiplo con divisor'
        );
      case TipoFragmentoEnTejado.multiplos:
        return (
          '¿el número es múltiplo?',
          'confundir múltiplo con divisor'
        );
      case TipoFragmentoEnTejado.divisores:
        return (
          'tres son divisores, tocar el que NO lo es',
          'no comprobar la división exacta'
        );
      case TipoFragmentoEnTejado.primo:
        return (
          '¿${f.numerador} es primo?',
          'olvidar que 1 no es primo, o creer que impar = primo'
        );
      case TipoFragmentoEnTejado.mcmMcd:
        final esMcd = f.etiquetaDecimal == 'mcd';
        return (
          esMcd ? 'calcular el MCD' : 'calcular el MCM',
          esMcd
              ? 'confundir MCD con MCM, o escoger el menor sin descomponer'
              : 'confundir MCM con MCD, o multiplicar sin eliminar comunes'
        );
      case TipoFragmentoEnTejado.porcentajeCantidad:
        return (
          'calcular el porcentaje de una cantidad',
          'multiplicar sin dividir entre 100, o confundir % con el número literal'
        );
      case TipoFragmentoEnTejado.porcentajeDe:
        return (
          '¿qué porcentaje representa una parte del total?',
          'poner parte/total al revés o no multiplicar por 100'
        );
      case TipoFragmentoEnTejado.aumentoDescuento:
        return (
          'calcular aumento o descuento porcentual',
          'calcular solo la variación sin sumarla/restarla, o confundir aumento con descuento'
        );
      case TipoFragmentoEnTejado.proporcional:
        return (
          'completar la proporción',
          'aplicar la relación al revés'
        );
      case TipoFragmentoEnTejado.reglaDeTres:
        return (
          'regla de tres directa',
          'invertir la relación (multiplicar los términos equivocados)'
        );
      case TipoFragmentoEnTejado.razon:
        return (
          'elegir la razón reducida',
          'no simplificar o confundir el orden de los términos'
        );
      case TipoFragmentoEnTejado.fraccionDeCantidad:
        return (
          'calcular la fracción de una cantidad',
          'multiplicar sin dividir, o dividir sin multiplicar'
        );
      case TipoFragmentoEnTejado.escala:
        return (
          'aplicar escala y convertir unidades',
          'olvidar la conversión de unidades o confundir escala'
        );
      case TipoFragmentoEnTejado.lecturaFraccion:
        return (
          'leer el texto y elegir la fracción correcta',
          'invertir numerador y denominador'
        );
      case TipoFragmentoEnTejado.lecturaDecimal:
        return (
          'leer el texto y elegir el decimal correcto',
          'confundir décimas con centésimas o leer mal las cifras'
        );
      case TipoFragmentoEnTejado.redondeoDecimal:
        return (
          'redondear ${f.numerador},${f.denominador} a la décima',
          'truncar en vez de redondear, o redondear mal la centésima 5'
        );
      case TipoFragmentoEnTejado.comparacionDecimal:
        return (
          'tocar el decimal mayor',
          'elegir el de más cifras en vez del de mayor valor'
        );
      case TipoFragmentoEnTejado.ordenarDecimales:
        return (
          'ordenar decimales de menor a mayor',
          'ordenar por número de cifras en vez de por valor posicional'
        );
      case TipoFragmentoEnTejado.ordenarFracciones:
        return (
          'ordenar fracciones de menor a mayor',
          'ordenar solo por numerador o solo por denominador'
        );
      case TipoFragmentoEnTejado.impropio:
        return (
          'convertir fracción impropia a número mixto',
          'poner el resto como numerador sin cambiar el denominador'
        );
      case TipoFragmentoEnTejado.mixtoAImpropio:
        return (
          'convertir número mixto a fracción impropia',
          'multiplicar sin sumar, o sumar sin multiplicar'
        );
      case TipoFragmentoEnTejado.longitud:
        return (
          'convertir unidades de longitud',
          'aplicar el factor equivocado (×10 en vez de ×100, o dirección contraria)'
        );
      case TipoFragmentoEnTejado.masaCapacidad:
        return (
          'convertir unidades de masa o capacidad',
          'aplicar el factor lineal del metro a litros o gramos'
        );
      case TipoFragmentoEnTejado.superficie:
        return (
          'convertir unidades de superficie',
          'aplicar factor lineal (×10) en vez de ×100 por peldaño'
        );
      case TipoFragmentoEnTejado.tiempo:
        return (
          'convertir unidades de tiempo (horas, minutos, segundos)',
          'tratar el tiempo como decimal (base 60 vs base 10)'
        );
      case TipoFragmentoEnTejado.angulo:
        return (
          'clasificar el ángulo por su abertura',
          'confundir obtuso con agudo, o no identificar el recto exacto'
        );
      case TipoFragmentoEnTejado.poligono:
        return (
          'nombrar el polígono por su número de lados',
          'confundir el nombre (pentágono por hexágono)'
        );
      case TipoFragmentoEnTejado.perimetro:
        return (
          'calcular el perímetro del polígono',
          'olvidar un lado o sumar solo la base y la altura'
        );
      case TipoFragmentoEnTejado.areaRectangulo:
        return (
          'calcular el área del rectángulo',
          'calcular el perímetro en vez del área'
        );
      case TipoFragmentoEnTejado.areaTriangulo:
        return (
          'calcular el área del triángulo (b × h / 2)',
          'olvidar dividir entre 2'
        );
      case TipoFragmentoEnTejado.circulo:
        return (
          'calcular área o perímetro del círculo con π',
          'confundir área con perímetro, o usar diámetro en vez de radio'
        );
      case TipoFragmentoEnTejado.volumen:
        return (
          'calcular el volumen del ortoedro (l × a × h)',
          'calcular el área superficial en vez del volumen'
        );
      case TipoFragmentoEnTejado.simetria:
        return (
          '¿la figura es simétrica respecto al eje?',
          'confundir simetría axial con simetría rotacional'
        );
      case TipoFragmentoEnTejado.graficoBarras:
        return (
          'leer el valor de una barra en el gráfico',
          'leer la barra contigua o confundir la escala del eje'
        );
      case TipoFragmentoEnTejado.graficoCircular:
        return (
          'leer el porcentaje de una porción en el gráfico circular',
          'leer la porción contigua o confundir fracción visual con porcentaje'
        );
      case TipoFragmentoEnTejado.media:
        return (
          'calcular la media aritmética',
          'sumar sin dividir entre la cantidad de elementos'
        );
      case TipoFragmentoEnTejado.modaMediana:
        return (
          'calcular la moda o la mediana',
          'confundir moda con mediana o no ordenar los datos'
        );
      case TipoFragmentoEnTejado.probabilidad:
        return (
          'calcular la probabilidad como fracción',
          'poner casos favorables y totales al revés'
        );
      case TipoFragmentoEnTejado.probabilidadPorcentaje:
        return (
          'convertir probabilidad de fracción a porcentaje',
          'no multiplicar por 100 o confundir numerador y denominador'
        );
      case TipoFragmentoEnTejado.sumaBasica:
        return (
          'suma básica',
          'error de cálculo simple'
        );
      case TipoFragmentoEnTejado.ecuacionLineal:
        return (
          'resolver ecuación lineal simple',
          'no aislar la incógnita correctamente o error de signo al despejar'
        );
      case TipoFragmentoEnTejado.potenciaNatural:
        return (
          'calcular potencia natural',
          'multiplicar base × exponente en vez de base^exponente'
        );
      case TipoFragmentoEnTejado.raizCuadrada:
        return (
          'calcular raíz cuadrada',
          'elegir la mitad del número en vez de la raíz'
        );
      case TipoFragmentoEnTejado.pitagoras:
        return (
          'aplicar Pitágoras',
          'sumar catetos sin elevar al cuadrado, o no identificar la hipotenusa'
        );
      case TipoFragmentoEnTejado.ecuacionAmbosLados:
        return (
          'resolver ecuación con incógnita en ambos lados',
          'no agrupar términos semejantes antes de despejar'
        );
      case TipoFragmentoEnTejado.enteroSigno:
        return (
          'operar con enteros y signo',
          'error con la regla de signos (menos × menos = más)'
        );
      case TipoFragmentoEnTejado.valorAbsoluto:
        return (
          'calcular valor absoluto',
          'ignorar el valor absoluto y tratar como paréntesis'
        );
      case TipoFragmentoEnTejado.sistemaDosXDos:
        return (
          'resolver sistema de dos ecuaciones',
          'no aislar bien una incógnita o error de sustitución'
        );
      case TipoFragmentoEnTejado.relacionLineal:
        return (
          'encontrar la regla de una relación lineal',
          'confundir pendiente con ordenada al origen'
        );
    }
  }

  void _comentarTrasCaptura() {
    final hitos = {
      1: 'Bien. El primero ya es tuyo.',
      5: 'Cinco. Te estás haciendo a esto.',
      10: 'Diez en una noche. Mira el barrio.',
      20: 'Veinte. A ver si te atreves con los primos.',
    };
    final mensajeHito = hitos[_esquirlasEstaSesion];
    if (mensajeHito != null) {
      _mostrarLineaAmbienteSora(mensajeHito);
      return;
    }
    if (_esquirlasEstaSesion % 3 == 0) {
      const variedad = [
        'Otro menos.',
        'Así.',
        'Bien visto.',
        'Sigue.',
      ];
      _mostrarLineaAmbienteSora(
          variedad[math.Random().nextInt(variedad.length)]);
    }
  }

  void _comentarTrasEscape(int cantidad) {
    if (cantidad == 1) {
      _mostrarLineaAmbienteSora('Se te ha ido. No pasa nada.');
    } else {
      _mostrarLineaAmbienteSora('Se han escapado varios. Atento.');
    }
  }

  void _mostrarLineaAmbienteSora(String texto) {
    _temporizadorLineaSora?.cancel();
    setState(() => _lineaAmbienteSora = texto);
    _temporizadorLineaSora = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _lineaAmbienteSora = null);
    });
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_controladorCielo, _controladorLluvia]),
        builder: (_, __) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: PintorEscenario(
                  fasePulso: _controladorCielo.value,
                  fasePulsoLluvia: _controladorLluvia.value,
                  nivelRestauracion:
                      (_esquirlasTotal / 30).clamp(0.0, 1.0),
                  idDistrito: widget.distrito.identificador,
                  ambiente: _ambienteHoy,
                  piezasRestauradas: _piezasRestauradas,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _BarraSuperior(
                      nombreDistrito: traducirNarrativa(
                        widget.distrito.nombre,
                        Localizations.localeOf(context),
                      ),
                      esquirlas: _esquirlasTotal,
                      esquirlasNuevasDestello: _esquirlasEstaSesion,
                      alVolverAlMapa: () => Navigator.of(context).pop(),
                      etiquetaEntrenamiento: widget.dominioFiltrado != null
                          ? widget.nombreDominio
                          : null,
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (_, constraints) {
                          return Stack(
                            children: [
                              // Secretos espaciales (doc 16, eje E):
                              // zonas tocables SIN señal visual. Van
                              // antes que los Fragmentos en el Stack,
                              // así un Fragmento encima siempre gana
                              // el toque.
                              if (widget.dominioFiltrado == null)
                                for (final secreto
                                    in CatalogoSecretos.delDistrito(
                                        widget.distrito.identificador))
                                  if (!_flagsAlEntrar
                                      .contains(secreto.flagDescubierto))
                                    Positioned(
                                      left: secreto.xEscena *
                                              constraints.biggest.width -
                                          CatalogoSecretos.radioToquePx,
                                      top: secreto.yEscena *
                                              constraints.biggest.height -
                                          CatalogoSecretos.radioToquePx,
                                      width:
                                          CatalogoSecretos.radioToquePx * 2,
                                      height:
                                          CatalogoSecretos.radioToquePx * 2,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () =>
                                            _descubrirSecreto(secreto),
                                      ),
                                    ),
                              for (final fragmento in _activos)
                                _FragmentoEnMapa(
                                  key: ValueKey(fragmento.identificador),
                                  fragmento: fragmento,
                                  tamanoContenedor: constraints.biggest,
                                  ahora: _ahoraRef,
                                  fasePulso: _controladorCielo.value,
                                  alTocar: () => _alTocarFragmento(fragmento),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    SoraPresencia(
                      textoActivo: _lineaAmbienteSora == null
                          ? null
                          : traducirNarrativa(
                              _lineaAmbienteSora!,
                              Localizations.localeOf(context),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BarraSuperior extends StatelessWidget {
  final String nombreDistrito;
  final int esquirlas;
  final int esquirlasNuevasDestello;
  final VoidCallback alVolverAlMapa;

  /// Cuando el cazadero está en modo entrenamiento, esta etiqueta
  /// (nombre legible del dominio) sustituye al nombre del distrito en
  /// el centro de la barra y se prefija con "Entrenando ·" en violeta.
  final String? etiquetaEntrenamiento;

  const _BarraSuperior({
    required this.nombreDistrito,
    required this.esquirlas,
    required this.esquirlasNuevasDestello,
    required this.alVolverAlMapa,
    this.etiquetaEntrenamiento,
  });

  @override
  Widget build(BuildContext contexto) {
    final textos = AppLocalizations.of(contexto);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: alVolverAlMapa,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: PaletaNeon.violetaBase,
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                textos.cazaBotonMapa,
                style: const TextStyle(
                  color: PaletaNeon.textoTenue,
                  fontSize: 12,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: etiquetaEntrenamiento != null
                ? RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: 2.4,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: textos.cazaBadgeEntrenando,
                          style: TextStyle(
                            color: PaletaNeon.violetaNeon.withOpacity(0.85),
                          ),
                        ),
                        TextSpan(
                          text: etiquetaEntrenamiento!.toUpperCase(),
                          style: const TextStyle(
                            color: PaletaNeon.textoPrincipal,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    nombreDistrito.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      letterSpacing: 3,
                      color: PaletaNeon.textoTenue,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
          ),
          _ContadorEsquirlas(
            total: esquirlas,
            pulso: esquirlasNuevasDestello,
          ),
        ],
      ),
    );
  }
}

class _ContadorEsquirlas extends StatelessWidget {
  final int total;
  final int pulso;

  const _ContadorEsquirlas({required this.total, required this.pulso});

  @override
  Widget build(BuildContext contexto) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: PaletaNeon.fondoMedio.withOpacity(0.6),
        border: Border.all(
          color: PaletaNeon.azulNeon.withOpacity(0.6),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: pulso > 0
            ? [
                BoxShadow(
                  color: PaletaNeon.azulNeon.withOpacity(0.35),
                  blurRadius: 10,
                ),
              ]
            : const [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: PaletaNeon.azulNeon,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: PaletaNeon.azulNeon.withOpacity(0.6),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          Text(
            AppLocalizations.of(contexto).habEsquirlasResumen(total),
            style: const TextStyle(
              color: PaletaNeon.textoPrincipal,
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _FragmentoEnMapa extends StatelessWidget {
  final FragmentoEnTejado fragmento;
  final Size tamanoContenedor;
  final DateTime ahora;
  final double fasePulso;
  final VoidCallback alTocar;

  const _FragmentoEnMapa({
    super.key,
    required this.fragmento,
    required this.tamanoContenedor,
    required this.ahora,
    required this.fasePulso,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext contexto) {
    final fraccionVida = fragmento.fraccionVidaConsumida(ahora);
    final x = fragmento.xNormalizado * tamanoContenedor.width;
    final y = fragmento.yNormalizado * tamanoContenedor.height;
    final desplazaY = fraccionVida > 0.75
        ? -(fraccionVida - 0.75) / 0.25 * 80
        : 0.0;
    const diametro = 78.0;
    return Positioned(
      left: x - diametro / 2,
      top: y - diametro / 2 + desplazaY,
      child: GestureDetector(
        onTap: alTocar,
        child: SizedBox(
          width: diametro,
          height: diametro,
          child: CustomPaint(
            painter: PintorFragmentoTejado(
              fragmento: fragmento,
              fraccionVida: fraccionVida,
              fasePulso: fasePulso,
            ),
          ),
        ),
      ),
    );
  }
}
