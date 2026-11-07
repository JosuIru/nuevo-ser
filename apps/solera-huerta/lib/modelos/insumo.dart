/// Tipo de insumo, tal como los separa el certificador.
const List<String> tiposInsumo = [
  'fertilizante',
  'enmienda',
  'fitosanitario',
  'otro',
];

/// Insumo que entra en la huerta (abono, enmienda, producto fitosanitario).
///
/// **«Permitido en ecológico» lo marca la persona** con su justificante
/// (etiqueta, listado del organismo de control, certificado del
/// fabricante): la app no lo decide ni lo certifica. La categoría del
/// catálogo (`insumos_ecologicos.csv`) es solo la referencia del anexo.
class Insumo {
  Insumo({
    this.id,
    required this.nombre,
    this.tipo = 'fertilizante',
    this.categoriaEcologicaId = '',
    this.permitidoEcologico = false,
    this.justificantePermitido = '',
    this.numeroRegistro = '',
    this.proveedor = '',
    this.notas = '',
  });

  final int? id;

  /// Nombre tal como figura en el envase o el albarán.
  final String nombre;

  /// Uno de [tiposInsumo].
  final String tipo;

  /// Id del catálogo de categorías de insumos o texto libre.
  final String categoriaEcologicaId;
  final bool permitidoEcologico;

  /// Por qué se marca como permitido: «etiqueta "utilizable en AE"»,
  /// «listado CPAEN 2026»…
  final String justificantePermitido;

  /// Nº del Registro de Productos Fitosanitarios o de fertilizantes.
  final String numeroRegistro;
  final String proveedor;
  final String notas;

  bool get esFitosanitario => tipo == 'fitosanitario';

  /// Marcado como permitido sin decir por qué.
  bool get faltaJustificante =>
      permitidoEcologico && justificantePermitido.trim().isEmpty;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'categoria_ecologica_id': categoriaEcologicaId,
        'permitido_ecologico': permitidoEcologico ? 1 : 0,
        'justificante_permitido': justificantePermitido,
        'numero_registro': numeroRegistro,
        'proveedor': proveedor,
        'notas': notas,
      };

  factory Insumo.fromMap(Map<String, Object?> mapa) => Insumo(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        tipo: (mapa['tipo'] as String?) ?? 'fertilizante',
        categoriaEcologicaId: (mapa['categoria_ecologica_id'] as String?) ?? '',
        permitidoEcologico: (mapa['permitido_ecologico'] as int?) == 1,
        justificantePermitido:
            (mapa['justificante_permitido'] as String?) ?? '',
        numeroRegistro: (mapa['numero_registro'] as String?) ?? '',
        proveedor: (mapa['proveedor'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
