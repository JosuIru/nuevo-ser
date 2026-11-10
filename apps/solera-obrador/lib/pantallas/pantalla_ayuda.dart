import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

/// Apartados de la ayuda, en orden: (clave del título, clave del texto).
const List<(String, String)> apartadosAyudaObrador = [
  ('obra.ayuda_empezar_titulo', 'obra.ayuda_empezar_texto'),
  ('obra.ayuda_recetas_titulo', 'obra.ayuda_recetas_texto'),
  ('obra.ayuda_guia_titulo', 'obra.ayuda_guia_texto'),
  ('obra.ayuda_autocontrol_titulo', 'obra.ayuda_autocontrol_texto'),
  ('obra.ayuda_hornadas_titulo', 'obra.ayuda_hornadas_texto'),
  ('obra.plan_ayuda_titulo', 'obra.plan_ayuda_texto'),
  ('obra.ayuda_documentos_titulo', 'obra.ayuda_documentos_texto'),
  ('obra.etiq_ayuda_titulo', 'obra.etiq_ayuda_texto'),
  ('obra.ayuda_ia_titulo', 'obra.ayuda_ia_texto'),
  ('obra.ayuda_limites_titulo', 'obra.ayuda_limites_texto'),
];

class PantallaAyuda extends StatelessWidget {
  const PantallaAyuda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('obra.ayuda'))),
      body: ListView(
        children: [
          for (final (titulo, texto) in apartadosAyudaObrador)
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
