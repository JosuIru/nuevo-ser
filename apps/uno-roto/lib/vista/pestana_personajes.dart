import 'package:flutter/material.dart';

import '../datos/dibujos_taller.dart';
import '../datos/repositorio_progreso.dart';
import '../dominio/personajes_taller.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';
import 'personajes/retratos.dart';
import 'taller_dibujo.dart';

/// Pestaña PERSONAJES de Mi Cuaderno (El taller de dibujo, fase 2): el
/// elenco que el niño ya conoce, con su retrato, y la invitación a
/// dibujarlos. Lo que dibuje aparece en sus escenas.
///
/// Los que aún no ha conocido salen como «???», igual que en el
/// bestiario: curiosidad, no lista de tareas.
class PestanaPersonajes extends StatefulWidget {
  final RepositorioProgreso repositorio;

  const PestanaPersonajes({super.key, required this.repositorio});

  @override
  State<PestanaPersonajes> createState() => _PestanaPersonajesState();
}

class _PestanaPersonajesState extends State<PestanaPersonajes> {
  Set<String> _conocidos = const {};
  bool _cargado = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final flags = await widget.repositorio.flagsNarrativosActivos();
    await dibujosPersonajes.cargar(widget.repositorio);
    if (!mounted) return;
    setState(() {
      _conocidos = personajesConocidos(flags);
      _cargado = true;
    });
  }

  @override
  Widget build(BuildContext contexto) {
    if (!_cargado) return const SizedBox.shrink();
    final locale = Localizations.localeOf(contexto);
    return ValueListenableBuilder<Map<String, String>>(
      valueListenable: dibujosPersonajes.rutas,
      builder: (_, dibujos, __) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              traducirNarrativa(
                  'Así los ves tú. Dibújalos en papel y aparecerán así en sus escenas.',
                  locale),
              style: TextStyle(
                  color: PaletaNeon.textoTenue.withOpacity(0.85),
                  fontSize: 13,
                  height: 1.45,
                  fontStyle: FontStyle.italic),
            ),
          ),
          for (final personaje in personajesDelTaller)
            _TarjetaPersonaje(
              personaje: personaje,
              conocido: _conocidos.contains(personaje.id),
              tieneDibujo: dibujos.containsKey(personaje.id),
              alDibujar: ColeccionDibujos.disponible
                  ? () => dibujarEnElTaller(
                        contexto,
                        coleccion: dibujosPersonajes,
                        repositorio: widget.repositorio,
                        id: personaje.id,
                        nombre: personaje.voz.nombreVisible,
                        invitacion:
                            'Dibuja cómo ves a {n} en un papel, con los colores que quieras. Luego hazle una foto con buena luz: aparecerá así en sus escenas.',
                      )
                  : null,
              alQuitar: () =>
                  dibujosPersonajes.quitar(widget.repositorio, personaje.id),
            ),
        ],
      ),
    );
  }
}

class _TarjetaPersonaje extends StatelessWidget {
  final PersonajeTaller personaje;
  final bool conocido;
  final bool tieneDibujo;
  final VoidCallback? alDibujar;
  final VoidCallback alQuitar;

  const _TarjetaPersonaje({
    required this.personaje,
    required this.conocido,
    required this.tieneDibujo,
    required this.alDibujar,
    required this.alQuitar,
  });

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final color = conocido
        ? colorDePersonaje(personaje.voz)
        : PaletaNeon.textoTenue.withOpacity(0.5);
    return Container(
      key: ValueKey('personaje-${personaje.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PaletaNeon.fondoMedio.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            height: 88,
            child: conocido
                ? RetratoPersonaje(voz: personaje.voz)
                : Icon(Icons.help_outline, color: color, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conocido ? personaje.voz.nombreVisible : '???',
                  style: TextStyle(
                    color: conocido
                        ? PaletaNeon.textoPrincipal
                        : PaletaNeon.textoTenue,
                    fontSize: 15,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  conocido
                      ? traducirNarrativa(personaje.papel, locale)
                      : traducirNarrativa('Todavía no os conocéis.', locale),
                  style: TextStyle(
                      color: PaletaNeon.textoTenue.withOpacity(0.8),
                      fontSize: 12,
                      letterSpacing: 1),
                ),
                if (conocido && alDibujar != null) ...[
                  const SizedBox(height: 6),
                  BotonesTaller(
                    id: personaje.id,
                    tieneDibujo: tieneDibujo,
                    color: color,
                    alDibujar: alDibujar!,
                    alQuitar: alQuitar,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
