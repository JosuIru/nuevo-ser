import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

/// Apartados de la ayuda, en orden: (clave del título, clave del texto).
const List<(String, String)> apartadosAyudaVivero = [
  ('vive.ayuda_empezar_titulo', 'vive.ayuda_empezar_texto'),
  ('vive.ayuda_trazabilidad_titulo', 'vive.ayuda_trazabilidad_texto'),
  ('vive.ayuda_bandejas_titulo', 'vive.ayuda_bandejas_texto'),
  ('vive.ayuda_pasaporte_titulo', 'vive.ayuda_pasaporte_texto'),
  ('vive.ayuda_cuaderno_titulo', 'vive.ayuda_cuaderno_texto'),
  ('vive.ayuda_documentos_titulo', 'vive.ayuda_documentos_texto'),
  ('vive.ayuda_ia_titulo', 'vive.ayuda_ia_texto'),
  ('vive.ayuda_economia_titulo', 'vive.ayuda_economia_texto'),
  ('vive.ayuda_limites_titulo', 'vive.ayuda_limites_texto'),
];

class PantallaAyuda extends StatelessWidget {
  const PantallaAyuda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('vive.ayuda'))),
      body: ListView(
        children: [
          for (final (titulo, texto) in apartadosAyudaVivero)
            ExpansionTile(
              title: Text(SoleraL10n.t(titulo)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(SoleraL10n.t(texto))],
            ),
        ],
      ),
    );
  }
}
