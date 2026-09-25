import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../nucleo/paleta.dart';

/// Voz concreta del worldbuilding de Uno Roto. Implementa el contrato
/// genérico [VozPersonajeContrato] del core para que el sistema de
/// cinemáticas compartido sepa cómo pintarla, manteniendo a la vez la
/// API estilo enum (`VozPersonaje.sora`, `voz.nombreVisible`) que ya
/// usaban todas las pantallas y catálogos del juego.
///
/// Los Fragmentos nombrados (Kurz, Eco, Zafrán, Vorax) son los que
/// llevan énfasis tipográfico — Cormorant Garamond italic, guía visual
/// §5. El resto del elenco usa la sans del tema.
final class VozPersonaje implements VozPersonajeContrato {
  @override
  final String nombreVisible;
  @override
  final Color colorNombre;
  @override
  final bool esEnfasis;

  /// Alias semántico de [esEnfasis] dentro de Uno Roto. Aquí "voz con
  /// énfasis" = Fragmento nombrado; preservar el getter facilita leer
  /// el código de pantallas y combates.
  bool get esFragmento => esEnfasis;

  const VozPersonaje._({
    required this.nombreVisible,
    required this.colorNombre,
    this.esEnfasis = false,
  });

  static const VozPersonaje narrador = VozPersonaje._(
    nombreVisible: '',
    colorNombre: PaletaNeon.textoTenue,
  );
  static const VozPersonaje sora = VozPersonaje._(
    nombreVisible: 'Sora',
    colorNombre: PaletaNeon.azulNeon,
  );
  static const VozPersonaje kai = VozPersonaje._(
    nombreVisible: 'Kai',
    colorNombre: PaletaNeon.rosaAcento,
  );
  static const VozPersonaje irune = VozPersonaje._(
    nombreVisible: 'Irune',
    colorNombre: PaletaNeon.violetaNeon,
  );
  static const VozPersonaje oryn = VozPersonaje._(
    nombreVisible: 'Oryn',
    colorNombre: PaletaNeon.exitoSuave,
  );
  static const VozPersonaje naini = VozPersonaje._(
    nombreVisible: 'Naini',
    colorNombre: PaletaNeon.rosaAcento,
  );
  static const VozPersonaje brina = VozPersonaje._(
    nombreVisible: 'Brina',
    colorNombre: PaletaNeon.violetaNeon,
  );
  static const VozPersonaje rexan = VozPersonaje._(
    nombreVisible: 'Rexán',
    colorNombre: PaletaNeon.ambarCanales,
  );
  static const VozPersonaje vadic = VozPersonaje._(
    nombreVisible: 'Vadic',
    colorNombre: PaletaNeon.grisMetal,
  );
  static const VozPersonaje ari = VozPersonaje._(
    nombreVisible: 'Ari',
    colorNombre: PaletaNeon.exitoSuave,
  );
  static const VozPersonaje aprendizNiko = VozPersonaje._(
    nombreVisible: 'Niko',
    colorNombre: PaletaNeon.azulNeon,
  );
  /// Arco V (Era 3): el guardián del Archivo de la Sociedad.
  static const VozPersonaje ulden = VozPersonaje._(
    nombreVisible: 'Ulden',
    colorNombre: PaletaNeon.ambarCanales,
  );

  /// Arco V (Era 3): la Algebrista de la Montaña.
  static const VozPersonaje aldara = VozPersonaje._(
    nombreVisible: 'Aldara',
    colorNombre: PaletaNeon.exitoSuave,
  );
  static const VozPersonaje fragmentoKurz = VozPersonaje._(
    nombreVisible: 'Kurz',
    colorNombre: PaletaNeon.violetaNeon,
    esEnfasis: true,
  );
  static const VozPersonaje fragmentoEco = VozPersonaje._(
    nombreVisible: 'Eco',
    colorNombre: PaletaNeon.violetaNeon,
    esEnfasis: true,
  );
  static const VozPersonaje fragmentoZafran = VozPersonaje._(
    nombreVisible: 'Zafrán',
    colorNombre: PaletaNeon.violetaNeon,
    esEnfasis: true,
  );
  static const VozPersonaje fragmentoVorax = VozPersonaje._(
    nombreVisible: 'Vorax',
    colorNombre: PaletaNeon.violetaNeon,
    esEnfasis: true,
  );

  /// Arco V: el Fragmento de la niebla, que borra los números que sabes.
  static const VozPersonaje fragmentoVelo = VozPersonaje._(
    nombreVisible: 'Velo',
    colorNombre: PaletaNeon.violetaNeon,
    esEnfasis: true,
  );

  /// Tipografía Cormorant Garamond italic para los Fragmentos —
  /// guía visual §5. Sans con tracking más amplio para humanos.
  @override
  TextStyle estiloTextoCuerpo() {
    if (esEnfasis) {
      return const TextStyle(
        fontFamily: 'CormorantGaramond',
        fontSize: 22,
        height: 1.45,
        color: PaletaNeon.textoPrincipal,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w400,
      );
    }
    return const TextStyle(
      fontSize: 20,
      height: 1.5,
      color: PaletaNeon.textoPrincipal,
      letterSpacing: 0.3,
      fontWeight: FontWeight.w300,
    );
  }
}
