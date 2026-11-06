import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' show LatLng;

import '../../branding.dart';
import '../../datos/base_datos.dart';
import '../../estado/sesion_espacio.dart';
import '../../l10n/app_localizations.dart';
import '../../modelos/ganado.dart';
import '../../modelos/ganado_ecologico.dart';
import '../../utiles/crotal.dart';
import '../pantalla_ganado.dart' show etiquetaEspecie;

/// Etiqueta amarilla de crotal, como la de la oreja: «ES03 1101 2345 67».
class EtiquetaCrotal extends StatelessWidget {
  const EtiquetaCrotal({super.key, required this.identificacion});
  final String identificacion;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresZunbeltz;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
      decoration: BoxDecoration(
        color: colores.crotal,
        borderRadius: BorderRadius.circular(radioZunbeltz),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        // El agujero del crotal.
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
                color: colores.sobreCrotal.withValues(alpha: 0.4), width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Text(crotalLegible(identificacion),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colores.sobreCrotal,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()])),
      ]),
    );
  }
}

/// Cuadro salvia con las dos primeras letras de la especie: «OV», «VA».
class AvatarEspecie extends StatelessWidget {
  const AvatarEspecie({super.key, required this.especie, this.tamano = 56});
  final String especie;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final idioma = Localizations.localeOf(context).languageCode;
    final nombre = especie.isEmpty ? '' : etiquetaEspecie(especie, idioma);
    final siglas =
        nombre.length >= 2 ? nombre.substring(0, 2).toUpperCase() : '·';
    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorCuadroSalvia,
        borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
      ),
      child: Text(siglas,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorSobreCuadroClaro, fontWeight: FontWeight.w700)),
    );
  }
}

/// Chip informativo (no se pulsa): icono, texto y su color.
class ChipGanado extends StatelessWidget {
  const ChipGanado({
    super.key,
    required this.texto,
    this.icono,
    required this.fondo,
    required this.color,
  });

  final String texto;
  final IconData? icono;
  final Color fondo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(radioZunbeltz),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icono != null) ...[
          Icon(icono, size: 16, color: color),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(texto,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: color)),
        ),
      ]),
    );
  }
}

/// Los chips de estado de un rebaño (pantalla 09): ecológico, tratamientos
/// que cuentan en ecológico («1 de 3»; en rojo si se pasa), plazos de
/// supresión vigentes y, si lo está, cerrado.
List<Widget> chipsEstadoRebano(BuildContext context, LoteGanado lote,
    Iterable<EventoGanado> eventos, DateTime ahora) {
  final textos = AppLocalizations.of(context);
  final idioma = Localizations.localeOf(context).languageCode;
  final colores = context.coloresZunbeltz;
  final esquema = context.esquemaZunbeltz;
  final supresion = supresionVigente(eventos, ahora, ecologico: lote.ecologico);
  final formato = DateFormat('d MMM', idioma);
  final chips = <Widget>[
    if (!lote.activo)
      ChipGanado(
          texto: textos.ganChipCerrado,
          icono: Icons.archive_outlined,
          fondo: esquema.surfaceContainerHighest,
          color: esquema.onSurfaceVariant),
  ];
  if (lote.ecologico) {
    final estado = estadoTratamientosEcologico(eventos, ahora,
        cicloCorto: lote.cicloCorto);
    chips.add(ChipGanado(
        texto: lote.cicloCorto
            ? textos.ganChipEcologicoCicloCorto
            : textos.ganChipEcologico,
        icono: Icons.eco_outlined,
        fondo: colores.fondoHecha,
        color: colores.hecha));
    final alerta = estado.superado || estado.enElLimite;
    chips.add(ChipGanado(
        texto: textos.ganChipTratamientos(estado.tratamientos, estado.limite),
        icono:
            alerta ? Icons.warning_amber_outlined : Icons.medication_outlined,
        fondo: estado.superado
            ? colores.fondoBloqueada
            : estado.enElLimite
                ? colores.fondoPendiente
                : esquema.surfaceContainerHigh,
        color: estado.superado
            ? colores.bloqueada
            : estado.enElLimite
                ? colores.pendiente
                : esquema.onSurfaceVariant));
  }
  if (supresion.carneHasta != null) {
    chips.add(ChipGanado(
        texto: textos.ganChipCarneLibre(formato.format(supresion.carneHasta!)),
        icono: Icons.hourglass_bottom,
        fondo: colores.fondoPendiente,
        color: colores.pendiente));
  }
  if (supresion.lecheHasta != null) {
    chips.add(ChipGanado(
        texto: textos.ganChipLecheLibre(formato.format(supresion.lecheHasta!)),
        icono: Icons.hourglass_bottom,
        fondo: colores.fondoPendiente,
        color: colores.pendiente));
  }
  return chips;
}

