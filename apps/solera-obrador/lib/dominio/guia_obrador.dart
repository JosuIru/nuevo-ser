// Guía del obrador: recetas base en porcentaje panadero y fichas de técnica
// (fermentación, tiempos, cocción, harinas, trucos). Lógica pura, sin
// Flutter: búsqueda, paso de % a gramos, temperatura del agua y comprobación
// de que el nombre de una receta base no promete una denominación del
// RD 308/2019 que no cumple.
//
// HARD LIMIT: contenido orientativo, revisado con IA (no por una persona).
// Sin promesas de salud ni nutricionales; los alérgenos solo los calcula la
// app a partir de los ingredientes.

import '../datos/catalogos_generados/catalogo_guia_fichas.dart';
import '../datos/catalogos_generados/catalogo_guia_recetas.dart';
import '../datos/catalogos_generados/catalogo_guia_recetas_ingredientes.dart';
import '../datos/catalogos_generados/catalogo_ingredientes_base.dart';
import '../modelos/ingrediente.dart';
import '../modelos/receta.dart';
import 'comprobacion_denominacion.dart';
import 'composicion_receta.dart';

/// Secciones de la guía, en el orden de la pantalla. `recetas` son las
/// recetas base; el resto, fichas de [catalogoGuiaFichas].
const List<String> seccionesGuiaObrador = [
  'recetas',
  'fermentacion',
  'tiempos',
  'coccion',
  'harinas',
  'trucos',
];

/// Ingredientes que admite el pan común (RD 308/2019 art. 11.1 y 11.2):
/// harinas, agua, levadura o masa madre y sal.
const Set<String> _ingredientesPanComun = {
  'agua',
  'sal',
  'levadura_fresca',
  'masa_madre',
};

/// Denominaciones de pan común del catálogo (arts. 3 y 4).
const Set<String> _denominacionesPanComun = {
  'pan_comun',
  'pan_integral',
  'pan_con_harina_integral',
  'pan_un_cereal',
  'pan_varios_cereales',
};

/// Cereal de cada harina de `ingredientes_base.csv`.
const Map<String, String> _cerealDeHarina = {
  'harina_trigo': 'trigo',
  'harina_trigo_integral': 'trigo',
  'harina_espelta': 'espelta',
  'harina_centeno': 'centeno',
  'harina_maiz': 'maiz',
  'harina_arroz': 'arroz',
};

const Set<String> _harinasIntegrales = {'harina_trigo_integral'};

/// Palabras del nombre con requisitos del RD 308/2019 que la guía no puede
/// garantizar (dependen de cómo se elabora): no deben aparecer en el
/// nombre de una receta base.
const Map<String, String> _mencionesNoComprobables = {
  'larga fermentacion': 'art. 14.4',
  'artesan': 'arts. 10 y 14.3',
  'horno de lena': 'art. 14.6',
  'pan de lena': 'art. 14.6',
  'multicereal': 'art. 6',
  'candeal': 'art. 4.1 (cilindros refinadores)',
  'bregado': 'art. 4.1 (cilindros refinadores)',
};

bool esHarina(String ingredienteBaseId) =>
    _cerealDeHarina.containsKey(ingredienteBaseId);

String normalizarTextoGuia(String texto) {
  const conAcento = 'áéíóúüàèìòùñç';
  const sinAcento = 'aeiouuaeiounc';
  final salida = StringBuffer();
  for (final letra in texto.toLowerCase().split('')) {
    final posicion = conAcento.indexOf(letra);
    salida.write(posicion < 0 ? letra : sinAcento[posicion]);
  }
  return salida.toString();
}

RecetaGuia? recetaGuiaPorId(String id) {
  for (final receta in catalogoGuiaRecetas) {
    if (receta.id == id) return receta;
  }
  return null;
}

FichaGuiaObrador? fichaGuiaPorId(String id) {
  for (final ficha in catalogoGuiaFichas) {
    if (ficha.id == id) return ficha;
  }
  return null;
}

List<IngredienteRecetaGuia> ingredientesDeRecetaGuia(String recetaId) =>
    catalogoGuiaRecetasIngredientes
        .where((linea) => linea.recetaId == recetaId)
        .toList();

IngredienteBase? ingredienteBasePorId(String id) {
  for (final base in catalogoIngredientesBase) {
    if (base.id == id) return base;
  }
  return null;
}

/// Nombre visible de un ingrediente base (o su id si no está).
String nombreIngredienteBase(String id) =>
    ingredienteBasePorId(id)?.nombre ?? id;

