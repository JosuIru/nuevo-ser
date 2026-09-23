import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show CapaAudio;

import '../../dominio/minijuegos/canales.dart' show Direccion;

import '../../sonido/servicio_sonoro.dart';

import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';

/// Marco común de las máquinas de Rexán: cabecera con el nombre y la
/// ronda (sin puntos), la línea de Rexán y, al terminar la partida, el
/// cierre amable con un único botón para volver.
class MarcoMinijuego extends StatelessWidget {
  final String titulo;
  final int ronda;
  final int rondasTotales;
  final String lineaRexan;
  final bool terminada;
  final Widget child;

  const MarcoMinijuego({
    super.key,
    required this.titulo,
    required this.ronda,
    required this.rondasTotales,
    required this.lineaRexan,
    required this.terminada,
    required this.child,
  });

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: PaletaNeon.textoTenue, size: 20),
                    onPressed: () => Navigator.of(contexto).pop(),
                  ),
                  Expanded(
                    child: Text(
                      traducirNarrativa(titulo, locale).toUpperCase(),
                      style: const TextStyle(
                        color: PaletaNeon.textoPrincipal,
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  if (!terminada)
                    Text(
                      '$ronda / $rondasTotales',
                      style: TextStyle(
                        color: PaletaNeon.textoTenue.withOpacity(0.8),
                        fontSize: 13,
                        letterSpacing: 1.5,
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 0, 8),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    '“$lineaRexan”\n— Rexán',
                    key: ValueKey(lineaRexan),
                    style: TextStyle(
                      color: PaletaNeon.textoTenue.withOpacity(0.85),
                      fontSize: 13,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: terminada
                      ? Center(
                          child: BotonMinijuego(
                            texto: traducirNarrativa('VOLVER', locale),
                            alPulsar: () => Navigator.of(contexto).pop(),
                          ),
                        )
                      : child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Música de cada máquina mientras se juega: se enciende al entrar y
/// se apaga con fundido al salir, como la de los combates.
mixin MusicaDeMaquina<T extends StatefulWidget> on State<T> {
  String get idMusica;

  @override
  void initState() {
    super.initState();
    ServicioSonoro.instancia.reproducirLoop(idMusica, msFade: 1500);
  }

  @override
  void dispose() {
    ServicioSonoro.instancia.detenerCapa(CapaAudio.musica, msFade: 1200);
    super.dispose();
  }

  void sonar(String idEfecto) =>
      ServicioSonoro.instancia.reproducirEfecto(idEfecto);
}

class BotonMinijuego extends StatelessWidget {
  final String texto;
  final VoidCallback? alPulsar;

  const BotonMinijuego({super.key, required this.texto, this.alPulsar});

  @override
  Widget build(BuildContext contexto) {
    final activo = alPulsar != null;
    return GestureDetector(
      onTap: alPulsar,
      child: AnimatedOpacity(
        opacity: activo ? 1 : 0.35,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: PaletaNeon.ambarCanales, width: 1.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            texto,
            style: const TextStyle(
              color: PaletaNeon.ambarCanales,
              fontSize: 13,
              letterSpacing: 2.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// Cruceta de cuatro direcciones (Canales, Serpiente). Reacciona al
/// apoyar el dedo, no al soltarlo: en un juego con reloj cuenta.
class CrucetaMinijuego extends StatelessWidget {
  final void Function(Direccion) alPulsar;

  const CrucetaMinijuego({super.key, required this.alPulsar});

  Widget _boton(Direccion direccion, IconData icono) => GestureDetector(
        key: ValueKey('cruceta-${direccion.name}'),
        onTapDown: (_) => alPulsar(direccion),
        child: Container(
          width: 54,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: PaletaNeon.violetaBase),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icono, color: PaletaNeon.textoTenue, size: 22),
        ),
      );

  @override
  Widget build(BuildContext contexto) {
    return Column(
      children: [
        _boton(Direccion.arriba, Icons.keyboard_arrow_up),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _boton(Direccion.izquierda, Icons.keyboard_arrow_left),
            const SizedBox(width: 62),
            _boton(Direccion.derecha, Icons.keyboard_arrow_right),
          ],
        ),
        const SizedBox(height: 4),
        _boton(Direccion.abajo, Icons.keyboard_arrow_down),
      ],
    );
  }
}
