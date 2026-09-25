import 'dart:math' as math;

import 'problema_eso.dart';

/// Fichas de números de 1.º y 2.º de ESO: enteros, potencias, notación
/// científica, fracciones con signo, factorización y unidades de volumen.
final List<FichaProblemaEso> fichasNumerosEso = [
  FichaProblemaEso(
    idHabilidad: 'ARI.06',
    generar: _multiplicarDividirEnteros,
    etiquetaTejado: '−×−',
    tituloAyuda: 'MULTIPLICAR Y DIVIDIR ENTEROS',
    textoAyuda:
        'Primero los números sin signo; luego el signo: si los dos tienen el mismo signo, '
        'el resultado es positivo; si tienen signos distintos, negativo. (−3) · (−4) = 12; '
        '(−12) : 3 = −4.',
    transferencia: 'En la vida: deber 3 € cada día durante 4 días son −12 €.',
    preguntaTutor: 'multiplicar o dividir números enteros con signo',
    errorTipico:
        'equivocarse con la regla de los signos: menos por menos da más',
    dificultadEstimada: 1.4,
    esquirlas: 4,
  ),
  const FichaProblemaEso(
    idHabilidad: 'ARI.07',
    generar: _operacionesCombinadasEnteros,
    etiquetaTejado: '−2+3·4',
    tituloAyuda: 'OPERACIONES COMBINADAS CON ENTEROS',
    textoAyuda:
        'Primero los paréntesis; después multiplicaciones y divisiones; al final sumas y '
        'restas, de izquierda a derecha. Un menos delante de un paréntesis cambia el signo '
        'de todo lo de dentro. −3 + 4 · (−2) = −3 − 8 = −11.',
    transferencia:
        'En la vida: si hace −2 °C y la temperatura baja 3 grados cada hora durante 4 horas, '
        'llega a −2 − 3 · 4 = −14 °C.',
    preguntaTutor:
        'calcular una expresión con enteros negativos, paréntesis y varias operaciones',
    errorTipico:
        'operar de izquierda a derecha sin respetar la jerarquía, o no cambiar todos los '
        'signos al quitar un paréntesis precedido de un menos',
    dificultadEstimada: 1.5,
    esquirlas: 4,
  ),
  const FichaProblemaEso(
    idHabilidad: 'ARI.08',
    generar: _propiedadesPotencias,
    etiquetaTejado: 'aᵐ·aⁿ',
    tituloAyuda: 'PROPIEDADES DE LAS POTENCIAS',
    textoAyuda:
        'Con la misma base, al multiplicar se suman los exponentes y al dividir se restan. '
        'En una potencia de una potencia se multiplican. Cualquier número distinto de 0 '
        'elevado a 0 da 1. 2⁵ · 2³ = 2⁸; (3²)⁴ = 3⁸.',
    transferencia:
        'En la vida: un papel doblado 3 veces tiene 2³ capas; si ese taco se dobla 2 veces '
        'más, 2³ · 2² = 2⁵ = 32 capas.',
    preguntaTutor:
        'escribir como una sola potencia un producto, un cociente o una potencia de potencias '
        'de la misma base',
    errorTipico:
        'multiplicar los exponentes en vez de sumarlos (2⁵ · 2³ = 2¹⁵), multiplicar las bases '
        'o creer que a⁰ = 0',
    dificultadEstimada: 1.3,
    esquirlas: 4,
  ),
  const FichaProblemaEso(
    idHabilidad: 'ARI.09',
    generar: _notacionCientifica,
    etiquetaTejado: 'a·10ⁿ',
    tituloAyuda: 'EXPONENTE NEGATIVO Y NOTACIÓN CIENTÍFICA',
    textoAyuda:
        'Un exponente negativo da la inversa, no un número negativo: 2⁻³ = 1/2³ = 1/8. '
        'En notación científica hay una sola cifra antes de la coma, distinta de 0, por una '
        'potencia de 10: 3 500 000 = 3,5 · 10⁶ y 0,00042 = 4,2 · 10⁻⁴. Para multiplicar, se '
        'multiplican las cifras y se suman los exponentes.',
    transferencia:
        'En la vida: un virus mide del orden de 10⁻⁷ m y la distancia a la Luna, de 10⁸ m; '
        'con notación científica se comparan sin contar ceros.',
    preguntaTutor:
        'calcular potencias de exponente negativo y pasar números a notación científica y '
        'desde ella',
    errorTipico:
        'creer que 2⁻³ es negativo, contar mal los ceros del exponente o dejar la parte '
        'entera con más de una cifra (35 · 10⁵)',
    dificultadEstimada: 1.7,
    esquirlas: 5,
  ),
  const FichaProblemaEso(
    idHabilidad: 'FR.23',
    generar: _fraccionesConSigno,
    etiquetaTejado: '−3/4',
    tituloAyuda: 'FRACCIONES CON SIGNO',
    textoAyuda:
        'Los signos siguen las reglas de los enteros. Para sumar o restar, busca un '
        'denominador común; para multiplicar, numerador por numerador y denominador por '
        'denominador; para dividir, multiplica por la inversa. Simplifica al final: '
        '−1/2 + 1/3 = −3/6 + 2/6 = −1/6.',
    transferencia:
        'En la vida: si un depósito pierde 1/4 de su agua y después recibe 1/6, el cambio '
        'total es −1/4 + 1/6 = −1/12 del depósito.',
    preguntaTutor:
        'sumar, restar, multiplicar o dividir fracciones con signo y simplificar el resultado',
    errorTipico:
        'sumar numeradores y denominadores por separado, perder el signo menos o no invertir '
        'la segunda fracción al dividir',
    dificultadEstimada: 1.5,
    esquirlas: 4,
  ),
  const FichaProblemaEso(
    idHabilidad: 'DIV.08',
    generar: _factoresPrimos,
    etiquetaTejado: '2²·3·5',
    tituloAyuda: 'FACTORES PRIMOS',
    textoAyuda:
        'Divide entre el primo más pequeño que puedas (2, 3, 5, 7…) hasta llegar a 1 y '
        'agrupa los repetidos en potencias: 60 = 2² · 3 · 5. El m.c.d. son los primos comunes '
        'con el menor exponente; el m.c.m., todos los primos con el mayor. Un número es '
        'cuadrado perfecto si todos sus exponentes son pares.',
    transferencia:
        'En la vida: dos autobuses que salen juntos y pasan cada 12 y cada 18 minutos vuelven '
        'a coincidir a los 36 minutos: el m.c.m. de 12 y 18.',
    preguntaTutor:
        'descomponer un número en factores primos y usarlo para el m.c.d., el m.c.m. o '
        'los cuadrados perfectos',
    errorTipico:
        'dejar un factor que no es primo (4, 6, 9), contar mal cuántas veces se repite un '
        'primo o confundir la regla del m.c.d. con la del m.c.m.',
    dificultadEstimada: 1.3,
    esquirlas: 4,
  ),
  const FichaProblemaEso(
    idHabilidad: 'MED.06',
    generar: _volumenCapacidad,
    etiquetaTejado: 'dm³=L',
    tituloAyuda: 'VOLUMEN Y CAPACIDAD',
    textoAyuda:
        'Entre m³, dm³ y cm³ cada paso multiplica o divide por 1000, no por 10. Entre L, dL, '
        'cL y mL cada paso es por 10. El puente entre las dos: 1 dm³ = 1 L y 1 cm³ = 1 mL, '
        'así que 1 m³ = 1000 L.',
    transferencia:
        'En la vida: una piscina de 50 m³ necesita 50 000 litros de agua para llenarse.',
    preguntaTutor:
        'pasar entre unidades de volumen (m³, dm³, cm³) y de capacidad (L, dL, cL, mL)',
    errorTipico:
        'multiplicar por 10 en cada paso entre unidades cúbicas en vez de por 1000, o creer '
        'que 1 m³ es 1 L',
    dificultadEstimada: 1.4,
    esquirlas: 4,
  ),
];

