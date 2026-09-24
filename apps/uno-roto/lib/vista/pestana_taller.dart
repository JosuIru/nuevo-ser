import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show EstadoHabilidad;

import '../datos/dibujos_taller.dart';
import '../datos/repositorio_progreso.dart';
import '../dominio/catalogo_distritos.dart';
import '../dominio/minijuegos/catalogo_minijuegos.dart';
import '../dominio/personajes_taller.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';
import 'dibujo_con_halo.dart';
import 'minijuegos/pantalla_recreativa.dart' show coloresDeMaquina;
import 'personajes/retratos.dart';
import 'taller_dibujo.dart';

/// Pestaña TALLER de Mi Cuaderno (El taller de dibujo, fases 2 y 3):
/// los personajes, los distritos y las máquinas que el niño ya conoce,
/// con la invitación a dibujarlos. Lo que dibuje aparece en el juego:
/// los personajes en sus escenas, los distritos como su paisaje y las
/// máquinas como su armario en la sala de Rexán. (Los monstruos se
/// dibujan desde el bestiario.)
///
/// Lo que aún no conoce sale como «???»: curiosidad, no lista de tareas.
class PestanaTaller extends StatefulWidget {
  final RepositorioProgreso repositorio;

  const PestanaTaller({super.key, required this.repositorio});

  @override
  State<PestanaTaller> createState() => _PestanaTallerState();
}

