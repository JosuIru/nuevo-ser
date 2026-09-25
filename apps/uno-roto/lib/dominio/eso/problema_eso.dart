import 'dart:math' as math;

import 'algebra_eso.dart';
import 'ecuaciones_eso.dart';
import 'estadistica_eso.dart';
import 'funciones_eso.dart';
import 'geometria_eso.dart';
import 'numeros_eso.dart';
import 'proporcion_eso.dart';

/// Las habilidades de 1.º y 2.º de ESO (Fase B de la ampliación a 14
/// años) comparten un único tipo de Fragmento, `problemaEso`, y una
/// única pantalla: enunciado, un dibujo si hace falta y cuatro opciones
/// con el error típico entre ellas. Lo propio de cada habilidad vive en
/// su [FichaProblemaEso]: el generador, la ayuda y lo que necesita el
/// tutor. Las fichas se agrupan por dominio (`numeros_eso.dart`,
/// `algebra_eso.dart`…) y se reúnen en [fichasProblemasEso].

/// Un problema listo para enseñar.
class ProblemaEso {
  final String idHabilidad;

  /// Enunciado en castellano con `{a}`, `{b}`… (se traduce con
  /// `traducirNarrativa` y luego se rellenan los [datos]).
  final String enunciado;
  final Map<String, String> datos;

  /// Cuatro opciones ya escritas (números, expresiones: no se traducen).
  final List<String> opciones;
  final int indiceCorrecto;

  /// El dibujo que acompaña al enunciado, si lo hay.
  final VisualEso? visual;

  const ProblemaEso({
    required this.idHabilidad,
    required this.enunciado,
    this.datos = const {},
    required this.opciones,
    required this.indiceCorrecto,
    this.visual,
  });

  String get respuesta => opciones[indiceCorrecto];

  /// El enunciado en castellano con los datos puestos (para el tutor).
  String get enunciadoRelleno {
    var texto = enunciado;
    datos
        .forEach((clave, valor) => texto = texto.replaceAll('{$clave}', valor));
    return texto;
  }
}

/// Los dibujos que puede llevar un problema. La pantalla sabe pintar
/// cada uno; las fichas sólo dicen qué y con qué datos.
sealed class VisualEso {
  const VisualEso();
}

/// Plano cartesiano de −[rango] a [rango]: puntos con etiqueta y rectas
/// `y = pendiente·x + ordenada`.
class VisualPlano extends VisualEso {
  final int rango;
  final List<({num x, num y, String etiqueta})> puntos;
  final List<({num pendiente, num ordenada})> rectas;

  const VisualPlano(
      {this.rango = 6, this.puntos = const [], this.rectas = const []});
}

/// Gráfica de una magnitud frente a otra: una línea por los puntos.
class VisualGrafica extends VisualEso {
  final List<({num x, num y})> puntos;
  final String etiquetaX;
  final String etiquetaY;

  const VisualGrafica(
      {required this.puntos, this.etiquetaX = '', this.etiquetaY = ''});
}

/// Dos triángulos semejantes (Tales): los tres lados de cada uno
/// escritos como texto (`'6'`, `'?'`), en el orden base, lado izquierdo,
/// lado derecho.
class VisualTriangulos extends VisualEso {
  final List<String> ladosPequeno;
  final List<String> ladosGrande;

  const VisualTriangulos(
      {required this.ladosPequeno, required this.ladosGrande});
}

enum FormaCuerpo { prisma, cubo, cilindro, cono, piramide, esfera }

/// Un cuerpo geométrico con sus medidas escritas (`'alto': '5 cm'`…).
/// Claves que sabe colocar la pantalla: `largo`, `ancho`, `alto` (prisma),
/// `lado` (cubo y base de la pirámide), `radio`, `alto` (cilindro y
/// cono), `generatriz` (cono) y `radio` (esfera). `'?'` marca lo que se
/// pregunta.
class VisualCuerpo extends VisualEso {
  final FormaCuerpo forma;
  final Map<String, String> medidas;

  const VisualCuerpo({required this.forma, this.medidas = const {}});
}

/// Una figura plana con sus medidas escritas. Claves: `baseMayor`,
/// `baseMenor`, `alto` (trapecio); `diagonalMayor`, `diagonalMenor`
/// (rombo); `lado`, `apotema` (polígono regular); `cateto1` (abajo),
/// `cateto2` (izquierda), `hipotenusa` (triángulo rectángulo); `base`,
/// `alto` (rectángulo).
enum FormaPlana {
  trapecio,
  rombo,
  poligonoRegular,
  trianguloRectangulo,
  rectangulo
}

class VisualFigura extends VisualEso {
  final FormaPlana forma;

  /// Lados del polígono regular.
  final int lados;
  final Map<String, String> medidas;

  const VisualFigura(
      {required this.forma, this.lados = 6, this.medidas = const {}});
}

