import 'dart:math' as math;

import 'problema_eso.dart';

/// Fichas de geometría de 1.º y 2.º de ESO: Tales y semejanza, áreas de
/// polígonos, prismas y cilindros, pirámides, conos y esferas, y
/// Pitágoras en problemas.
const List<FichaProblemaEso> fichasGeometriaEso = [
  FichaProblemaEso(
    idHabilidad: 'GEO.09',
    generar: _talesSemejanza,
    etiquetaTejado: 'Tales',
    tituloAyuda: 'TEOREMA DE TALES Y SEMEJANZA',
    textoAyuda:
        'En dos figuras semejantes, todos los lados se multiplican por el mismo número: '
        'la razón de semejanza. Divide dos lados que se correspondan y multiplica por el '
        'resultado. Si el lado de 4 pasa a medir 6, la razón es 6 : 4 = 1,5, y el lado de '
        '10 pasa a medir 15 (no 12).',
    transferencia:
        'En la vida: con la sombra de un palo que sí puedes medir, sabes la altura de un '
        'árbol o de una torre.',
    preguntaTutor:
        'hallar un lado desconocido en triángulos semejantes con la razón de semejanza',
    errorTipico:
        'sumar la diferencia entre dos lados en vez de multiplicar por la razón de semejanza',
    dificultadEstimada: 1.7,
    esquirlas: 5,
  ),
  FichaProblemaEso(
    idHabilidad: 'GEO.10',
    generar: _areasPoligonos,
    etiquetaTejado: 'D·d/2',
    tituloAyuda: 'ÁREAS DE POLÍGONOS',
    textoAyuda:
        'Trapecio: (base mayor + base menor) · altura : 2. Rombo: diagonal mayor · '
        'diagonal menor : 2. Polígono regular: perímetro · apotema : 2. Un rombo de '
        'diagonales 8 y 6 tiene 8 · 6 : 2 = 24 de área: no olvides dividir entre 2.',
    transferencia:
        'En la vida: para saber cuánta pintura o cuánto césped hace falta, se parte la '
        'superficie en figuras conocidas y se suman sus áreas.',
    preguntaTutor:
        'calcular el área de trapecios, rombos, polígonos regulares y figuras compuestas',
    errorTipico:
        'olvidar dividir entre 2 en el trapecio, el rombo o el polígono regular',
    dificultadEstimada: 1.4,
    esquirlas: 4,
  ),
  FichaProblemaEso(
    idHabilidad: 'GEO.11',
    generar: _prismasCilindros,
    etiquetaTejado: 'πr²h',
    tituloAyuda: 'PRISMAS Y CILINDROS',
    textoAyuda:
        'Volumen = área de la base · altura. En un prisma rectangular, largo · ancho · '
        'alto; en un cilindro, π · r² · h. El área lateral del cilindro es un rectángulo '
        'enrollado: 2 · π · r · h. Un cilindro de radio 3 y altura 5 tiene 9 · 5 = 45π de '
        'volumen.',
    transferencia:
        'En la vida: 1 dm³ es 1 litro; con el volumen de un depósito sabes cuánta agua cabe.',
    preguntaTutor: 'calcular volúmenes y áreas de prismas y cilindros',
    errorTipico:
        'confundir área y volumen, no elevar el radio al cuadrado o usar el diámetro como radio',
    dificultadEstimada: 1.7,
    esquirlas: 5,
  ),
  FichaProblemaEso(
    idHabilidad: 'GEO.12',
    generar: _piramidesConosEsferas,
    etiquetaTejado: '⅓·B·h',
    tituloAyuda: 'PIRÁMIDES, CONOS Y ESFERAS',
    textoAyuda:
        'Una pirámide o un cono ocupan la tercera parte del prisma o del cilindro con la '
        'misma base y altura: V = área de la base · altura : 3. Esfera: V = 4/3 · π · r³ y '
        'área = 4 · π · r². Un cono de radio 3 y altura 4 tiene 9 · 4 : 3 = 12π de volumen. '
        'El área lateral del cono es π · r · g, con g la generatriz.',
    transferencia:
        'En la vida: un cucurucho lleno cabe tres veces en un vaso cilíndrico con la misma '
        'boca y la misma altura.',
    preguntaTutor: 'calcular volúmenes y áreas de pirámides, conos y esferas',
    errorTipico:
        'olvidar dividir entre 3 en pirámides y conos, o confundir el volumen de la esfera con su área',
    dificultadEstimada: 1.8,
    esquirlas: 5,
  ),
  FichaProblemaEso(
    idHabilidad: 'GEO.13',
    generar: _pitagorasProblemas,
    etiquetaTejado: 'a²+b²',
    tituloAyuda: 'PITÁGORAS EN PROBLEMAS',
    textoAyuda:
        'En un triángulo rectángulo, hipotenusa² = cateto² + cateto². Para la hipotenusa, '
        'suma los cuadrados y haz la raíz: √(6² + 8²) = √100 = 10. Para un cateto, resta: '
        '√(10² − 6²) = √64 = 8. Busca el ángulo recto: la escalera, la pared y el suelo '
        'forman uno.',
    transferencia:
        'En la vida: el tamaño de una pantalla es su diagonal; con Pitágoras sabes si cabe '
        'en un hueco.',
    preguntaTutor:
        'aplicar el teorema de Pitágoras para hallar la hipotenusa o un cateto en un problema',
    errorTipico:
        'sumar los lados sin elevarlos al cuadrado, olvidar la raíz o sumar los cuadrados cuando hay que restarlos',
    dificultadEstimada: 1.7,
    esquirlas: 5,
  ),
];

