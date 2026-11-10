import 'package:flutter/material.dart';

/// Tema común de las apps Larrea (agro y las verticales), sacado del
/// rediseño de Larrea Zunbeltz de noviembre de 2026: la misma estructura
/// (escala tipográfica, formas, temas de cada componente, colores de estado)
/// con la paleta de cada app. Zunbeltz sigue con su `branding.dart` propio.
///
/// Uso, en el `MaterialApp`:
///
/// ```dart
/// theme: temaSolera(paletaQuesera),
/// darkTheme: temaSolera(paletaQuesera, oscuro: true), // si la app lo admite
/// ```
///
/// Letra: Poppins (títulos y cifras) e Inter (lo demás), ambas SIL OFL, en
/// `lib/fuentes/` del core. **No se empaquetan solas** (para no engordar las
/// apps Kids, que dependen del core): cada app que use el tema las declara en
/// su `pubspec.yaml` con rutas `packages/nuevo_ser_core/fuentes/…` (ver
/// apps/solera-quesera/pubspec.yaml). Sin declararlas, sale la letra del
/// sistema y todo lo demás funciona igual.

/// Colores de marca de una app Larrea.
@immutable
class PaletaSolera {
  const PaletaSolera({
    required this.primario,
    required this.crema,
    this.acento,
  });

  /// Color de marca. Se usa tal cual como `primary` en modo claro si el texto
  /// blanco se lee encima (contraste ≥ 4,5); si no (un dorado, un ámbar),
  /// el primario es un tono más oscuro del mismo color.
  final Color primario;

  /// Fondo cálido de la app en modo claro (el «papel» de cada vertical).
  final Color crema;

  /// Color del botón flotante y de la acción principal. Sin él, el
  /// contenedor del primario.
  final Color? acento;
}

/// Familia de títulos y cifras destacadas.
const String familiaTitularSolera = 'Poppins';

/// Familia del texto, etiquetas, controles y datos.
const String familiaTextoSolera = 'Inter';

/// Radio de chips y campos de formulario.
const double radioCampoSolera = 8;

/// Separación vertical entre dos campos de formulario seguidos. Con los
/// bordes outline del tema, la etiqueta flotante sobresale por arriba del
/// campo: con menos hueco casi toca el borde del campo anterior.
const double separacionCamposSolera = 12;

/// Radio de tarjetas y listas agrupadas.
const double radioTarjetaSolera = 16;

/// Bloque destacado: esquinas alternas de 24 y 8 px.
const BorderRadius bordeDestacadoSolera = BorderRadius.only(
  topLeft: Radius.circular(24),
  topRight: Radius.circular(8),
  bottomLeft: Radius.circular(8),
  bottomRight: Radius.circular(24),
);

const BorderRadius _bordeCampo =
    BorderRadius.all(Radius.circular(radioCampoSolera));
const BorderRadius _bordeTarjeta =
    BorderRadius.all(Radius.circular(radioTarjetaSolera));

// ── Colores propios que no están en el ColorScheme ────────────────────────

/// Lo que Material 3 no trae: acento de la acción principal, cabecera de
/// color y estados (pendiente, en curso, hecho, peligro) con su fondo. Se
/// lee con `context.coloresSolera`.
@immutable
class ColoresSolera extends ThemeExtension<ColoresSolera> {
  const ColoresSolera({
    required this.acento,
    required this.sobreAcento,
    required this.cabecera,
    required this.sobreCabecera,
    required this.sobreCabeceraVariante,
    required this.pendiente,
    required this.fondoPendiente,
    required this.enCurso,
    required this.fondoEnCurso,
    required this.hecho,
    required this.fondoHecho,
    required this.peligro,
    required this.fondoPeligro,
  });

  final Color acento;
  final Color sobreAcento;
  final Color cabecera;
  final Color sobreCabecera;
  final Color sobreCabeceraVariante;
  final Color pendiente;
  final Color fondoPendiente;
  final Color enCurso;
  final Color fondoEnCurso;
  final Color hecho;
  final Color fondoHecho;
  final Color peligro;
  final Color fondoPeligro;

  @override
  ColoresSolera copyWith() => this;

