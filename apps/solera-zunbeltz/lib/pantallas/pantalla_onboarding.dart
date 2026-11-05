import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../branding.dart';
import '../estado/idioma_app.dart';
import '../l10n/app_localizations.dart';
import 'widgets/curvas_de_nivel.dart';
import 'widgets/logos_entidades.dart' show filtroLogoClaro;

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
    final colores = context.coloresZunbeltz;
    final estilos = Theme.of(context).textTheme;
    // Iconos de la barra de estado en claro, sobre la cabecera verde.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colores.cabecera,
        body: Stack(children: [
          // Curvas de nivel de adorno, arriba a la derecha.
          Positioned.fill(
            child: CustomPaint(
              painter: CurvasDeNivel(
                color: colores.sobreCabecera.withValues(alpha: 0.14),
                centroRelativo: const Offset(0.92, 0.26),
                separacion: 0.028,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: LayoutBuilder(
                  builder: (contexto, limites) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: limites.maxHeight - 48),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ColorFiltered(
                                colorFilter: filtroLogoClaro(colores
                                    .sobreCabecera
                                    .withValues(alpha: 0.9)),
                                child: Image.asset(rutaLogoZunbeltz,
                                    height: 72, semanticLabel: 'Zunbeltz'),
                              ),
                            ),
                            const Spacer(flex: 3),
                            Text(textos.onboardingTitulo,
                                style: estilos.displaySmall?.copyWith(
                                    color: colores.sobreCabecera,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 16),
                            Text(textos.onboardingCuerpo,
                                style: estilos.titleMedium?.copyWith(
                                    color: colores.sobreCabeceraVariante,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5)),
                            const Spacer(flex: 2),
                            const SizedBox(height: 24),
                            // Ambos idiomas de primera clase desde el día uno.
                            SegmentedButton<String>(
                              style: SegmentedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: colores.sobreCabecera,
                                selectedBackgroundColor: colorCuadroSalvia,
                                selectedForegroundColor: colorSobreCuadroClaro,
                                side: BorderSide(
                                    color: colores.sobreCabeceraVariante
                                        .withValues(alpha: 0.6)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              segments: [
                                ButtonSegment(
                                    value: 'es',
                                    label:
                                        Text(textos.ajustesIdiomaCastellano)),
                                ButtonSegment(
                                    value: 'eu',
                                    label: Text(textos.ajustesIdiomaEuskera)),
                              ],
                              selected: {localeActivo},
                              onSelectionChanged: (elegidos) =>
                                  elegirIdiomaZunbeltz(elegidos.first),
                            ),
                            const Spacer(flex: 2),
                            const SizedBox(height: 24),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: colores.acento,
                                foregroundColor: colores.sobreAcento,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                              ),
                              onPressed: _empezar,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(textos.onboardingBoton,
                                      style: estilos.titleMedium?.copyWith(
                                          color: colores.sobreAcento,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.arrow_forward),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(textos.onboardingPie,
                                textAlign: TextAlign.center,
                                style: estilos.bodyMedium?.copyWith(
                                    color: colores.sobreCabeceraVariante)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
