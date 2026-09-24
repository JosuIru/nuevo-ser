import 'catalogo_escenas.dart';
import 'escena_cinematica.dart';
import 'plano_escena.dart';
import 'variantes_entrenamiento.dart';
import 'variantes_era_dos.dart';
import 'variantes_maquinas.dart';
import 'variantes_puentes.dart';
import 'voz_personaje.dart';

/// Los personajes que se pueden dibujar en El taller de dibujo (fase 2):
/// el elenco con retrato, sin los Fragmentos (esos son del bestiario).
class PersonajeTaller {
  /// El mismo id que usan los retratos (`sora`, `rexan`…).
  final String id;
  final VozPersonaje voz;

  /// Quién es, en pocas palabras y sin destripar nada (doc 04).
  final String papel;

  const PersonajeTaller(this.id, this.voz, this.papel);
}

const personajesDelTaller = [
  PersonajeTaller('sora', VozPersonaje.sora, 'La mentora'),
  PersonajeTaller('kai', VozPersonaje.kai, 'El rival'),
  PersonajeTaller('irune', VozPersonaje.irune, 'Maestra de los Tejados'),
  PersonajeTaller('rexan', VozPersonaje.rexan, 'Maestro de los Canales'),
  PersonajeTaller('naini', VozPersonaje.naini, 'Maestra del Mercado'),
  PersonajeTaller('vadic', VozPersonaje.vadic, 'Maestro de la Industria'),
  PersonajeTaller('oryn', VozPersonaje.oryn, 'Maestro del Puerto'),
  PersonajeTaller('brina', VozPersonaje.brina, 'Maestra de las Afueras'),
  PersonajeTaller('ari', VozPersonaje.ari, 'Aprendiz'),
  PersonajeTaller('niko', VozPersonaje.aprendizNiko, 'Aprendiz'),
];

/// El personaje del taller de [voz], si lo es.
PersonajeTaller? personajeDeVoz(Object voz) {
  for (final personaje in personajesDelTaller) {
    if (personaje.voz == voz) return personaje;
  }
  return null;
}

/// Todas las escenas del juego (historia y variantes).
List<EscenaCinematica> get _todasLasEscenas => [
      ...CatalogoEscenas.todas,
      ...VariantesEntrenamiento.todas,
      ...VariantesPuentes.todas,
      ...VariantesMaquinas.todas,
      ...VariantesEraDos.todas,
    ];

/// Los personajes que el niño ya conoce: los que han hablado en alguna
/// escena que ya ha visto (su flag de salida está activo). No hace falta
/// guardar nada nuevo: se deduce de los flags narrativos.
Set<String> personajesConocidos(Set<String> flagsActivos) {
  final conocidos = <String>{};
  for (final escena in _todasLasEscenas) {
    if (!flagsActivos.contains(escena.flagDeSalida)) continue;
    for (final plano in escena.planos) {
      final voz = switch (plano) {
        PlanoDialogo(:final voz) => voz,
        PlanoEleccion(:final voz) => voz,
        _ => null,
      };
      final personaje = voz == null ? null : personajeDeVoz(voz);
      if (personaje != null) conocidos.add(personaje.id);
    }
  }
  return conocidos;
}
