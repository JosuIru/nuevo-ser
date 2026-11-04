import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solera_apicola/main.dart';
import 'package:solera_apicola/pantallas/pantalla_onboarding.dart';

void main() {
  testWidgets('Primer arranque muestra onboarding con CTA Empezar', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SoleraApicolaApp());
    await tester.pumpAndSettle();
    // El onboarding tiene 3 páginas — la primera y al final hay CTA Siguiente.
    expect(find.text(SoleraL10n.t('api.onboarding_mapa_titulo')), findsOneWidget);
    expect(find.text(SoleraL10n.t('api.siguiente')), findsOneWidget);
  });

  testWidgets('Onboarding visto: arranca directamente sin onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({
      PantallaOnboarding.claveOnboardingVisto: true,
    });
    await tester.pumpWidget(const SoleraApicolaApp());
    // No esperamos pumpAndSettle porque PantallaMapa abre tile layer por red.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // No debe quedar onboarding en árbol.
    expect(find.text(SoleraL10n.t('api.onboarding_mapa_titulo')), findsNothing);
  });
}
