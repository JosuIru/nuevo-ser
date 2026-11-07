import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../modelos/ganado.dart';

/// «Soto → Larre altua», «ES31… → Soto».
String trayectoMovimiento(
    MovimientoGanado movimiento, Map<int, String> piezas) {
  String externo() => [
        movimiento.titularExterno,
        movimiento.explotacionExterna,
      ]
          .where((parte) => parte.isNotEmpty)
          .join(' ')
          .siVacio(SoleraL10n.t('gana.fuera_de_la_explotacion'));
  final origen = movimiento.esEntradaEnExplotacion
      ? externo()
      : piezas[movimiento.piezaOrigenId] ?? '—';
  final destino = movimiento.esSalidaDeExplotacion
      ? externo()
      : piezas[movimiento.piezaDestinoId] ??
          piezas[movimiento.piezaOrigenId] ??
          '—';
  return '$origen → $destino';
}

extension on String {
  String siVacio(String alternativa) => isEmpty ? alternativa : this;
}
