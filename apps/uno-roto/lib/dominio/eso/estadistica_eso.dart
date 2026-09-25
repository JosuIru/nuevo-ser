import 'dart:math' as math;

import 'problema_eso.dart';

/// Fichas de estadística y probabilidad de 1.º y 2.º de ESO: tablas de
/// frecuencias, parámetros de una tabla (media, rango, moda, mediana) y
/// probabilidad compuesta con diagramas de árbol.
final List<FichaProblemaEso> fichasEstadisticaEso = [
  const FichaProblemaEso(
    idHabilidad: 'EST.07',
    generar: _tablaFrecuencias,
    etiquetaTejado: 'fi · hi',
    tituloAyuda: 'TABLAS DE FRECUENCIAS',
    textoAyuda:
        'La frecuencia absoluta (fi) es cuántas veces sale un dato; todas suman el total. '
        'La relativa (hi) es fi entre el total, y por 100 da el porcentaje. La acumulada (Fi) '
        'suma las fi de ese dato y de los anteriores. Si 5 de 20 datos valen 2: hi = 5/20 = 0,25, '
        'o sea, el 25 %.',
    transferencia:
        'En la vida: contar votos, notas o ventas y ver qué parte del total es cada cosa.',
    preguntaTutor:
        'completar una tabla de frecuencias: absoluta, relativa, acumulada o porcentaje',
    errorTipico:
        'confundir la frecuencia absoluta con la acumulada, u olvidar dividir entre el total',
    dificultadEstimada: 1.3,
    esquirlas: 4,
  ),
  const FichaProblemaEso(
    idHabilidad: 'EST.08',
    generar: _parametrosTabla,
    etiquetaTejado: 'x̄ · Me',
    tituloAyuda: 'MEDIA, MODA, MEDIANA Y RANGO DE UNA TABLA',
    textoAyuda:
        'Media: multiplica cada dato por su frecuencia, suma y divide entre el total de datos '
        '(no entre el número de filas). Moda: el dato con más frecuencia, no la frecuencia. '
        'Mediana: el dato que queda en el centro al ordenarlos todos. Rango: el dato mayor menos '
        'el menor. Con 2 veces el 4 y 3 veces el 6: media = (8 + 18) : 5 = 5,2.',
    transferencia:
        'En la vida: calcular la nota media de una clase o saber qué talla se vende más.',
    preguntaTutor:
        'calcular la media, la moda, la mediana o el rango a partir de una tabla de frecuencias',
    errorTipico:
        'hacer la media de los datos sin tener en cuenta sus frecuencias, o dar la frecuencia como moda',
    dificultadEstimada: 1.7,
    esquirlas: 5,
  ),
  const FichaProblemaEso(
    idHabilidad: 'EST.09',
    generar: _probabilidadCompuesta,
    etiquetaTejado: 'P·P',
    tituloAyuda: 'PROBABILIDAD COMPUESTA',
    textoAyuda:
        'Dibuja el árbol: en cada rama, la probabilidad de ese paso. Para un camino, multiplica '
        'las probabilidades de sus ramas; si valen varios caminos, suma sus resultados. Sin '
        'devolver la bola, en el segundo paso hay una bola menos. Dos caras con dos monedas: '
        '1/2 · 1/2 = 1/4.',
    transferencia:
        'En la vida: saber qué es más probable en un juego de dados o en un sorteo.',
    preguntaTutor:
        'calcular la probabilidad de dos sucesos seguidos con un diagrama de árbol',
    errorTipico:
        'sumar las probabilidades en vez de multiplicarlas, o no quitar la bola que ya se sacó',
    dificultadEstimada: 1.8,
    esquirlas: 5,
  ),
];

