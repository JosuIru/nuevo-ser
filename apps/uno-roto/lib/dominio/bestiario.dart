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
      // La multiplicación y la división (FR.18-21) son de las Polillas.
      idsHabilidades: ['FR.14', 'FR.15', 'FR.16', 'FR.17'],
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
      // Las cuentas con decimales (DEC.05-07) son de los Revisores.
      idsHabilidades: ['DEC.01', 'DEC.02', 'DEC.03', 'DEC.04', 'DEC.08', 'DEC.09'],
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
    FichaBestiario(
      id: 'oxidados',
      nombre: 'Los Oxidados',
      idsHabilidades: ['DIV.06', 'DIV.07'],
      habitat: 'Puerto, en la grúa',
      rareza: RarezaBestiario.inusual,
      colorAura: Color(0xFFC9A04A),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Óxido con hambre de dientes. Se meten en los engranajes de la grúa y se comen un diente aquí y otro allá, hasta que las marcas ya no vuelven a coincidir.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'Odian el número que comparten dos ruedas. Por eso lo esconden: quien encuentra el mayor divisor común o el primer múltiplo común los deja sin nada que roer.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'Rexán guarda en un bote una rueda de doce dientes que los Oxidados dejaron en siete. Dice que no la tira porque siete es primo y ya nadie puede quitarle nada más.',
        ),
      ],
    ),
    FichaBestiario(
      id: 'signos',
      nombre: 'Los Signos',
      idsHabilidades: ['ARI.04', 'ARI.05'],
      habitat: 'Montaña, en la mina',
      rareza: RarezaBestiario.inusual,
      colorAura: Color(0xFFB98A73),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Viven por debajo del suelo, donde los números llevan un menos delante. No son números malos: son los que cuentan hacia abajo.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'Su truco es esconder el signo. Si bajas de la planta 3 a la −2 y te olvidas del cero, te quedas un piso corto. Los Signos lo saben y te esperan en el rellano.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'En la planta más honda de la mina hay una pared con marcas: −1, −2, −3… hasta donde llega la luz. Nadie sabe quién empezó a contar. Nadie ha llegado al final.',
        ),
      ],
    ),
    FichaBestiario(
      id: 'destellos',
      nombre: 'Los Destellos',
      idsHabilidades: ['MED.04', 'GEO.01', 'GEO.07'],
      habitat: 'Industria, en los focos',
      rareza: RarezaBestiario.comun,
      colorAura: Color(0xFF7CF2FF),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Chispas sueltas que se beben la luz. Si el rayo pasa demasiado cerca, se lo tragan. Se esquivan eligiendo bien el ángulo.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'La luz rebota en un espejo igual que llega: el mismo ángulo de ida que de vuelta. Los Destellos no lo entienden y se quedan mirando el reflejo, quietos.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'Vadic dice que en Industria hubo un foco que alumbraba en línea recta hasta el mar. Desde que llegaron los Destellos, la luz dobla esquinas. A Vadic no le gusta nada que doble esquinas.',
        ),
      ],
    ),
    FichaBestiario(
      id: 'maleza',
      nombre: 'La Maleza',
      idsHabilidades: ['GEO.02', 'GEO.03', 'GEO.04', 'MED.05'],
      habitat: 'Afueras, en los planos',
      rareza: RarezaBestiario.comun,
      colorAura: Color(0xFF7FB069),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Hierba que brota en las casillas de los planos y no deja construir encima. No muerde. Sólo ocupa sitio.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'Con la Maleza en medio, 24 metros cuadrados ya no caben como 4 por 6, pero sí como 3 por 8. La misma área, otra forma. La Maleza enseña eso sin querer.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'Las casas de las Afueras se levantaron sobre planos mojados. Por eso algunas tienen un rincón torcido: es donde creció la Maleza y alguien no quiso volver a medir.',
        ),
      ],
    ),
    FichaBestiario(
      id: 'azarosos',
      nombre: 'Los Azarosos',
      idsHabilidades: ['EST.05', 'EST.06'],
      habitat: 'Puerto, en el mar',
      rareza: RarezaBestiario.inusual,
      colorAura: Color(0xFF4D86C9),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Peces que cambian de color al saltar. No hacen trampa: son el azar mismo, nadando.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'Un solo lance no dice nada. Veinte ya cuentan algo. Con la red buena también se puede sacar un pez gris, y eso no quita la razón a quien la eligió.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'Los pescadores más viejos del Puerto no apuestan nunca. Cuentan. Dicen que el mar no tiene memoria, pero las libretas sí.',
        ),
      ],
    ),
    FichaBestiario(
      id: 'oleaje',
      nombre: 'El Oleaje',
      idsHabilidades: ['EST.01', 'EST.03', 'EST.04'],
      habitat: 'Puerto, en los barcos',
      rareza: RarezaBestiario.comun,
      colorAura: Color(0xFF6FB7C9),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Olas que llegan cada cierto rato y empujan el barco hacia la pila más alta. Avisan antes. No rompen nada.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'Un barco bien cargado deja pasar el Oleaje sin moverse. Para eso hay que saber repartir: la media es lo que tendría cada pila si fueran todas iguales.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'Hay capitanes que leen el Oleaje en las pilas de contenedores como quien lee un gráfico. No miran el mar. Miran la carga, y saben.',
        ),
      ],
    ),
    FichaBestiario(
      id: 'destenidos',
      nombre: 'Los Desteñidos',
      idsHabilidades: ['PROP.01', 'PROP.02', 'PROP.03', 'PROP.06', 'PROP.07'],
      habitat: 'Mercado, en los toldos',
      rareza: RarezaBestiario.comun,
      colorAura: Color(0xFF6BB38A),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Manchas grises que se comen el color de un toldo cuando la mezcla no guarda la receta. El toldo se queda gris, pero se puede repintar.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'Dos de azul por tres de amarillo es el mismo verde que cuatro por seis. Los Desteñidos no soportan que el color se mantenga cuando todo crece a la vez.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'En el Mercado cuentan que el primer toldo desteñido fue el de un puesto que subió los precios sin avisar. Desde entonces, cada vez que alguien hace trampa con un porcentaje, algo pierde el color.',
        ),
      ],
    ),
    FichaBestiario(
      id: 'cambiados',
      nombre: 'Los Cambiados',
      idsHabilidades: ['MED.01', 'MED.02', 'MED.03'],
      habitat: 'Industria, en el taller',
      rareza: RarezaBestiario.comun,
      colorAura: Color(0xFFD9B77A),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Piezas con la etiqueta en otra unidad: una pesa de 0,5 kg junto a una de 500 g. Parecen distintas. Son la misma.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'Algunos Cambiados mienten. Uno dice que 1000 cm son un kilómetro, muy serio. Hay que apartarlo sin enfadarse: sólo le falta subir dos peldaños de la escalera.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'El relojero del taller tiene un reloj que marca las horas en minutos, otro en segundos y otro en días. Dice que así nunca llega tarde, porque siempre hay uno que va bien.',
        ),
      ],
    ),
    FichaBestiario(
      id: 'mudos',
      nombre: 'Los Mudos',
      idsHabilidades: ['FUN.01', 'ALG.03'],
      habitat: 'Montaña, en la caja negra',
      rareza: RarezaBestiario.inusual,
      colorAura: Color(0xFF9E95C7),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Números que la caja negra se traga sin devolver. Cada Mudo cuesta un experimento, y los experimentos se acaban.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'Callan, pero no esconden la regla. Si entra 1 y sale 5, entra 2 y sale 8, la caja suma de tres en tres. Los Mudos sólo esperan a que alguien lo diga en voz alta.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'Nadie en la Montaña sabe quién construyó la caja. Rexán la encontró ya cerrada. Tiene una teoría: dentro no hay nada, sólo una regla. Y una regla no necesita sitio.',
        ),
      ],
    ),
    FichaBestiario(
      id: 'polillas',
      nombre: 'Las Polillas',
      idsHabilidades: ['FR.18', 'FR.19', 'FR.20', 'FR.21'],
      habitat: 'Mercado, en el telar',
      rareza: RarezaBestiario.comun,
      colorAura: Color(0xFFD9848C),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Se comen la tela que sobra y dejan agujeros donde no hay que mirar. Si te fijas en los agujeros, te equivocas de cuenta.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'Donde se cruzan dos hilos está la multiplicación: tres cuartos de ancho por dos tercios de alto. Las Polillas nunca muerden ahí. Dicen que sabe raro.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'La tejedora más vieja del Mercado no tira los retales. Los cose en una manta de trozos iguales. Dice que es la única tela a la que las Polillas no se acercan: está toda contada.',
        ),
      ],
    ),
    FichaBestiario(
      id: 'revisores',
      nombre: 'Los Revisores',
      idsHabilidades: ['DEC.05', 'DEC.06', 'DEC.07'],
      habitat: 'Canales y Mercado, en el tranvía',
      rareza: RarezaBestiario.comun,
      colorAura: Color(0xFFE8B85C),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Suben al tranvía y piden el billete con una cuenta: tres viajes de 1,25, el 0,6 de 2,5, repartir 7,5 entre tres. No multan a nadie. Sólo quieren la cuenta bien hecha.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'Su manía es la coma. Si la pones un sitio más allá, el billete cuesta diez veces más, y el Revisor te mira por encima de las gafas sin decir nada.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'El tranvía para en cada décima. Los Revisores se saben todas las paradas de memoria, hasta las que no existen: la 1,45, la 2,999… Dicen que entre dos paradas siempre cabe otra.',
        ),
      ],
    ),
    FichaBestiario(
      id: 'vertigos',
      nombre: 'Los Vértigos',
      idsHabilidades: ['ARI.03', 'GEO.08'],
      habitat: 'Montaña, en los andamios',
      rareza: RarezaBestiario.inusual,
      colorAura: Color(0xFFC9A25E),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Ráfagas de viento que sólo soplan arriba. Si la escalera no es justa, la hacen temblar. Si lo es, pasan de largo.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'Pared y suelo al cuadrado, sumados, son la escalera al cuadrado. Los Vértigos lo saben desde siempre. Por eso no pueden con un 3, un 4 y un 5.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'Las farolas de la Montaña se apagaron el día que alguien subió con una escalera larga «por si acaso». Rexán lo cuenta a menudo. Nunca dice quién fue.',
        ),
      ],
    ),
    FichaBestiario(
      id: 'fugas',
      nombre: 'Las Fugas',
      idsHabilidades: ['GEO.05', 'GEO.06'],
      habitat: 'Industria, en los depósitos',
      rareza: RarezaBestiario.comun,
      colorAura: Color(0xFF4FA9D9),
      tramos: [
        TramoLore(
          umbralEncuentros: umbralTramo1,
          texto:
              'Agujeros que aparecen cuando se pide más agua de la que cabe. Lo que sobra, lo tiran al suelo.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo2,
          texto:
              'Un depósito se llena por capas: largo por ancho cubitos en cada una, y tantas capas como alto. Quien cuenta así nunca pide de más, y las Fugas se secan.',
        ),
        TramoLore(
          umbralEncuentros: umbralTramo3,
          texto:
              'Las tuberías de la Industria son redondas porque Vadic dice que el círculo es la forma que más agua guarda con menos chapa. Las Fugas prefieren las esquinas.',
        ),
      ],
    ),
  ];
}
