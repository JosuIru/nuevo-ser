import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

/// Apartados de la ayuda, en orden: (clave del título, clave del texto).
const List<(String, String)> apartadosAyudaGanadera = [
  ('gana.ayuda_empezar_titulo', 'gana.ayuda_empezar_texto'),
  ('gana.ayuda_pastos_titulo', 'gana.ayuda_pastos_texto'),
  ('gana.ayuda_rebanos_titulo', 'gana.ayuda_rebanos_texto'),
  ('gana.ayuda_tratamientos_titulo', 'gana.ayuda_tratamientos_texto'),
  ('gana.ayuda_ecoregimen_titulo', 'gana.ayuda_ecoregimen_texto'),
  ('gana.ayuda_documentos_titulo', 'gana.ayuda_documentos_texto'),
  ('gana.ayuda_ia_titulo', 'gana.ayuda_ia_texto'),
  ('gana.ayuda_datos_titulo', 'gana.ayuda_datos_texto'),
  ('gana.ayuda_limites_titulo', 'gana.ayuda_limites_texto'),
];

class PantallaAyuda extends StatelessWidget {
  const PantallaAyuda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('gana.ayuda'))),
      body: ListView(
        children: [
          for (final (titulo, texto) in apartadosAyudaGanadera)
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
