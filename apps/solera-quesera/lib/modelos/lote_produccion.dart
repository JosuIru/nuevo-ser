/// Lote de producción — la entidad central de Larrea Quesera.
/// Cada lote = una hornada de queso fabricada un día, con trazabilidad
/// completa de partidas de leche usadas, ingredientes y rendimiento.
///
/// `numeroLote` se autogenera con formato AAAAMMDD-NNN (secuencia
/// diaria). `partidasLecheUsadasJson` almacena los ids de las partidas
/// como JSON array para relación M:N sin tabla intermedia en v0.1.
class LoteProduccion {
  final int? id;
  final String numeroLote;
  final int fechaMs;
  final int recetaId;
  final String tipoQuesoId;
  final String? doId;
  final String partidasLecheUsadasJson; // [idPartida1, idPartida2, ...]
  final double volumenLecheTotal;
  final double pesoTotalObtenido;
  final double rendimientoReal; // autocalculado: L/kg
  final int numPiezasProducidas;
  final double pesoMedioPieza;
  final String fermentoNombre;
  final String fermentoLoteComercial;
  final String cuajoTipo;
  final String cuajoLoteComercial;
  final String salLote;
  final double tempCoagulacion;
  final int tiempoCoagMinutos;
  final double? phCuajada;
  final String estado; // fresca / enCuracion / lista / baja
  final String notas;
  final int fechaCreacionMs;

  LoteProduccion({
    this.id,
    required this.numeroLote,
    required this.fechaMs,
    required this.recetaId,
    this.tipoQuesoId = '',
    this.doId,
    this.partidasLecheUsadasJson = '[]',
    this.volumenLecheTotal = 0,
    this.pesoTotalObtenido = 0,
    this.rendimientoReal = 0,
    this.numPiezasProducidas = 0,
    this.pesoMedioPieza = 0,
    this.fermentoNombre = '',
    this.fermentoLoteComercial = '',
    this.cuajoTipo = 'animal',
    this.cuajoLoteComercial = '',
    this.salLote = '',
    this.tempCoagulacion = 30,
    this.tiempoCoagMinutos = 30,
    this.phCuajada,
    this.estado = 'fresca',
    this.notas = '',
    required this.fechaCreacionMs,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'numero_lote': numeroLote,
        'fecha_ms': fechaMs,
        'receta_id': recetaId,
        'tipo_queso_id': tipoQuesoId,
        'do_id': doId,
        'partidas_leche_usadas_json': partidasLecheUsadasJson,
        'volumen_leche_total': volumenLecheTotal,
        'peso_total_obtenido': pesoTotalObtenido,
        'rendimiento_real': rendimientoReal,
        'num_piezas_producidas': numPiezasProducidas,
        'peso_medio_pieza': pesoMedioPieza,
        'fermento_nombre': fermentoNombre,
        'fermento_lote_comercial': fermentoLoteComercial,
        'cuajo_tipo': cuajoTipo,
        'cuajo_lote_comercial': cuajoLoteComercial,
        'sal_lote': salLote,
        'temp_coagulacion': tempCoagulacion,
        'tiempo_coag_minutos': tiempoCoagMinutos,
        'ph_cuajada': phCuajada,
        'estado': estado,
        'notas': notas,
        'fecha_creacion_ms': fechaCreacionMs,
      };

  factory LoteProduccion.fromMap(Map<String, Object?> mapa) => LoteProduccion(
        id: mapa['id'] as int?,
        numeroLote: mapa['numero_lote'] as String,
        fechaMs: mapa['fecha_ms'] as int,
        recetaId: mapa['receta_id'] as int,
        tipoQuesoId: (mapa['tipo_queso_id'] as String?) ?? '',
        doId: mapa['do_id'] as String?,
        partidasLecheUsadasJson:
            (mapa['partidas_leche_usadas_json'] as String?) ?? '[]',
        volumenLecheTotal: (mapa['volumen_leche_total'] as num?)?.toDouble() ?? 0,
        pesoTotalObtenido: (mapa['peso_total_obtenido'] as num?)?.toDouble() ?? 0,
        rendimientoReal: (mapa['rendimiento_real'] as num?)?.toDouble() ?? 0,
        numPiezasProducidas: (mapa['num_piezas_producidas'] as int?) ?? 0,
        pesoMedioPieza: (mapa['peso_medio_pieza'] as num?)?.toDouble() ?? 0,
        fermentoNombre: (mapa['fermento_nombre'] as String?) ?? '',
        fermentoLoteComercial: (mapa['fermento_lote_comercial'] as String?) ?? '',
        cuajoTipo: (mapa['cuajo_tipo'] as String?) ?? 'animal',
        cuajoLoteComercial: (mapa['cuajo_lote_comercial'] as String?) ?? '',
        salLote: (mapa['sal_lote'] as String?) ?? '',
        tempCoagulacion: (mapa['temp_coagulacion'] as num?)?.toDouble() ?? 30,
        tiempoCoagMinutos: (mapa['tiempo_coag_minutos'] as int?) ?? 30,
        phCuajada: (mapa['ph_cuajada'] as num?)?.toDouble(),
        estado: (mapa['estado'] as String?) ?? 'fresca',
        notas: (mapa['notas'] as String?) ?? '',
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as int?) ?? 0,
      );
}
