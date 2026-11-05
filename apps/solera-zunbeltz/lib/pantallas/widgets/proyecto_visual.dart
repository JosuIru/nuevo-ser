import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../branding.dart';
import '../../modelos/constantes.dart';
import '../../modelos/proyecto_test.dart';

/// Euros enteros con separador de miles: «6.480 €».
String eurosRedondos(int centimos) =>
    '${NumberFormat.decimalPattern('es').format((centimos / 100).round())} €';

/// «+1.360 €» / «−640 €»: euros enteros con su signo.
String eurosConSigno(int centimos) {
  if ((centimos / 100).round() == 0) return '0 €';
  return '${centimos > 0 ? '+' : '−'}${eurosRedondos(centimos.abs())}';
}

/// Colores del reparto de gastos: la persona tester en salvia y Zunbeltz
/// en pino (en oscuro, la salvia apagada para que se distingan).
({Color tester, Color zunbeltz}) coloresReparto(BuildContext context) {
  final esquema = context.esquemaZunbeltz;
  final oscuro = esquema.brightness == Brightness.dark;
  return (
    tester:
        oscuro ? colorCuadroSalvia.withValues(alpha: 0.4) : colorCuadroSalvia,
    zunbeltz: oscuro ? esquema.primary : colorCuadroPino,
  );
}

/// Una casilla por mes del test; las pasadas, en pino.
class BarraMesesTest extends StatelessWidget {
  const BarraMesesTest(
      {super.key, required this.hechos, required this.totales});

  final int hechos;
  final int totales;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquemaZunbeltz;
    final hecho = esquema.brightness == Brightness.dark
        ? colorCuadroSalvia
        : colorCuadroPino;
    // Más de 36 casillas no se distinguen: una barra continua.
    if (totales > 36) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: hechos / totales,
          minHeight: 8,
          color: hecho,
          backgroundColor: esquema.surfaceContainerHighest,
        ),
      );
    }
    return Row(children: [
      for (var indice = 0; indice < totales; indice++) ...[
        if (indice > 0) const SizedBox(width: 3),
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: indice < hechos ? hecho : esquema.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ],
    ]);
  }
}

/// Barra partida en dos: lo que asume la persona tester y Zunbeltz.
class BarraRepartoGastos extends StatelessWidget {
  const BarraRepartoGastos(
      {super.key,
      required this.tester,
      required this.zunbeltz,
      this.alto = 12});

  final int tester;
  final int zunbeltz;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final colores = coloresReparto(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(alto / 2),
      child: SizedBox(
        height: alto,
        child: Row(children: [
          if (tester > 0)
            Expanded(flex: tester, child: Container(color: colores.tester)),
          if (tester > 0 && zunbeltz > 0) const SizedBox(width: 3),
          if (zunbeltz > 0)
            Expanded(flex: zunbeltz, child: Container(color: colores.zunbeltz)),
        ]),
      ),
    );
  }
}

/// Barra de lo gastado frente a lo previsto: esmeralda; ámbar pasado el
/// 85 %; roja si se pasa de lo previsto.
class BarraPrevisto extends StatelessWidget {
  const BarraPrevisto({super.key, required this.real, required this.previsto});

  final int real;
  final int previsto;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquemaZunbeltz;
    final proporcion = previsto <= 0 ? 0.0 : real / previsto;
    final colores = context.coloresZunbeltz;
    final color = proporcion > 1
        ? colores.bloqueada
        : proporcion > 0.85
            ? colores.pendiente
            : colorCuadroEsmeralda;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value:
            previsto <= 0 ? (real > 0 ? 1 : 0) : (real / previsto).clamp(0, 1),
        minHeight: 8,
        color: color,
        backgroundColor: esquema.surfaceContainerHighest,
      ),
    );
  }
}

/// Dos letras del proyecto: las de su especie si la tiene; si no, las de
/// la actividad o el nombre.
String siglasProyecto(ProyectoTest proyecto, String idioma) {
  final especie = buscarOpcion(especiesGanado, proyecto.especie);
  final base = [
    if (especie != null && proyecto.especie != 'varias')
      especie.etiqueta(idioma),
    proyecto.actividad,
    proyecto.nombre,
  ].firstWhere((texto) => texto.trim().length >= 2, orElse: () => '·');
  return base
      .trim()
      .substring(0, base.trim().length >= 2 ? 2 : 1)
      .toUpperCase();
}

class AvatarProyecto extends StatelessWidget {
  const AvatarProyecto(
      {super.key,
      required this.proyecto,
      this.tamano = 64,
      this.apagado = false});

  final ProyectoTest proyecto;
  final double tamano;
  final bool apagado;

  @override
  Widget build(BuildContext context) {
    final idioma = Localizations.localeOf(context).languageCode;
    final esquema = context.esquemaZunbeltz;
    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: apagado ? esquema.surfaceContainerHighest : colorCuadroEsmeralda,
        // Esquinas alternas, como los cuadros del logotipo.
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(tamano * 0.18),
          topRight: Radius.circular(tamano * 0.18),
          bottomLeft: Radius.circular(tamano * 0.18),
          bottomRight: Radius.circular(tamano * 0.4),
        ),
      ),
      child: Text(siglasProyecto(proyecto, idioma),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: tamano * 0.34,
              fontWeight: FontWeight.w700,
              color:
                  apagado ? esquema.onSurfaceVariant : colorSobreCuadroClaro)),
    );
  }
}

/// Icono de cada tipo de acompañamiento (`tiposAcompanamiento`).
IconData iconoAcompanamiento(String tipo) => switch (tipo) {
      'formacion' => Icons.school_outlined,
      'visita_referencia' => Icons.travel_explore,
      'asesoramiento' => Icons.support_agent,
      'reunion' => Icons.groups_outlined,
      'visita_finca' => Icons.agriculture_outlined,
      'visita_recibida' => Icons.waving_hand_outlined,
      'mercado' => Icons.storefront_outlined,
      'difusion' => Icons.campaign_outlined,
      'busqueda_canales' => Icons.alt_route,
      'apoyo_tareas' => Icons.handyman_outlined,
      _ => Icons.event_note_outlined,
    };
