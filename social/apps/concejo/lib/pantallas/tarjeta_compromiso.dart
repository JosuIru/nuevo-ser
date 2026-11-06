import 'package:flutter/material.dart';

import '../dominio/compromiso.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'textos_dominio.dart';

class TarjetaCompromiso extends StatelessWidget {
  const TarjetaCompromiso({
    super.key,
    required this.estado,
    required this.compromiso,
    this.mostrarAsunto = false,
  });

  final EstadoConcejo estado;
  final Compromiso compromiso;
  final bool mostrarAsunto;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final colores = Theme.of(context).colorScheme;
    final vencido = compromiso.vencidoEn(estado.ahora);
    final (icono, color) = switch (compromiso.estado) {
      EstadoCompromiso.hecho => (Icons.check_circle, colores.primary),
      EstadoCompromiso.noSeHara => (Icons.block, colores.outline),
      EstadoCompromiso.enMarcha => (Icons.autorenew, colores.tertiary),
      EstadoCompromiso.pendiente => vencido
          ? (Icons.error_outline, colores.error)
          : (Icons.radio_button_unchecked, colores.outline),
    };
    return Card(
      child: ListTile(
        leading: Icon(icono, color: color),
        title: Text(compromiso.que),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(textos.compromisoPara(
                compromiso.responsable, textos.fecha(compromiso.fechaLimite))),
            Text(vencido
                ? textos.compromisoVencido
                : textos.estadoCompromiso(compromiso.estado)),
            if (compromiso.nota.isNotEmpty) Text(compromiso.nota),
            if (mostrarAsunto)
              Text(textos.deAsunto(estado.asunto(compromiso.asuntoUid).titulo),
                  style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        trailing: estado.soyMesa && !compromiso.cerrado
            ? PopupMenuButton<EstadoCompromiso>(
                onSelected: (nuevo) =>
                    estado.cambiarEstadoCompromiso(compromiso.uid, nuevo),
                itemBuilder: (_) => [
                  if (compromiso.estado != EstadoCompromiso.enMarcha)
                    PopupMenuItem(
                        value: EstadoCompromiso.enMarcha,
                        child: Text(textos.marcarEnMarcha)),
                  PopupMenuItem(
                      value: EstadoCompromiso.hecho,
                      child: Text(textos.marcarHecho)),
                ],
              )
            : null,
      ),
    );
  }
}
