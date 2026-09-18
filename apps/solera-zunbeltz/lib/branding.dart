import 'package:flutter/material.dart';

/// Paleta, tipografía y tema de Solera Zunbeltz. Consolidados en un único
/// punto para que el ilustrador pueda sustituirlos sin tocar el árbol de
/// widgets.
///
/// La dirección visual replica la de la presentación
/// (`presentacion/index.html`), revisada en 2026-09-14: papel de plano
/// catastral (gris-verde frío) + verde monte, con el rojo de marcaje del
/// ganado como único acento, usado con cuentagotas. Tipografía invertida
/// respecto a la convención: grotesca (Archivo) en los títulos y serif de
/// lectura (Spectral) en el texto corrido.
///
/// Ver la sección "Dirección visual" de `CLAUDE.md`.

/// Papel de plano catastral — fondo principal de la app. Gris-verde frío,
/// no crema cálido.
const Color colorPapelZunbeltz = Color(0xFFE9EBE2);

/// Papel hundido — superficies elevadas, cabeceras y campos de formulario.
const Color colorPapelHundidoZunbeltz = Color(0xFFDFE2D6);

/// Verde monte profundo — color principal del branding Zunbeltz.
const Color colorMonteZunbeltz = Color(0xFF1B2320);

/// Rojo de marcaje del ganado — el único acento. Se reserva para lo que
/// de verdad reclama atención: tareas pendientes, avisos, la acción
/// principal de una pantalla.
const Color colorSenalZunbeltz = Color(0xFFB8402A);

/// Verde pasto — acento secundario sobre fondo claro (lo hecho, lo validado).
const Color colorPastoZunbeltz = Color(0xFF5E7D3A);

/// Musgo — verde suave para superficies y chips.
const Color colorMusgoZunbeltz = Color(0xFF8AA66B);

/// Tinta — texto sobre papel.
const Color colorTintaZunbeltz = Color(0xFF171D19);

/// Tinta apagada — texto secundario y metadatos.
const Color colorTintaApagadaZunbeltz = Color(0xFF6C7870);

/// Línea — bordes finos. Sustituyen a las sombras: en esta dirección visual
/// las superficies se separan por trazo, no por elevación.
const Color colorLineaZunbeltz = Color(0x2B1B2320);

/// Colores de estado de las tareas de mantenimiento (coherentes con la
/// leyenda de la presentación: pendiente = señal, en curso = niebla,
/// hecha = pasto, bloqueada = terracota).
const Color colorEstadoPendiente = colorSenalZunbeltz;
const Color colorEstadoEnCurso = Color(0xFF4B7488);
const Color colorEstadoHecha = colorPastoZunbeltz;
const Color colorEstadoBloqueada = Color(0xFFB05E3B);

/// Familia de los títulos: grotesca, empaquetada en `assets/fuentes`.
const String familiaTitularZunbeltz = 'Archivo';

/// Familia del texto corrido: serif de lectura, empaquetada en la app.
const String familiaTextoZunbeltz = 'Spectral';

/// Logo placeholder. Lo sustituye el ilustrador cuando entregue el activo
/// definitivo (ver BLOQUEOS-PENDIENTES, branding visual).
const String rutaLogoZunbeltz = 'assets/icono-logo-zunbeltz.png';

/// Radio de las esquinas. Corto y constante: es papel, no tarjeta de app.
const double radioZunbeltz = 4;

const BorderRadius _bordeRedondeado = BorderRadius.all(
  Radius.circular(radioZunbeltz),
);