/// Traducciones de los textos de estas fichas: castellano → [euskera,
/// catalán]. Borrador pendiente de revisión nativa.
const Map<String, List<String>> traduccionesEstadisticaEso = {
  // EST.07
  'TABLAS DE FRECUENCIAS': ['MAIZTASUN-TAULAK', 'TAULES DE FREQÜÈNCIES'],
  'La frecuencia absoluta (fi) es cuántas veces sale un dato; todas suman el total. La relativa (hi) es fi entre el total, y por 100 da el porcentaje. La acumulada (Fi) suma las fi de ese dato y de los anteriores. Si 5 de 20 datos valen 2: hi = 5/20 = 0,25, o sea, el 25 %.':
      [
    'Maiztasun absolutua (fi) datu bat zenbat aldiz agertzen den da; guztiek batera totala ematen dute. Erlatiboa (hi) fi zati totala da, eta 100ez biderkatuta ehunekoa ematen du. Metatuak (Fi) datu horren eta aurrekoen fi-ak batzen ditu. 20 datutatik 5ek 2 balio badute: hi = 5/20 = 0,25, hau da, % 25.',
    'La freqüència absoluta (fi) és quantes vegades surt una dada; totes sumen el total. La relativa (hi) és fi entre el total, i per 100 dona el percentatge. L\'acumulada (Fi) suma les fi d\'aquella dada i de les anteriors. Si 5 de 20 dades valen 2: hi = 5/20 = 0,25, és a dir, el 25 %.',
  ],
  'En la vida: contar votos, notas o ventas y ver qué parte del total es cada cosa.':
      [
    'Bizitzan: botoak, notak edo salmentak zenbatu eta bakoitza totalaren zer zati den ikusi.',
    'A la vida: comptar vots, notes o vendes i veure quina part del total és cada cosa.',
  ],
  'Se preguntó a {n} familias cuántos hijos tienen. ¿Qué frecuencia absoluta falta en la tabla?':
      [
    '{n} familiari galdetu zitzaien zenbat seme-alaba dituzten. Zein maiztasun absolutu falta da taulan?',
    'Es va preguntar a {n} famílies quants fills tenen. Quina freqüència absoluta falta a la taula?',
  ],
  'Se anotaron los goles de {n} partidos en el distrito del Puerto. ¿Cuál es la frecuencia relativa del dato {v} goles?':
      [
    'Portuko barrutian {n} partidatako golak idatzi ziren. Zein da maiztasun erlatiboa, gol kopurua {v} denean?',
    'Es van anotar els gols de {n} partits al districte del Port. Quina és la freqüència relativa de la dada {v} gols?',
  ],
  'Se preguntó a {n} estudiantes cuántos libros leyeron en verano. ¿Qué frecuencia acumulada falta en la tabla?':
      [
    '{n} ikasleri galdetu zitzaien udan zenbat liburu irakurri zituzten. Zein maiztasun metatu falta da taulan?',
    'Es va preguntar a {n} estudiants quants llibres van llegir a l\'estiu. Quina freqüència acumulada falta a la taula?',
  ],
  'En un aparcamiento de Afueras se contaron los ocupantes de {n} coches. ¿Qué porcentaje de los coches llevaba {v} ocupantes?':
      [
    'Kanpoaldeko aparkaleku batean {n} autotako bidaiariak zenbatu ziren. Autoen zer ehunekok zeramatzan {v} bidaiari?',
    'En un aparcament de les Afores es van comptar els ocupants de {n} cotxes. Quin percentatge dels cotxes portava {v} ocupants?',
  ],
  'La tabla da las frecuencias relativas de {n} datos. ¿Cuál es la frecuencia absoluta del dato {v}?':
      [
    'Taulak {n} daturen maiztasun erlatiboak ematen ditu. Zein da maiztasun absolutua, datua {v} denean?',
    'La taula dona les freqüències relatives de {n} dades. Quina és la freqüència absoluta de la dada {v}?',
  ],
  'Hijos': ['Seme-alabak', 'Fills'],
  'Goles': ['Golak', 'Gols'],
  'Libros': ['Liburuak', 'Llibres'],
  'Ocupantes': ['Bidaiariak', 'Ocupants'],
  'Dato': ['Datua', 'Dada'],
  'Total': ['Guztira', 'Total'],
  // EST.08
  'MEDIA, MODA, MEDIANA Y RANGO DE UNA TABLA': [
    'TAULA BATEN BATEZBESTEKOA, MODA, MEDIANA ETA HEINA',
    'MITJANA, MODA, MEDIANA I RANG D\'UNA TAULA',
  ],
  'Media: multiplica cada dato por su frecuencia, suma y divide entre el total de datos (no entre el número de filas). Moda: el dato con más frecuencia, no la frecuencia. Mediana: el dato que queda en el centro al ordenarlos todos. Rango: el dato mayor menos el menor. Con 2 veces el 4 y 3 veces el 6: media = (8 + 18) : 5 = 5,2.':
      [
    'Batezbestekoa: biderkatu datu bakoitza bere maiztasunaz, batu, eta zatitu datu kopuru osoaz (ez errenkada kopuruaz). Moda: maiztasun handiena duen datua, ez maiztasuna bera. Mediana: datu guztiak ordenatzean erdian geratzen dena. Heina: datu handiena ken txikiena. 4a 2 aldiz eta 6a 3 aldiz: batezbestekoa = (8 + 18) : 5 = 5,2.',
    'Mitjana: multiplica cada dada per la seva freqüència, suma i divideix entre el total de dades (no entre el nombre de files). Moda: la dada amb més freqüència, no la freqüència. Mediana: la dada que queda al centre en ordenar-les totes. Rang: la dada més gran menys la més petita. Amb 2 vegades el 4 i 3 vegades el 6: mitjana = (8 + 18) : 5 = 5,2.',
  ],
  'En la vida: calcular la nota media de una clase o saber qué talla se vende más.':
      [
    'Bizitzan: gela baten batez besteko nota kalkulatu edo zein neurri saltzen den gehien jakin.',
    'A la vida: calcular la nota mitjana d\'una classe o saber quina talla es ven més.',
  ],
  'La tabla recoge las notas de un examen. ¿Cuál es la nota media?': [
    'Taulak azterketa bateko notak jasotzen ditu. Zein da batez besteko nota?',
    'La taula recull les notes d\'un examen. Quina és la nota mitjana?',
  ],
  'La tabla recoge la edad de las personas de un grupo de teatro de Canales. ¿Cuál es el rango (recorrido) de las edades?':
      [
    'Taulak Kanaletako antzerki-talde bateko pertsonen adina jasotzen du. Zein da adinen heina (ibiltartea)?',
    'La taula recull l\'edat de les persones d\'un grup de teatre dels Canals. Quin és el rang (recorregut) de les edats?',
  ],
  'La tabla recoge la talla de calzado de las personas de un equipo. ¿Cuál es la moda?':
      [
    'Taulak talde bateko pertsonen oinetako-neurria jasotzen du. Zein da moda?',
    'La taula recull la talla de calçat de les persones d\'un equip. Quina és la moda?',
  ],
  'La tabla recoge cuántas mascotas tienen varias familias de Montaña. ¿Cuál es la mediana?':
      [
    'Taulak Mendiko hainbat familiak zenbat maskota dituzten jasotzen du. Zein da mediana?',
    'La taula recull quantes mascotes tenen diverses famílies de la Muntanya. Quina és la mediana?',
  ],
  'Nota': ['Nota', 'Nota'],
  'Edad': ['Adina', 'Edat'],
  'Talla': ['Neurria', 'Talla'],
  'Mascotas': ['Maskotak', 'Mascotes'],
  // EST.09
  'PROBABILIDAD COMPUESTA': [
    'PROBABILITATE KONPOSATUA',
    'PROBABILITAT COMPOSTA'
  ],
  'Dibuja el árbol: en cada rama, la probabilidad de ese paso. Para un camino, multiplica las probabilidades de sus ramas; si valen varios caminos, suma sus resultados. Sin devolver la bola, en el segundo paso hay una bola menos. Dos caras con dos monedas: 1/2 · 1/2 = 1/4.':
      [
    'Marraztu zuhaitza: adar bakoitzean, urrats horren probabilitatea. Bide baterako, biderkatu bere adarren probabilitateak; bide batek baino gehiagok balio badute, batu haien emaitzak. Bola itzuli gabe, bigarren urratsean bola bat gutxiago dago. Bi txanponekin bi aurpegi: 1/2 · 1/2 = 1/4.',
    'Dibuixa l\'arbre: a cada branca, la probabilitat d\'aquell pas. Per a un camí, multiplica les probabilitats de les seves branques; si valen diversos camins, suma\'n els resultats. Sense tornar la bola, en el segon pas hi ha una bola menys. Dues cares amb dues monedes: 1/2 · 1/2 = 1/4.',
  ],
  'En la vida: saber qué es más probable en un juego de dados o en un sorteo.':
      [
    'Bizitzan: dado-joko batean edo zozketa batean zer den probableagoa jakin.',
    'A la vida: saber què és més probable en un joc de daus o en un sorteig.',
  ],
  'Se lanzan dos monedas (C = cara, X = cruz). ¿Cuál es la probabilidad de sacar dos caras?':
      [
    'Bi txanpon jaurtitzen dira (C = aurpegia, X = gurutzea). Zein da bi aurpegi ateratzeko probabilitatea?',
    'Es llancen dues monedes (C = cara, X = creu). Quina és la probabilitat de treure dues cares?',
  ],
  'Se lanzan dos monedas (C = cara, X = cruz). ¿Cuál es la probabilidad de sacar una cara y una cruz?':
      [
    'Bi txanpon jaurtitzen dira (C = aurpegia, X = gurutzea). Zein da aurpegi bat eta gurutze bat ateratzeko probabilitatea?',
    'Es llancen dues monedes (C = cara, X = creu). Quina és la probabilitat de treure una cara i una creu?',
  ],
  'Se lanzan dos monedas (C = cara, X = cruz). ¿Cuál es la probabilidad de sacar al menos una cara?':
      [
    'Bi txanpon jaurtitzen dira (C = aurpegia, X = gurutzea). Zein da gutxienez aurpegi bat ateratzeko probabilitatea?',
    'Es llancen dues monedes (C = cara, X = creu). Quina és la probabilitat de treure almenys una cara?',
  ],
  'Se lanzan un dado y una moneda (C = cara, X = cruz). ¿Cuál es la probabilidad de sacar un {d} en el dado y cara en la moneda?':
      [
    'Dado bat eta txanpon bat jaurtitzen dira (C = aurpegia, X = gurutzea). Zein da probabilitatea dadoan {d} zenbakia ateratzeko eta txanponean aurpegia?',
    'Es llancen un dau i una moneda (C = cara, X = creu). Quina és la probabilitat de treure un {d} al dau i cara a la moneda?',
  ],
  'Se lanzan un dado y una moneda (C = cara, X = cruz). ¿Cuál es la probabilidad de sacar en el dado un número mayor que {d} y cruz en la moneda?':
      [
    'Dado bat eta txanpon bat jaurtitzen dira (C = aurpegia, X = gurutzea). Zein da probabilitatea dadoan {d} baino zenbaki handiagoa ateratzeko eta txanponean gurutzea?',
    'Es llancen un dau i una moneda (C = cara, X = creu). Quina és la probabilitat de treure al dau un nombre més gran que {d} i creu a la moneda?',
  ],
  'Se lanzan un dado y una moneda (C = cara, X = cruz). ¿Cuál es la probabilidad de sacar en el dado un número par y cara en la moneda?':
      [
    'Dado bat eta txanpon bat jaurtitzen dira (C = aurpegia, X = gurutzea). Zein da probabilitatea dadoan zenbaki bikoitia ateratzeko eta txanponean aurpegia?',
    'Es llancen un dau i una moneda (C = cara, X = creu). Quina és la probabilitat de treure al dau un nombre parell i cara a la moneda?',
  ],
  'En una bolsa hay {b} bolas blancas (B) y {n} negras (N). Se saca una bola, se devuelve a la bolsa y se saca otra. ¿Cuál es la probabilidad de que las dos sean blancas?':
      [
    'Poltsa batean {b} bola zuri (B) eta {n} bola beltz (N) daude. Bola bat atera, poltsara itzuli eta beste bat ateratzen da. Zein da biak zuriak izateko probabilitatea?',
    'En una bossa hi ha {b} boles blanques (B) i {n} de negres (N). Es treu una bola, es torna a la bossa i se\'n treu una altra. Quina és la probabilitat que totes dues siguin blanques?',
  ],
  'En una bolsa hay {b} bolas blancas (B) y {n} negras (N). Se saca una bola, se devuelve a la bolsa y se saca otra. ¿Cuál es la probabilidad de que la primera sea blanca y la segunda negra?':
      [
    'Poltsa batean {b} bola zuri (B) eta {n} bola beltz (N) daude. Bola bat atera, poltsara itzuli eta beste bat ateratzen da. Zein da lehena zuria eta bigarrena beltza izateko probabilitatea?',
    'En una bossa hi ha {b} boles blanques (B) i {n} de negres (N). Es treu una bola, es torna a la bossa i se\'n treu una altra. Quina és la probabilitat que la primera sigui blanca i la segona negra?',
  ],
  'En una bolsa hay {b} bolas blancas (B) y {n} negras (N). Se sacan dos bolas, una detrás de otra, sin devolver la primera. ¿Cuál es la probabilidad de que las dos sean blancas?':
      [
    'Poltsa batean {b} bola zuri (B) eta {n} bola beltz (N) daude. Bi bola ateratzen dira, bata bestearen atzetik, lehena itzuli gabe. Zein da biak zuriak izateko probabilitatea?',
    'En una bossa hi ha {b} boles blanques (B) i {n} de negres (N). Es treuen dues boles, una darrere l\'altra, sense tornar la primera. Quina és la probabilitat que totes dues siguin blanques?',
  ],
  'En una bolsa hay {b} bolas blancas (B) y {n} negras (N). Se sacan dos bolas, una detrás de otra, sin devolver la primera. ¿Cuál es la probabilidad de que la primera sea blanca y la segunda negra?':
      [
    'Poltsa batean {b} bola zuri (B) eta {n} bola beltz (N) daude. Bi bola ateratzen dira, bata bestearen atzetik, lehena itzuli gabe. Zein da lehena zuria eta bigarrena beltza izateko probabilitatea?',
    'En una bossa hi ha {b} boles blanques (B) i {n} de negres (N). Es treuen dues boles, una darrere l\'altra, sense tornar la primera. Quina és la probabilitat que la primera sigui blanca i la segona negra?',
  ],
  'En una bolsa hay {b} bolas blancas (B) y {n} negras (N). Se sacan dos bolas, una detrás de otra, sin devolver la primera. ¿Cuál es la probabilidad de sacar una de cada color?':
      [
    'Poltsa batean {b} bola zuri (B) eta {n} bola beltz (N) daude. Bi bola ateratzen dira, bata bestearen atzetik, lehena itzuli gabe. Zein da kolore bakoitzeko bat ateratzeko probabilitatea?',
    'En una bossa hi ha {b} boles blanques (B) i {n} de negres (N). Es treuen dues boles, una darrere l\'altra, sense tornar la primera. Quina és la probabilitat de treure\'n una de cada color?',
  ],
};

