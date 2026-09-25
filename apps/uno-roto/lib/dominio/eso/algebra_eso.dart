import 'dart:math' as math;

import 'problema_eso.dart';

/// Fichas de álgebra de 1.º y 2.º de ESO: lenguaje algebraico, valor
/// numérico, monomios, polinomios e identidades notables.
const List<FichaProblemaEso> fichasAlgebraEso = [
  FichaProblemaEso(
    idHabilidad: 'ALG.04',
    generar: _lenguajeAlgebraico,
    etiquetaTejado: '2x−3',
    tituloAyuda: 'LENGUAJE ALGEBRAICO',
    textoAyuda:
        'Llama x al número y traduce trozo a trozo: «el doble» es 2x, «el cuadrado» es x², '
        '«el siguiente» es x + 1. Fíjate en a qué afecta cada palabra: «el doble del número '
        'menos 3» es 2x − 3, pero «el doble de la diferencia entre el número y 3» es 2(x − 3).',
    transferencia:
        'En la vida: si una entrada cuesta x euros, cuatro entradas y 2 € de gastos son 4x + 2.',
    preguntaTutor: 'traducir frases a expresiones algebraicas y al revés',
    errorTipico:
        'confundir el doble con el cuadrado (2x con x²) o poner paréntesis donde no van: '
        '2(x − 3) en vez de 2x − 3',
    dificultadEstimada: 1.3,
    esquirlas: 4,
  ),
  FichaProblemaEso(
    idHabilidad: 'ALG.05',
    generar: _valorNumerico,
    etiquetaTejado: 'x=−2',
    tituloAyuda: 'VALOR NUMÉRICO',
    textoAyuda:
        'Cambia cada x por el número, siempre entre paréntesis, y respeta el orden: primero '
        'potencias, luego productos y al final sumas y restas. Con x = −2: 3x² − x + 1 = '
        '3·(−2)² − (−2) + 1 = 12 + 2 + 1 = 15. Ojo: (−2)² = 4, no −4.',
    transferencia:
        'En la vida: con la tarifa 4 + 2x, el precio de un viaje de 10 km se calcula poniendo '
        'x = 10: 24 €.',
    preguntaTutor: 'calcular el valor numérico de una expresión algebraica',
    errorTipico:
        'elevar mal los negativos, (−2)² = −4, o sustituir sin paréntesis y perder el signo',
    dificultadEstimada: 1.4,
    esquirlas: 4,
  ),
  FichaProblemaEso(
    idHabilidad: 'ALG.06',
    generar: _monomios,
    etiquetaTejado: '3x²',
    tituloAyuda: 'MONOMIOS',
    textoAyuda:
        'En −5x²y el coeficiente es −5 y el grado es 2 + 1 = 3. Sólo se suman los monomios '
        'semejantes, y el exponente no cambia: 3x² + 5x² = 8x². Al multiplicar se multiplican '
        'los coeficientes y se suman los exponentes: 2x³ · 4x² = 8x⁵; al dividir, se dividen '
        'los coeficientes y se restan los exponentes.',
    transferencia:
        'En la vida: 3 cajas de x² baldosas más 5 cajas iguales son 8x² baldosas, no 8x⁴.',
    preguntaTutor:
        'reconocer grado y coeficiente, y sumar, multiplicar y dividir monomios',
    errorTipico:
        'sumar los exponentes al sumar monomios semejantes (3x² + 5x² = 8x⁴) o juntar '
        'monomios que no son semejantes',
    dificultadEstimada: 1.6,
    esquirlas: 5,
  ),
  FichaProblemaEso(
    idHabilidad: 'ALG.07',
    generar: _polinomios,
    etiquetaTejado: 'P(x)',
    tituloAyuda: 'POLINOMIOS',
    textoAyuda:
        'Para sumar o restar, junta los términos del mismo grado. Un menos delante del '
        'paréntesis cambia el signo de todos sus términos: (x² + 3x) − (x² − 2x) = 5x. Para '
        'multiplicar, multiplica cada término por cada término y junta los semejantes. Sacar '
        'factor común es el camino de vuelta: 6x² − 9x = 3x(2x − 3).',
    transferencia:
        'En la vida: un huerto de x metros de ancho y x + 3 de largo mide x(x + 3) = x² + 3x '
        'metros cuadrados.',
    preguntaTutor:
        'sumar, restar y multiplicar polinomios y sacar factor común',
    errorTipico:
        'cambiar sólo el signo del primer término al restar un paréntesis, o multiplicar sólo '
        'el primer término',
    dificultadEstimada: 1.8,
    esquirlas: 5,
  ),
  FichaProblemaEso(
    idHabilidad: 'ALG.08',
    generar: _identidadesNotables,
    etiquetaTejado: '(a+b)²',
    tituloAyuda: 'IDENTIDADES NOTABLES',
    textoAyuda:
        '(a + b)² = a² + 2ab + b²; (a − b)² = a² − 2ab + b²; (a + b)(a − b) = a² − b². El '
        'doble producto no se puede olvidar: (x + 3)² = x² + 6x + 9, no x² + 9. Leídas al '
        'revés sirven para escribir como producto: x² − 25 = (x + 5)(x − 5).',
    transferencia:
        'En la vida: 31 · 29 = (30 + 1)(30 − 1) = 900 − 1 = 899, sin calculadora.',
    preguntaTutor:
        'desarrollar identidades notables y reconocerlas en los dos sentidos',
    errorTipico: 'olvidar el doble producto: (x + 3)² = x² + 9',
    dificultadEstimada: 1.9,
    esquirlas: 5,
  ),
];

