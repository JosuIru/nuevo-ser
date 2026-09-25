import 'eso/problema_eso.dart';
import 'fragmento_en_tejado.dart';

/// Conjunto de skill_ids del doc 02 que el MVP sí sabe plantear hoy
/// (tiene algún TipoFragmentoEnTejado mapeado). El selector solo
/// elige entre estos; los demás están documentados pero pendientes de
/// diseño de puzzle.
const Set<String> skillsConPuzzleImplementado = {
  'FR.01',
  'FR.05',
  'FR.06',
  'FR.09',
  'FR.10',
  'FR.11',
  'FR.12',
  'FR.14',
  'FR.15',
  'FR.16',
  'FR.17',
  'FR.18',
  'FR.19',
  'FR.20',
  'FR.21',
  'DEC.04',
  'DEC.05',
  'DEC.06',
  'DEC.07',
  'DEC.08',
  'PROP.02',
  'PROP.04',
  'DIV.01',
  'DIV.03',
  'DIV.04',
  'DEC.01',
  'DEC.02',
  'FR.04',
  'FR.02',
  'FR.13',
  'DEC.09',
  'FR.07',
  'DIV.05',
  'PROP.03',
  'DEC.03',
  'DIV.06',
  'DIV.07',
  'OP.01',
  'FR.03',
  'DIV.02',
  'FR.22',
  'FR.08',
  'PROP.01',
  'MED.01',
  'MED.02',
  'PROP.05',
  'MED.03',
  'PROP.06',
  'MED.05',
  'OP.02',
  'PROP.07',
  'MED.04',
  'EST.03',
  'EST.04',
  'EST.05',
  'EST.06',
  'OP.03',
  'GEO.01',
  'GEO.02',
  'GEO.03',
  'GEO.04',
  'GEO.05',
  'GEO.06',
  'GEO.07',
  'EST.01',
  'EST.02',
  'ARI.01',
  'ALG.01',
  'ARI.02',
  'ARI.03',
  'ALG.02',
  'GEO.08',
  'ARI.04',
  'ARI.05',
  'ALG.03',
  'FUN.01',
  // Ampliación a 14 años: todas con el tipo `problemaEso` (ver
  // `habilidadesEso`); el selector sólo propone las que ya tienen ficha.
  'ARI.06',
  'ARI.07',
  'ARI.08',
  'ARI.09',
  'FR.23',
  'DIV.08',
  'PROP.08',
  'PROP.09',
  'PROP.10',
  'MED.06',
  'ALG.04',
  'ALG.05',
  'ALG.06',
  'ALG.07',
  'ALG.08',
  'ALG.09',
  'ALG.10',
  'ALG.11',
  'ALG.12',
  'FUN.02',
  'FUN.03',
  'FUN.04',
  'GEO.09',
  'GEO.10',
  'GEO.11',
  'GEO.12',
  'GEO.13',
  'EST.07',
  'EST.08',
  'EST.09',
};

/// Las habilidades de 1.º y 2.º de ESO que usan el tipo `problemaEso`.
const Set<String> habilidadesEso = {
  'ARI.06',
  'ARI.07',
  'ARI.08',
  'ARI.09',
  'FR.23',
  'DIV.08',
  'PROP.08',
  'PROP.09',
  'PROP.10',
  'MED.06',
  'ALG.04',
  'ALG.05',
  'ALG.06',
  'ALG.07',
  'ALG.08',
  'ALG.09',
  'ALG.10',
  'ALG.11',
  'ALG.12',
  'FUN.02',
  'FUN.03',
  'FUN.04',
  'GEO.09',
  'GEO.10',
  'GEO.11',
  'GEO.12',
  'GEO.13',
  'EST.07',
  'EST.08',
  'EST.09',
};

/// Si el juego puede proponer ya [skillId]: tiene puzzle y, si es de
/// ESO, su ficha está escrita.
bool puzzleDisponible(String skillId) =>
    skillsConPuzzleImplementado.contains(skillId) &&
    (!habilidadesEso.contains(skillId) || fichasProblemasEso.containsKey(skillId));