int _entre(math.Random azar, int minimo, int maximo) =>
    minimo + azar.nextInt(maximo - minimo + 1);

int _mcd(int a, int b) => b == 0 ? a.abs() : _mcd(b, a % b);

/// Una fracción simplificada como texto (`3/8`, `1`, `0`).
String _fraccion(int numerador, int denominador) {
  if (numerador == 0) return '0';
  final divisor = _mcd(numerador, denominador);
  final arriba = numerador ~/ divisor;
  final abajo = denominador ~/ divisor;
  return abajo == 1 ? '$arriba' : '$arriba/$abajo';
}

/// Reparte [total] en [partes] enteros positivos al azar.
List<int> _repartir(math.Random azar, int total, int partes) {
  final cortes = <int>{};
  while (cortes.length < partes - 1) {
    cortes.add(_entre(azar, 1, total - 1));
  }
  final ordenados = [0, ...cortes.toList()..sort(), total];
  return [for (var i = 0; i < partes; i++) ordenados[i + 1] - ordenados[i]];
}

/// Las frecuencias acumuladas de una lista de frecuencias.
List<int> _acumuladas(List<int> frecuencias) {
  var suma = 0;
  return [for (final frecuencia in frecuencias) suma += frecuencia];
}

// ---------------------------------------------------------------- EST.07