/// Traducciones de los textos de estas fichas: castellano → [euskera,
/// catalán]. Borrador pendiente de revisión nativa.
const Map<String, List<String>> traduccionesAlgebraEso = {
  // ALG.04 — ayuda.
  'LENGUAJE ALGEBRAICO': ['HIZKUNTZA ALJEBRAIKOA', 'LLENGUATGE ALGEBRAIC'],
  'Llama x al número y traduce trozo a trozo: «el doble» es 2x, «el cuadrado» es x², «el siguiente» es x + 1. Fíjate en a qué afecta cada palabra: «el doble del número menos 3» es 2x − 3, pero «el doble de la diferencia entre el número y 3» es 2(x − 3).':
      [
    'Deitu x zenbakiari eta itzuli zatiz zati: «bikoitza» 2x da, «karratua» x², «hurrengoa» x + 1. Begiratu hitz bakoitzak zeri eragiten dion: «zenbakiaren bikoitza ken 3» 2x − 3 da, baina «zenbakiaren eta 3ren arteko kenduraren bikoitza» 2(x − 3) da.',
    'Anomena x el nombre i tradueix tros a tros: «el doble» és 2x, «el quadrat» és x², «el següent» és x + 1. Fixa\'t a què afecta cada paraula: «el doble del nombre menys 3» és 2x − 3, però «el doble de la diferència entre el nombre i 3» és 2(x − 3).',
  ],
  'En la vida: si una entrada cuesta x euros, cuatro entradas y 2 € de gastos son 4x + 2.':
      [
    'Bizitzan: sarrera batek x euro balio badu, lau sarrera eta 2 € gastu 4x + 2 dira.',
    'A la vida: si una entrada costa x euros, quatre entrades i 2 € de despeses són 4x + 2.',
  ],
  // ALG.04 — de la frase a la expresión.
  'Llamamos x a un número. ¿Cómo se escribe «el doble del número menos {a}»?': [
    'Zenbaki bati x deitzen diogu. Nola idazten da «zenbakiaren bikoitza ken {a}»?',
    'Anomenem x un nombre. Com s\'escriu «el doble del nombre menys {a}»?',
  ],
  'Llamamos x a un número. ¿Cómo se escribe «el triple de la suma del número y {a}»?':
      [
    'Zenbaki bati x deitzen diogu. Nola idazten da «zenbakiaren eta {a} zenbakiaren baturaren hirukoitza»?',
    'Anomenem x un nombre. Com s\'escriu «el triple de la suma del nombre i {a}»?',
  ],
  'Llamamos x a un número. ¿Cómo se escribe «la suma del cuadrado del número y {a}»?':
      [
    'Zenbaki bati x deitzen diogu. Nola idazten da «zenbakiaren karratuaren eta {a} zenbakiaren batura»?',
    'Anomenem x un nombre. Com s\'escriu «la suma del quadrat del nombre i {a}»?',
  ],
  'Llamamos x a un número. ¿Cómo se escribe «el doble de la diferencia entre el número y {a}»?':
      [
    'Zenbaki bati x deitzen diogu. Nola idazten da «zenbakiaren eta {a} zenbakiaren arteko kenduraren bikoitza»?',
    'Anomenem x un nombre. Com s\'escriu «el doble de la diferència entre el nombre i {a}»?',
  ],
  'Llamamos x a un número. ¿Cómo se escribe «{a} menos el triple del número»?':
      [
    'Zenbaki bati x deitzen diogu. Nola idazten da «{a} ken zenbakiaren hirukoitza»?',
    'Anomenem x un nombre. Com s\'escriu «{a} menys el triple del nombre»?',
  ],
  'Llamamos x a un número. ¿Cómo se escribe «el cuadrado de la suma del número y {a}»?':
      [
    'Zenbaki bati x deitzen diogu. Nola idazten da «zenbakiaren eta {a} zenbakiaren baturaren karratua»?',
    'Anomenem x un nombre. Com s\'escriu «el quadrat de la suma del nombre i {a}»?',
  ],
  'Llamamos x a un número. ¿Cómo se escribe «la tercera parte de la suma del número y {a}»?':
      [
    'Zenbaki bati x deitzen diogu. Nola idazten da «zenbakiaren eta {a} zenbakiaren baturaren herena»?',
    'Anomenem x un nombre. Com s\'escriu «la tercera part de la suma del nombre i {a}»?',
  ],
  'Llamamos x a un número. ¿Cómo se escribe «la suma del número y su siguiente»?':
      [
    'Zenbaki bati x deitzen diogu. Nola idazten da «zenbakiaren eta haren hurrengoaren batura»?',
    'Anomenem x un nombre. Com s\'escriu «la suma del nombre i el seu següent»?',
  ],
  // ALG.04 — de la expresión a la frase.
  '¿Qué frase corresponde a la expresión {e}?': [
    'Zein esaldi dagokio {e} adierazpenari?',
    'Quina frase correspon a l\'expressió {e}?',
  ],
  'El doble de un número menos 3': [
    'Zenbaki baten bikoitza ken 3',
    'El doble d\'un nombre menys 3',
  ],
  'El doble de la diferencia entre un número y 3': [
    'Zenbaki baten eta 3ren arteko kenduraren bikoitza',
    'El doble de la diferència entre un nombre i 3',
  ],
  'El cuadrado de un número menos 3': [
    'Zenbaki baten karratua ken 3',
    'El quadrat d\'un nombre menys 3',
  ],
  'Un número menos el doble de 3': [
    'Zenbaki bat ken 3ren bikoitza',
    'Un nombre menys el doble de 3',
  ],
  'El triple de la suma de un número y 5': [
    'Zenbaki baten eta 5en baturaren hirukoitza',
    'El triple de la suma d\'un nombre i 5',
  ],
  'El triple de un número más 5': [
    'Zenbaki baten hirukoitza gehi 5',
    'El triple d\'un nombre més 5',
  ],
  'Un número más el triple de 5': [
    'Zenbaki bat gehi 5en hirukoitza',
    'Un nombre més el triple de 5',
  ],
  'El cubo de la suma de un número y 5': [
    'Zenbaki baten eta 5en baturaren kuboa',
    'El cub de la suma d\'un nombre i 5',
  ],
  'La suma del cuadrado de un número y 1': [
    'Zenbaki baten karratuaren eta 1en batura',
    'La suma del quadrat d\'un nombre i 1',
  ],
  'El cuadrado de la suma de un número y 1': [
    'Zenbaki baten eta 1en baturaren karratua',
    'El quadrat de la suma d\'un nombre i 1',
  ],
  'El doble de un número más 1': [
    'Zenbaki baten bikoitza gehi 1',
    'El doble d\'un nombre més 1',
  ],
  'La suma de un número y su siguiente': [
    'Zenbaki baten eta haren hurrengoaren batura',
    'La suma d\'un nombre i el seu següent',
  ],
  'La mitad de la suma de un número y 4': [
    'Zenbaki baten eta 4ren baturaren erdia',
    'La meitat de la suma d\'un nombre i 4',
  ],
  'La mitad de un número más 4': [
    'Zenbaki baten erdia gehi 4',
    'La meitat d\'un nombre més 4',
  ],
  'El doble de la suma de un número y 4': [
    'Zenbaki baten eta 4ren baturaren bikoitza',
    'El doble de la suma d\'un nombre i 4',
  ],
  'Un número más la mitad de 4': [
    'Zenbaki bat gehi 4ren erdia',
    'Un nombre més la meitat de 4',
  ],
  // ALG.05.
  'VALOR NUMÉRICO': ['ZENBAKIZKO BALIOA', 'VALOR NUMÈRIC'],
  'Cambia cada x por el número, siempre entre paréntesis, y respeta el orden: primero potencias, luego productos y al final sumas y restas. Con x = −2: 3x² − x + 1 = 3·(−2)² − (−2) + 1 = 12 + 2 + 1 = 15. Ojo: (−2)² = 4, no −4.':
      [
    'Aldatu x bakoitza zenbakiagatik, beti parentesi artean, eta errespetatu ordena: lehenik berreturak, gero biderketak eta azkenik batuketak eta kenketak. x = −2 denean: 3x² − x + 1 = 3·(−2)² − (−2) + 1 = 12 + 2 + 1 = 15. Kontuz: (−2)² = 4 da, ez −4.',
    'Canvia cada x pel nombre, sempre entre parèntesis, i respecta l\'ordre: primer potències, després productes i al final sumes i restes. Amb x = −2: 3x² − x + 1 = 3·(−2)² − (−2) + 1 = 12 + 2 + 1 = 15. Compte: (−2)² = 4, no −4.',
  ],
  'En la vida: con la tarifa 4 + 2x, el precio de un viaje de 10 km se calcula poniendo x = 10: 24 €.':
      [
    'Bizitzan: 4 + 2x tarifarekin, 10 km-ko bidaia baten prezioa x = 10 jarrita kalkulatzen da: 24 €.',
    'A la vida: amb la tarifa 4 + 2x, el preu d\'un viatge de 10 km es calcula posant x = 10: 24 €.',
  ],
  '¿Cuánto vale {e} si x = {v}?': [
    'Zenbat balio du {e} adierazpenak, x = {v} denean?',
    'Quant val {e} si x = {v}?',
  ],
  '¿Cuánto vale {e} si a = {v} y b = {w}?': [
    'Zenbat balio du {e} adierazpenak, a = {v} eta b = {w} direnean?',
    'Quant val {e} si a = {v} i b = {w}?',
  ],
  'Un taxi del Puerto cobra {e} euros por un viaje de x kilómetros. ¿Cuánto cuesta un viaje de {k} km?':
      [
    'Portuko taxi batek {e} euro kobratzen ditu x kilometroko bidaia batengatik. Zenbat balio du {k} km-ko bidaia batek?',
    'Un taxi del Port cobra {e} euros per un viatge de x quilòmetres. Quant costa un viatge de {k} km?',
  ],
  // ALG.06.
  'MONOMIOS': ['MONOMIOAK', 'MONOMIS'],
  'En −5x²y el coeficiente es −5 y el grado es 2 + 1 = 3. Sólo se suman los monomios semejantes, y el exponente no cambia: 3x² + 5x² = 8x². Al multiplicar se multiplican los coeficientes y se suman los exponentes: 2x³ · 4x² = 8x⁵; al dividir, se dividen los coeficientes y se restan los exponentes.':
      [
    '−5x²y monomioan koefizientea −5 da eta maila 2 + 1 = 3. Monomio antzekoak bakarrik batzen dira, eta berretzailea ez da aldatzen: 3x² + 5x² = 8x². Biderkatzean koefizienteak biderkatzen dira eta berretzaileak batu: 2x³ · 4x² = 8x⁵; zatitzean, koefizienteak zatitzen dira eta berretzaileak kendu.',
    'En −5x²y el coeficient és −5 i el grau és 2 + 1 = 3. Només se sumen els monomis semblants, i l\'exponent no canvia: 3x² + 5x² = 8x². En multiplicar es multipliquen els coeficients i se sumen els exponents: 2x³ · 4x² = 8x⁵; en dividir, es divideixen els coeficients i es resten els exponents.',
  ],
  'En la vida: 3 cajas de x² baldosas más 5 cajas iguales son 8x² baldosas, no 8x⁴.':
      [
    'Bizitzan: x² baldosako 3 kutxa gehi beste 5 kutxa berdin 8x² baldosa dira, ez 8x⁴.',
    'A la vida: 3 caixes de x² rajoles més 5 caixes iguals són 8x² rajoles, no 8x⁴.',
  ],
  '¿Cuál es el grado de {m}?': [
    'Zein da {m} monomioaren maila?',
    'Quin és el grau de {m}?',
  ],
  '¿Cuál es el coeficiente de {m}?': [
    'Zein da {m} monomioaren koefizientea?',
    'Quin és el coeficient de {m}?',
  ],
  'Simplifica: {e}': ['Sinplifikatu: {e}', 'Simplifica: {e}'],
  // ALG.07.
  'POLINOMIOS': ['POLINOMIOAK', 'POLINOMIS'],
  'Para sumar o restar, junta los términos del mismo grado. Un menos delante del paréntesis cambia el signo de todos sus términos: (x² + 3x) − (x² − 2x) = 5x. Para multiplicar, multiplica cada término por cada término y junta los semejantes. Sacar factor común es el camino de vuelta: 6x² − 9x = 3x(2x − 3).':
      [
    'Batzeko edo kentzeko, bildu maila bereko gaiak. Parentesiaren aurreko ken batek bere gai guztien zeinua aldatzen du: (x² + 3x) − (x² − 2x) = 5x. Biderkatzeko, biderkatu gai bakoitza gai bakoitzarekin eta bildu antzekoak. Faktore komuna ateratzea itzulerako bidea da: 6x² − 9x = 3x(2x − 3).',
    'Per sumar o restar, ajunta els termes del mateix grau. Un menys davant del parèntesi canvia el signe de tots els seus termes: (x² + 3x) − (x² − 2x) = 5x. Per multiplicar, multiplica cada terme per cada terme i ajunta els semblants. Treure factor comú és el camí de tornada: 6x² − 9x = 3x(2x − 3).',
  ],
  'En la vida: un huerto de x metros de ancho y x + 3 de largo mide x(x + 3) = x² + 3x metros cuadrados.':
      [
    'Bizitzan: x metro zabal eta x + 3 luze den baratze batek x(x + 3) = x² + 3x metro koadro ditu.',
    'A la vida: un hort de x metres d\'amplada i x + 3 de llargada fa x(x + 3) = x² + 3x metres quadrats.',
  ],
  'Desarrolla: {e}': ['Garatu: {e}', 'Desenvolupa: {e}'],
  'Saca factor común: {e}': [
    'Atera faktore komuna: {e}',
    'Treu factor comú: {e}',
  ],
  // ALG.08.
  'IDENTIDADES NOTABLES': ['IDENTITATE NABARMENAK', 'IDENTITATS NOTABLES'],
  '(a + b)² = a² + 2ab + b²; (a − b)² = a² − 2ab + b²; (a + b)(a − b) = a² − b². El doble producto no se puede olvidar: (x + 3)² = x² + 6x + 9, no x² + 9. Leídas al revés sirven para escribir como producto: x² − 25 = (x + 5)(x − 5).':
      [
    '(a + b)² = a² + 2ab + b²; (a − b)² = a² − 2ab + b²; (a + b)(a − b) = a² − b². Biderkadura bikoitza ezin da ahaztu: (x + 3)² = x² + 6x + 9, ez x² + 9. Alderantziz irakurrita, biderkadura gisa idazteko balio dute: x² − 25 = (x + 5)(x − 5).',
    '(a + b)² = a² + 2ab + b²; (a − b)² = a² − 2ab + b²; (a + b)(a − b) = a² − b². El doble producte no es pot oblidar: (x + 3)² = x² + 6x + 9, no x² + 9. Llegides a l\'inrevés serveixen per escriure com a producte: x² − 25 = (x + 5)(x − 5).',
  ],
  'En la vida: 31 · 29 = (30 + 1)(30 − 1) = 900 − 1 = 899, sin calculadora.': [
    'Bizitzan: 31 · 29 = (30 + 1)(30 − 1) = 900 − 1 = 899, kalkulagailurik gabe.',
    'A la vida: 31 · 29 = (30 + 1)(30 − 1) = 900 − 1 = 899, sense calculadora.',
  ],
  'Escribe como producto: {e}': [
    'Idatzi biderkadura gisa: {e}',
    'Escriu com a producte: {e}',
  ],
  'Calcula de cabeza con una identidad notable: {e}': [
    'Kalkulatu buruz, identitate nabarmen bat erabiliz: {e}',
    'Calcula mentalment amb una identitat notable: {e}',
  ],
};

