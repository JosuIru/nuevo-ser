import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../datos/base_datos.dart';
import '../../l10n/app_localizations.dart';
import '../../servicios/servicio_fotos_sync.dart';
import '../../servicios/servicio_fotos_web.dart';
import '../../utiles/fotos_sincronizadas.dart';

/// Miniatura de una entrada de fotos (ver `utiles/fotos_sincronizadas.dart`):
/// una ruta de este móvil se ve tal cual; una referencia `foto:<hash>`, si
/// ya bajó, también; si no, sale el marcador «Sin descargar» y al tocarlo
/// se baja (con la red que haya: la persona lo ha pedido). Una foto que ya
/// se ve se abre a pantalla completa. En el navegador las fotos están en la
/// BD (`servicio_fotos_web.dart`), no en ficheros.
class MiniaturaFoto extends StatefulWidget {
  const MiniaturaFoto({
    super.key,
    required this.entrada,
    this.tamano = 96,
    this.alQuitar,
  });

  final String entrada;
  final double tamano;

  /// Si no es null, sale la cruz para quitarla (formularios).
  final VoidCallback? alQuitar;

  @override
  State<MiniaturaFoto> createState() => _MiniaturaFotoState();
}

class _MiniaturaFotoState extends State<MiniaturaFoto> {
  ImageProvider? _imagen;
  bool _resuelta = false;
  bool _bajando = false;

  @override
  void initState() {
    super.initState();
    _resolver();
  }

  @override
  void didUpdateWidget(MiniaturaFoto anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.entrada != widget.entrada) _resolver();
  }

  Future<void> _resolver() async {
    final hash = hashDeReferencia(widget.entrada);
    ImageProvider? imagen;
    if (hash == null) {
      // Una ruta de fichero (en el navegador no hay).
      if (!kIsWeb) imagen = FileImage(File(widget.entrada));
    } else if (kIsWeb) {
      final bytes = await bytesFotoWebGuardada(hash);
      if (bytes != null) imagen = MemoryImage(bytes);
    } else {
      try {
        final local = await BaseDatosSoleraZunbeltz().rutaLocalDeFoto(hash);
        if (local != null && await File(local).exists()) {
          imagen = FileImage(File(local));
        }
      } catch (_) {
        imagen = null;
      }
    }
    if (!mounted) return;
    setState(() {
      _imagen = imagen;
      _resuelta = true;
    });
  }

  Future<void> _bajar(String hash) async {
    if (_bajando) return;
    setState(() => _bajando = true);
    final ImageProvider? imagen;
    if (kIsWeb) {
      final bytes = await bajarFotoWebAhora(hash);
      imagen = bytes == null ? null : MemoryImage(bytes);
    } else {
      final ruta = await bajarFotoAhora(hash);
      imagen = ruta == null ? null : FileImage(File(ruta));
    }
    if (!mounted) return;
    setState(() {
      _bajando = false;
      if (imagen != null) _imagen = imagen;
    });
    if (imagen == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).fotoNoSeHaPodidoBajar)));
    }
  }

  void _verEnGrande(ImageProvider imagen) {
    showDialog<void>(
      context: context,
      builder: (contexto) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                child: Image(image: imagen, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: SafeArea(
                child: IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.close),
                  tooltip:
                      MaterialLocalizations.of(contexto).closeButtonTooltip,
                  onPressed: () => Navigator.pop(contexto),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tema = Theme.of(context);
    final tamano = widget.tamano;
    final hash = hashDeReferencia(widget.entrada);
    final imagen = _imagen;

    final Widget contenido;
    if (!_resuelta) {
      contenido = SizedBox(width: tamano, height: tamano);
    } else if (imagen != null) {
      contenido = InkWell(
        onTap: () => _verEnGrande(imagen),
        child: Image(
          image: ResizeImage.resizeIfNeeded((tamano * 3).round(), null, imagen),
          width: tamano,
          height: tamano,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _hueco(tema, const Icon(Icons.broken_image)),
        ),
      );
    } else if (hash != null) {
      contenido = Tooltip(
        message: textos.fotoSinDescargarDetalle,
        child: InkWell(
          onTap: () => _bajar(hash),
          child: _hueco(
            tema,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _bajando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_download_outlined),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    _bajando ? textos.fotoBajando : textos.fotoSinDescargar,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      contenido = _hueco(tema, const Icon(Icons.broken_image));
    }

    return SizedBox(
      width: tamano,
      height: tamano,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: contenido,
          ),
          if (widget.alQuitar != null)
            Positioned(
              right: 2,
              top: 2,
              child: Tooltip(
                message: textos.fotoQuitar,
                child: InkWell(
                  onTap: widget.alQuitar,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                        color: Colors.black54, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _hueco(ThemeData tema, Widget dentro) => Container(
        width: widget.tamano,
        height: widget.tamano,
        color: tema.colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: dentro,
      );
}

/// Tira de fotos de solo lectura (fichas). No ocupa nada si no hay fotos.
class GaleriaFotos extends StatelessWidget {
  const GaleriaFotos({
    super.key,
    required this.entradas,
    this.titulo,
    this.tamano = 88,
  });

  final List<String> entradas;
  final String? titulo;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    if (entradas.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titulo != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child:
                  Text(titulo!, style: Theme.of(context).textTheme.labelLarge),
            ),
          SizedBox(
            height: tamano,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: entradas.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, indice) =>
                  MiniaturaFoto(entrada: entradas[indice], tamano: tamano),
            ),
          ),
        ],
      ),
    );
  }
}