/// Traducciones de los textos de estas fichas: castellano → [euskera,
/// catalán]. Borrador pendiente de revisión nativa.
const Map<String, List<String>> traduccionesNumerosEso = {
  '¿Cuánto es {e}?': ['Zenbat da {e}?', 'Quant és {e}?'],
  'MULTIPLICAR Y DIVIDIR ENTEROS': [
    'ZENBAKI OSOAK BIDERKATU ETA ZATITU',
    'MULTIPLICAR I DIVIDIR ENTERS'
  ],
  'Primero los números sin signo; luego el signo: si los dos tienen el mismo signo, el resultado es positivo; si tienen signos distintos, negativo. (−3) · (−4) = 12; (−12) : 3 = −4.':
      [
    'Lehenik zenbakiak zeinurik gabe; gero zeinua: biek zeinu bera badute, emaitza positiboa da; zeinu desberdinak badituzte, negatiboa. (−3) · (−4) = 12; (−12) : 3 = −4.',
    'Primer els nombres sense signe; després el signe: si tots dos tenen el mateix signe, el resultat és positiu; si tenen signes diferents, negatiu. (−3) · (−4) = 12; (−12) : 3 = −4.',
  ],
  'En la vida: deber 3 € cada día durante 4 días son −12 €.': [
    'Bizitzan: lau egunez egunero 3 € zor izatea −12 € da.',
    'A la vida: deure 3 € cada dia durant 4 dies són −12 €.',
  ],
  // ARI.07
  'OPERACIONES COMBINADAS CON ENTEROS': [
    'ZENBAKI OSOEKIN ERAGIKETA KONBINATUAK',
    'OPERACIONS COMBINADES AMB ENTERS'
  ],
  'Primero los paréntesis; después multiplicaciones y divisiones; al final sumas y restas, de izquierda a derecha. Un menos delante de un paréntesis cambia el signo de todo lo de dentro. −3 + 4 · (−2) = −3 − 8 = −11.':
      [
    'Lehenik parentesiak; gero biderketak eta zatiketak; azkenik batuketak eta kenketak, ezkerretik eskuinera. Parentesi baten aurreko minus batek barruko guztiaren zeinua aldatzen du. −3 + 4 · (−2) = −3 − 8 = −11.',
    'Primer els parèntesis; després multiplicacions i divisions; al final sumes i restes, d\'esquerra a dreta. Un menys davant d\'un parèntesi canvia el signe de tot el que hi ha dins. −3 + 4 · (−2) = −3 − 8 = −11.',
  ],
  'En la vida: si hace −2 °C y la temperatura baja 3 grados cada hora durante 4 horas, llega a −2 − 3 · 4 = −14 °C.':
      [
    'Bizitzan: −2 °C badaude eta tenperatura 3 gradu jaisten bada orduro lau orduz, −2 − 3 · 4 = −14 °C-ra iristen da.',
    'A la vida: si fa −2 °C i la temperatura baixa 3 graus cada hora durant 4 hores, arriba a −2 − 3 · 4 = −14 °C.',
  ],
  // ARI.08
  'PROPIEDADES DE LAS POTENCIAS': [
    'BERREKETEN PROPIETATEAK',
    'PROPIETATS DE LES POTÈNCIES'
  ],
  'Con la misma base, al multiplicar se suman los exponentes y al dividir se restan. En una potencia de una potencia se multiplican. Cualquier número distinto de 0 elevado a 0 da 1. 2⁵ · 2³ = 2⁸; (3²)⁴ = 3⁸.':
      [
    'Oinarri berarekin, biderkatzean berretzaileak batu egiten dira eta zatitzean kendu. Berreketa baten berreketan biderkatu egiten dira. 0 ez den edozein zenbaki 0 berretzailera jasota 1 da. 2⁵ · 2³ = 2⁸; (3²)⁴ = 3⁸.',
    'Amb la mateixa base, en multiplicar se sumen els exponents i en dividir es resten. En una potència d\'una potència es multipliquen. Qualsevol nombre diferent de 0 elevat a 0 dona 1. 2⁵ · 2³ = 2⁸; (3²)⁴ = 3⁸.',
  ],
  'En la vida: un papel doblado 3 veces tiene 2³ capas; si ese taco se dobla 2 veces más, 2³ · 2² = 2⁵ = 32 capas.':
      [
    'Bizitzan: hiru aldiz tolestutako paperak 2³ geruza ditu; bloke hori beste bi aldiz tolesten bada, 2³ · 2² = 2⁵ = 32 geruza.',
    'A la vida: un paper doblegat 3 vegades té 2³ capes; si aquest bloc es doblega 2 vegades més, 2³ · 2² = 2⁵ = 32 capes.',
  ],
  'Escribe {e} como una sola potencia.': [
    'Idatzi {e} berreketa bakar gisa.',
    'Escriu {e} com una sola potència.'
  ],
  // ARI.09
  'EXPONENTE NEGATIVO Y NOTACIÓN CIENTÍFICA': [
    'BERRETZAILE NEGATIBOA ETA IDAZKERA ZIENTIFIKOA',
    'EXPONENT NEGATIU I NOTACIÓ CIENTÍFICA'
  ],
  'Un exponente negativo da la inversa, no un número negativo: 2⁻³ = 1/2³ = 1/8. En notación científica hay una sola cifra antes de la coma, distinta de 0, por una potencia de 10: 3 500 000 = 3,5 · 10⁶ y 0,00042 = 4,2 · 10⁻⁴. Para multiplicar, se multiplican las cifras y se suman los exponentes.':
      [
    'Berretzaile negatibo batek alderantzizkoa ematen du, ez zenbaki negatibo bat: 2⁻³ = 1/2³ = 1/8. Idazkera zientifikoan zifra bakarra dago komaren aurretik, 0 ez dena, eta 10en berreketa batez biderkatzen da: 3 500 000 = 3,5 · 10⁶ eta 0,00042 = 4,2 · 10⁻⁴. Biderkatzeko, zifrak biderkatu eta berretzaileak batu egiten dira.',
    'Un exponent negatiu dona l\'inversa, no un nombre negatiu: 2⁻³ = 1/2³ = 1/8. En notació científica hi ha una sola xifra abans de la coma, diferent de 0, per una potència de 10: 3 500 000 = 3,5 · 10⁶ i 0,00042 = 4,2 · 10⁻⁴. Per multiplicar, es multipliquen les xifres i se sumen els exponents.',
  ],
  'En la vida: un virus mide del orden de 10⁻⁷ m y la distancia a la Luna, de 10⁸ m; con notación científica se comparan sin contar ceros.':
      [
    'Bizitzan: birus batek 10⁻⁷ m inguru neurtzen du eta Ilargirako distantzia 10⁸ m ingurukoa da; idazkera zientifikoarekin zeroak zenbatu gabe konparatzen dira.',
    'A la vida: un virus fa de l\'ordre de 10⁻⁷ m i la distància a la Lluna, de 10⁸ m; amb notació científica es comparen sense comptar zeros.',
  ],
  'Escribe {n} en notación científica.': [
    'Idatzi {n} idazkera zientifikoan.',
    'Escriu {n} en notació científica.'
  ],
  'Escribe {n} sin potencias de 10.': [
    'Idatzi {n} 10en berreketarik gabe.',
    'Escriu {n} sense potències de 10.'
  ],
  'Calcula {e} y da el resultado en notación científica.': [
    'Kalkulatu {e} eta eman emaitza idazkera zientifikoan.',
    'Calcula {e} i dona el resultat en notació científica.'
  ],
  // FR.23
  'FRACCIONES CON SIGNO': ['ZATIKIAK ZEINUAREKIN', 'FRACCIONS AMB SIGNE'],
  'Los signos siguen las reglas de los enteros. Para sumar o restar, busca un denominador común; para multiplicar, numerador por numerador y denominador por denominador; para dividir, multiplica por la inversa. Simplifica al final: −1/2 + 1/3 = −3/6 + 2/6 = −1/6.':
      [
    'Zeinuek zenbaki osoen arauak jarraitzen dituzte. Batu edo kentzeko, bilatu izendatzaile komun bat; biderkatzeko, zenbakitzailea bider zenbakitzailea eta izendatzailea bider izendatzailea; zatitzeko, biderkatu alderantzizkoaz. Sinplifikatu amaieran: −1/2 + 1/3 = −3/6 + 2/6 = −1/6.',
    'Els signes segueixen les regles dels enters. Per sumar o restar, busca un denominador comú; per multiplicar, numerador per numerador i denominador per denominador; per dividir, multiplica per la inversa. Simplifica al final: −1/2 + 1/3 = −3/6 + 2/6 = −1/6.',
  ],
  'En la vida: si un depósito pierde 1/4 de su agua y después recibe 1/6, el cambio total es −1/4 + 1/6 = −1/12 del depósito.':
      [
    'Bizitzan: depositu batek bere uraren 1/4 galtzen badu eta gero 1/6 jasotzen badu, aldaketa osoa −1/4 + 1/6 = −1/12 da.',
    'A la vida: si un dipòsit perd 1/4 de l\'aigua i després en rep 1/6, el canvi total és −1/4 + 1/6 = −1/12 del dipòsit.',
  ],
  'Calcula {e} y simplifica el resultado.': [
    'Kalkulatu {e} eta sinplifikatu emaitza.',
    'Calcula {e} i simplifica el resultat.'
  ],
  // DIV.08
  'FACTORES PRIMOS': ['FAKTORE LEHENAK', 'FACTORS PRIMERS'],
  'Divide entre el primo más pequeño que puedas (2, 3, 5, 7…) hasta llegar a 1 y agrupa los repetidos en potencias: 60 = 2² · 3 · 5. El m.c.d. son los primos comunes con el menor exponente; el m.c.m., todos los primos con el mayor. Un número es cuadrado perfecto si todos sus exponentes son pares.':
      [
    'Zatitu ahal duzun zenbaki lehen txikienaz (2, 3, 5, 7…) 1era iritsi arte, eta bildu errepikatuak berreketetan: 60 = 2² · 3 · 5. Z.k.h. faktore lehen komunak dira, berretzaile txikienarekin; m.k.t., faktore lehen guztiak, berretzaile handienarekin. Zenbaki bat karratu perfektua da bere berretzaile guztiak bikoitiak badira.',
    'Divideix pel primer més petit que puguis (2, 3, 5, 7…) fins a arribar a 1 i agrupa els repetits en potències: 60 = 2² · 3 · 5. El m.c.d. són els primers comuns amb l\'exponent més petit; el m.c.m., tots els primers amb el més gran. Un nombre és quadrat perfecte si tots els exponents són parells.',
  ],
  'En la vida: dos autobuses que salen juntos y pasan cada 12 y cada 18 minutos vuelven a coincidir a los 36 minutos: el m.c.m. de 12 y 18.':
      [
    'Bizitzan: batera irteten diren eta 12 eta 18 minuturo pasatzen diren bi autobus 36 minutura elkartzen dira berriro: 12 eta 18 zenbakien m.k.t.',
    'A la vida: dos autobusos que surten junts i passen cada 12 i cada 18 minuts tornen a coincidir als 36 minuts: el m.c.m. de 12 i 18.',
  ],
  'Descompón {n} en factores primos.': [
    'Deskonposatu {n} faktore lehenetan.',
    'Descompon {n} en factors primers.'
  ],
  'Si {a} = {fa} y {b} = {fb}, ¿cuál es el m.c.d. de {a} y {b}?': [
    '{a} = {fa} eta {b} = {fb} badira, zein da {a} eta {b} zenbakien z.k.h.?',
    'Si {a} = {fa} i {b} = {fb}, quin és el m.c.d. de {a} i {b}?'
  ],
  'Si {a} = {fa} y {b} = {fb}, ¿cuál es el m.c.m. de {a} y {b}?': [
    '{a} = {fa} eta {b} = {fb} badira, zein da {a} eta {b} zenbakien m.k.t.?',
    'Si {a} = {fa} i {b} = {fb}, quin és el m.c.m. de {a} i {b}?'
  ],
  '¿Cuál de estos números es un cuadrado perfecto? Piensa en sus factores primos.':
      [
    'Zenbaki hauetatik zein da karratu perfektua? Pentsatu haien faktore lehenetan.',
    'Quin d\'aquests nombres és un quadrat perfecte? Pensa en els seus factors primers.',
  ],
  // MED.06
  'VOLUMEN Y CAPACIDAD': ['BOLUMENA ETA EDUKIERA', 'VOLUM I CAPACITAT'],
  'Entre m³, dm³ y cm³ cada paso multiplica o divide por 1000, no por 10. Entre L, dL, cL y mL cada paso es por 10. El puente entre las dos: 1 dm³ = 1 L y 1 cm³ = 1 mL, así que 1 m³ = 1000 L.':
      [
    'm³, dm³ eta cm³ artean urrats bakoitzak 1000 aldiz biderkatzen edo zatitzen du, ez 10 aldiz. L, dL, cL eta mL artean urrats bakoitza 10 aldizkoa da. Bien arteko zubia: 1 dm³ = 1 L eta 1 cm³ = 1 mL; beraz, 1 m³ = 1000 L.',
    'Entre m³, dm³ i cm³ cada pas multiplica o divideix per 1000, no per 10. Entre L, dL, cL i mL cada pas és per 10. El pont entre les dues: 1 dm³ = 1 L i 1 cm³ = 1 mL, així que 1 m³ = 1000 L.',
  ],
  'En la vida: una piscina de 50 m³ necesita 50 000 litros de agua para llenarse.':
      [
    'Bizitzan: 50 m³-ko igerileku batek 50 000 litro ur behar ditu betetzeko.',
    'A la vida: una piscina de 50 m³ necessita 50 000 litres d\'aigua per omplir-se.',
  ],
  '¿Cuántos {u2} son {v} {u1}?': [
    'Zenbat {u2} dira {v} {u1}?',
    'Quants {u2} són {v} {u1}?'
  ],
  '¿Cuántos litros caben en este depósito? Las medidas son interiores.': [
    'Zenbat litro sartzen dira depositu honetan? Neurriak barnekoak dira.',
    'Quants litres caben en aquest dipòsit? Les mesures són interiors.',
  ],
};

