import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../servicios/servicio_commons.dart';

/// Muestra una imagen de Wikimedia Commons con su pie de atribución
/// obligatorio (autor + licencia + enlace a Commons). Cumplir esto es
/// la condición que las licencias CC y equivalentes exigen para uso
/// comercial — sin atribución la app estaría infringiendo.
///
/// Si la búsqueda no encuentra imagen con licencia compatible, no
/// renderiza nada (devuelve `SizedBox.shrink`). El padre debe
/// proporcionar su propio placeholder visual (icono del cultivo,
/// emoji, etc.).
class ImagenCommonsWidget extends StatefulWidget {
  /// Título del artículo en Wikipedia (ej. 'Olea_europaea',
  /// 'Tuber_melanosporum'). Se usa para pedir la lead image del
  /// artículo del taxón.
  final String tituloWikipedia;

  /// Término científico de búsqueda libre en Commons como fallback
  /// si la lead image del artículo no está disponible o es un mapa.
  /// Típicamente coincide con el nombre científico de la especie.
  final String terminoBusqueda;

  /// Altura fija de la imagen (la atribución va debajo).
  final double altura;

  const ImagenCommonsWidget({
    super.key,
    required this.tituloWikipedia,
    required this.terminoBusqueda,
    this.altura = 200,
  });

  @override
  State<ImagenCommonsWidget> createState() => _ImagenCommonsWidgetState();
}

class _ImagenCommonsWidgetState extends State<ImagenCommonsWidget> {
  late Future<ImagenCommons?> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = buscarImagenLibreParaCultivo(widget.tituloWikipedia, termino: widget.terminoBusqueda);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImagenCommons?>(
      future: _futuro,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: widget.altura,
            alignment: Alignment.center,
            color: Colors.black12,
            child: const CircularProgressIndicator(),
          );
        }
        final imagen = snapshot.data;
        if (imagen == null) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imagen.urlThumb,
                height: widget.altura,
                fit: BoxFit.cover,
                memCacheWidth: 1200,
                placeholder: (_, __) => Container(
                  height: widget.altura,
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: widget.altura,
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, size: 48, color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Pie de atribución obligatorio. Tap → abre la página de
            // Commons para que el usuario pueda comprobar la licencia
            // y el autor original.
            InkWell(
              onTap: () async {
                final uri = Uri.tryParse(imagen.urlPaginaDescripcion);
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    const Icon(Icons.copyright, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        SoleraL10n.tf('viti.credito_foto_commons', {
                          'autor': imagen.autorTexto,
                          'licencia': imagen.licenciaCorta,
                        }),
                        style: const TextStyle(fontSize: 11, color: Colors.grey, decoration: TextDecoration.underline),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