class _PestanaTallerState extends State<PestanaTaller> {
  Set<String> _personajesConocidos = const {};
  Set<String> _distritosConocidos = const {};
  Set<String> _maquinasConocidas = const {};
  bool _cargado = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final repositorio = widget.repositorio;
    final flags = await repositorio.flagsNarrativosActivos();
    final distritos = <String>{'tejados'};
    for (final distrito in CatalogoDistritos.todos) {
      if (await repositorio.distritoVisitado(distrito.identificador))
        distritos.add(distrito.identificador);
    }
    // Una máquina se conoce cuando ya está encendida en la sala.
    final estados = <String, EstadoHabilidad?>{};
    for (final definicion in CatalogoMinijuegos.todos) {
      for (final id in [...definicion.habilidades, ...definicion.llaves]) {
        estados[id] ??= await repositorio.cargarEstadoHabilidad(id);
      }
    }
    final maquinas = {
      for (final definicion in CatalogoMinijuegos.todos)
        if (disponibilidadMinijuego(definicion, estados).disponible)
          definicion.id.name,
    };
    await cargarDibujosDelTaller(repositorio);
    if (!mounted) return;
    setState(() {
      _personajesConocidos = personajesConocidos(flags);
      _distritosConocidos = distritos;
      _maquinasConocidas = maquinas;
      _cargado = true;
    });
  }

  VoidCallback? _dibujar(ColeccionDibujos coleccion, String id, String nombre,
          String invitacion) =>
      ColeccionDibujos.disponible
          ? () => dibujarEnElTaller(
                context,
                coleccion: coleccion,
                repositorio: widget.repositorio,
                id: id,
                nombre: nombre,
                invitacion: invitacion,
              )
          : null;

  @override
  Widget build(BuildContext contexto) {
    if (!_cargado) return const SizedBox.shrink();
    final locale = Localizations.localeOf(contexto);
    return AnimatedBuilder(
      animation: Listenable.merge([
        dibujosPersonajes.rutas,
        dibujosDistritos.rutas,
        dibujosMaquinas.rutas,
        dibujosFondos.rutas
      ]),
      builder: (_, __) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              traducirNarrativa(
                  'Así lo ves tú. Dibújalo en papel, hazle una foto y aparecerá así en el juego.',
                  locale),
              style: TextStyle(
                  color: PaletaNeon.textoTenue.withOpacity(0.85),
                  fontSize: 13,
                  height: 1.45,
                  fontStyle: FontStyle.italic),
            ),
          ),
          _Seccion(traducirNarrativa('Personajes', locale)),
          for (final personaje in personajesDelTaller)
            _TarjetaTaller(
              id: personaje.id,
              conocido: _personajesConocidos.contains(personaje.id),
              nombre: personaje.voz.nombreVisible,
              subtitulo: traducirNarrativa(personaje.papel, locale),
              color: colorDePersonaje(personaje.voz),
              visual: RetratoPersonaje(voz: personaje.voz),
              tieneDibujo:
                  dibujosPersonajes.rutas.value.containsKey(personaje.id),
              alDibujar: _dibujar(
                  dibujosPersonajes,
                  personaje.id,
                  personaje.voz.nombreVisible,
                  'Dibuja cómo ves a {n} en un papel, con los colores que quieras. Luego hazle una foto con buena luz: aparecerá así en sus escenas.'),
              alQuitar: () =>
                  dibujosPersonajes.quitar(widget.repositorio, personaje.id),
            ),
          _Seccion(traducirNarrativa('Distritos', locale)),
          for (final distrito in CatalogoDistritos.todos)
            _TarjetaTaller(
              id: distrito.identificador,
              conocido: _distritosConocidos.contains(distrito.identificador),
              nombre: traducirNarrativa(distrito.nombre, locale),
              subtitulo: traducirNarrativa('Su paisaje de noche', locale),
              color: distrito.colorAcento,
              visual: _Miniatura(
                dibujo: dibujosDistritos.rutas.value[distrito.identificador],
                original: 'assets/escenarios/${distrito.identificador}_on.webp',
                color: distrito.colorAcento,
              ),
              tieneDibujo: dibujosDistritos.rutas.value
                  .containsKey(distrito.identificador),
              alDibujar: _dibujar(
                  dibujosDistritos,
                  distrito.identificador,
                  distrito.nombre,
                  'Dibuja cómo ves {n} de noche, con sus edificios y sus luces. Luego hazle una foto con buena luz: será su paisaje.'),
              alQuitar: () => dibujosDistritos.quitar(
                  widget.repositorio, distrito.identificador),
            ),
          _Seccion(traducirNarrativa('Máquinas', locale)),
          for (final maquina in CatalogoMinijuegos.todos)
            _TarjetaTaller(
              id: maquina.id.name,
              conocido: _maquinasConocidas.contains(maquina.id.name),
              nombre: traducirNarrativa(maquina.nombre, locale),
              subtitulo: traducirNarrativa(
                  maquina.sala == 2
                      ? 'La planta de arriba'
                      : 'Las máquinas de Rexán',
                  locale),
              color: coloresDeMaquina[maquina.nombre] ?? PaletaNeon.violetaNeon,
              visual: _Miniatura(
                dibujo: dibujosMaquinas.rutas.value[maquina.id.name],
                original: 'assets/maquinas/${maquina.id.name}_on.png',
                color:
                    coloresDeMaquina[maquina.nombre] ?? PaletaNeon.violetaNeon,
              ),
              tieneDibujo:
                  dibujosMaquinas.rutas.value.containsKey(maquina.id.name),
              alDibujar: _dibujar(
                  dibujosMaquinas,
                  maquina.id.name,
                  maquina.nombre,
                  'Dibuja cómo te imaginas la máquina {n}. Luego hazle una foto con buena luz: así estará en la sala de Rexán.'),
              alQuitar: () =>
                  dibujosMaquinas.quitar(widget.repositorio, maquina.id.name),
              // Y lo de dentro: el fondo detrás del juego.
              extra: ColeccionDibujos.disponible
                  ? _BotonesFondo(
                      id: maquina.id.name,
                      tieneFondo: dibujosFondos.rutas.value
                          .containsKey(maquina.id.name),
                      color: coloresDeMaquina[maquina.nombre] ??
                          PaletaNeon.violetaNeon,
                      alDibujar: _dibujar(
                          dibujosFondos,
                          maquina.id.name,
                          maquina.nombre,
                          'Dibuja lo que se ve dentro de la máquina {n}, detrás del juego: un paisaje, un cielo, lo que quieras. Luego hazle una foto con buena luz.')!,
                      alQuitar: () => dibujosFondos.quitar(
                          widget.repositorio, maquina.id.name),
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;

  const _Seccion(this.titulo);

  @override
  Widget build(BuildContext contexto) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 16, 0, 10),
        child: Text(
          titulo.toUpperCase(),
          style: TextStyle(
              color: PaletaNeon.ambarCanales.withOpacity(0.9),
              fontSize: 11,
              letterSpacing: 2.5),
        ),
      );
}

