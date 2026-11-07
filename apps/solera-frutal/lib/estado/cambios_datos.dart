import 'package:flutter/foundation.dart';

/// Se incrementa cada vez que se guarda algo: las pestañas que siguen vivas
/// en el IndexedStack lo escuchan y recargan.
final ValueNotifier<int> cambiosDatos = ValueNotifier<int>(0);

void avisarCambioDatos() => cambiosDatos.value++;