int _entre(math.Random azar, int minimo, int maximo) =>
    minimo + azar.nextInt(maximo - minimo + 1);

/// Los negativos van entre paréntesis: (−3) · 4.
String _entreParentesis(int valor) =>
    valor < 0 ? '(${conSigno(valor)})' : conSigno(valor);

ProblemaEso _multiplicarDividirEnteros(math.Random azar, int dificultad) {
  final maximo = dificultad <= 2 ? 9 : 12;
  var a = _entre(azar, 2, maximo);
  var b = _entre(azar, 2, maximo);
  // Signos: al menos uno negativo.
  final signoA = azar.nextBool() ? -1 : 1;
  final signoB = signoA == 1 ? -1 : (azar.nextBool() ? -1 : 1);
  a *= signoA;
  b *= signoB;
  final dividir = dificultad >= 2 && azar.nextBool();
  final String expresion;
  final int resultado;
  if (dividir) {
    // (a·b) : b = a, exacta.
    expresion = '${_entreParentesis(a * b)} : ${_entreParentesis(b)}';
    resultado = a;
  } else {
    expresion = '${_entreParentesis(a)} · ${_entreParentesis(b)}';
    resultado = a * b;
  }
  final elegidas = opcionesConErrores(
    azar,
    conSigno(resultado),
    [
      conSigno(-resultado),
      conSigno(dividir ? a * b - b : a + b),
      conSigno(dividir ? -b : -(a.abs() + b.abs()))
    ],
    relleno: (n) => conSigno(resultado + (n.isOdd ? n : -n)),
  );
  return ProblemaEso(
    idHabilidad: 'ARI.06',
    enunciado: '¿Cuánto es {e}?',
    datos: {'e': expresion},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
  );
}

