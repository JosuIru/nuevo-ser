import 'dart:math' as math;

import 'problema_eso.dart';

/// Fichas de ecuaciones de 2.º de ESO: con paréntesis y denominadores,
/// de segundo grado y problemas con ecuaciones y sistemas.
final List<FichaProblemaEso> fichasEcuacionesEso = [
  const FichaProblemaEso(
    idHabilidad: 'ALG.09',
    generar: _ecuacionesParentesisDenominadores,
    etiquetaTejado: 'a(x−b)',
    tituloAyuda: 'ECUACIONES CON PARÉNTESIS Y DENOMINADORES',
    textoAyuda:
        'Quita los paréntesis multiplicando el número de fuera por cada término de dentro: '
        '3(x − 2) = 3x − 6. Si hay denominadores, multiplica todos los términos, también los '
        'que no llevan fracción, por el mínimo común múltiplo: x/2 + x/3 = 5 pasa a ser '
        '3x + 2x = 30, así que x = 6. Después, las x a un lado y los números al otro.',
    transferencia:
        'En la vida: repartir una cantidad en partes (la mitad para una cosa, un tercio para otra) lleva a ecuaciones con denominadores.',
    preguntaTutor:
        'resolver una ecuación de primer grado con paréntesis o denominadores',
    errorTipico:
        'multiplicar sólo el primer término del paréntesis, o no multiplicar todos los términos por el mcm',
    dificultadEstimada: 1.7,
    esquirlas: 5,
  ),
  const FichaProblemaEso(
    idHabilidad: 'ALG.10',
    generar: _ecuacionesSegundoGrado,
    etiquetaTejado: 'ax²+bx',
    tituloAyuda: 'ECUACIONES DE SEGUNDO GRADO',
    textoAyuda:
        'Si falta el término en x, despeja x² y haz la raíz con sus dos signos: x² = 25 da '
        'x = 5 y x = −5. Si falta el número, saca x factor común: x(x − 4) = 0 da x = 0 y '
        'x = 4. Si está completa, usa x = (−b ± √(b² − 4ac)) / 2a; si lo de dentro de la '
        'raíz es negativo, no tiene solución.',
    transferencia:
        'En la vida: si un terreno cuadrado mide 49 m², su lado sale de x² = 49: 7 m (la solución negativa no vale para una longitud).',
    preguntaTutor:
        'resolver una ecuación de segundo grado, completa o incompleta',
    errorTipico:
        'olvidar la solución negativa de la raíz, o la solución x = 0 al sacar factor común',
    dificultadEstimada: 1.9,
    esquirlas: 5,
  ),
  const FichaProblemaEso(
    idHabilidad: 'ALG.11',
    generar: _problemasConEcuaciones,
    etiquetaTejado: 'x+(x+1)',
    tituloAyuda: 'PROBLEMAS CON ECUACIONES',
    textoAyuda:
        'Llama x a lo que no sabes, escribe con x las demás cantidades y plantea la igualdad '
        'que dice el enunciado. Tres números consecutivos que suman 36: '
        'x + (x + 1) + (x + 2) = 36, así que x = 11. Al final, mira qué te preguntan: el mayor '
        'es 13, no 11.',
    transferencia:
        'En la vida: si sabes lo que pagaste en total y cuánto más cuesta una cosa que otra, una ecuación te da el precio de cada una.',
    preguntaTutor: 'plantear y resolver una ecuación a partir de un enunciado',
    errorTipico:
        'dar el valor de x cuando se pide otra cantidad, o no multiplicar todo el paréntesis al plantear',
    dificultadEstimada: 1.8,
    esquirlas: 5,
  ),
  const FichaProblemaEso(
    idHabilidad: 'ALG.12',
    generar: _problemasConSistemas,
    etiquetaTejado: 'x+y=s',
    tituloAyuda: 'PROBLEMAS CON SISTEMAS',
    textoAyuda:
        'Usa dos incógnitas, x e y, y escribe una ecuación con cada dato. Luego resuelve el '
        'sistema por sustitución, igualación o reducción. Si 3 entradas de adulto y 2 de niño '
        'cuestan 40 € y 2 de adulto y 2 de niño, 30 €, al restar queda que la de adulto cuesta '
        '10 €; y la de niño, 5 €.',
    transferencia:
        'En la vida: con dos tickets de compra de las mismas cosas en distinta cantidad puedes averiguar el precio de cada una.',
    preguntaTutor:
        'plantear y resolver un sistema de dos ecuaciones con dos incógnitas a partir de un enunciado',
    errorTipico:
        'dar el valor de la otra incógnita, o restar las ecuaciones sin igualar antes los coeficientes',
    dificultadEstimada: 1.9,
    esquirlas: 5,
  ),
];

