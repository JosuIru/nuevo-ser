import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;

import 'estado/datos_ejemplo.dart';
import 'estado/estado_concejo.dart';
import 'l10n/app_localizations.dart';
import 'pantallas/pantalla_entrar.dart';
import 'pantallas/pantalla_inicio.dart';
import 'servidor/almacen_local.dart';
import 'servidor/cliente_concejo.dart';
import 'servidor/sincronizador.dart';
import 'tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RaizConcejo(almacen: await AlmacenPreferencias.abrir()));
}

/// Con un estado fijo (tests y pueblo de ejemplo) o con la [pantalla] que
/// toque.
class AppConcejo extends StatelessWidget {
  const AppConcejo({super.key, this.estado, this.pantalla, this.idioma})
      : assert(estado != null || pantalla != null);

  final EstadoConcejo? estado;
  final Widget? pantalla;

  /// Para fijar el idioma en los tests; si no, el del sistema.
  final Locale? idioma;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).nombreApp,
      debugShowCheckedModeBanner: false,
      theme: temaConcejo(Brightness.light),
      darkTheme: temaConcejo(Brightness.dark),
      locale: idioma,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: pantalla ?? PantallaInicio(estado: estado!),
    );
  }
}

/// Decide qué enseñar: entrar, el pueblo de ejemplo o el pueblo de verdad
/// (y lo mantiene al día: al abrir, al volver a la app y cada poco).
class RaizConcejo extends StatefulWidget {
  const RaizConcejo(
      {super.key, required this.almacen, this.clienteHttp, this.idioma});

  static const claveDireccion = 'concejo.direccion';
  static const claveCodigo = 'concejo.codigo';

  final AlmacenLocal almacen;
  final http.Client? clienteHttp;
  final Locale? idioma;

  @override
  State<RaizConcejo> createState() => _RaizConcejoState();
}

class _RaizConcejoState extends State<RaizConcejo> with WidgetsBindingObserver {
  Sincronizador? _sincronizador;
  EstadoConcejo? _ejemplo;
  Timer? _cadaPoco;

  AlmacenLocal get _almacen => widget.almacen;

  ClienteConcejo? _clienteGuardado() {
    final direccion = _almacen.leer(RaizConcejo.claveDireccion);
    final codigo = _almacen.leer(RaizConcejo.claveCodigo);
    if (direccion == null || codigo == null) return null;
    return ClienteConcejo(
        api: Uri.parse(direccion), codigo: codigo, cliente: widget.clienteHttp);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final cliente = _clienteGuardado();
    if (cliente != null) {
      _empezar(Sincronizador.abrir(cliente: cliente, almacen: _almacen));
    }
  }

  void _empezar(Sincronizador? sincronizador) {
    _sincronizador = sincronizador;
    if (sincronizador == null) return;
    unawaited(sincronizador.sincronizar());
    _cadaPoco = Timer.periodic(
        const Duration(minutes: 2), (_) => sincronizador.sincronizar());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (estado == AppLifecycleState.resumed) {
      unawaited(_sincronizador?.sincronizar());
    }
  }

  Future<void> _entrar(String direccion, String codigo) async {
    final cliente = ClienteConcejo(
        api: direccionApi(direccion),
        codigo: codigo.trim(),
        cliente: widget.clienteHttp);
    final sincronizador =
        await Sincronizador.entrar(cliente: cliente, almacen: _almacen);
    await _almacen.escribir(RaizConcejo.claveDireccion, cliente.api.toString());
    await _almacen.escribir(RaizConcejo.claveCodigo, cliente.codigo);
    setState(() => _empezar(sincronizador));
  }

  Future<void> _salir() async {
    _cadaPoco?.cancel();
    await _almacen.escribir(RaizConcejo.claveDireccion, null);
    await _almacen.escribir(RaizConcejo.claveCodigo, null);
    setState(() {
      _sincronizador?.dispose();
      _sincronizador = null;
      _ejemplo = null;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cadaPoco?.cancel();
    _sincronizador?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sincronizador = _sincronizador;
    final ejemplo = _ejemplo;
    final Widget pantalla;
    if (sincronizador != null) {
      pantalla = PantallaInicio(
        key: ObjectKey(sincronizador),
        estado: sincronizador.estado,
        sincronizador: sincronizador,
        alSalir: _salir,
        almacen: _almacen,
      );
    } else if (ejemplo != null) {
      pantalla = PantallaInicio(
          key: ObjectKey(ejemplo), estado: ejemplo, alSalir: _salir);
    } else {
      pantalla = PantallaEntrar(
        entrar: _entrar,
        verEjemplo: () => setState(() => _ejemplo = estadoDeEjemplo()),
      );
    }
    return AppConcejo(pantalla: pantalla, idioma: widget.idioma);
  }
}
