import 'package:flutter/foundation.dart';

/// Tipo de puzzle que plantea este Fragmento al ser tocado.
///
/// - [unitario]: combate de cortes (Familia B y C). El niño corta en
///   partes iguales tantas veces como indique numerador/denominador.
/// - [espejo]: puzzle de equivalencia (Familia D). Se muestra la
///   fracción del Fragmento y el niño elige su equivalente entre
///   varios candidatos.
/// - [decimal]: puzzle de conversión (Familia G). El Fragmento se
///   etiqueta con un decimal (0,25) y el niño elige la fracción
///   equivalente entre cuatro candidatos.
/// - [porcentaje]: puzzle de conversión (Familia H). El Fragmento se
///   etiqueta con un porcentaje (25%) y el niño elige la fracción
///   equivalente.
/// - [comparacion]: puzzle de comparación (Familia B/C, FR.05/FR.06).
///   Se muestran dos fracciones — con el mismo denominador o con el
///   mismo numerador — y el niño toca la mayor.
/// - [simplificar]: puzzle FR.10. Se muestra una fracción reducible
///   (p. ej. 6/8) y el niño elige su forma mínima entre cuatro
///   candidatos. A diferencia de [espejo], el ganador es único.
/// - [amplificar]: puzzle FR.11. Se presenta la ecuación
///   "3/4 = ?/12" y el niño elige el numerador que la completa.
///   Mecánica de "rellenar el hueco".
/// - [divisibilidad]: puzzle DIV.03/DIV.04. Se muestra un número y un
///   divisor; el niño decide sí/no. Primera mecánica binaria.
/// - [comparacionDecimal]: puzzle DEC.02. Dos decimales lado a lado,
///   tocar el mayor. Sesgado a casos donde el más largo no es el mayor.
/// - [lecturaDecimal]: puzzle DEC.01. Se muestra un decimal en
///   palabras ("veinticinco centésimas") y el niño elige su etiqueta
///   numérica entre cuatro candidatos.
/// - [multiplos]: puzzle DIV.01. Variante de divisibilidad con
///   fraseado inverso: "¿N es múltiplo de M?".
/// - [comparacionUnidad]: puzzle FR.04. Una fracción y tres botones
///   (<1, =1, >1). Primera mecánica de tres opciones en Uno Roto.
/// - [lecturaFraccion]: puzzle FR.02. Texto en castellano
///   ("tres quintos") + cuatro fracciones candidatas. Simétrico a
///   [lecturaDecimal] pero con trampas propias del idioma de fracciones.
/// - [mixtoAImpropio]: puzzle FR.13. Número mixto ("2 y 3/4") y
///   cuatro fracciones impropias candidatas. Inverso de [impropio].
/// - [redondeoDecimal]: puzzle DEC.09. Decimal con dos cifras (2,37)
///   y cuatro candidatos a su redondeo a la décima.
/// - [comparacionDistinta]: puzzle FR.07. Dos fracciones sin nada en
///   común (denominadores y numeradores distintos). Siguiente escalón
///   sobre [comparacion]: la intuición simple ya no basta.
/// - [primo]: puzzle DIV.05. Mecánica binaria sí/no — ¿el número es
///   primo? Generador con sesgo a casos confusos: el 1, el 2, impares
///   no primos como 9, 15, 21.
/// - [reglaDeTres]: puzzle PROP.03. "a → b · c → ?" + cuatro
///   resultados candidatos. Mecánica de regla de tres directa con
///   trampas pedagógicas (relación invertida, suma de los tres).
/// - [ordenarDecimales]: puzzle DEC.03. Tres decimales sin ordenar y
///   cuatro candidatos con permutaciones; el niño elige la que va de
///   menor a mayor. Distractores curados al error "más cifras = mayor".
/// - [mcmMcd]: puzzle DIV.06/DIV.07. Dos números y la pregunta sobre
///   MCM (DIV.07) o MCD (DIV.06). Comparten pantalla y motor; el modo
///   lo fija la skill.
/// - [jerarquia]: puzzle OP.01. Expresión "a op b op c" con prioridad
///   de × y ÷. Distractor estrella: el cálculo izquierda-a-derecha.
/// - [fraccionDeCantidad]: puzzle FR.22. "Los 3/5 de 20 = ?" + cuatro
///   candidatos. Paralelo a porcentajeCantidad pero con fracción.
/// - [razon]: puzzle PROP.01. Dos cantidades con contexto + cuatro
///   razones candidatas; el niño elige la reducida que las relaciona.
/// - [ordenarFracciones]: puzzle FR.08. Tres fracciones sin ordenar y
///   cuatro permutaciones candidatas; el niño elige la que va de
///   menor a mayor. Paralelo a ordenarDecimales pero con fracciones.
/// - [divisores]: puzzle DIV.02. Un número grande N + cuatro candidatos;
///   tres son divisores reales de N y uno es el intruso. El niño toca
///   el que NO divide. Refuerza la idea de divisor por contraste.
/// - [porcentajeCantidad]: puzzle PROP.04. "El X % de Y = ?" + cuatro
///   resultados candidatos. Mecánica de cálculo directo con trampas.
/// - [comparacionMedia]: puzzle FR.03. Una fracción y tres botones
///   (<1/2, =1/2, >1/2) con un rectángulo de referencia mostrando la
///   mitad. Generador con sesgo a casos contraintuitivos (5/9, 7/13).
/// - [longitud]: puzzle MED.01. "5 m = ? cm" + cuatro candidatos. Primera
///   habilidad del dominio MED — escalera del sistema métrico, conversión
///   por potencias de 10. Distractores: factor menor, dirección invertida.
/// - [masaCapacidad]: puzzle MED.02. "3 kg = ? g" o "5 L = ? mL".
///   Comparte mecánica de escalera ×10 con [longitud] pero rota entre
///   las familias de masa (kg/g/mg) y capacidad (L/dL/mL).
/// - [porcentajeDe]: puzzle PROP.05. "12 de 50 → ¿qué %?" + cuatro
///   candidatos. Inversa de porcentajeCantidad: aquí calcula
///   parte/total × 100. Distractores reales: complemento (76),
///   parte literal como % (12), total como % (50).
/// - [tiempo]: puzzle MED.03. Conversión sexagesimal h/min/s. Soporta
///   conversión simple ("3 h = ? min" → 180) y compuesta
///   ("2 h y 30 min = ? min" → 150). La trampa estrella: leer
///   "2 h 30" como "230" en lugar de 150.
/// - [aumentoDescuento]: puzzle PROP.06. "Aumenta un 15% sobre 200 →
///   ?" o "Descuenta un 20% sobre 80 → ?". Mecánica: cantidad ± (% ×
///   cantidad / 100). Distractores reales: operación inversa
///   (descuento confundido con aumento), solo la variación, base sin
///   cambio, restar el % literal sin calcular.
/// - [superficie]: puzzle MED.05. "5 m² = ? cm²" → 50000 (NO 500). El
///   sistema de áreas multiplica por 100 (no 10) por peldaño — la
///   trampa estrella es aplicar el factor lineal por inercia.
/// - [jerarquiaFracciones]: puzzle OP.02. "1/2 + 1/4 × 2/3" + cuatro
///   candidatos. Extiende la prioridad de × y ÷ a fracciones; trampa
///   estrella: izquierda-a-derecha. Casos curados con resultado en
///   forma fraccionaria simplificada.
/// - [escala]: puzzle PROP.07. "Mapa 1:500 — 4 cm en plano = ? m" →
///   20 m. Mecánica: aplicar la escala y luego convertir cm → m.
///   Distractor estrella: olvidar la conversión y dar el resultado en
///   cm.
/// - [angulo]: puzzle MED.04. Se muestra un ángulo dibujado y su
///   valor en grados, y el niño elige el tipo (agudo/recto/obtuso/
///   llano) entre cuatro candidatos. Mecánica de reconocimiento.
/// - [media]: puzzle EST.03. Conjunto de números + cuatro candidatos
///   para la media aritmética. Distractor estrella: la suma sin
///   dividir entre la cantidad.
/// - [modaMediana]: puzzle EST.04. Conjunto de números + cuatro
///   candidatos. El modo (moda o mediana) viaja con el Fragmento.
///   Distractor estrella: confundir las dos estadísticas.
/// - [probabilidad]: puzzle EST.05. "saco con 3 rojas y 5 azules →
///   P(roja) = ?" + cuatro fracciones candidatas (reducidas).
///   Distractor estrella: la probabilidad complementaria (P(azul)).
/// - [probabilidadPorcentaje]: puzzle EST.06. "P = 3/4 → como % = ?"
///   + cuatro candidatos %. Reformula EST.05 → DEC.08 → PROP.04 con
///   sentido probabilístico.
/// - [operacionMixta]: puzzle OP.03. Operación binaria mezclando un
///   decimal y una fracción ("0,5 + 1/4" o "1/2 × 0,4"). Trampa
///   estrella: leer el numerador como décimas (1/4 → 0,4 en vez de
///   0,25). Refuerza la equivalencia decimal ↔ fracción dentro de una
///   operación.
/// - [poligono]: puzzle GEO.01. Primera mecánica visual del dominio
///   GEO. Se dibuja un polígono regular y el niño elige su nombre
///   entre cuatro candidatos (triángulo, cuadrado, pentágono…).
/// - [perimetro]: puzzle GEO.02. Polígono dibujado con sus lados
///   etiquetados; el niño suma los lados y elige el perímetro entre
///   cuatro candidatos. Distractores: olvidar un lado, tomar la
///   mitad, multiplicar por número de lados.
/// - [areaRectangulo]: puzzle GEO.03. Rectángulo (o cuadrado) con base
///   y altura etiquetadas; el niño elige el área (b×h). Distractor
///   estrella: el perímetro 2(b+h) en lugar del área.
/// - [areaTriangulo]: puzzle GEO.04. Triángulo con base y altura
///   marcada con línea discontinua + ángulo recto, y cuatro
///   candidatos. Mecánica: (b × h) / 2. Distractor estrella: olvidar
///   el /2.
/// - [circulo]: puzzle GEO.05. Círculo con su radio marcado y la
///   fórmula del modo (área π·r² o perímetro 2·π·r) explícita; el
///   niño elige entre cuatro candidatos decimales. π ≈ 3,14.
///   Distractor estrella: confundir las fórmulas.
/// - [volumen]: puzzle GEO.06. Caja 3D (ortoedro) en proyección
///   isométrica con sus tres dimensiones etiquetadas; el niño
///   calcula el volumen l × a × h. Distractores: área superficial,
///   suma l+a+h, área de una cara.
/// - [simetria]: puzzle GEO.07. Figura simple con un eje (vertical u
///   horizontal) sobreimpreso; el niño decide si es simétrica
///   respecto al eje (sí/no). Decisión binaria.
/// - [graficoBarras]: puzzle EST.01. Gráfico de barras con etiquetas
///   y eje numerado; el niño elige el valor de una barra resaltada
///   o el total entre cuatro candidatos.
/// - [graficoCircular]: puzzle EST.02. Gráfico circular (pie chart)
///   con porciones coloreadas; el niño elige el porcentaje correcto
///   de la porción resaltada en rosa.
enum TipoFragmentoEnTejado {
  unitario,
  espejo,
  decimal,
  porcentaje,
  impropio,
  proporcional,
  dual,
  operacionDecimal,
  comparacion,
  simplificar,
  amplificar,
  divisibilidad,
  comparacionDecimal,
  lecturaDecimal,
  multiplos,
  comparacionUnidad,
  lecturaFraccion,
  mixtoAImpropio,
  redondeoDecimal,
  comparacionDistinta,
  primo,
  reglaDeTres,
  ordenarDecimales,
  mcmMcd,
  jerarquia,
  comparacionMedia,
  porcentajeCantidad,
  divisores,
  fraccionDeCantidad,
  ordenarFracciones,
  razon,
  longitud,
  masaCapacidad,
  porcentajeDe,
  tiempo,
  aumentoDescuento,
  superficie,
  jerarquiaFracciones,
  escala,
  angulo,
  media,
  modaMediana,
  probabilidad,
  probabilidadPorcentaje,
  operacionMixta,
  poligono,
  perimetro,
  areaRectangulo,
  areaTriangulo,
  circulo,
  volumen,
  simetria,
  graficoBarras,
  graficoCircular,
  sumaBasica,
  ecuacionLineal,
  // Era 3 — 12 a 14 años:
  potenciaNatural,
  raizCuadrada,
  pitagoras,
  ecuacionAmbosLados,
  enteroSigno,
  valorAbsoluto,
  sistemaDosXDos,
  relacionLineal,
  // Ampliación a 14 años (1.º y 2.º de ESO): un único tipo para todas
  // las habilidades nuevas; la habilidad va en `idHabilidadEso` y lo
  // propio de cada una, en su ficha (`lib/dominio/eso/`).
  problemaEso,
}