/// Traducciones de los textos de estas fichas: castellano → [euskera,
/// catalán]. Borrador pendiente de revisión nativa.
const Map<String, List<String>> traduccionesEcuacionesEso = {
  // ALG.09
  'ECUACIONES CON PARÉNTESIS Y DENOMINADORES': [
    'PARENTESIAK ETA IZENDATZAILEAK DITUZTEN EKUAZIOAK',
    'EQUACIONS AMB PARÈNTESIS I DENOMINADORS',
  ],
  'Quita los paréntesis multiplicando el número de fuera por cada término de dentro: 3(x − 2) = 3x − 6. Si hay denominadores, multiplica todos los términos, también los que no llevan fracción, por el mínimo común múltiplo: x/2 + x/3 = 5 pasa a ser 3x + 2x = 30, así que x = 6. Después, las x a un lado y los números al otro.':
      [
    'Kendu parentesiak, kanpoko zenbakia barruko gai bakoitzarekin biderkatuta: 3(x − 2) = 3x − 6. Izendatzaileak badaude, biderkatu gai guztiak multiplo komunetako txikienarekin, baita zatikirik ez dutenak ere: x/2 + x/3 = 5 ekuazioa 3x + 2x = 30 bihurtzen da; beraz, x = 6. Gero, x-ak alde batera eta zenbakiak bestera.',
    'Treu els parèntesis multiplicant el nombre de fora per cada terme de dins: 3(x − 2) = 3x − 6. Si hi ha denominadors, multiplica tots els termes, també els que no porten fracció, pel mínim comú múltiple: x/2 + x/3 = 5 passa a ser 3x + 2x = 30, així que x = 6. Després, les x a un costat i els nombres a l\'altre.',
  ],
  'En la vida: repartir una cantidad en partes (la mitad para una cosa, un tercio para otra) lleva a ecuaciones con denominadores.':
      [
    'Bizitzan: kopuru bat zatitan banatzeak (erdia gauza baterako, herena beste baterako) izendatzaileak dituzten ekuazioetara eramaten du.',
    'A la vida: repartir una quantitat en parts (la meitat per a una cosa, un terç per a una altra) porta a equacions amb denominadors.',
  ],
  'Resuelve la ecuación: {e}': [
    'Ebatzi ekuazioa: {e}',
    'Resol l\'equació: {e}',
  ],
  // ALG.10
  'ECUACIONES DE SEGUNDO GRADO': [
    'BIGARREN MAILAKO EKUAZIOAK',
    'EQUACIONS DE SEGON GRAU',
  ],
  'Si falta el término en x, despeja x² y haz la raíz con sus dos signos: x² = 25 da x = 5 y x = −5. Si falta el número, saca x factor común: x(x − 4) = 0 da x = 0 y x = 4. Si está completa, usa x = (−b ± √(b² − 4ac)) / 2a; si lo de dentro de la raíz es negativo, no tiene solución.':
      [
    'x-dun gaia falta bada, bakandu x² eta egin erro karratua bi zeinuekin: x² = 25 ekuaziotik x = 5 eta x = −5 ateratzen dira. Zenbakia falta bada, atera x faktore komun gisa: x(x − 4) = 0 ekuaziotik x = 0 eta x = 4. Osoa bada, erabili x = (−b ± √(b² − 4ac)) / 2a; erroaren barrukoa negatiboa bada, ez du soluziorik.',
    'Si falta el terme en x, aïlla x² i fes l\'arrel amb els dos signes: x² = 25 dona x = 5 i x = −5. Si falta el nombre, treu x factor comú: x(x − 4) = 0 dona x = 0 i x = 4. Si és completa, fes servir x = (−b ± √(b² − 4ac)) / 2a; si el que hi ha dins de l\'arrel és negatiu, no té solució.',
  ],
  'En la vida: si un terreno cuadrado mide 49 m², su lado sale de x² = 49: 7 m (la solución negativa no vale para una longitud).':
      [
    'Bizitzan: lur karratu batek 49 m² baditu, haren aldea x² = 49 ekuaziotik ateratzen da: 7 m (soluzio negatiboak ez du balio luzera baterako).',
    'A la vida: si un terreny quadrat fa 49 m², el seu costat surt de x² = 49: 7 m (la solució negativa no serveix per a una longitud).',
  ],
  'Resuelve la ecuación de segundo grado: {e}': [
    'Ebatzi bigarren mailako ekuazioa: {e}',
    'Resol l\'equació de segon grau: {e}',
  ],
  'No tiene solución': ['Ez du soluziorik', 'No té solució'],
  // ALG.11
  'PROBLEMAS CON ECUACIONES': [
    'EKUAZIOEKIN EBAZTEKO PROBLEMAK',
    'PROBLEMES AMB EQUACIONS',
  ],
  'Llama x a lo que no sabes, escribe con x las demás cantidades y plantea la igualdad que dice el enunciado. Tres números consecutivos que suman 36: x + (x + 1) + (x + 2) = 36, así que x = 11. Al final, mira qué te preguntan: el mayor es 13, no 11.':
      [
    'Deitu x ez dakizunari, idatzi gainerako kantitateak x erabiliz eta planteatu enuntziatuak dioen berdintza. Batura 36 duten hiru zenbaki jarraitu: x + (x + 1) + (x + 2) = 36; beraz, x = 11. Azkenean, begiratu zer galdetzen dizuten: handiena 13 da, ez 11.',
    'Anomena x el que no saps, escriu amb x les altres quantitats i planteja la igualtat que diu l\'enunciat. Tres nombres consecutius que sumen 36: x + (x + 1) + (x + 2) = 36, així que x = 11. Al final, mira què et pregunten: el més gran és 13, no 11.',
  ],
  'En la vida: si sabes lo que pagaste en total y cuánto más cuesta una cosa que otra, una ecuación te da el precio de cada una.':
      [
    'Bizitzan: guztira zenbat ordaindu zenuen eta gauza bat bestea baino zenbat garestiagoa den badakizu, ekuazio batek bakoitzaren prezioa ematen dizu.',
    'A la vida: si saps quant vas pagar en total i quant més costa una cosa que una altra, una equació et dona el preu de cadascuna.',
  ],
  'La suma de tres números consecutivos es {s}. ¿Cuál es el mayor de los tres?':
      [
    'Hiru zenbaki jarraituren batura {s} da. Zein da hiruretatik handiena?',
    'La suma de tres nombres consecutius és {s}. Quin és el més gran dels tres?',
  ],
  'La suma de dos números pares consecutivos es {s}. ¿Cuál es el mayor?': [
    'Bi zenbaki bikoiti jarraituren batura {s} da. Zein da handiena?',
    'La suma de dos nombres parells consecutius és {s}. Quin és el més gran?',
  ],
  'Una madre tiene {m} años y su hija, {h}. ¿Dentro de cuántos años la edad de la madre será {k} veces la de la hija?':
      [
    'Ama batek {m} urte ditu, eta alabak, {h}. Zenbat urte barru izango da amaren adina alabarena bider {k}?',
    'Una mare té {m} anys i la seva filla, {h}. D\'aquí a quants anys l\'edat de la mare serà {k} vegades la de la filla?',
  ],
  'Una madre tiene {m} años y su hija, {h}. Dentro de unos años, la edad de la madre será {k} veces la de la hija. ¿Qué edad tendrá entonces la hija?':
      [
    'Ama batek {m} urte ditu, eta alabak, {h}. Urte batzuk barru, amaren adina alabarena bider {k} izango da. Zenbat urte izango ditu orduan alabak?',
    'Una mare té {m} anys i la seva filla, {h}. D\'aquí a uns anys, l\'edat de la mare serà {k} vegades la de la filla. Quina edat tindrà llavors la filla?',
  ],
  'Un rectángulo mide {d} cm más de largo que de ancho. Su perímetro es {p} cm. ¿Cuánto mide de largo?':
      [
    'Laukizuzen baten luzera zabalera baino {d} cm handiagoa da. Perimetroa {p} cm da. Zenbat neurtzen du luzerak?',
    'Un rectangle fa {d} cm més de llarg que d\'ample. El seu perímetre és {p} cm. Quant fa de llarg?',
  ],
  'En un triángulo isósceles, cada lado igual mide {d} cm más que la base. El perímetro es {p} cm. ¿Cuánto mide la base?':
      [
    'Triangelu isoszele batean, alde berdin bakoitza oinarria baino {d} cm luzeagoa da. Perimetroa {p} cm da. Zenbat neurtzen du oinarriak?',
    'En un triangle isòsceles, cada costat igual fa {d} cm més que la base. El perímetre és {p} cm. Quant fa la base?',
  ],
  'En el Mercado, el kilo de manzanas cuesta {d} € más que el de naranjas. Por {a} kg de manzanas y {b} kg de naranjas se pagan {t} €. ¿Cuánto cuesta el kilo de manzanas?':
      [
    'Merkatuan, sagar kiloak laranja kiloak baino {d} € gehiago balio du. Sagarretatik {a} kg eta laranjetatik {b} kg erosita, {t} € ordaintzen dira. Zenbat balio du sagar kilo batek?',
    'Al Mercat, el quilo de pomes costa {d} € més que el de taronges. Per {a} kg de pomes i {b} kg de taronges es paguen {t} €. Quant costa el quilo de pomes?',
  ],
  'Un depósito de los Canales está lleno. Se gasta 1/{p} del agua y después 1/{q} del agua que había al principio. Quedan {r} L. ¿Cuántos litros caben en el depósito?':
      [
    'Canales-eko ur-biltegi bat beteta dago. Uraren 1/{p} gastatzen da, eta gero hasieran zegoen uraren 1/{q}. {r} L geratzen dira. Zenbat litro sartzen dira ur-biltegian?',
    'Un dipòsit dels Canales és ple. Se\'n gasta 1/{p} de l\'aigua i després 1/{q} de l\'aigua que hi havia al principi. En queden {r} L. Quants litres caben al dipòsit?',
  ],
  // ALG.12
  'PROBLEMAS CON SISTEMAS': [
    'SISTEMEKIN EBAZTEKO PROBLEMAK',
    'PROBLEMES AMB SISTEMES',
  ],
  'Usa dos incógnitas, x e y, y escribe una ecuación con cada dato. Luego resuelve el sistema por sustitución, igualación o reducción. Si 3 entradas de adulto y 2 de niño cuestan 40 € y 2 de adulto y 2 de niño, 30 €, al restar queda que la de adulto cuesta 10 €; y la de niño, 5 €.':
      [
    'Erabili bi ezezagun, x eta y, eta idatzi ekuazio bat datu bakoitzarekin. Gero, ebatzi sistema ordezkapenez, berdinketaz edo laburketaz. Helduentzako 3 sarrerak eta haurrentzako 2k 40 € balio badute, eta helduentzako 2k eta haurrentzako 2k 30 €, kenduta ateratzen da helduen sarrerak 10 € balio duela; eta haurrenak, 5 €.',
    'Fes servir dues incògnites, x i y, i escriu una equació amb cada dada. Després resol el sistema per substitució, igualació o reducció. Si 3 entrades d\'adult i 2 d\'infant costen 40 € i 2 d\'adult i 2 d\'infant, 30 €, en restar queda que la d\'adult costa 10 €; i la d\'infant, 5 €.',
  ],
  'En la vida: con dos tickets de compra de las mismas cosas en distinta cantidad puedes averiguar el precio de cada una.':
      [
    'Bizitzan: gauza berak kantitate desberdinetan dituzten bi erosketa-tiketekin, bakoitzaren prezioa jakin dezakezu.',
    'A la vida: amb dos tiquets de compra de les mateixes coses en quantitats diferents pots esbrinar el preu de cadascuna.',
  ],
  'La suma de dos números es {s} y su diferencia es {d}. ¿Cuál es el mayor?': [
    'Bi zenbakiren batura {s} da, eta kendura, {d}. Zein da handiena?',
    'La suma de dos nombres és {s} i la seva diferència és {d}. Quin és el més gran?',
  ],
  'La suma de dos números es {s} y su diferencia es {d}. ¿Cuál es el menor?': [
    'Bi zenbakiren batura {s} da, eta kendura, {d}. Zein da txikiena?',
    'La suma de dos nombres és {s} i la seva diferència és {d}. Quin és el més petit?',
  ],
  'En el cine del Puerto, {a} entradas de adulto y {b} de niño cuestan {t} €, y {c} de adulto y {d} de niño cuestan {u} €. ¿Cuánto cuesta una entrada de adulto?':
      [
    'Portuko zineman, helduentzako {a} sarrerak eta haurrentzako {b} sarrerak {t} € balio dute, eta helduentzako {c} sarrerak eta haurrentzako {d} sarrerak, {u} €. Zenbat balio du helduentzako sarrera batek?',
    'Al cinema del Port, {a} entrades d\'adult i {b} d\'infant costen {t} €, i {c} d\'adult i {d} d\'infant costen {u} €. Quant costa una entrada d\'adult?',
  ],
  'En el cine del Puerto, {a} entradas de adulto y {b} de niño cuestan {t} €, y {c} de adulto y {d} de niño cuestan {u} €. ¿Cuánto cuesta una entrada de niño?':
      [
    'Portuko zineman, helduentzako {a} sarrerak eta haurrentzako {b} sarrerak {t} € balio dute, eta helduentzako {c} sarrerak eta haurrentzako {d} sarrerak, {u} €. Zenbat balio du haurrentzako sarrera batek?',
    'Al cinema del Port, {a} entrades d\'adult i {b} d\'infant costen {t} €, i {c} d\'adult i {d} d\'infant costen {u} €. Quant costa una entrada d\'infant?',
  ],
  'En una hucha hay {n} monedas: unas de {v} y otras de {w}. En total hay {t}. ¿Cuántas monedas de {v} hay?':
      [
    'Itsulapiko batean {n} txanpon daude: batzuek {v} balio dute, eta besteek, {w}. Guztira {t} daude. Zenbat txanponek balio dute {v}?',
    'En una guardiola hi ha {n} monedes: unes de {v} i unes altres de {w}. En total hi ha {t}. Quantes monedes de {v} hi ha?',
  ],
  'En una granja de las Afueras hay gallinas y conejos. Entre todos tienen {c} cabezas y {p} patas. ¿Cuántos conejos hay?':
      [
    'Kanpoaldeko baserri batean oiloak eta untxiak daude. Guztira {c} buru eta {p} hanka dituzte. Zenbat untxi daude?',
    'En una granja dels Afores hi ha gallines i conills. Entre tots tenen {c} caps i {p} potes. Quants conills hi ha?',
  ],
  'En una granja de las Afueras hay gallinas y conejos. Entre todos tienen {c} cabezas y {p} patas. ¿Cuántas gallinas hay?':
      [
    'Kanpoaldeko baserri batean oiloak eta untxiak daude. Guztira {c} buru eta {p} hanka dituzte. Zenbat oilo daude?',
    'En una granja dels Afores hi ha gallines i conills. Entre tots tenen {c} caps i {p} potes. Quantes gallines hi ha?',
  ],
  'Se mezcla café de {p} €/kg con café de {q} €/kg y se obtienen {m} kg a {r} €/kg. ¿Cuántos kilos del café de {p} €/kg se usan?':
      [
    'Bi kafe nahasten dira: bata {p} €/kg da, eta bestea, {q} €/kg. Guztira {m} kg lortzen dira, eta nahasketaren prezioa {r} €/kg da. Zenbat kilo erabiltzen dira {p} €/kg balio duen kafetik?',
    'Es barreja cafè de {p} €/kg amb cafè de {q} €/kg i se n\'obtenen {m} kg a {r} €/kg. Quants quilos del cafè de {p} €/kg s\'hi fan servir?',
  ],
};

