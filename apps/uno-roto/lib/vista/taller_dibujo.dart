import 'package:flutter/material.dart';

import '../datos/dibujos_taller.dart';
import '../datos/repositorio_progreso.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';
import 'pantalla_encuadre.dart';

/// El taller de dibujo, lado de la pantalla: la hoja que invita a
/// dibujar (foto o galería) y lo que pasa después. [invitacion] va en
/// castellano con `{n}` para el nombre; se traduce aquí.
Future<void> dibujarEnElTaller(
  BuildContext contexto, {
  required ColeccionDibujos coleccion,
  required RepositorioProgreso repositorio,
  required String id,
  required String nombre,
  required String invitacion,
}) async {
  final locale = Localizations.localeOf(contexto);
  final conCamara = await showModalBottomSheet<bool>(
    context: contexto,
    backgroundColor: PaletaNeon.fondoMedio,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (hoja) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              traducirNarrativa(invitacion, locale)
                  .replaceAll('{n}', traducirNarrativa(nombre, locale)),
              style: const TextStyle(
                  color: PaletaNeon.textoPrincipal, fontSize: 14, height: 1.45),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey('dibujo-camara'),
              onPressed: () => Navigator.of(hoja).pop(true),
              icon: const Icon(Icons.photo_camera_outlined),
              label:
                  Text(traducirNarrativa('Hacer una foto a mi dibujo', locale)),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const ValueKey('dibujo-galeria'),
              onPressed: () => Navigator.of(hoja).pop(false),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(traducirNarrativa('Elegir de la galería', locale)),
            ),
          ],
        ),
      ),
    ),
  );
  if (conCamara == null || !contexto.mounted) return;
  String? aviso;
  try {
    await coleccion.elegir(
      repositorio,
      id,
      conCamara: conCamara,
      // El niño ajusta el encuadre antes de guardar.
      encuadrar: (foto, sugerido) => Navigator.of(contexto).push<Rect>(
        MaterialPageRoute(builder: (_) => PantallaEncuadre(foto: foto, sugerido: sugerido)),
      ),
    );
  } on DibujoSinContenido {
    aviso =
        'No he encontrado el dibujo en esa foto. Prueba con más luz y con el papel entero.';
  } catch (_) {
    aviso = 'No se ha podido abrir la cámara ni la galería.';
  }
  if (aviso != null && contexto.mounted) {
    ScaffoldMessenger.of(contexto).showSnackBar(
        SnackBar(content: Text(traducirNarrativa(aviso, locale))));
  }
}

/// Los botones del taller en una ficha: «Dibujarlo» o «Cambiar el
/// dibujo» y, si hay dibujo, «Volver al original».
class BotonesTaller extends StatelessWidget {
  final String id;
  final bool tieneDibujo;
  final Color color;
  final VoidCallback alDibujar;
  final VoidCallback alQuitar;

  const BotonesTaller({
    super.key,
    required this.id,
    required this.tieneDibujo,
    required this.color,
    required this.alDibujar,
    required this.alQuitar,
  });

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    return Wrap(
      spacing: 4,
      children: [
        TextButton.icon(
          key: ValueKey('dibujar-$id'),
          onPressed: alDibujar,
          icon: Icon(Icons.brush_outlined, size: 16, color: color),
          label: Text(
            traducirNarrativa(
                tieneDibujo ? 'Cambiar el dibujo' : 'Dibujarlo', locale),
            style: TextStyle(color: color, fontSize: 12, letterSpacing: 1),
          ),
        ),
        if (tieneDibujo)
          TextButton(
            key: ValueKey('quitar-dibujo-$id'),
            onPressed: alQuitar,
            child: Text(
              traducirNarrativa('Volver al original', locale),
              style: TextStyle(
                  color: PaletaNeon.textoTenue.withOpacity(0.8), fontSize: 12),
            ),
          ),
      ],
    );
  }
}