/// Traducciones de los textos de estas fichas: castellano → [euskera,
/// catalán]. Borrador pendiente de revisión nativa.
const Map<String, List<String>> traduccionesGeometriaEso = {
  // GEO.09
  'TEOREMA DE TALES Y SEMEJANZA': [
    'TALESEN TEOREMA ETA ANTZEKOTASUNA',
    'TEOREMA DE TALES I SEMBLANÇA'
  ],
  'En dos figuras semejantes, todos los lados se multiplican por el mismo número: la razón de semejanza. Divide dos lados que se correspondan y multiplica por el resultado. Si el lado de 4 pasa a medir 6, la razón es 6 : 4 = 1,5, y el lado de 10 pasa a medir 15 (no 12).':
      [
    'Bi irudi antzekotan, alde guztiak zenbaki berberaz biderkatzen dira: antzekotasun-arrazoiaz. Zatitu elkarri dagozkion bi alde, eta biderkatu emaitzaz. 4ko aldeak 6 neurtzera pasatzen badu, arrazoia 6 : 4 = 1,5 da, eta 10eko aldeak 15 neurtuko du (ez 12).',
    'En dues figures semblants, tots els costats es multipliquen pel mateix nombre: la raó de semblança. Divideix dos costats que es corresponguin i multiplica pel resultat. Si el costat de 4 passa a mesurar 6, la raó és 6 : 4 = 1,5, i el costat de 10 passa a mesurar 15 (no 12).',
  ],
  'En la vida: con la sombra de un palo que sí puedes medir, sabes la altura de un árbol o de una torre.':
      [
    'Bizitzan: neur dezakezun makila baten itzalarekin, zuhaitz edo dorre baten altuera jakin dezakezu.',
    'A la vida: amb l’ombra d’un pal que sí que pots mesurar, saps l’alçada d’un arbre o d’una torre.',
  ],
  'Los dos triángulos son semejantes. ¿Cuánto mide el lado marcado con «?»? (Medidas en cm.)':
      [
    'Bi triangeluak antzekoak dira. Zenbat neurtzen du «?» ikurra duen aldeak? (Neurriak cm-tan.)',
    'Els dos triangles són semblants. Quant mesura el costat marcat amb «?»? (Mesures en cm.)',
  ],
  'Los dos triángulos son semejantes. ¿Cuál es la razón de semejanza del grande respecto al pequeño?':
      [
    'Bi triangeluak antzekoak dira. Zein da handiaren antzekotasun-arrazoia txikiarekiko?',
    'Els dos triangles són semblants. Quina és la raó de semblança del gran respecte del petit?',
  ],
  'A la misma hora, un poste de {p} m da una sombra de {sp} m y un árbol da una sombra de {sa} m. ¿Cuánto mide el árbol?':
      [
    'Ordu berean, zutoin baten altuera {p} m da eta haren itzala {sp} m; zuhaitz baten itzala, berriz, {sa} m da. Zenbat neurtzen du zuhaitzak?',
    'A la mateixa hora, un pal de {p} m fa una ombra de {sp} m i un arbre fa una ombra de {sa} m. Quant mesura l’arbre?',
  ],
  'Dos triángulos semejantes tienen razón de semejanza {k}. El pequeño tiene un área de {a} cm². ¿Qué área tiene el grande?':
      [
    'Bi triangelu antzekoren antzekotasun-arrazoia {k} da. Txikiaren azalera {a} cm² da. Zein da handiaren azalera?',
    'Dos triangles semblants tenen raó de semblança {k}. El petit té una àrea de {a} cm². Quina àrea té el gran?',
  ],

  // GEO.10
  'ÁREAS DE POLÍGONOS': ['POLIGONOEN AZALERAK', 'ÀREES DE POLÍGONS'],
  'Trapecio: (base mayor + base menor) · altura : 2. Rombo: diagonal mayor · diagonal menor : 2. Polígono regular: perímetro · apotema : 2. Un rombo de diagonales 8 y 6 tiene 8 · 6 : 2 = 24 de área: no olvides dividir entre 2.':
      [
    'Trapezioa: (oinarri handia + oinarri txikia) · altuera : 2. Erronboa: diagonal handia · diagonal txikia : 2. Poligono erregularra: perimetroa · apotema : 2. 8 eta 6 diagonaleko erronbo batek 8 · 6 : 2 = 24 azalera du: ez ahaztu 2rekin zatitzea.',
    'Trapezi: (base major + base menor) · altura : 2. Rombe: diagonal major · diagonal menor : 2. Polígon regular: perímetre · apotema : 2. Un rombe de diagonals 8 i 6 té 8 · 6 : 2 = 24 d’àrea: no oblidis dividir entre 2.',
  ],
  'En la vida: para saber cuánta pintura o cuánto césped hace falta, se parte la superficie en figuras conocidas y se suman sus áreas.':
      [
    'Bizitzan: zenbat pintura edo zenbat belar behar den jakiteko, azalera irudi ezagunetan zatitzen da eta haien azalerak batzen dira.',
    'A la vida: per saber quanta pintura o quanta gespa cal, es divideix la superfície en figures conegudes i se sumen les seves àrees.',
  ],
  'Calcula el área de este trapecio.': [
    'Kalkulatu trapezio honen azalera.',
    'Calcula l’àrea d’aquest trapezi.'
  ],
  'Calcula el área de este rombo.': [
    'Kalkulatu erronbo honen azalera.',
    'Calcula l’àrea d’aquest rombe.'
  ],
  'Calcula el área de este polígono regular de {n} lados.': [
    'Kalkulatu poligono erregular honen azalera. Alde kopurua: {n}.',
    'Calcula l’àrea d’aquest polígon regular de {n} costats.',
  ],
  'Un trapecio tiene {A} cm² de área y sus bases miden {B} cm y {b} cm. ¿Cuánto mide su altura?':
      [
    'Trapezio baten azalera {A} cm² da, eta haren oinarriek {B} cm eta {b} cm neurtzen dute. Zenbat neurtzen du haren altuerak?',
    'Un trapezi té {A} cm² d’àrea i les seves bases mesuren {B} cm i {b} cm. Quant mesura la seva altura?',
  ],
  'La fachada de una casa de las Afueras es un rectángulo de {b} m de ancho y {h} m de alto, con un tejado triangular encima de la misma base y {t} m de altura. ¿Cuál es el área de la fachada?':
      [
    'Kanpoaldeetako etxe baten fatxada laukizuzen bat da: zabalera {b} m eta altuera {h} m. Gainean teilatu triangeluar bat du, oinarri berekoa; teilatuaren altuera {t} m da. Zein da fatxadaren azalera?',
    'La façana d’una casa dels Afores és un rectangle de {b} m d’amplada i {h} m d’alçada, amb una teulada triangular a sobre de la mateixa base i {t} m d’alçada. Quina és l’àrea de la façana?',
  ],

  // GEO.11
  'PRISMAS Y CILINDROS': ['PRISMAK ETA ZILINDROAK', 'PRISMES I CILINDRES'],
  'Volumen = área de la base · altura. En un prisma rectangular, largo · ancho · alto; en un cilindro, π · r² · h. El área lateral del cilindro es un rectángulo enrollado: 2 · π · r · h. Un cilindro de radio 3 y altura 5 tiene 9 · 5 = 45π de volumen.':
      [
    'Bolumena = oinarriaren azalera · altuera. Prisma laukizuzen batean, luzera · zabalera · altuera; zilindro batean, π · r² · h. Zilindroaren alboko azalera bildutako laukizuzen bat da: 2 · π · r · h. 3 erradioko eta 5 altuerako zilindro batek 9 · 5 = 45π bolumen du.',
    'Volum = àrea de la base · altura. En un prisma rectangular, llargada · amplada · alçada; en un cilindre, π · r² · h. L’àrea lateral del cilindre és un rectangle enrotllat: 2 · π · r · h. Un cilindre de radi 3 i altura 5 té 9 · 5 = 45π de volum.',
  ],
  'En la vida: 1 dm³ es 1 litro; con el volumen de un depósito sabes cuánta agua cabe.':
      [
    'Bizitzan: 1 dm³ litro 1 da; biltegi baten bolumenarekin badakizu zenbat ur sartzen den.',
    'A la vida: 1 dm³ és 1 litre; amb el volum d’un dipòsit saps quanta aigua hi cap.',
  ],
  '¿Cuál es el volumen de este cubo?': [
    'Zein da kubo honen bolumena?',
    'Quin és el volum d’aquest cub?'
  ],
  '¿Cuál es el volumen de este prisma rectangular?': [
    'Zein da prisma laukizuzen honen bolumena?',
    'Quin és el volum d’aquest prisma rectangular?'
  ],
  '¿Cuál es el área total de este prisma rectangular (sus seis caras)?': [
    'Zein da prisma laukizuzen honen azalera osoa (sei aurpegiak)?',
    'Quina és l’àrea total d’aquest prisma rectangular (les sis cares)?',
  ],
  'Un acuario del Mercado mide {l} cm de largo, {a} cm de ancho y {h} cm de alto. ¿Cuántos litros caben?':
      [
    'Merkatuko akuario baten neurriak: luzera {l} cm, zabalera {a} cm eta altuera {h} cm. Zenbat litro sartzen dira?',
    'Un aquari del Mercat fa {l} cm de llargada, {a} cm d’amplada i {h} cm d’alçada. Quants litres hi caben?',
  ],
  '¿Cuál es el volumen de este cilindro? Exprésalo en función de π.': [
    'Zein da zilindro honen bolumena? Adierazi π-ren funtzioan.',
    'Quin és el volum d’aquest cilindre? Expressa’l en funció de π.',
  ],
  '¿Cuál es el volumen de este cilindro? Usa π ≈ 3,14.': [
    'Zein da zilindro honen bolumena? Erabili π ≈ 3,14.',
    'Quin és el volum d’aquest cilindre? Fes servir π ≈ 3,14.',
  ],
  'Un bote cilíndrico tiene {d} cm de diámetro y {h} cm de altura. ¿Cuál es su volumen en función de π?':
      [
    'Pote zilindriko baten diametroa {d} cm da eta altuera {h} cm. Zein da haren bolumena π-ren funtzioan?',
    'Un pot cilíndric té {d} cm de diàmetre i {h} cm d’altura. Quin és el seu volum en funció de π?',
  ],
  '¿Cuál es el área lateral de este cilindro? Exprésala en función de π.': [
    'Zein da zilindro honen alboko azalera? Adierazi π-ren funtzioan.',
    'Quina és l’àrea lateral d’aquest cilindre? Expressa-la en funció de π.',
  ],
  '¿Cuál es el área total de este cilindro, con sus dos bases? Exprésala en función de π.':
      [
    'Zein da zilindro honen azalera osoa, bi oinarriak barne? Adierazi π-ren funtzioan.',
    'Quina és l’àrea total d’aquest cilindre, amb les dues bases? Expressa-la en funció de π.',
  ],

  // GEO.12
  'PIRÁMIDES, CONOS Y ESFERAS': [
    'PIRAMIDEAK, KONOAK ETA ESFERAK',
    'PIRÀMIDES, CONS I ESFERES'
  ],
  'Una pirámide o un cono ocupan la tercera parte del prisma o del cilindro con la misma base y altura: V = área de la base · altura : 3. Esfera: V = 4/3 · π · r³ y área = 4 · π · r². Un cono de radio 3 y altura 4 tiene 9 · 4 : 3 = 12π de volumen. El área lateral del cono es π · r · g, con g la generatriz.':
      [
    'Piramide batek edo kono batek oinarri eta altuera bereko prismaren edo zilindroaren herena hartzen dute: V = oinarriaren azalera · altuera : 3. Esfera: V = 4/3 · π · r³ eta azalera = 4 · π · r². 3 erradioko eta 4 altuerako kono batek 9 · 4 : 3 = 12π bolumen du. Konoaren alboko azalera π · r · g da, g sortzailea izanik.',
    'Una piràmide o un con ocupen la tercera part del prisma o del cilindre amb la mateixa base i altura: V = àrea de la base · altura : 3. Esfera: V = 4/3 · π · r³ i àrea = 4 · π · r². Un con de radi 3 i altura 4 té 9 · 4 : 3 = 12π de volum. L’àrea lateral del con és π · r · g, amb g la generatriu.',
  ],
  'En la vida: un cucurucho lleno cabe tres veces en un vaso cilíndrico con la misma boca y la misma altura.':
      [
    'Bizitzan: kukurutxo bete bat hiru aldiz sartzen da aho eta altuera bereko edalontzi zilindriko batean.',
    'A la vida: un cucurutxo ple cap tres vegades en un got cilíndric amb la mateixa boca i la mateixa alçada.',
  ],
  '¿Cuál es el volumen de esta pirámide de base cuadrada?': [
    'Zein da oinarri karratuko piramide honen bolumena?',
    'Quin és el volum d’aquesta piràmide de base quadrada?',
  ],
  'Un cono y un cilindro tienen la misma base y la misma altura. En el cilindro caben {v} L. ¿Cuántos litros caben en el cono?':
      [
    'Kono batek eta zilindro batek oinarri eta altuera bera dituzte. Zilindroan {v} L sartzen dira. Zenbat litro sartzen dira konoan?',
    'Un con i un cilindre tenen la mateixa base i la mateixa altura. Al cilindre hi caben {v} L. Quants litres hi caben al con?',
  ],
  '¿Cuál es el volumen de este cono? Exprésalo en función de π.': [
    'Zein da kono honen bolumena? Adierazi π-ren funtzioan.',
    'Quin és el volum d’aquest con? Expressa’l en funció de π.',
  ],
  '¿Cuál es el volumen de esta esfera? Exprésalo en función de π.': [
    'Zein da esfera honen bolumena? Adierazi π-ren funtzioan.',
    'Quin és el volum d’aquesta esfera? Expressa’l en funció de π.',
  ],
  '¿Cuál es el área de esta esfera? Exprésala en función de π.': [
    'Zein da esfera honen azalera? Adierazi π-ren funtzioan.',
    'Quina és l’àrea d’aquesta esfera? Expressa-la en funció de π.',
  ],
  'Una pelota tiene {d} cm de diámetro. ¿Cuál es su volumen? Usa π ≈ 3,14.': [
    'Pilota baten diametroa {d} cm da. Zein da haren bolumena? Erabili π ≈ 3,14.',
    'Una pilota té {d} cm de diàmetre. Quin és el seu volum? Fes servir π ≈ 3,14.',
  ],
  'Un cono tiene {r} cm de radio y {h} cm de altura. ¿Cuál es su área lateral? Exprésala en función de π.':
      [
    'Kono baten erradioa {r} cm da eta altuera {h} cm. Zein da haren alboko azalera? Adierazi π-ren funtzioan.',
    'Un con té {r} cm de radi i {h} cm d’altura. Quina és la seva àrea lateral? Expressa-la en funció de π.',
  ],

  // GEO.13
  'PITÁGORAS EN PROBLEMAS': ['PITAGORAS PROBLEMETAN', 'PITÀGORES EN PROBLEMES'],
  'En un triángulo rectángulo, hipotenusa² = cateto² + cateto². Para la hipotenusa, suma los cuadrados y haz la raíz: √(6² + 8²) = √100 = 10. Para un cateto, resta: √(10² − 6²) = √64 = 8. Busca el ángulo recto: la escalera, la pared y el suelo forman uno.':
      [
    'Triangelu zuzen batean, hipotenusa² = katetoa² + katetoa². Hipotenusa lortzeko, batu karratuak eta atera erro karratua: √(6² + 8²) = √100 = 10. Kateto bat lortzeko, kendu: √(10² − 6²) = √64 = 8. Bilatu angelu zuzena: eskailerak, hormak eta lurrak bat osatzen dute.',
    'En un triangle rectangle, hipotenusa² = catet² + catet². Per a la hipotenusa, suma els quadrats i fes l’arrel: √(6² + 8²) = √100 = 10. Per a un catet, resta: √(10² − 6²) = √64 = 8. Busca l’angle recte: l’escala, la paret i el terra en formen un.',
  ],
  'En la vida: el tamaño de una pantalla es su diagonal; con Pitágoras sabes si cabe en un hueco.':
      [
    'Bizitzan: pantaila baten neurria haren diagonala da; Pitagorasekin badakizu hutsune batean sartzen den.',
    'A la vida: la mida d’una pantalla és la seva diagonal; amb Pitàgores saps si cap en un forat.',
  ],
  'Una escalera de {l} m está apoyada en una pared. Su pie está a {d} m de la pared. ¿A qué altura de la pared llega?':
      [
    'Eskailera bat horma baten kontra bermatuta dago. Eskailerak {l} m neurtzen ditu, eta haren oinaren eta hormaren arteko distantzia {d} m da. Zer altueraraino iristen da horman?',
    'Una escala de {l} m està recolzada en una paret. El seu peu és a {d} m de la paret. Fins a quina alçada de la paret arriba?',
  ],
  'Una pantalla mide {a} cm de ancho y {b} cm de alto. ¿Cuánto mide su diagonal?':
      [
    'Pantaila baten zabalera {a} cm da eta altuera {b} cm. Zenbat neurtzen du haren diagonalak?',
    'Una pantalla fa {a} cm d’amplada i {b} cm d’alçada. Quant mesura la seva diagonal?',
  ],
  'La diagonal de una pantalla mide {c} cm y su ancho, {a} cm. ¿Cuánto mide de alto?':
      [
    'Pantaila baten diagonalak {c} cm neurtzen ditu eta zabalerak {a} cm. Zenbat neurtzen du altuerak?',
    'La diagonal d’una pantalla mesura {c} cm i l’amplada, {a} cm. Quant fa d’alçada?',
  ],
  'Una barca sale del Puerto, navega {a} km hacia el norte y después {b} km hacia el este. ¿A qué distancia en línea recta está del punto de salida?':
      [
    'Txalupa bat Portutik ateratzen da: iparralderantz nabigatzen du (distantzia: {a} km), eta gero ekialderantz (distantzia: {b} km). Zer distantziatara dago, lerro zuzenean, irteera-puntutik?',
    'Una barca surt del Port, navega {a} km cap al nord i després {b} km cap a l’est. A quina distància en línia recta és del punt de sortida?',
  ],
  'Un triángulo isósceles tiene los dos lados iguales de {l} cm y la base de {b} cm. ¿Cuánto mide su altura? (El dibujo muestra la mitad del triángulo.)':
      [
    'Triangelu isoszele baten bi alde berdinek {l} cm neurtzen dute, eta oinarriak {b} cm. Zenbat neurtzen du haren altuerak? (Marrazkiak triangeluaren erdia erakusten du.)',
    'Un triangle isòsceles té els dos costats iguals de {l} cm i la base de {b} cm. Quant mesura la seva altura? (El dibuix mostra la meitat del triangle.)',
  ],
};

