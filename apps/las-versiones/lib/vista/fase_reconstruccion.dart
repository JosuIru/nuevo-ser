import 'package:flutter/material.dart';

import '../datos/registro_maestria_archivo.dart';
import '../datos/repositorio_reconstruccion.dart';
import '../dominio/brecha.dart';
import '../nucleo/paleta_archivo.dart';

/// Pantalla jugable de la Fase 4 — Reconstrucción con declaración de
/// niveles de confianza (AH.03, perfil P4 Brier). Es el corazón
/// pedagógico del juego: la Cronista elige qué afirmaciones del
/// catálogo sostiene y, para cada una, declara el nivel de confianza
/// con que la sostiene —Sólido, Probable o Disputado.
///
/// El cálculo Brier no se evalúa aquí (eso pasa en la Fase 5
/// Concilio, que lee la reconstrucción persistida y devuelve
/// feedback). Aquí sólo se construye la versión.
class FaseReconstruccion extends StatefulWidget {
  /// Brecha cuya Fase 4 se está jugando.
  final Brecha brecha;

  /// Callback al que llamar cuando la Cronista pulsa "AL CONCILIO".
  final VoidCallback alAvanzarFase;

  /// Repositorio de persistencia. Inyectable para tests.
  final RepositorioReconstruccion repoReconstruccion;

  /// Motor de maestría: al ir al Concilio apunta cada afirmación
  /// declarada en AH.03 (P4). `null` en tests.
  final RegistroMaestriaArchivo? registro;

  const FaseReconstruccion({
    super.key,
    required this.brecha,
    required this.alAvanzarFase,
    required this.repoReconstruccion,
    this.registro,
  });

  @override
  State<FaseReconstruccion> createState() => _FaseReconstruccionState();
}

class _FaseReconstruccionState extends State<FaseReconstruccion> {
  Map<String, NivelConfianza> _declaraciones = const {};
  bool _cargando = true;
  final Stopwatch _cronometro = Stopwatch()..start();

  /// Al Concilio: la versión queda cerrada y cada afirmación declarada
  /// es un intento de AH.03 (lo que haya al pulsar, no los cambios
  /// intermedios: aquí se construye, se juzga al cerrar).
  void _alIrAlConcilio() {
    final registro = widget.registro;
    if (registro != null && _declaraciones.isNotEmpty) {
      final duracionMedia = _cronometro.elapsed ~/ _declaraciones.length;
      for (final afirmacion in widget.brecha.afirmacionesCanonicas) {
        final declarado = _declaraciones[afirmacion.id];
        if (declarado == null) continue;
        registro.registrar(
          idHabilidad: 'AH.03',
          acierto: declarado == afirmacion.calibracionCorrecta,
          nivelDeclarado: declarado,
          nivelCanonico: afirmacion.calibracionCorrecta,
          duracion: duracionMedia,
        );
      }
    }
    widget.alAvanzarFase();
  }

  @override
  void initState() {
    super.initState();
    _cargarReconstruccion();
  }

  Future<void> _cargarReconstruccion() async {
    final mapa = await widget.repoReconstruccion.cargar(widget.brecha.id);
    if (!mounted) return;
    setState(() {
      _declaraciones = mapa;
      _cargando = false;
    });
  }

  Future<void> _alElegirNivel(String idAfirmacion, NivelConfianza nivel) async {
    final nuevas = {..._declaraciones, idAfirmacion: nivel};
    await widget.repoReconstruccion.guardar(widget.brecha.id, nuevas);
    if (!mounted) return;
    setState(() => _declaraciones = nuevas);
  }

  /// Nombres visibles (`tipoVisible`) de las fuentes que anclan una
  /// afirmación. Antes se mostraban los ids internos
  /// (`restos_oseos_in_situ`), ilegibles para la Cronista.
  List<String> _nombresFuentes(AfirmacionCanonica afirmacion) => [
        for (final id in afirmacion.idsFuentesAnclaje)
          for (final fuente in widget.brecha.fuentes)
            if (fuente.id == id) fuente.tipoVisible,
      ];

  Future<void> _alQuitar(String idAfirmacion) async {
    final nuevas = {..._declaraciones}..remove(idAfirmacion);
    await widget.repoReconstruccion.guardar(widget.brecha.id, nuevas);
    if (!mounted) return;
    setState(() => _declaraciones = nuevas);
  }

  Future<void> _abrirAyuda(BuildContext contexto) async {
    await showDialog<void>(
      context: contexto,
      builder: (_) => const _DialogoAyudaReconstruccion(),
    );
  }

