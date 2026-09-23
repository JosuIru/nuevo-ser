import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/minijuegos/niveles_maquinas.dart';
import '../../dominio/minijuegos/minas.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'marco_minijuego.dart';

/// Minas — máquina de Rexán: buscaminas de divisibilidad. Con el
/// selector ABRIR / MARCAR (o pulsación larga para marcar) el niño dice
/// "segura" o "mina" en cada casilla. Cada tablero registra un resultado
/// en la maestría (acierto con como mucho dos fallos).
class PantallaMinas extends StatefulWidget {
  final RegistroMaestriaMinijuego? registro;
  final int dificultad;
  final List<String> habilidadesPracticadas;
  final int? semilla;

  const PantallaMinas({
    super.key,
    required this.registro,
    required this.dificultad,
    required this.habilidadesPracticadas,
    this.semilla,
  });

  @override
  State<PantallaMinas> createState() => _PantallaMinasState();
}

class _PantallaMinasState extends State<PantallaMinas> with MusicaDeMaquina, PistaTrasFallos {
  @override
  String get idMusica => 'musica_maquina_minas';

  static final _definicion = CatalogoMinijuegos.de(IdMinijuego.minas);

  int get _nivel => nivelDeRonda(_ronda, _definicion.rondasPorPartida);

  /// Dificultad de las cuentas en esta ronda (sube con el nivel).
  ({int dificultad, int extra}) get _enNivel =>
      dificultadEnNivel(widget.dificultad, _nivel);

  late final math.Random _azar;
  late final List<String> _habilidades;
  late TableroMinas _tablero;
  int _ronda = 1;
  bool _marcando = false;
  /// Plantilla de la línea de Rexán (se traduce) y el número del último
  /// fallo, que se sustituye en `{n}` después de traducir.
  String? _lineaRexan;
  String _numeroFallo = '';
  bool _entreTableros = false;
  bool _terminada = false;
  DateTime _inicioTablero = DateTime.now();

  @override
  void initState() {
    super.initState();
    _azar = math.Random(widget.semilla);
    _habilidades = [
      for (final id in widget.habilidadesPracticadas)
        if (textosReglaMinas.containsKey(id)) id,
    ];
    if (_habilidades.isEmpty) _habilidades.add('DIV.01');
    _nuevoTablero();
  }

  void _nuevoTablero() {
    _tablero = TableroMinas.generar(
      idHabilidad: _habilidades[(_ronda - 1) % _habilidades.length],
      dificultad: _enNivel.dificultad,
      extra: _enNivel.extra,
      azar: _azar,
    );
    _entreTableros = false;
    _lineaRexan = null;
    _inicioTablero = DateTime.now();
  }

  void _jugar(int indice, {required bool marcar}) {
    if (_terminada || _entreTableros) return;
    final casilla = _tablero.casillas[indice];
    final resultado =
        marcar ? _tablero.marcar(indice) : _tablero.abrir(indice);
    if (resultado == ResultadoJugada.ninguno) return;
    setState(() {
      if (resultado == ResultadoJugada.bien) {
        HapticFeedback.selectionClick();
        sonar(marcar ? 'efecto_tablon' : 'efecto_tap');
        anotarAcierto();
        _lineaRexan = null;
      } else {
        HapticFeedback.vibrate();
        sonar('efecto_error');
        anotarFallo();
        _numeroFallo = casilla.etiqueta;
        _lineaRexan = marcar
            ? '{n} no cumple la regla: era segura.'
            : '{n} cumple la regla: era mina. La desactivo yo.';
      }
      if (_tablero.completo) _terminarTablero();
    });
  }

