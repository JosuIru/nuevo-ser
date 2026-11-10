// Guía del huerto: fichas por cultivo, fauna auxiliar, plantas que ayudan y
// técnicas (content/huerta/guia_*.csv). Lógica pura, sin Flutter: búsqueda,
// meses de siembra, enlaces entre fichas y sugerencias del mes para Hoy.

import '../datos/catalogos_generados/catalogo_cultivos.dart';
import '../datos/catalogos_generados/catalogo_guia_cultivos.dart';
import '../datos/catalogos_generados/catalogo_guia_fauna.dart';
import '../datos/catalogos_generados/catalogo_guia_plantas.dart';
import '../datos/catalogos_generados/catalogo_guia_tecnicas.dart';

/// Secciones de la guía, en el orden de las pestañas.
enum SeccionGuia { cultivos, fauna, plantas, tecnicas }

/// Forma de sembrar o plantar que da el calendario de una ficha.
enum FormaSiembra { semillero, directa, trasplante }

final Map<String, FichaGuiaCultivo> _fichasCultivo = {
  for (final ficha in catalogoGuiaCultivos) ficha.id: ficha
};
final Map<String, FichaGuiaFauna> _fichasFauna = {
  for (final ficha in catalogoGuiaFauna) ficha.id: ficha
};
final Map<String, FichaGuiaPlanta> _fichasPlanta = {
  for (final ficha in catalogoGuiaPlantas) ficha.id: ficha
};
final Map<String, CultivoCatalogo> _cultivosCatalogo = {
  for (final cultivo in catalogoCultivos) cultivo.id: cultivo
};

FichaGuiaCultivo? fichaGuiaCultivo(String cultivoId) =>
    _fichasCultivo[cultivoId];
FichaGuiaFauna? fichaGuiaFauna(String id) => _fichasFauna[id];
FichaGuiaPlanta? fichaGuiaPlanta(String id) => _fichasPlanta[id];

/// Nombre visible del cultivo de una ficha (el del catálogo de cultivos).
String nombreCultivoGuia(String cultivoId) =>
    _cultivosCatalogo[cultivoId]?.nombre ?? cultivoId;

/// Nombre de una planta en una lista de asociaciones: el del catálogo si es
/// un id de cultivo; si no, el texto tal cual (p. ej. «Albahaca»).
String nombreAsociacion(String valor) =>
    _cultivosCatalogo[valor]?.nombre ?? valor;

/// La asociación apunta a un cultivo con ficha en la guía.
bool asociacionConFicha(String valor) => _fichasCultivo.containsKey(valor);

/// Meses (1-12) de una lista de rangos «a-b» o «a»; un rango puede cruzar
/// el año («8-1» = agosto a enero). Los valores mal formados se ignoran.
Set<int> mesesDeRangos(List<String> rangos) {
  final meses = <int>{};
  for (final rango in rangos) {
    final partes = rango.split('-').map((parte) => int.tryParse(parte.trim()));
    final limites = partes.toList();
    if (limites.isEmpty || limites.any((mes) => mes == null)) continue;
    final inicio = limites.first!;
    final fin = limites.last!;
    if (inicio < 1 || inicio > 12 || fin < 1 || fin > 12) continue;
    var mes = inicio;
    while (true) {
      meses.add(mes);
      if (mes == fin) break;
      mes = mes == 12 ? 1 : mes + 1;
    }
  }
  return meses;
}

/// Meses de cada forma de siembra de la ficha (solo las que tienen meses).
Map<FormaSiembra, Set<int>> calendarioDe(FichaGuiaCultivo ficha) {
  final calendario = {
    FormaSiembra.semillero: mesesDeRangos(ficha.mesesSemillero),
    FormaSiembra.directa: mesesDeRangos(ficha.mesesDirecta),
    FormaSiembra.trasplante: mesesDeRangos(ficha.mesesTrasplante),
  };
  calendario.removeWhere((_, meses) => meses.isEmpty);
  return calendario;
}

/// Una sugerencia para la tarjeta «Esta semana en el huerto».
typedef SugerenciaMes = ({String cultivoId, FormaSiembra forma});

/// Hasta [maximo] cultivos que, según las fichas, se siembran o plantan en
/// [mes]. Primero los que la persona ya tiene dados de alta
/// ([especiesPropias]); la elección rota con el día del año para que la
/// tarjeta no diga siempre lo mismo.
List<SugerenciaMes> sugerenciasDelMes(
  int mes, {
  Set<String> especiesPropias = const {},
  int maximo = 3,
  int giro = 0,
}) {
  final candidatas = <SugerenciaMes>[];
  for (final ficha in catalogoGuiaCultivos) {
    final calendario = calendarioDe(ficha);
    // Preferencia: siembra directa, luego semillero, luego trasplante.
    for (final forma in const [
      FormaSiembra.directa,
      FormaSiembra.semillero,
      FormaSiembra.trasplante,
    ]) {
      if (calendario[forma]?.contains(mes) ?? false) {
        candidatas.add((cultivoId: ficha.id, forma: forma));
        break;
      }
    }
  }
  if (candidatas.isEmpty) return const [];
  final desplazamiento = giro % candidatas.length;
  final rotadas = [
    ...candidatas.sublist(desplazamiento),
    ...candidatas.sublist(0, desplazamiento),
  ];
  final propias = [
    for (final candidata in rotadas)
      if (especiesPropias.contains(candidata.cultivoId)) candidata
  ];
  final resto = [
    for (final candidata in rotadas)
      if (!especiesPropias.contains(candidata.cultivoId)) candidata
  ];
  return [...propias, ...resto].take(maximo).toList();
}

