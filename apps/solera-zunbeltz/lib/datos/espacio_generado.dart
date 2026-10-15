// GENERADO por tool/compilar_espacio.dart — NO editar a mano.
// Fuente: content/espacio/{fincas,puntos,zonas,tareas}.csv

class FincaSeed {
  const FincaSeed(this.nombre, this.latitud, this.longitud, this.superficieHa,
      this.recintosSigpac, this.notas);
  final String nombre;
  final double? latitud;
  final double? longitud;
  final double superficieHa;
  final String recintosSigpac;
  final String notas;
}

class PuntoSeed {
  const PuntoSeed(this.finca, this.tipo, this.nombre, this.latitud,
      this.longitud, this.estado, this.notas);
  final String finca;
  final String tipo;
  final String nombre;
  final double? latitud;
  final double? longitud;
  final String estado;
  final String notas;
}

class ZonaSeed {
  const ZonaSeed(this.finca, this.tipo, this.nombre, this.recintoSigpac,
      this.estado, this.notas, this.verticesJson,
      [this.color = '']);
  final String finca;
  final String tipo;
  final String nombre;
  final String recintoSigpac;
  final String estado;
  final String notas;
  final String verticesJson;
  final String color;
}

/// Tarea de partida, anclada por nombre a una zona o a un punto de su
/// finca. [clave] da el uid: el mismo en todos los móviles.
class TareaSeed {
  const TareaSeed(this.finca, this.clave, this.titulo, this.descripcion,
      this.zona, this.punto, this.prioridad);
  final String finca;
  final String clave;
  final String titulo;
  final String descripcion;
  final String zona;
  final String punto;
  final String prioridad;
}

const List<FincaSeed> fincasEspacio = [
  FincaSeed('Zunbeltz', 42.8169, -2.033, 229.36, 'Yerri · pol. 24 parc. 2',
      'Punto interior de la parcela catastral 24-2 de Yerri (Catastro de Navarra, IDENA, oct-2026)'),
  FincaSeed(
      'La Planilla',
      42.7707,
      -2.0144,
      197.14,
      'Yerri · pol. 13 parc. 1 y 2',
      'Polígono 13 de Yerri, localizado por la toponimia oficial (IDENA) y el Catastro de Navarra, oct-2026'),
];

const List<PuntoSeed> puntosEspacio = [
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 1',
      42.828056,
      -2.028482,
      'revisar',
      'Punto rojo nº 1 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Portillo norte (sierra de Urbasa)',
      42.828001,
      -2.029645,
      'revisar',
      'Punto rojo nº 2 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Finca de la Era',
      42.826158,
      -2.028636,
      'revisar',
      'Punto rojo nº 3 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed('Zunbeltz', 'puerta', 'La Cañada', 42.825109, -2.028399, 'revisar',
      'Punto rojo nº 4 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 5',
      42.824696,
      -2.02881,
      'revisar',
      'Punto rojo nº 5 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 6',
      42.824212,
      -2.029689,
      'revisar',
      'Punto rojo nº 6 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Sectorización oeste',
      42.823032,
      -2.030553,
      'revisar',
      'Punto rojo nº 7 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 8',
      42.822725,
      -2.029205,
      'revisar',
      'Punto rojo nº 8 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 9',
      42.822579,
      -2.030597,
      'revisar',
      'Punto rojo nº 9 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 10',
      42.822527,
      -2.028754,
      'revisar',
      'Punto rojo nº 10 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 11',
      42.822449,
      -2.028313,
      'revisar',
      'Punto rojo nº 11 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 12',
      42.822385,
      -2.030638,
      'revisar',
      'Punto rojo nº 12 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 13',
      42.821799,
      -2.030419,
      'revisar',
      'Punto rojo nº 13 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 14',
      42.82177,
      -2.029081,
      'revisar',
      'Punto rojo nº 14 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 15',
      42.821526,
      -2.028705,
      'revisar',
      'Punto rojo nº 15 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 16',
      42.821505,
      -2.02844,
      'revisar',
      'Punto rojo nº 16 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 17',
      42.821365,
      -2.02824,
      'revisar',
      'Punto rojo nº 17 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 18',
      42.821278,
      -2.02905,
      'revisar',
      'Punto rojo nº 18 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 19',
      42.821124,
      -2.02832,
      'revisar',
      'Punto rojo nº 19 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 20',
      42.821118,
      -2.028737,
      'revisar',
      'Punto rojo nº 20 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Entrada de la finca',
      42.820565,
      -2.027936,
      'revisar',
      'Punto rojo nº 21 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 22',
      42.820345,
      -2.02938,
      'revisar',
      'Punto rojo nº 22 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 23',
      42.820235,
      -2.028333,
      'revisar',
      'Punto rojo nº 23 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 24',
      42.819651,
      -2.029517,
      'revisar',
      'Punto rojo nº 24 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 25',
      42.819373,
      -2.026021,
      'revisar',
      'Punto rojo nº 25 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 26',
      42.818303,
      -2.030118,
      'revisar',
      'Punto rojo nº 26 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 27',
      42.818197,
      -2.025028,
      'revisar',
      'Punto rojo nº 27 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 28',
      42.816177,
      -2.023871,
      'revisar',
      'Punto rojo nº 28 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
  PuntoSeed('Zunbeltz', 'aprisco', 'Aprisco', 42.821274, -2.028482, 'revisar',
      'Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.'),
];

