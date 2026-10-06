/// Categorías de aviso, como en la app de la Mancomunidad de Andía que
/// propuso Zunbeltz (respuestas del 2026-10-06). PROVISIONAL hasta verla.
const String categoriaAvisoGanado = 'ganado';
const String categoriaAvisoInstalaciones = 'instalaciones';
const String categoriaAvisoSeguimiento = 'seguimiento';
const String categoriaAvisoNoticias = 'noticias';

const List<String> categoriasAviso = [
  categoriaAvisoGanado,
  categoriaAvisoInstalaciones,
  categoriaAvisoSeguimiento,
  categoriaAvisoNoticias,
];

/// `alarma`: animal enfermo, rotura importante, falta de alimento… salta
/// como notificación al momento. `aviso`: lo normal.
const String gravedadAlarma = 'alarma';
const String gravedadAviso = 'aviso';

const String estadoAvisoAbierto = 'abierto';
const String estadoAvisoResuelto = 'resuelto';

/// Aviso de campo: algo que alguien ve y cuenta al resto del espacio (una
/// oveja coja, un cierre roto, que se acaba el pienso) o una noticia de
/// coordinación (feria, subvención). Lo ve todo el espacio.
class AvisoCampo {
  AvisoCampo({
    this.id,
    this.autorUid = '',
    this.fincaId,
    this.puntoId,
    this.categoria = categoriaAvisoInstalaciones,
    this.gravedad = gravedadAviso,
    this.titulo = '',
    this.descripcion = '',
    this.estado = estadoAvisoAbierto,
    this.fechaMs = 0,
  });

  final int? id;
  final String autorUid;
  final int? fincaId;
  final int? puntoId;
  final String categoria;
  final String gravedad;
  final String titulo;
  final String descripcion;
  final String estado;
  final int fechaMs;

  bool get esAlarma => gravedad == gravedadAlarma;
  bool get abierto => estado == estadoAvisoAbierto;

  Map<String, Object?> toMap() => {
        'id': id,
        'autor_uid': autorUid,
        'finca_id': fincaId,
        'punto_id': puntoId,
        'categoria': categoria,
        'gravedad': gravedad,
        'titulo': titulo,
        'descripcion': descripcion,
        'estado': estado,
        'fecha_ms': fechaMs,
      };

  factory AvisoCampo.fromMap(Map<String, Object?> mapa) => AvisoCampo(
        id: mapa['id'] as int?,
        autorUid: (mapa['autor_uid'] as String?) ?? '',
        fincaId: mapa['finca_id'] as int?,
        puntoId: mapa['punto_id'] as int?,
        categoria:
            (mapa['categoria'] as String?) ?? categoriaAvisoInstalaciones,
        gravedad: (mapa['gravedad'] as String?) ?? gravedadAviso,
        titulo: (mapa['titulo'] as String?) ?? '',
        descripcion: (mapa['descripcion'] as String?) ?? '',
        estado: (mapa['estado'] as String?) ?? estadoAvisoAbierto,
        fechaMs: (mapa['fecha_ms'] as int?) ?? 0,
      );
}
