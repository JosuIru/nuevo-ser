import 'package:flutter/foundation.dart';

/// Avisa de que las fincas han cambiado (alta, nombre, SIGPAC, área…).
/// El mapa vive en un IndexedStack y no se reconstruye al volver a su
/// pestaña: escucha esto para repintar las áreas y el selector.
final ValueNotifier<int> cambiosFincas = ValueNotifier<int>(0);

void avisarCambioFincas() => cambiosFincas.value++;
