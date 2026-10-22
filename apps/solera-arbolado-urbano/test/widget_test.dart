import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solera_arbolado_urbano/main.dart';
import 'package:solera_arbolado_urbano/pantallas/pantalla_onboarding.dart';
import 'package:solera_arbolado_urbano/pantallas/pantalla_principal.dart';

void main() {
  testWidgets('Primer arranque muestra onboarding con CTA Empezar', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SoleraArboladoUrbanoApp());
    await tester.pumpAndSettle();
    expect(find.text('Inventario por chapa QR'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);
  });

  testWidgets('Onboarding visto: arranca directamente sin onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({
      PantallaOnboarding.claveOnboardingVisto: true,
    });
    await tester.pumpWidget(const SoleraArboladoUrbanoApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // No debe quedar onboarding en árbol.
    expect(find.text('Inventario por chapa QR'), findsNothing);
    // Barra inferior con las cinco pestañas, arrancando en el mapa.
    for (final etiqueta in ['Hoy', 'Mapa', 'Árboles', 'Registros', 'Ajustes']) {
      expect(find.text(etiqueta), findsWidgets);
    }
    final barra = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(barra.selectedIndex, PestanaPrincipal.mapa.index);
  });
}
