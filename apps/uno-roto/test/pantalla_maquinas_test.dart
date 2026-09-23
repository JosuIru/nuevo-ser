import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_roto/datos/repositorio_progreso.dart';
import 'package:uno_roto/dominio/minijuegos/catalogo_minijuegos.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/vista/minijuegos/pantalla_maquinas.dart';

Widget _envolver() => MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('eu'), Locale('ca')],
      home: PantallaMaquinas(repositorio: RepositorioProgreso()),
    );

void main() {
  testWidgets('sin práctica ni modo dios, todas en reparación', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 7200);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_envolver());
    await tester.pumpAndSettle();
    expect(find.textContaining('todavía la está arreglando'),
        findsNWidgets(CatalogoMinijuegos.todos.length));
    expect(find.byKey(const ValueKey('dios-puentes-1')), findsNothing);
  });

  testWidgets('en modo dios todas encendidas con sus tres dificultades',
      (tester) async {
    SharedPreferences.setMockInitialValues({'uroto.modo_dios_activo': true});
    tester.view.physicalSize = const Size(1080, 7200);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_envolver());
    await tester.pumpAndSettle();
    expect(find.textContaining('todavía la está arreglando'), findsNothing);
    for (final definicion in CatalogoMinijuegos.todos) {
      for (final dificultad in [1, 2, 3]) {
        expect(find.byKey(ValueKey('dios-${definicion.id.name}-$dificultad')),
            findsOneWidget);
      }
    }
  });
}
