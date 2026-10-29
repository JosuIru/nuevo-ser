import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../i18n/solera_l10n.dart';

/// Dónde se guarda el idioma elegido con [SelectorIdioma]. Las preferencias
/// son de cada app, así que la clave puede ser común.
const _claveIdiomaSolera = 'solera.idioma_app';

/// Recupera el idioma que se eligió la última vez. Llamar en `main()` antes
/// de `runApp` (tras `WidgetsFlutterBinding.ensureInitialized()`); sin esto
/// la app vuelve al castellano cada vez que se abre.
Future<void> cargarIdiomaSolera() async {
  try {
    final preferencias = await SharedPreferences.getInstance();
    final guardado = preferencias.getString(_claveIdiomaSolera);
    if (guardado != null &&
        SelectorIdioma.idiomas.any((idioma) => idioma.codigo == guardado)) {
      SoleraL10n.idioma = guardado;
    }
  } catch (_) {
    // Sin preferencias legibles se queda el idioma por defecto.
  }
}

Future<void> _guardarIdiomaSolera(String codigo) async {
  try {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(_claveIdiomaSolera, codigo);
  } catch (_) {
    // No guardarlo no impide usar el idioma en esta sesión.
  }
}

/// Selector de idioma para la suite Larrea.
/// Muestra los 4 idiomas disponibles (es, eu, ca, gl) como chips.
///
/// Uso:
/// ```dart
/// SelectorIdioma(
///   onCambio: (codigo) => setState(() {}),
/// )
/// ```
class SelectorIdioma extends StatelessWidget {
  final VoidCallback? onCambio;

  const SelectorIdioma({super.key, this.onCambio});

  static const idiomas = [
    _InfoIdioma('es', 'Español'),
    _InfoIdioma('eu', 'Euskera'),
    _InfoIdioma('ca', 'Català'),
    _InfoIdioma('gl', 'Galego'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: idiomas.map((idioma) {
        final activo = SoleraL10n.idioma == idioma.codigo;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            selected: activo,
            label: Text(idioma.nombre),
            onSelected: (_) {
              SoleraL10n.idioma = idioma.codigo;
              _guardarIdiomaSolera(idioma.codigo);
              onCambio?.call();
            },
          ),
        );
      }).toList(),
    );
  }
}

class _InfoIdioma {
  final String codigo;
  final String nombre;
  const _InfoIdioma(this.codigo, this.nombre);
}
