import '../datos/catalogos_generados/catalogo_dop_sidra_txakoli.dart';
import '../datos/catalogos_generados/catalogo_fitosanitarios_manzano.dart';
import '../datos/catalogos_generados/catalogo_plagas_manzano.dart';
import '../datos/catalogos_generados/catalogo_variedades_manzana.dart';
import '../datos/catalogos_generados/catalogo_variedades_uva.dart';

/// Denominaciones (grupos del catálogo de productos) en el orden en que se
/// ofrecen.
const List<String> denominacionesOrigen = [
  'euskal_sagardoa',
  'sidra_asturias',
  'bizkaiko_txakolina',
  'getariako_txakolina',
  'arabako_txakolina',
];

final Map<String, VariedadManzana> _variedadesManzana = {
  for (final variedad in catalogoVariedadesManzana) variedad.id: variedad,
};
final Map<String, VariedadUva> _variedadesUva = {
  for (final variedad in catalogoVariedadesUva) variedad.id: variedad,
};
final Map<String, PlagaManzano> _plagas = {
  for (final plaga in catalogoPlagasManzano) plaga.id: plaga,
};
final Map<String, SustanciaActivaManzano> _sustancias = {
  for (final sustancia in catalogoFitosanitariosManzano)
    sustancia.id: sustancia,
};
final Map<String, ProductoDop> _productosDop = {
  for (final producto in catalogoProductosDop) producto.id: producto,
};

PlagaManzano? plagaPorId(String id) => _plagas[id];
SustanciaActivaManzano? sustanciaPorId(String id) => _sustancias[id];
ProductoDop? productoDopPorId(String id) => _productosDop[id];

/// Nombre visible de una variedad de manzana o de uva; el id si no está.
String nombreVariedad(String id) =>
    _variedadesManzana[id]?.nombre ?? _variedadesUva[id]?.nombre ?? id;

String nombrePlaga(String id) => _plagas[id]?.nombre ?? id;

String nombreSustancia(String id) => _sustancias[id]?.nombre ?? id;

/// Variedades que se ofrecen para un cultivo, las de [dop] primero.
List<({String id, String nombre})> variedadesParaCultivo(String cultivo,
    {String dop = ''}) {
  if (cultivo == 'vid') {
    return [
      for (final uva in catalogoVariedadesUva) (id: uva.id, nombre: uva.nombre),
    ];
  }
  final ordenadas = [...catalogoVariedadesManzana]..sort((a, b) {
      final primeroA = a.dop == dop ? 0 : 1;
      final primeroB = b.dop == dop ? 0 : 1;
      return primeroA != primeroB
          ? primeroA - primeroB
          : a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
    });
  return [
    for (final variedad in ordenadas)
      (id: variedad.id, nombre: variedad.nombre),
  ];
}

/// Productos (tipos de sidra o txakoli) de una denominación.
List<ProductoDop> productosDeDenominacion(String dop) =>
    catalogoProductosDop.where((producto) => producto.dop == dop).toList();

/// Sustancias con uso autorizado contra [plagaId] (todas si está vacío),
/// por nombre. Solo sustancias activas: nunca un producto por marca.
List<SustanciaActivaManzano> sustanciasParaPlaga(String plagaId) {
  final lista = plagaId.isEmpty
      ? [...catalogoFitosanitariosManzano]
      : catalogoFitosanitariosManzano
          .where((sustancia) => sustancia.plagasObjetivo.contains(plagaId))
          .toList();
  return lista..sort((a, b) => a.nombre.compareTo(b.nombre));
}

/// Variedades de [variedades] que no están en la lista del pliego de [dop]
/// (para avisar: la app no decide si se pueden usar).
Set<String> variedadesFueraDelPliego(Set<String> variedades, String dop) {
  if (dop.isEmpty) return const {};
  if (dop.endsWith('_txakolina')) {
    final columna = dop.split('_').first; // bizkaiko, arabako, getariako
    return variedades.where((id) {
      final uva = _variedadesUva[id];
      if (uva == null) return true;
      final estado = switch (columna) {
        'bizkaiko' => uva.bizkaiko,
        'arabako' => uva.arabako,
        _ => uva.getariako,
      };
      return estado.isEmpty;
    }).toSet();
  }
  return variedades.where((id) => _variedadesManzana[id]?.dop != dop).toSet();
}