int _entre(math.Random azar, int minimo, int maximo) =>
    minimo + azar.nextInt(maximo - minimo + 1);

T _unoDe<T>(math.Random azar, List<T> lista) =>
    lista[azar.nextInt(lista.length)];

/// Un número con coma y la unidad detrás (`12,5 cm²`).
String _medida(num valor, String unidad) =>
    '${formatearDecimal(valor)} $unidad';

/// Un coeficiente de π con la unidad (`45π cm³`).
String _conPi(num coeficiente, String unidad) =>
    '${formatearDecimal(coeficiente)}π $unidad';

/// Si un valor tiene como mucho dos decimales (para no enseñar 2,667).
bool _esLimpio(num valor) =>
    ((valor * 100) - (valor * 100).round()).abs() < 1e-9;

/// Una fracción simplificada como texto (`3/2`, `4`).
String _fraccion(int numerador, int denominador) {
  final divisor = numerador.gcd(denominador);
  final arriba = numerador ~/ divisor;
  final abajo = denominador ~/ divisor;
  return abajo == 1 ? '$arriba' : '$arriba/$abajo';
}

/// Valor de relleno cerca del bueno: arriba y abajo alternando, sin
/// bajar de cero.
num _cercano(num buena, int n, num paso) {
  final hacia = n.isOdd || buena - n * paso <= 0 ? n : -n;
  return buena + hacia * paso;
}

// ── GEO.09 Teorema de Tales y semejanza ─────────────────────────────

/// Tríos de lados que forman triángulo, todos distintos.
const _triangulosBase = [
  [3, 4, 5],
  [4, 5, 6],
  [5, 6, 7],
  [2, 3, 4],
  [3, 5, 7],
  [4, 6, 7],
  [5, 7, 8],
  [6, 7, 9],
];

