// Consultas sobre los catálogos generados (content/huerta/*.csv). Lógica
// pura, sin Flutter. Los registros guardan el id del catálogo o, si la
// persona escribió algo que no está, el texto libre: por eso cada consulta
// de nombre devuelve el propio texto cuando no lo encuentra.

import '../datos/catalogos_generados/catalogo_cultivos.dart';
import '../datos/catalogos_generados/catalogo_insumos.dart';
import '../datos/catalogos_generados/catalogo_plagas.dart';
import '../datos/catalogos_generados/catalogo_rotacion.dart';
import '../modelos/cultivo.dart';
import 'prevision_cosecha.dart';
import 'rotacion.dart';

/// Una opción para elegir en un campo: id del catálogo y nombre visible.
typedef OpcionCatalogo = ({String id, String nombre});

final Map<String, CultivoCatalogo> _cultivos = {
  for (final cultivo in catalogoCultivos) cultivo.id: cultivo
};
final Map<String, FamiliaRotacionCatalogo> _familias = {
  for (final familia in catalogoRotacion) familia.familiaId: familia
};
final Map<String, CategoriaInsumoCatalogo> _categoriasInsumo = {
  for (final categoria in catalogoCategoriasInsumo) categoria.id: categoria
};
final Map<String, PlagaCatalogo> _plagas = {
  for (final plaga in catalogoPlagas) plaga.id: plaga
};

CultivoCatalogo? especiePorId(String id) => _cultivos[id];
FamiliaRotacionCatalogo? familiaPorId(String id) =>
    _familias[normalizarFamilia(id)];
CategoriaInsumoCatalogo? categoriaInsumoPorId(String id) =>
    _categoriasInsumo[id];
PlagaCatalogo? plagaPorId(String id) => _plagas[id];

String nombreEspecie(String id) => _cultivos[id]?.nombre ?? id;
String nombreFamilia(String id) =>
    _familias[normalizarFamilia(id)]?.nombre ?? id;
String nombreCategoriaInsumo(String id) => _categoriasInsumo[id]?.nombre ?? id;
String nombrePlaga(String id) => _plagas[id]?.nombre ?? id;

/// «Tomate · Corazón de buey».
String nombreCultivo(Cultivo cultivo) => [
      nombreEspecie(cultivo.especieId),
      if (cultivo.variedad.trim().isNotEmpty) cultivo.variedad.trim(),
    ].join(' · ');

List<OpcionCatalogo> opcionesEspecies() => [
      for (final cultivo in catalogoCultivos)
        (id: cultivo.id, nombre: cultivo.nombre),
    ];

List<OpcionCatalogo> opcionesFamilias() => [
      for (final familia in catalogoRotacion)
        (id: familia.familiaId, nombre: familia.nombre),
    ];

/// Categorías de insumo del catálogo de un tipo (`fertilizante` o
/// `fitosanitario`); todas si [tipo] es null.
List<OpcionCatalogo> opcionesCategoriasInsumo({String? tipo}) => [
      for (final categoria in catalogoCategoriasInsumo)
        if (tipo == null || categoria.tipo == tipo)
          (id: categoria.id, nombre: categoria.nombre),
    ];

/// Plagas, enfermedades y carencias; primero las de la familia dada.
List<OpcionCatalogo> opcionesPlagas({String? familiaId}) {
  final familia = familiaId == null ? null : normalizarFamilia(familiaId);
  final todas = [...catalogoPlagas];
  int prioridad(PlagaCatalogo plaga) =>
      familia != null && plaga.familias.contains(familia) ? 0 : 1;
  todas.sort((a, b) {
    final porPrioridad = prioridad(a).compareTo(prioridad(b));
    return porPrioridad != 0 ? porPrioridad : a.nombre.compareTo(b.nombre);
  });
  return [for (final plaga in todas) (id: plaga.id, nombre: plaga.nombre)];
}

/// Familia botánica de una especie del catálogo, o vacío si no está.
String familiaDeEspecie(String especieId) =>
    _cultivos[especieId]?.familiaId ?? '';

/// Años mínimos de retorno por familia (solo las que tienen dato).
Map<String, int> aniosMinimosPorFamilia() => {
      for (final familia in catalogoRotacion)
        if (familia.aniosMinimos != null)
          normalizarFamilia(familia.familiaId): familia.aniosMinimos!,
    };

/// Ciclo para prever la cosecha, o null si al catálogo le falta el dato.
CicloCultivo? cicloDeEspecie(String especieId) {
  final cultivo = _cultivos[especieId];
  if (cultivo?.cicloDias == null) return null;
  return (
    diasHastaCosecha: cultivo!.cicloDias!,
    semanasCosecha: cultivo.semanasCosecha ?? 1,
  );
}

/// Si la especie se reparte por piezas (lechuga, col, manojo).
bool seRepartePorUnidades(String especieId) =>
    _cultivos[especieId]?.porUnidades ?? false;

/// Convierte lo escrito en un campo en el id del catálogo si coincide con el
/// nombre (sin distinguir mayúsculas) o con el id; si no, el texto tal cual.
String idDesdeTexto(String texto, List<OpcionCatalogo> opciones) {
  final limpio = texto.trim();
  for (final opcion in opciones) {
    if (opcion.nombre.toLowerCase() == limpio.toLowerCase() ||
        opcion.id == limpio) {
      return opcion.id;
    }
  }
  return limpio;
}