int _entre(math.Random azar, int minimo, int maximo) =>
    minimo + azar.nextInt(maximo - minimo + 1);

/// Un entero entre −[maximo] y [maximo] que no es cero.
int _noNulo(math.Random azar, int maximo) =>
    _entre(azar, 1, maximo) * (azar.nextBool() ? 1 : -1);

/// Un entero entre [minimo] y [maximo] con signo al azar.
int _conSignoAlAzar(math.Random azar, int minimo, int maximo) =>
    _entre(azar, minimo, maximo) * (azar.nextBool() ? 1 : -1);

/// Arma el problema con la buena, los errores típicos y el relleno.
ProblemaEso _problema(
  math.Random azar,
  String idHabilidad,
  String enunciado,
  Map<String, String> datos,
  String buena,
  List<String> errores,
  String Function(int n) relleno,
) {
  final elegidas = opcionesConErrores(azar, buena, errores, relleno: relleno);
  return ProblemaEso(
    idHabilidad: idHabilidad,
    enunciado: enunciado,
    datos: datos,
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
  );
}

// ---------------------------------------------------------------------
// Escritura de expresiones: términos con x e y (o a y b), superíndices
// Unicode y el signo menos tipográfico.
// ---------------------------------------------------------------------

typedef _Termino = ({int coeficiente, int gradoX, int gradoY});

