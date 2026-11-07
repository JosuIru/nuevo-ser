// Consultas sobre los catálogos generados (content/monte/*.csv). Lógica pura,
// sin Flutter. Los registros guardan el id del catálogo o, si la persona
// escribió algo que no está, el texto libre: por eso cada consulta de nombre
// devuelve el propio texto cuando no lo encuentra.

import '../datos/catalogos_generados/catalogo_especies.dart';
import '../datos/catalogos_generados/catalogo_plagas.dart';
import '../datos/catalogos_generados/catalogo_unidades.dart';

/// Una opción para elegir en un campo: id del catálogo y nombre visible.
typedef OpcionCatalogo = ({String id, String nombre});

final Map<String, EspecieForestal> _especies = {
  for (final especie in catalogoEspecies) especie.id: especie
};
final Map<String, PlagaForestal> _plagas = {
  for (final plaga in catalogoPlagas) plaga.id: plaga
};
final Map<String, UnidadVolumen> _unidades = {
  for (final unidad in catalogoUnidades) unidad.id: unidad
};

EspecieForestal? especiePorId(String id) => _especies[id];
PlagaForestal? plagaPorId(String id) => _plagas[id];

String nombreEspecie(String id) => _especies[id]?.nombre ?? id;
String nombreCientificoEspecie(String id) =>
    _especies[id]?.nombreCientifico ?? '';
String nombrePlaga(String id) => _plagas[id]?.nombre ?? id;

/// Especies ordenadas por nombre.
List<OpcionCatalogo> opcionesEspecies() => [
      for (final especie in [
        ...catalogoEspecies
      ]..sort((a, b) => a.nombre.compareTo(b.nombre)))
        (id: especie.id, nombre: especie.nombre)
    ];

/// Género de una especie del catálogo: lo que va antes del primer «_».
String generoDe(String especieId) => especieId.split('_').first;

/// ¿Afecta [plaga] a [especieId]? Por especie nombrada o por género.
bool plagaAfectaA(PlagaForestal plaga, String especieId) =>
    plaga.especies.contains(especieId) ||
    plaga.generos.contains(generoDe(especieId));

/// Plagas del catálogo que afectan a alguna de [especiesIds] (sin repetir),
/// las prioritarias de la UE primero.
List<PlagaForestal> plagasDeEspecies(Iterable<String> especiesIds) {
  final ids = especiesIds.toSet();
  final encontradas = [
    for (final plaga in catalogoPlagas)
      if (ids.any((especie) => plagaAfectaA(plaga, especie))) plaga
  ]..sort((a, b) {
      final porAviso = (a.aviso == 'prioritaria_ue' ? 0 : 1)
          .compareTo(b.aviso == 'prioritaria_ue' ? 0 : 1);
      return porAviso != 0 ? porAviso : a.nombre.compareTo(b.nombre);
    });
  return encontradas;
}

/// Metros cúbicos sólidos por estéreo (orientativo, del catálogo de
/// unidades). 0,65 si el catálogo no lo trae.
double get m3PorEstereo => _unidades['estereos']?.m3PorUnidad ?? 0.65;

/// Conversión orientativa a m³; null si la unidad no es de volumen.
double? aMetrosCubicos(double cantidad, String unidad) {
  final factor = _unidades[unidad]?.m3PorUnidad;
  return factor == null ? null : cantidad * factor;
}

UnidadVolumen? unidadPorId(String id) => _unidades[id];
