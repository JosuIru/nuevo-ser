import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../dominio/fragmento_en_tejado.dart';
import '../nucleo/paleta.dart';

/// Dibuja un Fragmento flotando en el tejado a la espera de ser
/// cazado. Más pequeño y discreto que el del combate: el niño lo ve
/// como presencia ambiente, no como diana del momento.
class PintorFragmentoTejado extends CustomPainter {
  final FragmentoEnTejado fragmento;
  final double fraccionVida; // 0..1
  final double fasePulso;

  PintorFragmentoTejado({
    required this.fragmento,
    required this.fraccionVida,
    required this.fasePulso,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final radioBase = math.min(size.width, size.height) / 2 - 6;
    const amplitud = 2.5;
    final radio =
        radioBase + math.sin(fasePulso * 2 * math.pi) * amplitud;
    final escapando = fraccionVida >= 0.75;
    final opacidad = escapando
        ? (1 - (fraccionVida - 0.75) / 0.25).clamp(0.0, 1.0)
        : 1.0;

    final esEspejo = fragmento.tipo == TipoFragmentoEnTejado.espejo;
    final esDecimal = fragmento.tipo == TipoFragmentoEnTejado.decimal;
    final esPorcentaje = fragmento.tipo == TipoFragmentoEnTejado.porcentaje;
    final esImpropio = fragmento.tipo == TipoFragmentoEnTejado.impropio;
    final esProporcional =
        fragmento.tipo == TipoFragmentoEnTejado.proporcional;
    final esDual = fragmento.tipo == TipoFragmentoEnTejado.dual;
    final esOperacionDecimal =
        fragmento.tipo == TipoFragmentoEnTejado.operacionDecimal;
    final esComparacion =
        fragmento.tipo == TipoFragmentoEnTejado.comparacion;
    final esSimplificar =
        fragmento.tipo == TipoFragmentoEnTejado.simplificar;
    final esAmplificar =
        fragmento.tipo == TipoFragmentoEnTejado.amplificar;
    final esDivisibilidad =
        fragmento.tipo == TipoFragmentoEnTejado.divisibilidad;
    final esComparacionDecimal =
        fragmento.tipo == TipoFragmentoEnTejado.comparacionDecimal;
    final esLecturaDecimal =
        fragmento.tipo == TipoFragmentoEnTejado.lecturaDecimal;
    final esMultiplos =
        fragmento.tipo == TipoFragmentoEnTejado.multiplos;
    final esComparacionUnidad =
        fragmento.tipo == TipoFragmentoEnTejado.comparacionUnidad;
    final esLecturaFraccion =
        fragmento.tipo == TipoFragmentoEnTejado.lecturaFraccion;
    final esMixtoAImpropio =
        fragmento.tipo == TipoFragmentoEnTejado.mixtoAImpropio;
    final esRedondeoDecimal =
        fragmento.tipo == TipoFragmentoEnTejado.redondeoDecimal;
    final esComparacionDistinta =
        fragmento.tipo == TipoFragmentoEnTejado.comparacionDistinta;
    final esPrimo = fragmento.tipo == TipoFragmentoEnTejado.primo;
    final esReglaDeTres =
        fragmento.tipo == TipoFragmentoEnTejado.reglaDeTres;
    final esOrdenarDecimales =
        fragmento.tipo == TipoFragmentoEnTejado.ordenarDecimales;
    final esMcmMcd = fragmento.tipo == TipoFragmentoEnTejado.mcmMcd;
    final esJerarquia = fragmento.tipo == TipoFragmentoEnTejado.jerarquia;
    final esComparacionMedia =
        fragmento.tipo == TipoFragmentoEnTejado.comparacionMedia;
    final esPorcentajeCantidad =
        fragmento.tipo == TipoFragmentoEnTejado.porcentajeCantidad;
    final esDivisores =
        fragmento.tipo == TipoFragmentoEnTejado.divisores;
    final esFraccionDeCantidad =
        fragmento.tipo == TipoFragmentoEnTejado.fraccionDeCantidad;
    final esOrdenarFracciones =
        fragmento.tipo == TipoFragmentoEnTejado.ordenarFracciones;
    final esRazon = fragmento.tipo == TipoFragmentoEnTejado.razon;
    final esLongitud = fragmento.tipo == TipoFragmentoEnTejado.longitud;
    final esMasaCapacidad =
        fragmento.tipo == TipoFragmentoEnTejado.masaCapacidad;
    final esPorcentajeDe =
        fragmento.tipo == TipoFragmentoEnTejado.porcentajeDe;
    final esTiempo = fragmento.tipo == TipoFragmentoEnTejado.tiempo;
    final esAumentoDescuento =
        fragmento.tipo == TipoFragmentoEnTejado.aumentoDescuento;
    final esSuperficie =
        fragmento.tipo == TipoFragmentoEnTejado.superficie;
    final esJerarquiaFracciones =
        fragmento.tipo == TipoFragmentoEnTejado.jerarquiaFracciones;
    final esEscala = fragmento.tipo == TipoFragmentoEnTejado.escala;
    final esAngulo = fragmento.tipo == TipoFragmentoEnTejado.angulo;
    final esMedia = fragmento.tipo == TipoFragmentoEnTejado.media;
    final esModaMediana =
        fragmento.tipo == TipoFragmentoEnTejado.modaMediana;
    final esProbabilidad =
        fragmento.tipo == TipoFragmentoEnTejado.probabilidad;
    final esProbabilidadPorcentaje =
        fragmento.tipo == TipoFragmentoEnTejado.probabilidadPorcentaje;
    final esOperacionMixta =
        fragmento.tipo == TipoFragmentoEnTejado.operacionMixta;
    final esPoligono = fragmento.tipo == TipoFragmentoEnTejado.poligono;
    final esPerimetro = fragmento.tipo == TipoFragmentoEnTejado.perimetro;
    final esAreaRectangulo =
        fragmento.tipo == TipoFragmentoEnTejado.areaRectangulo;
    final esAreaTriangulo =
        fragmento.tipo == TipoFragmentoEnTejado.areaTriangulo;
    final esCirculo = fragmento.tipo == TipoFragmentoEnTejado.circulo;
    final esVolumen = fragmento.tipo == TipoFragmentoEnTejado.volumen;
    final esSimetria = fragmento.tipo == TipoFragmentoEnTejado.simetria;
    final esGraficoBarras =
        fragmento.tipo == TipoFragmentoEnTejado.graficoBarras;
    final esGraficoCircular =
        fragmento.tipo == TipoFragmentoEnTejado.graficoCircular;
    final colorAura = escapando
        ? PaletaNeon.rosaAcento
        : esEspejo
            ? const Color(0xFFFFC36B)
            : esDecimal
                ? const Color(0xFF7EE8D7)
                : esPorcentaje
                    ? const Color(0xFFFF7ED0)
                    : esImpropio
                        ? const Color(0xFFFFA552)
                        : esProporcional
                            ? const Color(0xFFB392FF)
                            : esDual
                                ? const Color(0xFFFF9A6B)
                                : esOperacionDecimal
                                    ? const Color(0xFF79D1FF)
                                    : esComparacion
                                        ? const Color(0xFFA8E6A3)
                                        : esSimplificar
                                            ? const Color(0xFFD8B4FE)
                                            : esAmplificar
                                                ? const Color(0xFFF8C6E0)
                                                : esDivisibilidad
                                                    ? const Color(0xFFFFE082)
                                                    : esComparacionDecimal
                                                        ? const Color(0xFF80DEEA)
                                                        : esLecturaDecimal
                                                            ? const Color(0xFFC5CAE9)
                                                            : esMultiplos
                                                                ? const Color(0xFFFFB74D)
                                                                : esComparacionUnidad
                                                                    ? const Color(0xFF9FE7C7)
                                                                    : esLecturaFraccion
                                                                        ? const Color(0xFFFFAB91)
                                                                        : esMixtoAImpropio
                                                                            ? const Color(0xFFEF9A9A)
                                                                            : esRedondeoDecimal
                                                                                ? const Color(0xFF90CAF9)
                                                                                : esComparacionDistinta
                                                                                    ? const Color(0xFFCE93D8)
                                                                                    : esPrimo
                                                                                        ? const Color(0xFFAED581)
                                                                                        : esReglaDeTres
                                                                                            ? const Color(0xFFFFAB40)
                                                                                            : esOrdenarDecimales
                                                                                                ? const Color(0xFFB39DDB)
                                                                                                : esMcmMcd
                                                                                                    ? const Color(0xFF4FC3F7)
                                                                                                    : esJerarquia
                                                                                                        ? const Color(0xFFFFD54F)
                                                                                                        : esComparacionMedia
                                                                                                            ? const Color(0xFFA5D6A7)
                                                                                                            : esPorcentajeCantidad
                                                                                                                ? const Color(0xFFFF8A65)
                                                                                                                : esDivisores
                                                                                                                    ? const Color(0xFFB2DFDB)
                                                                                                                    : esFraccionDeCantidad
                                                                                                                        ? const Color(0xFFFFCC80)
                                                                                                                        : esOrdenarFracciones
                                                                                                                            ? const Color(0xFFB39DDB)
                                                                                                                            : esRazon
                                                                                                                                ? const Color(0xFFFFB74D)
                                                                                                                                : esLongitud
                                                                                                                                    ? const Color(0xFF80CBC4)
                                                                                                                                    : esMasaCapacidad
                                                                                                                                        ? const Color(0xFFA5D6A7)
                                                                                                                                        : esPorcentajeDe
                                                                                                                                            ? const Color(0xFFF48FB1)
                                                                                                                                            : esTiempo
                                                                                                                                                ? const Color(0xFFCE93D8)
                                                                                                                                                : esAumentoDescuento
                                                                                                                                                    ? const Color(0xFFFFCC80)
                                                                                                                                                    : esSuperficie
                                                                                                                                                        ? const Color(0xFF81D4FA)
                                                                                                                                                        : esJerarquiaFracciones
                                                                                                                                                            ? const Color(0xFFFFE082)
                                                                                                                                                            : esEscala
                                                                                                                                                                ? const Color(0xFF9FA8DA)
                                                                                                                                                                : esAngulo
                                                                                                                                                                    ? const Color(0xFF80DEEA)
                                                                                                                                                                    : esMedia
                                                                                                                                                                        ? const Color(0xFFB39DDB)
                                                                                                                                                                        : esModaMediana
                                                                                                                                                                            ? const Color(0xFF9CCC65)
                                                                                                                                                                            : esProbabilidad
                                                                                                                                                                                ? const Color(0xFFEF5350)
                                                                                                                                                                                : esProbabilidadPorcentaje
                                                                                                                                                                                    ? const Color(0xFFFFA726)
                                                                                                                                                                                    : esOperacionMixta
                                                                                                                                                                                        ? const Color(0xFF7E57C2)
                                                                                                                                                                                        : esPoligono
                                                                                                                                                                                            ? const Color(0xFF66BB6A)
                                                                                                                                                                                            : esPerimetro
                                                                                                                                                                                                ? const Color(0xFF26A69A)
                                                                                                                                                                                                : esAreaRectangulo
                                                                                                                                                                                                    ? const Color(0xFF8D6E63)
                                                                                                                                                                                                    : esAreaTriangulo
                                                                                                                                                                                                        ? const Color(0xFFA1887F)
                                                                                                                                                                                                        : esCirculo
                                                                                                                                                                                                            ? const Color(0xFFAB47BC)
                                                                                                                                                                                                            : esVolumen
                                                                                                                                                                                                                ? const Color(0xFF5C6BC0)
                                                                                                                                                                                                                : esSimetria
                                                                                                                                                                                                                    ? const Color(0xFFEC407A)
                                                                                                                                                                                                                    : esGraficoBarras
                                                                                                                                                                                                                        ? const Color(0xFF7CB342)
                                                                                                                                                                                                                        : esGraficoCircular
                                                                                                                                                                                                                            ? const Color(0xFFFFB300)
                                                                                                                                                                                                                            : PaletaNeon.azulNeon;

    // Raros de clima (doc 16, eje E): aura blanco-cálido que no usa
    // ninguna familia de puzzle — la señal de "esto no es normal".
    final colorAuraEfectivo = fragmento.esDeClima && !escapando
        ? const Color(0xFFF5E9C8)
        : colorAura;

    if (fragmento.esDeClima && !escapando) {
      // Doble anillo exterior respirando lento.
      final radioAnillo =
          radio + 8 + math.sin(fasePulso * 2 * math.pi) * 2;
      final pinturaRareza = Paint()
        ..color = colorAuraEfectivo.withOpacity(0.45 * opacidad)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(centro, radioAnillo, pinturaRareza);
      final pinturaRarezaExterior = Paint()
        ..color = colorAuraEfectivo.withOpacity(0.20 * opacidad)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(centro, radioAnillo + 5, pinturaRarezaExterior);
    }

    if (esEspejo && !escapando) {
      // Aro fantasma que insinúa el "espejo" del Fragmento.
      final pinturaEspejo = Paint()
        ..color = colorAuraEfectivo.withOpacity(0.3 * opacidad)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(
        centro.translate(radioBase * 0.4, -radioBase * 0.3),
        radioBase * 0.8,
        pinturaEspejo,
      );
    }

    // Aura suave.
    for (var capa = 3; capa >= 1; capa--) {
      final pinturaAura = Paint()
        ..color = colorAuraEfectivo.withOpacity(0.09 * capa * opacidad)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6.0 * capa);
      canvas.drawCircle(centro, radio + capa * 4.0, pinturaAura);
    }

    // Cuerpo.
    final pinturaInterior = Paint()
      ..color =
          PaletaNeon.violetaBase.withOpacity(0.85 * opacidad);
    canvas.drawCircle(centro, radio, pinturaInterior);

    final pinturaBorde = Paint()
      ..color = colorAuraEfectivo.withOpacity(opacidad)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(centro, radio, pinturaBorde);

    // Etiqueta. Para etiquetas largas (duales, decimales con muchas
    // cifras) reducimos el tamaño para que quepa en el círculo.
    final factorTamano = fragmento.etiqueta.length > 4 ? 0.32 : 0.5;
    final textoEstilo = TextStyle(
      color: PaletaNeon.textoPrincipal.withOpacity(0.9 * opacidad),
      fontSize: radio * factorTamano,
      fontWeight: FontWeight.w300,
      letterSpacing: 0.8,
    );
    final pintorTexto = TextPainter(
      text: TextSpan(text: fragmento.etiqueta, style: textoEstilo),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: radio * 1.8);
    pintorTexto.paint(
      canvas,
      Offset(
        centro.dx - pintorTexto.width / 2,
        centro.dy - pintorTexto.height / 2,
      ),
    );

    // Anillo de vida: se encoge según se acerca la fuga.
    if (fraccionVida > 0.1) {
      final pinturaAnilloVida = Paint()
        ..color = (escapando
                ? PaletaNeon.rosaAcento
                : PaletaNeon.azulNeon)
            .withOpacity(0.8 * opacidad)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      const anguloInicio = -math.pi / 2;
      final anguloFin = anguloInicio + 2 * math.pi * (1 - fraccionVida);
      canvas.drawArc(
        Rect.fromCircle(center: centro, radius: radio + 4),
        anguloInicio,
        anguloFin - anguloInicio,
        false,
        pinturaAnilloVida,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PintorFragmentoTejado oldDelegate) {
    return oldDelegate.fasePulso != fasePulso ||
        oldDelegate.fraccionVida != fraccionVida ||
        oldDelegate.fragmento.identificador != fragmento.identificador;
  }
}
