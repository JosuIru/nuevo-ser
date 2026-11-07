// PROVISIONAL CORE — módulo transversal T2 (venta directa). Ver socio.dart.
//
// Reparto de la cosecha de la semana entre las cestas. Lógica pura, sin
// Flutter ni BD. Es una **propuesta**: la persona la retoca antes de
// preparar las cestas.

/// Lo que hay para repartir de un cultivo esta semana.
class ExistenciaReparto {
  const ExistenciaReparto({
    required this.cultivoId,
    this.kg = 0,
    this.unidades,
  });

  final int cultivoId;
  final double kg;

  /// Si se reparte por piezas (lechugas, manojos), el número de piezas;
  /// entonces [kg] no cuenta.
  final int? unidades;

  bool get porUnidades => unidades != null;
}

/// Una cesta que entra en el reparto: su suscripción y sus partes.
class CestaEnReparto {
  const CestaEnReparto({required this.suscripcionId, required this.partes});

  final int suscripcionId;

  /// Peso relativo de la cesta (pequeña 2, mediana 3, grande 4).
  final int partes;
}

/// Lo que recibe una cesta de un cultivo.
class LineaReparto {
  const LineaReparto({
    required this.cultivoId,
    this.kg = 0,
    this.unidades,
  });

  final int cultivoId;
  final double kg;
  final int? unidades;
}

/// Resultado del reparto: líneas por suscripción y lo que sobra.
class PropuestaReparto {
  const PropuestaReparto({required this.lineas, required this.sobrante});

  /// Por id de suscripción. Solo líneas con algo (> 0).
  final Map<int, List<LineaReparto>> lineas;

  /// Lo que no cabe en el redondeo, por cultivo (kg o piezas). Solo los
  /// cultivos con sobrante.
  final Map<int, LineaReparto> sobrante;
}

/// Reparte cada cultivo entre las [cestas] en proporción a sus partes.
///
/// - En kilos se reparte en pasos de [pasoKg] (50 g por defecto, lo que se
///   puede pesar a mano); en piezas, en piezas enteras.
/// - Cada cesta recibe la parte entera que le toca (redondeo hacia abajo) y
///   el resto se reparte paso a paso por **mayor resto** (método de Hamilton):
///   el total repartido nunca supera lo que hay.
/// - A igualdad de resto decide un turno que rota con [semilla] (p. ej. el
///   número de semana) y con el orden del cultivo, para que no le toque
///   siempre a la misma cesta quedarse sin la lechuga que falta.
PropuestaReparto repartirCosecha({
  required List<ExistenciaReparto> existencias,
  required List<CestaEnReparto> cestas,
  double pasoKg = 0.05,
  int semilla = 0,
}) {
  assert(pasoKg > 0);
  final lineas = <int, List<LineaReparto>>{
    for (final cesta in cestas) cesta.suscripcionId: <LineaReparto>[],
  };
  final sobrante = <int, LineaReparto>{};
  final validas = cestas.where((cesta) => cesta.partes > 0).toList();
  final sumaPartes = validas.fold<int>(0, (suma, cesta) => suma + cesta.partes);

  for (var indice = 0; indice < existencias.length; indice++) {
    final existencia = existencias[indice];
    // Todo en «pasos» enteros: piezas, o múltiplos de pasoKg (con margen
    // para no perder un paso por el error de coma flotante).
    final pasosTotales = existencia.porUnidades
        ? existencia.unidades!.clamp(0, 1 << 30)
        : (existencia.kg / pasoKg + 1e-9).floor().clamp(0, 1 << 30);
    final asignados = List<int>.filled(validas.length, 0);
    if (sumaPartes > 0 && pasosTotales > 0) {
      final restos = <(int, double)>[];
      var repartidos = 0;
      for (var posicion = 0; posicion < validas.length; posicion++) {
        final cuota = pasosTotales * validas[posicion].partes / sumaPartes;
        asignados[posicion] = cuota.floor();
        repartidos += asignados[posicion];
        restos.add((posicion, cuota - cuota.floor()));
      }
      final desplazamiento = (semilla + indice) % validas.length;
      int turno(int posicion) => (posicion - desplazamiento) % validas.length;
      restos.sort((a, b) {
        final porResto = b.$2.compareTo(a.$2);
        if ((a.$2 - b.$2).abs() > 1e-9) return porResto;
        return turno(a.$1).compareTo(turno(b.$1));
      });
      for (var extra = 0; extra < pasosTotales - repartidos; extra++) {
        asignados[restos[extra].$1]++;
      }
    }
    var pasosAsignados = 0;
    for (var posicion = 0; posicion < validas.length; posicion++) {
      final pasos = asignados[posicion];
      if (pasos == 0) continue;
      pasosAsignados += pasos;
      lineas[validas[posicion].suscripcionId]!.add(existencia.porUnidades
          ? LineaReparto(cultivoId: existencia.cultivoId, unidades: pasos)
          : LineaReparto(
              cultivoId: existencia.cultivoId,
              kg: _redondearGramos(pasos * pasoKg)));
    }
    if (existencia.porUnidades) {
      final quedan = existencia.unidades! - pasosAsignados;
      if (quedan > 0) {
        sobrante[existencia.cultivoId] =
            LineaReparto(cultivoId: existencia.cultivoId, unidades: quedan);
      }
    } else {
      final quedan = _redondearGramos(existencia.kg - pasosAsignados * pasoKg);
      if (quedan > 0) {
        sobrante[existencia.cultivoId] =
            LineaReparto(cultivoId: existencia.cultivoId, kg: quedan);
      }
    }
  }
  return PropuestaReparto(lineas: lineas, sobrante: sobrante);
}

/// Kilos con tres decimales (gramos enteros).
double _redondearGramos(double kg) => (kg * 1000).round() / 1000;

/// Suma de lo repartido por cultivo (para comprobar la hoja de reparto).
Map<int, LineaReparto> totalesRepartidos(PropuestaReparto propuesta) {
  final kilos = <int, double>{};
  final piezas = <int, int>{};
  for (final lineasCesta in propuesta.lineas.values) {
    for (final linea in lineasCesta) {
      if (linea.unidades != null) {
        piezas[linea.cultivoId] =
            (piezas[linea.cultivoId] ?? 0) + linea.unidades!;
      } else {
        kilos[linea.cultivoId] = (kilos[linea.cultivoId] ?? 0) + linea.kg;
      }
    }
  }
  return {
    for (final entrada in kilos.entries)
      entrada.key: LineaReparto(
          cultivoId: entrada.key, kg: _redondearGramos(entrada.value)),
    for (final entrada in piezas.entries)
      entrada.key:
          LineaReparto(cultivoId: entrada.key, unidades: entrada.value),
  };
}