/// Suma de los porcentajes de las harinas de la receta (debe ser 100).
double sumaHarinasRecetaGuia(String recetaId) =>
    ingredientesDeRecetaGuia(recetaId)
        .where((linea) => esHarina(linea.ingredienteId))
        .fold(0, (suma, linea) => suma + linea.porcentaje);

/// Suma de todos los porcentajes (peso de masa por cada 100 g de harina).
double sumaPorcentajesRecetaGuia(String recetaId) =>
    ingredientesDeRecetaGuia(recetaId)
        .fold(0, (suma, linea) => suma + linea.porcentaje);

/// Gramos de cada ingrediente base para hacer la receta a partir del peso
/// de harina o del peso total de masa (uno de los dos).
Map<String, double> gramosRecetaGuia(String recetaId,
    {double? gramosHarina, double? gramosMasa}) {
  assert((gramosHarina == null) != (gramosMasa == null),
      'se da el peso de harina o el de masa, no los dos');
  final harinaTotal =
      gramosHarina ?? gramosMasa! / sumaPorcentajesRecetaGuia(recetaId) * 100;
  final gramos = <String, double>{};
  for (final linea in ingredientesDeRecetaGuia(recetaId)) {
    gramos.update(linea.ingredienteId,
        (valor) => valor + harinaTotal * linea.porcentaje / 100,
        ifAbsent: () => harinaTotal * linea.porcentaje / 100);
  }
  return gramos;
}

/// Temperatura del agua (°C) para que la masa salga a [objetivo]: objetivo ×
/// 3 − harina − ambiente − fricción; con prefermento, × 4 y se resta también
/// la del prefermento (King Arthur Baking, «Dough Temperature»).
double temperaturaAguaParaMasa({
  required double objetivo,
  required double harina,
  required double ambiente,
  required double friccion,
  double? prefermento,
}) {
  final factor = prefermento == null ? 3 : 4;
  return objetivo * factor - harina - ambiente - friccion - (prefermento ?? 0);
}

/// Factor de fricción de una amasadora a partir de una masa ya hecha:
/// temperatura de la masa × 3 − harina − ambiente − agua (× 4 y − prefermento
/// con prefermento).
double factorFriccion({
  required double masa,
  required double harina,
  required double ambiente,
  required double agua,
  double? prefermento,
}) {
  final factor = prefermento == null ? 3 : 4;
  return masa * factor - harina - ambiente - agua - (prefermento ?? 0);
}

/// Composición de la receta base con los ingredientes del catálogo, para
/// estimar la sal (sobre 1 kg de harina).
ComposicionReceta composicionRecetaGuia(RecetaGuia receta) {
  final lineas = ingredientesDeRecetaGuia(receta.id);
  final ingredientes = <int, Ingrediente>{};
  final lineasReceta = <LineaReceta>[];
  for (final (indice, linea) in lineas.indexed) {
    final base = ingredienteBasePorId(linea.ingredienteId);
    ingredientes[indice] = Ingrediente(
      id: indice,
      nombre: base?.nombre ?? linea.ingredienteId,
      alergenos: base?.alergenos ?? const {},
      trazas: base?.trazas ?? const {},
      salGramosPor100g: base?.salGramosPor100g ?? 0,
    );
    lineasReceta.add(LineaReceta(
        recetaId: 0, ingredienteId: indice, gramos: linea.porcentaje * 10));
  }
  return ComposicionReceta.calcular(
    recetaId: 0,
    recetas: {
      0: Receta(
          id: 0,
          nombre: receta.nombre,
          denominacion: receta.denominacion,
          mermaCoccionPorcentaje: receta.mermaCoccionPorcentaje)
    },
    lineasPorReceta: {0: lineasReceta},
    ingredientes: ingredientes,
  );
}

