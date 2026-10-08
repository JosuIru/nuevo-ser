import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../branding.dart';
import '../l10n/app_localizations.dart';
import '../modelos/noticia_sector.dart';
import '../servicios/servicio_noticias_sector.dart';

/// Todas las noticias del sector que ha bajado el dispositivo (las de los
/// canales RSS que elige coordinación en el panel). Tirar hacia abajo
/// vuelve a pedirlas al servidor.
class PantallaNoticiasSector extends StatefulWidget {
  const PantallaNoticiasSector({super.key, this.servicio});

  /// Para tests; si no, uno nuevo.
  final ServicioNoticiasSector? servicio;

  @override
  State<PantallaNoticiasSector> createState() => _PantallaNoticiasSectorState();
}

class _PantallaNoticiasSectorState extends State<PantallaNoticiasSector> {
  late final ServicioNoticiasSector _servicio =
      widget.servicio ?? ServicioNoticiasSector();

  @override
  void initState() {
    super.initState();
    _servicio.actualizar();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(textos.noticiasSectorTitulo)),
      body: ValueListenableBuilder<NoticiasSectorGuardadas>(
        valueListenable: ServicioNoticiasSector.actuales,
        builder: (contexto, guardadas, _) => RefreshIndicator(
          onRefresh: () => _servicio.actualizar(forzar: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (guardadas.noticias.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(textos.noticiasSectorVacio),
                )
              else
                for (final noticia in guardadas.noticias)
                  TarjetaNoticiaSector(noticia, conEntradilla: true),
              if (guardadas.actualizadoMs > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    textos.noticiasSectorActualizadas(
                        DateFormat('dd/MM HH:mm', idioma).format(
                            DateTime.fromMillisecondsSinceEpoch(
                                guardadas.actualizadoMs))),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Una noticia del sector: fuente y fecha, titular y (en la lista
/// completa) la entradilla. Al tocarla se abre el original en el
/// navegador.
class TarjetaNoticiaSector extends StatelessWidget {
  const TarjetaNoticiaSector(this.noticia,
      {super.key, this.conEntradilla = false});

  final NoticiaSector noticia;
  final bool conEntradilla;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final estiloTexto = Theme.of(context).textTheme;
    final cabecera = [
      if (noticia.fijada) textos.noticiasSectorDestacada,
      noticia.fuente,
      if (noticia.fechaMs > 0)
        DateFormat('dd/MM/yyyy', idioma)
            .format(DateTime.fromMillisecondsSinceEpoch(noticia.fechaMs)),
    ].where((parte) => parte.isNotEmpty).join(' · ');
    return Card(
      child: InkWell(
        onTap: () => _abrir(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cabecera,
                  style: estiloTexto.labelSmall?.copyWith(
                      color: noticia.fijada
                          ? colorSenalZunbeltz
                          : colorTintaApagadaZunbeltz)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child:
                          Text(noticia.titulo, style: estiloTexto.titleSmall)),
                  const SizedBox(width: 8),
                  const Icon(Icons.open_in_new, size: 16),
                ],
              ),
              if (conEntradilla && noticia.entradilla.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(noticia.entradilla, style: estiloTexto.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrir(BuildContext context) async {
    final mensajero = ScaffoldMessenger.of(context);
    final textoError = AppLocalizations.of(context).noticiasSectorSinAbrir;
    var abierta = false;
    try {
      abierta = await launchUrl(Uri.parse(noticia.enlace),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      abierta = false;
    }
    if (!abierta) {
      mensajero.showSnackBar(SnackBar(content: Text(textoError)));
    }
  }
}
