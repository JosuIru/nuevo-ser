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
];

/// Tipos de punto que se mueven de sitio (corrales, bidones…).
const Set<String> tiposPuntoMoviles = {'corral_movil', 'deposito_movil'};

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
const List<int?> recurrenciasTarea = [null, 1, 7, 15, 30, 90];

/// Etiqueta bilingüe de una periodicidad de tarea.
String etiquetaRecurrencia(int? dias, String idioma) {
  if (dias == null) return idioma == 'eu' ? 'Aldi bakarrekoa' : 'Puntual';
  switch (dias) {
    case 1:
      return idioma == 'eu' ? 'Egunero' : 'Diaria';
    case 7:
      return idioma == 'eu' ? 'Astero' : 'Semanal';
    case 15:
      return idioma == 'eu' ? '15 egunero' : 'Quincenal';
    case 30:
      return idioma == 'eu' ? 'Hilero' : 'Mensual';
    case 90:
      return idioma == 'eu' ? 'Hiruhilero' : 'Trimestral';
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

/// Categorías de gasto (desglose de costes del proyecto de test). Siguen el
/// reparto de costes iniciales del convenio tester (art. 7): ganado,
/// alimentación y veterinario los asume la persona tester; el resto,
/// Zunbeltz (ver [asumidoPorDefecto]).
const List<OpcionCatalogo> categoriasGasto = [
  OpcionCatalogo('ganado', 'Ganado', 'Abereak'),
  OpcionCatalogo('alimentacion', 'Alimentación', 'Elikadura'),
  OpcionCatalogo('sanidad', 'Sanidad / veterinario', 'Osasuna / albaitaritza'),
  OpcionCatalogo('infraestructuras', 'Infraestructuras y fincas', 'Azpiegiturak eta finkak'),
  OpcionCatalogo('insumos', 'Materiales ganaderos / insumos', 'Abeltzaintza-materialak / hornidurak'),
  OpcionCatalogo('transformacion', 'Transformación', 'Eraldaketa'),
  OpcionCatalogo('mano_obra', 'Personal / mano de obra', 'Langileak / eskulana'),
  OpcionCatalogo('alquiler', 'Alquiler / cesión', 'Alokairua / lagapena'),
  OpcionCatalogo('maquinaria', 'Maquinaria / combustible', 'Makineria / erregaia'),
  OpcionCatalogo('servicios', 'Servicios', 'Zerbitzuak'),
  OpcionCatalogo('otros', 'Otros', 'Bestelakoak'),
];

/// Categorías de ingreso (desglose de ingresos del proyecto de test).
const List<OpcionCatalogo> categoriasIngreso = [
  OpcionCatalogo('venta', 'Venta', 'Salmenta'),
  OpcionCatalogo('ayuda', 'Ayuda / prima', 'Laguntza / saria'),
  OpcionCatalogo('otros', 'Otros', 'Bestelakoak'),
];

/// Quién asume un coste: la persona tester o la asociación.
const String asumidoPorTester = 'tester';
const String asumidoPorZunbeltz = 'zunbeltz';

const List<OpcionCatalogo> asumidoPorOpciones = [
  OpcionCatalogo(asumidoPorTester, 'Persona tester', 'Pertsona testerra'),
  OpcionCatalogo(asumidoPorZunbeltz, 'Zunbeltz', 'Zunbeltz'),
];

/// Quién asume de entrada un gasto de esta categoría (convenio, art. 7).
String asumidoPorDefecto(String categoria) =>
    const {'ganado', 'alimentacion', 'sanidad'}.contains(categoria)
        ? asumidoPorTester
        : asumidoPorZunbeltz;

/// Devuelve el catálogo de categorías según el tipo de apunte.
List<OpcionCatalogo> categoriasDe(String tipoApunte) =>
    tipoApunte == 'ingreso' ? categoriasIngreso : categoriasGasto;

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
const String categoriaGastoPorDefecto = 'otros';
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