/// Una tabla (frecuencias, datos): cabecera y filas, todo texto.
class VisualTabla extends VisualEso {
  final List<String> cabecera;
  final List<List<String>> filas;

  const VisualTabla({required this.cabecera, required this.filas});
}

/// Un diagrama de árbol de dos pasos: las ramas del primero y, para
/// cada una, las del segundo (etiquetas como «C 1/2»).
class VisualArbol extends VisualEso {
  final List<String> primeras;
  final List<List<String>> segundas;

  const VisualArbol({required this.primeras, required this.segundas});
}

/// Lo que necesita el juego de cada habilidad de ESO.
class FichaProblemaEso {
  final String idHabilidad;

  /// Crea un problema. Tiene que ser determinista para un [azar] con la
  /// misma semilla (la pantalla lo regenera desde la semilla del
  /// Fragmento) y aceptar cualquier [dificultad] de 0 a 7.
  final ProblemaEso Function(math.Random azar, int dificultad) generar;

  /// Lo que se ve sobre el Fragmento en el tejado: corto (`x²`, `3/4`…).
  final String etiquetaTejado;

  /// Ayuda del puzzle (castellano; se traduce): título en mayúsculas,
  /// explicación y «En la vida: …».
  final String tituloAyuda;
  final String textoAyuda;
  final String transferencia;

  /// Para el tutor: qué se pide y el error típico.
  final String preguntaTutor;
  final String errorTipico;

  /// Peso de dificultad para el motor de maestría (0,5 a 2,0) y
  /// esquirlas por acertar a la primera.
  final double dificultadEstimada;
  final int esquirlas;

  const FichaProblemaEso({
    required this.idHabilidad,
    required this.generar,
    required this.etiquetaTejado,
    required this.tituloAyuda,
    required this.textoAyuda,
    required this.transferencia,
    required this.preguntaTutor,
    required this.errorTipico,
    this.dificultadEstimada = 1.6,
    this.esquirlas = 5,
  });
}

/// Todas las fichas, por id de habilidad.
final Map<String, FichaProblemaEso> fichasProblemasEso = {
  for (final ficha in [
    ...fichasNumerosEso,
    ...fichasProporcionEso,
    ...fichasAlgebraEso,
    ...fichasEcuacionesEso,
    ...fichasFuncionesEso,
    ...fichasGeometriaEso,
    ...fichasEstadisticaEso,
  ])
    ficha.idHabilidad: ficha,
};

/// Traducciones de todos los textos de las fichas (enunciados, ayudas,
/// dibujos): castellano → [euskera, catalán]. `traducirNarrativa` las
/// consulta si no están en los mapas generales.
final Map<String, List<String>> traduccionesEso = {
  ...traduccionesNumerosEso,
  ...traduccionesProporcionEso,
  ...traduccionesAlgebraEso,
  ...traduccionesEcuacionesEso,
  ...traduccionesFuncionesEso,
  ...traduccionesGeometriaEso,
  ...traduccionesEstadisticaEso,
};

/// El problema de [idHabilidad] para la [semilla] y la [dificultad].
ProblemaEso generarProblemaEso(String idHabilidad,
        {required int semilla, required int dificultad}) =>
    fichasProblemasEso[idHabilidad]!.generar(math.Random(semilla), dificultad);

/// Ayuda para escribir generadores: cuatro opciones distintas con la
/// buena y los errores dados (en orden, sin repetir); si faltan, se
/// completan con [relleno] (llamado con 1, 2, 3…). Se barajan con
/// [azar]. Devuelve las opciones y dónde quedó la buena.
({List<String> opciones, int indiceCorrecto}) opcionesConErrores(
  math.Random azar,
  String buena,
  List<String> errores, {
  required String Function(int n) relleno,
}) {
  final opciones = <String>[buena];
  for (final error in errores) {
    if (opciones.length == 4) break;
    if (!opciones.contains(error)) opciones.add(error);
  }
  var n = 1;
  while (opciones.length < 4 && n < 200) {
    final extra = relleno(n++);
    if (!opciones.contains(extra)) opciones.add(extra);
  }
  opciones.shuffle(azar);
  return (opciones: opciones, indiceCorrecto: opciones.indexOf(buena));
}

/// Un entero con el signo menos tipográfico (−3).
String conSigno(num valor) {
  final texto = valor is int || valor == valor.roundToDouble()
      ? '${valor.round().abs()}'
      : formatearDecimal(valor.abs());
  return valor < 0 ? '−$texto' : texto;
}

/// Un decimal con coma y sin ceros de más (2,5; 0,125).
String formatearDecimal(num valor, {int decimales = 3}) {
  var texto = valor.toStringAsFixed(decimales);
  if (texto.contains('.')) {
    texto = texto.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  return texto.replaceAll('.', ',').replaceAll('-', '−');
}