int _entre(math.Random azar, int minimo, int maximo) =>
    minimo + azar.nextInt(maximo - minimo + 1);

T _elegir<T>(math.Random azar, List<T> lista) =>
    lista[azar.nextInt(lista.length)];

int _mcd(int a, int b) => b == 0 ? a.abs() : _mcd(b, a % b);

int _mcm(int a, int b) => a * b ~/ _mcd(a, b);

/// «x = n» con el valor como fracción irreducible si no es entero
/// (x = −3/4). Null si el denominador es cero (un error que no lleva a
/// ninguna solución).
String? _solucion(int numerador, int denominador) {
  if (denominador == 0) return null;
  if (denominador < 0) {
    numerador = -numerador;
    denominador = -denominador;
  }
  final divisor = _mcd(numerador, denominador);
  final arriba = numerador ~/ divisor;
  final abajo = denominador ~/ divisor;
  if (abajo == 1) return 'x = ${conSigno(arriba)}';
  return 'x = ${arriba < 0 ? '−' : ''}${arriba.abs()}/$abajo';
}

/// Dos soluciones, la mayor primero: «x = 3, x = −2».
String _parSoluciones(int primera, int segunda) {
  final mayor = math.max(primera, segunda);
  final menor = math.min(primera, segunda);
  return 'x = ${conSigno(mayor)}, x = ${conSigno(menor)}';
}

