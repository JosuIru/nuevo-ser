import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
const _claveVisto = 'solera_quesera.onboarding.visto';
class PantallaOnboarding extends StatefulWidget {
  final VoidCallback alTerminar;
  PantallaOnboarding({super.key, required this.alTerminar});
  @override
  State<PantallaOnboarding> createState() => _PantallaOnboardingState();
  static Future<bool> yaVisto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_claveVisto) ?? false;
  }
}
class _PantallaOnboardingState extends State<PantallaOnboarding> {
  final _ctrl = PageController();
  int _pagina = 0;
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  Future<void> _terminar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claveVisto, true);
    widget.alTerminar();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(child: Column(children: [
        Expanded(child: PageView(controller: _ctrl, onPageChanged: (i) => setState(() => _pagina = i), children: [
          _card(theme, Icons.inventory_2, 'Trazabilidad de tu queso', 'Registra cada lote desde la leche hasta la venta.'),
          _card(theme, Icons.kitchen, 'Gestión de la cava', 'Controla cada pieza individualmente: volteos, temperatura, humedad.'),
          _card(theme, Icons.description, 'Libro de trazabilidad APPCC', 'Genera el PDF de trazabilidad que te pide el inspector.'),
          _card(theme, Icons.verified, 'Cumplimiento de DO', 'Activa el perfil de tu denominación de origen.'),
        ])),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => AnimatedContainer(duration: Duration(milliseconds: 200), margin: const EdgeInsets.symmetric(horizontal: 4), width: _pagina == i ? 24 : 8, height: 8, decoration: BoxDecoration(color: _pagina == i ? theme.colorScheme.primary : theme.colorScheme.primary.withAlpha(80), borderRadius: BorderRadius.circular(4))))),
        SizedBox(height: 24),
        Padding(padding: const EdgeInsets.all(24), child: SizedBox(width: double.infinity, child: FilledButton(onPressed: _pagina < 3 ? () => _ctrl.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut) : _terminar, child: Text(_pagina < 3 ? 'Siguiente' : 'Comenzar')))),
      ])),
    );
  }
  Widget _card(ThemeData t, IconData i, String tit, String desc) => Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 80, color: t.colorScheme.primary), SizedBox(height: 32), Text(tit, style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center), SizedBox(height: 16), Text(desc, style: t.textTheme.bodyLarge, textAlign: TextAlign.center)]));
}