ProblemaEso _tablaFrecuencias(math.Random azar, int dificultad) {
  final numeroFilas = dificultad <= 2 ? 3 : (dificultad <= 5 ? 4 : 5);
  // Totales que dividen a 100: la relativa y el porcentaje salen exactos.
  final totalesPosibles = dificultad <= 2 ? [10, 20] : [20, 25, 50];
  final total = totalesPosibles[azar.nextInt(totalesPosibles.length)];
  final frecuencias = _repartir(azar, total, numeroFilas);
  final acumuladas = _acumuladas(frecuencias);
  final fila = azar.nextInt(numeroFilas);
  final modelos = [
    'absoluta',
    'relativa',
    if (dificultad >= 2) 'acumulada',
    if (dificultad >= 3) 'porcentaje',
    if (dificultad >= 6) 'desdeRelativa',
  ];
  final modelo = modelos[azar.nextInt(modelos.length)];
  final frecuencia = frecuencias[fila];
  String frecuenciaVecina(int n) =>
      '${math.max(1, frecuencia + (n.isOdd ? n : -n))}';

  switch (modelo) {
    case 'absoluta':
      // Hijos por familia (0, 1, 2…); falta una fi y se da el total.
      final elegidas = opcionesConErrores(
        azar,
        '$frecuencia',
        [
          '${total - frecuencia}', // la suma de las otras, sin restar
          '${acumuladas[fila]}', // la acumulada de esa fila
          '$total',
        ],
        relleno: frecuenciaVecina,
      );
      return ProblemaEso(
        idHabilidad: 'EST.07',
        enunciado:
            'Se preguntó a {n} familias cuántos hijos tienen. ¿Qué frecuencia absoluta falta en la tabla?',
        datos: {'n': '$total'},
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
        visual: VisualTabla(cabecera: const [
          'Hijos',
          'fi'
        ], filas: [
          for (var i = 0; i < numeroFilas; i++)
            ['$i', i == fila ? '?' : '${frecuencias[i]}'],
          ['Total', '$total'],
        ]),
      );
    case 'relativa':
      final elegidas = opcionesConErrores(
        azar,
        formatearDecimal(frecuencia / total),
        [
          '${frecuencia * 100 ~/ total}', // el porcentaje, sin dividir
          formatearDecimal(acumuladas[fila] / total), // con la acumulada
          formatearDecimal(total / frecuencia, decimales: 2), // al revés
        ],
        relleno: (n) => formatearDecimal(
            math.max(1, frecuencia + (n.isOdd ? n : -n)) / total),
      );
      return ProblemaEso(
        idHabilidad: 'EST.07',
        enunciado:
            'Se anotaron los goles de {n} partidos en el distrito del Puerto. ¿Cuál es la frecuencia relativa del dato {v} goles?',
        datos: {'n': '$total', 'v': '$fila'},
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
        visual: VisualTabla(cabecera: const [
          'Goles',
          'fi'
        ], filas: [
          for (var i = 0; i < numeroFilas; i++) ['$i', '${frecuencias[i]}'],
          ['Total', '$total'],
        ]),
      );
    case 'acumulada':
      final elegidas = opcionesConErrores(
        azar,
        '${acumuladas[fila]}',
        [
          '$frecuencia', // la absoluta de esa fila
          if (fila > 0) '${acumuladas[fila - 1]}', // se queda en la anterior
          if (fila < numeroFilas - 1) '${acumuladas[fila + 1]}',
        ],
        relleno: (n) => '${acumuladas[fila] + (n.isOdd ? n : -n)}',
      );
      return ProblemaEso(
        idHabilidad: 'EST.07',
        enunciado:
            'Se preguntó a {n} estudiantes cuántos libros leyeron en verano. ¿Qué frecuencia acumulada falta en la tabla?',
        datos: {'n': '$total'},
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
        visual: VisualTabla(cabecera: const [
          'Libros',
          'fi',
          'Fi'
        ], filas: [
          for (var i = 0; i < numeroFilas; i++)
            ['$i', '${frecuencias[i]}', i == fila ? '?' : '${acumuladas[i]}'],
        ]),
      );
    case 'porcentaje':
      // Ocupantes por coche: 1, 2, 3…
      String porcentaje(num valor) => '${formatearDecimal(valor)} %';
      final elegidas = opcionesConErrores(
        azar,
        porcentaje(frecuencia * 100 / total),
        [
          porcentaje(frecuencia / total), // la relativa sin multiplicar
          porcentaje(frecuencia), // la absoluta como si fuera %
          porcentaje(acumuladas[fila] * 100 / total), // con la acumulada
        ],
        relleno: (n) => porcentaje(
            math.max(1, frecuencia + (n.isOdd ? n : -n)) * 100 / total),
      );
      return ProblemaEso(
        idHabilidad: 'EST.07',
        enunciado:
            'En un aparcamiento de Afueras se contaron los ocupantes de {n} coches. ¿Qué porcentaje de los coches llevaba {v} ocupantes?',
        datos: {'n': '$total', 'v': '${fila + 1}'},
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
        visual: VisualTabla(cabecera: const [
          'Ocupantes',
          'fi'
        ], filas: [
          for (var i = 0; i < numeroFilas; i++)
            ['${i + 1}', '${frecuencias[i]}'],
          ['Total', '$total'],
        ]),
      );
    default:
      // Dadas las relativas y el total, sacar una absoluta: fi = hi · N.
      final datoPrimero = _entre(azar, 1, 4);
      final elegidas = opcionesConErrores(
        azar,
        '$frecuencia',
        [
          formatearDecimal(frecuencia * 100 / total), // el porcentaje
          '${acumuladas[fila]}', // la acumulada
          '${total - frecuencia}', // el resto
        ],
        relleno: frecuenciaVecina,
      );
      return ProblemaEso(
        idHabilidad: 'EST.07',
        enunciado:
            'La tabla da las frecuencias relativas de {n} datos. ¿Cuál es la frecuencia absoluta del dato {v}?',
        datos: {'n': '$total', 'v': '${datoPrimero + fila}'},
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
        visual: VisualTabla(cabecera: const [
          'Dato',
          'hi'
        ], filas: [
          for (var i = 0; i < numeroFilas; i++)
            ['${datoPrimero + i}', formatearDecimal(frecuencias[i] / total)],
        ]),
      );
  }
}

