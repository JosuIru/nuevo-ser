/// Traducciones del Arco V (La Montaña, Era 3) y del combate con Velo:
/// castellano → [euskera, catalán]. Borrador pendiente de revisión
/// nativa, como el resto de la narrativa. `traducirNarrativa` las
/// consulta si la línea no está en los mapas generales.
const Map<String, List<String>> narrativaArcoCinco = {
  'La carta': ['Gutuna', 'La carta'],
  'Afueras. Tarde. El despacho de Brina: libros apilados en el suelo, una ventana que da a la Montaña.':
      [
    'Kanpoaldea. Arratsaldea. Brinaren bulegoa: liburuak lurrean pilatuta, Mendira ematen duen leiho bat.',
    'Afores. Tarda. El despatx de Brina: llibres apilats a terra, una finestra que dona a la Muntanya.'
  ],
  'Pasa. Cierra, que entra el viento.': [
    'Sartu. Itxi, haizea sartzen da eta.',
    'Passa. Tanca, que entra el vent.'
  ],
  'Te he llamado por esto.': [
    'Honengatik deitu dizut.',
    'T\'he cridat per això.'
  ],
  'Una hoja doblada en cuatro. Papel grueso, húmedo en los bordes. No hay palabras: sólo letras sueltas, igualdades y una x rodeada con un círculo.':
      [
    'Lautan tolestutako orri bat. Paper lodia, hezea ertzetan. Ez dago hitzik: letra solteak, berdintzak eta zirkulu batez inguratutako x bat besterik ez.',
    'Un full plegat en quatre. Paper gruixut, humit a les vores. No hi ha paraules: només lletres soltes, igualtats i una x encerclada.'
  ],
  'Me escribe así desde hace doce años.': [
    'Hamabi urte daramatza niri horrela idazten.',
    'Fa dotze anys que m\'escriu així.'
  ],
  'Nunca una palabra. Sólo cuentas.': [
    'Hitz bat ere ez, inoiz. Kontuak bakarrik.',
    'Mai una paraula. Només comptes.'
  ],
  '¿Sabes quién?': ['Badakizu nork?', 'Saps qui?'],
  '¿El Algebrista?': ['Algebralariak?', 'L\'Algebrista?'],
  'Sí. Ahora ya lo sabes tú también.': [
    'Bai. Orain zuk ere badakizu.',
    'Sí. Ara ja ho saps tu també.'
  ],
  '¿Por qué en cuentas?': ['Zergatik kontuetan?', 'Per què en comptes?'],
  'Porque una cuenta no se puede leer a medias.': [
    'Kontu bat ezin delako erdizka irakurri.',
    'Perquè un compte no es pot llegir a mitges.'
  ],
  '— mirar la hoja —': ['— orriari begiratu —', '— mirar el full —'],
  'Mírala. Sin prisa.': [
    'Begira iezaiozu. Presarik gabe.',
    'Mira\'l. Sense pressa.'
  ],
  'Ésta es distinta. Mira abajo.': [
    'Hau desberdina da. Begiratu behean.',
    'Aquest és diferent. Mira a baix.'
  ],
  'Debajo de las letras, una frase de verdad, con letra apretada: «La niebla baja. Cuarenta metros cada semana. Está a mil doscientos metros del Borde.»':
      [
    'Letren azpian, benetako esaldi bat, letra estuz: «Lainoa jaisten ari da. Berrogei metro astero. Ertzetik mila eta berrehun metrora dago.»',
    'Sota les lletres, una frase de debò, amb lletra atapeïda: «La boira baixa. Quaranta metres cada setmana. És a mil dos-cents metres de la Vora.»'
  ],
  'Es la primera frase que me escribe en doce años.': [
    'Hamabi urtean idatzi didan lehen esaldia da.',
    'És la primera frase que m\'escriu en dotze anys.'
  ],
  'Cuarenta metros cada semana. Mil doscientos. ¿Cuánto tarda en llegar?': [
    'Berrogei metro astero. Mila eta berrehun. Zenbat behar du iristeko?',
    'Quaranta metres cada setmana. Mil dos-cents. Quant triga a arribar?'
  ],
  'Treinta semanas': ['Hogeita hamar aste', 'Trenta setmanes'],
  'Treinta. Eso me sale a mí.': [
    'Hogeita hamar. Hori ateratzen zait niri ere.',
    'Trenta. És el que em surt a mi.'
  ],
  'Cuarenta y ocho semanas': [
    'Berrogeita zortzi aste',
    'Quaranta-vuit setmanes'
  ],
  'No. Mil doscientos entre cuarenta. Treinta.': [
    'Ez. Mila eta berrehun zati berrogei. Hogeita hamar.',
    'No. Mil dos-cents entre quaranta. Trenta.'
  ],
  'No lo sé': ['Ez dakit', 'No ho sé'],
  'Mil doscientos entre cuarenta. Treinta semanas.': [
    'Mila eta berrehun zati berrogei. Hogeita hamar aste.',
    'Mil dos-cents entre quaranta. Trenta setmanes.'
  ],
  'Siete meses.': ['Zazpi hilabete.', 'Set mesos.'],
  'Cuando llegue al Borde, los Fragmentos viejos bajarán con ella.': [
    'Ertzera iristen denean, Zati zaharrak berarekin jaitsiko dira.',
    'Quan arribi a la Vora, els Fragments vells baixaran amb ella.'
  ],
  'Al pie de la hoja, un dibujo pequeño: una brújula.': [
    'Orriaren oinean, marrazki txiki bat: iparrorratz bat.',
    'Al peu del full, un dibuix petit: una brúixola.'
  ],
  'Esto no lo entendía. Hasta que he visto lo que llevas en el bolsillo.': [
    'Hau ez nuen ulertzen. Poltsikoan daramazuna ikusi dudan arte.',
    'Això no ho entenia. Fins que he vist el que portes a la butxaca.'
  ],
  'La brújula vieja de Sora pesa un poco más.': [
    'Soraren iparrorratz zaharrak pixka bat gehiago pisatzen du.',
    'La brúixola vella de Sora pesa una mica més.'
  ],
  'Quiere que subas. Tú y quien te la dio.': [
    'Igo zaitezen nahi du. Zuk eta hura eman zizunak.',
    'Vol que hi pugis. Tu i qui te la va donar.'
  ],
  'Antes de nada, habla con Irune.': [
    'Ezer baino lehen, hitz egin Irunerekin.',
    'Abans de res, parla amb Irune.'
  ],
  'Y no le digas que te he mandado yo.': [
    'Eta ez esan nik bidali zaitudala.',
    'I no li diguis que t\'he enviat jo.'
  ],
  'Irune no sube': ['Irune ez da igotzen', 'Irune no hi puja'],
  'Tejados. Noche. Irune riega las macetas de la azotea con una lata vieja.': [
    'Teilatuak. Gaua. Irunek teilatu laueko loreontziak ureztatzen ditu lata zahar batekin.',
    'Terrats. Nit. Irune rega els testos del terrat amb una llauna vella.'
  ],
  'Te esperaba antes.': ['Lehenago espero zintudan.', 'T\'esperava abans.'],
  'Le enseñas la hoja. No la coge. La mira desde lejos.': [
    'Orria erakusten diozu. Ez du hartzen. Urrunetik begiratzen dio.',
    'Li ensenyes el full. No l\'agafa. El mira de lluny.'
  ],
  'Escucha.': ['Entzun.', 'Escolta.'],
  'Hace cuarenta años subimos dos. Bajé una.': [
    'Duela berrogei urte bi igo ginen. Bat jaitsi zen: ni.',
    'Fa quaranta anys hi vam pujar dues. En va baixar una: jo.'
  ],
  'Deja la lata en el suelo.': [
    'Lata lurrean uzten du.',
    'Deixa la llauna a terra.'
  ],
  'Yo iba a quedarme arriba. Todos lo daban por hecho. Yo también.': [
    'Ni goian geratzekoa nintzen. Denek hala uste zuten. Nik ere bai.',
    'Jo m\'havia de quedar a dalt. Tothom ho donava per fet. Jo també.'
  ],
  'Una noche hubo niebla. Mucha. Y tuve miedo de no volver a ver esta ciudad.':
      [
    'Gau batean lainoa egon zen. Asko. Eta beldur izan nintzen hiri hau berriro ez ikusteko.',
    'Una nit hi va haver boira. Molta. I vaig tenir por de no tornar a veure aquesta ciutat.'
  ],
  'Bajé. La otra se quedó.': [
    'Jaitsi nintzen. Bestea geratu zen.',
    'Vaig baixar. L\'altra es va quedar.'
  ],
  '¿La otra es quien escribe?': [
    'Bestea da idazten duena?',
    'L\'altra és qui escriu?'
  ],
  '¿Te arrepientes?': ['Damutzen zara?', 'Te\'n penedeixes?'],
  'Todos los días. Y ninguno.': ['Egunero. Eta inoiz ez.', 'Cada dia. I cap.'],
  '— no decir nada —': ['— ezer ez esan —', '— no dir res —'],
  'No me pidas que suba. No voy a subir.': [
    'Ez eskatu igotzeko. Ez naiz igoko.',
    'No em demanis que hi pugi. No hi pujaré.'
  ],
  'Pero tampoco te voy a decir que no subas.': [
    'Baina ez dizut esango ez igotzeko ere.',
    'Però tampoc no et diré que no hi pugis.'
  ],
  'Antes, ve al Archivo. Pregunta por la página de Iria.': [
    'Lehenago, joan Artxibora. Galdetu Iriaren orriaz.',
    'Abans, ves a l\'Arxiu. Pregunta per la pàgina d\'Iria.'
  ],
  'Si el guardián te la enseña, es que ha llegado el momento.': [
    'Zaindariak erakusten badizu, garaia iritsi da.',
    'Si el guardià te l\'ensenya, és que ha arribat el moment.'
  ],
  'Vuelve a coger la lata. Riega una maceta que ya estaba regada.': [
    'Lata berriro hartzen du. Jada ureztatuta zegoen loreontzi bat ureztatzen du.',
    'Torna a agafar la llauna. Rega un test que ja estava regat.'
  ],
  'El Archivo': ['Artxiboa', 'L\'Arxiu'],
  'El Archivo de la Sociedad. Un sótano largo bajo el cuartel de las Afueras. Estanterías hasta el techo. Huele a papel y a café frío.':
      [
    'Elkartearen Artxiboa. Soto luze bat Kanpoaldeko kuartelaren azpian. Apalak sabairaino. Paper eta kafe hotz usaina dago.',
    'L\'Arxiu de la Societat. Un soterrani llarg sota la caserna d\'Afores. Prestatges fins al sostre. Fa olor de paper i de cafè fred.'
  ],
  'Cuidado con el tercer escalón. Lleva cuatrocientos años suelto.': [
    'Kontuz hirugarren mailarekin. Laurehun urte daramatza askatuta.',
    'Compte amb el tercer esglaó. Fa quatre-cents anys que està solt.'
  ],
  'Un hombre mayor, con unas gafas en la frente y otras en la nariz.': [
    'Gizon nagusi bat, betaurreko batzuk kopetan eta beste batzuk sudurrean.',
    'Un home gran, amb unes ulleres al front i unes altres al nas.'
  ],
  'Ulden. Guardo esto. No viene nunca nadie, así que me alegro de verte.': [
    'Ulden. Hau zaintzen dut. Ez da inoiz inor etortzen, beraz pozten naiz zu ikusteaz.',
    'Ulden. Custodio això. No hi ve mai ningú, així que m\'alegro de veure\'t.'
  ],
  'Te manda Irune. Lo sé porque traes la misma cara que traía ella.': [
    'Irunek bidali zaitu. Badakit, berak zekarren aurpegi bera dakarzulako.',
    'T\'envia Irune. Ho sé perquè portes la mateixa cara que portava ella.'
  ],
  'La página de Iria.': ['Iriaren orria.', 'La pàgina d\'Iria.'],
  'Silencio largo. Ulden se quita las gafas de la nariz. Se deja las de la frente.':
      [
    'Isiltasun luzea. Uldenek sudurreko betaurrekoak kentzen ditu. Kopetakoak uzten ditu.',
    'Silenci llarg. Ulden es treu les ulleres del nas. Es deixa les del front.'
  ],
  'Iria de Tres Voces escribió mucho. Casi todo se publicó. Esto no.': [
    'Hiru Ahotseko Iriak asko idatzi zuen. Ia dena argitaratu zen. Hau ez.',
    'Iria de Tres Veus va escriure molt. Gairebé tot es va publicar. Això no.'
  ],
  'Una caja de madera. Dentro, una sola página: una cuadrícula, dos ejes y cuatro puntos en tinta. (0, 0). (2, 3). (5, 3). (7, 6).':
      [
    'Egurrezko kutxa bat. Barruan, orri bakar bat: lauki-sare bat, bi ardatz eta tintazko lau puntu. (0, 0). (2, 3). (5, 3). (7, 6).',
    'Una capsa de fusta. A dins, una sola pàgina: una quadrícula, dos eixos i quatre punts de tinta. (0, 0). (2, 3). (5, 3). (7, 6).'
  ],
  'Durante cuatrocientos años hemos creído que era un ejercicio.': [
    'Laurehun urtez ariketa bat zela uste izan dugu.',
    'Durant quatre-cents anys hem cregut que era un exercici.'
  ],
  'No lo es. Es un camino.': ['Ez da. Bide bat da.', 'No ho és. És un camí.'],
  'Coordenadas': ['Koordenatuak', 'Coordenades'],
  'Eso. Pares de números: el primero dice cuánto andas; el segundo, cuánto subes.':
      [
    'Hori. Zenbaki bikoteak: lehenengoak dio zenbat ibiltzen zaren; bigarrenak, zenbat igotzen zaren.',
    'Això. Parells de nombres: el primer diu quant camines; el segon, quant puges.'
  ],
  'Un mapa': ['Mapa bat', 'Un mapa'],
  'Casi. Un mapa que no dibuja el paisaje: sólo dice cómo cambia.': [
    'Ia. Paisaia marrazten ez duen mapa bat: nola aldatzen den bakarrik esaten du.',
    'Gairebé. Un mapa que no dibuixa el paisatge: només diu com canvia.'
  ],
  'Nadie lo supo en cuatrocientos años. Tranquilidad.': [
    'Laurehun urtean inork ez zuen jakin. Lasai.',
    'Ningú no ho va saber en quatre-cents anys. Tranquil·litat.'
  ],
  'El origen, el (0, 0), es el Borde Oscuro. Lo he comprobado yo mismo. Con un mapa, claro.':
      [
    'Jatorria, (0, 0) puntua, Ertz Iluna da. Neuk egiaztatu dut. Mapa batekin, noski.',
    'L\'origen, el (0, 0), és la Vora Fosca. Ho he comprovat jo mateix. Amb un mapa, és clar.'
  ],
  'Llévatela. Iria la escribió para quien fuera a subir. Hasta hoy no había nadie.':
      [
    'Eraman ezazu. Iriak igotzera zihoanarentzat idatzi zuen. Gaur arte ez zen inor egon.',
    'Emporta-te-la. Iria la va escriure per a qui hagués de pujar. Fins avui no hi havia ningú.'
  ],
  'Y tráemela de vuelta. Aunque sea mojada.': [
    'Eta ekarri berriro. Bustita bada ere.',
    'I torna-me-la. Encara que sigui mullada.'
  ],
  'La página de Iria': ['Iriaren orria', 'La pàgina d\'Iria'],
  'Tejados. Sora y tú, sentados, con la página de Iria entre los dos. La Montaña al fondo.':
      [
    'Teilatuak. Sora eta zu, eserita, Iriaren orria bien artean. Mendia hondoan.',
    'Terrats. Sora i tu, a terra, amb la pàgina d\'Iria al mig. La Muntanya al fons.'
  ],
  'Así que era esto.': ['Hau zen, beraz.', 'Així que era això.'],
  'Léela tú. A mí las gráficas me marean.': [
    'Irakur ezazu zuk. Grafikoek zorabiatu egiten naute.',
    'Llegeix-la tu. A mi els gràfics em marregen.'
  ],
  'Unidos, los puntos hacen una línea con escalones: sube, se queda plana, vuelve a subir.':
      [
    'Batuta, puntuek mailaka doan lerro bat osatzen dute: igo egiten da, lau geratzen da, berriro igotzen da.',
    'Units, els punts fan una línia amb graons: puja, es queda plana, torna a pujar.'
  ],
  '¿Qué pasa entre el 2 y el 5?': [
    'Zer gertatzen da 2aren eta 5aren artean?',
    'Què passa entre el 2 i el 5?'
  ],
  'No sube: es llano': ['Ez da igotzen: laua da', 'No puja: és pla'],
  'Un descansillo. Ahí se duerme.': [
    'Eskailburu bat. Han egiten da lo.',
    'Un replà. Allà s\'hi dorm.'
  ],
  'Baja': ['Jaisten da', 'Baixa'],
  'Mira otra vez. El segundo número no cambia: tres y tres. Es llano.': [
    'Begiratu berriro. Bigarren zenbakia ez da aldatzen: hiru eta hiru. Laua da.',
    'Mira-ho un altre cop. El segon nombre no canvia: tres i tres. És pla.'
  ],
  'Sube más deprisa': ['Azkarrago igotzen da', 'Puja més de pressa'],
  'Tres y tres. No sube nada. Es llano.': [
    'Hiru eta hiru. Ez da batere igotzen. Laua da.',
    'Tres i tres. No puja gens. És pla.'
  ],
  'Un llano a media subida. Iria dormía ahí.': [
    'Zelai bat igoeraren erdian. Iriak han egiten zuen lo.',
    'Un pla a mitja pujada. Iria dormia allà.'
  ],
  'Y lo último, del 5 al 7, sube tres de golpe. Lo más empinado.': [
    'Eta azkena, 5etik 7ra, hiru igotzen da bat-batean. Aldapatsuena.',
    'I l\'últim tram, del 5 al 7, puja tres de cop. El més costerut.'
  ],
  'Sora dobla la página con cuidado. Tarda en hablar.': [
    'Sorak kontu handiz tolesten du orria. Denbora behar du hitz egiteko.',
    'Sora plega la pàgina amb compte. Triga a parlar.'
  ],
  'Te lo prometí en el borde. Que subíamos juntos.': [
    'Ertzean agindu nizun. Elkarrekin igoko ginela.',
    'T\'ho vaig prometre a la vora. Que pujaríem tu i jo.'
  ],
  'Pensaba que tardaríamos años.': [
    'Urteak beharko genituela uste nuen.',
    'Pensava que trigaríem anys.'
  ],
  'No pasa nada. Las promesas no avisan.': [
    'Ez da ezer gertatzen. Promesek ez dute abisatzen.',
    'No passa res. Les promeses no avisen.'
  ],
  'La sombra de la Montaña': ['Mendiaren itzala', 'L\'ombra de la Muntanya'],
  'El Borde Oscuro. La última farola. Brina clava un palo en la tierra. Atardecer: las sombras son largas.':
      [
    'Ertz Iluna. Azken farola. Brinak makila bat sartzen du lurrean. Ilunabarra: itzalak luzeak dira.',
    'La Vora Fosca. L\'últim fanal. Brina clava un pal a terra. Capvespre: les ombres són llargues.'
  ],
  'Iria midió la Montaña sin subir. Vamos a hacer lo mismo.': [
    'Iriak Mendia neurtu zuen igo gabe. Gauza bera egingo dugu.',
    'Iria va mesurar la Muntanya sense pujar-hi. Farem el mateix.'
  ],
  'El palo mide dos metros. Su sombra, tres.': [
    'Makilak bi metro neurtzen ditu. Bere itzalak, hiru.',
    'El pal fa dos metres. La seva ombra, tres.'
  ],
  'Y la sombra de la cumbre acaba justo a tres mil metros de la base.': [
    'Eta gailurraren itzala oinarritik hiru mila metrora amaitzen da, zehazki.',
    'I l\'ombra del cim acaba just a tres mil metres de la base.'
  ],
  'Mismo sol, misma forma. ¿Cuánto mide la Montaña?': [
    'Eguzki bera, forma bera. Zenbat neurtzen du Mendiak?',
    'Mateix sol, mateixa forma. Quant fa la Muntanya?'
  ],
  'Dos mil metros': ['Bi mila metro', 'Dos mil metres'],
  'Dos mil. Lo mismo que le salió a Iria.': [
    'Bi mila. Iriari atera zitzaion bera.',
    'Dos mil. El mateix que li va sortir a Iria.'
  ],
  'Cuatro mil quinientos metros': [
    'Lau mila eta bostehun metro',
    'Quatre mil cinc-cents metres'
  ],
  'Al revés. El palo es más bajo que su sombra; la Montaña, también. Dos mil.':
      [
    'Alderantziz. Makila bere itzala baino baxuagoa da; Mendia ere bai. Bi mila.',
    'Al revés. El pal és més baix que la seva ombra; la Muntanya, també. Dos mil.'
  ],
  'Dos mil novecientos noventa y nueve': [
    'Bi mila bederatziehun eta laurogeita hemeretzi',
    'Dos mil nou-cents noranta-nou'
  ],
  'No se resta. Se multiplica por la misma razón: dos tercios. Dos mil.': [
    'Ez da kentzen. Arrazoi berarekin biderkatzen da: bi heren. Bi mila.',
    'No es resta. Es multiplica per la mateixa raó: dos terços. Dos mil.'
  ],
  'Y la niebla está a mil doscientos. Ya ha bajado de la mitad.': [
    'Eta lainoa mila eta berrehunean dago. Erdia baino beherago jaitsi da jada.',
    'I la boira és a mil dos-cents. Ja ha baixat de la meitat.'
  ],
  'Esto es lo que me gusta de Tales. No hace falta tocar las cosas para saber cuánto miden.':
      [
    'Horixe gustatzen zait Talesez. Ez dago gauzak ukitu beharrik zenbat neurtzen duten jakiteko.',
    'Això és el que m\'agrada de Tales. No cal tocar les coses per saber quant fan.'
  ],
  'Brina arranca el palo y se lo pone al hombro.': [
    'Brinak makila ateratzen du eta sorbaldan jartzen du.',
    'Brina arrenca el pal i se\'l posa a l\'espatlla.'
  ],
  'Cuando subáis, yo me quedo aquí. Alguien tiene que mirar la niebla desde abajo.':
      [
    'Igotzen zaretenean, ni hemen geratuko naiz. Norbaitek begiratu behar dio lainoari behetik.',
    'Quan pugeu, jo em quedo aquí. Algú ha de mirar la boira des de baix.'
  ],
  'Cruzar el Borde': ['Ertza zeharkatu', 'Travessar la Vora'],
  'Antes del alba. El Borde Oscuro. Sora, con una mochila demasiado grande. Tú, con la brújula.':
      [
    'Egunsentia baino lehen. Ertz Iluna. Sora, motxila handiegi batekin. Zu, iparrorratzarekin.',
    'Abans de l\'alba. La Vora Fosca. Sora, amb una motxilla massa gran. Tu, amb la brúixola.'
  ],
  'Alguien corre hacia vosotros desde la última farola. Kai.': [
    'Norbait korrika dator zuengana azken farolatik. Kai.',
    'Algú corre cap a vosaltres des de l\'últim fanal. Kai.'
  ],
  'No os vais sin despediros. No es educado.': [
    'Ez zoazte agur esan gabe. Hori ez da polita.',
    'No marxeu sense acomiadar-vos. No és educat.'
  ],
  'Un termo abollado, con una pegatina del Puerto.': [
    'Termo koskatu bat, Portuko pegatina batekin.',
    'Un termo abonyegat, amb un adhesiu del Port.'
  ],
  'Era de mi madre. Lo quiero de vuelta.': [
    'Nire amarena zen. Bueltan nahi dut.',
    'Era de la meva mare. El vull de tornada.'
  ],
  'Te lo devuelvo': ['Itzuliko dizut', 'Te\'l tornaré'],
  'Más te vale.': ['Hobe duzu.', 'Més et val.'],
  'Ven con nosotros': ['Etorri gurekin', 'Vine amb nosaltres'],
  'No. Alguien tiene que quedarse a ganar a los de abajo.': [
    'Ez. Norbaitek hemen geratu behar du behekoei irabazteko.',
    'No. Algú s\'ha de quedar a guanyar els de baix.'
  ],
  '— chocar la mano —': ['— bostekoa eman —', '— xocar-li la mà —'],
  'Vale. Vale. Idos ya.': [
    'Ados. Ados. Zoazte behingoz.',
    'D\'acord. D\'acord. Marxeu ja.'
  ],
  'Kai se va sin mirar atrás. Sora mira la línea donde acaba la luz. No se mueve.':
      [
    'Kai atzera begiratu gabe joaten da. Sorak argia amaitzen den lerroari begiratzen dio. Ez da mugitzen.',
    'Kai se\'n va sense mirar enrere. Sora mira la línia on s\'acaba la llum. No es mou.'
  ],
  'En Kir también había un borde.': [
    'Kirren ere bazen ertz bat.',
    'A Kir també hi havia una vora.'
  ],
  'Nunca lo crucé. Cuando quise, ya no había ciudad.': [
    'Ez nuen inoiz zeharkatu. Nahi izan nuenean, jada ez zegoen hiririk.',
    'No la vaig travessar mai. Quan vaig voler, ja no hi havia ciutat.'
  ],
  'Da un paso. Luego otro. La farola queda detrás.': [
    'Urrats bat ematen du. Gero beste bat. Farola atzean geratzen da.',
    'Fa un pas. Després un altre. El fanal queda enrere.'
  ],
  'Ya está. Era sólo un paso.': [
    'Kitto. Urrats bat besterik ez zen.',
    'Ja està. Només era un pas.'
  ],
  'La niebla': ['Lainoa', 'La boira'],
  'El llano de Iria. Mil doscientos metros. La niebla llega de golpe: blanca, espesa, fría.':
      [
    'Iriaren zelaia. Mila eta berrehun metro. Lainoa bat-batean dator: zuria, lodia, hotza.',
    'El pla d\'Iria. Mil dos-cents metres. La boira arriba de cop: blanca, espessa, freda.'
  ],
  'No veo nada.': ['Ez dut ezer ikusten.', 'No hi veig res.'],
  'Algo se mueve dentro de la niebla. Un Fragmento sin forma: cuando lo miras, los números que llevas encima se borran.':
      [
    'Zerbait mugitzen da lainoaren barruan. Formarik gabeko Zati bat: begiratzen diozunean, gainean daramatzazun zenbakiak ezabatu egiten dira.',
    'Alguna cosa es mou dins la boira. Un Fragment sense forma: quan el mires, els nombres que portes a sobre s\'esborren.'
  ],
  'Contaste los pasos hasta aquí. Ya no recuerdas cuántos. Donde estaba el número, hay un hueco.':
      [
    'Hona arteko urratsak zenbatu zenituen. Jada ez duzu gogoratzen zenbat. Zenbakia zegoen lekuan, hutsune bat dago.',
    'Vas comptar els passos fins aquí. Ja no recordes quants. On hi havia el nombre, hi ha un buit.'
  ],
  '¿Cuántos?': ['Zenbat?', 'Quants?'],
  'No lo sabes. Aquí arriba nadie lo sabe.': [
    'Ez dakizu. Hemen goian inork ez daki.',
    'No ho saps. Aquí dalt ningú no ho sap.'
  ],
  'Es un Fragmento viejo. De los que se esconden.': [
    'Zati zahar bat da. Ezkutatzen direnetakoa.',
    'És un Fragment vell. Dels que s\'amaguen.'
  ],
  '{nombre}. Brina dice que lo que no se ve se puede nombrar. No sé qué significa.':
      [
    '{nombre}. Brinak dio ikusten ez dena izendatu daitekeela. Ez dakit zer esan nahi duen.',
    '{nombre}. Brina diu que el que no es veu es pot anomenar. No sé què vol dir.'
  ],
  'Nómbralo, si puedes.': ['Izendatu, ahal baduzu.', 'Anomena\'l, si pots.'],
  'Detrás de la niebla': ['Lainoaren atzean', 'Darrere la boira'],
  'La niebla se retira ladera arriba, como un animal que no quiere pelea. Detrás, una mujer mayor con un farol apagado.':
      [
    'Lainoa maldan gora erretiratzen da, borrokarik nahi ez duen animalia bat bezala. Atzean, emakume nagusi bat farol itzali batekin.',
    'La boira es retira vessant amunt, com un animal que no vol baralla. Al darrere, una dona gran amb una llanterna apagada.'
  ],
  'Lo has nombrado.': ['Izendatu duzu.', 'L\'has anomenat.'],
  'Hacía mucho que nadie de abajo lo nombraba.': [
    'Aspaldian ez zuen behetik inork izendatzen.',
    'Feia molt que ningú de baix no l\'anomenava.'
  ],
  'Venid. Está a punto de hacer frío de verdad.': [
    'Zatozte. Benetako hotza egitear dago.',
    'Veniu. Està a punt de fer fred de debò.'
  ],
  'La niebla os rodea. Entonces se abre sola, como una cortina. En medio, una mujer mayor con un farol apagado.':
      [
    'Lainoak inguratu egiten zaituzte. Orduan bere kasa irekitzen da, gortina bat bezala. Erdian, emakume nagusi bat farol itzali batekin.',
    'La boira us envolta. Llavors s\'obre sola, com una cortina. Al mig, una dona gran amb una llanterna apagada.'
  ],
  'Suficiente.': ['Nahikoa.', 'Prou.'],
  'Velo se retira ladera arriba.': [
    'Velo maldan gora erretiratzen da.',
    'Velo es retira vessant amunt.'
  ],
  'No te preocupes. A mí me costó once años.': [
    'Ez kezkatu. Niri hamaika urte kostatu zitzaizkidan.',
    'No et preocupis. A mi em va costar onze anys.'
  ],
  'La Algebrista': ['Algebralaria', 'L\'Algebrista'],
  'Una casa de piedra pegada a la roca, a mil quinientos metros. Dentro, una estufa y una mesa llena de papeles. Las paredes, escritas con tiza de arriba abajo.':
      [
    'Harrizko etxe bat harkaitzari itsatsita, mila eta bostehun metrotan. Barruan, berogailu bat eta paperez betetako mahai bat. Hormak, klarionez idatzita goitik behera.',
    'Una casa de pedra arrapada a la roca, a mil cinc-cents metres. A dins, una estufa i una taula plena de papers. Les parets, escrites amb guix de dalt a baix.'
  ],
  'Aldara.': ['Aldara.', 'Aldara.'],
  'Abajo me llaman «el Algebrista». Nunca he sabido si es por no preguntar o por no subir a ver.':
      [
    'Behean «Algebralaria» deitzen didate, inork ezer galdetu gabe. Ez dut inoiz jakin galdetzen ez dutelako den, ala ikustera igotzen ez direlako.',
    'A baix em diuen «l\'Algebrista» i donen per fet que soc un home. Mai no he sabut si és per no preguntar o per no pujar a veure-ho.'
  ],
  'Brina te escribe.': ['Brinak idazten dizu.', 'Brina t\'escriu.'],
  'Brina me contesta. No es lo mismo.': [
    'Brinak erantzuten dit. Ez da gauza bera.',
    'Brina em contesta. No és el mateix.'
  ],
  'Una pregunta cada uno. Aquí arriba se piensa despacio.': [
    'Galdera bana. Hemen goian poliki pentsatzen da.',
    'Una pregunta cadascú. Aquí dalt es pensa a poc a poc.'
  ],
  '¿De qué lado estás?': ['Zein aldetan zaude?', 'De quin costat estàs?'],
  'Del lado de la Montaña. Los Fragmentos viejos vienen aquí a esconderse. Yo me quedo para que no bajen.':
      [
    'Mendiaren aldean. Zati zaharrak hona etortzen dira ezkutatzera. Ni hemen geratzen naiz jaitsi ez daitezen.',
    'Del costat de la Muntanya. Els Fragments vells venen aquí a amagar-se. Jo em quedo perquè no baixin.'
  ],
  '¿Qué es Velo?': ['Zer da Velo?', 'Què és Velo?'],
  'Uno de los primeros. No come proporción: come lo que sabes. Te deja los huecos.':
      [
    'Lehenetako bat. Ez du proportziorik jaten: dakizuna jaten du. Hutsuneak uzten dizkizu.',
    'Un dels primers. No menja proporció: menja el que saps. Et deixa els buits.'
  ],
  '¿Por qué nos has llamado?': [
    'Zergatik deitu gaituzu?',
    'Per què ens has cridat?'
  ],
  'Porque la niebla baja. Y porque yo sola ya no puedo subirla.': [
    'Lainoa jaisten ari delako. Eta nik bakarrik ezin dudalako jada gora eraman.',
    'Perquè la boira baixa. I perquè jo sola ja no la puc fer pujar.'
  ],
  'Yo pregunto otra cosa.': [
    'Nik beste gauza bat galdetzen dut.',
    'Jo pregunto una altra cosa.'
  ],
  '¿Por qué la brújula?': ['Zergatik iparrorratza?', 'Per què la brúixola?'],
  'Aldara coge la brújula de tus manos. La gira. En la tapa hay una marca que no habías visto: una x pequeña.':
      [
    'Aldarak iparrorratza hartzen dizu eskuetatik. Biratu egiten du. Estalkian ikusi ez zenuen marka bat dago: x txiki bat.',
    'Aldara t\'agafa la brúixola de les mans. La gira. A la tapa hi ha una marca que no havies vist: una x petita.'
  ],
  'Porque la hice yo. Hace cuarenta años. Para alguien que bajó.': [
    'Nik egin nuelako. Duela berrogei urte. Jaitsi zen norbaitentzat.',
    'Perquè la vaig fer jo. Fa quaranta anys. Per a algú que va baixar.'
  ],
  'Sora se queda muy quieta.': [
    'Sora geldi-geldi geratzen da.',
    'Sora es queda molt quieta.'
  ],
  'A mí me la dio Irune.': [
    'Niri Irunek eman zidan.',
    'A mi me la va donar Irune.'
  ],
  'Dormid. Mañana empezamos.': [
    'Egin lo. Bihar hasiko gara.',
    'Dormiu. Demà comencem.'
  ],
  'La primera lección': ['Lehen ikasgaia', 'La primera lliçó'],
  'Mañana. La niebla queda abajo, como un mar. Aldara escribe en la pared con tiza.':
      [
    'Hurrengo goiza. Lainoa behean geratzen da, itsaso bat bezala. Aldarak horman idazten du klarionez.',
    'L\'endemà al matí. La boira queda a baix, com un mar. Aldara escriu a la paret amb guix.'
  ],
  'Abajo contáis lo que veis. Tres manzanas. Cinco puentes.': [
    'Behean ikusten duzuena zenbatzen duzue. Hiru sagar. Bost zubi.',
    'A baix compteu el que veieu. Tres pomes. Cinc ponts.'
  ],
  'Aquí arriba casi nada se ve. Hay que contar lo que no está.': [
    'Hemen goian ia ezer ez da ikusten. Ez dagoena zenbatu behar da.',
    'Aquí dalt gairebé no es veu res. Cal comptar el que no hi és.'
  ],
  'Escribe una x grande. La rodea con un círculo, como en las cartas.': [
    'x handi bat idazten du. Zirkulu batez inguratzen du, gutunetan bezala.',
    'Escriu una x grossa. L\'encercla, com a les cartes.'
  ],
  'Esto no es un número que no sabes.': [
    'Hau ez da ezagutzen ez duzun zenbaki bat.',
    'Això no és un nombre que no saps.'
  ],
  'Es el nombre que le pones mientras tanto. Para poder hablar de él.': [
    'Bitartean jartzen diozun izena da. Hartaz hitz egin ahal izateko.',
    'És el nom que li poses mentrestant. Per poder-ne parlar.'
  ],
  'Cuando algo tiene nombre, puedes decir lo que sabes de él. Y lo que sabes, a veces, basta.':
      [
    'Zerbaitek izena duenean, hartaz dakizuna esan dezakezu. Eta dakizuna, batzuetan, nahikoa da.',
    'Quan una cosa té nom, pots dir el que en saps. I, de vegades, amb el que saps n\'hi ha prou.'
  ],
  'Tengo el triple de años que Sora, más veinticuatro. Sora tiene trece. ¿Cómo lo escribes?':
      [
    'Soraren urteen hirukoitza ditut, gehi hogeita lau. Sorak hamahiru ditu. Nola idazten duzu?',
    'Tinc el triple d\'anys que Sora, més vint-i-quatre. Sora en té tretze. Com ho escrius?'
  ],
  'a = 3 · 13 + 24': ['a = 3 · 13 + 24', 'a = 3 · 13 + 24'],
  'Eso. Y si no supieras la edad de Sora, pondrías una s en su sitio.': [
    'Hori. Eta Soraren adina jakingo ez bazenu, s bat jarriko zenuke haren lekuan.',
    'Això. I si no sabessis l\'edat de Sora, posaries una s al seu lloc.'
  ],
  '3 · a + 24 = 13': ['3 · a + 24 = 13', '3 · a + 24 = 13'],
  'Al revés. El triple es de los años de Sora, no de los míos.': [
    'Alderantziz. Hirukoitza Soraren urteena da, ez nireena.',
    'Al revés. El triple és dels anys de Sora, no dels meus.'
  ],
  'a = 3 · (13 + 24)': ['a = 3 · (13 + 24)', 'a = 3 · (13 + 24)'],
  'Sin paréntesis. El triple de Sora, y luego los veinticuatro.': [
    'Parentesirik gabe. Soraren hirukoitza, eta gero hogeita lauak.',
    'Sense parèntesi. El triple de Sora, i després els vint-i-quatre.'
  ],
  'Sesenta y tres.': ['Hirurogeita hiru.', 'Seixanta-tres.'],
  'Sesenta y tres. No se lo digas a Irune: cree que tengo más.': [
    'Hirurogeita hiru. Ez esan Iruneri: gehiago ditudala uste du.',
    'Seixanta-tres. No li ho diguis a Irune: es pensa que en tinc més.'
  ],
  'Abajo cazáis acertando el número. Aquí arriba se gana escribiendo la relación.':
      [
    'Behean zenbakia asmatuz ehizatzen duzue. Hemen goian erlazioa idatziz irabazten da.',
    'A baix caceu encertant el nombre. Aquí dalt es guanya escrivint la relació.'
  ],
  'Iria lo sabía.': ['Iriak bazekien.', 'Iria ho sabia.'],
  'Iria lo inventó. Por eso no la entendió nadie.': [
    'Iriak asmatu zuen. Horregatik ez zuen inork ulertu.',
    'Iria ho va inventar. Per això no la va entendre ningú.'
  ],
  'La cisterna': ['Zisterna', 'La cisterna'],
  'Detrás de la casa, un depósito de piedra redondo, medio lleno de agua de nieve.':
      [
    'Etxearen atzean, harrizko ur-biltegi biribil bat, erdi beteta elur-urez.',
    'Darrere la casa, un dipòsit de pedra rodó, mig ple d\'aigua de neu.'
  ],
  'Un metro de radio. Dos metros de agua. Con eso paso el invierno.': [
    'Metro bateko erradioa. Bi metro ur. Horrekin ematen dut negua.',
    'Un metre de radi. Dos metres d\'aigua. Amb això passo l\'hivern.'
  ],
  'Pi, tres coma catorce. ¿Cuántos litros son?': [
    'Pi, hiru koma hamalau. Zenbat litro dira?',
    'Pi, tres coma catorze. Quants litres són?'
  ],
  '6280 litros': ['6280 litro', '6280 litres'],
  'Seis metros cúbicos y pico. Seis mil doscientos ochenta litros.': [
    'Sei metro kubiko eta pixka bat. Sei mila berrehun eta laurogei litro.',
    'Sis metres cúbics i escaig. Sis mil dos-cents vuitanta litres.'
  ],
  '6,28 litros': ['6,28 litro', '6,28 litres'],
  'Eso son metros cúbicos. Cada uno, mil litros.': [
    'Hori metro kubikoak dira. Bakoitza, mila litro.',
    'Això són metres cúbics. Cadascun, mil litres.'
  ],
  '12 560 litros': ['12 560 litro', '12 560 litres'],
  'Eso es la pared, no el agua. El volumen es la base por la altura.': [
    'Hori horma da, ez ura. Bolumena oinarria bider altuera da.',
    'Això és la paret, no l\'aigua. El volum és la base per l\'alçada.'
  ],
  'Si no nieva, no llega.': [
    'Elurrik egiten ez badu, ez da iristen.',
    'Si no neva, no arriba.'
  ],
  'Aldara no te mira cuando pregunta.': [
    'Aldarak ez dizu begiratzen galdetzen duenean.',
    'Aldara no et mira quan pregunta.'
  ],
  '¿Cómo está?': ['Nola dago?', 'Com està?'],
  'Riega macetas ya regadas': [
    'Ureztatutako loreontziak ureztatzen ditu',
    'Rega testos ja regats'
  ],
  'Siempre lo hizo.': ['Beti egin izan du.', 'Sempre ho ha fet.'],
  'Dice que no va a subir': ['Ez dela igoko dio', 'Diu que no hi pujarà'],
  'Ya lo sé. No se lo pido.': [
    'Badakit. Ez diot eskatzen.',
    'Ja ho sé. No l\'hi demano.'
  ],
  'Creo que te echa de menos': [
    'Zure falta sumatzen duela uste dut',
    'Crec que et troba a faltar'
  ],
  'Eso lo dices tú. Pero gracias.': [
    'Hori zuk diozu. Baina eskerrik asko.',
    'Això ho dius tu. Però gràcies.'
  ],
  'Cuando bajéis, le llevaréis una cosa.': [
    'Jaisten zaretenean, gauza bat eramango diozue.',
    'Quan baixeu, li portareu una cosa.'
  ],
  'Lo que escribió Iria': ['Iriak idatzi zuena', 'El que va escriure Iria'],
  'Noche. La estufa. Aldara saca una caja igual que la del Archivo. Dentro, otra página. La letra es la misma.':
      [
    'Gaua. Berogailua. Aldarak Artxibokoaren berdina den kutxa bat ateratzen du. Barruan, beste orri bat. Letra bera da.',
    'Nit. L\'estufa. Aldara treu una capsa igual que la de l\'Arxiu. A dins, una altra pàgina. La lletra és la mateixa.'
  ],
  'Ulden tiene la primera mitad. Yo, la segunda.': [
    'Uldenek lehen erdia du. Nik, bigarrena.',
    'Ulden té la primera meitat. Jo, la segona.'
  ],
  'Iria la partió en dos para que nadie la leyera sin subir.': [
    'Iriak bitan zatitu zuen, inork igo gabe irakur ez zezan.',
    'Iria la va partir en dues perquè ningú no la llegís sense pujar.'
  ],
  'Dos igualdades con dos letras. Y debajo, una frase.': [
    'Bi berdintza bi letrarekin. Eta azpian, esaldi bat.',
    'Dues igualtats amb dues lletres. I a sota, una frase.'
  ],
  'x + y = 7. x − y = 1. ¿Cuánto vale x?': [
    'x + y = 7. x − y = 1. Zenbat balio du x-k?',
    'x + y = 7. x − y = 1. Quant val x?'
  ],
  '4': ['4', '4'],
  'Cuatro, y la y vale tres. Cuatro jornadas de subida; tres de bajada.': [
    'Lau, eta y-k hiru balio du. Lau egun igotzeko; hiru jaisteko.',
    'Quatre, i la y val tres. Quatre jornades de pujada; tres de baixada.'
  ],
  '3': ['3', '3'],
  'Ése es y. Suma las dos igualdades: la y desaparece. x vale cuatro.': [
    'Hori y da. Batu bi berdintzak: y desagertu egiten da. x-k lau balio du.',
    'Aquesta és la y. Suma les dues igualtats: la y desapareix. x val quatre.'
  ],
  '7': ['7', '7'],
  'Siete es la suma. Suma las dos igualdades y divide entre dos: cuatro.': [
    'Zazpi batura da. Batu bi berdintzak eta zatitu bitan: lau.',
    'Set és la suma. Suma les dues igualtats i divideix entre dos: quatre.'
  ],
  'Las cuentas dicen cuánto se tarda. La frase dice para qué subir.': [
    'Kontuek diote zenbat behar den. Esaldiak dio zertarako igo.',
    'Els comptes diuen quant es triga. La frase diu per a què pujar.'
  ],
  'Aldara no mira la página. Se la sabe.': [
    'Aldarak ez dio orriari begiratzen. Buruz daki.',
    'Aldara no mira la pàgina. Se la sap.'
  ],
  '«El Uno no volverá a ser uno. Será muchos que se entienden.»': [
    '«Bata ez da berriro bat izango. Elkar ulertzen duten asko izango da.»',
    '«L\'U no tornarà a ser u. Serà molts que s\'entenen.»'
  ],
  'Silencio. La estufa cruje.': [
    'Isiltasuna. Berogailuak kirrinka egiten du.',
    'Silenci. L\'estufa cruix.'
  ],
  'Eso es lo que dicen los Opacos.': [
    'Hori esaten dute Opakoek.',
    'Això és el que diuen els Opacs.'
  ],
  'No. Los Opacos dicen que da igual que no se entiendan.': [
    'Ez. Opakoek diote berdin dela elkar ez ulertzea.',
    'No. Els Opacs diuen que tant se val que no s\'entenguin.'
  ],
  'Iria decía que el trabajo es ése: que se entiendan.': [
    'Iriak zioen hori dela lana: elkar ulertzea.',
    'Iria deia que la feina és aquesta: que s\'entenguin.'
  ],
  'Por eso no se publicó. A la Sociedad le gusta más reparar que entender.': [
    'Horregatik ez zen argitaratu. Elkarteari gehiago gustatzen zaio konpontzea ulertzea baino.',
    'Per això no es va publicar. A la Societat li agrada més reparar que entendre.'
  ],
  '¿Y tú qué crees?': ['Eta zuk zer uste duzu?', 'I tu què en penses?'],
  'Que llevo cuarenta años aquí arriba escribiendo relaciones. Saca la cuenta.':
      [
    'Berrogei urte daramatzadala hemen goian erlazioak idazten. Atera kontua.',
    'Que fa quaranta anys que soc aquí dalt escrivint relacions. Fes-ne el compte.'
  ],
  'Bajar': ['Jaitsi', 'Baixar'],
  'Amanecer. La niebla se ha retirado cien metros ladera arriba. No es mucho. Es algo.':
      [
    'Egunsentia. Lainoa ehun metro erretiratu da maldan gora. Ez da asko. Zerbait da.',
    'Alba. La boira s\'ha retirat cent metres vessant amunt. No és gaire. És alguna cosa.'
  ],
  'Velo ha retrocedido. No se ha ido.': [
    'Velok atzera egin du. Ez da joan.',
    'Velo ha retrocedit. No se n\'ha anat.'
  ],
  'Volveréis. Cuando sepáis más letras.': [
    'Itzuliko zarete. Letra gehiago dakizuenean.',
    'Tornareu. Quan sapigueu més lletres.'
  ],
  'Te da un sobre cerrado, sin nombre.': [
    'Gutunazal itxi bat ematen dizu, izenik gabe.',
    'Et dona un sobre tancat, sense nom.'
  ],
  'Para Irune. Si lo abres, no te vuelvo a abrir la puerta.': [
    'Irunerentzat. Irekitzen baduzu, ez dizut atea berriro irekiko.',
    'Per a Irune. Si l\'obres, no et torno a obrir la porta.'
  ],
  'La brújula quédatela. Ahora es tuya de verdad.': [
    'Iparrorratza gorde ezazu. Orain benetan zurea da.',
    'La brúixola, queda-te-la. Ara és teva de debò.'
  ],
  'Gracias, Aldara': ['Eskerrik asko, Aldara', 'Gràcies, Aldara'],
  'Gracias a ti. Hacía años que no hablaba en voz alta con nadie.': [
    'Eskerrik asko zuri. Urteak ziren inorekin ozen hitz egiten ez nuela.',
    'Gràcies a tu. Feia anys que no parlava en veu alta amb ningú.'
  ],
  'Alguien tiene que quedarse arriba. Irune lo sabía. Por eso bajó.': [
    'Norbaitek goian geratu behar du. Irunek bazekien. Horregatik jaitsi zen.',
    'Algú s\'ha de quedar a dalt. Irune ho sabia. Per això va baixar.'
  ],
  '— asentir —': ['— baiezkoa eman —', '— assentir —'],
  'Eso. Aquí arriba se habla poco.': [
    'Hori. Hemen goian gutxi hitz egiten da.',
    'Això. Aquí dalt es parla poc.'
  ],
  'Bajáis. Sora va delante. En el llano de Iria se para y mira atrás.': [
    'Jaisten zarete. Sora aurretik doa. Iriaren zelaian gelditu eta atzera begiratzen du.',
    'Baixeu. Sora va davant. Al pla d\'Iria s\'atura i mira enrere.'
  ],
  'Pensaba que la Montaña era el final.': [
    'Mendia amaiera zela uste nuen.',
    'Pensava que la Muntanya era el final.'
  ],
  'Es otra ciudad. Más pequeña. Con una sola persona.': [
    'Beste hiri bat da. Txikiagoa. Pertsona bakar batekin.',
    'És una altra ciutat. Més petita. Amb una sola persona.'
  ],
  'La carta de Irune': ['Iruneren gutuna', 'La carta d\'Irune'],
  'Tejados. Tarde. Irune en la azotea, como siempre, con la lata.': [
    'Teilatuak. Arratsaldea. Irune teilatu lauan, beti bezala, latarekin.',
    'Terrats. Tarda. Irune al terrat, com sempre, amb la llauna.'
  ],
  'Le das el sobre. Esta vez lo coge.': [
    'Gutunazala ematen diozu. Oraingoan hartu egiten du.',
    'Li dones el sobre. Aquesta vegada l\'agafa.'
  ],
  'Lo abre. Dentro no hay letras sueltas: hay palabras. Una sola línea.': [
    'Ireki egiten du. Barruan ez dago letra solterik: hitzak daude. Lerro bakar bat.',
    'L\'obre. A dins no hi ha lletres soltes: hi ha paraules. Una sola línia.'
  ],
  'Irune lee. Deja la lata en el suelo.': [
    'Irunek irakurri egiten du. Lata lurrean uzten du.',
    'Irune llegeix. Deixa la llauna a terra.'
  ],
  'Dice que hice bien en bajar.': [
    'Jaistean ondo egin nuela dio.',
    'Diu que vaig fer bé de baixar.'
  ],
  'Que alguien tenía que enseñar a los de abajo.': [
    'Norbaitek behekoei irakatsi behar ziela.',
    'Que algú havia d\'ensenyar els de baix.'
  ],
  'Irune mira la Montaña mucho rato.': [
    'Irunek denbora luzez begiratzen dio Mendiari.',
    'Irune mira la Muntanya molta estona.'
  ],
  'Cuarenta años.': ['Berrogei urte.', 'Quaranta anys.'],
  'Y me lo dice en una línea.': [
    'Eta lerro batean esaten dit.',
    'I m\'ho diu en una línia.'
  ],
  'Guarda la carta en el bolsillo del pecho.': [
    'Gutuna bularreko poltsikoan gordetzen du.',
    'Es guarda la carta a la butxaca del pit.'
  ],
  'Devuélvele la página a Ulden. Y el termo a Kai.': [
    'Itzuli orria Uldeni. Eta termoa Kairi.',
    'Torna-li la pàgina a Ulden. I el termo a Kai.'
  ],
  'Y luego descansa. Vas a subir más veces.': [
    'Eta gero atseden hartu. Gehiagotan igoko zara.',
    'I després descansa. Hi pujaràs més vegades.'
  ],
  'En el borde norte, Sora, con las piernas colgando. Te hace sitio.': [
    'Iparraldeko ertzean, Sora, hankak zintzilik. Tokia egiten dizu.',
    'A la vora nord, Sora, amb les cames penjant. Et fa lloc.'
  ],
  'Cumplí.': ['Hitza bete nuen.', 'Vaig complir.'],
  'La próxima vez, subes tú delante.': [
    'Hurrengoan, zu igoko zara aurretik.',
    'La propera vegada, puges tu davant.'
  ],
  'FIN DEL ARCO V. LA MONTAÑA.': [
    'V. ARKUAREN AMAIERA. MENDIA.',
    'FI DE L\'ARC V. LA MUNTANYA.'
  ],
  'Velo tapa un número: 3 · ▢ − 5 = 16. ¿Cuál es?': [
    'Velok zenbaki bat estaltzen du: 3 · ▢ − 5 = 16. Zein da?',
    'Velo tapa un nombre: 3 · ▢ − 5 = 16. Quin és?'
  ],
  'La niebla se espesa. Deshaz la cuenta al revés.': [
    'Lainoa loditu egiten da. Desegin kontua atzetik aurrera.',
    'La boira s\'espesseix. Desfés el compte al revés.'
  ],
  'El doble de un número, más cuatro, es dieciocho. ¿Qué número es?': [
    'Zenbaki baten bikoitza, gehi lau, hemezortzi da. Zein zenbaki da?',
    'El doble d\'un nombre, més quatre, és divuit. Quin nombre és?'
  ],
  'Escríbelo primero: 2x + 4 = 18.': [
    'Idatzi lehenengo: 2x + 4 = 18.',
    'Escriu-ho primer: 2x + 4 = 18.'
  ],
  '2 · (▢ + 4) = 18. ¿Qué número tapa?': [
    '2 · (▢ + 4) = 18. Zein zenbaki estaltzen du?',
    '2 · (▢ + 4) = 18. Quin nombre tapa?'
  ],
  'El dos multiplica a todo el paréntesis.': [
    'Biak parentesi osoa biderkatzen du.',
    'El dos multiplica tot el parèntesi.'
  ],
  '▢/2 + ▢/3 = 10. Es el mismo número las dos veces. ¿Cuál?': [
    '▢/2 + ▢/3 = 10. Bi aldietan zenbaki bera da. Zein?',
    '▢/2 + ▢/3 = 10. És el mateix nombre les dues vegades. Quin?'
  ],
  'Busca un denominador común. Seis.': [
    'Bilatu izendatzaile komun bat. Sei.',
    'Busca un denominador comú. Sis.'
  ],
  'x + y = 14 y x − y = 4. ¿Cuánto vale x?': [
    'x + y = 14 eta x − y = 4. Zenbat balio du x-k?',
    'x + y = 14 i x − y = 4. Quant val x?'
  ],
  'Suma las dos igualdades. La y desaparece.': [
    'Batu bi berdintzak. y desagertu egiten da.',
    'Suma les dues igualtats. La y desapareix.'
  ],
  'La niebla se abre un palmo.': [
    'Lainoa arra bat irekitzen da.',
    'La boira s\'obre un pam.'
  ],
  'Velo se cierra. Alguien sale de la niebla.': [
    'Velo ixten da. Norbait ateratzen da lainotik.',
    'Velo es tanca. Algú surt de la boira.'
  ],
  'Velo se deshace en gotas. Hay alguien detrás.': [
    'Velo tantatan desegiten da. Norbait dago atzean.',
    'Velo es desfà en gotes. Hi ha algú al darrere.'
  ],
};
