/// Qué tablas locales se sincronizan con el WordPress de Zunbeltz
/// (`POST /sync`, ver `servicios/cliente_sync_zunbeltz.dart`) y cómo se
/// traducen sus filas al sobre del servidor:
/// `{tipo, uid, actualizado_ms, borrado, proyecto_uid, autor_uid, datos}`.
///
/// Las referencias entre filas son ids locales (autoincrement, distintos en
/// cada móvil), así que viajan como `uid`: la columna `finca_id` sale en
/// `datos` como `finca_uid` y al bajar se vuelve a traducir a un id local.
/// La pertenencia a un proyecto (`proyecto_id`) va en el sobre
/// (`proyecto_uid`) porque el servidor decide con ella quién lo ve.
///
/// Las tareas no están aquí: tienen su propio formato en el API (ver
/// `ClienteSyncZunbeltz.tareaAJson`).
library;

/// Qué pasa con las filas que apuntan a una que se borra.
enum AlBorrarReferencia { cascada, anular }

class ReferenciaSincronizable {
  const ReferenciaSincronizable(
    this.columna,
    this.tablaDestino, {
    required this.obligatoria,
    required this.alBorrar,
  });

  /// Columna local con el id (`finca_id`).
  final String columna;

  /// Tabla a la que apunta (`fincas`).
  final String tablaDestino;

  /// Sin la fila destino la fila no se puede guardar (columna NOT NULL).
  final bool obligatoria;

  final AlBorrarReferencia alBorrar;

  /// Nombre con el que viaja en `datos`: `finca_id` → `finca_uid`.
  String get claveUid => '${columna.substring(0, columna.length - 3)}_uid';
}

class TablaSincronizable {
  const TablaSincronizable({
    required this.tipo,
    required this.tabla,
    this.referencias = const [],
    this.columnaProyecto,
    this.proyectoObligatorio = false,
    this.columnasLocales = const [],
    this.columnasFotos = const {},
  });

  /// Nombre del tipo en el API (`punto`).
  final String tipo;
  final String tabla;
  final List<ReferenciaSincronizable> referencias;

  /// Columna con el id del proyecto al que pertenece la fila; viaja en el
  /// sobre como `proyecto_uid`. Borrar el proyecto borra estas filas.
  final String? columnaProyecto;
  final bool proyectoObligatorio;

  /// Columnas que no viajan tal cual (rutas de fotos, que son ficheros del
  /// móvil).
  final List<String> columnasLocales;

  /// Columnas de fotos (de [columnasLocales]) que viajan traducidas a
  /// hashes, con la clave de `datos` en que van: `rutas_fotos_json` →
  /// `fotos`. Ver `utiles/fotos_sincronizadas.dart`.
  final Map<String, String> columnasFotos;
}

/// Las fotos de una entidad viajan en `datos.fotos` como hashes.
const Map<String, String> _fotosDeEntidad = {'rutas_fotos_json': 'fotos'};

/// Tablas locales con columnas de fotos (listas JSON de entradas), también
/// las tareas, que no están en [tablasSincronizables]. Sirve para buscar
/// las fotos que hay que preparar, subir o bajar.
const Map<String, List<String>> columnasFotosPorTabla = {
  'fincas': ['rutas_fotos_json'],
  'zonas_finca': ['rutas_fotos_json'],
  'puntos_infraestructura': ['rutas_fotos_json'],
  'tareas_mantenimiento': ['rutas_fotos_antes_json', 'rutas_fotos_despues_json'],
};

/// Claves con que viajan las fotos de una tarea en el API de tareas.
const String claveFotosAntesTarea = 'fotos_antes';
const String claveFotosDespuesTarea = 'fotos_despues';

const _refFinca = ReferenciaSincronizable('finca_id', 'fincas',
    obligatoria: true, alBorrar: AlBorrarReferencia.cascada);
const _refFincaOpcional = ReferenciaSincronizable('finca_id', 'fincas',
    obligatoria: false, alBorrar: AlBorrarReferencia.anular);
const _refPuntoOpcional = ReferenciaSincronizable(
    'punto_id', 'puntos_infraestructura',
    obligatoria: false, alBorrar: AlBorrarReferencia.anular);

const _refZonaOpcional = ReferenciaSincronizable('zona_id', 'zonas_finca',
    obligatoria: false, alBorrar: AlBorrarReferencia.anular);

const _refLoteOpcional = ReferenciaSincronizable('lote_id', 'lotes_ganado',
    obligatoria: false, alBorrar: AlBorrarReferencia.anular);

TablaSincronizable _hijoDeProyecto(String tipo, String tabla) =>
    TablaSincronizable(
      tipo: tipo,
      tabla: tabla,
      columnaProyecto: 'proyecto_id',
      proyectoObligatorio: true,
    );

