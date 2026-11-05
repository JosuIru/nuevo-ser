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

/// Color del estado de una tarea (roles `pending`, `progress`, `done` y
/// `blocked` del rediseño).
Color colorEstadoTarea(String codigo,
    [ColoresZunbeltz colores = ColoresZunbeltz.claro]) {
  switch (codigo) {
    case 'en_curso':
      return colores.enCurso;
    case 'hecha':
      return colores.hecha;
    case 'bloqueada':
      return colores.bloqueada;
    default:
      return colores.pendiente;
  }
}

/// Color del estado de conservación de un punto (operativo = musgo,
/// revisar = ocre, averiado = terracota).
Color colorEstadoPunto(String codigo,
    [ColoresZunbeltz colores = ColoresZunbeltz.claro]) {
  switch (codigo) {
    case 'revisar':
      return colores.pendiente;
    case 'averiado':
      return colores.bloqueada;
    default:
      return colores.hecha;
  }
}

/// Color del estado de uso de una zona (en uso = pasto, en descanso =
/// musgo, vedada = terracota). Se usa a baja opacidad para el relleno del
/// polígono y entero para su borde.
Color colorEstadoZona(String codigo,
    [ColoresZunbeltz colores = ColoresZunbeltz.claro]) {
  switch (codigo) {
    case 'descanso':
      return colores.pendiente;
    case 'vedada':
      return colores.bloqueada;
    default:
      return colores.hecha;
  }
}

/// Icono de cada tipo de punto de infraestructura, para el mapa.
IconData iconoTipoPunto(String tipo) => switch (tipo) {
      'abrevadero' || 'bebedero_movil' => Icons.water_drop_outlined,
      'balsa' || 'deposito_movil' => Icons.waves_outlined,
      'manga' || 'cargadero' => Icons.swap_horiz,
      'cierre' || 'pastor_electrico' => Icons.fence_outlined,
      'refugio' || 'vestuario' => Icons.cabin_outlined,
      'cuadra' || 'aprisco' => Icons.warehouse_outlined,
      'almacen' || 'isotermo' => Icons.inventory_2_outlined,
      'comedero' => Icons.grass_outlined,
      'parcela' => Icons.crop_square,
      'corral_movil' => Icons.grid_on,
      'placas_solares' => Icons.solar_power_outlined,
      'molino' => Icons.wind_power_outlined,
      'puerta' => Icons.door_front_door_outlined,
      _ => Icons.place_outlined,
    };
