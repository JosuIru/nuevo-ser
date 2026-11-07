/// Formatos de cultivo (de la bandeja o de la partida).
const List<String> formatosCultivo = [
  'alveolo',
  'maceta',
  'contenedor',
  'cepellon',
  'raiz_desnuda',
];

/// Prefijo del contenido del QR de las bandejas. El QR lleva el código tal
/// cual (patrón de Arbolado urbano: el payload es el identificador, sin
/// URL ni JSON, para buscarlo en la BD sin interpretar nada).
const String prefijoQrBandeja = 'VIV-B-';

/// Bandeja, contenedor o mesa identificada con un QR.
class Bandeja {
  Bandeja({
    this.id,
    required this.codigoQr,
    this.formato = 'alveolo',
    this.numeroAlveolos = 0,
    this.zonaId,
    this.ubicacion = '',
    this.activa = true,
    this.notas = '',
  });

  final int? id;

  /// Lo que va en el QR y en la etiqueta legible. Único en la BD.
  final String codigoQr;

  /// Uno de [formatosCultivo].
  final String formato;

  /// Alveolos o huecos (0 si no aplica).
  final int numeroAlveolos;

  /// Nave, invernadero o parcela donde está ahora.
  final int? zonaId;

  /// Mesa, pasillo o fila dentro de la zona.
  final String ubicacion;

  /// Una bandeja vacía y guardada deja de estar activa (no se borra: está
  /// en la trazabilidad de lo que se sembró en ella).
  final bool activa;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'codigo_qr': codigoQr,
        'formato': formato,
        'numero_alveolos': numeroAlveolos,
        'zona_id': zonaId,
        'ubicacion': ubicacion,
        'activa': activa ? 1 : 0,
        'notas': notas,
      };

  factory Bandeja.fromMap(Map<String, Object?> mapa) => Bandeja(
        id: mapa['id'] as int?,
        codigoQr: (mapa['codigo_qr'] as String?) ?? '',
        formato: (mapa['formato'] as String?) ?? 'alveolo',
        numeroAlveolos: (mapa['numero_alveolos'] as int?) ?? 0,
        zonaId: mapa['zona_id'] as int?,
        ubicacion: (mapa['ubicacion'] as String?) ?? '',
        activa: (mapa['activa'] as int?) != 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Siguiente código de bandeja libre: «VIV-B-0001», «VIV-B-0002»…
/// Sigue al número más alto de los códigos con el prefijo; los códigos con
/// otro formato (QR de otro sistema) no cuentan.
String siguienteCodigoBandeja(Iterable<String> codigosExistentes) {
  var mayor = 0;
  final patron = RegExp('^${RegExp.escape(prefijoQrBandeja)}(\\d+)\$');
  for (final codigo in codigosExistentes) {
    final coincidencia = patron.firstMatch(codigo.trim());
    if (coincidencia == null) continue;
    final numero = int.parse(coincidencia.group(1)!);
    if (numero > mayor) mayor = numero;
  }
  return '$prefijoQrBandeja${(mayor + 1).toString().padLeft(4, '0')}';
}
