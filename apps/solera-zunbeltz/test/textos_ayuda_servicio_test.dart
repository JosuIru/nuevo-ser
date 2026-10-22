import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solera_zunbeltz/l10n/app_localizations.dart';
import 'package:solera_zunbeltz/pantallas/pantalla_ayuda.dart';
import 'package:solera_zunbeltz/servicios/servicio_textos_ayuda.dart';

void main() {
  test('la respuesta del servidor se limpia: solo cadenas no vacías', () {
    final textos = ServicioTextosAyuda.textosDesdeRespuesta({
      'textos': {
        'es': {'ayudaQueEsT': '¿Para qué sirve?', 'ayudaPie': '', 'x': 3},
        'eu': {},
        'fr': 'no',
      }
    });
    expect(textos, {
      'es': {'ayudaQueEsT': '¿Para qué sirve?'}
    });
    expect(ServicioTextosAyuda.textosDesdeRespuesta('nada'), isEmpty);
  });

  test('textoAyuda prefiere lo del panel en su idioma y cae al de serie', () {
    final cambiados = {
      'es': {'ayudaQueEsT': 'Cambiado'}
    };
    const deSerie = {'ayudaQueEsT': 'De serie', 'ayudaPie': 'Pie'};
    expect(textoAyuda(cambiados, 'es', deSerie, 'ayudaQueEsT'), 'Cambiado');
    expect(textoAyuda(cambiados, 'eu', deSerie, 'ayudaQueEsT'), 'De serie');
    expect(textoAyuda(cambiados, 'es', deSerie, 'ayudaPie'), 'Pie');
    expect(textoAyuda(cambiados, 'es', deSerie, 'noExiste'), '');
  });

  testWidgets('la pantalla enseña el texto cambiado en el panel',
      (tester) async {
    ServicioTextosAyuda.actuales.value = {
      'es': {'ayudaQueEsT': 'Qué es Zunlanda'}
    };
    addTearDown(() => ServicioTextosAyuda.actuales.value = const {});
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PantallaAyuda(perfilTester: false),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Qué es Zunlanda'), findsOneWidget);
    expect(find.text('¿Qué es esta app?'), findsNothing);
    expect(find.text('Moverse por la app'), findsOneWidget);
  });
}
