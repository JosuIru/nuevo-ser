import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show CapaAudio;

import '../../dominio/minijuegos/ayudas_maquinas.dart';
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

  /// Botón de ayuda: cómo se juega y el truco de la habilidad en juego.
  final String? comoSeJuega;
  final String? idHabilidadActual;

  /// Para los juegos con reloj: se pausa mientras la ayuda está abierta.
  final VoidCallback? alPausar;
  final VoidCallback? alReanudar;

  /// Tras dos fallos seguidos, Rexán ofrece la ayuda (no la abre sola).
  final bool ofrecerPista;
  final VoidCallback? alAbrirAyuda;

  const MarcoMinijuego({
    super.key,
    required this.titulo,
    required this.ronda,
    required this.rondasTotales,
    required this.lineaRexan,
    required this.terminada,
    required this.child,
    this.comoSeJuega,
    this.idHabilidadActual,
    this.alPausar,
    this.alReanudar,
    this.ofrecerPista = false,
    this.alAbrirAyuda,
  });

  Future<void> _abrirAyuda(BuildContext contexto) async {
    final locale = Localizations.localeOf(contexto);
    final truco = idHabilidadActual == null ? null : trucosPorHabilidad[idHabilidadActual];
    alAbrirAyuda?.call();
    alPausar?.call();
    await showModalBottomSheet<void>(
      context: contexto,
      backgroundColor: PaletaNeon.fondoMedio,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (hoja) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (titulo, texto) in [
                if (comoSeJuega != null) ('CÓMO SE JUEGA', comoSeJuega!),
                if (truco != null) ('EL TRUCO', truco),
              ]) ...[
                Text(
                  traducirNarrativa(titulo, locale),
                  style: TextStyle(
                    color: PaletaNeon.ambarCanales.withOpacity(0.9),
                    fontSize: 11,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  traducirNarrativa(texto, locale),
                  style: const TextStyle(
                    color: PaletaNeon.textoPrincipal,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: BotonMinijuego(
                  texto: traducirNarrativa('SEGUIR', locale),
                  alPulsar: () => Navigator.of(hoja).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    alReanudar?.call();
  }

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
                  if (!terminada && comoSeJuega != null)
                    IconButton(
                      key: const ValueKey('ayuda-maquina'),
                      tooltip: traducirNarrativa('Ayuda', locale),
                      icon: const Icon(Icons.help_outline,
                          color: PaletaNeon.textoTenue, size: 20),
                      onPressed: () => _abrirAyuda(contexto),
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
              if (ofrecerPista && !terminada && comoSeJuega != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 0, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _ChipPista(
                      texto: traducirNarrativa('¿Te echo una mano?', locale),
                      alPulsar: () => _abrirAyuda(contexto),
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

/// Botón discreto que late suave: Rexán ofrece ayuda, no la impone.
class _ChipPista extends StatefulWidget {
  final String texto;
  final VoidCallback alPulsar;

  const _ChipPista({required this.texto, required this.alPulsar});

  @override
  State<_ChipPista> createState() => _ChipPistaState();
}

class _ChipPistaState extends State<_ChipPista> with SingleTickerProviderStateMixin {
  late final AnimationController _latido = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _latido.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext contexto) => AnimatedBuilder(
        animation: _latido,
        builder: (_, hijo) => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: PaletaNeon.ambarCanales
                    .withOpacity(0.45 + 0.4 * _latido.value)),
          ),
          child: hijo,
        ),
        child: InkWell(
          key: const ValueKey('pista-ofrecida'),
          borderRadius: BorderRadius.circular(20),
          onTap: widget.alPulsar,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lightbulb_outline,
                    size: 16, color: PaletaNeon.ambarCanales),
                const SizedBox(width: 6),
                Text(widget.texto,
                    style: const TextStyle(
                        color: PaletaNeon.ambarCanales, fontSize: 13)),
              ],
            ),
          ),
        ),
      );
}

/// Cuenta los fallos seguidos de una máquina. Con dos, el marco ofrece
/// la ayuda; un acierto o abrir la ayuda ponen la cuenta a cero. No
/// toca la maestría: el truco explica el método, no da la respuesta.
mixin PistaTrasFallos<T extends StatefulWidget> on State<T> {
  int _fallosSeguidos = 0;

  bool get ofrecerPista => _fallosSeguidos >= 2;

  /// Llamar dentro de un setState (o seguido de uno).
  void anotarFallo() => _fallosSeguidos++;
  void anotarAcierto() => _fallosSeguidos = 0;

  void pistaAtendida() {
    if (mounted) setState(() => _fallosSeguidos = 0);
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
