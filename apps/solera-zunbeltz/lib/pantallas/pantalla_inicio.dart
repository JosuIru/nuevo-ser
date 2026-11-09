import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/datos_notificador.dart';
import '../estado/sesion_espacio.dart';
import '../estado/version_demo.dart';
import '../l10n/app_localizations.dart';
import '../modelos/aviso_campo.dart';
import '../modelos/constantes.dart';
import '../modelos/entidad_colaboradora.dart';
import '../modelos/entrada_actividad.dart';
import '../modelos/finca.dart';
import '../modelos/punto_infraestructura.dart';
import '../modelos/tarea_mantenimiento.dart';
import '../modelos/zona_finca.dart';
import '../servicios/servicio_logos_entidades.dart';
import '../servicios/servicio_textos_ayuda.dart';
import '../servicios/servicio_noticias_sector.dart';
import '../servicios/servicio_sincronizacion.dart';
import '../servicios/sincronizacion_segundo_plano.dart'
    show claveUltimaSincronizacion;
import '../utiles/descripcion_actividad.dart';
import '../utiles/estilo_aviso.dart';
import '../utiles/tareas_hoy.dart';
import '../utiles/traductor_actualizaciones.dart';
import 'nueva_peticion.dart';
import 'nuevo_aviso.dart';
import 'pantalla_ayuda.dart';
import 'pantalla_contactos.dart';
import 'pantalla_meteo.dart';
import 'pantalla_entidades.dart';
import 'pantalla_noticias_sector.dart';
import 'widgets/acciones_tarea.dart';
import 'widgets/fila_tarea.dart';
import 'widgets/logos_entidades.dart';
import 'pantalla_peticiones.dart';
import 'tablero_tareas.dart';
import 'widgets/ficha_aviso.dart';

/// Pestaña «Hoy»: la bandeja del espacio. Cabecera verde con la fecha y el
/// estado de la sincronización; las alarmas abiertas; las tareas (vencidas,
/// de esta semana o mías) con su estado y el botón de darlas por hechas; las
/// peticiones; los avisos por categoría en los cuatro cuadros de color del
/// logotipo y, para coordinación, lo último que ha pasado en el espacio. En
/// Noticias, debajo de lo que publica coordinación, van las noticias del
/// sector (los canales RSS del panel). Al final, la franja verde con los
/// logos de las entidades.
///
/// Maqueta del rediseño de noviembre de 2026 (ver `CLAUDE.md`).
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

/// Cuántas tareas se ven en Hoy antes de «Ver todas».
const int _tareasVisiblesEnHoy = 5;

/// Orden de los cuadros de avisos, como en la propuesta de diseño.
const List<String> _ordenCategoriasHoy = [
  categoriaAvisoSeguimiento,
  categoriaAvisoNoticias,
  categoriaAvisoInstalaciones,
  categoriaAvisoGanado,
];

class _PantallaInicioState extends State<PantallaInicio> {
  final _bd = BaseDatosSoleraZunbeltz();
  final _noticiasSector = ServicioNoticiasSector();
  final _logosEntidades = ServicioLogosEntidades();
  final _textosAyuda = ServicioTextosAyuda();
  List<AvisoCampo> _avisos = const [];
  List<EntradaActividad> _actividad = const [];
  List<TareaMantenimiento> _tareas = const [];
  Map<int, Finca> _fincasPorId = const {};
  Map<int, PuntoInfraestructura> _puntosPorId = const {};
  Map<int, ZonaFinca> _zonasPorId = const {};
  int _peticionesPendientes = 0;
  int? _ultimaSincronizacionMs;
  String _categoria = categoriaAvisoGanado;

  /// El filtro de tareas que ha tocado la persona; sin tocar, las vencidas
  /// si las hay y si no las de esta semana.
  FiltroTareasHoy? _filtroElegido;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
    _noticiasSector.actualizar();
    _logosEntidades.actualizar();
    _textosAyuda.actualizar();
    notificadorDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    notificadorDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() => _cargar();

