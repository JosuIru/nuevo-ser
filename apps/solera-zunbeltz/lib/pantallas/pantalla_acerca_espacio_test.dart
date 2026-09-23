import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import 'widgets/relleno_seguro.dart';

/// Información pública sobre el Espacio Test Agrario Zunbeltz y enlaces a las
/// fuentes oficiales. Da contexto a quien usa la app por primera vez.
class PantallaAcercaEspacioTest extends StatelessWidget {
  const PantallaAcercaEspacioTest({super.key});

  static const _enlaces = <_Enlace>[
    _Enlace('Guesálaz · Zunbeltz',
        'http://www.guesalaz.es/zunbeltz-espacio-test-agrario/'),
    _Enlace('Mancomunidad de Andía',
        'https://andiamank.com/proyecto/espacio-test-agrario-zunbeltz/'),
    _Enlace('zunbeltz.com', 'https://zunbeltz.com/'),
    _Enlace(
        'Red de Espacios Test Agrarios (RETA)', 'https://espaciostestagrarios.org/'),
  ];

  Future<void> _abrir(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(textos.acercaTitulo)),
      body: ListView(
        padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
        children: [
          Text(textos.acercaIntro,
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          Text(textos.acercaEnlaces,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          for (final e in _enlaces)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.link),
              title: Text(e.titulo),
              subtitle: Text(e.url),
              onTap: () => _abrir(e.url),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(textos.acercaFuentes,
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _Enlace {
  const _Enlace(this.titulo, this.url);
  final String titulo;
  final String url;
}
