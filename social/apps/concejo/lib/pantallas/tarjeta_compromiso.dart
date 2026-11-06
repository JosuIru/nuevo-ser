import 'package:flutter/material.dart';

import '../dominio/compromiso.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'dialogos.dart';
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
                onSelected: (nuevo) async {
                  if (nuevo != EstadoCompromiso.noSeHara) {
                    estado.cambiarEstadoCompromiso(compromiso.uid, nuevo);
                    return;
                  }
                  final motivo = await pedirTexto(
                    context,
                    titulo: textos.compromisoNoSeHara,
                    etiqueta: textos.porQueNoSeHara,
                    confirmar: textos.guardar,
                  );
                  if (motivo != null) {
                    estado.cambiarEstadoCompromiso(compromiso.uid, nuevo,
                        nota: motivo);
                  }
                },
                itemBuilder: (_) => [
                  if (compromiso.estado != EstadoCompromiso.enMarcha)
                    PopupMenuItem(
                        value: EstadoCompromiso.enMarcha,
                        child: Text(textos.marcarEnMarcha)),
                  PopupMenuItem(
                      value: EstadoCompromiso.hecho,
                      child: Text(textos.marcarHecho)),
                  PopupMenuItem(
                      value: EstadoCompromiso.noSeHara,
                      child: Text(textos.marcarNoSeHara)),
                ],
              )
            : null,
      ),
    );
  }
}

/// La mesa apunta qué se hará, quién y para cuándo.
Future<void> apuntarCompromiso(
    BuildContext context, EstadoConcejo estado, String asuntoUid) async {
  final datos =
      await showDialog<({String que, String responsable, DateTime fecha})>(
    context: context,
    builder: (_) => _DialogoCompromiso(ahora: estado.ahora),
  );
  if (datos != null) {
    estado.anadirCompromiso(
      asuntoUid: asuntoUid,
      que: datos.que,
      responsable: datos.responsable,
      fechaLimite: datos.fecha,
    );
  }
}

class _DialogoCompromiso extends StatefulWidget {
  const _DialogoCompromiso({required this.ahora});

  final DateTime ahora;

  @override
  State<_DialogoCompromiso> createState() => _DialogoCompromisoState();
}

class _DialogoCompromisoState extends State<_DialogoCompromiso> {
  final _que = TextEditingController();
  final _responsable = TextEditingController();
  late var _fecha =
      DateTime(widget.ahora.year, widget.ahora.month + 1, widget.ahora.day);

  @override
  void dispose() {
    _que.dispose();
    _responsable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final completo =
        _que.text.trim().isNotEmpty && _responsable.text.trim().isNotEmpty;
    return AlertDialog(
      title: Text(textos.apuntarCompromiso),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _que,
            autofocus: true,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
                labelText: textos.campoQue, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _responsable,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
                labelText: textos.campoResponsable,
                helperText: textos.ayudaResponsable,
                border: const OutlineInputBorder()),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: Text(textos.campoFechaLimite),
            subtitle: Text(textos.fecha(_fecha)),
            onTap: () async {
              final elegida = await showDatePicker(
                context: context,
                initialDate: _fecha,
                firstDate: DateTime(_fecha.year - 1),
                lastDate: DateTime(_fecha.year + 3),
              );
              if (elegida != null) setState(() => _fecha = elegida);
            },
          ),
        ]),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(textos.cancelar)),
        FilledButton(
          onPressed: completo
              ? () => Navigator.pop(context, (
                    que: _que.text.trim(),
                    responsable: _responsable.text.trim(),
                    fecha: _fecha,
                  ))
              : null,
          child: Text(textos.guardar),
        ),
      ],
    );
  }
}
