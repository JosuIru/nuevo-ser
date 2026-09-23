import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../datos/banco_ediciones_faro.dart';
import '../datos/repositorio_encargo.dart';
import '../datos/repositorio_faro.dart';
import '../datos/repositorio_progreso.dart';
import '../dominio/catalogo_distritos.dart';
import '../dominio/cuaderno.dart';
import '../dominio/distrito.dart';
import '../dominio/encargo_del_dia.dart';
import '../dominio/faro_de_azula.dart';
import '../dominio/progreso_arco.dart';
import '../dominio/rango_narrativo.dart';
import '../l10n/app_localizations.dart';
import '../l10n/textos_enums.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';
import 'escenario.dart';
import 'pantalla_ajustes_sonido.dart';
import 'pantalla_caza.dart';
import 'pantalla_entrenamiento.dart';
import 'pantalla_progreso_distrito.dart';
import 'pantalla_faro.dart';
import 'pantalla_habilidades.dart';
import 'pantalla_instrucciones.dart';
import 'pantalla_mi_cuaderno.dart';
import 'pantalla_taller.dart';
import 'pantalla_modo_dios.dart';
import 'pantalla_tour_educadores.dart';
import 'widgets/banner_actualizacion.dart';

/// Mapa de la ciudad. Muestra los distritos del catálogo posicionados
/// según biblia §3.4 y la Montaña al fondo. Los distritos bloqueados
/// aparecen apagados con el umbral de esquirlas visible. El jugador
/// toca un distrito disponible y entra a cazar allí.
class PantallaMapa extends StatefulWidget {
  final RepositorioProgreso repositorio;

  /// Callback opcional proporcionado por el orquestador para reiniciar
  /// el flujo al perfil activo tras un cambio. Se propaga a la pantalla
  /// de habilidades (y de ahí al selector de perfiles).
  final VoidCallback? alReiniciarConPerfilActivo;

  const PantallaMapa({
    super.key,
    required this.repositorio,
    this.alReiniciarConPerfilActivo,
  });

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controladorCielo;
  int _esquirlas = 0;
  RangoNarrativo _rango = RangoNarrativo.aprendiz1;
  ProgresoArco _arcoMostrado = ProgresoArco.arco1;
  int _escenasDelArcoVistas = 0;
  int _entradasCuadernoDisponibles = 0;
  bool _cargado = false;
  bool _hayEdicionFaroNueva = false;
  List<EdicionFaro>? _bancoFaroCacheado;
  // Encargo del día (doc 16, eje D) + su avance. Se recargan en cada
  // _cargar() — al volver del cazadero el progreso se refresca solo.
  EncargoDelDia? _encargoDeHoy;
  EstadoEncargoDia _estadoEncargo =
      const EstadoEncargoDia(progreso: 0, completado: false);

  @override
  void initState() {
    super.initState();
    _controladorCielo = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _cargar();
    _mostrarOnboardingSiPrimeraVez();
  }