  @override
  ColoresSolera lerp(ColoresSolera? otro, double t) {
    if (otro == null) return this;
    Color mezcla(Color a, Color b) => Color.lerp(a, b, t)!;
    return ColoresSolera(
      acento: mezcla(acento, otro.acento),
      sobreAcento: mezcla(sobreAcento, otro.sobreAcento),
      cabecera: mezcla(cabecera, otro.cabecera),
      sobreCabecera: mezcla(sobreCabecera, otro.sobreCabecera),
      sobreCabeceraVariante:
          mezcla(sobreCabeceraVariante, otro.sobreCabeceraVariante),
      pendiente: mezcla(pendiente, otro.pendiente),
      fondoPendiente: mezcla(fondoPendiente, otro.fondoPendiente),
      enCurso: mezcla(enCurso, otro.enCurso),
      fondoEnCurso: mezcla(fondoEnCurso, otro.fondoEnCurso),
      hecho: mezcla(hecho, otro.hecho),
      fondoHecho: mezcla(fondoHecho, otro.fondoHecho),
      peligro: mezcla(peligro, otro.peligro),
      fondoPeligro: mezcla(fondoPeligro, otro.fondoPeligro),
    );
  }
}

extension ColoresSoleraDeContexto on BuildContext {
  /// Colores propios del tema activo. Fuera de [temaSolera], los de un tema
  /// claro hecho con el primario del contexto.
  ColoresSolera get coloresSolera =>
      Theme.of(this).extension<ColoresSolera>() ??
      _coloresPropios(Theme.of(this).colorScheme);
}

// ── Esquema de color ──────────────────────────────────────────────────────

/// Contraste WCAG entre dos colores (1 a 21).
double contrasteEntre(Color a, Color b) {
  final claro = a.computeLuminance();
  final oscuro = b.computeLuminance();
  final mayor = claro > oscuro ? claro : oscuro;
  final menor = claro > oscuro ? oscuro : claro;
  return (mayor + 0.05) / (menor + 0.05);
}

