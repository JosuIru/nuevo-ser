import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'checker_actualizaciones.dart';

/// Banner sticky para anunciar una versión disponible. Pensado para
/// colocarse en la cabecera de las pantallas de inicio de cada app.
/// Con [alTocar] (lo que pone [AvisoActualizaciones]) abre la pantalla
/// de actualizaciones, que descarga e instala desde la app; sin él,
/// abre el enlace del APK en el navegador, como antes.
class BannerActualizacionDisponible extends StatelessWidget {
  final ActualizacionDisponible actualizacion;

  /// Callback opcional al pulsar la X de descartar. Si está presente
  /// se muestra el botón.
  final VoidCallback? onDescartar;

  /// Estilo del banner. `compacto` cabe junto a un AppBar; `expandido`
  /// llena el ancho con padding generoso.
  final bool compacto;

  /// Qué hacer al tocarlo. Por defecto, abrir el enlace del APK.
  final VoidCallback? alTocar;

  /// Traductor de los textos (castellano por defecto).
  final String Function(String textoEs)? traducir;

  const BannerActualizacionDisponible({
    super.key,
    required this.actualizacion,
    this.onDescartar,
    this.compacto = false,
    this.alTocar,
    this.traducir,
  });

  String _t(String texto) => traducir?.call(texto) ?? texto;

  Future<void> _abrirDescarga() async {
    if (alTocar != null) return alTocar!();
    final url = Uri.tryParse(actualizacion.urlAsset);
    if (url == null) return;
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = compacto
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : const EdgeInsets.all(14);
    return Material(
      color: theme.colorScheme.primary.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _abrirDescarga,
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              Icon(Icons.system_update,
                  size: compacto ? 18 : 22, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_t('Versión disponible')}: ${actualizacion.versionDisponible}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: compacto ? 12 : 14,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (!compacto) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${_t('Tienes instalada la')} ${actualizacion.versionInstalada}. '
                        '${_t('Toca para actualizar.')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: _abrirDescarga,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: compacto ? 10 : 14,
                    vertical: compacto ? 4 : 8,
                  ),
                ),
                child: Text(
                  _t('Actualizar'),
                  style: TextStyle(fontSize: compacto ? 12 : 13),
                ),
              ),
              if (onDescartar != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onDescartar,
                  tooltip: _t('Descartar por ahora'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
