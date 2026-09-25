import 'dart:math' as math;

import 'problema_eso.dart';

/// Fichas de funciones de 1.º y 2.º de ESO: coordenadas cartesianas,
/// lectura de gráficas y función lineal y afín.
final List<FichaProblemaEso> fichasFuncionesEso = [
  FichaProblemaEso(
    idHabilidad: 'FUN.02',
    generar: _coordenadasCartesianas,
    etiquetaTejado: '(x, y)',
    tituloAyuda: 'COORDENADAS CARTESIANAS',
    textoAyuda:
        'Un punto se escribe (x, y): primero lo que avanza en horizontal y después lo que '
        'sube o baja. (3, −2) está 3 a la derecha y 2 abajo, en el cuarto cuadrante. El '
        'simétrico respecto al eje x cambia el signo de la y: (3, 2).',
    transferencia:
        'En la vida: en un mapa, una casilla como «C4» funciona igual: primero la columna y después la fila.',
    preguntaTutor:
        'leer o escribir las coordenadas de un punto, su cuadrante o su simétrico',
    errorTipico:
        'cambiar el orden de las coordenadas (escribir (y, x)) o equivocarse con el signo',
    dificultadEstimada: 1.3,
    esquirlas: 4,
  ),
  FichaProblemaEso(
    idHabilidad: 'FUN.03',
    generar: _leerGrafica,
    etiquetaTejado: '╱‾╲',
    tituloAyuda: 'LEER UNA GRÁFICA',
    textoAyuda:
        'Primero mira qué hay en cada eje y en qué unidades. Un tramo horizontal significa '
        'que la distancia no cambia: no se mueve. Para saber cuánto recorre en un tramo, '
        'resta la distancia del final menos la del principio: de 2 km a 5 km son 3 km.',
    transferencia:
        'En la vida: la aplicación del móvil que registra tus paseos dibuja justo esta gráfica.',
    preguntaTutor:
        'interpretar una gráfica de distancia frente al tiempo (máximo, paradas, tramos)',
    errorTipico:
        'leer el valor de un punto en vez de la diferencia entre dos, o confundir los ejes',
    dificultadEstimada: 1.4,
    esquirlas: 4,
  ),
  FichaProblemaEso(
    idHabilidad: 'FUN.04',
    generar: _funcionLinealAfin,
    etiquetaTejado: 'mx+n',
    tituloAyuda: 'FUNCIÓN LINEAL Y AFÍN',
    textoAyuda:
        'La recta y = mx + n tiene pendiente m (lo que sube y cuando x avanza 1) y ordenada '
        'en el origen n (donde corta al eje y). Si pasa por (0, 1) y (1, 3), sube 2 por cada '
        'paso: y = 2x + 1. Si n = 0 pasa por el origen y es lineal.',
    transferencia:
        'En la vida: una tarifa de taxi con 3 € de bajada de bandera y 1 € por kilómetro es y = x + 3.',
    preguntaTutor:
        'hallar la pendiente, la ordenada en el origen o la ecuación de una recta',
    errorTipico:
        'confundir la pendiente con la ordenada en el origen, o calcular la pendiente al revés (x entre y)',
    dificultadEstimada: 1.8,
    esquirlas: 5,
  ),
];