/// Operador aritmético usado por los Fragmentos Duales y los de
/// operación con decimales.
enum OperadorAritmetico { suma, resta, producto, division }

/// Modo de un puzzle de comparación. Determina qué se fija entre las
/// dos fracciones y qué tiene que mirar el niño.
enum ModoComparacion {
  /// FR.05 — misma base (3/8 vs 5/8): gana el numerador mayor.
  mismoDenominador,

  /// FR.06 — mismo numerador (3/5 vs 3/8): gana el denominador menor.
  /// Contraintuitivo: más importante.
  mismoNumerador,
}

extension SimboloOperador on OperadorAritmetico {
  String get simbolo {
    switch (this) {
      case OperadorAritmetico.suma:
        return '+';
      case OperadorAritmetico.resta:
        return '−';
      case OperadorAritmetico.producto:
        return '×';
      case OperadorAritmetico.division:
        return '÷';
    }
  }
}

/// Un Fragmento concreto flotando en el tejado a la espera de ser
/// cazado. Se distingue de [FragmentoUnitario] en que carga datos de
/// **presencia en el mundo**: posición en pantalla, cuándo apareció
/// y cuándo se escapará si nadie lo engancha.
@immutable
class FragmentoEnTejado {
  final String identificador;
  final int numerador;
  final int denominador;
  final TipoFragmentoEnTejado tipo;