/// El primer término de una expresión: «3x», «−x», «x²», «−5».
String _terminoPrimero(int coeficiente, String parteLiteral) {
  final signo = coeficiente < 0 ? '−' : '';
  final valor = coeficiente.abs();
  final numero = valor == 1 && parteLiteral.isNotEmpty ? '' : '$valor';
  return '$signo$numero$parteLiteral';
}

/// Un término con su signo delante para ir detrás de otro: « + 3x»,
/// « − x», « − 5». Vacío si el coeficiente es cero.
String _terminoSiguiente(int coeficiente, String parteLiteral) {
  if (coeficiente == 0) return '';
  final signo = coeficiente < 0 ? ' − ' : ' + ';
  return '$signo${_terminoPrimero(coeficiente.abs(), parteLiteral)}';
}

/// `coeficiente·x + constante` escrito bien (x, −2x + 5, 7…).
String _expresionLineal(int coeficiente, int constante) {
  if (coeficiente == 0) return conSigno(constante);
  return _terminoPrimero(coeficiente, 'x') + _terminoSiguiente(constante, '');
}

/// `a·x² + b·x + c` escrito bien (x² − 5x + 6, 2x² + 8…).
String _expresionCuadratica(int a, int b, int c) =>
    _terminoPrimero(a, 'x²') +
    _terminoSiguiente(b, 'x') +
    _terminoSiguiente(c, '');

/// «(x + 3)» o «(x − 3)».
String _parentesis(int constante) =>
    '(x ${constante < 0 ? '−' : '+'} ${constante.abs()})';

/// El valor con su unidad («12 cm», «7 €») o solo («12»).
String _conUnidad(int valor, String unidad) =>
    unidad.isEmpty ? '$valor' : '$valor $unidad';

/// El resultado de un error de cálculo sólo si es un entero positivo
/// (si no, no sirve como opción creíble).
int? _siEnteroPositivo(int numerador, int denominador) => denominador != 0 &&
        numerador % denominador == 0 &&
        numerador ~/ denominador > 0
    ? numerador ~/ denominador
    : null;

/// Relleno para problemas con enunciado: valores positivos alrededor de
/// la respuesta (+1, −1, +2, −2… escalados si la respuesta es grande).
String Function(int n) _rellenoCercano(int buena, String unidad) => (n) {
      final paso = math.max(1, buena ~/ 10);
      final desplazamiento = (n.isOdd ? (n + 1) ~/ 2 : -(n ~/ 2)) * paso;
      var valor = buena + desplazamiento;
      if (valor <= 0) valor = buena + n * paso;
      return _conUnidad(valor, unidad);
    };

// ---------------------------------------------------------------------
// ALG.09 — Ecuaciones con paréntesis y denominadores.
// ---------------------------------------------------------------------

/// Una ecuación de primer grado ya escrita, su solución entera y las
/// soluciones a las que llevan los errores típicos.
typedef _PlanteoLineal = ({
  String ecuacion,
  int solucion,
  List<String?> errores,
});

ProblemaEso _ecuacionesParentesisDenominadores(
    math.Random azar, int dificultad) {
  final modelos = dificultad <= 2
      ? [0, 1]
      : dificultad <= 5
          ? [0, 1, 2]
          : [0, 2, 3];
  final planteo = switch (_elegir(azar, modelos)) {
    0 => _unParentesis(azar, dificultad),
    1 => _dosDenominadores(azar, dificultad),
    2 => _dosFracciones(azar, dificultad),
    _ => _dosParentesis(azar),
  };
  final elegidas = opcionesConErrores(
    azar,
    _solucion(planteo.solucion, 1)!,
    planteo.errores.whereType<String>().toList(),
    relleno: (n) =>
        _solucion(planteo.solucion + (n.isOdd ? (n + 1) ~/ 2 : -(n ~/ 2)), 1)!,
  );
  return ProblemaEso(
    idHabilidad: 'ALG.09',
    enunciado: 'Resuelve la ecuación: {e}',
    datos: {'e': planteo.ecuacion},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
  );
}