/// En orden de dependencias: lo referenciado antes que lo que referencia.
final List<TablaSincronizable> tablasSincronizables = [
  const TablaSincronizable(
      tipo: 'finca',
      tabla: 'fincas',
      columnasLocales: ['rutas_fotos_json'],
      columnasFotos: _fotosDeEntidad),
  const TablaSincronizable(
      tipo: 'zona',
      tabla: 'zonas_finca',
      referencias: [_refFinca],
      columnasLocales: ['rutas_fotos_json'],
      columnasFotos: _fotosDeEntidad),
  const TablaSincronizable(
      tipo: 'punto',
      tabla: 'puntos_infraestructura',
      referencias: [_refFinca],
      columnasLocales: ['rutas_fotos_json'],
      columnasFotos: _fotosDeEntidad),
  const TablaSincronizable(
      tipo: 'proyecto',
      tabla: 'proyectos_test',
      referencias: [_refFincaOpcional]),
  const TablaSincronizable(
      tipo: 'registro_actividad',
      tabla: 'registros_actividad',
      referencias: [_refFinca],
      columnaProyecto: 'proyecto_id'),
  const TablaSincronizable(
      tipo: 'apunte',
      tabla: 'apuntes_economicos',
      referencias: [_refFinca],
      columnaProyecto: 'proyecto_id'),
  _hijoDeProyecto('venta', 'registros_comercializacion'),
  _hijoDeProyecto('validacion', 'validaciones_producto'),
  _hijoDeProyecto('partida_presupuesto', 'partidas_presupuesto'),
  _hijoDeProyecto('movimiento_fianza', 'movimientos_fianza'),
  _hijoDeProyecto('acompanamiento', 'acompanamientos'),
  _hijoDeProyecto('incidencia_cumplimiento', 'incidencias_cumplimiento'),
  const TablaSincronizable(
      tipo: 'peticion',
      tabla: 'peticiones',
      referencias: [_refFincaOpcional, _refPuntoOpcional, _refZonaOpcional]),
  const TablaSincronizable(
      tipo: 'aviso',
      tabla: 'avisos',
      referencias: [_refFincaOpcional, _refPuntoOpcional]),
  const TablaSincronizable(tipo: 'contacto', tabla: 'contactos'),
  const TablaSincronizable(tipo: 'rendimiento', tabla: 'rendimientos'),
  _hijoDeProyecto('escenario_transformacion', 'escenarios_transformacion'),
  const TablaSincronizable(
      tipo: 'bien_amortizable', tabla: 'bienes_amortizables'),
  const TablaSincronizable(
    tipo: 'uso_bien',
    tabla: 'usos_bienes',
    referencias: [
      ReferenciaSincronizable('bien_id', 'bienes_amortizables',
          obligatoria: true, alBorrar: AlBorrarReferencia.cascada),
    ],
    columnaProyecto: 'proyecto_id',
    proyectoObligatorio: true,
  ),
  // Ganado (BD v15).
  const TablaSincronizable(tipo: 'lote_ganado', tabla: 'lotes_ganado'),
  const TablaSincronizable(
      tipo: 'animal', tabla: 'animales', referencias: [_refLoteOpcional]),
  const TablaSincronizable(
    tipo: 'movimiento_ganado',
    tabla: 'movimientos_ganado',
    referencias: [
      ReferenciaSincronizable('lote_id', 'lotes_ganado',
          obligatoria: true, alBorrar: AlBorrarReferencia.cascada),
      ReferenciaSincronizable('zona_origen_id', 'zonas_finca',
          obligatoria: false, alBorrar: AlBorrarReferencia.anular),
      ReferenciaSincronizable('zona_destino_id', 'zonas_finca',
          obligatoria: false, alBorrar: AlBorrarReferencia.anular),
    ],
  ),
  const TablaSincronizable(
    tipo: 'evento_ganado',
    tabla: 'eventos_ganado',
    referencias: [
      ReferenciaSincronizable('animal_id', 'animales',
          obligatoria: false, alBorrar: AlBorrarReferencia.cascada),
      ReferenciaSincronizable('lote_id', 'lotes_ganado',
          obligatoria: false, alBorrar: AlBorrarReferencia.cascada),
    ],
  ),
];

TablaSincronizable? tablaSincronizablePorTipo(String tipo) {
  for (final tabla in tablasSincronizables) {
    if (tabla.tipo == tipo) return tabla;
  }
  return null;
}

TablaSincronizable? tablaSincronizablePorNombre(String nombreTabla) {
  for (final tabla in tablasSincronizables) {
    if (tabla.tabla == nombreTabla) return tabla;
  }
  return null;
}

/// uids fijos de las fincas que siembra la app: así dos móviles que las
/// siembran por su cuenta no suben dos copias de la misma finca.
const Map<String, String> uidsFincasSembradas = {
  'Zunbeltz': 'finca-zunbeltz',
  'La Planilla': 'finca-la-planilla',
};

/// uid determinista para lo que siembra la app desde los CSV del espacio
/// (`content/espacio/`): el mismo en todos los móviles.
String uidSembrado(String tipo, String nombre) {
  if (tipo == 'finca' && uidsFincasSembradas.containsKey(nombre)) {
    return uidsFincasSembradas[nombre]!;
  }
  const sinTilde = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n'
  };
  final normalizado = nombre
      .toLowerCase()
      .split('')
      .map((letra) => sinTilde[letra] ?? letra)
      .join()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return '$tipo-$normalizado';
}