  Future<void> _cargar() async {
    try {
      final politica = politicaEspacioActual;
      final tareas = await _bd.listarTareas();
      final fincas = await _bd.listarFincas();
      final puntos = await _bd.listarPuntos();
      final zonas = await _bd.listarZonas();
      final avisos = await _bd.listarAvisos();
      final actividad = politica.puedeVerActividad
          ? await _bd.listarActividadEspacio(limite: 15)
          : const <EntradaActividad>[];
      final peticiones = await _bd.contarPeticionesPendientes();
      int? ultimaSincronizacion;
      try {
        ultimaSincronizacion = (await SharedPreferences.getInstance())
            .getInt(claveUltimaSincronizacion);
      } catch (_) {
        // Sin preferencias, la cabecera dice «aún sin sincronizar».
      }
      if (!mounted) return;
      setState(() {
        _avisos = avisos;
        _actividad = actividad;
        _tareas = tareas;
        _fincasPorId = {
          for (final finca in fincas)
            if (finca.id != null) finca.id!: finca
        };
        _puntosPorId = {
          for (final punto in puntos)
            if (punto.id != null) punto.id!: punto
        };
        _zonasPorId = {
          for (final zona in zonas)
            if (zona.id != null) zona.id!: zona
        };
        _peticionesPendientes = peticiones;
        _ultimaSincronizacionMs = ultimaSincronizacion;
        _cargando = false;
      });
    } catch (_) {
      // Resumen no crítico: sin BD (p. ej. en tests sin plugins) se muestra
      // vacío en vez de romper la pantalla.
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _refrescar() async {
    await Future.wait([
      sincronizarEspacioEnSilencio(),
      _noticiasSector.actualizar(forzar: true),
      _logosEntidades.actualizar(forzar: true),
      _textosAyuda.actualizar(forzar: true),
    ]);
    await _cargar();
  }

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => pantalla));
    if (mounted) await _cargar();
  }

  Future<void> _marcarHecha(TareaMantenimiento tarea) =>
      marcarTareaHechaDesdeLista(context, tarea, _cargar);

  Future<void> _accionesTarea(TareaMantenimiento tarea) async {
    if (await mostrarAccionesTarea(context, tarea)) await _cargar();
  }

  /// Dónde está la tarea: el punto, la pieza o, si no tiene, la finca.
  String _lugarDeTarea(TareaMantenimiento tarea, String idioma) {
    final punto = tarea.puntoId == null ? null : _puntosPorId[tarea.puntoId];
    if (punto != null) {
      return punto.nombre.isNotEmpty
          ? punto.nombre
          : buscarOpcion(tiposPunto, punto.tipo)?.etiqueta(idioma) ??
              punto.tipo;
    }
    final zona = tarea.zonaId == null ? null : _zonasPorId[tarea.zonaId];
    if (zona != null) {
      return zona.nombre.isNotEmpty
          ? zona.nombre
          : buscarOpcion(tiposZona, zona.tipo)?.etiqueta(idioma) ?? zona.tipo;
    }
    return _fincasPorId[tarea.fincaId]?.nombre ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final politica = politicaEspacioActual;
    final alarmas =
        _avisos.where((aviso) => aviso.esAlarma && aviso.abierto).toList();
    final ahora = DateTime.now();
    final listas = {
      for (final filtro in FiltroTareasHoy.values)
        filtro: tareasDeHoy(_tareas, filtro, ahora, politica),
    };
    final hayMias = !politica.modoLocal;
    final filtro = _filtroElegido ??
        (listas[FiltroTareasHoy.vencidas]!.isNotEmpty
            ? FiltroTareasHoy.vencidas
            : FiltroTareasHoy.semana);
    final tareasVisibles = listas[filtro]!;
    final avisosAbiertos = _avisos.where((aviso) => aviso.abierto).length;

    Widget conMargen(Widget hijo) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16), child: hijo);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Iconos de la barra de estado en claro, sobre la cabecera verde.
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        floatingActionButton: politica.puedeCrearAvisos
            ? FloatingActionButton.extended(
                onPressed: () => _abrir(NuevoAviso(categoria: _categoria)),
                icon: const Icon(Icons.campaign_outlined),
                label: Text(textos.avisoNuevo),
              )
            : null,
        body: RefreshIndicator(
          onRefresh: _refrescar,
          edgeOffset: MediaQuery.paddingOf(context).top,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _CabeceraHoy(
                ultimaSincronizacionMs: _ultimaSincronizacionMs,
                alSincronizar: politica.modoLocal ? null : _refrescar,
                alAbrir: _abrir,
              ),
              if (_cargando)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                const SizedBox(height: 16),
                // Aviso de versión nueva: si no la hay, no ocupa sitio. En el
                // navegador no: la web se actualiza sola con el plugin y el
                // aviso ofrecería descargar el APK.
                if (!kIsWeb)
                  conMargen(AvisoActualizaciones(
                    config: configActualizacionesZunbeltz,
                    nombreApp: textos.appTitulo,
                    traducir: traductorActualizaciones(textos),
                    margen: EdgeInsets.zero,
                  )),
                if (alarmas.isNotEmpty) ...[
                  conMargen(_TituloSeccion(
                      textos.hoyAlarmasAbiertas(alarmas.length))),
                  for (final aviso in alarmas)
                    conMargen(_TarjetaAviso(aviso, alCambiar: _cargar)),
                ],
                conMargen(_TituloSeccion(
                  textos.hoyTareas,
                  accion: TextButton(
                    onPressed: () => _abrir(const TableroTareas()),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(textos.hoyVerTodas),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 20),
                    ]),
                  ),
                )),
                conMargen(Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final opcion in FiltroTareasHoy.values)
                      if (opcion != FiltroTareasHoy.mias || hayMias)
                        FilterChip(
                          label: Text(switch (opcion) {
                            FiltroTareasHoy.vencidas =>
                              textos.hoyFiltroVencidas(listas[opcion]!.length),
                            FiltroTareasHoy.semana =>
                              textos.hoyFiltroSemana(listas[opcion]!.length),
                            FiltroTareasHoy.mias =>
                              textos.hoyFiltroMias(listas[opcion]!.length),
                          }),
                          selected: opcion == filtro,
                          onSelected: (_) =>
                              setState(() => _filtroElegido = opcion),
                        ),
                  ],
                )),
                const SizedBox(height: 12),
                conMargen(_GrupoTarjetas(children: [
                  if (tareasVisibles.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(textos.hoyTareasNinguna,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  for (final tarea in tareasVisibles.take(_tareasVisiblesEnHoy))
                    FilaTarea(
                      tarea: tarea,
                      lugar: _lugarDeTarea(tarea, idioma),
                      alPulsar: () => _accionesTarea(tarea),
                      alMarcarHecha: politicaTareasActual.puedeEjecutar(tarea)
                          ? () => _marcarHecha(tarea)
                          : null,
                    ),
                  if (tareasVisibles.length > _tareasVisiblesEnHoy)
                    ListTile(
                      title: Text(textos.hoyVerTodas,
                          style: TextStyle(
                              color: context.esquemaZunbeltz.primary)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _abrir(const TableroTareas()),
                    ),
                ])),
                if (politica.puedeGestionarPeticiones &&
                    _peticionesPendientes > 0)
                  conMargen(Card(
                    margin: const EdgeInsets.only(top: 12),
                    child: ListTile(
                      leading: const Icon(Icons.forum_outlined),
                      title: Text(textos
                          .hoyPeticionesPendientes(_peticionesPendientes)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _abrir(const PantallaPeticiones()),
                    ),
                  ))
                else if (!politica.modoLocal &&
                    !politica.puedeGestionarPeticiones &&
                    politica.puedeEnviarPeticiones)
                  conMargen(Card(
                    margin: const EdgeInsets.only(top: 12),
                    child: ListTile(
                      leading: const Icon(Icons.add_comment_outlined),
                      title: Text(textos.peticionNueva),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _abrir(const NuevaPeticion()),
                    ),
                  )),
                conMargen(_TituloSeccion(
                  textos.hoyAvisos,
                  accion: Text(textos.hoyAvisosAbiertos(avisosAbiertos),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.esquemaZunbeltz.onSurfaceVariant)),
                )),
                conMargen(_CuadrosCategoriasAviso(
                  seleccionada: _categoria,
                  avisos: _avisos,
                  alElegir: (categoria) =>
                      setState(() => _categoria = categoria),
                )),
                const SizedBox(height: 12),
                if (_avisosDeCategoria().isEmpty)
                  conMargen(Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(textos.avisosVacio),
                  ))
                else
                  for (final aviso in _avisosDeCategoria())
                    conMargen(_TarjetaAviso(aviso, alCambiar: _cargar)),
                if (_categoria == categoriaAvisoNoticias)
                  conMargen(_NoticiasSectorResumidas(
                    // Sin sesión también se ven (el servidor las da sin
                    // token), pero el hueco vacío solo tiene sentido si
                    // hay servidor del que esperarlas.
                    ocultarSiNoHay: politica.modoLocal && !esVersionDemo,
                    alVerTodas: () => _abrir(const PantallaNoticiasSector()),
                  )),
                if (politica.puedeVerActividad && !politica.modoLocal) ...[
                  conMargen(_TituloSeccion(textos.hoyActividad)),
                  if (_actividad.isEmpty)
                    conMargen(Text(textos.hoyActividadVacia))
                  else
                    conMargen(_GrupoTarjetas(children: [
                      for (final entrada in _actividad)
                        ListTile(
                          dense: true,
                          title:
                              Text(describirActividad(entrada, textos, idioma)),
                          subtitle: Text(haceCuanto(
                              textos, entrada.momentoMs, ahora,
                              idioma: idioma)),
                        ),
                    ])),
                ],
                const SizedBox(height: 32),
                _FranjaVerdeEntidades(
                    alPulsar: () => _abrir(const PantallaEntidades())),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<AvisoCampo> _avisosDeCategoria() =>
      _avisos.where((aviso) => aviso.categoria == _categoria).take(20).toList();
}

/// «hace 5 min», «hace 3 h», «ayer», «hace 4 días»; pasada una semana, la
/// fecha.
String haceCuanto(AppLocalizations textos, int momentoMs, DateTime ahora,
    {required String idioma}) {
  final momento = DateTime.fromMillisecondsSinceEpoch(momentoMs);
  final diferencia = ahora.difference(momento);
  if (diferencia.inMinutes < 1) return textos.hoyAhoraMismo;
  if (diferencia.inMinutes < 60) {
    return textos.hoyHaceMinutos(diferencia.inMinutes);
  }
  final dias = DateTime(ahora.year, ahora.month, ahora.day)
      .difference(DateTime(momento.year, momento.month, momento.day))
      .inDays;
  if (dias == 0) return textos.hoyHaceHoras(diferencia.inHours);
  if (dias < 7) return textos.hoyHaceDias(dias);
  return DateFormat('d MMM', idioma).format(momento);
}

String _conMayuscula(String texto) =>
    texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);