/// Traducciones de los textos de estas fichas: castellano → [euskera,
/// catalán]. Borrador pendiente de revisión nativa.
const Map<String, List<String>> traduccionesFuncionesEso = {
  // FUN.02
  'COORDENADAS CARTESIANAS': [
    'KOORDENATU KARTESIARRAK',
    'COORDENADES CARTESIANES'
  ],
  'Un punto se escribe (x, y): primero lo que avanza en horizontal y después lo que sube o baja. (3, −2) está 3 a la derecha y 2 abajo, en el cuarto cuadrante. El simétrico respecto al eje x cambia el signo de la y: (3, 2).':
      [
    'Puntu bat (x, y) idazten da: lehenik horizontalean aurreratzen duena eta gero gora edo behera egiten duena. (3, −2) 3 eskuinera eta 2 behera dago, laugarren koadrantean. X ardatzarekiko simetrikoak y-ren zeinua aldatzen du: (3, 2).',
    'Un punt s\'escriu (x, y): primer el que avança en horitzontal i després el que puja o baixa. (3, −2) és 3 a la dreta i 2 avall, al quart quadrant. El simètric respecte a l\'eix x canvia el signe de la y: (3, 2).',
  ],
  'En la vida: en un mapa, una casilla como «C4» funciona igual: primero la columna y después la fila.':
      [
    'Bizitzan: mapa batean, «C4» bezalako lauki batek berdin funtzionatzen du: lehenik zutabea eta gero errenkada.',
    'A la vida: en un mapa, una casella com «C4» funciona igual: primer la columna i després la fila.',
  ],
  '¿Cuáles son las coordenadas del punto A?': [
    'Zein dira A puntuaren koordenatuak?',
    'Quines són les coordenades del punt A?'
  ],
  '¿En qué cuadrante está el punto A?': [
    'Zein koadrantetan dago A puntua?',
    'En quin quadrant és el punt A?'
  ],
  '¿En qué cuadrante está el punto {p}?': [
    'Zein koadrantetan dago puntu hau: {p}?',
    'En quin quadrant és el punt {p}?'
  ],
  '¿Cuáles son las coordenadas del simétrico de A respecto al eje x?': [
    'Zein dira A puntuaren simetrikoaren koordenatuak, x ardatzarekiko?',
    'Quines són les coordenades del simètric d\'A respecte a l\'eix x?'
  ],
  '¿Cuáles son las coordenadas del simétrico de A respecto al eje y?': [
    'Zein dira A puntuaren simetrikoaren koordenatuak, y ardatzarekiko?',
    'Quines són les coordenades del simètric d\'A respecte a l\'eix y?'
  ],
  '¿Cuáles son las coordenadas del simétrico de A respecto al origen?': [
    'Zein dira A puntuaren simetrikoaren koordenatuak, jatorriarekiko?',
    'Quines són les coordenades del simètric d\'A respecte a l\'origen?'
  ],
  '¿Qué punto tiene coordenadas {p}?': [
    'Zein puntuk ditu koordenatu hauek: {p}?',
    'Quin punt té coordenades {p}?'
  ],
  'Primer cuadrante': ['Lehen koadrantea', 'Primer quadrant'],
  'Segundo cuadrante': ['Bigarren koadrantea', 'Segon quadrant'],
  'Tercer cuadrante': ['Hirugarren koadrantea', 'Tercer quadrant'],
  'Cuarto cuadrante': ['Laugarren koadrantea', 'Quart quadrant'],
  // FUN.03
  'LEER UNA GRÁFICA': ['GRAFIKO BAT IRAKURRI', 'LLEGIR UN GRÀFIC'],
  'Primero mira qué hay en cada eje y en qué unidades. Un tramo horizontal significa que la distancia no cambia: no se mueve. Para saber cuánto recorre en un tramo, resta la distancia del final menos la del principio: de 2 km a 5 km son 3 km.':
      [
    'Lehenik begiratu zer dagoen ardatz bakoitzean eta zein unitatetan. Zati horizontal batek esan nahi du distantzia ez dela aldatzen: ez da mugitzen. Zati batean zenbat egiten duen jakiteko, kendu amaierako distantziari hasierakoa: 2 km-tik 5 km-ra 3 km dira.',
    'Primer mira què hi ha a cada eix i en quines unitats. Un tram horitzontal vol dir que la distància no canvia: no es mou. Per saber quant recorre en un tram, resta la distància del final menys la del principi: de 2 km a 5 km són 3 km.',
  ],
  'En la vida: la aplicación del móvil que registra tus paseos dibuja justo esta gráfica.':
      [
    'Bizitzan: zure ibilaldiak erregistratzen dituen mugikorreko aplikazioak grafiko hau bera marrazten du.',
    'A la vida: l\'aplicació del mòbil que registra les teves passejades dibuixa just aquest gràfic.',
  ],
  'La gráfica muestra la distancia a casa durante un paseo en bici. ¿A qué distancia máxima de casa llega?':
      [
    'Grafikoak etxerainoko distantzia erakusten du bizikleta-ibilaldi batean. Zein da etxetik iristen den distantzia handiena?',
    'El gràfic mostra la distància a casa durant una passejada en bici. A quina distància màxima de casa arriba?',
  ],
  'La gráfica muestra la distancia a casa durante un paseo en bici. ¿Cuántos minutos dura la parada?':
      [
    'Grafikoak etxerainoko distantzia erakusten du bizikleta-ibilaldi batean. Zenbat minutu irauten du geldialdiak?',
    'El gràfic mostra la distància a casa durant una passejada en bici. Quants minuts dura la parada?',
  ],
  'La gráfica muestra la distancia a casa durante un paseo en bici. ¿Cuántos kilómetros recorre entre el minuto {a} y el minuto {b}?':
      [
    'Grafikoak etxerainoko distantzia erakusten du bizikleta-ibilaldi batean. Zenbat kilometro egiten ditu minutu hauen artean: {a} eta {b}?',
    'El gràfic mostra la distància a casa durant una passejada en bici. Quants quilòmetres recorre entre el minut {a} i el minut {b}?',
  ],
  'La gráfica muestra la distancia a casa durante un paseo en bici. ¿Cuántos kilómetros recorre en total?':
      [
    'Grafikoak etxerainoko distantzia erakusten du bizikleta-ibilaldi batean. Zenbat kilometro egiten ditu guztira?',
    'El gràfic mostra la distància a casa durant una passejada en bici. Quants quilòmetres recorre en total?',
  ],
  'La gráfica muestra la distancia a casa durante una excursión en bici. ¿A qué velocidad va en el primer tramo?':
      [
    'Grafikoak etxerainoko distantzia erakusten du bizikleta-txango batean. Zer abiaduratan doa lehen zatian?',
    'El gràfic mostra la distància a casa durant una excursió en bici. A quina velocitat va en el primer tram?',
  ],
  'tiempo (min)': ['denbora (min)', 'temps (min)'],
  'tiempo (h)': ['denbora (h)', 'temps (h)'],
  'distancia (km)': ['distantzia (km)', 'distància (km)'],
  // FUN.04
  'FUNCIÓN LINEAL Y AFÍN': ['FUNTZIO LINEALA ETA AFINA', 'FUNCIÓ LINEAL I AFÍ'],
  'La recta y = mx + n tiene pendiente m (lo que sube y cuando x avanza 1) y ordenada en el origen n (donde corta al eje y). Si pasa por (0, 1) y (1, 3), sube 2 por cada paso: y = 2x + 1. Si n = 0 pasa por el origen y es lineal.':
      [
    'y = mx + n zuzenaren malda m da (x 1 aurreratzean y-k igotzen duena) eta jatorriko ordenatua n (y ardatza mozten duen tokia). (0, 1) eta (1, 3) puntuetatik igarotzen bada, urrats bakoitzeko 2 igotzen da: y = 2x + 1. n = 0 bada, jatorritik igarotzen da eta lineala da.',
    'La recta y = mx + n té pendent m (el que puja la y quan la x avança 1) i ordenada a l\'origen n (on talla l\'eix y). Si passa per (0, 1) i (1, 3), puja 2 per cada pas: y = 2x + 1. Si n = 0 passa per l\'origen i és lineal.',
  ],
  'En la vida: una tarifa de taxi con 3 € de bajada de bandera y 1 € por kilómetro es y = x + 3.':
      [
    'Bizitzan: taxi-tarifa bat, 3 € hasieran eta 1 € kilometro bakoitzeko, y = x + 3 da.',
    'A la vida: una tarifa de taxi amb 3 € de baixada de bandera i 1 € per quilòmetre és y = x + 3.',
  ],
  'En la función {f}, ¿cuánto vale y cuando x = {x}?': [
    'Funtzio honetan, {f}, zenbat balio du y-k x = {x} denean?',
    'En la funció {f}, quant val y quan x = {x}?'
  ],
  '¿Cuál es la pendiente de la recta del dibujo?': [
    'Zein da marrazkiko zuzenaren malda?',
    'Quin és el pendent de la recta del dibuix?'
  ],
  '¿En qué punto corta la recta del dibujo al eje y?': [
    'Zein puntutan mozten du marrazkiko zuzenak y ardatza?',
    'En quin punt talla la recta del dibuix l\'eix y?'
  ],
  '¿Cuál es la ecuación de la recta del dibujo?': [
    'Zein da marrazkiko zuzenaren ekuazioa?',
    'Quina és l\'equació de la recta del dibuix?'
  ],
  '¿Cuál es la ecuación de la recta que pasa por los puntos {p} y {q}?': [
    'Zein da puntu hauetatik igarotzen den zuzenaren ekuazioa: {p} eta {q}?',
    'Quina és l\'equació de la recta que passa pels punts {p} i {q}?'
  ],
};

