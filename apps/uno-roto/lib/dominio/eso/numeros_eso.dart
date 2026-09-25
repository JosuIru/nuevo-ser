import 'dart:math' as math;

import 'problema_eso.dart';

/// Fichas de números de 1.º y 2.º de ESO: enteros, potencias, notación
/// científica, fracciones con signo, factorización y unidades de volumen.
final List<FichaProblemaEso> fichasNumerosEso = [
  FichaProblemaEso(
    idHabilidad: 'ARI.06',
    generar: _multiplicarDividirEnteros,
    etiquetaTejado: '−×−',
    tituloAyuda: 'MULTIPLICAR Y DIVIDIR ENTEROS',
    textoAyuda:
        'Primero los números sin signo; luego el signo: si los dos tienen el mismo signo, '
        'el resultado es positivo; si tienen signos distintos, negativo. (−3) · (−4) = 12; '
        '(−12) : 3 = −4.',
    transferencia: 'En la vida: deber 3 € cada día durante 4 días son −12 €.',
    preguntaTutor: 'multiplicar o dividir números enteros con signo',
    errorTipico:
        'equivocarse con la regla de los signos: menos por menos da más',
    dificultadEstimada: 1.4,
    esquirlas: 4,
  ),
];

/// Traducciones de los textos de estas fichas: castellano → [euskera,
/// catalán]. Borrador pendiente de revisión nativa.
const Map<String, List<String>> traduccionesNumerosEso = {
  '¿Cuánto es {e}?': ['Zenbat da {e}?', 'Quant és {e}?'],
  'MULTIPLICAR Y DIVIDIR ENTEROS': [
    'ZENBAKI OSOAK BIDERKATU ETA ZATITU',
    'MULTIPLICAR I DIVIDIR ENTERS'
  ],
  'Primero los números sin signo; luego el signo: si los dos tienen el mismo signo, el resultado es positivo; si tienen signos distintos, negativo. (−3) · (−4) = 12; (−12) : 3 = −4.':
      [
    'Lehenik zenbakiak zeinurik gabe; gero zeinua: biek zeinu bera badute, emaitza positiboa da; zeinu desberdinak badituzte, negatiboa. (−3) · (−4) = 12; (−12) : 3 = −4.',
    'Primer els nombres sense signe; després el signe: si tots dos tenen el mateix signe, el resultat és positiu; si tenen signes diferents, negatiu. (−3) · (−4) = 12; (−12) : 3 = −4.',
  ],
  'En la vida: deber 3 € cada día durante 4 días son −12 €.': [
    'Bizitzan: lau egunez egunero 3 € zor izatea −12 € da.',
    'A la vida: deure 3 € cada dia durant 4 dies són −12 €.',
  ],
};

int _entre(math.Random azar, int minimo, int maximo) =>
    minimo + azar.nextInt(maximo - minimo + 1);

ProblemaEso _multiplicarDividirEnteros(math.Random azar, int dificultad) {
  final maximo = dificultad <= 2 ? 9 : 12;
  var a = _entre(azar, 2, maximo);
  var b = _entre(azar, 2, maximo);
  // Signos: al menos uno negativo.
  final signoA = azar.nextBool() ? -1 : 1;
  final signoB = signoA == 1 ? -1 : (azar.nextBool() ? -1 : 1);
  a *= signoA;
  b *= signoB;
  final dividir = dificultad >= 2 && azar.nextBool();
  final String expresion;
  final int resultado;
  if (dividir) {
    // (a·b) : b = a, exacta.
    expresion = '(${conSigno(a * b)}) : (${conSigno(b)})';
    resultado = a;
  } else {
    expresion = '(${conSigno(a)}) · (${conSigno(b)})';
    resultado = a * b;
  }
  final elegidas = opcionesConErrores(
    azar,
    conSigno(resultado),
    [
      conSigno(-resultado),
      conSigno(dividir ? a * b - b : a + b),
      conSigno(dividir ? -b : -(a.abs() + b.abs()))
    ],
    relleno: (n) => conSigno(resultado + (n.isOdd ? n : -n)),
  );
  return ProblemaEso(
    idHabilidad: 'ARI.06',
    enunciado: '¿Cuánto es {e}?',
    datos: {'e': expresion},
    opciones: elegidas.opciones,
    indiceCorrecto: elegidas.indiceCorrecto,
  );
}
