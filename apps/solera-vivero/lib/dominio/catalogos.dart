// Consultas sobre los catálogos generados (content/vivero/*.csv). Lógica
// pura, sin Flutter. Los registros guardan el id del catálogo o, si la
// persona escribió algo que no está, el texto libre: por eso cada consulta
// de nombre devuelve el propio texto cuando no lo encuentra.

import '../datos/catalogos_generados/catalogo_especies.dart';
import '../datos/catalogos_generados/catalogo_fitosanitarios.dart';
import '../datos/catalogos_generados/catalogo_plagas.dart';
import '../datos/catalogos_generados/catalogo_plagas_reguladas.dart';

/// Una opción para elegir en un campo: id del catálogo y nombre visible.
typedef OpcionCatalogo = ({String id, String nombre});

final Map<String, EspecieCatalogo> _especies = {
  for (final especie in catalogoEspecies) especie.id: especie
};
final Map<String, PlagaCatalogo> _plagas = {
  for (final plaga in catalogoPlagas) plaga.id: plaga
};
final Map<String, PlagaReguladaCatalogo> _reguladas = {
  for (final plaga in catalogoPlagasReguladas) plaga.id: plaga
};
final Map<String, SustanciaActivaCatalogo> _sustancias = {
  for (final sustancia in catalogoSustanciasActivas) sustancia.id: sustancia
};

EspecieCatalogo? especiePorId(String id) => _especies[id];
PlagaCatalogo? plagaPorId(String id) => _plagas[id];
PlagaReguladaCatalogo? plagaReguladaPorId(String id) => _reguladas[id];
SustanciaActivaCatalogo? sustanciaPorId(String id) => _sustancias[id];

String nombreEspecie(String id) => _especies[id]?.nombre ?? id;

/// Nombre de una plaga, común o regulada (los ids no se pisan).
String nombrePlaga(String id) =>
    _plagas[id]?.nombre ??
    (_reguladas[id] == null
        ? id
        : '${_reguladas[id]!.nombre} (${_reguladas[id]!.nombreCientifico})');
String nombreSustancia(String id) => _sustancias[id]?.nombre ?? id;

List<OpcionCatalogo> opcionesEspecies() => [
      for (final especie in catalogoEspecies)
        (id: especie.id, nombre: especie.nombre),
    ];

/// Plagas comunes con algún uso registrado en el grupo de cultivo de la
/// especie; si la especie no tiene grupo, todas.
List<OpcionCatalogo> opcionesPlagas(String? especieId) {
  final grupo =
      especieId == null ? '' : _especies[especieId]?.grupoFitosanitario ?? '';
  final conUso = grupo.isEmpty
      ? null
      : {
          for (final sustancia in catalogoSustanciasActivas)
            for (final uso in sustancia.usos)
              if (uso.startsWith('$grupo:')) uso.substring(grupo.length + 1)
        };
  return [
    for (final plaga in catalogoPlagas)
      if (conUso == null || conUso.contains(plaga.id))
        (id: plaga.id, nombre: plaga.nombre),
  ];
}

/// Si la plaga regulada afecta a la planta, por el nombre botánico: el
/// género (o la especie) de la lista coincide con el principio del nombre.
bool plagaReguladaAfecta(PlagaReguladaCatalogo plaga, String nombreBotanico) {
  final nombre = nombreBotanico.trim().toLowerCase();
  if (nombre.isEmpty) return false;
  return plaga.generos.any((genero) {
    final huesped = genero.trim().toLowerCase();
    return nombre == huesped || nombre.startsWith('$huesped ');
  });
}

/// Plagas reguladas: primero las que afectan a la planta (por nombre
/// botánico o por la lista de la especie); si no hay planta, todas.
List<OpcionCatalogo> opcionesPlagasReguladas(
    {String? especieId, String nombreBotanico = ''}) {
  final deEspecie = especieId == null
      ? const <String>[]
      : _especies[especieId]?.plagasReguladas ?? const <String>[];
  bool afecta(PlagaReguladaCatalogo plaga) =>
      deEspecie.contains(plaga.id) ||
      plagaReguladaAfecta(plaga, nombreBotanico);
  final ordenadas = [...catalogoPlagasReguladas]
    ..sort((a, b) => (afecta(a) ? 0 : 1).compareTo(afecta(b) ? 0 : 1));
  return [
    for (final plaga in ordenadas)
      (
        id: plaga.id,
        nombre: '${plaga.nombre} (${plaga.nombreCientifico})',
      ),
  ];
}

/// Sustancias con algún uso registrado en el grupo de cultivo de la
/// especie; si se da una plaga, primero las que tienen uso para ella. Sin
/// grupo, todas.
List<OpcionCatalogo> opcionesSustancias(String? especieId, {String? plagaId}) {
  final grupo =
      especieId == null ? '' : _especies[especieId]?.grupoFitosanitario ?? '';
  final candidatas = catalogoSustanciasActivas
      .where((sustancia) =>
          grupo.isEmpty ||
          sustancia.usos.any((uso) => uso.startsWith('$grupo:')))
      .toList();
  int prioridad(SustanciaActivaCatalogo sustancia) => plagaId != null &&
          sustancia.usos.any((uso) =>
              uso.endsWith(':$plagaId') &&
              (grupo.isEmpty || uso.startsWith('$grupo:')))
      ? 0
      : 1;
  candidatas.sort((a, b) {
    final porPrioridad = prioridad(a).compareTo(prioridad(b));
    return porPrioridad != 0 ? porPrioridad : a.nombre.compareTo(b.nombre);
  });
  return [
    for (final sustancia in candidatas)
      (id: sustancia.id, nombre: sustancia.nombre),
  ];
}

/// Si el uso (grupo de la especie : plaga) está en el registro. Nulo si no
/// se puede saber (especie sin grupo, sustancia o plaga fuera del catálogo).
bool? usoAutorizado(
    {required String especieId,
    required String sustanciaId,
    required String plagaId}) {
  final grupo = _especies[especieId]?.grupoFitosanitario ?? '';
  final sustancia = _sustancias[sustanciaId];
  if (grupo.isEmpty || sustancia == null || !_plagas.containsKey(plagaId)) {
    return null;
  }
  return sustancia.usos.contains('$grupo:$plagaId');
}

/// Convierte lo escrito en un campo en el id del catálogo si coincide con
/// un nombre (sin distinguir mayúsculas); si no, deja el texto libre.
String idDesdeTexto(String texto, List<OpcionCatalogo> opciones) {
  final limpio = texto.trim();
  final normalizado = limpio.toLowerCase();
  for (final opcion in opciones) {
    if (opcion.nombre.toLowerCase() == normalizado || opcion.id == limpio) {
      return opcion.id;
    }
  }
  return limpio;
}