int _entre(math.Random azar, int minimo, int maximo) =>
    minimo + azar.nextInt(maximo - minimo + 1);

T _elegir<T>(math.Random azar, List<T> lista) =>
    lista[azar.nextInt(lista.length)];

/// Un punto escrito como (3, −2).
String _punto(int x, int y) => '(${conSigno(x)}, ${conSigno(y)})';

/// FUN.02: leer coordenadas, cuadrante y simétricos. Errores: cambiar el
/// orden (y, x), cambiar el signo que no toca, cambiar los dos.
ProblemaEso _coordenadasCartesianas(math.Random azar, int dificultad) {
  final modelos = dificultad <= 2
      ? [0, 1]
      : dificultad <= 5
          ? [0, 1, 2, 3]
          : [1, 2, 3];
  final modelo = _elegir(azar, modelos);
  final maximo = dificultad <= 2 ? 4 : 5;
  int x, y;
  do {
    x = _entre(azar, -maximo, maximo);
    y = _entre(azar, -maximo, maximo);
  } while (x == 0 || y == 0 || x.abs() == y.abs());
  final dibujoConA = VisualPlano(puntos: [(x: x, y: y, etiqueta: 'A')]);

  switch (modelo) {
    case 1:
      // Cuadrante: con dibujo o, desde 3, a veces sólo con las coordenadas.
      const cuadrantes = [
        'Primer cuadrante',
        'Segundo cuadrante',
        'Tercer cuadrante',
        'Cuarto cuadrante'
      ];
      final indice = x > 0 ? (y > 0 ? 0 : 3) : (y > 0 ? 1 : 2);
      final sinDibujo = dificultad >= 3 && azar.nextBool();
      return ProblemaEso(
        idHabilidad: 'FUN.02',
        enunciado: sinDibujo
            ? '¿En qué cuadrante está el punto {p}?'
            : '¿En qué cuadrante está el punto A?',
        datos: sinDibujo ? {'p': _punto(x, y)} : const {},
        opciones: cuadrantes,
        indiceCorrecto: indice,
        visual: sinDibujo ? null : dibujoConA,
      );
    case 2:
      // Simétrico respecto a un eje (o al origen, desde 6).
      final respecto = _entre(azar, 0, dificultad >= 6 ? 2 : 1);
      final respectoX = _punto(x, -y);
      final respectoY = _punto(-x, y);
      final respectoOrigen = _punto(-x, -y);
      final buena = [respectoX, respectoY, respectoOrigen][respecto];
      final elegidas = opcionesConErrores(
        azar,
        buena,
        [respectoX, respectoY, respectoOrigen, _punto(y, x)]
            .where((opcion) => opcion != buena)
            .toList(),
        relleno: (n) => _punto(-y, -x - n),
      );
      return ProblemaEso(
        idHabilidad: 'FUN.02',
        enunciado: const [
          '¿Cuáles son las coordenadas del simétrico de A respecto al eje x?',
          '¿Cuáles son las coordenadas del simétrico de A respecto al eje y?',
          '¿Cuáles son las coordenadas del simétrico de A respecto al origen?',
        ][respecto],
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
        visual: dibujoConA,
      );
    case 3:
      // Se dan las coordenadas y se elige entre cuatro puntos dibujados:
      // el bueno, el de orden cambiado y los de un signo cambiado.
      final candidatos = [(x, y), (y, x), (-x, y), (x, -y)];
      final barajados = [...candidatos]..shuffle(azar);
      const letras = ['A', 'B', 'C', 'D'];
      return ProblemaEso(
        idHabilidad: 'FUN.02',
        enunciado: '¿Qué punto tiene coordenadas {p}?',
        datos: {'p': _punto(x, y)},
        opciones: letras,
        indiceCorrecto: barajados.indexOf((x, y)),
        visual: VisualPlano(puntos: [
          for (var i = 0; i < 4; i++)
            (x: barajados[i].$1, y: barajados[i].$2, etiqueta: letras[i])
        ]),
      );
    default:
      // Leer las coordenadas del punto dibujado.
      final elegidas = opcionesConErrores(
        azar,
        _punto(x, y),
        [_punto(y, x), _punto(-x, y), _punto(x, -y)],
        relleno: (n) => _punto(-x, -y - n + 1),
      );
      return ProblemaEso(
        idHabilidad: 'FUN.02',
        enunciado: '¿Cuáles son las coordenadas del punto A?',
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
        visual: dibujoConA,
      );
  }
}

