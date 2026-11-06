import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'estado/datos_ejemplo.dart';
import 'estado/estado_concejo.dart';
import 'l10n/app_localizations.dart';
import 'pantallas/pantalla_inicio.dart';
import 'tema.dart';

void main() {
  runApp(AppConcejo(estado: estadoDeEjemplo()));
}

class AppConcejo extends StatelessWidget {
  const AppConcejo({super.key, required this.estado, this.idioma});

  final EstadoConcejo estado;

  /// Para fijar el idioma en los tests; si no, el del sistema.
  final Locale? idioma;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).nombreApp,
      debugShowCheckedModeBanner: false,
      theme: temaConcejo(Brightness.light),
      darkTheme: temaConcejo(Brightness.dark),
      locale: idioma,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: PantallaInicio(estado: estado),
    );
  }
}
