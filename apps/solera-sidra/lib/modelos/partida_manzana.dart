import 'codificacion.dart';

/// Estado de la fruta a la entrada (el pliego pide anotarlo).
const List<String> estadosFruta = ['sana', 'danos_leves', 'danos_graves'];

/// Fruta que entra en la sagardotegi (manzana) o en la bodega (uva de
/// txakoli): propia o comprada. Es el «registro de entrada en elaboración»
/// del pliego de Euskal Sagardoa (ap. E): proveedor, cantidad, fecha de
/// recolección, estado de la fruta y fecha de entrega.
class PartidaManzana {
  PartidaManzana({
    this.id,
    required this.fechaEntregaMs,
    required this.kilos,
    this.fruta = 'manzana',
    this.propia = true,
    this.pomaradaId,
    this.proveedor = '',
    this.proveedorRegistradoDop = false,
    this.procedencia = '',
    this.variedades = const {},
    this.fechaRecoleccionMs,
    this.estadoFruta = 'sana',
    this.documentoTransporte = '',
    this.precioCentimosKg = 0,
    this.notas = '',
  });

  final int? id;
  final int fechaEntregaMs;
  final double kilos;

  /// `manzana` o `uva`.
  final String fruta;

  /// De una pomarada propia ([pomaradaId]) o comprada a [proveedor].
  final bool propia;
  final int? pomaradaId;
  final String proveedor;

  /// La persona confirma que el manzanal del proveedor está inscrito en la
  /// DOP. La app no lo comprueba contra ningún registro.
  final bool proveedorRegistradoDop;

  /// Municipio o zona de origen.
  final String procedencia;
  final Set<String> variedades;
  final int? fechaRecoleccionMs;

  /// Uno de [estadosFruta].
  final String estadoFruta;

  /// N.º del título de transporte o albarán que acompaña al lote.
  final String documentoTransporte;

  /// Precio pagado por kilo (0 si es propia o no se sabe).
  final int precioCentimosKg;
  final String notas;

  /// La partida puede ir a una elaboración DOP: propia de una pomarada
  /// registrada lo decide la pomarada; comprada, el proveedor.
  bool procedenciaRegistrada({bool pomaradaRegistrada = false}) =>
      propia ? pomaradaRegistrada : proveedorRegistradoDop;

  Map<String, Object?> toMap() => {
        'id': id,
        'fecha_entrega_ms': fechaEntregaMs,
        'kilos': kilos,
        'fruta': fruta,
        'propia': propia ? 1 : 0,
        'pomarada_id': pomaradaId,
        'proveedor': proveedor,
        'proveedor_registrado_dop': proveedorRegistradoDop ? 1 : 0,
        'procedencia': procedencia,
        'variedades': codificarIds(variedades),
        'fecha_recoleccion_ms': fechaRecoleccionMs,
        'estado_fruta': estadoFruta,
        'documento_transporte': documentoTransporte,
        'precio_centimos_kg': precioCentimosKg,
        'notas': notas,
      };

  factory PartidaManzana.fromMap(Map<String, Object?> mapa) => PartidaManzana(
        id: mapa['id'] as int?,
        fechaEntregaMs: mapa['fecha_entrega_ms'] as int,
        kilos: comoDecimal(mapa['kilos']) ?? 0,
        fruta: mapa['fruta'] == 'uva' ? 'uva' : 'manzana',
        propia: comoBooleano(mapa['propia']),
        pomaradaId: mapa['pomarada_id'] as int?,
        proveedor: (mapa['proveedor'] as String?) ?? '',
        proveedorRegistradoDop: comoBooleano(mapa['proveedor_registrado_dop']),
        procedencia: (mapa['procedencia'] as String?) ?? '',
        variedades: decodificarIds(mapa['variedades']),
        fechaRecoleccionMs: mapa['fecha_recoleccion_ms'] as int?,
        estadoFruta: estadosFruta.contains(mapa['estado_fruta'])
            ? mapa['estado_fruta'] as String
            : 'sana',
        documentoTransporte: (mapa['documento_transporte'] as String?) ?? '',
        precioCentimosKg: (mapa['precio_centimos_kg'] as int?) ?? 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
