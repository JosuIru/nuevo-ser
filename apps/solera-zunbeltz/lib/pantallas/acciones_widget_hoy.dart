import 'package:flutter/material.dart';

import '../datos/base_datos.dart';
import '../estado/datos_notificador.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/ganado.dart';
import '../servicios/widget_hoy.dart';
import 'formularios_ganado.dart';
import 'nuevo_aviso.dart';

/// Pestañas de la pantalla principal a las que lleva el widget.
const int indicePestanaHoy = 0;
const int indicePestanaGanado = 2;

/// Lo que hace la app al abrirse desde un botón del widget de la pantalla
/// de inicio. Sin permiso para lo pedido, se queda en la pestaña.
Future<void> abrirAccionWidgetHoy(
  BuildContext context,
  AccionWidgetHoy accion, {
  required void Function(int indice) irAPestana,
}) async {
  final politica = politicaEspacioActual;
  switch (accion) {
    case AccionWidgetHoy.hoy:
      irAPestana(indicePestanaHoy);
    case AccionWidgetHoy.ganado:
      irAPestana(indicePestanaGanado);
    case AccionWidgetHoy.nuevoAviso:
      irAPestana(indicePestanaHoy);
      if (!politica.puedeCrearAvisos) return;
      await _abrir(context, const NuevoAviso());
    case AccionWidgetHoy.moverLote:
    case AccionWidgetHoy.apuntarCura:
      irAPestana(indicePestanaGanado);
      if (!politica.puedeManejarAnimales) return;
      final lote = await elegirLoteActivo(context);
      if (lote == null || !context.mounted) return;
      await _abrir(
          context,
          accion == AccionWidgetHoy.moverLote
              ? FormularioMovimiento(lote: lote)
              : FormularioEventoGanado(loteId: lote.id, titulo: lote.nombre));
  }
}

Future<void> _abrir(BuildContext context, Widget pantalla) async {
  final guardado = await Navigator.of(context)
      .push<bool>(MaterialPageRoute(builder: (_) => pantalla));
  if (guardado == true) avisarCambioDatos();
}

/// Hoja para elegir uno de los lotes en uso. Null si se cancela o no hay.
Future<LoteGanado?> elegirLoteActivo(BuildContext context) async {
  final textos = AppLocalizations.of(context);
  final lotes = await BaseDatosSoleraZunbeltz().listarLotes(soloActivos: true);
  if (!context.mounted) return null;
  if (lotes.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.ganSinLotes)));
    return null;
  }
  return showModalBottomSheet<LoteGanado>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (contexto) => SafeArea(
      child: ListView(shrinkWrap: true, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(textos.ganElegirLote,
              style: Theme.of(contexto).textTheme.titleMedium),
        ),
        for (final lote in lotes)
          ListTile(
            leading: const Icon(Icons.pets_outlined),
            title: Text(lote.nombre),
            onTap: () => Navigator.pop(contexto, lote),
          ),
      ]),
    ),
  );
}