/// a(x − b) = cx + d.
_PlanteoLineal _unParentesis(math.Random azar, int dificultad) {
  final a = _entre(azar, 2, dificultad <= 2 ? 3 : 5);
  final c = _entre(azar, dificultad <= 1 ? 0 : 1, a - 1);
  final magnitudB = _entre(azar, 1, dificultad <= 2 ? 4 : 7);
  // b > 0 se escribe (x − b); b < 0, (x + |b|).
  final b = dificultad <= 2 || azar.nextBool() ? magnitudB : -magnitudB;
  final solucion = dificultad <= 2 ? _entre(azar, 1, 8) : _entre(azar, -6, 9);
  final d = a * (solucion - b) - c * solucion;
  return (
    ecuacion: '$a${_parentesis(-b)} = ${_expresionLineal(c, d)}',
    solucion: solucion,
    errores: [
      // Sólo multiplica la x del paréntesis: ax − b.
      _solucion(d + b, a - c),
      // Se equivoca de signo al quitar el paréntesis: ax + ab.
      _solucion(d - a * b, a - c),
      // Pasa cx al otro lado sin cambiarle el signo.
      _solucion(d + a * b, a + c),
    ],
  );
}

/// x/p + x/q = r (o x/p − x/q = r).
_PlanteoLineal _dosDenominadores(math.Random azar, int dificultad) {
  final denominadores = dificultad <= 2 ? [2, 3, 4] : [2, 3, 4, 5, 6];
  final p = _elegir(azar, denominadores);
  var q = _elegir(azar, denominadores);
  while (q == p) {
    q = _elegir(azar, denominadores);
  }
  final restar = dificultad >= 3 && azar.nextBool();
  // Al restar, el denominador pequeño primero para que r sea positivo.
  final primero = restar ? math.min(p, q) : p;
  final segundo = restar ? math.max(p, q) : q;
  final minimo = _mcm(primero, segundo);
  final veces = _entre(azar, 1, dificultad <= 2 ? 3 : 4);
  final coeficienteTotal = restar
      ? minimo ~/ primero - minimo ~/ segundo
      : minimo ~/ primero + minimo ~/ segundo;
  final r = veces * coeficienteTotal;
  return (
    ecuacion: 'x/$primero ${restar ? '−' : '+'} x/$segundo = $r',
    solucion: minimo * veces,
    errores: [
      // Multiplica por el mcm las x pero no el término de la derecha.
      _solucion(r, coeficienteTotal),
      // Suma (o resta) los denominadores.
      restar
          ? _solucion(r * (segundo - primero), 1)
          : _solucion(r * (primero + segundo), 2),
      // Multiplica sólo la r por el mcm y deja las x sin coeficiente.
      _solucion(r * minimo, restar ? 1 : 2),
    ],
  );
}

/// (x + s)/p = (x + t)/q.
_PlanteoLineal _dosFracciones(math.Random azar, int dificultad) {
  final denominadores = dificultad <= 5 ? [2, 3, 4, 5] : [2, 3, 4, 5, 6];
  final p = _elegir(azar, denominadores);
  var q = _elegir(azar, denominadores);
  while (q == p) {
    q = _elegir(azar, denominadores);
  }
  // x + s = p·v y x + t = q·v, con s y t distintos de cero.
  var solucion = 5;
  var s = 0;
  var t = 0;
  for (var intento = 0; intento < 50 && (s == 0 || t == 0); intento++) {
    solucion = dificultad <= 5 ? _entre(azar, 1, 9) : _entre(azar, -5, 9);
    final valorComun = _entre(azar, dificultad <= 5 ? 1 : -2, 4);
    s = p * valorComun - solucion;
    t = q * valorComun - solucion;
  }
  if (s == 0 || t == 0) {
    solucion = 5;
    s = p * 2 - 5;
    t = q * 2 - 5;
  }
  return (
    ecuacion: '${_parentesis(s)}/$p = ${_parentesis(t)}/$q',
    solucion: solucion,
    errores: [
      // Multiplica en cruz sólo la x de cada paréntesis.
      _solucion(t - s, q - p),
      // Multiplica cada lado por su propio denominador.
      _solucion(q * t - p * s, p - q),
      // Pasa q·s al otro lado sin cambiarle el signo.
      _solucion(p * t + q * s, q - p),
    ],
  );
}

/// a(x − b) − c(x + d) = e.
_PlanteoLineal _dosParentesis(math.Random azar) {
  final a = _entre(azar, 3, 6);
  final c = _entre(azar, 1, a - 1);
  final b = _entre(azar, 1, 6);
  final d = _entre(azar, 1, 6);
  final solucion = _entre(azar, -5, 9);
  final e = a * (solucion - b) - c * (solucion + d);
  final segundoParentesis =
      c == 1 ? '− ${_parentesis(d)}' : '− $c${_parentesis(d)}';
  return (
    ecuacion: '$a${_parentesis(-b)} $segundoParentesis = ${conSigno(e)}',
    solucion: solucion,
    errores: [
      // El menos de delante no llega al número del segundo paréntesis.
      _solucion(e + a * b - c * d, a - c),
      // No multiplica los números de dentro de los paréntesis.
      _solucion(e + b + d, a - c),
      // El menos de delante no llega a la x del segundo paréntesis.
      _solucion(e + a * b + c * d, a + c),
    ],
  );
}

// ---------------------------------------------------------------------
// ALG.10 — Ecuaciones de segundo grado.
// ---------------------------------------------------------------------

const _sinSolucion = 'No tiene solución';

