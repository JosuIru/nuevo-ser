import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

/// Apartados de la ayuda, en orden: (clave del título, clave del texto).
const List<(String, String)> apartadosAyudaSidra = [
  ('sidr.ayuda_empezar_titulo', 'sidr.ayuda_empezar_texto'),
  ('sidr.ayuda_pomaradas_titulo', 'sidr.ayuda_pomaradas_texto'),
  ('sidr.ayuda_bodega_titulo', 'sidr.ayuda_bodega_texto'),
  ('sidr.ayuda_txotx_titulo', 'sidr.ayuda_txotx_texto'),
  ('sidr.ayuda_dop_titulo', 'sidr.ayuda_dop_texto'),
  ('sidr.ayuda_documentos_titulo', 'sidr.ayuda_documentos_texto'),
  ('sidr.ayuda_ia_titulo', 'sidr.ayuda_ia_texto'),
  ('sidr.ayuda_economia_titulo', 'sidr.ayuda_economia_texto'),
  ('sidr.ayuda_limites_titulo', 'sidr.ayuda_limites_texto'),
];

class PantallaAyuda extends StatelessWidget {
  const PantallaAyuda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('sidr.ayuda'))),
      body: ListView(
        children: [
          for (final (titulo, texto) in apartadosAyudaSidra)
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