/// El dibujo del niño o la imagen original, en pequeño.
class _Miniatura extends StatelessWidget {
  final String? dibujo;
  final String original;
  final Color color;

  const _Miniatura(
      {required this.dibujo, required this.original, required this.color});

  @override
  Widget build(BuildContext contexto) {
    final ruta = dibujo;
    if (ruta != null) return DibujoConHalo(ruta: ruta, color: color);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(original,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink()),
    );
  }
}

class _TarjetaTaller extends StatelessWidget {
  final String id;
  final bool conocido;
  final String nombre;
  final String subtitulo;
  final Color color;
  final Widget visual;
  final bool tieneDibujo;
  final VoidCallback? alDibujar;
  final VoidCallback alQuitar;

  /// Otra fila de acciones bajo los botones (el fondo de las máquinas).
  final Widget? extra;

  const _TarjetaTaller({
    this.extra,
    required this.id,
    required this.conocido,
    required this.nombre,
    required this.subtitulo,
    required this.color,
    required this.visual,
    required this.tieneDibujo,
    required this.alDibujar,
    required this.alQuitar,
  });

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final colorTarjeta =
        conocido ? color : PaletaNeon.textoTenue.withOpacity(0.5);
    return Container(
      key: ValueKey('taller-$id'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PaletaNeon.fondoMedio.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorTarjeta.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            height: 88,
            child: conocido
                ? visual
                : Icon(Icons.help_outline, color: colorTarjeta, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conocido ? nombre : '???',
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
                      ? subtitulo
                      : traducirNarrativa('Todavía no os conocéis.', locale),
                  style: TextStyle(
                      color: PaletaNeon.textoTenue.withOpacity(0.8),
                      fontSize: 12,
                      letterSpacing: 1),
                ),
                if (conocido && alDibujar != null) ...[
                  const SizedBox(height: 6),
                  BotonesTaller(
                    id: id,
                    tieneDibujo: tieneDibujo,
                    color: colorTarjeta,
                    alDibujar: alDibujar!,
                    alQuitar: alQuitar,
                  ),
                  if (extra != null) extra!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// «Dibujar el fondo» / «Cambiar el fondo» y «Quitar el fondo».
class _BotonesFondo extends StatelessWidget {
  final String id;
  final bool tieneFondo;
  final Color color;
  final VoidCallback alDibujar;
  final VoidCallback alQuitar;

  const _BotonesFondo({
    required this.id,
    required this.tieneFondo,
    required this.color,
    required this.alDibujar,
    required this.alQuitar,
  });

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    return Wrap(
      spacing: 4,
      children: [
        TextButton.icon(
          key: ValueKey('dibujar-fondo-$id'),
          onPressed: alDibujar,
          icon: Icon(Icons.wallpaper_outlined, size: 16, color: color),
          label: Text(
            traducirNarrativa(
                tieneFondo ? 'Cambiar el fondo' : 'Dibujar el fondo', locale),
            style: TextStyle(color: color, fontSize: 12, letterSpacing: 1),
          ),
        ),
        if (tieneFondo)
          TextButton(
            key: ValueKey('quitar-fondo-$id'),
            onPressed: alQuitar,
            child: Text(
              traducirNarrativa('Quitar el fondo', locale),
              style: TextStyle(
                  color: PaletaNeon.textoTenue.withOpacity(0.8), fontSize: 12),
            ),
          ),
      ],
    );
  }
}
