import 'constantes.dart';

/// Tareas tipo de Zunbeltz para el ganado y las instalaciones, sacadas del
/// documento que mandó Pablo el 2026-10-13 (`Ganado.docx`). Sirven para dar
/// de alta tareas y peticiones sin escribirlas cada vez.
///
/// La periodicidad sugerida es PROVISIONAL: el documento dice si cada tarea
/// es rutinaria, puntual, periódica o estacional, pero no cada cuánto; está
/// preguntado (docs/material-zunbeltz-2026-10-13.md, pregunta 1). Se puede
/// cambiar en cada tarea.

/// Cómo la clasifica Zunbeltz.
const List<OpcionCatalogo> tiposPlantillaTarea = [
  OpcionCatalogo('rutinaria', 'Rutinaria', 'Ohikoa'),
  OpcionCatalogo('puntual', 'Puntual', 'Noizbehinkakoa'),
  OpcionCatalogo('periodica', 'Periódica', 'Aldizkakoa'),
  OpcionCatalogo('estacional', 'Estacional', 'Sasoikoa'),
];

const List<OpcionCatalogo> gruposPlantillaTarea = [
  OpcionCatalogo('ganado', 'Ganado', 'Abereak'),
  OpcionCatalogo('instalaciones', 'Instalaciones', 'Instalazioak'),
];

/// Variante de una tarea tipo («Revisión» → «del pastor eléctrico»).
class SubtipoTarea {
  const SubtipoTarea(this.codigo, this.es, this.eu,
      {this.tipoPunto, this.gasto});

  final String codigo;
  final String es;
  final String eu;

  /// Tipo de punto (`tiposPunto`) al que suele ir.
  final String? tipoPunto;

  /// Bloque y partida del gasto que genera (compras).
  final (String, String)? gasto;
}

class PlantillaTarea {
  const PlantillaTarea({
    required this.codigo,
    required this.grupo,
    required this.es,
    required this.eu,
    required this.tipo,
    this.recurrenciaDias,
    this.tipoPunto,
    this.subtipos = const [],
  });

  final String codigo;

  /// `ganado` o `instalaciones`.
  final String grupo;
  final String es;
  final String eu;

  /// Código de `tiposPlantillaTarea`.
  final String tipo;

  /// Periodicidad sugerida (días); `null` = puntual. PROVISIONAL.
  final int? recurrenciaDias;
  final String? tipoPunto;
  final List<SubtipoTarea> subtipos;

  String etiqueta(String idioma) => idioma == 'eu' ? eu : es;

  /// Título de la tarea: «Revisión: pastor eléctrico».
  String titulo(String idioma, [SubtipoTarea? subtipo]) => subtipo == null
      ? etiqueta(idioma)
      : '${etiqueta(idioma)}: ${idioma == 'eu' ? subtipo.eu : subtipo.es}';

  /// Si encaja con un punto de este tipo (ella o alguno de sus subtipos).
  bool encajaCon(String tipoPuntoBuscado) =>
      tipoPunto == tipoPuntoBuscado ||
      subtipos.any((subtipo) => subtipo.tipoPunto == tipoPuntoBuscado);
}

