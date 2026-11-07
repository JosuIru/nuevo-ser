import 'dart:math' as math;

/// Herramientas comunes de los generadores: fracciones, formato español
/// de números y elección aleatoria con semilla.

int mcd(int a, int b) {
  a = a.abs();
  b = b.abs();
  while (b != 0) {
    final resto = a % b;
    a = b;
    b = resto;
  }
  return a;
}

int mcm(int a, int b) => (a * b).abs() ~/ mcd(a, b);

/// Fracción con signo en el numerador y denominador positivo. No se
/// simplifica sola: «6/8» y «3/4» son fracciones distintas aunque valgan
/// lo mismo, y eso es justo lo que trabajan algunas fichas.
class Fraccion {
  final int numerador;
  final int denominador;

  Fraccion(int numerador, int denominador)
      : numerador = denominador < 0 ? -numerador : numerador,
        denominador = denominador.abs() {
    if (denominador == 0) throw ArgumentError('denominador 0');
  }

  Fraccion simplificada() {
    final divisor = mcd(numerador, denominador);
    if (divisor == 0) return Fraccion(0, 1);
    return Fraccion(numerador ~/ divisor, denominador ~/ divisor);
  }

  Fraccion operator +(Fraccion otra) => Fraccion(
          numerador * otra.denominador + otra.numerador * denominador,
          denominador * otra.denominador)
      .simplificada();
  Fraccion operator -(Fraccion otra) => this + Fraccion(-otra.numerador, otra.denominador);
  Fraccion operator *(Fraccion otra) =>
      Fraccion(numerador * otra.numerador, denominador * otra.denominador)
          .simplificada();
  Fraccion operator /(Fraccion otra) =>
      Fraccion(numerador * otra.denominador, denominador * otra.numerador)
          .simplificada();

  double get valor => numerador / denominador;

  int compareTo(Fraccion otra) =>
      (numerador * otra.denominador).compareTo(otra.numerador * denominador);

  bool get esEntera => numerador % denominador == 0;

  /// «3/4», «−3/4», o el entero si el denominador es 1.
  String get texto {
    if (denominador == 1) return formatearEntero(numerador);
    final signo = numerador < 0 ? '−' : '';
    return '$signo${numerador.abs()}/$denominador';
  }

  /// Entre paréntesis si es negativa, para escribirla tras un operador.
  String get textoOperando => numerador < 0 ? '($texto)' : texto;

  @override
  bool operator ==(Object other) =>
      other is Fraccion &&
      other.numerador == numerador &&
      other.denominador == denominador;

  @override
  int get hashCode => Object.hash(numerador, denominador);

  @override
  String toString() => texto;
}

/// Entero con el signo menos tipográfico (−) y sin separador de miles
/// hasta 9999 (norma RAE: «2500», pero «12 500»).
String formatearEntero(int numero) {
  final signo = numero < 0 ? '−' : '';
  final cifras = numero.abs().toString();
  if (cifras.length <= 4) return '$signo$cifras';
  final grupos = <String>[];
  for (var fin = cifras.length; fin > 0; fin -= 3) {
    grupos.insert(0, cifras.substring(math.max(0, fin - 3), fin));
  }
  return '$signo${grupos.join(' ')}';
}

/// Entre paréntesis si es negativo: «3 · (−4)».
String enteroOperando(int numero) =>
    numero < 0 ? '(${formatearEntero(numero)})' : formatearEntero(numero);

/// Decimal con coma y sin ceros sobrantes: 2.50 → «2,5». [cifras] es el
/// máximo de decimales (redondea para quitar el ruido de coma flotante).
String formatearDecimal(num numero, {int cifras = 4}) {
  if (numero == numero.roundToDouble() && numero.abs() < 1e15) {
    return formatearEntero(numero.round());
  }
  var texto = numero.abs().toStringAsFixed(cifras);
  texto = texto.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  final partes = texto.split('.');
  final parteEntera = formatearEntero(int.parse(partes[0]));
  final signo = numero < 0 ? '−' : '';
  return partes.length == 1 ? '$signo$parteEntera' : '$signo$parteEntera,${partes[1]}';
}

/// Decimal con un número fijo de cifras: 2.3 con 2 → «2,30».
String formatearDecimalFijo(num numero, int cifras) =>
    numero.toStringAsFixed(cifras).replaceAll('.', ',');

/// Superíndice en el marcado de las fichas: `potencia('2', 5)` → «2^{5}».
String potencia(String base, Object exponente) {
  final textoExponente =
      exponente is int ? formatearEntero(exponente) : exponente.toString();
  return '$base^{$textoExponente}';
}

extension EleccionAzar on math.Random {
  T elegir<T>(List<T> opciones) => opciones[nextInt(opciones.length)];

  /// Entero en [minimo, maximo], ambos incluidos.
  int entre(int minimo, int maximo) => minimo + nextInt(maximo - minimo + 1);

  /// Entero distinto de cero en [−maximo, maximo].
  int conSignoNoNulo(int maximo) {
    final valor = entre(1, maximo);
    return nextBool() ? valor : -valor;
  }

  List<T> barajar<T>(List<T> elementos) {
    final copia = [...elementos];
    copia.shuffle(this);
    return copia;
  }
}

/// Hash FNV-1a de 32 bits: estable entre ejecuciones (a diferencia de
/// `String.hashCode`), para derivar la semilla de cada ficha.
int hashEstable(String texto) {
  var hash = 0x811c9dc5;
  for (final unidad in texto.codeUnits) {
    hash ^= unidad;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash;
}

/// Lista en castellano: «a, b y c».
String unirConY(List<String> elementos) {
  if (elementos.length <= 1) return elementos.join();
  return '${elementos.sublist(0, elementos.length - 1).join(', ')} y ${elementos.last}';
}
