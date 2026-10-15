import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../branding.dart';
import '../modelos/constantes.dart';
import '../modelos/zona_finca.dart';

/// Valores de [coloresZona].
const Map<String, Color> paletaZonas = {
  'amarillo': Color(0xFFFFD400),
  'naranja': Color(0xFFFF7A00),
  'rojo': Color(0xFFE5262B),
  'magenta': Color(0xFFE040FB),
  'violeta': Color(0xFF8E44FF),
  'azul': Color(0xFF1E88E5),
  'cian': Color(0xFF00D4E8),
  'blanco': Color(0xFFFFFFFF),
};

/// Color de una zona en el mapa: el elegido o, si no hay, el de su tipo.
Color colorDeZona(ZonaFinca zona) =>
    paletaZonas[zona.color] ??
    paletaZonas[colorPorTipoZona[zona.tipo]] ??
    paletaZonas['blanco']!;

/// El estado de una zona se lee en su borde: continuo en uso, a trazos en
/// descanso y de puntos si está vedada.
StrokePattern patronEstadoZona(String estado) => switch (estado) {
      'descanso' => StrokePattern.dashed(segments: const [14, 8]),
      'vedada' => const StrokePattern.dotted(spacingFactor: 2),
      _ => const StrokePattern.solid(),
    };

/// Color del estado de una tarea (coherente con la leyenda de la
/// presentación: pendiente = ocre, en curso = niebla, hecha = musgo,
/// bloqueada = terracota).
Color colorEstadoTarea(String codigo) {
  switch (codigo) {
    case 'en_curso':
      return colorEstadoEnCurso;
    case 'hecha':
      return colorEstadoHecha;
    case 'bloqueada':
      return colorEstadoBloqueada;
    default:
      return colorEstadoPendiente;
  }
}

/// Color del estado de conservación de un punto (operativo = musgo,
/// revisar = ocre, averiado = terracota).
Color colorEstadoPunto(String codigo) {
  switch (codigo) {
    case 'revisar':
      return colorEstadoPendiente;
    case 'averiado':
      return colorEstadoBloqueada;
    default:
      return colorEstadoHecha;
  }
}

/// Color del estado de uso de una zona (en uso = pasto, en descanso =
/// musgo, vedada = terracota). Se usa a baja opacidad para el relleno del
/// polígono y entero para su borde.
Color colorEstadoZona(String codigo) {
  switch (codigo) {
    case 'descanso':
      return colorEstadoPendiente;
    case 'vedada':
      return colorEstadoBloqueada;
    default:
      return colorPastoZunbeltz;
  }
}
