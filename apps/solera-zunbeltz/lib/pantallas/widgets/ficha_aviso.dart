import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../branding.dart';
import '../../datos/base_datos.dart';
import '../../estado/datos_notificador.dart';
import '../../estado/sesion_espacio.dart';
import '../../l10n/app_localizations.dart';
import '../../modelos/aviso_campo.dart';
import '../../utiles/estilo_aviso.dart';
import 'confirmar_borrado.dart';

/// Hoja con el detalle de un aviso y lo que se puede hacer con él
/// (resolverlo, reabrirlo, borrarlo) según quién mira. Devuelve `true` si
/// cambió algo.
Future<bool> mostrarFichaAviso(BuildContext context, AvisoCampo aviso) async {
  final textos = AppLocalizations.of(context);
  final idioma = Localizations.localeOf(context).languageCode;
  final puedeEditar = politicaEspacioActual.puedeEditarAviso(aviso.autorUid);
  final bd = BaseDatosSoleraZunbeltz();
  final cambio = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (contexto) => SingleChildScrollView(
        child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(iconoCategoriaAviso(aviso.categoria),
                  color: aviso.esAlarma ? colorSenalZunbeltz : null),
              const SizedBox(width: 8),
              Expanded(
                child: Text(aviso.titulo,
                    style: Theme.of(contexto).textTheme.titleLarge),
              ),
            ]),
            const SizedBox(height: 6),
            Text([
              etiquetaCategoriaAviso(aviso.categoria, textos),
              if (aviso.esAlarma) textos.avisoAlarma,
              textos.avisoDe(nombrePersonaEspacio(aviso.autorUid) ??
                  textos.personaDesconocida),
              if (aviso.fechaMs > 0)
                DateFormat('dd/MM/yyyy HH:mm', idioma)
                    .format(DateTime.fromMillisecondsSinceEpoch(aviso.fechaMs)),
              if (!aviso.abierto) textos.avisoResuelto,
            ].join(' · ')),
            if (aviso.descripcion.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(aviso.descripcion),
            ],
            if (puedeEditar && aviso.id != null) ...[
              const SizedBox(height: 16),
              Wrap(spacing: 8, children: [
                FilledButton.tonal(
                  onPressed: () async {
                    await bd.actualizarAviso(aviso.id!, {
                      'estado': aviso.abierto
                          ? estadoAvisoResuelto
                          : estadoAvisoAbierto,
                    });
                    if (contexto.mounted) Navigator.pop(contexto, true);
                  },
                  child: Text(aviso.abierto
                      ? textos.avisoResolver
                      : textos.avisoReabrir),
                ),
                TextButton(
                  onPressed: () async {
                    if (!await confirmarBorrado(contexto)) return;
                    await bd.borrarAviso(aviso.id!);
                    if (contexto.mounted) Navigator.pop(contexto, true);
                  },
                  child: Text(textos.avisoBorrar),
                ),
              ]),
            ],
          ],
        ),
      ),
    )),
  );
  if (cambio == true) avisarCambioDatos();
  return cambio == true;
}
