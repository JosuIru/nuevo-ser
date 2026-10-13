// Catálogos y enumeraciones de Solera Zunbeltz (FZ-2).
//
// Las etiquetas llevan castellano y euskera porque la app es bilingüe desde
// el día uno. El euskera es borrador y debe pasar por revisión nativa (ver
// BLOQUEOS-PENDIENTES, 9-bis) — sobre todo la terminología agroganadera. En
// BD se persiste siempre el `codigo` (estable), nunca la etiqueta traducida.

/// Una opción de catálogo con su código estable y etiquetas bilingües.
class OpcionCatalogo {
  const OpcionCatalogo(this.codigo, this.es, this.eu);

  final String codigo;
  final String es;
  final String eu;

  /// Etiqueta en el idioma dado (`'eu'` → euskera; cualquier otro → es).
  String etiqueta(String idioma) => idioma == 'eu' ? eu : es;
}

/// Devuelve la opción cuyo `codigo` coincide, o `null` si no existe.
OpcionCatalogo? buscarOpcion(List<OpcionCatalogo> catalogo, String codigo) {
  for (final opcion in catalogo) {
    if (opcion.codigo == codigo) return opcion;
  }
  return null;
}

/// Tipos de punto de infraestructura que se marcan sobre el mapa.
const List<OpcionCatalogo> tiposPunto = [
  OpcionCatalogo('abrevadero', 'Abrevadero', 'Aska'),
  OpcionCatalogo('manga', 'Manga de manejo', 'Kudeaketa-manga'),
  OpcionCatalogo('cierre', 'Cierre / alambrada', 'Hesia'),
  OpcionCatalogo('refugio', 'Refugio / cabaña', 'Aterpea'),
  OpcionCatalogo('cuadra', 'Cuadra', 'Ukuilua'),
  OpcionCatalogo('almacen', 'Almacén', 'Biltegia'),
  OpcionCatalogo('balsa', 'Balsa / punto de agua', 'Urmaela'),
  OpcionCatalogo('comedero', 'Comedero', 'Askatokia'),
  OpcionCatalogo('cargadero', 'Cargadero', 'Zamalekua'),
  OpcionCatalogo('parcela', 'Parcela de pasto', 'Larre-saila'),
  // Infraestructura móvil (respuestas de Zunbeltz, 2026-10-06): se recoloca
  // en el mapa cada vez que se mueve.
  OpcionCatalogo('corral_movil', 'Corral móvil', 'Korta mugikorra'),
  OpcionCatalogo(
      'deposito_movil', 'Bidón / depósito portátil', 'Ur-biltegi eramangarria'),
  // Del inventario de Zunbeltz (2026-10-13).
  OpcionCatalogo('aprisco', 'Aprisco', 'Artegia'),
  OpcionCatalogo('placas_solares', 'Placas solares y baterías', 'Eguzki-plakak eta bateriak'),
  OpcionCatalogo('vestuario', 'Caseta / vestuario', 'Etxola / aldagela'),
  OpcionCatalogo('bebedero_movil', 'Bebedero móvil', 'Edaska mugikorra'),
  OpcionCatalogo('pastor_electrico', 'Pastor eléctrico', 'Artzain elektrikoa'),
  OpcionCatalogo('isotermo', 'Isotermo / cámara de frío', 'Isotermoa / hotz-ganbera'),
  OpcionCatalogo('molino', 'Molino', 'Errota'),
];

/// Tipos de punto que se mueven de sitio (corrales, bidones…).
const Set<String> tiposPuntoMoviles = {
  'corral_movil',
  'deposito_movil',
  'bebedero_movil',
  'pastor_electrico',
};

/// Especie del proyecto o del material ganadero. La hoja de amortizaciones
/// de Zunbeltz agrupa el material por especie y ya hay tests avícolas.
const List<OpcionCatalogo> especiesGanado = [
  OpcionCatalogo('vacuno', 'Vacuno', 'Behiak'),
  OpcionCatalogo('ovino', 'Ovino', 'Ardiak'),
  OpcionCatalogo('caprino', 'Caprino', 'Ahuntzak'),
  OpcionCatalogo('porcino', 'Porcino', 'Txerriak'),
  OpcionCatalogo('aves', 'Aves', 'Hegaztiak'),
  OpcionCatalogo('equino', 'Equino', 'Zaldiak'),
  OpcionCatalogo('varias', 'Varias / sin ganado', 'Hainbat / abererik gabe'),
];

