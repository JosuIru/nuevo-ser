import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_roto/datos/repositorio_progreso.dart';

/// Tests de `RepositorioEncargo` (doc 16, eje D): progreso por día,
/// evaporación silenciosa del encargo de ayer y la señal
/// `recienCompletado` en la captura exacta que cierra el encargo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const hoy = '2026-07-08';
  const ayer = '2026-07-07';

  test('sin nada guardado, el estado es limpio', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = RepositorioProgreso();
    final estado = await repo.encargo.cargarEstado(hoy);
    expect(estado.progreso, 0);
    expect(estado.completado, isFalse);
  });

  test('registrar capturas avanza y cierra en el objetivo exacto', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = RepositorioProgreso();

    final primera =
        await repo.encargo.registrarCaptura(claveFecha: hoy, objetivo: 3);
    expect(primera.progreso, 1);
    expect(primera.completado, isFalse);
    expect(primera.recienCompletado, isFalse);

    await repo.encargo.registrarCaptura(claveFecha: hoy, objetivo: 3);
    final tercera =
        await repo.encargo.registrarCaptura(claveFecha: hoy, objetivo: 3);
    expect(tercera.progreso, 3);
    expect(tercera.completado, isTrue);
    expect(tercera.recienCompletado, isTrue,
        reason: 'la captura que cierra el encargo debe señalarlo una vez');

    // Capturas posteriores al cierre no avanzan ni re-señalan.
    final extra =
        await repo.encargo.registrarCaptura(claveFecha: hoy, objetivo: 3);
    expect(extra.progreso, 3);
    expect(extra.recienCompletado, isFalse);
  });

  test('el progreso de ayer se evapora al pedir el estado de hoy', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = RepositorioProgreso();
    await repo.encargo.registrarCaptura(claveFecha: ayer, objetivo: 3);
    await repo.encargo.registrarCaptura(claveFecha: ayer, objetivo: 3);

    final estadoHoy = await repo.encargo.cargarEstado(hoy);
    expect(estadoHoy.progreso, 0,
        reason: 'el encargo de ayer no deja rastro (sin racha, sin culpa)');
    expect(estadoHoy.completado, isFalse);

    // Y la primera captura de hoy reescribe el trío coherente.
    final primeraHoy =
        await repo.encargo.registrarCaptura(claveFecha: hoy, objetivo: 3);
    expect(primeraHoy.progreso, 1);
  });

  test('borrarTodo limpia el estado', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = RepositorioProgreso();
    await repo.encargo.registrarCaptura(claveFecha: hoy, objetivo: 3);
    await repo.encargo.borrarTodo();
    final estado = await repo.encargo.cargarEstado(hoy);
    expect(estado.progreso, 0);
    expect(estado.completado, isFalse);
  });
}
