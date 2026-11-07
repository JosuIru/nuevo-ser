/// Figura de propiedad del monte. Ley 43/2003, art. 11 (públicos y privados;
/// los vecinales en mano común son privados de naturaleza especial, 11.4) y
/// TRRL art. 75 (bienes comunales de ayuntamientos y juntas vecinales).
const List<String> figurasMonte = [
  'particular',
  'vecinal_mano_comun',
  'comunal_junta_vecinal',
  'comunal_ayuntamiento',
  'otro',
];

/// Instrumentos de gestión forestal (Ley 43/2003, art. 6.m), más «ninguno».
const List<String> tiposInstrumentoGestion = [
  'ninguno',
  'proyecto_ordenacion',
  'plan_dasocratico',
  'plan_tecnico',
  'modelo_tipo',
  'otro',
];

/// Sistemas de certificación forestal que la app sabe apuntar.
const List<String> sistemasCertificacion = ['ninguna', 'pefc', 'fsc'];

/// El monte y quien lo gestiona (tabla de una sola fila): una instalación de
/// la app es un monte, como en el resto de la suite una explotación.
///
/// La época de peligro de incendios la fija cada comunidad autónoma (Ley
/// 43/2003, art. 48.4.b): la app no la sabe y la apunta la persona.
class Monte {
  Monte({
    this.id,
    this.nombre = '',
    this.titular = '',
    this.nif = '',
    this.figura = 'particular',
    this.comunidadAutonoma = '',
    this.municipio = '',
    this.numeroCatalogo = '',
    this.instrumentoGestion = 'ninguno',
    this.referenciaInstrumento = '',
    this.finVigenciaInstrumentoMs,
    this.certificacion = 'ninguna',
    this.codigoCertificado = '',
    this.inicioEpocaPeligroMes,
    this.inicioEpocaPeligroDia,
    this.tecnicoForestal = '',
    this.notas = '',
  });

  final int? id;
  final String nombre;

  /// Persona propietaria, comunidad de montes, junta vecinal o concejo.
  final String titular;
  final String nif;

  /// Uno de [figurasMonte].
  final String figura;
  final String comunidadAutonoma;
  final String municipio;

  /// Número en el catálogo de montes de utilidad pública o en el registro
  /// de montes vecinales, si lo tiene (texto libre).
  final String numeroCatalogo;

  /// Uno de [tiposInstrumentoGestion].
  final String instrumentoGestion;
  final String referenciaInstrumento;
  final int? finVigenciaInstrumentoMs;

  /// Uno de [sistemasCertificacion].
  final String certificacion;
  final String codigoCertificado;

  /// Inicio de la época de peligro de incendios (mes 1-12 y día), tal como
  /// la publica la comunidad autónoma. null = sin apuntar.
  final int? inicioEpocaPeligroMes;
  final int? inicioEpocaPeligroDia;

  /// Técnico forestal de referencia (nombre y contacto, texto libre).
  final String tecnicoForestal;
  final String notas;

  bool get esComunal => figura != 'particular' && figura != 'otro';
  bool get tieneInstrumentoGestion => instrumentoGestion != 'ninguno';
  bool get estaCertificado => certificacion != 'ninguna';

  /// Inicio de la época de peligro en [anyo]; null si no está apuntado o la
  /// fecha no existe (31 de febrero).
  DateTime? inicioEpocaPeligroEn(int anyo) {
    final mes = inicioEpocaPeligroMes;
    final dia = inicioEpocaPeligroDia;
    if (mes == null || dia == null || mes < 1 || mes > 12 || dia < 1) {
      return null;
    }
    final fecha = DateTime(anyo, mes, dia);
    return fecha.month == mes ? fecha : null;
  }

  Monte copiarCon({int? inicioEpocaPeligroMes, int? inicioEpocaPeligroDia}) =>
      Monte.fromMap({
        ...toMap(),
        'inicio_epoca_peligro_mes': inicioEpocaPeligroMes,
        'inicio_epoca_peligro_dia': inicioEpocaPeligroDia,
      });

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'titular': titular,
        'nif': nif,
        'figura': figura,
        'comunidad_autonoma': comunidadAutonoma,
        'municipio': municipio,
        'numero_catalogo': numeroCatalogo,
        'instrumento_gestion': instrumentoGestion,
        'referencia_instrumento': referenciaInstrumento,
        'fin_vigencia_instrumento_ms': finVigenciaInstrumentoMs,
        'certificacion': certificacion,
        'codigo_certificado': codigoCertificado,
        'inicio_epoca_peligro_mes': inicioEpocaPeligroMes,
        'inicio_epoca_peligro_dia': inicioEpocaPeligroDia,
        'tecnico_forestal': tecnicoForestal,
        'notas': notas,
      };

  factory Monte.fromMap(Map<String, Object?> mapa) => Monte(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        titular: (mapa['titular'] as String?) ?? '',
        nif: (mapa['nif'] as String?) ?? '',
        figura: figurasMonte.contains(mapa['figura'])
            ? mapa['figura'] as String
            : 'otro',
        comunidadAutonoma: (mapa['comunidad_autonoma'] as String?) ?? '',
        municipio: (mapa['municipio'] as String?) ?? '',
        numeroCatalogo: (mapa['numero_catalogo'] as String?) ?? '',
        instrumentoGestion:
            tiposInstrumentoGestion.contains(mapa['instrumento_gestion'])
                ? mapa['instrumento_gestion'] as String
                : 'otro',
        referenciaInstrumento:
            (mapa['referencia_instrumento'] as String?) ?? '',
        finVigenciaInstrumentoMs: mapa['fin_vigencia_instrumento_ms'] as int?,
        certificacion: sistemasCertificacion.contains(mapa['certificacion'])
            ? mapa['certificacion'] as String
            : 'ninguna',
        codigoCertificado: (mapa['codigo_certificado'] as String?) ?? '',
        inicioEpocaPeligroMes: mapa['inicio_epoca_peligro_mes'] as int?,
        inicioEpocaPeligroDia: mapa['inicio_epoca_peligro_dia'] as int?,
        tecnicoForestal: (mapa['tecnico_forestal'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
