import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/parejas.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// Parejas — máquina de Rexán. Cartas boca arriba: se tocan dos que
/// valen lo mismo y se retiran; si no, tiemblan y se sigue. Al acabar
/// cada tablero registra un resultado por habilidad presente.
class PantallaParejas extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final List<String> habilidadesPracticadas;
  final int? semilla;

  const PantallaParejas({
    super.key,
    required this.registro,
    required this.dificultad,
    required this.habilidadesPracticadas,
    this.semilla,
  });

  @override
  State<PantallaParejas> createState() => _PantallaParejasState();
}

class _PantallaParejasState extends State<PantallaParejas>
    with SingleTickerProviderStateMixin, MusicaDeMaquina {
  @override
  String get idMusica => 'musica_maquina_parejas';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.parejas);

  late final GeneradorParejas _generador;
  late final AnimationController _temblor;
  late TableroParejas _tablero;
  int _ronda = 1;
  int? _elegida;
  Set<int> _temblando = const {};
  String? _lineaRexan;
  bool _terminada = false;
  DateTime _inicioTablero = DateTime.now();

  @override
  void initState() {
    super.initState();
    _generador = GeneradorParejas(semilla: widget.semilla);
    _temblor = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _nuevoTablero();
  }

  @override
  void dispose() {
    _temblor.dispose();
    super.dispose();
  }

  void _nuevoTablero() {
    _tablero = _generador.generar(widget.habilidadesPracticadas,
        dificultad: widget.dificultad);
    _elegida = null;
    _inicioTablero = DateTime.now();
  }

  void _tocar(int indice) {
    if (_tablero.retiradas.contains(indice) || _terminada) return;
    final elegida = _elegida;
    if (elegida == null || elegida == indice) {
      HapticFeedback.selectionClick();
      setState(() => _elegida = elegida == indice ? null : indice);
      return;
    }
    final acierta = _tablero.emparejar(elegida, indice);
    if (acierta) {
      HapticFeedback.lightImpact();
      sonar('efecto_fila_completa');
      setState(() {
        _elegida = null;
        _lineaRexan = null;
      });
      if (_tablero.completo) _terminarTablero();
    } else {
      HapticFeedback.vibrate();
      sonar('efecto_error');
      setState(() {
        _temblando = {elegida, indice};
        _elegida = null;
        _lineaRexan = 'Esas dos no valen lo mismo.';
      });
      _temblor.forward(from: 0).whenComplete(() {
        if (mounted) setState(() => _temblando = const {});
      });
    }
  }

  void _terminarTablero() {
    sonar('efecto_acierto');
    final duracion = DateTime.now().difference(_inicioTablero);
    _tablero.aciertoPorHabilidad.forEach((habilidad, acierto) {
      widget.registro?.registrar(
        idHabilidad: habilidad,
        acierto: acierto,
        dificultad: 0.8 + 0.3 * widget.dificultad,
        duracion: duracion,
      );
    });
    if (_ronda >= _definicion.rondasPorPartida) {
      setState(() => _terminada = true);
      return;
    }
    setState(() => _lineaRexan = 'Tablero limpio.');
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _ronda++;
        _lineaRexan = null;
        _nuevoTablero();
      });
    });
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final linea = _terminada
        ? 'Tres tableros. Ya sabes que una misma cosa tiene muchos nombres.'
        : _lineaRexan ?? _definicion.lineaRexan;
    final columnas = 4;
    return MarcoMinijuego(
      titulo: _definicion.nombre,
      ronda: _ronda,
      rondasTotales: _definicion.rondasPorPartida,
      lineaRexan: traducirNarrativa(linea, locale),
      terminada: _terminada,
      child: AnimatedBuilder(
        animation: _temblor,
        builder: (_, __) => GridView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.78,
          ),
          itemCount: _tablero.cartas.length,
          itemBuilder: (_, indice) {
            final retirada = _tablero.retiradas.contains(indice);
            final desplazamiento = _temblando.contains(indice)
                ? math.sin(_temblor.value * math.pi * 6) * 6 * (1 - _temblor.value)
                : 0.0;
            return Transform.translate(
              offset: Offset(desplazamiento, 0),
              child: AnimatedOpacity(
                opacity: retirada ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: _Carta(
                  key: ValueKey('carta-$indice'),
                  etiqueta: _tablero.cartas[indice].etiqueta,
                  elegida: _elegida == indice,
                  alTocar: retirada ? null : () => _tocar(indice),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Carta extends StatelessWidget {
  final String etiqueta;
  final bool elegida;
  final VoidCallback? alTocar;

  const _Carta({
    super.key,
    required this.etiqueta,
    required this.elegida,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext contexto) {
    return GestureDetector(
      onTap: alTocar,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: elegida
              ? PaletaNeon.ambarCanales.withOpacity(0.22)
              : PaletaNeon.fondoMedio.withOpacity(0.85),
          border: Border.all(
            color: elegida
                ? PaletaNeon.ambarCanales
                : PaletaNeon.violetaBase.withOpacity(0.7),
            width: elegida ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              etiqueta,
              style: const TextStyle(
                color: PaletaNeon.textoPrincipal,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