/// Estado de conservación de un punto de infraestructura.
const List<OpcionCatalogo> estadosPunto = [
  OpcionCatalogo('operativo', 'Operativo', 'Operatibo'),
  OpcionCatalogo('revisar', 'Revisar', 'Berrikusteke'),
  OpcionCatalogo('averiado', 'Averiado', 'Matxuratuta'),
];

/// Tipos de zona que se dibujan como recinto sobre el mapa. Traducción del
/// euskera pendiente de revisión nativa, como el resto de catálogos.
const List<OpcionCatalogo> tiposZona = [
  OpcionCatalogo('parcela_pasto', 'Parcela de pasto', 'Larre-saila'),
  OpcionCatalogo('cercado', 'Cercado provisional', 'Behin-behineko hesitua'),
  OpcionCatalogo('pastoreo', 'Zona de pastoreo', 'Alha-eremua'),
  OpcionCatalogo('siega', 'Prado de siega', 'Belardi ebakigarria'),
  OpcionCatalogo('monte', 'Monte / arbolado', 'Mendia / zuhaiztia'),
  OpcionCatalogo('vedado', 'Vedado / exclusión', 'Debekatutako eremua'),
  OpcionCatalogo('otra', 'Otra', 'Bestelakoa'),
];

/// Estado de uso de una zona.
const List<OpcionCatalogo> estadosZona = [
  OpcionCatalogo('en_uso', 'En uso', 'Erabilian'),
  OpcionCatalogo('descanso', 'En descanso', 'Atsedenean'),
  OpcionCatalogo('vedada', 'Vedada', 'Debekatuta'),
];

/// Estado de una tarea de mantenimiento (coincide con la leyenda de la
/// presentación: pendiente / en curso / hecha / bloqueada).
const List<OpcionCatalogo> estadosTarea = [
  OpcionCatalogo('pendiente', 'Pendiente', 'Egiteke'),
  OpcionCatalogo('en_curso', 'En curso', 'Egiten'),
  OpcionCatalogo('hecha', 'Hecha', 'Eginda'),
  OpcionCatalogo('bloqueada', 'Bloqueada', 'Blokeatuta'),
];

/// Periodicidad de una tarea recurrente (rellenar comederos, revisar
/// vallados…), en días. `null` = tarea puntual, la opción por defecto.
const List<int?> recurrenciasTarea = [null, 1, 7, 14, 15, 30, 90, 180, 365];

/// Etiqueta bilingüe de una periodicidad de tarea.
String etiquetaRecurrencia(int? dias, String idioma) {
  if (dias == null) return idioma == 'eu' ? 'Aldi bakarrekoa' : 'Puntual';
  switch (dias) {
    case 1:
      return idioma == 'eu' ? 'Egunero' : 'Diaria';
    case 7:
      return idioma == 'eu' ? 'Astero' : 'Semanal';
    case 14:
      return idioma == 'eu' ? '2 astero' : 'Cada 2 semanas';
    case 15:
      return idioma == 'eu' ? '15 egunero' : 'Quincenal';
    case 30:
      return idioma == 'eu' ? 'Hilero' : 'Mensual';
    case 90:
      return idioma == 'eu' ? 'Hiruhilero' : 'Trimestral';
    case 180:
      return idioma == 'eu' ? 'Seihilero' : 'Semestral';
    case 365:
      return idioma == 'eu' ? 'Urtero' : 'Anual';
    default:
      return idioma == 'eu' ? '$dias egunero' : 'Cada $dias días';
  }
}

/// Prioridad de una tarea de mantenimiento.
const List<OpcionCatalogo> prioridadesTarea = [
  OpcionCatalogo('baja', 'Baja', 'Baxua'),
  OpcionCatalogo('media', 'Media', 'Ertaina'),
  OpcionCatalogo('alta', 'Alta', 'Altua'),
];

