import 'package:flutter/material.dart';

import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import '../datos/dibujos_monstruos.dart';
import '../datos/repositorio_progreso.dart';
import '../dominio/bestiario.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';
import 'minijuegos/monstruo_maquina.dart' show DibujoMonstruo;

/// Pestaña BESTIARIO de Mi Cuaderno (doc 16, eje C): las familias de
/// Fragmentos como fichas con identidad. Los encuentros se derivan de
/// las exposiciones que ya persiste el motor de maestría.
///
/// Reglas de tono (doc 01): la ficha sin encuentros muestra "???" con
/// su hábitat — el "me falta uno" es curiosidad, no checklist. Los
/// tramos bloqueados se insinúan con puntos, sin contador ni barra.
class PestanaBestiario extends StatefulWidget {
  final RepositorioProgreso repositorio;

  const PestanaBestiario({super.key, required this.repositorio});

  @override
  State<PestanaBestiario> createState() => _PestanaBestiarioState();
}

class _PestanaBestiarioState extends State<PestanaBestiario> {
  Map<String, EstadoHabilidad> _estados = const {};
  bool _cargado = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final mapa = <String, EstadoHabilidad>{};
    for (final ficha in CatalogoBestiario.todas) {
      for (final idHabilidad in ficha.idsHabilidades) {
        final estado =
            await widget.repositorio.cargarEstadoHabilidad(idHabilidad);
        if (estado != null) mapa[idHabilidad] = estado;
      }
    }
    await DibujosMonstruos.cargar(widget.repositorio);
    if (!mounted) return;
    setState(() {
      _estados = mapa;
      _cargado = true;
    });
  }

  /// El taller de dibujo: foto de su dibujo en papel → la familia pasa a
  /// ser así, aquí y en su máquina.
  Future<void> _dibujar(FichaBestiario ficha) async {
    final locale = Localizations.localeOf(context);
    final conCamara = await showModalBottomSheet<bool>(
      context: context,
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
                traducirNarrativa(
                        'Dibuja cómo te imaginas a {n} en un papel, con los colores que quieras. Luego hazle una foto con buena luz: aparecerán así aquí y en su máquina.',
                        locale)
                    .replaceAll('{n}', traducirNarrativa(ficha.nombre, locale)),
                style: const TextStyle(
                    color: PaletaNeon.textoPrincipal,
                    fontSize: 14,
                    height: 1.45),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const ValueKey('dibujo-camara'),
                onPressed: () => Navigator.of(hoja).pop(true),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(
                    traducirNarrativa('Hacer una foto a mi dibujo', locale)),
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
    if (conCamara == null || !mounted) return;
    String? aviso;
    try {
      await DibujosMonstruos.elegir(widget.repositorio, ficha.id,
          conCamara: conCamara);
    } on DibujoSinContenido {
      aviso =
          'No he encontrado el dibujo en esa foto. Prueba con más luz y con el papel entero.';
    } catch (_) {
      aviso = 'No se ha podido abrir la cámara ni la galería.';
    }
    if (aviso != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(traducirNarrativa(aviso, locale))));
    }
  }

  @override
  Widget build(BuildContext contexto) {
    if (!_cargado) return const SizedBox.shrink();
    return ValueListenableBuilder<Map<String, String>>(
      valueListenable: DibujosMonstruos.rutas,
      builder: (_, dibujos, __) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          for (final ficha in CatalogoBestiario.todas)
            _TarjetaFicha(
              ficha: ficha,
              encuentros: ficha.encuentros(_estados),
              dibujo: dibujos[ficha.id],
              alDibujar:
                  DibujosMonstruos.disponible ? () => _dibujar(ficha) : null,
              alQuitarDibujo: () =>
                  DibujosMonstruos.quitar(widget.repositorio, ficha.id),
            ),
        ],
      ),
    );
  }
}

class _TarjetaFicha extends StatelessWidget {
  final FichaBestiario ficha;
  final int encuentros;

