import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

/// «2,55» (dos decimales, en el idioma de la app).
String formatearHectareas(double hectareas) =>
    NumberFormat.decimalPatternDigits(
            locale: SoleraL10n.idioma, decimalDigits: 2)
        .format(hectareas);

/// «1.240» (metros enteros).
String formatearMetros(double metros) =>
    NumberFormat.decimalPattern(SoleraL10n.idioma).format(metros.round());
