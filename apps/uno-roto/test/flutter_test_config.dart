import 'dart:async';

import 'package:uno_roto/vista/minijuegos/pantalla_recreativa.dart';

/// Configuración común de los tests: sin la animación de ambiente de
/// las máquinas (va en bucle y no dejaría terminar a `pumpAndSettle`).
Future<void> testExecutable(FutureOr<void> Function() pruebas) async {
  PantallaRecreativa.animacionAmbiente = false;
  await pruebas();
}