// ---------------------------------------------------------------------
// Ayudas de escritura comunes a las fichas de abajo.
// ---------------------------------------------------------------------

/// Un elemento al azar de [lista].
T _unoDe<T>(math.Random azar, List<T> lista) =>
    lista[azar.nextInt(lista.length)];

const Map<String, String> _cifrasVoladas = {
  '0': '⁰',
  '1': '¹',
  '2': '²',
  '3': '³',
  '4': '⁴',
  '5': '⁵',
  '6': '⁶',
  '7': '⁷',
  '8': '⁸',
  '9': '⁹',
  '-': '⁻',
};

/// Un exponente en superíndice Unicode (−3 → ⁻³).
String _superindice(int exponente) =>
    '$exponente'.split('').map((caracter) => _cifrasVoladas[caracter]!).join();

/// Un entero dentro de una expresión: entre paréntesis si es negativo.
String _termino(int numero) => numero < 0 ? '(${conSigno(numero)})' : '$numero';

/// Una potencia tal como se escribe: la base negativa entre paréntesis;
/// con exponente 1, la base sola.
String _potencia(int base, int exponente) => exponente == 1
    ? _termino(base)
    : '${_termino(base)}${_superindice(exponente)}';

/// Una potencia como respuesta: a⁰ = 1 y a¹ = a.
String _resultadoPotencia(int base, int exponente) => switch (exponente) {
      0 => '1',
      1 => conSigno(base),
      _ => _potencia(base, exponente),
    };

int _elevar(int base, int exponente) {
  var resultado = 1;
  for (var vez = 0; vez < exponente; vez++) {
    resultado *= base;
  }
  return resultado;
}

int _maximoComunDivisor(int a, int b) =>
    b == 0 ? a.abs() : _maximoComunDivisor(b, a % b);

/// El número `cifras · 10^exponenteDiez` escrito en decimal, sin errores
/// de coma flotante: 35 y 5 → «3 500 000»; 42 y −5 → «0,00042». La
/// parte entera de cinco cifras o más se agrupa de tres en tres con un
/// espacio que no se parte.
String _escribirNumero(int cifras, int exponenteDiez) {
  final digitos = '$cifras';
  String parteEntera;
  String parteDecimal;
  if (exponenteDiez >= 0) {
    parteEntera = digitos + '0' * exponenteDiez;
    parteDecimal = '';
  } else {
    final posicionComa = digitos.length + exponenteDiez;
    if (posicionComa <= 0) {
      parteEntera = '0';
      parteDecimal = '0' * -posicionComa + digitos;
    } else {
      parteEntera = digitos.substring(0, posicionComa);
      parteDecimal = digitos.substring(posicionComa);
    }
  }
  parteDecimal = parteDecimal.replaceAll(RegExp(r'0+$'), '');
  if (parteEntera.length >= 5) {
    final grupos = <String>[];
    for (var fin = parteEntera.length; fin > 0; fin -= 3) {
      grupos.insert(0, parteEntera.substring(math.max(0, fin - 3), fin));
    }
    parteEntera = grupos.join(' ');
  }
  return parteDecimal.isEmpty ? parteEntera : '$parteEntera,$parteDecimal';
}

/// `cifras · 10^exponenteDiez` en notación científica: 35 y 5 →
/// «3,5 · 10⁶».
String _enNotacionCientifica(int cifras, int exponenteDiez) {
  var cifrasSinCeros = cifras;
  var exponente = exponenteDiez;
  while (cifrasSinCeros % 10 == 0) {
    cifrasSinCeros ~/= 10;
    exponente++;
  }
  final digitos = '$cifrasSinCeros';
  final mantisa =
      digitos.length == 1 ? digitos : '${digitos[0]},${digitos.substring(1)}';
  return '$mantisa · 10${_superindice(exponente + digitos.length - 1)}';
}

/// Unas cifras con sentido para un dato: una sola (7) o dos que no
/// acaben en 0 (35).
int _cifrasDato(math.Random azar, {required bool dosCifras}) {
  if (!dosCifras) return _entre(azar, 1, 9);
  return _entre(azar, 1, 9) * 10 + _entre(azar, 1, 9);
}

// ---------------------------------------------------------------------
// ARI.07 Operaciones combinadas con enteros.
// ---------------------------------------------------------------------

/// Cinco modelos: `a ± b · c`, `a − (b + c)`, `(a + b) · c`,
/// `a · b − c : d` y `a − b · (c − d)`. Los errores son operar de
/// izquierda a derecha sin jerarquía, equivocar el signo del producto y
/// quitar mal el paréntesis precedido de un menos.
ProblemaEso _operacionesCombinadasEnteros(math.Random azar, int dificultad) {
  final maximo = dificultad <= 2
      ? 6
      : dificultad <= 5
          ? 9
          : 12;
  int numero() => _entre(azar, 1, maximo) * (azar.nextBool() ? -1 : 1);
  int factor() => _entre(azar, 2, maximo) * (azar.nextBool() ? -1 : 1);
  // El interior de un paréntesis «b + c» con el signo de c ya puesto.
  String sumaInterior(int primero, int segundo) =>
      '${conSigno(primero)} ${segundo < 0 ? '−' : '+'} ${segundo.abs()}';

  final modelos = dificultad <= 2
      ? [0, 1]
      : dificultad <= 5
          ? [0, 1, 2, 3]
          : [2, 3, 4];
  final String expresion;
  final int resultado;
  final List<int> errores;
  switch (_unoDe(azar, modelos)) {
    case 0:
      // a ± b · c
      final a = numero();
      final b = dificultad <= 2 ? _entre(azar, 2, maximo) : factor();
      final c = factor();
      final signo = azar.nextBool() ? 1 : -1;
      expresion =
          '${conSigno(a)} ${signo == 1 ? '+' : '−'} ${_termino(b)} · ${_termino(c)}';
      resultado = a + signo * b * c;
      errores = [(a + signo * b) * c, a - signo * b * c];
    case 1:
      // a − (b + c)
      final a = numero();
      final b = numero();
      final c = numero();
      expresion = '${conSigno(a)} − (${sumaInterior(b, c)})';
      resultado = a - (b + c);
      errores = [a - b + c, a + b + c, -resultado];
    case 2:
      // (a + b) · c
      final a = numero();
      var b = numero();
      // Que el paréntesis no valga 0.
      while (a + b == 0) {
        b = numero();
      }
      final c = factor();
      expresion = '(${sumaInterior(a, b)}) · ${_termino(c)}';
      resultado = (a + b) * c;
      errores = [a + b * c, -resultado, a * c + b];
    case 3:
      // a · b − c : d, con la división exacta.
      final a = factor();
      final b = factor();
      final d = factor();
      final cociente = numero();
      final c = cociente * d;
      expresion =
          '${conSigno(a)} · ${_termino(b)} − ${_termino(c)} : ${_termino(d)}';
      resultado = a * b - cociente;
      errores = [
        if ((a * b - c) % d == 0) (a * b - c) ~/ d,
        a * b + cociente,
        -resultado,
      ];
    default:
      // a − b · (c − d)
      final a = numero();
      final b = factor();
      final c = numero();
      final d = numero();
      expresion =
          '${conSigno(a)} − ${_termino(b)} · (${conSigno(c)} − ${_termino(d)})';
      resultado = a - b * (c - d);
      errores = [(a - b) * (c - d), a - b * c - d, a + b * (c - d)];
  }
  final elegidas = opcionesConErrores(
    azar,
    conSigno(resultado),
    [for (final error in errores) conSigno(error)],
    relleno: (n) => conSigno(resultado + (n.isOdd ? n : -n)),
  );
  return ProblemaEso(
    idHabilidad: 'ARI.07',
    enunciado: '¿Cuánto es {e}?',
    datos: {'e': expresion},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
  );
}

