import 'dart:math' as math;

import 'problema_eso.dart';

/// Fichas de proporcionalidad de 1.º y 2.º de ESO: proporcionalidad
/// inversa, porcentajes encadenados y repartos proporcionales.
final List<FichaProblemaEso> fichasProporcionEso = [
  FichaProblemaEso(
    idHabilidad: 'PROP.08',
    generar: _proporcionalidadInversa,
    etiquetaTejado: '↑·↓',
    tituloAyuda: 'PROPORCIONALIDAD INVERSA',
    textoAyuda:
        'Si una magnitud se duplica y la otra se reduce a la mitad, son inversamente '
        'proporcionales: su producto no cambia. 4 personas tardan 6 días: el trabajo son '
        '4 · 6 = 24 días de persona; 8 personas tardan 24 : 8 = 3 días.',
    transferencia:
        'En la vida: cuanto más rápido vas, menos tardas; a doble velocidad, la mitad de tiempo.',
    preguntaTutor:
        'resolver un problema de proporcionalidad inversa (más personas, menos días)',
    errorTipico:
        'tratarla como directa: pensar que con más personas se tardan más días',
    dificultadEstimada: 1.4,
    esquirlas: 4,
  ),
  FichaProblemaEso(
    idHabilidad: 'PROP.09',
    generar: _porcentajesEncadenados,
    etiquetaTejado: '%·%',
    tituloAyuda: 'PORCENTAJES ENCADENADOS',
    textoAyuda:
        'Cada porcentaje se aplica sobre lo que queda después del anterior, así que se '
        'multiplican los índices: subir un 20 % es multiplicar por 1,2 y bajar un 20 %, por 0,8. '
        '100 € · 1,2 · 0,8 = 96 €: no se vuelve a 100 €.',
    transferencia:
        'En la vida: una rebaja del 20 % y otra del 10 % encima no son un 30 %, son un 28 %.',
    preguntaTutor:
        'aplicar dos porcentajes seguidos multiplicando los índices de variación',
    errorTipico:
        'sumar o restar los porcentajes: creer que subir un 20 % y bajar un 20 % deja igual',
    dificultadEstimada: 1.7,
    esquirlas: 5,
  ),
  FichaProblemaEso(
    idHabilidad: 'PROP.10',
    generar: _repartosProporcionales,
    etiquetaTejado: 'a:b:c',
    tituloAyuda: 'REPARTOS PROPORCIONALES',
    textoAyuda:
        'Directo: se suman las partes y se divide el total entre la suma; cada uno recibe su '
        'parte por ese valor. 600 € en proporción a 1 y 2: 600 : 3 = 200, reciben 200 € y 400 €. '
        'Inverso: se reparte en proporción a los inversos, y quien tiene más recibe menos.',
    transferencia:
        'En la vida: si dos personas ponen dinero en un negocio, las ganancias se reparten según lo que puso cada una.',
    preguntaTutor:
        'repartir una cantidad de forma directa o inversamente proporcional',
    errorTipico:
        'repartir a partes iguales, o hacer un reparto directo cuando es inverso',
    dificultadEstimada: 1.7,
    esquirlas: 5,
  ),
];

