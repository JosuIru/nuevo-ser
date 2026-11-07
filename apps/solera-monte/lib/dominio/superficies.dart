import '../modelos/rodal.dart';

/// Superficie por especie principal, en hectáreas, de mayor a menor. Usa la
/// superficie declarada del rodal si la hay y, si no, la del polígono.
List<(String, double)> superficiePorEspecie(List<Rodal> rodales) {
  final suma = <String, double>{};
  for (final rodal in rodales) {
    final superficie = rodal.superficieHa;
    if (superficie <= 0) continue;
    suma.update(rodal.especiePrincipalId, (valor) => valor + superficie,
        ifAbsent: () => superficie);
  }
  final lista = suma.entries.map((e) => (e.key, e.value)).toList()
    ..sort((a, b) {
      final porSuperficie = b.$2.compareTo(a.$2);
      return porSuperficie != 0 ? porSuperficie : a.$1.compareTo(b.$1);
    });
  return lista;
}

/// Superficie total de los rodales (ha).
double superficieTotal(List<Rodal> rodales) =>
    rodales.fold(0.0, (suma, rodal) => suma + rodal.superficieHa);

/// Rodales sin superficie (ni declarada ni dibujada): hay que medirlos.
List<Rodal> rodalesSinSuperficie(List<Rodal> rodales) =>
    rodales.where((rodal) => rodal.superficieHa <= 0).toList();

/// Diferencia relativa entre la superficie dibujada y la declarada
/// (0,1 = la dibujada es un 10 % mayor); null si falta alguna.
double? diferenciaDibujadaDeclarada(Rodal rodal) {
  final declarada = rodal.superficieDeclaradaHa;
  if (declarada == null || declarada <= 0 || !rodal.tieneContorno) return null;
  return (rodal.superficieCalculadaHa - declarada) / declarada;
}