/// Tipos de registro de actividad del seguimiento del testaje.
const List<OpcionCatalogo> tiposActividad = [
  OpcionCatalogo('alimentacion', 'Alimentación', 'Elikadura'),
  OpcionCatalogo('paricion', 'Pariciones', 'Erditzeak'),
  OpcionCatalogo('producto', 'Producto comercializado', 'Merkaturatutako produktua'),
];

/// Unidad de la cantidad según el tipo de actividad.
String unidadActividad(String tipoActividad, String idioma) {
  switch (tipoActividad) {
    case 'alimentacion':
      return 'kg';
    case 'paricion':
      return idioma == 'eu' ? 'kume' : 'crías';
    default:
      return idioma == 'eu' ? 'unitate' : 'uds';
  }
}

/// Tipos de apunte económico simple.
const List<OpcionCatalogo> tiposApunte = [
  OpcionCatalogo('ingreso', 'Ingreso', 'Sarrera'),
  OpcionCatalogo('gasto', 'Gasto', 'Gastua'),
];

/// Canales de comercialización del proyecto de test.
///
/// Lista del convenio tester (anexo IV, «búsqueda de canales»). Se conservan
/// los códigos antiguos (`tienda`, `mercado`…) para no perder los registros
/// que ya los usan.
const List<OpcionCatalogo> canalesComercializacion = [
  OpcionCatalogo('directa', 'Venta directa', 'Zuzeneko salmenta'),
  OpcionCatalogo('grupo_consumo', 'Grupos de consumo', 'Kontsumo-taldeak'),
  OpcionCatalogo('mercado', 'Mercados y ferias', 'Azokak eta feriak'),
  OpcionCatalogo('tienda', 'Pequeño comercio', 'Merkataritza txikia'),
  OpcionCatalogo('hosteleria', 'Hostelería', 'Ostalaritza'),
  OpcionCatalogo('restauracion', 'Restauración colectiva', 'Jantoki kolektiboak'),
  OpcionCatalogo('acopio', 'Centro de acopio y distribución', 'Bilketa- eta banaketa-zentroa'),
  OpcionCatalogo('crowdfunding', 'Crowdfunding', 'Crowdfundinga'),
  OpcionCatalogo('online', 'Online', 'Online'),
  OpcionCatalogo('mayorista', 'Mayorista / distribuidor', 'Handizkaria / banatzailea'),
  OpcionCatalogo('otro', 'Otros', 'Bestelakoak'),
];

/// Resultado de una prueba de validación de producto.
const List<OpcionCatalogo> resultadosValidacion = [
  OpcionCatalogo('validado', 'Validado', 'Baliozkotua'),
  OpcionCatalogo('ajustar', 'Ajustar', 'Doitu'),
  OpcionCatalogo('descartar', 'Descartar', 'Baztertu'),
];

/// Bloques de gasto de la hoja de seguimiento de Zunbeltz (material del
/// 2026-10-13): fijos para todos los proyectos. Lo que cambia de un
/// proyecto a otro es la partida ([partidasGasto]), no el bloque.
const List<OpcionCatalogo> categoriasGasto = [
  OpcionCatalogo('directos', 'I. Costes directos', 'I. Kostu zuzenak'),
  OpcionCatalogo('maquinaria', 'II. Costes de maquinaria', 'II. Makineria-kostuak'),
  OpcionCatalogo('transformacion', 'III. Coste de transformación', 'III. Eraldaketa-kostua'),
  OpcionCatalogo('mano_obra', 'IV. Costes de mano de obra', 'IV. Eskulan-kostuak'),
  OpcionCatalogo('indirectos', 'V. Costes indirectos', 'V. Zeharkako kostuak'),
  OpcionCatalogo('amortizacion', 'VI. Amortización', 'VI. Amortizazioa'),
];

/// Bloque de las cuotas de amortización: cuentan en el balance del
/// proyecto pero no en el del test.
const String categoriaAmortizacion = 'amortizacion';

