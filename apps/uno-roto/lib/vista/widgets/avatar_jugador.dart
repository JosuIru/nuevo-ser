import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../nucleo/paleta.dart';

/// Avatar del jugador dibujado a partir de la imagen que subió, o
/// fallback en blanco con icono de persona si todavía no hay foto.
///
/// Si [rutaImagen] es null o el fichero no existe, se pinta el
/// fallback. Si existe, se muestra recortado a círculo. El borde
/// violeta marca la identidad visual del juego.
class AvatarJugador extends StatelessWidget {
  final String? rutaImagen;
  final double tamano;
  final VoidCallback? alPulsar;

  const AvatarJugador({
    super.key,
    required this.rutaImagen,
    this.tamano = 56,
    this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    final hijo = Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: PaletaNeon.fondoMedio.withOpacity(0.85),
        border: Border.all(
          color: PaletaNeon.violetaNeon.withOpacity(0.7),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: PaletaNeon.violetaNeon.withOpacity(0.18),
            blurRadius: 8,
          ),
        ],
        image: _imagenValida()
            ? DecorationImage(
                image: FileImage(File(rutaImagen!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: _imagenValida()
          ? null
          : Icon(
              Icons.person,
              size: tamano * 0.55,
              color: PaletaNeon.violetaNeon.withOpacity(0.7),
            ),
    );
    if (alPulsar == null) return hijo;
    return InkWell(
      onTap: alPulsar,
      borderRadius: BorderRadius.circular(tamano),
      child: hijo,
    );
  }

  bool _imagenValida() {
    final ruta = rutaImagen;
    if (ruta == null || ruta.isEmpty) return false;
    // En web no hay sistema de ficheros: File() lanzaría.
    if (kIsWeb) return false;
    // No bloqueamos en sync (existsSync) por simplicidad — si el
    // fichero se borró desde fuera, FileImage falla en silencio y
    // el círculo sale gris.
    return true;
  }
}
