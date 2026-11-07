/// Partida de planta: plantas de una especie, variedad y formato que se
/// manejan juntas y comparten código de trazabilidad (letra C del
/// pasaporte). Nace de una siembra o de un repicado de otra partida.
class PartidaPlanta {
  PartidaPlanta({
    this.id,
    required this.codigo,
    required this.especieId,
    this.nombreBotanico = '',
    this.variedad = '',
    this.formato = 'alveolo',
    required this.cantidadInicial,
    this.mermas = 0,
    this.siembraId,
    this.partidaOrigenId,
    this.bandejaId,
    this.zonaId,
    this.paisOrigen = 'ES',
    required this.fechaAltaMs,
    this.listaParaVenta = false,
    this.notas = '',
  });

  final int? id;

  /// Código de trazabilidad propio. Único en la BD.
  final String codigo;

  /// Id del catálogo de especies o texto libre.
  final String especieId;

  /// Letra A del pasaporte. Se copia del catálogo o del lote.
  final String nombreBotanico;
  final String variedad;

  /// Uno de `formatosCultivo` (bandeja.dart).
  final String formato;

  /// Plantas al dar de alta la partida.
  final int cantidadInicial;

  /// Plantas perdidas (marras, descartes) apuntadas hasta hoy.
  final int mermas;

  /// De qué siembra sale (si sale de una).
  final int? siembraId;

  /// De qué partida sale, si es un repicado.
  final int? partidaOrigenId;
  final int? bandejaId;
  final int? zonaId;

  /// Letra D del pasaporte: Estado miembro o país tercero de origen.
  final String paisOrigen;
  final int fechaAltaMs;
  final bool listaParaVenta;
  final String notas;

  PartidaPlanta copiarCon(
          {int? mermas, bool? listaParaVenta, int? bandejaId}) =>
      PartidaPlanta(
        id: id,
        codigo: codigo,
        especieId: especieId,
        nombreBotanico: nombreBotanico,
        variedad: variedad,
        formato: formato,
        cantidadInicial: cantidadInicial,
        mermas: mermas ?? this.mermas,
        siembraId: siembraId,
        partidaOrigenId: partidaOrigenId,
        bandejaId: bandejaId ?? this.bandejaId,
        zonaId: zonaId,
        paisOrigen: paisOrigen,
        fechaAltaMs: fechaAltaMs,
        listaParaVenta: listaParaVenta ?? this.listaParaVenta,
        notas: notas,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'codigo': codigo,
        'especie_id': especieId,
        'nombre_botanico': nombreBotanico,
        'variedad': variedad,
        'formato': formato,
        'cantidad_inicial': cantidadInicial,
        'mermas': mermas,
        'siembra_id': siembraId,
        'partida_origen_id': partidaOrigenId,
        'bandeja_id': bandejaId,
        'zona_id': zonaId,
        'pais_origen': paisOrigen,
        'fecha_alta_ms': fechaAltaMs,
        'lista_para_venta': listaParaVenta ? 1 : 0,
        'notas': notas,
      };

  factory PartidaPlanta.fromMap(Map<String, Object?> mapa) => PartidaPlanta(
        id: mapa['id'] as int?,
        codigo: (mapa['codigo'] as String?) ?? '',
        especieId: (mapa['especie_id'] as String?) ?? '',
        nombreBotanico: (mapa['nombre_botanico'] as String?) ?? '',
        variedad: (mapa['variedad'] as String?) ?? '',
        formato: (mapa['formato'] as String?) ?? 'alveolo',
        cantidadInicial: (mapa['cantidad_inicial'] as int?) ?? 0,
        mermas: (mapa['mermas'] as int?) ?? 0,
        siembraId: mapa['siembra_id'] as int?,
        partidaOrigenId: mapa['partida_origen_id'] as int?,
        bandejaId: mapa['bandeja_id'] as int?,
        zonaId: mapa['zona_id'] as int?,
        paisOrigen: (mapa['pais_origen'] as String?) ?? 'ES',
        fechaAltaMs: (mapa['fecha_alta_ms'] as int?) ?? 0,
        listaParaVenta: (mapa['lista_para_venta'] as int?) == 1,
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Siguiente código de partida del año: «P26-0001», «P26-0002»…
String siguienteCodigoPartida(Iterable<String> codigosExistentes, int anyo) {
  final prefijo = 'P${(anyo % 100).toString().padLeft(2, '0')}-';
  var mayor = 0;
  final patron = RegExp('^${RegExp.escape(prefijo)}(\\d+)\$');
  for (final codigo in codigosExistentes) {
    final coincidencia = patron.firstMatch(codigo.trim());
    if (coincidencia == null) continue;
    final numero = int.parse(coincidencia.group(1)!);
    if (numero > mayor) mayor = numero;
  }
  return '$prefijo${(mayor + 1).toString().padLeft(4, '0')}';
}
