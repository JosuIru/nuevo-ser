import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../branding.dart';
import '../../l10n/app_localizations.dart';
import '../../modelos/constantes.dart';
import '../../modelos/tarea_mantenimiento.dart';

/// Una tarea en una lista (Hoy, hoja de una pieza): icono del estado sobre su color, dónde está, el
/// título, estado y prioridad, la fecha y el botón de darla por hecha.
class FilaTarea extends StatelessWidget {
  const FilaTarea({
    super.key,
    required this.tarea,
    required this.lugar,
    required this.alPulsar,
    required this.alMarcarHecha,
    this.margenIzquierdo = 16,
    this.verResponsable = false,
  });

  final TareaMantenimiento tarea;
  final String lugar;
  final VoidCallback alPulsar;
  final VoidCallback? alMarcarHecha;

  /// 16 en una tarjeta (Hoy); 0 donde el contenedor ya pone su margen.
  final double margenIzquierdo;

  /// Debajo, quién la lleva (tablero y hoja de la pieza).
  final bool verResponsable;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final colores = context.coloresZunbeltz;
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final (Color color, Color fondo, IconData icono) = switch (tarea.estado) {
      'en_curso' => (colores.enCurso, colores.fondoEnCurso, Icons.autorenew),
      'bloqueada' => (colores.bloqueada, colores.fondoBloqueada, Icons.block),
      'hecha' => (colores.hecha, colores.fondoHecha, Icons.check),
      _ => (colores.pendiente, colores.fondoPendiente, Icons.schedule),
    };
    final estado = buscarOpcion(estadosTarea, tarea.estado)?.etiqueta(idioma) ??
        tarea.estado;
    final prioridad =
        buscarOpcion(prioridadesTarea, tarea.prioridad)?.etiqueta(idioma) ??
            tarea.prioridad;
    final fechaMs = tarea.fechaObjetivoMs;
    String? fecha;
    if (fechaMs != null) {
      final dia = DateTime.fromMillisecondsSinceEpoch(fechaMs);
      final dentroDeUnaSemana = dia.difference(DateTime.now()).inDays.abs() < 7;
      fecha = _conMayusculaInicial(
          DateFormat(dentroDeUnaSemana ? 'E d' : 'd MMM', idioma)
              .format(dia)
              // Que «Jue 5» no se parta en dos líneas.
              .replaceAll(' ', '\u00A0'));
    }
    return InkWell(
      onTap: alPulsar,
      child: Padding(
        padding: EdgeInsets.fromLTRB(margenIzquierdo, 14, 4, 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: fondo, borderRadius: BorderRadius.circular(12)),
            child: Icon(icono, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lugar.isNotEmpty)
                  Text(lugar,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: estilos.bodySmall
                          ?.copyWith(color: esquema.onSurfaceVariant)),
                Text(tarea.titulo.isEmpty ? '—' : tarea.titulo,
                    style: estilos.titleMedium),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: textos.hoyEstadoPrioridad(
                          estado, prioridad.toLowerCase()),
                      style: estilos.labelLarge?.copyWith(color: color),
                    ),
                    if (fecha != null)
                      TextSpan(
                        text: ' · $fecha',
                        style: estilos.bodyMedium
                            ?.copyWith(color: esquema.onSurfaceVariant),
                      ),
                    if (tarea.esRecurrente)
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.repeat, size: 15),
                        ),
                      ),
                  ]),
                ),
                if (verResponsable && tarea.responsable.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(children: [
                      Icon(Icons.person_outline,
                          size: 16, color: esquema.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(tarea.responsable,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: estilos.bodySmall
                                ?.copyWith(color: esquema.onSurfaceVariant)),
                      ),
                    ]),
                  ),
              ],
            ),
          ),
          if (alMarcarHecha != null && tarea.estado != 'hecha')
            IconButton(
              tooltip: textos.tareaMarcarHecha,
              icon: Icon(Icons.check_circle_outline,
                  size: 28, color: esquema.outline),
              onPressed: alMarcarHecha,
            )
          else
            const SizedBox(width: 12),
        ]),
      ),
    );
  }
}

String _conMayusculaInicial(String texto) =>
    texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);