  /// El dibujo del niño para esta familia, si lo ha hecho.
  final String? dibujo;

  /// Null donde no se puede dibujar (la web).
  final VoidCallback? alDibujar;
  final VoidCallback alQuitarDibujo;

  const _TarjetaFicha({
    required this.ficha,
    required this.encuentros,
    required this.dibujo,
    required this.alDibujar,
    required this.alQuitarDibujo,
  });

  bool get _conocida => encuentros >= 1;

  String _etiquetaRareza(Locale locale) {
    switch (ficha.rareza) {
      case RarezaBestiario.comun:
        return traducirNarrativa('Común', locale);
      case RarezaBestiario.inusual:
        return traducirNarrativa('Inusual', locale);
    }
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final colorFicha =
        _conocida ? ficha.colorAura : PaletaNeon.textoTenue.withOpacity(0.5);
    final revelados = ficha.tramosRevelados(encuentros);
    final bloqueados = ficha.tramos.length - revelados.length;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PaletaNeon.fondoMedio.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorFicha.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // La "silueta": el aura de la familia, la misma que el
              // niño ve flotando en el cazadero; o su dibujo, si lo hizo.
              if (_conocida && dibujo != null)
                DibujoMonstruo(
                    ruta: dibujo!, color: ficha.colorAura, tamano: 52)
              else
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PaletaNeon.violetaBase
                        .withOpacity(_conocida ? 0.85 : 0.4),
                    border: Border.all(color: colorFicha, width: 1.4),
                    boxShadow: _conocida
                        ? [
                            BoxShadow(
                              color: ficha.colorAura.withOpacity(0.35),
                              blurRadius: 10,
                            ),
                          ]
                        : const [],
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _conocida
                          ? traducirNarrativa(ficha.nombre, locale)
                          : '???',
                      style: TextStyle(
                        color: _conocida
                            ? PaletaNeon.textoPrincipal
                            : PaletaNeon.textoTenue,
                        fontSize: 15,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_etiquetaRareza(locale)} · '
                      '${traducirNarrativa(ficha.habitat, locale)}',
                      style: TextStyle(
                        color: PaletaNeon.textoTenue.withOpacity(0.8),
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (_conocida)
                Text(
                  '× $encuentros',
                  style: TextStyle(
                    color: colorFicha.withOpacity(0.9),
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
            ],
          ),
          for (final tramo in revelados) ...[
            const SizedBox(height: 10),
            Text(
              traducirNarrativa(tramo.texto, locale),
              style: TextStyle(
                color: PaletaNeon.textoPrincipal.withOpacity(0.85),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
          // El taller de dibujo: sólo para las familias ya vistas.
          if (_conocida && alDibujar != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: [
                TextButton.icon(
                  key: ValueKey('dibujar-${ficha.id}'),
                  onPressed: alDibujar,
                  icon: Icon(Icons.brush_outlined, size: 16, color: colorFicha),
                  label: Text(
                    traducirNarrativa(
                        dibujo == null ? 'Dibujarlo' : 'Cambiar el dibujo',
                        locale),
                    style: TextStyle(
                        color: colorFicha, fontSize: 12, letterSpacing: 1),
                  ),
                ),
                if (dibujo != null)
                  TextButton(
                    key: ValueKey('quitar-dibujo-${ficha.id}'),
                    onPressed: alQuitarDibujo,
                    child: Text(
                      traducirNarrativa('Volver al original', locale),
                      style: TextStyle(
                          color: PaletaNeon.textoTenue.withOpacity(0.8),
                          fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
          // Los tramos que faltan se insinúan sin contador ni barra:
          // una línea de puntos por tramo. El niño entiende que hay
          // más sin que nadie le ponga deberes.
          if (_conocida && bloqueados > 0) ...[
            const SizedBox(height: 10),
            for (var i = 0; i < bloqueados; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '· · ·',
                  style: TextStyle(
                    color: PaletaNeon.textoTenue.withOpacity(0.4),
                    fontSize: 13,
                    letterSpacing: 3,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