/// Partidas habituales de cada bloque, sacadas de los Excel de seguimiento
/// de Zunbeltz. Son sugerencias: cada proyecto puede escribir las suyas
/// (la partida se guarda como código si es de aquí y como texto si no).
const Map<String, List<OpcionCatalogo>> partidasGasto = {
  'directos': [
    OpcionCatalogo('animales', 'Animales', 'Abereak'),
    OpcionCatalogo('compra_alimento', 'Compra de alimento', 'Elikagai-erosketa'),
    OpcionCatalogo('forraje', 'Forraje', 'Bazka'),
    OpcionCatalogo('concentrados', 'Concentrados', 'Kontzentratuak'),
    OpcionCatalogo('transporte_concentrados', 'Transporte de concentrados', 'Kontzentratuen garraioa'),
    OpcionCatalogo('zoosanitarios', 'Productos zoosanitarios y otros suministros', 'Zoosanitarioak eta bestelako hornidurak'),
    OpcionCatalogo('inseminacion', 'Inseminación', 'Intseminazioa'),
    OpcionCatalogo('vacunas_veterinario', 'Vacunas y veterinario', 'Txertoak eta albaitaria'),
    OpcionCatalogo('tasas_cpaen', 'Tasas CPAEN', 'NNPEK tasak'),
    OpcionCatalogo('cama_limpieza', 'Cama, limpieza y desinfección', 'Ohea, garbiketa eta desinfekzioa'),
    OpcionCatalogo('agua_luz', 'Agua, luz y calefacción', 'Ura, argia eta berogailua'),
    OpcionCatalogo('transporte', 'Transporte', 'Garraioa'),
    OpcionCatalogo('semillas_pastizales', 'Semillas y manejo de pastizales', 'Haziak eta larreen kudeaketa'),
    OpcionCatalogo('canon_arrendamiento', 'Canon de arrendamiento', 'Errentamendu-kanona'),
  ],
  'maquinaria': [
    OpcionCatalogo('trabajos_realizados', 'Trabajos realizados', 'Egindako lanak'),
    OpcionCatalogo('combustibles', 'Combustibles', 'Erregaiak'),
    OpcionCatalogo('reparaciones_cercados', 'Reparaciones y repuestos de cercados', 'Hesien konponketak eta ordezkoak'),
  ],
  'transformacion': [
    OpcionCatalogo('transporte_matadero', 'Transporte', 'Garraioa'),
    OpcionCatalogo('tasa_sanitaria', 'Tasa sanitaria', 'Osasun-tasa'),
    OpcionCatalogo('sacrificio', 'Sacrificio', 'Hiltzea'),
    OpcionCatalogo('despiece', 'Deshuese y despiece', 'Hezurgabetzea eta zatiketa'),
    OpcionCatalogo('obrador', 'Trabajos de elaboración (obrador)', 'Elaborazio-lanak (obradorea)'),
    OpcionCatalogo('envasado', 'Envasado y bolsas', 'Ontziratzea eta poltsak'),
    OpcionCatalogo('transporte_venta', 'Transporte de venta', 'Salmenta-garraioa'),
    OpcionCatalogo('comercializacion', 'Comercialización', 'Merkaturatzea'),
  ],
  'mano_obra': [
    OpcionCatalogo('asalariada', 'Asalariada', 'Soldatapekoa'),
    OpcionCatalogo('no_asalariada', 'No asalariada', 'Soldatapekoa ez dena'),
  ],
  'indirectos': [
    OpcionCatalogo('financieros_impuestos', 'Intereses, gastos financieros e impuestos', 'Interesak, finantza-gastuak eta zergak'),
    OpcionCatalogo('mano_obra_familiar', 'Mano de obra familiar', 'Familiako eskulana'),
  ],
  'amortizacion': [
    OpcionCatalogo('instalaciones', 'Instalaciones', 'Instalazioak'),
    OpcionCatalogo('material_ganadero', 'Material ganadero', 'Abeltzaintza-materiala'),
    OpcionCatalogo('adecuaciones', 'Adecuaciones de finca', 'Finkaren egokitzapenak'),
  ],
};

