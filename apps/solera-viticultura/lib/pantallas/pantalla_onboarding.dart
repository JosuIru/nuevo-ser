import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding del primer arranque. 3 cards con beneficios + CTA
/// "Empezar". Marca un flag global en SharedPreferences que se lee
/// en `main.dart` para no volver a mostrarlo.
///
/// Tono: directo, profesional. No es un juego — el usuario es
/// viticultor o enólogo y aprecia que se le respete el tiempo.
class PantallaOnboarding extends StatefulWidget {
  /// Callback que el orquestador (main) ejecuta cuando el usuario
  /// pulsa "Empezar". Marca el flag y reemplaza esta pantalla por
  /// el mapa.
  final VoidCallback alTerminar;

  const PantallaOnboarding({super.key, required this.alTerminar});

  static const claveOnboardingVisto = 'solera_viticultura.onboarding.visto';

  static Future<bool> yaVisto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(claveOnboardingVisto) ?? false;
  }

  static Future<void> marcarVisto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(claveOnboardingVisto, true);
  }

  @override
  State<PantallaOnboarding> createState() => _PantallaOnboardingState();
}

class _PantallaOnboardingState extends State<PantallaOnboarding> {
  final _pageController = PageController();
  int _pagina = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _terminar() async {
    await PantallaOnboarding.marcarVisto();
    widget.alTerminar();
  }

  @override
  Widget build(BuildContext context) {
    final paleta = Theme.of(context).colorScheme;
    final esUltima = _pagina == _paginas.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/icono-log-viticultura.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _pagina = i),
                itemCount: _paginas.length,
                itemBuilder: (_, i) => _PaginaOnboarding(datos: _paginas[i], paleta: paleta),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_paginas.length, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  width: i == _pagina ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _pagina ? paleta.primary : paleta.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: esUltima ? null : _terminar,
                    child: Text(esUltima ? '' : 'Saltar'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      if (esUltima) {
                        _terminar();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
                    child: Text(esUltima ? 'Empezar' : 'Siguiente'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatosPagina {
  final IconData icono;
  final String titulo;
  final String texto;
  const _DatosPagina(this.icono, this.titulo, this.texto);
}

const _paginas = <_DatosPagina>[
  _DatosPagina(
    Icons.location_on,
    'Tus cepas en el mapa',
    'Cataloga cada cepa con su ubicación GPS, variedad, portainjerto y fotos. '
        'Localiza cualquier planta singular en segundos desde el mapa con clustering.',
  ),
  _DatosPagina(
    Icons.auto_awesome,
    'Diagnóstico con IA por foto',
    'Hazle una foto a un racimo o una hoja con síntomas y la IA propone diagnóstico '
        '(mildiu, oídio, botritis…) y manejo cultural. Tú decides; nada se aplica sin tu '
        'revisión.',
  ),
  _DatosPagina(
    Icons.description,
    'Libro PAC al alcance',
    'Anota cada tratamiento con sus campos PAC y exporta el libro oficial '
        '(RD 1311/2012) en PDF firmable. Adiós a la oficina los domingos.',
  ),
];

class _PaginaOnboarding extends StatelessWidget {
  final _DatosPagina datos;
  final ColorScheme paleta;
  const _PaginaOnboarding({required this.datos, required this.paleta});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: paleta.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(datos.icono, size: 56, color: paleta.primary),
          ),
          const SizedBox(height: 32),
          Text(
            datos.titulo,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: paleta.primary,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            datos.texto,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade800,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
