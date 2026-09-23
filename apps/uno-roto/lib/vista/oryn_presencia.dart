import 'package:flutter/material.dart';

import '../nucleo/paleta.dart';

/// Presencia de Oryn: maestro de Sora. Avatar en el centro inferior de
/// la pantalla — su rol es figura tutelar, no compañero (izquierda) ni
/// rival (derecha). Bocadillo encima.
///
/// Paleta canónica del concept-art (`docs/personajes/concept-art/oryn.pdf`):
/// cabeza envuelta en vendas blanco-lavanda con un solo ojo verde
/// visible, traje azul con sombras violeta, bandolera negra cruzada,
/// pantalón rojo terroso con franja verde lateral, botas altas negras.
class OrynPresencia extends StatelessWidget {
  final String? textoActivo;
  final VoidCallback? alTocarBocadillo;

  const OrynPresencia({
    super.key,
    required this.textoActivo,
    this.alTocarBocadillo,
  });

  @override
  Widget build(BuildContext contexto) {
    return SizedBox(
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          const Positioned(
            bottom: 0,
            child: _AvatarOryn(),
          ),
          if (textoActivo != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 180,
              child: _BocadilloOryn(
                texto: textoActivo!,
                alTocar: alTocarBocadillo,
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarOryn extends StatelessWidget {
  const _AvatarOryn();

  @override
  Widget build(BuildContext contexto) {
    // PNG escaneado del concept-art original (oryn.pdf). 170x200 —
    // un pelín más ancho que Kai porque la postura de guardia con
    // pies abiertos ocupa más, y el dibujo es vertical.
    return Image.asset(
      'assets/personajes/oryn.png',
      width: 170,
      height: 200,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}


class _BocadilloOryn extends StatelessWidget {
  final String texto;
  final VoidCallback? alTocar;

  const _BocadilloOryn({required this.texto, this.alTocar});

  @override
  Widget build(BuildContext contexto) {
    return GestureDetector(
      onTap: alTocar,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (hijo, animacion) => FadeTransition(
          opacity: animacion,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(animacion),
            child: hijo,
          ),
        ),
        child: Container(
          key: ValueKey(texto),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: PaletaNeon.fondoProfundo.withOpacity(0.85),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(
              color: PaletaNeon.exitoSuave.withOpacity(0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: PaletaNeon.exitoSuave.withOpacity(0.25),
                blurRadius: 14,
              ),
            ],
          ),
          child: Text(
            texto,
            style: const TextStyle(
              color: PaletaNeon.textoPrincipal,
              fontSize: 14,
              height: 1.4,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
