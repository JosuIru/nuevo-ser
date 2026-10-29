import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../servicios/avisos_push_web.dart';

/// Interruptor de Ajustes (solo en la versión web y con sincronización):
/// avisos al momento de alarmas, peticiones y tareas aunque la app esté
/// cerrada.
class InterruptorAvisosPushWeb extends StatefulWidget {
  const InterruptorAvisosPushWeb(
      {super.key, required this.url, required this.token});

  final String url;
  final String token;

  @override
  State<InterruptorAvisosPushWeb> createState() =>
      _InterruptorAvisosPushWebState();
}

class _InterruptorAvisosPushWebState extends State<InterruptorAvisosPushWeb> {
  EstadoAvisosPush? _estado;
  bool _trabajando = false;

  @override
  void initState() {
    super.initState();
    estadoAvisosPush().then((estado) {
      if (mounted) setState(() => _estado = estado);
    });
  }

  void _cambiar(bool activar) {
    // Sin esperar nada antes de llamar: el permiso se pide en este toque.
    final peticion = activar
        ? activarAvisosPush(
            url: widget.url,
            token: widget.token,
            idioma: Localizations.localeOf(context).languageCode)
        : desactivarAvisosPush(url: widget.url, token: widget.token);
    setState(() => _trabajando = true);
    peticion.then((estado) {
      if (mounted) {
        setState(() {
          _estado = estado;
          _trabajando = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final estado = _estado;
    final explicacion = switch (estado) {
      null => '',
      EstadoAvisosPush.activo => textos.avisosPushActivo,
      EstadoAvisosPush.inactivo => textos.avisosPushInactivo,
      EstadoAvisosPush.denegado => textos.avisosPushDenegado,
      EstadoAvisosPush.instalar => textos.avisosPushInstalar,
      EstadoAvisosPush.noCompatible => textos.avisosPushNoCompatible,
      EstadoAvisosPush.error => textos.avisosPushError,
    };
    final sePuedeCambiar = !_trabajando &&
        (estado == EstadoAvisosPush.activo ||
            estado == EstadoAvisosPush.inactivo ||
            estado == EstadoAvisosPush.error);
    return SwitchListTile(
      secondary: _trabajando
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(estado == EstadoAvisosPush.activo
              ? Icons.notifications_active_outlined
              : Icons.notifications_off_outlined),
      title: Text(textos.avisosPushTitulo),
      subtitle: explicacion.isEmpty ? null : Text(explicacion),
      value: estado == EstadoAvisosPush.activo,
      onChanged: sePuedeCambiar ? _cambiar : null,
    );
  }
}
