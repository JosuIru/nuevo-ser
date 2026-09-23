import 'package:flutter/material.dart';

import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// El bestiario de Fragmentos (doc 16, eje C): fichas por familia con
/// identidad — nombre diegético, hábitat, rareza — y un texto de lore
/// que se completa **por tramos** según los encuentros del niño con
/// esa familia. La recompensa es conocimiento, no botín: el tramo
/// nuevo cuenta algo del mundo (doc 16 §3.C).
///
/// Los "encuentros" no necesitan persistencia nueva: se derivan del
/// `totalExposiciones` que el motor de maestría ya guarda por
/// habilidad, sumando las habilidades de la familia. Cada puzzle
/// jugado con un Fragmento de la familia es un encuentro.
enum RarezaBestiario { comun, inusual }

/// Un tramo de la ficha: a partir de [umbralEncuentros] encuentros,
/// el [texto] se revela en el bestiario.
class TramoLore {
  final int umbralEncuentros;
  final String texto;

  const TramoLore({required this.umbralEncuentros, required this.texto});
}

class FichaBestiario {
  /// Identificador estable.
  final String id;

  /// Nombre diegético de la familia, en castellano canónico.
  final String nombre;

  /// Ids de las habilidades del catálogo cuyas exposiciones cuentan
  /// como encuentros con esta familia.
  final List<String> idsHabilidades;

  /// Dónde suele encontrarse, en texto corto (castellano canónico).
  final String habitat;

  final RarezaBestiario rareza;

  /// Color del aura de la familia — el mismo que usa el pintor del
  /// cazadero, para que el niño la reconozca de vista.
  final Color colorAura;

  /// Tramos en orden creciente de umbral. El primero debería ser 1
  /// (el niño ya los ha visto) y los siguientes premiar la vuelta.
  final List<TramoLore> tramos;

  const FichaBestiario({
    required this.id,
    required this.nombre,
    required this.idsHabilidades,
    required this.habitat,
    required this.rareza,
    required this.colorAura,
    required this.tramos,
  });

  /// Encuentros acumulados con la familia según los estados de
  /// habilidad persistidos. Función pura.
  int encuentros(Map<String, EstadoHabilidad> estados) {
    var total = 0;
    for (final id in idsHabilidades) {
      total += estados[id]?.totalExposiciones ?? 0;
    }
    return total;
  }

  /// Tramos ya revelados para [encuentros] encuentros.
  List<TramoLore> tramosRevelados(int encuentros) =>
      tramos.where((t) => encuentros >= t.umbralEncuentros).toList();
}

class CatalogoBestiario {
  CatalogoBestiario._();

  /// Umbrales canónicos de los tres tramos (doc 16 §3.C).
  static const int umbralTramo1 = 1;
  static const int umbralTramo2 = 5;
  static const int umbralTramo3 = 15;

