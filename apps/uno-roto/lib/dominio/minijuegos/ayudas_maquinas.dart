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
  'DIV.07': 'Escribe los múltiplos de cada número hasta encontrar el primero '
      'que se repite: 4, 8, 12… y 6, 12… El mínimo común múltiplo es 12.',
  'DIV.06': 'Escribe los divisores de cada número y quédate con el mayor que '
      'comparten: 24 y 36 se dividen los dos entre 12.',
  'ALG.02': 'Primero quita bolsas de los dos lados hasta que sólo queden a '
      'la izquierda; luego, como siempre.',
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
