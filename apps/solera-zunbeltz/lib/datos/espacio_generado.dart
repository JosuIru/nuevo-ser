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
  FincaSeed('Zunbeltz', 42.8226, -2.0315, 231.0, 'Yerri · pol. 24 parc. 2',
      'Centro del perímetro del mapa de actuaciones (oct-2026). Superficie pública, PROVISIONAL — validar con Zunbeltz'),
  FincaSeed('La Planilla', 42.801, -1.972, 197.0, '',
      'PROVISIONAL · superficie publica, centroide aproximado — validar con Zunbeltz'),
];

const List<PuntoSeed> puntosEspacio = [
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 1',
      42.828325,
      -2.028554,
      'revisar',
      'Punto rojo nº 1 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Portillo norte (sierra de Urbasa)',
      42.828266,
      -2.029794,
      'revisar',
      'Punto rojo nº 2 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Finca de la Era',
      42.826293,
      -2.02872,
      'revisar',
      'Punto rojo nº 3 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed('Zunbeltz', 'puerta', 'La Cañada', 42.82517, -2.028468, 'revisar',
      'Punto rojo nº 4 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 5',
      42.824727,
      -2.028906,
      'revisar',
      'Punto rojo nº 5 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 6',
      42.824209,
      -2.029844,
      'revisar',
      'Punto rojo nº 6 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Sectorización oeste',
      42.822947,
      -2.030767,
      'revisar',
      'Punto rojo nº 7 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 8',
      42.822617,
      -2.02933,
      'revisar',
      'Punto rojo nº 8 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 9',
      42.822461,
      -2.030815,
      'revisar',
      'Punto rojo nº 9 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 10',
      42.822405,
      -2.028848,
      'revisar',
      'Punto rojo nº 10 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 11',
      42.822322,
      -2.028378,
      'revisar',
      'Punto rojo nº 11 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 12',
      42.822253,
      -2.030859,
      'revisar',
      'Punto rojo nº 12 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 13',
      42.821627,
      -2.030626,
      'revisar',
      'Punto rojo nº 13 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 14',
      42.821595,
      -2.029198,
      'revisar',
      'Punto rojo nº 14 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 15',
      42.821333,
      -2.028798,
      'revisar',
      'Punto rojo nº 15 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 16',
      42.821311,
      -2.028515,
      'revisar',
      'Punto rojo nº 16 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 17',
      42.82116,
      -2.028302,
      'revisar',
      'Punto rojo nº 17 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 18',
      42.821068,
      -2.029166,
      'revisar',
      'Punto rojo nº 18 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 19',
      42.820903,
      -2.028387,
      'revisar',
      'Punto rojo nº 19 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 20',
      42.820897,
      -2.028832,
      'revisar',
      'Punto rojo nº 20 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Entrada de la finca',
      42.820304,
      -2.027978,
      'revisar',
      'Punto rojo nº 21 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 22',
      42.82007,
      -2.029518,
      'revisar',
      'Punto rojo nº 22 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 23',
      42.819951,
      -2.028402,
      'revisar',
      'Punto rojo nº 23 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 24',
      42.819327,
      -2.029665,
      'revisar',
      'Punto rojo nº 24 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 25',
      42.819027,
      -2.025937,
      'revisar',
      'Punto rojo nº 25 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 26',
      42.817884,
      -2.030307,
      'revisar',
      'Punto rojo nº 26 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 27',
      42.817768,
      -2.024878,
      'revisar',
      'Punto rojo nº 27 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed(
      'Zunbeltz',
      'puerta',
      'Puerta / portillo 28',
      42.815605,
      -2.023646,
      'revisar',
      'Punto rojo nº 28 del mapa de actuaciones: qué es exactamente, POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
  PuntoSeed('Zunbeltz', 'aprisco', 'Aprisco', 42.821063, -2.028559, 'revisar',
      'Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.'),
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
      'Línea amarilla del mapa de actuaciones. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.',
      '[[42.828276,-2.028608],[42.828233,-2.029458],[42.827569,-2.029482],[42.827593,-2.029953],[42.828168,-2.029944],[42.828196,-2.030847],[42.828118,-2.031091],[42.828102,-2.031522],[42.827369,-2.031587],[42.827392,-2.032045],[42.827918,-2.032037],[42.827897,-2.033102],[42.827848,-2.033157],[42.825755,-2.033135],[42.825506,-2.033059],[42.825077,-2.032769],[42.825075,-2.032472],[42.825253,-2.032456],[42.825239,-2.031971],[42.824733,-2.031979],[42.824728,-2.032559],[42.823705,-2.032453],[42.823367,-2.032297],[42.82303,-2.032342],[42.822383,-2.032043],[42.82238,-2.031746],[42.823035,-2.031736],[42.823041,-2.031264],[42.822356,-2.031261],[42.822363,-2.030911],[42.822482,-2.030896],[42.822531,-2.030787],[42.822341,-2.030709],[42.822327,-2.030143],[42.821821,-2.030151],[42.821814,-2.030529],[42.821616,-2.030532],[42.821558,-2.030789],[42.818742,-2.0309],[42.818912,-2.031005],[42.81898,-2.03091],[42.821727,-2.030826],[42.821746,-2.030638],[42.822182,-2.030631],[42.822184,-2.030887],[42.822314,-2.030966],[42.822293,-2.032004],[42.821629,-2.032027],[42.821251,-2.031925],[42.820637,-2.032043],[42.820487,-2.031937],[42.819565,-2.03206],[42.818393,-2.031795],[42.817964,-2.031532],[42.817759,-2.030808],[42.817746,-2.030404],[42.817905,-2.030401],[42.817943,-2.030252],[42.817883,-2.030199],[42.817834,-2.030267],[42.817606,-2.030271],[42.817525,-2.030043],[42.817561,-2.029625],[42.817776,-2.029312],[42.81826,-2.028981],[42.818455,-2.028681],[42.818821,-2.028541],[42.819008,-2.028336],[42.819335,-2.028317],[42.819328,-2.027455],[42.81902,-2.027446],[42.818868,-2.027031],[42.818833,-2.026479],[42.8189,-2.026154],[42.819128,-2.026151],[42.819149,-2.026299],[42.819289,-2.02635],[42.81932,-2.026579],[42.819449,-2.02659],[42.81949,-2.026724],[42.81961,-2.02679],[42.819611,-2.028057],[42.819889,-2.028066],[42.819902,-2.028497],[42.82013,-2.028507],[42.820145,-2.029072],[42.820651,-2.029064],[42.82066,-2.02893],[42.820987,-2.028938],[42.820989,-2.029154],[42.821079,-2.02926],[42.821175,-2.028895],[42.821403,-2.028877],[42.821417,-2.028203],[42.82225,-2.028163],[42.822253,-2.028473],[42.822352,-2.028485],[42.82239,-2.028229],[42.822588,-2.028226],[42.822597,-2.028131],[42.824532,-2.028128],[42.824822,-2.028393],[42.82488,-2.028297],[42.824878,-2.028068],[42.826416,-2.028017],[42.827489,-2.02823],[42.828245,-2.028501]]',
      'amarillo'),
  ZonaSeed(
      'Zunbeltz',
      'parcela_pasto',
      'Pieza Larga',
      'Pol. 24 parc. 2 subp. E',
      'en_uso',
      'Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.',
      '[[42.824729,-2.029162],[42.824552,-2.0293],[42.824545,-2.029691],[42.824457,-2.029894],[42.824358,-2.029855],[42.824287,-2.029681],[42.824148,-2.029684],[42.824007,-2.029416],[42.823829,-2.029433],[42.823712,-2.029663],[42.823036,-2.029566],[42.822586,-2.029142],[42.822496,-2.028995],[42.822493,-2.028753],[42.822394,-2.028673],[42.822363,-2.028526],[42.822432,-2.028484],[42.82243,-2.028282],[42.823491,-2.028238],[42.824405,-2.028426],[42.824586,-2.02872],[42.824646,-2.028719],[42.824638,-2.029002]]',
      'naranja'),
  ZonaSeed(
      'Zunbeltz',
      'parcela_pasto',
      'Pieza de los Silos',
      'Pol. 24 parc. 2 subp. N',
      'en_uso',
      'Frente al aprisco. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.',
      '[[42.821275,-2.028933],[42.821246,-2.029069],[42.821156,-2.029003],[42.820929,-2.02906],[42.820871,-2.029331],[42.820395,-2.029284],[42.819969,-2.029385],[42.819962,-2.029682],[42.819466,-2.029676],[42.819445,-2.029542],[42.819275,-2.029409],[42.819343,-2.029193],[42.819442,-2.029191],[42.81946,-2.029043],[42.819618,-2.028932],[42.819617,-2.028771],[42.819814,-2.028646],[42.819812,-2.028444],[42.819723,-2.028419],[42.819652,-2.028258],[42.819701,-2.028136],[42.820138,-2.028183],[42.820138,-2.028264],[42.81987,-2.028255],[42.819843,-2.028592],[42.820082,-2.028615],[42.820106,-2.02914],[42.820711,-2.029117],[42.820706,-2.028525],[42.8202,-2.028519],[42.820199,-2.028384],[42.820614,-2.028256],[42.820623,-2.028162],[42.820792,-2.028119],[42.820819,-2.028941],[42.821017,-2.028991],[42.821036,-2.028843],[42.821224,-2.02884]]',
      'naranja'),
  ZonaSeed(
      'Zunbeltz',
      'parcela_pasto',
      'Pieza de la Puerta',
      'Pol. 24 parc. 2 subp. M',
      'en_uso',
      'Contorno trazado a mano. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.',
      '[[42.819901,-2.028375],[42.819995,-2.027808],[42.819087,-2.026003],[42.819039,-2.027351],[42.819602,-2.028245]]',
      'naranja'),
  ZonaSeed(
      'Zunbeltz',
      'parcela_pasto',
      'Pieza de la Venta Vieja',
      'Pol. 24 parc. 2 subp. O',
      'en_uso',
      'Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.',
      '[[42.816894,-2.024744],[42.816835,-2.024758],[42.816284,-2.024147],[42.815927,-2.024139],[42.815632,-2.024521],[42.815076,-2.024422],[42.814806,-2.024143],[42.814794,-2.023915],[42.814714,-2.023835],[42.814813,-2.023793],[42.814812,-2.023672],[42.81496,-2.023629],[42.815377,-2.023703],[42.815448,-2.023823],[42.815735,-2.023778],[42.816083,-2.023867],[42.816223,-2.024027],[42.816891,-2.024353]]',
      'naranja'),
  ZonaSeed(
      'Zunbeltz',
      'cercado',
      'Parques (por confirmar)',
      '',
      'en_uso',
      'Morado en el mapa. ¿Parques de porcino? POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.',
      '[[42.824519,-2.030096],[42.823185,-2.030709],[42.822877,-2.030633],[42.822828,-2.030782],[42.82258,-2.0308],[42.82252,-2.030652],[42.82245,-2.03064],[42.822455,-2.030074],[42.821781,-2.030084],[42.821776,-2.030691],[42.822163,-2.030698],[42.822124,-2.030847],[42.821777,-2.030812],[42.821765,-2.03057],[42.821605,-2.030451],[42.821596,-2.029373],[42.821685,-2.029318],[42.821703,-2.029075],[42.821415,-2.029093],[42.821374,-2.028959],[42.821433,-2.028891],[42.821421,-2.028608],[42.822195,-2.028623],[42.822275,-2.028729],[42.822288,-2.029079],[42.822468,-2.029211],[42.82247,-2.029494],[42.822678,-2.029477],[42.822786,-2.029341],[42.823047,-2.029633],[42.823732,-2.029704],[42.823858,-2.029446],[42.823997,-2.029443],[42.824099,-2.029698],[42.824101,-2.029981],[42.824418,-2.029922],[42.824508,-2.029988]]',
      'violeta'),
  ZonaSeed(
      'Zunbeltz',
      'otra',
      'Zona granate (por confirmar)',
      '',
      'en_uso',
      'Granate en el mapa. ¿Enfermería / cuarentena? POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.',
      '[[42.819626,-2.028636],[42.819156,-2.029357],[42.819178,-2.029694],[42.818516,-2.029974],[42.818152,-2.030384],[42.818043,-2.030385],[42.817952,-2.030198],[42.817843,-2.030173],[42.817777,-2.029419],[42.818161,-2.029117],[42.818439,-2.029045],[42.818586,-2.028827],[42.818783,-2.02873],[42.819068,-2.028402],[42.819247,-2.028399]]',
      'rojo'),
  ZonaSeed(
      'Zunbeltz',
      'otra',
      'Zona verde (por confirmar)',
      '',
      'en_uso',
      'Verde en el mapa. POR CONFIRMAR. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.',
      '[[42.822214,-2.028514],[42.82146,-2.028486],[42.821309,-2.028273],[42.822201,-2.028245]]',
      'cian'),
  ZonaSeed(
      'Zunbeltz',
      'monte',
      'Monte (sur)',
      '',
      'en_uso',
      'Azul en el mapa. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.',
      '[[42.822501,-2.031946],[42.821449,-2.031963],[42.821359,-2.031856],[42.821347,-2.031641],[42.82099,-2.031566],[42.820963,-2.03197],[42.820844,-2.031972],[42.820753,-2.031677],[42.820614,-2.031679],[42.820536,-2.031883],[42.820099,-2.031863],[42.82009,-2.03193],[42.819694,-2.031963],[42.819645,-2.032045],[42.819326,-2.031929],[42.819305,-2.031821],[42.818809,-2.031775],[42.818808,-2.0316],[42.818727,-2.031493],[42.81843,-2.031498],[42.818421,-2.031687],[42.818371,-2.03158],[42.818212,-2.031582],[42.818071,-2.031355],[42.818068,-2.030938],[42.817889,-2.030927],[42.817906,-2.030522],[42.818302,-2.030516],[42.818351,-2.030435],[42.818353,-2.030664],[42.818512,-2.030728],[42.818514,-2.030957],[42.818713,-2.030968],[42.818721,-2.030766],[42.818631,-2.030659],[42.81863,-2.030511],[42.81852,-2.030499],[42.81852,-2.030391],[42.81845,-2.030379],[42.818459,-2.030231],[42.818657,-2.030174],[42.818665,-2.030052],[42.818982,-2.029993],[42.818985,-2.030276],[42.819154,-2.030287],[42.819162,-2.030125],[42.819311,-2.03011],[42.819318,-2.02984],[42.819744,-2.029739],[42.819893,-2.029764],[42.819916,-2.030167],[42.820075,-2.030178],[42.820084,-2.030097],[42.820253,-2.030081],[42.820251,-2.029906],[42.820639,-2.029954],[42.820637,-2.029765],[42.820518,-2.029754],[42.820507,-2.029592],[42.820269,-2.029583],[42.820287,-2.029447],[42.820495,-2.02935],[42.821199,-2.029393],[42.821207,-2.029177],[42.821287,-2.029176],[42.821368,-2.029336],[42.821567,-2.029414],[42.821497,-2.030547],[42.821378,-2.030562],[42.821381,-2.030859],[42.822086,-2.030969],[42.822117,-2.03113],[42.822455,-2.031192],[42.822457,-2.031448],[42.822378,-2.03145],[42.822366,-2.031288],[42.822217,-2.03129],[42.82221,-2.031547],[42.822269,-2.031559],[42.822281,-2.031721],[42.822469,-2.031704]]',
      'azul'),
  ZonaSeed(
      'Zunbeltz',
      'monte',
      'Monte (norte)',
      '',
      'en_uso',
      'Azul en el mapa. Mapa de actuaciones de Zunbeltz (oct-2026), situado a mano sobre el plano de QGIS: ±20 m.',
      '[[42.828202,-2.02931],[42.828203,-2.029431],[42.827529,-2.029402],[42.827521,-2.029631],[42.827254,-2.029756],[42.827265,-2.029958],[42.827733,-2.030072],[42.827734,-2.030234],[42.827576,-2.030277],[42.827659,-2.030747],[42.827887,-2.03073],[42.827885,-2.030542],[42.827826,-2.030529],[42.827824,-2.030354],[42.827754,-2.030288],[42.827903,-2.030285],[42.82794,-2.030015],[42.82805,-2.030013],[42.828032,-2.030324],[42.828114,-2.030578],[42.828055,-2.030593],[42.828078,-2.031064],[42.827974,-2.031591],[42.827923,-2.031484],[42.827725,-2.031488],[42.827714,-2.031393],[42.827447,-2.031492],[42.827446,-2.031398],[42.827585,-2.031382],[42.827573,-2.03118],[42.827435,-2.031182],[42.827426,-2.03129],[42.827257,-2.03132],[42.827323,-2.0321],[42.82778,-2.032107],[42.82787,-2.03228],[42.827752,-2.03235],[42.827754,-2.032565],[42.827843,-2.032577],[42.827844,-2.032645],[42.827735,-2.03266],[42.827738,-2.032997],[42.827687,-2.032836],[42.827429,-2.032853],[42.82741,-2.032961],[42.827182,-2.033032],[42.826943,-2.032847],[42.826725,-2.032851],[42.826717,-2.03308],[42.826498,-2.033057],[42.826477,-2.032922],[42.825923,-2.033092],[42.825913,-2.033025],[42.825515,-2.032964],[42.825504,-2.032749],[42.825285,-2.032765],[42.825302,-2.032334],[42.825361,-2.03232],[42.82536,-2.032198],[42.825627,-2.03214],[42.825625,-2.031925],[42.824683,-2.031912],[42.824678,-2.032532],[42.824877,-2.032543],[42.824818,-2.032598],[42.824569,-2.032534],[42.824549,-2.032453],[42.8243,-2.03243],[42.824289,-2.032188],[42.82409,-2.032191],[42.824062,-2.032421],[42.823536,-2.032308],[42.823932,-2.032288],[42.823941,-2.032166],[42.824149,-2.032123],[42.824107,-2.0318],[42.823898,-2.031803],[42.823851,-2.03206],[42.823672,-2.032036],[42.82366,-2.03182],[42.823432,-2.03177],[42.823411,-2.03169],[42.823143,-2.031694],[42.823095,-2.031789],[42.823137,-2.03098],[42.823067,-2.0309],[42.823135,-2.030737],[42.823818,-2.030551],[42.823916,-2.030428],[42.824145,-2.030425],[42.824302,-2.03022],[42.824529,-2.03019],[42.824632,-2.029366],[42.824858,-2.029214],[42.824854,-2.028689],[42.824923,-2.028634],[42.825023,-2.02878],[42.825028,-2.029346],[42.825643,-2.029283],[42.825701,-2.029134],[42.825648,-2.028757],[42.825708,-2.02877],[42.825759,-2.028971],[42.825858,-2.028969],[42.825762,-2.029348],[42.825446,-2.029434],[42.825357,-2.029557],[42.825369,-2.029772],[42.825567,-2.029729],[42.825578,-2.029809],[42.825756,-2.029807],[42.825805,-2.029712],[42.825924,-2.02971],[42.825933,-2.029629],[42.826519,-2.02962],[42.826536,-2.02935],[42.826752,-2.029131],[42.82716,-2.029246],[42.827171,-2.02938],[42.82735,-2.029377],[42.827359,-2.029296],[42.827498,-2.029294],[42.827507,-2.029213],[42.827568,-2.02932],[42.827726,-2.029318],[42.827755,-2.029209],[42.827904,-2.029194]]',
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