  static const List<FichaBestiario> todas = [
    FichaBestiario(
      id: 'plenos',
      nombre: 'Los Plenos',
      idsHabilidades: ['FR.01', 'FR.02'],
      habitat: 'Tejados del Centro',
      rareza: RarezaBestiario.comun,
      colorAura: Color(0xFF4DC9FF),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'La forma más simple de Fragmento: un círculo entero que '
              'se cree indivisible. Se caza cortándolo en partes '
              'iguales. Los primeros que verás.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'No huyen casi nunca. Sora dice que es porque no saben '
              'que están rotos — cada Pleno se cree el Uno entero, y '
              'esperar no cuesta nada cuando te crees eterno.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'Irune guarda el primer Pleno que desfragmentó, dibujado '
              'a lápiz en la última página de su cuaderno. Debajo '
              'escribió: "No era grande. Era mío."',
        ),
      ],
    ),
    FichaBestiario(
      id: 'comparadores',
      nombre: 'Los Comparadores',
      idsHabilidades: ['FR.03', 'FR.04', 'FR.05', 'FR.06', 'FR.07', 'FR.08'],
      habitat: 'Tejados y Canales',
      rareza: RarezaBestiario.comun,
      colorAura: Color(0xFFA8E6A3),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Aparecen de dos en dos o de tres en tres, nunca solos. '
              'Uno siempre vale más que otro, aunque no lo parezca — '
              'cazarlos es saber cuál.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'Las parejas engañan a los ojos: la fracción con números '
              'grandes puede ser la pequeña. Los cazadores novatos '
              'caen. Tú caíste. Todos caímos.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'Hay una teoría en la redacción del Faro: los '
              'Comparadores no son varios Fragmentos, sino uno solo '
              'que se mira. Nadie la ha podido desmentir.',
        ),
      ],
    ),
    FichaBestiario(
      id: 'espejos',
      nombre: 'Los Espejos',
      idsHabilidades: ['FR.09', 'FR.10', 'FR.11'],
      habitat: 'Barrio de los Canales',
      rareza: RarezaBestiario.comun,
      colorAura: Color(0xFFFFC36B),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Cada Espejo tiene infinitas caras: 1/2, 2/4, 3/6… Todas '
              'valen lo mismo. Cazarlo es reconocerlo aunque venga '
              'disfrazado.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'Se amplifican y se simplifican a voluntad, como quien '
              'se cambia de abrigo. La forma mínima es su cara '
              'verdadera — la única que no pueden quitarse.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'En los Canales dicen que si ves las dos caras de un '
              'Espejo en el agua a la vez, el reflejo se queda '
              'contigo. Pregúntale a El Reflejo, si lo encuentras.',
        ),
      ],
    ),
    FichaBestiario(
      id: 'impropios',
      nombre: 'Los Impropios',
      idsHabilidades: ['FR.12', 'FR.13'],
      habitat: 'Canales y Mercado',
      rareza: RarezaBestiario.inusual,
      colorAura: Color(0xFFFFA552),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Fragmentos con el numerador más grande que el '
              'denominador: llevan más de un entero dentro. Caminan '
              'raro, como sobrecargados.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'Se pueden reescribir como número mixto — el entero '
              'delante, el resto en fracción. No les gusta. Ningún '
              'Impropio admite que en el fondo es un dos y pico.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'Vorax era un Impropio antiguo que nunca dejó que lo '
              'reescribieran. Lo que guardaba dentro ya lo viste. '
              'O lo verás.',
        ),
      ],
    ),
    FichaBestiario(
      id: 'duales',
      nombre: 'Los Duales',
      idsHabilidades: ['FR.16', 'FR.17', 'FR.18', 'FR.19', 'FR.20', 'FR.21'],
      habitat: 'Barrio de los Canales',
      rareza: RarezaBestiario.inusual,
      colorAura: Color(0xFFFF9A6B),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Dos Fragmentos unidos por una línea de luz que no se '
              'puede cortar. Para cazarlos hay que hacerlos hablar el '
              'mismo idioma: mismo denominador.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'La línea que los une no es una cadena — es una '
              'operación. Sumar, restar, multiplicar. Resuélvela y la '
              'luz se apaga sola.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'Zafrán es el Dual más viejo que se conoce. No habla. '
              'Sora cree que los dos extremos discutieron hace siglos '
              'y desde entonces guardan silencio.',
        ),
      ],
    ),
    FichaBestiario(
      id: 'comas',
      nombre: 'Las Comas',
      idsHabilidades: [
        'DEC.01',
        'DEC.02',
        'DEC.03',
        'DEC.04',
        'DEC.05',
        'DEC.06',
        'DEC.07',
        'DEC.08',
        'DEC.09',
      ],
      habitat: 'Canales e Industria',
      rareza: RarezaBestiario.comun,
      colorAura: Color(0xFF7EE8D7),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Fragmentos que se escriben con coma: 0,5 · 2,37 · '
              '0,825. Parecen exactos y presumen de ello. Son '
              'fracciones con uniforme de trabajo.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'Su trampa favorita: aparentar que más cifras es más '
              'valor. 0,35 se pavonea delante de 0,4 y pierde. Lee '
              'las cifras, no las cuentes.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'En Industria las Comas se alinean solas junto a las '
              'máquinas de Vadic, décima con décima, centésima con '
              'centésima. Nadie las ha entrenado. A Vadic le inquieta.',
        ),
      ],
    ),
  ];
}
