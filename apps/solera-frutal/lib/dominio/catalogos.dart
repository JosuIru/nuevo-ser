// Consultas sobre los catálogos generados (content/frutal/*.csv). Lógica
// pura, sin Flutter. Los registros guardan el id del catálogo o, si la
// persona escribió algo que no está, el texto libre: por eso cada consulta
// de nombre devuelve el propio texto cuando no lo encuentra.

import '../datos/catalogos_generados/catalogo_especies.dart';
import '../datos/catalogos_generados/catalogo_fenologia.dart';
import '../datos/catalogos_generados/catalogo_fitosanitarios.dart';
import '../datos/catalogos_generados/catalogo_plagas.dart';
import '../datos/catalogos_generados/catalogo_variedades.dart';
import 'polinizacion.dart';

/// Una opción para elegir en un campo: id del catálogo y nombre visible.
typedef OpcionCatalogo = ({String id, String nombre});

final Map<String, PlagaCatalogo> _plagas = {
  for (final plaga in catalogoPlagas) plaga.id: plaga
};
final Map<String, SustanciaActivaCatalogo> _sustancias = {
  for (final sustancia in catalogoSustanciasActivas) sustancia.id: sustancia
};
final Map<String, VariedadCatalogo> _variedades = {
  for (final variedad in catalogoVariedades) variedad.id: variedad
};

PlagaCatalogo? plagaPorId(String id) => _plagas[id];
SustanciaActivaCatalogo? sustanciaPorId(String id) => _sustancias[id];
VariedadCatalogo? variedadPorId(String id) => _variedades[id];
EspecieCatalogo? especiePorId(String id) {
  for (final especie in catalogoEspecies) {
    if (especie.id == id) return especie;
  }
  return null;
}

String nombrePlaga(String id) => _plagas[id]?.nombre ?? id;
String nombreSustancia(String id) => _sustancias[id]?.nombre ?? id;
String nombreVariedad(String id) => _variedades[id]?.nombre ?? id;

List<OpcionCatalogo> opcionesPlagas(String especieId) => [
      for (final plaga in catalogoPlagas)
        if (plaga.especies.contains(especieId))
          (id: plaga.id, nombre: plaga.nombre),
    ];

List<OpcionCatalogo> opcionesVariedades(String especieId) => [
      for (final variedad in catalogoVariedades)
        if (variedad.especieId == especieId)
          (id: variedad.id, nombre: variedad.nombre),
    ];

/// Sustancias con algún uso registrado en la especie; si se da una plaga,
/// primero las que tienen uso para esa plaga.
List<OpcionCatalogo> opcionesSustancias(String especieId, {String? plagaId}) {
  final deEspecie = catalogoSustanciasActivas
      .where((sustancia) =>
          sustancia.usos.any((uso) => uso.startsWith('$especieId:')))
      .toList();
  int prioridad(SustanciaActivaCatalogo sustancia) =>
      plagaId != null && sustancia.usos.contains('$especieId:$plagaId') ? 0 : 1;
  deEspecie.sort((a, b) {
    final porPrioridad = prioridad(a).compareTo(prioridad(b));
    return porPrioridad != 0 ? porPrioridad : a.nombre.compareTo(b.nombre);
  });
  return [
    for (final sustancia in deEspecie)
      (id: sustancia.id, nombre: sustancia.nombre)
  ];
}

/// Si el catálogo recoge un uso de esa sustancia para esa especie y plaga.
/// Null si la sustancia o la plaga no son del catálogo (no se puede decir).
bool? usoRegistrado(String sustanciaId, String especieId, String plagaId) {
  final sustancia = _sustancias[sustanciaId];
  if (sustancia == null || !_plagas.containsKey(plagaId)) return null;
  return sustancia.usos.contains('$especieId:$plagaId');
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

/// Datos de polinización de todas las variedades del catálogo.
Map<String, DatosPolinizacionVariedad> datosPolinizacionCatalogo() => {
      for (final variedad in catalogoVariedades)
        variedad.id: DatosPolinizacionVariedad(
          id: variedad.id,
          especieId: variedad.especieId,
          autocompatible: variedad.autocompatible,
          grupoIncompatibilidad: variedad.grupoIncompatibilidad,
          floracion: variedad.floracion,
        ),
    };

/// El mes cae entre [inicio] y [fin], admitiendo intervalos que cruzan el
/// año (noviembre → enero).
bool mesEnIntervalo(int mes, int inicio, int fin) =>
    inicio <= fin ? mes >= inicio && mes <= fin : mes >= inicio || mes <= fin;

/// Estados fenológicos orientativos de una especie en un mes.
List<EstadoFenologicoCatalogo> estadosEnMes(String especieId, int mes) => [
      for (final estado in catalogoFenologia)
        if (estado.especieId == especieId &&
            estado.mesInicio != null &&
            estado.mesFin != null &&
            mesEnIntervalo(mes, estado.mesInicio!, estado.mesFin!))
          estado,
    ];
