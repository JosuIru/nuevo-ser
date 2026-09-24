import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/base_datos.dart';
import '../estado/ajustes_sincronizacion.dart';
import '../estado/coordinador.dart';
import '../estado/datos_notificador.dart';
import '../servicios/cliente_sync_zunbeltz.dart';
import '../servicios/exportador_espacio.dart';
import '../estado/idioma_app.dart';
import '../estado/sesion_espacio.dart';
import '../modelos/persona_espacio.dart';
import '../l10n/app_localizations.dart';
import '../utiles/traductor_actualizaciones.dart';
import 'pantalla_acerca_espacio_test.dart';
import 'pantalla_ayuda.dart';

/// Versión visible de la app. Se mantiene a mano sincronizada con `version`
/// del `pubspec.yaml` (campo antes del `+`).
const String versionAppZunbeltz = '0.1.0';

/// Pestaña "Ajustes": idioma y acerca de.
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

  @override
  void initState() {
    super.initState();
    Coordinador.cargarCorreo().then((c) {
      if (mounted) setState(() => _coordinador = c);
    });
    AjustesSincronizacion.cargarUrl().then((u) {
      if (mounted) setState(() => _syncUrl = u);
    });
    AjustesSincronizacion.cargarToken().then((t) {
      if (mounted) setState(() => _syncToken = t);
    });
  }

  Future<void> _cambiarIdioma(String codigo) async {
    await elegirIdiomaZunbeltz(codigo);
    if (mounted) setState(() {});
  }

  Future<void> _exportarEspacio() async {
    final ficheros = await exportarEspacioCsv();
    if (!mounted) return;
    try {
      await Share.shareXFiles(ficheros.map((f) => XFile(f.path)).toList(),
          subject: 'Espacio Solera Zunbeltz (CSV)');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ficheros.map((f) => f.path).join('\n'))));
      }
    }
  }

  Future<void> _cargarDemo() async {
    final textos = AppLocalizations.of(context);
    final sembrado = await BaseDatosSoleraZunbeltz().sembrarDemostracionSiVacia();
    if (sembrado) avisarCambioDatos();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(sembrado ? textos.demoCargada : textos.demoYaHay)));
  }

  Future<void> _editarCoordinador() async {
    final textos = AppLocalizations.of(context);
    final controlador = TextEditingController(text: _coordinador);
    final correo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
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
    );
    if (correo == null) return;
    await Coordinador.guardarCorreo(correo);
    if (mounted) setState(() => _coordinador = correo);
  }

  Future<void> _editarSyncUrl() async {
    final textos = AppLocalizations.of(context);
    final controlador = TextEditingController(text: _syncUrl);
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(textos.ajustesSyncUrl),
        content: TextField(
          controller: controlador,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(hintText: 'https://tuwordpress.org'),
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
    );
    if (url == null || url == _syncUrl) return;
    await AjustesSincronizacion.guardarUrl(url);
    if (mounted) setState(() => _syncUrl = url);
    await _conectar();
  }

  Future<void> _editarSyncToken() async {
    final textos = AppLocalizations.of(context);
    final controlador = TextEditingController(text: _syncToken);
    final token = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(textos.ajustesSyncToken),
        content: TextField(
          controller: controlador,
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
    );
    if (token == null || token == _syncToken) return;
    await AjustesSincronizacion.guardarToken(token);
    if (mounted) setState(() => _syncToken = token);
    await _conectar();
  }

  /// Tras cambiar de WordPress o de token, la sesión anterior deja de valer:
  /// se cierra y se pregunta al servidor quién es la dueña del token nuevo.
  Future<void> _conectar() async {
    final textos = AppLocalizations.of(context);
    await cerrarSesionEspacio();
    if (!mounted || _syncUrl.isEmpty || _syncToken.isEmpty) return;
    setState(() => _sincronizando = true);
    try {
      final remota =
          await ClienteSyncZunbeltz(urlBase: _syncUrl, token: _syncToken)
              .obtenerSesion();
      await guardarSesionEspacio(remota.sesion, remota.personas);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(textos.ajustesSesionConectada(remota.sesion.persona.nombre))));
    } on ErrorSyncZunbeltz catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.mensaje)));
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  Future<void> _sincronizarAhora() async {
    final textos = AppLocalizations.of(context);
    setState(() => _sincronizando = true);
    try {
      final resultado = await ClienteSyncZunbeltz(
        urlBase: _syncUrl,
        token: _syncToken,
      ).sincronizar(BaseDatosSoleraZunbeltz());
      await guardarSesionEspacio(
          resultado.sesionRemota.sesion, resultado.sesionRemota.personas);
      avisarCambioDatos();
      if (!mounted) return;
      final resumen = textos.ajustesSyncResultado(
          resultado.subidas, resultado.bajadas, resultado.omitidasFincaDesconocida);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(resultado.rechazadasPorPermisos == 0
              ? resumen
              : '$resumen\n${textos.ajustesSyncRechazadas(resultado.rechazadasPorPermisos)}')));
    } on ErrorSyncZunbeltz catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.mensaje)));
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final localeActivo = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(textos.navAjustes)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.translate_outlined),
            title: Text(textos.ajustesIdioma),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 10,
                children: [
                  ChoiceChip(
                    selected: localeActivo == 'es',
                    label: Text(textos.ajustesIdiomaCastellano),
                    onSelected: (_) => _cambiarIdioma('es'),
                  ),
                  ChoiceChip(
                    selected: localeActivo == 'eu',
                    label: Text(textos.ajustesIdiomaEuskera),
                    onSelected: (_) => _cambiarIdioma('eu'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(textos.ayudaTitulo),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PantallaAyuda()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.outgoing_mail),
            title: Text(textos.ajustesCoordinador),
            subtitle: Text(
                _coordinador.isEmpty ? textos.ajustesCoordinadorVacio : _coordinador),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _editarCoordinador,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.landscape_outlined),
            title: Text(textos.acercaTitulo),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const PantallaAcercaEspacioTest()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(textos.ajustesAcercaDe),
            subtitle: Text(textos.ajustesVersion(versionAppZunbeltz)),
          ),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: Text(textos.actualizacionesTitulo),
            subtitle: Text(textos.ajustesActualizacionesSubtitulo),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PantallaEstadoActualizaciones(
                  config: configActualizacionesZunbeltz,
                  nombreApp: textos.appTitulo,
                  traducir: traductorActualizaciones(textos),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: Text(textos.ajustesExportarEspacio),
            trailing: const Icon(Icons.ios_share),
            onTap: _exportarEspacio,
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(textos.ajustesSyncTitulo,
                style: Theme.of(context).textTheme.titleSmall),
          ),
          ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: Text(textos.ajustesSyncUrl),
            subtitle: Text(_syncUrl.isEmpty ? textos.ajustesSyncSinConfigurar : _syncUrl),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _editarSyncUrl,
          ),
          ListTile(
            leading: const Icon(Icons.key_outlined),
            title: Text(textos.ajustesSyncToken),
            subtitle: Text(_syncToken.isEmpty
                ? textos.ajustesSyncSinConfigurar
                : '•' * _syncToken.length.clamp(4, 24)),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _editarSyncToken,
          ),
          ValueListenableBuilder<SesionEspacio?>(
            valueListenable: sesionEspacio,
            builder: (contexto, sesion, _) => ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(sesion == null
                  ? textos.ajustesSesionLocal
                  : textos.ajustesSesionComo(sesion.persona.nombre)),
              subtitle: Text(sesion == null
                  ? textos.ajustesSesionLocalDetalle
                  : sesion.persona.etiquetaRol),
            ),
          ),
          ListTile(
            leading: _sincronizando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync_outlined),
            title: Text(textos.ajustesSyncAhora),
            onTap:
                (_sincronizando || _syncUrl.isEmpty || _syncToken.isEmpty)
                    ? null
                    : _sincronizarAhora,
          ),
          if (kDebugMode)
            ListTile(
              leading: const Icon(Icons.science_outlined),
              title: Text(textos.ajustesDemo),
              trailing: const Icon(Icons.download),
              onTap: _cargarDemo,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Text(
              textos.ajustesProvisional,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