_Termino _termino(int coeficiente, [int gradoX = 0, int gradoY = 0]) =>
    (coeficiente: coeficiente, gradoX: gradoX, gradoY: gradoY);

/// Un exponente en superíndice (², ³, ¹⁰).
String _superindice(int exponente) {
  const cifras = '⁰¹²³⁴⁵⁶⁷⁸⁹';
  final texto = exponente
      .abs()
      .toString()
      .split('')
      .map((cifra) => cifras[int.parse(cifra)])
      .join();
  return exponente < 0 ? '⁻$texto' : texto;
}

String _cuerpoTermino(
    int valorAbsoluto, int gradoX, int gradoY, String letraX, String letraY) {
  String letra(String nombre, int grado) => grado == 0
      ? ''
      : grado == 1
          ? nombre
          : '$nombre${_superindice(grado)}';
  final letras = letra(letraX, gradoX) + letra(letraY, gradoY);
  if (letras.isEmpty) return '$valorAbsoluto';
  return valorAbsoluto == 1 ? letras : '$valorAbsoluto$letras';
}

/// Escribe un polinomio. Con [reducir] junta los semejantes, quita los
/// ceros y ordena de mayor a menor grado; sin él, lo deja como viene
/// (para enunciados sin simplificar).
String _polinomio(List<_Termino> terminos,
    {String letraX = 'x', String letraY = 'y', bool reducir = true}) {
  var lista = terminos;
  if (reducir) {
    final acumulados = <(int, int), int>{};
    for (final termino in terminos) {
      final clave = (termino.gradoX, termino.gradoY);
      acumulados[clave] = (acumulados[clave] ?? 0) + termino.coeficiente;
    }
    lista = [
      for (final entrada in acumulados.entries)
        if (entrada.value != 0)
          _termino(entrada.value, entrada.key.$1, entrada.key.$2)
    ]..sort((primero, segundo) {
        final porGrado = (segundo.gradoX + segundo.gradoY) -
            (primero.gradoX + primero.gradoY);
        return porGrado != 0 ? porGrado : segundo.gradoX - primero.gradoX;
      });
  }
  if (lista.isEmpty) return '0';
  final texto = StringBuffer();
  for (var posicion = 0; posicion < lista.length; posicion++) {
    final termino = lista[posicion];
    final cuerpo = _cuerpoTermino(termino.coeficiente.abs(), termino.gradoX,
        termino.gradoY, letraX, letraY);
    final negativo = termino.coeficiente < 0;
    if (posicion == 0) {
      texto.write(negativo ? '−$cuerpo' : cuerpo);
    } else {
      texto.write(negativo ? ' − $cuerpo' : ' + $cuerpo');
    }
  }
  return texto.toString();
}

String _monomio(int coeficiente, [int gradoX = 0, int gradoY = 0]) =>
    _polinomio([_termino(coeficiente, gradoX, gradoY)]);

List<_Termino> _multiplicar(List<_Termino> primero, List<_Termino> segundo) => [
      for (final factorA in primero)
        for (final factorB in segundo)
          _termino(factorA.coeficiente * factorB.coeficiente,
              factorA.gradoX + factorB.gradoX, factorA.gradoY + factorB.gradoY),
    ];

List<_Termino> _cambiarSigno(List<_Termino> terminos) => [
      for (final termino in terminos)
        _termino(-termino.coeficiente, termino.gradoX, termino.gradoY)
    ];

int _mcd(int a, int b) => b == 0 ? a.abs() : _mcd(b, a % b);

// ---------------------------------------------------------------------
// ALG.04 — Lenguaje algebraico.
// ---------------------------------------------------------------------

/// Expresiones para el sentido inverso (de la expresión a la frase):
/// la frase buena primero y luego las de los errores típicos.
const List<(String, List<String>)> _frasesDeExpresiones = [
  (
    '2x − 3',
    [
      'El doble de un número menos 3',
      'El doble de la diferencia entre un número y 3',
      'El cuadrado de un número menos 3',
      'Un número menos el doble de 3',
    ]
  ),
  (
    '3(x + 5)',
    [
      'El triple de la suma de un número y 5',
      'El triple de un número más 5',
      'Un número más el triple de 5',
      'El cubo de la suma de un número y 5',
    ]
  ),
  (
    'x² + 1',
    [
      'La suma del cuadrado de un número y 1',
      'El cuadrado de la suma de un número y 1',
      'El doble de un número más 1',
      'La suma de un número y su siguiente',
    ]
  ),
  (
    '(x + 4)/2',
    [
      'La mitad de la suma de un número y 4',
      'La mitad de un número más 4',
      'El doble de la suma de un número y 4',
      'Un número más la mitad de 4',
    ]
  ),
];

ProblemaEso _lenguajeAlgebraico(math.Random azar, int dificultad) {
  // Fácil: doble, triple de la suma, suma del cuadrado. Medio: además
  // la diferencia entre paréntesis, el sentido inverso y «a menos el
  // triple». Difícil: cuadrado de la suma, tercera parte y consecutivos.
  final modelosDisponibles = dificultad <= 2 ? 3 : (dificultad <= 5 ? 6 : 9);
  final modelo = azar.nextInt(modelosDisponibles);
  final numero = _entre(azar, 2, 9);

  if (modelo == 4) {
    final (expresion, frases) =
        _frasesDeExpresiones[azar.nextInt(_frasesDeExpresiones.length)];
    return _problema(
      azar,
      'ALG.04',
      '¿Qué frase corresponde a la expresión {e}?',
      {'e': expresion},
      frases.first,
      frases.skip(1).toList(),
      (n) => frases.first,
    );
  }

  const prefijo = 'Llamamos x a un número. ¿Cómo se escribe ';
  final (String frase, String buena, List<String> errores) = switch (modelo) {
    0 => (
        '«el doble del número menos {a}»?',
        '2x − $numero',
        // Paréntesis de más, doble por cuadrado, orden al revés.
        ['2(x − $numero)', 'x² − $numero', '$numero − 2x'],
      ),
    1 => (
        '«el triple de la suma del número y {a}»?',
        '3(x + $numero)',
        ['3x + $numero', 'x + ${3 * numero}', '(x + $numero)³'],
      ),
    2 => (
        '«la suma del cuadrado del número y {a}»?',
        'x² + $numero',
        ['(x + $numero)²', '2x + $numero', 'x² + ${numero * numero}'],
      ),
    3 => (
        '«el doble de la diferencia entre el número y {a}»?',
        '2(x − $numero)',
        ['2x − $numero', '(x − $numero)²', 'x − ${2 * numero}'],
      ),
    5 => (
        '«{a} menos el triple del número»?',
        '$numero − 3x',
        ['3x − $numero', '3($numero − x)', '$numero − x³'],
      ),
    6 => (
        '«el cuadrado de la suma del número y {a}»?',
        '(x + $numero)²',
        ['x² + $numero', 'x² + ${numero * numero}', '2(x + $numero)'],
      ),
    7 => (
        '«la tercera parte de la suma del número y {a}»?',
        '(x + $numero)/3',
        ['x/3 + $numero', '3(x + $numero)', 'x + $numero/3'],
      ),
    _ => (
        '«la suma del número y su siguiente»?',
        '2x + 1',
        ['x + 1', 'x² + 1', '2x'],
      ),
  };
  return _problema(
    azar,
    'ALG.04',
    '$prefijo$frase',
    frase.contains('{a}') ? {'a': '$numero'} : const <String, String>{},
    buena,
    errores,
    (n) => '${n + 3}x + $numero',
  );
}