/// Dado un skill_id, devuelve el tipo de Fragmento que lo ejercita.
/// Si no hay mapeo, devuelve null (no debería ocurrir si el selector
/// filtra por [skillsConPuzzleImplementado]).
TipoFragmentoEnTejado? tipoParaSkillId(String skillId) {
  if (habilidadesEso.contains(skillId)) return TipoFragmentoEnTejado.problemaEso;
  if (skillId == 'FR.05' || skillId == 'FR.06') {
    return TipoFragmentoEnTejado.comparacion;
  }
  if (skillId == 'FR.09') return TipoFragmentoEnTejado.espejo;
  if (skillId == 'FR.10') return TipoFragmentoEnTejado.simplificar;
  if (skillId == 'FR.11') return TipoFragmentoEnTejado.amplificar;
  if (skillId == 'DIV.01') return TipoFragmentoEnTejado.multiplos;
  if (skillId == 'DIV.02') return TipoFragmentoEnTejado.divisores;
  if (skillId == 'FR.22') return TipoFragmentoEnTejado.fraccionDeCantidad;
  if (skillId == 'FR.08') return TipoFragmentoEnTejado.ordenarFracciones;
  if (skillId == 'PROP.01') return TipoFragmentoEnTejado.razon;
  if (skillId == 'MED.01') return TipoFragmentoEnTejado.longitud;
  if (skillId == 'MED.02') return TipoFragmentoEnTejado.masaCapacidad;
  if (skillId == 'PROP.05') return TipoFragmentoEnTejado.porcentajeDe;
  if (skillId == 'MED.03') return TipoFragmentoEnTejado.tiempo;
  if (skillId == 'PROP.06') return TipoFragmentoEnTejado.aumentoDescuento;
  if (skillId == 'MED.05') return TipoFragmentoEnTejado.superficie;
  if (skillId == 'OP.02') return TipoFragmentoEnTejado.jerarquiaFracciones;
  if (skillId == 'PROP.07') return TipoFragmentoEnTejado.escala;
  if (skillId == 'MED.04') return TipoFragmentoEnTejado.angulo;
  if (skillId == 'EST.03') return TipoFragmentoEnTejado.media;
  if (skillId == 'EST.04') return TipoFragmentoEnTejado.modaMediana;
  if (skillId == 'EST.05') return TipoFragmentoEnTejado.probabilidad;
  if (skillId == 'EST.06') {
    return TipoFragmentoEnTejado.probabilidadPorcentaje;
  }
  if (skillId == 'OP.03') return TipoFragmentoEnTejado.operacionMixta;
  if (skillId == 'GEO.01') return TipoFragmentoEnTejado.poligono;
  if (skillId == 'GEO.02') return TipoFragmentoEnTejado.perimetro;
  if (skillId == 'GEO.03') return TipoFragmentoEnTejado.areaRectangulo;
  if (skillId == 'GEO.04') return TipoFragmentoEnTejado.areaTriangulo;
  if (skillId == 'GEO.05') return TipoFragmentoEnTejado.circulo;
  if (skillId == 'GEO.06') return TipoFragmentoEnTejado.volumen;
  if (skillId == 'GEO.07') return TipoFragmentoEnTejado.simetria;
  if (skillId == 'EST.01') return TipoFragmentoEnTejado.graficoBarras;
  if (skillId == 'EST.02') return TipoFragmentoEnTejado.graficoCircular;
  if (skillId == 'ARI.01') return TipoFragmentoEnTejado.sumaBasica;
  if (skillId == 'ALG.01') return TipoFragmentoEnTejado.ecuacionLineal;
  if (skillId == 'ARI.02') return TipoFragmentoEnTejado.potenciaNatural;
  if (skillId == 'ARI.03') return TipoFragmentoEnTejado.raizCuadrada;
  if (skillId == 'ALG.02') return TipoFragmentoEnTejado.ecuacionAmbosLados;
  if (skillId == 'GEO.08') return TipoFragmentoEnTejado.pitagoras;
  if (skillId == 'ARI.04') return TipoFragmentoEnTejado.enteroSigno;
  if (skillId == 'ARI.05') return TipoFragmentoEnTejado.valorAbsoluto;
  if (skillId == 'ALG.03') return TipoFragmentoEnTejado.sistemaDosXDos;
  if (skillId == 'FUN.01') return TipoFragmentoEnTejado.relacionLineal;
  if (skillId == 'DIV.03' || skillId == 'DIV.04') {
    return TipoFragmentoEnTejado.divisibilidad;
  }
  if (skillId == 'DEC.01') return TipoFragmentoEnTejado.lecturaDecimal;
  if (skillId == 'DEC.02') return TipoFragmentoEnTejado.comparacionDecimal;
  if (skillId == 'FR.04') return TipoFragmentoEnTejado.comparacionUnidad;
  if (skillId == 'FR.02') return TipoFragmentoEnTejado.lecturaFraccion;
  if (skillId == 'FR.13') return TipoFragmentoEnTejado.mixtoAImpropio;
  if (skillId == 'DEC.09') return TipoFragmentoEnTejado.redondeoDecimal;
  if (skillId == 'FR.07') return TipoFragmentoEnTejado.comparacionDistinta;
  if (skillId == 'DIV.05') return TipoFragmentoEnTejado.primo;
  if (skillId == 'PROP.03') return TipoFragmentoEnTejado.reglaDeTres;
  if (skillId == 'DEC.03') return TipoFragmentoEnTejado.ordenarDecimales;
  if (skillId == 'DIV.06' || skillId == 'DIV.07') {
    return TipoFragmentoEnTejado.mcmMcd;
  }
  if (skillId == 'OP.01') return TipoFragmentoEnTejado.jerarquia;
  if (skillId == 'FR.03') return TipoFragmentoEnTejado.comparacionMedia;
  if (skillId == 'FR.12') return TipoFragmentoEnTejado.impropio;
  if (skillId == 'FR.16' ||
      skillId == 'FR.17' ||
      skillId == 'FR.18' ||
      skillId == 'FR.19' ||
      skillId == 'FR.20' ||
      skillId == 'FR.21') {
    return TipoFragmentoEnTejado.dual;
  }
  if (skillId == 'DEC.08') return TipoFragmentoEnTejado.decimal;
  if (skillId == 'DEC.04' ||
      skillId == 'DEC.05' ||
      skillId == 'DEC.06' ||
      skillId == 'DEC.07') {
    return TipoFragmentoEnTejado.operacionDecimal;
  }
  if (skillId == 'PROP.04') return TipoFragmentoEnTejado.porcentajeCantidad;
  if (skillId == 'PROP.02') {
    return TipoFragmentoEnTejado.proporcional;
  }
  if (skillId.startsWith('FR.')) return TipoFragmentoEnTejado.unitario;
  return null;
}

