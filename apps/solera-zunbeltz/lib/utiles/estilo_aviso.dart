import 'package:flutter/material.dart';

import '../branding.dart';
import '../l10n/app_localizations.dart';
import '../modelos/aviso_campo.dart';

/// Icono pequeño de cada categoría de aviso (como en la app de Andía).
IconData iconoCategoriaAviso(String categoria) => switch (categoria) {
      categoriaAvisoGanado => Icons.pets_outlined,
      categoriaAvisoInstalaciones => Icons.handyman_outlined,
      categoriaAvisoSeguimiento => Icons.person_search_outlined,
      categoriaAvisoNoticias => Icons.campaign_outlined,
      _ => Icons.info_outline,
    };

/// Color de cada categoría, de la paleta de la app. El rojo de marcaje se
/// reserva para las alarmas, así que ninguna categoría lo usa.
Color colorCategoriaAviso(String categoria) => switch (categoria) {
      categoriaAvisoGanado => colorPastoZunbeltz,
      categoriaAvisoInstalaciones => colorEstadoEnCurso,
      categoriaAvisoSeguimiento => const Color(0xFF8C6A2E),
      categoriaAvisoNoticias => colorMonteZunbeltz,
      _ => colorTintaApagadaZunbeltz,
    };

String etiquetaCategoriaAviso(String categoria, AppLocalizations textos) =>
    switch (categoria) {
      categoriaAvisoGanado => textos.avisoCategoriaGanado,
      categoriaAvisoInstalaciones => textos.avisoCategoriaInstalaciones,
      categoriaAvisoSeguimiento => textos.avisoCategoriaSeguimiento,
      categoriaAvisoNoticias => textos.avisoCategoriaNoticias,
      _ => categoria,
    };