/// Fauna auxiliar que, según la guía, come o parasita la plaga [plagaId].
List<FichaGuiaFauna> auxiliaresDePlaga(String plagaId) => [
      for (final ficha in catalogoGuiaFauna)
        if (ficha.plagas.contains(plagaId)) ficha
    ];

/// Plantas de la guía que alimentan o acogen a la fauna [faunaId].
List<FichaGuiaPlanta> plantasParaFauna(String faunaId) => [
      for (final ficha in catalogoGuiaPlantas)
        if (ficha.fauna.contains(faunaId)) ficha
    ];

/// Cultivos con ficha cuya lista de plagas incluye [plagaId].
List<String> cultivosConPlaga(String plagaId) => [
      for (final ficha in catalogoGuiaCultivos)
        if (ficha.plagas.contains(plagaId)) ficha.id
    ];

String _sinAcentos(String texto) {
  const conAcento = 'áéíóúüàèìòùñç';
  const sinAcento = 'aeiouuaeiounc';
  final salida = StringBuffer();
  for (final letra in texto.toLowerCase().split('')) {
    final posicion = conAcento.indexOf(letra);
    salida.write(posicion < 0 ? letra : sinAcento[posicion]);
  }
  return salida.toString();
}

bool _coincide(List<String> textos, String consulta) {
  final buscada = _sinAcentos(consulta.trim());
  if (buscada.isEmpty) return true;
  return _sinAcentos(textos.join(' ')).contains(buscada);
}

/// Todo el texto visible de cada tipo de ficha (búsqueda y test de límites).
List<String> textosFichaCultivo(FichaGuiaCultivo ficha) => [
      nombreCultivoGuia(ficha.id),
      _cultivosCatalogo[ficha.id]?.nombreCientifico ?? '',
      ficha.siembra,
      ficha.riego,
      ficha.cosecha,
      ...ficha.asociacionesFavorables.map(nombreAsociacion),
      ...ficha.asociacionesDesfavorables.map(nombreAsociacion),
      ficha.notaAsociaciones,
      ficha.curiosidad,
    ];

List<String> textosFichaFauna(FichaGuiaFauna ficha) => [
      ficha.nombre,
      ficha.nombreCientifico,
      ficha.queHace,
      ficha.comoReconocerla,
      ficha.comoAtraerla,
    ];

List<String> textosFichaPlanta(FichaGuiaPlanta ficha) => [
      ficha.nombre,
      ficha.nombreCientifico,
      ficha.queAporta,
      ficha.cuandoSembrar,
      ficha.cuidado,
    ];

List<String> textosFichaTecnica(FichaGuiaTecnica ficha) => [
      ficha.titulo,
      ficha.resumen,
      ...ficha.pasos,
      ficha.truco,
    ];

/// Fichas de cultivo que coinciden con [consulta] (sin distinguir mayúsculas
/// ni acentos) en cualquier texto de la ficha. Primero las que coinciden por
/// nombre; dentro de cada grupo, por orden alfabético.
List<FichaGuiaCultivo> buscarCultivos(String consulta) {
  int prioridad(FichaGuiaCultivo ficha) =>
      _coincide([nombreCultivoGuia(ficha.id)], consulta) ? 0 : 1;
  return [
    for (final ficha in catalogoGuiaCultivos)
      if (_coincide(textosFichaCultivo(ficha), consulta)) ficha
  ]..sort((a, b) {
      final porPrioridad = prioridad(a).compareTo(prioridad(b));
      return porPrioridad != 0
          ? porPrioridad
          : nombreCultivoGuia(a.id).compareTo(nombreCultivoGuia(b.id));
    });
}

List<FichaGuiaFauna> buscarFauna(String consulta) => [
      for (final ficha in catalogoGuiaFauna)
        if (_coincide(textosFichaFauna(ficha), consulta)) ficha
    ];

List<FichaGuiaPlanta> buscarPlantas(String consulta) => [
      for (final ficha in catalogoGuiaPlantas)
        if (_coincide(textosFichaPlanta(ficha), consulta)) ficha
    ];

List<FichaGuiaTecnica> buscarTecnicas(String consulta) => [
      for (final ficha in catalogoGuiaTecnicas)
        if (_coincide(textosFichaTecnica(ficha), consulta)) ficha
    ];

/// Citas de la columna `fuente`, separadas por «;».
List<String> citasDe(String fuente) => [
      for (final cita in fuente.split(';'))
        if (cita.trim().isNotEmpty) cita.trim()
    ];