// ---------------------------------------------------------------- EST.08

/// [cuantos] datos distintos entre [minimo] y [maximo], ordenados.
List<int> _valoresDistintos(
    math.Random azar, int cuantos, int minimo, int maximo) {
  final valores = <int>{};
  while (valores.length < cuantos) {
    valores.add(_entre(azar, minimo, maximo));
  }
  return valores.toList()..sort();
}

VisualTabla _tablaDatos(
        String cabecera, List<int> valores, List<int> frecuencias) =>
    VisualTabla(cabecera: [
      cabecera,
      'fi'
    ], filas: [
      for (var i = 0; i < valores.length; i++)
        ['${valores[i]}', '${frecuencias[i]}'],
    ]);

String _decimal(num valor) => formatearDecimal(valor, decimales: 2);

int _sumaProductos(List<int> valores, List<int> frecuencias) {
  var suma = 0;
  for (var i = 0; i < valores.length; i++) {
    suma += valores[i] * frecuencias[i];
  }
  return suma;
}

int _suma(List<int> numeros) => numeros.fold(0, (suma, n) => suma + n);

ProblemaEso _parametrosTabla(math.Random azar, int dificultad) {
  final numeroFilas = dificultad <= 2 ? 3 : (dificultad <= 5 ? 4 : 5);
  final frecuenciaMaxima = dificultad <= 2 ? 5 : 8;
  final modelos = [
    'media',
    'rango',
    'moda',
    if (dificultad >= 3) 'mediana',
    if (dificultad >= 3) 'media',
  ];
  final modelo = modelos[azar.nextInt(modelos.length)];
  List<int> frecuenciasAlAzar() =>
      [for (var i = 0; i < numeroFilas; i++) _entre(azar, 1, frecuenciaMaxima)];

  switch (modelo) {
    case 'media':
      // Notas de 2 a 10; la media sale entera (fácil) o con un decimal, y
      // distinta de la media sin ponderar.
      var valores = <int>[];
      var frecuencias = <int>[];
      var encontrada = false;
      for (var intento = 0; intento < 400 && !encontrada; intento++) {
        valores = _valoresDistintos(azar, numeroFilas, 2, 10);
        frecuencias = frecuenciasAlAzar();
        final total = _suma(frecuencias);
        final sumaProductos = _sumaProductos(valores, frecuencias);
        final exacta = dificultad <= 2
            ? sumaProductos % total == 0
            : (sumaProductos * 10) % total == 0;
        final distinta = sumaProductos * numeroFilas != _suma(valores) * total;
        encontrada = exacta && distinta;
      }
      if (!encontrada) {
        valores = [2, 6, 8];
        frecuencias = [1, 1, 2];
      }
      final total = _suma(frecuencias);
      final sumaProductos = _sumaProductos(valores, frecuencias);
      final media = sumaProductos / total;
      final elegidas = opcionesConErrores(
        azar,
        _decimal(media),
        [
          _decimal(_suma(valores) / valores.length), // sin ponderar
          _decimal(sumaProductos / valores.length), // entre el nº de filas
          '$sumaProductos', // sin dividir
        ],
        relleno: (n) => _decimal(media + (n.isOdd ? n : -n) * 0.5),
      );
      return ProblemaEso(
        idHabilidad: 'EST.08',
        enunciado:
            'La tabla recoge las notas de un examen. ¿Cuál es la nota media?',
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
        visual: _tablaDatos('Nota', valores, frecuencias),
      );
    case 'rango':
      // Edades de 10 a 30 (o 60): el rango es de los datos, no de las fi.
      final valores =
          _valoresDistintos(azar, numeroFilas, 10, dificultad <= 2 ? 30 : 60);
      final frecuencias = frecuenciasAlAzar();
      final rango = valores.last - valores.first;
      final elegidas = opcionesConErrores(
        azar,
        '$rango',
        [
          // el rango de las frecuencias
          '${frecuencias.reduce(math.max) - frecuencias.reduce(math.min)}',
          '${valores.last}', // sólo el mayor
          '${valores.last + valores.first}', // suma en vez de resta
        ],
        relleno: (n) => '${rango + (n.isOdd ? n : -n)}',
      );
      return ProblemaEso(
        idHabilidad: 'EST.08',
        enunciado:
            'La tabla recoge la edad de las personas de un grupo de teatro de Canales. ¿Cuál es el rango (recorrido) de las edades?',
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
        visual: _tablaDatos('Edad', valores, frecuencias),
      );
    case 'moda':
      // Tallas de calzado; una sola frecuencia máxima.
      final valores = _valoresDistintos(azar, numeroFilas, 34, 45);
      final frecuenciasPrevias = frecuenciasAlAzar();
      final filaModa = azar.nextInt(numeroFilas);
      final maximaResto = [
        for (var i = 0; i < numeroFilas; i++)
          if (i != filaModa) frecuenciasPrevias[i]
      ].reduce(math.max);
      final frecuencias = [
        for (var i = 0; i < numeroFilas; i++)
          i == filaModa
              ? maximaResto + _entre(azar, 1, 3)
              : frecuenciasPrevias[i]
      ];
      final moda = valores[filaModa];
      final elegidas = opcionesConErrores(
        azar,
        '$moda',
        [
          '${frecuencias[filaModa]}', // la frecuencia, no el dato
          '${valores[numeroFilas ~/ 2]}', // el de en medio
          '${valores.last}', // el mayor
          '${valores.first}',
        ],
        relleno: (n) => '${moda + n}',
      );
      return ProblemaEso(
        idHabilidad: 'EST.08',
        enunciado:
            'La tabla recoge la talla de calzado de las personas de un equipo. ¿Cuál es la moda?',
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
        visual: _tablaDatos('Talla', valores, frecuencias),
      );
    default:
      // Mascotas por familia (0, 1, 2…). Total impar hasta dificultad 5;
      // en 6-7 puede ser par (media de los dos centrales).
      final valores = [for (var i = 0; i < numeroFilas; i++) i];
      final frecuencias = frecuenciasAlAzar();
      if (dificultad < 6 && _suma(frecuencias).isEven) {
        frecuencias[azar.nextInt(numeroFilas)] += 1;
      }
      final total = _suma(frecuencias);
      final datosOrdenados = [
        for (var i = 0; i < numeroFilas; i++)
          for (var veces = 0; veces < frecuencias[i]; veces++) valores[i]
      ];
      final num mediana = total.isOdd
          ? datosOrdenados[total ~/ 2]
          : (datosOrdenados[total ~/ 2 - 1] + datosOrdenados[total ~/ 2]) / 2;
      final num centroSinPonderar = numeroFilas.isOdd
          ? valores[numeroFilas ~/ 2]
          : (valores[numeroFilas ~/ 2 - 1] + valores[numeroFilas ~/ 2]) / 2;
      final moda = valores[frecuencias.indexOf(frecuencias.reduce(math.max))];
      final elegidas = opcionesConErrores(
        azar,
        _decimal(mediana),
        [
          _decimal(centroSinPonderar), // el centro de la columna de datos
          _decimal((total + 1) / 2), // la posición en vez del dato
          _decimal(moda),
          _decimal(frecuencias[numeroFilas ~/ 2]),
        ],
        relleno: (n) => _decimal(mediana + n),
      );
      return ProblemaEso(
        idHabilidad: 'EST.08',
        enunciado:
            'La tabla recoge cuántas mascotas tienen varias familias de Montaña. ¿Cuál es la mediana?',
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
        visual: _tablaDatos('Mascotas', valores, frecuencias),
      );
  }
}

