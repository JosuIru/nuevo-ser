// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Basque (`eu`).
class AppLocalizationsEu extends AppLocalizations {
  AppLocalizationsEu([String locale = 'eu']) : super(locale);

  @override
  String get appTitulo => 'Solera Zunbeltz';

  @override
  String get navHoy => 'Gaur';

  @override
  String get navFincas => 'Finkak';

  @override
  String get navSeguimiento => 'Jarraipena';

  @override
  String get navAjustes => 'Ezarpenak';

  @override
  String get onboardingTitulo => 'Solera Zunbeltz';

  @override
  String get onboardingCuerpo =>
      'Nekazaritza Saiakuntza Guneko tresna: kudeatu finkak, banatu mantentze-lanak eta egin saiakuntzaren jarraipena. Estaldurarik gabe ere funtzionatzen du mendian.';

  @override
  String get onboardingBoton => 'Hasi';

  @override
  String get hoyTitulo => 'Gaur';

  @override
  String hoyResumenTareas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n zeregin zabalik',
      one: 'Zeregin 1 zabalik',
      zero: 'Zereginik gabe',
    );
    return '$_temp0';
  }

  @override
  String get hoyVacio =>
      'Oraindik ez dago ezer erregistratuta. Hasi azpiegitura bat mapan markatuz, Finketan.';

  @override
  String get hoyVerTablero => 'Ikusi zereginak';

  @override
  String get ajustesIdioma => 'Hizkuntza';

  @override
  String get ajustesIdiomaCastellano => 'Gaztelania';

  @override
  String get ajustesIdiomaEuskera => 'Euskara';

  @override
  String get ajustesAcercaDe => 'Honi buruz';

  @override
  String ajustesVersion(String version) {
    return '$version bertsioa';
  }

  @override
  String get ajustesProvisional =>
      'Aurretiazko bertsioa. Sortzen dituen parte eta txostenak orientagarriak dira eta haien formatua baliozkotzeke dago. Paper-lan ofiziala (ustiategi-liburua, PAC koadernoa, trazabilitatea…) geroagoko faseetan iritsiko da.';

  @override
  String get comunGuardar => 'Gorde';

  @override
  String get comunCancelar => 'Utzi';

  @override
  String get comunBorrar => 'Ezabatu';

  @override
  String get comunFecha => 'Data';

  @override
  String get mapaNuevoPunto => 'Puntu berria';

  @override
  String get mapaUsarGps => 'Erabili uneko GPSa';

  @override
  String get mapaUsarCentro => 'Erabili maparen erdigunea';

  @override
  String get mapaElegirFinca => 'Zein finkatan?';

  @override
  String get mapaSinPuntos =>
      'Oraindik ez dago punturik. Ukitu mapa edo sakatu «Puntu berria» lehena markatzeko.';

  @override
  String get mapaTocaParaAnadir => 'Ukitu mapa puntu bat gehitzeko';

  @override
  String get mapaTocaNuevaUbicacion => 'Ukitu puntuaren kokaleku berria';

  @override
  String get puntoRecolocado => 'Puntua birkokatuta';

  @override
  String get fichaRecolocar => 'Kokatu berriro mapan';

  @override
  String get mapaGpsNoDisponible =>
      'GPSa ez dago eskuragarri — bete kokapena eskuz.';

  @override
  String get mapaCapas => 'Geruzak';

  @override
  String get mapaMapa => 'Mapa';

  @override
  String get mapaGps => 'GPS';

  @override
  String get mapaTablero => 'Zereginak';

  @override
  String get puntoNuevoTitulo => 'Azpiegitura-puntu berria';

  @override
  String get puntoFinca => 'Finka';

  @override
  String get puntoTipo => 'Mota';

  @override
  String get puntoNombre => 'Izena';

  @override
  String get puntoEstado => 'Egoera';

  @override
  String get puntoNotas => 'Oharrak';

  @override
  String get puntoFotos => 'Argazkiak';

  @override
  String get puntoLatitud => 'Latitudea';

  @override
  String get puntoLongitud => 'Longitudea';

  @override
  String get puntoGuardado => 'Puntua gordeta';

  @override
  String get fichaPuntoTareas => 'Puntuaren zereginak';

  @override
  String get fichaSinTareas => 'Puntu honetan zereginik ez.';

  @override
  String get fichaNuevaTarea => 'Zeregin berria';

  @override
  String get fichaBorrarPunto => 'Ezabatu puntua';

  @override
  String get fichaCoordenadas => 'Koordenatuak';

  @override
  String get fichaSinCoordenadas => 'Koordenaturik gabe';

  @override
  String get tareaNuevaTitulo => 'Zeregin berria';

  @override
  String get tareaTitulo => 'Izenburua';

  @override
  String get tareaDescripcion => 'Deskribapena';

  @override
  String get tareaResponsable => 'Arduraduna';

  @override
  String get tareaPrioridad => 'Lehentasuna';

  @override
  String get tareaEstado => 'Egoera';

  @override
  String get tareaFechaObjetivo => 'Helburu-data';

  @override
  String get tareaSinFecha => 'Datarik gabe';

  @override
  String get tareaFotosAntes => 'Aurreko argazkiak';

  @override
  String get tareaFotosDespues => 'Ondorengo argazkiak';

  @override
  String get tareaCoste => 'Kostua (€)';

  @override
  String get tareaGuardada => 'Zeregina gordeta';

  @override
  String get tareaTituloObligatorio => 'Jarri izenburua zereginari.';

  @override
  String get tareaRecurrencia => 'Periodikotasuna';

  @override
  String get tareaMarcarHecha => 'Eginda gisa markatu';

  @override
  String get tareaSiguienteGenerada => 'Eginda. Hurrengo zeregina sortu da.';

  @override
  String get tableroTitulo => 'Mantentze-zereginak';

  @override
  String get tableroTodas => 'Guztiak';

  @override
  String get tableroFiltroFinca => 'Finka';

  @override
  String get tableroFiltroEstado => 'Egoera';

  @override
  String get tableroSinTareas => 'Ez dago zereginik iragazki hauekin.';

  @override
  String get tableroPartePdf => 'PDF txostena';

  @override
  String get tableroGenerandoPdf => 'Txostena sortzen…';

  @override
  String get tareaDeFinca => 'Finkaren zeregina';

  @override
  String get parteTitulo => 'Mantentze-txostena';

  @override
  String get parteSubtitulo =>
      'Zunbeltz Nekazaritza Saiakuntza Gunea · BEHIN-BEHINEKO dokumentua';

  @override
  String get parteProvisional =>
      'BEHIN-BEHINEKO DOKUMENTUA — formatua baliozkotzeke.';

  @override
  String parteResumenTareas(int n) {
    return 'Sartutako zereginak: $n';
  }

  @override
  String get parteColPunto => 'Puntua';

  @override
  String get parteColTarea => 'Zeregina';

  @override
  String get parteColResponsable => 'Arduraduna';

  @override
  String get parteColPrioridad => 'Lehentasuna';

  @override
  String get parteColEstado => 'Egoera';

  @override
  String get parteColFecha => 'Helburu-data';

  @override
  String get parteSinResponsable => 'Esleitu gabe';

  @override
  String get segTitulo => 'Jarraipena';

  @override
  String get segIndicadores => 'Aldiko adierazleak';

  @override
  String get segTodasFincas => 'Finka guztiak';

  @override
  String get segAlimentacion => 'Elikadura (kg)';

  @override
  String get segPariciones => 'Erditzeak';

  @override
  String get segProductos => 'Merkaturatutako produktuak';

  @override
  String get segIngresos => 'Sarrerak';

  @override
  String get segGastos => 'Gastuak';

  @override
  String get segBalance => 'Balantzea';

  @override
  String get segPestanaActividad => 'Jarduera';

  @override
  String get segPestanaEconomico => 'Ekonomikoa';

  @override
  String get segNuevaActividad => 'Erregistratu jarduera';

  @override
  String get segNuevoApunte => 'Apunte ekonomikoa';

  @override
  String get segSinRegistros => 'Oraindik erregistrorik ez.';

  @override
  String get segInformePdf => 'Jarraipen-txostena (PDF)';

  @override
  String get segGenerandoInforme => 'Txostena sortzen…';

  @override
  String get actNuevaTitulo => 'Erregistratu jarduera';

  @override
  String get actTipo => 'Jarduera mota';

  @override
  String get actCantidad => 'Kopurua';

  @override
  String get actLote => 'Sorta / artaldea';

  @override
  String get actNotas => 'Oharrak';

  @override
  String get actGuardada => 'Jarduera erregistratuta';

  @override
  String get actCantidadObligatoria => 'Adierazi zerotik gorako kopuru bat.';

  @override
  String get apuNuevoTitulo => 'Apunte ekonomiko berria';

  @override
  String get apuTipo => 'Mota';

  @override
  String get apuConcepto => 'Kontzeptua';

  @override
  String get apuImporte => 'Zenbatekoa (€)';

  @override
  String get apuNotas => 'Oharrak';

  @override
  String get apuGuardado => 'Apuntea gordeta';

  @override
  String get apuImporteObligatorio => 'Adierazi zerotik gorako zenbateko bat.';

  @override
  String get informeSegTitulo => 'Jarraipen-txostena';

  @override
  String informeSegResumenPeriodo(int actividades, int apuntes) {
    return 'Erregistroak: $actividades · apunteak: $apuntes';
  }

  @override
  String get informeSegTablaActividad => 'Jarduera-erregistroak';

  @override
  String get informeSegTablaEconomico => 'Apunte ekonomikoak';

  @override
  String get informeSegColTipo => 'Mota';

  @override
  String get informeSegColCantidad => 'Kopurua';

  @override
  String get informeSegColConcepto => 'Kontzeptua';

  @override
  String get informeSegColImporte => 'Zenbatekoa (€)';

  @override
  String get meteoTitulo => 'Iragarpena';

  @override
  String get meteoHoy => 'Gaur';

  @override
  String get meteoSinConexion =>
      'Ezin izan da iragarpena lortu. Egiaztatu konexioa eta saiatu berriro.';

  @override
  String get meteoReintentar => 'Saiatu berriro';

  @override
  String get meteoOrientativo =>
      'Iragarpen orientagarria (Open-Meteo). Ez du ordezkatzen abeltzainaren ezta albaitariaren irizpidea.';

  @override
  String get avisoHelada => 'Izotza';

  @override
  String get avisoLluvia => 'Euria';

  @override
  String get avisoViento => 'Haize bortitza';

  @override
  String get avisoCalor => 'Beroa';

  @override
  String get avisoBuenManejo => 'Lan egiteko egun ona';

  @override
  String get acercaTitulo => 'Saiakuntza Guneari buruz';

  @override
  String get acercaIntro =>
      'Zunbeltz Nafarroako lehen Nekazaritza eta Abeltzaintza Saiakuntza Gunea da: ekintzaileek abeltzaintza ekologiko estentsiboko proiektu bat denbora-tarte mugatu batean probatzeko inkubagailua, abeltzain adituen laguntzarekin, Zunbeltz (231 ha) eta La Planilla (197 ha) finketan. Nafarroako Gobernuak, Andiako Mankomunitateak eta inguruko udalerriek bultzatua, EBren finantzaketarekin, eta Zunbeltz Elkarteak kudeatua.';

  @override
  String get acercaEnlaces => 'Estekak';

  @override
  String get acercaFuentes => 'Informazioa iturri publikoetatik.';

  @override
  String get navProyectos => 'Proiektuak';

  @override
  String get proyectosTitulo => 'Test-proiektuak';

  @override
  String get proyectosVacio =>
      'Oraindik ez dago proiekturik. Sakatu + lehena gehitzeko.';

  @override
  String get proyectoNuevo => 'Proiektu berria';

  @override
  String get proyectoNombre => 'Proiektuaren izena';

  @override
  String get proyectoPersona => 'Tester pertsona';

  @override
  String get proyectoActividad => 'Jarduera / bertikala';

  @override
  String get proyectoFinca => 'Finka (laguntza)';

  @override
  String get proyectoSinFinca => 'Finkarik gabe';

  @override
  String get proyectoFechaInicio => 'Hasiera';

  @override
  String get proyectoFechaFin => 'Amaiera';

  @override
  String get proyectoGuardado => 'Proiektua gordeta';

  @override
  String get proyectoNombreObligatorio => 'Jarri izena proiektuari.';

  @override
  String get proyectoBorrar => 'Ezabatu proiektua';

  @override
  String get rentTitulo => 'Errentagarritasuna';

  @override
  String get rentVentas => 'Salmentak';

  @override
  String get rentOtrosIngresos => 'Beste sarrera batzuk';

  @override
  String get rentGastos => 'Gastuak';

  @override
  String get rentBalance => 'Balantzea';

  @override
  String get rentMargen => 'Marjina';

  @override
  String get rentProyeccion => 'Urteko proiekzioa';

  @override
  String get detProduccion => 'Ekoizpena';

  @override
  String get detValidacion => 'Balidazioa';

  @override
  String get detComercial => 'Merkaturatzea';

  @override
  String get detEconomico => 'Ekonomikoa';

  @override
  String get detSinDatos => 'Oraindik daturik ez.';

  @override
  String get detInformePdf => 'Proiektuaren txostena (PDF)';

  @override
  String get comNuevaTitulo => 'Salmenta berria';

  @override
  String get comProducto => 'Produktua';

  @override
  String get comCanal => 'Kanala';

  @override
  String get comCantidad => 'Kopurua';

  @override
  String get comUnidad => 'Unitatea';

  @override
  String get comPrecio => 'Unitateko prezioa (€)';

  @override
  String get comIngreso => 'Sarrera (€)';

  @override
  String get comGuardada => 'Salmenta gordeta';

  @override
  String get valNuevaTitulo => 'Produktuaren balidazio berria';

  @override
  String get valDescripcion => 'Zer balidatzen da?';

  @override
  String get valResultado => 'Emaitza';

  @override
  String get valValoracion => 'Balorazioa';

  @override
  String get valSinValorar => 'Baloratu gabe';

  @override
  String get valGuardada => 'Balidazioa gordeta';

  @override
  String get infProyTitulo => 'Test-proiektuaren txostena';

  @override
  String infProyResumen(String nombre, String persona) {
    return 'Proiektua: $nombre · testerra: $persona';
  }

  @override
  String get comparativaPdf => 'Konparaketa (PDF)';

  @override
  String get comparativaTitulo => 'Test-proiektuen konparaketa';

  @override
  String get comparativaColProyecto => 'Proiektua';

  @override
  String get comparativaColTester => 'Testerra';

  @override
  String get comparativaTotal => 'Guztira';

  @override
  String get periodoEtiqueta => 'Aldia';

  @override
  String get periodoTodo => 'Dena';

  @override
  String get periodoAnio => 'Aurten';

  @override
  String get periodoTrimestre => 'Hiruhileko hau';

  @override
  String get periodoTrimestreAnterior => 'Aurreko hiruhilekoa';

  @override
  String get detDesgloseGastos => 'Gastuen banakapena';

  @override
  String get detIvaSoportado => 'Jasandako BEZa';

  @override
  String get detIvaRepercutido => 'Jasanarazitako BEZa';

  @override
  String get apuCategoria => 'Kategoria';

  @override
  String get apuIva => 'BEZ';

  @override
  String get comIva => 'BEZ';

  @override
  String get ivaNoFiscal =>
      'Kalkulu orientagarria. Ez da zerga-aitorpenerako modulua: araubidea (REAGP / orokorra) zuen aholkulariak zehazten du.';

  @override
  String get detExportarCsv => 'Esportatu CSV';

  @override
  String get enviarCoordinador => 'Bidali koordinatzaileari';

  @override
  String get enviarCoordinadorTexto =>
      'Zunbeltz Saiakuntza Guneko koordinatzailearentzako test-proiektuaren txostena.';

  @override
  String get enviarCoordinadorSinDestino =>
      'Konfiguratu koordinatzailearen helbidea Ezarpenetan.';

  @override
  String get enviarCoordinadorAdjuntar => 'Erantsi txostena (hemen sortuta):';

  @override
  String get ajustesCoordinador => 'Koordinatzailea (txostenak bidaltzea)';

  @override
  String get ajustesCoordinadorVacio => 'Konfiguratu gabe';

  @override
  String get coordinadorCorreo => 'Koordinatzailearen helbide elektronikoa';

  @override
  String get ayudaTitulo => 'Laguntza';

  @override
  String get ayudaIntro =>
      'App-a erabiltzeko gida, urratsez urrats. Ukitu atal bat irekitzeko, edo idatzi goian bilatzen duzuna. Galtzen bazara, itzuli atzera goian ezkerrean dagoen geziarekin.';

  @override
  String get ayudaBuscar => 'Bilatu laguntzan';

  @override
  String get ayudaSinResultados =>
      'Ez dago hitz hori duen atalik. Probatu beste batekin: «zeregina», «eremua», «salmenta», «token»…';

  @override
  String get ayudaConsejo => 'Jakitea komeni da';

  @override
  String get ayudaGrupoEmpezar => 'Lehen urratsak';

  @override
  String get ayudaGrupoFincas => 'Finkak eta zereginak';

  @override
  String get ayudaGrupoProyectos => 'Zure test-proiektua';

  @override
  String get ayudaGrupoEquipo => 'Taldean lan egin';

  @override
  String get ayudaGrupoProblemas => 'Zerbaitek huts egiten badu';

  @override
  String get ayudaQueEsT => 'Zer da app hau?';

  @override
  String get ayudaQueEsB =>
      'Zunbeltz Saiakuntza Gunearen tresna da. Bi gauzatarako balio du: zure test-proiektuaren jarraipena egiteko (zer ekoizten duzun, zer saltzen duzun, zer gastatzen duzun eta zer irabazten duzun) eta finkak zaintzeko (mapako azpiegiturak eta haien mantentze-zereginak).\nDena zure mugikorrean gordetzen da, eta mendian estaldurarik gabe ere badabil.';

  @override
  String get ayudaPestanasT => 'App-an mugitu';

  @override
  String get ayudaPestanasB =>
      'Behean lau fitxa dituzu. Ukitu pantailaz aldatzeko:\n• Gaur: laburpena, zabalik dauden zereginekin.\n• Finkak: mapa, puntuekin, eremuekin eta zereginekin.\n• Proiektuak: zure test-prozesua eta zure zenbakiak.\n• Ezarpenak: hizkuntza, laguntza, txostenak bidaltzea eta sinkronizazioa.\nAtzera itzultzeko, erabili goian ezkerrean dagoen gezia.';

  @override
  String get ayudaIdiomaDatosT =>
      'Hizkuntza, argazkiak, eguraldia eta internet';

  @override
  String get ayudaIdiomaDatosB =>
      '• Aldatu gaztelania eta euskara artean Ezarpenak → Hizkuntza atalean.\n• Argazkiak zure mugikorrean bertan gordetzen dira.\n• Finketan, hodeiaren ikonoak (goian) finkako eguraldia irekitzen du: orain nola dagoen, hurrengo 24 orduak, ura (egindako euria, aurreikusitako euria eta lurrak eta larreak galtzen dutena) eta hurrengo 7 egunak. Ukitu egun bat xehetasun gehiago ikusteko.\n• Abisuak: izotza, elurra, ekaitza, euria, haize bortitza, beroa, abereen bero-estresa eta maneiurako egun onak.\n» Dena internetik gabe dabil, eguraldia eta zereginen sinkronizazioa izan ezik. Estaldurarik gabe, eguraldiak deskargatutako azken iragarpena erakusten du, eta noizkoa den adierazten du.';

  @override
  String get ayudaFincasT => 'Puntu bat markatu mapan';

  @override
  String get ayudaFincasB =>
      'Puntua azpiegitura bakoitza da: aska, manga, hesia, aterpea, urmaela…\n1. Sartu Finketan.\n2. Ukitu mapan leku zehatza. Edo sakatu «Puntu berria» (behean eskuinean) eta aukeratu «Erabili uneko GPSa» instalazioaren ondoan bazaude, edo «Erabili maparen erdigunea».\n3. Aukeratu mota eta egoera, jarri izena eta, nahi baduzu, gehitu argazkiak.\n4. Sakatu Gorde.\n» Puntuaren koloreak egoera adierazten du: berdea, operatiboa; okrea, berrikusteke; gorrixka, matxuratuta. «GPS» botoiak mapa zugan zentratzen du, eta «Geruzak» botoiak mapa eta satelitea txandakatzen ditu.';

  @override
  String get ayudaZonasT => 'Eremu bat marraztu (saila, hesitua…)';

  @override
  String get ayudaZonasB =>
      '1. Finketan, sakatu «Eremua marraztu».\n2. Ukitu mapan eremuaren izkinak, bata bestearen atzetik. Oker bazabiltza, sakatu «Desegin».\n3. Hiru izkina edo gehiago dituzunean, sakatu «Eremua itxi».\n4. Aukeratu finka, mota (larre-saila, hesitua, alha-eremua…), izena eta egoera, eta gorde.\n» Marrazkitik ateratzen den azalera gutxi gorabeherakoa da. SIGPAC barrutiaren azalera ofiziala baduzu, jarri «SIGPAC azalera ofiziala» eremuan eta hori erabiliko da.';

  @override
  String get ayudaEditarMapaT => 'Puntu edo eremu bat mugitu edo ezabatu';

  @override
  String get ayudaEditarMapaB =>
      '1. Ukitu mapan puntua edo eremua haren fitxa irekitzeko.\n2. Puntu bat mugitzeko: sakatu «Kokatu berriro mapan» (goian) eta ukitu leku berria.\n3. Eremu bat zuzentzeko: sakatu «Berriro marraztu» (goian) eta markatu berriro haren izkinak.\n4. Ezabatzeko: sakatu zakarrontzia eta berretsi.';

  @override
  String get ayudaTareasT => 'Mantentze-zeregin bat apuntatu';

  @override
  String get ayudaTareasB =>
      '1. Ireki puntu edo eremu baten fitxa eta sakatu «Zeregin berria».\n2. Idatzi zer egin behar den. Nahi baduzu, gehitu arduraduna, lehentasuna, helburu-data, aurreko eta ondorengo argazkiak eta kostua.\n3. Sakatu Gorde.\n» Zeregina puntu edo eremu horri lotuta geratzen da: haren fitxan eta zereginen taulan ikusiko duzu.';

  @override
  String get ayudaRecurrentesT => 'Errepikatzen diren zereginak';

  @override
  String get ayudaRecurrentesB =>
      'Beti egiten dena (askak betetzea, hesia berrikustea…) ez da aldi bakoitzean apuntatu behar.\n1. Zeregina sortzean, aukeratu «Periodikotasuna»: egunero, astero, 15 egunero, hilero edo hiruhilero.\n2. Eginda gisa markatzen duzunean, app-ak berak sortzen du hurrengoa, dagokion datarekin.\n» Zerrendan, zeregin periodikoek errepikatzeko ikurra dute.';

  @override
  String get ayudaTableroT => 'Zereginak egunean eraman';

  @override
  String get ayudaTableroB =>
      '1. Finketan, sakatu «Zereginak» (goian) guztiak dituen taula ikusteko.\n2. Iragazi finkaren eta egoeraren arabera. Taldearekin sinkronizatzen baduzu, «Nire zereginak» aukerak zuri esleitutakoak bakarrik uzten ditu.\n3. Eginda emateko, sakatu zereginaren eskuinean dagoen marka duen zirkulua.\n4. Ukitu zeregin bat haren egoera aldatzeko (egiteke, egiten, eginda, blokeatuta), zuri esleitzeko edo askatzeko.\n5. «PDF txostena» botoiarekin iragazita duzunaren mantentze-partea ateratzen duzu, inprimatzeko edo bidaltzeko.';

  @override
  String get ayudaProyectosT => 'Zure proiektua sortu';

  @override
  String get ayudaProyectosB =>
      '1. Sartu Proiektuetan eta sakatu +.\n2. Jarri proiektuaren izena, pertsona testerra eta jarduera. Nahi baduzu, baita finka eta hasiera- eta amaiera-datak ere.\n3. Sakatu Gorde. Ukitu proiektua zerrendan barrura sartzeko.';

  @override
  String get ayudaApuntarT => 'Zure egunerokoa apuntatu';

  @override
  String get ayudaApuntarB =>
      'Proiektuaren barruan lau fitxa daude: Ekoizpena, Merkaturatzea, Balidazioa eta Ekonomikoa.\n1. Joan apuntatu nahi duzunaren fitxara.\n2. Sakatu + eta bete dagokiona: ekoitzitakoa; salmenta bat (produktua, kanala, kantitatea eta prezioa); produktu-proba bat eta haren emaitza; edo gastu edo sarrera bat bere kategoriarekin.\n3. Gorde. Goiko zenbakiak berez eguneratzen dira.';

  @override
  String get ayudaNumerosT => 'Zure zenbakiak ulertu';

  @override
  String get ayudaNumerosB =>
      'Proiektuaren goialdean errentagarritasuna ikusten duzu: salmentak, beste sarrera batzuk, gastuak, balantzea, marjina eta urtebeterako proiekzioa.\n• «Aldia» iragazkiarekin (goian) denbora osorako, aurtengo, hiruhileko honetarako edo aurreko hiruhilekorako ikus dezakezu.\n• Gastuak badaude, kategorien araberako banaketa eta BEZ jasana eta jasanarazia ikusiko dituzu.\n» BEZa gutxi gorabeherako kalkulua da, ez zerga-aitorpena: araubidea zuen aholkulariak erabakitzen du.';

  @override
  String get ayudaInformesT => 'Txostenak atera eta bidali';

  @override
  String get ayudaInformesB =>
      '• Zure proiektuan, partekatzeko botoiak (goian) «Proiektuaren txostena (PDF)» ateratzen du, CSVra esportatzen du (Excelekin irekitzen da) edo «Bidali koordinatzaileari» aukerarekin bidaltzen du.\n• Koordinatzaileari bidaltzeko, jarri lehenago haren helbidea Ezarpenak → Koordinatzailea atalean.\n• Proiektuen zerrendan, grafikoaren botoiak (goian) proiektu guztien arteko «Konparaketa (PDF)» ateratzen du.\n• Ezarpenetan, «Esportatu gunea (CSV)» aukerak finkak eta mapako puntuak ateratzen ditu, koordinazioari pasatzeko.';

  @override
  String get ayudaSyncT => 'Zereginak taldearekin partekatu';

  @override
  String get ayudaSyncB =>
      'Saiakuntza Gunean sinkronizazioa erabiltzen baduzue, zereginak talde osoaren mugikorren artean partekatzen dira.\n1. Eskatu koordinazioari zure token pertsonala. Zure giltza da: pertsona bakoitzak berea du, eta ez da partekatzen.\n2. Ezarpenak → Zereginen sinkronizazioa atalean, jarri Zunbeltzen WordPress-aren helbidea eta zure tokena.\n3. Sakatu «Sinkronizatu orain» estaldura duzunean: zure aldaketak igotzen dira eta besteenak jaisten.\n» Zereginak bakarrik partekatzen dira. Puntuak, eremuak eta proiektuak zure mugikorrean bakarrik geratzen dira.';

  @override
  String get ayudaRolesT => 'Nork zer egin dezakeen';

  @override
  String get ayudaRolesB =>
      'Pertsona bakoitzak rol bat du, koordinazioak ematen diona.\n• Koordinazioa: zeregin guztiak ikusi, sortu, aldatu eta banatzen ditu.\n• Testerra: guztiak ikusten ditu eta bereak sortzen ditu. Berak sortutakoak edo esleituta dituenak alda ditzake, eta esleitu gabe daudenak har ditzake.\n» Ezarpenetan ikusten duzu zein izen eta rolekin zauden konektatuta. Sinkronizaziorik gabe «Tokiko modua» zaude, eta dena edita dezakezu.';

  @override
  String get ayudaProblemasT => 'Ohiko arazoak';

  @override
  String get ayudaProblemasB =>
      '• «Zure rolak ez du … baimenik»: zeregin hori ez da zurea. Har ezazu esleitu gabe badago, edo eskatu koordinazioari zuri esleitzeko.\n• «… desegin da / dira» sinkronizatzean: zure rolak baimentzen ez duen zerbait ukitu duzu, eta zegoen bezala utzi da.\n• «Token incorrecto…» mezua: begiratu osorik kopiatu duzula. Galdu baduzu, koordinazioak berri bat sortuko dizu, eta zaharrak ez du balioko.\n• «finka ezezagunarekin»: zeregin hori zure mugikorrean beste izen bat duen finka batekoa da. Finkek izen bera izan behar dute mugikor guztietan.\n• Eguraldiaren iragarpena ez da agertzen: internet behar du. Gainerakoa estaldurarik gabe dabil.\n» Zure datuak zure mugikorrean daude. Aldatu edo galtzen baduzu, hitz egin lehenago koordinazioarekin.';

  @override
  String get ayudaPie =>
      'Zerbait argi ez badago, galdetu Saiakuntza Guneko koordinazioari.';

  @override
  String get ajustesExportarEspacio => 'Esportatu gunea (CSV)';

  @override
  String get ajustesSyncTitulo => 'Zereginen sinkronizazioa';

  @override
  String get ajustesSyncUrl => 'Zunbeltzen WordPress-a';

  @override
  String get ajustesSyncToken => 'Token pertsonala';

  @override
  String get ajustesSyncSinConfigurar => 'Konfiguratu gabe';

  @override
  String get ajustesSyncAhora => 'Sinkronizatu orain';

  @override
  String ajustesSyncResultado(int subidas, int bajadas, int omitidas) {
    String _temp0 = intl.Intl.pluralLogic(
      omitidas,
      locale: localeName,
      other: ' · $omitidas finka ezezagunarekin',
      zero: '',
    );
    return '$subidas zeregin igota · $bajadas jaitsita$_temp0';
  }

  @override
  String get ajustesDemo => 'Kargatu demostrazio-datuak';

  @override
  String get demoCargada => 'Demostrazio-datuak kargatuta';

  @override
  String get demoYaHay =>
      'Jada badaude proiektuak; ezabatu itzazu demoa berriz kargatzeko.';

  @override
  String get zonaDibujar => 'Eremua marraztu';

  @override
  String get zonaNuevaTitulo => 'Eremu berria';

  @override
  String get zonaTitulo => 'Eremuak';

  @override
  String get zonaFinca => 'Finka';

  @override
  String get zonaTipo => 'Eremu mota';

  @override
  String get zonaNombre => 'Izena';

  @override
  String get zonaEstado => 'Egoera';

  @override
  String get zonaNotas => 'Oharrak';

  @override
  String get zonaFotos => 'Argazkiak';

  @override
  String get zonaRecintoSigpac => 'SIGPAC esparrua';

  @override
  String get zonaSuperficie => 'Azalera';

  @override
  String get zonaSuperficieOficial => 'SIGPAC azalera ofiziala (ha)';

  @override
  String get zonaPerimetro => 'Perimetroa';

  @override
  String get zonaOrientativa => 'orientagarria';

  @override
  String get zonaAvisoSuperficie =>
      'Marrazkiaren azalera orientagarria da: ofiziala SIGPAC esparruarena da. Baldin baduzue, idatzi «Azalera ofiziala» atalean eta hori erabiliko da.';

  @override
  String get zonaGuardada => 'Eremua gordeta';

  @override
  String get zonaBorrar => 'Eremua ezabatu';

  @override
  String get zonaTareas => 'Eremuko zereginak';

  @override
  String get zonaSinTareas => 'Eremu honetan zereginik ez.';

  @override
  String get zonaNuevaTarea => 'Zeregin berria';

  @override
  String get zonaRedibujar => 'Berriro marraztu';

  @override
  String get zonaTrazadoActualizado => 'Marrazkia eguneratuta';

  @override
  String get zonaTrazadoCorto => 'Markatu gutxienez hiru izkina eremua ixteko.';

  @override
  String get dibujoTocaVertices =>
      'Ukitu eremuaren izkinak. Hiru edo gehiagorekin, sakatu «Eremua itxi».';

  @override
  String get dibujoDeshacer => 'Desegin';

  @override
  String get dibujoCerrar => 'Eremua itxi';

  @override
  String get dibujoCancelar => 'Utzi';

  @override
  String dibujoEnCurso(String esquinas, String ha) {
    return '$esquinas · ≈ $ha ha';
  }

  @override
  String dibujoEsquinas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n izkina',
      one: 'Izkina 1',
      zero: 'Izkinarik ez',
    );
    return '$_temp0';
  }

  @override
  String get tareaDeZona => 'Eremuko zeregina';

  @override
  String get parteColZona => 'Eremua';

  @override
  String ajustesSesionComo(String nombre) {
    return 'Saioa: $nombre';
  }

  @override
  String ajustesSesionConectada(String nombre) {
    return 'Saioa konektatuta: $nombre';
  }

  @override
  String get ajustesSesionLocal => 'Tokiko modua';

  @override
  String get ajustesSesionLocalDetalle =>
      'Sinkronizaziorik gabe: gailu honetan dena edita daiteke.';

  @override
  String ajustesSyncRechazadas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n aldaketa desegin dira: zure rolak ez ditu baimentzen',
      one: 'Aldaketa 1 desegin da: zure rolak ez du baimentzen',
    );
    return '$_temp0';
  }

  @override
  String get tareaSinAsignar => 'Esleitu gabe';

  @override
  String get tareaAsignarme => 'Niri esleitu';

  @override
  String get tareaSoltar => 'Zeregina askatu';

  @override
  String get tareaCambiarEstado => 'Egoera aldatu';

  @override
  String get tareaSinPermiso =>
      'Zure rolak ez du zeregin hau aldatzeko baimenik.';

  @override
  String get tareaNoPuedesCrear =>
      'Zure rolak ez du zereginak sortzeko baimenik.';

  @override
  String get tableroMisTareas => 'Nire zereginak';

  @override
  String get meteoAhora => 'Orain';

  @override
  String get meteoSensacion => 'Sentsazioa';

  @override
  String get meteoHumedad => 'Hezetasuna';

  @override
  String get meteoViento => 'Haizea';

  @override
  String get meteoRachas => 'boladak';

  @override
  String meteoLuz(int horas, int minutos) {
    return '$horas h $minutos min argi';
  }

  @override
  String get meteoAmanecer => 'Egunsentia';

  @override
  String get meteoAnochecer => 'Ilunabarra';

  @override
  String meteoAltitud(int metros) {
    return 'Ereduaren datuak $metros m-ko altitudean';
  }

  @override
  String get meteoProximasHoras => 'Hurrengo 24 orduak';

  @override
  String get meteoAgua => 'Ura eta larrea';

  @override
  String get meteoLluviaPasada => 'Azken 7 egunetako euria';

  @override
  String get meteoLluviaPrevista => 'Aurreikusitako euria (7 egun)';

  @override
  String get meteoEvapotranspiracion =>
      'Lurrak eta larreak galtzen duten ura (7 egun)';

  @override
  String get meteoBalanceSeco =>
      'Lurrak eta larreak egingo duen euria baino ur gehiago galduko dutela aurreikusten da: kontuz larrearekin, urmaelekin eta askekin.';

  @override
  String get meteoBalanceHumedo =>
      'Lurrak eta larreak galtzen dutena baino euri gehiago aurreikusten da.';

  @override
  String get meteoDiasTitulo => 'Hurrengo 7 egunak';

  @override
  String get meteoSensacionMin => 'Gutxieneko sentsazioa';

  @override
  String get meteoHorasLluvia => 'Euri-orduak';

  @override
  String get meteoNieve => 'Elurra';

  @override
  String get meteoUv => 'UV indize maximoa';

  @override
  String get meteoThi => 'Bero-estresaren indizea (THI) maximoa';

  @override
  String get meteoThiNota =>
      'THIa eta haren alerta-muga (75, abereen segurtasun-indizea, LCI) orientagarriak dira, eta albaitariarekin balioztatzeko zain daude estentsiboko haragi-behientzat eta ardientzat.';

  @override
  String meteoGuardada(String fecha) {
    return 'Konexiorik gabe. Iragarpena $fecha gorde zen.';
  }

  @override
  String meteoActualizado(String fecha) {
    return 'Eguneratua: $fecha';
  }

  @override
  String get avisoNieve => 'Elurra';

  @override
  String get avisoTormenta => 'Ekaitza';

  @override
  String get avisoEstresCalor => 'Bero-estresa';

  @override
  String get meteoEvapotranspiracionDia =>
      'Lurrak eta larreak galtzen duten ura';

  @override
  String get actualizacionesTitulo => 'Eguneraketak';

  @override
  String get actualizacionesVersionInstalada => 'Instalatutako bertsioa';

  @override
  String get actualizacionesUltimaPublicada => 'Argitaratutako azkena';

  @override
  String get actualizacionesSinConexion => 'konexiorik gabe';

  @override
  String get actualizacionesNingunaTodavia => 'oraindik bat ere ez';

  @override
  String get actualizacionesPublicadaEl => 'Argitaratze-data';

  @override
  String get actualizacionesComprobadoEl => 'Egiaztatze-data';

  @override
  String get actualizacionesHayVersionNueva => 'Bertsio berri bat dago.';

  @override
  String get actualizacionesTienesLaUltima => 'Azken bertsioa duzu.';

  @override
  String get actualizacionesQueTrae => 'Zer dakarren';

  @override
  String get actualizacionesDescargando => 'Deskargatzen…';

  @override
  String get actualizacionesDescargarEInstalar => 'Deskargatu eta instalatu';

  @override
  String get actualizacionesBuscarAhora => 'Bilatu orain';

  @override
  String get actualizacionesVersionDisponible => 'Bertsio eskuragarria';

  @override
  String get actualizacionesTienesInstalada => 'Instalatuta duzuna:';

  @override
  String get actualizacionesTocaParaActualizar => 'Sakatu eguneratzeko.';

  @override
  String get actualizacionesActualizar => 'Eguneratu';

  @override
  String get actualizacionesDescartar => 'Baztertu oraingoz';

  @override
  String get actualizacionesInstaladorAbierto =>
      'Instalatzailea ireki da. Berretsi eguneraketa eta ireki berriro aplikazioa.';

  @override
  String get actualizacionesDescargaEnNavegador =>
      'Deskarga nabigatzailean ireki da.';

  @override
  String get actualizacionesErrorDescarga =>
      'Ezin izan da deskargatu. Egiaztatu konexioa eta saiatu berriro.';

  @override
  String get actualizacionesErrorInstalador =>
      'Deskargatuta dago, baina Androidek ez du utzi instalatzailea irekitzen. Baimendu «aplikazio ezezagunak instalatzea» aplikazio honetarako mugikorraren ezarpenetan.';

  @override
  String get ajustesActualizacionesSubtitulo =>
      'Instalatutako bertsioa eta argitaratutako azkena';
}