/// FUN.03: una gráfica distancia-tiempo de un paseo (ida, parada,
/// vuelta). Errores: leer el valor en vez de la diferencia, leer el eje
/// equivocado, contar sólo la ida.
ProblemaEso _leerGrafica(math.Random azar, int dificultad) {
  final modelos = dificultad <= 2
      ? [0, 1, 2]
      : dificultad <= 5
          ? [0, 1, 2, 3]
          : [1, 2, 3, 4];
  final modelo = _elegir(azar, modelos);
  const introduccion =
      'La gráfica muestra la distancia a casa durante un paseo en bici.';

  if (modelo == 4) {
    // Velocidad media en el primer tramo, con el tiempo en horas.
    final velocidad = _elegir(azar, [10, 12, 15, 20]);
    final horasIda = _entre(azar, 1, 3);
    final distancia = velocidad * horasIda;
    final horasVuelta = _elegir(azar, [
      for (var horas = 1; horas <= 5; horas++)
        if (distancia % horas == 0 && distancia ~/ horas <= 25) horas
    ]);
    final finParada = horasIda + 1;
    final elegidas = opcionesConErrores(
      azar,
      '$velocidad km/h',
      [
        // No dividir entre el tiempo.
        '$distancia km/h',
        // La velocidad de la vuelta.
        '${distancia ~/ horasVuelta} km/h',
        // Dividir entre la hora final del paseo.
        if (distancia % (finParada + horasVuelta) == 0)
          '${distancia ~/ (finParada + horasVuelta)} km/h',
      ],
      relleno: (n) => '${velocidad + n * 5} km/h',
    );
    return ProblemaEso(
      idHabilidad: 'FUN.03',
      enunciado:
          'La gráfica muestra la distancia a casa durante una excursión en bici. ¿A qué velocidad va en el primer tramo?',
      opciones: elegidas.opciones,
      indiceCorrecto: elegidas.indiceCorrecto,
      visual: VisualGrafica(
        puntos: [
          (x: 0, y: 0),
          (x: horasIda, y: distancia),
          (x: finParada, y: distancia),
          (x: finParada + horasVuelta, y: 0),
        ],
        etiquetaX: 'tiempo (h)',
        etiquetaY: 'distancia (km)',
      ),
    );
  }

  // Ida, parada y (desde 3) un segundo tramo de ida antes de volver.
  final finIda = 10 * _entre(azar, 1, 3);
  final distanciaParada = _entre(azar, 2, 6);
  final minutosParada = 10 * _entre(azar, 1, 2);
  final finParada = finIda + minutosParada;
  final conSegundoTramo = dificultad >= 3;
  final puntos = <({int x, int y})>[
    (x: 0, y: 0),
    (x: finIda, y: distanciaParada),
    (x: finParada, y: distanciaParada),
  ];
  if (conSegundoTramo) {
    puntos.add((
      x: finParada + 10 * _entre(azar, 1, 3),
      y: distanciaParada + _entre(azar, 1, 4)
    ));
  }
  puntos.add((x: puntos.last.x + 10 * _entre(azar, 2, 4), y: 0));
  final distanciaMaxima = puntos.map((punto) => punto.y).reduce(math.max);
  final minutoMaximo =
      puntos.firstWhere((punto) => punto.y == distanciaMaxima).x;
  final minutoFinal = puntos.last.x;
  final grafica = VisualGrafica(
    puntos: [for (final punto in puntos) (x: punto.x, y: punto.y)],
    etiquetaX: 'tiempo (min)',
    etiquetaY: 'distancia (km)',
  );

  final String pregunta;
  final String buena;
  final List<String> errores;
  final Map<String, String> datos;
  switch (modelo) {
    case 1:
      pregunta = '¿Cuántos minutos dura la parada?';
      buena = '$minutosParada min';
      // Leer el minuto en que empieza o acaba la parada, o la distancia.
      errores = ['$finIda min', '$finParada min', '$distanciaParada min'];
      datos = const {};
    case 2:
      // Un tramo en movimiento (distancias distintas en sus extremos).
      final tramos = [
        for (var i = 0; i + 1 < puntos.length; i++)
          if (puntos[i].y != puntos[i + 1].y) i
      ];
      final tramo = _elegir(azar, tramos);
      final inicio = puntos[tramo];
      final fin = puntos[tramo + 1];
      pregunta =
          '¿Cuántos kilómetros recorre entre el minuto {a} y el minuto {b}?';
      buena = '${(fin.y - inicio.y).abs()} km';
      errores = [
        // Leer el valor final en vez de la diferencia.
        '${fin.y} km',
        '${inicio.y} km',
        // Sumar las dos lecturas.
        '${inicio.y + fin.y} km',
        // Leer el eje del tiempo.
        '${fin.x - inicio.x} km',
      ];
      datos = {'a': '${inicio.x}', 'b': '${fin.x}'};
    case 3:
      pregunta = '¿Cuántos kilómetros recorre en total?';
      buena = '${2 * distanciaMaxima} km';
      errores = [
        // Contar sólo la ida.
        '$distanciaMaxima km',
        // Sumar las distancias rotuladas.
        '${distanciaParada + distanciaMaxima} km',
        '${distanciaMaxima + distanciaParada * 2} km',
      ];
      datos = const {};
    default:
      pregunta = '¿A qué distancia máxima de casa llega?';
      buena = '$distanciaMaxima km';
      errores = [
        // Leer el eje del tiempo.
        '$minutoMaximo km',
        // Ida y vuelta.
        '${2 * distanciaMaxima} km',
        if (conSegundoTramo) '$distanciaParada km',
        '$minutoFinal km',
      ];
      datos = const {};
  }
  final numeroBuena = int.parse(buena.split(' ').first);
  final unidad = buena.split(' ').last;
  final elegidas = opcionesConErrores(azar, buena, errores,
      relleno: (n) => '${numeroBuena + n} $unidad');
  return ProblemaEso(
    idHabilidad: 'FUN.03',
    enunciado: '$introduccion $pregunta',
    datos: datos,
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: grafica,
  );
}

