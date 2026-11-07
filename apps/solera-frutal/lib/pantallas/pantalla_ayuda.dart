import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

/// Apartados de la ayuda, en orden: (clave del título, clave del texto).
const List<(String, String)> apartadosAyudaFrutal = [
  ('frut.ayuda_empezar_titulo', 'frut.ayuda_empezar_texto'),
  ('frut.ayuda_parcelas_titulo', 'frut.ayuda_parcelas_texto'),
  ('frut.ayuda_cuaderno_titulo', 'frut.ayuda_cuaderno_texto'),
  ('frut.ayuda_cosecha_titulo', 'frut.ayuda_cosecha_texto'),
  ('frut.ayuda_helada_titulo', 'frut.ayuda_helada_texto'),
  ('frut.ayuda_documentos_titulo', 'frut.ayuda_documentos_texto'),
  ('frut.ayuda_ia_titulo', 'frut.ayuda_ia_texto'),
  ('frut.ayuda_economia_titulo', 'frut.ayuda_economia_texto'),
  ('frut.ayuda_limites_titulo', 'frut.ayuda_limites_texto'),
];

class PantallaAyuda extends StatelessWidget {
  const PantallaAyuda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('frut.ayuda'))),
      body: ListView(
        children: [
          for (final (titulo, texto) in apartadosAyudaFrutal)
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
