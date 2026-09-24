import 'dart:math';

import 'fenologia.dart';

/// Paleta del lugar: los colores que dominan en las fotos que el niño
/// ha hecho en su sit spot, estación a estación. Se calcula al vuelo
/// desde las fotos (que no salen del dispositivo); no se guarda nada.
///
/// No es un progreso ni una colección que completar: es una forma de
/// mirar cómo cambia el mismo sitio con el año (biblia §3.5, habitar un
/// lugar; CIC, notar el tiempo de la vida). Una estación sin fotos
/// simplemente no aparece.
///
/// Los colores van como enteros ARGB (0xAARRGGBB) para que este archivo
/// no dependa de Flutter.

/// Colores dominantes de una lista de píxeles RGBA (4 bytes por píxel,
/// como `ui.Image.toByteData(format: rawRgba)`). Determinista.
///
/// Método: histograma a 4 bits por canal (4096 cajas); se eligen las
/// cajas más pobladas que se distingan de las ya elegidas por más de
/// [distanciaMinima] (distancia RGB 0-255), y cada color es la media
/// real de su caja. Los píxeles casi transparentes no cuentan.
List<int> coloresDominantes(
  List<int> pixelesRgba, {
  int numeroColores = 5,
  double distanciaMinima = 48,
}) {
  final cuenta = List<int>.filled(4096, 0);
  final sumaRojo = List<int>.filled(4096, 0);
  final sumaVerde = List<int>.filled(4096, 0);
  final sumaAzul = List<int>.filled(4096, 0);
  for (var indice = 0; indice + 3 < pixelesRgba.length; indice += 4) {
    if (pixelesRgba[indice + 3] < 128) continue;
    final rojo = pixelesRgba[indice];
    final verde = pixelesRgba[indice + 1];
    final azul = pixelesRgba[indice + 2];
    final caja = ((rojo >> 4) << 8) | ((verde >> 4) << 4) | (azul >> 4);
    cuenta[caja]++;
    sumaRojo[caja] += rojo;
    sumaVerde[caja] += verde;
    sumaAzul[caja] += azul;
  }
  return _elegirDistintos(
    [
      for (var caja = 0; caja < 4096; caja++)
        if (cuenta[caja] > 0)
          _Candidato(
            peso: cuenta[caja],
            rojo: sumaRojo[caja] ~/ cuenta[caja],
            verde: sumaVerde[caja] ~/ cuenta[caja],
            azul: sumaAzul[caja] ~/ cuenta[caja],
          ),
    ],
    numeroColores,
    distanciaMinima,
  );
}

/// Junta las paletas de varias fotos en una sola. Cada color de cada
/// foto pesa igual (una foto no domina por tener más píxeles).
List<int> fusionarPaletas(
  List<List<int>> paletas, {
  int numeroColores = 6,
  double distanciaMinima = 40,
}) {
  final candidatos = <_Candidato>[];
  for (final paleta in paletas) {
    for (var posicion = 0; posicion < paleta.length; posicion++) {
      final color = paleta[posicion];
      candidatos.add(_Candidato(
        // Dentro de una foto, el primer color es el más presente.
        peso: paleta.length - posicion,
        rojo: (color >> 16) & 0xFF,
        verde: (color >> 8) & 0xFF,
        azul: color & 0xFF,
      ));
    }
  }
  return _elegirDistintos(candidatos, numeroColores, distanciaMinima);
}

/// Una franja de colores de una estación.
class PaletaEstacional {
  const PaletaEstacional({
    required this.estacion,
    required this.colores,
    required this.numeroFotos,
  });

  final Estacion estacion;
  final List<int> colores;
  final int numeroFotos;
}

/// Agrupa por estación las paletas de cada foto (fecha de la
/// observación → colores dominantes de su foto) y devuelve una franja
/// por estación con fotos, en el orden del año empezando en primavera.
List<PaletaEstacional> paletasPorEstacion(
  List<({DateTime fecha, List<int> colores})> fotos, {
  String regionCode = 'ES',
}) {
  final porEstacion = <Estacion, List<List<int>>>{};
  for (final foto in fotos) {
    if (foto.colores.isEmpty) continue;
    final estacion = estacionDeFecha(foto.fecha, regionCode: regionCode);
    porEstacion.putIfAbsent(estacion, () => []).add(foto.colores);
  }
  return [
    for (final estacion in Estacion.values)
      if (porEstacion[estacion] != null)
        PaletaEstacional(
          estacion: estacion,
          colores: fusionarPaletas(porEstacion[estacion]!),
          numeroFotos: porEstacion[estacion]!.length,
        ),
  ];
}

class _Candidato {
  const _Candidato({
    required this.peso,
    required this.rojo,
    required this.verde,
    required this.azul,
  });

  final int peso;
  final int rojo;
  final int verde;
  final int azul;

  int get argb => 0xFF000000 | (rojo << 16) | (verde << 8) | azul;

  double distanciaA(_Candidato otro) {
    final dr = rojo - otro.rojo;
    final dg = verde - otro.verde;
    final db = azul - otro.azul;
    return sqrt((dr * dr + dg * dg + db * db).toDouble());
  }
}

List<int> _elegirDistintos(
    List<_Candidato> candidatos, int numeroColores, double distanciaMinima) {
  // Orden estable: por peso y, a igualdad, por el propio color.
  candidatos.sort((a, b) {
    final porPeso = b.peso.compareTo(a.peso);
    return porPeso != 0 ? porPeso : a.argb.compareTo(b.argb);
  });
  final elegidos = <_Candidato>[];
  for (final candidato in candidatos) {
    if (elegidos.length >= numeroColores) break;
    if (elegidos.every((e) => e.distanciaA(candidato) > distanciaMinima)) {
      elegidos.add(candidato);
    }
  }
  return elegidos.map((c) => c.argb).toList();
}
