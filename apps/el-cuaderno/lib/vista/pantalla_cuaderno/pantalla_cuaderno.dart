import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_companion/nuevo_ser_companion.dart' as companion;
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../../datos/almacenador_medios.dart';
import '../../datos/cliente_auth_cuaderno.dart';
import '../../datos/cola_sync_observaciones.dart';
import '../../datos/selector_imagen.dart';
import '../../datos/repositorio_historico_resumenes.dart';
import '../../datos/repositorio_mapa_online_opt_in.dart';
import '../../datos/repositorio_presentacion_sit_spot.dart';
import '../../datos/sincronizador_agregados.dart';
import '../../dominio/eco_temporal.dart';
import '../../dominio/exportador_cuaderno.dart';
import '../../dominio/exportador_cuaderno_pdf.dart';
import '../../dominio/fenologia.dart';
import '../../dominio/geolocalizacion_privacy_first.dart';
import '../../dominio/misterio.dart';
import '../../dominio/observacion.dart';
import '../../dominio/pregunta_del_nino.dart';
import '../../dominio/repositorio_local.dart';
import '../../nucleo/i18n/generado/textos_app.dart';
import '../pantalla_ajustes/pantalla_ajustes.dart';
import '../pantalla_observacion/pantalla_detalle_observacion.dart';
import '../pantalla_observacion/pantalla_observacion.dart';
import '../pantalla_observaciones/pantalla_lista_observaciones.dart';
import '../pantalla_atlas/pantalla_atlas.dart';
import '../pantalla_pregunta/pantalla_formular_pregunta.dart';
import '../pantalla_pregunta/pantalla_pagina_pregunta.dart';
import '../pantalla_profesor/pantalla_login_profesor.dart';
import '../pantalla_sit_spot/pantalla_crear_sit_spot.dart';
import '../pantalla_sit_spot/pantalla_pagina_sit_spot.dart';
import '../pantalla_tutor/pantalla_tutor.dart';
import '../tema/colores.dart';
import '../tema/tipografia.dart';
import 'datos_mapa.dart';
import 'estado_cuaderno.dart';
import 'pantalla_pagina_misterio.dart';
import 'seccion_ultima_pagina.dart';
import 'tarjeta_misterio.dart';
import 'tarjeta_sit_spot.dart';

/// Pantalla principal del juego. Bottom nav con cuatro pestañas; en
/// S1 solo Cuaderno y Tutor llevan a algo — Mapa y Misterios muestran
/// "próximamente" sin más fanfarria.
class PantallaCuaderno extends StatefulWidget {
  const PantallaCuaderno({
    super.key,
    required this.repositorio,
    required this.estado,
    this.repoIdioma,
    this.locale,
    this.alCambiarIdioma,
    this.enviarPreguntaTutor,
    this.repoCuenta,
    this.iniciarSesionAdulto,
    this.alCambiarToken,
    this.repoCuentaDebug,
    this.alCambiarTokenDebug,
    this.sincronizadorAgregados,
    this.repoHistoricoResumenes,
    this.repoPresentacionSitSpot,
    this.alResetearPresentacionSitSpot,
    this.alGuardarObservacion,
    this.intentarSincronizarObservaciones,
    this.selectorImagen,
    this.almacenadorMedios,
    this.servicioGeolocalizacion,
    this.resolverMedioParaExport,
    this.cargarMedioParaPdf,
    this.nombrePerfilActivo,
    this.clienteAuthProfesor,
    this.clienteCompanionProfesor,
    this.repoCuentaProfesor,
    this.repoAulaProfesor,
    this.repoMapaOnlineOptIn,
    this.constructorMapa,
  });

  final RepositorioLocal repositorio;
  final EstadoCuaderno estado;

  /// Inyectados por `main.dart`. Opcionales para que los tests de
  /// widget puedan instanciar la pantalla sin tocar `SharedPreferences`.
  /// Si llegan, el AppBar muestra el botón de Ajustes; si no, lo oculta.
  final RepositorioIdiomaApp? repoIdioma;
  final Locale? locale;
  final Future<void> Function()? alCambiarIdioma;

  /// Closure que la pantalla del Tutor consume al recibir una pregunta.
  /// `null` cuando no hay token guardado — la pantalla cae al canned
  /// response. La construcción de la closure (cliente HTTP + lectura
  /// de token) vive en `main.dart`.
  final EnviarPreguntaTutor? enviarPreguntaTutor;

  /// Repositorio de la cuenta del backend. Si llega no nulo, Ajustes
  /// muestra el bloque "Cuenta del adulto" para iniciar/cerrar sesión
  /// real contra `POST /login`. Tests que no tocan login pueden dejarlo
  /// null para instanciar la pantalla aislada.
  final RepositorioCuentaBackend? repoCuenta;

  /// Closure que invoca `ClienteAuthCuaderno.iniciarSesion`. Se inyecta
  /// como callback (en lugar de pasar el cliente entero) para que los
  /// tests puedan ejercitar el flujo con un stub.
  final Future<ResultadoLogin> Function({
    required String email,
    required String password,
  })? iniciarSesionAdulto;

  /// Notifica al orquestador (`main.dart`) que el token cambió tras
  /// iniciar/cerrar sesión, para que recompute la closure del Tutor.
  final VoidCallback? alCambiarToken;

  /// Inyectado solo en builds de debug. Se reenvía a `PantallaAjustes`
  /// para activar el bloque de pegado de JWT. En release siempre llega
  /// null.
  final RepositorioCuentaBackend? repoCuentaDebug;

  /// Callback debug: invocado desde el bloque de pegado de JWT de
  /// Ajustes tras guardar o borrar el token. `main.dart` lo cablea a
  /// un `setState` que refresca el `FutureBuilder` del Tutor.
  final VoidCallback? alCambiarTokenDebug;

