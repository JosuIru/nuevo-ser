import 'package:flutter/material.dart';

/// Verde de monte sobre fondo claro. Letra algo más grande de lo normal:
/// mucha gente de los pueblos usará la app con gafas de cerca o sin ellas.
ThemeData temaConcejo(Brightness brillo) {
  final colores = ColorScheme.fromSeed(
    seedColor: const Color(0xFF3E6B48),
    brightness: brillo,
  );
  final base = ThemeData(colorScheme: colores, useMaterial3: true);
  return base.copyWith(
    // Tamaños de la geometría de Material 2021 y colores del esquema. Ojo:
    // `merge` con la geometría sola borraba los colores (sus estilos no
    // heredan) y el texto salía blanco sobre fondo claro en Android.
    textTheme: Typography.englishLike2021
        .apply(fontSizeFactor: 1.08)
        .apply(bodyColor: colores.onSurface, displayColor: colores.onSurface),
    cardTheme: const CardThemeData(margin: EdgeInsets.symmetric(vertical: 6)),
  );
}

/// Color de cada columna del debate, coherente en claro y oscuro.
Color colorDeColumna(ColorScheme colores, int indice) => switch (indice) {
      0 => colores.primary,
      1 => colores.error,
      2 => colores.tertiary,
      _ => colores.secondary,
    };