/// Partidas que de entrada asume la persona tester: los animales, su
/// alimentación y su sanidad (convenio, art. 7; así lo reparte también la
/// hoja de seguimiento de Zunbeltz). El resto, Zunbeltz.
const Set<String> partidasAsumidasPorTester = {
  'animales',
  'compra_alimento',
  'forraje',
  'concentrados',
  'transporte_concentrados',
  'zoosanitarios',
  'inseminacion',
  'vacunas_veterinario',
};

/// Categorías de ingreso de la hoja de seguimiento.
const List<OpcionCatalogo> categoriasIngreso = [
  OpcionCatalogo('venta', 'Venta de ganado y productos ganaderos', 'Abereen eta abeltzaintza-produktuen salmenta'),
  OpcionCatalogo('venta_transformado', 'Venta de transformado', 'Eraldatutakoaren salmenta'),
  OpcionCatalogo('ayuda', 'Subvenciones directas y primas', 'Diru-laguntza zuzenak eta sariak'),
  OpcionCatalogo('otros', 'Otros', 'Bestelakoak'),
];

/// Quién asume un coste: la persona tester o la asociación.
const String asumidoPorTester = 'tester';
const String asumidoPorZunbeltz = 'zunbeltz';

const List<OpcionCatalogo> asumidoPorOpciones = [
  OpcionCatalogo(asumidoPorTester, 'Persona tester', 'Pertsona testerra'),
  OpcionCatalogo(asumidoPorZunbeltz, 'Zunbeltz', 'Zunbeltz'),
];

/// Quién asume de entrada un gasto de esta partida (convenio, art. 7).
String asumidoPorDefecto(String partida) =>
    partidasAsumidasPorTester.contains(partida)
        ? asumidoPorTester
        : asumidoPorZunbeltz;

/// Devuelve el catálogo de categorías según el tipo de apunte.
List<OpcionCatalogo> categoriasDe(String tipoApunte) =>
    tipoApunte == 'ingreso' ? categoriasIngreso : categoriasGasto;

/// Partidas sugeridas de un bloque de gasto (vacío para ingresos).
List<OpcionCatalogo> partidasDe(String categoria) =>
    partidasGasto[categoria] ?? const [];

/// Etiqueta de una partida: la del catálogo si es un código conocido; si
/// no, el texto tal cual (partida propia del proyecto).
String etiquetaPartida(String categoria, String partida, String idioma) =>
    buscarOpcion(partidasDe(categoria), partida)?.etiqueta(idioma) ?? partida;

/// Si [texto] es la etiqueta (en cualquier idioma) de una partida del
/// bloque, su código; si no, el texto recortado.
String codigoPartida(String categoria, String texto) {
  final limpio = texto.trim();
  final minusculas = limpio.toLowerCase();
  for (final opcion in partidasDe(categoria)) {
    if (opcion.codigo == limpio ||
        opcion.es.toLowerCase() == minusculas ||
        opcion.eu.toLowerCase() == minusculas) {
      return opcion.codigo;
    }
  }
  return limpio;
}

/// Categorías de gasto de antes de los bloques (hasta la BD v10) → bloque
/// y partida. Los datos guardados en el servidor o en un móvil sin migrar
/// pueden traerlas todavía.
const Map<String, (String, String)> _categoriasGastoAntiguas = {
  'ganado': ('directos', 'animales'),
  'alimentacion': ('directos', 'compra_alimento'),
  'sanidad': ('directos', 'vacunas_veterinario'),
  'insumos': ('directos', 'zoosanitarios'),
  'alquiler': ('directos', 'canon_arrendamiento'),
  'infraestructuras': ('maquinaria', 'reparaciones_cercados'),
  'servicios': ('indirectos', ''),
  'otros': ('directos', ''),
};