ProblemaEso _talesSemejanza(math.Random azar, int dificultad) {
  final modelos = [
    'lado',
    'sombra',
    if (dificultad >= 2) 'razon',
    if (dificultad >= 6) 'area',
  ];
  return switch (_unoDe(azar, modelos)) {
    'sombra' => _talesSombras(azar, dificultad),
    'razon' => _talesRazon(azar, dificultad),
    'area' => _talesAreas(azar),
    _ => _talesLado(azar, dificultad),
  };
}

/// Multiplicadores (pequeño, grande): la razón es grande/pequeño.
(int, int) _multiplicadoresSemejanza(math.Random azar, int dificultad) {
  if (dificultad <= 2) return (1, _entre(azar, 2, 3));
  if (dificultad <= 5) {
    return _unoDe(azar, const [(1, 2), (1, 3), (2, 3), (2, 5), (1, 4)]);
  }
  return _unoDe(azar, const [(2, 3), (2, 5), (3, 4), (3, 5), (4, 5)]);
}

ProblemaEso _talesLado(math.Random azar, int dificultad) {
  final base = _unoDe(azar, _triangulosBase);
  final (multiplicadorPequeno, multiplicadorGrande) =
      _multiplicadoresSemejanza(azar, dificultad);
  final pequeno = [for (final lado in base) lado * multiplicadorPequeno];
  final grande = [for (final lado in base) lado * multiplicadorGrande];
  final ladoPreguntado = azar.nextInt(3);
  final ladoReferencia = (ladoPreguntado + 1 + azar.nextInt(2)) % 3;
  final diferenciaReferencia = grande[ladoReferencia] - pequeno[ladoReferencia];
  // Con dificultad alta, a veces se pregunta por el triángulo pequeño.
  // Del otro triángulo sólo se ve el lado de referencia.
  final preguntarPequeno = dificultad >= 4 && azar.nextBool();
  final int buena;
  final List<num> errores;
  final List<String> ladosPequeno;
  final List<String> ladosGrande;
  List<String> ladosConPregunta(List<int> lados) => [
        for (var i = 0; i < 3; i++)
          i == ladoPreguntado ? '?' : (i == ladoReferencia ? '${lados[i]}' : '')
      ];
  if (preguntarPequeno) {
    buena = pequeno[ladoPreguntado];
    final inversa =
        grande[ladoPreguntado] * multiplicadorGrande / multiplicadorPequeno;
    errores = [
      // Restar la diferencia en vez de dividir por la razón.
      grande[ladoPreguntado] - diferenciaReferencia,
      // Aplicar la razón al revés.
      if (_esLimpio(inversa)) inversa,
    ];
    ladosPequeno = ladosConPregunta(pequeno);
    ladosGrande = [for (final lado in grande) '$lado'];
  } else {
    buena = grande[ladoPreguntado];
    final inversa =
        pequeno[ladoPreguntado] * multiplicadorPequeno / multiplicadorGrande;
    errores = [
      // Sumar la diferencia en vez de multiplicar por la razón.
      pequeno[ladoPreguntado] + diferenciaReferencia,
      // Aplicar la razón al revés.
      if (_esLimpio(inversa)) inversa,
    ];
    ladosPequeno = [for (final lado in pequeno) '$lado'];
    ladosGrande = ladosConPregunta(grande);
  }
  final elegidas = opcionesConErrores(
    azar,
    _medida(buena, 'cm'),
    [
      for (final error in errores)
        if (error > 0) _medida(error, 'cm')
    ],
    relleno: (n) => _medida(_cercano(buena, n, 1), 'cm'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.09',
    enunciado:
        'Los dos triángulos son semejantes. ¿Cuánto mide el lado marcado con «?»? (Medidas en cm.)',
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual:
        VisualTriangulos(ladosPequeno: ladosPequeno, ladosGrande: ladosGrande),
  );
}

ProblemaEso _talesRazon(math.Random azar, int dificultad) {
  final base = _unoDe(azar, _triangulosBase);
  final (multiplicadorPequeno, multiplicadorGrande) =
      _multiplicadoresSemejanza(azar, dificultad);
  final pequeno = [for (final lado in base) lado * multiplicadorPequeno];
  final grande = [for (final lado in base) lado * multiplicadorGrande];
  final elegidas = opcionesConErrores(
    azar,
    _fraccion(multiplicadorGrande, multiplicadorPequeno),
    [
      // La razón al revés (pequeño entre grande).
      _fraccion(multiplicadorPequeno, multiplicadorGrande),
      // La diferencia entre dos lados en vez del cociente.
      '${grande[0] - pequeno[0]}',
      // La razón de las áreas.
      _fraccion(multiplicadorGrande * multiplicadorGrande,
          multiplicadorPequeno * multiplicadorPequeno),
    ],
    relleno: (n) => _fraccion(multiplicadorGrande + n, multiplicadorPequeno),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.09',
    enunciado:
        'Los dos triángulos son semejantes. ¿Cuál es la razón de semejanza del grande respecto al pequeño?',
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualTriangulos(
      ladosPequeno: [for (final lado in pequeno) '$lado'],
      ladosGrande: [for (final lado in grande) '$lado'],
    ),
  );
}

ProblemaEso _talesSombras(math.Random azar, int dificultad) {
  // Un poste con su sombra; la sombra del árbol es [veces] la del poste.
  final num alturaPoste;
  final int sombraPoste;
  final int veces;
  if (dificultad <= 2) {
    alturaPoste = _entre(azar, 2, 3);
    sombraPoste = _unoDe(
        azar, [1, 2, 3].where((sombra) => sombra != alturaPoste).toList());
    veces = _entre(azar, 2, 5);
  } else {
    alturaPoste = _unoDe(azar, const [1.5, 2, 2.5]);
    sombraPoste = _unoDe(azar, const [3, 4]);
    veces = _entre(azar, 3, 8);
  }
  final sombraArbol = sombraPoste * veces;
  final alturaArbol = alturaPoste * veces;
  final inversa = sombraArbol * sombraPoste / alturaPoste;
  final elegidas = opcionesConErrores(
    azar,
    _medida(alturaArbol, 'm'),
    [
      // Sumar la diferencia de sombras a la altura del poste.
      _medida(alturaPoste + sombraArbol - sombraPoste, 'm'),
      // Quedarse en la razón de las sombras.
      _medida(veces, 'm'),
      // Aplicar la razón al revés.
      if (_esLimpio(inversa)) _medida(inversa, 'm'),
    ],
    relleno: (n) => _medida(_cercano(alturaArbol, n, alturaPoste / 2), 'm'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.09',
    enunciado:
        'A la misma hora, un poste de {p} m da una sombra de {sp} m y un árbol da una sombra de {sa} m. ¿Cuánto mide el árbol?',
    datos: {
      'p': formatearDecimal(alturaPoste),
      'sp': '$sombraPoste',
      'sa': '$sombraArbol',
    },
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualTriangulos(
      ladosPequeno: [_medida(sombraPoste, 'm'), _medida(alturaPoste, 'm')],
      ladosGrande: [_medida(sombraArbol, 'm'), '?'],
    ),
  );
}

ProblemaEso _talesAreas(math.Random azar) {
  final razon = _entre(azar, 2, 4);
  final areaPequeno = _entre(azar, 3, 12);
  final buena = areaPequeno * razon * razon;
  final elegidas = opcionesConErrores(
    azar,
    _medida(buena, 'cm²'),
    [
      // Multiplicar el área por la razón sin elevarla al cuadrado.
      _medida(areaPequeno * razon, 'cm²'),
      // Multiplicar por el doble de la razón.
      _medida(areaPequeno * razon * 2, 'cm²'),
      // Elevar la razón al cubo (como en los volúmenes).
      _medida(areaPequeno * razon * razon * razon, 'cm²'),
    ],
    relleno: (n) => _medida(buena + n * areaPequeno, 'cm²'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.09',
    enunciado:
        'Dos triángulos semejantes tienen razón de semejanza {k}. El pequeño tiene un área de {a} cm². ¿Qué área tiene el grande?',
    datos: {'k': '$razon', 'a': '$areaPequeno'},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
  );
}

// ── GEO.10 Áreas de polígonos ───────────────────────────────────────

ProblemaEso _areasPoligonos(math.Random azar, int dificultad) {
  final modelos = [
    'trapecio',
    'rombo',
    if (dificultad >= 3) 'poligono',
    if (dificultad >= 4) 'alturaTrapecio',
    if (dificultad >= 6) 'compuesta',
  ];
  return switch (_unoDe(azar, modelos)) {
    'rombo' => _areaRombo(azar, dificultad),
    'poligono' => _areaPoligonoRegular(azar, dificultad),
    'alturaTrapecio' => _alturaTrapecio(azar),
    'compuesta' => _areaCompuesta(azar),
    _ => _areaTrapecio(azar, dificultad),
  };
}

ProblemaEso _areaTrapecio(math.Random azar, int dificultad) {
  final maximo = dificultad <= 2 ? 10 : 16;
  final baseMayor = _entre(azar, 6, maximo);
  final baseMenor = _entre(azar, 2, baseMayor - 2);
  var altura = _entre(azar, 2, dificultad <= 2 ? 6 : 10);
  if ((baseMayor + baseMenor) * altura % 2 == 1) altura++;
  final buena = (baseMayor + baseMenor) * altura ~/ 2;
  final elegidas = opcionesConErrores(
    azar,
    _medida(buena, 'cm²'),
    [
      // Olvidar dividir entre 2.
      _medida((baseMayor + baseMenor) * altura, 'cm²'),
      // Usar sólo la base mayor.
      _medida(baseMayor * altura, 'cm²'),
      // Restar las bases en vez de sumarlas.
      _medida((baseMayor - baseMenor) * altura / 2, 'cm²'),
    ],
    relleno: (n) => _medida(_cercano(buena, n, altura), 'cm²'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.10',
    enunciado: 'Calcula el área de este trapecio.',
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualFigura(forma: FormaPlana.trapecio, medidas: {
      'baseMayor': _medida(baseMayor, 'cm'),
      'baseMenor': _medida(baseMenor, 'cm'),
      'alto': _medida(altura, 'cm'),
    }),
  );
}

ProblemaEso _areaRombo(math.Random azar, int dificultad) {
  final maximo = dificultad <= 2 ? 10 : 20;
  final diagonalMenor = _entre(azar, 2, maximo ~/ 2) * 2;
  final diagonalMayor = diagonalMenor + _entre(azar, 1, maximo ~/ 2);
  final buena = diagonalMayor * diagonalMenor ~/ 2;
  final elegidas = opcionesConErrores(
    azar,
    _medida(buena, 'cm²'),
    [
      // Olvidar dividir entre 2.
      _medida(diagonalMayor * diagonalMenor, 'cm²'),
      // Dividir entre 4 (las dos mitades de las diagonales).
      _medida(diagonalMayor * diagonalMenor / 4, 'cm²'),
      // Sumar en vez de multiplicar.
      _medida(diagonalMayor + diagonalMenor, 'cm²'),
    ],
    relleno: (n) => _medida(_cercano(buena, n, 2), 'cm²'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.10',
    enunciado: 'Calcula el área de este rombo.',
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualFigura(forma: FormaPlana.rombo, medidas: {
      'diagonalMayor': _medida(diagonalMayor, 'cm'),
      'diagonalMenor': _medida(diagonalMenor, 'cm'),
    }),
  );
}

/// Apotema entre lado de los polígonos regulares que se usan.
const _apotemaPorLado = {5: 0.688, 6: 0.866, 8: 1.207};

ProblemaEso _areaPoligonoRegular(math.Random azar, int dificultad) {
  final lados = _unoDe(azar, dificultad >= 6 ? const [5, 6, 8] : const [5, 6]);
  final lado = _unoDe(azar, const [4, 6, 8, 10]);
  // La apotema, redondeada a décimas como en los libros.
  final apotemaDecimas = (lado * _apotemaPorLado[lados]! * 10).round();
  final buena = lados * lado * apotemaDecimas / 20;
  final elegidas = opcionesConErrores(
    azar,
    _medida(buena, 'cm²'),
    [
      // Olvidar dividir entre 2.
      _medida(lados * lado * apotemaDecimas / 10, 'cm²'),
      // Calcular sólo uno de los triángulos.
      _medida(lado * apotemaDecimas / 20, 'cm²'),
      // Usar el lado en lugar de la apotema.
      _medida(lados * lado * lado / 2, 'cm²'),
    ],
    relleno: (n) => _medida(_cercano(buena, n, lado), 'cm²'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.10',
    enunciado: 'Calcula el área de este polígono regular de {n} lados.',
    datos: {'n': '$lados'},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualFigura(
      forma: FormaPlana.poligonoRegular,
      lados: lados,
      medidas: {
        'lado': _medida(lado, 'cm'),
        'apotema': _medida(apotemaDecimas / 10, 'cm'),
      },
    ),
  );
}

ProblemaEso _alturaTrapecio(math.Random azar) {
  final baseMayor = _entre(azar, 6, 14);
  final baseMenor = _entre(azar, 2, baseMayor - 2);
  var altura = _entre(azar, 2, 9);
  if ((baseMayor + baseMenor) * altura % 2 == 1) altura++;
  final area = (baseMayor + baseMenor) * altura ~/ 2;
  final sinDoble = area / (baseMayor + baseMenor);
  final conBaseMayor = 2 * area / baseMayor;
  final elegidas = opcionesConErrores(
    azar,
    _medida(altura, 'cm'),
    [
      // Olvidar multiplicar el área por 2.
      if (_esLimpio(sinDoble)) _medida(sinDoble, 'cm'),
      // Usar sólo la base mayor.
      if (_esLimpio(conBaseMayor)) _medida(conBaseMayor, 'cm'),
      // Multiplicar por 2 en vez de dividir.
      _medida(altura * 2, 'cm'),
    ],
    relleno: (n) => _medida(_cercano(altura, n, 1), 'cm'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.10',
    enunciado:
        'Un trapecio tiene {A} cm² de área y sus bases miden {B} cm y {b} cm. ¿Cuánto mide su altura?',
    datos: {'A': '$area', 'B': '$baseMayor', 'b': '$baseMenor'},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualFigura(forma: FormaPlana.trapecio, medidas: {
      'baseMayor': _medida(baseMayor, 'cm'),
      'baseMenor': _medida(baseMenor, 'cm'),
      'alto': '?',
    }),
  );
}

ProblemaEso _areaCompuesta(math.Random azar) {
  final ancho = _entre(azar, 3, 6) * 2;
  final altoPared = _entre(azar, 3, 7);
  final altoTejado = _entre(azar, 2, 4);
  final buena = ancho * altoPared + ancho * altoTejado ~/ 2;
  final elegidas = opcionesConErrores(
    azar,
    _medida(buena, 'm²'),
    [
      // Olvidar dividir el triángulo entre 2.
      _medida(ancho * altoPared + ancho * altoTejado, 'm²'),
      // Sólo el rectángulo.
      _medida(ancho * altoPared, 'm²'),
      // Todo como si fuera un triángulo.
      _medida(ancho * (altoPared + altoTejado) / 2, 'm²'),
    ],
    relleno: (n) => _medida(_cercano(buena, n, 2), 'm²'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.10',
    enunciado:
        'La fachada de una casa de las Afueras es un rectángulo de {b} m de ancho y {h} m de alto, con un tejado triangular encima de la misma base y {t} m de altura. ¿Cuál es el área de la fachada?',
    datos: {'b': '$ancho', 'h': '$altoPared', 't': '$altoTejado'},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
  );
}

// ── GEO.11 Prismas y cilindros ──────────────────────────────────────

ProblemaEso _prismasCilindros(math.Random azar, int dificultad) {
  final modelos = [
    if (dificultad <= 3) 'cubo',
    'volumenPrisma',
    'volumenCilindroPi',
    if (dificultad >= 3) 'areaPrisma',
    if (dificultad >= 3) 'lateralCilindro',
    if (dificultad >= 3) 'volumenCilindro314',
    if (dificultad >= 5) 'litros',
    if (dificultad >= 5) 'diametro',
    if (dificultad >= 6) 'totalCilindro',
  ];
  return switch (_unoDe(azar, modelos)) {
    'cubo' => _volumenCubo(azar),
    'areaPrisma' => _areaPrisma(azar),
    'litros' => _litrosAcuario(azar),
    'volumenCilindroPi' => _volumenCilindroPi(azar, dificultad),
    'volumenCilindro314' => _volumenCilindro314(azar),
    'diametro' => _volumenCilindroDiametro(azar),
    'lateralCilindro' => _areaCilindro(azar, total: false),
    'totalCilindro' => _areaCilindro(azar, total: true),
    _ => _volumenPrisma(azar, dificultad),
  };
}

ProblemaEso _volumenCubo(math.Random azar) {
  final lado = _entre(azar, 2, 6);
  final buena = lado * lado * lado;
  final elegidas = opcionesConErrores(
    azar,
    _medida(buena, 'cm³'),
    [
      // Elevar al cuadrado en vez de al cubo.
      _medida(lado * lado, 'cm³'),
      // Multiplicar por 3 en vez de elevar a 3.
      _medida(lado * 3, 'cm³'),
      // El área de las seis caras.
      _medida(6 * lado * lado, 'cm³'),
    ],
    relleno: (n) => _medida(buena + n * lado, 'cm³'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.11',
    enunciado: '¿Cuál es el volumen de este cubo?',
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualCuerpo(
        forma: FormaCuerpo.cubo, medidas: {'lado': _medida(lado, 'cm')}),
  );
}

typedef _Prisma = ({int largo, int ancho, int alto});

_Prisma _dimensionesPrisma(math.Random azar, int maximo) {
  final largo = _entre(azar, 3, maximo);
  final ancho = _entre(azar, 2, largo - 1);
  final alto = _entre(azar, 2, maximo);
  return (largo: largo, ancho: ancho, alto: alto);
}

VisualCuerpo _dibujoPrisma(_Prisma prisma) =>
    VisualCuerpo(forma: FormaCuerpo.prisma, medidas: {
      'largo': _medida(prisma.largo, 'cm'),
      'ancho': _medida(prisma.ancho, 'cm'),
      'alto': _medida(prisma.alto, 'cm'),
    });

/// Suma de las áreas de tres caras distintas del prisma.
int _tresCaras(_Prisma prisma) =>
    prisma.largo * prisma.ancho +
    prisma.largo * prisma.alto +
    prisma.ancho * prisma.alto;

ProblemaEso _volumenPrisma(math.Random azar, int dificultad) {
  final prisma = _dimensionesPrisma(azar, dificultad <= 2 ? 6 : 12);
  final buena = prisma.largo * prisma.ancho * prisma.alto;
  final elegidas = opcionesConErrores(
    azar,
    _medida(buena, 'cm³'),
    [
      // Sólo el área de la base.
      _medida(prisma.largo * prisma.ancho, 'cm³'),
      // El área total en vez del volumen.
      _medida(2 * _tresCaras(prisma), 'cm³'),
      // Sumar las medidas.
      _medida(prisma.largo + prisma.ancho + prisma.alto, 'cm³'),
    ],
    relleno: (n) => _medida(buena + n * prisma.alto, 'cm³'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.11',
    enunciado: '¿Cuál es el volumen de este prisma rectangular?',
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: _dibujoPrisma(prisma),
  );
}

ProblemaEso _areaPrisma(math.Random azar) {
  final prisma = _dimensionesPrisma(azar, 8);
  final buena = 2 * _tresCaras(prisma);
  final elegidas = opcionesConErrores(
    azar,
    _medida(buena, 'cm²'),
    [
      // Contar cada cara una sola vez.
      _medida(_tresCaras(prisma), 'cm²'),
      // Sólo las cuatro caras laterales.
      _medida(2 * (prisma.largo + prisma.ancho) * prisma.alto, 'cm²'),
      // El volumen en vez del área.
      _medida(prisma.largo * prisma.ancho * prisma.alto, 'cm²'),
    ],
    relleno: (n) => _medida(_cercano(buena, n, 2), 'cm²'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.11',
    enunciado:
        '¿Cuál es el área total de este prisma rectangular (sus seis caras)?',
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: _dibujoPrisma(prisma),
  );
}

ProblemaEso _litrosAcuario(math.Random azar) {
  final largo = _unoDe(azar, const [40, 50, 60, 80]);
  final ancho = _unoDe(azar, const [20, 30, 40]);
  final alto = _unoDe(azar, const [20, 30, 40, 50]);
  final centimetrosCubicos = largo * ancho * alto;
  final litros = centimetrosCubicos / 1000;
  final elegidas = opcionesConErrores(
    azar,
    _medida(litros, 'L'),
    [
      // Tomar los cm³ como litros.
      _medida(centimetrosCubicos, 'L'),
      // Dividir entre 100 en vez de entre 1000.
      _medida(centimetrosCubicos / 100, 'L'),
      // Dividir entre 10 000.
      _medida(centimetrosCubicos / 10000, 'L'),
    ],
    relleno: (n) => _medida(litros + n * 6, 'L'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.11',
    enunciado:
        'Un acuario del Mercado mide {l} cm de largo, {a} cm de ancho y {h} cm de alto. ¿Cuántos litros caben?',
    datos: {'l': '$largo', 'a': '$ancho', 'h': '$alto'},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: _dibujoPrisma((largo: largo, ancho: ancho, alto: alto)),
  );
}

VisualCuerpo _dibujoCilindro(int radio, int alto) =>
    VisualCuerpo(forma: FormaCuerpo.cilindro, medidas: {
      'radio': _medida(radio, 'cm'),
      'alto': _medida(alto, 'cm'),
    });

ProblemaEso _volumenCilindroPi(math.Random azar, int dificultad) {
  final radio = _entre(azar, 2, dificultad <= 2 ? 4 : 6);
  final alto = _entre(azar, 2, 10);
  final buena = radio * radio * alto;
  final elegidas = opcionesConErrores(
    azar,
    _conPi(buena, 'cm³'),
    [
      // No elevar el radio al cuadrado.
      _conPi(radio * alto, 'cm³'),
      // El área lateral en vez del volumen.
      _conPi(2 * radio * alto, 'cm³'),
      // Usar el diámetro como radio.
      _conPi(4 * radio * radio * alto, 'cm³'),
    ],
    relleno: (n) => _conPi(buena + n * radio, 'cm³'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.11',
    enunciado:
        '¿Cuál es el volumen de este cilindro? Exprésalo en función de π.',
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: _dibujoCilindro(radio, alto),
  );
}

ProblemaEso _volumenCilindro314(math.Random azar) {
  final radio = _entre(azar, 1, 5);
  final alto = _entre(azar, 2, 10);
  // En centésimas para que 3,14 · r² · h salga exacto.
  final buenaCentesimas = 314 * radio * radio * alto;
  final elegidas = opcionesConErrores(
    azar,
    _medida(buenaCentesimas / 100, 'cm³'),
    [
      // No elevar el radio al cuadrado.
      _medida(314 * radio * alto / 100, 'cm³'),
      // El área lateral en vez del volumen.
      _medida(2 * 314 * radio * alto / 100, 'cm³'),
      // Olvidar el π.
      _medida(radio * radio * alto, 'cm³'),
    ],
    relleno: (n) => _medida((buenaCentesimas + n * 314) / 100, 'cm³'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.11',
    enunciado: '¿Cuál es el volumen de este cilindro? Usa π ≈ 3,14.',
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: _dibujoCilindro(radio, alto),
  );
}

ProblemaEso _volumenCilindroDiametro(math.Random azar) {
  final radio = _entre(azar, 2, 6);
  final alto = _entre(azar, 3, 12);
  final buena = radio * radio * alto;
  final elegidas = opcionesConErrores(
    azar,
    _conPi(buena, 'cm³'),
    [
      // Usar el diámetro como radio.
      _conPi(4 * radio * radio * alto, 'cm³'),
      // Diámetro por altura, sin cuadrado.
      _conPi(2 * radio * alto, 'cm³'),
      // Radio sin elevar al cuadrado.
      _conPi(radio * alto, 'cm³'),
    ],
    relleno: (n) => _conPi(buena + n * alto, 'cm³'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.11',
    enunciado:
        'Un bote cilíndrico tiene {d} cm de diámetro y {h} cm de altura. ¿Cuál es su volumen en función de π?',
    datos: {'d': '${2 * radio}', 'h': '$alto'},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualCuerpo(
        forma: FormaCuerpo.cilindro, medidas: {'alto': _medida(alto, 'cm')}),
  );
}

ProblemaEso _areaCilindro(math.Random azar, {required bool total}) {
  final radio = _entre(azar, 2, 6);
  final alto = _entre(azar, 2, 10);
  final lateral = 2 * radio * alto;
  final bases = 2 * radio * radio;
  final buena = total ? lateral + bases : lateral;
  final errores = total
      ? [
          // Contar una sola base.
          _conPi(lateral + radio * radio, 'cm²'),
          // Sólo el área lateral.
          _conPi(lateral, 'cm²'),
          // Olvidar el 2 del área lateral.
          _conPi(radio * alto + bases, 'cm²'),
        ]
      : [
          // Olvidar el 2.
          _conPi(radio * alto, 'cm²'),
          // El volumen en vez del área.
          _conPi(radio * radio * alto, 'cm²'),
          // Sumarle las bases.
          _conPi(lateral + bases, 'cm²'),
        ];
  final elegidas = opcionesConErrores(
    azar,
    _conPi(buena, 'cm²'),
    errores,
    relleno: (n) => _conPi(buena + n * 2, 'cm²'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.11',
    enunciado: total
        ? '¿Cuál es el área total de este cilindro, con sus dos bases? Exprésala en función de π.'
        : '¿Cuál es el área lateral de este cilindro? Exprésala en función de π.',
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: _dibujoCilindro(radio, alto),
  );
}

// ── GEO.12 Pirámides, conos y esferas ───────────────────────────────

ProblemaEso _piramidesConosEsferas(math.Random azar, int dificultad) {
  final modelos = [
    'piramide',
    if (dificultad <= 4) 'comparar',
    if (dificultad >= 2) 'cono',
    if (dificultad >= 3) 'volumenEsfera',
    if (dificultad >= 3) 'areaEsfera',
    if (dificultad >= 6) 'esfera314',
    if (dificultad >= 6) 'lateralCono',
  ];
  return switch (_unoDe(azar, modelos)) {
    'comparar' => _conoFrenteCilindro(azar),
    'cono' => _volumenCono(azar),
    'volumenEsfera' => _volumenEsfera(azar, dificultad),
    'areaEsfera' => _areaEsfera(azar),
    'esfera314' => _volumenEsfera314(azar),
    'lateralCono' => _areaLateralCono(azar),
    _ => _volumenPiramide(azar, dificultad),
  };
}

/// Una altura que hace divisible entre 3 el producto base² · altura.
int _alturaDivisible(math.Random azar, int ladoBase, int maximo) =>
    ladoBase % 3 == 0
        ? _entre(azar, 2, maximo)
        : 3 * _entre(azar, 1, maximo ~/ 3);

ProblemaEso _volumenPiramide(math.Random azar, int dificultad) {
  final lado = _entre(azar, 2, dificultad <= 2 ? 6 : 10);
  final alto = _alturaDivisible(azar, lado, dificultad <= 2 ? 9 : 12);
  final prisma = lado * lado * alto;
  final buena = prisma ~/ 3;
  final elegidas = opcionesConErrores(
    azar,
    _medida(buena, 'cm³'),
    [
      // Olvidar el 1/3.
      _medida(prisma, 'cm³'),
      // Dividir entre 2 en vez de entre 3.
      _medida(prisma / 2, 'cm³'),
      // No elevar el lado al cuadrado.
      if (lado * alto % 3 == 0) _medida(lado * alto ~/ 3, 'cm³'),
    ],
    relleno: (n) => _medida(buena + n * lado, 'cm³'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.12',
    enunciado: '¿Cuál es el volumen de esta pirámide de base cuadrada?',
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualCuerpo(forma: FormaCuerpo.piramide, medidas: {
      'lado': _medida(lado, 'cm'),
      'alto': _medida(alto, 'cm'),
    }),
  );
}

ProblemaEso _conoFrenteCilindro(math.Random azar) {
  final cilindro = _entre(azar, 1, 8) * 6;
  final buena = cilindro ~/ 3;
  final elegidas = opcionesConErrores(
    azar,
    _medida(buena, 'L'),
    [
      // La mitad en vez de la tercera parte.
      _medida(cilindro ~/ 2, 'L'),
      // Lo mismo que el cilindro.
      _medida(cilindro, 'L'),
      // El triple en vez de la tercera parte.
      _medida(cilindro * 3, 'L'),
    ],
    relleno: (n) => _medida(buena + n, 'L'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.12',
    enunciado:
        'Un cono y un cilindro tienen la misma base y la misma altura. En el cilindro caben {v} L. ¿Cuántos litros caben en el cono?',
    datos: {'v': '$cilindro'},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: const VisualCuerpo(forma: FormaCuerpo.cono),
  );
}

ProblemaEso _volumenCono(math.Random azar) {
  final radio = _entre(azar, 2, 6);
  final alto = _alturaDivisible(azar, radio, 12);
  final cilindro = radio * radio * alto;
  final buena = cilindro ~/ 3;
  final elegidas = opcionesConErrores(
    azar,
    _conPi(buena, 'cm³'),
    [
      // Olvidar el 1/3.
      _conPi(cilindro, 'cm³'),
      // Usar el diámetro como radio.
      _conPi(4 * cilindro ~/ 3, 'cm³'),
      // No elevar el radio al cuadrado.
      if (radio * alto % 3 == 0) _conPi(radio * alto ~/ 3, 'cm³'),
    ],
    relleno: (n) => _conPi(buena + n * radio, 'cm³'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.12',
    enunciado: '¿Cuál es el volumen de este cono? Exprésalo en función de π.',
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualCuerpo(forma: FormaCuerpo.cono, medidas: {
      'radio': _medida(radio, 'cm'),
      'alto': _medida(alto, 'cm'),
    }),
  );
}

ProblemaEso _volumenEsfera(math.Random azar, int dificultad) {
  // Radio múltiplo de 3 para que 4/3 · r³ sea entero.
  final radio = _unoDe(azar, dificultad >= 6 ? const [3, 6, 9] : const [3, 6]);
  final cubo = radio * radio * radio;
  final buena = 4 * cubo ~/ 3;
  final elegidas = opcionesConErrores(
    azar,
    _conPi(buena, 'cm³'),
    [
      // Olvidar el 1/3.
      _conPi(4 * cubo, 'cm³'),
      // El área en vez del volumen.
      _conPi(4 * radio * radio, 'cm³'),
      // Elevar al cuadrado en vez de al cubo.
      _conPi(4 * radio * radio ~/ 3, 'cm³'),
    ],
    relleno: (n) => _conPi(buena + n * 12, 'cm³'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.12',
    enunciado: '¿Cuál es el volumen de esta esfera? Exprésalo en función de π.',
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualCuerpo(
        forma: FormaCuerpo.esfera, medidas: {'radio': _medida(radio, 'cm')}),
  );
}

ProblemaEso _areaEsfera(math.Random azar) {
  final radio = _entre(azar, 2, 10);
  final buena = 4 * radio * radio;
  final elegidas = opcionesConErrores(
    azar,
    _conPi(buena, 'cm²'),
    [
      // Olvidar el 4 (el área del círculo).
      _conPi(radio * radio, 'cm²'),
      // No elevar el radio al cuadrado.
      _conPi(4 * radio, 'cm²'),
      // Usar el diámetro como radio.
      _conPi(16 * radio * radio, 'cm²'),
    ],
    relleno: (n) => _conPi(buena + n * 4, 'cm²'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.12',
    enunciado: '¿Cuál es el área de esta esfera? Exprésala en función de π.',
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualCuerpo(
        forma: FormaCuerpo.esfera, medidas: {'radio': _medida(radio, 'cm')}),
  );
}

ProblemaEso _volumenEsfera314(math.Random azar) {
  final radio = _unoDe(azar, const [3, 6]);
  final diametro = 2 * radio;
  // En centésimas: 4 · 314 · r³ / 3 es entero con r múltiplo de 3.
  final buenaCentesimas = 4 * 314 * radio * radio * radio ~/ 3;
  final elegidas = opcionesConErrores(
    azar,
    _medida(buenaCentesimas / 100, 'cm³'),
    [
      // Usar el diámetro como radio.
      _medida(4 * 314 * diametro * diametro * diametro / 300, 'cm³'),
      // Olvidar el 1/3.
      _medida(4 * 314 * radio * radio * radio / 100, 'cm³'),
      // El área en vez del volumen.
      _medida(4 * 314 * radio * radio / 100, 'cm³'),
    ],
    relleno: (n) => _medida((buenaCentesimas + n * 314) / 100, 'cm³'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.12',
    enunciado:
        'Una pelota tiene {d} cm de diámetro. ¿Cuál es su volumen? Usa π ≈ 3,14.',
    datos: {'d': '$diametro'},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: const VisualCuerpo(forma: FormaCuerpo.esfera),
  );
}

ProblemaEso _areaLateralCono(math.Random azar) {
  // (radio, altura, generatriz): ternas pitagóricas.
  final (radio, alto, generatriz) = _unoDe(azar, const [
    (3, 4, 5),
    (4, 3, 5),
    (6, 8, 10),
    (8, 6, 10),
    (5, 12, 13),
    (9, 12, 15),
  ]);
  final buena = radio * generatriz;
  final elegidas = opcionesConErrores(
    azar,
    _conPi(buena, 'cm²'),
    [
      // Usar la altura en vez de la generatriz.
      _conPi(radio * alto, 'cm²'),
      // Sumarle la base (área total).
      _conPi(buena + radio * radio, 'cm²'),
      // Copiar el 2 del área lateral del cilindro (2 · π · r · g).
      _conPi(2 * buena, 'cm²'),
    ],
    relleno: (n) => _conPi(buena + n * radio, 'cm²'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.12',
    enunciado:
        'Un cono tiene {r} cm de radio y {h} cm de altura. ¿Cuál es su área lateral? Exprésala en función de π.',
    datos: {'r': '$radio', 'h': '$alto'},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualCuerpo(forma: FormaCuerpo.cono, medidas: {
      'radio': _medida(radio, 'cm'),
      'alto': _medida(alto, 'cm'),
    }),
  );
}

// ── GEO.13 Pitágoras en problemas ───────────────────────────────────

/// Ternas pitagóricas (cateto, cateto, hipotenusa) por dificultad.
List<(num, num, num)> _ternasPitagoricas(int dificultad) => [
      (3, 4, 5),
      (6, 8, 10),
      (9, 12, 15),
      if (dificultad >= 3) ...[(5, 12, 13), (8, 15, 17), (12, 16, 20)],
      if (dificultad >= 6) ...[(7, 24, 25), (20, 21, 29), (9, 40, 41)],
    ];

/// Escaleras en metros (pie, altura, largo), con el pie más cerca de la
/// pared que la altura.
List<(num, num, num)> _escaleras(int dificultad) => [
      (3, 4, 5),
      (6, 8, 10),
      if (dificultad >= 3) ...[(1.5, 2, 2.5), (5, 12, 13), (4.5, 6, 7.5)],
      if (dificultad >= 6) ...[(0.7, 2.4, 2.5), (1.8, 2.4, 3), (2.1, 2.8, 3.5)],
    ];

/// La raíz sin hacer, como distractor (`√125`), si el radicando es entero.
String? _raizSinHacer(num radicando, String unidad) {
  final redondeado = radicando.round();
  if (radicando <= 0 || (radicando - redondeado).abs() > 1e-9) return null;
  return '√$redondeado $unidad';
}

/// Errores al buscar la hipotenusa a partir de dos catetos.
List<String> _erroresHipotenusa(num catetoA, num catetoB, String unidad) => [
      // Sumar los catetos sin elevar al cuadrado.
      _medida(catetoA + catetoB, unidad),
      // Olvidar la raíz.
      _medida(catetoA * catetoA + catetoB * catetoB, unidad),
    ];

/// Errores al buscar un cateto a partir de la hipotenusa y el otro cateto.
List<String> _erroresCateto(num hipotenusa, num catetoConocido, String unidad) {
  final raizSumada = _raizSinHacer(
      hipotenusa * hipotenusa + catetoConocido * catetoConocido, unidad);
  return [
    // Restar los lados sin elevar al cuadrado.
    _medida(hipotenusa - catetoConocido, unidad),
    // Olvidar la raíz.
    _medida(hipotenusa * hipotenusa - catetoConocido * catetoConocido, unidad),
    // Sumar los cuadrados cuando hay que restarlos.
    if (raizSumada != null) raizSumada,
  ];
}

String Function(int) _rellenoPitagoras(num buena, String unidad) =>
    (n) => _medida(_cercano(buena, n, 1), unidad);

ProblemaEso _pitagorasProblemas(math.Random azar, int dificultad) {
  final modelos = [
    'barca',
    'pantalla',
    if (dificultad >= 2) 'escalera',
    if (dificultad >= 4) 'altoPantalla',
    if (dificultad >= 5) 'isosceles',
  ];
  return switch (_unoDe(azar, modelos)) {
    'pantalla' => _diagonalPantalla(azar, dificultad),
    'escalera' => _escalera(azar, dificultad),
    'altoPantalla' => _altoPantalla(azar),
    'isosceles' => _alturaIsosceles(azar, dificultad),
    _ => _barca(azar, dificultad),
  };
}

ProblemaEso _barca(math.Random azar, int dificultad) {
  final (primero, segundo, distancia) =
      _unoDe(azar, _ternasPitagoricas(dificultad));
  // Los catetos, en un orden u otro.
  final (norte, este) =
      azar.nextBool() ? (primero, segundo) : (segundo, primero);
  final elegidas = opcionesConErrores(
    azar,
    _medida(distancia, 'km'),
    _erroresHipotenusa(norte, este, 'km'),
    relleno: _rellenoPitagoras(distancia, 'km'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.13',
    enunciado:
        'Una barca sale del Puerto, navega {a} km hacia el norte y después {b} km hacia el este. ¿A qué distancia en línea recta está del punto de salida?',
    datos: {'a': formatearDecimal(norte), 'b': formatearDecimal(este)},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualFigura(forma: FormaPlana.trianguloRectangulo, medidas: {
      'cateto1': _medida(este, 'km'),
      'cateto2': _medida(norte, 'km'),
      'hipotenusa': '?',
    }),
  );
}

/// Pantallas con proporción 4:3 (ancho, alto, diagonal).
List<(int, int, int)> _pantallas(int dificultad) => [
      for (final factor
          in dificultad <= 2 ? const [5, 10, 12] : const [8, 12, 16])
        (4 * factor, 3 * factor, 5 * factor),
    ];

ProblemaEso _diagonalPantalla(math.Random azar, int dificultad) {
  final (ancho, alto, diagonal) = _unoDe(azar, _pantallas(dificultad));
  final elegidas = opcionesConErrores(
    azar,
    _medida(diagonal, 'cm'),
    _erroresHipotenusa(ancho, alto, 'cm'),
    relleno: _rellenoPitagoras(diagonal, 'cm'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.13',
    enunciado:
        'Una pantalla mide {a} cm de ancho y {b} cm de alto. ¿Cuánto mide su diagonal?',
    datos: {'a': '$ancho', 'b': '$alto'},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualFigura(forma: FormaPlana.rectangulo, medidas: {
      'base': _medida(ancho, 'cm'),
      'alto': _medida(alto, 'cm'),
    }),
  );
}

ProblemaEso _altoPantalla(math.Random azar) {
  final (ancho, alto, diagonal) = _unoDe(azar, _pantallas(4));
  final elegidas = opcionesConErrores(
    azar,
    _medida(alto, 'cm'),
    _erroresCateto(diagonal, ancho, 'cm'),
    relleno: _rellenoPitagoras(alto, 'cm'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.13',
    enunciado:
        'La diagonal de una pantalla mide {c} cm y su ancho, {a} cm. ¿Cuánto mide de alto?',
    datos: {'c': '$diagonal', 'a': '$ancho'},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualFigura(forma: FormaPlana.rectangulo, medidas: {
      'base': _medida(ancho, 'cm'),
      'alto': '?',
    }),
  );
}

ProblemaEso _escalera(math.Random azar, int dificultad) {
  final (distanciaPie, alturaPared, largo) =
      _unoDe(azar, _escaleras(dificultad));
  final elegidas = opcionesConErrores(
    azar,
    _medida(alturaPared, 'm'),
    _erroresCateto(largo, distanciaPie, 'm'),
    relleno: _rellenoPitagoras(alturaPared, 'm'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.13',
    enunciado:
        'Una escalera de {l} m está apoyada en una pared. Su pie está a {d} m de la pared. ¿A qué altura de la pared llega?',
    datos: {'l': formatearDecimal(largo), 'd': formatearDecimal(distanciaPie)},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualFigura(forma: FormaPlana.trianguloRectangulo, medidas: {
      'cateto1': _medida(distanciaPie, 'm'),
      'cateto2': '?',
      'hipotenusa': _medida(largo, 'm'),
    }),
  );
}

ProblemaEso _alturaIsosceles(math.Random azar, int dificultad) {
  // (mitad de la base, altura, lado igual).
  final (mitadBase, altura, ladoIgual) = _unoDe(azar, [
    (3, 4, 5),
    (4, 3, 5),
    (6, 8, 10),
    (8, 6, 10),
    (5, 12, 13),
    (12, 5, 13),
    if (dificultad >= 6) ...[(8, 15, 17), (15, 8, 17), (12, 9, 15)],
  ]);
  final base = 2 * mitadBase;
  final conBaseEntera =
      _raizSinHacer(ladoIgual * ladoIgual - base * base, 'cm');
  final elegidas = opcionesConErrores(
    azar,
    _medida(altura, 'cm'),
    [
      // Usar la base entera en vez de la mitad.
      if (conBaseEntera != null) conBaseEntera,
      // Restar los lados sin elevar al cuadrado.
      _medida(ladoIgual - mitadBase, 'cm'),
      // Olvidar la raíz.
      _medida(ladoIgual * ladoIgual - mitadBase * mitadBase, 'cm'),
    ],
    relleno: _rellenoPitagoras(altura, 'cm'),
  );
  return ProblemaEso(
    idHabilidad: 'GEO.13',
    enunciado:
        'Un triángulo isósceles tiene los dos lados iguales de {l} cm y la base de {b} cm. ¿Cuánto mide su altura? (El dibujo muestra la mitad del triángulo.)',
    datos: {'l': '$ladoIgual', 'b': '$base'},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
    visual: VisualFigura(forma: FormaPlana.trianguloRectangulo, medidas: {
      'cateto1': _medida(mitadBase, 'cm'),
      'cateto2': '?',
      'hipotenusa': _medida(ladoIgual, 'cm'),
    }),
  );
}