/// Plano de una pieza sin teselas (funciona sin cobertura): su contorno
/// relleno sobre verde claro, encajado en la caja.
class PlanoPieza extends StatelessWidget {
  const PlanoPieza({super.key, required this.vertices, this.alto = 150});
  final List<LatLng> vertices;
  final double alto;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: alto,
      width: double.infinity,
      child: CustomPaint(
        painter: _PintorPlano(
          vertices: vertices,
          fondo: context.esquemaZunbeltz.brightness == Brightness.dark
              ? const Color(0xFF1E3329)
              : const Color(0xFFDCE8DA),
          relleno: colorMusgoZunbeltz.withValues(alpha: 0.75),
          borde: context.esquemaZunbeltz.brightness == Brightness.dark
              ? colorMusgoZunbeltz
              : colorMonteZunbeltz,
        ),
      ),
    );
  }
}

class _PintorPlano extends CustomPainter {
  _PintorPlano({
    required this.vertices,
    required this.fondo,
    required this.relleno,
    required this.borde,
  });

  final List<LatLng> vertices;
  final Color fondo;
  final Color relleno;
  final Color borde;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = fondo);
    if (vertices.length < 3) return;
    // Proyección local: la longitud se encoge con el coseno de la latitud.
    final latitudMedia =
        vertices.map((v) => v.latitude).reduce((a, b) => a + b) /
            vertices.length;
    final factor = math.cos(latitudMedia * math.pi / 180);
    final puntos = [
      for (final v in vertices) Offset(v.longitude * factor, -v.latitude)
    ];
    final minX = puntos.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
    final maxX = puntos.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
    final minY = puntos.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
    final maxY = puntos.map((p) => p.dy).reduce((a, b) => a > b ? a : b);
    const margen = 20.0;
    final ancho = (maxX - minX).abs();
    final altoPlano = (maxY - minY).abs();
    if (ancho == 0 || altoPlano == 0) return;
    final escala = [
      (size.width - 2 * margen) / ancho,
      (size.height - 2 * margen) / altoPlano,
    ].reduce((a, b) => a < b ? a : b);
    final desplazamiento = Offset(
      (size.width - ancho * escala) / 2,
      (size.height - altoPlano * escala) / 2,
    );
    final camino = Path();
    for (var indice = 0; indice < puntos.length; indice++) {
      final punto = Offset((puntos[indice].dx - minX) * escala,
              (puntos[indice].dy - minY) * escala) +
          desplazamiento;
      indice == 0
          ? camino.moveTo(punto.dx, punto.dy)
          : camino.lineTo(punto.dx, punto.dy);
    }
    camino.close();
    canvas.drawPath(camino, Paint()..color = relleno);
    canvas.drawPath(
        camino,
        Paint()
          ..color = borde
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(_PintorPlano viejo) =>
      viejo.vertices != vertices || viejo.fondo != fondo;
}

