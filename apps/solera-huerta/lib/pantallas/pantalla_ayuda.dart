import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

/// Apartados de la ayuda, en orden: (clave del título, clave del texto).
const List<(String, String)> apartadosAyudaHuerta = [
  ('huer.ayuda_empezar_titulo', 'huer.ayuda_empezar_texto'),
  ('huer.ayuda_bancales_titulo', 'huer.ayuda_bancales_texto'),
  ('huer.ayuda_rotacion_titulo', 'huer.ayuda_rotacion_texto'),
  ('huer.ayuda_siembras_titulo', 'huer.ayuda_siembras_texto'),
  ('huer.ayuda_cestas_titulo', 'huer.ayuda_cestas_texto'),
  ('huer.ayuda_insumos_titulo', 'huer.ayuda_insumos_texto'),
  ('huer.ayuda_documentos_titulo', 'huer.ayuda_documentos_texto'),
  ('huer.ayuda_guia_titulo', 'huer.ayuda_guia_texto'),
  ('huer.ayuda_ia_titulo', 'huer.ayuda_ia_texto'),
  ('huer.ayuda_economia_titulo', 'huer.ayuda_economia_texto'),
  ('huer.ayuda_limites_titulo', 'huer.ayuda_limites_texto'),
];

class PantallaAyuda extends StatelessWidget {
  const PantallaAyuda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('huer.ayuda'))),
      body: ListView(
        children: [
          for (final (titulo, texto) in apartadosAyudaHuerta)
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
