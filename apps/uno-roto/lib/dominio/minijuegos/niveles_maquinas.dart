/// Niveles de las máquinas "de pensar" (Puentes, Parejas, Minas, Flota,
/// Balanza): las rondas se reparten en tres tramos y cada tramo sube un
/// punto la dificultad de las cuentas. Lo que pasaría de 3 (una partida
/// ya en dificultad alta) se devuelve como [extra] para que cada máquina
/// lo convierta en algo suyo: más distractores, más minas, una trampa.

/// Nivel (1-3) de la [ronda] en una partida de [rondasTotales].
int nivelDeRonda(int ronda, int rondasTotales) {
  if (rondasTotales <= 3) return ronda.clamp(1, 3);
  return ((ronda - 1) * 3 ~/ rondasTotales + 1).clamp(1, 3);
}

/// Dificultad de las cuentas en ese [nivel] y lo que sobra por encima de 3.
({int dificultad, int extra}) dificultadEnNivel(int dificultad, int nivel) {
  final total = dificultad + nivel - 1;
  return (dificultad: total.clamp(1, 3), extra: total > 3 ? total - 3 : 0);
}