  /// Segunda fracción — solo se usa en Fragmentos Duales (Familia F)
  /// donde el puzzle es una operación aritmética sobre a/b y c/d.
  /// Null en cualquier otro tipo.
  final int? numeradorB;
  final int? denominadorB;

  /// Operador que une la primera y segunda fracción en un Dual, o los
  /// dos decimales en un Fragmento de operación decimal. Null en
  /// Fragmentos que no tienen operación binaria explícita.
  final OperadorAritmetico? operador;

  /// Operandos decimales para [TipoFragmentoEnTejado.operacionDecimal].
  /// Se guardan como texto ya formateado ("0,5", "1,25") para mostrar
  /// tal cual en la pantalla, y como valor numérico para la evaluación.
  final String? decimalA;
  final String? decimalB;

  /// Modo de comparación en Fragmentos de tipo
  /// [TipoFragmentoEnTejado.comparacion]. Null para el resto.
  final ModoComparacion? modoComparacion;

  /// Etiqueta alternativa para Fragmentos decimales. Si está presente
  /// se muestra en el tejado en lugar de numerador/denominador.
  final String? etiquetaDecimal;

  /// Coordenadas normalizadas (0-1) sobre el área de caza. El pintor
  /// las multiplica por el tamaño del lienzo al dibujar.
  final double xNormalizado;
  final double yNormalizado;

