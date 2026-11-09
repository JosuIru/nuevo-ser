import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/ajustes_sincronizacion.dart';
import '../estado/datos_notificador.dart';
import '../estado/sesion_espacio.dart';
import '../estado/version_demo.dart';
import '../l10n/app_localizations.dart';
import '../modelos/persona_espacio.dart';
import '../servicios/cliente_sync_zunbeltz.dart';
import '../servicios/servicio_logos_entidades.dart';
import '../servicios/servicio_noticias_sector.dart';
import '../servicios/servicio_sincronizacion.dart';
import '../servicios/servicio_textos_ayuda.dart';
import '../servicios/sincronizacion_segundo_plano.dart'
    show claveUltimaSincronizacion;
import '../utiles/texto_error_sync.dart';
import 'pantalla_inicio.dart' show haceCuanto;
import 'widgets/avisos_push_web.dart';
import 'widgets/liberar_al_cerrar.dart';
import 'widgets/relleno_seguro.dart';

/// Sincroniza el espacio y cuenta el resultado en un aviso. Devuelve
/// `false` si no se hizo (otra sincronización tenía el candado).
Future<bool> sincronizarConAviso(BuildContext context,
    {bool completa = false}) async {
  final textos = AppLocalizations.of(context);
  final mensajero = ScaffoldMessenger.of(context);
  try {
    final resultado = await sincronizarEspacio(completa: completa);
    if (resultado == null) {
      // Otra sincronización (la automática) tiene el candado: que la
      // completa pedida no se pierda, y decirlo.
      if (completa) {
        await BaseDatosSoleraZunbeltz().pedirSincronizacionCompleta();
      }
      mensajero
          .showSnackBar(SnackBar(content: Text(textos.ajustesSyncOcupado)));
      return false;
    }
    final resumen = textos.ajustesSyncResultado(
        resultado.subidas + resultado.entidadesSubidas,
        resultado.bajadas + resultado.entidadesBajadas,
        resultado.retiradas);
    mensajero.showSnackBar(SnackBar(
        content: Text(resultado.rechazadasPorPermisos == 0
            ? resumen
            : '$resumen\n${textos.ajustesSyncRechazadas(resultado.rechazadasPorPermisos)}')));
    return true;
  } catch (error) {
    mensajero
        .showSnackBar(SnackBar(content: Text(textoErrorSync(error, textos))));
    return false;
  }
}

/// Hora de la última sincronización (null si nunca).
Future<int?> leerUltimaSincronizacion() async {
  try {
    return (await SharedPreferences.getInstance())
        .getInt(claveUltimaSincronizacion);
  } catch (_) {
    return null;
  }
}

/// Estado de la sincronización, la cuenta (clave de usuario y sesión), el
/// servidor y la sincronización completa.
class PantallaSincronizacion extends StatefulWidget {
  const PantallaSincronizacion({super.key});

  @override
  State<PantallaSincronizacion> createState() => _PantallaSincronizacionState();
}

class _PantallaSincronizacionState extends State<PantallaSincronizacion> {
  String _syncUrl = '';
  String _syncToken = '';
  bool _sincronizando = false;
  bool _verClave = false;
  int? _ultimaMs;

  bool get _configurado => _syncUrl.isNotEmpty && _syncToken.isNotEmpty;

  @override
  void initState() {
    super.initState();
    AjustesSincronizacion.cargarUrl().then((url) {
      if (mounted) setState(() => _syncUrl = url);
    });
    AjustesSincronizacion.cargarToken().then((token) {
      if (mounted) setState(() => _syncToken = token);
    });
    _leerUltima();
  }

  Future<void> _leerUltima() async {
    final ultima = await leerUltimaSincronizacion();
    if (mounted) setState(() => _ultimaMs = ultima);
  }

