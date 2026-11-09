import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../branding.dart';
import '../estado/ajustes_sincronizacion.dart';
import '../estado/coordinador.dart';
import '../servicios/documento_generado.dart';
import '../servicios/exportador_espacio.dart';
import '../estado/idioma_app.dart';
import '../estado/sesion_espacio.dart';
import '../estado/tema_app.dart';
import '../modelos/persona_espacio.dart';
import '../l10n/app_localizations.dart';
import '../utiles/traductor_actualizaciones.dart';
import 'pantalla_acerca_espacio_test.dart';
import 'pantalla_entidades.dart';
import 'pantalla_mapa_sin_cobertura.dart';
import 'pantalla_ayuda.dart';
import 'pantalla_inicio.dart' show haceCuanto;
import 'pantalla_sincronizacion.dart';
import 'widgets/relleno_seguro.dart';
import 'widgets/liberar_al_cerrar.dart';

/// Versión visible de la app. Se mantiene a mano sincronizada con `version`
/// del `pubspec.yaml` (campo antes del `+`); `test/version_app_test.dart`
/// falla si no coinciden.
const String versionAppZunbeltz = '0.9.3';

/// Pestaña «Ajustes»: arriba, quién es y cómo va la sincronización; luego
/// preferencias, datos y cuenta, y lo de la app.
class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  String _coordinador = '';
  String _syncUrl = '';
  String _syncToken = '';
  bool _sincronizando = false;
  int? _ultimaMs;

  bool get _configurado => _syncUrl.isNotEmpty && _syncToken.isNotEmpty;

  @override
  void initState() {
    super.initState();
    Coordinador.cargarCorreo().then((correo) {
      if (mounted) setState(() => _coordinador = correo);
    });
    _cargarSincronizacion();
  }

  Future<void> _cargarSincronizacion() async {
    final url = await AjustesSincronizacion.cargarUrl();
    final token = await AjustesSincronizacion.cargarToken();
    final ultima = await leerUltimaSincronizacion();
    if (!mounted) return;
    setState(() {
      _syncUrl = url;
      _syncToken = token;
      _ultimaMs = ultima;
    });
  }

  Future<void> _cambiarIdioma(String codigo) async {
    await elegirIdiomaZunbeltz(codigo);
    if (mounted) setState(() {});
  }

  Future<void> _elegirTema() async {
    final textos = AppLocalizations.of(context);
    final elegido = await showDialog<ThemeMode>(
      context: context,
      builder: (contexto) => SimpleDialog(
        title: Text(textos.ajuTema),
        children: [
          // Filas y no botones de radio: tocar la opción ya elegida
          // también tiene que cerrar el diálogo.
          for (final (tema, etiqueta) in [
            (ThemeMode.system, textos.ajuTemaSistema),
            (ThemeMode.light, textos.ajuTemaClaro),
            (ThemeMode.dark, textos.ajuTemaOscuro),
          ])
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(temaAppZunbeltz.value == tema
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked),
              title: Text(etiqueta),
              onTap: () => Navigator.pop(contexto, tema),
            ),
        ],
      ),
    );
    if (elegido != null) await elegirTemaZunbeltz(elegido);
    if (mounted) setState(() {});
  }

  Future<void> _exportarEspacio() async {
    final documentos = await exportarEspacioCsv();
    if (!mounted) return;
    try {
      await compartirDocumentos(documentos,
          asunto: 'Espacio Larrea Zunbeltz (CSV)');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(documentos
                .map((documento) => documento.nombreFichero)
                .join('\n'))));
      }
    }
  }

  Future<void> _editarCoordinador() async {
    final textos = AppLocalizations.of(context);
    final controlador = TextEditingController(text: _coordinador);
    final correo = await showDialog<String>(
      context: context,
      builder: (ctx) => LiberarAlCerrar(
        controladores: [controlador],
        child: AlertDialog(
          title: Text(textos.ajustesCoordinador),
          content: TextField(
            controller: controlador,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: textos.coordinadorCorreo),
            autofocus: true,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(textos.comunCancelar)),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, controlador.text.trim()),
                child: Text(textos.comunGuardar)),
          ],
        ),
      ),
    );
    if (correo == null) return;
    await Coordinador.guardarCorreo(correo);
    if (mounted) setState(() => _coordinador = correo);
  }

  Future<void> _sincronizarAhora() async {
    setState(() => _sincronizando = true);
    await sincronizarConAviso(context);
    final ultima = await leerUltimaSincronizacion();
    if (mounted) {
      setState(() {
        _ultimaMs = ultima;
        _sincronizando = false;
      });
    }
  }

  Future<void> _ir(Widget pantalla) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => pantalla));
    await _cargarSincronizacion();
  }

  /// Cabecera verde: la persona, su rol y la tarjeta de sincronización.
  Widget _cabecera(AppLocalizations textos, String idioma) {
    final colores = context.coloresZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final ultima = _ultimaMs;
    final relleno = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, relleno + 20, 20, 24),
      decoration: BoxDecoration(
        color: colores.cabecera,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: ValueListenableBuilder<SesionEspacio?>(
        valueListenable: sesionEspacio,
        builder: (contexto, sesion, _) {
          final nombre = sesion?.persona.nombre ?? '';
          final palabras =
              nombre.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
          final iniciales = palabras.isEmpty
              ? null
              : palabras.take(2).map((p) => p[0].toUpperCase()).join();
          final (IconData icono, String titulo, String detalle) = switch (()) {
            _ when !_configurado => (
                Icons.phone_android_outlined,
                textos.ajustesSesionLocal,
                textos.ajuNadaPorSincronizar
              ),
            _ when _sincronizando => (
                Icons.sync,
                textos.hoySincronizando,
                _syncUrl
              ),
            _ when ultima == null => (
                Icons.cloud_off_outlined,
                textos.hoySinSincronizar,
                _syncUrl
              ),
            _ => (
                Icons.cloud_done_outlined,
                textos.hoySincronizado(
                    haceCuanto(textos, ultima, DateTime.now(), idioma: idioma)),
                _syncUrl.replaceFirst(RegExp(r'^https?://'), '')
              ),
          };
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(textos.navAjustes,
                    style: estilos.headlineMedium
                        ?.copyWith(color: colores.sobreCabecera)),
                const SizedBox(height: 18),
                Row(children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: colorCuadroSalvia,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(26),
                      ),
                    ),
                    child: iniciales == null
                        ? const Icon(Icons.person_outline,
                            size: 32, color: colorSobreCuadroClaro)
                        : Text(iniciales,
                            style: estilos.titleLarge?.copyWith(
                                color: colorSobreCuadroClaro,
                                fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            nombre.isEmpty ? textos.ajustesSesionLocal : nombre,
                            style: estilos.titleLarge
                                ?.copyWith(color: colores.sobreCabecera)),
                        if (sesion != null)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  colores.sobreCabecera.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(sesion.persona.etiquetaRol,
                                style: estilos.labelLarge
                                    ?.copyWith(color: colores.sobreCabecera)),
                          ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                Material(
                  color: colores.sobreCabecera.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color: colores.sobreCabeceraVariante
                            .withValues(alpha: 0.3)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _ir(const PantallaSincronizacion()),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                      child: Row(children: [
                        Icon(icono, color: colores.sobreCabecera),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(titulo,
                                  style: estilos.titleSmall?.copyWith(
                                      color: colores.sobreCabecera,
                                      fontWeight: FontWeight.w600)),
                              if (detalle.isNotEmpty)
                                Text(detalle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: estilos.bodySmall?.copyWith(
                                        color: colores.sobreCabeceraVariante)),
                            ],
                          ),
                        ),
                        if (_configurado) ...[
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                                backgroundColor: colorCuadroSalvia,
                                foregroundColor: colorSobreCuadroClaro),
                            onPressed:
                                _sincronizando ? null : _sincronizarAhora,
                            icon: const Icon(Icons.sync, size: 20),
                            label: Text(textos.ajuAhora),
                          ),
                        ],
                      ]),
                    ),
                  ),
                ),
              ]);
        },
      ),
    );
  }

  Widget _grupo(String titulo, List<Widget> filas) {
    final esquema = context.esquemaZunbeltz;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
        child: Text(titulo,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: esquema.primary, fontWeight: FontWeight.w600)),
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: esquema.surfaceContainerLow,
          borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          for (var indice = 0; indice < filas.length; indice++) ...[
            if (indice > 0)
              Divider(
                  height: 1,
                  indent: 72,
                  endIndent: 16,
                  color: esquema.outlineVariant),
            filas[indice],
          ],
        ]),
      ),
    ]);
  }

  Widget _fila(IconData icono, String titulo,
          {String? detalle,
          Color? colorDetalle,
          Widget? final_,
          VoidCallback? alPulsar}) =>
      ListTile(
        contentPadding: const EdgeInsets.fromLTRB(20, 6, 16, 6),
        leading: Icon(icono),
        title: Text(titulo),
        subtitle: detalle == null
            ? null
            : Text(detalle,
                style: colorDetalle == null
                    ? null
                    : TextStyle(
                        color: colorDetalle, fontWeight: FontWeight.w600)),
        trailing: final_ ??
            (alPulsar == null ? null : const Icon(Icons.chevron_right)),
        onTap: alPulsar,
      );

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final localeActivo = Localizations.localeOf(context).languageCode;
    final estilos = Theme.of(context).textTheme;
    final esquema = context.esquemaZunbeltz;
    final tema = switch (temaAppZunbeltz.value) {
      ThemeMode.light => textos.ajuTemaClaro,
      ThemeMode.dark => textos.ajuTemaOscuro,
      ThemeMode.system => textos.ajuTemaSistema,
    };
    // Iconos de la barra de estado en claro, sobre la cabecera verde.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            _cabecera(textos, localeActivo),
            _grupo(textos.ajuPreferencias, [
              _fila(
                Icons.translate_outlined,
                textos.ajustesIdioma,
                detalle: localeActivo == 'eu'
                    ? textos.ajustesIdiomaEuskera
                    : textos.ajustesIdiomaCastellano,
                final_: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'es', label: Text('ES')),
                    ButtonSegment(value: 'eu', label: Text('EU')),
                  ],
                  selected: {localeActivo},
                  onSelectionChanged: (elegidos) =>
                      _cambiarIdioma(elegidos.first),
                ),
              ),
              _fila(Icons.contrast, textos.ajuTema,
                  detalle: tema, alPulsar: _elegirTema),
            ]),
            _grupo(textos.ajuDatosCuenta, [
              _fila(Icons.sync_alt, textos.ajuSyncCuenta,
                  detalle: textos.ajuSyncCuentaDetalle,
                  alPulsar: () => _ir(const PantallaSincronizacion())),
              _fila(Icons.outgoing_mail, textos.ajustesCoordinador,
                  detalle: _coordinador.isEmpty
                      ? textos.ajustesCoordinadorVacio
                      : _coordinador,
                  alPulsar: _editarCoordinador),
              _fila(Icons.upload_file_outlined, textos.ajustesExportarEspacio,
                  final_: const Icon(Icons.ios_share),
                  alPulsar: _exportarEspacio),
              if (!kIsWeb)
                _fila(Icons.cloud_download_outlined, textos.mapaSinCobertura,
                    detalle: textos.mapaCallejeroSoloVisto,
                    alPulsar: () => _ir(const PantallaMapaSinCobertura())),
            ]),
            _grupo(textos.ajuLaApp, [
              _fila(Icons.help_outline, textos.ayudaTitulo,
                  detalle: textos.ajuAyudaDetalle,
                  alPulsar: () => _ir(const PantallaAyuda())),
              // En el navegador la app se actualiza sola con el plugin:
              // las releases de GitHub (el APK) no son para ella.
              if (!kIsWeb)
                _fila(
                    Icons.system_update_outlined, textos.actualizacionesTitulo,
                    detalle: textos.ajustesActualizacionesSubtitulo,
                    alPulsar: () => _ir(PantallaEstadoActualizaciones(
                          config: configActualizacionesZunbeltz,
                          nombreApp: textos.appTitulo,
                          traducir: traductorActualizaciones(textos),
                        ))),
              _fila(Icons.landscape_outlined, textos.acercaTitulo,
                  alPulsar: () => _ir(const PantallaAcercaEspacioTest())),
              _fila(Icons.handshake_outlined, textos.entidadesTitulo,
                  alPulsar: () => _ir(const PantallaEntidades())),
            ]),
            Padding(
              padding: rellenoSobreBarraSistema(
                  context, const EdgeInsets.fromLTRB(20, 28, 20, 28)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${textos.appTitulo} $versionAppZunbeltz',
                      style: estilos.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(textos.ajustesProvisional,
                      style: estilos.bodySmall
                          ?.copyWith(color: esquema.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
