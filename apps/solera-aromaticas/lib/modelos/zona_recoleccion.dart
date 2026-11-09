import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart'
    show contornoVacio, leerContorno;
import 'lista_ids.dart';

/// Tipo de terreno de una zona de recolección silvestre.
const List<String> tiposTerrenoRecoleccion = [
  'monte_publico',
  'monte_privado',
  'otro',
];

/// Zona de recolección silvestre con el permiso que la ampara.
///
/// La app **no decide** si hace falta permiso ni qué límite aplica: guarda
/// lo que dice la autorización del órgano autonómico (Ley 42/2007, art. 61,
/// y la normativa de cada comunidad, ver CLAUDE.md). Si no hay permiso, los
/// campos van vacíos y la app avisa al apuntar una recolección.
class ZonaRecoleccion {
  ZonaRecoleccion({
    this.id,
    required this.nombre,
    this.comunidadAutonoma = '',
    this.municipio = '',
    this.tipoTerreno = 'monte_publico',
    this.titularTerreno = '',
    this.numeroPermiso = '',
    this.organismoPermiso = '',
    this.inicioVigenciaMs,
    this.finVigenciaMs,
    this.especiesPermitidas = const [],
    this.limiteKg,
    this.latitud,
    this.longitud,
    this.contorno = contornoVacio,
    this.notas = '',
  });

  final int? id;
  final String nombre;
  final String comunidadAutonoma;
  final String municipio;

  /// Uno de [tiposTerrenoRecoleccion].
  final String tipoTerreno;

  /// Propietario del monte o de la finca (ayuntamiento, junta vecinal…).
  final String titularTerreno;

  /// Número o referencia de la autorización; vacío si no hay.
  final String numeroPermiso;

  /// Órgano que la emite (servicio territorial, ayuntamiento…).
  final String organismoPermiso;
  final int? inicioVigenciaMs;
  final int? finVigenciaMs;

  /// Ids del catálogo de especies (o nombres libres) que cubre el permiso.
  final List<String> especiesPermitidas;

  /// Cantidad máxima autorizada en kg frescos durante la vigencia (todas
  /// las especies juntas); null si el permiso no fija límite o no se sabe.
  final double? limiteKg;
  final double? latitud;
  final double? longitud;

  /// Área marcada en el mapa: JSON `[[lat,lng],…]` (nuevo_ser_mapa).
  final String contorno;

  List<LatLng> get vertices => leerContorno(contorno);
  final String notas;

  bool get tienePermiso => numeroPermiso.trim().isNotEmpty;
  bool get tieneUbicacion => latitud != null && longitud != null;

  /// El permiso cubre [momento]: hay permiso y la fecha está en su vigencia.
  bool vigenteEn(DateTime momento) => tienePermiso && dentroDeVigencia(momento);

  /// [momento] cae entre las fechas de vigencia (los dos extremos
  /// incluidos; el fin vale para todo ese día). Sin fechas, true.
  bool dentroDeVigencia(DateTime momento) {
    final ms = momento.millisecondsSinceEpoch;
    if (inicioVigenciaMs != null) {
      final inicio = DateTime.fromMillisecondsSinceEpoch(inicioVigenciaMs!);
      final inicioDelDia = DateTime(inicio.year, inicio.month, inicio.day);
      if (ms < inicioDelDia.millisecondsSinceEpoch) return false;
    }
    if (finVigenciaMs != null) {
      final fin = DateTime.fromMillisecondsSinceEpoch(finVigenciaMs!);
      final finDelDia = DateTime(fin.year, fin.month, fin.day + 1);
      if (!momento.isBefore(finDelDia)) return false;
    }
    return true;
  }

  /// Días que faltan hasta el fin de la vigencia (negativo si ya pasó);
  /// null sin fecha de fin.
  int? diasHastaFinVigencia(DateTime hoy) {
    if (finVigenciaMs == null) return null;
    final fin = DateTime.fromMillisecondsSinceEpoch(finVigenciaMs!);
    return DateTime.utc(fin.year, fin.month, fin.day)
        .difference(DateTime.utc(hoy.year, hoy.month, hoy.day))
        .inDays;
  }

  /// La especie está en el permiso. Si el permiso no enumera especies, null
  /// (no se puede decir).
  bool? cubreEspecie(String especieId) => especiesPermitidas.isEmpty
      ? null
      : especiesPermitidas.contains(especieId);

  ZonaRecoleccion copiarConUbicacion(double latitud, double longitud) =>
      ZonaRecoleccion.fromMap(
          {...toMap(), 'latitud': latitud, 'longitud': longitud});

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'comunidad_autonoma': comunidadAutonoma,
        'municipio': municipio,
        'tipo_terreno': tipoTerreno,
        'titular_terreno': titularTerreno,
        'numero_permiso': numeroPermiso,
        'organismo_permiso': organismoPermiso,
        'inicio_vigencia_ms': inicioVigenciaMs,
        'fin_vigencia_ms': finVigenciaMs,
        'especies_permitidas': unirLista(especiesPermitidas),
        'limite_kg': limiteKg,
        'latitud': latitud,
        'longitud': longitud,
        'contorno': contorno,
        'notas': notas,
      };

  factory ZonaRecoleccion.fromMap(Map<String, Object?> mapa) => ZonaRecoleccion(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        comunidadAutonoma: (mapa['comunidad_autonoma'] as String?) ?? '',
        municipio: (mapa['municipio'] as String?) ?? '',
        tipoTerreno: tiposTerrenoRecoleccion.contains(mapa['tipo_terreno'])
            ? mapa['tipo_terreno'] as String
            : 'otro',
        titularTerreno: (mapa['titular_terreno'] as String?) ?? '',
        numeroPermiso: (mapa['numero_permiso'] as String?) ?? '',
        organismoPermiso: (mapa['organismo_permiso'] as String?) ?? '',
        inicioVigenciaMs: mapa['inicio_vigencia_ms'] as int?,
        finVigenciaMs: mapa['fin_vigencia_ms'] as int?,
        especiesPermitidas:
            separarLista(mapa['especies_permitidas'] as String?),
        limiteKg: (mapa['limite_kg'] as num?)?.toDouble(),
        latitud: (mapa['latitud'] as num?)?.toDouble(),
        longitud: (mapa['longitud'] as num?)?.toDouble(),
        contorno: (mapa['contorno'] as String?) ?? contornoVacio,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
