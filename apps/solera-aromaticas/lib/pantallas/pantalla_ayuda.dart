import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

/// Apartados de la ayuda, en orden: (clave del título, clave del texto).
const List<(String, String)> apartadosAyudaAromaticas = [
  ('arom.ayuda_empezar_titulo', 'arom.ayuda_empezar_texto'),
  ('arom.ayuda_zonas_titulo', 'arom.ayuda_zonas_texto'),
  ('arom.ayuda_cosechas_titulo', 'arom.ayuda_cosechas_texto'),
  ('arom.ayuda_taller_titulo', 'arom.ayuda_taller_texto'),
  ('arom.ayuda_lotes_titulo', 'arom.ayuda_lotes_texto'),
  ('arom.ayuda_documentos_titulo', 'arom.ayuda_documentos_texto'),
  ('arom.ayuda_guia_titulo', 'arom.ayuda_guia_texto'),
  ('arom.ayuda_ia_titulo', 'arom.ayuda_ia_texto'),
  ('arom.ayuda_economia_titulo', 'arom.ayuda_economia_texto'),
  ('arom.ayuda_limites_titulo', 'arom.ayuda_limites_texto'),
];

class PantallaAyuda extends StatelessWidget {
  const PantallaAyuda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('arom.ayuda'))),
      body: ListView(
        children: [
          for (final (titulo, texto) in apartadosAyudaAromaticas)
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