/// El [ColorScheme] de la paleta: tonos de Material 3 a partir del color de
/// marca, con el primario exacto cuando se lee bien, superficies sobre la
/// crema de la app (claro) y sin el tinte de elevación.
ColorScheme esquemaSolera(PaletaSolera paleta, {bool oscuro = false}) {
  final base = ColorScheme.fromSeed(
    seedColor: paleta.primario,
    brightness: oscuro ? Brightness.dark : Brightness.light,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
  if (oscuro) {
    return base.copyWith(surfaceTint: Colors.transparent);
  }
  final primarioLegible =
      contrasteEntre(paleta.primario, Colors.white) >= 4.5;
  // Las superficies, de la crema hacia el color de marca: las tarjetas y la
  // barra de navegación se distinguen del fondo sin sombras.
  Color hacia(double cantidad) =>
      Color.alphaBlend(paleta.primario.withValues(alpha: cantidad), paleta.crema);
  return base.copyWith(
    primary: primarioLegible ? paleta.primario : null,
    onPrimary: primarioLegible ? Colors.white : null,
    surface: paleta.crema,
    surfaceContainerLowest: Color.alphaBlend(
        Colors.white.withValues(alpha: 0.6), paleta.crema),
    surfaceContainerLow: hacia(0.05),
    surfaceContainer: hacia(0.08),
    surfaceContainerHigh: hacia(0.11),
    surfaceContainerHighest: hacia(0.14),
    surfaceTint: Colors.transparent,
  );
}

ColoresSolera _coloresPropios(ColorScheme esquema, {Color? acento}) {
  final oscuro = esquema.brightness == Brightness.dark;
  final colorAcento = acento ?? esquema.primaryContainer;
  final sobreAcento = acento == null
      ? esquema.onPrimaryContainer
      : (contrasteEntre(acento, Colors.white) >= 3
          ? Colors.white
          : const Color(0xFF1B1B1B));
  if (oscuro) {
    return ColoresSolera(
      acento: colorAcento,
      sobreAcento: sobreAcento,
      cabecera: Color.alphaBlend(
          esquema.primary.withValues(alpha: 0.16), esquema.surface),
      sobreCabecera: esquema.onSurface,
      sobreCabeceraVariante: esquema.onSurfaceVariant,
      pendiente: const Color(0xFFFFB77C),
      fondoPendiente: const Color(0xFF4A2800),
      enCurso: const Color(0xFF9ECAF2),
      fondoEnCurso: const Color(0xFF123A57),
      hecho: const Color(0xFF8FD8A0),
      fondoHecho: const Color(0xFF0F3D1C),
      peligro: const Color(0xFFF2B8B5),
      fondoPeligro: const Color(0xFF5C1712),
    );
  }
  return ColoresSolera(
    acento: colorAcento,
    sobreAcento: sobreAcento,
    cabecera: esquema.primary,
    sobreCabecera: esquema.onPrimary,
    sobreCabeceraVariante: esquema.onPrimary.withValues(alpha: 0.75),
    pendiente: const Color(0xFF8A4600),
    fondoPendiente: const Color(0xFFFFE2C9),
    enCurso: const Color(0xFF24577F),
    fondoEnCurso: const Color(0xFFD6E6F5),
    hecho: const Color(0xFF1E6B33),
    fondoHecho: const Color(0xFFD5EED9),
    peligro: const Color(0xFFB3261E),
    fondoPeligro: const Color(0xFFF9DEDC),
  );
}

// ── Tema ─────────────────────────────────────────────────────────────────

/// Tema de una app Larrea con su [paleta]; `oscuro: true` para el modo
/// oscuro.
ThemeData temaSolera(PaletaSolera paleta, {bool oscuro = false}) {
  final esquema = esquemaSolera(paleta, oscuro: oscuro);
  final propios = _coloresPropios(esquema, acento: paleta.acento);
  final texto = textoSolera(esquema);
  const pildora = StadiumBorder();
  const rellenoBoton = EdgeInsets.symmetric(horizontal: 24, vertical: 14);

  return ThemeData(
    useMaterial3: true,
    brightness: esquema.brightness,
    colorScheme: esquema,
    extensions: [propios],
    scaffoldBackgroundColor: esquema.surface,
    canvasColor: esquema.surface,
    textTheme: texto,
    fontFamily: familiaTextoSolera,
    dividerColor: esquema.outlineVariant,
    dividerTheme: DividerThemeData(
      color: esquema.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: esquema.surface,
      foregroundColor: esquema.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: texto.titleLarge,
      iconTheme: IconThemeData(color: esquema.onSurface),
    ),
    cardTheme: CardThemeData(
      color: esquema.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: const RoundedRectangleBorder(borderRadius: _bordeTarjeta),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: esquema.onSurfaceVariant,
      titleTextStyle: texto.titleMedium,
      subtitleTextStyle:
          texto.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
      shape: const RoundedRectangleBorder(borderRadius: _bordeTarjeta),
    ),
    // Sin colores: M3 ya pinta FilledButton en primary, y fijarlos dejaría
    // los tonales (FilledButton.tonal) iguales que los rellenos.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        textStyle: texto.labelLarge,
        padding: rellenoBoton,
        shape: pildora,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
        elevation: 0,
        textStyle: texto.labelLarge,
        padding: rellenoBoton,
        shape: pildora,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: esquema.primary,
        textStyle: texto.labelLarge,
        side: BorderSide(color: esquema.outline),
        padding: rellenoBoton,
        shape: pildora,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: esquema.primary,
        textStyle: texto.labelLarge,
        shape: pildora,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: esquema.onSurfaceVariant),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: esquema.secondaryContainer,
        selectedForegroundColor: esquema.onSecondaryContainer,
        foregroundColor: esquema.onSurface,
        side: BorderSide(color: esquema.outline),
        textStyle: texto.labelLarge,
        shape: pildora,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: propios.acento,
      foregroundColor: propios.sobreAcento,
      elevation: 2,
      focusElevation: 2,
      hoverElevation: 3,
      highlightElevation: 3,
      extendedTextStyle: texto.titleMedium,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: esquema.surface,
      selectedColor: esquema.secondaryContainer,
      checkmarkColor: esquema.onSecondaryContainer,
      side: WidgetStateBorderSide.resolveWith(
        (estados) => estados.contains(WidgetState.selected)
            ? BorderSide.none
            : BorderSide(color: esquema.outline),
      ),
      labelStyle: texto.labelLarge?.copyWith(color: esquema.onSurface),
      shape: const RoundedRectangleBorder(borderRadius: _bordeCampo),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: _bordeDeCampo(esquema.outline),
      enabledBorder: _bordeDeCampo(esquema.outline),
      focusedBorder: _bordeDeCampo(esquema.primary, grosor: 2),
      errorBorder: _bordeDeCampo(esquema.error),
      focusedErrorBorder: _bordeDeCampo(esquema.error, grosor: 2),
      labelStyle: texto.bodyLarge?.copyWith(color: esquema.onSurfaceVariant),
      hintStyle: texto.bodyLarge?.copyWith(color: esquema.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: esquema.primary,
      unselectedLabelColor: esquema.onSurfaceVariant,
      indicatorColor: esquema.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: esquema.outlineVariant,
      labelStyle: texto.titleSmall,
      unselectedLabelStyle:
          texto.titleSmall?.copyWith(fontWeight: FontWeight.w500),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: esquema.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      indicatorColor: esquema.secondaryContainer,
      elevation: 0,
      iconTheme: WidgetStateProperty.resolveWith(
        (estados) => IconThemeData(
          color: estados.contains(WidgetState.selected)
              ? esquema.onSecondaryContainer
              : esquema.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (estados) => texto.labelMedium?.copyWith(
          color: estados.contains(WidgetState.selected)
              ? esquema.onSurface
              : esquema.onSurfaceVariant,
          fontWeight: estados.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: esquema.surfaceContainer,
      indicatorColor: esquema.secondaryContainer,
      selectedIconTheme: IconThemeData(color: esquema.onSecondaryContainer),
      unselectedIconTheme: IconThemeData(color: esquema.onSurfaceVariant),
      selectedLabelTextStyle: texto.labelMedium
          ?.copyWith(color: esquema.onSurface, fontWeight: FontWeight.w700),
      unselectedLabelTextStyle:
          texto.labelMedium?.copyWith(color: esquema.onSurfaceVariant),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: esquema.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: esquema.outline,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: esquema.inverseSurface,
      contentTextStyle:
          texto.bodyMedium?.copyWith(color: esquema.onInverseSurface),
      actionTextColor: esquema.inversePrimary,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: _bordeCampo),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: esquema.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      titleTextStyle: texto.headlineSmall,
      contentTextStyle:
          texto.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: esquema.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      textStyle: texto.bodyLarge,
      shape: const RoundedRectangleBorder(borderRadius: _bordeCampo),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: esquema.primary,
      linearTrackColor: esquema.outlineVariant,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (estados) => estados.contains(WidgetState.selected)
            ? esquema.onPrimary
            : esquema.outline,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (estados) => estados.contains(WidgetState.selected)
            ? esquema.primary
            : esquema.surfaceContainerHighest,
      ),
    ),
  );
}

OutlineInputBorder _bordeDeCampo(Color color, {double grosor = 1}) {
  return OutlineInputBorder(
    borderRadius: _bordeCampo,
    borderSide: BorderSide(color: color, width: grosor),
  );
}

/// Escala tipográfica de Material 3 (tamaños en sp): Poppins 600 en
/// display, headline y titleLarge (títulos de pantalla y de sección, cifras
/// destacadas); Inter en lo demás.
TextTheme textoSolera(ColorScheme esquema) {
  TextStyle titular(double tamano, double alto) => TextStyle(
        fontFamily: familiaTitularSolera,
        fontSize: tamano,
        height: alto / tamano,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: esquema.onSurface,
      );

  TextStyle inter(
    double tamano,
    double alto, {
    FontWeight peso = FontWeight.w400,
    double espaciado = 0,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: familiaTextoSolera,
        fontSize: tamano,
        height: alto / tamano,
        fontWeight: peso,
        letterSpacing: espaciado,
        color: color ?? esquema.onSurface,
      );

  return TextTheme(
    displayLarge: titular(57, 64),
    displayMedium: titular(45, 52),
    displaySmall: titular(36, 44),
    headlineLarge: titular(32, 40),
    headlineMedium: titular(28, 36),
    headlineSmall: titular(24, 32),
    titleLarge: titular(22, 28),
    titleMedium: inter(16, 24, peso: FontWeight.w600, espaciado: 0.1),
    titleSmall: inter(14, 20, peso: FontWeight.w600, espaciado: 0.1),
    bodyLarge: inter(16, 24, espaciado: 0.2),
    bodyMedium: inter(14, 20, espaciado: 0.2),
    bodySmall: inter(12, 16, espaciado: 0.3, color: esquema.onSurfaceVariant),
    labelLarge: inter(14, 20, peso: FontWeight.w600, espaciado: 0.1),
    labelMedium: inter(12, 16, peso: FontWeight.w600, espaciado: 0.4),
    labelSmall: inter(11, 16,
        peso: FontWeight.w500, espaciado: 0.5, color: esquema.onSurfaceVariant),
  );
}
