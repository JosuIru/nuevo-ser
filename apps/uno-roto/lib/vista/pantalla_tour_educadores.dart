import 'package:flutter/material.dart';
import '../nucleo/paleta.dart';

/// Tour guiado para educadores. Slide deck que muestra las mecánicas clave
/// de Uno Roto sin necesidad de jugar. Accesible desde el mapa.
class PantallaTourEducadores extends StatefulWidget {
  const PantallaTourEducadores({super.key});

  @override
  State<PantallaTourEducadores> createState() => _PantallaTourEducadoresState();
}

class _PantallaTourEducadoresState extends State<PantallaTourEducadores> {
  final _pageController = PageController();
  int _paginaActual = 0;

  static const _totalPaginas = 10;

  void _irA(int pagina) {
    _pageController.animateToPage(
      pagina,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      body: SafeArea(
        child: Column(
          children: [
            _barraSuperior(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _paginaActual = i),
                children: const [
                  _SlideBienvenida(),
                  _SlideMapa(),
                  _SlideCazadero(),
                  _SlidePuzzles(),
                  _SlideNarrativa(),
                  _SlideProgreso(),
                  _SlideFaro(),
                  _SlideEntrenamiento(),
                  _SlideTutor(),
                  _SlidePerfiles(),
                ],
              ),
            ),
            _navegacionInferior(),
          ],
        ),
      ),
    );
  }

  Widget _barraSuperior() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: PaletaNeon.textoTenue),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Cerrar tour',
          ),
          const Spacer(),
          Text(
            '${_paginaActual + 1} / $_totalPaginas',
            style: const TextStyle(
              color: PaletaNeon.textoTenue,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navegacionInferior() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          if (_paginaActual > 0)
            _botonNavegacion(
              icono: Icons.arrow_back,
              label: 'Anterior',
              alPulsar: () => _irA(_paginaActual - 1),
            )
          else
            const SizedBox(width: 100),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              _totalPaginas,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _paginaActual ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _paginaActual
                      ? PaletaNeon.azulNeon
                      : PaletaNeon.textoTenue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const Spacer(),
          if (_paginaActual < _totalPaginas - 1)
            _botonNavegacion(
              icono: Icons.arrow_forward,
              label: 'Siguiente',
              alPulsar: () => _irA(_paginaActual + 1),
            )
          else
            _botonNavegacion(
              icono: Icons.check,
              label: 'Cerrar',
              alPulsar: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  Widget _botonNavegacion({
    required IconData icono,
    required String label,
    required VoidCallback alPulsar,
  }) {
    return TextButton.icon(
      onPressed: alPulsar,
      icon: Icon(icono, color: PaletaNeon.azulNeon, size: 18),
      label: Text(
        label,
        style: const TextStyle(color: PaletaNeon.azulNeon, fontSize: 13),
      ),
    );
  }
}

// ─── Slides ────────────────────────────────────────────────────────────────

class _SlideBienvenida extends StatelessWidget {
  const _SlideBienvenida();

  @override
  Widget build(BuildContext context) {
    return _PlantillaSlide(
      titulo: 'Uno Roto',
      subtitulo: 'Tour para educadores',
      nino: null,
      cuerpo: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _MockupRecuadro(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Icon(Icons.auto_stories,
                      size: 48, color: PaletaNeon.violetaNeon),
                  const SizedBox(height: 8),
                  Text(
                    'Uno Roto',
                    style: TextStyle(
                      color: PaletaNeon.azulNeon,
                      fontSize: 22,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Colección Nuevo Ser Kids',
                    style: TextStyle(
                      color: PaletaNeon.textoTenue,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Juego educativo de matemáticas para niños de 9 a 14 años.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PaletaNeon.textoPrincipal,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Fracciones, decimales, proporciones, álgebra, geometría y estadística — todo integrado en una narrativa de misterio y superación personal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PaletaNeon.textoTenue,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _Etiqueta(
                '106 habilidades · 11 dominios · 4.º de Primaria a 2.º de ESO'),
          ],
        ),
      ),
      pie: 'Desliza para explorar las mecánicas →',
    );
  }
}

class _SlideMapa extends StatelessWidget {
  const _SlideMapa();

  @override
  Widget build(BuildContext context) {
    return _PlantillaSlide(
      titulo: 'Mapa de la Ciudad',
      subtitulo: 'Progreso visible por distritos',
      nino: null,
      cuerpo: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _MockupRecuadro(
              child: Column(
                children: [
                  _simularHeader('Tejados · Rango Aprendiz I'),
                  const Divider(color: PaletaNeon.textoTenue, height: 1),
                  Container(
                    height: 140,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _distritoMini('Tejados', true),
                        _distritoMini('Canales', false),
                        _distritoMini('Mercado', false),
                        _distritoMini('Afueras', false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'El punto de partida. Cada distrito representa un conjunto de habilidades matemáticas. Los distritos se desbloquean al acumular esquirlas, la recompensa por resolver puzzles.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PaletaNeon.textoTenue,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '7 distritos únicos con atmósfera, color y banda sonora propios.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PaletaNeon.azulNeon,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _distritoMini(String nombre, bool activo) {
    return Container(
      width: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            activo ? PaletaNeon.violetaBase.withOpacity(0.4) : Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: activo
              ? PaletaNeon.violetaNeon.withOpacity(0.5)
              : PaletaNeon.textoTenue.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_city,
            size: 20,
            color: activo ? PaletaNeon.violetaNeon : PaletaNeon.textoTenue,
          ),
          const SizedBox(height: 4),
          Text(
            nombre,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: activo ? PaletaNeon.textoPrincipal : PaletaNeon.textoTenue,
              fontSize: 7,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideCazadero extends StatelessWidget {
  const _SlideCazadero();

  @override
  Widget build(BuildContext context) {
    return _PlantillaSlide(
      titulo: 'Cazadero',
      subtitulo: 'El núcleo del juego',
      nino: null,
      cuerpo: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _MockupRecuadro(
              child: Column(
                children: [
                  _simularHeader('Tejados'),
                  const Divider(color: PaletaNeon.textoTenue, height: 1),
                  Container(
                    height: 120,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app,
                            size: 40, color: PaletaNeon.azulNeon),
                        const SizedBox(height: 8),
                        Text(
                          '3/4 + 1/2 = ?',
                          style: TextStyle(
                            color: PaletaNeon.azulNeon,
                            fontSize: 22,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 2,
                    color: PaletaNeon.textoTenue.withOpacity(0.15),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _candidatoMini('5/4'),
                        _candidatoMini('4/6'),
                        _candidatoMini('1'),
                        _candidatoMini('1/2'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Los Fragmentos (puzzles) aparecen en el escenario del distrito. El niño los captura y resuelve el problema matemático que contienen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PaletaNeon.textoTenue,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _Etiqueta('Acierto → esquirlas · Fallo → intento extra'),
          ],
        ),
      ),
    );
  }

  Widget _candidatoMini(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: PaletaNeon.textoTenue.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: PaletaNeon.textoPrincipal,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _SlidePuzzles extends StatelessWidget {
  const _SlidePuzzles();

  @override
  Widget build(BuildContext context) {
    return _PlantillaSlide(
      titulo: '106 habilidades',
      subtitulo: '11 dominios curriculares',
      nino: null,
      cuerpo: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _MockupRecuadro(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _chipDomino('FR', 'Fracciones', PaletaNeon.azulNeon),
                    _chipDomino('DEC', 'Decimales', PaletaNeon.violetaNeon),
                    _chipDomino(
                        'PROP', 'Proporciones', PaletaNeon.ambarCanales),
                    _chipDomino('DIV', 'Divisibilidad', PaletaNeon.exitoSuave),
                    _chipDomino('OP', 'Operaciones', PaletaNeon.rosaAcento),
                    _chipDomino('MED', 'Medidas', PaletaNeon.textoPrincipal),
                    _chipDomino('GEO', 'Geometría', PaletaNeon.azulNeon),
                    _chipDomino('EST', 'Estadística', PaletaNeon.violetaNeon),
                    _chipDomino(
                        'ARI', 'Enteros y potencias', PaletaNeon.ambarCanales),
                    _chipDomino('ALG', 'Álgebra', PaletaNeon.exitoSuave),
                    _chipDomino('FUN', 'Funciones', PaletaNeon.rosaAcento),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cada habilidad tiene su propio puzzle con distractores sacados de los errores típicos. No son ejercicios genéricos — cada uno ataca una dificultad concreta. Las de 1.º y 2.º de ESO llegan como problemas con dibujo: plano, gráficas, cuerpos, tablas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PaletaNeon.textoTenue,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Amplificar, simplificar, comparar, ordenar, convertir, redondear, clasificar, medir…',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PaletaNeon.azulNeon,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipDomino(String id, String nombre, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(4),
        color: color.withOpacity(0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            id,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            nombre,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideNarrativa extends StatelessWidget {
  const _SlideNarrativa();

  @override
  Widget build(BuildContext context) {
    return _PlantillaSlide(
      titulo: 'Narrativa',
      subtitulo: '4 arcos, 10 personajes',
      nino: null,
      cuerpo: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _MockupRecuadro(
              child: Column(
                children: [
                  _simularHeader('Arco I · 3/14'),
                  const Divider(color: PaletaNeon.textoTenue, height: 1),
                  Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sora',
                          style: TextStyle(
                            color: PaletaNeon.azulNeon,
                            fontSize: 18,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"La Ciudad recuerda quién eres, {nombre}."',
                          style: TextStyle(
                            color: PaletaNeon.textoTenue,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: PaletaNeon.textoTenue, height: 1),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Kurz · Eco · Zafrán · Kai · Vorax · Vadic · Ari · Irune · Niko · Rexán',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: PaletaNeon.textoTenue.withOpacity(0.6),
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Las matemáticas no son una excusa para la historia — son la historia. Cada Fragmento nombrado tiene personalidad, voz y un arco de redención. El niño avanza porque quiere saber qué pasa, no porque toque.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PaletaNeon.textoTenue,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _Etiqueta(
                'Cinemáticas con diálogos, opciones y combates narrativos'),
          ],
        ),
      ),
    );
  }
}

class _SlideProgreso extends StatelessWidget {
  const _SlideProgreso();

  @override
  Widget build(BuildContext context) {
    return _PlantillaSlide(
      titulo: 'Motor de Maestría',
      subtitulo: '5 niveles por habilidad',
      nino: null,
      cuerpo: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _MockupRecuadro(
              child: Column(
                children: [
                  _simularHeader('Tejados — 12 habilidades'),
                  const Divider(color: PaletaNeon.textoTenue, height: 1),
                  Container(
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _habilidadBarra('FR.01 Reconocer fracción', 0.8),
                        const SizedBox(height: 6),
                        _habilidadBarra('FR.02 Leer fracción', 0.6),
                        const SizedBox(height: 6),
                        _habilidadBarra('FR.04 Comparar con unidad', 0.3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cada habilidad progresa de Novato a Maestro según precisión, velocidad y consistencia. El sistema adapta la dificultad automáticamente. Las habilidades con decaimiento recuerdan lo que se ha olvidado.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PaletaNeon.textoTenue,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _Etiqueta(
                'Decaimiento 21 días · Anti-repetición · Dificultad adaptativa'),
          ],
        ),
      ),
    );
  }

  Widget _habilidadBarra(String nombre, double valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nombre,
          style: TextStyle(
            color: PaletaNeon.textoTenue,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: PaletaNeon.textoTenue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: valor,
            child: Container(
              decoration: BoxDecoration(
                color: valor > 0.5
                    ? PaletaNeon.exitoSuave
                    : PaletaNeon.ambarCanales,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SlideFaro extends StatelessWidget {
  const _SlideFaro();

  @override
  Widget build(BuildContext context) {
    return _PlantillaSlide(
      titulo: 'El Faro de Azula',
      subtitulo: 'Periódico semanal del lore',
      nino: null,
      cuerpo: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _MockupRecuadro(
              child: Column(
                children: [
                  _simularHeader('El Faro de Azula'),
                  const Divider(color: PaletaNeon.textoTenue, height: 1),
                  Container(
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'N.º 1234 — Año 412 de la Orden',
                          style: TextStyle(
                            color: PaletaNeon.ambarCanales,
                            fontSize: 9,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 2,
                          color: PaletaNeon.ambarCanales.withOpacity(0.4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'La redacción informa: los ecos del Mercado\nse intensifican con la luna nueva.',
                          style: TextStyle(
                            color: PaletaNeon.textoTenue,
                            fontSize: 9,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: PaletaNeon.textoTenue, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.psychology,
                            size: 14, color: PaletaNeon.ambarCanales),
                        const SizedBox(width: 4),
                        Text(
                          'Acertijo matemático semanal',
                          style: TextStyle(
                            color: PaletaNeon.ambarCanales.withOpacity(0.7),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cada semana, una nueva edición con noticias del mundo del juego, crónicas, cartas al director y un acertijo. El niño escribe su respuesta — el periódico nunca corrige, la solución llega en la edición siguiente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PaletaNeon.textoTenue,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _Etiqueta('10 ediciones · Lectura voluntaria · Lore vivo'),
          ],
        ),
      ),
    );
  }
}

class _SlideEntrenamiento extends StatelessWidget {
  const _SlideEntrenamiento();

  @override
  Widget build(BuildContext context) {
    return _PlantillaSlide(
      titulo: 'Modo Entrenamiento',
      subtitulo: 'Práctica dirigida por dominio',
      nino: null,
      cuerpo: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _MockupRecuadro(
              child: Column(
                children: [
                  _simularHeader('Entrenando · FR'),
                  const Divider(color: PaletaNeon.textoTenue, height: 1),
                  Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _dominoEntreno('FR', 'Fracciones'),
                        _dominoEntreno('DEC', 'Decimales'),
                        _dominoEntreno('PROP', 'Proporciones'),
                      ],
                    ),
                  ),
                  const Divider(color: PaletaNeon.textoTenue, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      'Elige un dominio y practica sin presión',
                      style: TextStyle(
                        color: PaletaNeon.violetaNeon,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'El selector adaptativo filtra por dominio en lugar de distrito, manteniendo el decaimiento y la anti-repetición. Ideal para reforzar áreas débiles sin la presión del cazadero libre.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PaletaNeon.textoTenue,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _Etiqueta('11 dominios · Dificultad progresiva · Sin límite'),
          ],
        ),
      ),
    );
  }

  Widget _dominoEntreno(String id, String nombre) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: PaletaNeon.violetaNeon.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$id · $nombre',
        style: TextStyle(
          color: PaletaNeon.violetaNeon,
          fontSize: 8,
        ),
      ),
    );
  }
}

class _SlideTutor extends StatelessWidget {
  const _SlideTutor();

  @override
  Widget build(BuildContext context) {
    return _PlantillaSlide(
      titulo: 'Tutor IA',
      subtitulo: 'Ayuda contextual con Claude',
      nino: null,
      cuerpo: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _MockupRecuadro(
              child: Column(
                children: [
                  _simularHeader('Tutor'),
                  const Divider(color: PaletaNeon.textoTenue, height: 1),
                  Container(
                    height: 90,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _burbuja(
                          'Eco: Intenta pensar en las fracciones\ncomo trozos de una tarta.',
                          true,
                        ),
                        const SizedBox(height: 6),
                        _burbuja(
                          'Vale, pero no sé cuánto es 3/4 + 1/2...',
                          false,
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: PaletaNeon.textoTenue, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      PaletaNeon.textoTenue.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.send,
                            size: 14, color: PaletaNeon.violetaNeon),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Después de varios fallos, Eco (el personaje-tutor) aparece y ofrece ayuda. Sin necesidad de internet para las explicaciones básicas. Con internet, usa Claude Haiku para respuestas más ricas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PaletaNeon.textoTenue,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _Etiqueta('Sin registro · Sin tracking · Privacidad por diseño'),
          ],
        ),
      ),
    );
  }

  Widget _burbuja(String texto, bool esTutor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: esTutor
            ? PaletaNeon.violetaBase.withOpacity(0.3)
            : PaletaNeon.azulNeon.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: PaletaNeon.textoTenue,
          fontSize: 9,
          height: 1.3,
        ),
      ),
    );
  }
}

class _SlidePerfiles extends StatelessWidget {
  const _SlidePerfiles();

  @override
  Widget build(BuildContext context) {
    return _PlantillaSlide(
      titulo: 'Perfiles Multi-jugador',
      subtitulo: 'Un dispositivo, varios niños',
      nino: null,
      cuerpo: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _MockupRecuadro(
              child: Column(
                children: [
                  _simularHeader('¿Quién eres?'),
                  const Divider(color: PaletaNeon.textoTenue, height: 1),
                  Container(
                    height: 80,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _avatarMini('Ane', PaletaNeon.azulNeon),
                        _avatarMini('Lucas', PaletaNeon.violetaNeon),
                        _avatarMini('Martina', PaletaNeon.rosaAcento),
                      ],
                    ),
                  ),
                  const Divider(color: PaletaNeon.textoTenue, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      '+ Añadir perfil',
                      style: TextStyle(
                        color: PaletaNeon.textoTenue.withOpacity(0.5),
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cada niño tiene su propio progreso, perfil, ajustes de sonido y nivel de dificultad. Ideal para uso en aula con dispositivos compartidos. Un toque para cambiar de perfil.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PaletaNeon.textoTenue,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _Etiqueta('Perfiles independientes · Sin cuenta · Sin email'),
          ],
        ),
      ),
    );
  }

  Widget _avatarMini(String nombre, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            nombre[0],
            style: TextStyle(color: color, fontSize: 16),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          nombre,
          style: TextStyle(
            color: PaletaNeon.textoTenue,
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}

// ─── Componentes compartidos ───────────────────────────────────────────────

class _PlantillaSlide extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Widget? nino;
  final Widget cuerpo;
  final String? pie;

  const _PlantillaSlide({
    required this.titulo,
    required this.subtitulo,
    this.nino,
    required this.cuerpo,
    this.pie,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          titulo,
          style: const TextStyle(
            color: PaletaNeon.azulNeon,
            fontSize: 28,
            letterSpacing: 4,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitulo,
          style: TextStyle(
            color: PaletaNeon.textoTenue.withOpacity(0.7),
            fontSize: 12,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: cuerpo),
        if (pie != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              pie!,
              style: TextStyle(
                color: PaletaNeon.textoTenue.withOpacity(0.3),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

class _MockupRecuadro extends StatelessWidget {
  final Widget child;
  const _MockupRecuadro({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: PaletaNeon.fondoMedio.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PaletaNeon.textoTenue.withOpacity(0.15),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

Widget _simularHeader(String texto) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Text(
      texto,
      style: const TextStyle(
        color: PaletaNeon.textoPrincipal,
        fontSize: 11,
        letterSpacing: 2,
        fontWeight: FontWeight.w300,
      ),
    ),
  );
}

Widget _Etiqueta(String texto) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: PaletaNeon.violetaBase.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: PaletaNeon.violetaNeon.withOpacity(0.2),
      ),
    ),
    child: Text(
      texto,
      style: const TextStyle(
        color: PaletaNeon.violetaNeon,
        fontSize: 11,
        letterSpacing: 1,
      ),
    ),
  );
}
