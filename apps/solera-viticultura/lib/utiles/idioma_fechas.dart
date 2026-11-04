import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Locale de `intl` para formatear fechas con nombres de mes o de día
/// («lun 3 nov») en el idioma elegido en Ajustes. Los datos de los cuatro
/// idiomas se cargan en `main()` con `initializeDateFormatting`.
String get localeFechasSolera => switch (SoleraL10n.idioma) {
      'eu' => 'eu',
      'ca' => 'ca',
      'gl' => 'gl',
      _ => 'es_ES',
    };