/// Para Fragmentos de divisibilidad/múltiplos, el conjunto de divisores
/// que se pueden plantear según la skill objetivo.
/// - DIV.01: cualquier divisor pequeño {2, 3, 4, 5, 6, 7, 8, 9, 10},
///   porque la habilidad es entender el concepto de múltiplo, no
///   memorizar criterios.
/// - DIV.03: criterios básicos {2, 3, 5, 10}.
/// - DIV.04: criterios avanzados {4, 6, 9}.
/// Null si la skill no es de divisibilidad — el generador caerá en el
/// set predeterminado.
List<int>? divisoresParaSkillId(String skillId) {
  switch (skillId) {
    case 'DIV.01':
      return const [2, 3, 4, 5, 6, 7, 8, 9, 10];
    case 'DIV.03':
      return const [2, 3, 5, 10];
    case 'DIV.04':
      return const [4, 6, 9];
    default:
      return null;
  }
}

/// Para Fragmentos de MCM/MCD, qué calcular según skill.
/// - DIV.07 → MCM (`'mcm'`).
/// - DIV.06 → MCD (`'mcd'`).
/// Null si la skill no es de esta familia.
String? modoMcmMcdParaSkillId(String skillId) {
  switch (skillId) {
    case 'DIV.07':
      return 'mcm';
    case 'DIV.06':
      return 'mcd';
    default:
      return null;
  }
}

/// Para Fragmentos de comparación, el modo concreto según skill.
/// Null si la skill no es una de comparación.
ModoComparacion? modoComparacionParaSkillId(String skillId) {
  switch (skillId) {
    case 'FR.05':
      return ModoComparacion.mismoDenominador;
    case 'FR.06':
      return ModoComparacion.mismoNumerador;
    default:
      return null;
  }
}

/// Para skills que exigen "fracción × natural" o "decimal × natural"
/// — FR.18, FR.20, DEC.05 — el segundo operando debe ser entero, no
/// fracción ni decimal. Devuelve true cuando hay que forzarlo.
bool segundoOperandoNaturalParaSkill(String skillId) {
  return skillId == 'FR.18' ||
      skillId == 'FR.20' ||
      skillId == 'DEC.05';
}