ProblemaEso _ecuacionesSegundoGrado(math.Random azar, int dificultad) {
  // 0: ax² = c; 1: ax² + c = 0 sin solución; 2: ax² + bx = 0;
  // 3: completa con dos soluciones enteras; 4: completa sin solución.
  final modelos = dificultad <= 1
      ? [0, 2]
      : dificultad <= 4
          ? [0, 1, 2, 3, 3]
          : dificultad <= 5
              ? [0, 2, 3, 3]
              : [1, 2, 3, 3, 4];
  final String ecuacion;
  final String buena;
  final List<String> errores;
  final String Function(int n) relleno;
  switch (_elegir(azar, modelos)) {
    case 0:
      final a = dificultad <= 2 ? 1 : _entre(azar, 1, 3);
      final raiz = _entre(azar, 1, dificultad <= 2 ? 9 : 7);
      final c = a * raiz * raiz;
      // Con dificultad, a veces todo a un lado: ax² − c = 0.
      ecuacion = dificultad >= 3 && azar.nextBool()
          ? '${_expresionCuadratica(a, 0, -c)} = 0'
          : '${_terminoPrimero(a, 'x²')} = $c';
      buena = _parSoluciones(raiz, -raiz);
      errores = [
        'x = $raiz', // olvida la solución negativa
        _parSoluciones(raiz * raiz, -raiz * raiz), // no hace la raíz
        _sinSolucion,
      ];
      relleno = (n) => _parSoluciones(raiz + n, -raiz - n);
    case 1:
      final a = _entre(azar, 1, 3);
      final raiz = _entre(azar, 1, 6);
      ecuacion = '${_expresionCuadratica(a, 0, a * raiz * raiz)} = 0';
      buena = _sinSolucion;
      errores = [
        _parSoluciones(raiz, -raiz), // se come el signo menos
        'x = ${conSigno(-raiz)}', // «la raíz de −9 es −3»
        'x = 0',
      ];
      relleno = (n) => _parSoluciones(raiz + n, -raiz - n);
    case 2:
      final a = dificultad <= 2 ? 1 : _entre(azar, 1, dificultad <= 5 ? 3 : 4);
      var raiz = _entre(azar, 1, 8);
      if (azar.nextBool()) raiz = -raiz;
      ecuacion = '${_expresionCuadratica(a, -a * raiz, 0)} = 0';
      buena = _parSoluciones(0, raiz);
      errores = [
        'x = ${conSigno(raiz)}', // divide entre x y pierde x = 0
        _parSoluciones(0, -raiz), // se equivoca de signo
        'x = ${conSigno(-raiz)}',
      ];
      relleno = (n) => _parSoluciones(0, raiz + (raiz > 0 ? n : -n));
    case 3:
      final a = dificultad >= 6 && azar.nextBool() ? 2 : 1;
      final alcance = dificultad <= 4 ? 5 : 7;
      var primera = 0;
      var segunda = 0;
      // Dos raíces distintas, no nulas y no opuestas (b y c no nulos).
      while (primera == 0 ||
          segunda == 0 ||
          primera == segunda ||
          primera == -segunda) {
        primera = _entre(azar, -alcance, alcance);
        segunda = _entre(azar, -alcance, alcance);
      }
      final b = -a * (primera + segunda);
      final c = a * primera * segunda;
      ecuacion = '${_expresionCuadratica(a, b, c)} = 0';
      buena = _parSoluciones(primera, segunda);
      errores = [
        _parSoluciones(-primera, -segunda), // usa b en vez de −b
        // No divide entre 2a: se queda con −b ± √Δ.
        _parSoluciones(2 * a * primera, 2 * a * segunda),
        'x = ${conSigno(math.max(primera, segunda))}', // sólo una
      ];
      relleno = (n) => _parSoluciones(primera + n, segunda - n);
    default:
      // x² + 2mx + (m² + n²) = 0: el discriminante es −4n².
      var m = _entre(azar, 1, 4);
      if (azar.nextBool()) m = -m;
      final n = _entre(azar, 1, 3);
      ecuacion = '${_expresionCuadratica(1, 2 * m, m * m + n * n)} = 0';
      buena = _sinSolucion;
      errores = [
        // Hace la raíz de −4n² como si fuera 4n².
        _parSoluciones(-m + n, -m - n),
        _parSoluciones(m + n, m - n), // y además usa b en vez de −b
        'x = ${conSigno(-m)}', // se salta la raíz
      ];
      relleno = (k) => _parSoluciones(-m + n + k, -m - n - k);
  }
  final elegidas = opcionesConErrores(azar, buena, errores, relleno: relleno);
  return ProblemaEso(
    idHabilidad: 'ALG.10',
    enunciado: 'Resuelve la ecuación de segundo grado: {e}',
    datos: {'e': ecuacion},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
  );
}

// ---------------------------------------------------------------------
// ALG.11 — Problemas con ecuaciones.
// ---------------------------------------------------------------------