// ---------------------------------------------------------------- EST.09

/// Una etiqueta de rama: suceso y probabilidad (`B 3/5`).
String _rama(String suceso, int numerador, int denominador) =>
    '$suceso ${_fraccion(numerador, denominador)}';

ProblemaEso _probabilidadCompuesta(math.Random azar, int dificultad) {
  final modelos = [
    'monedas',
    'dadoMoneda',
    'conReemplazamiento',
    if (dificultad >= 3) 'sinReemplazamiento',
    if (dificultad >= 5) 'sinReemplazamiento',
  ];
  final modelo = modelos[azar.nextInt(modelos.length)];
  const ramasMoneda = ['C 1/2', 'X 1/2'];

  switch (modelo) {
    case 'monedas':
      final preguntas = [
        'dosCaras',
        'caraYCruz',
        if (dificultad >= 2) 'alMenosUna',
      ];
      final pregunta = preguntas[azar.nextInt(preguntas.length)];
      final (enunciado, buena, errores) = switch (pregunta) {
        'dosCaras' => (
            'Se lanzan dos monedas (C = cara, X = cruz). ¿Cuál es la probabilidad de sacar dos caras?',
            '1/4',
            ['1', '1/2', '1/3'], // sumar; una sola moneda; 3 casos iguales
          ),
        'caraYCruz' => (
            'Se lanzan dos monedas (C = cara, X = cruz). ¿Cuál es la probabilidad de sacar una cara y una cruz?',
            '1/2',
            ['1/4', '1/3', '1'], // un solo orden; 3 casos iguales; sumar
          ),
        _ => (
            'Se lanzan dos monedas (C = cara, X = cruz). ¿Cuál es la probabilidad de sacar al menos una cara?',
            '3/4',
            ['1/2', '1/4', '2/3'], // una moneda; sólo CC; 3 casos iguales
          ),
      };
      final elegidas = opcionesConErrores(azar, buena, errores,
          relleno: (n) => '1/${n + 4}');
      return ProblemaEso(
        idHabilidad: 'EST.09',
        enunciado: enunciado,
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
        visual: const VisualArbol(
            primeras: ramasMoneda, segundas: [ramasMoneda, ramasMoneda]),
      );
    case 'dadoMoneda':
      final preguntas = [
        'numero',
        if (dificultad >= 2) 'mayorQue',
        if (dificultad >= 4) 'par',
      ];
      final pregunta = preguntas[azar.nextInt(preguntas.length)];
      final String enunciado;
      final Map<String, String> datos;
      final int favorablesDado;
      final List<String> ramasDado;
      switch (pregunta) {
        case 'numero':
          final numero = _entre(azar, 1, 6);
          enunciado =
              'Se lanzan un dado y una moneda (C = cara, X = cruz). ¿Cuál es la probabilidad de sacar un {d} en el dado y cara en la moneda?';
          datos = {'d': '$numero'};
          favorablesDado = 1;
          ramasDado = ['$numero 1/6', '≠$numero 5/6'];
        case 'mayorQue':
          final limite = _entre(azar, 2, 4);
          enunciado =
              'Se lanzan un dado y una moneda (C = cara, X = cruz). ¿Cuál es la probabilidad de sacar en el dado un número mayor que {d} y cruz en la moneda?';
          datos = {'d': '$limite'};
          favorablesDado = 6 - limite;
          ramasDado = [
            _rama('>$limite', 6 - limite, 6),
            _rama('≤$limite', limite, 6),
          ];
        default:
          enunciado =
              'Se lanzan un dado y una moneda (C = cara, X = cruz). ¿Cuál es la probabilidad de sacar en el dado un número par y cara en la moneda?';
          datos = const {};
          favorablesDado = 3;
          ramasDado = ['2, 4, 6 1/2', '1, 3, 5 1/2'];
      }
      // P = favorables/6 · 1/2. Sumar daría favorables/6 + 1/2.
      final elegidas = opcionesConErrores(
        azar,
        _fraccion(favorablesDado, 12),
        [
          if (favorablesDado + 3 <= 6) _fraccion(favorablesDado + 3, 6),
          _fraccion(favorablesDado, 6), // olvida la moneda
          _fraccion(favorablesDado, 8), // casos 6 + 2 en vez de 6 · 2
          if (pregunta == 'mayorQue')
            _fraccion(favorablesDado + 1, 12), // cuenta el propio número
        ],
        relleno: (n) => _fraccion(1, 12 + 2 * n),
      );
      return ProblemaEso(
        idHabilidad: 'EST.09',
        enunciado: enunciado,
        datos: datos,
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
        visual: VisualArbol(
            primeras: ramasDado, segundas: [ramasMoneda, ramasMoneda]),
      );
    case 'conReemplazamiento':
      final maximo = dificultad <= 2 ? 4 : 6;
      final blancas = _entre(azar, 2, maximo);
      final negras = _entre(azar, 2, maximo);
      final total = blancas + negras;
      final dosBlancas = dificultad < 2 || azar.nextBool();
      // Bolas buenas en la segunda extracción: blancas o negras.
      final favorablesSegunda = dosBlancas ? blancas : negras;
      final numerador = blancas * favorablesSegunda;
      final ramas = [_rama('B', blancas, total), _rama('N', negras, total)];
      final elegidas = opcionesConErrores(
        azar,
        _fraccion(numerador, total * total),
        [
          if (blancas + favorablesSegunda <= total)
            _fraccion(blancas + favorablesSegunda, total), // sumar
          // como si la bola no se devolviera
          _fraccion(blancas * (favorablesSegunda - (dosBlancas ? 1 : 0)),
              total * (total - 1)),
          _fraccion(blancas, total), // sólo la primera extracción
          _fraccion(favorablesSegunda, total),
        ],
        relleno: (n) => _fraccion(numerador + n, total * total),
      );
      return ProblemaEso(
        idHabilidad: 'EST.09',
        enunciado: dosBlancas
            ? 'En una bolsa hay {b} bolas blancas (B) y {n} negras (N). Se saca una bola, se devuelve a la bolsa y se saca otra. ¿Cuál es la probabilidad de que las dos sean blancas?'
            : 'En una bolsa hay {b} bolas blancas (B) y {n} negras (N). Se saca una bola, se devuelve a la bolsa y se saca otra. ¿Cuál es la probabilidad de que la primera sea blanca y la segunda negra?',
        datos: {'b': '$blancas', 'n': '$negras'},
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
        visual: VisualArbol(primeras: ramas, segundas: [ramas, ramas]),
      );
    default:
      // Sin reemplazamiento: en el segundo paso hay una bola menos.
      final maximo = dificultad <= 4 ? 4 : 6;
      final blancas = _entre(azar, 2, maximo);
      final negras = _entre(azar, 2, maximo);
      final total = blancas + negras;
      final casosSin = total * (total - 1);
      final preguntas = [
        'dosBlancas',
        'blancaNegra',
        if (dificultad >= 6) 'unaDeCada',
      ];
      final pregunta = preguntas[azar.nextInt(preguntas.length)];
      final String enunciado;
      final int numerador;
      final List<String> errores;
      switch (pregunta) {
        case 'dosBlancas':
          enunciado =
              'En una bolsa hay {b} bolas blancas (B) y {n} negras (N). Se sacan dos bolas, una detrás de otra, sin devolver la primera. ¿Cuál es la probabilidad de que las dos sean blancas?';
          numerador = blancas * (blancas - 1);
          errores = [
            _fraccion(blancas * blancas, total * total), // no quita la bola
            _fraccion(numerador, total * total), // quita la bola a medias
            if (2 * blancas - 1 <= total)
              _fraccion(2 * blancas - 1, total), // sumar
            _fraccion(blancas, total),
          ];
        case 'blancaNegra':
          enunciado =
              'En una bolsa hay {b} bolas blancas (B) y {n} negras (N). Se sacan dos bolas, una detrás de otra, sin devolver la primera. ¿Cuál es la probabilidad de que la primera sea blanca y la segunda negra?';
          numerador = blancas * negras;
          errores = [
            _fraccion(numerador, total * total), // no quita la bola
            _fraccion(blancas * (negras - 1), casosSin), // quita una negra
            _fraccion(2 * numerador, casosSin), // los dos órdenes
            _fraccion(negras, total - 1),
          ];
        default:
          enunciado =
              'En una bolsa hay {b} bolas blancas (B) y {n} negras (N). Se sacan dos bolas, una detrás de otra, sin devolver la primera. ¿Cuál es la probabilidad de sacar una de cada color?';
          numerador = 2 * blancas * negras;
          errores = [
            _fraccion(blancas * negras, casosSin), // un solo orden
            _fraccion(numerador, total * total), // no quita la bola
            _fraccion(blancas * negras, total * total),
          ];
      }
      // El árbol completo en los niveles bajos; después, las segundas
      // ramas con «?» para que se calculen.
      final mostrarSegundas = dificultad <= 4;
      String segunda(String suceso, int bolas) =>
          mostrarSegundas ? _rama(suceso, bolas, total - 1) : '$suceso ?';
      final elegidas = opcionesConErrores(
        azar,
        _fraccion(numerador, casosSin),
        errores,
        relleno: (n) => _fraccion(numerador + n, casosSin),
      );
      return ProblemaEso(
        idHabilidad: 'EST.09',
        enunciado: enunciado,
        datos: {'b': '$blancas', 'n': '$negras'},
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
        visual: VisualArbol(primeras: [
          _rama('B', blancas, total),
          _rama('N', negras, total)
        ], segundas: [
          [segunda('B', blancas - 1), segunda('N', negras)],
          [segunda('B', blancas), segunda('N', negras - 1)],
        ]),
      );
  }
}