// ---------------------------------------------------------------------
// ARI.08 Propiedades de las potencias.
// ---------------------------------------------------------------------

/// Cinco modelos: producto y cociente de igual base, potencia de
/// potencia, exponente 0 (el resultado es 1) y, en lo más alto, todo
/// junto. Errores: multiplicar exponentes en vez de sumarlos (o al
/// revés), multiplicar o dividir las bases, sumar en vez de restar al
/// dividir y creer que a⁰ = 0 o a⁰ = a.
ProblemaEso _propiedadesPotencias(math.Random azar, int dificultad) {
  var base = _entre(azar, 2, dificultad <= 2 ? 5 : 9);
  if (dificultad >= 5 && azar.nextInt(3) == 0) base = -base;
  final exponenteMaximo = dificultad <= 2 ? 5 : 8;
  final modelos = dificultad <= 2
      ? [0, 1, 2]
      : dificultad <= 5
          ? [0, 1, 2, 3]
          : [2, 3, 4];

  var enunciado = 'Escribe {e} como una sola potencia.';
  final String expresion;
  final String buena;
  final List<String> errores;
  final String Function(int n) relleno;
  switch (_unoDe(azar, modelos)) {
    case 0:
      // aᵐ · aⁿ = aᵐ⁺ⁿ
      final m = _entre(azar, 2, exponenteMaximo);
      final n = _entre(azar, 2, exponenteMaximo);
      expresion = '${_potencia(base, m)} · ${_potencia(base, n)}';
      buena = _potencia(base, m + n);
      errores = [
        _potencia(base, m * n),
        _potencia(base * base, m + n),
        if (m != n) _resultadoPotencia(base, (m - n).abs()),
      ];
      relleno = (k) => _potencia(base, m + n + k);
    case 1:
      // aᵐ : aⁿ = aᵐ⁻ⁿ
      final n = _entre(azar, 2, exponenteMaximo - 1);
      final m = n + _entre(azar, 2, exponenteMaximo);
      expresion = '${_potencia(base, m)} : ${_potencia(base, n)}';
      buena = _potencia(base, m - n);
      errores = [
        _potencia(base, m + n),
        '1${_superindice(m - n)}',
        if (m % n == 0) _potencia(base, m ~/ n),
      ];
      relleno = (k) => _potencia(base, m - n + k);
    case 2:
      // (aᵐ)ⁿ = aᵐ·ⁿ
      final m = _entre(azar, 2, dificultad <= 2 ? 4 : 5);
      final n = _entre(azar, 2, 4);
      expresion = '(${_potencia(base, m)})${_superindice(n)}';
      buena = _potencia(base, m * n);
      errores = [
        _potencia(base, m + n),
        _potencia(base * n, m),
        if (_elevar(m, n) <= 99) _potencia(base, _elevar(m, n)),
      ];
      relleno = (k) => _potencia(base, m * n + k);
    case 3:
      // Exponente 0: aᵐ · aⁿ : aᵐ⁺ⁿ o (aᵐ)ⁿ : aᵐ·ⁿ dan a⁰ = 1.
      enunciado = '¿Cuánto es {e}?';
      final m = _entre(azar, 2, 5);
      final n = _entre(azar, 2, 4);
      final int exponenteDelDivisor;
      if (azar.nextBool()) {
        exponenteDelDivisor = m + n;
        expresion =
            '${_potencia(base, m)} · ${_potencia(base, n)} : ${_potencia(base, exponenteDelDivisor)}';
      } else {
        exponenteDelDivisor = m * n;
        expresion =
            '(${_potencia(base, m)})${_superindice(n)} : ${_potencia(base, exponenteDelDivisor)}';
      }
      buena = '1';
      errores = [
        '0',
        conSigno(base),
        _potencia(base, 2 * exponenteDelDivisor),
      ];
      relleno = (k) => _potencia(base, k + 1);
    default:
      // (aᵐ)ⁿ · aᵖ : aᵠ
      final m = _entre(azar, 2, 3);
      final n = _entre(azar, 2, 3);
      final p = _entre(azar, 1, 4);
      final exponenteFinal = _entre(azar, 2, 7);
      final q = math.max(1, m * n + p - exponenteFinal);
      final exponenteBueno = m * n + p - q;
      expresion =
          '(${_potencia(base, m)})${_superindice(n)} · ${_potencia(base, p)} : ${_potencia(base, q)}';
      buena = _resultadoPotencia(base, exponenteBueno);
      errores = [
        _resultadoPotencia(base, m + n + p - q),
        _resultadoPotencia(base, m * n + p + q),
        _resultadoPotencia(base, m * n * p - q),
      ];
      relleno = (k) => _potencia(base, exponenteBueno + k);
  }
  final elegidas = opcionesConErrores(azar, buena, errores, relleno: relleno);
  return ProblemaEso(
    idHabilidad: 'ARI.08',
    enunciado: enunciado,
    datos: {'e': expresion},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
  );
}

// ---------------------------------------------------------------------
// ARI.09 Potencias de exponente negativo y notación científica.
// ---------------------------------------------------------------------