  /// Momento de aparición en el tejado.
  final DateTime instanteAparicion;

  /// Cuánto tiempo permanece antes de empezar a escapar si nadie lo
  /// engancha. Varía por Fragmento para que no todos se sientan
  /// igual de urgentes.
  final Duration tiempoDeVida;

  /// Dificultad calibrada por el `GeneradorCaza` desde esquirlas y
  /// rango (0..7). Las pantallas Era 3 (raíz cuadrada, Pitágoras,
  /// sistemas 2×2…) la leen para regenerar el problema con el mismo
  /// peldaño que el cazadero — sin esto, un Aprendiz III veía siempre
  /// los casos triviales que se generan con `dificultad: 1` por
  /// defecto. Null en Fragmentos construidos a mano (tests, escenas
  /// guionadas) donde no hay calibración que respetar.
  final int? dificultadSugerida;

  /// Semilla del generador que produjo el problema asociado al
  /// Fragmento. Las pantallas Era 3 (potencia, raíz, Pitágoras,
  /// ec. ambos lados, entero con signo, valor absoluto, sistema 2×2,
  /// relación lineal, ecuación lineal) la usan para regenerar
  /// **exactamente el mismo** problema que vio el niño al spawn — sin
  /// esto, la pantalla regeneraba uno nuevo aleatorio y el "7³" del
  /// Fragmento aparecía como "2⁵" al abrir. Null en Fragmentos cuyo
  /// puzzle se reconstruye desde numerador/denominador/etiquetaDecimal
  /// directamente (la mayoría — esto solo aplica a las Era 3 que usan
  /// `Generador.generar(dificultad:)` con aleatoriedad interna).
  final int? semillaProblema;

