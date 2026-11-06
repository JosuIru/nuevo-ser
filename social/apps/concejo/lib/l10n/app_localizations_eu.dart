// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Basque (`eu`).
class AppLocalizationsEu extends AppLocalizations {
  AppLocalizationsEu([String locale = 'eu']) : super(locale);

  @override
  String get nombreApp => 'Kontzejua';

  @override
  String get pestanaAsuntos => 'Gaiak';

  @override
  String get pestanaSeHaHecho => 'Egin da?';

  @override
  String get faseBorrador => 'Prestatzen';

  @override
  String get faseDebate => 'Eztabaidan';

  @override
  String get faseDecision => 'Orain erabakitzen da';

  @override
  String get faseSeguimiento => 'Erabakita';

  @override
  String get sinAsuntos => 'Ez dago gairik fase honetan.';

  @override
  String get tipoVinculante => 'Taldeak erabakitzen du';

  @override
  String get tipoConCompromiso => 'Aurretiko konpromisoarekin';

  @override
  String get tipoConsultiva => 'Kontsulta';

  @override
  String get explicaVinculante =>
      'Ateratzen dena taldeak berak erabakitzen du, bere arauen arabera.';

  @override
  String get explicaConCompromiso =>
      'Organo formalak aldez aurretik konpromisoa hartu du ateratzen dena betetzeko:';

  @override
  String get explicaConsultiva =>
      'Jendeak zer pentsatzen duen jakiteko balio du. Organo formalak erabakitzen du.';

  @override
  String get seccionCalendario => 'Egutegia';

  @override
  String calendarioDebate(String fecha) {
    return 'Eztabaida: $fecha(e)tik aurrera';
  }

  @override
  String calendarioDecision(String desde, String hasta) {
    return 'Erabakia: $desde(e)tik $hasta(e)ra';
  }

  @override
  String get seccionComoSeDecide => 'Nola erabakitzen da';

  @override
  String get formaVotacion => 'Bozketa: bai, ez edo abstentzioa';

  @override
  String get formaEleccion =>
      'Aukeren artean: onartzen dituzun guztiak markatu';

  @override
  String get formaConsentimiento =>
      'Adostasuna: inork arrazoitutako objekziorik jartzen ez badu onartzen da';

  @override
  String get formaPresupuesto =>
      'Aurrekontua: nahi dituzun proposamenak babestu; babesen arabera sartzen dira dirua dagoen bitartean';

  @override
  String get mayoriaSimple => 'Gehiengo soila (baiak ezak baino gehiago)';

  @override
  String get mayoriaAbsoluta => 'Gehiengo osoa (botoen erdia baino gehiago)';

  @override
  String get mayoriaDosTercios => 'Baien eta ezen bi heren';