/// Cuatro modelos: calcular una potencia de exponente negativo (2⁻³, 10⁻²
/// y, arriba, (2/3)⁻²), pasar un número a notación científica, pasar de
/// notación científica a número y multiplicar en notación científica.
/// Errores: creer que el exponente negativo da un número negativo o
/// multiplicar base por exponente, contar mal los ceros, cambiar el
/// signo del exponente, dejar la parte entera con dos cifras, multiplicar
/// los exponentes al multiplicar y olvidar reajustar la potencia.
ProblemaEso _notacionCientifica(math.Random azar, int dificultad) {
  final modelos = dificultad <= 2 ? [0, 1, 2] : [0, 1, 2, 3];
  var enunciado = '¿Cuánto es {e}?';
  var claveDato = 'e';
  final String dato;
  final String buena;
  final List<String> errores;
  final String Function(int n) relleno;
  switch (_unoDe(azar, modelos)) {
    case 0:
      if (dificultad >= 6 && azar.nextBool()) {
        // (p/q)⁻ᵏ = (q/p)ᵏ
        final (numerador, denominador) = _unoDe(azar, const [
          (1, 2),
          (1, 3),
          (2, 3),
          (3, 4),
          (2, 5),
          (3, 5),
          (4, 5),
        ]);
        final exponente = _entre(azar, 1, 2);
        final arriba = _elevar(denominador, exponente);
        final abajo = _elevar(numerador, exponente);
        String fraccion(int n, int d) => d == 1 ? '$n' : '$n/$d';
        dato = '($numerador/$denominador)${_superindice(-exponente)}';
        buena = fraccion(arriba, abajo);
        errores = [
          fraccion(abajo, arriba),
          '−${fraccion(abajo, arriba)}',
          '−${fraccion(arriba, abajo)}',
        ];
        relleno = (n) => fraccion(arriba + n, abajo);
      } else {
        final base = dificultad <= 2
            ? _unoDe(azar, const [2, 3, 10])
            : _unoDe(azar, const [2, 3, 4, 5, 10]);
        final exponenteMaximo = switch (base) {
          2 || 3 => 3,
          10 => dificultad <= 2 ? 3 : 4,
          _ => 2,
        };
        final exponente = _entre(azar, 1, exponenteMaximo);
        final potencia = _elevar(base, exponente);
        dato = '$base${_superindice(-exponente)}';
        if (base == 10) {
          buena = _escribirNumero(1, -exponente);
          errores = [
            '−$potencia',
            _escribirNumero(1, -exponente - 1),
            '−${base * exponente}',
          ];
          relleno = (n) => _escribirNumero(1, -exponente - 1 - n);
        } else {
          buena = '1/$potencia';
          errores = [
            '−$potencia',
            '−${base * exponente}',
            '1/${base * exponente}',
          ];
          relleno = (n) => '1/${potencia + n}';
        }
      }
    case 1:
      // Un número a notación científica.
      enunciado = 'Escribe {n} en notación científica.';
      claveDato = 'n';
      final cifras = _cifrasDato(azar, dosCifras: azar.nextBool());
      final pequeno = dificultad >= 3 && azar.nextBool();
      final exponenteCientifico = pequeno
          ? -_entre(azar, 2, dificultad <= 5 ? 4 : 6)
          : _entre(azar, 3, dificultad <= 5 ? 6 : 8);
      final exponenteDiez = exponenteCientifico - ('$cifras'.length - 1);
      dato = _escribirNumero(cifras, exponenteDiez);
      buena = _enNotacionCientifica(cifras, exponenteDiez);
      errores = [
        if (cifras >= 10) '$cifras · 10${_superindice(exponenteDiez)}',
        _enNotacionCientifica(
            cifras, -exponenteCientifico - ('$cifras'.length - 1)),
        _enNotacionCientifica(cifras, exponenteDiez + (pequeno ? 1 : -1)),
      ];
      relleno = (n) =>
          _enNotacionCientifica(cifras, exponenteDiez + (pequeno ? -n : n));
    case 2:
      // De notación científica a número.
      enunciado = 'Escribe {n} sin potencias de 10.';
      claveDato = 'n';
      final cifras = _cifrasDato(azar, dosCifras: azar.nextBool());
      final pequeno = dificultad >= 3 && azar.nextBool();
      final exponenteCientifico = pequeno
          ? -_entre(azar, 1, 4)
          : _entre(azar, 2, dificultad <= 2 ? 5 : 6);
      final exponenteDiez = exponenteCientifico - ('$cifras'.length - 1);
      dato = _enNotacionCientifica(cifras, exponenteDiez);
      buena = _escribirNumero(cifras, exponenteDiez);
      errores = [
        _escribirNumero(cifras, exponenteDiez + 1),
        _escribirNumero(cifras, exponenteDiez - 1),
        _escribirNumero(cifras, -exponenteCientifico - ('$cifras'.length - 1)),
      ];
      relleno = (n) => _escribirNumero(cifras, exponenteDiez + n + 1);
    default:
      // (a · 10ᵐ) · (c · 10ⁿ)
      enunciado = 'Calcula {e} y da el resultado en notación científica.';
      final primera = _entre(azar, 2, 9);
      final segunda = _entre(azar, 2, 9);
      int exponenteNoNulo(int minimo, int maximo) {
        final exponente = _entre(azar, minimo, maximo - 1);
        return exponente >= 0 ? exponente + 1 : exponente;
      }

      final m = exponenteNoNulo(dificultad <= 5 ? 2 : -6, 8);
      final n = exponenteNoNulo(dificultad <= 5 ? -3 : -8, 6);
      final producto = primera * segunda;
      dato =
          '(${_enNotacionCientifica(primera, m)}) · (${_enNotacionCientifica(segunda, n)})';
      buena = _enNotacionCientifica(producto, m + n);
      errores = [
        if (producto >= 10) '$producto · 10${_superindice(m + n)}',
        _enNotacionCientifica(producto, m * n),
        if (producto >= 10)
          _enNotacionCientifica(producto, m + n - 1)
        else
          _enNotacionCientifica(primera + segunda, m + n),
      ];
      relleno = (k) => _enNotacionCientifica(producto, m + n + k);
  }
  final elegidas = opcionesConErrores(azar, buena, errores, relleno: relleno);
  return ProblemaEso(
    idHabilidad: 'ARI.09',
    enunciado: enunciado,
    datos: {claveDato: dato},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
  );
}

// ---------------------------------------------------------------------
// FR.23 Operar fracciones con signo.
// ---------------------------------------------------------------------

/// Una fracción siempre simplificada y con el denominador positivo.
class _Fraccion {
  final int numerador;
  final int denominador;

  const _Fraccion._(this.numerador, this.denominador);

  factory _Fraccion(int numerador, int denominador) {
    if (denominador < 0) {
      numerador = -numerador;
      denominador = -denominador;
    }
    final divisor = _maximoComunDivisor(numerador.abs(), denominador);
    return _Fraccion._(numerador ~/ divisor, denominador ~/ divisor);
  }

  _Fraccion operator +(_Fraccion otra) => _Fraccion(
      numerador * otra.denominador + otra.numerador * denominador,
      denominador * otra.denominador);
  _Fraccion operator -(_Fraccion otra) => this + -otra;
  _Fraccion operator -() => _Fraccion._(-numerador, denominador);
  _Fraccion operator *(_Fraccion otra) =>
      _Fraccion(numerador * otra.numerador, denominador * otra.denominador);
  _Fraccion operator /(_Fraccion otra) =>
      _Fraccion(numerador * otra.denominador, denominador * otra.numerador);

  bool get esCero => numerador == 0;

  /// −3/4, o el entero si el denominador es 1.
  String get texto => denominador == 1
      ? conSigno(numerador)
      : '${numerador < 0 ? '−' : ''}${numerador.abs()}/$denominador';

  /// Dentro de una expresión, las negativas van entre paréntesis.
  String get enExpresion => numerador < 0 ? '($texto)' : texto;
}

/// Cuatro modelos: sumar o restar, multiplicar, dividir y, en lo más
/// alto, `x ± y · z` con jerarquía. Errores: sumar numeradores y
/// denominadores, perder el signo, tratar «− (−)» como «−», multiplicar
/// en cruz o sin invertir al dividir y operar sin jerarquía.
ProblemaEso _fraccionesConSigno(math.Random azar, int dificultad) {
  final denominadorMaximo = dificultad <= 2
      ? 6
      : dificultad <= 5
          ? 8
          : 10;
  _Fraccion fraccion() {
    final denominador = _entre(azar, 2, denominadorMaximo);
    var numerador = _entre(azar, 1, denominador + 2);
    // Sin fracciones que sean un entero (4/2, 3/3).
    while (numerador % denominador == 0) {
      numerador = _entre(azar, 1, denominador + 2);
    }
    return _Fraccion(azar.nextBool() ? -numerador : numerador, denominador);
  }

  final modelos = dificultad <= 2
      ? [0, 1]
      : dificultad <= 5
          ? [0, 1, 2]
          : [0, 2, 3];
  final modelo = _unoDe(azar, modelos);
  String expresion;
  _Fraccion resultado;
  List<_Fraccion> errores;
  // Se repite hasta tener un problema con algún negativo y resultado
  // no nulo (con el mismo azar, así que sigue siendo determinista).
  while (true) {
    final x = fraccion();
    final y = fraccion();
    switch (modelo) {
      case 0:
        final sumar = azar.nextBool();
        expresion = '${x.texto} ${sumar ? '+' : '−'} ${y.enExpresion}';
        resultado = sumar ? x + y : x - y;
        final operacionContraria = sumar ? x - y : x + y;
        errores = [
          _Fraccion(
              sumar ? x.numerador + y.numerador : x.numerador - y.numerador,
              x.denominador + y.denominador),
          -resultado,
          operacionContraria,
        ];
      case 1:
        expresion = '${x.texto} · ${y.enExpresion}';
        resultado = x * y;
        errores = [-resultado, x / y, x + y];
      case 2:
        expresion = '${x.texto} : ${y.enExpresion}';
        resultado = x / y;
        errores = [x * y, y / x, -resultado];
      default:
        final z = fraccion();
        final sumar = azar.nextBool();
        expresion =
            '${x.texto} ${sumar ? '+' : '−'} ${y.enExpresion} · ${z.enExpresion}';
        resultado = sumar ? x + y * z : x - y * z;
        errores = [
          (sumar ? x + y : x - y) * z,
          sumar ? x - y * z : x + y * z,
          -resultado,
        ];
    }
    final hayNegativo = expresion.contains('−');
    if (hayNegativo && !resultado.esCero) break;
  }
  final buena = resultado;
  final elegidas = opcionesConErrores(
    azar,
    buena.texto,
    [for (final error in errores) error.texto],
    relleno: (n) =>
        _Fraccion(buena.numerador + (n.isOdd ? n : -n), buena.denominador)
            .texto,
  );
  return ProblemaEso(
    idHabilidad: 'FR.23',
    enunciado: 'Calcula {e} y simplifica el resultado.',
    datos: {'e': expresion},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
  );
}