  /// Sincronizador de agregados semanales con el companion. Se reenvía
  /// a `PantallaCuidador` para activar el botón "Compartir resumen con
  /// el adulto" — opt-in, lo dispara la persona adulta.
  final SincronizadorAgregadosCuaderno? sincronizadorAgregados;

  /// Persistencia local de los últimos resúmenes archivados (default
  /// 3) — se reenvía a `PantallaCuidador` para que muestre el bloque
  /// "Resúmenes anteriores" y archive cada nueva sincronización
  /// exitosa. Si es null, el bloque no aparece — modo S1 / tests sin
  /// `SharedPreferences`. También lo reusa el flujo "borrar mi
  /// cuaderno" para purgar el histórico junto con Isar.
  final RepositorioHistoricoResumenes? repoHistoricoResumenes;

  /// Flag global de la presentación pedagógica del sit spot. Se
  /// reenvía a `PantallaAjustes` para que el flujo "borrar mi cuaderno"
  /// lo purge junto con el resto del cuaderno.
  final RepositorioPresentacionSitSpot? repoPresentacionSitSpot;

  /// Callback que el orquestador cabla a un reset del `ValueNotifier`
  /// global de la presentación, para que la app vuelva a montarla
  /// inmediatamente tras un "borrar todo" sin esperar a un reinicio.
  final VoidCallback? alResetearPresentacionSitSpot;

  /// Cableado por el orquestador a `ColaSyncObservaciones.marcarPendiente`.
  /// Cada observación nueva queda apuntada para subir al backend cuando
  /// el adulto pulse "Sincronizar observaciones" en Ajustes (opt-in).
  /// Si es null, el cuaderno funciona sólo en local.
  final Future<void> Function(Observacion observacion)? alGuardarObservacion;

  /// Closure que el orquestador cablea a `ColaSyncObservaciones.intentarEnviar`
  /// con el `ClienteElCuaderno` ya construido. Si es null, el botón de
  /// sincronizar no aparece. Devuelve null si no hay token guardado.
  final Future<ResultadoSyncObservaciones?> Function()?
      intentarSincronizarObservaciones;

  /// Selector de imagen (cámara + galería) que `PantallaObservacion`
  /// usa para anclar una foto. Si es null, los botones de foto no
  /// aparecen — modo S1, builds de test que no quieren simular el
  /// flujo nativo.
  final SelectorImagen? selectorImagen;

  /// Almacenador que mueve la foto seleccionada al directorio privado
  /// de la app. Requerido si [selectorImagen] no es null.
  final AlmacenadorMedios? almacenadorMedios;

  /// Servicio de geolocalización para anclar coordenadas a las
  /// observaciones (B5). Si llega no nulo, `PantallaObservacion`
  /// muestra el bloque opt-in. Las coords se persisten sólo en local.
  final ServicioGeolocalizacion? servicioGeolocalizacion;

  /// Resuelve presencia y tamaño de cada fichero medio al exportar el
  /// cuaderno (export v2). Si es null, el export queda sin manifiesto
  /// — sigue siendo válido pero menos informativo.
  final ResolverMedioExportado? resolverMedioParaExport;

  /// Lee bytes de cada fichero medio para incrustarlo como imagen en
  /// el PDF exportado. Si es null, el PDF se queda sin imágenes
  /// (modo degradado: el contenido textual sigue siendo legible).
  final CargarMedioPdf? cargarMedioParaPdf;

  /// Nombre del niño dueño del cuaderno (perfil activo). Se usa en
  /// el saludo del home ("Hola, {nombre}.") y como encabezado del PDF
  /// exportado. Lo provee el orquestador desde el `ValueNotifier`
  /// global. Si es null o vacío, el saludo cae al genérico ("Hola.").
  final String? nombrePerfilActivo;

  /// Conjunto de dependencias del modo profesor (B7 — fallback de
  /// experto pendiente de policy escolar). Se reenvían a Ajustes para
  /// que el bloque "Acceder como profesor" pueda construir las
  /// pantallas de login/dashboard. Si alguno es null, el bloque no se
  /// monta y los tests del cuaderno-niño pueden ignorarlo.
  final companion.ClienteAuthAdulto? clienteAuthProfesor;
  final companion.ClienteCompanion? clienteCompanionProfesor;
  final RepositorioCuentaBackend? repoCuentaProfesor;
  final RepositorioAulaProfesorContrato? repoAulaProfesor;

  /// Opt-in del adulto al mapa online provisional (B5 fallback de
  /// experto). Si llega no nulo, la pestaña Mapa lo lee al construirse
  /// y decide si monta el `FlutterMap` (opt-in activo) o microcopia
  /// educativa (opt-in inactivo). Si es null, la pestaña cae al estado
  /// "tu adulto puede activar el mapa en Ajustes" — es lo mismo que
  /// `false`, sólo que el orquestador no lo cabló (p. ej. tests).
  final RepositorioMapaOnlineOptIn? repoMapaOnlineOptIn;

  /// Constructor opcional del widget de mapa para tests. Por defecto
  /// se usa `FlutterMap` real, que en `flutter test` falla al pintar
  /// tiles porque no hay capa de red. Tests inyectan un stub que pinta
  /// un `Container` y permiten ejercitar el dispatcher de estados.
  final Widget Function(BuildContext context, DatosMapa datos)?
      constructorMapa;

  @override
  State<PantallaCuaderno> createState() => _EstadoPantallaCuaderno();
}

class _EstadoPantallaCuaderno extends State<PantallaCuaderno> {
  int _indicePestana = 0;

  /// Versión del opt-in del mapa online. Se incrementa cada vez que el
  /// adulto cambia el switch en Ajustes — la usamos como `Key` de la
  /// pestaña Mapa para forzar que `_VistaMapa` se reconstruya y vuelva
  /// a leer el repo.
  int _versionMapaOptIn = 0;

