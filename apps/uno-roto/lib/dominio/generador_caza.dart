import 'dart:math' as math;

import 'package:nuevo_ser_core/nuevo_ser_core.dart' show NivelMaestria;

import 'distrito.dart';
import 'eso/problema_eso.dart';
import 'fragmento_en_tejado.dart';
import 'mapeo_habilidades_puzzle.dart'
    show
        divisoresParaSkillId,
        modoComparacionParaSkillId,
        modoMcmMcdParaSkillId,
        operadorParaSkillId,
        segundoOperandoNaturalParaSkill,
        tipoParaSkillId;
import 'problema_amplificar.dart' show GeneradorAmplificar;
import 'problema_comparacion.dart' show GeneradorComparacion;
import 'problema_comparacion_decimal.dart'
    show GeneradorComparacionDecimal;
import 'problema_comparacion_unidad.dart'
    show GeneradorComparacionUnidad;
import 'problema_decimal.dart' show decimalesConocidos;
import 'problema_divisibilidad.dart' show GeneradorDivisibilidad;
import 'problema_divisores.dart' show GeneradorDivisores;
import 'problema_fraccion_de_cantidad.dart'
    show GeneradorFraccionDeCantidad;
import 'problema_ordenar_fracciones.dart'
    show GeneradorOrdenarFracciones;
import 'problema_razon.dart' show GeneradorRazon;
import 'problema_lectura_decimal.dart' show GeneradorLecturaDecimal;
import 'problema_lectura_fraccion.dart' show GeneradorLecturaFraccion;
import 'problema_mixto_a_impropio.dart' show GeneradorMixtoAImpropio;
import 'problema_comparacion_distinta.dart'
    show GeneradorComparacionDistinta;
import 'problema_ordenar_decimales.dart' show GeneradorOrdenarDecimales;
import 'problema_jerarquia.dart' show GeneradorJerarquia;
import 'problema_suma_basica.dart' show GeneradorSumaBasica;
import 'problema_ecuacion_lineal.dart' show GeneradorEcuacionLineal;
import 'problema_potencia_natural.dart' show GeneradorPotenciaNatural;
import 'problema_raiz_cuadrada.dart' show GeneradorRaizCuadrada;
import 'problema_ecuacion_ambos_lados.dart'
    show GeneradorEcuacionAmbosLados;
import 'problema_pitagoras.dart' show GeneradorPitagoras;
import 'problema_entero_signo.dart' show GeneradorEnteroSigno;
import 'problema_valor_absoluto.dart' show GeneradorValorAbsoluto;
import 'problema_sistema_dos_x_dos.dart' show GeneradorSistemaDosXDos;
import 'problema_relacion_lineal.dart' show GeneradorRelacionLineal;
import 'problema_angulo.dart' show GeneradorAngulo;
import 'problema_media.dart' show GeneradorMedia;
import 'problema_moda_mediana.dart'
    show EtiquetaModo, GeneradorModaMediana, ModoEstadistico;
import 'problema_probabilidad.dart' show GeneradorProbabilidad;
import 'problema_probabilidad_porcentaje.dart'
    show GeneradorProbabilidadPorcentaje;
import 'problema_escala.dart' show GeneradorEscala;
import 'problema_jerarquia_fracciones.dart'
    show GeneradorJerarquiaFracciones;
import 'problema_operacion_mixta.dart' show GeneradorOperacionMixta;
import 'problema_perimetro.dart' show GeneradorPerimetro;
import 'problema_area_rectangulo.dart' show GeneradorAreaRectangulo;
import 'problema_area_triangulo.dart' show GeneradorAreaTriangulo;
import 'problema_circulo.dart' show GeneradorCirculo;
import 'problema_volumen.dart' show GeneradorVolumen;
import 'problema_simetria.dart' show GeneradorSimetria;
import 'problema_grafico_barras.dart' show GeneradorGraficoBarras;
import 'problema_grafico_circular.dart' show GeneradorGraficoCircular;
// problema_poligono.dart no necesita import: el generador crea el
// Fragmento con `numerador = numeroDeLados` y el dispatcher reconstruye
// con `GeneradorPoligono.generarDesdeLados`.
import 'problema_longitud.dart' show GeneradorLongitud, SimboloUnidad;
import 'problema_masa_capacidad.dart' show GeneradorMasaCapacidad;
import 'problema_aumento_descuento.dart'
    show GeneradorAumentoDescuento, TipoVariacionPorcentual;
import 'problema_superficie.dart'
    show GeneradorSuperficie, SimboloSuperficie;
import 'problema_porcentaje_de.dart' show GeneradorPorcentajeDe;
import 'problema_tiempo.dart'
    show GeneradorTiempo, ModoTiempo, SimboloTiempo;
import 'problema_comparacion_media.dart' show GeneradorComparacionMedia;
import 'problema_porcentaje_cantidad.dart' show GeneradorPorcentajeCantidad;
import 'problema_mcm_mcd.dart' show GeneradorMcmMcd, ModoMcmMcd;
import 'problema_regla_de_tres.dart' show GeneradorReglaDeTres;
import 'problema_primo.dart' show GeneradorPrimo;
import 'problema_redondeo_decimal.dart' show GeneradorRedondeoDecimal;
import 'problema_porcentaje.dart' show porcentajesConocidos;
import 'problema_simplificar.dart' show GeneradorSimplificar;

/// Genera Fragmentos que aparecen en el tejado a lo largo de una
/// sesión de caza. La dificultad sube **continuamente** con el número
/// de esquirlas acumuladas: denominadores más altos, aparición de
/// primos, compuestos más exigentes y tiempos de vida más cortos.
///
/// Biblia §6.2: un niño de 12 años que domina rápido no debe quedarse
/// con contenido de su edad; aquí no hay tope.
class GeneradorCaza {
  final math.Random _azar;

  /// Si viene un distrito, el generador usa su mezcla de puzzles como
  /// sesgo fuerte. Si es null, cae al reparto general por dificultad.
  final Distrito? distrito;

  /// Offset que se suma al nivel calculado por esquirlas. Sirve al modo
  /// experto: un niño avanzado parte unos peldaños más arriba en lugar
  /// de tener que recorrer los casos triviales para llegar a los
  /// interesantes. 0 = comportamiento normal (default). 2 = modo
  /// experto canónico (salta los tiers más fáciles).
  final int offsetDificultad;

  GeneradorCaza({
    int? semilla,
    this.distrito,
    this.offsetDificultad = 0,
  }) : _azar = math.Random(semilla);

  /// Variante dirigida por skill_id: el motor adaptativo decide qué
  /// habilidad tocar y este generador produce un Fragmento del tipo
  /// correspondiente. Si el skill no tiene tipo mapeado, cae al
  /// comportamiento normal.
  ///
  /// Con [nivelMaestria], la dificultad no baja de lo que el niño ya
  /// domina de esa habilidad (en desarrollo, competente, maestría): así
  /// quien la sabe no se entretiene en los casos triviales aunque tenga
  /// pocas esquirlas.
  FragmentoEnTejado siguienteParaSkill({
    required String idHabilidad,
    required int esquirlasAcumuladas,
    required DateTime ahora,
    NivelMaestria? nivelMaestria,
  }) {
    final tipoObjetivo = tipoParaSkillId(idHabilidad);
    if (tipoObjetivo == TipoFragmentoEnTejado.problemaEso) {
      return _fragmentoEso(idHabilidad, esquirlasAcumuladas, ahora, nivelMaestria);
    }
    if (tipoObjetivo == null) {
      return siguiente(
        esquirlasAcumuladas: esquirlasAcumuladas,
        ahora: ahora,
      );
    }
    final dificultad = math.max(
      _nivelDificultadSegunEsquirlas(esquirlasAcumuladas),
      dificultadMinimaPorMaestria(nivelMaestria),
    );
    return _generarDeTipo(
      tipo: tipoObjetivo,
      dificultad: dificultad,
      ahora: ahora,
      operadorPreferido: operadorParaSkillId(idHabilidad),
      modoComparacionPreferido: modoComparacionParaSkillId(idHabilidad),
      divisoresPermitidos: divisoresParaSkillId(idHabilidad),
      modoMcmMcdPreferido: modoMcmMcdParaSkillId(idHabilidad),
      segundoOperandoNatural:
          segundoOperandoNaturalParaSkill(idHabilidad),
    );
  }