/// Traducciones de los textos de estas fichas: castellano → [euskera,
/// catalán]. Borrador pendiente de revisión nativa.
const Map<String, List<String>> traduccionesProporcionEso = {
  // PROP.08
  'PROPORCIONALIDAD INVERSA': [
    'ALDERANTZIZKO PROPORTZIONALTASUNA',
    'PROPORCIONALITAT INVERSA'
  ],
  'Si una magnitud se duplica y la otra se reduce a la mitad, son inversamente proporcionales: su producto no cambia. 4 personas tardan 6 días: el trabajo son 4 · 6 = 24 días de persona; 8 personas tardan 24 : 8 = 3 días.':
      [
    'Magnitude bat bikoiztean bestea erdira jaisten bada, alderantziz proportzionalak dira: haien biderkadura ez da aldatzen. 4 pertsonak 6 egun behar dituzte: lana 4 · 6 = 24 pertsona-egun da; 8 pertsonak 24 : 8 = 3 egun beharko dituzte.',
    'Si una magnitud es duplica i l\'altra es redueix a la meitat, són inversament proporcionals: el seu producte no canvia. 4 persones tarden 6 dies: la feina són 4 · 6 = 24 dies de persona; 8 persones tarden 24 : 8 = 3 dies.',
  ],
  'En la vida: cuanto más rápido vas, menos tardas; a doble velocidad, la mitad de tiempo.':
      [
    'Bizitzan: zenbat eta azkarrago joan, orduan eta denbora gutxiago; abiadura bikoitzean, denboraren erdia.',
    'A la vida: com més de pressa vas, menys tardes; al doble de velocitat, la meitat de temps.',
  ],
  '{a} personas tardan {b} días en pintar una nave del Puerto. ¿Cuántos días tardarían {c} personas al mismo ritmo?':
      [
    'Portuko nabe bat margotzeko, {a} pertsonak {b} egun behar dituzte. Erritmo berean, zenbat egun beharko lituzkete {c} pertsonak?',
    '{a} persones tarden {b} dies a pintar una nau del Port. Quants dies tardarien {c} persones al mateix ritme?',
  ],
  '{a} grifos iguales llenan un depósito de los Canales en {b} min. ¿Cuántos minutos tardan {c} grifos como esos?':
      [
    'Berdinak diren {a} txorrok Kanaletako biltegi bat betetzeko {b} min behar dituzte. Horrelako {c} txorrok zenbat minutu behar dituzte?',
    '{a} aixetes iguals omplen un dipòsit dels Canals en {b} min. Quants minuts tarden {c} aixetes com aquestes?',
  ],
  'A {v} km/h, un camión tarda {t} h en ir de la Industria a las Afueras. ¿Cuánto tardaría a {w} km/h?':
      [
    'Kamioi batek {t} h behar ditu Industriatik Kanpoaldera joateko, orduko {v} km eginez. Zenbat beharko luke orduko {w} km eginez?',
    'A {v} km/h, un camió tarda {t} h a anar de la Indústria als Afores. Quant tardaria a {w} km/h?',
  ],
  'Con {a} máquinas, un pedido se termina en {b} horas. ¿Cuántas máquinas hacen falta para terminarlo en {c} horas?':
      [
    '{a} makinarekin, eskaera bat {b} ordutan amaitzen da. Zenbat makina behar dira {c} ordutan amaitzeko?',
    'Amb {a} màquines, una comanda s\'acaba en {b} hores. Quantes màquines calen per acabar-la en {c} hores?',
  ],
  // PROP.09
  'PORCENTAJES ENCADENADOS': ['EHUNEKO KATEATUAK', 'PERCENTATGES ENCADENATS'],
  'Cada porcentaje se aplica sobre lo que queda después del anterior, así que se multiplican los índices: subir un 20 % es multiplicar por 1,2 y bajar un 20 %, por 0,8. 100 € · 1,2 · 0,8 = 96 €: no se vuelve a 100 €.':
      [
    'Ehuneko bakoitza aurrekoaren ondoren geratzen denari aplikatzen zaio; beraz, indizeak biderkatzen dira: % 20 igotzea 1,2rekin biderkatzea da, eta % 20 jaistea, 0,8rekin. 100 € · 1,2 · 0,8 = 96 €: ez da 100 eurora itzultzen.',
    'Cada percentatge s\'aplica sobre el que queda després de l\'anterior, així que es multipliquen els índexs: pujar un 20 % és multiplicar per 1,2 i baixar un 20 %, per 0,8. 100 € · 1,2 · 0,8 = 96 €: no es torna a 100 €.',
  ],
  'En la vida: una rebaja del 20 % y otra del 10 % encima no son un 30 %, son un 28 %.':
      [
    'Bizitzan: % 20ko beherapena eta horren gainean % 10ekoa ez dira % 30, % 28 baizik.',
    'A la vida: una rebaixa del 20 % i una altra del 10 % a sobre no són un 30 %, són un 28 %.',
  ],
  'Un abrigo cuesta {p}. Sube un {a} % y después baja un {b} %. ¿Cuánto cuesta ahora?':
      [
    'Beroki batek {p} balio du. % {a} igotzen da eta gero % {b} jaisten da. Zenbat balio du orain?',
    'Un abric costa {p}. Puja un {a} % i després baixa un {b} %. Quant costa ara?',
  ],
  'Un abrigo cuesta {p}. Tiene un descuento del {a} % y, sobre ese precio, otro del {b} %. ¿Cuánto cuesta ahora?':
      [
    'Beroki batek {p} balio du. % {a} deskontua du eta, prezio horren gainean, beste % {b}. Zenbat balio du orain?',
    'Un abric costa {p}. Té un descompte del {a} % i, sobre aquest preu, un altre del {b} %. Quant costa ara?',
  ],
  'Una cantidad sube un {a} % y luego baja un {b} %. ¿Por qué número queda multiplicada en total?':
      [
    'Kantitate bat % {a} igotzen da eta gero % {b} jaisten da. Guztira, zein zenbakirekin geratzen da biderkatuta?',
    'Una quantitat puja un {a} % i després baixa un {b} %. Per quin nombre queda multiplicada en total?',
  ],
  'Una tienda hace un descuento del {a} % y, sobre ese precio, otro del {b} %. ¿Qué descuento único equivale a los dos?':
      [
    'Denda batek % {a} deskontua egiten du eta, prezio horren gainean, beste % {b}. Zein deskontu bakar da bien baliokidea?',
    'Una botiga fa un descompte del {a} % i, sobre aquest preu, un altre del {b} %. Quin descompte únic equival als dos?',
  ],
  'Un precio sube un {a} % y después baja un {a} %. ¿Qué porcentaje ha bajado en total respecto al precio inicial?':
      [
    'Prezio bat % {a} igotzen da eta gero % {a} jaisten da. Hasierako prezioarekin alderatuta, zenbat jaitsi da guztira, ehunekotan?',
    'Un preu puja un {a} % i després baixa un {a} %. Quin percentatge ha baixat en total respecte al preu inicial?',
  ],
  'Un artículo sube un {a} % y después baja un {b} %. Ahora cuesta {f}. ¿Cuánto costaba al principio?':
      [
    'Artikulu bat % {a} igotzen da eta gero % {b} jaisten da. Orain {f} balio du. Zenbat balio zuen hasieran?',
    'Un article puja un {a} % i després baixa un {b} %. Ara costa {f}. Quant costava al principi?',
  ],
  // PROP.10
  'REPARTOS PROPORCIONALES': [
    'BANAKETA PROPORTZIONALAK',
    'REPARTIMENTS PROPORCIONALS'
  ],
  'Directo: se suman las partes y se divide el total entre la suma; cada uno recibe su parte por ese valor. 600 € en proporción a 1 y 2: 600 : 3 = 200, reciben 200 € y 400 €. Inverso: se reparte en proporción a los inversos, y quien tiene más recibe menos.':
      [
    'Zuzena: zatiak batu eta guztizkoa baturaz zatitzen da; bakoitzak bere zatia bider balio hori jasotzen du. 600 €, 1 eta 2ren proportzioan: 600 : 3 = 200, eta 200 € eta 400 € jasotzen dituzte. Alderantzizkoa: alderantzizkoen proportzioan banatzen da, eta gehiago duenak gutxiago jasotzen du.',
    'Directe: se sumen les parts i es divideix el total entre la suma; cadascú rep la seva part per aquest valor. 600 € en proporció a 1 i 2: 600 : 3 = 200, reben 200 € i 400 €. Invers: es reparteix en proporció als inversos, i qui té més rep menys.',
  ],
  'En la vida: si dos personas ponen dinero en un negocio, las ganancias se reparten según lo que puso cada una.':
      [
    'Bizitzan: bi pertsonak negozio batean dirua jartzen badute, irabaziak bakoitzak jarritakoaren arabera banatzen dira.',
    'A la vida: si dues persones posen diners en un negoci, els guanys es reparteixen segons el que va posar cadascuna.',
  ],
  'Dos socias ponen {a} € y {b} € en un puesto del Mercado. Ganan {t} € y lo reparten en proporción a lo que puso cada una. ¿Cuánto le toca a la que puso {a} €?':
      [
    'Bi bazkidek dirua jartzen dute Merkatuko postu batean: batek {a} € eta besteak {b} €. {t} € irabazten dituzte eta bakoitzak jarritakoaren proportzioan banatzen dute. Zenbat dagokio {a} € jarri zituenari?',
    'Dues sòcies posen {a} € i {b} € en una parada del Mercat. Guanyen {t} € i ho reparteixen en proporció al que va posar cadascuna. Quant li toca a la que va posar {a} €?',
  ],
  'Se reparten {t} € entre el Mercado, el Puerto y los Canales en proporción a sus habitantes: {a} mil, {b} mil y {c} mil. ¿Cuánto recibe el Mercado?':
      [
    '{t} € banatzen dira Merkatuaren, Portuaren eta Kanalen artean, biztanleen proportzioan: {a} mila, {b} mila eta {c} mila. Zenbat jasotzen du Merkatuak?',
    'Es reparteixen {t} € entre el Mercat, el Port i els Canals en proporció als seus habitants: {a} mil, {b} mil i {c} mil. Quant rep el Mercat?',
  ],
  'Un premio de {t} € se reparte entre dos equipos de forma inversamente proporcional al tiempo que tardaron: {a} min y {b} min. ¿Cuánto recibe el equipo que tardó {a} min?':
      [
    'Sari bat bi taldeen artean banatzen da, behar izan zuten denboraren alderantzizko proportzioan: {a} min eta {b} min. Saria {t} € da. Zenbat jasotzen du {a} min behar izan zituen taldeak?',
    'Un premi de {t} € es reparteix entre dos equips de manera inversament proporcional al temps que van tardar: {a} min i {b} min. Quant rep l\'equip que va tardar {a} min?',
  ],
  'Se reparten {t} € entre tres personas de forma inversamente proporcional a los días que faltaron: {a}, {b} y {c}. ¿Cuánto recibe la que faltó {a} días?':
      [
    '{t} € banatzen dira hiru pertsonaren artean, huts egin zituzten egunen alderantzizko proportzioan: {a}, {b} eta {c}. Zenbat jasotzen du {a} egunetan huts egin zuenak?',
    'Es reparteixen {t} € entre tres persones de manera inversament proporcional als dies que van faltar: {a}, {b} i {c}. Quant rep la que va faltar {a} dies?',
  ],
  'En un reparto proporcional a {a} y {b}, la primera parte recibe {x} €. ¿Cuánto se reparte en total?':
      [
    '{a} eta {b} zenbakien proportzioko banaketa batean, lehenengo zatiak {x} € jasotzen ditu. Zenbat banatzen da guztira?',
    'En un repartiment proporcional a {a} i {b}, la primera part rep {x} €. Quant es reparteix en total?',
  ],
};