const List<ZonaSeed> zonasEspacio = [
  ZonaSeed(
      'Zunbeltz',
      'otra',
      'Parcela catastral 24-2',
      'Yerri · pol. 24 parc. 2',
      'en_uso',
      'Toda la finca (229,36 ha). Sin la ranura del camino que la cruza. Límite oficial del Catastro de Navarra (IDENA, oct-2026).',
      '[[42.8068538,-2.0407152],[42.8071096,-2.041212],[42.8072152,-2.0414574],[42.8072852,-2.0416671],[42.8077715,-2.0411657],[42.8080095,-2.0408731],[42.8085015,-2.0403438],[42.808656,-2.0401663],[42.8087418,-2.0400853],[42.8088758,-2.0401177],[42.8091176,-2.0402229],[42.8092436,-2.0402476],[42.8093478,-2.0402319],[42.8094852,-2.0401461],[42.809769,-2.039914],[42.8099418,-2.0397303],[42.8101271,-2.0395123],[42.8104464,-2.0392133],[42.8106433,-2.0391492],[42.8112238,-2.0389274],[42.8115123,-2.0387792],[42.8117035,-2.0386592],[42.8118763,-2.0385205],[42.812048,-2.0384301],[42.8122758,-2.038341],[42.8125405,-2.0382627],[42.8128184,-2.0381146],[42.81315,-2.0379633],[42.8135045,-2.0378197],[42.8137527,-2.03774],[42.8139689,-2.0376884],[42.8142686,-2.0376319],[42.8148268,-2.0375392],[42.8151436,-2.0374454],[42.8153804,-2.0373968],[42.8160313,-2.0373008],[42.8163527,-2.0372645],[42.8166833,-2.0372017],[42.8173685,-2.0372067],[42.8179211,-2.0372647],[42.8181477,-2.0373016],[42.8182667,-2.0372936],[42.818635,-2.0371966],[42.8195295,-2.0371343],[42.8201977,-2.0371626],[42.8209287,-2.037242],[42.82128,-2.0372895],[42.82174,-2.0373881],[42.8219517,-2.0374546],[42.8223854,-2.0376542],[42.8225926,-2.037761],[42.8226935,-2.0380824],[42.8227576,-2.0382051],[42.8228974,-2.0383788],[42.8231021,-2.0383241],[42.8237151,-2.038093],[42.8243076,-2.0379629],[42.8251724,-2.0378231],[42.8261492,-2.0376131],[42.8273868,-2.037415],[42.8274469,-2.0366721],[42.8274704,-2.0360583],[42.8275019,-2.0354911],[42.8276164,-2.0341452],[42.8276786,-2.0332687],[42.8276676,-2.032467],[42.8276822,-2.0321686],[42.8278187,-2.0312158],[42.82788,-2.0307092],[42.8279539,-2.0301853],[42.8280013,-2.029486],[42.8278114,-2.029404],[42.8273994,-2.029265],[42.8271923,-2.0291753],[42.8269863,-2.0291136],[42.8267711,-2.0290347],[42.8263626,-2.0289299],[42.8261852,-2.0288572],[42.8260033,-2.0287628],[42.8255283,-2.0285819],[42.8252434,-2.0284862],[42.8249013,-2.0284061],[42.824788,-2.0283503],[42.8247124,-2.0282915],[42.8244879,-2.0280231],[42.8241631,-2.0280517],[42.822558,-2.0280953],[42.8218454,-2.0281387],[42.8216372,-2.0281314],[42.8214335,-2.0280945],[42.8212424,-2.0280467],[42.8210822,-2.0279864],[42.820994,-2.0279384],[42.8208429,-2.0278129],[42.820839,-2.0278192],[42.820757,-2.0277229],[42.8206654,-2.0276346],[42.8205795,-2.0275307],[42.8200114,-2.0267332],[42.819803,-2.0264617],[42.8196139,-2.026184],[42.819213,-2.0256411],[42.8190527,-2.0254394],[42.8188832,-2.0252766],[42.8187092,-2.0251434],[42.8185055,-2.0250164],[42.8175657,-2.0244559],[42.8167084,-2.0239792],[42.8164383,-2.0238756],[42.8159588,-2.0237228],[42.815453,-2.0235763],[42.8152779,-2.0235269],[42.8150502,-2.0234777],[42.8147677,-2.0234534],[42.8144851,-2.0234493],[42.8137414,-2.0234058],[42.8125458,-2.0232763],[42.8116652,-2.0231939],[42.8114029,-2.0231525],[42.8103549,-2.0230739],[42.8099311,-2.0230732],[42.8094387,-2.0230929],[42.8091879,-2.0231214],[42.8091689,-2.0235893],[42.8091741,-2.0242125],[42.8091569,-2.0253689],[42.8091179,-2.0265052],[42.8090441,-2.0272218],[42.8089921,-2.0279415],[42.8089467,-2.0283209],[42.8087548,-2.0288419],[42.808525,-2.0293677],[42.8081101,-2.0302483],[42.8078633,-2.0308627],[42.8077582,-2.0311053],[42.8076507,-2.0313231],[42.8075009,-2.0315379],[42.8074036,-2.0316423],[42.807367,-2.0317107],[42.8071533,-2.0321712],[42.8070859,-2.0323734],[42.8069375,-2.0329487],[42.8067925,-2.0334246],[42.8067252,-2.0336889],[42.8066637,-2.0341444],[42.8066182,-2.0344196],[42.8065771,-2.0346186],[42.8064696,-2.0348333],[42.8063634,-2.0350946],[42.8062971,-2.035289],[42.8061479,-2.0362233],[42.8061275,-2.0364394],[42.8060021,-2.0370815],[42.8058959,-2.037548],[42.8058709,-2.0377796],[42.8058792,-2.0380671],[42.8059218,-2.0383157],[42.8060137,-2.0386124],[42.806218,-2.0391824],[42.8063845,-2.0397198],[42.8065625,-2.0402137],[42.8066795,-2.0404528]]',
      'blanco'),
  ZonaSeed(
      'Zunbeltz',
      'otra',
      'Cierre perimetral',
      '',
      'en_uso',
      'Línea amarilla del mapa de actuaciones: el cierre del área de trabajo, no el límite catastral. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.',
      '[[42.82801,-2.028533],[42.82798,-2.029304],[42.827906,-2.029343],[42.827935,-2.030631],[42.827862,-2.03086],[42.827847,-2.031264],[42.827699,-2.031304],[42.827703,-2.031835],[42.827632,-2.032215],[42.827655,-2.032745],[42.827609,-2.032796],[42.825654,-2.032775],[42.825031,-2.032443],[42.82501,-2.032241],[42.82425,-2.032227],[42.823694,-2.032122],[42.823424,-2.031987],[42.823109,-2.03203],[42.82256,-2.031747],[42.822366,-2.031826],[42.822347,-2.031713],[42.8218,-2.031733],[42.821447,-2.031638],[42.820874,-2.031747],[42.820734,-2.031648],[42.819873,-2.031762],[42.818778,-2.031513],[42.818377,-2.031266],[42.818186,-2.030587],[42.818174,-2.030208],[42.818322,-2.030206],[42.818358,-2.030067],[42.818302,-2.030017],[42.818256,-2.030081],[42.818043,-2.030084],[42.817968,-2.02987],[42.818001,-2.029478],[42.818203,-2.029185],[42.818655,-2.028875],[42.818838,-2.028594],[42.819179,-2.028463],[42.819354,-2.02827],[42.81966,-2.028253],[42.819653,-2.027445],[42.819366,-2.027436],[42.819224,-2.027047],[42.819192,-2.026529],[42.819254,-2.026225],[42.819467,-2.026222],[42.819487,-2.026361],[42.819617,-2.026409],[42.819646,-2.026624],[42.819767,-2.026635],[42.819805,-2.02676],[42.819917,-2.026822],[42.819917,-2.028009],[42.820177,-2.028018],[42.820189,-2.028422],[42.820949,-2.028398],[42.820961,-2.028815],[42.821203,-2.028837],[42.821204,-2.029039],[42.82127,-2.029139],[42.821343,-2.029074],[42.821378,-2.028796],[42.821591,-2.02878],[42.821605,-2.028148],[42.822383,-2.028111],[42.822385,-2.028402],[42.822478,-2.028413],[42.822513,-2.028173],[42.822698,-2.02817],[42.822707,-2.028081],[42.824514,-2.02808],[42.824784,-2.028328],[42.824839,-2.028239],[42.824838,-2.028024],[42.826273,-2.027978],[42.827276,-2.028177],[42.827982,-2.028432]]',
      'amarillo'),
  ZonaSeed(
      'Zunbeltz',
      'parcela_pasto',
      'Pieza Larga',
      'Pol. 24 parc. 2 subp. E',
      'en_uso',
      'Límite oficial del Catastro de Navarra (IDENA, oct-2026).',
      '[[42.8226442,-2.0289414],[42.8226405,-2.0289827],[42.8226378,-2.0290134],[42.8226294,-2.0291083],[42.8226089,-2.0292587],[42.8227751,-2.0292801],[42.8228668,-2.0292727],[42.8231092,-2.0295029],[42.8232231,-2.0295252],[42.8234464,-2.0295877],[42.823591,-2.0296215],[42.8237571,-2.0296249],[42.8238226,-2.0296238],[42.8239171,-2.0294183],[42.8239646,-2.0293515],[42.8240257,-2.0293505],[42.8241196,-2.0295951],[42.8241515,-2.0297447],[42.8243574,-2.0298015],[42.8245281,-2.0298288],[42.8245963,-2.0296297],[42.8246209,-2.0294313],[42.8245758,-2.0292699],[42.8246665,-2.0291424],[42.824731,-2.0290153],[42.8247163,-2.0288355],[42.824688,-2.0285899],[42.8246782,-2.028458],[42.8245768,-2.0283575],[42.8244013,-2.0282883],[42.8241998,-2.0282314],[42.8238412,-2.028201],[42.8234781,-2.0281647],[42.8234658,-2.0281585],[42.8234744,-2.0282011],[42.8234461,-2.028223],[42.823243,-2.0281789],[42.8228914,-2.0281887],[42.8226066,-2.0282275],[42.8224832,-2.0282424],[42.8224076,-2.0282951],[42.8224209,-2.0283723],[42.8224384,-2.0285066],[42.8224674,-2.0285527],[42.8224949,-2.0287083],[42.8225443,-2.0288576],[42.8226454,-2.028928]]',
      'naranja'),
  ZonaSeed(
      'Zunbeltz',
      'parcela_pasto',
      'Pieza de los Silos',
      'Pol. 24 parc. 2 subp. N',
      'en_uso',
      'Frente al aprisco. Límite oficial del Catastro de Navarra (IDENA, oct-2026).',
      '[[42.8214713,-2.0284035],[42.8213511,-2.0282323],[42.8211461,-2.0281912],[42.820988,-2.0281011],[42.8209681,-2.0280087],[42.8209389,-2.0281075],[42.8207849,-2.028018],[42.8207826,-2.0280309],[42.8207982,-2.0280436],[42.8207871,-2.0281357],[42.8203119,-2.0285368],[42.8202508,-2.0284094],[42.8202442,-2.028415],[42.8201909,-2.0284472],[42.8201327,-2.0284729],[42.8200611,-2.0284806],[42.8200777,-2.0285099],[42.8200732,-2.0285191],[42.8200602,-2.0285464],[42.8197377,-2.0290023],[42.8195897,-2.0290408],[42.8195577,-2.0291218],[42.8195916,-2.0292743],[42.819672,-2.0292972],[42.819699,-2.029333],[42.8197782,-2.0295773],[42.8199683,-2.0296025],[42.8202561,-2.029606],[42.8203935,-2.0293623],[42.8205229,-2.0292355],[42.820804,-2.0290771],[42.8208241,-2.0290658],[42.8210367,-2.0289377],[42.8210927,-2.0289599],[42.8213002,-2.0289052],[42.8214296,-2.0287213],[42.82149,-2.0286407],[42.8214947,-2.028614],[42.8215113,-2.0285198],[42.8215216,-2.0284189]]',
      'naranja'),
  ZonaSeed(
      'Zunbeltz',
      'parcela_pasto',
      'Pieza de la Puerta',
      'Pol. 24 parc. 2 subp. M',
      'en_uso',
      'Límite oficial del Catastro de Navarra (IDENA, oct-2026).',
      '[[42.8193983,-2.0258974],[42.8193552,-2.0261563],[42.8193598,-2.0264045],[42.8193424,-2.0266632],[42.8194006,-2.0268121],[42.8194796,-2.0269642],[42.8196389,-2.0272063],[42.8197245,-2.0274664],[42.8198023,-2.027738],[42.8198616,-2.0279281],[42.8199394,-2.0281971],[42.8199877,-2.0283258],[42.8200221,-2.028436],[42.8200621,-2.0284452],[42.8201068,-2.028442],[42.8201719,-2.0284031],[42.8202828,-2.0283423],[42.8203857,-2.0282457],[42.8204813,-2.0281613],[42.8204323,-2.0278929],[42.8203839,-2.0274642],[42.8203539,-2.0272188],[42.8202073,-2.0270093],[42.8200114,-2.0267332],[42.819803,-2.0264617],[42.8196139,-2.026184],[42.819433,-2.025942]]',
      'naranja'),
  ZonaSeed(
      'Zunbeltz',
      'parcela_pasto',
      'Pieza de la Venta Vieja',
      'Pol. 24 parc. 2 subp. O',
      'en_uso',
      'Límite oficial del Catastro de Navarra (IDENA, oct-2026).',
      '[[42.8182297,-2.0249634],[42.8180413,-2.0248],[42.8167291,-2.0240421],[42.8161007,-2.0238379],[42.815497,-2.0237047],[42.815372,-2.0237161],[42.8153417,-2.0237635],[42.8153002,-2.0239223],[42.8152982,-2.0240873],[42.8153301,-2.02421],[42.8154413,-2.0243873],[42.8155693,-2.0245294],[42.8157431,-2.0246057],[42.8159372,-2.0246561],[42.8160831,-2.024684],[42.8162816,-2.0246437],[42.8164126,-2.0245347],[42.8164997,-2.0242939],[42.8165213,-2.0242713],[42.8165765,-2.0242705],[42.8167426,-2.02432],[42.8167949,-2.024376],[42.8169349,-2.0245966],[42.8170081,-2.0246856],[42.8170916,-2.0247601],[42.8172341,-2.0248763],[42.8173318,-2.0249934],[42.8174289,-2.0250487],[42.8175193,-2.0251137],[42.817627,-2.025202],[42.817718,-2.0253475],[42.81777,-2.0253751],[42.8178491,-2.0253407],[42.8180036,-2.025234],[42.8181163,-2.02509],[42.8182291,-2.024965]]',
      'naranja'),
  ZonaSeed(
      'Zunbeltz',
      'cercado',
      'Parques (por confirmar)',
      '',
      'en_uso',
      'Morado en el mapa. ¿Parques de porcino? POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.',
      '[[42.824501,-2.029924],[42.823254,-2.030499],[42.822967,-2.030427],[42.822921,-2.030567],[42.82269,-2.030583],[42.822633,-2.030445],[42.822568,-2.030433],[42.822573,-2.029903],[42.821943,-2.029912],[42.821938,-2.030481],[42.8223,-2.030488],[42.822264,-2.030627],[42.821939,-2.030594],[42.821928,-2.030367],[42.821779,-2.030256],[42.821771,-2.029245],[42.821854,-2.029193],[42.821871,-2.028966],[42.821602,-2.028982],[42.821564,-2.028856],[42.821619,-2.028792],[42.821608,-2.028527],[42.822331,-2.028542],[42.822406,-2.028642],[42.822417,-2.02897],[42.822585,-2.029094],[42.822587,-2.029359],[42.822782,-2.029344],[42.822883,-2.029216],[42.823126,-2.02949],[42.823766,-2.029556],[42.823884,-2.029314],[42.824014,-2.029313],[42.824109,-2.029551],[42.824111,-2.029816],[42.824407,-2.029761],[42.824491,-2.029823]]',
      'violeta'),
  ZonaSeed(
      'Zunbeltz',
      'otra',
      'Zona granate (por confirmar)',
      '',
      'en_uso',
      'Granate en el mapa. ¿Enfermería / cuarentena? POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.',
      '[[42.819931,-2.028552],[42.819491,-2.029228],[42.819512,-2.029544],[42.818894,-2.029806],[42.818554,-2.03019],[42.818452,-2.030192],[42.818367,-2.030016],[42.818265,-2.029992],[42.818204,-2.029286],[42.818563,-2.029002],[42.818822,-2.028935],[42.818959,-2.028731],[42.819144,-2.02864],[42.81941,-2.028333],[42.819577,-2.02833]]',
      'rojo'),
  ZonaSeed(
      'Zunbeltz',
      'otra',
      'Zona verde (por confirmar)',
      '',
      'en_uso',
      'Verde en el mapa. POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.',
      '[[42.822348,-2.02844],[42.821644,-2.028413],[42.821503,-2.028213],[42.822337,-2.028188]]',
      'cian'),
  ZonaSeed(
      'Zunbeltz',
      'monte',
      'Pieza sin nombre A (norte)',
      '',
      'en_uso',
      'Monte. NOMBRE POR CONFIRMAR con Zunbeltz. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.',
      '[[42.8275923,-2.0327783],[42.8276688,-2.0317425],[42.8271882,-2.0317441],[42.8271718,-2.0313282],[42.8278204,-2.0312639],[42.827849,-2.0307703],[42.8279134,-2.0305611],[42.8278961,-2.0297443],[42.8273764,-2.029778],[42.8273457,-2.0291209],[42.8267279,-2.0290608],[42.8262946,-2.0289452],[42.8263107,-2.0294082],[42.8258649,-2.0294142],[42.8258455,-2.0287356],[42.8255117,-2.0286579],[42.8254993,-2.0290912],[42.8250451,-2.0290981],[42.8250208,-2.0285484],[42.8247333,-2.0285471],[42.824718,-2.0288562],[42.824731,-2.0290153],[42.8246665,-2.0291424],[42.8245776,-2.0292692],[42.8246209,-2.0294316],[42.8245962,-2.0296299],[42.8245281,-2.0298288],[42.824493,-2.0298327],[42.824501,-2.029924],[42.823254,-2.030499],[42.8230873,-2.0304586],[42.823081,-2.0305741],[42.8230604,-2.0306028],[42.8230065,-2.0305986],[42.8229619,-2.0304794],[42.8229477,-2.0304858],[42.822921,-2.030567],[42.8226902,-2.030583],[42.8226475,-2.030501],[42.8225949,-2.0306467],[42.8224457,-2.0306864],[42.8224116,-2.0317156],[42.8225507,-2.0317191],[42.8230864,-2.031989],[42.8234952,-2.0319704],[42.8238079,-2.0321153],[42.8247021,-2.0322258],[42.8247151,-2.0316989],[42.8251598,-2.0316929],[42.8251373,-2.0321369],[42.8250314,-2.032156],[42.8250343,-2.0323764],[42.8254795,-2.0326807],[42.8257296,-2.032758],[42.8272421,-2.032723]]',
      'azul'),
  ZonaSeed(
      'Zunbeltz',
      'otra',
      'Pieza sin nombre B (junto a la carretera)',
      '',
      'en_uso',
      'Entre La Cañada y la carretera. ¿Finca de la Era (actuación 3)? NOMBRE POR CONFIRMAR con Zunbeltz. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.',
      '[[42.8267627,-2.0286322],[42.8267666,-2.0288547],[42.8269466,-2.0289114],[42.827933,-2.0289369],[42.8280016,-2.0287461],[42.8280092,-2.0285536],[42.8279869,-2.0284621],[42.8269183,-2.0281117],[42.826195,-2.0279941],[42.8248494,-2.0280514],[42.8248586,-2.0283523],[42.8253308,-2.0283176],[42.8260176,-2.0285851],[42.8264848,-2.0285652]]',
      'blanco'),
  ZonaSeed(
      'Zunbeltz',
      'monte',
      'Pieza sin nombre C (oeste)',
      '',
      'en_uso',
      'Monte. NOMBRE POR CONFIRMAR con Zunbeltz. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.',
      '[[42.8206911,-2.0316206],[42.8208132,-2.0316183],[42.8209407,-2.0317341],[42.8213705,-2.0316228],[42.8215594,-2.03162],[42.8218765,-2.0317161],[42.8224468,-2.0316928],[42.8224773,-2.0307273],[42.8223649,-2.0306921],[42.822316,-2.0305415],[42.8222852,-2.0305467],[42.822264,-2.030627],[42.821939,-2.030594],[42.8219282,-2.0305473],[42.8208061,-2.0305642],[42.8199662,-2.0306519],[42.8194772,-2.0306206],[42.8192137,-2.0307211],[42.819129,-2.0306694],[42.8186894,-2.0300589],[42.8186652,-2.0300645],[42.818554,-2.03019],[42.818452,-2.030192],[42.8184144,-2.0301258],[42.8183398,-2.0301452],[42.818322,-2.030206],[42.818175,-2.0302158],[42.8181795,-2.0303705],[42.8184076,-2.0312439],[42.818514,-2.0312486],[42.8186178,-2.031386],[42.818845,-2.0314944],[42.8192996,-2.0315493],[42.8193827,-2.0316227],[42.8199241,-2.0317331],[42.8202151,-2.0317167],[42.8206067,-2.0316649]]',
      'azul'),
  ZonaSeed(
      'Zunbeltz',
      'monte',
      'Pieza sin nombre D (sur)',
      '',
      'en_uso',
      'Monte, entre el camino y la Pieza de los Silos. NOMBRE POR CONFIRMAR con Zunbeltz. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.',
      '[[42.8217596,-2.0303961],[42.8218424,-2.030314],[42.821779,-2.030256],[42.821771,-2.0292453],[42.8218307,-2.029207],[42.8218335,-2.0291718],[42.8217343,-2.0291124],[42.8217167,-2.0289772],[42.821602,-2.028982],[42.821564,-2.028856],[42.8216119,-2.0287991],[42.8216008,-2.0287685],[42.8214238,-2.0287947],[42.8213972,-2.0288751],[42.8213672,-2.0288834],[42.821343,-2.029074],[42.82127,-2.029139],[42.8212432,-2.0291032],[42.8207587,-2.0291032],[42.8205239,-2.029235],[42.8203933,-2.0293628],[42.8202561,-2.029606],[42.8199685,-2.0296025],[42.8197782,-2.0295773],[42.8197325,-2.0294545],[42.8196697,-2.0295698],[42.8196346,-2.0295704],[42.8195607,-2.0294405],[42.8195092,-2.0294695],[42.819512,-2.029544],[42.8188941,-2.0298062],[42.8186765,-2.0300517],[42.8186696,-2.03009],[42.8191855,-2.0307526],[42.8195162,-2.0306653],[42.8199764,-2.030696],[42.820866,-2.0306069],[42.8217538,-2.0306208]]',
      'azul'),
  ZonaSeed(
      'Zunbeltz',
      'parcela_pasto',
      'Las Bordas',
      'Pol. 24 parc. 2 subp. AE',
      'en_uso',
      'Límite oficial del Catastro de Navarra (IDENA, oct-2026).',
      '[[42.8273188,-2.0308218],[42.827288,-2.030807],[42.8273507,-2.0305303],[42.8273738,-2.0305399],[42.827388,-2.0304667],[42.8272803,-2.0303394],[42.8270219,-2.0306176],[42.8268047,-2.0308548],[42.8266099,-2.0309465],[42.8263267,-2.031088],[42.8260066,-2.0310688],[42.8257926,-2.0309996],[42.8255484,-2.0308502],[42.825329,-2.0308214],[42.825188,-2.0309687],[42.8251545,-2.0312111],[42.8253032,-2.0312813],[42.8253869,-2.0313606],[42.8255117,-2.0314151],[42.8257252,-2.031436],[42.825814,-2.0314184],[42.8258833,-2.0312078],[42.8259897,-2.0311739],[42.8261209,-2.0312766],[42.8261338,-2.0314054],[42.8261357,-2.031623],[42.8260781,-2.0318255],[42.8260798,-2.032019],[42.826074,-2.0321385],[42.8264685,-2.032258],[42.8267339,-2.0323134],[42.8270281,-2.0323555],[42.8270691,-2.0319955],[42.8271203,-2.0317367],[42.8269886,-2.0315855],[42.8265917,-2.0315998],[42.8265601,-2.0313584],[42.8266361,-2.0312363],[42.8267896,-2.0311775],[42.8269192,-2.0310787],[42.8270432,-2.0310284],[42.8271794,-2.0310263],[42.8272915,-2.03096]]',
      'naranja'),
  ZonaSeed(
      'La Planilla',
      'otra',
      'Parcela catastral 13-1',
      'Yerri · pol. 13 parc. 1',
      'en_uso',
      '188,69 ha. Límite oficial del Catastro de Navarra (IDENA, oct-2026).',
      '[[42.7721718,-2.0070488],[42.7721319,-2.0068142],[42.7720621,-2.006804],[42.770984,-2.0067323],[42.7703878,-2.0067328],[42.7701854,-2.0067425],[42.770013,-2.0067689],[42.7698624,-2.0068057],[42.7697302,-2.0068578],[42.7688399,-2.0072966],[42.7684875,-2.0075268],[42.7681463,-2.0077257],[42.767942,-2.0078895],[42.7678234,-2.0080518],[42.7676678,-2.0082895],[42.7674125,-2.0087405],[42.7672214,-2.009097],[42.7670519,-2.0093178],[42.7667973,-2.0096038],[42.7665658,-2.0099221],[42.7662866,-2.0103984],[42.7660764,-2.0107849],[42.7658463,-2.0112463],[42.7656671,-2.0116539],[42.765561,-2.0119234],[42.7652736,-2.0127467],[42.7652218,-2.0128286],[42.7651223,-2.0129501],[42.7648323,-2.0136195],[42.7645687,-2.014167],[42.7643102,-2.0146569],[42.7642146,-2.014822],[42.7641082,-2.0156795],[42.7640314,-2.0163919],[42.7639748,-2.0170665],[42.7638365,-2.0179324],[42.7638374,-2.0180319],[42.7637924,-2.0183548],[42.7637037,-2.0188931],[42.7636827,-2.0190957],[42.7637076,-2.0194329],[42.7637797,-2.0198144],[42.7638404,-2.0201836],[42.763942,-2.0206502],[42.7639765,-2.0209511],[42.7640075,-2.021139],[42.7640782,-2.0214538],[42.764204,-2.0217788],[42.7642743,-2.0220159],[42.764349,-2.0222326],[42.7646536,-2.0229348],[42.7648142,-2.0233325],[42.7649857,-2.0238202],[42.7649895,-2.0238777],[42.7649729,-2.0239666],[42.7649437,-2.024051],[42.7649307,-2.0241679],[42.7648813,-2.0243288],[42.7648055,-2.0244792],[42.7648905,-2.0245107],[42.7651656,-2.0245474],[42.7652998,-2.0245814],[42.765378,-2.0246192],[42.765513,-2.0247761],[42.7658011,-2.0252343],[42.7661088,-2.0256984],[42.7664563,-2.0261262],[42.7666832,-2.0263208],[42.7670052,-2.0265265],[42.7674425,-2.0266637],[42.7676971,-2.0267147],[42.768496,-2.0267958],[42.7690904,-2.0267878],[42.769285,-2.0267681],[42.7694806,-2.0267297],[42.7700221,-2.0266835],[42.7704275,-2.0266749],[42.7707605,-2.0266269],[42.7708807,-2.0266001],[42.7710887,-2.0265141],[42.7713599,-2.0264901],[42.7715591,-2.0264959],[42.7720969,-2.0264541],[42.7722503,-2.0264677],[42.7728501,-2.0265764],[42.7732084,-2.0266655],[42.7734099,-2.0267582],[42.7735404,-2.0268215],[42.7745528,-2.0275116],[42.7747898,-2.0276399],[42.7748358,-2.0275181],[42.7749838,-2.0272003],[42.7751509,-2.0266488],[42.7752863,-2.0261475],[42.775658,-2.0249879],[42.7759661,-2.0240922],[42.776132,-2.0235236],[42.7762096,-2.0233063],[42.7762823,-2.0226829],[42.7764902,-2.0211614],[42.7765794,-2.0207308],[42.77666,-2.0202913],[42.7767469,-2.0199825],[42.7768784,-2.0193994],[42.7769962,-2.0188195],[42.7771092,-2.0181728],[42.7773081,-2.0172841],[42.777402,-2.0167247],[42.777519,-2.0162211],[42.7776801,-2.0153141],[42.7777634,-2.0149897],[42.7778341,-2.0146514],[42.7777439,-2.0144094],[42.7776174,-2.0139639],[42.7775752,-2.0137262],[42.7773817,-2.0131225],[42.7771583,-2.0130466],[42.776801,-2.01295],[42.7765351,-2.0128512],[42.7758214,-2.0126254],[42.7757343,-2.0125841],[42.7754178,-2.0124017],[42.7753397,-2.0123276],[42.7751436,-2.0122188],[42.7749577,-2.0120835],[42.7748143,-2.0119914],[42.7746526,-2.0119025],[42.7744785,-2.0118542],[42.7740092,-2.0117975],[42.7739015,-2.0117767],[42.7735727,-2.011655],[42.7733801,-2.0115648],[42.7733342,-2.011517],[42.773245,-2.0112626],[42.7730593,-2.01062],[42.7726443,-2.0090053],[42.772316,-2.0076155]]',
      'blanco'),
  ZonaSeed(
      'La Planilla',
      'otra',
      'Parcela catastral 13-2',
      'Yerri · pol. 13 parc. 2',
      'en_uso',
      '8,45 ha. Límite oficial del Catastro de Navarra (IDENA, oct-2026).',
      '[[42.7707194,-2.0021368],[42.7707198,-2.0021772],[42.770619,-2.0025213],[42.770576,-2.0026979],[42.7703021,-2.0034822],[42.7701143,-2.0039414],[42.7699563,-2.004285],[42.7695653,-2.00502],[42.7693313,-2.0054333],[42.7691054,-2.0058542],[42.7686093,-2.0068572],[42.7684683,-2.0070666],[42.7681191,-2.0076266],[42.7687627,-2.0072342],[42.7690665,-2.0070686],[42.7696563,-2.0067814],[42.7699242,-2.0066895],[42.7701354,-2.0066547],[42.7704062,-2.0066267],[42.7706603,-2.0066456],[42.7709665,-2.0066469],[42.7715844,-2.0066696],[42.7719129,-2.0066994],[42.7721028,-2.006704],[42.7719588,-2.0061716],[42.7718592,-2.005883],[42.7718394,-2.0057867],[42.7718355,-2.005418],[42.771795,-2.0047446],[42.7717774,-2.0043667],[42.7717753,-2.0041255],[42.7717346,-2.0039671],[42.7716807,-2.0036564],[42.7716425,-2.0032818],[42.7716228,-2.0029552],[42.771542,-2.0022199],[42.7712546,-2.002154],[42.7710222,-2.0021249],[42.7708928,-2.0021135]]',
      'blanco'),
  ZonaSeed(
      'La Planilla',
      'parcela_pasto',
      'Prado de La Planilla',
      'Pol. 13 parc. 1 subp. C',
      'en_uso',
      '9,59 ha, pastizal en SIGPAC. Límite oficial del Catastro de Navarra (IDENA, oct-2026).',
      '[[42.7726684,-2.0123762],[42.77259,-2.0123028],[42.7727362,-2.0121192],[42.7725859,-2.011823],[42.7722799,-2.011508],[42.7721855,-2.011147],[42.7719266,-2.0108739],[42.7716857,-2.0108991],[42.7715559,-2.0111677],[42.771362,-2.0112241],[42.7710347,-2.011144],[42.7708178,-2.0112328],[42.7710628,-2.0107917],[42.7711447,-2.0103746],[42.7711867,-2.0098408],[42.7709827,-2.0096308],[42.7706708,-2.0095185],[42.7704707,-2.0097563],[42.7701295,-2.0098683],[42.7697258,-2.0099387],[42.7694674,-2.009716],[42.7692016,-2.0095496],[42.7689384,-2.0096818],[42.7687377,-2.0098556],[42.768586,-2.0102951],[42.7684335,-2.0106387],[42.7683814,-2.0109168],[42.7680425,-2.0112847],[42.7680517,-2.0114445],[42.7682312,-2.0115269],[42.7684633,-2.0113953],[42.768654,-2.0111899],[42.7688137,-2.0116779],[42.7689245,-2.0119106],[42.7690889,-2.0120466],[42.7692233,-2.0122191],[42.7692621,-2.0123104],[42.7690621,-2.0125482],[42.7688151,-2.012744],[42.7685991,-2.0129287],[42.7685389,-2.0131536],[42.768803,-2.0131387],[42.7693772,-2.0130443],[42.769541,-2.0130768],[42.7700177,-2.0131074],[42.7701266,-2.0129629],[42.7706121,-2.0129081],[42.7708686,-2.0129779],[42.7711483,-2.0129628],[42.7714061,-2.0131187],[42.7718172,-2.0130375],[42.7721565,-2.0127335],[42.7722728,-2.0126997],[42.7727628,-2.0127559],[42.7728881,-2.0124715]]',
      'amarillo'),
];

