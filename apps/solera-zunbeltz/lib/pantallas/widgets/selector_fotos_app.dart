import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../../l10n/app_localizations.dart';

/// [SelectorFotos] del core, salvo en el navegador: allí no hay sistema de
/// ficheros donde copiar las fotos, así que se avisa de que se añaden
/// desde el móvil. Las rutas que ya tenga el registro se conservan.
class SelectorFotosApp extends StatelessWidget {
  final List<String> rutas;
  final ValueChanged<List<String>> alCambiar;

  const SelectorFotosApp({
    super.key,
    required this.rutas,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return SelectorFotos(rutas: rutas, alCambiar: alCambiar);
    }
    final tema = Theme.of(context);
    return Text(
      AppLocalizations.of(context).fotosSoloEnMovil,
      style: tema.textTheme.bodySmall
          ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
    );
  }
}