/// Un rebaño en la lista de Ganado (pantalla 09): especie, nombre, de quién
/// es y cabezas; dónde está y desde cuándo, con «Mover»; y sus chips de
/// estado sanitario.
class TarjetaRebano extends StatelessWidget {
  const TarjetaRebano({
    super.key,
    required this.resumen,
    required this.animales,
    required this.eventos,
    required this.nombresPieza,
    required this.ahora,
    required this.alAbrir,
    required this.alMover,
  });

  final ResumenLote resumen;
  final List<Animal> animales;
  final List<EventoGanado> eventos;
  final Map<int, String> nombresPieza;
  final DateTime ahora;
  final VoidCallback alAbrir;
  final VoidCallback? alMover;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final lote = resumen.lote;
    final apagado =
        estilos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant);
    final conCrotal = animales
        .where((animal) => animal.activo && animal.identificacion.isNotEmpty)
        .length;
    final chips = chipsEstadoRebano(context, lote, eventos, ahora);
    return Material(
      color: esquema.surfaceContainerLow,
      borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alAbrir,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                AvatarEspecie(especie: lote.especie),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          lote.nombre.isEmpty
                              ? etiquetaEspecie(lote.especie, idioma)
                              : lote.nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: estilos.titleLarge),
                      Text(
                          [
                            if (lote.especie.isNotEmpty)
                              etiquetaEspecie(lote.especie, idioma),
                            titularCorto(lote, textos),
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: apagado),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${resumen.cabezas}',
                      style: estilos.headlineMedium?.copyWith(
                          fontFamily: familiaTextoZunbeltz,
                          fontWeight: FontWeight.w700)),
                  Text(textos.ganRotuloCabezas(resumen.cabezas),
                      style: apagado),
                ]),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                decoration: BoxDecoration(
                  color: esquema.surface,
                  borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
                ),
                child: Row(children: [
                  Icon(Icons.place_outlined, color: esquema.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            dondeEstaRebano(
                                resumen.ultimoMovimiento, nombresPieza, textos),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: estilos.titleMedium),
                        Text(
                            [
                              if (resumen.ultimoMovimiento != null)
                                textos.ganDesdeElDia(DateFormat('d MMM', idioma)
                                    .format(DateTime.fromMillisecondsSinceEpoch(
                                        resumen.ultimoMovimiento!.fechaMs))),
                              conCrotal > 0
                                  ? textos.ganConCrotalN(conCrotal)
                                  : textos.ganSinCrotal,
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: estilos.bodySmall
                                ?.copyWith(color: esquema.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (alMover != null)
                    FilledButton.tonalIcon(
                      style: estiloBotonTonalZunbeltz,
                      onPressed: alMover,
                      icon: const Icon(Icons.moving, size: 18),
                      label: Text(textos.ganMover),
                    ),
                ]),
              ),
              if (chips.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: chips),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// «del espacio» o «de Ane».
String titularCorto(LoteGanado lote, AppLocalizations textos) {
  if (lote.titularUid.isEmpty) return textos.ganDelEspacio;
  final nombre = personasEspacio.value
      .where((persona) => persona.uid == lote.titularUid)
      .firstOrNull
      ?.nombre;
  return nombre == null ? textos.ganDelEspacio : textos.ganDePersona(nombre);
}

/// La pieza donde está, «Fuera: la sierra» o «Sin ubicar».
String dondeEstaRebano(MovimientoGanado? ultimo, Map<int, String> nombresPieza,
    AppLocalizations textos) {
  if (ultimo == null) return textos.ganSinUbicar;
  if (ultimo.esSalida) {
    return textos.ganFueraCorto(
        ultimo.destinoExterno.isEmpty ? '—' : ultimo.destinoExterno);
  }
  final nombre = nombresPieza[ultimo.zonaDestinoId];
  return nombre == null || nombre.isEmpty ? textos.ganSinUbicar : nombre;
}

/// Cabecera de «Mover un rebaño»: la pieza donde está y la de destino
/// dibujadas a escala (sin teselas: funciona sin cobertura), con una flecha
/// de una a otra y sus nombres en píldoras. Si falta una de las dos, se
/// dibuja la otra sola.
class PlanoMovimiento extends StatelessWidget {
  const PlanoMovimiento({
    super.key,
    this.origen = const [],
    this.destino = const [],
    this.rotuloOrigen,
    this.rotuloDestino,
    this.alto = 200,
  });

  final List<LatLng> origen;
  final List<LatLng> destino;
  final String? rotuloOrigen;
  final String? rotuloDestino;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final oscuro = context.esquemaZunbeltz.brightness == Brightness.dark;
    final estilo = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(fontWeight: FontWeight.w600);
    Widget pildora(String texto, Color fondo, Color tinta) => Container(
          constraints: const BoxConstraints(maxWidth: 220),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: fondo, borderRadius: BorderRadius.circular(8)),
          child: Text(texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: estilo?.copyWith(color: tinta)),
        );
    return SizedBox(
      height: alto,
      width: double.infinity,
      child: Stack(children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _PintorMovimiento(
              origen: origen,
              destino: destino,
              fondo: oscuro ? const Color(0xFF1E3329) : const Color(0xFFDCE8DA),
              rellenoOrigen:
                  oscuro ? const Color(0x33FFFFFF) : const Color(0xE6F4F5F2),
              bordeOrigen:
                  oscuro ? const Color(0xFFB8C4BC) : const Color(0xFF3F4945),
              rellenoDestino: colorMusgoZunbeltz.withValues(alpha: 0.75),
              bordeDestino: oscuro ? colorMusgoZunbeltz : colorMonteZunbeltz,
            ),
          ),
        ),
        if (rotuloOrigen != null)
          Positioned(
            left: 12,
            bottom: 12,
            child: pildora(rotuloOrigen!, Colors.white, colorSobreCuadroClaro),
          ),
        if (rotuloDestino != null)
          Positioned(
            right: 12,
            bottom: rotuloOrigen == null ? 12 : 48,
            child: pildora(rotuloDestino!, colorMonteZunbeltz, Colors.white),
          ),
      ]),
    );
  }
}