const List<TareaSeed> tareasEspacio = [
  TareaSeed(
      'Zunbeltz',
      'actuacion-1',
      '1. Cierre norte sierra Urbasa (izda. portillo): Desbroce y reparación',
      'Actuación 1 del mapa de la finca. Cierre norte sierra Urbasa (izda. portillo). Desbroce y reparación',
      '',
      'Portillo norte (sierra de Urbasa)',
      'media'),
  TareaSeed(
      'Zunbeltz',
      'actuacion-2',
      '2. Cierre norte sierra Urbasa (dcha. portillo): Desbroce y reparación',
      'Actuación 2 del mapa de la finca. Cierre norte sierra Urbasa (dcha. portillo). Desbroce y reparación',
      '',
      'Portillo norte (sierra de Urbasa)',
      'media'),
  TareaSeed(
      'Zunbeltz',
      'actuacion-3',
      '3. Finca de la Era: Limpieza de muro seco, reparación',
      'Actuación 3 del mapa de la finca. Finca de la Era. Limpieza de muro seco, reparación. Colocación de puerta.',
      '',
      'Finca de la Era',
      'media'),
  TareaSeed(
      'Zunbeltz',
      'actuacion-4',
      '4. La Cañada: Colocación de malla ganadera, alambre y 2 portillos',
      'Actuación 4 del mapa de la finca. La Cañada. Colocación de malla ganadera, alambre y 2 portillos.',
      '',
      'La Cañada',
      'media'),
  TareaSeed(
      'Zunbeltz',
      'actuacion-5',
      '5. Cierre lado oeste finca: Limpieza alambrado y reparación',
      'Actuación 5 del mapa de la finca. Cierre lado oeste finca. Limpieza alambrado y reparación.',
      'Cierre perimetral',
      '',
      'media'),
  TareaSeed(
      'Zunbeltz',
      'actuacion-6',
      '6. Sectorización oeste finca: Colocación de malla ganadera, portillo y alambre',
      'Actuación 6 del mapa de la finca. Sectorización oeste finca. Colocación de malla ganadera, portillo y alambre.',
      '',
      'Sectorización oeste',
      'media'),
  TareaSeed(
      'Zunbeltz',
      'actuacion-7',
      '7. Sectorización parques: Instalación de portillo ganadero de 1 hoja',
      'Actuación 7 del mapa de la finca. Sectorización parques. Instalación de portillo ganadero de 1 hoja.',
      'Parques (por confirmar)',
      '',
      'media'),
  TareaSeed(
      'Zunbeltz',
      'actuacion-8',
      '8. Pieza de los Silos (frente al aprisco): Sectorización de pieza de los Silos con cierre y portillo de 2 hojas',
      'Actuación 8 del mapa de la finca. Pieza de los Silos (frente al aprisco). Sectorización de pieza de los Silos con cierre y portillo de 2 hojas.',
      'Pieza de los Silos',
      '',
      'media'),
  TareaSeed(
      'Zunbeltz',
      'actuacion-9',
      '9. Entrada finca: Desbroce y limpieza',
      'Actuación 9 del mapa de la finca. Entrada finca. Desbroce y limpieza.',
      '',
      'Entrada de la finca',
      'media'),
  TareaSeed(
      'Zunbeltz',
      'actuacion-10',
      '10. Aprisco: Colocación de cierre y puerta',
      'Actuación 10 del mapa de la finca. Aprisco. Colocación de cierre y puerta.',
      '',
      'Aprisco',
      'media'),
  TareaSeed(
      'Zunbeltz',
      'actuacion-11',
      '11. Pieza de la Puerta: Reparación de muro seco',
      'Actuación 11 del mapa de la finca. Pieza de la Puerta. Reparación de muro seco. Colocación de malla ganadera y postes.',
      'Pieza de la Puerta',
      '',
      'media'),
  TareaSeed(
      'Zunbeltz',
      'actuacion-12',
      '12. Pieza de la Puerta: Reparación de muro seco',
      'Actuación 12 del mapa de la finca. Pieza de la Puerta. Reparación de muro seco. Colocación de malla ganadera y postes.',
      'Pieza de la Puerta',
      '',
      'media'),
  TareaSeed(
      'Zunbeltz',
      'actuacion-13',
      '13. Pieza de la Venta Vieja: Reparación de muro seco',
      'Actuación 13 del mapa de la finca. Pieza de la Venta Vieja. Reparación de muro seco. Colocación de malla ganadera. Instalación de abrevadero.',
      'Pieza de la Venta Vieja',
      '',
      'media'),
];
