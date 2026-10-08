import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/datos_notificador.dart';
import '../estado/sesion_espacio.dart';
import '../estado/version_demo.dart';
import '../l10n/app_localizations.dart';
import '../modelos/aviso_campo.dart';
import '../modelos/entrada_actividad.dart';
import '../servicios/resumen_notificaciones.dart';
import '../servicios/servicio_noticias_sector.dart';
import '../servicios/servicio_sincronizacion.dart';
import '../utiles/descripcion_actividad.dart';
import '../utiles/estilo_aviso.dart';
import '../utiles/traductor_actualizaciones.dart';
import 'nueva_peticion.dart';
import 'nuevo_aviso.dart';
import 'pantalla_ayuda.dart';
import 'pantalla_contactos.dart';
import 'pantalla_meteo.dart';
import 'pantalla_noticias_sector.dart';
import 'pantalla_peticiones.dart';
import 'tablero_tareas.dart';
import 'widgets/ficha_aviso.dart';

/// Pestaña «Hoy»: la bandeja del espacio. Arriba las alarmas abiertas;
/// luego las tareas (vencidas y próximas), las peticiones, los avisos por
/// categoría (ganado, instalaciones, seguimiento individual, noticias) y,
/// para coordinación, lo último que ha pasado en el espacio. En Noticias,
/// debajo de lo que publica coordinación, van las noticias del sector (los
/// canales RSS del panel).
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final _bd = BaseDatosSoleraZunbeltz();
  final _noticiasSector = ServicioNoticiasSector();
  List<AvisoCampo> _avisos = const [];
  List<EntradaActividad> _actividad = const [];
  int _vencidas = 0;
  int _proximas = 0;
  int _peticionesPendientes = 0;
  String _categoria = categoriaAvisoGanado;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
    _noticiasSector.actualizar();
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
      final ahora = DateTime.now();
      final avisos = await _bd.listarAvisos();
      final actividad = politica.puedeVerActividad
          ? await _bd.listarActividadEspacio(limite: 15)
          : const <EntradaActividad>[];
      final peticiones = await _bd.contarPeticionesPendientes();
      if (!mounted) return;
      setState(() {
        _avisos = avisos;
        _actividad = actividad;
        _vencidas = contarTareasVencidas(tareas, ahora, politica);
        _proximas = contarTareasProximas(tareas, ahora);
        _peticionesPendientes = peticiones;
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
    ]);
    await _cargar();
  }

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => pantalla));
    if (mounted) await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final politica = politicaEspacioActual;
    final alarmas =
        _avisos.where((aviso) => aviso.esAlarma && aviso.abierto).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(textos.hoyTitulo),
        actions: [
          if (!politica.modoLocal)
            ValueListenableBuilder<bool>(
              valueListenable: sincronizandoEspacio,
              builder: (contexto, sincronizando, _) => IconButton(
                tooltip: textos.ajustesSyncAhora,
                icon: sincronizando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.sync),
                onPressed: sincronizando ? null : _refrescar,
              ),
            ),
          IconButton(
            tooltip: textos.contactosTitulo,
            icon: const Icon(Icons.contacts_outlined),
            onPressed: () => _abrir(const PantallaContactos()),
          ),
          IconButton(
            tooltip: textos.hoyTiempo,
            icon: const Icon(Icons.cloud_outlined),
            onPressed: () => _abrir(const PantallaMeteo()),
          ),
          IconButton(
            tooltip: textos.ayudaTitulo,
            icon: const Icon(Icons.help_outline),
            onPressed: () => _abrir(const PantallaAyuda()),
          ),
        ],
      ),
      floatingActionButton: politica.puedeCrearAvisos
          ? FloatingActionButton.extended(
              onPressed: () => _abrir(NuevoAviso(categoria: _categoria)),
              icon: const Icon(Icons.campaign_outlined),
              label: Text(textos.avisoNuevo),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _refrescar,
        child: _cargando
            ? ListView(children: const [
                SizedBox(height: 120),
                Center(child: CircularProgressIndicator()),
              ])
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  // Aviso de versión nueva: si no la hay, no ocupa sitio.
                  AvisoActualizaciones(
                    config: configActualizacionesZunbeltz,
                    nombreApp: textos.appTitulo,
                    traducir: traductorActualizaciones(textos),
                    margen: EdgeInsets.zero,
                  ),
                  if (alarmas.isNotEmpty) ...[
                    _Seccion(textos.hoyAlarmasAbiertas(alarmas.length)),
                    for (final aviso in alarmas)
                      _TarjetaAviso(aviso, alCambiar: _cargar),
                  ],
                  _Seccion(textos.hoyTareas),
                  Card(
                    child: Column(children: [
                      ListTile(
                        leading: Icon(Icons.event_busy_outlined,
                            color: _vencidas > 0 ? colorSenalZunbeltz : null),
                        title: Text(textos.hoyTareasVencidas(_vencidas)),
                        subtitle: Text(textos.hoyTareasProximas(_proximas)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _abrir(const TableroTareas()),
                      ),
                      if (politica.puedeGestionarPeticiones &&
                          _peticionesPendientes > 0)
                        ListTile(
                          leading: const Icon(Icons.forum_outlined),
                          title: Text(textos
                              .hoyPeticionesPendientes(_peticionesPendientes)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _abrir(const PantallaPeticiones()),
                        )
                      else if (!politica.modoLocal &&
                          !politica.puedeGestionarPeticiones &&
                          politica.puedeEnviarPeticiones)
                        ListTile(
                          leading: const Icon(Icons.add_comment_outlined),
                          title: Text(textos.peticionNueva),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _abrir(const NuevaPeticion()),
                        ),
                    ]),
                  ),
                  _Seccion(textos.hoyAvisos),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      for (final categoria in categoriasAviso)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            avatar:
                                Icon(iconoCategoriaAviso(categoria), size: 18),
                            label: Text(_etiquetaConCuenta(categoria, textos)),
                            selected: _categoria == categoria,
                            onSelected: (_) =>
                                setState(() => _categoria = categoria),
                          ),
                        ),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  ..._avisosDeCategoria().isEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(textos.avisosVacio),
                          )
                        ]
                      : [
                          for (final aviso in _avisosDeCategoria())
                            _TarjetaAviso(aviso, alCambiar: _cargar),
                        ],
                  if (_categoria == categoriaAvisoNoticias &&
                      (!politica.modoLocal || esVersionDemo))
                    _NoticiasSectorResumidas(
                      alVerTodas: () => _abrir(const PantallaNoticiasSector()),
                    ),
                  if (politica.puedeVerActividad && !politica.modoLocal) ...[
                    _Seccion(textos.hoyActividad),
                    if (_actividad.isEmpty)
                      Text(textos.hoyActividadVacia)
                    else
                      Card(
                        child: Column(children: [
                          for (final entrada in _actividad)
                            ListTile(
                              dense: true,
                              title: Text(
                                  describirActividad(entrada, textos, idioma)),
                              subtitle: Text(DateFormat('dd/MM HH:mm', idioma)
                                  .format(DateTime.fromMillisecondsSinceEpoch(
                                      entrada.momentoMs))),
                            ),
                        ]),
                      ),
                  ],
                ],
              ),
      ),
    );
  }

  List<AvisoCampo> _avisosDeCategoria() =>
      _avisos.where((aviso) => aviso.categoria == _categoria).take(20).toList();

  String _etiquetaConCuenta(String categoria, AppLocalizations textos) {
    final abiertos = _avisos
        .where((aviso) => aviso.categoria == categoria && aviso.abierto)
        .length;
    final etiqueta = etiquetaCategoriaAviso(categoria, textos);
    return abiertos == 0 ? etiqueta : '$etiqueta ($abiertos)';
  }
}

