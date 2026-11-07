// Consultas sobre los catálogos generados (content/aromaticas/*.csv). Lógica
// pura, sin Flutter. Los registros guardan el id del catálogo o, si la
// persona escribió algo que no está, el texto libre: por eso cada consulta
// de nombre devuelve el propio texto cuando no lo encuentra.

import '../datos/catalogos_generados/catalogo_especies.dart';
import '../datos/catalogos_generados/catalogo_plagas.dart';
import '../datos/catalogos_generados/catalogo_rendimientos.dart';

/// Una opción para elegir en un campo: id del catálogo y nombre visible.
typedef OpcionCatalogo = ({String id, String nombre});

final Map<String, EspecieCatalogo> _especies = {
  for (final especie in catalogoEspecies) especie.id: especie
};
final Map<String, PlagaCatalogo> _plagas = {
  for (final plaga in catalogoPlagas) plaga.id: plaga
};

EspecieCatalogo? especiePorId(String id) => _especies[id];
PlagaCatalogo? plagaPorId(String id) => _plagas[id];

String nombreEspecie(String id) => _especies[id]?.nombre ?? id;
String nombreCientificoEspecie(String id) =>
    _especies[id]?.nombreCientifico ?? '';
String nombrePlaga(String id) => _plagas[id]?.nombre ?? id;

/// Todas las especies; con [soloSilvestres], las que se recolectan en el
/// monte (origen «silvestre» o «ambos»). Las protegidas van al final.
List<OpcionCatalogo> opcionesEspecies({bool soloSilvestres = false}) {
  final elegidas = [
    for (final especie in catalogoEspecies)
      if (!soloSilvestres || especie.origen != 'cultivo') especie,
  ]..sort((a, b) {
      final porProteccion = (a.proteccion.isEmpty ? 0 : 1)
          .compareTo(b.proteccion.isEmpty ? 0 : 1);
      return porProteccion != 0 ? porProteccion : a.nombre.compareTo(b.nombre);
    });
  return [
    for (final especie in elegidas) (id: especie.id, nombre: especie.nombre)
  ];
}

/// Plagas del catálogo que el boletín cita para la especie.
List<OpcionCatalogo> opcionesPlagas(String especieId) => [
      for (final plaga in catalogoPlagas)
        if (plaga.especies.contains(especieId))
          (id: plaga.id, nombre: plaga.nombre),
    ];

/// La especie tiene alguna figura de protección en el catálogo.
bool especieConProteccion(String especieId) =>
    (_especies[especieId]?.proteccion ?? '').isNotEmpty;

/// Especies parecidas (ids del catálogo o descripciones) para el aviso de
/// confusión al recolectar.
List<String> confundiblesDe(String especieId) =>
    _especies[especieId]?.confundibles ?? const [];

/// Texto de una confundible: el nombre si es un id del catálogo, si no tal cual.
String nombreConfundible(String confundible) =>
    _especies[confundible]?.nombre ?? confundible;

/// Rendimiento orientativo de [producto] (`aceite_esencial` o
/// `planta_seca`) para la especie y el estado de la planta; null si el
/// catálogo no tiene fuente para ese caso.
RendimientoOrientativo? rendimientoOrientativo(String especieId,
    {required String producto, String estadoPlanta = 'fresca'}) {
  for (final rendimiento in catalogoRendimientos) {
    if (rendimiento.especieId == especieId &&
        rendimiento.producto == producto &&
        rendimiento.estadoPlanta == estadoPlanta) {
      return rendimiento;
    }
  }
  return null;
}

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

/// El mes cae entre [inicio] y [fin], admitiendo intervalos que cruzan el año.
bool mesEnIntervalo(int mes, int inicio, int fin) =>
    inicio <= fin ? mes >= inicio && mes <= fin : mes >= inicio || mes <= fin;

/// Especies de [ids] cuya época orientativa de cosecha incluye [mes].
List<EspecieCatalogo> especiesEnEpoca(Iterable<String> ids, int mes) => [
      for (final id in ids.toSet())
        if (_especies[id] case final especie?
            when especie.mesInicio != null &&
                especie.mesFin != null &&
                mesEnIntervalo(mes, especie.mesInicio!, especie.mesFin!))
          especie,
    ];