  /// Un Fragmento de ESO: la ficha de [idHabilidad] genera el problema
  /// desde la semilla (la pantalla lo regenera igual).
  FragmentoEnTejado _fragmentoEso(
      String idHabilidad, int esquirlasAcumuladas, DateTime ahora, NivelMaestria? nivelMaestria) {
    final dificultad = math.max(
      _nivelDificultadSegunEsquirlas(esquirlasAcumuladas),
      dificultadMinimaPorMaestria(nivelMaestria),
    );
    final semilla = _azar.nextInt(1 << 30);
    final ficha = fichasProblemasEso[idHabilidad]!;
    return FragmentoEnTejado(
      identificador: 'frag_${ahora.microsecondsSinceEpoch}_${_azar.nextInt(9999)}',
      numerador: 1,
      denominador: 1,
      tipo: TipoFragmentoEnTejado.problemaEso,
      etiquetaDecimal: ficha.etiquetaTejado,
      xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
      yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
      instanteAparicion: ahora,
      tiempoDeVida: _tiempoDeVida(dificultad),
      dificultadSugerida: dificultad,
      semillaProblema: semilla,
      idHabilidadEso: idHabilidad,
    );
  }

  FragmentoEnTejado siguiente({
    required int esquirlasAcumuladas,
    required DateTime ahora,
  }) {
    final dificultad = _nivelDificultadSegunEsquirlas(esquirlasAcumuladas);
    final tipo = distrito != null
        ? _elegirTipoSegunDistrito(distrito!, dificultad)
        : _elegirTipo(dificultad);
    return _generarDeTipo(
      tipo: tipo,
      dificultad: dificultad,
      ahora: ahora,
    );
  }

  FragmentoEnTejado _generarDeTipo({
    required TipoFragmentoEnTejado tipo,
    required int dificultad,
    required DateTime ahora,
    OperadorAritmetico? operadorPreferido,
    ModoComparacion? modoComparacionPreferido,
    List<int>? divisoresPermitidos,
    String? modoMcmMcdPreferido,
    bool segundoOperandoNatural = false,
  }) {

    if (tipo == TipoFragmentoEnTejado.ecuacionLineal) {
      final semilla = _azar.nextInt(1 << 30);
      final problema =
          GeneradorEcuacionLineal(semilla: semilla).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        // (a, c) en numerador/denominador para la etiqueta del spawn.
        // El puzzle real lo reconstruye la pantalla con `semillaProblema`.
        numerador: problema.a,
        denominador: problema.c.abs() == 0 ? 1 : problema.c.abs(),
        tipo: tipo,
        etiquetaDecimal: problema.etiqueta,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
        dificultadSugerida: dificultad,
        semillaProblema: semilla,
      );
    }

    if (tipo == TipoFragmentoEnTejado.sumaBasica) {
      final problema = GeneradorSumaBasica(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        // Reusamos numerador/denominador como sumandos a/b para no
        // inflar el modelo del Fragmento.
        numerador: problema.a,
        denominador: problema.b,
        tipo: tipo,
        etiquetaDecimal: '${problema.a}+${problema.b}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.potenciaNatural) {
      final semilla = _azar.nextInt(1 << 30);
      final problema =
          GeneradorPotenciaNatural(semilla: semilla).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        // (base, exponente) en numerador/denominador.
        numerador: problema.base,
        denominador: problema.exponente,
        tipo: tipo,
        etiquetaDecimal: problema.etiqueta,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
        dificultadSugerida: dificultad,
        semillaProblema: semilla,
      );
    }

