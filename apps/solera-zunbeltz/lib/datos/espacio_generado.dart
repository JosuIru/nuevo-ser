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
  FincaSeed('Zunbeltz', 42.8223, -2.0297, 231.0, 'Yerri · pol. 24 parc. 2',
      'Centro del perímetro del mapa de actuaciones (oct-2026). Superficie pública, PROVISIONAL — validar con Zunbeltz'),
  FincaSeed('La Planilla', 42.801, -1.972, 197.0, '',
      'PROVISIONAL · superficie publica, centroide aproximado — validar con Zunbeltz'),
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
  PuntoSeed(
      'Zunbeltz',
      'parcela',
      'Las Bordas',
      42.826588,
      -2.030831,
      'operativo',
      'Pol. 24 parc. 2 subp. AE. Sin contorno todavía. Plano «Subparcelas entorno de Zunbeltz» (QGIS).'),
];

const List<ZonaSeed> zonasEspacio = [
  ZonaSeed(
      'Zunbeltz',
      'otra',
      'Perímetro de la finca',
      '',
      'en_uso',
      'Línea amarilla del mapa de actuaciones. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.',
      '[[42.82801,-2.028533],[42.827971,-2.029329],[42.82735,-2.029351],[42.827372,-2.029793],[42.827909,-2.029785],[42.827935,-2.030631],[42.827862,-2.03086],[42.827847,-2.031264],[42.827162,-2.031325],[42.827184,-2.031754],[42.827675,-2.031747],[42.827655,-2.032745],[42.827609,-2.032796],[42.825654,-2.032775],[42.825422,-2.032703],[42.825021,-2.032431],[42.825019,-2.032153],[42.825186,-2.032138],[42.825173,-2.031683],[42.8247,-2.03169],[42.824695,-2.032233],[42.82374,-2.032134],[42.823424,-2.031987],[42.823109,-2.03203],[42.822505,-2.031748],[42.822502,-2.03147],[42.823114,-2.031461],[42.82312,-2.031019],[42.82248,-2.031016],[42.822487,-2.030687],[42.822598,-2.030673],[42.822643,-2.030571],[42.822467,-2.030498],[42.822453,-2.029968],[42.821981,-2.029975],[42.821974,-2.030328],[42.821789,-2.030331],[42.821735,-2.030572],[42.819105,-2.030674],[42.819263,-2.030773],[42.819327,-2.030684],[42.821893,-2.030608],[42.82191,-2.03043],[42.822318,-2.030424],[42.82232,-2.030664],[42.822441,-2.030738],[42.822421,-2.031711],[42.8218,-2.031733],[42.821447,-2.031638],[42.820874,-2.031747],[42.820734,-2.031648],[42.819873,-2.031762],[42.818778,-2.031513],[42.818377,-2.031266],[42.818186,-2.030587],[42.818174,-2.030208],[42.818322,-2.030206],[42.818358,-2.030067],[42.818302,-2.030017],[42.818256,-2.030081],[42.818043,-2.030084],[42.817968,-2.02987],[42.818001,-2.029478],[42.818203,-2.029185],[42.818655,-2.028875],[42.818838,-2.028594],[42.819179,-2.028463],[42.819354,-2.02827],[42.81966,-2.028253],[42.819653,-2.027445],[42.819366,-2.027436],[42.819224,-2.027047],[42.819192,-2.026529],[42.819254,-2.026225],[42.819467,-2.026222],[42.819487,-2.026361],[42.819617,-2.026409],[42.819646,-2.026624],[42.819767,-2.026635],[42.819805,-2.02676],[42.819917,-2.026822],[42.819917,-2.028009],[42.820177,-2.028018],[42.820189,-2.028422],[42.820402,-2.028432],[42.820416,-2.028962],[42.820888,-2.028955],[42.820897,-2.028828],[42.821203,-2.028837],[42.821204,-2.029039],[42.821288,-2.029138],[42.821378,-2.028796],[42.821591,-2.02878],[42.821605,-2.028148],[42.822383,-2.028111],[42.822385,-2.028402],[42.822478,-2.028413],[42.822513,-2.028173],[42.822698,-2.02817],[42.822707,-2.028081],[42.824514,-2.02808],[42.824784,-2.028328],[42.824839,-2.028239],[42.824838,-2.028024],[42.826273,-2.027978],[42.827276,-2.028177],[42.827982,-2.028432]]',
      'amarillo'),
  ZonaSeed(
      'Zunbeltz',
      'parcela_pasto',
      'Pieza Larga',
      'Pol. 24 parc. 2 subp. E',
      'en_uso',
      'Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.',
      '[[42.824698,-2.02905],[42.824532,-2.029178],[42.824525,-2.029545],[42.824444,-2.029736],[42.824351,-2.029699],[42.824284,-2.029536],[42.824155,-2.029538],[42.824023,-2.029287],[42.823856,-2.029302],[42.823747,-2.029519],[42.823116,-2.029427],[42.822696,-2.029029],[42.822611,-2.028891],[42.82261,-2.028664],[42.822516,-2.02859],[42.822487,-2.028451],[42.822552,-2.028412],[42.82255,-2.028223],[42.823542,-2.028183],[42.824395,-2.028359],[42.824564,-2.028635],[42.82462,-2.028634],[42.824613,-2.028899]]',
      'naranja'),
  ZonaSeed(
      'Zunbeltz',
      'parcela_pasto',
      'Pieza de los Silos',
      'Pol. 24 parc. 2 subp. N',
      'en_uso',
      'Frente al aprisco. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.',
      '[[42.821471,-2.028833],[42.821444,-2.028959],[42.821361,-2.028897],[42.821148,-2.028951],[42.821094,-2.029205],[42.820649,-2.029161],[42.820251,-2.029255],[42.820244,-2.029533],[42.819781,-2.029527],[42.819761,-2.029401],[42.819603,-2.029277],[42.819666,-2.029074],[42.819759,-2.029073],[42.819776,-2.028934],[42.819924,-2.02883],[42.819922,-2.028679],[42.820107,-2.028562],[42.820105,-2.028373],[42.820022,-2.028349],[42.819956,-2.028198],[42.820001,-2.028084],[42.820409,-2.028128],[42.82041,-2.028204],[42.82016,-2.028195],[42.820134,-2.028511],[42.820357,-2.028533],[42.820379,-2.029026],[42.820944,-2.029005],[42.82094,-2.028449],[42.820467,-2.028443],[42.820466,-2.028317],[42.820855,-2.028197],[42.820863,-2.028109],[42.82102,-2.028069],[42.821045,-2.028839],[42.821231,-2.028887],[42.821248,-2.028747],[42.821424,-2.028745]]',
      'naranja'),
  ZonaSeed(
      'Zunbeltz',
      'parcela_pasto',
      'Pieza de la Puerta',
      'Pol. 24 parc. 2 subp. M',
      'en_uso',
      'Contorno trazado a mano. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.',
      '[[42.820188,-2.028308],[42.820277,-2.027777],[42.819429,-2.026084],[42.819384,-2.027348],[42.819909,-2.028186]]',
      'naranja'),
  ZonaSeed(
      'Zunbeltz',
      'parcela_pasto',
      'Pieza de la Venta Vieja',
      'Pol. 24 parc. 2 subp. O',
      'en_uso',
      'Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.',
      '[[42.817381,-2.024901],[42.817325,-2.024915],[42.816811,-2.024341],[42.816477,-2.024334],[42.816202,-2.024692],[42.815683,-2.024598],[42.81543,-2.024337],[42.815419,-2.024122],[42.815345,-2.024048],[42.815437,-2.024008],[42.815436,-2.023895],[42.815575,-2.023855],[42.815964,-2.023925],[42.81603,-2.024037],[42.816299,-2.023995],[42.816624,-2.024079],[42.816755,-2.024229],[42.817378,-2.024535]]',
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
      'Monte (sur)',
      '',
      'en_uso',
      'Azul en el mapa. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.',
      '[[42.822615,-2.031658],[42.821633,-2.031673],[42.821549,-2.031573],[42.821538,-2.031371],[42.821204,-2.0313],[42.821179,-2.031679],[42.821068,-2.031681],[42.820982,-2.031404],[42.820852,-2.031406],[42.82078,-2.031597],[42.820372,-2.031578],[42.820363,-2.031641],[42.819993,-2.031672],[42.819947,-2.031748],[42.81965,-2.031639],[42.81963,-2.031538],[42.819167,-2.031495],[42.819165,-2.03133],[42.81909,-2.031231],[42.818812,-2.031235],[42.818805,-2.031412],[42.818757,-2.031311],[42.818609,-2.031314],[42.818478,-2.031101],[42.818475,-2.030709],[42.818308,-2.030699],[42.818323,-2.03032],[42.818694,-2.030314],[42.81874,-2.030238],[42.818741,-2.030452],[42.81889,-2.030513],[42.818892,-2.030728],[42.819077,-2.030738],[42.819085,-2.030548],[42.819001,-2.030449],[42.819,-2.03031],[42.818898,-2.030299],[42.818897,-2.030197],[42.818832,-2.030186],[42.81884,-2.030047],[42.819025,-2.029993],[42.819033,-2.02988],[42.819329,-2.029825],[42.819331,-2.03009],[42.819489,-2.0301],[42.819497,-2.029948],[42.819636,-2.029934],[42.819643,-2.029681],[42.820041,-2.029587],[42.82018,-2.02961],[42.820202,-2.029989],[42.82035,-2.029999],[42.820359,-2.029923],[42.820516,-2.029908],[42.820515,-2.029744],[42.820877,-2.029789],[42.820875,-2.029612],[42.820764,-2.029601],[42.820753,-2.02945],[42.820531,-2.02944],[42.820548,-2.029314],[42.820742,-2.029222],[42.821401,-2.029263],[42.821408,-2.029061],[42.821482,-2.02906],[42.821558,-2.02921],[42.821744,-2.029283],[42.821678,-2.030345],[42.821567,-2.03036],[42.821569,-2.030638],[42.822228,-2.030742],[42.822257,-2.030893],[42.822572,-2.030951],[42.822574,-2.031191],[42.8225,-2.031192],[42.82249,-2.031041],[42.822351,-2.031043],[42.822343,-2.031283],[42.822399,-2.031295],[42.82241,-2.031446],[42.822585,-2.031431]]',
      'azul'),
  ZonaSeed(
      'Zunbeltz',
      'monte',
      'Monte (norte)',
      '',
      'en_uso',
      'Azul en el mapa. Mapa de actuaciones de Zunbeltz (oct-2026), encajado sobre la ortofoto PNOA: ±5 m.',
      '[[42.827942,-2.029191],[42.827943,-2.029304],[42.827312,-2.029276],[42.827305,-2.029491],[42.827055,-2.029608],[42.827066,-2.029798],[42.827503,-2.029905],[42.827504,-2.030056],[42.827356,-2.030096],[42.827434,-2.030537],[42.827647,-2.030522],[42.827645,-2.030345],[42.827589,-2.030333],[42.827588,-2.030169],[42.827523,-2.030107],[42.827662,-2.030105],[42.827697,-2.029851],[42.827799,-2.02985],[42.827782,-2.030141],[42.827858,-2.03038],[42.827803,-2.030393],[42.827825,-2.030835],[42.827727,-2.031329],[42.82768,-2.031229],[42.827495,-2.031231],[42.827485,-2.031143],[42.827235,-2.031235],[42.827235,-2.031147],[42.827364,-2.031132],[42.827353,-2.030943],[42.827224,-2.030945],[42.827215,-2.031046],[42.827058,-2.031074],[42.827119,-2.031805],[42.827546,-2.031812],[42.82763,-2.031975],[42.82752,-2.03204],[42.827521,-2.032242],[42.827605,-2.032253],[42.827605,-2.032316],[42.827504,-2.03233],[42.827506,-2.032646],[42.827459,-2.032495],[42.827218,-2.032511],[42.8272,-2.032613],[42.826987,-2.032679],[42.826764,-2.032506],[42.82656,-2.032509],[42.826552,-2.032724],[42.826348,-2.032701],[42.826329,-2.032575],[42.825811,-2.032735],[42.825801,-2.032672],[42.82543,-2.032614],[42.825419,-2.032412],[42.825216,-2.032428],[42.825231,-2.032023],[42.825287,-2.03201],[42.825286,-2.031896],[42.825535,-2.031842],[42.825534,-2.03164],[42.824653,-2.031628],[42.824649,-2.032209],[42.824834,-2.032219],[42.824779,-2.03227],[42.824547,-2.03221],[42.824528,-2.032135],[42.824296,-2.032113],[42.824285,-2.031886],[42.8241,-2.031888],[42.824073,-2.032104],[42.823581,-2.031997],[42.823952,-2.031979],[42.82396,-2.031865],[42.824155,-2.031824],[42.824115,-2.031522],[42.823921,-2.031525],[42.823876,-2.031765],[42.823709,-2.031743],[42.823698,-2.031541],[42.823485,-2.031493],[42.823466,-2.031418],[42.823215,-2.031422],[42.82317,-2.031511],[42.82321,-2.030752],[42.823145,-2.030677],[42.823208,-2.030525],[42.823846,-2.030351],[42.823938,-2.030236],[42.824151,-2.030233],[42.824298,-2.030041],[42.824511,-2.030013],[42.824606,-2.029241],[42.824818,-2.029098],[42.824814,-2.028606],[42.824879,-2.028554],[42.824973,-2.028692],[42.824977,-2.029222],[42.825551,-2.029163],[42.825605,-2.029023],[42.825556,-2.02867],[42.825612,-2.028682],[42.82566,-2.028871],[42.825752,-2.02887],[42.825663,-2.029225],[42.825367,-2.029305],[42.825284,-2.02942],[42.825295,-2.029622],[42.82548,-2.029581],[42.82549,-2.029657],[42.825657,-2.029654],[42.825702,-2.029565],[42.825814,-2.029564],[42.825822,-2.029488],[42.826369,-2.02948],[42.826385,-2.029227],[42.826587,-2.029021],[42.826968,-2.029129],[42.826979,-2.029256],[42.827145,-2.029253],[42.827154,-2.029177],[42.827284,-2.029175],[42.827292,-2.029099],[42.827349,-2.0292],[42.827497,-2.029197],[42.827524,-2.029096],[42.827663,-2.029081]]',
      'azul'),
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
      'Perímetro de la finca',
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