// ---------------------------------------------------------------------
// ALG.05 — Valor numérico.
// ---------------------------------------------------------------------

ProblemaEso _valorNumerico(math.Random azar, int dificultad) {
  // Fácil: tarifa lineal o expresión lineal con x negativo. Medio:
  // lineal o cuadrática con x negativo. Difícil: cuadrática con
  // coeficiente negativo o expresión con dos letras.
  final modelos = dificultad <= 2
      ? const [0, 1]
      : dificultad <= 5
          ? const [1, 2, 2]
          : const [2, 3];
  final modelo = modelos[azar.nextInt(modelos.length)];

  String relleno(int resultado, int n) =>
      conSigno(resultado + (n.isOdd ? n + 1 : -n - 1));

  switch (modelo) {
    case 0:
      // Tarifa: bajada de bandera + precio por kilómetro.
      final bajada = _entre(azar, 2, 5);
      final precioKilometro = _entre(azar, 1, 3);
      final kilometros = _entre(azar, 3, 12);
      final total = bajada + precioKilometro * kilometros;
      return _problema(
        azar,
        'ALG.05',
        'Un taxi del Puerto cobra {e} euros por un viaje de x kilómetros. '
            '¿Cuánto cuesta un viaje de {k} km?',
        {
          'e': _polinomio([_termino(bajada), _termino(precioKilometro, 1)],
              reducir: false),
          'k': '$kilometros',
        },
        '$total €',
        [
          // Suma antes de multiplicar.
          '${(bajada + precioKilometro) * kilometros} €',
          // Multiplica el término que no lleva x.
          '${bajada * kilometros + precioKilometro} €',
          // Lee 2x como 2 + x.
          '${bajada + precioKilometro + kilometros} €',
        ],
        (n) => '${total + n * 2} €',
      );
    case 1:
      final coeficiente = _conSignoAlAzar(azar, 2, 6);
      final independiente = _noNulo(azar, 9);
      final valorX = -_entre(azar, 1, dificultad <= 2 ? 4 : 6);
      final resultado = coeficiente * valorX + independiente;
      return _problema(
        azar,
        'ALG.05',
        '¿Cuánto vale {e} si x = {v}?',
        {
          'e': _polinomio([_termino(coeficiente, 1), _termino(independiente)]),
          'v': conSigno(valorX),
        },
        conSigno(resultado),
        [
          // Pierde el signo de x.
          conSigno(-coeficiente * valorX + independiente),
          // Lee 3x como 3 + x.
          conSigno(coeficiente + valorX + independiente),
          conSigno(coeficiente * valorX - independiente),
        ],
        (n) => relleno(resultado, n),
      );
    case 2:
      final cuadratico = dificultad >= 6
          ? _noNulo(azar, 3)
          : _entre(azar, 1, dificultad <= 4 ? 2 : 3);
      final lineal = _noNulo(azar, 5);
      final independiente = _noNulo(azar, 9);
      final valorX = -_entre(azar, 1, dificultad >= 6 ? 4 : 3);
      int valor(int cuadrado, int x) =>
          cuadratico * cuadrado + lineal * x + independiente;
      final resultado = valor(valorX * valorX, valorX);
      return _problema(
        azar,
        'ALG.05',
        '¿Cuánto vale {e} si x = {v}?',
        {
          'e': _polinomio([
            _termino(cuadratico, 2),
            _termino(lineal, 1),
            _termino(independiente),
          ]),
          'v': conSigno(valorX),
        },
        conSigno(resultado),
        [
          // (−2)² = −4.
          conSigno(valor(-valorX * valorX, valorX)),
          // Pierde el signo en el término de x.
          conSigno(valor(valorX * valorX, -valorX)),
          // Eleva también el coeficiente: (3·(−2))².
          conSigno(cuadratico * cuadratico * valorX * valorX +
              lineal * valorX +
              independiente),
        ],
        (n) => relleno(resultado, n),
      );
    default:
      // Dos letras: c₁a² + c₂ab + c₃b.
      final coefCuadrado = _entre(azar, 1, 3);
      final coefProducto = _noNulo(azar, 4);
      final coefB = _noNulo(azar, 5);
      final valorA = -_entre(azar, 1, 3);
      final valorB = _conSignoAlAzar(azar, 1, 4);
      int valor(int a, int b, int cuadradoA) =>
          coefCuadrado * cuadradoA + coefProducto * a * b + coefB * b;
      final resultado = valor(valorA, valorB, valorA * valorA);
      return _problema(
        azar,
        'ALG.05',
        '¿Cuánto vale {e} si a = {v} y b = {w}?',
        {
          'e': _polinomio([
            _termino(coefCuadrado, 2),
            _termino(coefProducto, 1, 1),
            _termino(coefB, 0, 1),
          ], letraX: 'a', letraY: 'b'),
          'v': conSigno(valorA),
          'w': conSigno(valorB),
        },
        conSigno(resultado),
        [
          // (−2)² = −4.
          conSigno(valor(valorA, valorB, -valorA * valorA)),
          // Pierde el signo de a en el producto.
          conSigno(valor(-valorA, valorB, valorA * valorA)),
          // Cambia una letra por la otra.
          conSigno(valor(valorB, valorA, valorB * valorB)),
        ],
        (n) => relleno(resultado, n),
      );
  }
}

// ---------------------------------------------------------------------
// ALG.06 — Monomios.
// ---------------------------------------------------------------------

