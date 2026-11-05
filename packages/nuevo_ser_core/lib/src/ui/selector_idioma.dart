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

/// Vuelve a pintar toda la app tras cambiar de idioma. Los textos salen de
/// [SoleraL10n.t], que no depende del `context`, así que Flutter no sabe que
/// han cambiado: sin esto ni el propio selector marcaba el idioma nuevo (es
/// `StatelessWidget`) y las pantallas abiertas seguían en el anterior.
void _reconstruirTodaLaApp() {
  void marcarParaReconstruir(Element elemento) {
    elemento.markNeedsBuild();
    elemento.visitChildren(marcarParaReconstruir);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(marcarParaReconstruir);
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
    // Wrap y no Row: con letra más ancha o pantalla estrecha, los cuatro
    // no caben en una fila y pasan a la siguiente en vez de desbordar.
    // Dentro de un scroll horizontal sigue saliendo en una sola fila.
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: idiomas.map((idioma) {
        final activo = SoleraL10n.idioma == idioma.codigo;
        return ChoiceChip(
          selected: activo,
          label: Text(idioma.nombre),
          onSelected: (_) {
            SoleraL10n.idioma = idioma.codigo;
            _guardarIdiomaSolera(idioma.codigo);
            _reconstruirTodaLaApp();
            onCambio?.call();
          },
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
