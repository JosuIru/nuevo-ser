import 'package:flutter/material.dart';

import '../branding.dart';

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