int _entre(math.Random azar, int minimo, int maximo) =>
    minimo + azar.nextInt(maximo - minimo + 1);

T _elegir<T>(math.Random azar, List<T> lista) =>
    lista[azar.nextInt(lista.length)];

/// Un importe en euros: entero si no tiene céntimos, con dos decimales
/// si los tiene (86,40 €).
String _euros(num valor) {
  final centimos = (valor * 100).round();
  final signo = centimos < 0 ? '−' : '';
  final absolutos = centimos.abs();
  if (absolutos % 100 == 0) return '$signo${absolutos ~/ 100} €';
  final restoCentimos = (absolutos % 100).toString().padLeft(2, '0');
  return '$signo${absolutos ~/ 100},$restoCentimos €';
}

/// PROP.08: más personas (grifos, velocidad…), menos tiempo. El producto
/// de las dos magnitudes es constante. Errores: tratarla como directa,
/// como aditiva (quitar tantos días como personas se añaden) u olvidar
/// dividir.
ProblemaEso _proporcionalidadInversa(math.Random azar, int dificultad) {
  final modelos = dificultad <= 2
      ? [0, 1]
      : dificultad <= 5
          ? [0, 1, 2]
          : [0, 2, 3];
  final modelo = _elegir(azar, modelos);

  if (modelo == 2) {
    // Velocidad y tiempo: la distancia es fija.
    final velocidades = [30, 40, 60, 80, 90, 120];
    int velocidadInicial, horasIniciales, velocidadNueva;
    do {
      velocidadInicial = _elegir(azar, velocidades);
      horasIniciales = _entre(azar, 2, 6);
      velocidadNueva = _elegir(azar, velocidades);
    } while (velocidadNueva == velocidadInicial ||
        (velocidadInicial * horasIniciales) % velocidadNueva != 0 ||
        velocidadInicial * horasIniciales ~/ velocidadNueva > 12);
    final horasNuevas = velocidadInicial * horasIniciales ~/ velocidadNueva;
    final elegidas = opcionesConErrores(
      azar,
      '$horasNuevas h',
      [
        // Tratarla como directa.
        if ((horasIniciales * velocidadNueva) % velocidadInicial == 0)
          '${horasIniciales * velocidadNueva ~/ velocidadInicial} h',
        // Multiplicar sin dividir.
        '${horasIniciales * velocidadNueva} h',
        // Creer que el tiempo no cambia.
        '$horasIniciales h',
      ],
      relleno: (n) => '${horasNuevas + n} h',
    );
    return ProblemaEso(
      idHabilidad: 'PROP.08',
      enunciado:
          'A {v} km/h, un camión tarda {t} h en ir de la Industria a las Afueras. ¿Cuánto tardaría a {w} km/h?',
      datos: {
        'v': '$velocidadInicial',
        't': '$horasIniciales',
        'w': '$velocidadNueva'
      },
      opciones: elegidas.opciones,
      indiceCorrecto: elegidas.indiceCorrecto,
    );
  }

  // Cantidad × tiempo = constante; se eligen dos divisores distintos.
  final constantes = dificultad <= 2
      ? [12, 18, 24, 30]
      : dificultad <= 5
          ? [24, 36, 48, 60]
          : [48, 60, 72, 90, 120];
  final constante = _elegir(azar, constantes);
  final divisores = [
    for (var divisor = 2; divisor <= 12; divisor++)
      if (constante % divisor == 0 && constante ~/ divisor >= 2) divisor
  ];
  final cantidadInicial = _elegir(azar, divisores);
  int cantidadNueva;
  do {
    cantidadNueva = _elegir(azar, divisores);
  } while (cantidadNueva == cantidadInicial);
  final tiempoInicial = constante ~/ cantidadInicial;
  final tiempoNuevo = constante ~/ cantidadNueva;

  if (modelo == 3) {
    // Se pregunta la cantidad: cuántas máquinas para un tiempo dado.
    final elegidas = opcionesConErrores(
      azar,
      '$cantidadNueva',
      [
        if ((cantidadInicial * tiempoNuevo) % tiempoInicial == 0)
          '${cantidadInicial * tiempoNuevo ~/ tiempoInicial}',
        if (cantidadInicial - (tiempoNuevo - tiempoInicial) > 0)
          '${cantidadInicial - (tiempoNuevo - tiempoInicial)}',
        '${cantidadInicial * tiempoNuevo}',
      ],
      relleno: (n) => '${cantidadNueva + n}',
    );
    return ProblemaEso(
      idHabilidad: 'PROP.08',
      enunciado:
          'Con {a} máquinas, un pedido se termina en {b} horas. ¿Cuántas máquinas hacen falta para terminarlo en {c} horas?',
      datos: {
        'a': '$cantidadInicial',
        'b': '$tiempoInicial',
        'c': '$tiempoNuevo'
      },
      opciones: elegidas.opciones,
      indiceCorrecto: elegidas.indiceCorrecto,
    );
  }

  final unidad = modelo == 1 ? ' min' : '';
  String conUnidad(int valor) => '$valor$unidad';
  final elegidas = opcionesConErrores(
    azar,
    conUnidad(tiempoNuevo),
    [
      // Directa: b·c/a.
      if ((tiempoInicial * cantidadNueva) % cantidadInicial == 0)
        conUnidad(tiempoInicial * cantidadNueva ~/ cantidadInicial),
      // Aditiva: restar (o sumar) la diferencia.
      if (tiempoInicial - (cantidadNueva - cantidadInicial) > 0)
        conUnidad(tiempoInicial - (cantidadNueva - cantidadInicial)),
      // Multiplicar sin dividir.
      conUnidad(tiempoInicial * cantidadNueva),
      // Calcular el producto y no dividir entre la nueva cantidad.
      conUnidad(constante),
    ],
    relleno: (n) => conUnidad(tiempoNuevo + n),
  );
  return ProblemaEso(
    idHabilidad: 'PROP.08',
    enunciado: modelo == 1
        ? '{a} grifos iguales llenan un depósito de los Canales en {b} min. ¿Cuántos minutos tardan {c} grifos como esos?'
        : '{a} personas tardan {b} días en pintar una nave del Puerto. ¿Cuántos días tardarían {c} personas al mismo ritmo?',
    datos: {
      'a': '$cantidadInicial',
      'b': '$tiempoInicial',
      'c': '$cantidadNueva'
    },
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
  );
}

