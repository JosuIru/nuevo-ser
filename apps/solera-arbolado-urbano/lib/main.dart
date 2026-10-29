import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show cargarIdiomaSolera;
import 'package:intl/date_symbol_data_local.dart';

import 'pantallas/pantalla_onboarding.dart';
import 'pantallas/pantalla_principal.dart';
import 'servicios/backup_servicio.dart';

Future<void> main() async {
  // `DateFormat('d MMM yyyy', 'es_ES')` que usa pantalla_facturas (y
  // otras pantallas con fechas) lanza al primer .format() si los
  // símbolos del locale no están cargados — la lista de facturas
  // reventaba al renderizar el primer item tras emitir una.
  WidgetsFlutterBinding.ensureInitialized();
  // Idioma elegido en Ajustes la última vez (si no, castellano).
  await cargarIdiomaSolera();
  await initializeDateFormatting('es_ES', null);
  // Si la app murió a mitad de una restauración, deshacerla antes de que
  // nada abra la base de datos.
  try {
    await servicioCopiaSeguridad.recuperarRestauracionInterrumpida();
  } catch (error) {
    debugPrint('No se pudo revisar una restauración interrumpida: $error');
  }
  runApp(const SoleraArboladoUrbanoApp());
}

class SoleraArboladoUrbanoApp extends StatelessWidget {
  const SoleraArboladoUrbanoApp({super.key});

  @override
  Widget build(BuildContext contexto) {
    final ColorScheme esquemaColores = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D32), // verde hoja oscuro
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'Larrea Arbolado Urbano',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: esquemaColores,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F8F0), // crema savia
      ),
      home: const _OrquestadorArranque(),
    );
  }
}

/// Decide qué pantalla mostrar al arrancar — onboarding la primera vez,
/// PantallaPrincipal (pestaña Mapa) a partir de la segunda. El flag se persiste en
/// SharedPreferences (`solera_arbolado_urbano.onboarding.visto`).
class _OrquestadorArranque extends StatefulWidget {
  const _OrquestadorArranque();

  @override
  State<_OrquestadorArranque> createState() => _OrquestadorArranqueState();
}

class _OrquestadorArranqueState extends State<_OrquestadorArranque> {
  bool? _onboardingVisto;

  @override
  void initState() {
    super.initState();
    _comprobarOnboarding();
  }

  Future<void> _comprobarOnboarding() async {
    final visto = await PantallaOnboarding.yaVisto();
    if (mounted) setState(() => _onboardingVisto = visto);
  }

  @override
  Widget build(BuildContext context) {
    final visto = _onboardingVisto;
    if (visto == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!visto) {
      return PantallaOnboarding(
        alTerminar: () => setState(() => _onboardingVisto = true),
      );
    }
    return const PantallaPrincipal();
  }
}