/// Lo que impide usar el nombre o la denominación de la receta base según
/// el RD 308/2019. Vacía si no se ve ningún problema (no es una
/// certificación: el pH de la masa madre, los aditivos o el proceso no se
/// pueden comprobar aquí).
List<String> problemasDenominacionRecetaGuia(RecetaGuia receta) {
  final problemas = <String>[];
  final nombre = normalizarTextoGuia(receta.nombre);
  final lineas = ingredientesDeRecetaGuia(receta.id);
  final harinas =
      lineas.where((linea) => esHarina(linea.ingredienteId)).toList();
  final cereales = {
    for (final harina in harinas) _cerealDeHarina[harina.ingredienteId]!
  };
  final todasIntegrales = harinas.isNotEmpty &&
      harinas
          .every((harina) => _harinasIntegrales.contains(harina.ingredienteId));
  double porcentajeDe(String ingredienteId) => lineas
      .where((linea) => linea.ingredienteId == ingredienteId)
      .fold(0, (suma, linea) => suma + linea.porcentaje);

  if (receta.denominacion.isNotEmpty &&
      denominacionPorId(receta.denominacion) == null) {
    problemas.add('denominación desconocida: ${receta.denominacion}');
  }
  if (_denominacionesPanComun.contains(receta.denominacion)) {
    final otros = lineas
        .map((linea) => linea.ingredienteId)
        .where((id) => !esHarina(id) && !_ingredientesPanComun.contains(id));
    if (otros.isNotEmpty) {
      problemas.add('el pan común solo admite harina, agua, levadura o masa '
          'madre y sal (art. 11): lleva ${otros.join(', ')}');
    }
  }
  if (receta.denominacion == 'pan_integral' && !todasIntegrales) {
    problemas.add('«pan integral» exige harina exclusivamente integral '
        '(art. 4.3)');
  }
  if (receta.denominacion == 'pan_un_cereal' &&
      (cereales.length != 1 || cereales.contains('trigo'))) {
    problemas.add('«pan de» un cereal exige un solo cereal distinto del '
        'trigo (art. 4.4)');
  }
  if (nombre.contains('integral') &&
      !todasIntegrales &&
      !(nombre.contains('harina integral') && nombre.contains('%'))) {
    problemas.add('el nombre dice «integral» sin ser toda la harina integral '
        'ni dar el % (arts. 4.3 y 14.1)');
  }
  for (final cereal in ['centeno', 'espelta', 'maiz', 'arroz']) {
    if (!nombre.contains('de $cereal')) continue;
    if (!cereales.contains(cereal)) {
      problemas.add('el nombre dice «de $cereal» y no lleva harina de $cereal');
    } else if (cereales.length > 1 && !nombre.contains('%')) {
      problemas.add('«de $cereal» con otras harinas exige dar el % de cada '
          'una (arts. 4.4 y 14.1)');
    }
  }
  if (nombre.contains('masa madre')) {
    final harinaTotal = sumaHarinasRecetaGuia(receta.id);
    if (porcentajeDe('masa_madre') < 5 * harinaTotal / 100) {
      problemas.add('«elaborado con masa madre» exige al menos un 5 % de masa '
          'madre sobre la harina (art. 14.5)');
    }
    if (porcentajeDe('levadura_fresca') > 0.2 * harinaTotal / 100) {
      problemas.add('«elaborado con masa madre» admite como mucho un 0,2 % de '
          'levadura (art. 14.5)');
    }
  }
  _mencionesNoComprobables.forEach((palabra, articulo) {
    if (nombre.contains(palabra)) {
      problemas.add('«$palabra» tiene requisitos de elaboración ($articulo) '
          'que una receta base no garantiza');
    }
  });
  if (receta.denominacion.isNotEmpty &&
      salSuperaMaximo(composicionRecetaGuia(receta), receta.denominacion)) {
    problemas.add('la sal estimada supera el máximo de la denominación '
        '(art. 11.2.c)');
  }
  return problemas;
}

/// La receta coincide con [consulta] (sin mayúsculas ni acentos) en el
/// nombre, las notas o sus ingredientes.
bool recetaGuiaCoincide(RecetaGuia receta, String consulta) {
  final buscada = normalizarTextoGuia(consulta.trim());
  if (buscada.isEmpty) return true;
  final texto = normalizarTextoGuia([
    receta.nombre,
    receta.notas,
    for (final linea in ingredientesDeRecetaGuia(receta.id))
      nombreIngredienteBase(linea.ingredienteId),
  ].join(' '));
  return texto.contains(buscada);
}

bool fichaGuiaCoincide(FichaGuiaObrador ficha, String consulta) {
  final buscada = normalizarTextoGuia(consulta.trim());
  if (buscada.isEmpty) return true;
  return normalizarTextoGuia([ficha.titulo, ...ficha.parrafos].join(' '))
      .contains(buscada);
}

List<RecetaGuia> recetasGuiaFiltradas({String consulta = ''}) =>
    catalogoGuiaRecetas
        .where((receta) => recetaGuiaCoincide(receta, consulta))
        .toList();

List<FichaGuiaObrador> fichasGuiaDeSeccion(String seccion,
        {String consulta = ''}) =>
    catalogoGuiaFichas
        .where((ficha) =>
            ficha.seccion == seccion && fichaGuiaCoincide(ficha, consulta))
        .toList();
