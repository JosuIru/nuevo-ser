import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../datos/dibujos_taller.dart';
import '../../dominio/bestiario.dart';
import '../../dominio/catalogo_distritos.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../dominio/personajes_taller.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';

/// Un dibujo colgado en la pared: la imagen y qué es.
class DibujoColgado {
  final String ruta;
  final String nombre;

  /// Qué parte es, si hace falta (el fondo de una máquina: «por dentro»).
  final String? detalle;

  const DibujoColgado(this.ruta, this.nombre, {this.detalle});
}

/// Todos los dibujos del niño (las cuatro colecciones del taller), con
/// el nombre de lo que representan, en castellano.
List<DibujoColgado> dibujosColgados() {
  String nombreDe(ColeccionDibujos coleccion, String id) {
    if (identical(coleccion, dibujosMonstruos)) {
      return CatalogoBestiario.todas.firstWhere((f) => f.id == id).nombre;
    }
    if (identical(coleccion, dibujosPersonajes)) {
      return personajesDelTaller.firstWhere((p) => p.id == id).voz.nombreVisible;
    }
    if (identical(coleccion, dibujosDistritos)) {
      return CatalogoDistritos.todos.firstWhere((d) => d.identificador == id).nombre;
    }
    return CatalogoMinijuegos.todos.firstWhere((m) => m.id.name == id).nombre;
  }

  return [
    for (final coleccion in coleccionesDelTaller)
      for (final MapEntry(key: id, value: ruta) in coleccion.rutas.value.entries)
        DibujoColgado(ruta, nombreDe(coleccion, id),
            detalle: identical(coleccion, dibujosFondos) ? 'por dentro' : null),
  ];
}

/// La pared de Rexán (El taller de dibujo, fase 4): en los recreativos,
/// todo lo que el niño ha dibujado, colgado como carteles con cinta. Sin
/// puntos ni orden de mérito: una pared, como la de una clase.
class PantallaPared extends StatelessWidget {
  const PantallaPared({super.key});

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    return Scaffold(
      backgroundColor: const Color(0xFF1B1530),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([for (final coleccion in coleccionesDelTaller) coleccion.rutas]),
          builder: (_, __) {
            final dibujos = dibujosColgados();
            return CustomPaint(
              painter: _PintorPared(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 10, 16, 24),
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: PaletaNeon.textoTenue, size: 20),
                        onPressed: () => Navigator.of(contexto).pop(),
                      ),
                      Expanded(
                        child: Text(
                          traducirNarrativa('La pared de Rexán', locale).toUpperCase(),
                          style: const TextStyle(
                              color: PaletaNeon.textoPrincipal, fontSize: 15, fontWeight: FontWeight.w300, letterSpacing: 3),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 0, 18),
                    child: Text(
                      '“${traducirNarrativa(dibujos.isEmpty ? 'Aquí cuelgo lo que me traes. De momento está vacía: los monstruos se dibujan en el bestiario, y el resto en Mi cuaderno, en el taller.' : 'Aquí cuelgo lo que me traes. Es la mejor pared de los recreativos.', locale)}”\n— Rexán',
                      style: TextStyle(
                          color: PaletaNeon.textoTenue.withOpacity(0.85), fontSize: 13, height: 1.5, fontStyle: FontStyle.italic),
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 14,
                    runSpacing: 18,
                    children: [
                      for (final dibujo in dibujos)
                        _Cartel(
                          key: ValueKey('cartel-${dibujo.ruta}'),
                          dibujo: dibujo,
                          nombre: [
                            traducirNarrativa(dibujo.nombre, locale),
                            if (dibujo.detalle != null) traducirNarrativa(dibujo.detalle!, locale),
                          ].join(' · '),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Un cartel: papel, cinta arriba, el dibujo y su nombre a lápiz. Un poco
/// torcido, siempre igual para el mismo dibujo.
class _Cartel extends StatelessWidget {
  final DibujoColgado dibujo;
  final String nombre;

  const _Cartel({super.key, required this.dibujo, required this.nombre});

  @override
  Widget build(BuildContext contexto) {
    final giro = (math.Random(dibujo.ruta.hashCode).nextDouble() - 0.5) * 0.12;
    return GestureDetector(
      onTap: () => showDialog<void>(
        context: contexto,
        builder: (_) => Dialog(
          backgroundColor: const Color(0xFFF1E9D6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(File(dibujo.ruta), fit: BoxFit.contain),
                const SizedBox(height: 10),
                Text(nombre, style: const TextStyle(color: Color(0xFF3A3040), fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
      child: Transform.rotate(
        angle: giro,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: 140,
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1E9D6),
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(2, 4))],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 130,
                    child: Image.file(File(dibujo.ruta), fit: BoxFit.contain, gaplessPlayback: true),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    nombre,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(color: Color(0xFF3A3040), fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            // La cinta.
            Positioned(
              top: -8,
              child: Transform.rotate(
                angle: -giro * 2,
                child: Container(width: 48, height: 16, color: const Color(0xFFE8D9A8).withOpacity(0.85)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pared de ladrillo en penumbra, con la luz de un neón arriba.
class _PintorPared extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const alto = 22.0;
    const ancho = 54.0;
    final junta = Paint()
      ..color = const Color(0xFF120E22)
      ..strokeWidth = 2;
    for (var fila = 0; fila * alto < size.height; fila++) {
      final y = fila * alto;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), junta);
      final desfase = fila.isEven ? 0.0 : ancho / 2;
      for (var x = desfase; x < size.width; x += ancho) {
        canvas.drawLine(Offset(x, y), Offset(x, y + alto), junta);
      }
    }
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -1),
          radius: 1.2,
          colors: [PaletaNeon.violetaNeon.withOpacity(0.18), Colors.transparent],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_PintorPared anterior) => false;
}
