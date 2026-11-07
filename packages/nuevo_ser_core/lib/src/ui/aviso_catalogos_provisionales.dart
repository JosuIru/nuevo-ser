import 'package:flutter/material.dart';

/// Aviso de catálogos provisionales para la pantalla Hoy de las apps Larrea.
///
/// Mismo aspecto en todas las verticales, sobrio y legible con cualquier
/// paleta: superficie suave, borde fino e icono discreto. Antes cada app lo
/// pintaba con el `tertiaryContainer` de su paleta y salía de un color
/// distinto en cada una (magenta, granate, morado…), a veces con poco
/// contraste. Se muestra mientras `catalogosCompletamenteRevisados` sea
/// falso, es decir, hasta que una persona experta firme los catálogos.
class AvisoCatalogosProvisionales extends StatelessWidget {
  const AvisoCatalogosProvisionales({super.key, required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: esquema.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fact_check_outlined, size: 20, color: esquema.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: esquema.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
