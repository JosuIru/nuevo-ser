/// Número para enseñar en pantalla con coma decimal y punto de millares
/// («1.234,5»), que es como se escribe en castellano, euskera, catalán y
/// gallego. `toStringAsFixed` pone punto decimal («0.0 litros»).
///
/// [decimales] fija cuántos decimales salen (como `toStringAsFixed`).
String formatearNumero(num numero, {int decimales = 0}) {
  final textoFijo = numero.abs().toStringAsFixed(decimales);
  final partes = textoFijo.split('.');
  final parteEntera = partes.first;
  final conMillares = StringBuffer();
  for (var posicion = 0; posicion < parteEntera.length; posicion++) {
    final cifrasRestantes = parteEntera.length - posicion;
    if (posicion > 0 && cifrasRestantes % 3 == 0) conMillares.write('.');
    conMillares.write(parteEntera[posicion]);
  }
  final signo = numero < 0 && double.parse(textoFijo) != 0 ? '-' : '';
  final parteDecimal = partes.length > 1 ? ',${partes[1]}' : '';
  return '$signo$conMillares$parteDecimal';
}

/// Importe en euros: «1.234,50 €».
String formatearEuros(num importe) => '${formatearNumero(importe, decimales: 2)} €';