  void _terminarTablero() {
    sonar('efecto_acierto');
    _entreTableros = true;
    widget.registro?.registrar(
      idHabilidad: _tablero.regla.idHabilidad,
      acierto: _tablero.acierto,
      dificultad: 0.8 + 0.3 * _enNivel.dificultad,
      duracion: DateTime.now().difference(_inicioTablero),
    );
    if (_ronda >= _definicion.rondasPorPartida) {
      _terminada = true;
      return;
    }
    _lineaRexan = 'Tablero despejado.';
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      setState(() {
        _ronda++;
        _nuevoTablero();
        _lineaRexan = 'Sube el nivel: cuentas algo más difíciles.';
      });
    });
  }

  String _linea(Locale locale) {
    if (_terminada) {
      return traducirNarrativa(
          'Tres tableros sin una sola explosión. Así se trabaja.', locale);
    }
    return traducirNarrativa(_lineaRexan ?? _definicion.lineaRexan, locale)
        .replaceAll('{n}', _numeroFallo);
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final parametro = _tablero.regla.parametro;
    return MarcoMinijuego(
      titulo: _definicion.nombre,
      ofrecerPista: ofrecerPista,
      alAbrirAyuda: pistaAtendida,
      efectos: efectosPantalla,
      comoSeJuega: _definicion.comoSeJuega,
      idHabilidadActual: _tablero.regla.idHabilidad,
      dificultadEjemplo: _enNivel.dificultad,
      parametroEjemplo: _tablero.regla.parametro,
      ronda: _ronda,
      rondasTotales: _definicion.rondasPorPartida,
      lineaRexan: _linea(locale),
      terminada: _terminada,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  traducirNarrativa(_tablero.textoRegla, locale)
                      .replaceAll('{n}', parametro?.toString() ?? ''),
                  style: const TextStyle(
                    color: PaletaNeon.ambarCanales,
                    fontSize: 17,
                  ),
                ),
              ),
              Text(
                traducirNarrativa('Quedan {n}', locale)
                    .replaceAll('{n}', '${_tablero.pendientes}'),
                style: TextStyle(
                  color: PaletaNeon.textoTenue.withOpacity(0.8),
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: _tablero.columnas / _tablero.filas,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _tablero.columnas,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                  ),
                  itemCount: _tablero.casillas.length,
                  itemBuilder: (_, indice) => _Casilla(
                    key: ValueKey('casilla-$indice'),
                    casilla: _tablero.casillas[indice],
                    minasAlrededor: _tablero.minasAlrededor(indice),
                    alTocar: () => _jugar(indice, marcar: _marcando),
                    alMantener: () => _jugar(indice, marcar: true),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SelectorModo(
            marcando: _marcando,
            textoAbrir: traducirNarrativa('ABRIR', locale),
            textoMarcar: traducirNarrativa('MARCAR', locale),
            alCambiar: (marcar) => setState(() => _marcando = marcar),
          ),
        ],
      ),
    );
  }
}

class _Casilla extends StatelessWidget {
  final CasillaMina casilla;
  final int minasAlrededor;
  final VoidCallback alTocar;
  final VoidCallback alMantener;

  const _Casilla({
    super.key,
    required this.casilla,
    required this.minasAlrededor,
    required this.alTocar,
    required this.alMantener,
  });