  @override
  Widget build(BuildContext contexto) {
    if (_cargando) {
      return const SizedBox.expand();
    }
    final declaradas = _declaraciones.length;
    final minimoDeclaradas = widget.brecha.minimoAfirmacionesParaConcilio;
    final puedeAvanzar = declaradas >= minimoDeclaradas;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _IntroFase4(alAbrirAyuda: () => _abrirAyuda(contexto)),
        const SizedBox(height: 6),
        _ContadorReconstruccion(
          declaradas: declaradas,
          minimo: minimoDeclaradas,
        ),
        const SizedBox(height: 14),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int indice = 0;
                    indice < widget.brecha.afirmacionesCanonicas.length;
                    indice++) ...[
                  if (indice > 0) const SizedBox(height: 12),
                  _TarjetaAfirmacion(
                    afirmacion: widget.brecha.afirmacionesCanonicas[indice],
                    nombresFuentesAnclaje: _nombresFuentes(
                        widget.brecha.afirmacionesCanonicas[indice]),
                    nivelDeclarado: _declaraciones[widget.brecha
                        .afirmacionesCanonicas[indice].id],
                    alElegirNivel: (nivel) => _alElegirNivel(
                      widget.brecha.afirmacionesCanonicas[indice].id,
                      nivel,
                    ),
                    alQuitar: () => _alQuitar(
                      widget.brecha.afirmacionesCanonicas[indice].id,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: puedeAvanzar ? _alIrAlConcilio : null,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: PaletaArchivo.textoPrincipal,
              // Sin esto el texto desactivado sale casi negro sobre el fondo
              // oscuro y el botón parece vacío.
              disabledForegroundColor: PaletaArchivo.textoTenue,
              backgroundColor:
                  PaletaArchivo.fondoMedio.withOpacity(puedeAvanzar ? 0.6 : 0.3),
              side: BorderSide(
                color: PaletaArchivo.ambarLacre.withOpacity(
                  puedeAvanzar ? 0.7 : 0.3,
                ),
              ),
            ),
            child: const Text(
              'AL CONCILIO',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroFase4 extends StatelessWidget {
  final VoidCallback alAbrirAyuda;

  const _IntroFase4({required this.alAbrirAyuda});

  @override
  Widget build(BuildContext contexto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Construye tu versión. Para cada afirmación que sostienes '
              'declara con qué confianza: Sólido, Probable o Disputado. '
              'Toca el "?" para entender los tres niveles.',
              style: TextStyle(
                fontSize: 14,
                color: PaletaArchivo.textoPrincipal.withOpacity(0.9),
                height: 1.5,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          tooltip: 'Niveles de confianza',
          icon: const Icon(
            Icons.help_outline,
            color: PaletaArchivo.ambarLacre,
            size: 22,
          ),
          onPressed: alAbrirAyuda,
        ),
      ],
    );
  }
}

/// Diálogo que explica los tres niveles de confianza con tono cercano
/// y ejemplos. Es el corazón pedagógico del juego (AH.03, perfil P4
/// Brier): la honestidad sobre lo que sé y lo que no sé. La idea
/// clave que el diálogo pone por delante: el oficio NO premia tener
/// razón, premia juzgar bien con lo que se tiene.
class _DialogoAyudaReconstruccion extends StatelessWidget {
  const _DialogoAyudaReconstruccion();

  @override
  Widget build(BuildContext contexto) {
    return Dialog(
      backgroundColor: PaletaArchivo.fondoProfundo,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'NIVELES DE CONFIANZA',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 4,
                  color: PaletaArchivo.ambarLacre.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'El oficio no premia tener razón. Premia juzgar bien '
                'con lo que tienes. Por cada cosa que sostienes, dices '
                'qué tan segura estás.',
                style: TextStyle(
                  fontSize: 13,
                  color: PaletaArchivo.textoPrincipal.withOpacity(0.92),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              const _BloqueAyudaNivel(
                titulo: 'SÓLIDO',
                explicacion:
                    'Hay pruebas claras y varias fuentes que apuntan a '
                    'lo mismo. Pondrías la mano en el fuego.',
                ejemplo:
                    'Ej.: "Aquí hubo una ciudad romana" — porque hay '
                    'restos físicos, monedas, inscripciones.',
              ),
              _BloqueAyudaNivel(
                titulo: 'PROBABLE',
                explicacion:
                    'Hay pistas que apuntan a esto, pero no es seguro '
                    'del todo. Es la opción más razonable, no la '
                    'única posible.',
                ejemplo:
                    'Ej.: "Probablemente esta domus era de una familia '
                    'rica" — porque los mosaicos son caros, pero no '
                    'hay un letrero que lo confirme.',
              ),
              _BloqueAyudaNivel(
                titulo: 'DISPUTADO',
                explicacion:
                    'Hay opiniones distintas, las pruebas chocan o no '
                    'bastan para decidir. La honestidad pide '
                    'reconocerlo.',
                ejemplo:
                    'Ej.: "Está disputado quién mandó esta inscripción" '
                    '— porque las fuentes dan dos personas distintas.',
              ),
              const SizedBox(height: 4),
              Text(
                'Si pones Sólido a algo que en realidad es Disputado, '
                'el Concilio te lo dirá. No es para que aciertes — es '
                'para que te entrenes en ser honesta con lo que sabes '
                'y lo que no sabes.',
                style: TextStyle(
                  fontSize: 12,
                  color: PaletaArchivo.textoTenue.withOpacity(0.85),
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(contexto).maybePop(),
                  child: const Text(
                    'CERRAR',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 3,
                      color: PaletaArchivo.ambarLacre,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BloqueAyudaNivel extends StatelessWidget {
  final String titulo;
  final String explicacion;
  final String ejemplo;

  const _BloqueAyudaNivel({
    required this.titulo,
    required this.explicacion,
    required this.ejemplo,
  });

  @override
  Widget build(BuildContext contexto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 3,
              color: PaletaArchivo.ambarLacre,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            explicacion,
            style: const TextStyle(
              fontSize: 13,
              color: PaletaArchivo.textoPrincipal,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 2),
            child: Text(
              ejemplo,
              style: TextStyle(
                fontSize: 12,
                color: PaletaArchivo.textoPrincipal.withOpacity(0.82),
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContadorReconstruccion extends StatelessWidget {
  final int declaradas;
  final int minimo;

  const _ContadorReconstruccion({
    required this.declaradas,
    required this.minimo,
  });

  @override
  Widget build(BuildContext contexto) {
    final faltan = (minimo - declaradas).clamp(0, minimo);
    final mensaje = faltan == 0
        ? 'Sostienes $declaradas afirmaciones — listo para el Concilio.'
        : 'Sostienes $declaradas. El mínimo para ir al Concilio es $minimo '
            '(faltan $faltan).';
    return Text(
      mensaje,
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 2.5,
        color: PaletaArchivo.ambarLacre,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _TarjetaAfirmacion extends StatelessWidget {
  final AfirmacionCanonica afirmacion;
  final List<String> nombresFuentesAnclaje;
  final NivelConfianza? nivelDeclarado;
  final ValueChanged<NivelConfianza> alElegirNivel;
  final VoidCallback alQuitar;

  const _TarjetaAfirmacion({
    required this.afirmacion,
    this.nombresFuentesAnclaje = const [],
    required this.nivelDeclarado,
    required this.alElegirNivel,
    required this.alQuitar,
  });

  @override
  Widget build(BuildContext contexto) {
    final declarada = nivelDeclarado != null;
    final colorAcento = declarada
        ? PaletaArchivo.ambarLacre
        : PaletaArchivo.tintaTenue.withOpacity(0.4);
    return Container(
      decoration: BoxDecoration(
        color: PaletaArchivo.fondoMedio.withOpacity(0.4),
        border: Border(
          left: BorderSide(color: colorAcento, width: 2),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            afirmacion.texto,
            style: TextStyle(
              fontSize: 14,
              color: PaletaArchivo.textoPrincipal.withOpacity(0.92),
              height: 1.5,
              fontWeight: FontWeight.w300,
            ),
          ),
          if (nombresFuentesAnclaje.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Anclada en: ${nombresFuentesAnclaje.join(' · ')}',
              style: TextStyle(
                fontSize: 11,
                color: PaletaArchivo.textoTenue.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              for (final nivel in NivelConfianza.values) ...[
                Expanded(
                  child: _BotonNivel(
                    nivel: nivel,
                    seleccionado: nivelDeclarado == nivel,
                    alPulsar: () => alElegirNivel(nivel),
                  ),
                ),
                if (nivel != NivelConfianza.values.last)
                  const SizedBox(width: 6),
              ],
            ],
          ),
          if (declarada)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: alQuitar,
                style: TextButton.styleFrom(
                  foregroundColor:
                      PaletaArchivo.textoTenue.withOpacity(0.85),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(0, 30),
                ),
                child: const Text(
                  'Quitar de mi versión',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BotonNivel extends StatelessWidget {
  final NivelConfianza nivel;
  final bool seleccionado;
  final VoidCallback alPulsar;

  const _BotonNivel({
    required this.nivel,
    required this.seleccionado,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext contexto) {
    return TextButton(
      onPressed: alPulsar,
      style: TextButton.styleFrom(
        backgroundColor: seleccionado
            ? PaletaArchivo.ambarLacre.withOpacity(0.22)
            : PaletaArchivo.fondoMedio.withOpacity(0.55),
        side: BorderSide(
          color: seleccionado
              ? PaletaArchivo.ambarLacre
              : PaletaArchivo.tintaTenue.withOpacity(0.5),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        foregroundColor: PaletaArchivo.textoPrincipal,
        // Sin esto el texto desactivado sale casi negro sobre el fondo
        // oscuro y el botón parece vacío.
        disabledForegroundColor: PaletaArchivo.textoTenue,
      ),
      child: Text(
        _etiquetaNivel(nivel),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: seleccionado ? FontWeight.w500 : FontWeight.w400,
          color: PaletaArchivo.textoPrincipal.withOpacity(0.95),
        ),
      ),
    );
  }

  String _etiquetaNivel(NivelConfianza nivel) {
    switch (nivel) {
      case NivelConfianza.solido:
        return 'Sólido';
      case NivelConfianza.probable:
        return 'Probable';
      case NivelConfianza.disputado:
        return 'Disputado';
    }
  }
}