    if (tipo == TipoFragmentoEnTejado.raizCuadrada) {
      final semilla = _azar.nextInt(1 << 30);
      final problema =
          GeneradorRaizCuadrada(semilla: semilla).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.radicando,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: problema.etiqueta,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
        dificultadSugerida: dificultad,
        semillaProblema: semilla,
      );
    }

    if (tipo == TipoFragmentoEnTejado.ecuacionAmbosLados) {
      final semilla = _azar.nextInt(1 << 30);
      final problema =
          GeneradorEcuacionAmbosLados(semilla: semilla).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        // (a, c) en numerador/denominador — los coeficientes de las x.
        numerador: problema.a,
        denominador: problema.c.abs() == 0 ? 1 : problema.c.abs(),
        tipo: tipo,
        etiquetaDecimal: problema.etiqueta,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
        dificultadSugerida: dificultad,
        semillaProblema: semilla,
      );
    }

    if (tipo == TipoFragmentoEnTejado.pitagoras) {
      final semilla = _azar.nextInt(1 << 30);
      final problema =
          GeneradorPitagoras(semilla: semilla).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        // (a, hipotenusa) en numerador/denominador.
        numerador: problema.a,
        denominador: problema.hipotenusa,
        tipo: tipo,
        etiquetaDecimal:
            '${problema.a}-${problema.b}-${problema.hipotenusa}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
        dificultadSugerida: dificultad,
        semillaProblema: semilla,
      );
    }

    if (tipo == TipoFragmentoEnTejado.enteroSigno) {
      final semilla = _azar.nextInt(1 << 30);
      final problema =
          GeneradorEnteroSigno(semilla: semilla).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.a,
        denominador: problema.b.abs() == 0 ? 1 : problema.b.abs(),
        tipo: tipo,
        etiquetaDecimal: problema.etiqueta,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
        dificultadSugerida: dificultad,
        semillaProblema: semilla,
      );
    }

    if (tipo == TipoFragmentoEnTejado.valorAbsoluto) {
      final semilla = _azar.nextInt(1 << 30);
      final problema =
          GeneradorValorAbsoluto(semilla: semilla).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.a,
        denominador: problema.b.abs() == 0 ? 1 : problema.b.abs(),
        tipo: tipo,
        etiquetaDecimal: problema.etiqueta,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
        dificultadSugerida: dificultad,
        semillaProblema: semilla,
      );
    }

    if (tipo == TipoFragmentoEnTejado.sistemaDosXDos) {
      final semilla = _azar.nextInt(1 << 30);
      final problema =
          GeneradorSistemaDosXDos(semilla: semilla).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.a,
        denominador: problema.e.abs() == 0 ? 1 : problema.e.abs(),
        tipo: tipo,
        etiquetaDecimal:
            '${problema.a},${problema.b},${problema.c};'
            '${problema.d},${problema.e},${problema.f}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
        dificultadSugerida: dificultad,
        semillaProblema: semilla,
      );
    }

    if (tipo == TipoFragmentoEnTejado.relacionLineal) {
      final semilla = _azar.nextInt(1 << 30);
      final problema =
          GeneradorRelacionLineal(semilla: semilla).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.m,
        denominador: problema.n.abs() == 0 ? 1 : problema.n.abs(),
        tipo: tipo,
        etiquetaDecimal: 'm=${problema.m},n=${problema.n}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
        dificultadSugerida: dificultad,
        semillaProblema: semilla,
      );
    }

    if (tipo == TipoFragmentoEnTejado.lecturaDecimal) {
      final problema = GeneradorLecturaDecimal(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        // numerador/denominador no aplican: el contenido pedagógico
        // viaja en `etiquetaDecimal` (texto en palabras).
        numerador: 0,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: problema.texto,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.comparacionDecimal) {
      final problema = GeneradorComparacionDecimal(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        // numerador/denominador no aplican para decimales puros, pero
        // mantenemos el contrato del struct con valores neutros.
        numerador: 0,
        denominador: 1,
        tipo: tipo,
        decimalA: problema.etiquetaA,
        decimalB: problema.etiquetaB,
        etiquetaDecimal: '${problema.etiquetaA} · ${problema.etiquetaB}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.multiplos) {
      final problema = GeneradorDivisibilidad(
        semilla: _azar.nextInt(1 << 30),
        divisoresPermitidos:
            divisoresPermitidos ?? const [2, 3, 4, 5, 6, 7, 8, 9, 10],
      ).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.numero,
        denominador: problema.divisor,
        tipo: tipo,
        // Etiqueta visual: "24·múlt 6" — al estilo del fragmento
        // divisibilidad pero indicando el fraseado.
        etiquetaDecimal: '${problema.numero}·m${problema.divisor}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.graficoCircular) {
      final indiceCaso =
          _azar.nextInt(GeneradorGraficoCircular.cantidadDeCasosCurados);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: indiceCaso,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: 'EST·%',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.graficoBarras) {
      // numerador → índice del caso curado;
      // denominador → 1 valorDeBarra, 2 total.
      final indiceCaso = _azar.nextInt(GeneradorGraficoBarras.cantidadDeCasosCurados);
      // Modo total solo en dificultades altas — exige sumar.
      final esTotal = dificultad >= 3 && _azar.nextBool();
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: indiceCaso,
        denominador: esTotal ? 2 : 1,
        tipo: tipo,
        etiquetaDecimal: esTotal ? 'EST·Σ' : 'EST·V',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.simetria) {
      // numerador → índice de la forma; denominador → 1 vertical, 2 horizontal.
      final indiceForma = _azar.nextInt(GeneradorSimetria.cantidadDeFormas);
      final esHorizontal = _azar.nextBool();
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: indiceForma,
        denominador: esHorizontal ? 2 : 1,
        tipo: tipo,
        etiquetaDecimal: 'SIM',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.volumen) {
      final indice =
          _azar.nextInt(GeneradorVolumen.cantidadDeCasosCurados);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: indice,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: 'V·l×a×h',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.circulo) {
      // numerador → índice del radio (en GeneradorCirculo.radiosCurados);
      // denominador → 1 perímetro, 2 área.
      final indiceRadio = _azar.nextInt(GeneradorCirculo.cantidadDeRadiosCurados);
      final esArea = _azar.nextBool();
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: indiceRadio,
        denominador: esArea ? 2 : 1,
        tipo: tipo,
        etiquetaDecimal: esArea ? 'A·π·r²' : 'P·2πr',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.areaTriangulo) {
      final indice =
          _azar.nextInt(GeneradorAreaTriangulo.cantidadDeCasosCurados);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: indice,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: 'A·b×h÷2',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.areaRectangulo) {
      final indice =
          _azar.nextInt(GeneradorAreaRectangulo.cantidadDeCasosCurados);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: indice,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: 'A·b×h',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.perimetro) {
      final indice =
          _azar.nextInt(GeneradorPerimetro.cantidadDeCasosCurados);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: indice,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: 'PER',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.poligono) {
      // Lados posibles: 3..8 — el numerador del Fragmento guarda el
      // número de lados, que el dispatcher reconstruye al mostrar la
      // pantalla. Dificultad 1 evita 7 y 8 (menos familiares).
      final lados = dificultad >= 2
          ? <int>[3, 4, 5, 6, 7, 8]
          : <int>[3, 4, 5, 6];
      final numeroDeLados = lados[_azar.nextInt(lados.length)];
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: numeroDeLados,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: 'POL',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.operacionMixta) {
      final indice = _azar
          .nextInt(GeneradorOperacionMixta.cantidadDeCasosCurados);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: indice,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: 'OP·MIX',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.probabilidadPorcentaje) {
      final indice = _azar
          .nextInt(GeneradorProbabilidadPorcentaje.cantidadCurada);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: indice,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: 'P %',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.probabilidad) {
      final indice =
          _azar.nextInt(GeneradorProbabilidad.cantidadCurada);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: indice,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: 'P(roja)',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.modaMediana) {
      final esModa = _azar.nextBool();
      final modo =
          esModa ? ModoEstadistico.moda : ModoEstadistico.mediana;
      final tope = esModa
          ? GeneradorModaMediana.cantidadModaCurada
          : GeneradorModaMediana.cantidadMedianaCurada;
      final indice = _azar.nextInt(tope);
      // numerador → índice, denominador 1=moda 2=mediana.
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: indice,
        denominador: esModa ? 1 : 2,
        tipo: tipo,
        etiquetaDecimal: modo.etiqueta,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.media) {
      final indice =
          _azar.nextInt(GeneradorMedia.poolCompleto.length);
      // numerador → índice del conjunto curado.
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: indice,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: 'media·${GeneradorMedia.poolCompleto[indice].length}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.angulo) {
      final problema = GeneradorAngulo(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      // numerador = grados. El dispatcher reconstruye con eso.
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.grados,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: '${problema.grados}°',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.escala) {
      final problema = GeneradorEscala(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      // numerador = denominador de la escala, denominador = valor en
      // plano (cm). El dispatcher reconstruye con esos dos.
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.denominadorEscala,
        denominador: problema.valorPlanoCm,
        tipo: tipo,
        etiquetaDecimal: '1:${problema.denominadorEscala}'
            ' ${problema.valorPlanoCm}cm',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.jerarquiaFracciones) {
      final indice =
          _azar.nextInt(GeneradorJerarquiaFracciones.cantidadDeCasosCurados);
      // Empaquetamos el índice del caso curado en numerador para que el
      // dispatcher pueda reconstruir el mismo problema al pulsar.
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: indice,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: 'op.02',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.superficie) {
      final problema = GeneradorSuperficie(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.valorOrigen,
        denominador: 1,
        tipo: tipo,
        decimalA: problema.unidadOrigen.simbolo,
        decimalB: problema.unidadDestino.simbolo,
        etiquetaDecimal:
            '${problema.valorOrigen} ${problema.unidadOrigen.simbolo}'
            '→${problema.unidadDestino.simbolo}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.aumentoDescuento) {
      final problema = GeneradorAumentoDescuento(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      // numerador = porcentaje, denominador = cantidad. El tipo
      // (aumento/descuento) viaja en decimalA: 'A' o 'D'.
      final marca = problema.tipo == TipoVariacionPorcentual.aumento
          ? 'A'
          : 'D';
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.porcentaje,
        denominador: problema.cantidad,
        tipo: tipo,
        decimalA: marca,
        etiquetaDecimal:
            '$marca ${problema.porcentaje}%/${problema.cantidad}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.tiempo) {
      final problema = GeneradorTiempo(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      // Empaquetamos: numerador = valorMayor, numeradorB = valorMenor
      // (>0 → compuesto, null → simple). decimalA/B llevan los símbolos.
      final esCompuesto = problema.modo == ModoTiempo.compuesto;
      final etiqueta = esCompuesto
          ? '${problema.valorMayor} h ${problema.valorMenor}→min'
          : '${problema.valorMayor} ${problema.unidadOrigen.simbolo}'
              '→${problema.unidadDestino.simbolo}';
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.valorMayor,
        denominador: 1,
        numeradorB: esCompuesto ? problema.valorMenor : null,
        tipo: tipo,
        decimalA: problema.unidadOrigen.simbolo,
        decimalB: problema.unidadDestino.simbolo,
        etiquetaDecimal: etiqueta,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.porcentajeDe) {
      final problema = GeneradorPorcentajeDe(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      // Empaquetamos parte y total en numerador y denominador.
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.parte,
        denominador: problema.total,
        tipo: tipo,
        etiquetaDecimal: '${problema.parte}/${problema.total} %',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.masaCapacidad) {
      final problema = GeneradorMasaCapacidad(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      // Empaquetamos el valor en numerador, los símbolos calculados de
      // la familia+posición en decimalA y decimalB. La familia se
      // recupera al parsear cualquier símbolo en el dispatcher.
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.valorOrigen,
        denominador: 1,
        tipo: tipo,
        decimalA: problema.simboloOrigen,
        decimalB: problema.simboloDestino,
        etiquetaDecimal:
            '${problema.valorOrigen} ${problema.simboloOrigen}'
            '→${problema.simboloDestino}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.longitud) {
      final problema = GeneradorLongitud(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      // Empaquetamos el valor en numerador, los símbolos de origen y
      // destino en decimalA y decimalB; etiquetaDecimal es lo que se
      // pinta en el tejado ("5 m→cm").
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.valorOrigen,
        denominador: 1,
        tipo: tipo,
        decimalA: problema.unidadOrigen.simbolo,
        decimalB: problema.unidadDestino.simbolo,
        etiquetaDecimal:
            '${problema.valorOrigen} ${problema.unidadOrigen.simbolo}'
            '→${problema.unidadDestino.simbolo}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.razon) {
      final problema = GeneradorRazon(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      // Empaquetamos primero/segundo en numerador/denominador y las
      // etiquetas en decimalA/decimalB para reproducir el contexto.
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.primero,
        denominador: problema.segundo,
        tipo: tipo,
        decimalA: problema.etiquetaPrimero,
        decimalB: problema.etiquetaSegundo,
        etiquetaDecimal:
            '${problema.primero}:${problema.segundo}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.ordenarFracciones) {
      final problema = GeneradorOrdenarFracciones(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      // Empaquetamos las tres fracciones en numerador/denominador
      // (la primera) y etiquetaDecimal con todas separadas por '|'.
      final f0 = problema.presentadas[0];
      final f1 = problema.presentadas[1];
      final f2 = problema.presentadas[2];
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: f0.numerador,
        denominador: f0.denominador,
        tipo: tipo,
        etiquetaDecimal: '${f0.numerador}/${f0.denominador}|'
            '${f1.numerador}/${f1.denominador}|'
            '${f2.numerador}/${f2.denominador}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.fraccionDeCantidad) {
      final problema = GeneradorFraccionDeCantidad(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      // Empaquetamos numerador, denominador y cantidad en
      // numerador/denominador/numeradorB para reproducirlo.
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.numerador,
        denominador: problema.denominador,
        numeradorB: problema.cantidad,
        tipo: tipo,
        etiquetaDecimal:
            '${problema.numerador}/${problema.denominador}·${problema.cantidad}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.divisores) {
      final problema = GeneradorDivisores(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        // Empaquetamos el número objetivo en numerador.
        numerador: problema.numero,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: 'div${problema.numero}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.porcentajeCantidad) {
      final problema = GeneradorPorcentajeCantidad(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        // Empaquetamos % en numerador y cantidad en denominador.
        numerador: problema.porcentaje,
        denominador: problema.cantidad,
        tipo: tipo,
        etiquetaDecimal: '${problema.porcentaje}%·${problema.cantidad}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.comparacionMedia) {
      final problema = GeneradorComparacionMedia(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.fraccion.numerador,
        denominador: problema.fraccion.denominador,
        tipo: tipo,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.jerarquia) {
      final problema = GeneradorJerarquia(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      // Empaquetamos los tres operandos en numerador (a), denominador
      // (b), numeradorB (c), y los dos operadores en el campo
      // operador (op2) y decimalA con el símbolo de op1.
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.a,
        denominador: problema.b,
        numeradorB: problema.c,
        tipo: tipo,
        operador: problema.op2,
        decimalA: problema.op1.name,
        etiquetaDecimal:
            '${problema.a}${problema.op1.simbolo}${problema.b}'
            '${problema.op2.simbolo}${problema.c}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.mcmMcd) {
      final modo = modoMcmMcdPreferido == 'mcd'
          ? ModoMcmMcd.mcd
          : ModoMcmMcd.mcm;
      final problema = GeneradorMcmMcd(
        semilla: _azar.nextInt(1 << 30),
      ).generar(modo: modo, dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        // numerador y denominador llevan los dos números a comparar.
        // etiquetaDecimal lleva el modo ('mcm' | 'mcd') para que
        // idHabilidadPrincipal y la pantalla puedan reconstruir.
        numerador: problema.a,
        denominador: problema.b,
        tipo: tipo,
        etiquetaDecimal: modo == ModoMcmMcd.mcd ? 'mcd' : 'mcm',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.ordenarDecimales) {
      final problema = GeneradorOrdenarDecimales(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      // Empaquetamos los tres decimales en decimalA/decimalB/
      // etiquetaDecimal para reconstruir el problema al abrir el
      // Fragmento.
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: 0,
        denominador: 1,
        tipo: tipo,
        decimalA: problema.presentados[0],
        decimalB: problema.presentados[1],
        etiquetaDecimal: '${problema.presentados[0]}|'
            '${problema.presentados[1]}|'
            '${problema.presentados[2]}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.reglaDeTres) {
      final problema = GeneradorReglaDeTres(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      // Empaquetamos los tres términos: a en numerador, b en
      // denominador y c en numeradorB para reconstruir el problema al
      // abrir el Fragmento.
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.a,
        denominador: problema.b,
        numeradorB: problema.c,
        tipo: tipo,
        etiquetaDecimal: '${problema.a}:${problema.b}·${problema.c}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.primo) {
      final problema = GeneradorPrimo(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        // numerador = el número candidato; denominador placeholder.
        numerador: problema.numero,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: '${problema.numero}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.comparacionDistinta) {
      final problema = GeneradorComparacionDistinta(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.a.numerador,
        denominador: problema.a.denominador,
        numeradorB: problema.b.numerador,
        denominadorB: problema.b.denominador,
        tipo: tipo,
        etiquetaDecimal:
            '${problema.a.etiqueta} · ${problema.b.etiqueta}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.redondeoDecimal) {
      final problema = GeneradorRedondeoDecimal(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        // numerador/denominador no aplican; el contenido viaja en
        // etiquetaDecimal con el decimal original "e,cc".
        numerador: 0,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: problema.etiquetaOriginal,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.mixtoAImpropio) {
      final problema = GeneradorMixtoAImpropio(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        // Empaquetamos el mixto en numerador/denominador como (e*d+n)/d
        // y dejamos el entero en numeradorB para reconstruirlo.
        numerador: problema.entero * problema.denominador + problema.numerador,
        denominador: problema.denominador,
        numeradorB: problema.entero,
        tipo: tipo,
        etiquetaDecimal: '${problema.entero} ${problema.numerador}/'
            '${problema.denominador}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.lecturaFraccion) {
      final problema = GeneradorLecturaFraccion(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        // numerador/denominador no aplican: el contenido pedagógico
        // viaja en `etiquetaDecimal` (texto en palabras). Mantenemos la
        // simetría con [TipoFragmentoEnTejado.lecturaDecimal].
        numerador: 0,
        denominador: 1,
        tipo: tipo,
        etiquetaDecimal: problema.texto,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.comparacionUnidad) {
      final problema = GeneradorComparacionUnidad(
        semilla: _azar.nextInt(1 << 30),
      ).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.fraccion.numerador,
        denominador: problema.fraccion.denominador,
        tipo: tipo,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.divisibilidad) {
      final problema = GeneradorDivisibilidad(
        semilla: _azar.nextInt(1 << 30),
        divisoresPermitidos:
            divisoresPermitidos ?? const [2, 3, 5, 10],
      ).generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        // Reusamos numerador/denominador como contenedores: numerador
        // = número candidato, denominador = divisor.
        numerador: problema.numero,
        denominador: problema.divisor,
        tipo: tipo,
        etiquetaDecimal: '${problema.numero}÷${problema.divisor}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.amplificar) {
      final problema = GeneradorAmplificar(semilla: _azar.nextInt(1 << 30))
          .generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.base.numerador,
        denominador: problema.base.denominador,
        // Reutilizamos denominadorB para llevar el denominador objetivo
        // hasta la pantalla — no hay segunda fracción aquí.
        denominadorB: problema.denominadorObjetivo,
        tipo: tipo,
        etiquetaDecimal:
            '${problema.base.etiqueta}=?/${problema.denominadorObjetivo}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.simplificar) {
      final problema = GeneradorSimplificar(semilla: _azar.nextInt(1 << 30))
          .generar(dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.objetivo.numerador,
        denominador: problema.objetivo.denominador,
        tipo: tipo,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.comparacion) {
      final modo = modoComparacionPreferido ??
          (_azar.nextBool()
              ? ModoComparacion.mismoDenominador
              : ModoComparacion.mismoNumerador);
      final problema = GeneradorComparacion(semilla: _azar.nextInt(1 << 30))
          .generar(modo: modo, dificultad: dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: problema.a.numerador,
        denominador: problema.a.denominador,
        numeradorB: problema.b.numerador,
        denominadorB: problema.b.denominador,
        tipo: tipo,
        modoComparacion: modo,
        etiquetaDecimal:
            '${problema.a.etiqueta} · ${problema.b.etiqueta}',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.decimal) {
      final decimalElegido =
          decimalesConocidos[_azar.nextInt(decimalesConocidos.length)];
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: decimalElegido.fraccionEquivalente.numerador,
        denominador: decimalElegido.fraccionEquivalente.denominador,
        tipo: tipo,
        etiquetaDecimal: decimalElegido.etiqueta,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.porcentaje) {
      final porcentajeElegido =
          porcentajesConocidos[_azar.nextInt(porcentajesConocidos.length)];
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: porcentajeElegido.fraccionEquivalente.numerador,
        denominador: porcentajeElegido.fraccionEquivalente.denominador,
        tipo: tipo,
        etiquetaDecimal: porcentajeElegido.etiqueta,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.impropio) {
      final denominadorImp = _elegirDenominadorImpropio(dificultad);
      final numeradorImp = _elegirNumeradorImpropio(denominadorImp, dificultad);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: numeradorImp,
        denominador: denominadorImp,
        tipo: tipo,
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.proporcional) {
      // Una razón "a:b" con a,b pequeños; el numerador/denominador del
      // Fragmento almacenan esos valores para que la pantalla use la
      // misma razón mostrada en el tejado.
      final a = 2 + _azar.nextInt(6);
      final b = 3 + _azar.nextInt(7);
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: a,
        denominador: b,
        tipo: tipo,
        etiquetaDecimal: '$a:$b',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.operacionDecimal) {
      final (textoA, textoB, operador) = _elegirOperacionDecimal(
        dificultad,
        operadorPreferido: operadorPreferido,
        segundoNatural: segundoOperandoNatural,
      );
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: 0,
        denominador: 1,
        tipo: tipo,
        operador: operador,
        decimalA: textoA,
        decimalB: textoB,
        etiquetaDecimal: '$textoA${operador.simbolo}$textoB',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    if (tipo == TipoFragmentoEnTejado.dual) {
      final operador = operadorPreferido ?? _elegirOperadorDual(dificultad);
      final (numA, denA, numB, denB) = _elegirSumandosDual(
        dificultad,
        operador,
        segundoNatural: segundoOperandoNatural,
      );
      return FragmentoEnTejado(
        identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
            '${_azar.nextInt(9999)}',
        numerador: numA,
        denominador: denA,
        numeradorB: numB,
        denominadorB: denB,
        tipo: tipo,
        operador: operador,
        etiquetaDecimal:
            '$numA/$denA${operador.simbolo}$numB/$denB',
        xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
        yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
        instanteAparicion: ahora,
        tiempoDeVida: _tiempoDeVida(dificultad),
      );
    }

    final denominador = tipo == TipoFragmentoEnTejado.espejo
        ? _elegirDenominadorEspejo(dificultad)
        : _elegirDenominador(dificultad);
    final numerador = tipo == TipoFragmentoEnTejado.espejo
        ? _elegirNumeradorEspejo(denominador, dificultad)
        : _elegirNumerador(denominador, dificultad);

    return FragmentoEnTejado(
      identificador: 'frag_${ahora.microsecondsSinceEpoch}_'
          '${_azar.nextInt(9999)}',
      numerador: numerador,
      denominador: denominador,
      tipo: tipo,
      xNormalizado: 0.18 + _azar.nextDouble() * 0.64,
      yNormalizado: 0.2 + _azar.nextDouble() * 0.48,
      instanteAparicion: ahora,
      tiempoDeVida: _tiempoDeVida(dificultad),
    );
  }

  /// Decide qué tipo de Fragmento aparece según el nivel.
  ///
  /// - Dificultad < 2: solo unitarios (el niño aún se hace al gesto).
  /// - Dificultad 2-3: aparecen Espejos.
  /// - Dificultad 3+: también aparecen Decimales.
  TipoFragmentoEnTejado _elegirTipo(int dificultad) {
    if (dificultad < 2) return TipoFragmentoEnTejado.unitario;

    final probEspejo = switch (dificultad) {
      2 => 0.18,
      3 => 0.2,
      4 => 0.22,
      5 => 0.22,
      6 => 0.24,
      _ => 0.26,
    };
    final probDecimal = dificultad < 3
        ? 0.0
        : switch (dificultad) {
            3 => 0.12,
            4 => 0.14,
            5 => 0.15,
            6 => 0.17,
            _ => 0.18,
          };
    final probPorcentaje = dificultad < 3
        ? 0.0
        : switch (dificultad) {
            3 => 0.1,
            4 => 0.12,
            5 => 0.13,
            6 => 0.14,
            _ => 0.15,
          };
    final probImpropio = dificultad < 4
        ? 0.0
        : switch (dificultad) {
            4 => 0.1,
            5 => 0.11,
            6 => 0.12,
            _ => 0.13,
          };
    final probProporcional = dificultad < 5
        ? 0.0
        : switch (dificultad) {
            5 => 0.07,
            6 => 0.09,
            _ => 0.1,
          };
    final probDual = dificultad < 5
        ? 0.0
        : switch (dificultad) {
            5 => 0.08,
            6 => 0.09,
            _ => 0.1,
          };
    final probOperacionDecimal = dificultad < 5
        ? 0.0
        : switch (dificultad) {
            5 => 0.06,
            6 => 0.08,
            _ => 0.1,
          };

    final tirada = _azar.nextDouble();
    var umbral = probEspejo;
    if (tirada < umbral) return TipoFragmentoEnTejado.espejo;
    umbral += probDecimal;
    if (tirada < umbral) return TipoFragmentoEnTejado.decimal;
    umbral += probPorcentaje;
    if (tirada < umbral) return TipoFragmentoEnTejado.porcentaje;
    umbral += probImpropio;
    if (tirada < umbral) return TipoFragmentoEnTejado.impropio;
    umbral += probProporcional;
    if (tirada < umbral) return TipoFragmentoEnTejado.proporcional;
    umbral += probDual;
    if (tirada < umbral) return TipoFragmentoEnTejado.dual;
    umbral += probOperacionDecimal;
    if (tirada < umbral) return TipoFragmentoEnTejado.operacionDecimal;
    return TipoFragmentoEnTejado.unitario;
  }

  /// Elige una operación decimal al azar: dos decimales amigables
  /// y un operador. Los resultados son decimales limpios por diseño
  /// (el generador de la pantalla re-evalúa desde los valores dados).
  (String, String, OperadorAritmetico) _elegirOperacionDecimal(
    int dificultad, {
    OperadorAritmetico? operadorPreferido,
    bool segundoNatural = false,
  }) {
    final operadoresPorDificultad = <OperadorAritmetico>[
      OperadorAritmetico.suma,
      OperadorAritmetico.resta,
      if (dificultad >= 5) OperadorAritmetico.producto,
      if (dificultad >= 6) OperadorAritmetico.division,
    ];
    final operador = operadorPreferido != null &&
            operadoresPorDificultad.contains(operadorPreferido)
        ? operadorPreferido
        : operadoresPorDificultad[
            _azar.nextInt(operadoresPorDificultad.length)];

    // Curado corto de casos por operador.
    switch (operador) {
      case OperadorAritmetico.suma:
        const pares = [
          ('0,5', '0,3'),
          ('0,25', '0,75'),
          ('0,1', '0,9'),
          ('1,2', '0,8'),
          ('0,6', '0,3'),
          ('1,5', '2,5'),
        ];
        final par = pares[_azar.nextInt(pares.length)];
        return (par.$1, par.$2, operador);
      case OperadorAritmetico.resta:
        const pares = [
          ('0,8', '0,3'),
          ('1,0', '0,25'),
          ('2,5', '1,2'),
          ('0,75', '0,25'),
          ('1,5', '0,3'),
        ];
        final par = pares[_azar.nextInt(pares.length)];
        return (par.$1, par.$2, operador);
      case OperadorAritmetico.producto:
        // Pares decimal × decimal (caso general DEC.06).
        const paresDecimal = [
          ('0,5', '0,4'),
          ('0,3', '0,6'),
          ('0,2', '0,5'),
          ('1,5', '0,2'),
          ('2,5', '0,4'),
        ];
        // Pares decimal × natural (DEC.05) — el segundo factor es
        // un entero sin coma, como pide el catálogo.
        const paresConNatural = [
          ('0,25', '4'),
          ('0,5', '6'),
          ('1,5', '3'),
          ('0,2', '7'),
          ('2,3', '5'),
          ('0,75', '2'),
        ];
        final pool = segundoNatural ? paresConNatural : paresDecimal;
        final par = pool[_azar.nextInt(pool.length)];
        return (par.$1, par.$2, operador);
      case OperadorAritmetico.division:
        const pares = [
          ('1,5', '3'),
          ('2,4', '2'),
          ('4,5', '5'),
          ('0,8', '4'),
          ('1,2', '0,4'),
          ('2,0', '0,5'),
        ];
        final par = pares[_azar.nextInt(pares.length)];
        return (par.$1, par.$2, operador);
    }
  }

  /// Elige un tipo respetando la mezcla del [Distrito]. Si el distrito
  /// pide un tipo que aún no se ha desbloqueado por dificultad (p. ej.
  /// el Mercado pide porcentajes pero estamos en dificultad 1), caemos
  /// al reparto general para que el niño no se quede sin Fragmentos en
  /// sus primeras visitas.
  TipoFragmentoEnTejado _elegirTipoSegunDistrito(
    Distrito distritoElegido,
    int dificultad,
  ) {
    final pesoTotal = distritoElegido.mezclaPuzzles.values
        .fold<double>(0, (acum, peso) => acum + peso);
    if (pesoTotal <= 0) return _elegirTipo(dificultad);

    final tirada = _azar.nextDouble() * pesoTotal;
    var acumulado = 0.0;
    for (final entrada in distritoElegido.mezclaPuzzles.entries) {
      acumulado += entrada.value;
      if (tirada < acumulado) {
        // Comprobamos que el tipo esté disponible por dificultad; si no,
        // nos quedamos con unitario en su lugar.
        if (_tipoDisponibleEnDificultad(entrada.key, dificultad)) {
          return entrada.key;
        }
        return TipoFragmentoEnTejado.unitario;
      }
    }
    return TipoFragmentoEnTejado.unitario;
  }

  bool _tipoDisponibleEnDificultad(
    TipoFragmentoEnTejado tipo,
    int dificultad,
  ) {
    switch (tipo) {
      case TipoFragmentoEnTejado.unitario:
        return true;
      case TipoFragmentoEnTejado.comparacion:
        // FR.05/FR.06 se introducen pronto (Aprendiz II); disponible
        // desde el primer tier adaptativo.
        return dificultad >= 1;
      case TipoFragmentoEnTejado.simplificar:
        // FR.10 entra al principio del Iniciado I — un pelín más tarde
        // que la equivalencia libre de FR.09.
        return dificultad >= 2;
      case TipoFragmentoEnTejado.amplificar:
        // FR.11 acompaña a FR.09 (equivalencia) — disponible cuando ya
        // se conoce la mecánica de equivalencia básica.
        return dificultad >= 2;
      case TipoFragmentoEnTejado.divisibilidad:
        // DIV.03 entra antes (Aprendiz III): mecánica binaria muy
        // accesible aunque sea la primera vez.
        return dificultad >= 1;
      case TipoFragmentoEnTejado.multiplos:
        // DIV.01 (concepto de múltiplo) entra a la vez que DIV.03 —
        // misma mecánica, sin necesidad de criterios memorizados.
        return dificultad >= 1;
      case TipoFragmentoEnTejado.comparacionDecimal:
        // DEC.02 entra a partir del Iniciado I.
        return dificultad >= 2;
      case TipoFragmentoEnTejado.lecturaDecimal:
        // DEC.01 es la primera habilidad de decimales — entra antes,
        // a tier 1 (Aprendiz III).
        return dificultad >= 1;
      case TipoFragmentoEnTejado.comparacionUnidad:
        // FR.04 entra cuando ya entiende fracciones simples — más fácil
        // que comparar dos fracciones, le abre los ojos a las impropias.
        return dificultad >= 1;
      case TipoFragmentoEnTejado.lecturaFraccion:
        // FR.02 es la primera habilidad de fracciones después de FR.01;
        // entra desde el primer tier para que aparezca pronto.
        return dificultad >= 1;
      case TipoFragmentoEnTejado.mixtoAImpropio:
        // FR.13 va a la par que FR.12 (impropio → mixto, ya en tier 3).
        return dificultad >= 3;
      case TipoFragmentoEnTejado.redondeoDecimal:
        // DEC.09 entra cuando el niño ya domina lectura y comparación
        // de decimales — antes le pides redondear sin saber leer.
        return dificultad >= 2;
      case TipoFragmentoEnTejado.comparacionDistinta:
        // FR.07 va después de FR.05/FR.06 — pide cálculo, no atajos.
        return dificultad >= 2;
      case TipoFragmentoEnTejado.primo:
        // DIV.05 entra pronto — mecánica binaria muy accesible aunque
        // los casos confusos exigen memoria.
        return dificultad >= 1;
      case TipoFragmentoEnTejado.reglaDeTres:
        // PROP.03 entra cuando el niño ya domina razón básica
        // (PROP.02). Es el segundo escalón de proporcionalidad.
        return dificultad >= 3;
      case TipoFragmentoEnTejado.ordenarDecimales:
        // DEC.03 entra cuando el niño ya domina la comparación
        // binaria (DEC.02, tier 2).
        return dificultad >= 2;
      case TipoFragmentoEnTejado.mcmMcd:
        // DIV.06/DIV.07 son Iniciado II — entran tras dominar
        // divisibilidad y primos.
        return dificultad >= 3;
      case TipoFragmentoEnTejado.jerarquia:
        // OP.01 introduce la prioridad de operaciones en Aprendiz III.
        return dificultad >= 2;
      case TipoFragmentoEnTejado.comparacionMedia:
        // FR.03 es de las primeras habilidades de fracciones — entra
        // desde el primer tier para que aparezca pronto.
        return dificultad >= 1;
      case TipoFragmentoEnTejado.porcentajeCantidad:
        // PROP.04 entra cuando el niño ya tiene base de fracciones y
        // decimales — cálculo, no reconocimiento.
        return dificultad >= 3;
      case TipoFragmentoEnTejado.divisores:
        // DIV.02 va a la par que DIV.03 — mecánica accesible apenas
        // domine la idea de divisor.
        return dificultad >= 1;
      case TipoFragmentoEnTejado.fraccionDeCantidad:
        // FR.22 entra cuando ya domina FR.18 y FR.20 (multiplicar y
        // dividir fracción por natural) — Iniciado II.
        return dificultad >= 3;
      case TipoFragmentoEnTejado.ordenarFracciones:
        // FR.08 entra después de dominar FR.07 (comparar dos
        // fracciones cualesquiera) — Iniciado I.
        return dificultad >= 2;
      case TipoFragmentoEnTejado.razon:
        // PROP.01 es base de proporcionalidad — entra en Iniciado I,
        // tras tener fracciones simplificables claras.
        return dificultad >= 2;
      case TipoFragmentoEnTejado.longitud:
        // MED.01 abre el dominio MED — entra en Iniciado I, tras tener
        // base de decimales (DEC.01) para entender la escalera ×10.
        return dificultad >= 2;
      case TipoFragmentoEnTejado.masaCapacidad:
        // MED.02 entra justo después de MED.01 — Iniciado II.
        return dificultad >= 3;
      case TipoFragmentoEnTejado.porcentajeDe:
        // PROP.05 entra cuando ya domina PROP.04 — Iniciado III.
        return dificultad >= 4;
      case TipoFragmentoEnTejado.tiempo:
        // MED.03 entra en Iniciado I — sexagesimal de uso cotidiano.
        return dificultad >= 2;
      case TipoFragmentoEnTejado.aumentoDescuento:
        // PROP.06 entra cuando ya domina PROP.04 — Iniciado III.
        return dificultad >= 4;
      case TipoFragmentoEnTejado.superficie:
        // MED.05 entra cuando ya domina MED.01 — Iniciado III.
        return dificultad >= 3;
      case TipoFragmentoEnTejado.jerarquiaFracciones:
        // OP.02 combina jerarquía con fracciones — Iniciado II/III.
        return dificultad >= 4;
      case TipoFragmentoEnTejado.escala:
        // PROP.07 depende de PROP.03 + MED.05 — Iniciado III.
        return dificultad >= 4;
      case TipoFragmentoEnTejado.angulo:
        // MED.04 entra desde Iniciado I — base de geometría.
        return dificultad >= 2;
      case TipoFragmentoEnTejado.media:
        // EST.03 entra desde Iniciado I — suma + división.
        return dificultad >= 2;
      case TipoFragmentoEnTejado.modaMediana:
        // EST.04 entra después de EST.01 — Iniciado II.
        return dificultad >= 3;
      case TipoFragmentoEnTejado.probabilidad:
        // EST.05 depende de FR.01 + FR.10 — Iniciado II.
        return dificultad >= 3;
      case TipoFragmentoEnTejado.probabilidadPorcentaje:
        // EST.06 depende de EST.05 + DEC.08 + PROP.04 — Iniciado III.
        return dificultad >= 4;
      case TipoFragmentoEnTejado.operacionMixta:
        // OP.03 depende de OP.02 + DEC.08 — Iniciado III/IV. Es la
        // habilidad más exigente del bloque de operaciones combinadas.
        return dificultad >= 4;
      case TipoFragmentoEnTejado.poligono:
        // GEO.01 abre el dominio GEO desde Aprendiz III — el niño ya
        // ha visto cuadrados y triángulos en la vida real, solo
        // necesita aprender los nombres griegos.
        return dificultad >= 2;
      case TipoFragmentoEnTejado.perimetro:
        // GEO.02 entra justo después de GEO.01 — Iniciado I.
        return dificultad >= 2;
      case TipoFragmentoEnTejado.areaRectangulo:
        // GEO.03 depende de GEO.01 + MED.05 — Iniciado II.
        return dificultad >= 3;
      case TipoFragmentoEnTejado.areaTriangulo:
        // GEO.04 depende de GEO.03 — Iniciado II.
        return dificultad >= 3;
      case TipoFragmentoEnTejado.circulo:
        // GEO.05 depende de DEC.06 + GEO.03 — Iniciado III.
        return dificultad >= 4;
      case TipoFragmentoEnTejado.volumen:
        // GEO.06 depende de GEO.03 — Iniciado III.
        return dificultad >= 4;
      case TipoFragmentoEnTejado.simetria:
        // GEO.07 entra desde Aprendiz III — visual e intuitivo.
        return dificultad >= 2;
      case TipoFragmentoEnTejado.graficoBarras:
        // EST.01 abre el dominio EST de lectura de gráficos — Iniciado I.
        return dificultad >= 2;
      case TipoFragmentoEnTejado.graficoCircular:
        // EST.02 entra justo después de EST.01 — Iniciado II. Pide
        // soltura visual con la idea de porcentaje.
        return dificultad >= 3;
      case TipoFragmentoEnTejado.sumaBasica:
        // ARI.01 — disponible siempre. Es la base. Si el motor la
        // ofrece es porque el niño la necesita.
        return true;
      case TipoFragmentoEnTejado.ecuacionLineal:
        // ALG.01 — solo desde dificultad alta o desde modo
        // Entrenamiento explícito. Es entrada a álgebra.
        return dificultad >= 4;
      case TipoFragmentoEnTejado.potenciaNatural:
        // ARI.02 — potencias. Iniciado II.
        return dificultad >= 3;
      case TipoFragmentoEnTejado.raizCuadrada:
        // ARI.03 — raíces cuadradas exactas. Iniciado III.
        return dificultad >= 4;
      case TipoFragmentoEnTejado.ecuacionAmbosLados:
        // ALG.02 — segundo escalón de álgebra, requiere agrupar.
        return dificultad >= 5;
      case TipoFragmentoEnTejado.pitagoras:
        // GEO.08 — Pitágoras. Iniciado III.
        return dificultad >= 4;
      case TipoFragmentoEnTejado.enteroSigno:
        // ARI.04 — enteros con signo. Iniciado II.
        return dificultad >= 3;
      case TipoFragmentoEnTejado.valorAbsoluto:
        // ARI.05 — valor absoluto. Iniciado II.
        return dificultad >= 3;
      case TipoFragmentoEnTejado.sistemaDosXDos:
        // ALG.03 — sistemas 2×2. Fraccionista / techo.
        return dificultad >= 5;
      case TipoFragmentoEnTejado.problemaEso:
        // Sólo aparece cuando el selector elige una habilidad de ESO
        // (siguienteParaSkill): nunca en el reparto al azar del distrito.
        return false;
      case TipoFragmentoEnTejado.relacionLineal:
        // FUN.01 — relación lineal en tabla. Iniciado III.
        return dificultad >= 4;
      case TipoFragmentoEnTejado.espejo:
        return dificultad >= 1;
      case TipoFragmentoEnTejado.decimal:
      case TipoFragmentoEnTejado.porcentaje:
        return dificultad >= 2;
      case TipoFragmentoEnTejado.impropio:
        return dificultad >= 3;
      case TipoFragmentoEnTejado.proporcional:
      case TipoFragmentoEnTejado.dual:
      case TipoFragmentoEnTejado.operacionDecimal:
        return dificultad >= 4;
    }
  }

  /// Elige un operador para el Dual según la dificultad: en niveles
  /// medios solo suma y resta; producto y división aparecen cuando el
  /// niño ya domina las bases.
  OperadorAritmetico _elegirOperadorDual(int dificultad) {
    final candidatos = <OperadorAritmetico>[
      OperadorAritmetico.suma,
      OperadorAritmetico.suma,
    ];
    if (dificultad >= 4) candidatos.add(OperadorAritmetico.resta);
    if (dificultad >= 5) candidatos.add(OperadorAritmetico.producto);
    if (dificultad >= 6) candidatos.add(OperadorAritmetico.division);
    return candidatos[_azar.nextInt(candidatos.length)];
  }

  /// Dos fracciones para una operación dual. Los denominadores suelen
  /// ser distintos (aunque producto y división no lo exigen) y los
  /// numeradores menores que sus denominadores para mantener el
  /// problema en rango de primaria.
  (int, int, int, int) _elegirSumandosDual(
    int dificultad,
    OperadorAritmetico operador, {
    bool segundoNatural = false,
  }) {
    final denominadoresPosibles = dificultad < 6
        ? const [2, 3, 3, 4, 4, 5, 6]
        : const [3, 4, 5, 6, 6, 8, 10, 12];
    final denA =
        denominadoresPosibles[_azar.nextInt(denominadoresPosibles.length)];
    int denB;
    final debeSerDistinto =
        operador == OperadorAritmetico.suma ||
            operador == OperadorAritmetico.resta;
    if (segundoNatural) {
      // FR.18 / FR.20: el segundo operando es un natural pequeño
      // (numB en [2,5]), denB = 1 — la pantalla detecta denB==1 y
      // muestra el natural sin barra de fracción.
      denB = 1;
    } else if (debeSerDistinto) {
      do {
        denB = denominadoresPosibles[
            _azar.nextInt(denominadoresPosibles.length)];
      } while (denB == denA);
    } else {
      denB = denominadoresPosibles[
          _azar.nextInt(denominadoresPosibles.length)];
    }
    final numA = 1 + _azar.nextInt(math.max(1, denA - 1));
    var numB = segundoNatural
        ? 2 + _azar.nextInt(4)
        : 1 + _azar.nextInt(math.max(1, denB - 1));
    // Si es resta, nos aseguramos que el minuendo sea mayor que el
    // sustraendo para no entrar en negativos.
    if (operador == OperadorAritmetico.resta) {
      final valorA = numA / denA;
      final valorB = numB / denB;
      if (valorA < valorB) {
        // Intercambiamos.
        return (numB, denB, numA, denA);
      }
    }
    return (numA, denA, numB, denB);
  }

  int _elegirDenominadorImpropio(int dificultad) {
    final candidatos = <int>[2, 3, 3, 4, 4, 5];
    if (dificultad >= 5) candidatos.addAll([6, 7]);
    if (dificultad >= 6) candidatos.addAll([8, 9]);
    return candidatos[_azar.nextInt(candidatos.length)];
  }

  int _elegirNumeradorImpropio(int denominador, int dificultad) {
    // Impropia: numerador > denominador. Cota superior más modesta para
    // que la parte entera no sea demasiado grande (1-3).
    final minimo = denominador + 1;
    final maximoBase = denominador * 3;
    final maximo = maximoBase - (_azar.nextInt(2));
    return minimo + _azar.nextInt(math.max(1, maximo - minimo));
  }

  /// Para Espejos interesa más variedad de denominadores pequeños
  /// (2, 3, 4, 5, 6, 8, 10) — equivalencias claras.
  int _elegirDenominadorEspejo(int dificultad) {
    final candidatos = <int>[2, 3, 4, 4, 5, 6, 6, 8];
    if (dificultad >= 3) candidatos.addAll([10, 10, 12]);
    if (dificultad >= 5) candidatos.addAll([9, 15]);
    return candidatos[_azar.nextInt(candidatos.length)];
  }

  /// En Espejos el numerador puede ser cualquiera < denominador. Al
  /// mostrar la fracción objetivo queremos que sea reducible y llamativa.
  int _elegirNumeradorEspejo(int denominador, int dificultad) {
    if (denominador <= 2) return 1;
    return 1 + _azar.nextInt(denominador - 1);
  }

  /// Nivel de dificultad creciente sin tope. Cada "tier" mete
  /// denominadores más grandes, primos más frecuentes y compuestos
  /// más cerca de 1 (7/8, 11/12) para el niño avanzado.
  ///
  /// Se le suma `offsetDificultad` para que el modo experto pueda
  /// arrancar más arriba. El máximo se mantiene en 7 — los tiers
  /// superiores no existen.
  int _nivelDificultadSegunEsquirlas(int esquirlas) {
    final base = _nivelBasePorEsquirlas(esquirlas);
    final ajustado = base + offsetDificultad;
    if (ajustado < 0) return 0;
    if (ajustado > 7) return 7;
    return ajustado;
  }

  int _nivelBasePorEsquirlas(int esquirlas) {
    if (esquirlas < 4) return 0;
    if (esquirlas < 10) return 1;
    if (esquirlas < 20) return 2;
    if (esquirlas < 35) return 3;
    if (esquirlas < 55) return 4;
    if (esquirlas < 80) return 5;
    if (esquirlas < 120) return 6;
    return 7;
  }

  int _elegirDenominador(int dificultad) {
    // Tope a 6 deliberado: la mecánica de corte exige N radios desde el
    // centro para 1/N, así que 1/11 obliga al niño a hacer 11 trazos
    // separados — un suplicio en pantalla pequeña sin valor pedagógico
    // adicional. Los denominadores grandes ya viven en los puzzles
    // abstractos (FR.05/06/07/09/10/11…); aquí queremos el gesto.
    final candidatos = <int>[];
    switch (dificultad) {
      case 0:
        candidatos.addAll([2, 2, 3]);
        break;
      case 1:
        candidatos.addAll([2, 3, 3, 4, 5]);
        break;
      case 2:
        candidatos.addAll([2, 3, 4, 4, 5, 5, 6]);
        break;
      case 3:
        candidatos.addAll([3, 4, 5, 5, 6, 6]);
        break;
      case 4:
        candidatos.addAll([3, 4, 5, 5, 6, 6]);
        break;
      case 5:
        candidatos.addAll([4, 5, 5, 6, 6]);
        break;
      case 6:
        candidatos.addAll([4, 5, 6, 6]);
        break;
      case 7:
      default:
        // Territorio del Fraccionista avanzado: la dificultad ya no se
        // expresa en denominadores más grandes (eso pasa a los puzzles
        // abstractos), sino en menos margen de tiempo y más mezcla de
        // tipos. Aquí pesamos un poco más los denominadores altos.
        candidatos.addAll([4, 5, 6, 6, 6]);
    }
    return candidatos[_azar.nextInt(candidatos.length)];
  }

  int _elegirNumerador(int denominador, int dificultad) {
    // En cazadero el numerador del unitario siempre es 1: nada de
    // Fragmentos compuestos como 10/11 que obligan al niño a repetir
    // el mismo corte de 1/11 diez veces seguidas (110 trazos para un
    // Fragmento es absurdo y se siente como bug aunque sea
    // matemáticamente coherente). Los compuestos viven en las sesiones
    // curadas del guión, donde el diseñador decide cuándo introducirlos
    // con peso narrativo.
    return 1;
  }

  /// Tiempo de vida del Fragmento antes de empezar a escapar.
  /// A mayor dificultad, menos margen — el Fraccionista avanzado
  /// tiene que ser más rápido.
  Duration _tiempoDeVida(int dificultad) {
    const msBase = 16000;
    final msVariacion = 7000 - dificultad * 500;
    const msMinimo = 7000;
    final msDisponibles = math.max(msMinimo, msBase - dificultad * 1200);
    final ms = msDisponibles + _azar.nextInt(math.max(1, msVariacion));
    return Duration(milliseconds: ms);
  }
}

/// El peldaño de dificultad (0-7) por debajo del cual no se baja para
/// una habilidad que el niño ya domina a ese [nivel].
int dificultadMinimaPorMaestria(NivelMaestria? nivel) => switch (nivel) {
      NivelMaestria.enDesarrollo => 3,
      NivelMaestria.competente => 5,
      NivelMaestria.maestria => 7,
      _ => 0,
    };
