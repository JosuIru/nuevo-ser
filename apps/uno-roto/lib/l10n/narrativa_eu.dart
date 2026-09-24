/// Traducciones de narrativa al euskera.
///
/// Clave: texto literal en castellano (la fuente canónica vive en los
/// archivos `.dart` del dominio narrativo). Valor: traducción al
/// euskera. Si una clave no está aquí, [traducirNarrativa] devuelve el
/// castellano original como fallback.
///
/// PENDIENTE DE REVISIÓN HUMANA: las traducciones automáticas pueden
/// no respetar la voz de cada personaje (Sora seca, Kurz murmurando,
/// Eco con poesía). Revisor nativo necesario antes de release.
const Map<String, String> narrativaEu = <String, String>{
  'Una azotea. Noche azul-violeta. Viento.': 'Teilatu bat. Gau urdin-bioleta. Haizea.',
  'Llegas tarde.': 'Berandu zatoz.',
  'Siempre llegáis tarde.': 'Beti zatozte berandu.',
  'Sora se gira despacio.': 'Sora poliki jiratzen da.',
  '{nombre}, ¿verdad?': '{nombre}, ezta?',
  'Mm.': 'Mm.',
  'Señala al horizonte. Una montaña oscura.': 'Zerumugara seinalatzen du. Mendi ilun bat.',
  'Eso es la Montaña. Hoy no.': 'Hori da Mendia. Gaur ez.',
  'Vale. Escucha. No te lo voy a decir dos veces.': 'Ondo. Entzun. Ez dizut bi aldiz esango.',
  'Esta ciudad tiene Fragmentos. Se comen cosas que no se ven. Nosotros los cazamos.': 'Hiri honek Zatiak ditu. Ikusten ez diren gauzak jaten dituzte. Guk ehizatzen ditugu.',
  'Te acabas de alistar. No sabes lo que haces. Tranquilo, nadie lo sabe al principio.': 'Oraintxe izena eman duzu. Ez dakizu zer ari zaren egiten. Lasai, inork ez daki hasieran.',
  'Yo voy a enseñarte.': 'Nik irakatsiko dizut.',
  '¿Vienes a entrenar, o has venido a mirar?': 'Entrenatzera zatoz, edo begiratzera etorri zara?',
  'Bien.': 'Ondo.',
  'Ya lo verás. Sígueme.': 'Ikusiko duzu. Jarraitu niri.',
  'Vale. Sígueme y miras.': 'Ondo. Jarraitu niri eta begiratu.',
  'AZULA — EDIFICIO DE LOS TEJADOS': 'AZULA — TEILATUEN ERAIKINA',
  'Una azotea contigua. Algo flota sobre el suelo.': 'Aldameneko teilatu bat. Zerbait flotatzen ari da lurraren gainean.',
  'Eso.': 'Hori.',
  'Eso es un Fragmento. Pequeño. Inofensivo, casi.': 'Hori Zati bat da. Txikia. Kalterik gabea, ia.',
  'Es un Pleno. Vale uno. Un entero. ¿Ves?': 'Oso bat da. Bat balio du. Oso bat. Ikusten?',
  'Dividirlo es romperlo en partes iguales. Prueba.': 'Hura zatitzea zati berdinetan haustea da. Saiatu.',
  'Un medio. Eso es un medio.': 'Erdi bat. Hori erdi bat da.',
  'Se llama desfragmentar.': 'Desfragmentatzea deitzen zaio.',
  'No los matas. Los vuelves al sitio del que salieron.': 'Ez dituzu hiltzen. Atera ziren tokira itzularazten dituzu.',
  'Vamos.': 'Goazen.',
  'Callejón trasero. Una farola amarilla parpadea.': 'Atzeko kalezuloa. Argi-zutoin hori batek keinu egiten du.',
  'Un gato cruza. Una mujer mayor, parada frente a una puerta.': 'Katu bat zeharkatzen ari da. Emakume nagusi bat, ate baten aurrean geldirik.',
  'Mira.': 'Begiratu.',
  'Lleva así un rato. No recuerda por qué ha venido.': 'Aspaldi hor dago. Ez du gogoratzen zergatik etorri den.',
  'Eso pasa cuando hay Fragmentos cerca. No muchos. No fuertes. Pero suficientes.': 'Hori gertatzen da Zatiak gertu daudenean. Ez asko. Ez indartsuak. Baina nahikoa.',
  'Por eso los cazamos.': 'Horregatik ehizatzen ditugu.',
  'La mujer se va. Se mueve bien. Solo desajustada.': 'Emakumea badoa. Ondo mugitzen da. Apur bat aldratuta soilik.',
  '¿Preguntas?': 'Galderarik?',
  'Seguramente. Los Fragmentos de aquí son pequeños. Se le pasa en una hora.': 'Seguruenik. Hemengo Zatiak txikiak dira. Ordubetean joango zaio.',
  'Muchos. Siempre.': 'Asko. Beti.',
  'No. Casi nadie sabe.': 'Ez. Ia inork ez daki.',
  'Vamos. Irune te está esperando.': 'Goazen. Irune zain duzu.',
  'Sala interior. Luz cálida. Libros. Una puerta con la placa ARCHIVO.': 'Barneko gela. Argi epela. Liburuak. Ate bat ARTXIBOA plakarekin.',
  'Irune sentada. Pelo blanco, chaqueta gris, marca de plata al cuello.': 'Irune eserita. Ile zuria, jaka grisa, zilarrezko marka lepoan.',
  'Llegas. Pasa.': 'Iritsi zara. Sartu.',
  'Soy Irune. Esta es mi casa, y también la tuya ahora, si te lo tomas en serio.': 'Irune naiz. Hau nire etxea da, eta zurea ere bai orain, serio hartzen baduzu.',
  'Sora te va a enseñar. Es la mejor que tengo ahora mismo. No se lo digas.': 'Sorak irakatsiko dizu. Oraintxe dudan onena da. Ez esan berari.',
  'Sora al fondo mira al suelo.': 'Sora hondoan lurrera begira.',
  'Tres cosas, {nombre}. Escucha.': 'Hiru gauza, {nombre}. Entzun.',
  'Primera. Aquí nadie sabe más de lo que sabe. Si alguien te dice que lo sabe todo, desconfía. Aunque sea yo.': 'Lehena. Hemen inork ez daki dakiena baino gehiago. Norbaitek dena dakiela esaten badizu, ez fidatu. Ni izanda ere.',
  'Segunda. Los Fragmentos no son enemigos. Son pedazos de algo que se rompió. Los desfragmentamos. Eso es todo.': 'Bigarrena. Zatiak ez dira etsaiak. Hautsi zen zerbaiten puskak dira. Desfragmentatu egiten ditugu. Hori da dena.',
  'Tercera. Si te cansas, paras. Si necesitas irte, te vas. Esto no es una cárcel.': 'Hirugarrena. Nekatzen bazara, gelditu. Joan behar baduzu, joan. Hau ez da kartzela.',
  'Vete con ella ya. Yo tengo cosas que hacer.': 'Joan berarekin orain. Nik egitekoak ditut.',
  'Al salir, Sora casi sin girarse:': 'Irtetean, Sorak ia jiratu gabe:',
  'Cae bien, Irune. Cuando quiere.': 'Atsegina da, Irune. Nahi duenean.',
  'De vuelta a la azotea. La noche más cerrada.': 'Teilatura itzulita. Gaua itxiagoa.',
  'Mejor.': 'Hobeto.',
  'No tan mal.': 'Ez hain gaizki.',
  'Vale. Hoy tienes un regalo.': 'Ondo. Gaur opari bat duzu.',
  'Sora silba. Algo grande baja del cielo.': 'Sorak txistu egiten du. Zerbait handi bat zerutik jaisten da.',
  'Brazos largos. Cabeza redonda. Ojos. Sobre él, el valor 3/4.': 'Beso luzeak. Buru biribila. Begiak. Beraren gainean, 3/4 balioa.',
  'Otro.': 'Beste bat.',
  'Pequeño.': 'Txikia.',
  'Es Kurz. Lleva aquí más tiempo que yo. Es un Fragmento nombrado. No se disuelve — se retira y vuelve.': 'Kurz da. Ni baino denbora gehiago darama hemen. Izendun Zati bat da. Ez da desegiten — atzera egiten du eta itzultzen da.',
  'Sirve para poneros a prueba. No es malo.': 'Zuek probatzeko balio du. Ez da txarra.',
  'Pero es mejor que tú. Todavía.': 'Baina zu baino hobea da. Oraindik.',
  '¿Empezamos?': 'Hasiko gara?',
  'El combate llega y se va. No hay forma de ganar hoy.': 'Borroka iritsi eta joan egiten da. Ezin da gaur irabazi.',
  'Muy lento.': 'Oso poliki.',
  'Otra vez mal.': 'Berriro gaizki.',
  'Tenías que haberlo visto venir.': 'Datorrela ikusi behar zenuen.',
  'Kurz se acerca. Calmo.': 'Kurz hurbiltzen da. Lasai.',
  'Ya está. No pasa nada.': 'Jada. Ez da ezer gertatzen.',
  'Negro. La azotea vuelve. Sentado en el suelo. Kurz se aleja.': 'Beltza. Teilatua itzultzen da. Lurrean eserita. Kurz aldentzen da.',
  'Sora se acerca. Tiende la mano.': 'Sora hurbiltzen da. Eskua luzatzen du.',
  'En serio. Bien.': 'Benetan. Ondo.',
  'La primera vez se pierde. Siempre. Yo también perdí contra Kurz mi primera vez.': 'Lehen aldian galdu egiten da. Beti. Nik ere galdu nuen Kurzen aurka lehen aldian.',
  'Y la segunda.': 'Eta bigarrena.',
  'Y la tercera.': 'Eta hirugarrena.',
  'Primera media sonrisa. Apenas un ángulo de la boca.': 'Lehen irribarre erdia. Ahoaren angelu bat besterik ez.',
  'La cuarta gané. Y no se olvida.': 'Laugarrenean irabazi nuen. Eta ez da ahazten.',
  'Kurz va a volver. Cuando estés listo, vuelves tú a él. Y le ganas.': 'Kurz itzuliko da. Prest zaudenean, zu itzuliko zara berarengana. Eta irabaziko diozu.',
  '¿Lo pillas?': 'Ulertzen duzu?',
  'Puedes. No hoy. Pero puedes.': 'Egin dezakezu. Gaur ez. Baina egin dezakezu.',
  'Vale. Vamos a descansar.': 'Ondo. Atseden hartzera goaz.',
  'Otra noche. Punto elevado de la azotea. Otro aprendiz entrena a 30 metros.': 'Beste gau bat. Teilatuko puntu altua. Beste ikastun bat 30 metrora entrenatzen.',
  'Se mueve con soltura. No es el primer día que lo hace.': 'Trebezia handiz mugitzen da. Ez da lehen eguna egiten duena.',
  'Ese es Kai.': 'Hori Kai da.',
  'Lleva cuatro años entrenando.': 'Lau urte daramatza entrenatzen.',
  'Es bueno.': 'Ona da.',
  'Kai termina, se echa la mochila al hombro. Pasa cerca.': 'Kaik amaitzen du, motxila sorbaldan jartzen du. Gertu igarotzen da.',
  'Asiente a Sora — saludo profesional. A ti te mira un segundo. Sin sonrisa. Registrando.': 'Sorari baietz egiten dio — agur profesionala. Zuri segundo batez begiratzen dizu. Irribarrerik gabe. Erregistratzen.',
  'Sigue bajando.': 'Jaisten jarraitzen du.',
  'Él va dos rangos por delante.': 'Bera bi maila aurretik doa.',
  'Algún día te lo vas a encontrar de verdad.': 'Egunen batean benetan topatuko duzu.',
  'Sora te ofrece una cantimplora.': 'Sorak kantinplora bat eskaintzen dizu.',
  'Bebe. Toca otra ronda.': 'Edan. Beste txanda bat dagokigu.',
  'Azotea nueva al norte. Cinco Fragmentos orbitan.': 'Teilatu berri bat iparraldean. Bost Zati orbitatzen.',
  'Tres medios. Dos tercios. Todos flotando.': 'Hiru erdi. Bi heren. Denak flotatzen.',
  '¿Cuántos medios ves?': 'Zenbat erdi ikusten dituzu?',
  'No. Cinco son todos. Tres son los medios. Otra vez.': 'Ez. Bost dira denak. Hiru dira erdiak. Berriro.',
  'Si sumas los tres medios...': 'Hiru erdiak batzen badituzu...',
  '¿Cuánto tienes?': 'Zenbat duzu?',
  'Los tres medios se fusionan. 3/2. Se desborda.': 'Hiru erdiak elkartzen dira. 3/2. Gainezka egiten du.',
  'Tres medios. Más de uno entero.': 'Hiru erdi. Oso bat baino gehiago.',
  'Cuando pasa de uno, se llama impropio.': 'Batetik gora pasatzen denean, ezpropio deitzen zaio.',
  'Son más grandes. Más trabajo.': 'Handiagoak dira. Lan gehiago.',
  'Pero aún no. Hoy, solo practica la suma.': 'Baina oraindik ez. Gaur, batuketa bakarrik landu.',
  'Plaza pequeña. Mesa fuera de un bar cerrado pero iluminado.': 'Plaza txikia. Mahaia itxitako baina argiztatutako taberna baten kanpoaldean.',
  'Come.': 'Jan.',
  'Mastican en silencio. Una pareja pasa riéndose. Sora los mira un instante.': 'Isilik murtxikatzen dute. Bikote bat barrez igarotzen da. Sorak une batez begiratzen die.',
  'No todo es entrenar.': 'Dena ez da entrenatzea.',
  'Aunque lo parezca.': 'Hala dirudien arren.',
  'Sora termina antes. Mira al cielo. Dos lunas.': 'Sorak lehenago bukatzen du. Zerura begiratzen du. Bi ilargi.',
  'Las dos esta noche.': 'Biak gaur gauean.',
  'Eso es otro tema. Come.': 'Hori beste gai bat da. Jan.',
  'Vamos. Duermes mucho mejor si entrenas antes.': 'Goazen. Askoz hobeto egingo duzu lo aurretik entrenatzen baduzu.',
  'Deja unas monedas en la mesa al levantarse.': 'Txanpon batzuk uzten ditu mahaian altxatzean.',
  'La azotea otra vez. Otra noche. Sora silba.': 'Teilatua berriro. Beste gau bat. Sorak txistu egiten du.',
  'Kurz baja del cielo. Más grande. Sobre él, el valor 5/6.': 'Kurz zerutik jaisten da. Handiagoa. Beraren gainean, 5/6 balioa.',
  'Otra vez.': 'Berriro.',
  'A ver.': 'Ikus dezagun.',
  'Casi.': 'Ia.',
  'Otra vez la semana que viene.': 'Berriro datorren astean.',
  'Has durado más.': 'Gehiago iraun duzu.',
  'Bastante más.': 'Askoz gehiago.',
  'Sora pone la mano en tu hombro un instante. La aparta rápido.': 'Sorak eskua sorbaldan jartzen dizu une batez. Azkar kentzen du.',
  'Vaya.': 'Hara.',
  'Tú ya eres otra cosa.': 'Zu jada beste gauza bat zara.',
  'Has ganado.': 'Irabazi duzu.',
  'No suelen ganar la segunda.': 'Bigarrenean ez dute ohi irabazten.',
  'Irune querrá verte.': 'Irunek ikusi nahiko zaitu.',
  'La azotea al atardecer. Por primera vez no es de noche.': 'Teilatua ilunabarrean. Lehen aldiz ez da gaua.',
  'Hoy.': 'Gaur.',
  'Hoy estás listo.': 'Gaur prest zaude.',
  'Silba. Kurz baja. La azotea tiembla un poco. 7/8 sobre él.': 'Txistu egiten du. Kurz jaisten da. Teilatuak apur bat dardar egiten du. 7/8 beraren gainean.',
  'Ah.': 'Ah.',
  'Te noto distinto.': 'Ezberdina nabaritzen zaitut.',
  'Kurz se hace pequeño. Sube despacio.': 'Kurz txikitzen da. Poliki igotzen da.',
  'Nos veremos cuando seas Iniciado.': 'Iniziatu zarenean ikusiko gara.',
  'Sora asiente una vez, muy despacio.': 'Sorak behin baietz egiten du, oso poliki.',
  'Ya está.': 'Hor dago.',
  'Ya eres algo más que un aprendiz.': 'Jada ikastun bat baino gehiago zara.',
  'Mira hacia la puerta. Irune está ahí. Asiente de lejos. Entra.': 'Aterantz begiratzen du. Irune han dago. Urrundik baietz egiten du. Sartu.',
  'Otra vez. La semana que viene.': 'Berriro. Datorren astean.',
  'Mañana.': 'Bihar.',
  'Estabas cerca.': 'Gertu zeunden.',
  'La sala de Irune. La luz más cálida que la primera vez.': 'Iruneren gela. Argia lehen aldian baino epelagoa.',
  'Siéntate.': 'Eseri.',
  'No te voy a felicitar. Sora tampoco. No es nuestro estilo.': 'Ez zaitut zoriondu behar. Sorak ere ez. Ez da gure estiloa.',
  'Pero lo que has hecho es real.': 'Baina egin duzuna benetakoa da.',
  'La gente habla de rangos como si fueran diplomas. No lo son. Son responsabilidades.': 'Jendeak mailei buruz hitz egiten du diplomak balira bezala. Ez dira. Erantzukizunak dira.',
  'Ahora eres Aprendiz II. Eso quiere decir que puedes salir del Edificio de los Tejados sin que Sora vaya detrás.': 'Orain Ikastun II zara. Horrek esan nahi du Teilatuen Eraikinetik atera zaitezkeela Sora atzetik joan gabe.',
  'Vas a hacerte amigos, enemigos, dudas. Sobre todo dudas.': 'Lagunak, etsaiak, zalantzak egingo dituzu. Batez ere zalantzak.',
  'Mañana puedes bajar a los Canales. Si quieres. O no. Tú decides.': 'Bihar Canales-era jaitsi zaitezke. Nahi baduzu. Edo ez. Zuk erabakitzen duzu.',
  'Y una cosa más.': 'Eta beste gauza bat.',
  'Hace mucho que no ponía una marca de Aprendiz II.': 'Aspaldi ez nuen Ikastun II marka bat jartzen.',
  'Silencio. Irune deja respirar la frase un momento largo.': 'Isiltasuna. Irunek esaldia une luze batez arnasa hartzen uzten du.',
  'Me alegro de que vuelva a haber alguien que la merezca.': 'Pozten naiz hura merezi duen norbait berriro egoteaz.',
  'Te pone una marca plateada al cuello. Una cuerda fina. Frío al principio, luego templada.': 'Zilarrezko marka bat jartzen dizu lepoan. Soka mehe bat. Hotza hasieran, gero epela.',
  'Bienvenido, Aprendiz II.': 'Ongi etorri, Ikastun II.',
  'Ya puedes irte. Duerme.': 'Jada joan zaitezke. Lo egin.',
  'Borde de la azotea. Sora sentada con las piernas colgando, sin miedo. Mira al norte.': 'Teilatuaren ertza. Sora eserita hankak zintzilik, beldurrik gabe. Iparraldera begira.',
  'Abajo, los Canales: puentes pequeños iluminados, reflejos amarillos en el agua. Una ciudad dentro de la ciudad.': 'Behean, Canales: zubi txiki argiztatuak, isla horiak uretan. Hiri bat hiriaren barruan.',
  'Allí vas a ir mañana.': 'Hara joango zara bihar.',
  'Los Canales.': 'Canales.',
  'Maestro Rexán.': 'Rexán maisua.',
  'Va a caerte bien. Es el tipo más simpático de la orden. No te fíes del todo — lo usa.': 'Atsegin izango duzu. Ordenako tipo jatorrena da. Ez fidatu erabat — erabili egiten du.',
  'Tiene una cojera. No preguntes por ella.': 'Herrenka egiten du. Ez galdetu horregatik.',
  'Algún día te lo contará. O no. Ya verás.': 'Egunen batean kontatuko dizu. Edo ez. Ikusiko duzu.',
  'Tienes que ir solo. Yo te esperaré aquí.': 'Bakarrik joan behar duzu. Hemen itxarongo dizut.',
  'Sí. Solo.': 'Bai. Bakarrik.',
  'No te asustes. Rexán es buena gente. Y tú ya no eres tan nuevo.': 'Ez izan beldur. Rexán jende ona da. Eta zu jada ez zara hain berria.',
  'Sora saca una pequeña brújula de bolsillo. No mágica. Solo una brújula.': 'Sorak patrikako iparrorratz txiki bat ateratzen du. Ez magikoa. Iparrorratz bat besterik ez.',
  'Toma. Era mía cuando empecé aquí.': 'Hartu. Nirea zen hemen hasi nintzenean.',
  'Devuélvemela cuando vuelvas.': 'Itzuli niri itzultzean.',
  'Mira otra vez hacia los Canales. Viento. Fundido lento.': 'Berriro Canales aldera begira. Haizea. Iraungitze geldoa.',
  'HASTA MAÑANA': 'BIHAR ARTE',
  'Escalera que baja del Edificio de los Tejados. Niebla baja en las calles.': 'Teilatuen Eraikinetik jaisten den eskailera. Lainoa baxua kaleetan.',
  'Ya.': 'Bai.',
  'Vete.': 'Joan.',
  'Si te pasa algo, vuelves corriendo. No te hagas el valiente.': 'Zerbait gertatzen bazaizu, korrika itzuli. Ez egin ausartarena.',
  'Y si tardas mucho, voy yo.': 'Eta luzatzen bazara, ni joango naiz.',
  'Calles estrechas. Una pareja en un portal. Un gato dormido. Un Fragmento tonto se disuelve solo.': 'Kale estuak. Bikote bat atari batean. Katu bat lo. Zati ergel bat bere kasa desegiten da.',
  'La luz cambia — más amarilla. El agua aparece entre las piedras.': 'Argia aldatu egiten da — horiagoa. Ura agertzen da harrien artean.',
  'BARRIO DE LOS CANALES': 'CANALES AUZOA',
  'Al otro lado de un puente, un hombre mayor sentado en un saliente. Lee. Levanta la vista. Sonríe.': 'Zubi baten bestaldean, gizon nagusi bat irtenune batean eserita. Irakurtzen ari da. Begirada altxatzen du. Irribarre egiten du.',
  'Se levanta. Cojea. No lo esconde ni lo señala.': 'Altxatzen da. Herrenka egiten du. Ez du ezkutatzen ezta seinalatzen ere.',
  'A ver, a ver.': 'Ea, ea.',
  'Primera sonrisa abierta de un adulto en el juego.': 'Jokoan heldu baten lehen irribarre irekia.',
  'Tú eres el que Sora manda.': 'Zu zara Sorak bidaltzen duena.',
  'Tiende la mano.': 'Eskua luzatzen du.',
  'Rexán. Maestro de los Canales, dicen. Yo me llamo Rexán. Sin más.': 'Rexán. Canales-eko maisua, diote. Nik Rexán dut izena. Besterik gabe.',
  'Tú ya sabes lo que es un Fragmento. Sabes sumar trozos cuando son iguales. Ya eres Aprendiz II. No está mal.': 'Zuk badakizu zer den Zati bat. Zatiak batzen dakizu berdinak direnean. Jada Ikastun II zara. Ez dago gaizki.',
  'Aquí vas a aprender algo distinto.': 'Hemen zerbait ezberdina ikasiko duzu.',
  'Señala el canal. Dos Fragmentos flotan sobre el agua: 1/2 y 2/4.': 'Kanala seinalatzen du. Bi Zati flotatzen ari dira uraren gainean: 1/2 eta 2/4.',
  '¿Cuál es más grande?': 'Zein da handiagoa?',
  'Mm. ¿Seguro? Míralos otra vez. Mira el agua.': 'Mm. Ziur? Begiratu berriro. Begiratu urari.',
  'Bien, {nombre}. Bien.': 'Ondo, {nombre}. Ondo.',
  'Los dos Fragmentos orbitan despacio y se fusionan en uno.': 'Bi Zatiek poliki orbitatzen dute eta batean elkartzen dira.',
  'Son la misma cosa. Con nombres distintos.': 'Gauza bera dira. Izen ezberdinekin.',
  'Un medio. Dos cuartos. Mismo trozo de mundo.': 'Erdi bat. Bi laurden. Munduaren puska bera.',
  'Eso se llama equivaler.': 'Horri baliokide izan deitzen zaio.',
  'Toda verdad tiene otra forma igualmente verdadera.': 'Egia orok beste forma bat du, era berean egiazkoa.',
  'Es lo que aprendes aquí. Lo demás viene después.': 'Hori da hemen ikasten duzuna. Gainerakoa gero dator.',
  'Vamos. Te enseño el barrio.': 'Goazen. Auzoa erakutsiko dizut.',
  'Callejón junto al canal. Dos Fragmentos emergen a la vez, con el mismo halo: 3/4 y 6/8.': 'Kanalaren ondoko kalezuloa. Bi Zati batera ageri dira, halo berarekin: 3/4 eta 6/8.',
  'Fragmentos Espejo.': 'Ispilu Zatiak.',
  'Se llaman así porque van en pareja. Uno parece el reflejo del otro.': 'Horrela deitzen dira bikoteka doazelako. Batek bestearen isla dirudi.',
  'Y casi siempre lo es.': 'Eta ia beti hala da.',
  'Míralos bien, {nombre}. ¿Son equivalentes?': 'Begiratu ondo, {nombre}. Baliokideak dira?',
  'Tres de cuatro. Seis de ocho. Simplifica seis de ocho y tienes tres de cuatro.': 'Lautik hiru. Zortzitik sei. Sinplifikatu zortzitik sei eta lautik hiru duzu.',
  'Cuando encuentres dos así, los emparejas y se disuelven juntos. Es el gesto más limpio que puedes hacer.': 'Horrelako bi aurkitzen dituzunean, parekatu eta elkarrekin desegiten dira. Egin dezakezun keinurik garbiena da.',
  'A veces no son equivalentes. Entonces tienes que reconocerlo y atacar por separado. No pasa nada.': 'Batzuetan ez dira baliokideak. Orduan hori onartu eta banaka eraso behar duzu. Ez da ezer gertatzen.',
  'Si los emparejas mal, hacen ruido. Los oyes.': 'Gaizki parekatzen badituzu, zarata egiten dute. Entzuten dituzu.',
  'Te guiña un ojo.': 'Begi-keinu egiten dizu.',
  'Vas a aprender a oírlos.': 'Haiek entzuten ikasiko duzu.',
  'Callejón. Pared vieja con una pintada reciente: un círculo roto con cuatro líneas hacia fuera.': 'Kalezuloa. Horma zaharra pintada berri batekin: zirkulu hautsi bat lau marrarekin kanporantz.',
  'Debajo, en letra temblorosa: "El uno era la cárcel."': 'Azpian, letra dardartiz: "Bata kartzela zen."',
  'Vámonos, {nombre}.': 'Goazen, {nombre}.',
  'Pintadas. No importantes.': 'Pintaketak. Garrantzirik gabeak.',
  'Porque algunos piensan así. Vamos.': 'Batzuek horrela pentsatzen dutelako. Goazen.',
  'No gira la cabeza hacia la pintada. Su voz no tiene miedo. Tiene cansancio.': 'Ez du burua pintaketarantz biratzen. Bere ahotsak ez dauka beldurrik. Nekea dauka.',
  'Terraza de un bar cerrado. Sillas apiladas. Dos monedas antiguas en la mesa.': 'Itxitako taberna baten terraza. Aulkiak pilatuta. Bi txanpon zahar mahai gainean.',
  'Oye.': 'Aizu.',
  '¿Sora te ha hablado de Zafrán alguna vez?': 'Sorak inoiz hitz egin dizu Zafránen inguruan?',
  'Niegas con la cabeza.': 'Buruarekin ezetz egiten duzu.',
  'Bueno. Yo te digo el nombre al menos.': 'Ondo. Nik gutxienez izena esango dizut.',
  'Es un Fragmento grande. Muy viejo. Vive por aquí.': 'Zatiki handia da. Oso zaharra. Hemen inguruan bizi da.',
  'Ahora mismo no te preocupes de él. No te va a ver. No te tiene que ver.': 'Oraintxe ez kezkatu hartaz. Ez zaitu ikusiko. Ez zaitu ikusi behar.',
  'Pero si alguna vez oyes un silbido largo y raro por la noche, de los canales... te vuelves al Edificio de los Tejados.': 'Baina inoiz gauez txistu luze eta arraro bat entzuten baduzu, Canales aldetik... Tejados Eraikinera itzultzen zara.',
  'Sin pensarlo. ¿De acuerdo?': 'Pentsatu gabe. Ados?',
  'Porque sí. Confía en mí una vez y hazme caso. Solo una vez.': 'Bai eta bai. Konfiantza nigan behin eta egidazu kasu. Behin bakarrik.',
  'Bien. Gracias.': 'Ondo. Eskerrik asko.',
  '¿Has visto la luna esta noche? Solo una. Qué pena.': 'Ikusi duzu ilargia gaur gauean? Bat bakarrik. Ze pena.',
  'Puente grande. Niebla leve. Dos Fragmentos flotan unidos por una línea de luz densa: 1/3 y 1/4.': 'Zubi handia. Lainoa arina. Bi Zatiki argi-lerro trinko batek lotuta flotatzen: 1/3 eta 1/4.',
  'Duales.': 'Dualak.',
  'Esto es lo nuevo. Esto es lo que querías ver.': 'Hau da berria. Hau da ikusi nahi zenuena.',
  'Con los Duales, no puedes atacar a uno solo. Están enganchados.': 'Dualekin ezin diozu bati bakarrik eraso. Lotuta daude.',
  'Tienes que unirlos primero. Volverlos un solo Fragmento. Y entonces los atacas.': 'Lehenbizi elkartu behar dituzu. Zatiki bakar bihurtu. Eta orduan eraso.',
  'Para unirlos, tienen que hablar el mismo idioma. Mismo denominador.': 'Elkartzeko, hizkuntza bera hitz egin behar dute. Izendatzaile bera.',
  'Un tercio y un cuarto no hablan el mismo idioma. Mira.': 'Heren batek eta laurden batek ez dute hizkuntza bera hitz egiten. Begira.',
  'Los Fragmentos se rozan. Un chirrido desagradable. Rebotan.': 'Zatikiak ukitzen dira. Karranka desatsegina. Errebotatzen dute.',
  '¿Lo oyes? Así suena cuando los unes mal.': 'Entzuten duzu? Horrela egiten du soinu gaizki elkartzean.',
  'Busca un número que sea múltiplo de los dos. De tres y de cuatro.': 'Bilatu bien multiploa den zenbaki bat. Hiruren eta lauren.',
  'Doce. 1/3 se vuelve 4/12. 1/4 se vuelve 3/12. Se funden en 7/12.': 'Hamabi. 1/3 4/12 bihurtzen da. 1/4 3/12 bihurtzen da. 7/12-n urtzen dira.',
  'Doce es lo más pequeño que los dos comparten. Se llama mínimo común múltiplo. MCM, para ir rápido.': 'Hamabi da bik partekatzen duten txikiena. Multiplo komun txikiena deitzen da. MKT, azkar joateko.',
  'Ahora ya es un Fragmento normal. Atácalo.': 'Orain Zatiki arrunt bat da. Eraso egin.',
  'Rexán sonríe de medio lado.': 'Rexánek erdi-irribarre egiten du.',
  'Esto es lo más bonito que se aprende aquí.': 'Hau da hemen ikasten den politena.',
  'En serio. Cuando esto lo tienes, el resto es juego.': 'Benetan. Hau dakizunean, gainerakoa jolasa da.',
  'Muelle pequeño al borde de un canal ancho. Pies casi tocando el agua.': 'Kai txikia kanal zabal baten ertzean. Oinak ia ura ukituz.',
  'Un minuto de silencio. Solo el agua.': 'Minutu bat isilik. Ura bakarrik.',
  'Yo me formé en el Puerto, ¿sabes?': 'Ni Portuan formatu nintzen, badakizu?',
  'Oryn me entrenó. Hace muchos años. Él era joven todavía, como Sora ahora.': 'Orynek entrenatu ninduen. Duela urte asko. Bera oraindik gaztea zen, Sora orain bezala.',
  'Desde entonces, el agua me gusta.': 'Harrezkero, ura gustatzen zait.',
  'Tira una piedrita al agua.': 'Harritxo bat botatzen du urera.',
  'Cuando me pasó lo de la pierna, hace ya, volví al Puerto a recuperar.': 'Hankarena gertatu zitzaidanean, aspaldi, Portura itzuli nintzen sendatzera.',
  'Estuve un año entero viendo el agua desde un muelle como este.': 'Urte oso bat eman nuen ura ikusten honelako kai batetik.',
  'Cuando pude caminar otra vez, me preguntaron si quería volver a ser Maestro.': 'Berriz ibili ahal izan nuenean, galdetu zidaten Maisu izaten itzuli nahi nuen.',
  'Les dije que sí, pero aquí, en los Canales. Porque los canales tienen agua también, y no son el mar.': 'Baietz esan nien, baina hemen, Canalesen. Kanalek ere ura dutelako, eta itsasoa ez direlako.',
  'El mar acuerda. Los canales olvidan.': 'Itsasoak gogoratzen du. Kanalek ahaztu egiten dute.',
  'Eso no lo entiendes todavía. No importa.': 'Hori oraindik ez duzu ulertzen. Berdin dio.',
  'Otro día, {nombre}. Hoy no.': 'Beste egun batean, {nombre}. Gaur ez.',
  'Sora no baja al Puerto. No le gusta el agua. Aún.': 'Sora ez da Portura jaisten. Ez zaio ura gustatzen. Oraindik.',
  'Tira otra piedrita. Se levanta apoyándose en el bastón.': 'Beste harritxo bat botatzen du. Makulan bermatuta zutitzen da.',
  'Venga. Antes de que nos durmamos los dos.': 'Goazen. Biok loak hartu baino lehen.',
  'Esquina cerca del Edificio de los Tejados. Una chica de tu edad, mochila cruzada.': 'Tejados Eraikinetik gertu dagoen kantoia. Zure adineko neska bat, motxila gurutzatuta.',
  'Hola.': 'Kaixo.',
  '¿Tú también eres nuevo?': 'Zu ere berria zara?',
  'Soy Ari. Llegué hace seis meses.': 'Ari naiz. Duela sei hilabete iritsi nintzen.',
  'Poco hablador, tú. Me gusta.': 'Hizketan gutxikoa, zu. Gustatzen zait.',
  'Oye. Estoy con el Maestro Vadic. Industria. ¿Tú?': 'Aizu. Vadic Maisuarekin nago. Industria. Zu?',
  'Ah, Rexán. Me cae bien. Luego te caerá a ti.': 'A, Rexán. Ondo erortzen zait. Gero zuri ere ondo eroriko zaizu.',
  'Vale, vale, no preguntaba por preguntar. Solo curiosidad.': 'Ondo, ondo, ez nintzen galdetzeagatik galdetzen ari. Jakin-mina bakarrik.',
  'Bueno. Me tengo que ir. Mis padres no saben que ando por aquí a esta hora.': 'Tira. Joan behar dut. Gurasoek ez dakite ordu hauetan hemen nabilenik.',
  'Nos vemos por los tejados.': 'Teilatuetan elkar ikusiko dugu.',
  'Echa a correr. Se gira al correr:': 'Korrika hasten da. Korrika doala biratzen da:',
  'No te metas con los Espejo los lunes, eh. No sé por qué pero los lunes son raros.': 'Ez sartu Ispiluekin astelehenetan, e. Ez dakit zergatik, baina astelehenak arraroak dira.',
  'Mitad de un entrenamiento con Rexán. Un silbido largo y grave rompe el aire.': 'Rexánekin entrenamendu erdian. Txistu luze eta sakon batek airea hausten du.',
  'Tres segundos. Un quiebro extraño al final. Ni pájaro ni sirena.': 'Hiru segundo. Bukaeran etenaldi arraro bat. Ez txori, ez sirena.',
  'Rexán se queda completamente quieto. Deja caer el bastón sin darse cuenta. Lo recoge despacio.': 'Rexán erabat geldi geratzen da. Konturatu gabe makulua erortzen uzten du. Astiro jasotzen du.',
  'Se acabó por hoy.': 'Bukatu da gaurkoz.',
  'Intenta sonreír. No lo consigue del todo.': 'Irribarre egiten saiatzen da. Ez du erabat lortzen.',
  'Vete al Edificio de los Tejados. Ahora. Despacio pero ya.': 'Joan zaitez Tejados Eraikinera. Orain. Astiro baina jada.',
  'Y no pasas por la calle del mercado nocturno.': 'Eta ez zara gaueko merkatuko kaletik pasatzen.',
  'Dile a Irune que he oído a Zafrán.': 'Esan Iruneri Zafrán entzun dudala.',
  'Se va en dirección contraria. La cojera se nota más. Calles silenciosas. Puestos cerrando antes. Ventanas apagándose al pasar.': 'Kontrako norabidean joaten da. Herrenaldia gehiago nabaritzen da. Kale isilak. Postuak lehenago ixten. Leihoak igarotzean itzaltzen.',
  'Al subir al Edificio, Sora en la puerta.': 'Eraikinera igotzean, Sora atean.',
  'Pasa. Irune quiere verte.': 'Sartu. Irunek ikusi nahi zaitu.',
  'Azotea al amanecer. Sora con cazadora gruesa y una bolsa pequeña cruzada al cuerpo.': 'Teilatu lauean egunsentian. Sora kazadora lodi batekin eta poltsa txiki bat gorputzean gurutzatuta.',
  'Hoy voy contigo.': 'Gaur zurekin noa.',
  'No al entrenamiento. Al combate.': 'Ez entrenamendura. Borrokara.',
  'Rexán no puede. No debe. Así que voy yo.': 'Rexán ezin du. Ez du behar. Beraz, ni noa.',
  'Irune aparece en la puerta sin cruzar. Asiente a Sora. Desaparece.': 'Irune atean agertzen da gurutzatu gabe. Sorari baietz egiten dio. Desagertzen da.',
  'Zafrán es un Fragmento Dual muy viejo. Enorme. Vive entre los canales, en la zona más profunda del distrito.': 'Zafrán Zatiki Dual oso zaharra da. Itzela. Kanalen artean bizi da, barrutiko zonalde sakonenean.',
  'No ataca todo el tiempo. A veces está dormido años. Y de vez en cuando sale.': 'Ez du beti erasotzen. Batzuetan urteak lo egoten da. Eta noizean behin ateratzen da.',
  'La última vez fue hace dos semanas. Un ruido en el mercado. No fue mucho. Rexán lo contuvo.': 'Azken aldia duela bi aste izan zen. Zarata bat merkatuan. Ez zen handia izan. Rexánek geldiarazi zuen.',
  'La anterior, hace veinte años, le dejó la pierna como la tiene.': 'Aurrekoak, duela hogei urte, hanka horrela utzi zion.',
  'Esta no la aguanta solo. Irune no quiere que vaya él. Voy yo.': 'Hau ez du bakarrik jasaten. Irunek ez du nahi bera joatea. Ni noa.',
  'Y tú.': 'Eta zu.',
  'Primera mirada sin distancia.': 'Lehen begirada distantziarik gabe.',
  'No porque seas bueno. Porque es tu distrito ahora. Tienes que verlo con tus ojos.': 'Ez ona zarelako. Zure barrutia delako orain. Zeure begiekin ikusi behar duzu.',
  'Te quedas atrás. Atacas cuando te digo. No haces nada que no te diga.': 'Atzean geratzen zara. Esaten dizudanean erasotzen duzu. Ez duzu egiten esaten ez dizudanik.',
  '¿Vale?': 'Ados?',
  'Mientras me hagas caso, sí.': 'Kasu egiten didazun bitartean, bai.',
  'Vale. Vamos.': 'Ondo. Goazen.',
  'La parte más profunda y vieja del Barrio. Plaza circular pequeña. Pozo viejo de piedra cubierto con reja oxidada.': 'Auzoaren zatirik sakonena eta zaharrena. Plaza zirkular txikia. Harrizko putzu zaharra burdin sare herdoilduarekin estalita.',
  'Aquí.': 'Hemen.',
  'Sale de ahí.': 'Hortik ateratzen da.',
  'Cuando salga, será grande. Más que todo lo que has visto.': 'Ateratzen denean, handia izango da. Ikusi duzun guztia baino gehiago.',
  'Va a tener dos valores distintos. Denominadores diferentes. Tú y yo los vamos a fusionar.': 'Bi balio ezberdin izango ditu. Izendatzaile ezberdinak. Zuk eta nik bateratuko ditugu.',
  'Yo uno. Tú otro.': 'Nik bata. Zuk bestea.',
  'Como en los puentes con Rexán.': 'Rexánekin zubietan bezala.',
  'Si fallas, no pasa nada. Yo fusiono los dos. Pero va a tardar más. Y va a doler más.': 'Huts egiten baduzu, ez da ezer gertatzen. Nik biak bateratzen ditut. Baina gehiago iraungo du. Eta gehiago minduko du.',
  'Atrás.': 'Atzera.',
  'La reja tiembla. Salta. Emerge Zafrán: altura de una casa, dos cuerpos conectados por una línea de luz densa.': 'Burdin sareak dardarka egiten du. Saltatzen da. Zafrán azaltzen da: etxe baten altuera, bi gorputz argi-lerro trinko batez lotuta.',
  'Izquierdo 5/7. Derecho 3/11. Cuerpo agrietado en patrones viejos.': 'Ezkerra 5/7. Eskuina 3/11. Gorputza patroi zaharretan pitzatuta.',
  'Un sonido vibrante hace temblar las piedras. La respiración de Sora se acelera. Rabia, no miedo.': 'Soinu bibratzaile batek harriak dardarazten ditu. Soraren arnasketa azkartzen da. Amorrua, ez beldurra.',
  'Hola, Zafrán.': 'Kaixo, Zafrán.',
  'Sí. Me acuerdo.': 'Bai. Gogoratzen naiz.',
  'Saca una marca pequeña del bolsillo. Vieja. Oxidada. Distinta de la del cuello. La aprieta.': 'Marka txiki bat ateratzen du poltsikotik. Zaharra. Herdoilduta. Lepokoa ez bezalakoa. Estutzen du.',
  'Esta es por Rexán.': 'Hau Rexánengatik da.',
  'Zafrán se hace pequeño. Al llegar a 1/16, escapa al pozo con un chirrido. La reja cae con un golpe seco.': 'Zafrán txikitzen da. 1/16-ra iristean, putzura ihes egiten du karranka batekin. Burdin sarea kolpe lehor batekin erortzen da.',
  'Silencio. Sora se limpia la cara con el dorso de la mano.': 'Isiltasuna. Sorak aurpegia eskuaren atzealdearekin garbitzen du.',
  'Se va.': 'Joaten da.',
  'Pero le hemos hecho daño.': 'Baina min eman diogu.',
  'Algo en su cara más abierto que nunca lo has visto.': 'Bere aurpegian zerbait inoiz ikusi duzun baino irekiagoa.',
  'Lo has hecho bien.': 'Ondo egin duzu.',
  'Muy bien, {nombre}.': 'Oso ondo, {nombre}.',
  'Sora sentada en el suelo contra el pozo. Mano en la rodilla izquierda.': 'Sora lurrean eserita putzuaren kontra. Eskua ezkerreko belaunean.',
  'No es grave.': 'Ez da larria.',
  'Solo el golpe. Mañana estará.': 'Kolpea bakarrik. Bihar ondo egongo da.',
  'Saca la pequeña marca vieja. La mira. La aprieta.': 'Marka zahar txikia ateratzen du. Begiratzen dio. Estutzen du.',
  'Esta era de alguien.': 'Hau norbaitena zen.',
  'De mi maestra. Antes de Irune.': 'Nire maistrarena. Iruneren aurretik.',
  'Lo mismo que a Rexán, más o menos. Peor.': 'Rexáni bezalaxe, gutxi gorabehera. Okerrago.',
  'No. Eso fue otra cosa. Otra ciudad.': 'Ez. Hori beste gauza bat izan zen. Beste hiri bat.',
  'Gracias.': 'Eskerrik asko.',
  'Ayúdame a levantarme.': 'Lagundu altxatzen.',
  'Acepta tu mano más tiempo del necesario. Cojea dos o tres pasos. Recupera su ritmo.': 'Zure eskua onartzen du beharrezkoa baino denbora gehiagoz. Bi edo hiru pauso herrenka. Bere erritmoa berreskuratzen du.',
  'Al volver al Edificio de los Tejados, Rexán está apoyado en el muro de la entrada con el bastón.': 'Tejados Eraikinera itzultzean, Rexán sarrerako paretaren kontra dago makuluarekin.',
  'Sora se queda atrás dando espacio.': 'Sora atzean geratzen da tartea utziz.',
  'A ver. Enséñame.': 'Ea ba. Erakutsi.',
  'Enseñas la marca de Aprendiz II. Tiene ahora un pequeño filete azul — señal de haber sobrevivido a un combate con un Fragmento nombrado.': 'Ikasle II marka erakusten duzu. Orain xingola urdin txiki bat dauka — Zatiki izendun batekin borrokari bizirik atera izanaren seinale.',
  'Bonita.': 'Polita.',
  'La mía también la tiene.': 'Nireak ere badauka.',
  'Se abre el cuello. Su marca con varios filetes azules, algunos viejos, uno muy desteñido.': 'Lepoa irekitzen du. Bere marka xingola urdin batzuekin, batzuk zaharrak, bat oso higatua.',
  'Sora.': 'Sora.',
  'Rexán.': 'Rexán.',
  'Sube. Irune quiere verte.': 'Igo. Irunek ikusi nahi zaitu.',
  'Y duerme, {nombre}. Mañana es otro día y hoy ya estuvo.': 'Eta lo egin, {nombre}. Bihar beste egun bat da eta gaurkoa joan da.',
  'Al entrar, Rexán y Sora se quedan fuera juntos. Sin hablar. Solo estando.': 'Sartzean, Rexán eta Sora kanpoan geratzen dira elkarrekin. Hitz egin gabe. Egoten bakarrik.',
  'Azotea. Borde norte. Sora con las piernas colgando, como al final del Arco 1. La niebla disipada, luces reflejadas en el agua.': 'Teilatu laua. Iparraldeko ertza. Sora hankak zintzilik, 1. Arkuaren amaieran bezala. Lainoa desagertuta, argiak uretan islatzen.',
  'Un minuto de silencio.': 'Minutu bat isilik.',
  'Cuando era pequeña, en mi ciudad...': 'Txikia nintzenean, nire hirian...',
  '...tenía una ventana que daba a un canal.': '...kanal batera ematen zuen leiho bat nuen.',
  'Se parece a estos.': 'Hauen antzekoa.',
  'Mirada breve. Vuelve al paisaje. Primera vez que menciona su ciudad sin cortar.': 'Begirada laburra. Paisaiara itzultzen da. Bere hiria aipatzen duen lehen aldia eten gabe.',
  'No es importante. No sé por qué lo he dicho.': 'Ez da garrantzitsua. Ez dakit zergatik esan dudan.',
  'Mañana, si quieres, puedes bajar al Mercado. Conocer a Naini.': 'Bihar, nahi baduzu, Mercadora jaitsi zaitezke. Naini ezagutzera.',
  'Yo no voy. Ella y yo ya nos conocemos.': 'Ni ez noa. Berak eta nik elkar ezagutzen dugu.',
  'Pero tú vas a querer ir. Te va a caer bien.': 'Baina zuk joan nahiko duzu. Ondo eroriko zaizu.',
  'La ciudad ya es tuya. Todos los distritos.': 'Hiria zurea da jada. Barruti guztiak.',
  'Bueno. Casi todos. La Montaña no.': 'Tira. Ia denak. Montaña ez.',
  'Segunda media sonrisa de Sora.': 'Soraren bigarren erdi-irribarrea.',
  'Aún.': 'Oraindik.',
  'Portón alto iluminado. Una explosión de luz, sonido y olor al cruzarlo.': 'Ate handi argitua. Argi-, soinu- eta usain-eztanda bat zeharkatzean.',
  '¡Qué bueno verte!': 'Ze ondo ikustea!',
  'Soy Naini. Maestra del Mercado. Aunque aquí casi todos me llaman Naini a secas.': 'Naini naiz. Mercadoko Maistra. Hala ere, hemen ia denek Naini hutsa deitzen didate.',
  'Iniciado, ¿eh? Pues venga. Pasa, pasa. Te cuento.': 'Hasiberri, e? Ba, ondo. Sartu, sartu. Kontatuko dizut.',
  'Fragmentos silvestres flotan entre la gente sin alarma.': 'Zatiki basatiak jendearen artean flotatzen ari dira alarmarik gabe.',
  'El Mercado es distinto. Aquí los Fragmentos no son enemigos todo el rato. Son valor en circulación.': 'Mercadoa ezberdina da. Hemen Zatikiak ez dira beti etsaiak. Zirkulazioan dagoen balioa dira.',
  '¿Tú has hecho alguna vez un trueque?': 'Zuk inoiz egin duzu trukerik?',
  'Vale. Entonces ya medio entiendes.': 'Ondo. Orduan erdi ulertzen duzu.',
  'Pues lo vas a hacer hoy.': 'Ba gaur egingo duzu.',
  'Aquí se cambia una cosa por otra. Un Fragmento por tres. Tres por uno. Porcentajes. Proporciones. Eso es lo que vas a aprender aquí.': 'Hemen gauza bat bestearengatik aldatzen da. Zatiki bat hiruren truke. Hiru baten truke. Ehunekoak. Proportzioak. Hori ikasiko duzu hemen.',
  'Y también vas a aprender a distinguir un trueque honesto de uno que no lo es.': 'Eta truke zintzo bat eta ez dena ere bereizten ikasiko duzu.',
  'Pero eso ya es más adelante. Ven.': 'Baina hori geroago da. Etorri.',
  'Puesto grande de frutas. 15 manzanas rojas y 10 amarillas.': 'Fruta-postu handia. 15 sagar gorri eta 10 hori.',
  'Si te llevas un tercio de las rojas y la mitad de las amarillas, ¿cuántas en total?': 'Gorrien herena eta horien erdia hartzen baduzu, zenbat guztira?',
  'No. Un tercio de 15 son 5. La mitad de 10 son 5.': 'Ez. 15-en herena 5 da. 10-en erdia 5 da.',
  'Justo. 5 y 5.': 'Hain zuzen. 5 eta 5.',
  'Demasiadas. Un tercio de 15 son 5. La mitad de 10 son 5.': 'Gehiegi. 15-en herena 5 da. 10-en erdia 5 da.',
  '¿Y qué porcentaje del total son tus 10 manzanas? El total era 25.': 'Eta zure 10 sagarrak guztiaren zer ehuneko dira? Guztira 25 ziren.',
  'No. 10 de 25. Diez de veinticinco.': 'Ez. 25-etik 10. Hogeita bostetik hamar.',
  '40%. Justo.': '40 %. Hain zuzen.',
  'Casi. 10 de 25 no es la mitad.': 'Ia. 25-etik 10 ez da erdia.',
  'Te pone dos manzanas en la mano. Le guiña un ojo a la vendedora.': 'Bi sagar jartzen dizkizu eskuan. Saltzaileari keinua egiten dio begiarekin.',
  'Aquí nadie te enseña nada gratis. Pero todo se aprende.': 'Hemen inork ez dizu ezer doan erakusten. Baina dena ikasten da.',
  'Esa es la regla del Mercado. Nada gratis. Pero todo posible.': 'Hori da Mercadoaren araua. Ezer ez doan. Baina dena posible.',
  'Plaza lateral del Mercado. Kai. Más filetes azules en su marca de Aprendiz.': 'Mercadoaren alboko plaza. Kai. Xingola urdin gehiago bere Ikasle markan.',
  'Hombre.': 'Aizu.',
  'Me dijeron que habías bajado a ver a Naini.': 'Esan zidaten Naini ikustera jaitsi zinela.',
  'Interesante.': 'Interesgarria.',
  'Oye, oye, tranquilo. Solo te saludaba.': 'Aizu, aizu, lasai. Agurtzen ari nintzen bakarrik.',
  'Vale. Tú mandas.': 'Ondo. Zuk agintzen duzu.',
  'Oye. He oído lo de Zafrán.': 'Aizu. Zafránena entzun dut.',
  'No todo el mundo sobrevive a su primer Fragmento nombrado.': 'Ez du jende guztiak bizirik irauten bere lehen Zatiki izendunarekin.',
  'Yo conmigo el mío... todavía no lo vi.': 'Nik nirea... oraindik ez dut ikusi.',
  'Bueno. Es lo que hay.': 'Tira. Dagoena da.',
  'Si un día te aburres de entrenar con señores mayores, podemos combatir.': 'Egunen batean jaun nagusiekin entrenatzeaz aspertzen bazara, borrokatu gaitezke.',
  'Tú contra mí. Nada oficial. Solo para ver.': 'Zu nire kontra. Ezer ofizialik ez. Ikusteagatik bakarrik.',
  'Ari se acerca. Kai ya no está. Te ofrece un refresco.': 'Ari hurbiltzen da. Kai ez da jada. Freskagarri bat eskaintzen dizu.',
  'Toma.': 'Hartu.',
  'No te va a hablar en un tiempo.': 'Ez dizu hitz egingo aldi batean.',
  'Es así.': 'Horrela da.',
  'Cuando yo le gané a Elen hace tres meses, estuvo desaparecida dos semanas. Ahora somos colegas.': 'Duela hiru hilabete Eleni irabazi nionean, bi astez desagertuta egon zen. Orain lagunak gara.',
  'Déjale espacio.': 'Utzi tartea.',
  'Tengo que volver con Vadic. Industria. Si bajas alguna vez, me avisas.': 'Vadicengana itzuli behar dut. Industria. Inoiz jaisten bazara, abisatu.',
  'Se gira al irse.': 'Joatean biratzen da.',
  'Por cierto, has estado bien.': 'Bide batez, ondo egon zara.',
  'Galpón de ladrillo rojo. Luz gris. Un hombre mide algo con un calibre. No levanta la vista.': 'Adreilu gorrizko biltegia. Argi grisa. Gizon batek zerbait neurtzen du kalibrearekin. Ez du begirada altxatzen.',
  'Un momento.': 'Une bat.',
  'Anota. Guarda el calibre. Ahora mira.': 'Idazten du. Kalibrea gordetzen du. Orain begiratzen du.',
  'Vadic.': 'Vadic.',
  '¿Nombre?': 'Izena?',
  'Dices tu nombre. Asiente una vez.': 'Zure izena esaten duzu. Behin baietz egiten du.',
  'Esto mide 2,34 metros. ¿Cuántos centímetros son?': 'Honek 2,34 metro neurtzen ditu. Zenbat zentimetro dira?',
  'No. Un metro son cien centímetros.': 'Ez. Metro bat ehun zentimetro da.',
  'Correcto.': 'Zuzena.',
  'No. Eso serían milímetros.': 'Ez. Hori milimetroak izango lirateke.',
  '¿Y en milímetros?': 'Eta milimetrotan?',
  'No. Diez veces más.': 'Ez. Hamar aldiz gehiago.',
  'Aprendiz tres, Iniciado II. Bien para trabajar aquí.': 'Ikasle hiru, Hasiberri II. Ondo hemen lan egiteko.',
  'Aquí las cosas se miden bien o no se miden. No hay término medio.': 'Hemen gauzak ondo neurtzen dira edo ez dira neurtzen. Ez dago erdibiderik.',
  'Lo que yo te diga, cuando yo te lo diga. Pero aprender a medir. Eso siempre.': 'Nik esaten dizudana, esaten dizudanean. Baina neurtzen ikastea. Hori beti.',
  'Veintidós años.': 'Hogeita bi urte.',
  'Vuelve mañana. Tengo trabajo.': 'Itzuli bihar. Lana daukat.',
  'Callejón estrecho entre galpones. Pared de ladrillo. La misma mano que en los Canales.': 'Biltegien arteko kale estua. Adreilu pareta. Canalesetan bezalako esku berbera.',
  'Letra temblorosa: "La unidad es la medida de la obediencia."': 'Letra dardartia: "Unitatea obedientziaren neurria da."',
  'Hay más últimamente.': 'Gehiago daude azkenaldian.',
  'Camina.': 'Ibili.',
  'Callejón cualquiera. De repente el mundo baja de volumen. Los pasos se apagan.': 'Edozein kale. Bat-batean munduak bolumena jaisten du. Pausoak itzaltzen dira.',
  'Un Fragmento pequeño flota delante de ti. Muestra dos valores a la vez: 2/4 y 1/2.': 'Zatiki txiki bat zure aurrean dabil hegan. Bi balio erakusten ditu aldi berean: 2/4 eta 1/2.',
  'Otro nuevo.': 'Beste berri bat.',
  '¿Vas a desfragmentarme, Aprendiz?': 'Deszatikatuko nauzu, Ikastun?',
  'Ah. Disculpa. Mejor así.': 'Ah. Barkatu. Hobe horrela.',
  'Eso es honesto. Mejor así.': 'Hori zintzoa da. Hobe horrela.',
  'Vale. No hablas. Bien.': 'Ondo. Ez duzu hitz egiten. Ondo.',
  'Eco gira despacio sobre sí mismo.': 'Eco bere buruaren inguruan biraka dabil astiro.',
  'Tengo una pregunta.': 'Galdera bat dut.',
  'Si tú y yo fuéramos el mismo pedazo de algo mayor, con nombres distintos, ¿seríamos la misma cosa?': 'Zu eta ni zerbait handiago baten zati bera bagina, izen ezberdinekin, gauza bera ginateke?',
  'Eco espera sin reloj.': 'Eco erlojurik gabe itxaroten du.',
  'Entonces tú y yo ya somos.': 'Orduan zu eta ni jada bagara.',
  'Entonces tú y yo todavía no somos.': 'Orduan zu eta ni oraindik ez gara.',
  'Yo tampoco. Ven a verme otra vez cuando sepas.': 'Nik ere ez. Etorri berriz ikustera jakiten duzunean.',
  'Otra vez será.': 'Beste batean izango da.',
  'Eco se desvanece en partículas que suben. No bajan. El mundo vuelve a su volumen.': 'Eco igotzen diren partikulatan desagertzen da. Ez dira jaisten. Mundua bere bolumenera itzultzen da.',
  'Muelle largo del Puerto Silencioso. Faro lejano parpadea. Mar negro.': 'Portu Isilaren kai luzea. Faro urruna keinuka. Itsaso beltza.',
  'Hm.': 'Hm.',
  'Pausa muy larga. Ocho segundos contados.': 'Etena oso luzea. Zortzi segundo zenbatuak.',
  'Siéntate si quieres.': 'Eseri nahi baduzu.',
  'Algo se mueve lejos en el mar. Se sumerge.': 'Zerbait mugitzen da urrun itsasoan. Murgildu egiten da.',
  'Oryn.': 'Oryn.',
  'Dices tu nombre.': 'Zure izena esaten duzu.',
  'Aquí aprendes a multiplicar y a dividir.': 'Hemen biderkatzen eta zatitzen ikasten duzu.',
  'Fracciones. Fracciones entre ellas.': 'Zatikiak. Zatikiak elkarren artean.',
  'No es rápido.': 'Ez da azkarra.',
  'Te mira lo justo para incomodarte.': 'Justu deserosotzeko adina begiratzen dizu.',
  'Trabajamos de noche. Y el mar pide silencio. Algunos piensan que el mar escucha.': 'Gauez lan egiten dugu. Eta itsasoak isiltasuna eskatzen du. Batzuek itsasoak entzuten duela uste dute.',
  'Hm. Mucho.': 'Hm. Asko.',
  'Vale.': 'Ondo.',
  'Vuelve mañana. Empezamos.': 'Itzuli bihar. Hasiko gara.',
  'Cafetería nocturna del Puerto. Ari ya ha pedido bebida para los dos.': 'Portuko gaueko kafetegia. Arik bientzako edaria eskatu du jada.',
  '¡Eh!': 'Aupa!',
  'No te esperaba aquí.': 'Ez nintzen zure zain hemen.',
  'Bueno, sí. Todo el mundo acaba pasando por el Puerto tarde o temprano.': 'Bueno, bai. Mundu guztia Portutik pasatzen da lehenago edo geroago.',
  'Oye. ¿Te puedo pedir una cosa?': 'Aizu. Gauza bat eska diezazuket?',
  'Llevo dos semanas viendo algo raro en el muelle 7. No voy a decir más aquí.': 'Bi aste daramatzat zerbait arraroa ikusten 7. kaian. Ez dut hemen gehiago esango.',
  'No es un Fragmento normal. Creo que es... otra cosa.': 'Ez da Zatiki arrunt bat. Beste zerbait dela uste dut...',
  'Yo sola no voy. ¿Me acompañas mañana por la noche?': 'Bakarrik ez naiz joango. Lagunduko didazu bihar gauean?',
  'Gracias, {nombre}. En serio. Aquí mismo mañana, a la misma hora.': 'Eskerrik asko, {nombre}. Benetan. Hemen bertan bihar, ordu berean.',
  'No. No sé cómo reaccionaría. Y además... quiero ver qué es primero.': 'Ez. Ez dakit nola erreakzionatuko lukeen. Eta gainera... lehenik zer den ikusi nahi dut.',
  'Por eso te lo pido a ti.': 'Horregatik eskatzen dizut zuri.',
  'Muelle 7. Un almacén viejo con la puerta entornada. Luz rojiza dentro.': '7. kaia. Biltegi zahar bat atea erdi-irekia duela. Argi gorrizta barruan.',
  'Un altar improvisado. Un Fragmento de valor 3/4 en una caja de cristal con filtros metálicos.': 'Aldare inprobisatua. 3/4 balioko Zatiki bat kristalezko kutxa batean iragazki metalikoekin.',
  'Alrededor: espejos antiguos, un reloj parado, una rosa disecada, un frasco con agua turbia.': 'Inguruan: ispilu zaharrak, gelditutako erloju bat, arrosa lehortu bat, ur lohia duen flasko bat.',
  'Los objetos fuera del altar —silla, mesa— están mal proporcionados. Como si el espacio doblara.': 'Aldaretik kanpoko objektuak —aulkia, mahaia— gaizki proportzionatuak daude. Espazioa tolestuko balitz bezala.',
  '¿Ves?': 'Ikusten?',
  'Eso no es un Fragmento cualquiera.': 'Hori ez da edozein Zatiki.',
  'Alguien lo está usando.': 'Norbaitek erabiltzen ari da.',
  'Una puerta se cierra dentro del almacén. Pasos.': 'Ate bat ixten da biltegi barruan. Pausoak.',
  'Vámonos.': 'Goazen.',
  'Corréis. Atravesáis el muelle 7 en silencio. Al parar, Ari respira hondo.': 'Korrika zoazte. 7. kaia zeharkatzen duzue isilik. Gelditzean, Arik arnasa hartzen du sakon.',
  'Hay que contárselo.': 'Esan egin behar zaio.',
  'A alguien. No sé a quién.': 'Norbaiti. Ez dakit nori.',
  'Sora... no sé. Ella es de Tejados. Mejor a uno del distrito de aquí.': 'Sora... ez dakit. Bera Teilatuetakoa da. Hobe hemengo barrutiko bati.',
  'Oryn sabrá. Pero no sé si es la persona adecuada. Siempre me da la sensación de que sabe más cosas de las que dice.': 'Oryn-ek jakingo du. Baina ez dakit aproposena den. Beti ematen dit esaten dituenak baino gehiago dakizkienaren irudipena.',
  'Sí. Ella sí. Naini reacciona. Los otros piensan demasiado antes.': 'Bai. Bera bai. Nainik erreakzionatzen du. Besteek gehiegi pentsatzen dute aurretik.',
  'Despacho pequeño al fondo del Mercado. Una lámpara de mesa. Naini sin sonrisa por primera vez.': 'Bulego txikia Merkatuaren hondoan. Mahai-lanpara bat. Naini irribarrerik gabe lehen aldiz.',
  'Contádmelo. Paso a paso.': 'Konta iezadazue. Urratsez urrats.',
  'Escucha sin interrumpir. Toma notas. Hace un círculo en el papel.': 'Eteten gabe entzuten du. Oharrak hartzen ditu. Zirkulu bat egiten du paperean.',
  'Esto no es un Fragmento silvestre. Esto es una infraestructura.': 'Hau ez da Zatiki basati bat. Hau azpiegitura bat da.',
  'Alguien está capturando Fragmentos y manteniéndolos vivos para que funcionen en un lugar concreto.': 'Norbaitek Zatikiak harrapatzen ari da eta bizirik mantentzen leku zehatz batean funtziona dezaten.',
  'Se llaman Coleccionistas. Algunos ricos que descubrieron hace décadas que un Fragmento grande, enjaulado, distorsiona el espacio a su alrededor.': 'Bildumagileak deitzen zaie. Aberats batzuek hamarkadak direla aurkitu zuten Zatiki handi batek, kaiolan, inguruko espazioa distortsionatzen duela.',
  'Y si lo pones bien, distorsiona a tu favor.': 'Eta ondo jartzen baduzu, zure alde distortsionatzen du.',
  'Contratos que firmas dentro te favorecen. Reuniones duran lo que te conviene.': 'Barruan sinatzen dituzun kontratuek mesede egiten dizute. Bilerak zuri komeni zaizun denbora irauten dute.',
  'Gente que visita tu oficina olvida la mitad de lo que iba a decirte.': 'Zure bulegoa bisitatzen duen jendeak esan behar zizunaren erdia ahazten du.',
  'Es difícil de probar. Y es muy viejo.': 'Frogatzen zaila da. Eta oso zaharra da.',
  'Ari, esto lo has hecho bien.': 'Ari, hau ondo egin duzu.',
  '{nombre}, tú también.': '{nombre}, zuk ere bai.',
  'Primera vez que un maestro os mira como colegas. No como alumnos.': 'Maisu batek lehen aldiz lankide bezala begiratzen dizue. Ez ikasle bezala.',
  'Lo voy a llevar al Cónclave. Es nivel Fraccionista Mayor.': 'Konklabera eramango dut. Zatikatzaile Nagusi mailakoa da.',
  'Primera vez que un maestro te da las gracias. Ari te mira de reojo. Tú también a ella.': 'Maisu batek lehen aldiz eskerrak ematen dizkizu. Arik zeharka begiratzen dizu. Zuk ere berari.',
  'Vosotros dos no habéis estado nunca en ese muelle. ¿De acuerdo?': 'Zuek biak ez zarete inoiz egon kai horretan. Ados?',
  'Bien. Hala. Id a descansar.': 'Ondo. Hala. Joan atseden hartzera.',
  'Azotea principal. Sora al fondo sin acercarse. Kai sentado contra un respiradero mirando el cielo.': 'Teilatu nagusia. Sora hondoan hurbildu gabe. Kai aireztagailu baten kontra eserita zerura begira.',
  'Te está esperando.': 'Zure zain dago.',
  'Me enteré de lo del muelle 7.': '7. kaikoaren berri jakin nuen.',
  'No vas a creerme, pero...': 'Ez didazu sinetsiko, baina...',
  'Yo llevaba un mes sospechando algo así en la calle donde vive mi padre.': 'Hilabete neraman antzeko zerbait susmatzen nire aitak bizi den kalean.',
  'Kai sin máscara. No es la primera vez que baja la guardia contigo pero sí es la más honda.': 'Kai mozorrorik gabe. Ez da lehen aldia zurekin guardia jaisten duena baina bai sakonena.',
  'No tengo pruebas. Pero cuando la gente entra a cenar con mi padre, salen distintas.': 'Ez dut frogarik. Baina jendea nire aitarekin afaltzera sartzen denean, ezberdin ateratzen dira.',
  'No lo he hablado con nadie.': 'Ez dut inorekin hitz egin.',
  'Necesito ayuda.': 'Laguntza behar dut.',
  'La oficina cerrada. La gente que sale confusa. Dos veces al mes. Mucha gente.': 'Bulegoa itxita. Nahasturik ateratzen den jendea. Hilean bi aldiz. Jende asko.',
  'Porque ya no confío en los que llevo años conociendo. Y tú acabas de hacer algo que yo no sabía hacer.': 'Urteak daramatzadan ezagutzen ditudanetan ez dudalako jada konfiantzarik. Eta zuk nik egiten ez nekien zerbait egin berri duzu.',
  'Gracias por no preguntar nada.': 'Eskerrik asko ezer ez galdetzeagatik.',
  'Mañana te cuento más.': 'Bihar gehiago kontatuko dizut.',
  'Has estado bien. En el duelo.': 'Ondo egon zara. Dueloan.',
  'Sora murmura al fondo, casi para sí misma:': 'Sorak hondoan marmar egiten du, ia bere buruari:',
  'Barrio residencial entre Canales e Industria. Portal de una casa cualquiera. Un Fragmento Impropio de valor 9/5 flota a media altura.': 'Bizitegi-auzoa Kanalen eta Industriaren artean. Edozein etxeren atari bat. 9/5 balioko Zatiki Inpropio bat erdi altueran dabil hegan.',
  'Impropio.': 'Inpropioa.',
  'Si lo convertimos en mixto, es 1 y 4/5.': 'Mistora bihurtzen badugu, 1 eta 4/5 da.',
  '¿Lo estabilizas tú o yo?': 'Zuk egonkortuko duzu edo nik?',
  'Vale. Yo ataco.': 'Ondo. Nik erasoko dut.',
  'Vale. Tú atacas.': 'Ondo. Zuk eraso.',
  'Vale. Juntos.': 'Ondo. Elkarrekin.',
  'El Fragmento se estabiliza. Kai, ya de compañero:': 'Zatikia egonkortzen da. Kai, jada lagun bezala:',
  'Espera.': 'Itxaron.',
  'Ahora.': 'Orain.',
  'Tu turno.': 'Zure txanda.',
  'El Fragmento se disuelve limpio. Kai guarda algo en el bolsillo. No dice qué.': 'Zatikia garbi disolbatzen da. Kaik zerbait gordetzen du poltsikoan. Ez du esaten zer.',
  'Mañana te paso algo por escrito.': 'Bihar idatziz pasatuko dizut zerbait.',
  'De lo de mi padre.': 'Nire aitarena.',
  'Por si no te vuelvo a ver en un tiempo.': 'Denbora batean berriro ikusten ez bazaitut.',
  'Observatorio antiguo al borde de un campo. Cielo estrellado. Dos lunas esta noche.': 'Behatoki zaharra zelai baten ertzean. Zeru izartsua. Bi ilargi gaur gauean.',
  'Ah, tú.': 'Ah, zu.',
  'Brina. Maestra de las Afueras. Y profesora, pero eso es otra cosa.': 'Brina. Kanpoaldeko maistra. Eta irakaslea, baina hori beste gauza bat da.',
  'Déjame pensar.': 'Utzi pentsatzen.',
  'Tú eres el que hizo lo de Zafrán con Sora y acaba de descubrir algo en el Puerto con Ari y trabajó ayer con Kai.': 'Zu zara Zafránena Sorarekin egin zuena eta Portuan Arirekin zerbait aurkitu berri duena eta atzo Kairekin lan egin zuena.',
  'Meses resumidos en una frase.': 'Hilabeteak esaldi batean laburtuta.',
  'Aquí trabajamos con datos. Probabilidades. Tendencias.': 'Hemen datuekin lan egiten dugu. Probabilitateak. Joerak.',
  'Te voy a enseñar una cosa que te va a parecer aburrida. No lo es.': 'Aspergarria irudituko zaizun gauza bat erakutsiko dizut. Ez da.',
  'Te pone una tabla delante. Fechas en una columna. Números que suben en la otra.': 'Taula bat jartzen dizu aurrean. Datak zutabe batean. Igotzen diren zenbakiak bestean.',
  '¿Qué ves?': 'Zer ikusten duzu?',
  'Bien. ¿Sabes qué miden?': 'Ondo. Badakizu zer neurtzen duten?',
  'Te lo iba a contar igual.': 'Berdin kontatuko nizun.',
  'Son Fragmentos. Fragmentos aparecidos en Azula cada mes.': 'Zatikiak dira. Azulan hilero agertutako Zatikiak.',
  'En los últimos dos años han subido un 17% cada trimestre.': 'Azken bi urteetan 17 % igo dira hiruhilekoan.',
  'Nadie se lo cuenta a los Fraccionistas nuevos. No quieren asustar.': 'Inork ez die kontatzen Zatikatzaile berriei. Ez dute izutu nahi.',
  'Pero tú ya eres Iniciado III. Tienes que saber.': 'Baina zu jada Hasiberri III zara. Jakin behar duzu.',
  'Azula está peor cada año.': 'Azula okerrago dago urtetik urtera.',
  'Y no sabemos por qué.': 'Eta ez dakigu zergatik.',
  'Mirador al borde de Afueras. Vista clara a la Montaña. La luna recorta su silueta.': 'Behatokia Kanpoaldearen ertzean. Mendiaren bista garbia. Ilargiak haren silueta ebakitzen du.',
  'Todos acaban mirándola.': 'Denek begiratzen diote azkenean.',
  '¿Irune te ha hablado de ella?': 'Irunek hitz egin dizu hari buruz?',
  'Ahí arriba vive alguien que todavía cree que puede repararse.': 'Han goian bizi da oraindik konpondu daitekeela uste duen norbait.',
  'El Uno. Lo que se rompió.': 'Bata. Apurtu zena.',
  'El Algebrista.': 'Algebralaria.',
  'Vale. Te lo cuento.': 'Ondo. Kontatuko dizut.',
  'Hace décadas que nadie sube. Irune no sube.': 'Hamarkadak dira inor ez dela igotzen. Irune ez da igotzen.',
  'Algunos dicen que ya no vive. Yo creo que sí.': 'Batzuek esaten dute jada ez dela bizi. Nik baietz uste dut.',
  'Algún día vas a querer subir.': 'Egunen batean igo nahi izango duzu.',
  'No hoy. No este año. Pero algún día.': 'Ez gaur. Ez aurten. Baina egunen batean.',
  'Cuando te toque, alguien te ayudará a ir. Irune. Sora. Alguien.': 'Tokatzen zaizunean, norbaitek lagunduko dizu joaten. Irune. Sora. Norbait.',
  'Sala de Irune. Chimenea encendida. Sora al fondo con un libro cerrado. Irune sirve té.': 'Iruneren gela. Tximinia piztuta. Sora hondoan liburu itxi batekin. Irunek tea zerbitzatzen du.',
  'Han pasado muchas cosas.': 'Gauza asko gertatu dira.',
  'Zafrán. El muelle 7. Kai. Eco.': 'Zafrán. 7. kaia. Kai. Eco.',
  'La última palabra con un tono distinto.': 'Azken hitza tonu ezberdin batekin.',
  'Sí. Sé lo de Eco.': 'Bai. Ecorena badakit.',
  'No te preocupes por él. De momento.': 'Ez kezkatu hartaz. Oraingoz.',
  'Has conocido a todos los maestros menos a Oryn bien. Eso te falta.': 'Maisu guztiak ezagutu dituzu Oryn ondo izan ezik. Hori falta zaizu.',
  'Y cuando lo conozcas, estarás listo.': 'Eta ezagutzen duzunean, prest egongo zara.',
  'Iniciado III, pronto. Fraccionista, en unos meses.': 'Hasiberri III, laster. Zatikatzaile, hilabete batzuetan.',
  'Mira a Sora un momento. Sora no se mueve.': 'Sorari une batez begiratzen dio. Sora ez da mugitzen.',
  'Cuando seas Fraccionista, ya no hace falta que nadie vaya contigo a ningún sitio.': 'Zatikatzaile zarenean, jada ez da beharrezkoa inor zurekin inora joatea.',
  'Entonces vas a tener que empezar a decidir tú qué hacer con lo que sabes.': 'Orduan zuk erabaki beharko duzu zer egin dakizunarekin.',
  'Es menos cómodo de lo que parece.': 'Dirudien baino erosotasun gutxiago dakar.',
  'Sonrisa pequeña.': 'Irribarre txikia.',
  'Descansa. Vete con Sora.': 'Atseden hartu. Joan Sorarekin.',
  'Azotea. Borde. Sora apoyada. Tú a su lado. Ninguno habla. Azula abajo, todos sus distritos, la Montaña al fondo.': 'Teilatua. Ertza. Sora bermaturik. Zu haren ondoan. Inork ez du hitz egiten. Azula behean, bere barruti guztiak, Mendia hondoan.',
  'Muelle largo del Puerto. Más niebla que la última vez. Sin Ari.': 'Portuko kai luzea. Lainoa azken aldian baino gehiago. Ari gabe.',
  'Hoy empezamos.': 'Gaur hasiko gara.',
  'Iniciado III. Sí.': 'Hasiberri III. Bai.',
  'Aquí vas a aprender una cosa que parece magia. Multiplicar dos fracciones entre sí.': 'Hemen magia ematen duen gauza bat ikasiko duzu. Bi zatiki elkarrekin biderkatzea.',
  'Dos tercios por tres cuartos.': 'Bi heren bider hiru laurden.',
  'El resultado es más pequeño que los dos.': 'Emaitza biak baino txikiagoa da.',
  'Parece mentira. No lo es.': 'Gezurra dirudi. Ez da.',
  'Cobertizo al final del muelle. Un tablón viejo con cuerdas con nudos. Un dispositivo de entrenamiento casero.': 'Etxola kaiaren amaieran. Ohol zahar bat korapiloak dituzten sokekin. Etxeko entrenamendu-tresna bat.',
  'Esto lo hice yo. Hace años.': 'Hau nik egin nuen. Urteak direla.',
  'Cuando multiplicas una fracción por otra, tomas una parte de una parte.': 'Zatiki bat beste batez biderkatzen duzunean, zati baten zati bat hartzen duzu.',
  'Si te quedas con la mitad de tres cuartos, ¿cuánto tienes?': 'Hiru laurdenen erdiarekin gelditzen bazara, zenbat duzu?',
  'No. La mitad de algo es menos.': 'Ez. Zerbaiten erdia gutxiago da.',
  'Tres octavos. Menos que un medio. Menos que tres cuartos. Pero es la mitad de ese tres cuartos.': 'Hiru zortziren. Erdi bat baino gutxiago. Hiru laurden baino gutxiago. Baina hiru laurden horren erdia da.',
  'No. Estás cogiendo la mitad, pero de tres cuartos, no de un entero.': 'Ez. Erdia hartzen ari zara, baina hiru laurdenena, ez oso batena.',
  'Esto hay que verlo muchas veces para que no parezca raro.': 'Hau askotan ikusi behar da arraroa ez dirudien arte.',
  'Madrugada. El cielo aclara muy despacio. Oryn mira el mar durante tres minutos reales. Tú estás ahí.': 'Goizaldea. Zerua oso astiro argitzen da. Orynek itsasoari begiratzen dio hiru minutu errealez. Zu hor zaude.',
  '{nombre}. Una cosa.': '{nombre}. Gauza bat.',
  'El agua recuerda.': 'Urak gogoratzen du.',
  'Silencio de cuatro segundos. La frase respira.': 'Lau segundoko isiltasuna. Esaldiak arnasa hartzen du.',
  'Esa es una de las dos veces en que te lo voy a decir.': 'Hori esango dizudan bi aldietako bat da.',
  'Si alguna vez estás perdido, vuelve aquí. No te digo por qué.': 'Inoiz galduta bazaude, itzuli hona. Ez dizut zergatik esaten.',
  'Solo vuelve.': 'Itzuli besterik ez.',
  'Mañana más. Descansa.': 'Bihar gehiago. Atseden hartu.',
  'Abre la bolsa impermeable que nunca abre delante de nadie. Saca una concha plana pulida con un agujero natural y un hilo fino.': 'Inoren aurrean inoiz irekitzen ez duen poltsa iragazgaitza irekitzen du. Maskor lau leundu bat ateratzen du zulo natural batekin eta hari mehe batekin.',
  'No vale nada. Pero la llevo mucho tiempo.': 'Ez du ezer balio. Baina denbora luzea darama.',
  'Ahora la llevas tú.': 'Orain zuk daramazu.',
  'Cierra la bolsa. Entra al cobertizo. Cierra la puerta.': 'Poltsa ixten du. Etxolan sartzen da. Atea ixten du.',
  'Muro exterior al borde de Afueras. La misma mano que las dos anteriores.': 'Kanpoko horma Kanpoaldearen ertzean. Aurreko bien esku berbera.',
  'Frase nueva: "En la parte está la libertad."': 'Esaldi berria: "Zatian dago askatasuna."',
  'Debajo, otra pintura más reciente, distinta, tachando la primera: "La parte sola no libra a nadie."': 'Behean, beste pintura berriago bat, ezberdina, lehena marratuz: "Zatiak bakarrik ez du inor askatzen."',
  'Las dos frases coexisten. Alguien ha respondido.': 'Bi esaldiak elkarrekin daude. Norbaitek erantzun du.',
  'Un callejón parecido al de la primera vez. El mundo baja de volumen otra vez.': 'Lehen aldikoaren antzeko kalezulo bat. Munduak bolumena jaisten du berriz.',
  'Pero nada aparece.': 'Baina ezer ez da agertzen.',
  'Silencio. Quince segundos. Te quedas quieto.': 'Isiltasuna. Hamabost segundo. Geldi gelditzen zara.',
  'El sonido vuelve. Sin explicación. Sientes que Eco estuvo a punto.': 'Soinua itzultzen da. Azalpenik gabe. Eco gertu egon zela sentitzen duzu.',
  'Sala de Irune. Un plato de pastas pequeñas — nunca las había sacado antes. Dos tazas de té.': 'Iruneren gela. Pasta txikien plater bat — inoiz ez zituen lehenago atera. Bi te-katilu.',
  'Te he llamado porque ha llegado el momento.': 'Deitu dizut unea iritsi delako.',
  'Estás listo para la Prueba.': 'Probarako prest zaude.',
  'No significa que sepas todo lo que tienes que saber. Significa que ya puedes demostrar lo que sabes.': 'Ez du esan nahi jakin behar duzun guztia dakizunik. Esan nahi du jada erakuts dezakezula dakizuna.',
  'La diferencia es fina. Es real.': 'Aldea fina da. Erreala da.',
  'Puedes decir que no. Puedes esperar unos meses. No te voy a presionar.': 'Ezetz esan dezakezu. Hilabete batzuk itxaron ditzakezu. Ez zaitut presionatuko.',
  'Pero si dices que sí, te explico las tres formas.': 'Baina baietz esaten baduzu, hiru moduak azalduko dizkizut.',
  'Bien. Escucha.': 'Ondo. Entzun.',
  'Siéntate y te las explico.': 'Eseri eta azalduko dizkizut.',
  'Tres Pruebas. Tú eliges una.': 'Hiru Proba. Zuk bat aukeratzen duzu.',
  'Primera. Prueba de Fuego. Combate contra un Fragmento representativo de tu rango. Sin ayudas, sin Sora. Tú solo.': 'Lehena. Suaren Proba. Zure mailako Zatiki adierazgarri baten kontrako borroka. Laguntzarik gabe, Sora gabe. Zu bakarrik.',
  'Es la más rápida. Tres minutos, cuatro. Intensa.': 'Azkarrena da. Hiru minutu, lau. Bizia.',
  'Para los que tienen confianza en su cuerpo.': 'Beren gorputzean konfiantza dutenentzat.',
  'Segunda. Prueba de Sendero. Serie larga de Fragmentos, todos los tipos, con margen de error limitado. Mide tu fluidez.': 'Bigarrena. Bidearen Proba. Zatiki sorta luzea, mota guztietakoak, errore-marjina mugatuarekin. Zure jariotasuna neurtzen du.',
  'Es la más lenta. Veinte minutos. Meditativa.': 'Geldoena da. Hogei minutu. Meditatiboa.',
  'Para los que tienen paciencia.': 'Pazientzia dutenentzat.',
  'Tercera. Prueba de Espejo.': 'Hirugarrena. Ispiluaren Proba.',
  'Tienes que enseñar a alguien más joven que tú. Un Fraccionista que está donde tú estabas hace un año.': 'Zu baino gazteagoa den norbaiti irakatsi behar diozu. Duela urtebete zu zinen lekuan dagoen Zatikatzaile bat.',
  'Te enfrentas a sus fallos. Le ayudas a resolverlos. Le haces preguntas, no le das respuestas.': 'Bere akatsei aurre egiten diezu. Ebazten laguntzen diozu. Galderak egiten dizkiozu, ez diozu erantzunik ematen.',
  'Mide si entiendes lo que has aprendido. Si puedes explicarlo a otro.': 'Ikasi duzuna ulertzen duzun neurtzen du. Beste bati azaldu diezaiokezun.',
  'Es la más difícil. Y la más importante, para muchos.': 'Zailena da. Eta garrantzitsuena, askorentzat.',
  'Las tres valen lo mismo. Ninguna es superior a las otras. Elige.': 'Hirurek balio bera dute. Bat bera ere ez da besteen gainetik. Aukeratu.',
  'Bien. Mañana. Aquí. Después de cenar.': 'Ondo. Bihar. Hemen. Afaldu ondoren.',
  'Azotea. Sora de pie con los brazos cruzados. Te estaba esperando.': 'Teilatua. Sora zutik besoak gurutzaturik. Zure zain zegoen.',
  '¿Cuál?': 'Zein?',
  'Dices: Fuego.': 'Esaten duzu: Sua.',
  'Clásica. Bien.': 'Klasikoa. Ondo.',
  'Solo una cosa. No vayas rápido. No es una carrera. La velocidad se entiende mal.': 'Gauza bakarra. Ez joan azkar. Ez da lasterketa bat. Abiadura gaizki ulertzen da.',
  'Respira en los cambios. Descomponer es también parar.': 'Arnasa hartu aldaketetan. Deskonposatzea ere gelditzea da.',
  'Suerte, {nombre}.': 'Zorte on, {nombre}.',
  'Cenamos. Luego entras.': 'Afaldu egingo dugu. Gero sartu.',
  'Dices: Sendero.': 'Esaten duzu: Bidezidorra.',
  'Paciente. Bien.': 'Pazientziaz. Ondo.',
  'Es la que hice yo.': 'Nik egin nuena da.',
  'Si te cansas a mitad, no te pares del todo. Cambia de ritmo. Descansa mientras sigues.': 'Erdian nekatzen bazara, ez gelditu erabat. Aldatu erritmoa. Jarraitzen duzun bitartean atseden hartu.',
  'Dices: Espejo. Sora se queda callada dos segundos.': 'Esaten duzu: Ispilua. Sora bi segundoz isilik geratzen da.',
  'Esa es la más personal.': 'Hori da pertsonalena.',
  'Ten cuidado con lo que le dices al otro. A veces se te escapan cosas que no sabías que pensabas.': 'Kontuz besteari esaten diozunarekin. Batzuetan, pentsatzen zenituela ez zenekizkien gauzak ihes egiten dizute.',
  'Y a veces... el otro se parece a alguien que no esperas.': 'Eta batzuetan... bestea espero ez zenuen norbaiten antza du.',
  'Silencio. Sora nunca había sido tan explícita. No te mira directo.': 'Isiltasuna. Sora ez zen inoiz hain argia izan. Ez dizu zuzenean begiratzen.',
  'Tengo que hacer un encargo. Te alcanzo al final.': 'Mandatu bat egin behar dut. Amaieran iritsiko naiz.',
  'Azotea. Seis maestros. Sora. Kai. Ari. Ninguno habla durante el combate. Vorax se retira hacia arriba como Zafrán.': 'Teilatua. Sei maisu. Sora. Kai. Ari. Borrokan inork ez du hitz egiten. Vorax goraka erretiratzen da, Zafrán bezala.',
  'Prueba de Sendero.': 'Bidezidorraren proba.',
  'Esta noche vas a recorrer la ciudad. Cuatro distritos. Una prueba en cada uno.': 'Gaur gauean hiria zeharkatuko duzu. Lau auzo. Proba bana bakoitzean.',
  'En cada distrito te espera un Fragmento distinto, diseñado por el maestro correspondiente.': 'Auzo bakoitzean Zatiki desberdin bat dago zain, dagokion maisuak diseinatua.',
  'Nadie te va a acompañar. Nadie te va a ayudar.': 'Inork ez zaitu lagunduko. Inork ez dizu lagunduko.',
  'Empiezas en los Canales.': 'Kanaletan hasiko zara.',
  'Canales. Niebla baja. Un Fragmento Espejo 5/10 esperando. Lo emparejas con 1/2. Silencio.': 'Kanalak. Lainoa baxua. 5/10 Ispilu Zatiki bat zain. 1/2-rekin parekatzen duzu. Isiltasuna.',
  'Industria. Luz gris. Un Fragmento con unidades que no cuadran: 1,2 kg más 800 g. Un punto dos kilos.': 'Industria. Argi grisa. Bat ez datozen unitateak dituen Zatiki bat: 1,2 kg gehi 800 g. Kilo bat puntu bi.',
  'Mercado. Puestos cerrando. Un Fragmento con 40 manzanas y una pregunta: el 25% son rojas. Diez rojas.': 'Merkatua. Postuak ixten. 40 sagar eta galdera bat dituen Zatiki bat: 25 % gorriak dira. Hamar gorri.',
  'Afueras. Observatorio. Un Fragmento con una tendencia: tres meses subiendo 5. Lo que viene ya lo sabes.': 'Hiri kanpoaldea. Behatokia. Joera bat duen Zatiki bat: hiru hilabete 5 igotzen. Datorrena badakizu.',
  'Subes al Edificio de los Tejados antes del amanecer. Irune en la puerta.': 'Teilatuetako Eraikinera igotzen zara egunsentia baino lehen. Irune atean.',
  'Sala de Irune. Cerrada. Luz tenue. Dos sillas frente a frente. Irune sale. Niko sentado enfrente.': 'Iruneren gela. Itxita. Argi epela. Bi aulki elkarren parean. Irune irteten da. Niko parean eserita.',
  'Pelo que te recuerda a alguien. Un gesto que no sabes por qué reconoces.': 'Norbait gogorarazten dizun ilea. Zergatik ezagutzen duzun ez dakizun keinu bat.',
  'Tengo que aprender contigo.': 'Zurekin ikasi behar dut.',
  'Irune me ha dicho que me vas a ayudar.': 'Iruneak esan dit lagunduko didazula.',
  'Ejercicio 1: 2/3 + 1/5 = ? Niko ha puesto 3/8 (sumando numeradores y denominadores).': '1. ariketa: 2/3 + 1/5 = ? Nikok 3/8 jarri du (zenbakitzaileak eta izendatzaileak batuz).',
  'No entiendo por qué está mal.': 'Ez dut ulertzen zergatik dagoen gaizki.',
  'Vale, gracias.': 'Ondo, eskerrik asko.',
  'Más. Porque un tercio ya es casi medio. ¡Ah!': 'Gehiago. Heren bat ia erdia delako. A!',
  'No. ¡Ah!': 'Ez. A!',
  'Niko calcula por su cuenta. Se pasa la mano por el pelo hacia atrás dos veces.': 'Nikok bere kabuz kalkulatzen du. Eskua ilean atzerantz pasatzen du bi aldiz.',
  '13/15. ¿Así está bien?': '13/15. Horrela ondo dago?',
  'Ejercicio 2: 35% de 80 = ?': '2. ariketa: 80ren 35 % = ?',
  'Sé que es algo así como 30. Pero no sé cómo pensarlo.': 'Badakit 30 ingurukoa dela. Baina ez dakit nola pentsatu.',
  'Vale. 28.': 'Ondo. 28.',
  '24. Y 5% son 4. ¡28!': '24. Eta 5 % 4 da. 28!',
  'Se pasa la mano por el pelo otra vez. Dos veces. Como Sora cuando se concentra.': 'Eskua ilean berriro pasatzen du. Bi aldiz. Sorak kontzentratzen denean bezala.',
  'Irune me dijo que si alguien te explicaba esto bien, lo ibas a recordar siempre.': 'Iruneak esan zidan norbaitek hau ondo azaltzen bazidan, beti gogoratuko nuela.',
  'Tú me lo explicaste bien.': 'Zuk ondo azaldu didazu.',
  'Irune entra.': 'Irune sartzen da.',
  'Se acabó.': 'Bukatu da.',
  'Niko se va por una puerta que no habías visto. "Hasta mañana."': 'Niko ikusi ez zenuen ate batetik joaten da. "Bihar arte."',
  'Sora te espera fuera.': 'Sora kanpoan zain duzu.',
  'Azotea, amanecer empezando. Todos los maestros en semicírculo. Sora entre ellos pero un paso atrás. Kai y Ari junto a la escalera.': 'Teilatua, egunsentia hasten. Maisu guztiak zirkulu erdian. Sora haien artean baina pauso bat atzeraka. Kai eta Ari eskaileraren ondoan.',
  'Repite conmigo.': 'Errepikatu nirekin.',
  'Prometo buscar el Uno que fue.': 'Izan zen Bata bilatzea agintzen dut.',
  'Repites.': 'Errepikatzen duzu.',
  'Prometo proteger el mundo que queda.': 'Geratzen den mundua babestea agintzen dut.',
  'Prometo no pretender nunca que sé más de lo que sé.': 'Dakidana baino gehiago dakidala inoiz ez itxuratzea agintzen dut.',
  'Saca una marca nueva — más grande, plata clara, símbolo de la orden en relieve. Te cambia la del cuello.': 'Marka berri bat ateratzen du — handiagoa, zilar argia, ordenaren ikurra erliebean. Lepokoa aldatzen dizu.',
  'Bienvenido, Fraccionista.': 'Ongi etorri, Frakziozale.',
  'Hace mucho que no ponía una de estas.': 'Aspaldi ez nuen horietako bat jartzen.',
  'Cada maestro da un paso adelante y dice su palabra antigua:': 'Maisu bakoitzak pauso bat aurrera ematen du eta bere hitz zaharra esaten du:',
  'Cinco "bien" con cinco voces distintas. Hermoso sin necesitar más.': 'Bost "ondo" bost ahots desberdinekin. Ederra, gehiago behar gabe.',
  'Sora da un paso adelante. Frente a ti. Silencio de tres segundos.': 'Sorak pauso bat aurrera ematen du. Zure parean. Hiru segundoko isiltasuna.',
  'En serio. Gracias.': 'Benetan. Eskerrik asko.',
  'La palabra dicha dos veces. Enorme para Sora. Se aparta al borde del semicírculo.': 'Hitza bi aldiz esana. Izugarria Sorarentzat. Zirkulu erdiaren ertzera baztertzen da.',
  'Por hoy está.': 'Gaurkoz nahikoa.',
  'Esquina apartada de la azotea. Dos vasos pequeños humeantes.': 'Teilatuko bazterreko ertza. Bi edalontzi txiki keatzen.',
  'Bébelo caliente.': 'Edan bero-bero.',
  'Te ha tocado llevarme en este año.': 'Aurten ni eramatea egokitu zaizu.',
  'Has sido muy buen aprendiz.': 'Ikasle ona izan zara.',
  'Ya no eres mi aprendiz. Ahora eres mi colega.': 'Ez zara jada nire ikaslea. Orain nire kidea zara.',
  'Si alguna vez quieres bajar a los Canales solo para hablar, me avisas.': 'Inoiz Kanaletara hitz egitera bakarrik jaitsi nahi baduzu, abisatu.',
  'Yo estaré.': 'Han egongo naiz.',
  'Saca una pequeña marca vieja, muy desteñida.': 'Marka zahar txiki bat ateratzen du, oso higatua.',
  'Era la primera marca de Fraccionista que me pusieron.': 'Hau zen jarri zidaten Frakziozale lehen marka.',
  'Ya tengo otras con más filetes azules.': 'Marra urdin gehiagoko beste batzuk ditut jada.',
  'Pero esta es la primera.': 'Baina hau da lehena.',
  'Cuida la tuya, {nombre}.': 'Zaindu zurea, {nombre}.',
  'Otra parte de la azotea. Kai apoyado en un respiradero, solo.': 'Teilatuaren beste alde batean. Kai aireztapen batean bermatuta, bakarrik.',
  'Fraccionista.': 'Frakziozale.',
  'Va delante, mira.': 'Aurretik doa, begira.',
  'Se señala a sí mismo. Sigue siendo Iniciado III. Tú ahora un rango por encima.': 'Bere burua seinalatzen du. Hasiberri III da oraindik. Zu orain maila bat goraxeago.',
  'Yo lo soy en unos meses. Si no me distraigo.': 'Hilabete batzuetan lortuko dut. Ez banaiz despistatzen.',
  'Lo de mi padre sigue en pie. Cuando me recuperes como colega, hablamos.': 'Aitarena oraindik zutik dago. Kide gisa berriz topatzen nauzunean, hitz egingo dugu.',
  'Enhorabuena, {nombre}.': 'Zorionak, {nombre}.',
  'Asiente una sola vez. Forma máxima de reconocimiento. Primera vez que dice "enhorabuena".': 'Behin baino ez du baietz egiten. Aitorpen modurik handiena. Lehen aldia "zorionak" esaten duela.',
  'Todos se han ido. Sora sentada en el borde norte, piernas colgando. Alba avanzada. La ciudad con luz limpia por primera vez. Distritos distinguibles. Montaña al fondo.': 'Denak joan dira. Sora iparraldeko ertzean eserita, hankak zintzilik. Egunsenti aurreratua. Hiria argi garbiarekin lehen aldiz. Auzoak bereiztu daitezke. Mendia hondoan.',
  'Bueno.': 'Bueno.',
  'Lo has hecho.': 'Lortu duzu.',
  'Te voy a decir una cosa y luego no la digo más.': 'Gauza bat esango dizut eta gero ez dut gehiago esango.',
  'Yo llegué a Azula hace dos años. Sola.': 'Ni Azulara duela bi urte iritsi nintzen. Bakarrik.',
  'Mi ciudad se llamaba Kir. Estaba al norte, al borde del mar.': 'Nire hiria Kir zen. Iparraldean zegoen, itsasoaren ertzean.',
  'La palabra KIR queda un instante en el aire. Recuérdala.': 'KIR hitza istant batez airean geratzen da. Gogoratu.',
  'La perdimos.': 'Galdu egin genuen.',
  'Yo tenía once años cuando pasó.': 'Hamaika urte nituen gertatu zenean.',
  'Silencio muy largo.': 'Isiltasun oso luzea.',
  'No entré aquí porque quisiera salvar el mundo.': 'Ez nintzen hona sartu mundua salbatu nahi nuelako.',
  'Entré porque no quería que pasara otra vez.': 'Sartu nintzen ez nuelako berriz gerta zedin nahi.',
  'Eso es todo. Pregúntame otro día si quieres más.': 'Hori da dena. Galdetu beste egun batean gehiago nahi baduzu.',
  'No creo que lo hagas.': 'Ez dut uste egingo duzunik.',
  'Media sonrisa.': 'Erdi irribarrea.',
  'Tú no preguntas. Me gustó desde el principio.': 'Zuk ez duzu galdetzen. Gustatu zitzaidan hasieratik.',
  'Gesto hacia la Montaña.': 'Mendirantz keinua.',
  'Brina te habló de ella.': 'Brinak hartaz hitz egin zizun.',
  'Ahí sube el que sea Fraccionista Mayor.': 'Hor igotzen da Frakziozale Nagusia dena.',
  'Yo tardaré. Tú tardarás más aún, porque empezaste más tarde.': 'Nik denbora beharko dut. Zuk are gehiago, beranduago hasi zinelako.',
  'Pero cuando llegue el momento, subimos juntos.': 'Baina unea iristen denean, elkarrekin igoko gara.',
  'Te lo prometo.': 'Agintzen dizut.',
  'No te prometo que la pelea valga la pena.': 'Ez dizut agintzen borrokak merezi izango duenik.',
  'Te prometo que te acompaño.': 'Agintzen dizut zurekin joango naizela.',
  'Saca la brújula vieja. Te cierra los dedos sobre ella.': 'Iparrorratz zaharra ateratzen du. Behatzak haren gainean ixten dizkizu.',
  'Quédatela.': 'Geratu zurea.',
  'Ya no la necesito yo.': 'Nik ez dut jada behar.',
  'Amanecer completo. La Montaña iluminada con nitidez por primera vez. Rocas. Laderas. Cumbre nevada. Un sendero tenue en un flanco.': 'Egunsenti osoa. Mendia argiz argituta lehen aldiz. Harriak. Hegalak. Gailur elurtua. Bidezidor mehe bat alde batean.',
  'Tú y Sora como siluetas pequeñas de espaldas. Viento. Amanecer.': 'Zu eta Sora silueta txikiak bizkarrez. Haizea. Egunsentia.',
  'Silencio. Fundido a blanco.': 'Isiltasuna. Zuriz urtua.',
  'FIN DEL ARCO IV. EL ASCENSO.': 'IV. ARKUAREN AMAIERA. IGOERA.',
  'URO UNO ROTO': 'URO BAT HAUTSIA',
  'FIN DEL MVP.': 'MVP-aren AMAIERA.',
  'HASTA ENTONCES': 'ORDU ARTE',
  'Noche despejada. Las dos lunas bajas, claras.': 'Gau argia. Bi ilargiak baxu, garbi.',
  'Arriba. Abajo. Arriba. Abajo.': 'Gora. Behera. Gora. Behera.',
  'Céntrate.': 'Zentratu.',
  'Cuando se parte un Fragmento, no pienses en las partes.': 'Zatiki bat hausten denean, ez pentsatu zatietan.',
  'Piensa en el tamaño de cada parte.': 'Pentsatu zati bakoitzaren tamainan.',
  'Las partes pequeñas son más fáciles. Siempre.': 'Zati txikiak errazagoak dira. Beti.',
  'Niebla baja. No se ven las lunas. La ciudad se oye pero no se ve.': 'Lainoa baxua. Ilargiak ez dira ikusten. Hiria entzuten da baina ez ikusten.',
  'Días así, hay más Fragmentos.': 'Halako egunetan, Zatiki gehiago daude.',
  'No sé por qué. Irune dice que la niebla les gusta.': 'Ez dakit zergatik. Iruneak dio lainoa gustatzen zaiela.',
  'Mantente cerca.': 'Egon gertu.',
  'La sesión es más corta esta noche. Sora lo nota.': 'Saioa motzagoa da gaur gauean. Sora konturatzen da.',
  'Hoy no más. Mañana.': 'Gaur ez gehiago. Bihar.',
  'Lluvia ligera. Las tejas mojadas brillan bajo las farolas.': 'Euri arina. Teila bustiak distiratzen dute farolen azpian.',
  'Si te caes, te caes. No pasa nada.': 'Erortzen bazara, erortzen zara. Ez da ezer gertatzen.',
  'Cae mejor.': 'Eror hobeto.',
  'Risa corta. Solo un instante — se la traga enseguida.': 'Barre laburra. Istant bat besterik ez — berehala irensten du.',
  'Cielo muy limpio. La Montaña se ve entera al horizonte.': 'Zeru oso garbia. Mendia osorik ikusten da hondoertzean.',
  'Sora la mira sin decir nada un rato largo.': 'Sorak begiratzen dio ezer esan gabe denbora luzez.',
  'Un Algebrista. O eso dicen. Fragmentos. Vamos.': 'Algebralari bat. Edo hori esaten dute. Zatikiak. Goazen.',
  'Porque no quiero llegar tarde.': 'Berandu iritsi nahi ez dudalako.',
  'Otro día.': 'Beste egun batean.',
  'Hablas poco. Me gusta.': 'Gutxi hitz egiten duzu. Gustatzen zait.',
  'La sesión termina antes de lo previsto. Sora asiente una vez.': 'Saioa aurreikusitakoa baino lehen amaitzen da. Sorak behin baietz egiten du.',
  'Aprendes rápido.': 'Azkar ikasten duzu.',
  'No te lo creas mucho.': 'Ez sinetsi gehiegi.',
  'Baja por la escalera sin girarse.': 'Eskaileretatik jaisten da bira eman gabe.',
  'Hasta mañana.': 'Bihar arte.',
  'Eh. Eres tú, ¿no?': 'E. Zu zara, ezta?',
  'Me han dicho que tienes buen ojo.': 'Esan didate begi ona duzula.',
  'Vamos a ver si es verdad.': 'Ikusiko dugu egia den.',
  'Mira ahí abajo. En el callejón.': 'Begiratu hor behean. Kalezuloan.',
  'Ese se come el cartel de neón. Pártelo en dos.': 'Horrek neoizko kartela jaten du. Bitan zatitu.',
  'Otro. Este va a por el reloj del kiosco. En tres.': 'Beste bat. Honek kioskoaren erlojua nahi du. Hirutan.',
  'Fácil. El letrero de la panadería. En dos.': 'Erraza. Okindegiaren errotulua. Bitan.',
  'Ese se ha tragado media ventana. En cuatro iguales.': 'Horrek leiho erdia irentsi du. Lau zati berdinetan.',
  'Baja al metro ese. Tres trenes dependen de cómo cortes esto.': 'Jaitsi metro horretara. Hiru trenek nola mozten duzun horren arabera dute.',
  'Este es rápido. Se come lo que la gente intenta decir. En cinco.': 'Hau azkarra da. Jendeak esan nahi duena jaten du. Bostetan.',
  'Cuatro escalones, cuatro cortes. Mira el centro.': 'Lau eskailera, lau ebaki. Begiratu erdira.',
  'Banderines. Cuélgalo tú otra vez. En tres.': 'Banderatxoak. Eseki itzazu berriro. Hirutan.',
  'Quíntuple. Si no lo pillas, toda la calle va a retraso.': 'Bost halako. Hartzen ez baduzu, kale osoa atzeratzen da.',
  'Último de esta noche. El espejo de la moto. En cuatro.': 'Gaur gaueko azkena. Motorraren ispilua. Lautan.',
  'Ya está por hoy.': 'Gaurkoz nahikoa.',
  'Diez Fragmentos. No se te da mal.': 'Hamar Zatiki. Ez zaizu gaizki ematen.',
  'Vete a dormir. Mañana los cazamos más gordos.': 'Joan lotara. Bihar handiagoak ehizatuko ditugu.',
  'Anda, has vuelto.': 'Hara, itzuli zara.',
  'Pensaba que te habías asustado.': 'Beldurtu zinela uste nuen.',
  'Hoy hay más. Venga.': 'Gaur gehiago daude. Goazen.',
  'Bici abandonada al fondo. Tres pedales quedan visibles.': 'Bizikleta abandonatua hondoan. Hiru pedal ikusgai geratzen dira.',
  'La sombra del farol. En dos. Sin pensarlo mucho.': 'Farolaren itzala. Bitan. Gehiegi pentsatu gabe.',
  'Radio del vecino del cuarto. Cinco emisoras. No deja oír nada.': 'Laugarreneko bizilagunaren irratia. Bost emisora. Ez du ezer entzuten uzten.',
  'Cartel roto. Cuatro esquinas que no cuadran.': 'Kartel hautsia. Bat ez datozen lau ertz.',
  'Semáforo. Tres colores. Se está comiendo el amarillo.': 'Semaforoa. Hiru kolore. Horia jaten ari da.',
  'Molinillo en una ventana. Cinco aspas. Se ha parado por su culpa.': 'Errota txiki bat leihoan. Bost hego. Haren erruz gelditu da.',
  'Alcantarilla cuadrada. Cuatro lados. Uno va a faltar.': 'Estolda karratua. Lau alde. Bat falta izango da.',
  'Paloma durmiendo en una cornisa. En dos. Sin hacer ruido.': 'Uso bat lo erlaitzean. Bitan. Zaratarik atera gabe.',
  'Música de un bar. Tres estrofas. Se comen alternas.': 'Taberna bateko musika. Hiru ahapaldi. Tartekatuta jaten dituzte.',
  'Último. Este se come el tiempo antes de que salga el sol. Cinco.': 'Azkena. Honek eguzkia atera baino lehenagoko denbora jaten du. Bost.',
  'Mira. Ya es casi de día.': 'Begira. Ia eguna da jada.',
  'Veinte Fragmentos en dos noches.': 'Hogei Zatiki bi gauetan.',
  'No está mal.': 'Ez dago gaizki.',
  'Vete a descansar.': 'Joan atseden hartzera.',
  'Vaya. Ya eres habitual.': 'Hara. Ohikoa zara dagoeneko.',
  'Hoy no valen los fáciles.': 'Gaur errazek ez dute balio.',
  'Algunos Fragmentos son a trozos. No los partes de una vez.': 'Zatiki batzuk zatika datoz. Ez dituzu aldi berean hausten.',
  'Uno a uno. Como quien desata un nudo.': 'Banaka. Korapilo bat askatzen duenak bezala.',
  'Entramos suaves. Un zapato olvidado. En tres.': 'Goxo sartzen gara. Ahaztutako oinetako bat. Hirutan.',
  'Ese ha mordido dos tercios. Son dos trozos de un tercio. Uno, y después otro.': 'Horrek bi heren hozka egin ditu. Heren bateko bi zati dira. Bat, eta gero bestea.',
  'Grafiti nuevo. Cuatro colores. Córtalo igual.': 'Grafiti berria. Lau kolore. Moztu berdin.',
  'Tres cuartos de la ventana del ático. Tres veces en cuatro.': 'Atikoaren leihoaren hiru laurden. Hiru aldiz lautan.',
  'Guitarra en el balcón. Cinco cuerdas. Suave.': 'Gitarra balkoian. Bost soka. Leun.',
  'Marquesina rota. Dos quintos. Dos pasadas en cinco.': 'Markesina hautsia. Bi bosten. Bi pasaldi bostetan.',
  'Mosaico de la plaza. Cinco de seis baldosas. Concentra.': 'Plazako mosaikoa. Sei baldosatik bost. Kontzentratu.',
  'El eco del último tren. En dos. Rápido antes de que pare.': 'Azken trenaren oihartzuna. Bitan. Azkar gelditu baino lehen.',
  'Ironía: Fragmento devora tres de cinco carteles. Tres trozos en cinco.': 'Ironia: Zatikiak bost karteletatik hiru irensten ditu. Hiru zati bostetan.',
  'Este se ha comido casi el reloj entero. Siete de ocho. Paciencia.': 'Honek erlojua ia osorik jan du. Zortzitik zazpi. Pazientzia.',
  'Bien. Los compuestos no son un muro.': 'Ondo. Konposatuak ez dira horma bat.',
  'Son una cadena. Un eslabón cada vez.': 'Kate bat dira. Begi bat aldiro.',
  'Mañana te presento a alguien.': 'Bihar norbait aurkeztuko dizut.',
  'Vete a dormir.': 'Joan lotara.',
  'Venga, sin calentar.': 'Goazen, berotu gabe.',
  'Hoy vas con los ojos abiertos.': 'Gaur begiak zabalik joango zara.',
  'Y te aguantas lo que toque.': 'Eta egokitzen dena jasango duzu.',
  'Plaza central. Cuatro farolas. Una a una.': 'Erdiko plaza. Lau farola. Banaka.',
  'Escaparate de la tintorería. Dos trozos en cinco.': 'Tindategiaren erakusleihoa. Bi zati bostetan.',
  'Vecinas discutiendo en el patio. En tres. Que vuelvan a oírse.': 'Bizilagunak patioan eztabaidan. Hirutan. Berriz entzun daitezela.',
  'Ni me mires. El de Kai. Cinco trozos en siete. Tú solo.': 'Ez niri begiratu. Kairena. Bost zati zazpitan. Zuk bakarrik.',
  'Respira. Batería de un bar. En cinco. Coge su compás.': 'Arnasa hartu. Taberna bateko bateria. Bostetan. Hartu bere konpasa.',
  'Mural pintado hace un mes. Tres cuartos. No dejes que se borre.': 'Duela hilabete margotutako horma-irudia. Hiru laurden. Ez utzi ezabatzen.',
  'Conversación a medias. En dos. Que las dos partes se oigan.': 'Erdi-elkarrizketa. Bitan. Bi zatiak entzun daitezela.',
  'El tejado de este edificio. Casi entero. Cuatro en cinco.': 'Eraikin honen teilatua. Ia osorik. Lau bostetan.',
  'Este se come los días. Tres de siete. Te los devuelves.': 'Honek egunak jaten ditu. Zazpitik hiru. Itzultzen dizkiozu.',
  'Último. Cinco octavos de la calle entera. Con calma.': 'Azkena. Kale osoaren bost zortziren. Lasai.',
  'Vaya, vaya.': 'Hara, hara.',
  'Tú eres el que se rumorea.': 'Zu zara aipatzen dutena.',
  'Me han dicho que vas por el tercero en los tejados.': 'Esan didate hirugarrenean zabiltzala teilatuetan.',
  'Yo iba por el séptimo a tu edad.': 'Ni zazpigarrenean nenbilen zure adinean.',
  'Toma. Este se me ha cruzado. Todo tuyo.': 'Tori. Hau bidean topatu dut. Dena zurea.',
  'A ver cómo sales.': 'Ikus dezagun nola ateratzen zaren.',
  'Déjalo. Ya se irá.': 'Utzi. Joango da.',
  'Y no le contestes. Le pone.': 'Eta ez erantzun. Pizten du.',
  'Ha estado bien. El de Kai lo has llevado.': 'Ondo egon da. Kairena ondo eraman duzu.',
  'No se lo digas. Ya lo sabe.': 'Ez esan. Badaki.',
  'Vete a dormir. Mañana otra vez.': 'Joan lotara. Bihar berriro.',
  // Líneas ambient de Sora durante la caza (pantalla_caza)
  'Ya volverá otro.': 'Beste bat etorriko da.',
  'Bien. El primero ya es tuyo.': 'Ondo. Lehenengoa zurea da jada.',
  'Cinco. Te estás haciendo a esto.': 'Bost. Honetara ohitzen ari zara.',
  'Diez en una noche. Mira el barrio.': 'Hamar gau batean. Begira auzoari.',
  'Veinte. A ver si te atreves con los primos.': 'Hogei. Lehen-zenbakiekin ausartzen zaren ikusiko dugu.',
  'Otro menos.': 'Beste bat gutxiago.',
  'Así.': 'Horrela.',
  'Bien visto.': 'Ondo ikusia.',
  'Sigue.': 'Jarraitu.',
  'Se te ha ido. No pasa nada.': 'Joan zaizu. Ez da ezer gertatzen.',
  'Se han escapado varios. Atento.': 'Asko ihes egin dute. Erne.',
  // Saludos de distrito (catalogo_distritos.dart)
  'Tejados. Lo básico. Aquí te haces la mano.': 'Teilatuak. Oinarrizkoa. Hemen eskua egiten zaizu.',
  'Canales. Aquí los Fragmentos vienen de dos en dos. Fúndelos.':
      'Kanalak. Hemen Zatiak binaka datoz. Urtu itzazu.',
  'Mercado de la Luz. Aquí todo se intercambia. Presta atención.':
      'Argiaren Merkatua. Hemen dena trukatzen da. Adi egon.',
  'Industria. Aquí no valen los aproximados. Cifra por cifra.':
      'Industria. Hemen gutxi gorabeherak ez du balio. Zifraz zifra.',
  'Puerto. Aquí los Fragmentos son grandes. No tengas prisa.':
      'Portua. Hemen Zatiak handiak dira. Ez izan presarik.',
  'Afueras. Aquí se ve el horizonte. Y la Montaña.':
      'Kanpoaldea. Hemen zerumuga ikusten da. Eta Mendia.',
  // Lectura de fracciones (FR.02 — texto que el niño asocia a la fracción)
  'un medio': 'erdi bat',
  'un tercio': 'heren bat',
  'dos tercios': 'bi heren',
  'un cuarto': 'laurden bat',
  'tres cuartos': 'hiru laurden',
  'dos quintos': 'bi bosten',
  'tres quintos': 'hiru bosten',
  'un sexto': 'seiren bat',
  'cinco sextos': 'bost seiren',
  'dos séptimos': 'bi zazpiren',
  'tres octavos': 'hiru zortziren',
  'cinco octavos': 'bost zortziren',
  'cuatro novenos': 'lau bederatziren',
  'siete décimos': 'zazpi hamarren',
  'tres décimos': 'hiru hamarren',
  // Lectura de decimales (DEC.01)
  'tres décimas': 'hiru hamarren',
  'siete décimas': 'zazpi hamarren',
  'veinticinco centésimas': 'hogeita bost ehunen',
  'cuarenta centésimas': 'berrogei ehunen',
  'siete centésimas': 'zazpi ehunen',
  'cinco milésimas': 'bost milaren',
  'doscientas treinta milésimas': 'berrehun eta hogeita hamar milaren',
  'una unidad y dos décimas': 'unitate bat eta bi hamarren',
  'dos unidades y cinco centésimas': 'bi unitate eta bost ehunen',
  'tres unidades y siete décimas': 'hiru unitate eta zazpi hamarren',
  // Etiquetas del gráfico de barras (EST.01)
  'lun': 'al',
  'mar': 'ar',
  'mié': 'az',
  'jue': 'og',
  'ene': 'urt',
  'feb': 'ots',
  'rojo': 'gorri',
  'azul': 'urdin',
  'verde': 'berde',
  'amar': 'horia',
  // Etiquetas de razón (PROP.01)
  'manzanas': 'sagarrak',
  'naranjas': 'laranjak',
  'rojas': 'gorriak',
  'azules': 'urdinak',
  'pequeñas': 'txikiak',
  'grandes': 'handiak',
  'sí': 'bai',
  'no': 'ez',
  'rosas': 'arrosak',
  'tulipanes': 'tulipak',
  'gatos': 'katuak',
  'perros': 'txakurrak',
  'verdes': 'berdeak',
  'amarillas': 'horiak',
  'lápices': 'arkatzak',
  'bolígrafos': 'boligrafoak',
  'altas': 'altuak',
  'bajas': 'baxuak',
  'libros': 'liburuak',
  'cuadernos': 'koadernoak',
  'monedas': 'txanponak',
  'billetes': 'billeteak',
  'mías': 'nireak',
  'tuyas': 'zureak',
  // Frases del combate Kurz/Zafrán/Vorax (pantalla_combate_kurz). Las
  // claves duplicadas con otros tramos del juego (Mm., Bien., Vamos.,
  // etc.) ya están traducidas más arriba en este mismo mapa.
  'Lento.': 'Geldo.',
  'Otra.': 'Beste bat.',
  'Más rápido.': 'Bizkorrago.',
  'Sigue. No pares.': 'Jarraitu. Ez gelditu.',
  'No lo veas — calcúlalo.': 'Ez ikusi — kalkulatu.',
  'Silencio. Otra vez.': 'Isiltasuna. Berriro.',
  'No está mal. Pero sigue mal.': 'Ez dago gaizki. Baina oraindik gaizki.',
  'Te noto distinto. No basta.': 'Ezberdina sumatzen zaitut. Ez da nahikoa.',
  '¿Eso es todo?': 'Hori al da dena?',
  'Vale. Ya está.': 'Ondo. Hor da.',
  'Casi. Otra vez la semana que viene.': 'Ia. Hurrengo astean berriro.',
  'Vaya. Otra vez la semana que viene.': 'Tira. Hurrengo astean berriro.',
  'Vaya. Tú ya eres otra cosa.': 'Tira. Zu beste zerbait zara dagoeneko.',
  'Buen intento. Otro día te doy la revancha.': 'Saiakera ona. Beste egun batean errebantxa emango dizut.',
  'Déjame a mí. Cuando puedas, seguimos.': 'Utzi niri. Ahal duzunean, jarraitzen dugu.',
  'Suma los numeradores. ¡Ahora!': 'Batu zenbakitzaileak. Orain!',
  'Amplifica. Busca un múltiplo de los dos.': 'Handitu. Bilatu bien multiploa.',
  'Once por siete. Tres por siete.': 'Hamaika bider zazpi. Hiru bider zazpi.',
  'Siete por once son 77. Cinco por once.': 'Zazpi bider hamaika 77 da. Bost bider hamaika.',
  'Vorax tiembla. Descomponer es también parar.': 'Vorax dardara egiten du. Deskonposatzea ere geldiaraztea da.',
  'Vorax intenta recuperar la forma impropia.': 'Voraxek forma irregularra berreskuratu nahi du.',
  'Vorax recupera la forma impropia. Respira.': 'Voraxek forma irregularra berreskuratzen du. Arnasa hartu.',
  'Vorax se encoge un grado más.': 'Vorax beste maila bat uzkurtzen da.',
  'Vorax se retira hacia arriba. Silencio.': 'Vorax gora erretiratzen da. Isiltasuna.',
  'Vorax se retira. Tendrás que volver.': 'Vorax erretiratzen da. Itzuli beharko duzu.',
  // Nombres y descripciones cortas de los distritos del mapa
  'Tejados del Centro': 'Erdiko Teilatuak',
  'Donde Sora te enseñó a cortar.': 'Sorak ebakitzen erakutsi zizun lekua.',
  'Barrio de los Canales': 'Kanalen Auzoa',
  'Donde los Fragmentos se juntan.': 'Zatiak elkartzen diren lekua.',
  'Mercado de la Luz': 'Argiaren Merkatua',
  'Porcentajes y proporciones, intercambios.':
      'Ehunekoak eta proportzioak, trukeak.',
  'Zona Industrial': 'Industria Eremua',
  'Medidas exactas, decimales.': 'Neurri zehatzak, hamartarrak.',
  'Puerto Silencioso': 'Portu Isila',
  'Aguas profundas. Pesos pesados.': 'Ur sakonak. Pisu astunak.',
  'Afueras': 'Kanpoaldea',
  'Donde los datos cuentan historias.':
      'Datuek istorioak kontatzen dituzten lekua.',
  'Esto aún no lo has visto.': 'Hau oraindik ez duzu ikusi.',
  'Lo has tocado. Vuelve cuando puedas.':
      'Ukitu duzu. Itzuli ahal duzunean.',
  'Estás aprendiéndolo. Tranquila, sin prisa.':
      'Ikasten ari zara. Lasai, presarik gabe.',
  'Esto ya te sale.': 'Hau dagoeneko ateratzen zaizu.',
  'Esto lo dominas.': 'Hau menderatzen duzu.',
  'Aún no': 'Oraindik ez',
  'Visto': 'Ikusia',
  'En práctica': 'Lantzen',
  'Firme': 'Sendoa',
  'Dominada': 'Menderatua',
  'ACERCA DE': 'JOKOARI BURUZ',
  'Las matemáticas son el mundo, no un peaje.':
      'Matematika mundua da, ez bidesari bat.',
  'EL JUEGO': 'JOKOA',
  'LAS MATEMÁTICAS': 'MATEMATIKA',
  'LA CIUDAD': 'HIRIA',
  'LA HISTORIA': 'ISTORIOA',
  'LOS PERSONAJES': 'PERTSONAIAK',
  'IDIOMAS': 'HIZKUNTZAK',
  'LICENCIA': 'LIZENTZIA',
  'TUTOR IA': 'TUTORE IA',

  'El tejado': 'Teilatua',
  'La primera ventana': 'Lehenengo leihoa',
  'El callejón': 'Kalezuloa',
  'Irune': 'Irune',
  'Kurz aparece': 'Kurz agertzen da',
  'La derrota': 'Porrota',
  'Kai visto de lejos': 'Kai urrunetik ikusia',
  'Los Plenos': 'Osoak',
  'Hoy': 'Gaur',
  'Kurz vuelve': 'Kurz itzultzen da',
  'Kurz vuelve — cierre derrota': 'Kurz itzultzen da — porrotaren itxiera',
  'Kurz vuelve — cierre victoria': 'Kurz itzultzen da — garaipenaren itxiera',
  'La cena que no se ve': 'Ikusten ez den afaria',
  'Hoy aún no': 'Gaur oraindik ez',
  'Kurz vencido': 'Kurz garaitua',
  'Las palabras de Irune': 'Iruneren hitzak',
  'Los Canales desde arriba': 'Kanalak goitik',
  'Bajar solo': 'Bakarrik jaitsi',
  'Rexán': 'Rexán',
  'El primer Fragmento Espejo': 'Lehenengo Ispilu Zatia',
  'Rexán y el agua': 'Rexán eta ura',
  'Ari': 'Ari',
  'Ari en el muelle': 'Ari kaira',
  'El silbido lejano': 'Txistu urruna',
  'Sora vuelve a bajar': 'Sora berriro jaisten da',
  'La noche de Zafrán': 'Zafránen gaua',
  'Zafrán escapa': 'Zafrán ihes egiten du',
  'Rexán espera': 'Rexán zain',
  'Rexán y el té': 'Rexán eta tea',
  'El santuario': 'Santutegia',
  'La Montaña se nombra': 'Mendia izendatzen da',
  'Kai otra vez': 'Kai berriro',
  'El interrogatorio de Naini': 'Nainiren galdeketa',
  'Vadic': 'Vadic',
  'Máquinas — conversiones': 'Makinak — bihurketa',
  'Máquinas — el metro cuadrado': 'Makinak — metro karratua',
  'Máquinas — la máquina miente': 'Makinak — makinak gezurra esaten du',
  'Kai desaparece': 'Kai desagertzen da',
  'Cuéntame.': 'Kontaidazu.',
  'Eco': 'Eco',
  'Eco otra vez, casi': 'Eco berriro, ia',
  'La bolsa': 'Poltsa',
  'Una tercera pintada': 'Hirugarren margotze bat',
  'Irune: la invitación': 'Irune: gonbidapena',
  'Las tres pruebas': 'Hiru probak',
  'La ceremonia': 'Ekitaldia',
  'Kai, lejos': 'Kai, urruti',
  'Sora en el borde': 'Sora ertzean',
  'La Montaña': 'Mendia',
  'Sendero.': 'Bidezidortxoa.',
  'Fuego.': 'Sua.',
  'Espejo.': 'Ispilua.',
  'Prueba de Fuego': 'Suaren proba',
  'Prueba de Sendero': 'Bidezidorraren proba',
  'Prueba de Espejo': 'Ispiluaren proba',
  'Sora antes — Fuego': 'Sora aurretik — Sua',
  'Sora antes — Sendero': 'Sora aurretik — Bidezidorra',
  'Sora antes — Espejo': 'Sora aurretik — Ispilua',
  'Kai vuelve': 'Kai itzultzen da',
  'La misión conjunta': 'Elkarlaneko misioa',
  'Naini': 'Naini',
  'Oryn': 'Oryn',
  'Brina': 'Brina',
  'Juntos.': 'Elkarrekin.',
  'Tres.': 'Hiru.',
  'Cinco.': 'Bost.',
  'Diez.': 'Hamar.',
  '8.': '8.',
  '10.': '10.',
  '12.': '12.',
  '25%.': '%25.',
  '50%.': '%50.',
  '40%.': '%40.',
  '3/4.': '3/4.',
  '1/2.': '1/2.',
  '3/8.': '3/8.',
  '234.': '234.',
  '23,4.': '23,4.',
  '2340.': '2340.',
  'Yo.': 'Ni.',
  'Tú.': 'Zu.',
  'No sé.': 'Ez dakit.',
  'No lo sé.': 'Ez dakit.',
  'No lo sé todavía.': 'Oraindik ez dakit.',
  'No sé muy bien qué hacer.': 'Ez dakit oso ondo zer egin.',
  'No te me pongas raro, Kai.': 'Ez zaitez jarri bitxi, Kai.',
  'Vengo a entrenar.': 'Entrenatzera nator.',
  'Vivo. Como ves. Tú también, ¿no?': 'Bizirik. Ikusten duzunez. Zu ere bai, ezta?',
  'Yo soy {nombre}.': 'Ni {nombre} naiz.',
  'Los números suben.': 'Zenbakiak gora doaz.',
  'Iniciado.': 'Hasiberria.',
  'El primero.': 'Lehenengoa.',
  'El segundo.': 'Bigarrena.',
  'A Sora.': 'Sorari.',
  'A Oryn.': 'Oryni.',
  'A Naini.': 'Nainiri.',
  'Los números de abajo no son iguales. ¿Los trozos son iguales?': 'Beheko zenbakiak ez dira berdinak. Zatiak berdinak al dira?',
  'Son iguales.': 'Berdinak dira.',
  'Son 28. Ya está.': '28 dira. Hori da.',
  'Si 10% de 80 son 8, ¿cuánto sería 30%?': '80ren %10 8 badira, zenbat litzateke %30?',
  'La respuesta es 13/15. Te la apuntas y vamos a otra.': 'Erantzuna 13/15 da. Apuntatu eta bestera goaz.',
  '¿Cuánto tiempo llevas aquí?': 'Zenbat denbora daramazu hemen?',
  '¿Qué hago aquí?': 'Zer egiten dut hemen?',
  '¿Qué son?': 'Zer dira?',
  '¿Cuántos Fragmentos hay?': 'Zenbat Zati daude?',
  '¿Por qué?': 'Zergatik?',
  '¿Por qué dice eso?': 'Zergatik esaten du hori?',
  '¿Ella sabe?': 'Badaki berak?',
  '¿Qué le pasó?': 'Zer gertatu zitzaion?',
  '¿Se va a poner bien?': 'Ondo jarriko al da?',
  '¿Repararse qué?': 'Konpondu zer?',
  '¿Y si es peligroso?': 'Eta arriskutsua bada?',
  '¿Y si no puedo?': 'Eta ezin badut?',
  '¿Qué tres formas?': 'Zein hiru modu?',
  '¿Voy a estar bien?': 'Ondo egongo al naiz?',
  '¿Qué te pasó?': 'Zer gertatu zitzaizun?',
  '¿Por qué es silencioso el Puerto?': 'Zergatik da isila Portua?',
  '¿No se lo has dicho a Oryn?': 'Ez al diozu esan Oryni?',
  '¿Conociste a Rexán?': 'Rexán ezagutu al zenuen?',
  '¿Sora conoce a Oryn?': 'Sorak ezagutzen al du Oryn?',
  '¿Quién vive?': 'Nor bizi da?',
  '¿Qué es esto?': 'Zer da hau?',
  '¿Por qué me lo cuentas a mí?': 'Zergatik kontatzen didazu niri?',
  '¿Fue Zafrán?': 'Zafrán izan al zen?',
  '¿Es más o menos que medio, un tercio más un quinto?': 'Hein bat baino gehiago ala gutxiago da, heren bat gehi bosten bat?',
  '¿Y cuando no están las dos?': 'Eta biak ez daudenean?',
  'El Mercado de la Luz': 'Argiaren Merkatua',
  'El Puerto otra vez': 'Portua berriro',
  'El agua recuerda': 'Urak gogoratzen du',
  'Una pintada rara': 'Margotze arraro bat',
  'Una segunda pintada': 'Bigarren margotze bat',
  'Los Canales en silencio': 'Kanalak isilean',
  'Kurz vuelve — derrota': 'Kurz itzultzen da — porrota',
  'Kurz vuelve — victoria': 'Kurz itzultzen da — garaipena',
  'Después': 'Gero',
  'La primera vez que Zafrán se menciona': 'Zafrán lehenengoz aipatzen denean',
  'Un Dual en el puente': 'Bikoitz bat zubian',
  'Irune al fondo': 'Irune atzean',
  'Kai enhorabuena': 'Zorionak Kai',
  'El faro': 'Itsasargia',
  'Sora antes': 'Sora aurretik',
  'Rexán té': 'Rexán tea',
  'Sora Kir': 'Sora Kir',
  '— asentir en silencio —': '— isilean baiezkoa eman —',
  '— escuchar sin preguntar —': '— galdetu gabe entzun —',
  '— quedarte callado —': '— isilik egon —',
  '— quedarte con ella en silencio —': '— berarekin isilean egon —',
  '— quedarte en silencio largo rato —': '— isilean egon denbora luzez —',
  '— quedarte mirando —': '— begira egon —',
  '— solo asentir —': '— baiezkoa eman soilik —',

  'Entrenar — noche despejada': 'Entrenatu — gau garbia',
  'Entrenar — niebla': 'Entrenatu — lainoa',
  'Entrenar — lluvia ligera': 'Entrenatu — euri arina',
  'Entrenar — con la Montaña visible': 'Entrenatu — Mendia ikusgai',
  'Entrenar — buen entrenamiento': 'Entrenatu — entrenamendu ona',
  'Entrenar — la pila del Faro': 'Entrenatu — Faroko pila',
  '«Si te cae lluvia ligera, te acuerdas de mí.»': '«Euri arina botatzen badizu, nitaz gogoratzen zara.»',
  'Cuando un Fragmento se simplifica, es como reconocer tu cara en un reflejo mal iluminado.': 'Zati bat sinplifikatzen denean, zure aurpegia argi txarreko ispilu batean ezagutzea bezala da.',
  'Parece otra cosa. No lo es.': 'Beste zerbait dirudi. Ez da.',
  'Venga. Otra ronda.': 'Tira. Beste txanda bat.',
  'Mira el agua un momento.': 'Begiratu ura une batez.',
  'Algunos días la veo grande.': 'Egun batzuetan handia ikusten dut.',
  'Otros días no la veo.': 'Beste egun batzuetan ez dut ikusten.',
  'Mira la Montaña sin decir nada un rato largo.': 'Begiratu Mendia ezer esan gabe denbora luzez.',
  '¿Qué hay allí?': 'Zer dago han?',
  'Ahora. Otra vez.': 'Orain. Berriro.',
  'Ahora explícame por qué.': 'Orain azaldu iezadazu zergatik.',
  'Es de día. Hay que salir.': 'Eguna da. Irten behar da.',
  'Así es Irune.': 'Hala da Irune.',
  'Sí. Dijo que hoy no.': 'Bai. Gaur ez zuela esan du.',
  'Bajan por la escalera. Junto a la puerta del Edificio hay una pila baja de papeles ordenados.': 'Eskaileratik jaisten dira. Eraikinaren ate ondoan antolatutako paper pila baxu bat dago.',
  'Eso es el Faro.': 'Hori Faroa da.',
  'Sale los viernes. Lo deja la redacción.': 'Ostiraletan ateratzen da. Erredakzioak uzten du.',
  'Coge uno si te apetece. No es obligatorio.': 'Hartu bat gogoz baduzu. Ez da derrigorrezkoa.',
  'Maren no escribe mal.': 'Maren ez du gaizki idazten.',
  'Maren no escribe mal — eso ya lo dijo Sora una vez. Cierras el periódico.': 'Maren ez du gaizki idazten — hori esan zuen Sorak behin. Egunkaria ixten duzu.',
  'Sora se queda un momento mirando la pila.': 'Sora une batez gelditzen da pila begira.',
  'Era 2 — El Faro te menciona': 'Aro 2 — Faroak aipatzen zaitu',
  'Era 2 — El Fragmento que se queda': 'Aro 2 — Geratzen den Zatia',
  'Era 2 — El primer despertar': 'Aro 2 — Lehenengo esnatzea',
  'Era 2 — Irune mira la Montaña': 'Aro 2 — Irunek Mendia begiratzen du',
  'Era 2 — Kai pasa': 'Aro 2 — Kai pasatzen da',
  'Era 2 — Una nota': 'Aro 2 — Ohar bat',
  'Niebla baja en el patio. Un Fragmento pequeño, casi del tamaño de una manzana, flota a media altura.': 'Laino baxua patioko. Zati txiki bat, sagar baten tamainakoa ia, erdi altueran flotatzen.',
  'No huye. No se acerca. Pulsa despacio, como si respirara.': 'Ez du ihes egiten. Ez da hurbiltzen. Poliki dabil, arnasa hartuko balu bezala.',
  'Lo que tiene el desajuste. No parece mucho.': 'Desdoitzeak duena. Ez dirudi asko.',
  'No lo tocas. Pasas de largo. El Fragmento sigue donde estaba.': 'Ez duzu ukitzen. Aurrera zoaz. Zatia han jarraitzen du.',
  'Sala de mezclas. Una máquina marca 0,25 l. Vadic acerca un medidor externo y lee 0,3 l.': 'Nahaste-gela. Makina batek 0,25 L markatzen du. Vadicek kanpoko neurgailu bat hurbiltzen du eta 0,3 L irakurtzen du.',
  '0,3. Correcto. La máquina miente por 0,05.': '0,3. Zuzena. Makinak 0,05ean gezurra esaten du.',
  'No. Un metro es cien centímetros. Pero estamos midiendo área. Piénsalo otra vez.': 'Ez. Metro bat ehun zentimetro da. Baina azalera neurtzen ari gara. Pentsatu berriro.',
  'Vadic escucha. Asiente.': 'Vadicek entzuten du. Baiezkoa ematen du.',
  'Mesa de Vadic. Una libreta con cifras: 3 kg, 0,4 l, 250 g, 1,2 kg, 750 ml.': 'Vadicek mahaia. Koaderno bat zifrekin: 3 kg, 0,4 L, 250 g, 1,2 kg, 750 mL.',
  'Multiplícalo por mil mezclas al día.': 'Biderkatu mila nahastez eguneko.',
  'Asiente una vez sin girarse. Sigue mirando.': 'Behin baiezkoa eman gabe jiratu. Begira jarraitzen du.',
  '«Sé otras cosas. Vas aprendiendo las tuyas.»': '«Beste gauza batzuk dakit. Zureak ikasten ari zara.»',
  '«No te creas que sé más que tú.»': '«Ez uste ni zuk baino gehiago dakitenik.»',
  'Calle estrecha entre los Tejados y los Canales. Alguien viene de frente, deprisa.': 'Kale estua Teilatuen eta Kanalen artean. Norbait aurretic dator, bizkor.',
  'Kai sigue de largo. Dos rangos por delante. No espera respuesta.': 'Kai aurrera jarraitzen du. Bi maila aurretik. Ez du erantzunik itxaroten.',
  'Eh.': 'Eh.',
  '¿Tú de dónde eres?': 'Zu nondik zara?',
  '¿Por qué entrenas tanto?': 'Zergatik entrenatzen duzu hainbeste?',
  'Te queda bien la marca.': 'Ondo geratzen zaizu marka.',
  'Nos vemos.': 'Gero arte.',
  'Sora no está. La taza que dejó anoche sigue donde la dejó. Vacía.': 'Sora ez dago. Bart utzitako katilua utzitako lekuan dago. Hutsik.',
  '«¿Cuánto?» «Hoy no.» «Vale.»': '«Zenbat?» «Gaur ez.» «Ondo.»',
  'La luz entra por la ventana y se apoya en la marca de Iniciado, sobre la mesa.': 'Argia leihotik sartzen da eta Hasiberriaren markaren gainean jartzen da, mahai gainean.',
  '10.000.': '10.000.',
  '100.': '100.',
  'Plano sobre la mesa. Vadic señala un cuadrado de 1 m² y pregunta cuántos cm² entran dentro.': 'Planoa mahai gainean. Vadicek 1 m²-ko karratu bat seinalatzen du eta zenbat cm² sartzen diren galdetzen du.',
  'Pasillo del Edificio. La Maestra Irune está parada delante de una ventana del archivo.': 'Eraikineko korridorea. Irune Maisua artxiboko leiho baten aurrean geldirik dago.',
  'Cuando te giras desde el final del patio, ya no está.': 'Patioko muturretik biratzen zarenean, jada ez dago.',
  'En el cajón superior, debajo de un trapo doblado, hay una nota. La letra es pequeña.': 'Goiko tiraderan, trapu tolestu baten azpian, ohar bat dago. Letra txikia da.',
  'No da el nombre completo. Solo las iniciales.': 'Ez du izen osoa ematen. Inizialak bakarrik.',
  'No hay firma. El niño dobla la nota despacio.': 'Sinadurarik ez. Haurrak oharra poliki tolesten du.',
  'Pero las iniciales son las tuyas, {nombre}.': 'Baina inizialak zureak dira, {nombre}.',
  'En el Faro de esta semana, una columna corta menciona a un Iniciado de los Tejados que ha cerrado dominios.': 'Aste honetako Faroan, zutabe labur batek Teilatuetako Hasiberri bat aipatzen du, domeinuak itxi dituena.',
  'Brina escribió en el Faro que los hay así. Pequeños, tranquilos.': 'Brinak Faroan idatzi zuen horrelakoak daudela. Txikiak, lasaiak.',
  'Las dos cosas son verdad.': 'Bi gauzak egia dira.',
  'Puentes — puente pequeño': 'Zubiak — zubi txikia',
  'Puentes — mercadillo nocturno': 'Zubiak — gaueko merkatua',
  'Puentes — vista a la Montaña': 'Zubiak — Mendiaren ikuspegia',
  'Puentes — el pan partido': 'Zubiak — ogia zatitua',
  'Puente pequeño de piedra. El agua baja muy despacio. Faroles lejanos.': 'Harrizko zubi txikia. Ura oso poliki jaisten da. Farol urrunak.',
  'Puente largo con mercadillo nocturno. Voces bajas, un olor a pan viejo.': 'Zubi luzea gaueko merkatuarekin. Ahots baxuak, ogi zahar usaina.',
  'Lleva vendiendo aquí desde que yo era joven.': 'Hemen saltzen ibili da ni gaztea nintzenetik.',
  'Nunca ha cambiado los precios.': 'Ez ditu preziorik aldatu inoiz.',
  'Compra dos bebidas. Paga con monedas antiguas que el vendedor acepta sin comentar.': 'Bi edari erosten ditu. Saltzaileak iruzkinik gabe onartzen dituen txanpon zaharrekin ordaintzen du.',
  'Puente alto. La Montaña al fondo, recortada sobre un cielo limpio.': 'Zubi altua. Mendia atzean, zeru garbi baten kontra moztuta.',
  'Rexán se agacha despacio. Saca un pedacito de pan y lo parte en dos.': 'Rexán poliki makurtzen da. Ogi puska bat atera eta bitan zatitzen du.',
  'Parte una de las mitades otra vez.': 'Zatitu erdietako bat berriro.',
  'Un cuarto.': 'Laurden bat.',
  'Si junto dos cuartos, tengo un medio.': 'Bi laurden biltzen baditut, erdi bat dut.',
  'El camino es al revés, pero el pan sigue siendo el mismo pan.': 'Bidea alderantziz da, baina ogia ogi bera da oraindik.',
  'Sí.': 'Bai.',

  // ═══ Combates: Kurz 1/2/3, Zafrán, Kai, Vorax ═══
  // Enunciados, opciones con texto, frases de fallo/acierto/derrota/
  // victoria. Traducciones provisionales pendientes de revisión nativa
  // — ver nota en CLAUDE.md sobre voz de cada personaje.

  // Kurz 1
  '¿Cuántos cuartos hay en un entero?': 'Zenbat laurden daude osoko batean?',
  'Si tengo 3/4 y quito 1/4, ¿cuánto queda?':
      '3/4 baditut eta 1/4 kentzen badut, zenbat geratzen da?',
  '¿Qué es más: 1/2 o 1/4?': 'Zer da gehiago: 1/2 ala 1/4?',
  'Iguales': 'Berdinak',

  // Kurz 2
  '¿Cuánto es 5/6 - 1/6?': 'Zenbat da 5/6 - 1/6?',
  '¿Cuánto es 4/6 - 1/6?': 'Zenbat da 4/6 - 1/6?',
  'Simplifica 3/6.': 'Sinplifikatu 3/6.',
  '¿Cuánto es 2/6 + 1/6?': 'Zenbat da 2/6 + 1/6?',
  'Simplifica 2/6.': 'Sinplifikatu 2/6.',

  // Kurz 3
  '¿Cuánto es 7/8 - 2/8?': 'Zenbat da 7/8 - 2/8?',
  'Simplifica 4/8.': 'Sinplifikatu 4/8.',
  '¿Cuánto es 5/8 - 2/8?': 'Zenbat da 5/8 - 2/8?',
  'Simplifica 6/8.': 'Sinplifikatu 6/8.',

  // Zafrán (MCM 7 y 11 = 77)
  '¿Cuál es el MCM de 7 y 11?': 'Zein da 7 eta 11ren MKT?',
  '¿A qué equivale 5/7 con denominador 77?':
      'Zeri dagokio 5/7 77 izendatzailearekin?',
  '¿A qué equivale 3/11 con denominador 77?':
      'Zeri dagokio 3/11 77 izendatzailearekin?',
  '¿Cuánto es 55/77 + 21/77?': 'Zenbat da 55/77 + 21/77?',
  '¿Cuánto le falta a 76/77 para ser un entero?':
      'Zenbat falta zaio 76/77ri oso bat izateko?',

  // Kai (duelo amistoso)
  'Ronda de reacción. ¿Cuánto es 3/5 de 20?':
      'Erreakzio-txanda. Zenbat da 20ren 3/5?',
  'Ronda de precisión. ¿A qué porcentaje equivale 3/4?':
      'Zehaztasun-txanda. Zein ehunekoari dagokio 3/4?',
  'Ronda Dual. 1/2 + 1/3 = ?': 'Txanda Duala. 1/2 + 1/3 = ?',

  // Vorax (Impropio 11/4 → mixto → cuartos)
  '11/4 es Impropio. Conviértelo a número mixto.':
      '11/4 Bidegabea da. Bihurtu zenbaki misto.',
  '1 y 7/4': '1 eta 7/4',
  '2 y 3/4': '2 eta 3/4',
  '3 y 2/4': '3 eta 2/4',
  '4 y 1/4': '4 eta 1/4',
  'Eliminas el 2 entero. ¿Qué parte queda como Fragmento?':
      '2 osoa kentzen duzu. Zer zati geratzen da Zati gisa?',
  '3/4 en cuartos: ¿cuántos cuartos son?':
      '3/4 laurdenetan: zenbat laurden dira?',
  'Tras eliminar un cuarto, ¿cuánto queda?':
      'Laurden bat kendu ondoren, zenbat geratzen da?',
  'Tras eliminar otro cuarto, ¿cuánto queda?':
      'Beste laurden bat kendu ondoren, zenbat geratzen da?',
  'Vorax se agita. No vayas rápido.':
      'Vorax astindu egiten da. Ez joan azkar.',

  // ═══ AyudaPuzzle: títulos y etiquetas de UI ═══
  // Cuerpos largos de la ayuda pedagógica todavía sin traducir — el
  // mapa devuelve el original si la clave no aparece, así que la app
  // sigue funcionando con título en euskera + cuerpo en castellano
  // hasta que haya revisión completa.
  'AMPLIFICAR FRACCIONES': 'ZATIKIAK ANPLIFIKATU',
  'ÁREA DEL RECTÁNGULO': 'LAUKIZUZENAREN AZALERA',
  'ÁREA DEL TRIÁNGULO': 'TRIANGELUAREN AZALERA',
  'AUMENTOS Y DESCUENTOS': 'GEHITUTAKOAK ETA DESKONTUAK',
  'CLASIFICAR ÁNGULOS': 'ANGELUAK SAILKATU',
  'COMPARAR CON LA UNIDAD': 'UNITATEAREKIN KONPARATU',
  'COMPARAR CON 1/2': '1/2RAKIN KONPARATU',
  'COMPARAR DECIMALES': 'HAMARTARRAK KONPARATU',
  'COMPARAR FRACCIONES': 'ZATIKIAK KONPARATU',
  'COMPARAR FRACCIONES DISTINTAS': 'ZATIKI DESBERDINAK KONPARATU',
  'CONVERTIR LONGITUD': 'LUZERA BIHURTU',
  'CONVERTIR MASA O CAPACIDAD': 'MASA EDO EDUKIERA BIHURTU',
  'CONVERTIR SUPERFICIE': 'AZALERA BIHURTU',
  'CONVERTIR TIEMPO': 'DENBORA BIHURTU',
  'CORTAR EN PARTES IGUALES': 'ZATI BERDINETAN MOZTU',
  'DIVISIBILIDAD': 'ZATIGARRITASUNA',
  'DIVISORES': 'ZATITZAILEAK',
  'ECUACIÓN EN AMBOS LADOS': 'BI ALDEETAKO EKUAZIOA',
  'ECUACIÓN LINEAL': 'EKUAZIO LINEALA',
  'ENTEROS CON SIGNO': 'ZEINUDUN OSOAK',
  'ESCALA': 'ESKALA',
  'FRACCIÓN DE UNA CANTIDAD': 'KOPURU BATEN ZATIKIA',
  'FRACCIONES EQUIVALENTES': 'ZATIKI BALIOKIDEAK',
  'GRÁFICO CIRCULAR': 'GRAFIKO ZIRKULARRA',
  'GRÁFICO DE BARRAS': 'BARRA-GRAFIKOA',
  'JERARQUÍA CON FRACCIONES': 'HIERARKIA ZATIKIEKIN',
  'JERARQUÍA DE OPERACIONES': 'ERAGIKETEN HIERARKIA',
  'LEER DECIMALES': 'HAMARTARRAK IRAKURRI',
  'LEER FRACCIONES': 'ZATIKIAK IRAKURRI',
  'MCM Y MCD': 'MKT ETA ZKH',
  'MEDIA ARITMÉTICA': 'BATEZBESTEKO ARITMETIKOA',
  'MODA Y MEDIANA': 'MODA ETA MEDIANA',
  'MÚLTIPLOS': 'MULTIPLOAK',
  'NOMBRAR POLÍGONOS': 'POLIGONOAK IZENDATU',
  'NÚMEROS PRIMOS': 'ZENBAKI LEHENAK',
  'OPERAR CON DECIMALES': 'HAMARTARREKIN ERAGITEKO',
  'OPERAR CON FRACCIONES': 'ZATIKIEKIN ERAGITEKO',
  'ORDENAR DECIMALES': 'HAMARTARRAK ORDENATU',
  'ORDENAR FRACCIONES': 'ZATIKIAK ORDENATU',
  'PERÍMETRO': 'PERIMETROA',
  'PORCENTAJE DE UNA CANTIDAD': 'KOPURU BATEN EHUNEKOA',
  'POTENCIAS': 'BERREDURAK',
  'PROBABILIDAD': 'PROBABILITATEA',
  'PROPORCIONES': 'PROPORTZIOAK',
  'RAÍZ CUADRADA': 'ERRO KARRATUA',
  'RAZÓN': 'ARRAZOIA',
  'REDONDEAR DECIMALES': 'HAMARTARRAK BIRIBILDU',
  'REGLAS DE TRES': 'HIRUREN ARAUA',
  'RELACIÓN LINEAL': 'ERLAZIO LINEALA',
  'SIMETRÍA AXIAL': 'SIMETRIA AXIALA',
  'SIMPLIFICAR FRACCIONES': 'ZATIKIAK SINPLIFIKATU',
  'SISTEMA DE ECUACIONES': 'EKUAZIO-SISTEMA',
  'SUMA BÁSICA': 'BATUKETA OINARRIZKOA',
  'TEOREMA DE PITÁGORAS': 'PITAGORASEN TEOREMA',
  'VALOR ABSOLUTO': 'BALIO ABSOLUTUA',
  'VOLUMEN DEL ORTOEDRO': 'ORTOEDROAREN BOLUMENA',

  // Etiquetas de UI de los dialogs de ayuda
  '¿Necesitas ayuda?': 'Laguntza behar duzu?',
  'SEGUIR': 'JARRAITU',
  'VOLVER': 'ITZULI',
  'EMPEZAR': 'HASI',
  'ENTENDIDO': 'ULERTUTA',
  'CERRAR': 'ITXI',
  'cerrar': 'itxi',
  // SnackBar tras captura con fallos: "+5 (de 10 posibles)"
  'posibles': 'posiblean',

  // ═══ AyudaPuzzle: cuerpos largos (texto + transferencia) ═══
  // Traducción euskera provisional pendiente de revisión nativa.
  // Si una clave no aparece o se ha modificado, el sistema cae al
  // castellano sin romper. 64 familias × 2 entradas = 128 strings.
  'Tienes que dividir el Fragmento en el número de partes que indica.\n\n1. Desliza el dedo para cortar.\n2. Cada corte debe hacer partes del mismo tamaño.\n3. Cuando tengas el número exacto de partes, el Fragmento se deshace.\n\nCuanto más preciso seas, mejor.':
      'Zatia adierazitako zati kopuruan banatu behar duzu.\n\n1. Lerratu hatza moztu ahal izateko.\n2. Moztu bakoitzak tamaina bereko zatiak egin behar ditu.\n3. Zati kopuru zehatza lortzen duzunean, Zatia desegingo da.\n\nZehatzago izan, hobeto.',
  'En la vida: repartir una pizza, una tarta o cualquier cosa en partes iguales.':
      'Bizitzan: pizza, tarta edo edozer zati berdinetan banatu.',
  'Tienes dos fracciones y tienes que tocar la mayor.\n\n• Si tienen el MISMO denominador (número de abajo), gana la que tiene el numerador (número de arriba) más grande.\n• Si tienen el MISMO numerador, gana la que tiene el denominador más pequeño (porque los trozos son más grandes).':
      'Bi zatiki dituzu eta handiena ukitu behar duzu.\n\n• IZENDATZAILE BERA badute (azpiko zenbakia), zenbakitzaile (gaineko zenbakia) handiena duenak irabazten du.\n• ZENBAKITZAILE BERA badute, izendatzaile txikiena duenak irabazten du (zatiak handiagoak baitira).',
  'En la vida: saber qué oferta es mejor (3/8 de descuento vs 5/12).':
      'Bizitzan: zein eskaintza den hobea jakitea (3/8 beherapena vs 5/12).',
  'Dos fracciones sin nada en común. No puedes comparar solo mirando.\n\nMultiplica en cruz:\n  a/b  ?  c/d  →  a×d  ?  c×b\nEl lado donde el producto sea mayor, esa fracción es la mayor.\n\nTambién puedes convertir a decimal dividiendo numerador entre denominador.':
      'Ezer komunean ez duten bi zatiki. Begira soilik ezin duzu konparatu.\n\nGurutzatuta biderkatu:\n  a/b  ?  c/d  →  a×d  ?  c×b\nBiderkadura handiena duen aldea, zatiki hori da handiena.\n\nZatiki batetik hamartar batera ere bihur dezakezu, zenbakitzailea izendatzailearen artean zatituz.',
  'En la vida: comparar ofertas con formatos distintos, o repartos diferentes.':
      'Bizitzan: formatu desberdineko eskaintzak edo banaketa desberdinak konparatu.',
  'Tienes dos decimales y tienes que tocar el mayor.\n\nCuidado: más cifras NO significa más grande.\n  0,35 NO es mayor que 0,4 (0,4 = 0,40).\n\nCompara cifra a cifra empezando por la izquierda: décimas, centésimas…':
      'Bi hamartar dituzu eta handiena ukitu behar duzu.\n\nKontuz: zifra gehiagok EZ du esan nahi handiagoa.\n  0,35 EZ da 0,4 baino handiagoa (0,4 = 0,40).\n\nKonparatu zifraz zifra ezkerretik hasita: hamarrenak, ehunenak…',
  'En la vida: comparar precios (0,35 €/kg vs 0,4 €/kg). Más cifras no es más caro.':
      'Bizitzan: prezioak konparatu (0,35 €/kg vs 0,4 €/kg). Zifra gehiago ez da garestiagoa.',
  '¿La fracción es menor, igual o mayor que 1?\n\n• numerador < denominador → la fracción es menor que 1 (propia)\n• numerador = denominador → la fracción es igual a 1\n• numerador > denominador → la fracción es mayor que 1 (impropia)':
      'Zatikia 1 baino txikiagoa, berdina ala handiagoa al da?\n\n• zenbakitzailea < izendatzailea → zatikia 1 baino txikiagoa da (propioa)\n• zenbakitzailea = izendatzailea → zatikia 1 da\n• zenbakitzailea > izendatzailea → zatikia 1 baino handiagoa da (irregularra)',
  'En la vida: saber si has comido más de una pizza entera o menos.':
      'Bizitzan: pizza oso bat baino gehiago jan duzun ala gutxiago jakitea.',
  'Verás una fracción y tres botones: <1/2, =1/2, >1/2.\n\nTruco: una fracción vale 1/2 cuando el denominador es el doble del numerador (2/4, 3/6, 5/10…). Desde ahí:\n\n  • Dobla el numerador y compáralo con el denominador.\n  • Si NO llega al denominador → la fracción es MENOR que 1/2.\n    Ejemplo: 4/9 → doble de 4 = 8, no llega a 9 → 4/9 < 1/2.\n\n  • Si da justo el denominador → IGUAL a 1/2.\n    Ejemplo: 3/6 → doble de 3 = 6 → 3/6 = 1/2.\n\n  • Si se pasa del denominador → MAYOR que 1/2.\n    Ejemplo: 5/9 → doble de 5 = 10, mayor que 9 → 5/9 > 1/2.':
      'Zatiki bat eta hiru botoi ikusiko dituzu: <1/2, =1/2, >1/2.\n\nTrukoa: zatiki batek 1/2 balio du izendatzailea zenbakitzailearen bikoitza denean (2/4, 3/6, 5/10…). Hortik:\n\n  • Bikoiztu zenbakitzailea eta izendatzailearekin konparatu.\n  • Izendatzailera EZ badira iristen → zatikia 1/2 baino TXIKIAGOA da.\n    Adibidea: 4/9 → 4ren bikoitza = 8, ez da 9ra iristen → 4/9 < 1/2.\n\n  • Izendatzailea zehazki ematen badu → 1/2ren BERDINA.\n    Adibidea: 3/6 → 3ren bikoitza = 6 → 3/6 = 1/2.\n\n  • Izendatzailetik pasatzen bada → 1/2 baino HANDIAGOA.\n    Adibidea: 5/9 → 5en bikoitza = 10, 9 baino handiagoa → 5/9 > 1/2.',
  'En la vida: estimar de un vistazo si un vaso o un depósito está más de la mitad lleno, sin medir.':
      'Bizitzan: edalontzi edo upel bat erditik gora dagoen ala ez begi kolpe batean igartzea, neurtu gabe.',
  'Elige la fracción que vale lo mismo que la que ves.\n\nDos fracciones son equivalentes cuando representan la misma cantidad.\n\nPara comprobarlo, multiplica en cruz: a/b = c/d si a×d = c×b.\nPara encontrar una equivalente, multiplica o divide numerador y denominador por el mismo número.':
      'Aukeratu ikusten duzun zatikiaren balio bera duen zatikia.\n\nBi zatiki baliokideak dira kantitate bera adierazten dutenean.\n\nEgiaztatzeko, gurutzatuta biderkatu: a/b = c/d baldin eta a×d = c×b.\nBaliokide bat aurkitzeko, biderkatu edo zatitu zenbakitzailea eta izendatzailea zenbaki beraren bidez.',
  'En la vida: repartir lo mismo de formas distintas (2/4 de pizza = 1/2).':
      'Bizitzan: gauza bera modu desberdinetan banatu (pizzaren 2/4 = 1/2).',
  'Reduce la fracción a su forma más simple.\n\nPara simplificar, divide numerador y denominador entre el mismo número (el MCD).\n\nEjemplo: 6/8 → divide entre 2 → 3/4.\n6/8 y 3/4 valen lo mismo, pero 3/4 es la forma más simple.':
      'Murriztu zatikia bere forma errazenera.\n\nSinplifikatzeko, zatitu zenbakitzailea eta izendatzailea zenbaki beraren bidez (ZKH).\n\nAdibidea: 6/8 → 2z zatitu → 3/4.\n6/8 eta 3/4 balio bera dute, baina 3/4 da forma errazena.',
  'En la vida: expresar medidas de la forma más simple (4/8 → 1/2).':
      'Bizitzan: neurriak forma errazenean adierazi (4/8 → 1/2).',
  'Completa el número que falta: a/b = ?/c.\n\nPara amplificar, multiplica numerador y denominador por el mismo número.\n\nEjemplo: 3/4 = ?/12 → 4×3 = 12, así que 3×3 = 9 → 3/4 = 9/12.':
      'Amplifikatu zatikia eskatzen den izendatzailera.\n\nZatikia berdina mantentzeko, biderkatu BIAK (zenbakitzailea eta izendatzailea) zenbaki beraren bidez.\n\nAdibidea: 3/4 = ?/12 → izendatzailea ×3 → zenbakitzailea ere ×3 → 9/12.',
  'En la vida: adaptar una receta para más comensales manteniendo proporciones.':
      'Bizitzan: errezeta gehiagorako neurriak handitu, proportzioa mantenduz.',
  'Elige el decimal que equivale a la fracción.\n\nPara convertir una fracción a decimal, divide el numerador entre el denominador.\n\nEjemplo: 3/4 = 3 ÷ 4 = 0,75.':
      'Zatikiari dagokion hamartarra hautatu.\n\nZatitu zenbakitzailea izendatzailearen artean:\n  1/2 = 0,5\n  1/4 = 0,25\n  3/4 = 0,75\n  1/5 = 0,2\n\nMemorizatu erabilienak; behin eta berriz agertuko zaizkizu.',
  'En la vida: convertir 3/4 de hora en 0,75 h para calcular tiempo total.':
      'Bizitzan: kalkulagailuko hamartarrak ulertzea, prezioak, neurriak.',
  'Elige el porcentaje que equivale a la fracción.\n\nUn porcentaje es una fracción con denominador 100.\nPara convertir: multiplica la fracción por 100.\n\nEjemplo: 3/4 = 3÷4 = 0,75 → 0,75×100 = 75%.':
      'Zatikiari dagokion ehunekoa aukeratu.\n\nLehenik hamartarra bilatu (zenbakitzailea/izendatzailea) eta 100ez biderkatu:\n  1/2 = 0,5 = 50 %\n  1/4 = 0,25 = 25 %\n  3/4 = 0,75 = 75 %\n  1/5 = 0,2 = 20 %',
  'En la vida: entender que 3/4 = 75% en un examen, un descuento o una encuesta.':
      'Bizitzan: beherapenak ulertu, ehunekoetan emandako emaitzak.',
  'Mira qué operador hay entre las dos fracciones y aplica la regla correspondiente.\n\n• SUMA o RESTA (a/b + c/d):\n    1) Iguala los denominadores buscando el MCM.\n    2) Suma o resta los numeradores; el denominador no cambia.\n    Ejemplo: 1/2 + 1/4 → 2/4 + 1/4 = 3/4.\n\n• MULTIPLICACIÓN (a/b × c/d):\n    Multiplica numerador × numerador y denominador × denominador.\n    Ejemplo: 2/3 × 4/5 = 8/15.\n\n• DIVISIÓN (a/b ÷ c/d):\n    Invierte la segunda fracción y multiplica.\n    Ejemplo: 2/3 ÷ 4/5 = 2/3 × 5/4 = 10/12 = 5/6.\n\nSimplifica el resultado siempre que puedas.':
      'Begiratu bi zatikien arteko eragiketa eta dagokion erregela aplikatu.\n\n• BATUKETA edo KENKETA (a/b + c/d):\n    1) Berdindu izendatzaileak MKT bilatuz.\n    2) Batu edo kendu zenbakitzaileak; izendatzailea ez da aldatzen.\n    Adibidea: 1/2 + 1/4 → 2/4 + 1/4 = 3/4.\n\n• BIDERKETA (a/b × c/d):\n    Biderkatu zenbakitzailea × zenbakitzailea eta izendatzailea × izendatzailea.\n    Adibidea: 2/3 × 4/5 = 8/15.\n\n• ZATIKETA (a/b ÷ c/d):\n    Alderantzikatu bigarren zatikia eta biderkatu.\n    Adibidea: 2/3 ÷ 4/5 = 2/3 × 5/4 = 10/12 = 5/6.\n\nEmaitza beti sinplifikatu ahal duzunean.',
  'En la vida: sumar ingredientes en cocina (1/2 taza + 1/4 taza = 3/4 taza).':
      'Bizitzan: sukaldean osagaiak batu (1/2 katilukada + 1/4 katilukada = 3/4 katilukada).',
  'Calcula el resultado de la operación con decimales.\n\n• SUMA y RESTA: alinea las comas decimales y suma o resta cifra a cifra.\n• MULTIPLICACIÓN: multiplica sin comas y después coloca la coma (tantos decimales como entre los dos factores).\n• DIVISIÓN: desplaza la coma para que el divisor sea entero.':
      'Egin eragiketa hamartarren artean.\n\n• BATUKETA/KENKETA: lerrokatu komak eta eragin.\n  2,5 + 1,75:\n     2,50\n   + 1,75\n   ─────\n     4,25\n\n• BIDERKETA: biderkatu komak kontuan hartu gabe; gero, jarri komak adina hamarren bi zenbakietan zituzten guztiak.\n  2,5 × 1,4 = 25 × 14 = 350 → 3,50 (1+1 hamarren).\n\n• ZATIKETA: biderkatu biak komak ezabatzeko, ondoren zatitu osokoak.',
  'En la vida: calcular el total de la compra (1,25 € + 3,80 €).':
      'Bizitzan: prezioak gehitu, deskontuak kalkulatu, neurriak banatu.',
  'Calcula respetando la prioridad de las operaciones.\n\n1. Primero las multiplicaciones (×) y divisiones (÷).\n2. Después las sumas (+) y restas (−).\n\nNo operes de izquierda a derecha sin respetar la jerarquía, ¡es la trampa!':
      'Eragiketa konplexu batean, hurrenkera dauka:\n\n1. Parentesiak ( )\n2. Berreduratak (² ³) eta erroak\n3. Biderketa × eta zatiketa ÷\n4. Batuketa + eta kenketa −\n\nMaila berean, ezkerretik eskuinera.\n\nAdibidea: 2 + 3 × 4 = 2 + 12 = 14 (EZ 5 × 4 = 20).',
  'En la vida: calcular 2 + 3 × 4 en una factura (× va antes que +).':
      'Bizitzan: kalkulagailu zientifikoa ulertu, formulak ondo aplikatu.',
  'Igual que la jerarquía normal, pero con fracciones.\n\n1. Primero multiplica y divide las fracciones.\n2. Después suma y resta, igualando denominadores cuando haga falta.\n\nRecuerda simplificar el resultado si puedes.':
      'Hierarkia bera, baina zatikiekin.\n\n1/2 + 1/4 × 2/3 ezagutzeko:\n  1) Lehenik biderketa: 1/4 × 2/3 = 2/12 = 1/6.\n  2) Ondoren batuketa: 1/2 + 1/6 = 3/6 + 1/6 = 4/6 = 2/3.\n\nGogoratu: × eta ÷ + eta − baino lehen.',
  'En la vida: cálculos mixtos con ingredientes y medidas en cocina.':
      'Bizitzan: errezetak doitu, errezeta osoetan zati gehiago kalkulatu.',
  'Operación que mezcla un decimal y una fracción.\n\nConvierte la fracción a decimal (numerador ÷ denominador) y después opera.\n\nO al revés: convierte el decimal a fracción y opera con fracciones.\n\nElige el camino que te resulte más fácil.':
      'Zenbaki hamartar eta zatiki bat batera dituzunean, biak formatu berera ekarri:\n\n• Zatikia hamartarrera (zenbakitzailea izendatzailearen artean zatitu).\n• Edo hamartarrak zatikira.\n\nEragin gero, formatu berean.\n\nAdibidea: 0,5 + 1/4 = 0,5 + 0,25 = 0,75.',
  'En la vida: combinar medidas en distintos formatos (0,5 L + 1/4 L).':
      'Bizitzan: prezioak (€ hamartar) eta tarta zatiak konbinatu.',
  '¿El número se puede dividir exactamente?\n\n• Un número es divisible entre 2 si termina en 0 o cifra par.\n• Entre 3 si la suma de sus cifras es múltiplo de 3.\n• Entre 5 si termina en 0 o 5.\n• Entre 10 si termina en 0.\n\nSi la división da exacta (resto 0), es divisible.':
      'Zenbaki bat beste batez zatigarria al den erabaki behar duzu (BAI/EZ).\n\nIrizpideak:\n  • 2ren: bukaeran 0,2,4,6,8\n  • 3ren: zifren batuketa 3ren multiploa\n  • 5en: bukaeran 0 ala 5\n  • 9ren: zifren batuketa 9ren multiploa\n  • 10en: bukaeran 0',
  'En la vida: saber si puedes repartir algo en grupos iguales sin que sobre nada.':
      'Bizitzan: 12 gozoki 3 lagun artean berdin banatu al daitezke jakitea.',
  '¿Un número es múltiplo de otro?\n\nUn número es múltiplo de otro si se puede dividir exactamente entre él.\n\nEjemplo: 15 es múltiplo de 3 porque 15÷3 = 5 exacto.\n         15 NO es múltiplo de 4 porque 15÷4 no da exacto.':
      'N zenbakia M-ren multiploa al den erabaki behar duzu.\n\nM-ren multiploak hauek dira: M, 2×M, 3×M, 4×M…\nAdibidea: 6ren multiploak: 6, 12, 18, 24, 30…\n\nTrukoa: N zatitu M-ren artean. Hondarrik ez badago, multiploa da.',
  'En la vida: calcular cuándo coinciden dos eventos (cada 3 y cada 4 días).':
      'Bizitzan: 30 minuturo aparkalekuaren erloju digitala — zer ordutan amaituko da?',
  'Tres números son divisores. El cuarto es el intruso: no lo es.\n\nUn divisor de N es un número que divide a N exactamente (resto 0).\n\nComprueba cada candidato haciendo la división mental. El que no encaja es el intruso.':
      'Zenbaki handi bat eta lau hautagai dituzu; hiru benetako zatitzaileak dira eta bat ez. Ez dena ukitu.\n\nZatitzaileak: N zehatz-mehatz zatitzen duten zenbakiak.\nAdibidea: 12ren zatitzaileak: 1, 2, 3, 4, 6, 12. 5 ez da zatitzailea.',
  'En la vida: repartir equitativamente entre varias personas sin que sobre nada.':
      'Bizitzan: 24 ikasle taldetan banatu, taldekide kopuru bera izanik.',
  '¿El número es primo?\n\nUn número primo solo se puede dividir exactamente entre 1 y entre sí mismo.\n\nImportante: 1 NO es primo (solo tiene un divisor).\n2 es el único número primo par.':
      'Erabaki zenbaki bat lehena al den (BAI/EZ).\n\nLehena: bi zatitzaile baino ez ditu: 1 eta bera.\nAdibideak: 2, 3, 5, 7, 11, 13, 17, 19…\n\nKontuz:\n  • 1 EZ da lehena.\n  • 2 lehen bakarra da bikoitia.\n  • 9 = 3×3, EZ da lehena.',
  'En la vida: conceptos básicos de cifrado y seguridad digital.':
      'Bizitzan: kriptografia eta zenbaki seguruen oinarria.',
  'Verás dos números y cuatro candidatos. Fíjate primero en si la pantalla pide MCM o MCD: son cosas distintas.\n\n• MCM (mínimo común múltiplo) = el primer número que aparece en las dos tablas de multiplicar.\n    Ejemplo (4 y 6):\n      Tabla del 4 → 4, 8, 12, 16, 20…\n      Tabla del 6 → 6, 12, 18, 24…\n      El primero que se repite es 12. MCM(4, 6) = 12.\n\n• MCD (máximo común divisor) = el número más grande que divide a los dos exactamente.\n    Ejemplo (12 y 18):\n      Divisores de 12 → 1, 2, 3, 4, 6, 12\n      Divisores de 18 → 1, 2, 3, 6, 9, 18\n      El mayor común es 6. MCD(12, 18) = 6.\n\nTruco para no confundirlos: MCM siempre es igual o mayor que los dos números; MCD siempre es igual o menor.':
      'Bi zenbaki eta lau hautagai ikusiko dituzu. Lehenik begiratu ea pantailak MKT ala ZKH eskatzen duen: gauza desberdinak dira.\n\n• MKT (multiplo komun txikiena) = bi biderketa-tauletan agertzen den lehen zenbakia.\n    Adibidea (4 eta 6):\n      4ren taula → 4, 8, 12, 16, 20…\n      6ren taula → 6, 12, 18, 24…\n      Errepikatzen den lehena 12 da. MKT(4, 6) = 12.\n\n• ZKH (zatitzaile komun handiena) = biak zehazki zatitzen dituen zenbakirik handiena.\n    Adibidea (12 eta 18):\n      12ren zatitzaileak → 1, 2, 3, 4, 6, 12\n      18ren zatitzaileak → 1, 2, 3, 6, 9, 18\n      Komuna handiena 6 da. ZKH(12, 18) = 6.\n\nNahasi ez izateko trukoa: MKT beti bi zenbaki baino berdina edo handiagoa; ZKH beti berdina edo txikiagoa.',
  'En la vida: dos campanas que suenan cada 6 y cada 8 minutos coinciden por primera vez al cabo de MCM(6, 8) = 24 minutos.':
      'Bizitzan: 6 eta 8 minuturo jotzen duten bi kanpaiak lehen aldiz MKT(6, 8) = 24 minuturen ondoren bat etortzen dira.',
  'Calcula el porcentaje de una cantidad.\n\nFórmula: (porcentaje × cantidad) ÷ 100\n\nEjemplo: el 25% de 80 = (25 × 80) ÷ 100 = 2000 ÷ 100 = 20.':
      'Kantitate baten ehunekoa kalkulatu.\n\nFormulea: % × kantitatea / 100\nAdibidea: 80ren % 25 = 25 × 80 / 100 = 2000 / 100 = 20.\n\nTrukoa: 50 % = erdia; 25 % = laurdena; 10 % = hamarrena.',
  'En la vida: calcular el 15% de propina o el 21% de IVA.':
      'Bizitzan: beherapenak kalkulatu, BEZa eta abar.',
  'Una cantidad es ¿qué porcentaje del total?\n\nFórmula: (parte ÷ total) × 100\n\nEjemplo: 12 de 50 → (12 ÷ 50) × 100 = 0,24 × 100 = 24%.':
      'Aurrekoaren alderantzia: zatia eta osoa dituzu, ehunekoa nahi duzu.\n\nFormulea: (zatia / osoa) × 100\nAdibidea: 50etik 12 → (12/50) × 100 = 24 %.',
  'En la vida: saber qué nota sacaste (12/14 → 85%).':
      'Bizitzan: zenbat lortu duzun proportzioan ehunekotan jakitea (12/50 = 24 %).',
  'Calcula el resultado tras aplicar un aumento o descuento porcentual.\n\n1. Calcula el porcentaje de la cantidad.\n2. Si es aumento → suma el resultado.\n   Si es descuento → resta el resultado.\n\nEjemplo: aumenta un 15% sobre 200 → 15% de 200 = 30 → 200+30 = 230.':
      'Kantitate bati ehuneko bat gehitu edo kendu.\n\n• Gehitu: kantitatea + (% × kantitatea / 100).\n  200i % 15 gehitu = 200 + 30 = 230.\n• Kendu: kantitatea − (% × kantitatea / 100).\n  80i % 20 kendu = 80 − 16 = 64.',
  'En la vida: calcular rebajas (20% descuento) o subidas (10% aumento).':
      'Bizitzan: dendako beherapenak (% 30 kendu) edo BEZa gehitu.',
  'Completa la proporción: a:b = c:?\n\nDos ratios son proporcionales si el factor de escala es el mismo.\nPara encontrar el valor que falta: multiplica o divide por el mismo número ambos términos.':
      'Bi magnituderen artean erlazio konstante bat dago.\n\nProportzio zuzena: bata gehitzean, bestea ere gehitzen da kopuru bera.\nProportzio alderantzizkoa: bata gehitzean, bestea txikitu.\n\nAdibidea: 3 sagar 2€ badira, 6 sagar 4€ izango dira (zuzena).',
  'En la vida: mantener la misma relación al ampliar una receta o un plano.':
      'Bizitzan: errezetak bikoiztu, neurri bera mantenduz.',
  'Si "a → b", entonces "c → ?"\n\nFórmula: ? = (b × c) ÷ a\n\nEjemplo: si 3 kg cuestan 12 €, 5 kg cuestan (12 × 5) ÷ 3 = 60 ÷ 3 = 20 €.':
      'Proportzio zuzena: a → b · c → ?\n\nFormulea: ? = b × c / a\n\nAdibidea: 3 sagar 2€ badira, 9 sagarrek zenbat balio dute?\n  ? = 2 × 9 / 3 = 18/3 = 6€.',
  'En la vida: si 3 kg cuestan 12 €, ¿cuánto cuestan 5 kg?':
      'Bizitzan: erosketak proportzio batekin, ahaztu gabe.',
  'Elige la razón reducida que relaciona dos cantidades.\n\nUna razón compara dos cantidades. Se reduce dividiendo ambas entre el mismo número (el MCD).\n\nEjemplo: 12 manzanas y 8 naranjas → 12:8 → dividiendo entre 4 → 3:2.':
      'Bi kantitateren arteko erlazioa, sinplifikatuta a:b moduan.\n\nAdibidea: 12 sagar eta 8 laranja → 12:8 = 3:2 (sinplifikatua).\n\nTrukoa: ZKH bilatu eta biak harekin zatitu.',
  'En la vida: expresar relaciones (3:2 de manzanas a naranjas en una macedonia).':
      'Bizitzan: errezeta proportzio batean (3 ur:1 erres), mapa eskala.',
  'Calcula la fracción de una cantidad.\n\nFórmula: (cantidad ÷ denominador) × numerador\n\nEjemplo: los 3/5 de 25 → (25 ÷ 5) × 3 = 5 × 3 = 15.':
      'Kantitate baten zatikia kalkulatu.\n\nFormulea: (zenbakitzailea × kantitatea) / izendatzailea\nAdibidea: 25en 3/5 = (3 × 25) / 5 = 75/5 = 15.',
  'En la vida: calcular los 3/5 de 25 € que te tocan en un reparto.':
      'Bizitzan: 30 gozokien 2/3 banatu = 20 gozoki.',
  'Aplica la escala y convierte las unidades.\n\nEscala 1:500 significa que 1 cm en el plano son 500 cm (5 m) en la realidad.\n\n1. Multiplica la medida del plano por el denominador de la escala.\n2. Convierte el resultado a la unidad que te pidan (cm → m ÷ 100).':
      'Mapa edo plano batean, eskalak adierazten du benetako neurriaren proportzioa.\n\nEskala 1:500 → planoko 1 cm = errealitatean 500 cm = 5 m.\nAdibidea: planoko 4 cm errealean = 4 × 500 = 2000 cm = 20 m.',
  'En la vida: leer mapas y planos (1 cm en el mapa = 500 cm reales).':
      'Bizitzan: mapak, planoak, jostailuzko maketak ulertu.',
  'Lee el texto y elige la fracción correcta.\n\n"Tres quintos" → el numerador es 3 y el denominador es 5 → 3/5.\n\nCuidado: no inviertas numerador y denominador.':
      'Hitzez emandako zatikia ("hiru bostenak") hautatu zenbakizko adierazpenetan.\n\n• Zenbakitzailea: kardinala (bat, bi, hiru…).\n• Izendatzailea: ordinala (laurden, bosten, seien…).\n\nAdibidea: "hiru bostenak" = 3/5.\nKontuz: "erdiak" = 1/2 ez 2/2.',
  'En la vida: entender "tres quintos" en una receta o un reparto.':
      'Bizitzan: errezetan eta hizketako neurriak ulertu.',
  'Lee el texto y elige el decimal correcto.\n\n"Veinticinco centésimas" → 0,25\n"Tres décimas" → 0,3\n\nCuidado con las cifras: décimas (1 cifra), centésimas (2 cifras).':
      'Hitzez emandako hamartarra hautatu zenbakizkoetan.\n\n• Hamarrenak: koma osteko lehen zifra.\n• Ehunenak: bigarrena.\n• Milarenak: hirugarrena.\n\nAdibidea: "hogeita bost ehunen" = 0,25.',
  'En la vida: entender cuando alguien dice "cero coma veinticinco".':
      'Bizitzan: prezioak ahoz ulertu, lasterketako denborak.',
  'Redondea el decimal a la décima.\n\nPara redondear a la décima, mira la centésima:\n• Si es 5 o más → la décima sube una.\n• Si es menos de 5 → la décima se queda igual.\n\nEjemplo: 2,37 → la centésima es 7 ≥ 5 → 2,4.':
      'Hurbildu hamartarra zifra gutxiagora.\n\nHamarrenera biribiltzeko:\n  • Begiratu ehunena.\n  • 0-4 → biribildu behera (hamarrena bere horretan utzi).\n  • 5-9 → biribildu gora (hamarrenari 1 gehitu).\n\nAdibidea: 2,37 → ehunena 7 → biribildu 2,4.',
  'En la vida: dar un precio aproximado (2,37 € → 2,4 € al redondear).':
      'Bizitzan: prezioak eta neurriak biribildu, kalkulu azkarrak.',
  'Ordena los decimales de menor a mayor.\n\nCompara cifra a cifra empezando por la izquierda.\nMás cifras NO significa más grande: 0,35 > 0,4? No, 0,4 = 0,40.':
      'Hiru hamartar sailkatu txikienetik handienera.\n\nKonparatu zifraz zifra ezkerretik. Kontuz: zifra gehiagok EZ du esan nahi handiagoa.\n\nAdibidea: 0,5 / 0,35 / 0,8 → ordena: 0,35 < 0,5 < 0,8.',
  'En la vida: ordenar precios de menor a mayor sin confundirte.':
      'Bizitzan: dendako prezioak ondo sailkatu merkeenetik garestienera.',
  'Ordena las fracciones de menor a mayor.\n\nConviértelas a decimal (numerador ÷ denominador) para compararlas.\nO multiplica en cruz para ver cuál es mayor.':
      'Hiru zatiki sailkatu txikienetik handienera.\n\nTrukoak:\n• Denak hamartarrera bihurtu (zenbakitzailea izendatzailearen artean zatitu) eta gero sailkatu.\n• Edo izendatzaile berdina bilatu eta zenbakitzaileak konparatu.',
  'En la vida: ordenar medidas de ingredientes de menor a mayor.':
      'Bizitzan: zatiketa errezetan, taldeen tamaina konparatu.',
  'Convierte la fracción impropia en número mixto.\n\nDivide el numerador entre el denominador:\n  • el cociente es la parte entera\n  • el resto es el nuevo numerador\n  • el denominador se queda igual\n\nEjemplo: 7/4 → 7÷4 = 1 y resto 3 → 1 y 3/4.':
      'Zatiki irregularra (zenbakitzailea > izendatzailea) zenbaki mistora bihurtu.\n\nZenbakitzailea izendatzailearen artean zatitu:\n  • Zatidura: parte osoa.\n  • Hondarra: zenbakitzaile berria (izendatzailea berdin mantenduta).\n\nAdibidea: 11/4 → 11÷4 = 2 hondar 3 → 2 eta 3/4.',
  'En la vida: expresar 7/4 de pizza como "una pizza y tres cuartos".':
      'Bizitzan: 7/4 pizza esan beharrean, 1 eta 3/4 pizza.',
  'Convierte el número mixto en fracción impropia.\n\nFórmula: (entero × denominador + numerador) / denominador\n\nEjemplo: 2 y 3/4 → (2×4 + 3)/4 = (8+3)/4 = 11/4.':
      'Zenbaki mistoa ("2 eta 3/4") zatiki irregularrera bihurtu.\n\nFormula: parte osoa × izendatzailea + zenbakitzailea = zenbakitzaile berria.\nAdibidea: 2 eta 3/4 → 2×4 + 3 = 11/4.',
  'En la vida: convertir "2 horas y media" a fracción para operar.':
      'Bizitzan: zatikiekin eragiketa egiteko forma erosoago bat lortzeko.',
  'Convierte entre unidades de longitud.\n\nLa escalera métrica: km → hm → dam → m → dm → cm → mm\nCada paso multiplica o divide por 10.\n\nEjemplo: 5 m = ? cm → de m a cm son 2 pasos ×10 → 5×10×10 = 500 cm.':
      'Metriko sistemaren eskaileran, maila bakoitzak ×10 (jaitsiz) edo ÷10 (igoz).\n\nkm → hm → dam → m → dm → cm → mm\n\nAdibidea: 5 m → cm: 2 maila jaitsi → ×100 → 500 cm.',
  'En la vida: 5 m = 500 cm al medir una habitación o un mueble.':
      'Bizitzan: distantziak unitate desberdinetan ulertu (km batetik m batera).',
  'Convierte entre unidades de masa (g) o capacidad (L).\n\nMisma escalera que longitud: cada paso ×10.\n\nEjemplo: 3 kg = ? g → 3×10×10×10 = 3000 g.\nEjemplo: 5 L = ? mL → 5×10×10×10 = 5000 mL.':
      'Masa (kg, g, mg) eta edukiera (L, dL, cL, mL) ere ×10 eskailera erabiltzen dute.\n\nMasa: kg → hg → dag → g → dg → cg → mg\nEdukiera: kL → hL → daL → L → dL → cL → mL\n\nAdibidea: 3 kg = 3000 g; 5 L = 500 cL.',
  'En la vida: 1 kg = 1000 g para una receta, o 1 L = 1000 mL.':
      'Bizitzan: errezeta unitateak konbinatu, edari botilen edukiera.',
  'Convierte entre unidades de superficie (m², cm²…).\n\nCada paso multiplica o divide por 100 (NO por 10).\n\nEjemplo: 5 m² = ? cm² → 5×100×100 = 50.000 cm².\n¡Atento! Es fácil confundirlo con la longitud lineal (×10).':
      'Azaleren eskailera maila bakoitzeko ×100 (luzeran ez bezala, ×10 baizik).\n\nAdibidea: 5 m² = ? cm²\n  Maila bakar bat jaitsi → ×100 → 500? EZ. m²→dm²→cm² bi maila → ×10 000 → 50 000 cm².\n\nBaina galdetzen badizute m²-tik dm² ondoz ondokorako: ×100 → 500 dm².',
  'En la vida: calcular 5 m² en cm² para comprar baldosas.':
      'Bizitzan: gelaren azalera neurri desberdinetan, baratzeko sailak.',
  'Convierte entre horas, minutos y segundos.\n\nEl tiempo NO es decimal, es sexagesimal (base 60):\n  1 hora = 60 minutos\n  1 minuto = 60 segundos\n\nEjemplo: 2 h y 30 min = 2×60 + 30 = 150 min (NO 230).':
      'Sexagesimala da: maila bakoitzak ×60 (×10 ez).\n\n1 h = 60 min\n1 min = 60 s\n1 h = 3600 s\n\nAdibideak:\n  3 h = 180 min\n  2 h eta 30 min = 2×60 + 30 = 150 min.\n\nKontuz: "2 h 30 min" EZ da 230 min, 150 min baizik.',
  'En la vida: 2 h y 30 min = 150 min (no 230). Útil para planificar.':
      'Bizitzan: bidaiaren denbora ulertu, errezeten denborak.',
  'Elige el nombre del ángulo según su abertura.\n\n• Agudo: menos de 90°\n• Recto: exactamente 90°\n• Obtuso: más de 90° y menos de 180°\n• Llano: exactamente 180°':
      'Begiratu pantailan dagoen angeluari eta sailkatu:\n\n• Zorrotza: 90° baino txikiagoa.\n• Zuzena: zehazki 90° (eskuadra).\n• Kameltsua: 90° eta 180° artean.\n• Lautua: zehazki 180° (lerro zuzena).',
  'En la vida: identificar si una esquina es recta (90°) para muebles.':
      'Bizitzan: gauzak laukizuzenak diren ala ez identifikatu, bidegurutzeak.',
  'Elige el nombre del polígono según su número de lados.\n\n• 3 lados → triángulo\n• 4 lados → cuadrado (o rectángulo)\n• 5 lados → pentágono\n• 6 lados → hexágono\n• 7 lados → heptágono\n• 8 lados → octágono':
      'Aldeen kopuruaren arabera izena:\n\n• 3 alde → triangelua\n• 4 alde → laukia / koadroa\n• 5 alde → pentagonoa\n• 6 alde → hexagonoa\n• 7 alde → heptagonoa\n• 8 alde → oktogonoa',
  'En la vida: reconocer formas en señales, mosaicos y construcciones.':
      'Bizitzan: trafiko-seinaleak (oktogonoa = STOP), errealitateko forma asko.',
  'Calcula el perímetro del polígono.\n\nEl perímetro es la suma de todos los lados.\n\nEn un rectángulo: P = 2 × (base + altura).\nEn un polígono regular: P = lado × número de lados.':
      'Poligono baten alde guztien batuketa.\n\nAdibideak:\n• Laukizuzena (3 cm × 5 cm): P = 2×(3+5) = 16 cm.\n• Triangelua aldeekin 4, 5, 6: P = 4+5+6 = 15 cm.\n• Hexagonoa erregularra alde 4-koa: P = 6×4 = 24 cm.',
  'En la vida: cuánta valla necesitas para cercar un terreno o un jardín.':
      'Bizitzan: itxitura baten luzera kalkulatu, koadro baten markoa.',
  'Calcula el área del rectángulo.\n\nFórmula: Área = base × altura\n\nNo lo confundas con el perímetro (que suma los lados).':
      'Formula: oinarria × altuera.\n\nAdibidea: 4 cm × 3 cm = 12 cm².\n\nKontuz: ez nahasi perimetroarekin (2×(b+h)).',
  'En la vida: calcular la superficie de una habitación para poner suelo.':
      'Bizitzan: gelaren azalera, lurpe edo pinturaren neurketa.',
  'Calcula el área del triángulo.\n\nFórmula: Área = (base × altura) ÷ 2\n\n¡No olvides dividir entre 2!':
      'Formula: (oinarria × altuera) / 2.\n\nAltuera oinarrira perpendikularra da.\n\nAdibidea: oinarria 6, altuera 4 → A = 6×4/2 = 12 cm².',
  'En la vida: calcular el área de un tejado o un panel solar triangular.':
      'Bizitzan: triangelu-formako sail bat neurtu, teilatu baten azalera.',
  'Calcula el área o el perímetro del círculo.\n\nUsa π ≈ 3,14.\n\n• Perímetro (circunferencia) = 2 × π × radio\n• Área = π × radio²\n\nNo las confundas: el perímetro mide el borde, el área mide el interior.':
      'Erradioa (r) erabiliz:\n\n• Perimetroa (zirkunferentzia): P = 2 × π × r.\n• Azalera: A = π × r².\n\nπ ≈ 3,14.\n\nAdibidea: r = 5 cm → P = 2×3,14×5 = 31,4 cm; A = 3,14×25 = 78,5 cm².',
  'En la vida: calcular la superficie de una mesa redonda o su borde.':
      'Bizitzan: pizza zirkular baten azalera, gurpilak.',
  'Calcula el volumen de la caja.\n\nFórmula: Volumen = largo × ancho × alto\n\nNo lo confundas con el área superficial (que suma todas las caras).':
      'Formula: luzera × zabalera × altuera.\n\nAdibidea: 3 × 4 × 5 = 60 cm³.\n\nKontuz: ez nahastu azalerarekin (2(la+lh+ah)).',
  'En la vida: cuántos litros caben en una pecera o una caja.':
      'Bizitzan: kaxa baten edukiera, akuario baten ura.',
  '¿La figura es simétrica respecto al eje marcado?\n\nUna figura es simétrica si al doblarla por el eje, las dos mitades coinciden exactamente.\n\nImagina un espejo en la línea. ¿El reflejo sería idéntico?':
      'Figura batek ardatz simetriko bat al du? (BAI/EZ).\n\nArdatzaren bi aldetan zati berdinak badaude, simetrikoa da.\n\nAdibideak:\n• Koadroa: ardatz horizontal, bertikal eta diagonalak ditu.\n• T letra: bertikala bakarrik.\n• R letra: bat ere ez.',
  'En la vida: reconocer formas simétricas en la naturaleza y el arte.':
      'Bizitzan: arkitektura, naturako patroiak (tximeletak, hostoak).',
  'Lee el valor en el gráfico de barras.\n\nMira la altura de la barra señalada y compárala con los números del eje vertical.\nSi te piden el total, suma todas las barras.':
      'Barra bakoitzaren altuera balio bati dagokio.\n\nGaldera bi mota:\n• Barra zehatz baten balioa irakurri.\n• Guztien batura kalkulatu.\n\nIrakurri Y ardatzaren eskala arretaz.',
  'En la vida: leer datos en periódicos, informes y estadísticas.':
      'Bizitzan: aurrekontuak, kirol estatistikak, klima.',
  'Lee el porcentaje de la porción señalada.\n\nEl círculo entero representa el 100%. Cada porción es una parte.\nFíjate en el tamaño de la porción respecto al círculo completo.':
      'Zirkulu osoa 100 % da. Zati bakoitzak portzentaia bat adierazten du.\n\nGaldera: zati nabarmenduak zer % adierazten duen.\n\nBegirada arinarekin: zati handiena > 50 %, txikiena < 25 %…',
  'En la vida: entender porcentajes visuales en encuestas y resultados.':
      'Bizitzan: hauteskunde emaitzak, bozketen banaketa.',
  'Calcula la media de los números.\n\nFórmula: (suma de todos los números) ÷ (cantidad de números)\n\n1. Suma todos los números.\n2. Divide entre cuántos números hay.':
      'Zenbaki guztien batuketa, zenbaki kopuruaren artean zatituta.\n\nAdibidea: 4, 6, 8 → batuketa 18, hiru zenbaki → 18/3 = 6.',
  'En la vida: calcular la nota media o el gasto promedio por día.':
      'Bizitzan: notaren batezbestekoa, bidaiaren abiadura.',
  'Calcula la moda o la mediana.\n\n• Moda: el número que más se repite.\n• Mediana: ordena los números y elige el del centro. Si hay dos, haz la media.':
      '• MODA: gehien errepikatzen den balioa.\n• MEDIANA: ordenatutako balio guztien erdiko balioa.\n\nAdibidea: 2, 3, 3, 5, 7 → moda 3, mediana 3.\nBalio kopurua bikoitia bada, erdiko bi balioen batezbestekoa.',
  'En la vida: entender qué talla es la más común (moda) o el salario típico (mediana).':
      'Bizitzan: galdetegietan erantzun ohikoenak, soldata tipikoak.',
  'Calcula la probabilidad como fracción.\n\nFórmula: P = (casos favorables) / (casos totales)\n\nEjemplo: en una bolsa con 3 bolas rojas y 5 azules,\nP(roja) = 3/8. Simplifica si puedes.':
      'Gertaera bat gertatzeko aukera.\n\nFormulea: gertaera onuragarriak / gertaera posible guztiak.\n\nAdibidea: txanpon bati buruz: P(burua) = 1/2.\nDado bati 6 ateratzea: P(6) = 1/6.',
  'En la vida: calcular la probabilidad de que llueva o de ganar un juego.':
      'Bizitzan: jokoetan, eguraldi iragarpenetan.',
  'Convierte la probabilidad de fracción a porcentaje.\n\nFórmula: (numerador ÷ denominador) × 100\n\nEjemplo: P = 3/4 → (3÷4)×100 = 0,75×100 = 75%.':
      'Probabilitatea zatiki gisa adierazi ondoren, hamartar eta ehuneko bihurtu.\n\nAdibidea: P = 1/4 = 0,25 = 25 %.\nP = 3/10 = 0,3 = 30 %.',
  'En la vida: expresar "3 de cada 4" como 75% de probabilidad.':
      'Bizitzan: eguraldiaren euri-probabilitatea ehunekotan.',
  'Suma los dos números.\n\nSi necesitas, puedes usar los dedos o hacer la suma en tu cabeza.\nEs la operación más básica. Tómate tu tiempo.':
      'Bi zenbakiren batuketa.\n\nTrukoa azkarra: zenbakiak deskonposatu hamarrekoen eta unitateen.\n  27 + 35 = (20 + 30) + (7 + 5) = 50 + 12 = 62.',
  'En la vida: contar dinero, sumar objetos, calcular el total de una compra pequeña.':
      'Bizitzan: erosketen kontu azkarrak, denboraren batuketa.',
  'Encuentra el valor de x.\n\nPara despejar x, pasa los números al otro lado del signo =:\n  • si están sumando → pasan restando\n  • si están restando → pasan sumando\n  • si están multiplicando → pasan dividiendo\n\nEjemplo: x + 5 = 12 → x = 12 - 5 → x = 7.':
      'Berdintza batean x bilatu.\n\nForma: a×x + b = c → x = (c − b) / a.\nAdibidea: 3x + 5 = 14 → 3x = 9 → x = 3.\n\nGogoratu: berdintzaren beste aldera doan zenbakia kontrako zeinuarekin doa.',
  'En la vida: calcular cuánto tiempo falta para ahorrar suficiente dinero.':
      'Bizitzan: ezezagun bat ebatzi (zenbat behar dut?).',
  'Calcula la potencia.\n\naⁿ = a × a × a … (n veces)\n\nEjemplo: 2³ = 2 × 2 × 2 = 8.\n\n¡Cuidado! No multipliques base × exponente (2³ ≠ 2×3).':
      'a^b adierazpenak a-ren b biderketa esan nahi du.\n\nAdibidea: 2³ = 2×2×2 = 8.\n5² = 5×5 = 25.\n\nKontuz: 2³ EZ da 2×3 = 6. Hori akats ohikoa da.',
  'En la vida: calcular áreas (3² = 9) o crecimiento exponencial (doblar cada día).':
      'Bizitzan: azalerak (m²), bolumenak (m³), informatika (bit, byte).',
  'Calcula la raíz cuadrada.\n\n√x es el número que multiplicado por sí mismo da x.\n\nEjemplo: √25 = 5 porque 5 × 5 = 25.\n\nPista: aprende los cuadrados perfectos (1, 4, 9, 16, 25, 36…).':
      '√n: zer zenbaki biderkatu bere buruaz n ematen du?\n\nAdibideak:\n  √16 = 4 (4×4 = 16)\n  √25 = 5 (5×5 = 25)\n  √49 = 7 (7×7 = 49)\n\nMemorizatu √1-√100 lehen erro karratuak.',
  'En la vida: calcular el lado de un cuadrado a partir de su área.':
      'Bizitzan: koadro baten aldea bere azaleratik abiatuta.',
  'En un triángulo rectángulo:\n\nhipotenusa² = cateto₁² + cateto₂²\n\nIdentifica primero la hipotenusa (el lado más largo, frente al ángulo recto).\nDespués aplica la fórmula.':
      'Triangelu zuzen batean: a² + b² = c²\n\n(a eta b kateakak; c hipotenusa).\n\nAdibidea: a=3, b=4 → c² = 9+16 = 25 → c = 5.\nTerna ezagunak: (3,4,5), (5,12,13), (8,15,17).',
  'En la vida: calcular la altura de una escalera apoyada en la pared.':
      'Bizitzan: distantziak kalkulatu, eskailera baten luzera.',
  'La x aparece a los dos lados del signo =. Para despejarla, junta todas las x en un lado y todos los números en el otro.\n\nRegla de oro: lo que cruza el = cambia de papel. Lo que estaba sumando cruza restando. Lo que multiplicaba cruza dividiendo. Y al revés.\n\nPasos, con ejemplo:  3x + 2 = x + 8\n\n  1) Cruza la x de la derecha al lado izquierdo (entra como −x).\n     3x − x + 2 = 8 → 2x + 2 = 8.\n\n  2) Cruza el +2 al lado derecho (entra como −2).\n     2x = 8 − 2 → 2x = 6.\n\n  3) El 2 está multiplicando a x: cruza dividiendo.\n     x = 6 ÷ 2 = 3.\n\nComprueba: 3·3 + 2 = 11 y 3 + 8 = 11. ¡Coincide!':
      'x berdintza zeinuaren bi aldeetan agertzen da. x kentzeko, x guztiak alde batean eta zenbaki guztiak bestean.\n\nUrrezko erregela: berdintzatik zeharkatzen duenak rola aldatzen du. Batzen ari zenak kentzen igarotzen du. Biderkatzen ari zenak zatitzen igarotzen du. Eta alderantziz.\n\nUrratsak, adibidearekin:  3x + 2 = x + 8\n\n  1) x eskubikoa ezkerrera zeharkatu (−x bezala sartzen da).\n     3x − x + 2 = 8 → 2x + 2 = 8.\n\n  2) +2 eskubira zeharkatu (−2 bezala sartzen da).\n     2x = 8 − 2 → 2x = 6.\n\n  3) 2 x biderkatzen ari da: zatitzen zeharkatu.\n     x = 6 ÷ 2 = 3.\n\nEgiaztatu: 3·3 + 2 = 11 eta 3 + 8 = 11. Bat dator!',
  'En la vida: problemas donde una cantidad aparece dos veces, como comparar tu edad con la de alguien de tu familia.':
      'Bizitzan: kantitate bat birritan agertzen den arazoak, adibidez familia bateko adinak konparatu.',
  'Opera con números enteros que pueden tener signo negativo.\n\nRecuerda: -(-3) = +3  y  -3 × -2 = +6\n          -3 + (-2) = -5  y  -3 - (-2) = -1\n\nDos negativos seguidos se convierten en positivo.':
      'Zeinudun zenbakiak: positiboak (+) eta negatiboak (−).\n\nBatuketa eta kenketa:\n  +3 + (+2) = +5\n  +3 + (−2) = +1\n  −3 + (−2) = −5\n\nZeinu berekoak: balioak batu eta zeinua mantendu.\nZeinu desberdinekoak: balioak kendu eta handienaren zeinua hartu.',
  'En la vida: temperaturas bajo cero, deber dinero, profundidad marina.':
      'Bizitzan: tenperaturak (−5 °C), zorrak (−10 €), itsas mailaren gainetik/azpitik.',
  'El valor absoluto de un número es su distancia hasta el 0.\n\n|5| = 5 y |-5| = 5 — ambos están a 5 unidades del 0.\n\nEl valor absoluto siempre es positivo o cero.':
      'Zenbaki baten balio absolutua zerotik duen distantzia da; beti positiboa.\n\nAdibideak:\n  |5| = 5\n  |−5| = 5\n  |0| = 0\n\nNotazioa: |x|.',
  'En la vida: medir distancia entre dos puntos (da igual la dirección).':
      'Bizitzan: bi tenperaturen arteko aldea, distantziak.',
  'Dos ecuaciones con dos incógnitas (x e y) que se cumplen a la vez. La pareja (x, y) que las satisface las dos es la solución del sistema.\n\nMétodo de sustitución, paso a paso:\n  1) Coge la ecuación más sencilla y despeja una incógnita.\n  2) Sustituye su valor en la otra ecuación.\n  3) Resuelve esa ecuación, que ahora solo tiene una incógnita.\n  4) Vuelve atrás con ese valor y calcula la otra.\n\nEjemplo:\n   x + y = 7\n   x − y = 1\n\n  De la 1.ª despejo:  x = 7 − y.\n  Sustituyo en la 2.ª:  (7 − y) − y = 1 → 7 − 2y = 1 → y = 3.\n  Vuelvo:  x = 7 − 3 = 4.\n  Solución: x = 4, y = 3.':
      'Bi ekuazio bi ezezagunekin (x eta y), aldi berean betetzen direnak. Biak betetzen dituen (x, y) bikotea sistemaren irtenbidea da.\n\nOrdezkapen metodoa, urratsez urrats:\n  1) Hartu errazena den ekuazioa eta ezezagun bat ebaki.\n  2) Bere balioa beste ekuazioan ordezkatu.\n  3) Ebatzi ekuazio hori, orain ezezagun bakar bat duena.\n  4) Itzuli balio horrekin eta beste ezezaguna kalkulatu.\n\nAdibidea:\n   x + y = 7\n   x − y = 1\n\n  1.etik ebaki:  x = 7 − y.\n  2.ean ordezkatu:  (7 − y) − y = 1 → 7 − 2y = 1 → y = 3.\n  Itzuli:  x = 7 − 3 = 4.\n  Irtenbidea: x = 4, y = 3.',
  'En la vida: dos manzanas y una naranja cuestan 5 €; una manzana y una naranja cuestan 3 €. ¿Cuánto vale cada fruta?':
      'Bizitzan: bi sagar eta laranja bat 5 € balio dute; sagar bat eta laranja bat 3 €. Zenbat balio du fruta bakoitzak?',
  'Verás una tabla con pares (x, y). Tu trabajo es encontrar la regla que dice cómo se obtiene cada y a partir de su x.\n\nLa regla siempre tiene la forma:  y = m·x + n.\n\nPara descubrirla:\n  1) Cuánto sube y cuando x sube de 1 en 1. Eso es m.\n     Mira dos filas seguidas: m = (y₂ − y₁) ÷ (x₂ − x₁).\n  2) Cuánto vale y cuando x = 0. Eso es n.\n     Si esa fila no aparece, despeja con cualquier fila:\n     n = y − m·x.\n\nAntes de elegir, prueba la regla con otra fila de la tabla.':
      '(x, y) bikoteen taula bat ikusiko duzu. Zure lana y bakoitza bere x-tik nola lortzen den arau bat aurkitzea.\n\nArauak beti forma hau du:  y = m·x + n.\n\nHori aurkitzeko:\n  1) Zenbat igotzen den y, x banaka igotzean. Hori da m.\n     Bi lerro segidakoak begiratu: m = (y₂ − y₁) ÷ (x₂ − x₁).\n  2) Zenbat balio duen y x = 0 denean. Hori da n.\n     Lerro hori ez bada agertzen, ebakitzen lerro bat erabiliz:\n     n = y − m·x.\n\nAukeratu aurretik, proba ezazu araua taularen beste lerro batekin.',
  'En la vida: la factura de la luz — n es la cuota fija que pagas cada mes, m es lo que cuesta cada kWh consumido.':
      'Bizitzan: argi-faktura — n da hilero ordaintzen duzun kuota finkoa, m kWh kontsumitutako bakoitzaren kostua.',
  // Encargo del día (doc 16, eje D): línea del mapa, diálogo de Sora
  // y cierre sobrio en el cazadero. Los tokens {n} y {distrito} se
  // sustituyen DESPUÉS de traducir — el orden de palabras es libre.
  'Encargo de Sora: {n} Fragmentos en {distrito}':
      'Soraren mandatua: {n} Zati — {distrito}',
  'Encargo de Sora: {n} Fragmentos donde tú quieras':
      'Soraren mandatua: {n} Zati, nahi duzun tokian',
  'Encargo de hoy: hecho.': 'Gaurko mandatua: eginda.',
  'El encargo del día': 'Eguneko mandatua',
  'He visto {n} Fragmentos en {distrito}. Si te apetece, tráemelos. Si no, mañana habrá otro.':
      '{n} Zati ikusi ditut {distrito} inguruan. Nahi baduzu, ekar iezazkidazu. Bestela, bihar beste bat egongo da.',
  'Hoy me valen {n} Fragmentos de donde sea. Si te apetece, tráemelos. Si no, mañana habrá otro.':
      'Gaur nonahiko {n} Zatik balio didate. Nahi baduzu, ekar iezazkidazu. Bestela, bihar beste bat egongo da.',
  'Hecho. Mañana habrá otro.': 'Eginda. Bihar beste bat egongo da.',
  'El encargo de hoy está hecho. Bien.':
      'Gaurko mandatua eginda dago. Ongi.',
  'VALE': 'ADOS',
  // El taller de Rexán (doc 16, eje B): pantalla, nodo del mapa,
  // nombres de las 21 piezas y líneas de Rexán.
  'El taller de Rexán': 'Rexánen tailerra',
  'Taller': 'Tailerra',
  'Trae esquirlas. Yo pongo las manos.':
      'Ekarri ezpalak. Nik eskuak jarriko ditut.',
  '¿Restaurar {pieza} por {precio} esquirlas?':
      '{pieza} berritu {precio} ezpalen truke?',
  'Te faltan esquirlas. Los Fragmentos de ahí fuera llevan unas cuantas.':
      'Ezpalak falta zaizkizu. Kanpoko Zatiek badaramatzate batzuk.',
  'RESTAURAR': 'BERRITU',
  'CANCELAR': 'UTZI',
  'Una luz más. La ciudad lo nota, aunque no lo diga.':
      'Argi bat gehiago. Hiriak nabaritzen du, esan ez arren.',
  'Alguien vive mejor esta noche. Buen trabajo.':
      'Norbaitek hobeto biziko du gaua. Lan ona.',
  'Mira eso. Casi parece fiesta. Casi.':
      'Begira hori. Ia jaia dirudi. Ia.',
  'La farola de la esquina': 'Izkinako farola',
  'Las ventanas del ático': 'Ganbarako leihoak',
  'La guirnalda del patio': 'Patioko argi-girlanda',
  'El farolillo del puente': 'Zubiko farolatxoa',
  'Las ventanas del embarcadero': 'Ontziralekuko leihoak',
  'Las luces del canal': 'Kanaleko argiak',
  'El farol de la entrada': 'Sarrerako farola',
  'Las ventanas del almacén': 'Biltegiko leihoak',
  'La guirnalda de los toldos': 'Olanetako argi-girlanda',
  'La lámpara del taller viejo': 'Tailer zaharreko lanpara',
  'Las ventanas de la nave': 'Nabeko leihoak',
  'Las luces de la pasarela': 'Pasabideko argiak',
  'El farol del muelle': 'Moilako farola',
  'Las ventanas de la lonja': 'Lonjako leihoak',
  'Las luces del espigón': 'Kai-muturreko argiak',
  'El farol del sendero': 'Bidezidorreko farola',
  'Las ventanas de la granja': 'Baserriko leihoak',
  'Las luces del observatorio': 'Behatokiko argiak',
  'La lámpara del refugio': 'Aterpeko lanpara',
  'Las ventanas de la estación': 'Geltokiko leihoak',
  'Las luces de la senda alta': 'Goiko bideko argiak',
  // Raros de clima (doc 16, eje E): líneas de Sora en el cazadero y
  // entradas del Cuaderno. Nombres traducidos como los distritos.
  'Espera. Ese brillo no es normal. Ve.':
      'Itxaron. Distira hori ez da normala. Zoaz.',
  'Ahí. En el agua. No parpadees.': 'Hor. Uretan. Ez kliskatu begirik.',
  'Esa luz entre la niebla no es del faro. Ve.':
      'Laino arteko argi hori ez da itsasargiarena. Zoaz.',
  'Mira. Flota distinto que los demás. Corre.':
      'Begira. Besteek ez bezala flotatzen du. Korri.',
  '«La Veleta». Solo baja cuando llueve en los Tejados. Irune querrá saberlo — mira el cuaderno.':
      '«Haize-orratza». Teilatuetan euria ari duenean bakarrik jaisten da. Irunek jakin nahiko du — begiratu koadernoa.',
  '«El Reflejo». Vive en la niebla de los Canales. Casi nadie lo ha visto dos veces. Apúntalo en el cuaderno.':
      '«Isla». Kanaletako lainoan bizi da. Ia inork ez du bi aldiz ikusi. Apuntatu koadernoan.',
  '«La Lucerna». Los del Puerto juran que guía barcos perdidos. Ahora está en tu cuaderno.':
      '«Kriseilua». Portukoek zin egiten dute itsasontzi galduak gidatzen dituela. Orain zure koadernoan dago.',
  '«El Vilano». Solo se deja ver cuando llueve en las Afueras, y allí casi nunca llueve. Al cuaderno.':
      '«Lumatxa». Kanpoaldean euria ari duenean bakarrik agertzen da, eta han ia inoiz ez du euririk egiten. Koadernora.',
  'Se ha ido. Volverá con este cielo.':
      'Joan da. Zeru honekin itzuliko da.',
  'La Veleta': 'Haize-orratza',
  'El Reflejo': 'Isla',
  'La Lucerna': 'Kriseilua',
  'El Vilano': 'Lumatxa',
  'Solo baja a los Tejados cuando llueve. Gira despacio sobre sí misma, como si buscara de dónde viene el viento — o de dónde vino la Rotura. Los cazadores viejos dicen que verla da suerte. Sora dice que la suerte no existe, pero esa noche silbó de vuelta a casa.':
      'Teilatuetara euria ari duenean bakarrik jaisten da. Poliki biratzen da bere buruaren gainean, haizea nondik datorren bilatuko balu bezala — edo Haustura nondik etorri zen. Ehiztari zaharrek diote hura ikusteak zortea dakarrela. Sorak dio zortea ez dela existitzen, baina gau hartan txistuka itzuli zen etxera.',
  'Vive en la niebla de los Canales, pegado al agua. No flota: se refleja. Lo raro es que a veces el agua lo muestra y el aire no. Maren Olbéa le dedicó una carta al director hace años preguntando si alguien más lo había visto. Nadie contestó. Tú sí lo has visto.':
      'Kanaletako lainoan bizi da, uretik gertu. Ez du flotatzen: islatu egiten da. Bitxiena da batzuetan urak erakusten duela eta aireak ez. Maren Olbéak gutun bat idatzi zion zuzendariari duela urteak, beste inork ikusi ote zuen galdezka. Inork ez zuen erantzun. Zuk bai ikusi duzu.',
  'Una luz pequeña que camina por la niebla del Puerto, a la altura de los mástiles. Los estibadores juran que guía a los barcos que se pierden — y que por eso el faro no la espanta. Irune sospecha que es más vieja que el faro. Quizá más vieja que el Puerto.':
      'Argi txiki bat Portuko lainoan zehar dabilena, mastaren garaieran. Zamaketariek zin egiten dute galtzen diren itsasontziak gidatzen dituela — eta horregatik itsasargiak ez duela uxatzen. Irunek susmoa du itsasargia baino zaharragoa dela. Agian Portua baino zaharragoa.',
  'En las Afueras casi nunca llueve. Cuando llueve, flota el Vilano: liviano, a contraviento, como una semilla que no quiere aterrizar. Capturarlo es de las cosas más difíciles que puede contar un cazador — no por el puzzle, sino por estar allí el día justo.':
      'Kanpoaldean ia inoiz ez du euririk egiten. Euria ari duenean, Lumatxa flotatzen da: arina, haizearen kontra, lurreratu nahi ez duen hazi bat bezala. Hura harrapatzea da ehiztari batek konta dezakeen gauzarik zailenetakoa — ez puzzleagatik, egun egokian han egoteagatik baizik.',
  // Secretos espaciales (doc 16, eje E).
  'Ahí vive el gato de Irune. No se lo digas a nadie.':
      'Hor bizi da Iruneren katua. Ez esan inori.',
  'Ese farolillo lleva años sin luz. Hasta ahora, parece.':
      'Farolatxo horrek urteak daramatza argirik gabe. Orain arte, dirudienez.',
  'La ventana del gato': 'Katuaren leihoa',
  'El farolillo apagado': 'Farolatxo itzalia',
  'Una ventana concreta de los Tejados, siempre encendida. Ahí vive el gato de Irune, que no se llama de ninguna manera porque Irune dice que los nombres son para quien acude cuando lo llaman. El gato la ignora desde hace nueve años. Tocaste su ventana y no pasó nada. O eso parece.':
      'Teilatuetako leiho jakin bat, beti piztuta. Hor bizi da Iruneren katua, izenik ez duena, Irunek dioelako izenak deitzean datozenentzat direla. Katuak bederatzi urte daramatza hari jaramonik egin gabe. Bere leihoa ukitu zenuen eta ez zen ezer gertatu. Edo hala dirudi.',
  'En el puente bajo de los Canales hay un farolillo que no se enciende desde antes de la Rotura. Los fareros lo saltan al hacer la ronda, por respeto o por costumbre. Lo tocaste. Sora jura que esa noche parpadeó una vez. Rexán dice que Sora exagera. Ninguno de los dos volvió a pasar por el puente sin mirarlo.':
      'Kanaletako zubi baxuan bada farolatxo bat Haustura baino lehenagotik pizten ez dena. Farolariek saltatu egiten dute erronda egitean, errespetuz edo ohituraz. Ukitu egin zenuen. Sorak zin egiten du gau hartan behin kliskatu zuela. Rexánek dio Sorak puzten duela. Bietako inor ez zen berriro zubitik pasa hari begiratu gabe.',
  // Bestiario (doc 16, eje C): fichas de familias de Fragmentos.
  // ('Los Plenos' ya está traducido arriba, con las escenas.)
  'Los Comparadores': 'Konparatzaileak',
  'Los Espejos': 'Ispiluak',
  'Los Impropios': 'Inpropioak',
  'Los Duales': 'Dualak',
  'Las Comas': 'Komak',
  'Tejados y Canales': 'Teilatuak eta Kanalak',
  'Canales y Mercado': 'Kanalak eta Merkatua',
  'Canales e Industria': 'Kanalak eta Industria',
  'Común': 'Arrunta',
  'Inusual': 'Ezohikoa',
  'La forma más simple de Fragmento: un círculo entero que se cree indivisible. Se caza cortándolo en partes iguales. Los primeros que verás.':
      'Zatirik sinpleena: zatiezina dela uste duen zirkulu oso bat. Zati berdinetan ebakiz ehizatzen da. Ikusiko dituzun lehenak.',
  'No huyen casi nunca. Sora dice que es porque no saben que están rotos — cada Pleno se cree el Uno entero, y esperar no cuesta nada cuando te crees eterno.':
      'Ia inoiz ez dute ihes egiten. Sorak dio hautsita daudela ez dakitelako dela — Oso bakoitzak bere burua Bat osotzat du, eta itxaroteak ez du ezer kostatzen betiereko sentitzen zarenean.',
  'Irune guarda el primer Pleno que desfragmentó, dibujado a lápiz en la última página de su cuaderno. Debajo escribió: "No era grande. Era mío."':
      'Irunek gordeta du desfragmentatu zuen lehen Osoa, arkatzez marraztuta bere koadernoaren azken orrialdean. Azpian idatzi zuen: "Ez zen handia. Nirea zen."',
  'Aparecen de dos en dos o de tres en tres, nunca solos. Uno siempre vale más que otro, aunque no lo parezca — cazarlos es saber cuál.':
      'Binaka edo hirunaka agertzen dira, inoiz ez bakarrik. Batek beti balio du besteak baino gehiago, hala ez badirudi ere — ehizatzea zein den jakitea da.',
  'Las parejas engañan a los ojos: la fracción con números grandes puede ser la pequeña. Los cazadores novatos caen. Tú caíste. Todos caímos.':
      'Bikoteek begiak engainatzen dituzte: zenbaki handiko zatikia txikiena izan daiteke. Ehiztari hasiberriak erortzen dira. Zu erori zinen. Denok erori ginen.',
  'Hay una teoría en la redacción del Faro: los Comparadores no son varios Fragmentos, sino uno solo que se mira. Nadie la ha podido desmentir.':
      'Teoria bat dago Faroko erredakzioan: Konparatzaileak ez dira hainbat Zati, bere buruari begiratzen dion bakar bat baizik. Inork ezin izan du gezurtatu.',
  'Cada Espejo tiene infinitas caras: 1/2, 2/4, 3/6… Todas valen lo mismo. Cazarlo es reconocerlo aunque venga disfrazado.':
      'Ispilu bakoitzak aurpegi infinituak ditu: 1/2, 2/4, 3/6… Denek berdin balio dute. Ehizatzea mozorrotuta etorri arren ezagutzea da.',
  'Se amplifican y se simplifican a voluntad, como quien se cambia de abrigo. La forma mínima es su cara verdadera — la única que no pueden quitarse.':
      'Nahieran anplifikatzen eta sinplifikatzen dira, berokia aldatzen duenaren moduan. Forma minimoa da haien benetako aurpegia — kendu ezin duten bakarra.',
  'En los Canales dicen que si ves las dos caras de un Espejo en el agua a la vez, el reflejo se queda contigo. Pregúntale a El Reflejo, si lo encuentras.':
      'Kanaletan diote Ispilu baten bi aurpegiak uretan aldi berean ikusten badituzu, isla zurekin geratzen dela. Galdetu Islari, aurkitzen baduzu.',
  'Fragmentos con el numerador más grande que el denominador: llevan más de un entero dentro. Caminan raro, como sobrecargados.':
      'Zenbakitzailea izendatzailea baino handiagoa duten Zatiak: oso bat baino gehiago daramate barruan. Arraro dabiltza, gainkargatuta bezala.',
  'Se pueden reescribir como número mixto — el entero delante, el resto en fracción. No les gusta. Ningún Impropio admite que en el fondo es un dos y pico.':
      'Zenbaki misto gisa berridatz daitezke — osoa aurrean, gainerakoa zatikian. Ez zaie gustatzen. Inpropio batek ere ez du onartzen funtsean bi eta piku bat dela.',
  'Vorax era un Impropio antiguo que nunca dejó que lo reescribieran. Lo que guardaba dentro ya lo viste. O lo verás.':
      'Vorax Inpropio zahar bat zen, inoiz berridazten utzi ez zuena. Barruan gordetzen zuena ikusi duzu jada. Edo ikusiko duzu.',
  'Dos Fragmentos unidos por una línea de luz que no se puede cortar. Para cazarlos hay que hacerlos hablar el mismo idioma: mismo denominador.':
      'Ebaki ezin den argi-lerro batek lotutako bi Zati. Ehizatzeko hizkuntza bera hitz egitera behartu behar dira: izendatzaile bera.',
  'La línea que los une no es una cadena — es una operación. Sumar, restar, multiplicar. Resuélvela y la luz se apaga sola.':
      'Lotzen dituen lerroa ez da kate bat — eragiketa bat da. Batu, kendu, biderkatu. Ebatzi eta argia berez itzaltzen da.',
  'Zafrán es el Dual más viejo que se conoce. No habla. Sora cree que los dos extremos discutieron hace siglos y desde entonces guardan silencio.':
      'Zafrán da ezagutzen den Dualik zaharrena. Ez du hitz egiten. Sorak uste du bi muturrek duela mendeak eztabaidatu zutela eta ordutik isilik daudela.',
  'Fragmentos que se escriben con coma: 0,5 · 2,37 · 0,825. Parecen exactos y presumen de ello. Son fracciones con uniforme de trabajo.':
      'Komaz idazten diren Zatiak: 0,5 · 2,37 · 0,825. Zehatzak dirudite eta harro daude. Laneko uniformea daramaten zatikiak dira.',
  'Su trampa favorita: aparentar que más cifras es más valor. 0,35 se pavonea delante de 0,4 y pierde. Lee las cifras, no las cuentes.':
      'Haien tranparik gogokoena: zifra gehiago balio handiagoa dela itxuratzea. 0,35 harrotu egiten da 0,4ren aurrean eta galdu egiten du. Irakurri zifrak, ez kontatu.',
  'En Industria las Comas se alinean solas junto a las máquinas de Vadic, décima con décima, centésima con centésima. Nadie las ha entrenado. A Vadic le inquieta.':
      'Industrian Komak berez lerrokatzen dira Vadicen makinen ondoan, hamarren hamarrenarekin, ehunen ehunenarekin. Inork ez ditu entrenatu. Vadic kezkatzen du.',
  // Balanza de comparación (doc 16, eje A — piloto Fase D3).
  'Arrastra hacia abajo el platillo que pese más.':
      'Arrastatu behera gehien pisatzen duen platertxoa.',
  // Ángulo manipulativo (doc 16, eje A — piloto Fase D3). De paso,
  // las categorías de MED.04 que la pantalla clásica dejaba sin
  // traducir (caían al castellano).
  'agudo': 'zorrotza',
  'recto': 'zuzena',
  'obtuso': 'kamutsa',
  'llano': 'laua',
  'completo': 'osoa',
  'Gira el brazo hasta formar un ángulo {tipo}.':
      'Biratu besoa angelu {tipo} bat osatu arte.',
  'Arrastra el brazo del ángulo y pulsa ASÍ cuando lo tengas.':
      'Arrastatu angeluaren besoa eta sakatu HORRELA duzunean.',
  'ASÍ': 'HORRELA',
  'Agudo: menos de 90°.': 'Zorrotza: 90° baino gutxiago.',
  'Recto: 90° exactos.': 'Zuzena: 90° zehatz.',
  'Obtuso: entre 90° y 180°.': 'Kamutsa: 90° eta 180° artean.',
  'Llano: 180° exactos.': 'Laua: 180° zehatz.',
  'Completo: 360°.': 'Osoa: 360°.',
  // Cortar la tarta (FR.07 manipulativo, doc 16 eje A).
  'Sirve cada fracción: pasa el dedo alrededor de su tarta.':
      'Zerbitzatu zatiki bakoitza: pasatu hatza bere tartaren inguruan.',
  'Ahora toca la tarta que tiene más.': 'Orain ukitu gehiago duen tarta.',
  // Máquinas de Rexán y Puentes (minijuegos)
  'Máquinas':
      'Makinak',
  'Las máquinas de Rexán':
      'Rexánen makinak',
  'Las saqué de los recreativos del Puerto. Funcionan con cabeza, no con monedas.':
      'Portuko jolas-aretotik atera nituen. Buruarekin dabiltza, ez txanponekin.',
  'Rexán todavía la está arreglando. Sigue cazando Fragmentos.':
      'Rexán oraindik konpontzen ari da. Jarraitu Zatiak ehizatzen.',
  'Puentes':
      'Zubiak',
  'Encaje':
      'Txertaketa',
  'Canales':
      'Kanalak',
  'Cubre el hueco con tablones. El carro sólo cruza si la medida es exacta.':
      'Estali hutsunea oholekin. Orgak neurria zehatza denean bakarrik gurutzatzen du.',
  'Tablones sueltos del Puerto. Si no llegan justos, el carro no pasa. Mide antes.':
      'Portuko ohol solteak. Zehatz iristen ez badira, orga ez da pasatzen. Neurtu lehenago.',
  'Caen trozos de fracción. Cada fila completa es una unidad entera.':
      'Zatiki-zatiak erortzen dira. Errenkada oso bakoitza unitate oso bat da.',
  'Una máquina vieja de los recreativos. Cada fila llena es un uno. Con eso basta.':
      'Jolas-aretoko makina zahar bat. Errenkada bete bakoitza bat da. Horrekin nahikoa.',
  'Recorre el laberinto y cómete sólo los números que cumplen la regla.':
      'Ibili labirintoan eta jan araua betetzen duten zenbakiak bakarrik.',
  'Las sombras de los Canales son lentas. Tú eliges qué números recoges.':
      'Kanaletako itzalak geldoak dira. Zuk aukeratzen duzu zein zenbaki biltzen dituzun.',
  'PROBAR EL PUENTE':
      'ZUBIA PROBATU',
  'En el puente':
      'Zubian',
  'Tablones':
      'Oholak',
  'Toca un tablón de abajo para ponerlo.':
      'Ukitu beheko ohol bat jartzeko.',
  'Justo. El carro pasa.':
      'Zehatz. Orga pasatzen da.',
  'Falta un trozo: el carro se para en el borde.':
      'Zati bat falta da: orga ertzean gelditzen da.',
  'Sobra: el último tablón no encaja.':
      'Soberan dago: azken oholak ez du sartzen.',
  'Otro hueco. Mismas reglas.':
      'Beste hutsune bat. Arau berak.',
  'Cinco puentes. Por hoy el Puerto está servido. Vuelve mañana si te apetece.':
      'Bost zubi. Gaurko, Portua zerbitzatuta dago. Itzuli bihar nahi baduzu.',
  // Encaje (minijuego)
  'Siguiente':
      'Hurrengoa',
  'SOLTAR':
      'ASKATU',
  'faltan':
      'falta dira',
  'Se ha llenado. Lo vacío y seguimos.':
      'Bete egin da. Hustu egingo dut eta jarraituko dugu.',
  'Un uno.':
      'Bat.',
  'Seis unidades. La máquina se calienta; mañana más.':
      'Sei unitate. Makina berotu egin da; bihar gehiago.',
  // Canales (minijuego)
  'Sólo múltiplos de {n}.':
      'Multiploak bakarrik: {n}.',
  'Sólo divisibles entre {n}.':
      'Zatigarriak bakarrik. Zatitzailea: {n}.',
  'Sólo números primos.':
      'Zenbaki lehenak bakarrik.',
  'Sólo decimales mayores que 0,5.':
      '0,5 baino handiagoak diren hamartarrak bakarrik.',
  'Sólo fracciones mayores que 1/2.':
      '1/2 baino handiagoak diren zatikiak bakarrik.',
  'Quedan {n}':
      '{n} falta dira',
  'Ese no cumple: {valor}.':
      'Horrek ez du betetzen: {valor}.',
  'Te han pillado. Vuelves a la salida.':
      'Harrapatu zaituzte. Irteerara itzultzen zara.',
  'Laberinto limpio.':
      'Labirintoa garbi.',
  'Lee la regla. Cuando quieras, elige una dirección.':
      'Irakurri araua. Nahi duzunean, aukeratu norabide bat.',
  'Tres laberintos. Las sombras se van a dormir; tú también.':
      'Hiru labirinto. Itzalak lotara doaz; zu ere bai.',
  // Parejas y Minas (minijuegos)
  'Parejas':
      'Bikoteak',
  'Minas':
      'Minak',
  'Toca dos cartas que valgan lo mismo, aunque estén escritas distinto.':
      'Ukitu balio bera duten bi karta, desberdin idatzita egon arren.',
  'Un medio, cero coma cinco, cincuenta por ciento. Tres trajes para la misma persona.':
      'Erdi bat, zero koma bost, ehuneko berrogeita hamar. Hiru jantzi pertsona berarentzat.',
  'Abre las casillas seguras y marca las minas. La regla dice cuáles son.':
      'Ireki gelaxka seguruak eta markatu minak. Arauak esaten du zein diren.',
  'Las minas no se esconden: cumplen la regla. Cada casilla abierta te dice cuántas tiene alrededor.':
      'Minak ez dira ezkutatzen: araua betetzen dute. Irekitako gelaxka bakoitzak inguruan zenbat dituen esaten dizu.',
  'Esas dos no valen lo mismo.':
      'Bi horiek ez dute balio bera.',
  'Tablero limpio.':
      'Taula garbi.',
  'Tres tableros. Ya sabes que una misma cosa tiene muchos nombres.':
      'Hiru taula. Badakizu gauza batek izen asko dituela.',
  'Las minas: múltiplos de {n}.':
      'Minak: {n} zenbakiaren multiploak.',
  'Las minas: divisibles entre {n}.':
      'Minak: zatigarriak. Zatitzailea: {n}.',
  'Las minas: números primos.':
      'Minak: zenbaki lehenak.',
  '{n} no cumple la regla: era segura.':
      '{n} zenbakiak ez du araua betetzen: segurua zen.',
  '{n} cumple la regla: era mina. La desactivo yo.':
      '{n} zenbakiak araua betetzen du: mina zen. Nik desaktibatuko dut.',
  'Tablero despejado.':
      'Taula garbituta.',
  'Tres tableros sin una sola explosión. Así se trabaja.':
      'Hiru taula leherketa bakar bat ere gabe. Horrela egiten da lana.',
  'ABRIR':
      'IREKI',
  'MARCAR':
      'MARKATU',
  // Serpiente, Balanza y La flota (minijuegos)
  'Serpiente':
      'Sugea',
  'Balanza':
      'Balantza',
  'La flota':
      'Flota',
  'Lleva la serpiente hasta el resultado. Los otros números son las trampas de siempre.':
      'Eraman sugea emaitzaraino. Beste zenbakiak betiko tranpak dira.',
  'Una serpiente que come cuentas. No muere nunca: sólo tiene hambre.':
      'Kontuak jaten dituen suge bat. Ez da inoiz hiltzen: gosea besterik ez du.',
  'Prueba un valor para la x y mira hacia dónde se inclina.':
      'Probatu x-rentzako balio bat eta begiratu nora makurtzen den.',
  'Una balanza no miente. Si baja un lado, algo pesa más.':
      'Balantza batek ez du gezurrik esaten. Alde bat jaisten bada, zerbaitek gehiago pisatzen du.',
  'Rexán canta las coordenadas en cálculo. Tú apuntas.':
      'Rexánek koordenatuak kalkulu gisa esaten ditu. Zuk apuntatzen duzu.',
  'Tres barcos escondidos en el Puerto. Yo canto, tú apuntas.':
      'Hiru itsasontzi ezkutatuta Portuan. Nik esan, zuk apuntatu.',
  'Ese no era. Busca otro.':
      'Hori ez zen. Bilatu beste bat.',
  'Cinco. Sigue, que aún tiene hambre.':
      'Bost. Jarraitu, oraindik gose da eta.',
  'Tres rondas. La serpiente se enrosca y duerme.':
      'Hiru txanda. Sugea biribildu eta lo geratzen da.',
  'Lee la cuenta. Cuando quieras, elige una dirección.':
      'Irakurri kontua. Nahi duzunean, aukeratu norabide bat.',
  'Equilibrio. x vale {x}.':
      'Oreka. x-k {x} balio du.',
  'Baja la derecha: con ese valor, la izquierda se queda corta.':
      'Eskuina jaisten da: balio horrekin, ezkerra motz geratzen da.',
  'Baja la izquierda: con ese valor, la izquierda pesa demasiado.':
      'Ezkerra jaisten da: balio horrekin, ezkerrak gehiegi pisatzen du.',
  'Seis ecuaciones, seis equilibrios. La balanza descansa.':
      'Sei ekuazio, sei oreka. Balantzak atseden hartzen du.',
  'PESAR':
      'PISATU',
  'Agua.':
      'Ura.',
  '¡Tocado!':
      'Jo dut!',
  'Hundido.':
      'Hondoratuta.',
  'Era la casilla {dato}. Disparo ahí.':
      '{dato} gelaxka zen. Hara tiro egiten dut.',
  'Flota hundida. Otra más, mar adentro.':
      'Flota hondoratuta. Beste bat, itsasoan barrura.',
  'Dos flotas al fondo. El Puerto vuelve a estar en calma.':
      'Bi flota hondoan. Portua lasai dago berriro.',
  'Columna':
      'Zutabea',
  'Fila':
      'Errenkada',
  // Versión web
  'La foto de tu personaje sólo se puede poner en la app del móvil.':
      'Zure pertsonaiaren argazkia mugikorreko app-an bakarrik jar daiteke.',
  // Salto (minijuego)
  'Salto':
      'Jauzia',
  'El Fragmento corre solo. Toca para saltar y elige la puerta del resultado: arriba o abajo.':
      'Zatia bakarrik doa korrika. Ukitu jauzi egiteko eta aukeratu emaitzaren atea: goian edo behean.',
  'Esta no para. Tú sólo decides cuándo saltar… y por qué puerta.':
      'Honek ez du gelditzen. Zuk bakarrik erabakitzen duzu noiz jauzi egin… eta zein atetatik.',
  'Esa puerta no era. Desde la marca.':
      'Ate hori ez zen. Markatik berriro.',
  'Otra vez desde la marca.':
      'Berriro markatik.',
  'Cinco puertas. Sigue, que la noche es larga.':
      'Bost ate. Jarraitu, gaua luzea da eta.',
  'Quince puertas. El Fragmento se para a mirar la ciudad.':
      'Hamabost ate. Zatia gelditu egiten da hiriari begira.',
  'Toca para empezar. Toca para saltar.':
      'Ukitu hasteko. Ukitu jauzi egiteko.',
  // Ayudas de las máquinas
  'CÓMO SE JUEGA':
      'NOLA JOKATZEN DEN',
  'EL TRUCO':
      'TRIKIMAILUA',
  'Ayuda':
      'Laguntza',
  'AYÚDAME PASO A PASO':
      'LAGUNDU URRATSEZ URRATS',
  'SIGUIENTE PASO':
      'HURRENGO URRATSA',
  'VOLVER A LA BALANZA':
      'BALANTZARA ITZULI',
  'Quita {n} bolsa(s) de cada lado: la balanza sigue igual.':
      'Kendu {n} poltsa alde bakoitzetik: balantza berdin dago.',
  'Quita {n} pesa(s) de cada lado: sigue en equilibrio.':
      'Kendu {n} pisu alde bakoitzetik: orekan jarraitzen du.',
  'Reparte las pesas entre las bolsas: cada bolsa pesa {n}.':
      'Banatu pisuak poltsen artean: poltsa bakoitzak {n} pisatzen du.',
  'Una bolsa sola frente a {n} pesas: x vale {n}.':
      'Poltsa bakarra {n} pisuren aurrean: x = {n}.',
  'Toca los tablones para ponerlos en el puente; tócalos otra vez para quitarlos. Cuando creas que cubren el hueco justo, pulsa PROBAR EL PUENTE.':
      'Ukitu oholak zubian jartzeko; ukitu berriro kentzeko. Hutsunea zehazki betetzen dutela uste duzunean, sakatu ZUBIA PROBATU.',
  'Arrastra el dedo por el tablero para mover la barra y toca para soltarla. Cada fila llena es una unidad: busca las piezas que completan lo que falta.':
      'Arrastatu hatza taulan barra mugitzeko eta ukitu askatzeko. Errenkada bete bakoitza unitate bat da: bilatu falta dena osatzen duten piezak.',
  'Desliza el dedo o usa la cruceta. Recoge sólo los números que cumplen la regla y aléjate de las sombras: si te pillan, vuelves a la salida.':
      'Irristatu hatza edo erabili gurutzea. Bildu araua betetzen duten zenbakiak bakarrik eta urrundu itzaletatik: harrapatzen bazaituzte, irteerara itzultzen zara.',
  'Toca dos cartas que valgan lo mismo aunque estén escritas distinto. Si lo son, se retiran.':
      'Ukitu berdin balio duten bi karta, desberdin idatzita egon arren. Hala badira, kendu egiten dira.',
  'Con ABRIR tocas las casillas seguras; con MARCAR (o dejando el dedo) marcas las minas. La regla dice qué números son minas. El número pequeño de cada casilla abierta cuenta las minas vecinas.':
      'IREKI-rekin lauki seguruak ukitzen dituzu; MARKATU-rekin (edo hatza utzita) minak markatzen dituzu. Arauak dio zein zenbaki diren minak. Lauki ireki bakoitzeko zenbaki txikiak ondoko minak zenbatzen ditu.',
  'Desliza el dedo o usa la cruceta. Lleva la serpiente al número que resuelve la cuenta. Los bordes se atraviesan.':
      'Irristatu hatza edo erabili gurutzea. Eraman sugea kalkulua ebazten duen zenbakira. Ertzak zeharkatu egin daitezke.',
  'Elige un valor para la x con − y + y pulsa PESAR. Si baja un lado, ese pesa más. Con AYÚDAME PASO A PASO ves cómo se despeja.':
      'Aukeratu x-rentzat balio bat − eta + botoiekin eta sakatu PISATU. Alde bat jaisten bada, horrek pisu gehiago du. LAGUNDU URRATSEZ URRATS botoiarekin ikusiko duzu nola askatzen den.',
  'Calcula la columna y la fila que canta Rexán y toca esa casilla. Hunde los tres barcos.':
      'Kalkulatu Rexanek esaten duen zutabea eta errenkada eta ukitu lauki hori. Hondoratu hiru itsasontziak.',
  'Toca para saltar. Esquiva pinchos, cajas y fosos. Antes de cada puerta decide: si la respuesta está arriba, salta a la plataforma; si está abajo, sigue por el suelo. En el último nivel, algunas cuentas usan el resultado de la puerta anterior.':
      'Ukitu jauzi egiteko. Saihestu arantzak, kutxak eta zuloak. Ate bakoitzaren aurretik erabaki: erantzuna goian badago, jauzi plataformara; behean badago, jarraitu lurretik. Azken mailan, kalkulu batzuek aurreko atearen emaitza erabiltzen dute.',
  'Suma primero las decenas y luego las unidades: 38 + 25 = 50 + 13 = 63.':
      'Batu lehenik hamarrekoak eta gero batekoak: 38 + 25 = 50 + 13 = 63.',
  'Primero multiplicaciones y divisiones; luego sumas y restas. Lo que va entre paréntesis, antes que nada.':
      'Lehenik biderketak eta zatiketak; gero batuketak eta kenketak. Parentesi artean dagoena, beste ezer baino lehen.',
  'La potencia repite la multiplicación: 5² = 5 × 5 = 25. No es 5 × 2.':
      'Berreturak biderketa errepikatzen du: 5² = 5 × 5 = 25. Ez da 5 × 2.',
  'Para 3/4 de 20: divide 20 entre 4 (sale 5) y multiplica por 3 (sale 15).':
      '20ren 3/4 kalkulatzeko: zatitu 20 4rekin (5 ateratzen da) eta biderkatu 3rekin (15 ateratzen da).',
  'El 50 % es la mitad; el 25 %, la cuarta parte; el 10 %, dividir entre 10. El 20 % es el doble del 10 %.':
      '% 50 erdia da; % 25, laurdena; % 10, 10ekin zatitzea. % 20 % 10aren bikoitza da.',
  'Con el mismo denominador, se suman los de arriba: 2/5 + 1/5 = 3/5.':
      'Izendatzaile bera dutenean, goikoak batzen dira: 2/5 + 1/5 = 3/5.',
  'Con denominadores distintos, pásalas al mismo: 1/2 + 1/3 = 3/6 + 2/6 = 5/6.':
      'Izendatzaile desberdinekin, eraman izendatzaile berera: 1/2 + 1/3 = 3/6 + 2/6 = 5/6.',
  'Coloca las comas una debajo de otra y suma como siempre: 1,2 + 0,8 = 2,0.':
      'Jarri komak bata bestearen azpian eta batu beti bezala: 1,2 + 0,8 = 2,0.',
  'Dos fracciones valen lo mismo si multiplicas (o divides) arriba y abajo por el mismo número: 1/2 = 2/4 = 3/6.':
      'Bi zatikik berdin balio dute goian eta behean zenbaki beraz biderkatzen (edo zatitzen) baduzu: 1/2 = 2/4 = 3/6.',
  'Para pasar a decimal, divide el de arriba entre el de abajo: 1/4 = 1 ÷ 4 = 0,25.':
      'Hamartarrera pasatzeko, zatitu goikoa behekoarekin: 1/4 = 1 ÷ 4 = 0,25.',
  'Un porcentaje es una fracción sobre 100: 1/4 = 25/100 = 25 %.':
      'Ehunekoa 100en gaineko zatiki bat da: 1/4 = 25/100 = % 25.',
  'Los múltiplos de un número salen de su tabla: 3, 6, 9, 12…':
      'Zenbaki baten multiploak bere taulatik ateratzen dira: 3, 6, 9, 12…',
  'Entre 2: acaba en par. Entre 5: acaba en 0 o 5. Entre 10: acaba en 0.':
      '2rekin: bikoitiz amaitzen da. 5ekin: 0z edo 5ez amaitzen da. 10ekin: 0z amaitzen da.',
  'Entre 4: sus dos últimas cifras son múltiplo de 4. Entre 6: es par y divisible entre 3. Entre 9: sus cifras suman múltiplo de 9.':
      '4rekin: azken bi zifrak 4ren multiploa dira. 6rekin: bikoitia da eta 3rekin zatigarria. 9rekin: zifren batura 9ren multiploa da.',
  'Un primo sólo se divide entre 1 y entre sí mismo. Prueba a dividir entre 2, 3, 5 y 7.':
      'Zenbaki lehena 1ekin eta bere buruarekin bakarrik zatitzen da. Probatu 2, 3, 5 eta 7rekin zatitzen.',
  'Compara cifra a cifra desde la coma: 0,45 < 0,5 porque en las décimas 4 < 5.':
      'Konparatu zifraz zifra komatik hasita: 0,45 < 0,5, hamarrenetan 4 < 5 delako.',
  'Mira la mitad del de abajo: si el de arriba es mayor, la fracción es mayor que 1/2. 5/8: la mitad de 8 es 4 y 5 > 4.':
      'Begiratu behekoaren erdia: goikoa handiagoa bada, zatikia 1/2 baino handiagoa da. 5/8: 8ren erdia 4 da eta 5 > 4.',
  'Haz lo mismo en los dos platillos: quita las pesas sueltas de la izquierda en los dos lados y reparte lo que queda entre las bolsas.':
      'Egin gauza bera bi platerretan: kendu ezkerreko pisu solteak bi aldeetatik eta banatu geratzen dena poltsen artean.',
  'Primero quita bolsas de los dos lados hasta que sólo queden a la izquierda; luego, como siempre.':
      'Lehenik kendu poltsak bi aldeetatik ezkerrean bakarrik geratu arte; gero, beti bezala.',
  // Salto v2: niveles
  'la de antes':
      'aurrekoa',
  'Cinco puertas. Ahora vienen cajas y fosos: salta o súbete encima.':
      'Bost ate. Orain kutxak eta zuloak datoz: jauzi egin edo igo gainera.',
  'Cinco más. Trampolines, más pinchos y cuentas que siguen a la anterior.':
      'Beste bost. Trapolinak, arantza gehiago eta aurrekoarekin jarraitzen duten kalkuluak.',
  // Niveles de las máquinas y pista
  '¿Te echo una mano?':
      'Lagunduko dizut?',
  'Un muro. Gira y sigue.':
      'Horma bat. Biratu eta jarraitu.',
  'Cinco. Ahora hay muros: no hacen daño, pero hay que rodearlos.':
      'Bost. Orain hormak daude: ez dute minik egiten, baina inguratu egin behar dira.',
  'Cinco más. Los números ya no se están quietos.':
      'Beste bost. Zenbakiak ez daude geldi jada.',
  'Desliza el dedo o usa la cruceta. Lleva la serpiente al número que resuelve la cuenta. Los bordes se atraviesan. Desde la segunda ronda hay muros que rodear, y en la tercera los números se mueven.':
      'Irristatu hatza edo erabili gurutzea. Eraman sugea kalkulua ebazten duen zenbakira. Ertzak zeharkatu egin daitezke. Bigarren txandatik aurrera inguratu beharreko hormak daude, eta hirugarrenean zenbakiak mugitu egiten dira.',
  'Tres sombras esta vez. Lee la regla y elige dirección.':
      'Hiru itzal oraingoan. Irakurri araua eta aukeratu norabidea.',
  'Una sombra ya no vaga: te busca. Y hay más números trampa.':
      'Itzal batek ez du noraezean ibiltzen: zure bila dabil. Eta tranpa-zenbaki gehiago daude.',
  'Ahora algunas piezas vienen disfrazadas: 2/4 es 1/2.':
      'Orain pieza batzuk mozorrotuta datoz: 2/4 eta 1/2 berdinak dira.',
  'Más rápido y sin ayudas en el tablero. Tú sabes lo que falta.':
      'Azkarrago eta taulan laguntzarik gabe. Badakizu zer falta den.',
  // Niveles de las máquinas de pensar
  'Sube el nivel: cuentas algo más difíciles.':
      'Maila igotzen da: kalkulu zailxeagoak.',
  'Flota hundida. La siguiente, mar adentro: cuentas más difíciles.':
      'Flota hondoratuta. Hurrengoa, itsasoan barrurago: kalkulu zailagoak.',
  'En este tablero sobra una carta: no tiene pareja. ¿Cuál es?':
      'Taula honetan karta bat soberan dago: ez du bikoterik. Zein da?',
  'Toca dos cartas que valgan lo mismo aunque estén escritas distinto. Si lo son, se retiran. En el último tablero sobra una carta: parece de alguna pareja, pero no vale lo mismo que ninguna.':
      'Ukitu berdin balio duten bi karta, desberdin idatzita egon arren. Hala badira, kendu egiten dira. Azken taulan karta bat soberan dago: bikoteren batekoa dirudi, baina ez du beste ezein kartaren balio bera.',
  // Ejemplos resueltos de la ayuda
  'UN EJEMPLO PARECIDO':
      'ANTZEKO ADIBIDE BAT',
  'OTRO EJEMPLO':
      'BESTE ADIBIDE BAT',
  'Tienen el mismo denominador ({d}): se queda igual.':
      'Izendatzaile bera dute ({d}): berdin geratzen da.',
  'Suma los de arriba: {a} + {b} = {s}.':
      'Batu goikoak: {a} + {b} = {s}.',
  'Resultado: {r}.':
      'Emaitza: {r}.',
  'Busca un denominador que sirva para los dos: {c}.':
      'Bilatu bientzat balio duen izendatzaile bat: {c}.',
  '{f} = {g}, multiplicando arriba y abajo por {m}.':
      '{f} = {g}, goian eta behean {m} zenbakiaz biderkatuta.',
  'Ahora suma los de arriba: {a} + {b} = {s}. Resultado: {r}.':
      'Orain batu goikoak: {a} + {b} = {s}. Emaitza: {r}.',
  'Pon las comas una debajo de otra: son décimas.':
      'Jarri komak bata bestearen azpian: hamarrenak dira.',
  'Suma las décimas: {a} + {b} = {s} décimas.':
      'Batu hamarrenak: {a} + {b} = {s} hamarren.',
  '10 décimas son 1 unidad: {s} décimas = {r}.':
      '10 hamarren unitate 1 dira: {s} hamarren = {r}.',
  'Multiplica arriba y abajo por el mismo número, por ejemplo {m}.':
      'Biderkatu goian eta behean zenbaki beraz, adibidez {m}.',
  'Arriba: {n} × {m} = {a}. Abajo: {d} × {m} = {b}.':
      'Goian: {n} × {m} = {a}. Behean: {d} × {m} = {b}.',
  '{f} y {g} valen lo mismo.':
      '{f} eta {g}: berdin balio dute.',
  '{f} = {g}.':
      '{f} = {g}.',
  'Busca cuánto hay que multiplicar {d} para llegar a 100: {m}.':
      'Bilatu zenbatez biderkatu behar den {d} zenbakia 100era iristeko: {m}.',
  '{c} centésimas se escriben {r}.':
      '{c} ehunen honela idazten da: {r}.',
  '{c} de cada 100 es el {r}.':
      '100etik {c}: hori da {r}.',
  'Divide {x} entre {n}: {n} × {q} = {p}.':
      'Zatitu {x} zenbakia {n} zenbakiaz: {n} × {q} = {p}.',
  'No sobra nada: {x} es múltiplo de {n}.':
      'Ez da ezer soberan geratzen: {x} zenbakia {n} zenbakiaren multiploa da.',
  'Sobran {r}: {x} no es múltiplo de {n}.':
      '{r} soberan: {x} zenbakia ez da {n} zenbakiaren multiploa.',
  'Prueba a dividir {x} entre 2, 3, 5 y 7.':
      'Probatu {x} zenbakia 2, 3, 5 eta 7 zenbakiez zatitzen.',
  '{x} ÷ {p} = {q}, exacto: no es primo.':
      '{x} ÷ {p} = {q}, zehatza: ez da lehena.',
  'Ninguna división es exacta: {x} es primo.':
      'Zatiketa bakar bat ere ez da zehatza: {x} zenbakia lehena da.',
  'Escribe 0,5 como 0,50 para comparar cifra a cifra.':
      'Idatzi 0,5 honela: 0,50, zifraz zifra konparatzeko.',
  'Décimas: {a} es mayor que 5, así que {x} es mayor que 0,5.':
      'Hamarrenak: {a} handiagoa da 5 baino; beraz, {x} handiagoa da 0,5 baino.',
  'Décimas: {a} es menor que 5, así que {x} es menor que 0,5.':
      'Hamarrenak: {a} txikiagoa da 5 baino; beraz, {x} txikiagoa da 0,5 baino.',
  'Las décimas empatan (5): mira las centésimas. {x} es mayor que 0,5.':
      'Hamarrenak berdin (5): begiratu ehunenei. {x} handiagoa da 0,5 baino.',
  'Las décimas empatan (5): mira las centésimas. {x} es igual a 0,5.':
      'Hamarrenak berdin (5): begiratu ehunenei. {x} eta 0,5 berdinak dira.',
  'La mitad de {d} es {m}.':
      '{d} zenbakiaren erdia {m} da.',
  '{n} es más que {m}: {f} es mayor que 1/2.':
      '{n} handiagoa da {m} baino: {f} handiagoa da 1/2 baino.',
  '{n} es menos que {m}: {f} es menor que 1/2.':
      '{n} txikiagoa da {m} baino: {f} txikiagoa da 1/2 baino.',
  'Empieza por el mayor y cuenta lo que falta: {m} y {k} más.':
      'Hasi handienetik eta zenbatu falta dena: {m} eta beste {k}.',
  '{m} + {k} = {r}.':
      '{m} + {k} = {r}.',
  'Decenas: {a} + {b} = {s}.':
      'Hamarrekoak: {a} + {b} = {s}.',
  'Unidades: {a} + {b} = {s}.':
      'Batekoak: {a} + {b} = {s}.',
  'Junta las dos: {a} + {b} = {r}.':
      'Batu biak: {a} + {b} = {r}.',
  'Primero el paréntesis: {a} + {b} = {s}.':
      'Lehenik parentesia: {a} + {b} = {s}.',
  'Luego multiplica: {s} × {c} = {r}.':
      'Gero biderkatu: {s} × {c} = {r}.',
  'Primero la multiplicación: {b} × {c} = {m}.':
      'Lehenik biderketa: {b} × {c} = {m}.',
  'Luego la suma: {a} + {m} = {r}.':
      'Gero batuketa: {a} + {m} = {r}.',
  '{e} es {b} × {b} × {b}.':
      '{e} = {b} × {b} × {b}.',
  '{b} × {b} = {c}; {c} × {b} = {r}.':
      '{b} × {b} = {c}; {c} × {b} = {r}.',
  '{e} es {b} × {b} (no {b} × 2).':
      '{e} = {b} × {b} (ez {b} × 2).',
  '{b} × {b} = {r}.':
      '{b} × {b} = {r}.',
  'Divide {q} entre {d}: sale {u}. Eso es 1/{d}.':
      'Zatitu {q} zenbakia {d} zenbakiaz: {u} ateratzen da. Hori da 1/{d}.',
  'Quieres {n} partes: {u} × {n} = {r}.':
      '{n} zati nahi dituzu: {u} × {n} = {r}.',
  'Sólo quieres una parte: {r}.':
      'Zati bakarra nahi duzu: {r}.',
  'El 50 % es la mitad: {q} ÷ 2 = {r}.':
      '% 50 erdia da: {q} ÷ 2 = {r}.',
  'El 10 % es dividir entre 10: {q} ÷ 10 = {r}.':
      '% 10 10ekin zatitzea da: {q} ÷ 10 = {r}.',
  'El 25 % es la cuarta parte: {q} ÷ 4 = {r}.':
      '% 25 laurdena da: {q} ÷ 4 = {r}.',
  'El 25 % es la cuarta parte: {q} ÷ 4 = {t}.':
      '% 25 laurdena da: {q} ÷ 4 = {t}.',
  'El 75 % son tres cuartas partes: {t} × 3 = {r}.':
      '% 75 hiru laurden dira: {t} × 3 = {r}.',
  'El 20 % es el doble: {t} × 2 = {r}.':
      '% 20 bikoitza da: {t} × 2 = {r}.',
  'Calcula {p} de cada 100: {q} × {p} ÷ 100 = {r}.':
      'Kalkulatu 100etik {p}: {q} × {p} ÷ 100 = {r}.',
  // Segunda sala y Engranajes
  'Engranajes':
      'Engranajeak',
  'La grúa del Puerto sólo arranca cuando las marcas de sus ruedas coinciden.':
      'Portuko garabia bere gurpilen markak bat datozenean bakarrik abiatzen da.',
  'Ruedas de 4 y de 6 dientes. Las marcas no vuelven a juntarse cuando tú crees. Cuéntalo.':
      '4 eta 6 horzdun gurpilak. Markak ez dira uste duzunean elkartzen. Zenbatu.',
  'Elige un número y mira girar las ruedas. Con las ruedas, busca cuántos dientes tienen que pasar para que las marcas rojas vuelvan arriba a la vez. Con los cabos, el trozo más largo que corta los dos sin que sobre nada. La rueda oxidada esconde sus dientes: descúbrelos.':
      'Aukeratu zenbaki bat eta begiratu gurpilei biraka. Gurpilekin, bilatu zenbat hortz pasa behar diren marka gorriak aldi berean gora itzul daitezen. Sokekin, biak ezer soberan utzi gabe mozten dituen zatirik luzeena. Gurpil herdoilduak bere hortzak ezkutatzen ditu: aurkitu itzazu.',
  'Trozos de {n} m y no sobra nada. Más largos no salen.':
      '{n} metroko zatiak eta ez da ezer soberan geratzen. Luzeagoak ez dira ateratzen.',
  'Clac. Las marcas arriba a la vez: la grúa arranca.':
      'Klak. Markak goian aldi berean: garabia abiatzen da.',
  'Con {v}, la rueda de {n} no ha dado vueltas enteras: su marca no está arriba.':
      '{v} zenbakiarekin, {n} horzdun gurpilak ez du bira osorik eman: bere marka ez dago goian.',
  'Coinciden en {v}, sí. Pero antes ya se habían juntado.':
      '{v} zenbakian bat datoz, bai. Baina lehenago ere elkartu ziren.',
  'Con trozos de {v} m, sobra un pedazo de cabo.':
      '{v} metroko zatiekin, soka puska bat soberan geratzen da.',
  'Salen iguales y no sobra nada, pero se pueden cortar más largos.':
      'Berdinak ateratzen dira eta ez da ezer soberan geratzen, baina luzeagoak moztu daitezke.',
  'Con {v} dientes coincidirían tras {m}, no tras {c}.':
      '{v} hortzekin {m} hortzen ondoren etorriko lirateke bat, ez {c} hortzen ondoren.',
  'Ruedas de {a}, {b} y {c} dientes. ¿Tras cuántos dientes vuelven las tres marcas arriba?':
      '{a}, {b} eta {c} horzdun gurpilak. Zenbat hortzen ondoren itzultzen dira hiru markak gora?',
  'Ruedas de {a} y {b} dientes. ¿Tras cuántos dientes vuelven las dos marcas arriba?':
      '{a} eta {b} horzdun gurpilak. Zenbat hortzen ondoren itzultzen dira bi markak gora?',
  'Cabos de {a} m y {b} m. ¿Cuánto mide el trozo más largo que corta los dos sin que sobre?':
      '{a} m eta {b} m-ko sokak. Zenbat neurtzen du biak ezer soberan utzi gabe mozten dituen zatirik luzeenak?',
  'Una rueda de {a} dientes y otra oxidada. Sus marcas coinciden tras {c} dientes. ¿Cuántos dientes tiene la oxidada?':
      '{a} horzdun gurpil bat eta beste bat herdoilduta. Haien markak {c} hortzen ondoren datoz bat. Zenbat hortz ditu herdoildutakoak?',
  'Seis arranques. La grúa ya carga sola; tú a descansar.':
      'Sei abiatze. Garabiak bakarrik kargatzen du orain; zu, atseden hartzera.',
  'La planta de arriba':
      'Goiko solairua',
  'Aquí arriba están las que enseñan cosas nuevas. Sólo se encienden si vienes preparado.':
      'Hemen goian gauza berriak irakasten dituztenak daude. Prestatuta bazatoz bakarrik pizten dira.',
  'Se enciende cuando domines: {llaves}.':
      'Hau menderatzen duzunean pizten da: {llaves}.',
  'Máquinas que enseñan cosas nuevas. Sube cuando quieras.':
      'Gauza berriak irakasten dituzten makinak. Igo nahi duzunean.',
  'Rexán la abre cuando domines bien lo de esta sala. No hay prisa.':
      'Rexanek aretoko hau ondo menderatzen duzunean irekitzen du. Ez dago presarik.',
  'Escribe los múltiplos de cada número hasta encontrar el primero que se repite: 4, 8, 12… y 6, 12… El mínimo común múltiplo es 12.':
      'Idatzi zenbaki bakoitzaren multiploak errepikatzen den lehena aurkitu arte: 4, 8, 12… eta 6, 12… Multiplo komunetako txikiena 12 da.',
  'Escribe los divisores de cada número y quédate con el mayor que comparten: 24 y 36 se dividen los dos entre 12.':
      'Idatzi zenbaki bakoitzaren zatitzaileak eta hartu partekatzen duten handiena: 24 eta 36 biak 12z zatitzen dira.',
  'Múltiplos de {a}: {lista}.':
      '{a} zenbakiaren multiploak: {lista}.',
  'El primero que está en las dos listas: {r}.':
      'Bi zerrendetan dagoen lehena: {r}.',
  'Divisores de {a}: {lista}.':
      '{a} zenbakiaren zatitzaileak: {lista}.',
  'El mayor que está en las dos listas: {r}.':
      'Bi zerrendetan dagoen handiena: {r}.',
  'Identificar fracciones equivalentes':
      'Zatiki baliokideak identifikatu',
  'Comparar fracción con 1/2':
      'Zatikia 1/2rekin konparatu',
  'Múltiplos de un número':
      'Zenbaki baten multiploak',
  'Números primos':
      'Zenbaki lehenak',
  'Suma básica de enteros pequeños':
      'Zenbaki oso txikien batuketa',
  'Jerarquía de operaciones':
      'Eragiketen hierarkia',
  'Resolver ecuación lineal simple':
      'Ekuazio lineal sinplea ebatzi',
  'Fracción de una cantidad':
      'Kantitate baten zatikia',
  'Sumar y restar decimales':
      'Hamartarrak batu eta kendu',
  'Sumar fracciones con denominadores distintos':
      'Izendatzaile desberdineko zatikiak batu',
  'Comparar decimales':
      'Hamartarrak konparatu',
  'Potencias de exponente natural':
      'Berretzaile arrunteko berreturak',
  'Área de rectángulos y cuadrados':
      'Laukizuzenen eta karratuen azalera',
  // Esclusas
  'Esclusas':
      'Ateak',
  'Los números bajan por el canal. Mándalos a su esclusa y ordena a los que vienen atados.':
      'Zenbakiak ubidean behera doaz. Bidali bakoitza bere atera eta ordenatu lotuta datozenak.',
  'Las compuertas de los Canales se han soltado. Tú decides por dónde pasa cada barca, y rápido.':
      'Ubideetako ateak askatu egin dira. Zuk erabakitzen duzu txalupa bakoitza nondik pasatzen den, eta azkar.',
  'Las barquitas bajan solas. En la primera tanda, toca la esclusa de su tramo antes de que lleguen abajo. En la segunda vienen atadas de dos en dos: toca la que vale más. En la tercera, de tres en tres: tócalas de la más pequeña a la más grande. Si una llega abajo, Rexán la sube otra vez.':
      'Txalupak bakarrik jaisten dira. Lehen txandan, ukitu bere tartearen atea behera iritsi aurretik. Bigarrenean bi eta bi lotuta datoz: ukitu gehien balio duena. Hirugarrenean, hiru eta hiru: ukitu txikienetik handienera. Bat behera iristen bada, Rexanek berriro igotzen du.',
  'Se te ha escapado. Te la subo otra vez.':
      'Ihes egin dizu. Berriro igoko dizut.',
  'Esa esclusa no es la suya: {b} no está en ese tramo.':
      'Ate hori ez da berea: {b} ez dago tarte horretan.',
  '{b} no es la mayor de las dos.':
      '{b} ez da bietan handiena.',
  'Esa no tocaba: {b} no es la más pequeña de las que quedan. Empieza otra vez.':
      'Hori ez zegokion: {b} ez da geratzen direnen artean txikiena. Hasi berriro.',
  'Ahora vienen atadas de dos en dos. Toca la que vale más.':
      'Orain bi eta bi lotuta datoz. Ukitu gehien balio duena.',
  'Ahora de tres en tres. De la más pequeña a la más grande.':
      'Orain hiru eta hiru. Txikienetik handienera.',
  'Tres tandas por las esclusas. El canal queda en calma.':
      'Hiru txanda ateetatik. Ubidea lasai geratzen da.',
  'Abre la esclusa de su tramo antes de que llegue abajo.':
      'Ireki bere tartearen atea behera iritsi aurretik.',
  'Toca la que vale más.':
      'Ukitu gehien balio duena.',
  'Tócalas de la más pequeña a la más grande.':
      'Ukitu txikienetik handienera.',
  'menos de {u}':
      '{u} baino gutxiago',
  'entre {u} y 1':
      '{u} eta 1 artean',
  'más de 1':
      '1 baino gehiago',
  'Si el de arriba es menor que el de abajo, la fracción es menor que 1; si es mayor, pasa de 1. 7/5 es más que 1 porque 7 > 5.':
      'Goikoa behekoa baino txikiagoa bada, zatikia 1 baino txikiagoa da; handiagoa bada, 1 gainditzen du. 7/5 1 baino gehiago da, 7 > 5 delako.',
  'Con el mismo denominador, gana el de arriba más grande: 5/8 > 3/8.':
      'Izendatzaile berarekin, goikoa handiena duenak irabazten du: 5/8 > 3/8.',
  'Con el mismo numerador, gana el denominador más pequeño: 2/3 > 2/5, porque los tercios son trozos más grandes que los quintos.':
      'Zenbakitzaile berarekin, izendatzaile txikienak irabazten du: 2/3 > 2/5, herenak bosdenak baino zati handiagoak direlako.',
  'Multiplica en cruz: para 3/4 y 5/7, 3 × 7 = 21 y 5 × 4 = 20. Gana la del producto mayor: 3/4.':
      'Biderkatu gurutzean: 3/4 eta 5/7rentzat, 3 × 7 = 21 eta 5 × 4 = 20. Biderkadura handiena duenak irabazten du: 3/4.',
  'Compáralas de dos en dos, o pásalas todas a decimal (divide arriba entre abajo) y ordénalas.':
      'Konparatu bi eta bi, edo pasa guztiak hamartarrera (zatitu goikoa behekoaz) eta ordenatu.',
  'Iguala las cifras con ceros y compara desde la coma: 0,5 = 0,50, y 0,50 > 0,45.':
      'Berdindu zifrak zeroekin eta konparatu komatik hasita: 0,5 = 0,50, eta 0,50 > 0,45.',
  'Compara el de arriba con el de abajo: {n} y {d}.':
      'Konparatu goikoa behekoarekin: {n} eta {d}.',
  '{n} es mayor que {d}: {f} es más que 1.':
      '{n} handiagoa da {d} baino: {f} 1 baino gehiago da.',
  '{n} es menor que {d}: {f} es menos que 1.':
      '{n} txikiagoa da {d} baino: {f} 1 baino gutxiago da.',
  'Mismo denominador ({d}): mira sólo los de arriba.':
      'Izendatzaile bera ({d}): begiratu goikoei bakarrik.',
  '{b} > {a}: {f} es la mayor.':
      '{b} > {a}: {f} da handiena.',
  'Mismo numerador ({n}): mira los de abajo.':
      'Zenbakitzaile bera ({n}): begiratu behekoei.',
  'Partido en {a}, cada trozo es más grande que partido en {b}: {f} es la mayor.':
      '{a} zatitan zatituta, zati bakoitza handiagoa da {b} zatitan baino: {f} da handiena.',
  'Multiplica en cruz: {a} × {d} = {x} y {c} × {b} = {y}.':
      'Biderkatu gurutzean: {a} × {d} = {x} eta {c} × {b} = {y}.',
  'El producto mayor va con la fracción mayor: {f}.':
      'Biderkadura handiena zatiki handienarekin doa: {f}.',
  '{f} ≈ {v}':
      '{f} ≈ {v}',
  'De menor a mayor: {orden}.':
      'Txikienetik handienera: {orden}.',
  'Iguala las cifras con ceros: {a} y {b}0.':
      'Berdindu zifrak zeroekin: {a} eta {b}0.',
  'Compara las décimas y luego las centésimas: {m} es la mayor.':
      'Konparatu hamarrenak eta gero ehunenak: {m} da handiena.',
  // Planos
  'Planos':
      'Planoak',
  'Redibuja las casas de las Afueras con la medida justa: área, valla y tejados.':
      'Marraztu berriro Kanpoaldeko etxeak neurri zehatzarekin: azalera, hesia eta teilatuak.',
  'Se mojaron los planos de las casas nuevas. Tú tienes cuadrícula y lápiz; yo, el sello.':
      'Etxe berrien planoak busti egin ziren. Zuk sareta eta arkatza dituzu; nik, zigilua.',
  'Arrastra el dedo de una esquina a la otra (o toca dos esquinas) para dibujar la habitación; cada cuadro es 1 m². Abajo ves su área y su valla. Cuando cumpla el encargo, pulsa ENTREGAR. No se construye sobre la maleza.':
      'Arrastatu hatza izkina batetik bestera (edo ukitu bi izkina) gela marrazteko; lauki bakoitza 1 m² da. Behean bere azalera eta hesia ikusten dituzu. Enkargua betetzen duenean, sakatu ENTREGATU. Sasi gainean ez da eraikitzen.',
  'Esta maleza crece mientras piensas. No hay prisa, pero no para.':
      'Sasi hau pentsatzen duzun bitartean hazten da. Ez dago presarik, baina ez da gelditzen.',
  'Ahí hay maleza: no se puede construir encima. Muévelo.':
      'Hor sasia dago: ezin da gainean eraiki. Mugitu.',
  'Sellado. Esa casa se puede construir.':
      'Zigilatuta. Etxe hori eraiki daiteke.',
  'Esa valla mide {p} m, no {P}.':
      'Hesi horrek {p} m neurtzen ditu, ez {P}.',
  'Con {P} m de valla cabe un huerto más grande.':
      '{P} m-ko hesiarekin baratze handiagoa sartzen da.',
  'Tiene {a} m², sí, pero lleva {p} m de valla. Se puede con menos.':
      '{a} m² ditu, bai, baina {p} m hesi behar ditu. Gutxiagorekin egin daiteke.',
  'Ese triángulo tiene {t} m²: la mitad del rectángulo de {a}.':
      'Triangelu horrek {t} m² ditu: {a} m²-ko laukizuzenaren erdia.',
  'Esa habitación tiene {a} m². El encargo pide otra cosa.':
      'Gela horrek {a} m² ditu. Enkarguak beste zerbait eskatzen du.',
  'Una habitación de {v} m².':
      '{v} m²-ko gela bat.',
  'Una habitación de {v} m² con la menor valla posible.':
      '{v} m²-ko gela bat, ahalik eta hesi txikienarekin.',
  'Con {v} m de valla, el huerto más grande posible.':
      '{v} m-ko hesiarekin, ahalik eta baratzerik handiena.',
  'Un tejado triangular de {v} m²: dibuja el rectángulo que lo contiene.':
      '{v} m²-ko teilatu triangeluarra: marraztu hura barnean duen laukizuzena.',
  'Una habitación de {v} dm².':
      '{v} dm²-ko gela bat.',
  'Seis planos sellados. Las Afueras ya tienen barrio.':
      'Sei plano zigilatuta. Kanpoaldeak auzoa du dagoeneko.',
  'Arrastra el dedo de una esquina a la otra.':
      'Arrastatu hatza izkina batetik bestera.',
  'Rectángulo: {a} m² · Tejado: {t} m²':
      'Laukizuzena: {a} m² · Teilatua: {t} m²',
  'Área: {a} m² · Valla: {p} m':
      'Azalera: {a} m² · Hesia: {p} m',
  'ENTREGAR':
      'ENTREGATU',
  'El área de un rectángulo es ancho por alto: 4 × 6 = 24 m². Cuenta los cuadros de una fila y multiplica por las filas.':
      'Laukizuzen baten azalera zabalera bider altuera da: 4 × 6 = 24 m². Zenbatu errenkada bateko laukiak eta biderkatu errenkada kopuruaz.',
  'El perímetro es la vuelta entera: suma los cuatro lados. Para la misma área, cuanto más cuadrado, menos valla.':
      'Perimetroa bira osoa da: batu lau aldeak. Azalera bera izanda, zenbat eta karratuagoa, orduan eta hesi gutxiago.',
  'Un triángulo rectángulo es medio rectángulo: base por altura y entre dos. Para 12 m² de tejado, un rectángulo de 24.':
      'Triangelu zuzena laukizuzen erdia da: oinarria bider altuera eta bitan zatitu. 12 m²-ko teilaturako, 24ko laukizuzena.',
  'Un metro cuadrado tiene 10 × 10 = 100 decímetros cuadrados. Para pasar de dm² a m², divide entre 100.':
      'Metro karratu batek 10 × 10 = 100 dezimetro karratu ditu. dm²-tik m²-ra pasatzeko, zatitu 100ez.',
  'Una fila tiene {a} cuadros y hay {h} filas.':
      'Errenkada batek {a} lauki ditu eta {h} errenkada daude.',
  'Área: {a} × {h} = {r} m².':
      'Azalera: {a} × {h} = {r} m².',
  '{a} × {b}: valla de {p} m.':
      '{a} × {b}: {p} m-ko hesia.',
  'La más cuadrada, {a} × {b}, gasta menos valla.':
      'Karratuenak, {a} × {b}, hesi gutxiago behar du.',
  'El rectángulo que lo contiene: {b} × {h} = {r} m².':
      'Hura barnean duen laukizuzena: {b} × {h} = {r} m².',
  'El triángulo es la mitad: {r} ÷ 2 = {t} m².':
      'Triangelua erdia da: {r} ÷ 2 = {t} m².',
  '1 m² = 10 dm × 10 dm = 100 dm².':
      '1 m² = 10 dm × 10 dm = 100 dm².',
  '{d} ÷ 100 = {m} m².':
      '{d} ÷ 100 = {m} m².',
  // Las redes, Nivelar y La caja negra
  'Las redes':
      'Sareak',
  'Elige la red de la que es más fácil sacar un pez ámbar y compruébalo echándola.':
      'Aukeratu arrain anbarra ateratzeko errazena den sarea eta egiaztatu botaz.',
  'Los pescadores quieren peces ámbar para las farolas. Tú eliges la red; el mar decide cada lance.':
      'Arrantzaleek arrain anbarrak nahi dituzte farolentzat. Zuk sarea aukeratzen duzu; itsasoak erabakitzen du bota bakoitza.',
  'Toca la red de la que es más probable sacar un pez ámbar: no la que tiene más ámbar, sino la que tiene más ámbar de cada tantos. La máquina la echa veinte veces para comprobarlo. Cuenta tu decisión, no lo que salga. Al final, elige cómo se escribe la probabilidad.':
      'Ukitu arrain anbar bat ateratzeko probableena den sarea: ez anbar gehien duena, baizik eta zenbatetik anbar gehien duena. Makinak hogei aldiz botatzen du egiaztatzeko. Zure erabakia zenbatzen da, ez ateratzen dena. Amaieran, aukeratu probabilitatea nola idazten den.',
  'Echamos la red veinte veces…':
      'Sarea hogei aldiz botatzen dugu…',
  'Esta vez sólo {k} de 20. Mala tanda, buena decisión: {a} de cada {t} era la mejor red.':
      'Oraingoan 20tik {k} bakarrik. Txanda txarra, erabaki ona: {t} arrainetatik {a} zituena zen sarerik onena.',
  'Buena red: {a} de cada {t}. Han salido {k} ámbar de 20.':
      'Sare ona: {t} arrainetatik {a}. 20tik {k} anbar atera dira.',
  'Han salido {k} de 20, pero la mejor era la de {ma} de cada {mt}: tocaba a más.':
      '20tik {k} atera dira, baina onena {mt} arrainetatik {ma} zituena zen: gehiago tokatzen zitzaion.',
  '{o}: {a} de cada {t}. Da igual cómo se escriba.':
      '{o}: {t} arrainetatik {a}. Berdin da nola idatzi.',
  '{o} no es {a} de cada {t}. Prueba otra.':
      '{o} ez da {t} arrainetatik {a}. Probatu beste bat.',
  'Seis redes echadas. Hay peces ámbar para todas las farolas del muelle.':
      'Sei sare botata. Kaiko farola guztientzat badira arrain anbarrak.',
  'De {t} peces, {a} son ámbar. ¿Qué probabilidad hay de sacar uno ámbar?':
      '{t} arrainetatik {a} anbarrak dira. Zer probabilitate dago anbar bat ateratzeko?',
  '¿De qué red es más probable sacar un pez ámbar?':
      'Zein saretatik da probableagoa arrain anbar bat ateratzea?',
  '{a} ámbar de {t}':
      '{a} anbar, {t} arrainetatik',
  'Nivelar':
      'Berdindu',
  'Lee las pilas de contenedores y reparte la carga: media, mediana y moda.':
      'Irakurri edukiontzi pilak eta banatu zama: batez bestekoa, mediana eta moda.',
  'Este barco va escorado. Si sabes a qué altura quedaría la carga, lo enderezamos.':
      'Itsasontzi hau okertuta doa. Zama zer altueratan geratuko litzatekeen badakizu, zuzenduko dugu.',
  'Las pilas de contenedores son un gráfico: el eje de la izquierda dice cuántos hay. Lee la pregunta y elige un número. Al acertar, el barco lo demuestra: las pilas se igualan (la media), se ordenan (la mediana) o se ilumina la altura que más se repite (la moda).':
      'Edukiontzi pilak grafiko bat dira: ezkerreko ardatzak zenbat dauden esaten du. Irakurri galdera eta aukeratu zenbaki bat. Asmatzean, itsasontziak erakusten du: pilak berdintzen dira (batez bestekoa), ordenatzen dira (mediana) edo gehien errepikatzen den altuera argitzen da (moda).',
  'Eso es. Mira: moviendo contenedores, todas quedan igual.':
      'Hori da. Begira: edukiontziak mugituz, denak berdin geratzen dira.',
  'Ordenadas, la del medio manda.':
      'Ordenatuta, erdikoak agintzen du.',
  'La que más se repite. El barco lo agradece.':
      'Gehien errepikatzen dena. Itsasontziak eskertzen du.',
  'Bien leído.':
      'Ondo irakurrita.',
  'Cuenta otra vez los contenedores de esa pila, con el eje de al lado.':
      'Zenbatu berriro pila horretako edukiontziak, ondoko ardatzarekin.',
  'Resta: la pila alta menos la baja.':
      'Kendu: pila altua ken baxua.',
  'Con esa altura sobran o faltan contenedores. Suma todos y reparte.':
      'Altuera horrekin edukiontziak soberan edo falta dira. Batu denak eta banatu.',
  'Primero ordénalas de menor a mayor; luego mira la del medio.':
      'Lehenik ordenatu txikienetik handienera; gero begiratu erdikoari.',
  'La moda es la altura que más se repite, no la más alta.':
      'Moda gehien errepikatzen den altuera da, ez altuena.',
  '¿Cuántos contenedores hay en la pila {x}?':
      'Zenbat edukiontzi daude {x} pilan?',
  '¿Cuántos contenedores más tiene la pila {x} que la {y}?':
      'Zenbat edukiontzi gehiago ditu {x} pilak {y} pilak baino?',
  'Si igualas todas las pilas moviendo contenedores, ¿a qué altura quedan?':
      'Edukiontziak mugituz pila guztiak berdintzen badituzu, zer altueratan geratzen dira?',
  'Ordena las pilas de menor a mayor. ¿Cuánto mide la del medio?':
      'Ordenatu pilak txikienetik handienera. Zenbat neurtzen du erdikoak?',
  '¿Qué altura se repite más?':
      'Zein altuera errepikatzen da gehien?',
  'Seis cargas repartidas. El barco sale derecho del puerto.':
      'Sei zama banatuta. Itsasontzia zuzen ateratzen da portutik.',
  'La caja negra':
      'Kutxa beltza',
  'Entran números y salen otros. Descubre la regla y la caja se abre.':
      'Zenbakiak sartzen dira eta beste batzuk ateratzen. Aurkitu araua eta kutxa irekiko da.',
  'Nadie en la Montaña sabe abrirla. Traga números y escupe otros. Tú, a mirar la tabla.':
      'Mendian inork ez daki irekitzen. Zenbakiak irensten ditu eta beste batzuk botatzen. Zuk, taulari begira.',
  'La tabla dice qué sale cuando entra cada número. Puedes meter algunos números más para ver qué hace la caja (pocos: piénsalos). Luego te pregunta por un número que no puedes probar. Al final, dos sacos y dos balanzas: ¿cuánto pesa el rojo?':
      'Taulak esaten du zer ateratzen den zenbaki bakoitza sartzean. Zenbaki gehiago sar ditzakezu kutxak zer egiten duen ikusteko (gutxi: pentsatu ondo). Gero probatu ezin duzun zenbaki bati buruz galdetzen dizu. Amaieran, bi poltsa eta bi balantza: zenbat pisatzen du gorriak?',
  'Glup. Ese se lo ha tragado: es un Mudo.':
      'Glup. Hori irentsi du: Mutu bat da.',
  'Clic. La caja se abre.':
      'Klik. Kutxa irekitzen da.',
  'Con esa respuesta, alguna fila de la tabla no cuadra. Compruébalas todas.':
      'Erantzun horrekin, taulako errenkadaren batek ez du bat egiten. Egiaztatu denak.',
  'Mete {v} en la regla de la tabla: ¿sale {y}?':
      'Sartu {v} taulako arauan: {y} ateratzen da?',
  'Si el rojo pesa {v}, alguna de las dos balanzas no cuadra.':
      'Gorriak {v} pisatzen badu, bi balantzetako batek ez du bat egiten.',
  'Seis cajas abiertas. En la Montaña ya nadie les tiene miedo.':
      'Sei kutxa irekita. Mendian inork ez die beldurrik jada.',
  'Si entra {n}, ¿qué sale?':
      '{n} sartzen bada, zer ateratzen da?',
  'Ha salido {n}. ¿Qué número entró?':
      '{n} atera da. Zein zenbaki sartu zen?',
  '¿Cuánto pesa el saco rojo?':
      'Zenbat pisatzen du poltsa gorriak?',
  'Prueba números ({n} intentos)':
      'Probatu zenbakiak ({n} saiakera)',
  'ENTRA':
      'SARTU',
  'SALE':
      'IRTEN',
  'Probabilidad = casos buenos entre casos posibles. 3 ámbar de 8 es 3/8; 5 de 16 es 5/16. Compara las fracciones, no sólo los ámbar.':
      'Probabilitatea = kasu onak zati kasu posibleak. 8tik 3 anbar 3/8 da; 16tik 5, 5/16. Konparatu zatikiak, ez anbarrak bakarrik.',
  'La misma probabilidad se escribe de tres maneras: 1/4 = 0,25 = 25 %. Divide los buenos entre el total y multiplica por 100 para el %.':
      'Probabilitate bera hiru eratara idazten da: 1/4 = 0,25 = % 25. Zatitu onak guztizkoaz eta biderkatu 100ez %-rako.',
  'Lleva la vista de lo alto de la barra al eje de la izquierda: ahí está el número. Para comparar dos barras, resta.':
      'Eraman begirada barraren goialdetik ezkerreko ardatzera: hor dago zenbakia. Bi barra konparatzeko, kendu.',
  'La media es repartir a partes iguales: suma todo y divide entre cuántos hay. 3 + 5 + 7 + 5 = 20, entre 4 = 5.':
      'Batez bestekoa zati berdinetan banatzea da: batu dena eta zatitu zenbat dauden. 3 + 5 + 7 + 5 = 20, 4rekin = 5.',
  'Mediana: ordena de menor a mayor y quédate con el del medio (si son dos, a mitad entre ellos). Moda: el que más se repite.':
      'Mediana: ordenatu txikienetik handienera eta hartu erdikoa (bi badira, bien erdian). Moda: gehien errepikatzen dena.',
  'Mira cuánto cambia la salida cuando la entrada sube de uno en uno: eso es lo que multiplica. Luego ajusta lo que suma o resta, y comprueba la regla con todas las filas.':
      'Begiratu irteera zenbat aldatzen den sarrera banaka igotzean: hori da biderkatzen duena. Gero doitu batzen edo kentzen duena, eta egiaztatu araua errenkada guztiekin.',
  'Junta las dos balanzas: si rojo + azul = 13 y rojo − azul = 5, sumándolas quedan dos rojos = 18. Un rojo pesa 9.':
      'Elkartu bi balantzak: gorria + urdina = 13 eta gorria − urdina = 5 badira, batuz bi gorri = 18 geratzen dira. Gorri batek 9 pisatzen du.',
  'Escribe cada red como fracción: {f} y {g}.':
      'Idatzi sare bakoitza zatiki gisa: {f} eta {g}.',
  'Gana la del producto mayor: {m}.':
      'Biderkadura handiena duenak irabazten du: {m}.',
  'Como fracción: {f}.':
      'Zatiki gisa: {f}.',
  'Multiplica arriba y abajo por {m}: {g}.':
      'Biderkatu goian eta behean {m} zenbakiaz: {g}.',
  'Como decimal, {d}; como porcentaje, {p} %.':
      'Hamartar gisa, {d}; ehuneko gisa, % {p}.',
  'La barra A llega a la línea del {a} en el eje; la B, a la del {b}.':
      'A barra ardatzeko {a} zenbakiaren lerrora iristen da; B, {b} zenbakiarenera.',
  'A tiene {a} − {b} = {r} más que B.':
      'Ak {a} − {b} = {r} gehiago ditu Bk baino.',
  'Suma todo: {s}.':
      'Batu dena: {s}.',
  'Reparte entre {n}: {s} ÷ {n} = {m}.':
      'Banatu {n} zatitan: {s} ÷ {n} = {m}.',
  'Ordena de menor a mayor: {o}.':
      'Ordenatu txikienetik handienera: {o}.',
  'El del medio (el tercero de cinco) es la mediana: {m}.':
      'Erdikoa (bostetik hirugarrena) mediana da: {m}.',
  'Cada vez que entra uno más, sale {a} más: la regla multiplica por {a}.':
      'Bat gehiago sartzen den bakoitzean, {a} gehiago ateratzen da: arauak {a} zenbakiaz biderkatzen du.',
  '{a} × 1 = {p}, pero sale {s}: además suma {b}.':
      '{a} × 1 = {p}, baina {s} ateratzen da: gainera {b} batzen du.',
  'La regla: × {a} y + {b}. Si entra 10, sale {r}.':
      'Araua: × {a} eta + {b}. 10 sartzen bada, {r} ateratzen da.',
  'Suma las dos: la y se va y quedan dos x = {s}.':
      'Batu biak: y desagertzen da eta bi x = {s} geratzen dira.',
  'Una x: {s} ÷ 2 = {r}. Y la y: {t} − {r} = {z}.':
      'x bat: {s} ÷ 2 = {r}. Eta y: {t} − {r} = {z}.',
  // El pozo y Pinturas
  'El pozo':
      'Putzua',
  'El ascensor de la mina baja por debajo de cero. Sigue sus órdenes y di dónde para.':
      'Meatzeko igogailua zerotik behera jaisten da. Jarraitu bere aginduei eta esan non gelditzen den.',
  'La mina está a oscuras. Si no sabes a qué planta vas, no la encuentras.':
      'Meatzea ilunpean dago. Zein solairutara zoazen ez badakizu, ez duzu aurkituko.',
  'Lee las órdenes del ascensor de izquierda a derecha: + sube, − baja. La ficha rosa da la vuelta a la orden siguiente y la azul repite la anterior; −(−5) sube 5. Toca la planta donde acabará. Al final, distancias al suelo: la 7 y la −7 están igual de lejos.':
      'Irakurri igogailuaren aginduak ezkerretik eskuinera: + igo, − jaitsi. Fitxa arrosak hurrengo agindua iraultzen du eta urdinak aurrekoa errepikatzen du; −(−5) 5 igotzen da. Ukitu amaituko den solairua. Amaieran, lurrarekiko distantziak: 7a eta −7a berdin urrun daude.',
  'Planta {r}. Justo donde dijiste.':
      '{r}. solairua. Esan zenuen tokian.',
  'La {f} está a {d} plantas del suelo; la {t}, a {e}. La del otro lado es la {r}.':
      '{f} solairua lurretik {d} solairura dago; {t} solairua, {e} solairura. Beste aldekoa {r} da.',
  'El ascensor para en la {r}, no en la {t}.':
      'Igogailua {r} solairuan gelditzen da, ez {t} solairuan.',
  '{r} plantas, pasando por el suelo.':
      '{r} solairu, lurretik pasatuz.',
  'Cuenta las plantas de la {a} a la {b}, pasando por el suelo.':
      'Zenbatu solairuak {a} solairutik {b} solairura, lurretik pasatuz.',
  'Seis viajes a oscuras sin perderte. La mina ya tiene luz.':
      'Sei bidaia ilunpean galdu gabe. Meatzeak argia du dagoeneko.',
  'Sales de la planta {p}. ¿Dónde acaba el ascensor? Toca la planta.':
      '{p} solairutik irteten zara. Non amaitzen da igogailua? Ukitu solairua.',
  'Baja o sube a la planta que está a la misma distancia del suelo que la {p}, al otro lado.':
      'Jaitsi edo igo lurretik {p} solairuaren distantzia berera dagoen solairura, beste aldean.',
  '¿Cuántas plantas hay de la {a} a la {b}?':
      'Zenbat solairu daude {a} solairutik {b} solairura?',
  'invierte la siguiente':
      'hurrengoa iraultzen du',
  'repite la anterior':
      'aurrekoa errepikatzen du',
  'Pinturas':
      'Margoak',
  'Prepara los colores de los toldos del Mercado con la receta justa.':
      'Prestatu Merkatuko toldoen koloreak errezeta zehatzarekin.',
  'Los toldos se han desteñido. Cada puesto trae su receta; si la mezcla no guarda la proporción, el color no sale.':
      'Toldoak kolorea galdu dute. Postu bakoitzak bere errezeta dakar; nahasteak proportzioa gordetzen ez badu, kolorea ez da ateratzen.',
  'La receta dice cuánto azul va por cada tanto de amarillo. Elige el cubo que guarda la receta, o pon los botes justos con − y + y pulsa ENTREGAR: el color de la cubeta te dice cómo vas. Al final, la escala del plano y las rebajas.':
      'Errezetak esaten du zenbat urdin doan hainbeste horiko. Aukeratu errezeta gordetzen duen ontzia, edo jarri pote zehatzak − eta + botoiekin eta sakatu ENTREGATU: ontziaren koloreak nola zoazen esaten dizu. Amaieran, planoaren eskala eta beherapenak.',
  'Justo: el puesto está a {v} m.':
      'Zehazki: postua {v} m-ra dago.',
  'Eso cuesta ahora: {v} €.':
      'Hori kostatzen du orain: {v} €.',
  'El toldo recupera su color.':
      'Toldoak bere kolorea berreskuratzen du.',
  'Ese cubo no guarda la receta: {a} de azul por cada {b} de amarillo. El Desteñido se come el color.':
      'Ontzi horrek ez du errezeta gordetzen: {b} horiko {a} urdin. Kolore-jaleak kolorea jaten du.',
  'Con esa cuenta el verde no sale: la receta es {a} de azul por cada {b} de amarillo. Repinta.':
      'Kontu horrekin berdea ez da ateratzen: errezeta {b} horiko {a} urdin da. Margotu berriro.',
  'Cada centímetro del plano son {k} m. Mide otra vez.':
      'Planoko zentimetro bakoitza {k} m da. Neurtu berriro.',
  'Calcula el {k} % de {p} € y réstalo.':
      'Kalkulatu {p} €-ren % {k} eta kendu.',
  'Seis toldos pintados. El Mercado vuelve a tener color.':
      'Sei toldo margotuta. Merkatuak kolorea du berriro.',
  'Receta: {a} de azul por cada {b} de amarillo. ¿Qué cubo da el mismo color?':
      'Errezeta: {b} horiko {a} urdin. Zein ontzik ematen du kolore bera?',
  'Receta {a} : {b}. Hacen falta {t} botes en total. ¿Cuántos de azul?':
      'Errezeta {a} : {b}. Guztira {t} pote behar dira. Zenbat urdin?',
  'Receta {a} : {b}. Ya hay {t} botes de azul. ¿Cuántos de amarillo?':
      'Errezeta {a} : {b}. Dagoeneko {t} pote urdin daude. Zenbat hori?',
  'En el plano del Mercado, 1 cm son {k} m. El puesto está a {t} cm. ¿A cuántos metros?':
      'Merkatuko planoan, 1 cm {k} m da. Postua {t} cm-ra dago. Zenbat metrora?',
  'Un bote de {t} € con un {k} % de descuento. ¿Cuánto cuesta ahora?':
      '{t} €-ko pote bat % {k} deskontuarekin. Zenbat balio du orain?',
  '{a} azul\n{b} amarillo':
      '{a} urdin\n{b} hori',
  'Piensa en plantas: sumar un positivo sube, restar baja. Si estás en la 2 y bajas 7, pasas el suelo: 2 − 7 = −5.':
      'Pentsatu solairuetan: positibo bat batzeak igotzen du, kentzeak jaisten. 2. solairuan bazaude eta 7 jaisten bazara, lurra pasatzen duzu: 2 − 7 = −5.',
  'El valor absoluto es la distancia al suelo, sin mirar si es arriba o abajo: la 7 y la −7 están a 7 plantas. Entre la −4 y la 3 hay 4 + 3 = 7.':
      'Balio absolutua lurrarekiko distantzia da, goian edo behean den begiratu gabe: 7a eta −7a 7 solairura daude. −4 eta 3 artean 4 + 3 = 7 daude.',
  'Dos mezclas dan el mismo color si una es la otra multiplicada: 2 : 3 y 4 : 6 sí (×2); 2 : 3 y 4 : 5 no (se sumó 2).':
      'Bi nahastek kolore bera ematen dute bata bestea biderkatuta bada: 2 : 3 eta 4 : 6 bai (×2); 2 : 3 eta 4 : 5 ez (2 batu zen).',
  'Si la receta es 2 : 3, cada tanda tiene 5 botes. Para 15 botes hacen falta 15 ÷ 5 = 3 tandas: 6 de azul y 9 de amarillo.':
      'Errezeta 2 : 3 bada, txanda bakoitzak 5 pote ditu. 15 poterako 15 ÷ 5 = 3 txanda behar dira: 6 urdin eta 9 hori.',
  'Regla de tres: si 2 de azul van con 3 de amarillo, 6 de azul (el triple) van con 9 de amarillo (el triple).':
      'Hiruko erregela: 2 urdin 3 horirekin badoaz, 6 urdin (hirukoitza) 9 horirekin doaz (hirukoitza).',
  'Un descuento del 25 % es quitar la cuarta parte: de 40 €, 10 € menos, 30 €. Calcula el descuento y réstalo.':
      '% 25eko deskontua laurdena kentzea da: 40 €-tik, 10 € gutxiago, 30 €. Kalkulatu deskontua eta kendu.',
  'La escala dice cuánto es cada centímetro del plano: si 1 cm son 5 m, 4 cm son 4 × 5 = 20 m.':
      'Eskalak planoko zentimetro bakoitza zenbat den esaten du: 1 cm 5 m bada, 4 cm 4 × 5 = 20 m dira.',
  'Desde la {a}, baja {a} plantas y llegas al suelo (0).':
      '{a} solairutik, jaitsi {a} solairu eta lurrera iristen zara (0).',
  'Te quedan {r} por bajar: acabas en la −{r}.':
      '{r} geratzen zaizkizu jaisteko: −{r} solairuan amaitzen duzu.',
  'De la {a} al suelo hay {x} plantas.':
      '{a} solairutik lurrera {x} solairu daude.',
  'Del suelo a la {b}, {b} más: {x} + {b} = {r}.':
      'Lurretik {b} solairura, {b} gehiago: {x} + {b} = {r}.',
  '{a} × {k} = {x} y {b} × {k} = {y}.':
      '{a} × {k} = {x} eta {b} × {k} = {y}.',
  'Los dos por el mismo número: misma razón, mismo color.':
      'Biak zenbaki beraz: arrazoi bera, kolore bera.',
  'Cada tanda lleva {a} + {b} = {t} botes.':
      'Txanda bakoitzak {a} + {b} = {t} pote ditu.',
  '{n} ÷ {t} = {k} tandas.':
      '{n} ÷ {t} = {k} txanda.',
  'Azul: {a} × {k} = {x}. Amarillo: {b} × {k} = {y}.':
      'Urdina: {a} × {k} = {x}. Horia: {b} × {k} = {y}.',
  'De {a} a {x} se ha multiplicado por {k}.':
      '{a} zenbakitik {x} zenbakira {k} zenbakiaz biderkatu da.',
  'El otro, igual: {b} × {k} = {y}.':
      'Bestea, berdin: {b} × {k} = {y}.',
  'El {p} % de {x} € es {d} €.':
      '{x} €-ren % {p} {d} € da.',
  'Se resta: {x} − {d} = {r} €.':
      'Kentzen da: {x} − {d} = {r} €.',
  'Cada centímetro son {e} m.':
      'Zentimetro bakoitza {e} m da.',
  '{c} × {e} = {r} m.':
      '{c} × {e} = {r} m.',
  // Rebote y El taller del relojero
  'Rebote':
      'Errebotea',
  'Mide ángulos, dispara el láser para que rebote hasta la diana y dibuja reflejos.':
      'Neurtu angeluak, bota laserra itua jo arte errebota dezan eta marraztu islak.',
  'Los focos de la Industria están desviados. La luz rebota como una pelota: sale como llega.':
      'Industriako fokuak desbideratuta daude. Argiak pilota batek bezala errebotatzen du: iristen den bezala ateratzen da.',
  'Lee el ángulo en el transportador y di cuánto mide o qué tipo es. En el láser, elige el ángulo para que el rayo rebote en el espejo del suelo y dé en la diana: sale del espejo con el mismo ángulo con el que llega. Cuidado con los Destellos. Al final, toca los cuadros para dibujar el reflejo de la figura y pulsa COMPROBAR.':
      'Irakurri angelua garraiagailuan eta esan zenbat neurtzen duen edo zer motatakoa den. Laserrean, aukeratu angelua izpiak lurreko ispiluan errebota dezan eta itua jo dezan: iristen den angelu berarekin ateratzen da ispilutik. Kontuz Distirekin. Amaieran, ukitu laukiak irudiaren isla marrazteko eta sakatu EGIAZTATU.',
  'Diana. El foco vuelve a su sitio.':
      'Itua. Fokua bere lekura itzultzen da.',
  'Sale con {g}°: igual que llegó.':
      '{g}°-rekin ateratzen da: iritsi zen bezala.',
  'Medido y apuntado.':
      'Neurtuta eta idatzita.',
  'Mira dónde empieza el cero del transportador y cuenta desde ahí.':
      'Begiratu garraiagailuaren zeroa non hasten den eta zenbatu hortik.',
  'Compáralo con una esquina de papel: el recto mide 90°.':
      'Konparatu paper-izkina batekin: zuzenak 90° neurtzen ditu.',
  'Un Destello se ha tragado la luz. Con {v}° no llega.':
      'Distira batek argia irentsi du. {v}°-rekin ez da iristen.',
  'Con {v}° el rayo no da en la diana. Prueba otro.':
      '{v}°-rekin izpiak ez du itua jotzen. Probatu beste bat.',
  'El rayo sale del espejo con el mismo ángulo con el que llega.':
      'Izpia iristen den angelu berarekin ateratzen da ispilutik.',
  'El reflejo, exacto: cada cuadro a la misma distancia del espejo.':
      'Isla, zehatza: lauki bakoitza ispilutik distantzia berera.',
  'En rosa, los que sobran; con borde, los que faltan. Cada cuadro, a la misma distancia del espejo.':
      'Arrosaz, soberan daudenak; ertzarekin, falta direnak. Lauki bakoitza, ispilutik distantzia berera.',
  'Seis focos en su sitio. La Industria vuelve a tener luz.':
      'Sei foku bere lekuan. Industriak argia du berriro.',
  '¿Cuántos grados mide el ángulo?':
      'Zenbat gradu neurtzen ditu angeluak?',
  '¿Qué tipo de ángulo es?':
      'Zer motatako angelua da?',
  '¿Con qué ángulo hay que disparar para que rebote en el espejo y dé en la diana?':
      'Zein angelurekin bota behar da ispiluan errebota dezan eta itua jo dezan?',
  'El rayo llega al espejo con {g}°. ¿Con qué ángulo sale?':
      'Izpia {g}°-rekin iristen da ispilura. Zein angelurekin ateratzen da?',
  'Dibuja el reflejo de la figura al otro lado del espejo.':
      'Marraztu irudiaren isla ispiluaren beste aldean.',
  'COMPROBAR':
      'EGIAZTATU',
  'El taller del relojero':
      'Erlojugilearen tailerra',
  'Pesa, llena, corta y pon en hora: los encargos de medida de la Industria.':
      'Pisatu, bete, moztu eta ordua jarri: Industriako neurketa-enkarguak.',
  'Aquí se mide todo. Ojo con las etiquetas: la misma pesa puede venir en gramos o en kilos.':
      'Hemen dena neurtzen da. Kontuz etiketekin: pisu bera gramotan edo kilotan etor daiteke.',
  'Toca las piezas para ponerlas (y tócalas arriba para quitarlas) hasta tener justo lo que pide el encargo; luego ENTREGAR. No verás el total hasta entregar: calcúlalo. En el reloj, elige qué hora será. 1 kg = 1000 g; 1 l = 1000 ml; 1 m = 100 cm; 1 h = 60 min.':
      'Ukitu piezak jartzeko (eta ukitu goian kentzeko) enkarguak eskatzen duena zehazki izan arte; gero ENTREGATU. Ez duzu guztizkoa ikusiko entregatu arte: kalkulatu. Erlojuan, aukeratu zer ordu izango den. 1 kg = 1000 g; 1 l = 1000 ml; 1 m = 100 cm; 1 h = 60 min.',
  'Justo lo que pedían. Al cliente.':
      'Eskatzen zutena zehazki. Bezeroarentzat.',
  'Llevas {x}: sobran {d}. Quita algo.':
      '{x} daramatzazu: {d} soberan. Kendu zerbait.',
  'Llevas {x}: faltan {d}. Añade algo.':
      '{x} daramatzazu: {d} falta dira. Gehitu zerbait.',
  'Las {h}. En hora.':
      '{h}. Orduan.',
  '{o} no. Recuerda: 60 minutos hacen una hora.':
      '{o} ez. Gogoratu: 60 minutuk ordu bat egiten dute.',
  'Seis encargos servidos. El taller cierra a su hora.':
      'Sei enkargu zerbitzatuta. Tailerra bere orduan ixten da.',
  'Corta una varilla de {o}.':
      'Moztu {o}-ko hagatxo bat.',
  'Pon en la báscula {o}.':
      'Jarri balantzan {o}.',
  'Llena la probeta con {o}.':
      'Bete probeta {o}-rekin.',
  'Son las {h}. ¿Qué hora será dentro de {s}?':
      '{h} dira. Zer ordu izango da {s} barru?',
  'Toca las piezas de abajo para ponerlas.':
      'Ukitu beheko piezak jartzeko.',
  'Pon el centro del transportador en el vértice y el 0 sobre un lado; lee dónde cae el otro. En un espejo, el rayo sale con el mismo ángulo con el que llega.':
      'Jarri garraiagailuaren erdigunea erpinean eta 0a alde baten gainean; irakurri bestea non erortzen den. Ispilu batean, izpia iristen den angelu berarekin ateratzen da.',
  'Agudo: menos de 90°. Recto: 90°, una esquina de papel. Obtuso: entre 90° y 180°. Llano: 180°, una línea recta.':
      'Zorrotza: 90° baino gutxiago. Zuzena: 90°, paper-izkina bat. Kamutsa: 90° eta 180° artean. Laua: 180°, lerro zuzen bat.',
  'En un reflejo, cada punto queda a la misma distancia del espejo, pero al otro lado: si está a 2 cuadros, su reflejo también.':
      'Isla batean, puntu bakoitza ispilutik distantzia berera geratzen da, baina beste aldean: 2 laukira badago, bere isla ere bai.',
  '1 m = 10 dm = 100 cm. 1,35 m son 1 m y 35 cm: 135 cm.':
      '1 m = 10 dm = 100 cm. 1,35 m 1 m eta 35 cm dira: 135 cm.',
  '1 kg = 1000 g y 1 l = 1000 ml. 1,75 kg son 1750 g; medio kilo, 500 g; un cuarto, 250 g.':
      '1 kg = 1000 g eta 1 l = 1000 ml. 1,75 kg 1750 g dira; kilo erdia, 500 g; laurdena, 250 g.',
  'Suma primero los minutos; si pasan de 60, son una hora más. 10:40 + 35 min = 10:75 = 11:15. Luego suma las horas.':
      'Batu lehenik minutuak; 60 gainditzen badituzte, ordu bat gehiago da. 10:40 + 35 min = 10:75 = 11:15. Gero batu orduak.',
  'El rayo llega al espejo con {g}°.':
      'Izpia {g}°-rekin iristen da ispilura.',
  'Rebota como una pelota: sale con los mismos {g}°, hacia el otro lado.':
      'Pilota batek bezala errebotatzen du: {g}° berberekin ateratzen da, beste aldera.',
  'Compáralo con 90° (una esquina) y con 180° (una recta).':
      'Konparatu 90°-rekin (izkina bat) eta 180°-rekin (lerro zuzen bat).',
  '{g}° es menos que 90°: agudo.':
      '{g}° 90° baino gutxiago da: zorrotza.',
  '{g}° es justo una esquina: recto.':
      '{g}° izkina bat da justu: zuzena.',
  '{g}° está entre 90° y 180°: obtuso.':
      '{g}° 90° eta 180° artean dago: kamutsa.',
  '{g}° es una línea recta: llano.':
      '{g}° lerro zuzen bat da: laua.',
  'Un cuadro está a {d} del espejo.':
      'Lauki bat ispilutik {d} laukira dago.',
  'Su reflejo, a {d} del espejo por el otro lado, en la misma fila.':
      'Bere isla, ispilutik {d} laukira beste aldean, errenkada berean.',
  '100 cm son 1 m.':
      '100 cm 1 m dira.',
  '{c} cm = {m} m {r} cm = {d} m.':
      '{c} cm = {m} m {r} cm = {d} m.',
  '1000 g son 1 kg.':
      '1000 g 1 kg dira.',
  '{g} g = {k} kg y {r} g = {d} kg.':
      '{g} g = {k} kg eta {r} g = {d} kg.',
  'Minutos: {a} + {b} = {t}.':
      'Minutuak: {a} + {b} = {t}.',
  '{t} minutos son 1 hora y {r} minutos: las {h}:{m}.':
      '{t} minutu ordu 1 eta {r} minutu dira: {h}:{m}.',
  // La hornada, El telar y El tranvía
  'La hornada':
      'Labealdia',
  'Empaqueta el pan justo: fracciones, impropias, mixtos y bandejas cortadas de otra manera.':
      'Ontziratu ogi zehatza: zatikiak, inpropioak, mistoak eta beste era batera moztutako erretiluak.',
  'Sale la hornada de los Tejados. Los pedidos vienen escritos de mil maneras; el pan, cortado de otra.':
      'Teilatuetako labealdia ateratzen da. Eskaerak mila eratara idatzita datoz; ogia, beste batera moztuta.',
  'Toca los trozos de pan para meterlos en la caja (y otra vez para sacarlos) hasta tener justo el pedido; luego ENTREGAR. 11/4 son 2 panes y 3 cuartos. Si la bandeja está cortada en octavos y piden 3/4, piensa cuántos octavos son.':
      'Ukitu ogi-zatiak kutxan sartzeko (eta berriro ateratzeko) eskaera zehazki izan arte; gero ENTREGATU. 11/4 2 ogi eta 3 laurden dira. Erretilua zortzirenetan moztuta badago eta 3/4 eskatzen badute, pentsatu zenbat zortziren diren.',
  'Ojo, que los Impropios parecen poca cosa.':
      'Kontuz, Inpropioek gutxi dirudite eta.',
  'Esta bandeja no está cortada como el pedido. Piénsalo.':
      'Erretilu hau ez dago eskaera bezala moztuta. Pentsatu.',
  '{k} trozos de {d}: justo el pedido. A la caja.':
      '{d} zatitik {k}: eskaera zehazki. Kutxara.',
  'Llevas {k} trozos de {d}: te has pasado.':
      '{d} zatitik {k} daramatzazu: pasatu zara.',
  'Llevas {k} trozos de {d}: falta pan.':
      '{d} zatitik {k} daramatzazu: ogia falta da.',
  '{k} trozos de los {d} de un pan: {k}/{d}.':
      'Ogi baten {d} zatietatik {k}: {k}/{d}.',
  'Cuenta los trozos de la caja (arriba) y en cuántos está cortado el pan (abajo).':
      'Zenbatu kutxako zatiak (goian) eta ogia zenbat zatitan dagoen moztuta (behean).',
  'Seis pedidos servidos. Huele a pan en todos los Tejados.':
      'Sei eskaera zerbitzatuta. Teilatu guztietan ogi usaina dago.',
  '¿Cuánto pan hay en la caja?':
      'Zenbat ogi dago kutxan?',
  'Pedido: {p} de pan. Toca los trozos para meterlos en la caja.':
      'Eskaera: {p} ogi. Ukitu zatiak kutxan sartzeko.',
  'y':
      'eta',
  'El telar':
      'Ehungailua',
  'Multiplica y divide fracciones con telas, hilos y cintas.':
      'Biderkatu eta zatitu zatikiak oihal, hari eta zintekin.',
  'En el telar se cruzan hilos. Lo que se cruza, eso es multiplicar.':
      'Ehungailuan hariak gurutzatzen dira. Gurutzatzen dena, hori da biderkatzea.',
  'Lee el encargo y elige el resultado. Al acertar, la tela lo enseña: varias telas juntas, los hilos cruzados (el trozo que se cruza es el resultado), el reparto o las cintas cortadas.':
      'Irakurri enkargua eta aukeratu emaitza. Asmatzean, oihalak erakusten du: hainbat oihal elkarrekin, hari gurutzatuak (gurutzatzen den zatia da emaitza), banaketa edo moztutako zintak.',
  'Lo que se cruza es el resultado: mira la tela.':
      'Gurutzatzen dena da emaitza: begiratu oihala.',
  'Cortadas y contadas.':
      'Moztuta eta zenbatuta.',
  'Tela medida. Al telar.':
      'Oihala neurtuta. Ehungailura.',
  'Junta las telas: se suman los trozos, el tamaño del trozo no cambia.':
      'Elkartu oihalak: zatiak batzen dira, zatiaren tamaina ez da aldatzen.',
  'Por fracción: arriba por arriba y abajo por abajo. No se suma nada.':
      'Zatikiaz: goikoa goikoaz eta behekoa behekoaz. Ez da ezer batzen.',
  'Repartir entre varios hace los trozos más pequeños: el de abajo crece.':
      'Hainbaten artean banatzeak zatiak txikiagoak egiten ditu: behekoa handitzen da.',
  'Cuenta cuántas cintas de ese largo caben en la tela.':
      'Zenbatu luzera horretako zenbat zinta sartzen diren oihalean.',
  'Seis telas tejidas. Las Polillas se quedan sin cena.':
      'Sei oihal ehunduta. Sitsak afaririk gabe geratzen dira.',
  '{k} telas de {f} de metro. ¿Cuánta tela en total?':
      'Metro baten {f}-ko {k} oihal. Zenbat oihal guztira?',
  'Un hilo a {f} del ancho y otro a {g} del alto. ¿Cuánto es {f} × {g}?':
      'Hari bat zabaleraren {f}-ra eta beste bat altueraren {g}-ra. Zenbat da {f} × {g}?',
  'Reparte {f} de tela entre {k}. ¿Cuánto para cada uno?':
      'Banatu {f} oihal {k} lagunen artean. Zenbat bakoitzarentzat?',
  '¿Cuántas cintas de 1/{c} de metro salen de {f} de metro?':
      'Metro baten 1/{c}-ko zenbat zinta ateratzen dira metro baten {f}-tik?',
  'El tranvía':
      'Tranbia',
  'Una línea de tranvía por la recta de los decimales: situar, redondear y pagar el billete.':
      'Tranbia-lerro bat hamartarren zuzenean zehar: kokatu, biribildu eta txartela ordaindu.',
  'El tranvía para en cada décima. Tú dices dónde; el Revisor, cuánto.':
      'Tranbia hamarren bakoitzean gelditzen da. Zuk esaten duzu non; Ikuskariak, zenbat.',
  'Toca la vía para parar el tranvía en una parada: la pedida, o la más cercana al viajero. Cuando sube un Revisor, elige cuánto cuesta el billete. Cuidado con dónde va la coma.':
      'Ukitu bidea tranbia geltoki batean gelditzeko: eskatutakoan, edo bidaiaritik hurbilenekoan. Ikuskari bat igotzen denean, aukeratu txartelak zenbat balio duen. Kontuz koma non doan.',
  'Sube un Revisor. Billete, por favor.':
      'Ikuskari bat igotzen da. Txartela, mesedez.',
  '{v} está más cerca de {r}. Parada.':
      '{v} {r} zenbakitik hurbilago dago. Geltokia.',
  'Parada {r}. Todos abajo.':
      '{r} geltokia. Denak behera.',
  'Paramos en {p}, pero {v} queda más cerca de otra parada.':
      '{p} geltokian gelditzen gara, baina {v} beste geltoki batetik hurbilago dago.',
  'Esta es la {p}. Busca la {r}.':
      'Hau {p} da. Bilatu {r}.',
  '{o} €. El Revisor se baja contento.':
      '{o} €. Ikuskaria pozik jaisten da.',
  '{o} € no. Mira bien dónde va la coma.':
      '{o} € ez. Begiratu ondo koma non doan.',
  'Seis viajes sin perder ni una parada. Última estación.':
      'Sei bidaia geltoki bat ere galdu gabe. Azken geltokia.',
  'Lleva el tranvía a la parada {v}. Toca la vía.':
      'Eraman tranbia {v} geltokira. Ukitu bidea.',
  'El viajero va a {v}. ¿En qué parada (número entero) baja, la más cercana?':
      'Bidaiaria {v}-ra doa. Zein geltokitan (zenbaki osoa) jaisten da, hurbilenean?',
  'El viajero va a {v}. ¿En qué parada de décimas baja, la más cercana?':
      'Bidaiaria {v}-ra doa. Hamarrenetako zein geltokitan jaisten da, hurbilenean?',
  'Billete: {k} viajes de {p} €. ¿Cuánto es?':
      'Txartela: {p} €-ko {k} bidaia. Zenbat da?',
  'Billete: el {a} del precio de {b} €. ¿Cuánto es?':
      'Txartela: {b} €-ko prezioaren {a}. Zenbat da?',
  'Billete: {p} € entre {k} viajeros. ¿Cuánto paga cada uno?':
      'Txartela: {p} € {k} bidaiarien artean. Zenbat ordaintzen du bakoitzak?',
  'El de abajo dice en cuántos trozos iguales se corta el pan; el de arriba, cuántos coges. 3/4: pan en 4 trozos, coges 3.':
      'Behekoak esaten du ogia zenbat zati berdinetan mozten den; goikoak, zenbat hartzen dituzun. 3/4: ogia 4 zatitan, 3 hartzen dituzu.',
  'Para escribir lo que hay: arriba los trozos que tienes, abajo en cuántos está cortado el pan.':
      'Dagoena idazteko: goian dituzun zatiak, behean ogia zenbat zatitan dagoen moztuta.',
  'Una impropia tiene más trozos que un pan entero: 11/4 son 8/4 (2 panes) y 3/4. Divide 11 entre 4: 2 y sobran 3.':
      'Inpropio batek ogi oso batek baino zati gehiago ditu: 11/4 8/4 (2 ogi) eta 3/4 dira. Zatitu 11 4rekin: 2 eta 3 soberan.',
  'Un mixto se pasa a trozos: 2 y 3/4 son 2 × 4 + 3 = 11 cuartos.':
      'Misto bat zatietara pasatzen da: 2 eta 3/4 2 × 4 + 3 = 11 laurden dira.',
  'Simplificar es juntar trozos: 6/8 = 3/4, dividiendo arriba y abajo entre 2.':
      'Sinplifikatzea zatiak elkartzea da: 6/8 = 3/4, goian eta behean 2rekin zatituz.',
  'Amplificar es partir los trozos: 3/4 = 6/8, multiplicando arriba y abajo por 2.':
      'Anplifikatzea zatiak zatitzea da: 3/4 = 6/8, goian eta behean 2rekin biderkatuz.',
  'Fracción por número: multiplica sólo el de arriba. 3 × 2/5 = 6/5.':
      'Zatikia bider zenbakia: biderkatu goikoa bakarrik. 3 × 2/5 = 6/5.',
  'Fracción por fracción: arriba por arriba y abajo por abajo. 3/4 × 2/3 = 6/12.':
      'Zatikia bider zatikia: goikoa goikoaz eta behekoa behekoaz. 3/4 × 2/3 = 6/12.',
  'Repartir entre un número hace los trozos más pequeños: se multiplica el de abajo. 3/4 entre 3 = 3/12 = 1/4.':
      'Zenbaki batekin banatzeak zatiak txikiagoak egiten ditu: behekoa biderkatzen da. 3/4 zati 3 = 3/12 = 1/4.',
  'Cuántas veces cabe: 3/2 entre 1/4 es contar cuartos en tres medios: 6.':
      'Zenbat aldiz sartzen den: 3/2 zati 1/4 hiru erditan laurdenak zenbatzea da: 6.',
  'Entre 1 y 2 hay diez décimas: 1,1; 1,2… 1,9. La primera cifra tras la coma son las décimas.':
      '1 eta 2 artean hamar hamarren daude: 1,1; 1,2… 1,9. Komaren ondorengo lehen zifra hamarrenak dira.',
  'Para redondear a la décima, mira la centésima: si es 5 o más, sube; si no, se queda. 2,46 → 2,5; 2,43 → 2,4.':
      'Hamarrenera biribiltzeko, begiratu ehunenari: 5 edo gehiago bada, igo; bestela, geratu. 2,46 → 2,5; 2,43 → 2,4.',
  'Multiplica como si no hubiera coma y luego pon tantas cifras decimales como tenía: 3 × 1,25 → 3 × 125 = 375 → 3,75.':
      'Biderkatu komarik ez balego bezala eta gero jarri zituen hainbat zifra hamartar: 3 × 1,25 → 3 × 125 = 375 → 3,75.',
  'Decimal por decimal: cuenta las cifras decimales de los dos. 0,6 × 2,5 → 6 × 25 = 150 → dos decimales: 1,50.':
      'Hamartarra bider hamartarra: zenbatu bien zifra hamartarrak. 0,6 × 2,5 → 6 × 25 = 150 → bi hamartar: 1,50.',
  'Dividir entre un número: reparte como siempre y pon la coma cuando llegues a ella. 7,5 entre 3 = 2,5.':
      'Zenbaki batekin zatitzea: banatu beti bezala eta jarri koma hara iristean. 7,5 zati 3 = 2,5.',
  'El pan se corta en {d} trozos iguales: eso es el de abajo.':
      'Ogia {d} zati berdinetan mozten da: hori da behekoa.',
  'Se cogen {n}: eso es el de arriba. {n}/{d}.':
      '{n} hartzen dira: hori da goikoa. {n}/{d}.',
  '{n} ÷ {d} = {e} y sobran {r}.':
      '{n} ÷ {d} = {e} eta {r} soberan.',
  '{e} panes enteros y {r}/{d}.':
      '{e} ogi oso eta {r}/{d}.',
  'Cada pan son {d} trozos: {e} × {d} = {p}.':
      'Ogi bakoitza {d} zati da: {e} × {d} = {p}.',
  'Más los {r} sueltos: {p} + {r} = {t}. Son {t}/{d}.':
      'Gehi {r} solteak: {p} + {r} = {t}. {t}/{d} dira.',
  'Arriba y abajo se pueden dividir entre {k}.':
      'Goikoa eta behekoa {k} zenbakiaz zatitu daitezke.',
  '{a} ÷ {k} = {n}; {b} ÷ {k} = {d}. Queda {n}/{d}.':
      '{a} ÷ {k} = {n}; {b} ÷ {k} = {d}. {n}/{d} geratzen da.',
  'De {d} a {e} se multiplica por {k}.':
      '{d} zenbakitik {e} zenbakira {k} zenbakiaz biderkatzen da.',
  'Arriba igual: {n} × {k} = {r}. {r}/{e}.':
      'Goian berdin: {n} × {k} = {r}. {r}/{e}.',
  '{k} veces {n} trozos: {k} × {n} = {r} trozos.':
      '{k} aldiz {n} zati: {k} × {n} = {r} zati.',
  'Los trozos siguen siendo de 1/{d}: {r}/{d}.':
      'Zatiak 1/{d}-koak dira oraindik: {r}/{d}.',
  'Arriba por arriba: {a} × {c} = {x}.':
      'Goikoa goikoaz: {a} × {c} = {x}.',
  'Abajo por abajo: {b} × {d} = {y}. Resultado: {x}/{y}.':
      'Behekoa behekoaz: {b} × {d} = {y}. Emaitza: {x}/{y}.',
  'Repartir entre {k} hace cada trozo {k} veces más pequeño.':
      '{k} lagunen artean banatzeak zati bakoitza {k} aldiz txikiagoa egiten du.',
  'El de abajo se multiplica: {d} × {k} = {e}. Cada uno, {n}/{e}.':
      'Behekoa biderkatzen da: {d} × {k} = {e}. Bakoitzak, {n}/{e}.',
  'En cada metro caben {c} cintas de 1/{c}.':
      'Metro bakoitzean 1/{c}-ko {c} zinta sartzen dira.',
  '{a}/{b} de metro: {a} × {c} ÷ {b} = {r} cintas.':
      'Metro baten {a}/{b}: {a} × {c} ÷ {b} = {r} zinta.',
  'Está entre {a} y {b}.':
      '{a} eta {b} artean dago.',
  'Cuenta {d} décimas desde el {a}.':
      'Zenbatu {d} hamarren {a} zenbakitik aurrera.',
  'Mira la centésima: {c}.':
      'Begiratu ehunenari: {c}.',
  'Es 5 o más: la décima sube. Queda {r}.':
      '5 edo gehiago da: hamarrena igotzen da. {r} geratzen da.',
  'Es menos de 5: la décima se queda. Queda {r}.':
      '5 baino gutxiago da: hamarrena geratzen da. {r} geratzen da.',
  'Sin coma: {k} × {p} = {r}.':
      'Komarik gabe: {k} × {p} = {r}.',
  'Dos cifras decimales: {d}.':
      'Bi zifra hamartar: {d}.',
  'Sin comas: {a} × {b} = {r}.':
      'Komarik gabe: {a} × {b} = {r}.',
  'Una decimal más otra: dos cifras decimales, {d}.':
      'Hamartar bat gehi beste bat: bi zifra hamartar, {d}.',
  'Sin coma: {p} ÷ {k} = {r}.':
      'Komarik gabe: {p} ÷ {k} = {r}.',
  'Tenía una cifra decimal: {d}.':
      'Zifra hamartar bat zuen: {d}.',
  // Pinturas
  'Multiplica en cruz: {a} × {s} = {x} y {b} × {t} = {y}.':
      'Biderkatu gurutzean: {a} × {s} = {x} eta {b} × {t} = {y}.',
  // Depósitos y Andamios
  'Depósitos':
      'Biltegiak',
  'Llena los depósitos de la Industria: cubitos por capas, litros y tapas redondas de tubería.':
      'Bete Industriako biltegiak: kubotxoak geruzaka, litroak eta hodietako tapa biribilak.',
  'La Industria se calienta. Pide el agua justa: lo que sobra, las Fugas lo tiran al suelo.':
      'Industria berotzen ari da. Eskatu ur zehatza: soberan dagoena, Ihesek lurrera botatzen dute.',
  'Lee el depósito y elige cuánto cabe. Al acertar se llena capa a capa. Cada capa son largo × ancho cubitos; hay tantas capas como alto. Un litro es un cubo de 10 cm de lado. En las tuberías, la valla es la vuelta (2 × 3,14 × radio) y la tapa, la superficie (3,14 × radio × radio).':
      'Irakurri biltegia eta aukeratu zenbat sartzen den. Asmatzean geruzaka betetzen da. Geruza bakoitza luzera × zabalera kubotxo da; altuera adina geruza daude. Litro bat 10 cm-ko aldeko kuboa da. Hodietan, hesia bira da (2 × 3,14 × erradioa) eta tapa, azalera (3,14 × erradioa × erradioa).',
  'Andamios':
      'Aldamioak',
  'Plataformas cuadradas y escaleras justas para subir a las farolas de la Montaña.':
      'Plataforma karratuak eta eskailera zehatzak Mendiko farolara igotzeko.',
  'Arriba sopla. Con la medida justa, los Vértigos no mueven nada.':
      'Goian haizea dabil. Neurri zehatzarekin, Zorabioek ez dute ezer mugitzen.',
  'Elige la medida entre cuatro. La plataforma o la escalera que elijas se dibuja tal cual: si no es justa, no llega, se pasa o se tambalea. El lado de un cuadrado es el número que, multiplicado por sí mismo, da el área. En una escalera apoyada, escalera² = pared² + suelo².':
      'Aukeratu neurria lauren artean. Aukeratzen duzun plataforma edo eskailera den bezala marrazten da: zehatza ez bada, ez da iristen, pasatu egiten da edo dardarka hasten da. Karratu baten aldea, bere buruaz biderkatuta, azalera ematen duen zenbakia da. Eskailera bermatu batean, eskailera² = horma² + lurra².',
  'Volumen de una caja: cuenta los cubitos de una capa (largo × ancho) y multiplica por las capas (alto). 4 × 3 × 2 = 24. No se suman.':
      'Kutxa baten bolumena: zenbatu geruza bateko kubotxoak (luzera × zabalera) eta biderkatu geruzekin (altuera). 4 × 3 × 2 = 24. Ez dira batzen.',
  'Con π ≈ 3,14: la vuelta del círculo es 2 × 3,14 × radio; la superficie, 3,14 × radio × radio. Radio 3: vuelta 18,84; superficie 28,26.':
      'π ≈ 3,14 hartuta: zirkuluaren bira 2 × 3,14 × erradioa da; azalera, 3,14 × erradioa × erradioa. 3 erradioa: bira 18,84; azalera 28,26.',
  'La raíz cuadrada busca el número que, multiplicado por sí mismo, da el que tienes: √49 = 7 porque 7 × 7 = 49. No es la mitad.':
      'Erro karratuak, bere buruaz biderkatuta, daukazuna ematen duen zenbakia bilatzen du: √49 = 7, 7 × 7 = 49 delako. Ez da erdia.',
  'En un triángulo rectángulo, el lado largo al cuadrado es la suma de los otros dos al cuadrado: 6² + 8² = 36 + 64 = 100 = 10². Sumar 6 + 8 da de más.':
      'Triangelu zuzen batean, alde luzea ber bi beste bien karratuen batura da: 6² + 8² = 36 + 64 = 100 = 10². 6 + 8 batzeak gehiegi ematen du.',
  'Una capa: {l} × {a} = {c} cubitos.':
      'Geruza bat: {l} × {a} = {c} kubotxo.',
  '{h} capas: {c} × {h} = {v} cubitos.':
      'Geruzak {h}: {c} × {h} = {v} kubotxo.',
  'Superficie: 3,14 × {r} × {r} = 3,14 × {c}.':
      'Azalera: 3,14 × {r} × {r} = 3,14 × {c}.',
  'Vuelta: 2 × 3,14 × {r} = 6,28 × {r}.':
      'Bira: 2 × 3,14 × {r} = 6,28 × {r}.',
  'Sale {x}.':
      'Emaitza: {x}.',
  'Busca un número que por sí mismo dé {a}.':
      'Bilatu bere buruaz biderkatuta {a} ematen duen zenbaki bat.',
  '{l} × {l} = {a}: la raíz es {l}.':
      '{l} × {l} = {a}: erroa {l} da.',
  'Al cuadrado: {a}² + {b}² = {x} + {y} = {s}.':
      'Karratura: {a}² + {b}² = {x} + {y} = {s}.',
  '¿Qué número por sí mismo da {s}? {c}.':
      'Zein zenbakik ematen du {s} bere buruaz biderkatuta? {c}.',
  'Capa a capa, lleno hasta arriba.':
      'Geruzaz geruza, goraino beteta.',
  'Cada litro es un cubo de 10 cm de lado. Lleno.':
      'Litro bakoitza 10 cm-ko aldeko kuboa da. Beteta.',
  'Tubería medida. La Industria se enfría.':
      'Hodia neurtuta. Industria hozten ari da.',
  'Las Fugas: eso no cabe, se sale por el borde. Cuenta una capa y multiplica por las capas.':
      'Ihesak: hori ez da sartzen, ertzetik irteten da. Zenbatu geruza bat eta biderkatu geruzekin.',
  'Falta agua. Cuenta una capa y multiplica por las capas.':
      'Ura falta da. Zenbatu geruza bat eta biderkatu geruzekin.',
  'Multiplica las tres medidas y pasa a litros: 1 litro son 1000 cm³.':
      'Biderkatu hiru neurriak eta pasatu litrotara: litro bat 1000 cm³ da.',
  'La valla es la vuelta: 2 × 3,14 × el radio. Nada al cuadrado.':
      'Hesia bira da: 2 × 3,14 × erradioa. Ezer ez karratura.',
  'La tapa es la superficie: 3,14 × el radio × el radio.':
      'Tapa azalera da: 3,14 × erradioa × erradioa.',
  'Seis depósitos llenos y ni una gota por el suelo. Las Fugas se secan.':
      'Sei biltegi beteta eta tanta bat ere ez lurrean. Ihesak lehortzen dira.',
  'Un depósito de {l} × {a} × {h} cubitos. ¿Cuántos cubitos caben?':
      'Biltegi bat: {l} × {a} × {h} kubotxo. Zenbat kubotxo sartzen dira?',
  'Un depósito de {l} × {a} × {h} cm. ¿Cuántos litros caben?':
      'Biltegi bat: {l} × {a} × {h} cm. Zenbat litro sartzen dira?',
  'Una tapa de tubería de radio {r} m. ¿Cuántos metros de valla la rodean? (π ≈ 3,14)':
      'Hodi-tapa bat, erradioa {r} m. Zenbat metro hesik inguratzen dute? (π ≈ 3,14)',
  'Una tapa de tubería de radio {r} m. ¿Cuántos m² de chapa la cubren? (π ≈ 3,14)':
      'Hodi-tapa bat, erradioa {r} m. Zenbat m² txapak estaltzen dute? (π ≈ 3,14)',
  'Lado justo. La plataforma no se mueve.':
      'Alde zehatza. Plataforma ez da mugitzen.',
  'Justa. Ni el viento la mueve. A arreglar la farola.':
      'Zehatza. Haizeak ere ez du mugitzen. Farola konpontzera.',
  'La mitad no: busca el número que multiplicado por sí mismo da el área.':
      'Erdia ez: bilatu bere buruaz biderkatuta azalera ematen duen zenbakia.',
  'Esa plataforma no mide eso. ¿Qué número por sí mismo da el área?':
      'Plataforma horrek ez du hori neurtzen. Zein zenbakik ematen du azalera bere buruaz biderkatuta?',
  'Sumar la pared y el suelo da de más: la escalera va en diagonal. Eleva al cuadrado.':
      'Horma eta lurra batzeak gehiegi ematen du: eskailera diagonalean doa. Egin karratua.',
  'Los Vértigos la mueven: no es justa. Escalera² = pared² + suelo².':
      'Zorabioek mugitzen dute: ez da zehatza. Eskailera² = horma² + lurra².',
  'Restar sin más no vale: suelo² = escalera² − pared².':
      'Kentze hutsak ez du balio: lurra² = eskailera² − horma².',
  'Así no sube lo que tiene que subir. Suelo² = escalera² − pared².':
      'Horrela ez da igo behar duena igotzen. Lurra² = eskailera² − horma².',
  'Seis andamios montados. Las farolas de la Montaña vuelven a dar luz.':
      'Sei aldamio muntatuta. Mendiko farolek argia ematen dute berriro.',
  'Una plataforma cuadrada de {a} m². ¿Cuánto mide su lado?':
      'Plataforma karratu bat, {a} m². Zenbat neurtzen du aldeak?',
  'La farola está a {h} m de alto y el pie de la escalera, a {b} m de la pared. ¿Qué escalera llega justa?':
      'Farola {h} m-ko altueran dago eta eskaileraren oina, hormatik {b} m-ra. Zein eskailera iristen da zehazki?',
  'La escalera mide {c} m y tiene que subir {h} m. ¿A cuántos metros de la pared se apoya?':
      'Eskailerak {c} m neurtzen ditu eta {h} m igo behar ditu. Hormatik zenbat metrora bermatzen da?',
  // Minas: divisores
  'Las minas: divisores de {n}.':
      'Minak: {n} zenbakiaren zatitzaileak.',
  'Sólo divisores de {n}.':
      '{n} zenbakiaren zatitzaileak bakarrik.',
  'Un divisor de 36 cabe en 36 un número exacto de veces: 36 ÷ 9 = 4, así que 9 es divisor. Búscalos por parejas: 1 y 36, 2 y 18, 3 y 12, 4 y 9, 6 y 6. El 24 no: 36 ÷ 24 no es exacto.':
      '36ren zatitzaile bat 36n aldi kopuru zehatz batean sartzen da: 36 ÷ 9 = 4, beraz 9 zatitzailea da. Bilatu bikoteka: 1 eta 36, 2 eta 18, 3 eta 12, 4 eta 9, 6 eta 6. 24 ez: 36 ÷ 24 ez da zehatza.',
  'Busca parejas que multiplicadas den {n}: {p}.':
      'Bilatu biderkatuta {n} ematen duten bikoteak: {p}.',
  'Todos los números de las parejas son divisores: {d}.':
      'Bikoteetako zenbaki guztiak zatitzaileak dira: {d}.',
  // Salto: jerarquía con fracciones y decimales
  'Luego la resta: {a} − {b} = {r}.':
      'Gero kenketa: {a} − {b} = {r}.',
  'Con fracciones, el orden es el mismo: primero × y ÷, luego + y −. 3 + 1/2 × 8: primero 1/2 de 8 = 4, luego 3 + 4 = 7. No (3 + 1/2) × 8.':
      'Zatikiekin, ordena berdina da: lehenik × eta ÷, gero + eta −. 3 + 1/2 × 8: lehenik 8ren 1/2 = 4, gero 3 + 4 = 7. Ez (3 + 1/2) × 8.',
  'Con decimales, lo mismo: primero la multiplicación. 4 + 2,5 × 2: 2,5 × 2 = 5, luego 4 + 5 = 9. Y cuidado con la coma: 2,5 no es 25.':
      'Hamartarrekin, berdin: lehenik biderketa. 4 + 2,5 × 2: 2,5 × 2 = 5, gero 4 + 5 = 9. Eta kontuz komarekin: 2,5 ez da 25.',
  // Puentes: el puente roto
  'Con el mismo denominador se restan los de arriba y el de abajo se queda: 7/8 − 3/8 = 4/8. El de abajo no se resta.':
      'Izendatzaile berarekin goikoak kentzen dira eta behekoa geratu egiten da: 7/8 − 3/8 = 4/8. Behekoa ez da kentzen.',
  'Con denominadores distintos, pásalas primero al mismo: 3/4 − 1/6 → 9/12 − 2/12 = 7/12.':
      'Izendatzaile desberdinekin, lehenik pasatu berera: 3/4 − 1/6 → 9/12 − 2/12 = 7/12.',
  'Mismo denominador: resta los de arriba, {a} − {b} = {r}.':
      'Izendatzaile bera: kendu goikoak, {a} − {b} = {r}.',
  'El de abajo se queda: {r}/{d}.':
      'Behekoa geratu egiten da: {r}/{d}.',
  'Denominador común: {m}. {a}/{b} = {x}/{m} y {c}/{d} = {y}/{m}.':
      'Izendatzaile komuna: {m}. {a}/{b} = {x}/{m} eta {c}/{d} = {y}/{m}.',
  '{x} − {y} = {r}: queda {r}/{m}.':
      '{x} − {y} = {r}: {r}/{m} geratzen da.',
  'Este puente ha salido largo. Quita justo lo que sobra: lo que mide el puente menos lo que mide el hueco.':
      'Zubi hau luzeegia atera da. Kendu soberan dagoena zehazki: zubiaren neurria ken hutsunearen neurria.',
  // Sin prisas
  'Sin prisas: la pieza espera arriba. Muévela y suéltala cuando lo tengas.':
      'Presarik gabe: pieza goian zain dago. Mugitu eta askatu argi duzunean.',
  // Bestiario: familias de la segunda sala
  'Los Oxidados':
      'Herdoilduak',
  'Puerto, en la grúa':
      'Portua, garabian',
  'Óxido con hambre de dientes. Se meten en los engranajes de la grúa y se comen un diente aquí y otro allá, hasta que las marcas ya no vuelven a coincidir.':
      'Hortzen gose den herdoila. Garabiaren engranajeetan sartzen dira eta hortz bat hemen eta beste bat han jaten dute, markak berriro bat etorri ezin diren arte.',
  'Odian el número que comparten dos ruedas. Por eso lo esconden: quien encuentra el mayor divisor común o el primer múltiplo común los deja sin nada que roer.':
      'Bi gurpilek partekatzen duten zenbakia gorroto dute. Horregatik ezkutatzen dute: zatitzaile komunetan handiena edo multiplo komunetan lehena aurkitzen duenak ez die ezer uzten karraskatzeko.',
  'Rexán guarda en un bote una rueda de doce dientes que los Oxidados dejaron en siete. Dice que no la tira porque siete es primo y ya nadie puede quitarle nada más.':
      'Rexánek pote batean gordetzen du Herdoilduek zazpi hortzetan utzi zuten hamabi hortzeko gurpil bat. Ez duela botatzen dio, zazpi lehena delako eta inork ezin diolako ezer gehiago kendu.',
  'Los Signos':
      'Zeinuak',
  'Montaña, en la mina':
      'Mendia, meategian',
  'Viven por debajo del suelo, donde los números llevan un menos delante. No son números malos: son los que cuentan hacia abajo.':
      'Lurraren azpian bizi dira, zenbakiek minus bat daramaten tokian. Ez dira zenbaki txarrak: beherantz zenbatzen dutenak dira.',
  'Su truco es esconder el signo. Si bajas de la planta 3 a la −2 y te olvidas del cero, te quedas un piso corto. Los Signos lo saben y te esperan en el rellano.':
      'Zeinua ezkutatzea da haien trikimailua. 3. solairutik −2ra jaitsi eta zeroaz ahazten bazara, solairu bat laburrago geratzen zara. Zeinuek badakite eta eskailera-buruan zain daude.',
  'En la planta más honda de la mina hay una pared con marcas: −1, −2, −3… hasta donde llega la luz. Nadie sabe quién empezó a contar. Nadie ha llegado al final.':
      'Meategiko solairurik sakonenean markak dituen horma bat dago: −1, −2, −3… argia iristen den arte. Inork ez daki nork hasi zuen zenbatzen. Inor ez da amaierara iritsi.',
  'Los Destellos':
      'Distirak',
  'Industria, en los focos':
      'Industria, fokuetan',
  'Chispas sueltas que se beben la luz. Si el rayo pasa demasiado cerca, se lo tragan. Se esquivan eligiendo bien el ángulo.':
      'Argia edaten duten txinparta solteak. Izpia gertuegi pasatzen bada, irentsi egiten dute. Angelua ondo aukeratuta saihesten dira.',
  'La luz rebota en un espejo igual que llega: el mismo ángulo de ida que de vuelta. Los Destellos no lo entienden y se quedan mirando el reflejo, quietos.':
      'Argiak ispilu batean iristen den bezala egiten du errebote: joaneko angelu bera itzulerakoan. Distirek ez dute ulertzen eta islari begira geratzen dira, geldi.',
  'Vadic dice que en Industria hubo un foco que alumbraba en línea recta hasta el mar. Desde que llegaron los Destellos, la luz dobla esquinas. A Vadic no le gusta nada que doble esquinas.':
      'Vadicek dio Industrian bazela lerro zuzenean itsasoraino argitzen zuen foko bat. Distirak iritsi zirenetik, argiak izkinak biratzen ditu. Vadici ez zaio batere gustatzen izkinak biratzea.',
  'La Maleza':
      'Sasiak',
  'Afueras, en los planos':
      'Kanpoaldea, planoetan',
  'Hierba que brota en las casillas de los planos y no deja construir encima. No muerde. Sólo ocupa sitio.':
      'Planoetako laukietan ateratzen den belarra, gainean eraikitzen uzten ez duena. Ez du hozka egiten. Tokia hartzen du, besterik ez.',
  'Con la Maleza en medio, 24 metros cuadrados ya no caben como 4 por 6, pero sí como 3 por 8. La misma área, otra forma. La Maleza enseña eso sin querer.':
      'Sasiak erdian daudela, 24 metro karratu ez dira sartzen 4 bider 6 bezala, baina bai 3 bider 8 bezala. Azalera bera, beste forma bat. Sasiek hori erakusten dute nahi gabe.',
  'Las casas de las Afueras se levantaron sobre planos mojados. Por eso algunas tienen un rincón torcido: es donde creció la Maleza y alguien no quiso volver a medir.':
      'Kanpoaldeko etxeak plano bustien gainean altxatu ziren. Horregatik dute batzuek txoko oker bat: Sasiak hazi ziren tokia da, eta norbaitek ez zuen berriro neurtu nahi izan.',
  'Los Azarosos':
      'Zorizkoak',
  'Puerto, en el mar':
      'Portua, itsasoan',
  'Peces que cambian de color al saltar. No hacen trampa: son el azar mismo, nadando.':
      'Jauzi egitean kolorez aldatzen diren arrainak. Ez dute tranparik egiten: zoria bera dira, igeri.',
  'Un solo lance no dice nada. Veinte ya cuentan algo. Con la red buena también se puede sacar un pez gris, y eso no quita la razón a quien la eligió.':
      'Sare-jaurtiketa batek ez du ezer esaten. Hogeik zerbait kontatzen dute. Sare onarekin ere arrain gris bat atera daiteke, eta horrek ez dio arrazoia kentzen aukeratu zuenari.',
  'Los pescadores más viejos del Puerto no apuestan nunca. Cuentan. Dicen que el mar no tiene memoria, pero las libretas sí.':
      'Portuko arrantzale zaharrenek ez dute inoiz apusturik egiten. Zenbatu egiten dute. Itsasoak memoriarik ez duela diote, baina koadernoek bai.',
  'El Oleaje':
      'Olatuak',
  'Puerto, en los barcos':
      'Portua, itsasontzietan',
  'Olas que llegan cada cierto rato y empujan el barco hacia la pila más alta. Avisan antes. No rompen nada.':
      'Noizean behin iristen diren eta itsasontzia pilarik altuenerantz bultzatzen duten olatuak. Aurretik abisatzen dute. Ez dute ezer apurtzen.',
  'Un barco bien cargado deja pasar el Oleaje sin moverse. Para eso hay que saber repartir: la media es lo que tendría cada pila si fueran todas iguales.':
      'Ondo kargatutako itsasontzi batek Olatuak mugitu gabe pasatzen uzten ditu. Horretarako banatzen jakin behar da: batez bestekoa pila bakoitzak izango lukeena da, denak berdinak balira.',
  'Hay capitanes que leen el Oleaje en las pilas de contenedores como quien lee un gráfico. No miran el mar. Miran la carga, y saben.':
      'Badira Olatuak edukiontzi-piletan irakurtzen dituzten kapitainak, grafiko bat irakurtzen duenak bezala. Ez diote itsasoari begiratzen. Kargari begiratzen diote, eta badakite.',
  'Los Desteñidos':
      'Koloregabeak',
  'Mercado, en los toldos':
      'Merkatua, toldoetan',
  'Manchas grises que se comen el color de un toldo cuando la mezcla no guarda la receta. El toldo se queda gris, pero se puede repintar.':
      'Nahasketak errezeta gordetzen ez duenean toldo baten kolorea jaten duten orban grisak. Toldoa gris geratzen da, baina berriro margotu daiteke.',
  'Dos de azul por tres de amarillo es el mismo verde que cuatro por seis. Los Desteñidos no soportan que el color se mantenga cuando todo crece a la vez.':
      'Bi urdin hiru horirekin lau sei-rekiko berde bera da. Koloregabeek ezin dute jasan dena batera hazten denean kolorea mantentzea.',
  'En el Mercado cuentan que el primer toldo desteñido fue el de un puesto que subió los precios sin avisar. Desde entonces, cada vez que alguien hace trampa con un porcentaje, algo pierde el color.':
      'Merkatuan kontatzen dute lehen toldo koloregabetua abisatu gabe prezioak igo zituen postu batena izan zela. Harrezkero, norbaitek ehuneko batekin tranpa egiten duen bakoitzean, zerbaitek kolorea galtzen du.',
  'Los Cambiados':
      'Aldatuak',
  'Industria, en el taller':
      'Industria, tailerrean',
  'Piezas con la etiqueta en otra unidad: una pesa de 0,5 kg junto a una de 500 g. Parecen distintas. Son la misma.':
      'Etiketa beste unitate batean duten piezak: 0,5 kg-ko pisu bat 500 g-ko baten ondoan. Desberdinak dirudite. Bera dira.',
  'Algunos Cambiados mienten. Uno dice que 1000 cm son un kilómetro, muy serio. Hay que apartarlo sin enfadarse: sólo le falta subir dos peldaños de la escalera.':
      'Aldatu batzuek gezurra esaten dute. Batek dio 1000 cm kilometro bat direla, oso serio. Haserretu gabe baztertu behar da: eskailerako bi maila igotzea besterik ez zaio falta.',
  'El relojero del taller tiene un reloj que marca las horas en minutos, otro en segundos y otro en días. Dice que así nunca llega tarde, porque siempre hay uno que va bien.':
      'Tailerreko erlojugileak erloju bat du orduak minututan markatzen dituena, beste bat segundotan eta beste bat egunetan. Horrela ez dela inoiz berandu iristen dio, beti dagoelako bat ondo doana.',
  'Los Mudos':
      'Mutuak',
  'Montaña, en la caja negra':
      'Mendia, kutxa beltzean',
  'Números que la caja negra se traga sin devolver. Cada Mudo cuesta un experimento, y los experimentos se acaban.':
      'Kutxa beltzak itzuli gabe irensten dituen zenbakiak. Mutu bakoitzak esperimentu bat balio du, eta esperimentuak amaitu egiten dira.',
  'Callan, pero no esconden la regla. Si entra 1 y sale 5, entra 2 y sale 8, la caja suma de tres en tres. Los Mudos sólo esperan a que alguien lo diga en voz alta.':
      'Isilik daude, baina ez dute araua ezkutatzen. 1 sartu eta 5 ateratzen bada, 2 sartu eta 8, kutxak hiruzka batzen du. Mutuak norbaitek ozen esan dezan zain daude.',
  'Nadie en la Montaña sabe quién construyó la caja. Rexán la encontró ya cerrada. Tiene una teoría: dentro no hay nada, sólo una regla. Y una regla no necesita sitio.':
      'Mendian inork ez daki nork eraiki zuen kutxa. Rexánek itxita aurkitu zuen. Teoria bat du: barruan ez dago ezer, arau bat besterik ez. Eta arau batek ez du tokirik behar.',
  'Las Polillas':
      'Sitsak',
  'Mercado, en el telar':
      'Merkatua, ehungailuan',
  'Se comen la tela que sobra y dejan agujeros donde no hay que mirar. Si te fijas en los agujeros, te equivocas de cuenta.':
      'Soberan dagoen oihala jaten dute eta begiratu behar ez den tokian zuloak uzten dituzte. Zuloetan fijatzen bazara, kontuan huts egiten duzu.',
  'Donde se cruzan dos hilos está la multiplicación: tres cuartos de ancho por dos tercios de alto. Las Polillas nunca muerden ahí. Dicen que sabe raro.':
      'Bi hari gurutzatzen diren tokian dago biderketa: zabaleraren hiru laurden bider altueraren bi heren. Sitsek ez dute inoiz hor hozka egiten. Zapore arraroa duela diote.',
  'La tejedora más vieja del Mercado no tira los retales. Los cose en una manta de trozos iguales. Dice que es la única tela a la que las Polillas no se acercan: está toda contada.':
      'Merkatuko ehule zaharrenak ez ditu oihal-puskak botatzen. Zati berdinetako manta batean josten ditu. Sitsak hurbiltzen ez diren oihal bakarra dela dio: dena zenbatuta dago.',
  'Los Revisores':
      'Ikuskariak',
  'Canales y Mercado, en el tranvía':
      'Kanalak eta Merkatua, tranbian',
  'Suben al tranvía y piden el billete con una cuenta: tres viajes de 1,25, el 0,6 de 2,5, repartir 7,5 entre tres. No multan a nadie. Sólo quieren la cuenta bien hecha.':
      'Tranbiara igotzen dira eta txartela kontu batekin eskatzen dute: 1,25eko hiru bidaia, 2,5en 0,6, 7,5 hiruren artean banatu. Ez diote inori isunik jartzen. Kontua ondo egina nahi dute, besterik ez.',
  'Su manía es la coma. Si la pones un sitio más allá, el billete cuesta diez veces más, y el Revisor te mira por encima de las gafas sin decir nada.':
      'Koma da haien zaletasuna. Toki bat haratago jartzen baduzu, txartelak hamar aldiz gehiago balio du, eta Ikuskariak betaurrekoen gainetik begiratzen dizu ezer esan gabe.',
  'El tranvía para en cada décima. Los Revisores se saben todas las paradas de memoria, hasta las que no existen: la 1,45, la 2,999… Dicen que entre dos paradas siempre cabe otra.':
      'Tranbia hamarren bakoitzean gelditzen da. Ikuskariek geltoki guztiak buruz dakizkite, existitzen ez direnak ere: 1,45, 2,999… Bi geltokiren artean beti sartzen dela beste bat diote.',
  'Los Vértigos':
      'Zorabioak',
  'Montaña, en los andamios':
      'Mendia, aldamioetan',
  'Ráfagas de viento que sólo soplan arriba. Si la escalera no es justa, la hacen temblar. Si lo es, pasan de largo.':
      'Goian bakarrik jotzen duten haize-boladak. Eskailera zehatza ez bada, dardaraz jartzen dute. Zehatza bada, aurrera jarraitzen dute.',
  'Pared y suelo al cuadrado, sumados, son la escalera al cuadrado. Los Vértigos lo saben desde siempre. Por eso no pueden con un 3, un 4 y un 5.':
      'Horma eta lurra ber bi, batuta, eskailera ber bi dira. Zorabioek betidanik dakite. Horregatik ezin dute 3, 4 eta 5 batekin.',
  'Las farolas de la Montaña se apagaron el día que alguien subió con una escalera larga «por si acaso». Rexán lo cuenta a menudo. Nunca dice quién fue.':
      'Mendiko farolak norbait eskailera luze batekin igo zen egunean itzali ziren, «badaezpada». Rexánek maiz kontatzen du. Ez du inoiz esaten nor izan zen.',
  'Las Fugas':
      'Ihesak',
  'Industria, en los depósitos':
      'Industria, biltegietan',
  'Agujeros que aparecen cuando se pide más agua de la que cabe. Lo que sobra, lo tiran al suelo.':
      'Sartzen dena baino ur gehiago eskatzen denean agertzen diren zuloak. Soberan dagoena lurrera botatzen dute.',
  'Un depósito se llena por capas: largo por ancho cubitos en cada una, y tantas capas como alto. Quien cuenta así nunca pide de más, y las Fugas se secan.':
      'Biltegi bat geruzaka betetzen da: luzera bider zabalera kubotxo bakoitzean, eta altuera adina geruza. Horrela zenbatzen duenak ez du inoiz gehiegi eskatzen, eta Ihesak lehortu egiten dira.',
  'Las tuberías de la Industria son redondas porque Vadic dice que el círculo es la forma que más agua guarda con menos chapa. Las Fugas prefieren las esquinas.':
      'Industriako hodiak biribilak dira, Vadicek dioelako zirkulua txapa gutxienarekin ur gehien gordetzen duen forma dela. Ihesek nahiago dituzte izkinak.',
  // Reto de la semana
  'El reto de la semana':
      'Asteko erronka',
  'El atasco':
      'Buxadura',
  'Las barcas se han quedado quietas en el canal, de tres en tres. Nada corre: ordénalas de menor a mayor con calma.':
      'Txalupak geldirik geratu dira kanalean, hiruka. Ezer ez dabil: ordenatu txikienetik handienera lasai.',
  'La rueda loca':
      'Gurpil zoroa',
  'Una de las ruedas tiene un número primo de dientes. Es de las cabezotas: casi nunca coincide con la otra.':
      'Gurpiletako batek hortz kopuru lehena du. Burugogorretakoa da: ia inoiz ez dator bat bestearekin.',
  'Bajo cero':
      'Zero azpitik',
  'Esta semana la Serpiente sólo come cuentas que cruzan el cero. Cuidado con el signo.':
      'Aste honetan Sugeak zeroa gurutzatzen duten kontuak bakarrik jaten ditu. Kontuz zeinuarekin.',
  'Los puentes rotos':
      'Zubi hautsiak',
  'Todos los puentes salen largos. Quita justo lo que sobra.':
      'Zubi guztiak luzeegi ateratzen dira. Kendu soberan dagoena zehazki.',
  'Tierra de divisores':
      'Zatitzaileen lurra',
  'En todos los tableros, las minas son los divisores de un número. Búscalos por parejas.':
      'Taula guztietan, minak zenbaki baten zatitzaileak dira. Bilatu bikoteka.',
  // Retos de la semana: tres especiales más
  'Sin transportador':
      'Garraiatzailerik gabe',
  'Los ángulos se miden a ojo. Luego aparece el transportador y compruebas. Esta semana no puntúa: es para afinar el ojo.':
      'Angeluak begiz neurtzen dira. Gero garraiatzailea agertzen da eta egiaztatzen duzu. Aste honetan ez du punturik ematen: begia fintzeko da.',
  'La doble negación':
      'Ezeztapen bikoitza',
  'Todos los viajes llevan un −(−n). Dos noes en la mina significan sí.':
      'Bidaia guztiek −(−n) bat daramate. Meategian bi ezezkok baietz esan nahi dute.',
  'Casa completa':
      'Etxe osoa',
  'Tres habitaciones que sumen justo lo que pide el encargo, sin pisarse ni pisar la maleza.':
      'Enkarguak eskatzen duena zehazki batzen duten hiru gela, elkar zapaldu gabe eta sasiak zapaldu gabe.',
  'Buen ojo: {g}°.':
      'Begi ona: {g}°.',
  'A ojo engaña. Ahí tienes el transportador: compruébalo y vuelve a elegir.':
      'Begiz engainatzen du. Hor duzu garraiatzailea: egiaztatu eta aukeratu berriro.',
  'A ojo, sin transportador: ¿cuántos grados mide?':
      'Begiz, garraiatzailerik gabe: zenbat gradu neurtzen ditu?',
  'Esa habitación pisa otra. Muévela.':
      'Gela horrek beste bat zapaltzen du. Mugitu.',
  'Habitación {n}: {a} m². Llevas {s} m² de {T}.':
      '{n}. gela: {a} m². {T} m²-tik {s} m² daramatzazu.',
  'Las tres suman {s} m², no {T}. Las borro: prueba otra vez.':
      'Hirurek {s} m² batzen dituzte, ez {T}. Ezabatu egingo ditut: saiatu berriro.',
  'Casa completa: {T} m² justos. Sellada.':
      'Etxe osoa: {T} m² zehazki. Zigilatuta.',
  'Una casa de {v} m² en tres habitaciones, sin pisar maleza.':
      '{v} m²-ko etxe bat hiru gelatan, sasirik zapaldu gabe.',
  'Tres casas completas. Rexán las cuelga en la pared.':
      'Hiru etxe oso. Rexánek horman zintzilikatzen ditu.',
  'PONER LA HABITACIÓN':
      'GELA JARRI',
  // Actualizaciones
  'NUEVA VERSIÓN':
      'BERTSIO BERRIA',
  'Se descarga e instala sin salir del juego.':
      'Jokotik irten gabe deskargatu eta instalatzen da.',
  'AHORA NO':
      'ORAIN EZ',
  'ACTUALIZAR':
      'EGUNERATU',
  'ACTUALIZACIONES':
      'EGUNERATZEAK',
  'Actualizaciones':
      'Eguneratzeak',
  'Versión instalada':
      'Instalatutako bertsioa',
  'Última publicada':
      'Argitaratutako azkena',
  'sin conexión':
      'konexiorik gabe',
  'ninguna todavía':
      'bat ere ez oraindik',
  'Publicada el':
      'Argitaratze-data',
  'Comprobado el':
      'Egiaztatze-data',
  'Hay una versión nueva.':
      'Bertsio berri bat dago.',
  'Tienes la última versión.':
      'Azken bertsioa duzu.',
  'Qué trae':
      'Zer dakar',
  'Descargando…':
      'Deskargatzen…',
  'Descargar e instalar':
      'Deskargatu eta instalatu',
  'Buscar ahora':
      'Bilatu orain',
  'Versión disponible':
      'Bertsio erabilgarria',
  'Tienes instalada la':
      'Instalatuta duzuna:',
  'Toca para actualizar.':
      'Ukitu eguneratzeko.',
  'Actualizar':
      'Eguneratu',
  'Descartar por ahora':
      'Baztertu oraingoz',
  'Se ha abierto el instalador. Confirma la actualización y vuelve a abrir la app.':
      'Instalatzailea ireki da. Berretsi eguneratzea eta ireki berriro aplikazioa.',
  'Se ha abierto la descarga en el navegador.':
      'Deskarga nabigatzailean ireki da.',
  'No se ha podido descargar. Comprueba la conexión y vuelve a probar.':
      'Ezin izan da deskargatu. Egiaztatu konexioa eta saiatu berriro.',
  'Descargada, pero Android no ha dejado abrir el instalador. Permite «instalar apps desconocidas» para esta app en los ajustes del móvil.':
      'Deskargatuta, baina Androidek ez du instalatzailea irekitzen utzi. Baimendu «aplikazio ezezagunak instalatzea» aplikazio honentzat mugikorraren ezarpenetan.',
  // El taller de dibujo
  'Dibuja cómo te imaginas a {n} en un papel, con los colores que quieras. Luego hazle una foto con buena luz: aparecerán así aquí y en su máquina.':
      'Marraztu paper batean nola irudikatzen dituzun {n}, nahi dituzun koloreekin. Gero atera argazki bat argi onarekin: horrela agertuko dira hemen eta haien makinan.',
  'Hacer una foto a mi dibujo':
      'Atera argazki bat nire marrazkiari',
  'Elegir de la galería':
      'Aukeratu galeriatik',
  'No he encontrado el dibujo en esa foto. Prueba con más luz y con el papel entero.':
      'Ez dut marrazkia aurkitu argazki horretan. Saiatu argi gehiagorekin eta paper osoarekin.',
  'No se ha podido abrir la cámara ni la galería.':
      'Ezin izan da kamera edo galeria ireki.',
  'Dibujarlo':
      'Marraztu',
  'Cambiar el dibujo':
      'Aldatu marrazkia',
  'Volver al original':
      'Itzuli jatorrizkora',
  // El taller de dibujo: personajes
  'Dibuja cómo ves a {n} en un papel, con los colores que quieras. Luego hazle una foto con buena luz: aparecerá así en sus escenas.':
      'Marraztu paper batean nola ikusten duzun {n}, nahi dituzun koloreekin. Gero atera argazki bat argi onarekin: horrela agertuko da bere eszenetan.',
  'Así los ves tú. Dibújalos en papel y aparecerán así en sus escenas.':
      'Horrela ikusten dituzu zuk. Marraztu paperean eta horrela agertuko dira beren eszenetan.',
  'Todavía no os conocéis.':
      'Oraindik ez duzue elkar ezagutzen.',
  'La mentora':
      'Tutorea',
  'El rival':
      'Arerioa',
  'Maestra de los Tejados':
      'Teilatuetako Maistra',
  'Maestro de los Canales':
      'Kanaletako Maisua',
  'Maestra del Mercado':
      'Mercadoko Maistra',
  'Maestro de la Industria':
      'Industriako Maisua',
  'Maestro del Puerto':
      'Portuko Maisua',
  'Maestra de las Afueras':
      'Kanpoaldeko Maistra',
  'Aprendiz':
      'Ikastuna',
  // El taller de dibujo: distritos, máquinas y la pared
  'Así lo ves tú. Dibújalo en papel, hazle una foto y aparecerá así en el juego.':
      'Horrela ikusten duzu zuk. Marraztu paperean, atera argazki bat eta horrela agertuko da jokoan.',
  'Personajes':
      'Pertsonaiak',
  'Distritos':
      'Auzoak',
  'Su paisaje de noche':
      'Bere gaueko paisaia',
  'Dibuja cómo ves {n} de noche, con sus edificios y sus luces. Luego hazle una foto con buena luz: será su paisaje.':
      'Marraztu nola ikusten duzun gauez, eraikin eta argiekin: {n}. Gero atera argazki bat argi onarekin: hori izango da bere paisaia.',
  'Dibuja cómo te imaginas la máquina {n}. Luego hazle una foto con buena luz: así estará en la sala de Rexán.':
      'Marraztu nola irudikatzen duzun makina hau: {n}. Gero atera argazki bat argi onarekin: horrela egongo da Rexánen aretoan.',
  'La pared de Rexán':
      'Rexánen horma',
  'Lo que dibujas, colgado en los recreativos.':
      'Marrazten duzuna, jolas-aretoan zintzilik.',
  'Aquí cuelgo lo que me traes. De momento está vacía: los monstruos se dibujan en el bestiario, y el resto en Mi cuaderno, en el taller.':
      'Hemen zintzilikatzen dut ekartzen didazuna. Oraingoz hutsik dago: munstroak bestiarioan marrazten dira, eta gainerakoa Nire koadernoan, tailerrean.',
  'Aquí cuelgo lo que me traes. Es la mejor pared de los recreativos.':
      'Hemen zintzilikatzen dut ekartzen didazuna. Jolas-aretoko hormarik onena da.',
  // El taller de dibujo: encuadre
  'Encuadre':
      'Enkoadraketa',
  'Ajusta el recuadro a tu dibujo: arrastra las esquinas para cambiarlo de tamaño y el centro para moverlo.':
      'Egokitu laukia zure marrazkira: arrastatu izkinak tamaina aldatzeko eta erdigunea mugitzeko.',
  'Toda la foto':
      'Argazki osoa',
  'Usar este encuadre':
      'Erabili enkoadraketa hau',
};
