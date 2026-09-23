import 'package:flutter/widgets.dart';

/// [base] más el hueco de la barra de navegación del sistema por abajo.
///
/// Un `ListView` con `padding` explícito deja de sumar solo ese hueco, y en
/// móviles de pantalla completa (Android 15, borde a borde) el último
/// elemento —normalmente el botón Guardar— queda debajo de la barra.
EdgeInsets rellenoSobreBarraSistema(BuildContext context, EdgeInsets base) =>
    base.copyWith(bottom: base.bottom + MediaQuery.paddingOf(context).bottom);