ProblemaEso _problemasConEcuaciones(math.Random azar, int dificultad) {
  // 0: consecutivos; 1: edades (cuándo); 2: edades (qué edad);
  // 3: rectángulo; 4: isósceles; 5: precios; 6: depósito con fracciones.
  final modelos = dificultad <= 2
      ? [0, 0, 3, 5]
      : dificultad <= 5
          ? [0, 1, 2, 3, 4, 5]
          : [1, 2, 4, 5, 6];
  final modelo = _elegir(azar, modelos);
  final String enunciado;
  final Map<String, String> datos;
  final int buena;
  final List<int?> errores;
  var unidad = '';
  VisualEso? visual;
  switch (modelo) {
    case 0:
      if (dificultad <= 2 || azar.nextBool()) {
        final menor =
            dificultad <= 2 ? _entre(azar, 3, 30) : _entre(azar, 10, 80);
        enunciado =
            'La suma de tres números consecutivos es {s}. ¿Cuál es el mayor de los tres?';
        datos = {'s': '${3 * menor + 3}'};
        buena = menor + 2;
        // Da x (el menor), el del medio (s : 3) o se pasa en uno.
        errores = [menor, menor + 1, menor + 3];
      } else {
        final menor = 2 * _entre(azar, 3, 40);
        enunciado =
            'La suma de dos números pares consecutivos es {s}. ¿Cuál es el mayor?';
        datos = {'s': '${2 * menor + 2}'};
        buena = menor + 2;
        // Da x, la mitad de la suma (consecutivos «de uno en uno») o x + 4.
        errores = [menor, menor + 1, menor + 4];
      }
    case 1:
    case 2:
      // m + t = k(h + t): se elige la edad de la hija, los años y k.
      var veces = 2;
      var edadHija = 5;
      var anos = 13;
      var edadMadre = 23;
      for (var intento = 0; intento < 60; intento++) {
        final vecesProbadas = _entre(azar, 2, dificultad >= 6 ? 4 : 3);
        final hijaProbada = _entre(azar, 2, 14);
        final anosProbados = _entre(azar, 1, 15);
        final madreProbada =
            vecesProbadas * (hijaProbada + anosProbados) - anosProbados;
        final diferencia = madreProbada - hijaProbada;
        if (diferencia >= 18 && diferencia <= 42 && madreProbada <= 60) {
          veces = vecesProbadas;
          edadHija = hijaProbada;
          anos = anosProbados;
          edadMadre = madreProbada;
          break;
        }
      }
      enunciado = modelo == 2
          ? 'Una madre tiene {m} años y su hija, {h}. Dentro de unos años, la edad de la madre será {k} veces la de la hija. ¿Qué edad tendrá entonces la hija?'
          : 'Una madre tiene {m} años y su hija, {h}. ¿Dentro de cuántos años la edad de la madre será {k} veces la de la hija?';
      datos = {'m': '$edadMadre', 'h': '$edadHija', 'k': '$veces'};
      // Suma los años sólo a la hija: m = k(h + t).
      final sinSumarMadre =
          _siEnteroPositivo(edadMadre - veces * edadHija, veces);
      // Olvida dividir entre k − 1.
      final sinDividir = edadMadre - veces * edadHija;
      if (modelo == 2) {
        buena = edadHija + anos;
        errores = [
          anos, // da x, los años que pasan
          edadMadre + anos, // la edad de la madre
          sinSumarMadre == null ? null : edadHija + sinSumarMadre,
          edadHija + sinDividir,
        ];
      } else {
        buena = anos;
        errores = [
          edadHija + anos, // la edad de la hija entonces
          sinSumarMadre,
          sinDividir,
          edadMadre + anos,
        ];
      }
    case 3:
      final ancho = _entre(azar, 2, dificultad <= 2 ? 10 : 20);
      final diferencia = _entre(azar, 1, dificultad <= 2 ? 6 : 10);
      final perimetro = 4 * ancho + 2 * diferencia;
      enunciado =
          'Un rectángulo mide {d} cm más de largo que de ancho. Su perímetro es {p} cm. ¿Cuánto mide de largo?';
      datos = {'d': '$diferencia', 'p': '$perimetro'};
      unidad = 'cm';
      buena = ancho + diferencia;
      // Plantea x + (x + d) = p (sólo dos lados).
      final anchoConDosLados = _siEnteroPositivo(perimetro - diferencia, 2);
      errores = [
        ancho, // da x, el ancho
        anchoConDosLados == null ? null : anchoConDosLados + diferencia,
        _siEnteroPositivo(perimetro, 4), // como si fuera un cuadrado
      ];
      visual = VisualFigura(
        forma: FormaPlana.rectangulo,
        medidas: {'base': 'x + $diferencia', 'alto': 'x'},
      );
    case 4:
      final base = _entre(azar, 3, 15);
      final diferencia = _entre(azar, 1, 8);
      final perimetro = 3 * base + 2 * diferencia;
      enunciado =
          'En un triángulo isósceles, cada lado igual mide {d} cm más que la base. El perímetro es {p} cm. ¿Cuánto mide la base?';
      datos = {'d': '$diferencia', 'p': '$perimetro'};
      unidad = 'cm';
      buena = base;
      errores = [
        base + diferencia, // da el lado igual
        _siEnteroPositivo(perimetro - diferencia, 3), // suma d una vez
        _siEnteroPositivo(perimetro, 3), // como si fuera equilátero
      ];
    case 5:
      final precioNaranjas = _entre(azar, 1, dificultad <= 2 ? 3 : 5);
      final diferencia = _entre(azar, 1, 4);
      final kilosManzanas = _entre(azar, 2, dificultad <= 2 ? 3 : 6);
      final kilosNaranjas = _entre(azar, 1, dificultad <= 2 ? 3 : 6);
      final total = kilosManzanas * (precioNaranjas + diferencia) +
          kilosNaranjas * precioNaranjas;
      enunciado =
          'En el Mercado, el kilo de manzanas cuesta {d} € más que el de naranjas. Por {a} kg de manzanas y {b} kg de naranjas se pagan {t} €. ¿Cuánto cuesta el kilo de manzanas?';
      datos = {
        'd': '$diferencia',
        'a': '$kilosManzanas',
        'b': '$kilosNaranjas',
        't': '$total',
      };
      unidad = '€';
      buena = precioNaranjas + diferencia;
      // Escribe a(x + d) como ax + d.
      final sinParentesis =
          _siEnteroPositivo(total - diferencia, kilosManzanas + kilosNaranjas);
      errores = [
        precioNaranjas, // da x, el kilo de naranjas
        sinParentesis == null ? null : sinParentesis + diferencia,
        _siEnteroPositivo(total, kilosManzanas + kilosNaranjas), // media
      ];
    default:
      const paresDenominadores = [
        (2, 3),
        (2, 4),
        (3, 4),
        (2, 5),
        (3, 6),
        (4, 6),
        (3, 5),
      ];
      final (p, q) = _elegir(azar, paresDenominadores);
      final capacidad = _mcm(p, q) * _entre(azar, 2, 8) * 10;
      final quedan = capacidad - capacidad ~/ p - capacidad ~/ q;
      enunciado =
          'Un depósito de los Canales está lleno. Se gasta 1/{p} del agua y después 1/{q} del agua que había al principio. Quedan {r} L. ¿Cuántos litros caben en el depósito?';
      datos = {'p': '$p', 'q': '$q', 'r': '$quedan'};
      unidad = 'L';
      buena = capacidad;
      errores = [
        capacidad - quedan, // da lo gastado
        // Toma 1/q de lo que quedaba, no del total.
        _siEnteroPositivo(quedan * p * q, (p - 1) * (q - 1)),
        // Aplica las fracciones a lo que queda: r + r/p + r/q.
        _siEnteroPositivo(quedan * (p * q + q + p), p * q),
      ];
  }
  final elegidas = opcionesConErrores(
    azar,
    _conUnidad(buena, unidad),
    [
      for (final error in errores)
        if (error != null && error > 0) _conUnidad(error, unidad),
    ],
    relleno: _rellenoCercano(buena, unidad),
  );
  return ProblemaEso(
    idHabilidad: 'ALG.11',
    enunciado: enunciado,
    datos: datos,
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: visual,
  );
}

// ---------------------------------------------------------------------
// ALG.12 — Problemas con sistemas.
// ---------------------------------------------------------------------

/// Céntimos escritos como euros: «2 €», «0,50 €».
String _euros(int centimos) => centimos % 100 == 0
    ? '${centimos ~/ 100} €'
    : '${(centimos / 100).toStringAsFixed(2).replaceAll('.', ',')} €';