ProblemaEso _monomios(math.Random azar, int dificultad) {
  // Fácil: grado, coeficiente, suma de semejantes. Medio: además
  // producto y suma de no semejantes; grado y coeficiente con dos
  // letras. Difícil: además la división, y productos con dos letras.
  final modelosDisponibles = dificultad <= 2 ? 3 : (dificultad <= 5 ? 5 : 6);
  final dosLetras = dificultad >= 3;
  switch (azar.nextInt(modelosDisponibles)) {
    case 0:
      final coeficiente = _conSignoAlAzar(azar, 2, 9);
      final gradoX = _entre(azar, 1, 5);
      final gradoY = dosLetras ? _entre(azar, 1, 4) : 0;
      final grado = gradoX + gradoY;
      return _problema(
        azar,
        'ALG.06',
        '¿Cuál es el grado de {m}?',
        {'m': _monomio(coeficiente, gradoX, gradoY)},
        '$grado',
        [
          // Multiplica los exponentes.
          if (gradoY > 0) '${gradoX * gradoY}',
          // Se queda con el exponente mayor.
          if (gradoY > 0) '${math.max(gradoX, gradoY)}',
          // Confunde grado con coeficiente.
          '${coeficiente.abs()}',
          '${grado + 1}',
        ],
        (n) => '${grado + 1 + n}',
      );
    case 1:
      final coeficiente = dosLetras && azar.nextInt(3) == 0
          ? (azar.nextBool() ? -1 : 1)
          : _conSignoAlAzar(azar, 2, 9);
      final gradoX = _entre(azar, 2, 5);
      final gradoY = dosLetras ? _entre(azar, 1, 3) : 0;
      return _problema(
        azar,
        'ALG.06',
        '¿Cuál es el coeficiente de {m}?',
        {'m': _monomio(coeficiente, gradoX, gradoY)},
        conSigno(coeficiente),
        [
          // Olvida el signo.
          conSigno(-coeficiente),
          // Toma el exponente o el grado por coeficiente.
          '$gradoX',
          '${gradoX + gradoY}',
          // Con −x² cree que no hay coeficiente.
          if (coeficiente.abs() == 1) '0',
        ],
        (n) => conSigno(coeficiente + (coeficiente > 0 ? n + 1 : -n - 1)),
      );
    case 2:
      // Suma de semejantes: dos términos (o tres a partir de medio).
      final exponente = _entre(azar, 1, 4);
      final numeroTerminos = dificultad >= 3 && azar.nextBool() ? 3 : 2;
      late List<int> coeficientes;
      do {
        coeficientes = [
          _entre(azar, 2, 9),
          for (var i = 1; i < numeroTerminos; i++)
            dificultad == 0 ? _entre(azar, 2, 9) : _noNulo(azar, 9),
        ];
      } while (coeficientes.reduce((a, b) => a + b) == 0);
      final suma = coeficientes.reduce((a, b) => a + b);
      final sumaSinSignos =
          coeficientes.fold<int>(0, (total, coef) => total + coef.abs());
      return _problema(
        azar,
        'ALG.06',
        'Simplifica: {e}',
        {
          'e': _polinomio(
              [for (final coef in coeficientes) _termino(coef, exponente)],
              reducir: false),
        },
        _monomio(suma, exponente),
        [
          // Suma también los exponentes: 3x² + 5x² = 8x⁴.
          _monomio(suma, exponente * numeroTerminos),
          if (numeroTerminos == 2) ...[
            // Multiplica los coeficientes.
            _monomio(coeficientes[0] * coeficientes[1], exponente),
            _monomio(coeficientes[0] * coeficientes[1], exponente * 2),
          ] else ...[
            // Pasa por alto los signos menos.
            _monomio(sumaSinSignos, exponente),
            _monomio(sumaSinSignos, exponente * numeroTerminos),
          ],
        ],
        (n) => _monomio(suma + n, exponente),
      );
    case 3:
      // Producto de monomios.
      final coefA = _conSignoAlAzar(azar, 2, 6);
      final coefB = _conSignoAlAzar(azar, 2, 6);
      final gradoXA = _entre(azar, 1, 4);
      final gradoXB = _entre(azar, 1, 4);
      final gradoYA = dificultad >= 6 ? _entre(azar, 0, 3) : 0;
      final gradoYB = dificultad >= 6 ? _entre(azar, 1, 3) : 0;
      final producto = coefA * coefB;
      return _problema(
        azar,
        'ALG.06',
        '¿Cuánto es {e}?',
        {
          'e': '(${_monomio(coefA, gradoXA, gradoYA)}) · '
              '(${_monomio(coefB, gradoXB, gradoYB)})',
        },
        _monomio(producto, gradoXA + gradoXB, gradoYA + gradoYB),
        [
          // Multiplica los exponentes.
          _monomio(producto, gradoXA * gradoXB, gradoYA * gradoYB),
          // Suma los coeficientes.
          if (coefA + coefB != 0)
            _monomio(coefA + coefB, gradoXA + gradoXB, gradoYA + gradoYB),
          // Se equivoca con el signo.
          _monomio(-producto, gradoXA + gradoXB, gradoYA + gradoYB),
        ],
        (n) => _monomio(producto, gradoXA + gradoXB + n, gradoYA + gradoYB),
      );
    case 4:
      // Suma de monomios que no son semejantes: no se puede juntar.
      final exponenteMayor = _entre(azar, 2, 4);
      final exponenteMenor = _entre(azar, 1, exponenteMayor - 1);
      final coefMayor = _entre(azar, 2, 9);
      var coefMenor = _noNulo(azar, 9);
      if (coefMayor + coefMenor == 0) coefMenor = -coefMenor;
      final terminos = [
        _termino(coefMayor, exponenteMayor),
        _termino(coefMenor, exponenteMenor),
      ];
      final suma = coefMayor + coefMenor;
      return _problema(
        azar,
        'ALG.06',
        'Simplifica: {e}',
        {'e': _polinomio(terminos)},
        _polinomio(terminos),
        [
          // Junta lo que no es semejante: 3x² + 5x = 8x³.
          _monomio(suma, exponenteMayor + exponenteMenor),
          _monomio(suma, exponenteMayor),
          _monomio(coefMayor * coefMenor, exponenteMayor + exponenteMenor),
        ],
        (n) => _monomio(suma, exponenteMayor + n),
      );
    default:
      // División exacta de monomios.
      final divisor = _entre(azar, 2, 5);
      final cociente = _conSignoAlAzar(azar, 2, 6);
      final dividendo = divisor * cociente;
      final gradoXDivisor = _entre(azar, 1, 3);
      final restaX = _entre(azar, 1, 4);
      final gradoXDividendo = gradoXDivisor + restaX;
      final gradoYDivisor = _entre(azar, 0, 2);
      final restaY = _entre(azar, 0, 2);
      final gradoYDividendo = gradoYDivisor + restaY;
      return _problema(
        azar,
        'ALG.06',
        '¿Cuánto es {e}?',
        {
          'e': '(${_monomio(dividendo, gradoXDividendo, gradoYDividendo)}) : '
              '(${_monomio(divisor, gradoXDivisor, gradoYDivisor)})',
        },
        _monomio(cociente, restaX, restaY),
        [
          // Suma los exponentes en vez de restarlos.
          _monomio(cociente, gradoXDividendo + gradoXDivisor,
              gradoYDividendo + gradoYDivisor),
          // Resta los coeficientes en vez de dividirlos.
          _monomio(dividendo - divisor, restaX, restaY),
          // No toca los exponentes.
          _monomio(cociente, gradoXDividendo, gradoYDividendo),
        ],
        (n) => _monomio(cociente, restaX + n, restaY),
      );
  }
}

// ---------------------------------------------------------------------
// ALG.07 — Polinomios.
// ---------------------------------------------------------------------

/// Un polinomio de grado 2 con coeficientes hasta [maximo], ordenado.
List<_Termino> _trinomio(math.Random azar, int maximo) => [
      _termino(_entre(azar, 1, maximo), 2),
      _termino(_noNulo(azar, maximo), 1),
      _termino(_noNulo(azar, maximo)),
    ];

/// El error de «sumar los exponentes»: x² + x² = 2x⁴.
String _exponentesDoblados(List<_Termino> terminos) => _polinomio([
      for (final termino in terminos)
        _termino(termino.coeficiente, termino.gradoX * 2, termino.gradoY)
    ]);

/// Junta los términos por grado de x y quita los ceros.
List<_Termino> _sumaReducida(List<_Termino> terminos) {
  final porGrado = <int, int>{};
  for (final termino in terminos) {
    porGrado[termino.gradoX] =
        (porGrado[termino.gradoX] ?? 0) + termino.coeficiente;
  }
  return [
    for (final entrada in porGrado.entries)
      if (entrada.value != 0) _termino(entrada.value, entrada.key)
  ];
}

