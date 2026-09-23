import 'package:flutter/material.dart';

import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import '../datos/repositorio_progreso.dart';
import '../dominio/bestiario.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';

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
    if (!mounted) return;
    setState(() {
      _estados = mapa;
      _cargado = true;
    });
  }

  @override
  Widget build(BuildContext contexto) {
    if (!_cargado) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        for (final ficha in CatalogoBestiario.todas)
          _TarjetaFicha(
            ficha: ficha,
            encuentros: ficha.encuentros(_estados),
          ),
      ],
    );
  }
}

class _TarjetaFicha extends StatelessWidget {
  final FichaBestiario ficha;
  final int encuentros;

  const _TarjetaFicha({required this.ficha, required this.encuentros});

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
    final colorFicha = _conocida
        ? ficha.colorAura
        : PaletaNeon.textoTenue.withOpacity(0.5);
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
              // niño ve flotando en el cazadero.
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