  @override
  Widget build(BuildContext contexto) {
    final tapada = casilla.estado == EstadoCasilla.tapada;
    final List<Color> degradado;
    final Color borde;
    Widget? marca;
    switch (casilla.estado) {
      case EstadoCasilla.tapada:
        // En relieve: luz arriba a la izquierda.
        degradado = const [Color(0xFF2C1C5C), Color(0xFF140A2E)];
        borde = PaletaNeon.violetaNeon.withOpacity(0.45);
      case EstadoCasilla.abierta:
        // Hundida: sombra arriba.
        degradado = const [Color(0xFF05030C), Color(0xFF0E0822)];
        borde = PaletaNeon.violetaBase.withOpacity(0.25);
        marca = Text(
          minasAlrededor == 0 ? '' : '$minasAlrededor',
          style: const TextStyle(color: PaletaNeon.azulNeon, fontSize: 10),
        );
      case EstadoCasilla.marcada:
        degradado = [
          PaletaNeon.ambarCanales.withOpacity(0.3),
          PaletaNeon.ambarCanales.withOpacity(0.1),
        ];
        borde = PaletaNeon.ambarCanales;
        marca = const Icon(Icons.flag, size: 11, color: PaletaNeon.ambarCanales);
      case EstadoCasilla.desactivada:
        degradado = [
          PaletaNeon.rosaAcento.withOpacity(0.2),
          PaletaNeon.rosaAcento.withOpacity(0.06),
        ];
        borde = PaletaNeon.rosaAcento.withOpacity(0.6);
        marca = Icon(Icons.power_settings_new,
            size: 11, color: PaletaNeon.rosaAcento.withOpacity(0.8));
    }
    return GestureDetector(
      onTap: alTocar,
      onLongPress: alMantener,
      // Al cambiar de estado se reproduce su efecto una vez.
      child: TweenAnimationBuilder<double>(
        key: ValueKey(casilla.estado),
        tween: Tween(begin: tapada ? 1 : 0, end: 1),
        duration: const Duration(milliseconds: 520),
        builder: (_, progreso, hijo) => CustomPaint(
          foregroundPainter: tapada ? null : _PintorEfectoCasilla(casilla.estado, progreso),
          child: Transform.scale(
            scale: casilla.estado == EstadoCasilla.marcada
                ? 1 + 0.12 * math.sin(progreso * math.pi)
                : 1,
            child: hijo,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: degradado,
            ),
            border: Border.all(color: borde),
            borderRadius: BorderRadius.circular(6),
            boxShadow: tapada
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              if (tapada)
                // Filo de luz en el borde de arriba.
                Positioned(
                  left: 5,
                  right: 5,
                  top: 1.5,
                  child: Container(
                    height: 1.2,
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text(
                      casilla.etiqueta,
                      style: TextStyle(
                        color: casilla.estado == EstadoCasilla.abierta
                            ? PaletaNeon.textoTenue
                            : PaletaNeon.textoPrincipal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              if (marca != null) Positioned(right: 3, top: 2, child: marca),
            ],
          ),
        ),
      ),
    );
  }
}

/// Onda azul al abrir y chispazo rosa (sin explosión: la desactiva
/// Rexán) si era mina.
class _PintorEfectoCasilla extends CustomPainter {
  final EstadoCasilla estado;
  final double progreso;

  _PintorEfectoCasilla(this.estado, this.progreso);

  @override
  void paint(Canvas canvas, Size size) {
    if (progreso >= 1) return;
    final centro = size.center(Offset.zero);
    final radio = size.shortestSide * (0.2 + 0.7 * progreso);
    switch (estado) {
      case EstadoCasilla.abierta:
        canvas.drawCircle(
          centro,
          radio,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 * (1 - progreso) + 0.5
            ..color = PaletaNeon.azulNeon.withOpacity(0.8 * (1 - progreso)),
        );
      case EstadoCasilla.desactivada:
        final rayo = Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2
          ..color = PaletaNeon.rosaAcento.withOpacity(1 - progreso);
        for (var i = 0; i < 8; i++) {
          final angulo = i * math.pi / 4;
          final direccion = Offset(math.cos(angulo), math.sin(angulo));
          canvas.drawLine(centro + direccion * radio * 0.4, centro + direccion * radio, rayo);
        }
      case EstadoCasilla.marcada || EstadoCasilla.tapada:
        break;
    }
  }

  @override
  bool shouldRepaint(_PintorEfectoCasilla anterior) =>
      anterior.progreso != progreso || anterior.estado != estado;
}

class _SelectorModo extends StatelessWidget {
  final bool marcando;
  final String textoAbrir;
  final String textoMarcar;
  final ValueChanged<bool> alCambiar;

  const _SelectorModo({
    required this.marcando,
    required this.textoAbrir,
    required this.textoMarcar,
    required this.alCambiar,
  });

  Widget _opcion(String texto, IconData icono, bool activa, VoidCallback alTocar,
          String clave) =>
      Expanded(
        child: GestureDetector(
          key: ValueKey(clave),
          onTap: alTocar,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: activa
                  ? PaletaNeon.ambarCanales.withOpacity(0.18)
                  : Colors.transparent,
              border: Border.all(
                  color: activa
                      ? PaletaNeon.ambarCanales
                      : PaletaNeon.violetaBase.withOpacity(0.6)),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icono,
                    size: 16,
                    color: activa
                        ? PaletaNeon.ambarCanales
                        : PaletaNeon.textoTenue),
                const SizedBox(width: 6),
                Text(
                  texto,
                  style: TextStyle(
                    color: activa
                        ? PaletaNeon.ambarCanales
                        : PaletaNeon.textoTenue,
                    fontSize: 13,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext contexto) => Row(
        children: [
          _opcion(textoAbrir, Icons.touch_app_outlined, !marcando,
              () => alCambiar(false), 'modo-abrir'),
          const SizedBox(width: 10),
          _opcion(textoMarcar, Icons.flag_outlined, marcando,
              () => alCambiar(true), 'modo-marcar'),
        ],
      );
}