  @override
  void initState() {
    super.initState();
    widget.estado.cargar();
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = TextosApp.of(context);

    final puedeAbrirAjustes = widget.repoIdioma != null &&
        widget.locale != null &&
        widget.alCambiarIdioma != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(textos.tituloApp),
        actions: [
          if (puedeAbrirAjustes)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: textos.ajustesTitulo,
              onPressed: _abrirAjustes,
            ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _indicePestana,
          children: [
            _VistaCuaderno(
              estado: widget.estado,
              nombrePerfilActivo: widget.nombrePerfilActivo,
              alAbrirNuevaObservacion: _abrirNuevaObservacion,
              alCrearSitSpot: _abrirCrearSitSpot,
              alJubilarSitSpot: _jubilarSitSpot,
              alAbrirListaObservaciones: _abrirListaObservaciones,
              alAbrirAtlas: _abrirAtlas,
              alAbrirMisterio: _abrirPaginaMisterio,
              alAbrirPaginaSitSpot: _abrirPaginaSitSpot,
              alAbrirDetalleObservacion: _abrirDetalleObservacion,
            ),
            _VistaMapa(
              key: ValueKey('vista-mapa-$_versionMapaOptIn'),
              repositorio: widget.repositorio,
              estado: widget.estado,
              repoMapaOnline: widget.repoMapaOnlineOptIn,
              constructorMapa: widget.constructorMapa,
              alAbrirAjustes: puedeAbrirAjustes ? _abrirAjustes : null,
              alAbrirCrearSitSpot: _abrirCrearSitSpot,
              alAbrirPaginaSitSpot: _abrirPaginaSitSpot,
              alAbrirDetalleObservacion: _abrirDetalleObservacion,
              alOptInCambiado: () {
                if (!mounted) return;
                setState(() => _versionMapaOptIn++);
              },
            ),
            _VistaMisterios(
              estado: widget.estado,
              alAbrirMisterio: _abrirPaginaMisterio,
              alAbrirPregunta: _abrirPaginaPregunta,
            ),
            PantallaTutor(
              repositorio: widget.repositorio,
              enviarPregunta: widget.enviarPreguntaTutor,
            ),
          ],
        ),
      ),
      floatingActionButton: _floatingActionButtonParaPestana(textos, esquema),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indicePestana,
        onDestinationSelected: (indice) =>
            setState(() => _indicePestana = indice),
        backgroundColor: esquema.surface,
        indicatorColor: esquema.surfaceContainerHighest,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: textos.navCuaderno,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: textos.navMapa,
          ),
          NavigationDestination(
            icon: const Icon(Icons.help_outline),
            selectedIcon: const Icon(Icons.help),
            label: textos.navMisterios,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_outlined),
            selectedIcon: const Icon(Icons.chat),
            label: textos.navTutor,
          ),
        ],
      ),
    );
  }

  Future<void> _abrirListaObservaciones() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PantallaListaObservaciones(
          repositorio: widget.repositorio,
          alAbrirDetalle: _abrirDetalleObservacion,
          almacenadorMedios: widget.almacenadorMedios,
        ),
      ),
    );
    if (mounted) {
      // Tras volver, una observación pudo borrarse desde el detalle.
      await widget.estado.cargar();
    }
  }

  Future<void> _abrirAtlas() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PantallaAtlas(
          repositorio: widget.repositorio,
          alAbrirDetalle: _abrirDetalleObservacion,
        ),
      ),
    );
    if (mounted) {
      // Tras volver, una observación pudo borrarse desde el detalle
      // del atlas — recargamos por si toca actualizar el home.
      await widget.estado.cargar();
    }
  }

  Future<void> _abrirCrearSitSpot() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PantallaCrearSitSpot(
          servicioGeolocalizacion: widget.servicioGeolocalizacion,
          alConfirmar: (sitSpot) async {
            await widget.repositorio.establecerSitSpot(sitSpot);
          },
        ),
      ),
    );
    if (mounted) {
      await widget.estado.cargar();
    }
  }

  /// Confirma con el niño la jubilación del sit spot activo (doc 13
  /// §2.6) y, tras aceptar, marca `retiradoEn`. La página del sit
  /// spot sigue accesible en el cuaderno; sólo no se podrán registrar
  /// nuevas observaciones contra él. Tras la jubilación, el home
  /// muestra otra vez la tarjeta de invitación.
  Future<void> _jubilarSitSpot() async {
    final actual = widget.estado.sitSpot;
    if (actual == null) return;
    final textos = TextosApp.of(context);
    final navigator = Navigator.of(context);
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: Text(textos.sitSpotJubilarTitulo),
        content: Text(textos.sitSpotJubilarMensaje(actual.nombre)),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(false),
            child: Text(textos.sitSpotJubilarCancelar),
          ),
          FilledButton(
            onPressed: () => navigator.pop(true),
            child: Text(textos.sitSpotJubilarConfirmar),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    await widget.repositorio.establecerSitSpot(
      actual.copyWith(retiradoEn: DateTime.now()),
    );
    if (mounted) {
      await widget.estado.cargar();
    }
  }

  Future<void> _abrirNuevaObservacion() => _abrirObservacion(null);

  Future<void> _abrirObservacion(String? misterioPreseleccionadoId) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PantallaObservacion(
          repositorio: widget.repositorio,
          misteriosAbiertos: widget.estado.misteriosAbiertos,
          sitSpotActivo: widget.estado.sitSpot,
          misterioPreseleccionadoId: misterioPreseleccionadoId,
          alGuardarObservacion: widget.alGuardarObservacion,
          selectorImagen: widget.selectorImagen,
          almacenadorMedios: widget.almacenadorMedios,
          servicioGeolocalizacion: widget.servicioGeolocalizacion,
        ),
      ),
    );
    if (mounted) {
      await widget.estado.cargar();
    }
  }

  Future<void> _abrirObservacionParaPregunta(String preguntaId) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PantallaObservacion(
          repositorio: widget.repositorio,
          misteriosAbiertos: widget.estado.misteriosAbiertos,
          sitSpotActivo: widget.estado.sitSpot,
          preguntaDelNinoPreseleccionadaId: preguntaId,
          alGuardarObservacion: widget.alGuardarObservacion,
          selectorImagen: widget.selectorImagen,
          almacenadorMedios: widget.almacenadorMedios,
          servicioGeolocalizacion: widget.servicioGeolocalizacion,
        ),
      ),
    );
    if (mounted) {
      await widget.estado.cargar();
    }
  }

  Future<void> _abrirPaginaMisterio(Misterio misterio) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PantallaPaginaMisterio(
          repositorio: widget.repositorio,
          misterio: misterio,
          alAbrirNuevaObservacion: _abrirObservacion,
        ),
      ),
    );
    if (mounted) {
      await widget.estado.cargar();
    }
  }

  Future<void> _abrirPaginaSitSpot() async {
    final sitSpot = widget.estado.sitSpot;
    if (sitSpot == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PantallaPaginaSitSpot(
          repositorio: widget.repositorio,
          sitSpot: sitSpot,
          alAbrirNuevaObservacion: _abrirNuevaObservacion,
          almacenadorMedios: widget.almacenadorMedios,
        ),
      ),
    );
    if (mounted) {
      await widget.estado.cargar();
    }
  }

  Future<void> _abrirDetalleObservacion(Observacion observacion) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PantallaDetalleObservacion(
          repositorio: widget.repositorio,
          observacion: observacion,
          almacenadorMedios: widget.almacenadorMedios,
          nombrePerfilActivo: widget.nombrePerfilActivo,
          cargarMedioParaPdf: widget.cargarMedioParaPdf,
        ),
      ),
    );
  }

  Future<void> _formularPregunta() async {
    await Navigator.of(context).push<PreguntaDelNino?>(
      MaterialPageRoute(
        builder: (_) => PantallaFormularPregunta(
          repositorio: widget.repositorio,
        ),
      ),
    );
    if (mounted) {
      await widget.estado.cargar();
    }
  }

  Future<void> _abrirPaginaPregunta(PreguntaDelNino pregunta) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PantallaPaginaPregunta(
          repositorio: widget.repositorio,
          pregunta: pregunta,
          alAbrirNuevaObservacion: _abrirObservacionParaPregunta,
        ),
      ),
    );
    if (mounted) {
      await widget.estado.cargar();
    }
  }

  /// FAB que cambia según la pestaña activa: en Cuaderno (0) abre nueva
  /// observación; en Misterios (2) formula pregunta del niño. Mapa y
  /// Tutor no muestran FAB.
  Widget? _floatingActionButtonParaPestana(
    TextosApp textos,
    ColorScheme esquema,
  ) {
    if (_indicePestana == 0) {
      return FloatingActionButton.extended(
        onPressed: _abrirNuevaObservacion,
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
        tooltip: textos.homeFabAnotarTooltip,
        icon: const Icon(Icons.edit_outlined),
        label: Text(textos.homeFabAnotar),
      );
    }
    if (_indicePestana == 2) {
      return FloatingActionButton.extended(
        onPressed: _formularPregunta,
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
        tooltip: textos.preguntaFabFormular,
        icon: const Icon(Icons.add_outlined),
        label: Text(textos.preguntaFabFormular),
      );
    }
    return null;
  }

  Future<void> _abrirAjustes() async {
    final repoIdioma = widget.repoIdioma!;
    final locale = widget.locale!;
    final alCambiarIdioma = widget.alCambiarIdioma!;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PantallaAjustes(
          repositorio: widget.repositorio,
          repoIdioma: repoIdioma,
          locale: locale,
          alCambiarIdioma: alCambiarIdioma,
          repoCuenta: widget.repoCuenta,
          iniciarSesionAdulto: widget.iniciarSesionAdulto,
          alCambiarToken: widget.alCambiarToken,
          repoCuentaDebug: widget.repoCuentaDebug,
          alCambiarTokenDebug: widget.alCambiarTokenDebug,
          sincronizadorAgregados: widget.sincronizadorAgregados,
          repoHistoricoResumenes: widget.repoHistoricoResumenes,
          repoPresentacionSitSpot: widget.repoPresentacionSitSpot,
          alResetearPresentacionSitSpot:
              widget.alResetearPresentacionSitSpot,
          intentarSincronizarObservaciones:
              widget.intentarSincronizarObservaciones,
          resolverMedioParaExport: widget.resolverMedioParaExport,
          cargarMedioParaPdf: widget.cargarMedioParaPdf,
          almacenadorMedios: widget.almacenadorMedios,
          nombrePerfilActivo: widget.nombrePerfilActivo,
          clienteAuthProfesor: widget.clienteAuthProfesor,
          clienteCompanionProfesor: widget.clienteCompanionProfesor,
          repoCuentaProfesor: widget.repoCuentaProfesor,
          repoAulaProfesor: widget.repoAulaProfesor,
          repoMapaOnlineOptIn: widget.repoMapaOnlineOptIn,
          alCambiarMapaOnlineOptIn: () {
            if (!mounted) return;
            setState(() => _versionMapaOptIn++);
          },
        ),
      ),
    );
    if (mounted) {
      // Tras el borrado el estado puede haber cambiado.
      await widget.estado.cargar();
    }
  }
}