/// Para Duales y OpDecimal, el operador concreto a forzar según
/// skill_id. Null si la skill no exige operador específico.
OperadorAritmetico? operadorParaSkillId(String skillId) {
  switch (skillId) {
    case 'FR.16':
    case 'DEC.04':
      return OperadorAritmetico.suma;
    case 'FR.17':
      return OperadorAritmetico.resta;
    case 'FR.19':
    case 'FR.18':
    case 'DEC.05':
    case 'DEC.06':
      return OperadorAritmetico.producto;
    case 'FR.21':
    case 'FR.20':
    case 'DEC.07':
      return OperadorAritmetico.division;
    default:
      return null;
  }
}

/// Dado un [FragmentoEnTejado], devuelve el id de la habilidad
/// principal que el puzzle asociado ejercita, según el mapa
/// pedagógico (docs/02).
///
/// Mapeo del MVP:
/// - Unitario (cortar en partes iguales) → FR.01.
/// - Espejo (elegir equivalente) → FR.09.
/// - Decimal (decimal → fracción) → DEC.08.
/// - Porcentaje (% → fracción) → PROP.04.
/// - Impropio (impropia → mixta) → FR.12.
/// - Proporcional (completar a:b = c:?) → PROP.02.
/// - Dual con suma → FR.16; resta → FR.17; producto → FR.19; división → FR.21.
/// - Operación decimal con suma/resta → DEC.04; producto → DEC.06;
///   división → DEC.07.
String idHabilidadPrincipal(FragmentoEnTejado fragmento) {
  switch (fragmento.tipo) {
    case TipoFragmentoEnTejado.unitario:
      return 'FR.01';
    case TipoFragmentoEnTejado.sumaBasica:
      return 'ARI.01';
    case TipoFragmentoEnTejado.ecuacionLineal:
      return 'ALG.01';
    case TipoFragmentoEnTejado.potenciaNatural:
      return 'ARI.02';
    case TipoFragmentoEnTejado.raizCuadrada:
      return 'ARI.03';
    case TipoFragmentoEnTejado.ecuacionAmbosLados:
      return 'ALG.02';
    case TipoFragmentoEnTejado.pitagoras:
      return 'GEO.08';
    case TipoFragmentoEnTejado.enteroSigno:
      return 'ARI.04';
    case TipoFragmentoEnTejado.valorAbsoluto:
      return 'ARI.05';
    case TipoFragmentoEnTejado.sistemaDosXDos:
      return 'ALG.03';
    case TipoFragmentoEnTejado.relacionLineal:
      return 'FUN.01';
    case TipoFragmentoEnTejado.problemaEso:
      return fragmento.idHabilidadEso ?? 'ALG.01';
    case TipoFragmentoEnTejado.espejo:
      return 'FR.09';
    case TipoFragmentoEnTejado.decimal:
      return 'DEC.08';
    case TipoFragmentoEnTejado.porcentaje:
      // El puzzle "% → fracción" no es PROP.04 estricto (eso lo hace
      // porcentajeCantidad), pero ejercita el concepto de porcentaje
      // como fracción de denominador 100 — sub-paso real de PROP.04.
      return 'PROP.04';
    case TipoFragmentoEnTejado.porcentajeCantidad:
      return 'PROP.04';
    case TipoFragmentoEnTejado.impropio:
      return 'FR.12';
    case TipoFragmentoEnTejado.proporcional:
      return 'PROP.02';
    case TipoFragmentoEnTejado.comparacion:
      switch (fragmento.modoComparacion) {
        case ModoComparacion.mismoNumerador:
          return 'FR.06';
        case ModoComparacion.mismoDenominador:
        case null:
          return 'FR.05';
      }
    case TipoFragmentoEnTejado.simplificar:
      return 'FR.10';
    case TipoFragmentoEnTejado.amplificar:
      return 'FR.11';
    case TipoFragmentoEnTejado.divisibilidad:
      // El divisor concreto distingue qué skill ejercita el Fragmento:
      // los criterios avanzados (4, 6, 9) son DIV.04; los básicos
      // (2, 3, 5, 10), DIV.03.
      const avanzados = {4, 6, 9};
      return avanzados.contains(fragmento.denominador)
          ? 'DIV.04'
          : 'DIV.03';
    case TipoFragmentoEnTejado.comparacionDecimal:
      return 'DEC.02';
    case TipoFragmentoEnTejado.lecturaDecimal:
      return 'DEC.01';
    case TipoFragmentoEnTejado.multiplos:
      return 'DIV.01';
    case TipoFragmentoEnTejado.divisores:
      return 'DIV.02';
    case TipoFragmentoEnTejado.fraccionDeCantidad:
      return 'FR.22';
    case TipoFragmentoEnTejado.ordenarFracciones:
      return 'FR.08';
    case TipoFragmentoEnTejado.razon:
      return 'PROP.01';
    case TipoFragmentoEnTejado.longitud:
      return 'MED.01';
    case TipoFragmentoEnTejado.masaCapacidad:
      return 'MED.02';
    case TipoFragmentoEnTejado.porcentajeDe:
      return 'PROP.05';
    case TipoFragmentoEnTejado.tiempo:
      return 'MED.03';
    case TipoFragmentoEnTejado.aumentoDescuento:
      return 'PROP.06';
    case TipoFragmentoEnTejado.superficie:
      return 'MED.05';
    case TipoFragmentoEnTejado.jerarquiaFracciones:
      return 'OP.02';
    case TipoFragmentoEnTejado.escala:
      return 'PROP.07';
    case TipoFragmentoEnTejado.angulo:
      return 'MED.04';
    case TipoFragmentoEnTejado.media:
      return 'EST.03';
    case TipoFragmentoEnTejado.modaMediana:
      return 'EST.04';
    case TipoFragmentoEnTejado.probabilidad:
      return 'EST.05';
    case TipoFragmentoEnTejado.probabilidadPorcentaje:
      return 'EST.06';
    case TipoFragmentoEnTejado.operacionMixta:
      return 'OP.03';
    case TipoFragmentoEnTejado.poligono:
      return 'GEO.01';
    case TipoFragmentoEnTejado.perimetro:
      return 'GEO.02';
    case TipoFragmentoEnTejado.areaRectangulo:
      return 'GEO.03';
    case TipoFragmentoEnTejado.areaTriangulo:
      return 'GEO.04';
    case TipoFragmentoEnTejado.circulo:
      return 'GEO.05';
    case TipoFragmentoEnTejado.volumen:
      return 'GEO.06';
    case TipoFragmentoEnTejado.simetria:
      return 'GEO.07';
    case TipoFragmentoEnTejado.graficoBarras:
      return 'EST.01';
    case TipoFragmentoEnTejado.graficoCircular:
      return 'EST.02';
    case TipoFragmentoEnTejado.comparacionUnidad:
      return 'FR.04';
    case TipoFragmentoEnTejado.lecturaFraccion:
      return 'FR.02';
    case TipoFragmentoEnTejado.mixtoAImpropio:
      return 'FR.13';
    case TipoFragmentoEnTejado.redondeoDecimal:
      return 'DEC.09';
    case TipoFragmentoEnTejado.comparacionDistinta:
      return 'FR.07';
    case TipoFragmentoEnTejado.primo:
      return 'DIV.05';
    case TipoFragmentoEnTejado.reglaDeTres:
      return 'PROP.03';
    case TipoFragmentoEnTejado.ordenarDecimales:
      return 'DEC.03';
    case TipoFragmentoEnTejado.mcmMcd:
      // El modo lo lleva etiquetaDecimal: 'mcm' → DIV.07, 'mcd' → DIV.06.
      return fragmento.etiquetaDecimal == 'mcd' ? 'DIV.06' : 'DIV.07';
    case TipoFragmentoEnTejado.jerarquia:
      return 'OP.01';
    case TipoFragmentoEnTejado.comparacionMedia:
      return 'FR.03';
    case TipoFragmentoEnTejado.dual:
      // Si el segundo operando es natural (denB == 1), el dual ejercita
      // FR.18 (× natural) o FR.20 (÷ natural). Si es fracción, FR.19
      // o FR.21.
      final esSegundoNatural = fragmento.denominadorB == 1;
      switch (fragmento.operador) {
        case OperadorAritmetico.suma:
          return 'FR.16';
        case OperadorAritmetico.resta:
          return 'FR.17';
        case OperadorAritmetico.producto:
          return esSegundoNatural ? 'FR.18' : 'FR.19';
        case OperadorAritmetico.division:
          return esSegundoNatural ? 'FR.20' : 'FR.21';
        case null:
          return 'FR.16';
      }
    case TipoFragmentoEnTejado.operacionDecimal:
      // Si el segundo operando es entero (sin coma), el producto
      // ejercita DEC.05 (decimal × natural). En otro caso, DEC.06
      // (decimal × decimal).
      final segundoEsEntero =
          fragmento.decimalB != null && !fragmento.decimalB!.contains(',');
      switch (fragmento.operador) {
        case OperadorAritmetico.suma:
        case OperadorAritmetico.resta:
          return 'DEC.04';
        case OperadorAritmetico.producto:
          return segundoEsEntero ? 'DEC.05' : 'DEC.06';
        case OperadorAritmetico.division:
          return 'DEC.07';
        case null:
          return 'DEC.04';
      }
  }
}

