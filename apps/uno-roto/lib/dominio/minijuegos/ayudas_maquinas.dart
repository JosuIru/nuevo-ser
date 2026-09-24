import 'balanza.dart';

/// Ayudas de las máquinas: cómo se juega cada una y un truco matemático
/// por habilidad. Textos en castellano (se traducen con
/// `traducirNarrativa`). Tono de Rexán: directo, sin condescendencia.
const trucosPorHabilidad = <String, String>{
  'ARI.01': 'Suma primero las decenas y luego las unidades: 38 + 25 = 50 + 13 = 63.',
  'OP.01': 'Primero multiplicaciones y divisiones; luego sumas y restas. '
      'Lo que va entre paréntesis, antes que nada.',
  'ARI.02': 'La potencia repite la multiplicación: 5² = 5 × 5 = 25. '
      'No es 5 × 2.',
  'FR.22': 'Para 3/4 de 20: divide 20 entre 4 (sale 5) y multiplica por 3 (sale 15).',
  'PROP.04': 'El 50 % es la mitad; el 25 %, la cuarta parte; el 10 %, '
      'dividir entre 10. El 20 % es el doble del 10 %.',
  'FR.14': 'Con el mismo denominador, se suman los de arriba: 2/5 + 1/5 = 3/5.',
  'FR.16': 'Con denominadores distintos, pásalas al mismo: 1/2 + 1/3 = 3/6 + 2/6 = 5/6.',
  'DEC.04': 'Coloca las comas una debajo de otra y suma como siempre: '
      '1,2 + 0,8 = 2,0.',
  'FR.09': 'Dos fracciones valen lo mismo si multiplicas (o divides) '
      'arriba y abajo por el mismo número: 1/2 = 2/4 = 3/6.',
  'DEC.08': 'Para pasar a decimal, divide el de arriba entre el de abajo: '
      '1/4 = 1 ÷ 4 = 0,25.',
  'PROP.05': 'Un porcentaje es una fracción sobre 100: 1/4 = 25/100 = 25 %.',
  'DIV.01': 'Los múltiplos de un número salen de su tabla: 3, 6, 9, 12…',
  'DIV.03': 'Entre 2: acaba en par. Entre 5: acaba en 0 o 5. '
      'Entre 10: acaba en 0.',
  'DIV.04': 'Entre 4: sus dos últimas cifras son múltiplo de 4. Entre 6: '
      'es par y divisible entre 3. Entre 9: sus cifras suman múltiplo de 9.',
  'DIV.05': 'Un primo sólo se divide entre 1 y entre sí mismo. '
      'Prueba a dividir entre 2, 3, 5 y 7.',
  'DEC.02': 'Compara cifra a cifra desde la coma: 0,45 < 0,5 porque '
      'en las décimas 4 < 5.',
  'FR.03': 'Mira la mitad del de abajo: si el de arriba es mayor, la '
      'fracción es mayor que 1/2. 5/8: la mitad de 8 es 4 y 5 > 4.',
  'ALG.01': 'Haz lo mismo en los dos platillos: quita las pesas sueltas '
      'de la izquierda en los dos lados y reparte lo que queda entre las bolsas.',
  'FR.04': 'Si el de arriba es menor que el de abajo, la fracción es menor '
      'que 1; si es mayor, pasa de 1. 7/5 es más que 1 porque 7 > 5.',
  'FR.05': 'Con el mismo denominador, gana el de arriba más grande: 5/8 > 3/8.',
  'FR.06': 'Con el mismo numerador, gana el denominador más pequeño: 2/3 > 2/5, '
      'porque los tercios son trozos más grandes que los quintos.',
  'FR.07': 'Multiplica en cruz: para 3/4 y 5/7, 3 × 7 = 21 y 5 × 4 = 20. '
      'Gana la del producto mayor: 3/4.',
  'FR.08': 'Compáralas de dos en dos, o pásalas todas a decimal (divide '
      'arriba entre abajo) y ordénalas.',
  'DEC.03': 'Iguala las cifras con ceros y compara desde la coma: '
      '0,5 = 0,50, y 0,50 > 0,45.',
  'GEO.03': 'El área de un rectángulo es ancho por alto: 4 × 6 = 24 m². '
      'Cuenta los cuadros de una fila y multiplica por las filas.',
  'GEO.02': 'El perímetro es la vuelta entera: suma los cuatro lados. '
      'Para la misma área, cuanto más cuadrado, menos valla.',
  'GEO.04': 'Un triángulo rectángulo es medio rectángulo: base por altura y '
      'entre dos. Para 12 m² de tejado, un rectángulo de 24.',
  'MED.05': 'Un metro cuadrado tiene 10 × 10 = 100 decímetros cuadrados. '
      'Para pasar de dm² a m², divide entre 100.',
  'EST.05': 'Probabilidad = casos buenos entre casos posibles. 3 ámbar de 8 '
      'es 3/8; 5 de 16 es 5/16. Compara las fracciones, no sólo los ámbar.',
  'EST.06': 'La misma probabilidad se escribe de tres maneras: 1/4 = 0,25 = '
      '25 %. Divide los buenos entre el total y multiplica por 100 para el %.',
  'EST.01': 'Lleva la vista de lo alto de la barra al eje de la izquierda: '
      'ahí está el número. Para comparar dos barras, resta.',
  'EST.03': 'La media es repartir a partes iguales: suma todo y divide entre '
      'cuántos hay. 3 + 5 + 7 + 5 = 20, entre 4 = 5.',
  'EST.04': 'Mediana: ordena de menor a mayor y quédate con el del medio (si '
      'son dos, a mitad entre ellos). Moda: el que más se repite.',
  'FUN.01': 'Mira cuánto cambia la salida cuando la entrada sube de uno en '
      'uno: eso es lo que multiplica. Luego ajusta lo que suma o resta, y '
      'comprueba la regla con todas las filas.',
  'ALG.03': 'Junta las dos balanzas: si rojo + azul = 13 y rojo − azul = 5, '
      'sumándolas quedan dos rojos = 18. Un rojo pesa 9.',
  'ARI.04': 'Piensa en plantas: sumar un positivo sube, restar baja. Si '
      'estás en la 2 y bajas 7, pasas el suelo: 2 − 7 = −5.',
  'ARI.05': 'El valor absoluto es la distancia al suelo, sin mirar si es '
      'arriba o abajo: la 7 y la −7 están a 7 plantas. Entre la −4 y la 3 hay '
      '4 + 3 = 7.',
  'PROP.01': 'Dos mezclas dan el mismo color si una es la otra multiplicada: '
      '2 : 3 y 4 : 6 sí (×2); 2 : 3 y 4 : 5 no (se sumó 2).',
  'PROP.02': 'Si la receta es 2 : 3, cada tanda tiene 5 botes. Para 15 botes '
      'hacen falta 15 ÷ 5 = 3 tandas: 6 de azul y 9 de amarillo.',
  'PROP.03': 'Regla de tres: si 2 de azul van con 3 de amarillo, 6 de azul (el '
      'triple) van con 9 de amarillo (el triple).',
  'PROP.06': 'Un descuento del 25 % es quitar la cuarta parte: de 40 €, 10 € '
      'menos, 30 €. Calcula el descuento y réstalo.',
  'PROP.07': 'La escala dice cuánto es cada centímetro del plano: si 1 cm son '
      '5 m, 4 cm son 4 × 5 = 20 m.',
  'MED.04': 'Pon el centro del transportador en el vértice y el 0 sobre un '
      'lado; lee dónde cae el otro. En un espejo, el rayo sale con el mismo '
      'ángulo con el que llega.',
  'GEO.01': 'Agudo: menos de 90°. Recto: 90°, una esquina de papel. Obtuso: '
      'entre 90° y 180°. Llano: 180°, una línea recta.',
  'GEO.07': 'En un reflejo, cada punto queda a la misma distancia del '
      'espejo, pero al otro lado: si está a 2 cuadros, su reflejo también.',
  'MED.01': '1 m = 10 dm = 100 cm. 1,35 m son 1 m y 35 cm: 135 cm.',
  'MED.02': '1 kg = 1000 g y 1 l = 1000 ml. 1,75 kg son 1750 g; medio kilo, '
      '500 g; un cuarto, 250 g.',
  'MED.03': 'Suma primero los minutos; si pasan de 60, son una hora más. '
      '10:40 + 35 min = 10:75 = 11:15. Luego suma las horas.',
  'FR.01': 'El de abajo dice en cuántos trozos iguales se corta el pan; el '
      'de arriba, cuántos coges. 3/4: pan en 4 trozos, coges 3.',
  'FR.02': 'Para escribir lo que hay: arriba los trozos que tienes, abajo en '
      'cuántos está cortado el pan.',
  'FR.12': 'Una impropia tiene más trozos que un pan entero: 11/4 son 8/4 (2 '
      'panes) y 3/4. Divide 11 entre 4: 2 y sobran 3.',
  'FR.13': 'Un mixto se pasa a trozos: 2 y 3/4 son 2 × 4 + 3 = 11 cuartos.',
  'FR.10': 'Simplificar es juntar trozos: 6/8 = 3/4, dividiendo arriba y abajo '
      'entre 2.',
  'FR.11': 'Amplificar es partir los trozos: 3/4 = 6/8, multiplicando arriba y '
      'abajo por 2.',
  'FR.18': 'Fracción por número: multiplica sólo el de arriba. 3 × 2/5 = 6/5.',
  'FR.19': 'Fracción por fracción: arriba por arriba y abajo por abajo. '
      '3/4 × 2/3 = 6/12.',
  'FR.20': 'Repartir entre un número hace los trozos más pequeños: se '
      'multiplica el de abajo. 3/4 entre 3 = 3/12 = 1/4.',
  'FR.21': 'Cuántas veces cabe: 3/2 entre 1/4 es contar cuartos en tres '
      'medios: 6.',
  'DEC.01': 'Entre 1 y 2 hay diez décimas: 1,1; 1,2… 1,9. La primera cifra '
      'tras la coma son las décimas.',
  'DEC.09': 'Para redondear a la décima, mira la centésima: si es 5 o más, '
      'sube; si no, se queda. 2,46 → 2,5; 2,43 → 2,4.',
  'DEC.05': 'Multiplica como si no hubiera coma y luego pon tantas cifras '
      'decimales como tenía: 3 × 1,25 → 3 × 125 = 375 → 3,75.',
  'DEC.06': 'Decimal por decimal: cuenta las cifras decimales de los dos. '
      '0,6 × 2,5 → 6 × 25 = 150 → dos decimales: 1,50.',
  'DEC.07': 'Dividir entre un número: reparte como siempre y pon la coma '
      'cuando llegues a ella. 7,5 entre 3 = 2,5.',
  'DIV.07': 'Escribe los múltiplos de cada número hasta encontrar el primero '
      'que se repite: 4, 8, 12… y 6, 12… El mínimo común múltiplo es 12.',
  'DIV.06': 'Escribe los divisores de cada número y quédate con el mayor que '
      'comparten: 24 y 36 se dividen los dos entre 12.',
  'ALG.02': 'Primero quita bolsas de los dos lados hasta que sólo queden a '
      'la izquierda; luego, como siempre.',
  'GEO.06': 'Volumen de una caja: cuenta los cubitos de una capa (largo × '
      'ancho) y multiplica por las capas (alto). 4 × 3 × 2 = 24. No se suman.',
  'GEO.05': 'Con π ≈ 3,14: la vuelta del círculo es 2 × 3,14 × radio; la '
      'superficie, 3,14 × radio × radio. Radio 3: vuelta 18,84; superficie 28,26.',
  'ARI.03': 'La raíz cuadrada busca el número que, multiplicado por sí mismo, '
      'da el que tienes: √49 = 7 porque 7 × 7 = 49. No es la mitad.',
  'GEO.08': 'En un triángulo rectángulo, el lado largo al cuadrado es la suma '
      'de los otros dos al cuadrado: 6² + 8² = 36 + 64 = 100 = 10². Sumar 6 + 8 '
      'da de más.',
  'DIV.02': 'Un divisor de 36 cabe en 36 un número exacto de veces: 36 ÷ 9 = 4, '
      'así que 9 es divisor. Búscalos por parejas: 1 y 36, 2 y 18, 3 y 12, 4 y 9, '
      '6 y 6. El 24 no: 36 ÷ 24 no es exacto.',
};