  Future<void> _mostrarOnboardingSiPrimeraVez() async {
    final yaVisto = await widget.repositorio.flagNarrativoActivo('onboarding_mapa_visto');
    if (yaVisto || !mounted) return;
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => AlertDialog(
        backgroundColor: PaletaNeon.fondoMedio,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: PaletaNeon.violetaNeon.withOpacity(0.3),
          ),
        ),
        title: const Text(
          'Bienvenido a Azula',
          style: TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 18,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _onbParrafo('Este es el mapa de la ciudad. Cada zona tiene Fragmentos matemáticos diferentes.'),
              _onbParrafo('Para empezar, toca un distrito. Allí verás Fragmentos flotando: tócalos para resolver puzzles.'),
              _onbParrafo('Si te atascas, pulsa el botón ? en cada puzzle. Si fallas varias veces, recibirás ayuda.'),
              _onbParrafo('Desde arriba puedes entrenar por temas, ver tu cuaderno o ajustar el sonido.'),
              _onbParrafo('\u{1F917} ¡Sora te guiará!'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await widget.repositorio.activarFlagNarrativo('onboarding_mapa_visto');
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text(
              '¡A JUGAR!',
              style: TextStyle(
                color: PaletaNeon.violetaNeon,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _onbParrafo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        texto,
        style: TextStyle(
          color: PaletaNeon.textoTenue.withOpacity(0.9),
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controladorCielo.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final total = await widget.repositorio.cargarEsquirlas();
    final rango = await widget.repositorio.cargarRango();
    final arco = await ProgresoArco.arcoActual(
      widget.repositorio.flagNarrativoActivo,
    );
    final vistas = await arco.contarVistas(
      widget.repositorio.flagNarrativoActivo,
    );
    final entradas = await CatalogoCuaderno.disponibles(
      widget.repositorio.flagNarrativoActivo,
    );
    final hayFaroNuevo = await _hayEdicionFaroNoLeida();
    final encargo = GeneradorEncargoDelDia.deHoy(
      ahora: DateTime.now(),
      idsDistritosDesbloqueados: CatalogoDistritos.todos
          .where((d) => d.esquirlasParaDesbloquear <= total)
          .map((d) => d.identificador)
          .toList(),
    );
    final estadoEncargo =
        await widget.repositorio.encargo.cargarEstado(encargo.claveFecha);
    if (!mounted) return;
    setState(() {
      _encargoDeHoy = encargo;
      _estadoEncargo = estadoEncargo;
      _esquirlas = total;
      _rango = rango;
      _arcoMostrado = arco;
      _escenasDelArcoVistas = vistas;
      _entradasCuadernoDisponibles = entradas.length;
      _hayEdicionFaroNueva = hayFaroNuevo;
      _cargado = true;
    });
    _quizasSugerirDescargaAudio();
  }

  /// `true` cuando hay un número del Faro que el niño todavía no ha
  /// abierto en este perfil. La regla concreta vive en la función
  /// pura `tieneEdicionFaroNoLeida`; aquí sólo cargamos los valores
  /// del repositorio + el banco y delegamos.
  Future<bool> _hayEdicionFaroNoLeida() async {
    final repo = widget.repositorio.faro;
    final primeraVistaMs = await repo.cargarPrimeraVistaMs();
    final ultimaVista = await repo.cargarUltimaEdicionVista();
    if (primeraVistaMs == null || ultimaVista == null) return true;
    final banco = await _cargarBancoFaroSiHaceFalta();
    final semana = calcularNumeroSemanaActual(
      ahora: DateTime.now(),
      primeraVistaMs: primeraVistaMs,
      totalEdiciones: banco.length,
    );
    return tieneEdicionFaroNoLeida(
      primeraVistaMs: primeraVistaMs,
      ultimaEdicionVista: ultimaVista,
      semanaActual: semana,
    );
  }

  Future<List<EdicionFaro>> _cargarBancoFaroSiHaceFalta() async {
    final cacheado = _bancoFaroCacheado;
    if (cacheado != null) return cacheado;
    final banco = await cargarBancoEdicionesFaro();
    _bancoFaroCacheado = banco;
    return banco;
  }

  /// Una sola vez por instalación: si el paquete de sonido aún no se
  /// descargó, le proponemos al niño/adulto bajarlo. La sugerencia se
  /// marca como vista en cuanto el banner aparece — no reaparece
  /// aunque la rechace, para no resultar pesada.
  Future<void> _quizasSugerirDescargaAudio() async {
    final yaSugerido =
        await widget.repositorio.cargarAudioSugerenciaVista();
    if (yaSugerido) return;
    final version =
        await widget.repositorio.cargarVersionPaqueteAudio();
    if (version != null) return;
    if (!mounted) return;
    await widget.repositorio.marcarAudioSugerenciaVista();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: PaletaNeon.fondoMedio,
        duration: const Duration(seconds: 12),
        behavior: SnackBarBehavior.floating,
        content: const Text(
          'Música y voces (~3,5 MB). Mejora mucho el ambiente. '
          '¿Descargar ahora con wifi?',
          style: TextStyle(
            color: PaletaNeon.textoPrincipal,
            height: 1.35,
          ),
        ),
        action: SnackBarAction(
          label: 'DESCARGAR',
          textColor: PaletaNeon.azulNeon,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PantallaAjustesSonido(
                  repositorio: widget.repositorio,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _abrirMiCuaderno() async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PantallaMiCuaderno(repositorio: widget.repositorio),
      ),
    );
    // Recargamos por si se abrieron entradas o subió maestría dentro.
    _cargar();
  }

  Future<void> _abrirEntrenamiento() async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PantallaEntrenamiento(repositorio: widget.repositorio),
      ),
    );
    // Al volver del entrenamiento puede haber esquirlas nuevas que
    // afectan al desbloqueo de distritos en el mapa.
    await _cargar();
  }

  Future<void> _abrirInstrucciones() async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PantallaInstrucciones(),
      ),
    );
  }

  Future<void> _abrirTour() async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PantallaTourEducadores(),
      ),
    );
  }

  Future<void> _abrirAjustesSonido() async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaAjustesSonido(
          repositorio: widget.repositorio,
        ),
      ),
    );
  }

  /// Invocado por `_RotuloSecreto` cuando detecta 7 toques rápidos
  /// seguidos sobre "UNO ROTO". Si el modo dios no estaba activo, lo
  /// activa; en ambos casos abre PantallaModoDios. Sin acceso visible
  /// — el rótulo no muestra ningún indicio de que esto exista.
  Future<void> _activarYAbrirModoDios() async {
    final yaEstaba = await widget.repositorio.cargarModoDiosActivo();
    if (!yaEstaba) {
      await widget.repositorio.guardarModoDiosActivo(true);
    }
    if (!mounted) return;
    final nombre = await widget.repositorio.cargarNombreJugador() ?? '';
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaModoDios(
          repositorio: widget.repositorio,
          nombreJugador: nombre,
          alDesactivar: () {},
        ),
      ),
    );
    if (!mounted) return;
    // Tras volver, recargamos por si "Desbloquear todo" o "Reiniciar"
    // cambiaron esquirlas/rango/escenas.
    await _cargar();
  }

  Future<void> _abrirFaro() async {
    HapticFeedback.selectionClick();
    final banco = await _cargarBancoFaroSiHaceFalta();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaFaro(
          repositorioFaro: widget.repositorio.faro,
          banco: banco,
        ),
      ),
    );
    // La pantalla del Faro marca su edición como vista al abrirla,
    // así que al volver el badge debería desaparecer.
    await _cargar();
  }


  /// Diálogo sobrio con la voz de Sora presentando el encargo del día
  /// (doc 16, eje D). Sin premios ni urgencia: propone, no obliga —
  /// si el niño lo ignora, mañana hay otro y no pasa nada.
  Future<void> _abrirDialogoEncargo() async {
    final encargo = _encargoDeHoy;
    if (encargo == null) return;
    HapticFeedback.selectionClick();
    final locale = Localizations.localeOf(context);
    final String cuerpo;
    if (_estadoEncargo.completado) {
      cuerpo = traducirNarrativa('Hecho. Mañana habrá otro.', locale);
    } else {
      final plantilla = encargo.esLibre
          ? 'Hoy me valen {n} Fragmentos de donde sea. '
              'Si te apetece, tráemelos. Si no, mañana habrá otro.'
          : 'He visto {n} Fragmentos en {distrito}. '
              'Si te apetece, tráemelos. Si no, mañana habrá otro.';
      cuerpo = traducirNarrativa(plantilla, locale)
          .replaceAll('{n}', encargo.objetivo.toString())
          .replaceAll('{distrito}', _nombreDistritoEncargo(locale));
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PaletaNeon.fondoMedio,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: PaletaNeon.violetaNeon.withOpacity(0.3),
          ),
        ),
        title: Text(
          traducirNarrativa('El encargo del día', locale),
          style: const TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 16,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '“$cuerpo”\n— Sora',
              style: TextStyle(
                color: PaletaNeon.textoTenue.withOpacity(0.9),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (!_estadoEncargo.completado) ...[
              const SizedBox(height: 12),
              Text(
                '${_estadoEncargo.progreso} / ${encargo.objetivo}',
                style: const TextStyle(
                  color: PaletaNeon.violetaNeon,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              traducirNarrativa('VALE', locale),
              style: const TextStyle(
                color: PaletaNeon.violetaNeon,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Nombre localizado del distrito del encargo activo (cadena vacía
  /// si el encargo es libre — el token `{distrito}` no aparece ahí).
  String _nombreDistritoEncargo(Locale locale) {
    final id = _encargoDeHoy?.idDistrito;
    if (id == null) return '';
    final distrito = CatalogoDistritos.todos
        .where((d) => d.identificador == id)
        .firstOrNull;
    if (distrito == null) return '';
    return traducirNarrativa(distrito.nombre, locale);
  }

  Future<void> _entrarADistrito(Distrito distrito) async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaCaza(
          repositorio: widget.repositorio,
          distrito: distrito,
        ),
      ),
    );
    // Al volver del distrito, recargamos esquirlas para reflejar las
    // ganadas durante la sesión.
    await _cargar();
  }

  Future<void> _abrirTaller() async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaTaller(repositorio: widget.repositorio),
      ),
    );
    // Al volver, el saldo disponible pudo cambiar (no las esquirlas
    // ganadas, que son las que muestra el HUD) — recargamos igualmente
    // por si el modo dios u otra pantalla tocó algo.
    await _cargar();
  }

  Future<void> _abrirProgreso(Distrito distrito) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaProgresoDistrito(
          distrito: distrito,
          repositorio: widget.repositorio,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controladorCielo,
        builder: (_, __) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: PintorEscenario(
                  fasePulso: _controladorCielo.value,
                  nivelRestauracion:
                      (_esquirlas / 100).clamp(0.0, 1.0),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    GestureDetector(
                      onLongPress: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PantallaHabilidades(
                              repositorio: widget.repositorio,
                              alReiniciarConPerfilActivo:
                                  widget.alReiniciarConPerfilActivo,
                            ),
                          ),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: _Encabezado(
                        esquirlas: _esquirlas,
                        rango: _rango,
                        arco: _arcoMostrado,
                        escenasVistasDelArco: _escenasDelArcoVistas,
                        entradasCuaderno: _entradasCuadernoDisponibles,
                        hayFaroNuevo: _hayEdicionFaroNueva,
                        alAbrirCuaderno: _abrirMiCuaderno,
                        alAbrirEntrenamiento: _abrirEntrenamiento,
                        alAbrirFaro: _abrirFaro,
                        alAbrirInstrucciones: _abrirInstrucciones,
                        alAbrirTour: _abrirTour,
                        alAbrirAjustesSonido: _abrirAjustesSonido,
                        alActivarModoDios: _activarYAbrirModoDios,
                      ),
                    ),
                    BannerActualizacion(repositorio: widget.repositorio),
                    if (_encargoDeHoy != null)
                      _BannerEncargo(
                        encargo: _encargoDeHoy!,
                        estado: _estadoEncargo,
                        alTocar: _abrirDialogoEncargo,
                      ),
                    Expanded(
                      child: _cargado
                          ? LayoutBuilder(
                              builder: (_, constraints) => _LienzoMapa(
                                esquirlas: _esquirlas,
                                tamano: constraints.biggest,
                                alEntrar: _entrarADistrito,
                                onVerProgreso: (d) => _abrirProgreso(d),
                                alAbrirTaller: _abrirTaller,
                              ),
                            )
                          : const SizedBox.shrink(),
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

/// Línea fina bajo la cabecera con el encargo del día y su avance
/// (doc 16, eje D). Da forma a la sesión: el niño sabe qué podría
/// hacer hoy nada más entrar. Es una línea y no un chip a propósito:
/// la cabecera va justa de ancho en móviles ~390 dp (informe Izan
/// 2026-05-19) y el encargo es del niño, no del menú adulto.
class _BannerEncargo extends StatelessWidget {
  final EncargoDelDia encargo;
  final EstadoEncargoDia estado;
  final VoidCallback alTocar;

  const _BannerEncargo({
    required this.encargo,
    required this.estado,
    required this.alTocar,
  });

  String _texto(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    if (estado.completado) {
      return traducirNarrativa('Encargo de hoy: hecho.', locale);
    }
    final plantilla = encargo.esLibre
        ? 'Encargo de Sora: {n} Fragmentos donde tú quieras'
        : 'Encargo de Sora: {n} Fragmentos en {distrito}';
    var texto = traducirNarrativa(plantilla, locale)
        .replaceAll('{n}', encargo.objetivo.toString());
    if (!encargo.esLibre) {
      final distrito = CatalogoDistritos.todos
          .where((d) => d.identificador == encargo.idDistrito)
          .firstOrNull;
      texto = texto.replaceAll(
        '{distrito}',
        distrito == null ? '' : traducirNarrativa(distrito.nombre, locale),
      );
    }
    return '$texto · ${estado.progreso}/${encargo.objetivo}';
  }

  @override
  Widget build(BuildContext contexto) {
    final completado = estado.completado;
    return GestureDetector(
      onTap: alTocar,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              completado
                  ? Icons.check_circle_outline
                  : Icons.radio_button_unchecked,
              size: 12,
              color: completado
                  ? PaletaNeon.violetaNeon.withOpacity(0.7)
                  : PaletaNeon.textoTenue.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _texto(contexto),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w300,
                  color: completado
                      ? PaletaNeon.textoTenue.withOpacity(0.55)
                      : PaletaNeon.textoTenue.withOpacity(0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  final int esquirlas;
  final RangoNarrativo rango;
  final ProgresoArco arco;
  final int escenasVistasDelArco;
  final int entradasCuaderno;
  final bool hayFaroNuevo;
  final VoidCallback alAbrirCuaderno;
  final VoidCallback alAbrirEntrenamiento;
  final VoidCallback alAbrirFaro;
  final VoidCallback alAbrirInstrucciones;
  final VoidCallback alAbrirTour;
  final VoidCallback alAbrirAjustesSonido;
  // Trigger oculto del modo dios — pasado al _RotuloSecreto que
  // envuelve el "UNO ROTO" y cuenta 7 toques rápidos.
  final VoidCallback alActivarModoDios;

  const _Encabezado({
    required this.esquirlas,
    required this.rango,
    required this.arco,
    required this.escenasVistasDelArco,
    required this.entradasCuaderno,
    required this.hayFaroNuevo,
    required this.alAbrirCuaderno,
    required this.alAbrirEntrenamiento,
    required this.alAbrirFaro,
    required this.alAbrirInstrucciones,
    required this.alAbrirTour,
    required this.alAbrirAjustesSonido,
    required this.alActivarModoDios,
  });

  @override
  Widget build(BuildContext contexto) {
    // Diseño compacto fijo. Antes se intentaba mostrar etiquetas en
    // móviles "anchos" y ocultarlas en estrechos, pero el cálculo era
    // frágil — un Redmi Note 8 a 440 dpi tiene 392 dp lógicos y los
    // chips con texto sumaban más que el ancho disponible, aplastando
    // la columna izquierda hasta romper "UNO ROTO" letra a letra. Con
    // iconos siempre + tooltips la barra cabe en cualquier teléfono y
    // queda holgada en tablet (donde igualmente no estorba).
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _RotuloSecreto(alActivar: alActivarModoDios),
              const SizedBox(height: 2),
              Text(
                rango.nombreLocalizado(AppLocalizations.of(contexto)),
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 2.5,
                  color: PaletaNeon.violetaNeon.withOpacity(0.85),
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
              const SizedBox(height: 1),
              Text(
                AppLocalizations.of(contexto).mapaArcoResumen(
                  arco.nombreRomano,
                  escenasVistasDelArco,
                  arco.totalEscenas,
                ),
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 2,
                  color: PaletaNeon.textoTenue.withOpacity(0.55),
                  fontWeight: FontWeight.w300,
                ),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ],
          ),
          const Spacer(),
          _ChipAccion(
            icono: Icons.menu_book,
            color: PaletaNeon.azulNeon,
            badge: entradasCuaderno > 0
                ? entradasCuaderno.toString()
                : null,
            alPulsar: alAbrirCuaderno,
            tooltip: 'Mi cuaderno',
          ),
          const SizedBox(width: 8),
          _ChipAccion(
            icono: Icons.newspaper,
            color: PaletaNeon.ambarCanales,
            badge: hayFaroNuevo ? '·' : null,
            alPulsar: alAbrirFaro,
            tooltip: 'El Faro de Azula',
          ),
          const SizedBox(width: 8),
          _ChipAccion(
            icono: Icons.fitness_center,
            color: PaletaNeon.violetaNeon,
            alPulsar: alAbrirEntrenamiento,
            tooltip: AppLocalizations.of(contexto).mapaBotonEntrenar,
          ),
          const SizedBox(width: 8),
          // Menú overflow con Instrucciones / Tour educadores / Ajustes
          // sonido. Antes los dos primeros eran chips sueltos en la
          // barra: con 5 chips la cabecera reventaba en móviles
          // ~390 dp (informe Izan 2026-05-19, dejaba inaccesibles los
          // ajustes de sonido). El menú agrupa los tres accesos
          // adultos en un solo punto de pulsado y devuelve aire al HUD.
          _MenuOverflowAdulto(
            alAbrirInstrucciones: alAbrirInstrucciones,
            alAbrirTour: alAbrirTour,
            alAbrirAjustesSonido: alAbrirAjustesSonido,
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: AppLocalizations.of(contexto)
                .habEsquirlasResumen(esquirlas),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: PaletaNeon.azulNeon.withOpacity(0.6),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                esquirlas.toString(),
                style: const TextStyle(
                  color: PaletaNeon.textoPrincipal,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Menú overflow del encabezado: agrupa instrucciones, tour de
/// educadores y ajustes de sonido en un solo punto de pulsado para
/// no inflar la barra del HUD. Se introdujo tras el informe de
/// testeo del 2026-05-19 (Izan), donde la cabecera con cinco chips
/// sueltos desbordaba el ancho en teléfonos ~390 dp y dejaba los
/// ajustes de sonido fuera de pantalla.
class _MenuOverflowAdulto extends StatelessWidget {
  final VoidCallback alAbrirInstrucciones;
  final VoidCallback alAbrirTour;
  final VoidCallback alAbrirAjustesSonido;

  const _MenuOverflowAdulto({
    required this.alAbrirInstrucciones,
    required this.alAbrirTour,
    required this.alAbrirAjustesSonido,
  });

  @override
  Widget build(BuildContext contexto) {
    final color = PaletaNeon.textoTenue;
    return Tooltip(
      message: 'Más opciones',
      child: PopupMenuButton<int>(
        tooltip: '',
        color: PaletaNeon.fondoMedio,
        padding: EdgeInsets.zero,
        onSelected: (valor) {
          switch (valor) {
            case 0:
              alAbrirInstrucciones();
              break;
            case 1:
              alAbrirAjustesSonido();
              break;
            case 2:
              alAbrirTour();
              break;
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem<int>(
            value: 0,
            child: _ItemMenuAdulto(
              icono: Icons.help_outline,
              etiqueta:
                  AppLocalizations.of(contexto).mapaBotonInstrucciones,
            ),
          ),
          const PopupMenuItem<int>(
            value: 1,
            child: _ItemMenuAdulto(
              icono: Icons.volume_up,
              etiqueta: 'Ajustes de sonido',
            ),
          ),
          const PopupMenuItem<int>(
            value: 2,
            child: _ItemMenuAdulto(
              icono: Icons.school,
              etiqueta: 'Tour para educadores',
            ),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.more_vert, size: 16, color: color.withOpacity(0.85)),
        ),
      ),
    );
  }
}

class _ItemMenuAdulto extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  const _ItemMenuAdulto({required this.icono, required this.etiqueta});

  @override
  Widget build(BuildContext contexto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 18, color: PaletaNeon.textoPrincipal),
        const SizedBox(width: 12),
        Text(
          etiqueta,
          style: const TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

/// Chip circular del encabezado del mapa: icono pequeño + borde de
/// color, opcional badge numérico (p. ej. entradas nuevas en el
/// cuaderno). El [tooltip] suple la etiqueta porque no hay texto
/// visible — la barra prioriza compactación sobre verbosidad.
class _ChipAccion extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String? badge;
  final VoidCallback alPulsar;
  final String tooltip;

  const _ChipAccion({
    required this.icono,
    required this.color,
    required this.alPulsar,
    required this.tooltip,
    this.badge,
  });

  @override
  Widget build(BuildContext contexto) {
    final hijo = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: color.withOpacity(0.85)),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: color.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: PaletaNeon.textoPrincipal,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: alPulsar,
        borderRadius: BorderRadius.circular(20),
        child: hijo,
      ),
    );
  }
}

class _LienzoMapa extends StatelessWidget {
  final int esquirlas;
  final Size tamano;
  final ValueChanged<Distrito> alEntrar;
  final ValueChanged<Distrito>? onVerProgreso;
  final VoidCallback? alAbrirTaller;

  const _LienzoMapa({
    required this.esquirlas,
    required this.tamano,
    required this.alEntrar,
    this.onVerProgreso,
    this.alAbrirTaller,
  });

  @override
  Widget build(BuildContext contexto) {
    final ancho = tamano.width;
    final alto = tamano.height;
    return Stack(
      children: [
        for (final distrito in CatalogoDistritos.todos)
          Positioned(
            left: distrito.xMapa * ancho - 68,
            top: distrito.yMapa * alto - 40,
            child: _NodoDistrito(
              distrito: distrito,
              desbloqueado: distrito.estaDesbloqueado(esquirlas),
              esquirlasDelJugador: esquirlas,
              alEntrar: alEntrar,
              onLongPress: onVerProgreso != null
                  ? () => onVerProgreso!(distrito)
                  : null,
            ),
          ),
        // El taller de Rexán (doc 16, eje B): un lugar del mapa, no un
        // chip — la cabecera va justa y el taller es del niño. Zona
        // libre entre Afueras (0.22, 0.28) y la Montaña (0.5, 0.15).
        if (alAbrirTaller != null)
          Positioned(
            left: 0.84 * ancho - 36,
            top: 0.30 * alto - 28,
            child: _NodoTaller(alAbrir: alAbrirTaller!),
          ),
      ],
    );
  }
}

/// Marcador del taller de Rexán en el lienzo del mapa. Pequeño y
/// cálido (ámbar del farolillo de Canales), sin badge ni urgencia.
class _NodoTaller extends StatelessWidget {
  final VoidCallback alAbrir;

  const _NodoTaller({required this.alAbrir});

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    return GestureDetector(
      onTap: alAbrir,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PaletaNeon.fondoMedio.withOpacity(0.8),
                border: Border.all(
                  color: PaletaNeon.ambarCanales.withOpacity(0.55),
                ),
                boxShadow: [
                  BoxShadow(
                    color: PaletaNeon.ambarCanales.withOpacity(0.18),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Icon(
                Icons.handyman_outlined,
                size: 18,
                color: PaletaNeon.ambarCanales.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              traducirNarrativa('Taller', locale).toUpperCase(),
              style: TextStyle(
                color: PaletaNeon.textoTenue.withOpacity(0.8),
                fontSize: 9,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NodoDistrito extends StatelessWidget {
  final Distrito distrito;
  final bool desbloqueado;
  final int esquirlasDelJugador;
  final ValueChanged<Distrito> alEntrar;
  final VoidCallback? onLongPress;

  const _NodoDistrito({
    required this.distrito,
    required this.desbloqueado,
    required this.esquirlasDelJugador,
    required this.alEntrar,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext contexto) {
    return GestureDetector(
      onTap: desbloqueado ? () => alEntrar(distrito) : null,
      onLongPress: onLongPress,
      child: Opacity(
        opacity: desbloqueado ? 1.0 : 0.45,
        child: Container(
          width: 136,
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: PaletaNeon.fondoMedio.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: desbloqueado
                  ? distrito.colorAcento
                  : PaletaNeon.violetaBase,
              width: 1.6,
            ),
            boxShadow: desbloqueado
                ? [
                    BoxShadow(
                      color: distrito.colorAcento.withOpacity(0.35),
                      blurRadius: 12,
                    ),
                  ]
                : const [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                traducirNarrativa(
                  distrito.nombre,
                  Localizations.localeOf(contexto),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: desbloqueado
                      ? PaletaNeon.textoPrincipal
                      : PaletaNeon.textoTenue,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.6,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desbloqueado
                    ? traducirNarrativa(
                        distrito.descripcionCorta,
                        Localizations.localeOf(contexto),
                      )
                    : AppLocalizations.of(contexto)
                        .mapaDistritoBloqueado(distrito.esquirlasParaDesbloquear),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: PaletaNeon.textoTenue.withOpacity(0.85),
                  fontSize: 10,
                  letterSpacing: 0.4,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Envuelve el rótulo "UNO ROTO" con un detector de 7 toques rápidos
/// que activa el modo dios (y, si ya estaba activo, abre directamente
/// PantallaModoDios). Sin pista visual de que el gesto exista — el
/// rótulo se ve igual que antes. El contador se resetea si pasan más
/// de 1500 ms entre toques. Cubierto de forma indirecta por los tests
/// de PantallaMapa cuando los haya; ahora vive solo en runtime.
class _RotuloSecreto extends StatefulWidget {
  final VoidCallback alActivar;

  const _RotuloSecreto({required this.alActivar});

  @override
  State<_RotuloSecreto> createState() => _RotuloSecretoState();
}

class _RotuloSecretoState extends State<_RotuloSecreto> {
  static const _toquesNecesarios = 7;
  static const _ventanaEntreToques = Duration(milliseconds: 1500);

  int _toquesAcumulados = 0;
  DateTime? _ultimoToque;

  void _registrarToque() {
    final ahora = DateTime.now();
    final ultimo = _ultimoToque;
    if (ultimo == null || ahora.difference(ultimo) > _ventanaEntreToques) {
      _toquesAcumulados = 1;
    } else {
      _toquesAcumulados++;
    }
    _ultimoToque = ahora;
    if (_toquesAcumulados >= _toquesNecesarios) {
      _toquesAcumulados = 0;
      _ultimoToque = null;
      widget.alActivar();
    }
  }

  @override
  Widget build(BuildContext contexto) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _registrarToque,
      child: const Text(
        'UNO ROTO',
        style: TextStyle(
          fontSize: 14,
          letterSpacing: 5,
          color: PaletaNeon.textoTenue,
          fontWeight: FontWeight.w300,
        ),
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}