// ---------------------------------------------------------------------
// DIV.08 Descomposición en factores primos.
// ---------------------------------------------------------------------

/// Primo → exponente, en orden creciente de primos.
typedef _Factores = Map<int, int>;

int _valorFactores(_Factores factores) => factores.entries.fold(
    1, (producto, entrada) => producto * _elevar(entrada.key, entrada.value));

/// 2³ · 3 · 5
String _textoFactores(_Factores factores) => [
      for (final entrada in factores.entries)
        if (entrada.value > 0) _potencia(entrada.key, entrada.value)
    ].join(' · ');

/// Unos exponentes al azar para [primos] (hasta [exponentesMaximos]).
_Factores _factoresAlAzar(
        math.Random azar, List<int> primos, List<int> exponentesMaximos) =>
    {
      for (var indice = 0; indice < primos.length; indice++)
        primos[indice]: azar.nextInt(exponentesMaximos[indice] + 1)
    };

/// Cuatro modelos: descomponer un número, calcular el m.c.d. o el m.c.m.
/// a partir de dos descomposiciones y reconocer el cuadrado perfecto.
/// Errores: un exponente contado de más o de menos, dejar un factor
/// compuesto (4, 6…), confundir la regla del m.c.d. con la del m.c.m.
/// (comunes/todos, menor/mayor exponente) y tomar por cuadrado un número
/// con algún exponente impar.
ProblemaEso _factoresPrimos(math.Random azar, int dificultad) {
  final modelos = dificultad <= 2 ? [0, 1, 2] : [0, 1, 2, 3];
  final modelo = _unoDe(azar, modelos);
  final String enunciado;
  final Map<String, String> datos;
  final String buena;
  final List<String> errores;
  final String Function(int n) relleno;
  switch (modelo) {
    case 0:
      final primos = dificultad <= 2
          ? const [2, 3, 5]
          : dificultad <= 5
              ? const [2, 3, 5, 7]
              : const [2, 3, 5, 7, 11];
      final exponentesMaximos = dificultad <= 2
          ? const [3, 2, 1]
          : dificultad <= 5
              ? const [4, 3, 2, 1]
              : const [5, 3, 2, 1, 1];
      final minimo = dificultad <= 2
          ? 12
          : dificultad <= 5
              ? 40
              : 150;
      final maximo = dificultad <= 2
          ? 120
          : dificultad <= 5
              ? 500
              : 2500;
      _Factores factores;
      while (true) {
        factores = _factoresAlAzar(azar, primos, exponentesMaximos);
        final valor = _valorFactores(factores);
        final distintos = factores.values.where((e) => e > 0).length;
        final total = factores.values.fold(0, (suma, e) => suma + e);
        if (valor >= minimo &&
            valor <= maximo &&
            distintos >= 2 &&
            total >= 3) {
          break;
        }
      }
      final presentes = [
        for (final entrada in factores.entries)
          if (entrada.value > 0) entrada.key
      ];
      _Factores cambiando(int primo, int cambio) =>
          {...factores, primo: factores[primo]! + cambio};
      // El primo que más se repite: el más fácil de contar mal.
      final masRepetido =
          presentes.reduce((a, b) => factores[b]! > factores[a]! ? b : a);
      final otro = presentes.lastWhere((primo) => primo != masRepetido);
      // Un factor que no es primo: p² escrito como su valor, o p·q.
      final String compuesto;
      if (factores[masRepetido]! >= 2) {
        compuesto = [
          for (final primo in presentes)
            if (primo == masRepetido) ...[
              '${primo * primo}',
              if (factores[primo]! > 2) _potencia(primo, factores[primo]! - 2),
            ] else
              _potencia(primo, factores[primo]!)
        ].join(' · ');
      } else {
        final primero = presentes[0];
        final segundo = presentes[1];
        compuesto = [
          '${primero * segundo}',
          for (final primo in presentes.skip(2))
            _potencia(primo, factores[primo]!)
        ].join(' · ');
      }
      enunciado = 'Descompón {n} en factores primos.';
      datos = {'n': '${_valorFactores(factores)}'};
      buena = _textoFactores(factores);
      errores = [
        compuesto,
        _textoFactores(
            cambiando(masRepetido, factores[masRepetido]! >= 2 ? -1 : 1)),
        _textoFactores(cambiando(otro, 1)),
      ];
      relleno = (n) => _textoFactores(cambiando(
          presentes[(n - 1) % presentes.length],
          1 + (n - 1) ~/ presentes.length));
    case 1:
    case 2:
      final esMcd = modelo == 1;
      const primos = [2, 3, 5, 7];
      final exponentesMaximos =
          dificultad <= 2 ? const [3, 2, 1, 1] : const [4, 2, 2, 1];
      final maximo = dificultad <= 2
          ? 100
          : dificultad <= 5
              ? 300
              : 1000;
      _Factores primero;
      _Factores segundo;
      _Factores mcd;
      _Factores mcm;
      while (true) {
        primero = _factoresAlAzar(azar, primos, exponentesMaximos);
        segundo = _factoresAlAzar(azar, primos, exponentesMaximos);
        mcd = {
          for (final primo in primos)
            primo: math.min(primero[primo]!, segundo[primo]!)
        };
        mcm = {
          for (final primo in primos)
            primo: math.max(primero[primo]!, segundo[primo]!)
        };
        final valorPrimero = _valorFactores(primero);
        final valorSegundo = _valorFactores(segundo);
        final valorMcd = _valorFactores(mcd);
        if (valorPrimero >= 12 &&
            valorSegundo >= 12 &&
            valorPrimero <= maximo &&
            valorSegundo <= maximo &&
            valorPrimero != valorSegundo &&
            valorMcd > 1 &&
            valorMcd != valorPrimero &&
            valorMcd != valorSegundo) {
          break;
        }
      }
      // Los errores de regla: comunes con el mayor exponente y todos con
      // el menor exponente que aparezca.
      final comunesConMayor = {
        for (final primo in primos)
          primo: primero[primo]! > 0 && segundo[primo]! > 0
              ? math.max(primero[primo]!, segundo[primo]!)
              : 0
      };
      final todosConMenor = {
        for (final primo in primos)
          primo: primero[primo]! == 0
              ? segundo[primo]!
              : segundo[primo]! == 0
                  ? primero[primo]!
                  : math.min(primero[primo]!, segundo[primo]!)
      };
      final valorMcd = _valorFactores(mcd);
      final valorMcm = _valorFactores(mcm);
      final valorPrimero = _valorFactores(primero);
      final valorSegundo = _valorFactores(segundo);
      enunciado = esMcd
          ? 'Si {a} = {fa} y {b} = {fb}, ¿cuál es el m.c.d. de {a} y {b}?'
          : 'Si {a} = {fa} y {b} = {fb}, ¿cuál es el m.c.m. de {a} y {b}?';
      datos = {
        'a': '$valorPrimero',
        'fa': _textoFactores(primero),
        'b': '$valorSegundo',
        'fb': _textoFactores(segundo),
      };
      final correcto = esMcd ? valorMcd : valorMcm;
      buena = '$correcto';
      errores = esMcd
          ? [
              '$valorMcm',
              '${_valorFactores(comunesConMayor)}',
              '${_valorFactores(todosConMenor)}',
            ]
          : [
              '$valorMcd',
              '${_valorFactores(comunesConMayor)}',
              '${_valorFactores(todosConMenor)}',
              '${valorPrimero * valorSegundo}',
            ];
      relleno = (n) => '${correcto * (n + 1)}';
    default:
      // El cuadrado perfecto entre números con algún exponente impar.
      final raiz = dificultad <= 5 ? _entre(azar, 6, 20) : _entre(azar, 12, 40);
      final cuadrado = raiz * raiz;
      final multiplicadores = [2, 3, 5, 6, 7, 10]..shuffle(azar);
      enunciado =
          '¿Cuál de estos números es un cuadrado perfecto? Piensa en sus factores primos.';
      datos = const {};
      buena = '$cuadrado';
      // k · m², con k sin cuadrados, se parece al cuadrado pero no lo es.
      errores = [
        for (final multiplicador in multiplicadores)
          if ((raiz / math.sqrt(multiplicador)).round() >= 2)
            '${multiplicador * (raiz / math.sqrt(multiplicador)).round() * (raiz / math.sqrt(multiplicador)).round()}'
      ];
      relleno = (n) => '${2 * (raiz + n) * (raiz + n)}';
  }
  final elegidas = opcionesConErrores(azar, buena, errores, relleno: relleno);
  return ProblemaEso(
    idHabilidad: 'DIV.08',
    enunciado: enunciado,
    datos: datos,
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
  );
}