/// PROP.09: dos porcentajes seguidos se multiplican (índices de
/// variación), no se suman. Errores: sumar los porcentajes, creer que
/// subir y bajar lo mismo deja igual, multiplicar en vez de dividir al
/// ir hacia atrás.
ProblemaEso _porcentajesEncadenados(math.Random azar, int dificultad) {
  final modelos = dificultad <= 2
      ? [0, 3]
      : dificultad <= 5
          ? [0, 1, 2, 3]
          : [0, 1, 2, 4];
  final modelo = _elegir(azar, modelos);
  final paso = dificultad >= 6 ? 5 : 10;
  int porcentaje(int minimo, int maximo) =>
      _entre(azar, minimo ~/ paso, maximo ~/ paso) * paso;

  switch (modelo) {
    case 1:
      // Índice de variación total: (1 + a/100)·(1 − b/100).
      final subida = porcentaje(10, 50);
      final bajada = porcentaje(10, 50);
      final indice = (100 + subida) * (100 - bajada) / 10000;
      final elegidas = opcionesConErrores(
        azar,
        formatearDecimal(indice, decimales: 4),
        [
          // Sumar porcentajes.
          formatearDecimal(1 + (subida - bajada) / 100, decimales: 4),
          // Sumar los índices.
          formatearDecimal((200 + subida - bajada) / 100, decimales: 4),
          // Multiplicar los porcentajes, no los índices.
          formatearDecimal(subida * bajada / 10000, decimales: 4),
        ],
        relleno: (n) => formatearDecimal(indice + n * 0.05, decimales: 4),
      );
      return ProblemaEso(
        idHabilidad: 'PROP.09',
        enunciado:
            'Una cantidad sube un {a} % y luego baja un {b} %. ¿Por qué número queda multiplicada en total?',
        datos: {'a': '$subida', 'b': '$bajada'},
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
      );
    case 2:
      // Descuento único equivalente a dos descuentos seguidos.
      final primero = _entre(azar, 1, 5) * 10;
      final segundo = _entre(azar, 1, 5) * 10;
      final unico = 100 - (100 - primero) * (100 - segundo) ~/ 100;
      final elegidas = opcionesConErrores(
        azar,
        '$unico %',
        [
          '${primero + segundo} %',
          '${primero * segundo ~/ 100} %',
          '${(primero + segundo) ~/ 2} %',
        ],
        relleno: (n) => '${unico + (n.isOdd ? n : -n)} %',
      );
      return ProblemaEso(
        idHabilidad: 'PROP.09',
        enunciado:
            'Una tienda hace un descuento del {a} % y, sobre ese precio, otro del {b} %. ¿Qué descuento único equivale a los dos?',
        datos: {'a': '$primero', 'b': '$segundo'},
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
      );
    case 3:
      // Subir y bajar el mismo porcentaje: baja a²/100 %.
      final cambio = _entre(azar, 1, dificultad <= 2 ? 3 : 5) * 10;
      final bajadaTotal = cambio * cambio ~/ 100;
      final elegidas = opcionesConErrores(
        azar,
        '$bajadaTotal %',
        ['0 %', '$cambio %', '${2 * cambio} %'],
        relleno: (n) => '${bajadaTotal + n} %',
      );
      return ProblemaEso(
        idHabilidad: 'PROP.09',
        enunciado:
            'Un precio sube un {a} % y después baja un {a} %. ¿Qué porcentaje ha bajado en total respecto al precio inicial?',
        datos: {'a': '$cambio'},
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
      );
    case 4:
      // Hacia atrás: se conoce el precio final y se divide entre el índice.
      final subida = porcentaje(10, 50);
      final bajada = porcentaje(10, 40);
      final inicial = _entre(azar, 1, 5) * 100;
      final indice = (100 + subida) * (100 - bajada) / 10000;
      final precioFinal = inicial * indice;
      final elegidas = opcionesConErrores(
        azar,
        _euros(inicial),
        [
          // Multiplicar por el índice en lugar de dividir.
          _euros(precioFinal * indice),
          // Deshacer aplicando los porcentajes contrarios sobre el final.
          _euros(precioFinal * (100 - subida) * (100 + bajada) / 10000),
          // Deshacer restando la suma de porcentajes.
          _euros(precioFinal * (100 - subida + bajada) / 100),
        ],
        relleno: (n) => _euros(inicial + n * 10),
      );
      return ProblemaEso(
        idHabilidad: 'PROP.09',
        enunciado:
            'Un artículo sube un {a} % y después baja un {b} %. Ahora cuesta {f}. ¿Cuánto costaba al principio?',
        datos: {'a': '$subida', 'b': '$bajada', 'f': _euros(precioFinal)},
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
      );
    default:
      // Precio con dos cambios seguidos: sube y baja, o dos descuentos.
      final dosDescuentos = dificultad >= 3 && azar.nextBool();
      final primero = porcentaje(10, dosDescuentos ? 40 : 50);
      final segundo = porcentaje(10, 40);
      final inicial = _entre(azar, 1, dificultad <= 2 ? 3 : 8) * 100;
      final factorPrimero = dosDescuentos ? 100 - primero : 100 + primero;
      final precioFinal = inicial * factorPrimero * (100 - segundo) / 10000;
      final sumaPorcentajes = dosDescuentos
          ? inicial * (100 - primero - segundo) / 100
          : inicial * (100 + primero - segundo) / 100;
      final elegidas = opcionesConErrores(
        azar,
        _euros(precioFinal),
        [
          // Sumar (o restar) los porcentajes.
          _euros(sumaPorcentajes),
          // Quedarse con el primer cambio.
          _euros(inicial * factorPrimero / 100),
          // Aplicar el segundo porcentaje sobre el precio inicial.
          _euros(inicial * factorPrimero / 100 - inicial * segundo / 100),
        ],
        relleno: (n) => _euros(precioFinal + (n.isOdd ? n : -n) * 2),
      );
      return ProblemaEso(
        idHabilidad: 'PROP.09',
        enunciado: dosDescuentos
            ? 'Un abrigo cuesta {p}. Tiene un descuento del {a} % y, sobre ese precio, otro del {b} %. ¿Cuánto cuesta ahora?'
            : 'Un abrigo cuesta {p}. Sube un {a} % y después baja un {b} %. ¿Cuánto cuesta ahora?',
        datos: {'p': _euros(inicial), 'a': '$primero', 'b': '$segundo'},
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
      );
  }
}