/// Las primeras noticias del sector y el acceso a todas.
class _NoticiasSectorResumidas extends StatelessWidget {
  const _NoticiasSectorResumidas({required this.alVerTodas});

  static const _cuantasSeVen = 3;

  final VoidCallback alVerTodas;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return ValueListenableBuilder<NoticiasSectorGuardadas>(
      valueListenable: ServicioNoticiasSector.actuales,
      builder: (contexto, guardadas, _) {
        final noticias = guardadas.noticias;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Seccion(textos.noticiasSectorTitulo),
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

class _Seccion extends StatelessWidget {
  const _Seccion(this.titulo);
  final String titulo;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
        child: Text(titulo, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _TarjetaAviso extends StatelessWidget {
  const _TarjetaAviso(this.aviso, {required this.alCambiar});

  final AvisoCampo aviso;
  final Future<void> Function() alCambiar;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final color = aviso.esAlarma && aviso.abierto ? colorSenalZunbeltz : null;
    return Card(
      child: ListTile(
        leading: Icon(iconoCategoriaAviso(aviso.categoria), color: color),
        title: Text(aviso.titulo,
            style: TextStyle(
                decoration: aviso.abierto ? null : TextDecoration.lineThrough)),
        subtitle: Text([
          nombrePersonaEspacio(aviso.autorUid) ?? '',
          if (aviso.fechaMs > 0)
            DateFormat('dd/MM HH:mm', idioma)
                .format(DateTime.fromMillisecondsSinceEpoch(aviso.fechaMs)),
          if (!aviso.abierto) textos.avisoResuelto,
        ].where((parte) => parte.isNotEmpty).join(' · ')),
        trailing: aviso.esAlarma && aviso.abierto
            ? Icon(Icons.notification_important, color: color)
            : null,
        onTap: () async {
          if (await mostrarFichaAviso(context, aviso)) await alCambiar();
        },
      ),
    );
  }
}
