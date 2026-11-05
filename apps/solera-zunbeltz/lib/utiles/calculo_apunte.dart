import '../modelos/indicadores_seguimiento.dart' show cuotaIva;

/// Cuentas de un apunte escrito como cantidad × precio sin IVA.
///
/// En la BD el importe de un apunte es el **total con IVA** (así lo leen
/// balance, desglose e informes con `cuotaIva`). Aquí se parte de lo que
/// se escribe —cantidad (opcional: sin ella, el precio es el importe) y
/// precio unitario sin IVA— y se devuelve la base, la cuota y el total que
/// se guarda. La cuota es la que `cuotaIva` sacará después del total, para
/// que lo que se ve al apuntar y lo que sale en el informe coincidan.
({int base, int cuota, int total}) cuentasApunte({
  double? cantidad,
  required double precioSinIva,
  required int ivaPorcentaje,
}) {
  final base = ((cantidad ?? 1) * precioSinIva * 100).round();
  final total = ivaPorcentaje <= 0
      ? base
      : (base * (100 + ivaPorcentaje) / 100).round();
  final cuota = cuotaIva(total, ivaPorcentaje);
  return (base: total - cuota, cuota: cuota, total: total);
}
