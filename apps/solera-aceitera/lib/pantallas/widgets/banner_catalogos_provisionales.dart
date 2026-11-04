import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../../datos/catalogos_generados/flag_revision.dart';

/// Banner persistente que recuerda al operador que los catálogos
/// agronómicos (variedades de olivo, plagas, fitosanitarios, DOPs,
/// calendario olivar) están sin validar por un asesor agrónomo
/// olivarero. Desaparece automáticamente cuando el compilador detecta
/// que `revisado_por` está rellenado en todas las filas de los 5 CSVs
/// y regenera `catalogosCompletamenteRevisados = true`.
///
/// Usado en pantallas que muestran datos derivados de catálogo
/// (dashboard Hoy, formularios con autocomplete) para mantener al
/// usuario informado del estado de validación. Cuando la validación
/// está cerrada el widget devuelve `SizedBox.shrink()` y no ocupa
/// espacio en el layout.
class BannerCatalogosProvisionales extends StatelessWidget {
  const BannerCatalogosProvisionales({super.key});

  @override
  Widget build(BuildContext context) {
    if (catalogosCompletamenteRevisados) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fact_check, color: Colors.amber.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  SoleraL10n.t('acei.catalogos_provisionales'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  SoleraL10n.t('acei.catalogos_provisionales_texto'),
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