class _PintorMovimiento extends CustomPainter {
  _PintorMovimiento({
    required this.origen,
    required this.destino,
    required this.fondo,
    required this.rellenoOrigen,
    required this.bordeOrigen,
    required this.rellenoDestino,
    required this.bordeDestino,
  });

  final List<LatLng> origen;
  final List<LatLng> destino;
  final Color fondo;
  final Color rellenoOrigen;
  final Color bordeOrigen;
  final Color rellenoDestino;
  final Color bordeDestino;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..color = fondo);
    final hayOrigen = origen.length >= 3;
    final hayDestino = destino.length >= 3;
    if (!hayOrigen && !hayDestino) return;
    final todos = [if (hayOrigen) ...origen, if (hayDestino) ...destino];
    // Proyección local común a las dos piezas.
    final latitudMedia =
        todos.map((v) => v.latitude).reduce((a, b) => a + b) / todos.length;
    final factor = math.cos(latitudMedia * math.pi / 180);
    Offset proyectar(LatLng v) => Offset(v.longitude * factor, -v.latitude);
    Rect caja(List<LatLng> vertices) {
      final puntos = vertices.map(proyectar).toList();
      return Rect.fromLTRB(
        puntos.map((p) => p.dx).reduce(math.min),
        puntos.map((p) => p.dy).reduce(math.min),
        puntos.map((p) => p.dx).reduce(math.max),
        puntos.map((p) => p.dy).reduce(math.max),
      );
    }

    // Se encuadra el destino. El origen entra en el encuadre salvo que sea
    // mucho mayor (una parcela catastral entera frente a una pieza): entonces
    // se ve solo su trozo cercano y la flecha sale del borde.
    var encuadre = caja(hayDestino ? destino : origen);
    if (hayOrigen && hayDestino) {
      final cajaOrigen = caja(origen);
      final unidas = encuadre.expandToInclude(cajaOrigen);
      final crecimiento = math.max(
          unidas.width / encuadre.width, unidas.height / encuadre.height);
      encuadre = crecimiento <= 6
          ? unidas
          : Rect.fromCenter(
              center: encuadre.center,
              width: encuadre.width * 3,
              height: encuadre.height * 3);
    }
    const margen = 28.0;
    if (encuadre.width == 0 || encuadre.height == 0) return;
    final escala = math.min((size.width - 2 * margen) / encuadre.width,
        (size.height - 2 * margen) / encuadre.height);
    final desplazamiento = Offset((size.width - encuadre.width * escala) / 2,
        (size.height - encuadre.height * escala) / 2);
    Offset enPantalla(LatLng v) {
      final p = proyectar(v);
      return Offset(
              (p.dx - encuadre.left) * escala, (p.dy - encuadre.top) * escala) +
          desplazamiento;
    }

    Path camino(List<LatLng> vertices) {
      final puntos = vertices.map(enPantalla).toList();
      return Path()..addPolygon(puntos, true);
    }

    Offset centro(List<LatLng> vertices) {
      final puntos = vertices.map(enPantalla).toList();
      return puntos.reduce((a, b) => a + b) / puntos.length.toDouble();
    }

    if (origen.length >= 3) {
      final trazo = camino(origen);
      canvas.drawPath(trazo, Paint()..color = rellenoOrigen);
      canvas.drawPath(
          trazo,
          Paint()
            ..color = bordeOrigen
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..strokeJoin = StrokeJoin.round);
    }
    if (destino.length >= 3) {
      final trazo = camino(destino);
      canvas.drawPath(trazo, Paint()..color = rellenoDestino);
      canvas.drawPath(
          trazo,
          Paint()
            ..color = bordeDestino
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeJoin = StrokeJoin.round);
    }
    if (origen.length >= 3 && destino.length >= 3) {
      final hasta = centro(destino);
      // Un centro fuera del encuadre se acerca hasta el borde.
      final dentro = (Offset.zero & size).deflate(margen);
      final centroOrigen = centro(origen);
      final desde = dentro.contains(centroOrigen)
          ? centroOrigen
          : Offset(centroOrigen.dx.clamp(dentro.left, dentro.right),
              centroOrigen.dy.clamp(dentro.top, dentro.bottom));
      final distancia = (hasta - desde).distance;
      if (distancia < 24) return;
      // Curva hacia arriba, recortada para no tapar los centros.
      final direccion = (hasta - desde) / distancia;
      final inicio = desde + direccion * math.min(16, distancia * 0.15);
      final fin = hasta - direccion * math.min(16, distancia * 0.15);
      final normal = Offset(direccion.dy, -direccion.dx);
      final control = (inicio + fin) / 2 +
          normal * (normal.dy <= 0 ? 1 : -1) * distancia * 0.3;
      final flecha = Path()
        ..moveTo(inicio.dx, inicio.dy)
        ..quadraticBezierTo(control.dx, control.dy, fin.dx, fin.dy);
      final pincel = Paint()
        ..color = bordeDestino
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(flecha, pincel);
      final tangente = fin - control;
      final angulo = math.atan2(tangente.dy, tangente.dx);
      const largo = 14.0;
      for (final giro in [math.pi * 0.8, -math.pi * 0.8]) {
        canvas.drawLine(
            fin,
            fin +
                Offset(math.cos(angulo + giro), math.sin(angulo + giro)) *
                    largo,
            pincel);
      }
    }
  }

  @override
  bool shouldRepaint(_PintorMovimiento viejo) =>
      viejo.origen != origen ||
      viejo.destino != destino ||
      viejo.fondo != fondo;
}
