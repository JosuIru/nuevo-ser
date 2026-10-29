import 'package:flutter/material.dart';

/// Paleta y assets de Larrea Aceitera. Consolidados en un único punto
/// para que el ilustrador de F1-A10 (branding visual definitivo) pueda
/// sustituirlos sin tocar el árbol de widgets.
///
/// La paleta sigue el patrón de la suite Larrea (color principal +
/// crema cálida) — verde oliva oscuro evita la colisión con el verde
/// hoja del arbolado urbano y con el burdeos de viticultura.

/// Verde oliva oscuro — color principal del branding aceitera.
const Color colorPrimarioAceitera = Color(0xFF5C6B3A);

/// Verde oliva más claro — para hover y acentos secundarios.
const Color colorSecundarioAceitera = Color(0xFF7A8A4D);

/// Crema cálida — fondo principal de la app (papel de cuaderno antiguo).
const Color colorCremaAceitera = Color(0xFFF5EFE2);

/// Verde oliva muy oscuro — para texto sobre fondo crema y para el
/// tronco/rama del logo.
const Color colorPrimarioOscuroAceitera = Color(0xFF3A4623);

/// Logo placeholder (1024×1024). Se sustituye en F1-A10 por el activo
/// del ilustrador.
const String rutaLogoAceitera = 'assets/icono-logo-aceitera.png';