  Future<String?> _pedirTexto(String titulo, String actual,
      {TextInputType? teclado, String? pista}) {
    final textos = AppLocalizations.of(context);
    final controlador = TextEditingController(text: actual);
    return showDialog<String>(
      context: context,
      builder: (contexto) => LiberarAlCerrar(
        controladores: [controlador],
        child: AlertDialog(
          title: Text(titulo),
          content: TextField(
            controller: controlador,
            keyboardType: teclado,
            decoration: InputDecoration(hintText: pista),
            autofocus: true,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(contexto),
                child: Text(textos.comunCancelar)),
            FilledButton(
                onPressed: () =>
                    Navigator.pop(contexto, controlador.text.trim()),
                child: Text(textos.comunGuardar)),
          ],
        ),
      ),
    );
  }

  Future<void> _editarSyncUrl() async {
    final textos = AppLocalizations.of(context);
    final url = await _pedirTexto(textos.ajustesSyncUrl, _syncUrl,
        teclado: TextInputType.url, pista: 'https://tuwordpress.org');
    if (url == null || url == _syncUrl) return;
    final descartar = await _confirmarDescarteModoLocal(url, _syncToken);
    if (descartar == null) return;
    await AjustesSincronizacion.guardarUrl(url);
    if (mounted) setState(() => _syncUrl = url);
    await _conectar(descartado: descartar);
  }

  Future<void> _editarSyncToken() async {
    final textos = AppLocalizations.of(context);
    final token = await _pedirTexto(textos.ajustesSyncToken, _syncToken);
    if (token == null || token == _syncToken) return;
    final descartar = await _confirmarDescarteModoLocal(_syncUrl, token);
    if (descartar == null) return;
    await AjustesSincronizacion.guardarToken(token);
    if (mounted) setState(() => _syncToken = token);
    await _conectar(descartado: descartar);
  }

  /// Antes de salir del modo local (sin sesión) hacia un servidor: lo hecho
  /// sin usuario no se sube, se descarta. Si hay algo, se pregunta antes.
  /// Devuelve `null` si se cancela, `true` si se ha descartado y `false` si
  /// no había nada que descartar (o no se sale del modo local).
  Future<bool?> _confirmarDescarteModoLocal(String url, String token) async {
    if (sesionEspacio.value != null || url.isEmpty || token.isEmpty) {
      return false;
    }
    final bd = BaseDatosSoleraZunbeltz();
    final cambios = await bd.contarCambiosSinSubir();
    if (cambios == 0) return false;
    if (!mounted) return null;
    final textos = AppLocalizations.of(context);
    final aceptado = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text(textos.syncDescartarLocalTitulo),
        content: Text(textos.syncDescartarLocalTexto(cambios)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(contexto, false),
              child: Text(textos.comunCancelar)),
          FilledButton(
              onPressed: () => Navigator.pop(contexto, true),
              child: Text(textos.syncDescartarLocalBoton)),
        ],
      ),
    );
    if (aceptado != true) return null;
    await bd.descartarCambiosSinSubir();
    avisarCambioDatos();
    return true;
  }

  /// Tras cambiar de WordPress o de clave, la sesión anterior deja de
  /// valer: se cierra y se pregunta al servidor de quién es la clave nueva.
  ///
  /// Con [descartado] (se acaba de vaciar lo hecho en modo local) se
  /// sincroniza todo al momento, para no dejar la app vacía.
  Future<void> _conectar({bool descartado = false}) async {
    final textos = AppLocalizations.of(context);
    await cerrarSesionEspacio();
    await reiniciarCursoresSincronizacion();
    await ServicioNoticiasSector.olvidarGuardadas();
    await ServicioLogosEntidades.olvidarGuardadas();
    await ServicioTextosAyuda.olvidarGuardados();
    avisarCambioDatos();
    if (!mounted || !_configurado) return;
    setState(() => _sincronizando = true);
    var conectada = false;
    try {
      final remota =
          await ClienteSyncZunbeltz(urlBase: _syncUrl, token: _syncToken)
              .obtenerSesion();
      await guardarSesionEspacio(remota.sesion, remota.personas);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              textos.ajustesSesionConectada(remota.sesion.persona.nombre))));
      conectada = true;
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(textoErrorSync(error, textos))));
    } finally {
      // Las pestañas (Fincas, Proyectos…) solo se reconstruyen con este
      // aviso: sin él seguirían ofreciendo lo que permitía la sesión
      // anterior hasta la siguiente sincronización.
      avisarCambioDatos();
      if (mounted) setState(() => _sincronizando = false);
    }
    if (descartado && conectada && mounted) await _sincronizar(completa: true);
  }

  Future<void> _sincronizar({bool completa = false}) async {
    setState(() => _sincronizando = true);
    await sincronizarConAviso(context, completa: completa);
    await _leerUltima();
    if (mounted) setState(() => _sincronizando = false);
  }

  Future<void> _cargarDemo() async {
    final textos = AppLocalizations.of(context);
    final sembrado =
        await BaseDatosSoleraZunbeltz().sembrarDemostracionSiVacia();
    if (sembrado) avisarCambioDatos();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(sembrado ? textos.demoCargada : textos.demoYaHay)));
  }

  Widget _estado(AppLocalizations textos, String idioma) {
    final esquema = context.esquemaZunbeltz;
    final colores = context.coloresZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final ultima = _ultimaMs;
    final (Color fondo, Color tinta, IconData icono, String titulo) =
        switch (()) {
      _ when !_configurado => (
          esquema.surfaceContainerLow,
          esquema.onSurfaceVariant,
          Icons.phone_android_outlined,
          textos.ajustesSesionLocal
        ),
      _ when _sincronizando => (
          colores.fondoEnCurso,
          colores.enCurso,
          Icons.sync,
          textos.hoySincronizando
        ),
      _ when ultima == null => (
          colores.fondoPendiente,
          colores.pendiente,
          Icons.cloud_off_outlined,
          textos.hoySinSincronizar
        ),
      _ => (
          colores.fondoHecha,
          colores.hecha,
          Icons.cloud_done_outlined,
          textos.sinSincronizado
        ),
    };
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: bordeDestacadoZunbeltz,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icono, size: 32, color: tinta),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: estilos.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  !_configurado
                      ? textos.ajustesSesionLocalDetalle
                      : ultima == null
                          ? textos.ajustesSyncSinConfigurar
                          : textos.ajuUltima(haceCuanto(
                              textos, ultima, DateTime.now(),
                              idioma: idioma)),
                  style: estilos.bodyMedium
                      ?.copyWith(color: esquema.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ]),
        if (_configurado) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _sincronizando ? null : _sincronizar,
            icon: _sincronizando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync),
            label: Text(textos.ajustesSyncAhora),
          ),
        ],
      ]),
    );
  }

  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 28, 0, 10),
        child: Text(texto,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: context.esquemaZunbeltz.primary,
                fontWeight: FontWeight.w600)),
      );

  /// Un campo de solo lectura que se edita con el lápiz.
  Widget _campo({
    required String etiqueta,
    required String valor,
    required VoidCallback alEditar,
    Widget? accionExtra,
  }) {
    return InkWell(
      onTap: alEditar,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
            if (accionExtra != null) accionExtra,
            IconButton(
                icon: const Icon(Icons.edit_outlined), onPressed: alEditar),
          ]),
        ),
        child: Text(valor, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _nota(IconData icono, String texto, Color color) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
        child: Row(children: [
          Icon(icono, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texto,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: color)),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final esquema = context.esquemaZunbeltz;
    final colores = context.coloresZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final clave = _syncToken.isEmpty
        ? textos.ajustesSyncSinConfigurar
        : _verClave
            ? _syncToken
            : '•' * _syncToken.length.clamp(4, 24);
    return Scaffold(
      appBar: AppBar(title: Text(textos.ajuSyncCuenta)),
      body: ListView(
        padding: rellenoSobreBarraSistema(
            context, const EdgeInsets.fromLTRB(16, 8, 16, 24)),
        children: [
          _estado(textos, idioma),
          _titulo(textos.sinTuCuenta),
          _campo(
            etiqueta: textos.ajustesSyncToken,
            valor: clave,
            alEditar: _editarSyncToken,
            accionExtra: _syncToken.isEmpty
                ? null
                : IconButton(
                    tooltip:
                        _verClave ? textos.sinOcultarClave : textos.sinVerClave,
                    icon: Icon(_verClave
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _verClave = !_verClave),
                  ),
          ),
          ValueListenableBuilder<SesionEspacio?>(
            valueListenable: sesionEspacio,
            builder: (contexto, sesion, _) => sesion == null
                ? const SizedBox.shrink()
                : _nota(
                    Icons.verified_user_outlined,
                    textos.sinSesionIniciada(sesion.persona.nombre,
                        sesion.persona.etiquetaRol.toLowerCase()),
                    colores.hecha),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(textos.sinPerdisteClave,
                style: estilos.bodyMedium
                    ?.copyWith(color: esquema.onSurfaceVariant)),
          ),
          _titulo(textos.sinServidor),
          _campo(
            etiqueta: textos.ajustesSyncUrl,
            valor:
                _syncUrl.isEmpty ? textos.ajustesSyncSinConfigurar : _syncUrl,
            alEditar: _editarSyncUrl,
          ),
          if (kIsWeb && _configurado)
            InterruptorAvisosPushWeb(
                key: ValueKey('$_syncUrl|$_syncToken'),
                url: _syncUrl,
                token: _syncToken),
          // Los datos de ejemplo no deben acabar en el WordPress de
          // Zunbeltz: solo en modo local.
          if (kDebugMode || esVersionDemo)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.science_outlined),
              title: Text(textos.ajustesDemo),
              subtitle:
                  _syncUrl.isEmpty ? null : Text(textos.ajustesDemoSoloLocal),
              trailing: const Icon(Icons.download),
              onTap: _syncUrl.isEmpty ? _cargarDemo : null,
            ),
          if (_configurado) ...[
            _titulo(textos.sinAlgoNoCuadra),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: esquema.outlineVariant),
                borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(textos.ajustesSyncCompletaDetalle,
                      style: estilos.bodyMedium),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: esquema.error,
                      side: BorderSide(color: esquema.error),
                    ),
                    onPressed: _sincronizando
                        ? null
                        : () => _sincronizar(completa: true),
                    icon: const Icon(Icons.restart_alt),
                    label: Text(textos.ajustesSyncCompleta),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