/// Tema de la app. Se construye el [ColorScheme] a mano en vez de derivarlo
/// con `fromSeed` para no heredar los tonos por defecto de Material 3.
ThemeData temaZunbeltz() {
  const esquema = ColorScheme(
    brightness: Brightness.light,
    primary: colorMonteZunbeltz,
    onPrimary: colorPapelZunbeltz,
    primaryContainer: colorPapelHundidoZunbeltz,
    onPrimaryContainer: colorMonteZunbeltz,
    secondary: colorPastoZunbeltz,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFCBD6B6),
    onSecondaryContainer: Color(0xFF25331A),
    tertiary: colorSenalZunbeltz,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFF0CFC7),
    onTertiaryContainer: Color(0xFF5C1A0E),
    error: colorSenalZunbeltz,
    onError: Colors.white,
    surface: colorPapelZunbeltz,
    onSurface: colorTintaZunbeltz,
    surfaceContainerHighest: colorPapelHundidoZunbeltz,
    onSurfaceVariant: colorTintaApagadaZunbeltz,
    outline: colorTintaApagadaZunbeltz,
    outlineVariant: colorLineaZunbeltz,
  );

  final textoBase = _textoZunbeltz();

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: colorPapelZunbeltz,
    textTheme: textoBase,
    fontFamily: familiaTextoZunbeltz,
    dividerColor: colorLineaZunbeltz,
    dividerTheme: const DividerThemeData(
      color: colorLineaZunbeltz,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorPapelZunbeltz,
      foregroundColor: colorMonteZunbeltz,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      shape: const Border(
        bottom: BorderSide(color: colorLineaZunbeltz, width: 1),
      ),
      titleTextStyle: textoBase.titleLarge,
    ),
    cardTheme: const CardThemeData(
      color: colorPapelZunbeltz,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: _bordeRedondeado,
        side: BorderSide(color: colorLineaZunbeltz),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: colorTintaApagadaZunbeltz,
      shape: RoundedRectangleBorder(borderRadius: _bordeRedondeado),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorMonteZunbeltz,
        foregroundColor: colorPapelZunbeltz,
        textStyle: _estiloBoton(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: const RoundedRectangleBorder(borderRadius: _bordeRedondeado),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorMonteZunbeltz,
        foregroundColor: colorPapelZunbeltz,
        elevation: 0,
        textStyle: _estiloBoton(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: const RoundedRectangleBorder(borderRadius: _bordeRedondeado),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorMonteZunbeltz,
        textStyle: _estiloBoton(),
        side: const BorderSide(color: colorTintaApagadaZunbeltz),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: const RoundedRectangleBorder(borderRadius: _bordeRedondeado),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorMonteZunbeltz,
        textStyle: _estiloBoton(),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: colorSenalZunbeltz,
      foregroundColor: Colors.white,
      elevation: 1,
      focusElevation: 1,
      hoverElevation: 2,
      highlightElevation: 2,
      shape: RoundedRectangleBorder(borderRadius: _bordeRedondeado),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorPapelHundidoZunbeltz,
      selectedColor: colorMusgoZunbeltz,
      side: const BorderSide(color: colorLineaZunbeltz),
      labelStyle: TextStyle(
        fontFamily: familiaTitularZunbeltz,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colorTintaZunbeltz,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorPapelHundidoZunbeltz,
      border: _bordeCampo(colorLineaZunbeltz),
      enabledBorder: _bordeCampo(colorLineaZunbeltz),
      focusedBorder: _bordeCampo(colorMonteZunbeltz, grosor: 2),
      errorBorder: _bordeCampo(colorSenalZunbeltz),
      focusedErrorBorder: _bordeCampo(colorSenalZunbeltz, grosor: 2),
      labelStyle: const TextStyle(
        fontFamily: familiaTitularZunbeltz,
        fontSize: 14,
        color: colorTintaApagadaZunbeltz,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: colorMonteZunbeltz,
      unselectedLabelColor: colorTintaApagadaZunbeltz,
      indicatorColor: colorSenalZunbeltz,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: colorLineaZunbeltz,
      labelStyle: _estiloBoton(),
      unselectedLabelStyle: _estiloBoton(peso: FontWeight.w400),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorPapelZunbeltz,
      surfaceTintColor: Colors.transparent,
      indicatorColor: colorPapelHundidoZunbeltz,
      elevation: 0,
      indicatorShape: const RoundedRectangleBorder(
        borderRadius: _bordeRedondeado,
      ),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontFamily: familiaTitularZunbeltz,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: colorMonteZunbeltz,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorMonteZunbeltz,
      contentTextStyle: TextStyle(
        fontFamily: familiaTextoZunbeltz,
        fontSize: 15,
        color: colorPapelZunbeltz,
      ),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: _bordeRedondeado),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorPapelZunbeltz,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: _bordeRedondeado,
        side: BorderSide(color: colorLineaZunbeltz),
      ),
      titleTextStyle: textoBase.titleLarge,
      contentTextStyle: textoBase.bodyMedium,
    ),
  );
}

OutlineInputBorder _bordeCampo(Color color, {double grosor = 1}) {
  return OutlineInputBorder(
    borderRadius: _bordeRedondeado,
    borderSide: BorderSide(color: color, width: grosor),
  );
}

TextStyle _estiloBoton({FontWeight peso = FontWeight.w600}) {
  return TextStyle(
    fontFamily: familiaTitularZunbeltz,
    fontSize: 15,
    fontWeight: peso,
    letterSpacing: 0,
  );
}

/// Escala tipográfica: títulos en grotesca con tracking cerrado, texto
/// corrido en serif con más interlínea de la que trae Material por defecto.
TextTheme _textoZunbeltz() {
  TextStyle titulo(double tamano, {FontWeight peso = FontWeight.w600}) {
    return TextStyle(
      fontFamily: familiaTitularZunbeltz,
      fontSize: tamano,
      fontWeight: peso,
      letterSpacing: -0.4,
      height: 1.14,
      color: colorMonteZunbeltz,
    );
  }

  TextStyle texto(double tamano, {Color color = colorTintaZunbeltz}) {
    return TextStyle(
      fontFamily: familiaTextoZunbeltz,
      fontSize: tamano,
      height: 1.5,
      color: color,
    );
  }

  TextStyle etiqueta(double tamano, {Color color = colorTintaZunbeltz}) {
    return TextStyle(
      fontFamily: familiaTitularZunbeltz,
      fontSize: tamano,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: color,
    );
  }

  return TextTheme(
    displayLarge: titulo(40),
    displayMedium: titulo(34),
    displaySmall: titulo(29),
    headlineLarge: titulo(26),
    headlineMedium: titulo(23),
    headlineSmall: titulo(20),
    titleLarge: titulo(19),
    titleMedium: titulo(17),
    titleSmall: titulo(15),
    bodyLarge: texto(17),
    bodyMedium: texto(15.5),
    bodySmall: texto(13.5, color: colorTintaApagadaZunbeltz),
    labelLarge: etiqueta(15),
    labelMedium: etiqueta(13),
    labelSmall: etiqueta(12, color: colorTintaApagadaZunbeltz),
  );
}