/// Cabecera verde: logotipo, título, accesos, la fecha de hoy en grande y
/// una píldora con el estado de la sincronización (tocarla, sincroniza).
class _CabeceraHoy extends StatelessWidget {
  const _CabeceraHoy({
    required this.ultimaSincronizacionMs,
    required this.alSincronizar,
    required this.alAbrir,
  });

  final int? ultimaSincronizacionMs;

  /// `null` sin sincronización (datos solo en este dispositivo).
  final Future<void> Function()? alSincronizar;
  final Future<void> Function(Widget pantalla) alAbrir;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final colores = context.coloresZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final fecha =
        _conMayuscula(DateFormat.MMMMEEEEd(idioma).format(DateTime.now()));
    return Container(
      decoration: BoxDecoration(
        color: colores.cabecera,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding:
          EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 8, 8, 24),
      child: IconTheme(
        data: IconThemeData(color: colores.sobreCabecera),
        child: Column(
          children: [
            Row(children: [
              SimboloZunbeltz(color: colores.sobreCabeceraVariante),
              const SizedBox(width: 12),
              Expanded(
                child: Text(textos.hoyTitulo,
                    style: estilos.headlineSmall
                        ?.copyWith(color: colores.sobreCabecera)),
              ),
              IconButton(
                tooltip: textos.contactosTitulo,
                color: colores.sobreCabecera,
                icon: const Icon(Icons.contacts_outlined),
                onPressed: () => alAbrir(const PantallaContactos()),
              ),
              IconButton(
                tooltip: textos.hoyTiempo,
                color: colores.sobreCabecera,
                icon: const Icon(Icons.cloud_outlined),
                onPressed: () => alAbrir(const PantallaMeteo()),
              ),
              IconButton(
                tooltip: textos.ayudaTitulo,
                color: colores.sobreCabecera,
                icon: const Icon(Icons.help_outline),
                onPressed: () => alAbrir(const PantallaAyuda()),
              ),
            ]),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(fecha,
                    textAlign: TextAlign.center,
                    style: estilos.headlineLarge
                        ?.copyWith(color: colores.sobreCabecera)),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ValueListenableBuilder<bool>(
                valueListenable: sincronizandoEspacio,
                builder: (contexto, sincronizando, _) => _PildoraSincronizacion(
                  sincronizando: sincronizando,
                  ultimaSincronizacionMs: ultimaSincronizacionMs,
                  alPulsar: sincronizando ? null : alSincronizar,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PildoraSincronizacion extends StatelessWidget {
  const _PildoraSincronizacion({
    required this.sincronizando,
    required this.ultimaSincronizacionMs,
    required this.alPulsar,
  });

  final bool sincronizando;
  final int? ultimaSincronizacionMs;
  final Future<void> Function()? alPulsar;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final colores = context.coloresZunbeltz;
    final ultima = ultimaSincronizacionMs;
    final sinServidor = alPulsar == null && !sincronizando;
    final (IconData icono, String texto) = switch (()) {
      _ when sincronizando => (Icons.sync, textos.hoySincronizando),
      _ when sinServidor => (
          Icons.phone_android_outlined,
          textos.hoySoloEnEsteDispositivo
        ),
      _ when ultima == null => (
          Icons.cloud_off_outlined,
          textos.hoySinSincronizar
        ),
      _ => (
          Icons.cloud_done_outlined,
          textos.hoySincronizado(
              haceCuanto(textos, ultima, DateTime.now(), idioma: idioma))
        ),
    };
    return Material(
      color: colores.sobreCabecera.withValues(alpha: 0.08),
      shape: StadiumBorder(
        side: BorderSide(
            color: colores.sobreCabeceraVariante.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: alPulsar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (sincronizando)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: colores.sobreCabecera),
              )
            else
              Icon(icono, size: 20, color: colores.sobreCabecera),
            const SizedBox(width: 8),
            Flexible(
              child: Text(texto,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colores.sobreCabecera)),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Título de sección (Poppins) con una acción opcional a la derecha.
class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion(this.titulo, {this.accion});
  final String titulo;
  final Widget? accion;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 28, 0, 10),
        child: Row(children: [
          Expanded(
            child: Text(titulo, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (accion != null) accion!,
        ]),
      );
}

/// Lista agrupada: un bloque de 16 px de radio con separadores finos.
class _GrupoTarjetas extends StatelessWidget {
  const _GrupoTarjetas({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquemaZunbeltz;
    return Material(
      color: esquema.surfaceContainerLow,
      borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        for (var indice = 0; indice < children.length; indice++) ...[
          if (indice > 0)
            Divider(indent: 16, endIndent: 16, color: esquema.outlineVariant),
          children[indice],
        ],
      ]),
    );
  }
}

/// Las cuatro categorías de avisos como los cuatro cuadros del logotipo:
/// 2 × 2 en el móvil, las cuatro en fila si hay sitio. Cada una con su
/// color, el número de avisos abiertos (en rojo si hay alguna alarma) y,
/// la elegida, en blanco con el borde esmeralda.
class _CuadrosCategoriasAviso extends StatelessWidget {
  const _CuadrosCategoriasAviso({
    required this.seleccionada,
    required this.avisos,
    required this.alElegir,
  });

  final String seleccionada;
  final List<AvisoCampo> avisos;
  final ValueChanged<String> alElegir;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return LayoutBuilder(builder: (contexto, limites) {
      const separacion = 8.0;
      final columnas = limites.maxWidth >= 560 ? 4 : 2;
      Widget cuadro(int indice) {
        final categoria = _ordenCategoriasHoy[indice];
        return _CuadroCategoriaAviso(
          etiqueta: etiquetaCategoriaAviso(categoria, textos),
          icono: iconoCategoriaAviso(categoria),
          categoria: categoria,
          borde: indice.isEven
              ? bordeDestacadoZunbeltz
              : bordeDestacadoEspejoZunbeltz,
          abiertos: avisos
              .where((aviso) => aviso.categoria == categoria && aviso.abierto)
              .length,
          hayAlarma: avisos.any((aviso) =>
              aviso.categoria == categoria &&
              aviso.abierto &&
              aviso.gravedad == gravedadAlarma),
          seleccionada: categoria == seleccionada,
          alPulsar: () => alElegir(categoria),
        );
      }

      // Por filas y no con Wrap: los cuadros de una fila, de igual alto.
      return Column(children: [
        for (var inicio = 0;
            inicio < _ordenCategoriasHoy.length;
            inicio += columnas) ...[
          if (inicio > 0) const SizedBox(height: separacion),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var indice = inicio;
                    indice < inicio + columnas;
                    indice++) ...[
                  if (indice > inicio) const SizedBox(width: separacion),
                  Expanded(
                    child: indice < _ordenCategoriasHoy.length
                        ? cuadro(indice)
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ]);
    });
  }
}

/// Fondo y texto de cada categoría: los cuadros del logotipo.
(Color fondo, Color texto) _coloresCuadro(String categoria) =>
    switch (categoria) {
      categoriaAvisoSeguimiento => (colorCuadroPino, colorSobreCuadroOscuro),
      categoriaAvisoNoticias => (colorCuadroHoja, colorSobreCuadroClaro),
      categoriaAvisoInstalaciones => (
          colorCuadroEsmeralda,
          colorSobreCuadroClaro
        ),
      _ => (colorCuadroSalvia, colorSobreCuadroClaro),
    };

class _CuadroCategoriaAviso extends StatelessWidget {
  const _CuadroCategoriaAviso({
    required this.etiqueta,
    required this.icono,
    required this.categoria,
    required this.borde,
    required this.abiertos,
    required this.hayAlarma,
    required this.seleccionada,
    required this.alPulsar,
  });

  final String etiqueta;
  final IconData icono;
  final String categoria;
  final BorderRadius borde;
  final int abiertos;
  final bool hayAlarma;
  final bool seleccionada;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquemaZunbeltz;
    final (fondoCategoria, textoCategoria) = _coloresCuadro(categoria);
    final fondo = seleccionada ? esquema.surface : fondoCategoria;
    final texto = seleccionada ? esquema.onSurface : textoCategoria;
    return Semantics(
      button: true,
      selected: seleccionada,
      label: abiertos == 0 ? etiqueta : '$etiqueta, $abiertos',
      excludeSemantics: true,
      child: Material(
        color: fondo,
        shape: RoundedRectangleBorder(
          borderRadius: borde,
          side: seleccionada
              ? const BorderSide(color: colorCuadroEsmeralda, width: 3)
              : BorderSide.none,
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(borderRadius: borde),
          onTap: alPulsar,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 108),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(icono, size: 30, color: texto),
                    const Spacer(),
                    if (abiertos > 0)
                      _ContadorAvisos(
                        cuenta: abiertos,
                        hayAlarma: hayAlarma,
                        // Sobre el pino, el contador en claro.
                        claro: !seleccionada &&
                            textoCategoria == colorSobreCuadroOscuro,
                      ),
                  ]),
                  const SizedBox(height: 16),
                  Text(
                    etiqueta,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: texto, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Número de avisos abiertos; con una alarma abierta, en rojo.
class _ContadorAvisos extends StatelessWidget {
  const _ContadorAvisos({
    required this.cuenta,
    required this.hayAlarma,
    required this.claro,
  });

  final int cuenta;
  final bool hayAlarma;
  final bool claro;

  @override
  Widget build(BuildContext context) {
    final Color fondo;
    final Color texto;
    if (hayAlarma) {
      fondo = colorSenalZunbeltz;
      texto = Colors.white;
    } else if (claro) {
      fondo = colorSobreCuadroOscuro;
      texto = colorSobreCuadroClaro;
    } else {
      fondo = colorSobreCuadroClaro;
      texto = colorSobreCuadroOscuro;
    }
    return Container(
      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: Alignment.center,
      child: Text(
        '$cuenta',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: texto, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Las primeras noticias del sector y el acceso a todas.
class _NoticiasSectorResumidas extends StatelessWidget {
  const _NoticiasSectorResumidas(
      {required this.alVerTodas, required this.ocultarSiNoHay});

  static const _cuantasSeVen = 3;

  final VoidCallback alVerTodas;
  final bool ocultarSiNoHay;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return ValueListenableBuilder<NoticiasSectorGuardadas>(
      valueListenable: ServicioNoticiasSector.actuales,
      builder: (contexto, guardadas, _) {
        final noticias = guardadas.noticias;
        if (noticias.isEmpty && ocultarSiNoHay) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TituloSeccion(textos.noticiasSectorTitulo),
            if (noticias.isEmpty)
              Text(textos.noticiasSectorVacio)
            else ...[
              for (final noticia in noticias.take(_cuantasSeVen))
                TarjetaNoticiaSector(noticia),
              if (noticias.length > _cuantasSeVen)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: alVerTodas,
                    child: Text(textos.noticiasSectorVerTodas(noticias.length)),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

/// Un aviso: quién y cuándo, el título y el principio del texto. Una alarma
/// abierta va en rojo.
class _TarjetaAviso extends StatelessWidget {
  const _TarjetaAviso(this.aviso, {required this.alCambiar});

  final AvisoCampo aviso;
  final Future<void> Function() alCambiar;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final colores = context.coloresZunbeltz;
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final alarmaAbierta = aviso.esAlarma && aviso.abierto;
    final colorDetalle =
        alarmaAbierta ? colores.bloqueada : esquema.onSurfaceVariant;
    final cabecera = [
      nombrePersonaEspacio(aviso.autorUid) ?? '',
      if (aviso.fechaMs > 0)
        haceCuanto(textos, aviso.fechaMs, DateTime.now(), idioma: idioma),
      if (!aviso.abierto) textos.avisoResuelto,
    ].where((parte) => parte.isNotEmpty).join(' · ');
    return Card(
      color: alarmaAbierta ? colores.fondoBloqueada : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
        onTap: () async {
          if (await mostrarFichaAviso(context, aviso)) await alCambiar();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(iconoCategoriaAviso(aviso.categoria),
                        size: 18, color: colorDetalle),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(cabecera,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              estilos.bodySmall?.copyWith(color: colorDetalle)),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(aviso.titulo,
                      style: estilos.titleMedium?.copyWith(
                          decoration: aviso.abierto
                              ? null
                              : TextDecoration.lineThrough)),
                  if (aviso.descripcion.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(aviso.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: estilos.bodyMedium
                            ?.copyWith(color: esquema.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
            if (alarmaAbierta)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Icon(Icons.notification_important,
                    color: colores.bloqueada),
              ),
          ]),
        ),
      ),
    );
  }
}

/// El pie de Hoy: banda verde a todo lo ancho con los logos en claro.
class _FranjaVerdeEntidades extends StatelessWidget {
  const _FranjaVerdeEntidades({required this.alPulsar});
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresZunbeltz;
    return ValueListenableBuilder<List<EntidadColaboradora>>(
      valueListenable: ServicioLogosEntidades.actuales,
      builder: (contexto, entidades, _) {
        if (entidades.isEmpty) return const SizedBox(height: 96);
        return Container(
          color: colores.cabecera,
          // Abajo, sitio para que el botón flotante no tape los logos.
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          child: FranjaLogosEntidades(
            alPulsar: alPulsar,
            colorTinta: colores.sobreCabecera,
            colorRotulo: colores.sobreCabeceraVariante,
          ),
        );
      },
    );
  }
}
