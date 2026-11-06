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
    return 'Gutxienez $cantidad pertsonak parte hartu behar dute';
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
    return '$cantidad pertsonak parte hartu dute';
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
    return '$cantidad babes';
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
}