/// Vista del cuaderno propiamente dicha — la primera pestaña. Scroll
/// vertical con cabecera + saludo + sit spot + Misterios + última
/// página, conforme al mockup descrito en biblia §5.4.
class _VistaCuaderno extends StatelessWidget {
  const _VistaCuaderno({
    required this.estado,
    required this.nombrePerfilActivo,
    required this.alAbrirNuevaObservacion,
    required this.alCrearSitSpot,
    required this.alJubilarSitSpot,
    required this.alAbrirListaObservaciones,
    required this.alAbrirAtlas,
    required this.alAbrirMisterio,
    required this.alAbrirPaginaSitSpot,
    required this.alAbrirDetalleObservacion,
  });

  final EstadoCuaderno estado;
  final String? nombrePerfilActivo;
  final VoidCallback alAbrirNuevaObservacion;
  final VoidCallback alCrearSitSpot;
  final VoidCallback alJubilarSitSpot;
  final VoidCallback alAbrirListaObservaciones;
  final VoidCallback alAbrirAtlas;
  final void Function(Misterio misterio) alAbrirMisterio;
  final VoidCallback alAbrirPaginaSitSpot;
  final void Function(Observacion observacion) alAbrirDetalleObservacion;

  @override
  Widget build(BuildContext context) {
    final textos = TextosApp.of(context);
    final esquema = Theme.of(context).colorScheme;
    final nombre = nombrePerfilActivo?.trim() ?? '';
    final saludo = nombre.isEmpty
        ? textos.saludoSinNombre
        : textos.saludoConNombre(nombre);

    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        if (estado.cargando && estado.sitSpot == null) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        final misteriosAMostrar =
            estado.misteriosAbiertos.take(3).toList(growable: false);

        final hayMisteriosVisibles = misteriosAMostrar.isNotEmpty;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            Text(
              saludo,
              style: TipografiaCuaderno.serif(
                color: esquema.onSurface,
                tamano: TipografiaCuaderno.tamano17,
                peso: TipografiaCuaderno.pesoMedio,
              ),
            ),
            ..._tipFenologico(estado),
            if (hayMisteriosVisibles) ...[
              const SizedBox(height: 12),
              Text(
                textos.homeOrientacionConMisterios,
                style: TipografiaCuaderno.serif(
                  color: PaletaCuaderno.tintaTenue,
                  tamano: TipografiaCuaderno.tamano13,
                  altoLinea: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 24),
            _Cabecera(textos.seccionSitSpot),
            const SizedBox(height: 8),
            TarjetaSitSpot(
              sitSpot: estado.sitSpot,
              alPulsarInvitacion: estado.sitSpot == null ? alCrearSitSpot : null,
              alPulsarActivo:
                  estado.sitSpot == null ? null : alAbrirPaginaSitSpot,
              alJubilar: estado.sitSpot == null ? null : alJubilarSitSpot,
            ),
            const SizedBox(height: 24),
            _Cabecera(textos.seccionMisteriosAbiertos),
            const SizedBox(height: 8),
            if (misteriosAMostrar.isEmpty)
              Text(
                textos.misteriosVacio,
                style: TipografiaCuaderno.serif(
                  color: PaletaCuaderno.tintaTenue,
                  tamano: TipografiaCuaderno.tamano13,
                  altoLinea: 1.45,
                ),
              )
            else
              for (final misterio in misteriosAMostrar) ...[
                TarjetaMisterio(
                  misterio: misterio,
                  evidencias: estado.evidenciasPorMisterio[misterio.id],
                  enVentanaCaliente:
                      estado.misteriosEnVentanaCaliente.contains(misterio.id),
                  alPulsar: () => alAbrirMisterio(misterio),
                ),
                const SizedBox(height: 8),
              ],
            if (estado.ecos.isNotEmpty) ...[
              const SizedBox(height: 24),
              _Cabecera(textos.seccionEcos),
              const SizedBox(height: 8),
              for (final eco in estado.ecos) ...[
                _TarjetaEco(
                  eco: eco,
                  alPulsar: () => alAbrirDetalleObservacion(eco.observacion),
                ),
                const SizedBox(height: 8),
              ],
            ],
            const SizedBox(height: 16),
            _Cabecera(textos.seccionUltimaPagina),
            const SizedBox(height: 8),
            SeccionUltimaPagina(
              observacion: estado.ultimaObservacion,
              alPulsar: alAbrirDetalleObservacion,
            ),
            if (estado.ultimasObservaciones.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: alAbrirAtlas,
                    child: Text(textos.atlasEnlaceDesdeCuaderno),
                  ),
                  TextButton(
                    onPressed: alAbrirListaObservaciones,
                    child: Text(textos.homeBotonVerTodasPaginas),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Construye el bloque del tip fenológico del día — una sola línea
/// en serif gris bajo el saludo, ata el cuaderno al lugar+estación
/// reales del niño con coste cero (los datos ya cargados).
///
/// Devuelve lista vacía si:
/// - el estado aún no ha hecho la primera carga (no hay
///   `estacionActual` o `fechaContexto`);
/// - para la pareja `(region, estacion)` no hay notas en el catálogo
///   de [NotasFenologicasIberia] (algunas combinaciones quedan vacías
///   a propósito hasta que entre la asesoría B11).
List<Widget> _tipFenologico(EstadoCuaderno estado) {
  final fecha = estado.fechaContexto;
  final estacion = estado.estacionActual;
  if (fecha == null || estacion == null) return const [];
  final nota = NotasFenologicasIberia.notaDelDia(
    regionCode: estado.regionActual ?? 'ES',
    estacion: estacion,
    fecha: fecha,
  );
  if (nota == null) return const [];
  return [
    const SizedBox(height: 4),
    Text(
      nota,
      style: TipografiaCuaderno.serif(
        color: PaletaCuaderno.tintaTenue,
        tamano: TipografiaCuaderno.tamano13,
        altoLinea: 1.45,
      ),
    ),
  ];
}

/// Constructor del mapa por defecto: `FlutterMap` real con tiles OSM.
/// Pintar tiles requiere conexión a internet — esto **sólo se invoca
/// cuando el adulto activó el opt-in en Ajustes** (biblia §2.9).
Widget _constructorMapaPorDefecto(BuildContext context, DatosMapa datos) {
  return FlutterMap(
    options: MapOptions(
      initialCenter: LatLng(datos.centroLat, datos.centroLng),
      initialZoom: datos.zoom,
    ),
    children: [
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'org.coleccionnuevoser.elcuaderno',
        // OSM exige cabecera User-Agent identificable y un cap razonable
        // de requests. Sin esto, el servidor puede bloquear el cliente.
      ),
      MarkerLayer(
        markers: [
          for (final descriptor in datos.markers)
            Marker(
              point: LatLng(descriptor.lat, descriptor.lng),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: descriptor.alPulsar,
                child: Tooltip(
                  message: descriptor.tooltip ?? '',
                  child: Icon(
                    descriptor.icono,
                    color: descriptor.color ?? PaletaCuaderno.tinta,
                    size: 32,
                    shadows: const [
                      Shadow(blurRadius: 3, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ],
  );
}

/// Pestaña Mapa del bottom nav (B5 fallback de experto, pendiente de
/// MBTiles offline). Cuatro estados:
///
/// 1. **Sin opt-in del adulto** (default): microcopia educativa con
///    botón "abrir Ajustes" donde el adulto puede activarlo. Sin
///    request a OSM. Es el estado pedagógicamente correcto del MVP —
///    el niño no fuerza una decisión que no le toca.
/// 2. **Opt-in activo + sin sit spot con coordenadas + sin
///    observaciones con coordenadas**: invitación a configurar un
///    sit spot anclando la posición.
/// 3. **Opt-in activo + coordenadas disponibles**: mapa real con
///    marker(s) — sit spot (verde bosque) y observaciones con
///    `dondeCoordenadas` (otro tono). El tap en una observación abre
///    el detalle.
/// 4. **Cargando** (lectura inicial del repo de opt-in): spinner.
class _VistaMapa extends StatefulWidget {
  const _VistaMapa({
    super.key,
    required this.repositorio,
    required this.estado,
    required this.repoMapaOnline,
    required this.constructorMapa,
    required this.alAbrirAjustes,
    required this.alAbrirCrearSitSpot,
    required this.alAbrirPaginaSitSpot,
    required this.alAbrirDetalleObservacion,
    this.alOptInCambiado,
  });

  final RepositorioLocal repositorio;
  final EstadoCuaderno estado;
  final RepositorioMapaOnlineOptIn? repoMapaOnline;
  final Widget Function(BuildContext context, DatosMapa datos)?
      constructorMapa;
  final VoidCallback? alAbrirAjustes;
  final void Function() alAbrirCrearSitSpot;
  final void Function() alAbrirPaginaSitSpot;
  final void Function(Observacion observacion) alAbrirDetalleObservacion;
  final VoidCallback? alOptInCambiado;

  @override
  State<_VistaMapa> createState() => _EstadoVistaMapa();
}

class _EstadoVistaMapa extends State<_VistaMapa> {
  bool _cargando = true;
  bool _optInActivo = false;
  List<Observacion> _observacionesConCoords = const [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final activo = widget.repoMapaOnline == null
        ? false
        : await widget.repoMapaOnline!.cargar();
    List<Observacion> observaciones = const [];
    if (activo) {
      // Sólo leemos las observaciones cuando el mapa va a montarse —
      // lectura local, sin red. Si el opt-in está OFF no tiene sentido
      // tocar el repo para nada.
      final todas =
          await widget.repositorio.obtenerObservaciones(limite: 200);
      observaciones = todas
          .where((obs) => obs.dondeCoordenadas != null)
          .toList(growable: false);
    }
    if (!mounted) return;
    setState(() {
      _cargando = false;
      _optInActivo = activo;
      _observacionesConCoords = observaciones;
    });
  }

  /// Atajo del adulto: AlertDialog inline con el copy del bloque y
  /// botón "encender". Evita que tenga que bucear hasta el final de
  /// Ajustes para encontrar el switch. Si confirma, activa el repo,
  /// avisa al padre (`alOptInCambiado`) y recarga la vista para que
  /// pase del aviso al mapa real (o al aviso "ancla tu lugar" si no
  /// hay coordenadas todavía).
  Future<void> _confirmarEncender() async {
    final repo = widget.repoMapaOnline;
    if (repo == null) return;
    final textos = TextosApp.of(context);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(textos.ajustesMapaOnlineEtiqueta),
          content: Text(textos.ajustesMapaOnlineCuerpo),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(textos.mapaConfirmarEncenderCancelar),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(textos.mapaConfirmarEncenderEncender),
            ),
          ],
        );
      },
    );
    if (confirmado != true) return;
    await repo.activar();
    if (!mounted) return;
    widget.alOptInCambiado?.call();
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (!_optInActivo) {
      return _AvisoMapaInactivo(
        alAbrirAjustes: widget.alAbrirAjustes,
        alEncender:
            widget.repoMapaOnline == null ? null : _confirmarEncender,
      );
    }
    return ListenableBuilder(
      listenable: widget.estado,
      builder: (context, _) {
        final coordsSitSpot = widget.estado.sitSpot?.coordenadas;
        if (coordsSitSpot == null && _observacionesConCoords.isEmpty) {
          return _AvisoSinCoordenadas(
            alAbrirCrearSitSpot: widget.alAbrirCrearSitSpot,
          );
        }
        // Centramos en el sit spot si lo hay, si no en la primera
        // observación con coords. Zoom 15 = nivel "barrio".
        final centro = coordsSitSpot ?? _observacionesConCoords.first.dondeCoordenadas!;
        final markers = <DescriptorMarker>[
          if (coordsSitSpot != null)
            DescriptorMarker(
              lat: coordsSitSpot.lat,
              lng: coordsSitSpot.lng,
              icono: Icons.place,
              color: PaletaCuaderno.tinta,
              tooltip: widget.estado.sitSpot?.nombre,
              alPulsar: widget.alAbrirPaginaSitSpot,
            ),
          for (final obs in _observacionesConCoords)
            DescriptorMarker(
              lat: obs.dondeCoordenadas!.lat,
              lng: obs.dondeCoordenadas!.lng,
              icono: Icons.fiber_manual_record,
              color: PaletaCuaderno.tintaTenue,
              tooltip: obs.queVio,
              alPulsar: () => widget.alAbrirDetalleObservacion(obs),
            ),
        ];
        final datos = DatosMapa(
          centroLat: centro.lat,
          centroLng: centro.lng,
          markers: markers,
        );
        final builder =
            widget.constructorMapa ?? _constructorMapaPorDefecto;
        return builder(context, datos);
      },
    );
  }
}

class _AvisoMapaInactivo extends StatelessWidget {
  const _AvisoMapaInactivo({
    required this.alAbrirAjustes,
    this.alEncender,
  });

  final VoidCallback? alAbrirAjustes;
  final VoidCallback? alEncender;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = TextosApp.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'El mapa está apagado.',
              textAlign: TextAlign.center,
              style: TipografiaCuaderno.serif(
                color: esquema.onSurface,
                tamano: TipografiaCuaderno.tamano14,
                peso: TipografiaCuaderno.pesoMedio,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'El adulto que te acompaña puede encenderlo. '
              'Mientras esté apagado, este cuaderno no le pide al servidor '
              'de mapas qué zona del mundo estás mirando.',
              textAlign: TextAlign.center,
              style: TipografiaCuaderno.serif(
                color: PaletaCuaderno.tintaTenue,
                tamano: TipografiaCuaderno.tamano13,
                altoLinea: 1.5,
              ),
            ),
            if (alEncender != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: alEncender,
                child: Text(textos.mapaBotonEncender),
              ),
            ],
            if (alAbrirAjustes != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: alAbrirAjustes,
                child: Text(textos.mapaBotonAbrirAjustes),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AvisoSinCoordenadas extends StatelessWidget {
  const _AvisoSinCoordenadas({required this.alAbrirCrearSitSpot});

  final VoidCallback alAbrirCrearSitSpot;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = TextosApp.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Aún no has anclado tu lugar al mapa.',
              textAlign: TextAlign.center,
              style: TipografiaCuaderno.serif(
                color: esquema.onSurface,
                tamano: TipografiaCuaderno.tamano14,
                peso: TipografiaCuaderno.pesoMedio,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cuando configures tu sit spot y le ancles la posición, '
              'aparecerá aquí. Las observaciones con posición ancladas '
              'también se ven en el mapa.',
              textAlign: TextAlign.center,
              style: TipografiaCuaderno.serif(
                color: PaletaCuaderno.tintaTenue,
                tamano: TipografiaCuaderno.tamano13,
                altoLinea: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: alAbrirCrearSitSpot,
              child: Text(textos.mapaBotonConfigurarSitSpot),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pestaña Misterios del bottom nav. El home muestra sólo `.take(3)`
/// por orden alfabético; aquí el niño ve la lista entera de Misterios
/// abiertos del catálogo. Cada tarjeta abre su [PantallaPaginaMisterio]
/// reusando la misma navegación que el home.
///
/// Lectura pura — el sistema (no el niño) decide qué Misterios están
/// abiertos en cada momento. Si todavía no hay ninguno, microcopia de
/// estado vacío idéntica a la del home (`textos.misteriosVacio`).
class _VistaMisterios extends StatelessWidget {
  const _VistaMisterios({
    required this.estado,
    required this.alAbrirMisterio,
    required this.alAbrirPregunta,
  });

  final EstadoCuaderno estado;
  final void Function(Misterio misterio) alAbrirMisterio;
  final void Function(PreguntaDelNino pregunta) alAbrirPregunta;

  @override
  Widget build(BuildContext context) {
    final textos = TextosApp.of(context);
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        if (estado.cargando && estado.misteriosAbiertos.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        final misterios = estado.misteriosAbiertos;
        // Distinguimos dos estados vacíos: catálogo vacío (no hay
        // Misterios abiertos en el repo) vs todos filtrados fuera por
        // contexto fenológico/regional. El segundo caso pide microcopia
        // pedagógica distinta — el catálogo existe, sólo está dormido
        // hasta que cambie la estación.
        final mensajeVacio = misterios.isEmpty
            ? (estado.totalMisteriosAbiertosSinFiltro > 0
                ? textos.misteriosFueraDeContexto
                : textos.misteriosVacio)
            : null;
        final cerrados = estado.misteriosCerrados;
        final preguntasAbiertas = estado.preguntasDelNinoAbiertas;
        final preguntasCerradas = estado.preguntasDelNinoCerradas;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            // Sección "Tus preguntas" PRIMERO — el oficio del niño se
            // antepone al catálogo del adulto (biblia §3.4
            // hipotetizar y contrastar).
            _Cabecera(textos.seccionTusPreguntas),
            const SizedBox(height: 12),
            if (preguntasAbiertas.isEmpty)
              Text(
                textos.tusPreguntasVacio,
                style: TipografiaCuaderno.serif(
                  color: PaletaCuaderno.tintaTenue,
                  tamano: TipografiaCuaderno.tamano13,
                  altoLinea: 1.5,
                ),
              )
            else
              for (final pregunta in preguntasAbiertas) ...[
                _TarjetaPreguntaDelNino(
                  pregunta: pregunta,
                  alPulsar: () => alAbrirPregunta(pregunta),
                ),
                const SizedBox(height: 8),
              ],
            if (preguntasCerradas.isNotEmpty) ...[
              const SizedBox(height: 16),
              for (final pregunta in preguntasCerradas) ...[
                _TarjetaPreguntaDelNinoCerrada(
                  pregunta: pregunta,
                  alPulsar: () => alAbrirPregunta(pregunta),
                ),
                const SizedBox(height: 8),
              ],
            ],
            const SizedBox(height: 28),
            _Cabecera(textos.seccionMisteriosDelCuaderno),
            const SizedBox(height: 12),
            if (mensajeVacio != null)
              Text(
                mensajeVacio,
                style: TipografiaCuaderno.serif(
                  color: PaletaCuaderno.tintaTenue,
                  tamano: TipografiaCuaderno.tamano13,
                  altoLinea: 1.5,
                ),
              )
            else
              for (final misterio in misterios) ...[
                TarjetaMisterio(
                  misterio: misterio,
                  evidencias: estado.evidenciasPorMisterio[misterio.id],
                  enVentanaCaliente:
                      estado.misteriosEnVentanaCaliente.contains(misterio.id),
                  alPulsar: () => alAbrirMisterio(misterio),
                ),
                const SizedBox(height: 8),
              ],
            if (cerrados.isNotEmpty) ...[
              const SizedBox(height: 28),
              const _Cabecera('Ya cerrados'),
              const SizedBox(height: 12),
              for (final misterio in cerrados) ...[
                _TarjetaMisterioCerrado(
                  misterio: misterio,
                  alPulsar: () => alAbrirMisterio(misterio),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ],
        );
      },
    );
  }
}

/// Tarjeta minimalista para una pregunta abierta del niño en la pestaña
/// Misterios. Sin contador de evidencias por ahora — Slice 4 lo añade
/// junto al anclaje. Chevron discreto a la derecha como las
/// `TarjetaMisterio`, coherente con el resto del cuaderno.
class _TarjetaPreguntaDelNino extends StatelessWidget {
  const _TarjetaPreguntaDelNino({
    required this.pregunta,
    required this.alPulsar,
  });

  final PreguntaDelNino pregunta;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Material(
      color: esquema.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: esquema.outline, width: 0.5),
      ),
      child: InkWell(
        onTap: alPulsar,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  pregunta.pregunta,
                  style: TipografiaCuaderno.serif(
                    color: esquema.onSurface,
                    tamano: TipografiaCuaderno.tamano14,
                    peso: TipografiaCuaderno.pesoMedio,
                    altoLinea: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: PaletaCuaderno.tintaTenue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta minimalista para una pregunta del niño cerrada — paralela a
/// [_TarjetaMisterioCerrado]. Más discreta que la de abierta: sin
/// chevron, sólo pregunta serif + fecha de cierre.
class _TarjetaPreguntaDelNinoCerrada extends StatelessWidget {
  const _TarjetaPreguntaDelNinoCerrada({
    required this.pregunta,
    required this.alPulsar,
  });

  final PreguntaDelNino pregunta;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final fecha = pregunta.cerradaEn!;
    final fechaFormateada =
        '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
    return Material(
      color: esquema.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: esquema.outline, width: 0.5),
      ),
      child: InkWell(
        onTap: alPulsar,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pregunta.pregunta,
                style: TipografiaCuaderno.serif(
                  color: esquema.onSurface,
                  tamano: TipografiaCuaderno.tamano14,
                  altoLinea: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'cerrada el $fechaFormateada',
                style: TipografiaCuaderno.sans(
                  color: esquema.tertiary,
                  tamano: TipografiaCuaderno.tamano11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Text(
      texto,
      style: TipografiaCuaderno.sans(
        color: esquema.tertiary,
        tamano: TipografiaCuaderno.tamano12,
        peso: TipografiaCuaderno.pesoMedio,
      ),
    );
  }
}

/// Tarjeta del bloque "Hace un tiempo, por aquí" del home. Muestra una
/// observación de hace ~1 mes / 6 meses / 1 año (±3 días), con la
/// cabecera de la ventana en sans gris ceniza y un fragmento del
/// `queVio` en serif. Pulsar abre el detalle. Sin huella visual fuerte:
/// es un guiño, no una notificación. Biblia §3.5: *"si vuelves al
/// mismo sitio, ves cómo cambia"*.
class _TarjetaEco extends StatelessWidget {
  const _TarjetaEco({required this.eco, required this.alPulsar});

  final Eco eco;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = TextosApp.of(context);
    final cabecera = switch (eco.ventana) {
      VentanaEco.haceUnMes => textos.ecoCabeceraUnMes,
      VentanaEco.haceSeisMeses => textos.ecoCabeceraSeisMeses,
      VentanaEco.haceUnAno => textos.ecoCabeceraUnAno,
    };
    final fecha = eco.observacion.cuandoOcurrio;
    final fechaFormateada =
        '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
    return Material(
      color: esquema.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: esquema.outline, width: 0.5),
      ),
      child: InkWell(
        onTap: alPulsar,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cabecera,
                style: TipografiaCuaderno.sans(
                  color: esquema.tertiary,
                  tamano: TipografiaCuaderno.tamano11,
                  peso: TipografiaCuaderno.pesoMedio,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                eco.observacion.queVio,
                style: TipografiaCuaderno.serif(
                  color: esquema.onSurface,
                  tamano: TipografiaCuaderno.tamano14,
                  altoLinea: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                fechaFormateada,
                style: TipografiaCuaderno.sans(
                  color: PaletaCuaderno.tintaTenue,
                  tamano: TipografiaCuaderno.tamano11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Versión visual reducida de `TarjetaMisterio` para Misterios que el
/// niño ya ha cerrado. Sin "estado del consenso" ni "estos días" —
/// muestra pregunta + un fragmento corto de la respuesta del niño +
/// fecha de cierre. Tap → página del Misterio (donde ve la respuesta
/// completa y puede reabrir).
class _TarjetaMisterioCerrado extends StatelessWidget {
  const _TarjetaMisterioCerrado({
    required this.misterio,
    required this.alPulsar,
  });

  final Misterio misterio;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final fecha = misterio.cerradoPorNino!;
    final fechaFormateada =
        '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
    return Material(
      color: esquema.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: esquema.outline, width: 0.5),
      ),
      child: InkWell(
        onTap: alPulsar,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                misterio.pregunta,
                style: TipografiaCuaderno.serif(
                  color: esquema.onSurface,
                  tamano: TipografiaCuaderno.tamano14,
                  altoLinea: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'cerrado el $fechaFormateada',
                style: TipografiaCuaderno.sans(
                  color: esquema.tertiary,
                  tamano: TipografiaCuaderno.tamano11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