/// PROP.10: repartos directos (se divide entre la suma de las partes) e
/// inversos (en proporción a los inversos). Errores: repartir a partes
/// iguales, dar la parte del otro, hacer directo lo que es inverso.
ProblemaEso _repartosProporcionales(math.Random azar, int dificultad) {
  final modelos = dificultad <= 2
      ? [0, 0, 3]
      : dificultad <= 5
          ? [0, 1, 2, 3]
          : [1, 2, 4];
  final modelo = _elegir(azar, modelos);
  final valorUnidad = _elegir(
      azar, dificultad <= 2 ? [10, 20, 50, 100] : [15, 20, 25, 30, 40, 60]);

  switch (modelo) {
    case 1:
      // Directo en tres partes.
      final partes = <int>[];
      while (partes.length < 3) {
        final parte = _entre(azar, 1, 9);
        if (!partes.contains(parte)) partes.add(parte);
      }
      final total = (partes[0] + partes[1] + partes[2]) * valorUnidad;
      final respuesta = partes[0] * valorUnidad;
      final elegidas = opcionesConErrores(
        azar,
        '$respuesta €',
        [
          // A partes iguales.
          if (total % 3 == 0) '${total ~/ 3} €',
          // Lo que le toca a otro.
          '${partes[1] * valorUnidad} €',
          // Dividir entre la suma de las otras partes.
          if ((total * partes[0]) % (partes[1] + partes[2]) == 0)
            '${total * partes[0] ~/ (partes[1] + partes[2])} €',
        ],
        relleno: (n) => '${respuesta + n * 5} €',
      );
      return ProblemaEso(
        idHabilidad: 'PROP.10',
        enunciado:
            'Se reparten {t} € entre el Mercado, el Puerto y los Canales en proporción a sus habitantes: {a} mil, {b} mil y {c} mil. ¿Cuánto recibe el Mercado?',
        datos: {
          't': '$total',
          'a': '${partes[0]}',
          'b': '${partes[1]}',
          'c': '${partes[2]}'
        },
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
      );
    case 2:
      // Inverso en dos partes: a quien tardó a le toca t·b/(a+b).
      final tiempoPrimero = _entre(azar, 2, 9);
      int tiempoSegundo;
      do {
        tiempoSegundo = _entre(azar, 2, 9);
      } while (tiempoSegundo == tiempoPrimero);
      final total = (tiempoPrimero + tiempoSegundo) * valorUnidad;
      final respuesta = tiempoSegundo * valorUnidad;
      final elegidas = opcionesConErrores(
        azar,
        '$respuesta €',
        [
          // Reparto directo en vez de inverso.
          '${tiempoPrimero * valorUnidad} €',
          // A partes iguales.
          if (total.isEven) '${total ~/ 2} €',
        ],
        relleno: (n) => '${respuesta + n * 5} €',
      );
      return ProblemaEso(
        idHabilidad: 'PROP.10',
        enunciado:
            'Un premio de {t} € se reparte entre dos equipos de forma inversamente proporcional al tiempo que tardaron: {a} min y {b} min. ¿Cuánto recibe el equipo que tardó {a} min?',
        datos: {'t': '$total', 'a': '$tiempoPrimero', 'b': '$tiempoSegundo'},
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
      );
    case 4:
      // Inverso en tres partes: faltas a, b, c y pesos 1/a, 1/b, 1/c
      // pasados a enteros.
      final ternas = [
        (faltas: [2, 3, 6], pesos: [3, 2, 1]),
        (faltas: [2, 4, 6], pesos: [6, 3, 2]),
        (faltas: [3, 4, 6], pesos: [4, 3, 2]),
        (faltas: [2, 3, 4], pesos: [6, 4, 3]),
        (faltas: [4, 5, 10], pesos: [5, 4, 2]),
      ];
      final terna = _elegir(azar, ternas);
      final sumaPesos = terna.pesos.reduce((a, b) => a + b);
      final sumaFaltas = terna.faltas.reduce((a, b) => a + b);
      final unidad = _elegir(azar, [10, 20, 30, 40, 50]);
      final total = sumaPesos * unidad;
      final respuesta = terna.pesos[0] * unidad;
      final elegidas = opcionesConErrores(
        azar,
        '$respuesta €',
        [
          // Reparto directo en vez de inverso.
          if ((total * terna.faltas[0]) % sumaFaltas == 0)
            '${total * terna.faltas[0] ~/ sumaFaltas} €',
          // A partes iguales.
          if (total % 3 == 0) '${total ~/ 3} €',
          // Dar lo de quien más faltó.
          '${terna.pesos[2] * unidad} €',
          '${terna.pesos[1] * unidad} €',
        ],
        relleno: (n) => '${respuesta + n * 5} €',
      );
      return ProblemaEso(
        idHabilidad: 'PROP.10',
        enunciado:
            'Se reparten {t} € entre tres personas de forma inversamente proporcional a los días que faltaron: {a}, {b} y {c}. ¿Cuánto recibe la que faltó {a} días?',
        datos: {
          't': '$total',
          'a': '${terna.faltas[0]}',
          'b': '${terna.faltas[1]}',
          'c': '${terna.faltas[2]}'
        },
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
      );
    case 3:
      // Hacia atrás: con una parte se saca el total.
      final parteA = _entre(azar, 1, 6);
      int parteB;
      do {
        parteB = _entre(azar, 1, 7);
      } while (parteB == parteA);
      final recibido = parteA * valorUnidad;
      final total = (parteA + parteB) * valorUnidad;
      final elegidas = opcionesConErrores(
        azar,
        '$total €',
        [
          // Lo que recibe la otra parte.
          '${parteB * valorUnidad} €',
          // Doblar lo recibido, como si fuera a partes iguales.
          '${2 * recibido} €',
          // Sumar la otra parte como si fueran euros.
          '${recibido + parteB} €',
        ],
        relleno: (n) => '${total + n * valorUnidad} €',
      );
      return ProblemaEso(
        idHabilidad: 'PROP.10',
        enunciado:
            'En un reparto proporcional a {a} y {b}, la primera parte recibe {x} €. ¿Cuánto se reparte en total?',
        datos: {'a': '$parteA', 'b': '$parteB', 'x': '$recibido'},
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
      );
    default:
      // Directo en dos partes: aportaciones de dos socias.
      final aportaA = _entre(azar, 1, 6);
      int aportaB;
      do {
        aportaB = _entre(azar, 1, 6);
      } while (aportaB == aportaA);
      final total = (aportaA + aportaB) * valorUnidad;
      final respuesta = aportaA * valorUnidad;
      final elegidas = opcionesConErrores(
        azar,
        '$respuesta €',
        [
          // A partes iguales.
          if (total.isEven) '${total ~/ 2} €',
          // Lo de la otra socia.
          '${aportaB * valorUnidad} €',
        ],
        relleno: (n) => '${respuesta + n * 5} €',
      );
      return ProblemaEso(
        idHabilidad: 'PROP.10',
        enunciado:
            'Dos socias ponen {a} € y {b} € en un puesto del Mercado. Ganan {t} € y lo reparten en proporción a lo que puso cada una. ¿Cuánto le toca a la que puso {a} €?',
        datos: {
          'a': '${aportaA * 100}',
          'b': '${aportaB * 100}',
          't': '$total'
        },
        opciones: elegidas.opciones,
        indiceCorrecto: elegidas.indiceCorrecto,
      );
  }
}