  @override
  String quorum(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'Gutxienez $cantidad pertsonak parte hartu behar dute',
      one: 'Gutxienez pertsona batek parte hartu behar du',
    );
    return '$_temp0';
  }

  @override
  String get sinQuorumRegla => 'Parte-hartze minimorik gabe';

  @override
  String get votoSecreto => 'Boto sekretua';

  @override
  String get votoNominal =>
      'Boto agerikoa (nork zer bozkatzen duen jakiten da)';

  @override
  String get reglasFijas =>
      'Arau hauek ireki aurretik finkatu ziren eta ezin dira aldatu.';

  @override
  String get seccionEntorno => 'Ingurunean duen eragina';

  @override
  String get seccionCoste => 'Kostua';

  @override
  String get verTextoCompleto => 'Testu osoa';

  @override
  String get pestanaInformacion => 'Informazioa';

  @override
  String get pestanaDebate => 'Eztabaida';

  @override
  String get pestanaDecidir => 'Erabaki';

  @override
  String get pestanaResultado => 'Emaitza';

  @override
  String get columnaAFavor => 'Alde';

  @override
  String get columnaEnContra => 'Kontra';

  @override
  String get columnaDudas => 'Zalantzak';

  @override
  String get columnaCambios => 'Aldaketa-proposamenak';

  @override
  String get columnaVacia => 'Oraindik inork ez du hemen idatzi.';

  @override
  String get vecinaAnonima => 'Herriko bizilaguna';

  @override
  String get aportar => 'Ekarpena egin';

  @override
  String get responder => 'Erantzun';

  @override
  String get tuAportacion => 'Esan nahi duzuna';

  @override
  String get tipoDeAportacion => 'Zer da?';

  @override
  String get aportarAnonima =>
      'Nire izenik gabe (mahaiak ikusiko du argitaratu aurretik)';

  @override
  String get publicar => 'Argitaratu';

  @override
  String get cancelar => 'Utzi';

  @override
  String get debateCerrado => 'Eztabaida itxita dago.';

  @override
  String get pendienteMesa =>
      'Izenik gabeko zure ekarpena mahaiak ikusi arte zain dago.';

  @override
  String decisionAunNo(String fecha) {
    return 'Erabakia $fecha(e)an irekiko da. Bitartean, eztabaidan parte har dezakezu.';
  }

  @override
  String get yaHasVotado => 'Parte hartu duzu. Eskerrik asko.';

  @override
  String get votoSi => 'Bai';

  @override
  String get votoNo => 'Ez';

  @override
  String get votoAbstencion => 'Abstentzioa';

  @override
  String get enviarVoto => 'Nire botoa bidali';

  @override
  String get confirmarVoto => 'Botoa bidaltzen duzu? Gero ezin da aldatu.';

  @override
  String get enviar => 'Bidali';

  @override
  String bolsaRestante(String gastado, String bolsa) {
    return '$bolsa(e)tik $gastado aukeratu dituzu. Sartzen ez dena ez da sartuko.';
  }

  @override
  String get votoEnBlanco =>
      'Ezer markatzen ez baduzu, boto zuri gisa zenbatzen da.';

  @override
  String rondaConsentimiento(int ronda, int maximo) {
    return '$maximo(e)tik $ronda. itzulia';
  }

  @override
  String get sinObjeciones => 'Oraingoz inork ez du objekziorik jarri.';

  @override
  String get objecionesVivas => 'Ebatzi gabeko objekzioak';

  @override
  String get objetar => 'Objekzioa jarri';

  @override
  String get queDanoCausa => 'Zer kalte eragingo luke proposamenak?';

  @override
  String get objetarNoEsContra =>
      'Objekzioa jartzea ez da kontra egotea: azaldu zer kalte eragingo lukeen eta, ahal baduzu, nola saihestu.';

  @override
  String get resultadoAprobada => 'Onartuta';

  @override
  String get resultadoRechazada => 'Ezetsita';

  @override
  String get resultadoSinQuorum =>
      'Ez du balio: ez zen parte-hartze minimora iritsi';

  @override
  String resultadoParticipacion(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad pertsonak parte hartu dute',
      one: 'Pertsona batek parte hartu du',
    );
    return '$_temp0';
  }

  @override
  String get resultadoEmpate =>
      'Berdinketa: mahaiak edo bigarren itzuli batek ebatziko du';

  @override
  String get resultadoGanadora => 'Onartuena';

  @override
  String get presupuestoEntra => 'Sartzen da';

  @override
  String get presupuestoNoCabe => 'Ez da sartzen';

  @override
  String get presupuestoSinApoyos => 'Babesik gabe';

  @override
  String apoyos(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad babes',
    );
    return '$_temp0';
  }

  @override
  String sobrante(String cantidad) {
    return '$cantidad soberan';
  }

  @override
  String get recuentoEnCurso => 'Zenbaketa erabakia ixtean ikusiko da.';

  @override
  String get seccionCompromisos => 'Konpromisoak';

  @override
  String get sinCompromisos => 'Oraindik ez dago konpromisorik.';

  @override
  String get compromisoPendiente => 'Egiteko';

  @override
  String get compromisoEnMarcha => 'Abian';

  @override
  String get compromisoHecho => 'Eginda';

  @override
  String get compromisoNoSeHara => 'Ez da egingo';

  @override
  String get compromisoVencido => 'Epez kanpo';

  @override
  String compromisoPara(String responsable, String fecha) {
    return '$responsable · $fecha(e)rako';
  }

  @override
  String balanceCompromisos(int hechos, int total, int vencidos) {
    return '$total(e)tik $hechos eginda · $vencidos epez kanpo';
  }

  @override
  String get marcarHecho => 'Egindakotzat jo';

  @override
  String get marcarEnMarcha => 'Abian jarri';

  @override
  String deAsunto(String titulo) {
    return 'Nondik: $titulo';
  }

  @override
  String get ejemploAviso =>
      'Adibideko herria: datuak gailu honetan bakarrik daude.';

  @override
  String eresMesa(String fecha) {
    return '$fecha arte mahaian zaude';
  }

  @override
  String get nuevoAsunto => 'Gai berria';

  @override
  String get editarAsunto => 'Gaia editatu';

  @override
  String get campoTitulo => 'Izenburua';

  @override
  String get campoResumen => 'Laburpena hiru lerrotan';

  @override
  String get ayudaResumen =>
      'Lehenik irakurtzen dena. Esaldi laburrak, jergarik gabe.';

  @override
  String get campoTexto => 'Testu osoa (aukerakoa)';

  @override
  String get campoTipoDecision => 'Zer balio du ateratzen denak?';

  @override
  String get campoCompromiso => 'Aurretiko konpromisoa';

  @override
  String get campoCoste => 'Kostua (€, aukerakoa)';

  @override
  String get campoEntorno => 'Ingurunean duen eragina';

  @override
  String get campoInicioDebate => 'Eztabaida hasten da';

  @override
  String get campoInicioDecision => 'Erabakia hasten da';

  @override
  String get campoFinDecision => 'Erabakia amaitzen da';

  @override
  String get campoForma => 'Nola erabakitzen da';

  @override
  String get nombreVotacion => 'Bozketa';

  @override
  String get nombreEleccion => 'Aukeren artean';

  @override
  String get nombreConsentimiento => 'Adostasuna';

  @override
  String get nombrePresupuesto => 'Aurrekontua';

  @override
  String get campoMayoria => 'Gehiengoa';

  @override
  String get campoQuorum => 'Gutxieneko parte-hartzea';

  @override
  String get campoSecreto => 'Boto sekretua';

  @override
  String get campoBolsa => 'Diru erabilgarria (€)';

  @override
  String get campoRondas => 'Bozketara edo batzarrera eraman aurreko itzuliak';

  @override
  String get opciones => 'Aukerak';

  @override
  String get propuestas => 'Proposamenak';

  @override
  String get anadirOpcion => 'Gehitu';

  @override
  String get textoOpcion => 'Testua';

  @override
  String get costeOpcion => 'Kostua €';

  @override
  String get guardarBorrador => 'Zirriborroa gorde';

  @override
  String get abrirAsunto => 'Gaia ireki';

  @override
  String get confirmarAbrir =>
      'Irekitzean, denek ikusiko dute eta erabakitzeko arauak ezin izango dira aldatu. Irekitzen duzu?';

  @override
  String get abrir => 'Ireki';

  @override
  String get borrarBorrador => 'Zirriborroa ezabatu';

  @override
  String get confirmarBorrar => 'Zirriborro hau ezabatzen duzu?';

  @override
  String get borrar => 'Ezabatu';

  @override
  String get editar => 'Editatu';

  @override
  String get guardar => 'Gorde';

  @override
  String get faltaParaAbrir => 'Ireki ahal izateko falta da:';

  @override
  String get problemaTitulo => 'izenburua';

  @override
  String get problemaResumen => 'laburpena';

  @override
  String get problemaEntorno => 'ingurunean duen eragina';

  @override
  String get problemaCompromiso => 'aurretiko konpromisoaren testua';

  @override
  String get problemaFechas =>
      'datak ordenan egotea (eztabaida, erabakia, amaiera)';

  @override
  String get problemaOpciones => 'gutxienez bi aukera (edo proposamen bat)';

  @override
  String get problemaRepetidas => 'aukera errepikaturik ez egotea';

  @override
  String get problemaBolsa => 'diru erabilgarria';

  @override
  String get problemaSinCoste => 'proposamen bakoitzaren kostua';

  @override
  String get problemaQuorum => 'negatiboa ez den parte-hartze minimoa';

  @override
  String get verComo => 'Honela ikusi…';

  @override
  String get rolMesa => 'mahaia';

  @override
  String get rolVecina => 'bizilaguna';

  @override
  String get pendienteModeracion => 'Izenik gabe · mahaiaren zain';

  @override
  String get publicarAportacion => 'Argitaratu';

  @override
  String get retirarAportacion => 'Erretiratu';

  @override
  String get motivoRetirada => 'Zergatik erretiratzen da? Agerian geratuko da.';

  @override
  String retiradaPorMesa(String motivo) {
    return 'Mahaiak erretiratua: $motivo';
  }

  @override
  String get escribirResumen => 'Eztabaidaren laburpena idatzi';

  @override
  String get resumenDebate => 'Eztabaidaren laburpena (mahaia)';

  @override
  String get integrarObjecion => 'Txertatu';

  @override
  String get noEsObjecion => 'Ez da objekzioa';

  @override
  String get comoSeIntegra => 'Nola aldatzen da proposamena konpontzeko?';

  @override
  String get porQueNoEsObjecion =>
      'Zergatik ez du kalterik arrazoitzen? Aktan geratuko da.';

  @override
  String get retirarMiObjecion => 'Nire objekzioa erretiratu';

  @override
  String cerrarVuelta(int ronda) {
    return '$ronda. itzulia itxi';
  }

  @override
  String get confirmarCerrarVuelta =>
      'Objekzio biziik geratzen ez bada, proposamena onartuta geratzen da. Geratzen badira, beste itzuli bat hasten da edo bozketara edo batzarrera pasatzen da. Itzulia ixten duzu?';

  @override
  String get cerrar => 'Itxi';

  @override
  String get consentimientoAprobado =>
      'Adostasunez onartua: inork ez du objekziorik mantentzen.';

  @override
  String get consentimientoPasa =>
      'Ebatzi gabeko objekzioak geratzen dira: bozketara edo aurrez aurreko batzarrera pasatzen da.';

  @override
  String get objecionesResueltas => 'Ebatzitako objekzioak';

  @override
  String get estadoIntegrada => 'Txertatua';

  @override
  String get estadoRetirada => 'Erretiratua';

  @override
  String get estadoNoEsObjecion => 'Ez zen objekzioa';

  @override
  String get apuntarCompromiso => 'Konpromisoa idatzi';

  @override
  String get campoQue => 'Zer egingo den';

  @override
  String get campoResponsable => 'Nork';

  @override
  String get campoFechaLimite => 'Noiz arte';

  @override
  String get marcarNoSeHara => 'Ez da egingo…';

  @override
  String get porQueNoSeHara =>
      'Zergatik ez da egingo? Herriarentzat informazioa ere bada.';

  @override
  String get ayudaEntorno =>
      'Ura, mendia, zarata, paisaia, animaliak… Ez badu, idatzi «bat ere ez».';

  @override
  String get ayudaQuorum =>
      'Balio izateko parte hartu behar duten pertsonak (0 = gutxienekorik gabe)';

  @override
  String get ayudaCompromiso =>
      'Nork zer hartzen duen bere gain eta zein baldintzatan';

  @override
  String get ayudaResponsable => 'Pertsona, batzordea, «batzarra»…';

  @override
  String get pdfHojaAsunto => 'Gaiaren orria';

  @override
  String get pdfPapeletas => 'Txartelak';

  @override
  String get pdfHojaRecuento => 'Zenbaketa-orria';

  @override
  String get pdfComoParticipar => 'Nola parte hartu';

  @override
  String get pdfParticiparTexto =>
      'Aplikazioan edo paperean: eskatu txartela mahaiari eta eman epearen barruan. Pertsona bakoitzak behin bakarrik bozkatzen du.';

  @override
  String get pdfMarcaUna => 'Lauki bakarra markatu.';

  @override
  String get pdfMarcaVarias => 'Onartzen dituzun aukera guztiak markatu.';

  @override
  String pdfMarcaPropuestas(String bolsa) {
    return 'Babesten dituzun proposamenak markatu. $bolsa daude: babesen arabera sartzen dira sartzen diren bitartean.';
  }

  @override
  String get pdfPapeletaSecreta =>
      'Boto sekretua: ez idatzi zure izena. Tolestu txartela.';

  @override
  String get pdfPapeletaNominal => 'Boto agerikoa: idatzi zure izena.';

  @override
  String get pdfNombre => 'Izena';

  @override
  String get pdfHojaObjeciones => 'Objekzioak';

  @override
  String get pdfObjecionesTexto =>
      'Proposamenak kalteren bat eragingo balu, azaldu hemen. Objekzioa jartzea ez da kontra egotea: esan zer kalte eta, ahal baduzu, nola saihestu.';

  @override
  String get pdfDanoYComoEvitarlo =>
      'Zer kalte eragingo lukeen eta nola saihestu';

  @override
  String get pdfRecuentoTexto =>
      'Mahaiarentzat: bi pertsonaren artean zenbatu paperezko txartelak eta pasatu zifrak aplikaziora.';

  @override
  String get pdfOpcion => 'Aukera';

  @override
  String get pdfMarcas => 'Markak';

  @override
  String get pdfPapeletasTotales => 'Txartelak guztira';

  @override
  String get pdfEnBlanco => 'Horietatik, zuriak';

  @override
  String get pdfPersonasAnotadas =>
      'Aurrez aurre bozkatu dutenen zerrendako pertsonak';

  @override
  String get pdfFirma => 'Sinadura';

  @override
  String get pdfFecha => 'Data';

  @override
  String get pdfRecorta => 'Moztu lerrotik';

  @override
  String get imprimir => 'Inprimatu edo partekatu';

  @override
  String get votosEnPersona => 'Aurrez aurreko botoak';

  @override
  String get votosEnPersonaTexto =>
      'Apuntatu pertsona bakoitza bere txartela ematen dizunean: horrela inork ez du bi aldiz bozkatzen, ez paperean ez aplikazioan. Ixtean, zenbatu txartelak biren artean eta pasatu zifrak.';

  @override
  String get buscarPersona => 'Izenez bilatu';

  @override
  String get haVotadoEnPersona => 'Aurrez aurre bozkatu du';

  @override
  String get anotar => 'Apuntatu';

  @override
  String get darDeAlta => 'Ez dago zerrendan: alta eman';

  @override
  String get nombreNuevaPersona => 'Pertsonaren izena';

  @override
  String anotadasEnPersona(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad pertsona aurrez aurre apuntatuta',
      one: 'Pertsona 1 aurrez aurre apuntatuta',
    );
    return '$_temp0';
  }

  @override
  String get pasarConteo => 'Txartelen zenbaketa pasatu';

  @override
  String conteosRegistrados(int papeletas) {
    String _temp0 = intl.Intl.pluralLogic(
      papeletas,
      locale: localeName,
      other: 'Erregistratutako zenbaketak: $papeletas txartel',
    );
    return '$_temp0';
  }

  @override
  String get segundaFirma => 'Bigarren sinadura (mahaiko beste pertsona bat)';

  @override
  String get registrarConteo => 'Zenbaketa erregistratu';

  @override
  String get avisoPapeletasNoCuadran =>
      'Paperean zenbatutako txartelak ez datoz bat apuntatutako pertsonekin. Berrikusi akta egin aurretik.';

  @override
  String get sinOtraMesa =>
      'Mahaiko beste pertsona bat behar da zenbaketa sinatzeko.';

  @override
  String get aportarEnNombreDe => 'Norbaitek aurrez aurre esandakoa jaso';

  @override
  String get objetarEnNombreDe => 'Aurrez aurre egindako objekzioa jaso';

  @override
  String get quienLoDijo => 'Nork esan zuen?';
}