/// Bloque y partida de un gasto, traduciendo las categorías antiguas.
/// Una cuota de amortización va siempre al bloque VI.
(String categoria, String partida) normalizarCategoriaGasto(
    String categoria, String partida, bool esAmortizacion) {
  var bloque = categoria;
  var partidaNormalizada = partida;
  final antigua = _categoriasGastoAntiguas[categoria];
  if (antigua != null) {
    bloque = antigua.$1;
    if (partidaNormalizada.isEmpty) partidaNormalizada = antigua.$2;
  } else if (buscarOpcion(categoriasGasto, categoria) == null) {
    bloque = 'directos';
  }
  if (esAmortizacion && bloque != categoriaAmortizacion) {
    bloque = categoriaAmortizacion;
    // La partida antigua (p. ej. «reparaciones_cercados») no es de este
    // bloque; mejor sin partida que con una equivocada.
    if (buscarOpcion(partidasDe(bloque), partidaNormalizada) == null &&
        antigua != null) {
      partidaNormalizada = '';
    }
  }
  return (bloque, partidaNormalizada);
}

/// Tipos de IVA aplicables (España). 0 = sin IVA / exento.
const List<int> tiposIva = [0, 4, 10, 21];

/// Códigos por defecto (primer alta).
const String tipoPuntoPorDefecto = 'abrevadero';
const String estadoPuntoPorDefecto = 'operativo';
const String tipoZonaPorDefecto = 'parcela_pasto';
const String estadoZonaPorDefecto = 'en_uso';
const String estadoTareaPorDefecto = 'pendiente';
const String prioridadTareaPorDefecto = 'media';
const String tipoActividadPorDefecto = 'alimentacion';
const String tipoApuntePorDefecto = 'gasto';
const String canalComercializacionPorDefecto = 'directa';
const String resultadoValidacionPorDefecto = 'validado';
const String categoriaGastoPorDefecto = 'directos';
const String categoriaIngresoPorDefecto = 'venta';
const int ivaPorDefecto = 0;

/// Movimientos de la fianza (convenio, art. 7 y 8).
const List<OpcionCatalogo> tiposMovimientoFianza = [
  OpcionCatalogo('deposito', 'Depósito', 'Gordailua'),
  OpcionCatalogo('devolucion', 'Devolución', 'Itzulketa'),
  OpcionCatalogo('retencion', 'Retención', 'Atxikipena'),
];

/// Niveles de incidencia de cumplimiento (convenio, art. 8).
const List<OpcionCatalogo> nivelesIncidencia = [
  OpcionCatalogo('leve', 'Leve', 'Arina'),
  OpcionCatalogo('grave', 'Grave', 'Larria'),
  OpcionCatalogo('muy_grave', 'Muy grave', 'Oso larria'),
];

/// Actividades de acompañamiento que cuentan en los indicadores del anexo
/// IV del convenio.
const List<OpcionCatalogo> tiposAcompanamiento = [
  OpcionCatalogo('formacion', 'Formación', 'Prestakuntza'),
  OpcionCatalogo('visita_referencia', 'Visita a explotación de referencia', 'Erreferentziazko ustiategira bisita'),
  OpcionCatalogo('asesoramiento', 'Asesoramiento de ganadería experta', 'Abeltzain adituen aholkularitza'),
  OpcionCatalogo('reunion', 'Reunión de seguimiento', 'Jarraipen-bilera'),
  OpcionCatalogo('visita_finca', 'Visita del equipo a la finca', 'Taldearen bisita finkara'),
  OpcionCatalogo('visita_recibida', 'Visita recibida en el espacio', 'Gunean jasotako bisita'),
  OpcionCatalogo('mercado', 'Mercado o feria', 'Azoka edo feria'),
  OpcionCatalogo('difusion', 'Medio de difusión', 'Hedabidea'),
  OpcionCatalogo('busqueda_canales', 'Búsqueda de canales de venta', 'Salmenta-bideen bilaketa'),
  OpcionCatalogo('apoyo_tareas', 'Apoyo en tareas generales', 'Laguntza zeregin orokorretan'),
];

/// Si la persona tester asistió a lo propuesto.
const List<OpcionCatalogo> asistenciasAcompanamiento = [
  OpcionCatalogo('propuesta', 'Propuesta', 'Proposatua'),
  OpcionCatalogo('asistida', 'Asistió', 'Joan zen'),
  OpcionCatalogo('no_asistida', 'No asistió', 'Ez zen joan'),
];
