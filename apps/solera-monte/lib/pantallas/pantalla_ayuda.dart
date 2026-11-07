import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

/// Apartados de la ayuda, en orden: (clave del título, clave del texto).
const List<(String, String)> apartadosAyudaMonte = [
  ('mont.ayuda_empezar_titulo', 'mont.ayuda_empezar_texto'),
  ('mont.ayuda_rodales_titulo', 'mont.ayuda_rodales_texto'),
  ('mont.ayuda_plan_titulo', 'mont.ayuda_plan_texto'),
  ('mont.ayuda_aprovechamientos_titulo', 'mont.ayuda_aprovechamientos_texto'),
  ('mont.ayuda_sorteo_titulo', 'mont.ayuda_sorteo_texto'),
  ('mont.ayuda_incendios_titulo', 'mont.ayuda_incendios_texto'),
  ('mont.ayuda_documentos_titulo', 'mont.ayuda_documentos_texto'),
  ('mont.ayuda_ia_titulo', 'mont.ayuda_ia_texto'),
  ('mont.ayuda_economia_titulo', 'mont.ayuda_economia_texto'),
  ('mont.ayuda_limites_titulo', 'mont.ayuda_limites_texto'),
];

class PantallaAyuda extends StatelessWidget {
  const PantallaAyuda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('mont.ayuda'))),
      body: ListView(
        children: [
          for (final (titulo, texto) in apartadosAyudaMonte)
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
