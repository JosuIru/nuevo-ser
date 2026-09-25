import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../datos/nivel_de_partida.dart';
import '../datos/repositorio_progreso.dart';
import '../dominio/prueba_nivel.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';
import 'sora_presencia.dart';

/// La prueba de nivel con Sora (Fase A de la ampliación a 14 años): unas
/// diez preguntas para saber por dónde empezar. Sin marcador ni «bien» o
/// «mal»: Sora sólo dice «Otra.». Al final, «empiezas por aquí» y se
/// aplica el punto de partida (lo de antes se da por sabido).
///
/// Devuelve el nivel resultante al cerrar, o null si se deja para luego.
class PantallaPruebaNivel extends StatefulWidget {
  final RepositorioProgreso repositorio;
  final int? semilla;

  const PantallaPruebaNivel({super.key, required this.repositorio, this.semilla});

  @override
  State<PantallaPruebaNivel> createState() => _PantallaPruebaNivelState();
}

enum _Momento { presentacion, preguntas, cierre }

class _PantallaPruebaNivelState extends State<PantallaPruebaNivel> {
  late final PruebaNivel _prueba = PruebaNivel(azar: math.Random(widget.semilla));
  _Momento _momento = _Momento.presentacion;
  bool _aplicando = false;

  String _texto(String plantilla, Locale locale, [Map<String, String> datos = const {}]) {
    var texto = traducirNarrativa(plantilla, locale);
    datos.forEach((clave, valor) => texto = texto.replaceAll('{$clave}', valor));
    return texto;
  }

  void _responder(String opcion) {
    HapticFeedback.selectionClick();
    setState(() {
      _prueba.responder(opcion);
      if (_prueba.terminada) _momento = _Momento.cierre;
    });
  }

  Future<void> _aplicar() async {
    setState(() => _aplicando = true);
    final nivel = _prueba.resultado;
    await aplicarNivelDePartida(widget.repositorio, nivel, origen: 'prueba');
    if (!mounted) return;
    Navigator.of(context).pop(nivel);
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final lineaSora = switch (_momento) {
      _Momento.presentacion => _texto(
          'Antes de salir quiero ver qué sabes ya. Unas preguntas, sin prisa. No cuentan para nada: son para saber por dónde empezar.',
          locale),
      _Momento.preguntas => _prueba.preguntasHechas == 0 ? _texto('Empezamos.', locale) : _texto('Otra.', locale),
      _Momento.cierre => _texto(
          'Ya sé por dónde empezar: {curso}. Lo de antes lo doy por sabido. Si algo cuesta, volverá a salir.',
          locale,
          {'curso': traducirNarrativa(_prueba.resultado.nombre, locale)}),
    };
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: PaletaNeon.textoTenue, size: 20),
                  tooltip: traducirNarrativa('Ahora no', locale),
                  onPressed: () => Navigator.of(contexto).pop(),
                ),
                Expanded(
                  child: Text(
                    traducirNarrativa('Por dónde empiezo', locale).toUpperCase(),
                    style: const TextStyle(
                        color: PaletaNeon.textoPrincipal, fontSize: 15, fontWeight: FontWeight.w300, letterSpacing: 3),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: switch (_momento) {
                  _Momento.presentacion => Center(
                      child: FilledButton(
                        key: const ValueKey('prueba-empezar'),
                        onPressed: () => setState(() => _momento = _Momento.preguntas),
                        child: Text(traducirNarrativa('Empezar', locale)),
                      ),
                    ),
                  _Momento.preguntas => _Pregunta(
                      key: ValueKey(_prueba.preguntasHechas),
                      pregunta: _prueba.preguntaActual,
                      enunciado: _texto(_prueba.preguntaActual.enunciado, locale, _prueba.preguntaActual.datos),
                      traducir: (opcion) => traducirNarrativa(opcion, locale),
                      alResponder: _responder,
                    ),
                  _Momento.cierre => Center(
                      child: FilledButton(
                        key: const ValueKey('prueba-vamos'),
                        onPressed: _aplicando ? null : _aplicar,
                        child: Text(traducirNarrativa('Vamos', locale)),
                      ),
                    ),
                },
              ),
            ),
            SoraPresencia(textoActivo: lineaSora),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _Pregunta extends StatelessWidget {
  final PreguntaNivel pregunta;
  final String enunciado;
  final String Function(String) traducir;
  final ValueChanged<String> alResponder;

  const _Pregunta({
    super.key,
    required this.pregunta,
    required this.enunciado,
    required this.traducir,
    required this.alResponder,
  });

  @override
  Widget build(BuildContext contexto) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          enunciado,
          key: const ValueKey('prueba-enunciado'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: PaletaNeon.ambarCanales, fontSize: 20, height: 1.4),
        ),
        const SizedBox(height: 28),
        for (final opcion in pregunta.opciones)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              key: ValueKey('prueba-opcion-$opcion'),
              onPressed: () => alResponder(opcion),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: PaletaNeon.textoPrincipal,
                side: BorderSide(color: PaletaNeon.violetaNeon.withOpacity(0.5)),
              ),
              child: Text(traducir(opcion), style: const TextStyle(fontSize: 18)),
            ),
          ),
      ],
    );
  }
}
