import 'package:flutter/material.dart';

import '../dominio/capa_historica.dart';

/// Los diez pigmentos históricos de la guía visual (doc 11 §2.1).
/// Saturación media-baja, sin negro ni blanco puros (§2.2).
///
/// Valores PROVISIONALES: aproximaciones del operador hasta que el
/// ilustrador cierre la paleta. Conviven con [PaletaArchivo], que
/// sigue siendo la de la interfaz general.
class Pigmentos {
  Pigmentos._();

  static const Color ocreAmarillo = Color(0xFFC49A45);
  static const Color ocreRojo = Color(0xFFA8553A);
  static const Color tierraSiena = Color(0xFF8A5A3B);
  static const Color tierraSombra = Color(0xFF4A3B2E);
  static const Color bermellon = Color(0xFFB8412F);
  static const Color lapislazuli = Color(0xFF2F4A7A);
  static const Color verdeMalaquita = Color(0xFF4F7A5E);
  static const Color negroCarbon = Color(0xFF221E1B);
  static const Color blancoPlomo = Color(0xFFEDE6D6);
  static const Color oroDePan = Color(0xFFC8A450);

  /// Madera de la mesa de trabajo del ático.
  static const Color maderaMesa = Color(0xFF5C4130);

  /// Pergamino / papel de trapo de las fichas.
  static const Color papelTrapo = Color(0xFFE4D6BA);
}

/// Acentos de una capa histórica (doc 11 §2.3). El primero es el
/// dominante; el resto, secundarios.
class PaletaDeCapa {
  const PaletaDeCapa(this.acentos);

  final List<Color> acentos;

  Color get dominante => acentos.first;
  Color get secundario => acentos.length > 1 ? acentos[1] : acentos.first;

  static PaletaDeCapa de(CapaHistorica capa) {
    switch (capa) {
      case CapaHistorica.paleo:
        return const PaletaDeCapa(
            [Pigmentos.ocreRojo, Pigmentos.tierraSombra, Pigmentos.negroCarbon]);
      case CapaHistorica.neo:
        return const PaletaDeCapa([
          Pigmentos.tierraSiena,
          Pigmentos.ocreAmarillo,
          Pigmentos.verdeMalaquita,
        ]);
      case CapaHistorica.proto:
        return const PaletaDeCapa([
          Color(0xFF8C6B3F), // bronce
          Pigmentos.ocreRojo,
          Pigmentos.negroCarbon,
        ]);
      case CapaHistorica.romana:
        return const PaletaDeCapa([
          Pigmentos.bermellon,
          Pigmentos.lapislazuli,
          Pigmentos.blancoPlomo,
        ]);
      case CapaHistorica.antiq:
        return const PaletaDeCapa([
          Color(0xFF9A3A2C), // rojo visigodo
          Pigmentos.oroDePan,
          Pigmentos.negroCarbon,
        ]);
      case CapaHistorica.form:
        return const PaletaDeCapa([
          Pigmentos.verdeMalaquita,
          Pigmentos.ocreAmarillo,
          Pigmentos.lapislazuli,
        ]);
      case CapaHistorica.plena:
        return const PaletaDeCapa([
          Pigmentos.lapislazuli,
          Pigmentos.bermellon,
          Pigmentos.oroDePan,
        ]);
      case CapaHistorica.dinastias:
        return const PaletaDeCapa([
          Color(0xFF34508A), // azul Évreux
          Pigmentos.oroDePan,
          Pigmentos.blancoPlomo,
        ]);
    }
  }
}
