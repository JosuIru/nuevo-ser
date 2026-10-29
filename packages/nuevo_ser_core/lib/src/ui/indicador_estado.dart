import 'package:flutter/material.dart';

/// Indicador de estado coloreado con icono.
/// Reutilizable en todas las apps Larrea para mostrar estados de
/// lotes, plantas, colmenas, árboles, etc.
///
/// Uso:
/// ```dart
/// IndicadorEstado(
///   estado: 'fresca',
///   map: {
///     'fresca': IndicadorEstilo(Colors.blue, Icons.water_drop, 'Fresca'),
///     'lista': IndicadorEstilo(Colors.green, Icons.check, 'Lista'),
///   },
/// )
/// ```
class IndicadorEstilo {
  final Color color;
  final IconData icono;
  final String etiqueta;

  const IndicadorEstilo(this.color, this.icono, this.etiqueta);
}

class IndicadorEstado extends StatelessWidget {
  final String estado;
  final Map<String, IndicadorEstilo> map;
  final double tamano;

  const IndicadorEstado({
    super.key,
    required this.estado,
    required this.map,
    this.tamano = 32,
  });

  @override
  Widget build(BuildContext context) {
    final estilo = map[estado];
    if (estilo == null) {
      return CircleAvatar(
        radius: tamano / 2,
        child: Icon(Icons.help_outline, size: tamano * 0.6),
      );
    }
    return CircleAvatar(
      radius: tamano / 2,
      backgroundColor: estilo.color.withAlpha(30),
      child: Icon(estilo.icono, color: estilo.color, size: tamano * 0.6),
    );
  }
}