ProblemaEso _polinomios(math.Random azar, int dificultad) {
  // Fácil: suma y monomio por binomio. Medio y difícil: además resta,
  // binomio por binomio y factor común; en difícil, con coeficientes
  // mayores, trinomios y x² como factor.
  final modelosDisponibles = dificultad <= 2 ? 2 : 5;
  final maximo = dificultad <= 2 ? 5 : (dificultad <= 5 ? 6 : 9);
  switch (azar.nextInt(modelosDisponibles)) {
    case 0:
      // Suma. A partir de medio, el segundo viene desordenado.
      final primero = _trinomio(azar, maximo);
      final segundo = _trinomio(azar, maximo);
      final desordenado = dificultad >= 3;
      final segundoEscrito =
          desordenado ? [segundo[1], segundo[2], segundo[0]] : segundo;
      final suma = [...primero, ...segundo];
      return _problema(
        azar,
        'ALG.07',
        'Simplifica: {e}',
        {
          'e': '(${_polinomio(primero)}) + '
              '(${_polinomio(segundoEscrito, reducir: false)})',
        },
        _polinomio(suma),
        [
          // Suma también los exponentes.
          _exponentesDoblados(_sumaReducida(suma)),
          // Suma por posición, sin mirar el grado.
          if (desordenado)
            _polinomio([
              for (var i = 0; i < 3; i++)
                _termino(primero[i].coeficiente + segundoEscrito[i].coeficiente,
                    primero[i].gradoX)
            ]),
          // Se equivoca con el signo del término independiente.
          _polinomio([
            ...primero.take(2),
            ...segundo.take(2),
            _termino(primero[2].coeficiente - segundo[2].coeficiente),
          ]),
        ],
        (n) => _polinomio([...suma, _termino(n.isOdd ? n : -n, 1)]),
      );
    case 1:
      // Monomio por polinomio.
      final factor =
          _entre(azar, 2, 5) * (dificultad >= 3 && azar.nextBool() ? -1 : 1);
      final gradoFactor = dificultad >= 6 ? _entre(azar, 1, 2) : 1;
      final polinomio = dificultad >= 6
          ? _trinomio(azar, 5)
          : [_termino(_entre(azar, 2, maximo), 1), _termino(_noNulo(azar, 9))];
      final producto = _multiplicar([_termino(factor, gradoFactor)], polinomio);
      return _problema(
        azar,
        'ALG.07',
        'Desarrolla: {e}',
        {'e': '${_monomio(factor, gradoFactor)}(${_polinomio(polinomio)})'},
        _polinomio(producto),
        [
          // Multiplica sólo el primer término.
          _polinomio([producto.first, ...polinomio.skip(1)]),
          // Olvida la x del factor.
          _polinomio(_multiplicar([_termino(factor)], polinomio)),
          if (factor < 0)
            // Cambia el signo sólo del primer término.
            _polinomio([
              producto.first,
              ..._multiplicar([_termino(factor.abs(), gradoFactor)],
                  polinomio.skip(1).toList()),
            ])
          else
            // No suma los exponentes: x · x = x.
            _polinomio([
              for (final termino in polinomio)
                _termino(factor * termino.coeficiente,
                    math.max(termino.gradoX, gradoFactor))
            ], reducir: false),
        ],
        (n) => _polinomio([...producto, _termino(n.isOdd ? n : -n)]),
      );
    case 2:
      // Resta.
      final primero = _trinomio(azar, maximo);
      final segundo = _trinomio(azar, maximo);
      final diferencia = [...primero, ..._cambiarSigno(segundo)];
      return _problema(
        azar,
        'ALG.07',
        'Simplifica: {e}',
        {'e': '(${_polinomio(primero)}) − (${_polinomio(segundo)})'},
        _polinomio(diferencia),
        [
          // Cambia el signo sólo del primer término del paréntesis.
          _polinomio([
            ...primero,
            _termino(-segundo[0].coeficiente, 2),
            ...segundo.skip(1),
          ]),
          // Suma en vez de restar.
          _polinomio([...primero, ...segundo]),
          _exponentesDoblados(_sumaReducida(diferencia)),
        ],
        (n) => _polinomio([...diferencia, _termino(n.isOdd ? n : -n)]),
      );
    case 3:
      // Binomio por binomio.
      final coefXA = dificultad >= 6 ? _entre(azar, 1, 3) : 1;
      final coefXB = dificultad >= 6 ? _entre(azar, 1, 3) : 1;
      final numeroA = _noNulo(azar, 6);
      var numeroB = _noNulo(azar, 6);
      if (coefXA * numeroB + coefXB * numeroA == 0) numeroB = -numeroB;
      final binomioA = [_termino(coefXA, 1), _termino(numeroA)];
      final binomioB = [_termino(coefXB, 1), _termino(numeroB)];
      final producto = _multiplicar(binomioA, binomioB);
      final cuadrado = coefXA * coefXB;
      final central = coefXA * numeroB + coefXB * numeroA;
      final independiente = numeroA * numeroB;
      return _problema(
        azar,
        'ALG.07',
        'Desarrolla: {e}',
        {'e': '(${_polinomio(binomioA)})(${_polinomio(binomioB)})'},
        _polinomio(producto),
        [
          // Olvida los productos cruzados.
          _polinomio([_termino(cuadrado, 2), _termino(independiente)]),
          // Se equivoca con el signo del término independiente.
          _polinomio([
            _termino(cuadrado, 2),
            _termino(central, 1),
            _termino(-independiente),
          ]),
          if (coefXA == 1 && coefXB == 1)
            // Suma también los números.
            _polinomio([
              _termino(1, 2),
              _termino(central, 1),
              _termino(numeroA + numeroB),
            ])
          else
            // Suma los números sin multiplicarlos por los coeficientes.
            _polinomio([
              _termino(cuadrado, 2),
              _termino(numeroA + numeroB, 1),
              _termino(independiente),
            ]),
        ],
        (n) => _polinomio([...producto, _termino(n.isOdd ? n : -n, 1)]),
      );
    default:
      // Factor común: g·xˢ(p·x ± q), con p y q primos entre sí.
      final factorNumerico = _entre(azar, 2, dificultad >= 6 ? 6 : 5);
      final gradoFactor = dificultad >= 6 ? _entre(azar, 1, 2) : 1;
      late int coefDentro;
      late int numeroDentro;
      do {
        coefDentro = _entre(azar, 1, 5);
        numeroDentro = _entre(azar, 1, 5);
      } while (
          _mcd(coefDentro, numeroDentro) != 1 || coefDentro == numeroDentro);
      final signo = azar.nextBool() ? -1 : 1;
      final factor = _monomio(factorNumerico, gradoFactor);
      String dentro(int coeficiente, int grado, int independiente) =>
          _polinomio([_termino(coeficiente, grado), _termino(independiente)]);
      final expresion = _polinomio([
        _termino(factorNumerico * coefDentro, gradoFactor + 1),
        _termino(signo * factorNumerico * numeroDentro, gradoFactor),
      ]);
      return _problema(
        azar,
        'ALG.07',
        'Saca factor común: {e}',
        {'e': expresion},
        '$factor(${dentro(coefDentro, 1, signo * numeroDentro)})',
        [
          // No divide el segundo término entre el número.
          '$factor(${dentro(coefDentro, 1, signo * factorNumerico * numeroDentro)})',
          // No divide el primer término entre la x.
          '$factor(${dentro(coefDentro, gradoFactor + 1, signo * numeroDentro)})',
          // Olvida la x del factor común.
          '$factorNumerico(${dentro(coefDentro, 1, signo * numeroDentro)})',
        ],
        (n) => '$factor(${dentro(coefDentro + n, 1, signo * numeroDentro)})',
      );
  }
}

// ---------------------------------------------------------------------
// ALG.08 — Identidades notables.
// ---------------------------------------------------------------------