// ---------------------------------------------------------------------
// MED.06 Unidades de volumen y capacidad.
// ---------------------------------------------------------------------

/// Una unidad y cuántas potencias de 10 de mL (o cm³) contiene.
typedef _UnidadVolumen = ({String simbolo, int potenciaDeMililitro});

const _metroCubico = (simbolo: 'm³', potenciaDeMililitro: 6);
const _decimetroCubico = (simbolo: 'dm³', potenciaDeMililitro: 3);
const _centimetroCubico = (simbolo: 'cm³', potenciaDeMililitro: 0);
const _litro = (simbolo: 'L', potenciaDeMililitro: 3);
const _decilitro = (simbolo: 'dL', potenciaDeMililitro: 2);
const _centilitro = (simbolo: 'cL', potenciaDeMililitro: 1);
const _mililitro = (simbolo: 'mL', potenciaDeMililitro: 0);

/// Cuatro modelos: entre unidades cúbicas, entre unidades de capacidad,
/// de volumen a capacidad (o al revés) y, en lo más alto, los litros que
/// caben en un depósito de medidas en cm. Errores: ×10 o ×100 por paso
/// entre unidades cúbicas (como si fueran de longitud o de superficie),
/// convertir al revés, contar mal los pasos, creer que 1 m³ = 1 L y no
/// pasar los cm³ a litros.
ProblemaEso _volumenCapacidad(math.Random azar, int dificultad) {
  final modelos = dificultad <= 5 ? [0, 1, 2] : [0, 2, 3];
  final modelo = _unoDe(azar, modelos);

  if (modelo == 3) {
    // Depósito en cm: largo · ancho · alto cm³ = (a·b·c) · 1000 cm³.
    final largo = _entre(azar, 2, 8);
    final ancho = _entre(azar, 1, 6);
    final alto = _entre(azar, 1, 5);
    final litros = largo * ancho * alto;
    final elegidas = opcionesConErrores(
      azar,
      '${_escribirNumero(litros, 0)} L',
      [
        '${_escribirNumero(litros, 3)} L',
        '${_escribirNumero(litros, 2)} L',
        '${_escribirNumero(litros, 1)} L',
      ],
      relleno: (n) => '${litros + n * largo * ancho} L',
    );
    return ProblemaEso(
      idHabilidad: 'MED.06',
      enunciado:
          '¿Cuántos litros caben en este depósito? Las medidas son interiores.',
      opciones: elegidas.opciones,
      indiceCorrecto: elegidas.indiceCorrecto,
      visual: VisualCuerpo(forma: FormaCuerpo.prisma, medidas: {
        'largo': '${largo * 10} cm',
        'ancho': '${ancho * 10} cm',
        'alto': '${alto * 10} cm',
      }),
    );
  }

  const cubicas = [_metroCubico, _decimetroCubico, _centimetroCubico];
  const capacidades = [_litro, _decilitro, _centilitro, _mililitro];
  _UnidadVolumen origen;
  _UnidadVolumen destino;
  switch (modelo) {
    case 0:
      final int indiceOrigen;
      final int indiceDestino;
      if (dificultad <= 2) {
        // Sólo de una unidad a la vecina más pequeña (multiplicar).
        indiceOrigen = azar.nextInt(2);
        indiceDestino = indiceOrigen + 1;
      } else {
        indiceOrigen = azar.nextInt(3);
        indiceDestino = _unoDe(azar, [
          for (var i = 0; i < 3; i++)
            if (i != indiceOrigen) i
        ]);
      }
      origen = cubicas[indiceOrigen];
      destino = cubicas[indiceDestino];
    case 1:
      // Con poca dificultad, sólo hacia una unidad más pequeña.
      final indiceOrigen = azar.nextInt(dificultad <= 2 ? 3 : 4);
      origen = capacidades[indiceOrigen];
      destino = _unoDe(azar, [
        for (var i = dificultad <= 2 ? indiceOrigen + 1 : 0; i < 4; i++)
          if (i != indiceOrigen) capacidades[i]
      ]);
    default:
      final cubica = dificultad <= 2
          ? _unoDe(azar, const [_decimetroCubico, _centimetroCubico])
          : _unoDe(azar, cubicas);
      final capacidad = dificultad <= 2
          ? _unoDe(azar, const [_litro, _mililitro])
          : _unoDe(azar, capacidades);
      if (azar.nextBool()) {
        origen = cubica;
        destino = capacidad;
      } else {
        origen = capacidad;
        destino = cubica;
      }
  }

  final dosCifras = dificultad >= 3 && azar.nextBool();
  final cifras = _cifrasDato(azar, dosCifras: dosCifras);
  final exponenteDato = dosCifras
      ? _unoDe(azar, const [-1, 0])
      : (dificultad <= 2 ? 0 : azar.nextInt(3));
  final salto = origen.potenciaDeMililitro - destino.potenciaDeMililitro;
  final signoSalto = salto >= 0 ? 1 : -1;
  String conSalto(int potencias) =>
      '${_escribirNumero(cifras, exponenteDato + potencias)} ${destino.simbolo}';

  final List<int> saltosErroneos;
  if (modelo == 0) {
    // Cada paso cúbico es ×1000: el error es ×10 o ×100 por paso.
    final pasos = salto ~/ 3;
    saltosErroneos = [pasos, 2 * pasos, -salto];
  } else if (modelo == 1) {
    saltosErroneos = [-salto, salto + signoSalto, salto - signoSalto];
  } else {
    // «1 m³ = 1 L» y confundir dm³ con cm³.
    saltosErroneos = [
      if (salto != 0) 0 else 3,
      salto + 3 * signoSalto,
      -salto,
      salto - 3,
    ];
  }
  final elegidas = opcionesConErrores(
    azar,
    conSalto(salto),
    [for (final saltoErroneo in saltosErroneos) conSalto(saltoErroneo)],
    relleno: (n) => conSalto(salto + (n.isOdd ? n : -n)),
  );
  return ProblemaEso(
    idHabilidad: 'MED.06',
    enunciado: '¿Cuántos {u2} son {v} {u1}?',
    datos: {
      'u2': destino.simbolo,
      'v': _escribirNumero(cifras, exponenteDato),
      'u1': origen.simbolo,
    },
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
  );
}
