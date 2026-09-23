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
const List<OpcionCatalogo> canalesComercializacion = [
  OpcionCatalogo('directa', 'Venta directa', 'Zuzeneko salmenta'),
  OpcionCatalogo('mercado', 'Mercado / feria', 'Azoka / feria'),
  OpcionCatalogo('tienda', 'Tienda / grupo de consumo', 'Denda / kontsumo-taldea'),
  OpcionCatalogo('online', 'Online', 'Online'),
  OpcionCatalogo('mayorista', 'Mayorista / distribuidor', 'Handizkaria / banatzailea'),
  OpcionCatalogo('restauracion', 'Restauración', 'Ostalaritza'),
  OpcionCatalogo('otro', 'Otro', 'Bestelakoa'),
];

/// Resultado de una prueba de validación de producto.
const List<OpcionCatalogo> resultadosValidacion = [
  OpcionCatalogo('validado', 'Validado', 'Baliozkotua'),
  OpcionCatalogo('ajustar', 'Ajustar', 'Doitu'),
  OpcionCatalogo('descartar', 'Descartar', 'Baztertu'),
];

/// Categorías de gasto (desglose de costes del proyecto de test).
const List<OpcionCatalogo> categoriasGasto = [
  OpcionCatalogo('alimentacion', 'Alimentación', 'Elikadura'),
  OpcionCatalogo('sanidad', 'Sanidad / veterinario', 'Osasuna / albaitaritza'),
  OpcionCatalogo('insumos', 'Insumos / materiales', 'Hornidurak / materialak'),
  OpcionCatalogo('mano_obra', 'Mano de obra', 'Eskulana'),
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