  /// Id del `FragmentoDeClima` que este Fragmento encarna, o null si
  /// es un Fragmento normal (doc 16, eje E). El puzzle es el mismo;
  /// la rareza está en el encuentro: aura distinta al flotar y flag
  /// de captura que desbloquea su entrada del Cuaderno.
  final String? idFragmentoDeClima;

  /// En los Fragmentos `problemaEso`: la habilidad de ESO que ejercita
  /// (su ficha genera el problema desde [semillaProblema]).
  final String? idHabilidadEso;

  const FragmentoEnTejado({
    this.idHabilidadEso,
    required this.identificador,
    required this.numerador,
    required this.denominador,
    required this.xNormalizado,
    required this.yNormalizado,
    required this.instanteAparicion,
    required this.tiempoDeVida,
    this.tipo = TipoFragmentoEnTejado.unitario,
    this.etiquetaDecimal,
    this.numeradorB,
    this.denominadorB,
    this.operador,
    this.decimalA,
    this.decimalB,
    this.modoComparacion,
    this.dificultadSugerida,
    this.semillaProblema,
    this.idFragmentoDeClima,
  });

  bool get esCompuesto => numerador > 1;

  bool get esDeClima => idFragmentoDeClima != null;

  /// Copia idéntica marcada como encarnación del raro de clima
  /// [idRaro]. El generador produce el Fragmento normal del distrito
  /// y el cazadero le añade la marca en el hueco de spawn que toque —
  /// así el puzzle sigue calibrado por el selector adaptativo.
  FragmentoEnTejado conMarcaDeClima(String idRaro) {
    return FragmentoEnTejado(
      identificador: identificador,
      numerador: numerador,
      denominador: denominador,
      xNormalizado: xNormalizado,
      yNormalizado: yNormalizado,
      instanteAparicion: instanteAparicion,
      tiempoDeVida: tiempoDeVida,
      tipo: tipo,
      etiquetaDecimal: etiquetaDecimal,
      numeradorB: numeradorB,
      denominadorB: denominadorB,
      operador: operador,
      decimalA: decimalA,
      decimalB: decimalB,
      modoComparacion: modoComparacion,
      dificultadSugerida: dificultadSugerida,
      semillaProblema: semillaProblema,
      idFragmentoDeClima: idRaro,
      idHabilidadEso: idHabilidadEso,
    );
  }

  String get etiqueta => etiquetaDecimal ?? '$numerador/$denominador';

  /// Fracción de vida consumida en este instante [ahora].
  /// 0.0 = acaba de aparecer, 1.0 = se le agotó el tiempo.
  double fraccionVidaConsumida(DateTime ahora) {
    final transcurrido = ahora.difference(instanteAparicion).inMilliseconds;
    if (transcurrido <= 0) return 0;
    final total = tiempoDeVida.inMilliseconds;
    if (total <= 0) return 1;
    return (transcurrido / total).clamp(0.0, 1.0);
  }

  bool seEstaEscapando(DateTime ahora) =>
      fraccionVidaConsumida(ahora) >= 0.75;

  bool seHaEscapado(DateTime ahora) => fraccionVidaConsumida(ahora) >= 1.0;
}
