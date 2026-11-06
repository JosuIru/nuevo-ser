import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../branding.dart';
import '../l10n/app_localizations.dart';
import 'widgets/curvas_de_nivel.dart';
import 'widgets/relleno_seguro.dart';

/// Información pública sobre el Espacio Test Agrario Zunbeltz y enlaces a las
/// fuentes oficiales. Da contexto a quien usa la app por primera vez.
class PantallaAcercaEspacioTest extends StatelessWidget {
  const PantallaAcercaEspacioTest({super.key});

  static const _enlaces = <_Enlace>[
    _Enlace('zunbeltz.com', 'https://zunbeltz.com/'),
    _Enlace('Guesálaz · Zunbeltz',
        'http://www.guesalaz.es/zunbeltz-espacio-test-agrario/'),
    _Enlace('Mancomunidad de Andía',
        'https://andiamank.com/proyecto/espacio-test-agrario-zunbeltz/'),
    _Enlace('Red de Espacios Test Agrarios (RETA)',
        'https://espaciostestagrarios.org/'),
  ];

  Future<void> _abrir(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// «https://www.guesalaz.es/zunbeltz/» → «guesalaz.es/zunbeltz».
  static String _sinProtocolo(String url) => url
      .replaceFirst(RegExp(r'^https?://(www\.)?'), '')
      .replaceFirst(RegExp(r'/$'), '');

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final colores = context.coloresZunbeltz;
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final arriba = MediaQuery.paddingOf(context).top;
    // Los párrafos del texto, separados.
    final parrafos = textos.acercaIntro
        .split(RegExp(r'\n\s*\n|\n'))
        .where((parrafo) => parrafo.trim().isNotEmpty);
    // Iconos de la barra de estado en claro, sobre la cabecera verde.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28)),
              child: Container(
                color: colores.cabecera,
                child: Stack(children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: CurvasDeNivel(
                          color: colores.sobreCabecera.withValues(alpha: 0.12)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, arriba + 4, 24, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BackButton(color: colores.sobreCabecera),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SimboloZunbeltz(
                                  tamano: 72,
                                  color: colores.sobreCabecera
                                      .withValues(alpha: 0.9),
                                  semanticLabel: 'Zunbeltz'),
                              const SizedBox(height: 12),
                              Text('Zunbeltz',
                                  style: estilos.displaySmall?.copyWith(
                                      color: colores.sobreCabecera,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              Text(textos.acercaAsociacion,
                                  style: estilos.bodyMedium?.copyWith(
                                      color: colores.sobreCabeceraVariante)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            Padding(
              padding: rellenoSobreBarraSistema(
                  context, const EdgeInsets.fromLTRB(24, 24, 24, 24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final parrafo in parrafos)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(parrafo.trim(), style: estilos.bodyLarge),
                    ),
                  const SizedBox(height: 12),
                  Text(textos.acercaEnlaces, style: estilos.titleLarge),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: esquema.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(children: [
                      for (var indice = 0;
                          indice < _enlaces.length;
                          indice++) ...[
                        if (indice > 0)
                          Divider(
                              height: 1,
                              indent: 64,
                              endIndent: 16,
                              color: esquema.outlineVariant),
                        ListTile(
                          contentPadding:
                              const EdgeInsets.fromLTRB(20, 6, 16, 6),
                          leading: const Icon(Icons.public),
                          title: Text(_enlaces[indice].titulo,
                              style: estilos.titleMedium),
                          subtitle: Text(_sinProtocolo(_enlaces[indice].url)),
                          trailing: const Icon(Icons.open_in_new),
                          onTap: () => _abrir(_enlaces[indice].url),
                        ),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Text(textos.acercaFuentes,
                      style: estilos.bodySmall
                          ?.copyWith(color: esquema.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Enlace {
  const _Enlace(this.titulo, this.url);
  final String titulo;
  final String url;
}