/// Una fracción con signo tipográfico (−3/2); entera si el denominador
/// es 1.
String _fraccion(int numerador, int denominador) {
  if (denominador < 0) return _fraccion(-numerador, -denominador);
  if (denominador == 1) return conSigno(numerador);
  return '${numerador < 0 ? '−' : ''}${numerador.abs()}/$denominador';
}

/// La ecuación y = (numerador/denominador)·x + ordenada escrita como en
/// clase: y = 2x − 1, y = −x, y = x/2 + 3, y = 4.
String _ecuacion(int numerador, int denominador, int ordenada) {
  if (denominador < 0) return _ecuacion(-numerador, -denominador, ordenada);
  final String termino;
  if (numerador == 0) {
    termino = '';
  } else {
    final coeficiente = numerador == 1
        ? ''
        : numerador == -1
            ? '−'
            : conSigno(numerador);
    termino =
        denominador == 1 ? '${coeficiente}x' : '${coeficiente}x/$denominador';
  }
  if (termino.isEmpty) return 'y = ${conSigno(ordenada)}';
  if (ordenada == 0) return 'y = $termino';
  return 'y = $termino ${ordenada < 0 ? '−' : '+'} ${ordenada.abs()}';
}

/// FUN.04: pendiente, ordenada en el origen y ecuación de la recta.
/// Errores: intercambiar pendiente y ordenada, pendiente al revés (x
/// entre y), signos, tomar la y de un punto como ordenada.
ProblemaEso _funcionLinealAfin(math.Random azar, int dificultad) {
  final modelos = dificultad <= 2
      ? [0, 0, 1]
      : dificultad <= 5
          ? [0, 1, 2]
          : [1, 2, 3];
  final modelo = _elegir(azar, modelos);

  if (modelo == 0) {
    // Valor de y para un x dado.
    int pendiente;
    do {
      pendiente = _entre(azar, -4, 4);
    } while (pendiente == 0);
    final ordenada = _entre(azar, dificultad <= 1 ? 0 : -6, 6);
    final valorX = _entre(azar, dificultad <= 1 ? 1 : -4, 5);
    final valorY = pendiente * valorX + ordenada;
    final elegidas = opcionesConErrores(
      azar,
      conSigno(valorY),
      [
        // Cambiar el signo de la ordenada.
        conSigno(pendiente * valorX - ordenada),
        // Sumar en vez de multiplicar.
        conSigno(pendiente + valorX + ordenada),
        // Multiplicar también la ordenada.
        conSigno(pendiente * (valorX + ordenada)),
      ],
      relleno: (n) => conSigno(valorY + (n.isOdd ? n : -n)),
    );
    return ProblemaEso(
      idHabilidad: 'FUN.04',
      enunciado: 'En la función {f}, ¿cuánto vale y cuando x = {x}?',
      datos: {'f': _ecuacion(pendiente, 1, ordenada), 'x': conSigno(valorX)},
      opciones: elegidas.opciones,
      indiceCorrecto: elegidas.indiceCorrecto,
    );
  }

  if (modelo == 3) {
    // Recta por dos puntos (sin dibujo).
    int pendiente;
    do {
      pendiente = _entre(azar, -3, 3);
    } while (pendiente == 0);
    final ordenada = _entre(azar, -4, 4);
    final primeraX = _entre(azar, -3, 2);
    final segundaX = primeraX + _entre(azar, 1, 3);
    final primeraY = pendiente * primeraX + ordenada;
    final segundaY = pendiente * segundaX + ordenada;
    final elegidas = opcionesConErrores(
      azar,
      _ecuacion(pendiente, 1, ordenada),
      [
        // Pendiente al revés: Δx/Δy.
        _ecuacion(pendiente.sign, pendiente.abs(), ordenada),
        // Tomar la y del primer punto como ordenada.
        _ecuacion(pendiente, 1, primeraY),
        // Signo de la pendiente cambiado.
        _ecuacion(-pendiente, 1, ordenada),
        _ecuacion(pendiente, 1, -ordenada),
      ],
      relleno: (n) => _ecuacion(pendiente, 1, ordenada + n),
    );
    return ProblemaEso(
      idHabilidad: 'FUN.04',
      enunciado:
          '¿Cuál es la ecuación de la recta que pasa por los puntos {p} y {q}?',
      datos: {'p': _punto(primeraX, primeraY), 'q': _punto(segundaX, segundaY)},
      opciones: elegidas.opciones,
      indiceCorrecto: elegidas.indiceCorrecto,
    );
  }

  // Con dibujo: pendiente entera o, desde 6, a veces de media unidad.
  final mediaUnidad = dificultad >= 6 && azar.nextBool();
  final denominador = mediaUnidad ? 2 : 1;
  final numerador = mediaUnidad
      ? _elegir(azar, [-3, -1, 1, 3])
      : _elegir(azar, [-3, -2, -1, 1, 2, 3]);
  final ordenada = _entre(azar, -3, 3);
  final dibujo = VisualPlano(
    rectas: [(pendiente: numerador / denominador, ordenada: ordenada)],
    puntos: [
      (x: 0, y: ordenada, etiqueta: ''),
      (x: denominador, y: ordenada + numerador, etiqueta: ''),
    ],
  );

  if (modelo == 1) {
    final preguntaCorte = ordenada != 0 && azar.nextBool();
    if (preguntaCorte) {
      final elegidas = opcionesConErrores(
        azar,
        _punto(0, ordenada),
        [
          // Coordenadas al revés.
          _punto(ordenada, 0),
          // Signo cambiado.
          _punto(0, -ordenada),
          // Confundir con la pendiente.
          if (denominador == 1 && numerador != ordenada) _punto(0, numerador),
        ],
        relleno: (n) => _punto(0, ordenada + n),
      );
      return ProblemaEso(
        idHabilidad: 'FUN.04',
        enunciado: '¿En qué punto corta la recta del dibujo al eje y?',
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
        visual: dibujo,
      );
    }
    final elegidas = opcionesConErrores(
      azar,
      _fraccion(numerador, denominador),
      [
        // La ordenada en lugar de la pendiente.
        conSigno(ordenada),
        // Signo cambiado.
        _fraccion(-numerador, denominador),
        // Al revés: x entre y.
        _fraccion(denominador * numerador.sign, numerador.abs()),
      ],
      relleno: (n) => _fraccion(numerador + n * denominador, denominador),
    );
    return ProblemaEso(
      idHabilidad: 'FUN.04',
      enunciado: '¿Cuál es la pendiente de la recta del dibujo?',
      opciones: elegidas.opciones,
      indiceCorrecto: elegidas.indiceCorrecto,
      visual: dibujo,
    );
  }

  // Ecuación de la recta dibujada.
  final elegidas = opcionesConErrores(
    azar,
    _ecuacion(numerador, denominador, ordenada),
    [
      // Pendiente y ordenada intercambiadas.
      if (denominador == 1) _ecuacion(ordenada, 1, numerador),
      // Signo de la pendiente cambiado.
      _ecuacion(-numerador, denominador, ordenada),
      // Pendiente al revés.
      _ecuacion(denominador * numerador.sign, numerador.abs(), ordenada),
      // Signo de la ordenada cambiado.
      if (ordenada != 0) _ecuacion(numerador, denominador, -ordenada),
    ],
    relleno: (n) => _ecuacion(numerador, denominador, ordenada + n),
  );
  return ProblemaEso(
    idHabilidad: 'FUN.04',
    enunciado: '¿Cuál es la ecuación de la recta del dibujo?',
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: dibujo,
  );
}
