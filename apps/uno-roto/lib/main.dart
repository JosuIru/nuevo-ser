import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'datos/ajuste_sin_prisas.dart';
import 'datos/nivel_de_partida.dart';
import 'datos/repositorio_progreso.dart';
import 'l10n/app_localizations.dart';
import 'dominio/desafio_kurz.dart';
import 'dominio/escena_cinematica.dart';
import 'dominio/orquestador_escenas.dart';
import 'dominio/rango_narrativo.dart';
import 'dominio/ritmo_juego.dart';
import 'nucleo/paleta.dart';
import 'sonido/servicio_sonoro.dart';
import 'vista/pantalla_apertura.dart';
import 'vista/pantalla_cinematica.dart';
import 'vista/pantalla_combate_kurz.dart';
import 'vista/pantalla_configuracion_inicial.dart';
import 'vista/pantalla_mapa.dart';
import 'vista/pantalla_nombre.dart';
import 'vista/pantalla_perfiles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  // Precarga del idioma elegido por el niño en sesiones previas. Si lo
  // hay, se aplica al ValueNotifier global ANTES del primer build de
  // MaterialApp para evitar un flash con el idioma del sistema. Si no
  // lo hay (primer arranque), el ValueNotifier sigue null y
  // localeResolutionCallback decide; el orquestador detectará la
  // ausencia y abrirá PantallaConfiguracionInicial.
  final repositorio = RepositorioProgreso();
  final codigoIdiomaPersistido = await repositorio.cargarIdiomaApp();
  await AjusteSinPrisas.cargar();
  if (codigoIdiomaPersistido != null) {
    localeAppUnoRoto.value = Locale(codigoIdiomaPersistido);
  }
  runApp(const AppUnoRoto());
}

/// Locale activo de la app. Lo lee `AppUnoRoto` para configurar
/// `MaterialApp` y se actualiza desde [OrquestadorFases] cuando el niño
/// elige idioma en la pantalla de configuración inicial. Permite que
/// `AppUnoRoto` siga siendo `StatelessWidget` (así los tests existentes
/// que hacen `pumpWidget(const AppUnoRoto())` siguen funcionando) y a
/// la vez tener un `Locale` reactivo que rebuilds `MaterialApp` al
/// cambiar.
final ValueNotifier<Locale?> localeAppUnoRoto = ValueNotifier<Locale?>(null);

class AppUnoRoto extends StatelessWidget {
  const AppUnoRoto({super.key});

  @override
  Widget build(BuildContext contexto) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeAppUnoRoto,
      builder: (ctx, localeActivo, _) {
        return MaterialApp(
          title: 'Uno Roto — Prototipo del combate',
          theme: temaUnoRoto(),
          debugShowCheckedModeBanner: false,
          // Si el niño eligió idioma en PantallaConfiguracionInicial,
          // localeAppUnoRoto manda. Si no, el localeResolutionCallback
          // mira el sistema y cae a castellano para idiomas no
          // soportados — sin eso el delegate elegiría el primero
          // alfabético (catalán) para usuarios en inglés.
          locale: localeActivo,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          localeResolutionCallback: (localeDispositivo, soportados) {
            if (localeDispositivo != null) {
              for (final soportado in soportados) {
                if (soportado.languageCode == localeDispositivo.languageCode) {
                  return soportado;
                }
              }
            }
            return const Locale('es');
          },
          home: const OrquestadorFases(),
        );
      },
    );
  }
}

enum _FaseApp {
  cargando,
  configuracionInicial,
  perfiles,
  apertura,
  nombre,
  cinematica,
  combateKurz,
  mapa,
}

class OrquestadorFases extends StatefulWidget {
  const OrquestadorFases({super.key});

  @override
  State<OrquestadorFases> createState() => _OrquestadorFasesState();
}

class _OrquestadorFasesState extends State<OrquestadorFases> {
  final RepositorioProgreso _repositorio = RepositorioProgreso();
  _FaseApp _fase = _FaseApp.cargando;
  EscenaCinematica? _escenaPendiente;
  DesafioKurz? _desafioKurzActivo;
  String? _nombreJugador;
  RitmoJuego _ritmo = RitmoJuego.estandar;