const List<PlantillaTarea> plantillasTarea = [
  // ─── Ganado ───
  PlantillaTarea(
      codigo: 'alimentacion',
      grupo: 'ganado',
      es: 'Alimentación del ganado',
      eu: 'Abereen elikadura',
      tipo: 'rutinaria',
      recurrenciaDias: 1,
      tipoPunto: 'comedero'),
  PlantillaTarea(
      codigo: 'agua',
      grupo: 'ganado',
      es: 'Revisión y suministro de agua',
      eu: 'Uraren berrikuspena eta hornidura',
      tipo: 'rutinaria',
      recurrenciaDias: 1,
      tipoPunto: 'abrevadero'),
  PlantillaTarea(
      codigo: 'limpieza_ganado',
      grupo: 'ganado',
      es: 'Limpieza de comederos, bebederos, corrales y zonas de descanso',
      eu: 'Askak, edaskak, kortak eta atseden-guneak garbitzea',
      tipo: 'rutinaria',
      recurrenciaDias: 7),
  PlantillaTarea(
      codigo: 'rotacion',
      grupo: 'ganado',
      es: 'Cambio de parcela o rotación de pastos',
      eu: 'Lursail-aldaketa edo larreen txandaketa',
      tipo: 'rutinaria',
      recurrenciaDias: 14,
      tipoPunto: 'parcela'),
  PlantillaTarea(
      codigo: 'reproductores',
      grupo: 'ganado',
      es: 'Revisión de animales reproductores y crías',
      eu: 'Abere ugaltzaileen eta umeen berrikuspena',
      tipo: 'rutinaria',
      recurrenciaDias: 7),
  PlantillaTarea(
      codigo: 'curas',
      grupo: 'ganado',
      es: 'Curas',
      eu: 'Sendaketak',
      tipo: 'puntual',
      subtipos: [
        SubtipoTarea('tratamiento', 'tratamiento veterinario',
            'albaitaritza-tratamendua'),
        SubtipoTarea('enfermo', 'animal enfermo o herido',
            'abere gaixoa edo zauritua'),
        SubtipoTarea('vacunacion', 'vacunación', 'txertaketa'),
        SubtipoTarea('desparasitacion', 'desparasitación', 'desparasitazioa'),
      ]),
  PlantillaTarea(
      codigo: 'partos',
      grupo: 'ganado',
      es: 'Gestión de partos y nacimientos',
      eu: 'Erditzeen eta jaiotzen kudeaketa',
      tipo: 'puntual'),
  PlantillaTarea(
      codigo: 'movimiento',
      grupo: 'ganado',
      es: 'Movimiento, carga y transporte de animales',
      eu: 'Abereen mugimendua, karga eta garraioa',
      tipo: 'puntual',
      tipoPunto: 'cargadero',
      subtipos: [
        SubtipoTarea('entrada', 'entrada en la explotación',
            'ustiategira sarrera'),
        SubtipoTarea('salida', 'salida de la explotación',
            'ustiategitik irteera'),
      ]),
  PlantillaTarea(
      codigo: 'identificacion',
      grupo: 'ganado',
      es: 'Identificación y registro de animales',
      eu: 'Abereen identifikazioa eta erregistroa',
      tipo: 'puntual',
      subtipos: [
        SubtipoTarea('alta', 'alta e identificación', 'alta eta identifikazioa'),
        SubtipoTarea('baja', 'baja o animal desaparecido',
            'baja edo abere desagertua'),
      ]),
  PlantillaTarea(
      codigo: 'solicitud_pienso',
      grupo: 'ganado',
      es: 'Solicitud de pienso, forraje o suplementos',
      eu: 'Pentsu, bazka edo osagarri eskaera',
      tipo: 'puntual'),
  PlantillaTarea(
      codigo: 'visita_veterinaria',
      grupo: 'ganado',
      es: 'Coordinación de visita veterinaria',
      eu: 'Albaitari-bisitaren koordinazioa',
      tipo: 'puntual'),

  // ─── Instalaciones ───
  PlantillaTarea(
      codigo: 'revision',
      grupo: 'instalaciones',
      es: 'Revisión',
      eu: 'Berrikuspena',
      tipo: 'rutinaria',
      recurrenciaDias: 7,
      subtipos: [
        SubtipoTarea('vallado', 'vallado, puertas, cierres y accesos',
            'hesia, ateak, itxiturak eta sarbideak',
            tipoPunto: 'cierre'),
        SubtipoTarea('pastor', 'pastor eléctrico', 'artzain elektrikoa',
            tipoPunto: 'pastor_electrico'),
        SubtipoTarea('agua', 'depósitos y sistemas de agua',
            'ur-biltegiak eta ur-sistemak',
            tipoPunto: 'balsa'),
        SubtipoTarea('corrales', 'corrales, refugios y cobertizos',
            'kortak, aterpeak eta estalpeak',
            tipoPunto: 'refugio'),
      ]),
  PlantillaTarea(
      codigo: 'placas',
      grupo: 'instalaciones',
      es: 'Comprobación de placas solares y baterías',
      eu: 'Eguzki-plaken eta baterien egiaztapena',
      tipo: 'rutinaria',
      recurrenciaDias: 30,
      tipoPunto: 'placas_solares'),
  PlantillaTarea(
      codigo: 'limpieza_instalaciones',
      grupo: 'instalaciones',
      es: 'Limpieza general de las instalaciones',
      eu: 'Instalazioen garbiketa orokorra',
      tipo: 'rutinaria',
      recurrenciaDias: 30),
  PlantillaTarea(
      codigo: 'reparacion',
      grupo: 'instalaciones',
      es: 'Reparación',
      eu: 'Konponketa',
      tipo: 'puntual',
      subtipos: [
        SubtipoTarea('vallado', 'vallados y mallas', 'hesiak eta sareak',
            tipoPunto: 'cierre'),
        SubtipoTarea('estructuras', 'puertas, tejados y estructuras',
            'ateak, teilatuak eta egiturak',
            tipoPunto: 'cuadra'),
        SubtipoTarea('agua', 'bebederos y conducciones de agua',
            'edaskak eta ur-hodiak',
            tipoPunto: 'abrevadero'),
      ]),
  PlantillaTarea(
      codigo: 'tractor',
      grupo: 'instalaciones',
      es: 'Mantenimiento del tractor y maquinaria',
      eu: 'Traktorearen eta makineriaren mantentze-lanak',
      tipo: 'periodica',
      recurrenciaDias: 180),
  PlantillaTarea(
      codigo: 'compra',
      grupo: 'instalaciones',
      es: 'Compra',
      eu: 'Erosketa',
      tipo: 'puntual',
      subtipos: [
        SubtipoTarea('combustible', 'gasoil y otros combustibles',
            'gasolioa eta beste erregai batzuk',
            gasto: ('maquinaria', 'combustibles')),
        SubtipoTarea('materiales', 'herramientas y materiales',
            'tresnak eta materialak',
            gasto: ('maquinaria', 'reparaciones_cercados')),
        SubtipoTarea('alimento', 'alimento', 'elikagaiak',
            gasto: ('directos', 'compra_alimento')),
        SubtipoTarea('veterinario', 'tratamientos veterinarios',
            'albaitaritza-tratamenduak',
            gasto: ('directos', 'zoosanitarios')),
      ]),
  PlantillaTarea(
      codigo: 'instalacion',
      grupo: 'instalaciones',
      es: 'Instalación',
      eu: 'Instalazioa',
      tipo: 'puntual',
      subtipos: [
        SubtipoTarea('vallado_movil', 'vallados móviles', 'hesi mugikorrak',
            tipoPunto: 'cierre'),
        SubtipoTarea('pastor', 'pastor eléctrico', 'artzain elektrikoa',
            tipoPunto: 'pastor_electrico'),
        SubtipoTarea('griferia', 'grifería y similares', 'txorrotak eta antzekoak',
            tipoPunto: 'abrevadero'),
      ]),
  PlantillaTarea(
      codigo: 'desbroce',
      grupo: 'instalaciones',
      es: 'Desbroce y mantenimiento de vegetación',
      eu: 'Sasi-garbiketa eta landarediaren mantentzea',
      tipo: 'periodica',
      recurrenciaDias: 90,
      tipoPunto: 'parcela'),
  PlantillaTarea(
      codigo: 'laboreo',
      grupo: 'instalaciones',
      es: 'Preparación y laboreo del terreno',
      eu: 'Lurraren prestaketa eta lantzea',
      tipo: 'puntual',
      tipoPunto: 'parcela'),
  PlantillaTarea(
      codigo: 'siembra',
      grupo: 'instalaciones',
      es: 'Siembra y mantenimiento de pastos',
      eu: 'Larreen ereintza eta mantentzea',
      tipo: 'estacional',
      recurrenciaDias: 365,
      tipoPunto: 'parcela'),
  PlantillaTarea(
      codigo: 'residuos',
      grupo: 'instalaciones',
      es: 'Gestión y retirada de residuos',
      eu: 'Hondakinen kudeaketa eta bilketa',
      tipo: 'puntual'),
];

/// Bloque y partida de gasto para una tarea por su título, si salió de una
/// plantilla de compra (en cualquiera de los dos idiomas). Si no, costes
/// directos sin partida.
(String, String) gastoSugeridoParaTarea(String titulo) {
  final limpio = titulo.trim().toLowerCase();
  for (final plantilla in plantillasTarea) {
    for (final subtipo in plantilla.subtipos) {
      final gasto = subtipo.gasto;
      if (gasto == null) continue;
      if (plantilla.titulo('es', subtipo).toLowerCase() == limpio ||
          plantilla.titulo('eu', subtipo).toLowerCase() == limpio) {
        return gasto;
      }
    }
  }
  return ('directos', '');
}