/// Un paso de despejar la x en la balanza, con cómo queda después.
class PasoBalanza {
  /// Texto con marcadores {n}, {m} ya resueltos (castellano).
  final String plantilla;
  final int valor;
  final int bolsasIzquierda;
  final int pesasIzquierda;
  final int bolsasDerecha;
  final int pesasDerecha;

  const PasoBalanza({
    required this.plantilla,
    required this.valor,
    required this.bolsasIzquierda,
    required this.pesasIzquierda,
    required this.bolsasDerecha,
    required this.pesasDerecha,
  });

  String get ecuacion {
    String lado(int bolsas, int pesas) {
      final partes = [
        if (bolsas > 0) bolsas == 1 ? 'x' : '${bolsas}x',
        if (pesas > 0 || bolsas == 0) '$pesas',
      ];
      return partes.join(' + ');
    }

    return '${lado(bolsasIzquierda, pesasIzquierda)} = ${lado(bolsasDerecha, pesasDerecha)}';
  }
}

/// Despejar la x "haciendo lo mismo en los dos platillos":
/// 1. quitar bolsas de la derecha (de los dos lados),
/// 2. quitar las pesas sueltas de la izquierda (de los dos lados),
/// 3. repartir lo que queda entre las bolsas.
List<PasoBalanza> pasosDespejar(EcuacionBalanza ecuacion) {
  var bi = ecuacion.bolsasIzquierda;
  var pi = ecuacion.pesasIzquierda;
  var bd = ecuacion.bolsasDerecha;
  var pd = ecuacion.pesasDerecha;
  final pasos = <PasoBalanza>[];
  if (bd > 0) {
    final quitar = bd;
    bi -= quitar;
    bd = 0;
    pasos.add(PasoBalanza(
      plantilla: 'Quita {n} bolsa(s) de cada lado: la balanza sigue igual.',
      valor: quitar,
      bolsasIzquierda: bi,
      pesasIzquierda: pi,
      bolsasDerecha: bd,
      pesasDerecha: pd,
    ));
  }
  if (pi > 0) {
    final quitar = pi;
    pi = 0;
    pd -= quitar;
    pasos.add(PasoBalanza(
      plantilla: 'Quita {n} pesa(s) de cada lado: sigue en equilibrio.',
      valor: quitar,
      bolsasIzquierda: bi,
      pesasIzquierda: pi,
      bolsasDerecha: bd,
      pesasDerecha: pd,
    ));
  }
  if (bi > 1) {
    final x = pd ~/ bi;
    pasos.add(PasoBalanza(
      plantilla: 'Reparte las pesas entre las bolsas: cada bolsa pesa {n}.',
      valor: x,
      bolsasIzquierda: 1,
      pesasIzquierda: 0,
      bolsasDerecha: 0,
      pesasDerecha: x,
    ));
  } else {
    pasos.add(PasoBalanza(
      plantilla: 'Una bolsa sola frente a {n} pesas: x vale {n}.',
      valor: pd,
      bolsasIzquierda: 1,
      pesasIzquierda: 0,
      bolsasDerecha: 0,
      pesasDerecha: pd,
    ));
  }
  return pasos;
}