/// Dificultad aproximada entre 0.5 y 2.0 para las métricas del motor.
double dificultadEstimadaDelPuzzle(FragmentoEnTejado fragmento) {
  switch (fragmento.tipo) {
    case TipoFragmentoEnTejado.sumaBasica:
      // Suma básica — la habilidad más fácil del catálogo. Peso bajo.
      return 0.5;
    case TipoFragmentoEnTejado.ecuacionLineal:
      // Álgebra inicial — peso alto: requiere abstracción de la
      // incógnita y manipulación inversa.
      return 1.6;
    case TipoFragmentoEnTejado.potenciaNatural:
      // Potencias — peso medio-alto. La trampa "base × exponente" es
      // muy habitual y obliga a entender qué hace la operación.
      return 1.4;
    case TipoFragmentoEnTejado.raizCuadrada:
      // Raíces — peso alto: inversa de potencia, exige tabla mental.
      return 1.5;
    case TipoFragmentoEnTejado.ecuacionAmbosLados:
      // Ecuación con incógnita en ambos lados — peso muy alto: además
      // de despejar, hay que agrupar las x antes.
      return 1.9;
    case TipoFragmentoEnTejado.pitagoras:
      // Pitágoras — peso alto: lectura visual + cuadrados + raíz.
      return 1.7;
    case TipoFragmentoEnTejado.enteroSigno:
      // Enteros con signo — peso medio: pedagogía del signo.
      return 1.2;
    case TipoFragmentoEnTejado.valorAbsoluto:
      // Valor absoluto — peso medio.
      return 1.2;
    case TipoFragmentoEnTejado.sistemaDosXDos:
      // Sistema 2×2 — peso muy alto: dos incógnitas, dos pasos
      // (sustitución/reducción) + verificación.
      return 2.0;
    case TipoFragmentoEnTejado.relacionLineal:
      // FUN.01 — peso alto: leer la regla detrás de los datos.
      return 1.6;
    case TipoFragmentoEnTejado.problemaEso:
      // Cada habilidad de ESO declara su peso en su ficha.
      return fichasProblemasEso[fragmento.idHabilidadEso]?.dificultadEstimada ?? 1.6;
    case TipoFragmentoEnTejado.unitario:
      final n = fragmento.numerador;
      final d = fragmento.denominador;
      // Denominadores mayores y compuestos pesan más.
      final base = (d / 3).clamp(0.5, 1.6);
      final porCompuesto = n > 1 ? 0.2 : 0.0;
      return (base + porCompuesto).clamp(0.5, 2.0);
    case TipoFragmentoEnTejado.comparacion:
      // Comparar mismo numerador es más contraintuitivo que mismo
      // denominador: pesa un poco más.
      return fragmento.modoComparacion == ModoComparacion.mismoNumerador
          ? 1.0
          : 0.8;
    case TipoFragmentoEnTejado.simplificar:
      // Simplificar pide reconocer una forma mínima entre varias
      // equivalencias — un escalón más que espejo.
      return 1.1;
    case TipoFragmentoEnTejado.amplificar:
      // Amplificar a denominador dado: igual de exigente que
      // simplificar, pero con la mecánica de rellenar.
      return 1.1;
    case TipoFragmentoEnTejado.divisibilidad:
      // Criterios avanzados (4, 6, 9) son menos automáticos que los
      // básicos (2, 3, 5, 10) y pesan un escalón más.
      const avanzados = {4, 6, 9};
      return avanzados.contains(fragmento.denominador) ? 0.95 : 0.7;
    case TipoFragmentoEnTejado.comparacionDecimal:
      // El error sistemático de "más dígitos = mayor" cuesta de superar
      // — pesa como una comparación de fracciones del lado difícil.
      return 1.0;
    case TipoFragmentoEnTejado.lecturaDecimal:
      // Lectura "texto → número": traducción ligera, parecida a
      // espejo o decimal.
      return 0.9;
    case TipoFragmentoEnTejado.multiplos:
      // Concepto de múltiplo, decisión binaria: ligero como DIV.03.
      return 0.7;
    case TipoFragmentoEnTejado.comparacionUnidad:
      // Tres opciones, pero la decisión sale casi a la vista. Más
      // exigente que una binaria, menos que comparar dos fracciones.
      return 0.85;
    case TipoFragmentoEnTejado.lecturaFraccion:
      // Mecánica texto→fracción, similar a DEC.01 lectura decimal.
      return 0.9;
    case TipoFragmentoEnTejado.mixtoAImpropio:
      // Conversión con cálculo aritmético — un escalón sobre simple
      // identificación, similar a impropio inverso.
      return 1.2;
    case TipoFragmentoEnTejado.redondeoDecimal:
      // Decisión sobre la centésima + escribir bien la décima — más
      // exigente que comparación decimal por la propagación.
      return 1.0;
    case TipoFragmentoEnTejado.comparacionDistinta:
      // FR.07 pide multiplicación cruzada o cálculo de valor — un
      // escalón claramente sobre FR.05/FR.06.
      return 1.2;
    case TipoFragmentoEnTejado.primo:
      // Decisión binaria pura, pero memoria + casos confusos pesan
      // como una divisibilidad media.
      return 0.85;
    case TipoFragmentoEnTejado.reglaDeTres:
      // Regla de tres directa: dos pasos mentales (producto cruzado y
      // división). Más exigente que un reconocimiento simple.
      return 1.2;
    case TipoFragmentoEnTejado.ordenarDecimales:
      // Tres decimales con presentaciones engañosas — exige leer cada
      // valor con cuidado. Pesa como redondeo decimal o un escalón
      // sobre la comparación de dos.
      return 1.1;
    case TipoFragmentoEnTejado.mcmMcd:
      // Cálculo con dos descomposiciones — más exigente que la
      // mecánica binaria de divisibilidad.
      return 1.3;
    case TipoFragmentoEnTejado.jerarquia:
      // Dos operaciones encadenadas — pesa como una operación con
      // decimales o un dual sencillo.
      return 1.3;
    case TipoFragmentoEnTejado.comparacionMedia:
      // Tres opciones; la heurística "doble del numerador frente al
      // denominador" es contraintuitiva la primera vez. Algo más
      // exigente que comparar con la unidad (FR.04).
      return 0.95;
    case TipoFragmentoEnTejado.espejo:
    case TipoFragmentoEnTejado.decimal:
    case TipoFragmentoEnTejado.porcentaje:
      return 1.0;
    case TipoFragmentoEnTejado.porcentajeCantidad:
      // Cálculo con dos pasos (multiplicar y dividir entre 100).
      return 1.2;
    case TipoFragmentoEnTejado.divisores:
      // Identificar divisores requiere comprobar mentalmente cada
      // candidato — pesa parecido a divisibilidad pero con cuatro
      // chequeos y descartes.
      return 1.0;
    case TipoFragmentoEnTejado.fraccionDeCantidad:
      // Cálculo de dos pasos (multiplicar por numerador y dividir
      // por denominador), igual que porcentajeCantidad.
      return 1.2;
    case TipoFragmentoEnTejado.ordenarFracciones:
      // Tres comparaciones cruzadas — un escalón sobre FR.07
      // (comparar dos fracciones distintas).
      return 1.3;
    case TipoFragmentoEnTejado.razon:
      // Reducir una razón pide ver el divisor común — pesa parecido a
      // simplificar pero con contexto.
      return 1.0;
    case TipoFragmentoEnTejado.longitud:
      // Conversión en la escalera métrica — un escalón sobre comparación
      // decimal: el niño tiene que recordar cuántos peldaños separan
      // las unidades y aplicar bien la potencia de 10.
      return 1.1;
    case TipoFragmentoEnTejado.masaCapacidad:
      // Mismo motor que longitud — pesa igual; la familia (masa o
      // capacidad) no cambia la dificultad pedagógica.
      return 1.1;
    case TipoFragmentoEnTejado.porcentajeDe:
      // Cálculo inverso de porcentajeCantidad — pide ver la fracción
      // como porcentaje. Pesa parecido a porcentajeCantidad.
      return 1.2;
    case TipoFragmentoEnTejado.tiempo:
      // Sexagesimal exige cambiar de mentalidad respecto al sistema
      // métrico — pesa más que un MED.01 puro.
      return 1.3;
    case TipoFragmentoEnTejado.aumentoDescuento:
      // Cálculo de dos pasos (calcular %, sumar/restar) + mantener el
      // signo correcto. Pesa parecido a porcentajeCantidad.
      return 1.3;
    case TipoFragmentoEnTejado.superficie:
      // El factor 100 frente al 10 lineal exige cambiar de mentalidad.
      // Pesa más que MED.01 puro: el niño tiene que recordar que es ×100.
      return 1.4;
    case TipoFragmentoEnTejado.jerarquiaFracciones:
      // Combina jerarquía + aritmética con fracciones (MCM, simplificar).
      // Pesa más que jerarquia con naturales y que un dual.
      return 1.7;
    case TipoFragmentoEnTejado.escala:
      // Aplicar escala + conversión cm→m. Pesa parecido a la regla
      // de tres con conversión añadida.
      return 1.4;
    case TipoFragmentoEnTejado.angulo:
      // Reconocimiento puro — la habilidad es memoria de las cuatro
      // fronteras. Pesa ligero, parecido a divisibilidad básica.
      return 0.7;
    case TipoFragmentoEnTejado.media:
      // Suma + división — pesa parecido a porcentajeCantidad.
      return 1.1;
    case TipoFragmentoEnTejado.modaMediana:
      // Reconocimiento de la frecuencia o el orden — más ligero que la
      // media (no requiere cálculo).
      return 0.9;
    case TipoFragmentoEnTejado.probabilidad:
      // Cálculo de razón + reducción. Pesa parecido a fraccionDeCantidad.
      return 1.2;
    case TipoFragmentoEnTejado.probabilidadPorcentaje:
      // Conversión fracción → % directa. Pesa como porcentajeCantidad.
      return 1.2;
    case TipoFragmentoEnTejado.operacionMixta:
      // Operación binaria mezclando decimal y fracción — exige
      // convertir mentalmente entre representaciones. Pesa más que un
      // dual o una operación con decimales por la doble representación.
      return 1.6;
    case TipoFragmentoEnTejado.poligono:
      // Reconocimiento puro — la habilidad es contar lados y aplicar
      // el nombre. Pesa ligero, parecido a divisibilidad básica.
      return 0.7;
    case TipoFragmentoEnTejado.perimetro:
      // Suma de lados — pesa parecido a la media: cálculo aritmético
      // con varios sumandos. Un escalón sobre poligono.
      return 1.0;
    case TipoFragmentoEnTejado.areaRectangulo:
      // Multiplicación b×h — pesa similar a perimetro. La trampa
      // estrella (perímetro confundido con área) la hace exigente.
      return 1.1;
    case TipoFragmentoEnTejado.areaTriangulo:
      // (b×h)/2 — escalón pedagógico claro sobre rectángulo. La
      // trampa "olvidar el /2" es persistente.
      return 1.3;
    case TipoFragmentoEnTejado.circulo:
      // Cálculo con π — multiplicación con decimales. Pesa más que el
      // triángulo: la trampa de confundir fórmulas y el formato decimal
      // suben la dificultad.
      return 1.5;
    case TipoFragmentoEnTejado.volumen:
      // Producto de tres factores — un escalón sobre área de
      // rectángulo. Pesa parecido a área de triángulo.
      return 1.3;
    case TipoFragmentoEnTejado.simetria:
      // Decisión binaria visual — la habilidad es la imaginería
      // espacial. Pesa ligero, parecido a divisibilidad básica.
      return 0.8;
    case TipoFragmentoEnTejado.graficoBarras:
      // Lectura de gráfico — pesa ligero (modo valorDeBarra) o
      // medio (modo total) por la suma. Promedio similar a media.
      return 1.0;
    case TipoFragmentoEnTejado.graficoCircular:
      // Lectura visual de pie chart — pesa similar a graficoBarras.
      // La porción está etiquetada y el resto del puzzle es percibir
      // el área proporcional.
      return 1.0;
    case TipoFragmentoEnTejado.impropio:
    case TipoFragmentoEnTejado.proporcional:
      return 1.3;
    case TipoFragmentoEnTejado.dual:
      return fragmento.operador == OperadorAritmetico.division ? 1.8 : 1.5;
    case TipoFragmentoEnTejado.operacionDecimal:
      return 1.5;
  }
}