ProblemaEso _problemasConSistemas(math.Random azar, int dificultad) {
  // 0: suma y diferencia; 1: entradas; 2: monedas; 3: granja; 4: mezcla.
  final modelos = dificultad <= 2
      ? [0, 1, 3]
      : dificultad <= 5
          ? [0, 1, 2, 3]
          : [1, 2, 3, 4];
  final String enunciado;
  final Map<String, String> datos;
  final int buena;
  final List<int?> errores;
  var unidad = '';
  switch (_elegir(azar, modelos)) {
    case 0:
      final menor = _entre(azar, 2, dificultad <= 2 ? 20 : 60);
      final mayor = menor + _entre(azar, 1, dificultad <= 2 ? 10 : 30);
      final suma = mayor + menor;
      final diferencia = mayor - menor;
      final preguntaMayor = azar.nextBool();
      enunciado = preguntaMayor
          ? 'La suma de dos números es {s} y su diferencia es {d}. ¿Cuál es el mayor?'
          : 'La suma de dos números es {s} y su diferencia es {d}. ¿Cuál es el menor?';
      datos = {'s': '$suma', 'd': '$diferencia'};
      buena = preguntaMayor ? mayor : menor;
      errores = [
        preguntaMayor ? menor : mayor, // da la otra incógnita
        // Suma o resta las ecuaciones pero no divide entre 2.
        preguntaMayor ? suma + diferencia : suma - diferencia,
        _siEnteroPositivo(suma, 2), // reparte a partes iguales
      ];
    case 1:
      final precioNino = _entre(azar, 2, dificultad <= 2 ? 6 : 9);
      final precioAdulto = precioNino + _entre(azar, 1, 6);
      int adultos1, ninos1, adultos2, ninos2;
      if (dificultad <= 2) {
        // Los mismos niños en las dos compras: al restar sale el adulto.
        adultos1 = _entre(azar, 2, 3);
        ninos1 = _entre(azar, 2, 4);
        adultos2 = adultos1 + 1;
        ninos2 = ninos1;
      } else {
        do {
          adultos1 = _entre(azar, 2, 5);
          ninos1 = _entre(azar, 2, 5);
          adultos2 = _entre(azar, 2, 5);
          ninos2 = _entre(azar, 2, 5);
        } while (adultos1 * ninos2 == adultos2 * ninos1);
      }
      final total1 = adultos1 * precioAdulto + ninos1 * precioNino;
      final total2 = adultos2 * precioAdulto + ninos2 * precioNino;
      final preguntaAdulto = dificultad <= 2 || azar.nextBool();
      enunciado = preguntaAdulto
          ? 'En el cine del Puerto, {a} entradas de adulto y {b} de niño cuestan {t} €, y {c} de adulto y {d} de niño cuestan {u} €. ¿Cuánto cuesta una entrada de adulto?'
          : 'En el cine del Puerto, {a} entradas de adulto y {b} de niño cuestan {t} €, y {c} de adulto y {d} de niño cuestan {u} €. ¿Cuánto cuesta una entrada de niño?';
      datos = {
        'a': '$adultos1',
        'b': '$ninos1',
        't': '$total1',
        'c': '$adultos2',
        'd': '$ninos2',
        'u': '$total2',
      };
      unidad = '€';
      buena = preguntaAdulto ? precioAdulto : precioNino;
      errores = [
        preguntaAdulto ? precioNino : precioAdulto, // la otra incógnita
        (total2 - total1).abs(), // resta sin igualar coeficientes
        _siEnteroPositivo(total1, adultos1 + ninos1), // precio medio
      ];
    case 2:
      const paresMonedas = [(200, 100), (100, 50), (200, 50), (50, 20)];
      final (valorGrande, valorPequeno) = _elegir(azar, paresMonedas);
      final grandes = _entre(azar, 2, dificultad <= 5 ? 12 : 20);
      final pequenas = _entre(azar, 2, dificultad <= 5 ? 12 : 20);
      final total = grandes * valorGrande + pequenas * valorPequeno;
      enunciado =
          'En una hucha hay {n} monedas: unas de {v} y otras de {w}. En total hay {t}. ¿Cuántas monedas de {v} hay?';
      datos = {
        'n': '${grandes + pequenas}',
        'v': _euros(valorGrande),
        'w': _euros(valorPequeno),
        't': _euros(total),
      };
      buena = grandes;
      errores = [
        pequenas, // la otra incógnita
        _siEnteroPositivo(grandes + pequenas, 2), // mitad y mitad
        _siEnteroPositivo(total, valorGrande), // como si todas fueran grandes
      ];
    case 3:
      final gallinas = _entre(azar, 2, dificultad <= 2 ? 12 : 30);
      final conejos = _entre(azar, 2, dificultad <= 2 ? 12 : 30);
      final cabezas = gallinas + conejos;
      final patas = 2 * gallinas + 4 * conejos;
      final preguntaConejos = azar.nextBool();
      enunciado = preguntaConejos
          ? 'En una granja de las Afueras hay gallinas y conejos. Entre todos tienen {c} cabezas y {p} patas. ¿Cuántos conejos hay?'
          : 'En una granja de las Afueras hay gallinas y conejos. Entre todos tienen {c} cabezas y {p} patas. ¿Cuántas gallinas hay?';
      datos = {'c': '$cabezas', 'p': '$patas'};
      buena = preguntaConejos ? conejos : gallinas;
      errores = [
        preguntaConejos ? gallinas : conejos, // la otra incógnita
        _siEnteroPositivo(patas, 4), // todas las patas como de conejo
        _siEnteroPositivo(cabezas, 2), // mitad y mitad
        patas - 2 * cabezas, // se queda en 2y sin dividir entre 2
      ];
    default:
      // x kg a p €/kg e y kg a q €/kg dan m kg a r €/kg, con r entero.
      var precioCaro = 12;
      var precioBarato = 8;
      var kilosCaro = 5;
      var kilosBarato = 15;
      for (var intento = 0; intento < 80; intento++) {
        final baratoProbado = _entre(azar, 6, 12);
        final caroProbado = baratoProbado + _entre(azar, 2, 8);
        final kilosCaroProbados = _entre(azar, 2, 20);
        final kilosBaratoProbados = _entre(azar, 2, 20);
        final coste = caroProbado * kilosCaroProbados +
            baratoProbado * kilosBaratoProbados;
        if (kilosCaroProbados != kilosBaratoProbados &&
            coste % (kilosCaroProbados + kilosBaratoProbados) == 0) {
          precioCaro = caroProbado;
          precioBarato = baratoProbado;
          kilosCaro = kilosCaroProbados;
          kilosBarato = kilosBaratoProbados;
          break;
        }
      }
      final kilosTotales = kilosCaro + kilosBarato;
      final precioMezcla =
          (precioCaro * kilosCaro + precioBarato * kilosBarato) ~/ kilosTotales;
      enunciado =
          'Se mezcla café de {p} €/kg con café de {q} €/kg y se obtienen {m} kg a {r} €/kg. ¿Cuántos kilos del café de {p} €/kg se usan?';
      datos = {
        'p': '$precioCaro',
        'q': '$precioBarato',
        'm': '$kilosTotales',
        'r': '$precioMezcla',
      };
      unidad = 'kg';
      buena = kilosCaro;
      errores = [
        kilosBarato, // la otra incógnita (reparte al revés)
        _siEnteroPositivo(kilosTotales, 2), // mitad y mitad
      ];
  }
  final elegidas = opcionesConErrores(
    azar,
    _conUnidad(buena, unidad),
    [
      for (final error in errores)
        if (error != null && error > 0) _conUnidad(error, unidad),
    ],
    relleno: _rellenoCercano(buena, unidad),
  );
  return ProblemaEso(
    idHabilidad: 'ALG.12',
    enunciado: enunciado,
    datos: datos,
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
  );
}