  /// Impide que se dispare más de una variante de entrenamiento por
  /// transición — sin esto, al volver de la variante el orquestador
  /// intentaría disparar otra en bucle.
  bool _varianteYaDisparadaEnEstaTransicion = false;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    // Primer arranque: si no hay idioma elegido, paramos aquí y dejamos
    // que el niño lo decida. Tras la elección, _alElegirIdiomaInicial
    // persiste, actualiza el ValueNotifier global y arranca el flujo
    // del perfil. En arranques posteriores, main() ya precargó el
    // idioma en el ValueNotifier antes de runApp, así que aquí solo
    // miramos si existe la clave para decidir si mostrar la pantalla.
    final codigoIdioma = await _repositorio.cargarIdiomaApp();
    if (codigoIdioma == null) {
      if (!mounted) return;
      setState(() => _fase = _FaseApp.configuracionInicial);
      return;
    }
    final perfiles = await _repositorio.listarPerfilesConInfo();
    // Si hay más de un perfil, pedimos al usuario que elija al arrancar.
    // Con un único perfil seguimos el flujo normal (el activo).
    final conVariosPerfiles = perfiles.length > 1;
    if (conVariosPerfiles) {
      if (!mounted) return;
      setState(() => _fase = _FaseApp.perfiles);
      return;
    }
    await _iniciarFlujoDelPerfilActivo();
  }

  Future<void> _iniciarFlujoDelPerfilActivo() async {
    // Arranca o recarga el motor sonoro con las preferencias del perfil
    // activo en segundo plano. No lo esperamos: el motor tolera que lo
    // llamen antes de estar listo (cada método sale sin hacer nada si
    // `_inicializado == false`) y si en tests el plugin de audio no
    // está registrado, la app no debe quedarse colgada en `.cargando`.
    unawaited(ServicioSonoro.instancia.inicializar(_repositorio));
    final yaVioApertura = await _repositorio.yaVioLaApertura();
    await _repositorio.guardarAhoraComoUltimaApertura();
    _nombreJugador = await _repositorio.cargarNombreJugador();
    _ritmo = await _repositorio.cargarRitmo();
    // Con punto de partida, lo dado por sabido necesita sus flags de
    // maestría para que la historia avance (perfiles de antes del
    // arreglo incluidos).
    if (await _repositorio.cargarNivelEscolar() != null) {
      await asegurarFlagsDeMaestria(_repositorio);
    }
    if (!mounted) return;
    if (!yaVioApertura) {
      setState(() => _fase = _FaseApp.apertura);
      return;
    }
    if (_nombreJugador == null) {
      setState(() => _fase = _FaseApp.nombre);
      return;
    }
    await _resolverCinematicaPendienteOMapa();
  }

  Future<void> _alElegirIdiomaInicial(String codigo) async {
    await _repositorio.guardarIdiomaApp(codigo);
    // Cambiar el locale global rebuilds MaterialApp; los textos a
    // partir de ahora salen en el nuevo idioma.
    localeAppUnoRoto.value = Locale(codigo);
    if (!mounted) return;
    setState(() => _fase = _FaseApp.cargando);
    final perfiles = await _repositorio.listarPerfilesConInfo();
    if (perfiles.length > 1) {
      if (!mounted) return;
      setState(() => _fase = _FaseApp.perfiles);
      return;
    }
    await _iniciarFlujoDelPerfilActivo();
  }

  Future<void> _alElegirPerfil() async {
    // El usuario seleccionó un perfil: reiniciamos estado de sesión y
    // arrancamos el flujo como si fuera un inicio nuevo para ese perfil.
    _escenaPendiente = null;
    _desafioKurzActivo = null;
    _nombreJugador = null;
    _varianteYaDisparadaEnEstaTransicion = false;
    await _iniciarFlujoDelPerfilActivo();
  }

  /// Invocado cuando el usuario cambia de perfil desde el selector
  /// abierto dentro de la app (p.ej. pantalla de habilidades). Cierra
  /// pilas de navegación y devuelve al flujo base con el perfil activo.
  void _reiniciarConPerfilActivo() {
    Navigator.of(context).popUntil((ruta) => ruta.isFirst);
    _escenaPendiente = null;
    _desafioKurzActivo = null;
    _nombreJugador = null;
    _varianteYaDisparadaEnEstaTransicion = false;
    setState(() => _fase = _FaseApp.cargando);
    _iniciarFlujoDelPerfilActivo();
  }

  Future<void> _alTerminarApertura() async {
    await _repositorio.marcarAperturaVista();
    if (!mounted) return;
    if (_nombreJugador == null) {
      setState(() => _fase = _FaseApp.nombre);
      return;
    }
    await _resolverCinematicaPendienteOMapa();
  }

  Future<void> _alConfirmarNombre(String nombre) async {
    await _repositorio.guardarNombreJugador(nombre);
    _nombreJugador = nombre;
    if (!mounted) return;
    await _resolverCinematicaPendienteOMapa();
  }

  final OrquestadorEscenas _orquestador = OrquestadorEscenas();

  /// Resuelve la siguiente pantalla a mostrar delegando la decisión
  /// pura al [OrquestadorEscenas] y traduciendo la decisión a
  /// `setState` + persistencia (marcar variante usada, resetear pool
  /// cuando hace falta).
  Future<void> _resolverCinematicaPendienteOMapa() async {
    final flagsActivos = await _repositorio.flagsNarrativosActivos();
    final variantesArco1Usadas =
        await _repositorio.cargarVariantesEntrenamientoUsadas();
    final variantesArco2Usadas =
        await _repositorio.cargarVariantesPuentesUsadas();
    final variantesArco3Usadas =
        await _repositorio.cargarVariantesMaquinasUsadas();
    final variantesEraDosUsadas =
        await _repositorio.cargarVariantesEraDosUsadas();

    final decision = _orquestador.decidir(
      flagsActivos: flagsActivos,
      variantesArco1Usadas: variantesArco1Usadas,
      variantesArco2Usadas: variantesArco2Usadas,
      variantesArco3Usadas: variantesArco3Usadas,
      variantesEraDosUsadas: variantesEraDosUsadas,
      varianteYaDisparadaEnEstaTransicion:
          _varianteYaDisparadaEnEstaTransicion,
    );

    switch (decision) {
      case CombateKurzPendiente(:final desafio):
        if (!mounted) return;
        setState(() {
          _desafioKurzActivo = desafio;
          _fase = _FaseApp.combateKurz;
        });
      case CinematicaPendiente(:final escena):
        if (!mounted) return;
        setState(() {
          _escenaPendiente = escena;
          _fase = _FaseApp.cinematica;
        });
      case VariantePendiente(:final variante, :final arco, :final poolReseteado):
        await _persistirVarianteElegida(arco, variante, poolReseteado);
        if (!mounted) return;
        setState(() {
          _escenaPendiente = variante;
          _fase = _FaseApp.cinematica;
          _varianteYaDisparadaEnEstaTransicion = true;
        });
      case IrAlMapa():
        if (!mounted) return;
        setState(() {
          _fase = _FaseApp.mapa;
          _varianteYaDisparadaEnEstaTransicion = false;
        });
    }
  }

  /// Persiste el estado del pool de variantes: si el orquestador
  /// indica `poolReseteado=true` significa que las cinco estaban
  /// usadas y ha elegido la primera de un pool reseteado, así que
  /// borramos el set persistido antes de marcar la nueva.
  Future<void> _persistirVarianteElegida(
    ArcoConVariantes arco,
    EscenaCinematica variante,
    bool poolReseteado,
  ) async {
    // Cuando el pool se acaba de resetear, usamos `reemplazarTodo: true`
    // para que el set quede en {id} en una sola escritura. Sin esto,
    // un reset seguido de un marcado dejaba una ventana intermedia con
    // el set vacío: si la app se cerraba ahí, en el siguiente arranque
    // la primera variante del array volvía a salir, repitiendo la que
    // el niño acababa de ver.
    switch (arco) {
      case ArcoConVariantes.arco1:
        await _repositorio.marcarVarianteEntrenamientoUsada(
          variante.id,
          reemplazarTodo: poolReseteado,
        );
      case ArcoConVariantes.arco2:
        await _repositorio.marcarVariantePuenteUsada(
          variante.id,
          reemplazarTodo: poolReseteado,
        );
      case ArcoConVariantes.arco3:
        await _repositorio.marcarVarianteMaquinaUsada(
          variante.id,
          reemplazarTodo: poolReseteado,
        );
      case ArcoConVariantes.eraDos:
        await _repositorio.marcarVarianteEraDosUsada(
          variante.id,
          reemplazarTodo: poolReseteado,
        );
    }
  }

  Future<void> _alTerminarCombateKurz(ResultadoCombateKurz resultado) async {
    final desafio = _desafioKurzActivo;
    if (desafio != null) {
      final id = desafio.identificador;
      await _repositorio.activarFlagNarrativo('combate_${id}_completado');
      await _repositorio.activarFlagNarrativo(
        resultado.victoria ? 'victoria_$id' : 'derrota_$id',
      );
      // Vencer a Kurz por tercera vez es el hito narrativo del Arco I:
      // garantiza Aprendiz II aunque no se haya alcanzado por esquirlas,
      // así la 1.13 (ceremonia) puede dispararse.
      if (id == 'kurz_3' && resultado.victoria) {
        await _repositorio.forzarRangoMinimo(RangoNarrativo.aprendiz2);
      }
    }
    if (!mounted) return;
    _desafioKurzActivo = null;
    await _resolverCinematicaPendienteOMapa();
  }

  Future<void> _alTerminarCinematica() async {
    final escena = _escenaPendiente;
    if (escena != null) {
      await _repositorio.activarFlagNarrativo(escena.flagDeSalida);
    }
    if (!mounted) return;
    final eraCierreAmable = escena?.esCierreAmable ?? false;
    _escenaPendiente = null;
    if (eraCierreAmable) {
      // Respeto del principio de cierre: no encadenamos otra cinemática
      // en esta misma sesión — vamos directamente al mapa.
      setState(() => _fase = _FaseApp.mapa);
      return;
    }
    await _resolverCinematicaPendienteOMapa();
  }

  @override
  Widget build(BuildContext contexto) {
    switch (_fase) {
      case _FaseApp.cargando:
        return const ColoredBox(color: PaletaNeon.fondoProfundo);
      case _FaseApp.configuracionInicial:
        return PantallaConfiguracionInicial(
          alElegirIdioma: _alElegirIdiomaInicial,
        );
      case _FaseApp.perfiles:
        return PantallaPerfiles(
          repositorio: _repositorio,
          alPerfilSeleccionado: _alElegirPerfil,
        );
      case _FaseApp.apertura:
        return PantallaApertura(alTerminarApertura: _alTerminarApertura);
      case _FaseApp.nombre:
        return PantallaNombre(alConfirmar: _alConfirmarNombre);
      case _FaseApp.cinematica:
        final escena = _escenaPendiente;
        if (escena == null) {
          return const ColoredBox(color: PaletaNeon.fondoProfundo);
        }
        return PantallaCinematica(
          escena: escena,
          nombreJugador: _nombreJugador ?? '',
          alTerminar: _alTerminarCinematica,
          alEstablecerFlag: _repositorio.activarFlagNarrativo,
          ritmo: _ritmo,
        );
      case _FaseApp.combateKurz:
        final desafio = _desafioKurzActivo;
        if (desafio == null) {
          return const ColoredBox(color: PaletaNeon.fondoProfundo);
        }
        return PantallaCombateKurz(
          desafio: desafio,
          nombreJugador: _nombreJugador ?? '',
          alTerminar: _alTerminarCombateKurz,
          ritmo: _ritmo,
        );
      case _FaseApp.mapa:
        return PantallaMapa(
          repositorio: _repositorio,
          alReiniciarConPerfilActivo: _reiniciarConPerfilActivo,
        );
    }
  }
}
