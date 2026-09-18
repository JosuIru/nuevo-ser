import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../branding.dart';
import '../estado/idioma_app.dart';
import '../l10n/app_localizations.dart';

/// Bienvenida de primer arranque. Permite elegir idioma (castellano/euskera)
/// y entrar. Marca `zunbeltz.onboarding_visto` para no repetirse.
class PantallaOnboarding extends StatefulWidget {
  const PantallaOnboarding({super.key, required this.alTerminar});

  final VoidCallback alTerminar;

  static const _claveVisto = 'zunbeltz.onboarding_visto';

  static Future<bool> yaVisto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_claveVisto) ?? false;
  }

  @override
  State<PantallaOnboarding> createState() => _PantallaOnboardingState();
}

class _PantallaOnboardingState extends State<PantallaOnboarding> {
  Future<void> _empezar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PantallaOnboarding._claveVisto, true);
    widget.alTerminar();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final localeActivo = Localizations.localeOf(context).languageCode;
    return Scaffold(
      backgroundColor: colorMonteZunbeltz,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    textos.onboardingTitulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    textos.onboardingCuerpo,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Selector de idioma: ambos de primera clase desde el día uno.
                  Wrap(
                    spacing: 10,
                    children: [
                      _ChipIdioma(
                        etiqueta: textos.ajustesIdiomaCastellano,
                        activo: localeActivo == 'es',
                        alPulsar: () => elegirIdiomaZunbeltz('es'),
                      ),
                      _ChipIdioma(
                        etiqueta: textos.ajustesIdiomaEuskera,
                        activo: localeActivo == 'eu',
                        alPulsar: () => elegirIdiomaZunbeltz('eu'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: colorSenalZunbeltz,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _empezar,
                      child: Text(
                        textos.onboardingBoton,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipIdioma extends StatelessWidget {
  const _ChipIdioma({
    required this.etiqueta,
    required this.activo,
    required this.alPulsar,
  });

  final String etiqueta;
  final bool activo;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    // Botón propio (no ChoiceChip) para controlar el contraste sobre el fondo
    // oscuro del onboarding: activo = musgo + texto oscuro; inactivo =
    // translúcido con borde y texto blancos.
    return Material(
      color: activo ? colorMusgoZunbeltz : Colors.white.withValues(alpha: 0.14),
      shape: StadiumBorder(
        side: BorderSide(
          color: activo ? Colors.transparent : Colors.white70,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alPulsar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          child: Text(
            etiqueta,
            style: TextStyle(
              color: activo ? colorMonteZunbeltz : Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