ProblemaEso _identidadesNotables(math.Random azar, int dificultad) {
  // Fácil: desarrollar cuadrados y suma por diferencia. Medio: además
  // el camino de vuelta (escribir como producto) y coeficiente 2.
  // Difícil: coeficiente hasta 3 y cálculo mental (21², 31 · 29).
  final modelosDisponibles = dificultad <= 2 ? 2 : (dificultad <= 5 ? 4 : 5);
  final coefX = dificultad <= 2 ? 1 : _entre(azar, 1, dificultad <= 5 ? 2 : 3);
  final numero = _entre(azar, 1, dificultad <= 2 ? 6 : 7);
  final signo = azar.nextBool() ? 1 : -1;
  final cuadradoX = coefX * coefX;
  final dobleProducto = 2 * coefX * numero;
  final cuadradoNumero = numero * numero;
  String binomio(int coeficiente, int independiente) =>
      _polinomio([_termino(coeficiente, 1), _termino(independiente)]);

  // En el camino de vuelta, a y b primos entre sí: si no, aún quedaría
  // un factor común fuera (9x² − 9 = 9(x + 1)(x − 1)).
  int primoConCoeficiente(int inicial) {
    var valor = inicial;
    while (_mcd(valor, coefX) != 1) {
      valor++;
    }
    return valor;
  }

  switch (azar.nextInt(modelosDisponibles)) {
    case 0:
      // (bx ± a)².
      return _problema(
        azar,
        'ALG.08',
        'Desarrolla: {e}',
        {'e': '(${binomio(coefX, signo * numero)})²'},
        _polinomio([
          _termino(cuadradoX, 2),
          _termino(signo * dobleProducto, 1),
          _termino(cuadradoNumero),
        ]),
        [
          // Olvida el doble producto: (x + 3)² = x² + 9.
          _polinomio(
              [_termino(cuadradoX, 2), _termino(signo * cuadradoNumero)]),
          if (coefX > 1)
            // No eleva el coeficiente de la x.
            _polinomio([
              _termino(coefX, 2),
              _termino(signo * dobleProducto, 1),
              _termino(cuadradoNumero),
            ]),
          // Sin el doble.
          _polinomio([
            _termino(cuadradoX, 2),
            _termino(signo * coefX * numero, 1),
            _termino(cuadradoNumero),
          ]),
          if (signo < 0)
            // Arrastra el menos al último término.
            _polinomio([
              _termino(cuadradoX, 2),
              _termino(-dobleProducto, 1),
              _termino(-cuadradoNumero),
            ])
          else
            // Toma a² por 2a.
            _polinomio([
              _termino(cuadradoX, 2),
              _termino(dobleProducto, 1),
              _termino(2 * numero),
            ]),
        ],
        (n) => _polinomio([
          _termino(cuadradoX, 2),
          _termino(signo * (dobleProducto + n), 1),
          _termino(cuadradoNumero),
        ]),
      );
    case 1:
      // (bx + a)(bx − a).
      return _problema(
        azar,
        'ALG.08',
        'Desarrolla: {e}',
        {'e': '(${binomio(coefX, numero)})(${binomio(coefX, -numero)})'},
        _polinomio([_termino(cuadradoX, 2), _termino(-cuadradoNumero)]),
        [
          // Suma los cuadrados.
          _polinomio([_termino(cuadradoX, 2), _termino(cuadradoNumero)]),
          // Lo confunde con (x − a)².
          _polinomio([
            _termino(cuadradoX, 2),
            _termino(-dobleProducto, 1),
            _termino(cuadradoNumero),
          ]),
          if (coefX > 1)
            // No eleva el coeficiente de la x.
            _polinomio([_termino(coefX, 2), _termino(-cuadradoNumero)])
          else
            // Toma a² por 2a.
            _polinomio([_termino(1, 2), _termino(-2 * numero)]),
        ],
        (n) =>
            _polinomio([_termino(cuadradoX, 2), _termino(-cuadradoNumero - n)]),
      );
    case 2:
      // Camino de vuelta: b²x² ± 2abx + a² = (bx ± a)².
      final numeroVuelta = primoConCoeficiente(numero == 1 ? 2 : numero);
      final dobleVuelta = 2 * coefX * numeroVuelta;
      return _problema(
        azar,
        'ALG.08',
        'Escribe como producto: {e}',
        {
          'e': _polinomio([
            _termino(cuadradoX, 2),
            _termino(signo * dobleVuelta, 1),
            _termino(numeroVuelta * numeroVuelta),
          ]),
        },
        '(${binomio(coefX, signo * numeroVuelta)})²',
        [
          // Signo cambiado.
          '(${binomio(coefX, -signo * numeroVuelta)})²',
          // Mete a² dentro del paréntesis: (x + 9)².
          '(${binomio(coefX, signo * numeroVuelta * numeroVuelta)})²',
          // La confunde con la suma por diferencia.
          '(${binomio(coefX, numeroVuelta)})(${binomio(coefX, -numeroVuelta)})',
          // No saca la raíz del coeficiente.
          if (coefX > 1) '(${binomio(cuadradoX, signo * numeroVuelta)})²',
        ],
        (n) => '(${binomio(coefX, signo * (numeroVuelta + n))})²',
      );
    case 3:
      // Camino de vuelta: b²x² − a² = (bx + a)(bx − a).
      final numeroVuelta = primoConCoeficiente(numero == 1 ? 3 : numero);
      return _problema(
        azar,
        'ALG.08',
        'Escribe como producto: {e}',
        {
          'e': _polinomio([
            _termino(cuadradoX, 2),
            _termino(-numeroVuelta * numeroVuelta),
          ]),
        },
        '(${binomio(coefX, numeroVuelta)})(${binomio(coefX, -numeroVuelta)})',
        [
          '(${binomio(coefX, -numeroVuelta)})²',
          '(${binomio(coefX, numeroVuelta)})²',
          // No saca la raíz: (x + 9)(x − 9).
          '(${binomio(coefX, numeroVuelta * numeroVuelta)})'
              '(${binomio(coefX, -numeroVuelta * numeroVuelta)})',
          if (coefX > 1)
            '(${binomio(cuadradoX, numeroVuelta)})'
                '(${binomio(cuadradoX, -numeroVuelta)})',
        ],
        (n) => '(${binomio(coefX, numeroVuelta + n)})'
            '(${binomio(coefX, -numeroVuelta - n)})',
      );
    default:
      // Cálculo mental: (10m ± u)² o (10m + u)(10m − u).
      final decenas = _entre(azar, 2, 9) * 10;
      final unidades = _entre(azar, 1, 2);
      final cuadradoDecenas = decenas * decenas;
      if (azar.nextBool()) {
        final base = decenas + signo * unidades;
        final resultado = base * base;
        return _problema(
          azar,
          'ALG.08',
          'Calcula de cabeza con una identidad notable: {e}',
          {'e': '$base²'},
          '$resultado',
          [
            // Sin el doble producto: 21² = 400 + 1.
            '${cuadradoDecenas + unidades * unidades}',
            // Con el producto una sola vez.
            '${cuadradoDecenas + signo * decenas * unidades + unidades * unidades}',
            // Con el signo cambiado.
            '${cuadradoDecenas - signo * 2 * decenas * unidades + unidades * unidades}',
          ],
          (n) => '${resultado + n * 10}',
        );
      }
      final resultado = cuadradoDecenas - unidades * unidades;
      return _problema(
        azar,
        'ALG.08',
        'Calcula de cabeza con una identidad notable: {e}',
        {'e': '${decenas + unidades} · ${decenas - unidades}'},
        '$resultado',
        [
          // Suma el cuadrado en vez de restarlo.
          '${cuadradoDecenas + unidades * unidades}',
          // Se olvida del cuadrado pequeño.
          '$cuadradoDecenas',
          // Toma u² por 2u.
          '${cuadradoDecenas - 2 * unidades}',
        ],
        (n) => '${resultado - n * 10}',
      );
  }
}
