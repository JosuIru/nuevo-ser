import '../datos/catalogos_generados/catalogo_razas.dart';
import '../datos/catalogos_generados/catalogo_sustancias_activas.dart';

/// Minúsculas y sin tildes, para comparar lo escrito con el catálogo.
String normalizarTexto(String texto) {
  const conTilde = 'áàäâéèëêíìïîóòöôúùüûñç';
  const sinTilde = 'aaaaeeeeiiiioooouuuunc';
  final buffer = StringBuffer();
  for (final caracter in texto.trim().toLowerCase().split('')) {
    final posicion = conTilde.indexOf(caracter);
    buffer.write(posicion < 0 ? caracter : sinTilde[posicion]);
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
}

/// La sustancia activa del catálogo que corresponde a [texto] («ivermectina»,
/// «IVERMECTINA 1 %»…): la que coincide entera o aparece como palabra. Null si
/// no hay ninguna (la persona puede apuntar otra: el catálogo solo ayuda).
SustanciaActivaCatalogo? buscarSustanciaActiva(String texto) {
  final buscado = normalizarTexto(texto);
  if (buscado.isEmpty) return null;
  for (final fila in catalogoSustanciasActivas) {
    if (normalizarTexto(fila.nombre) == buscado) return fila;
  }
  for (final fila in catalogoSustanciasActivas) {
    if (RegExp('\\b${RegExp.escape(normalizarTexto(fila.nombre))}\\b')
        .hasMatch(buscado)) {
      return fila;
    }
  }
  return null;
}

/// Las razas del catálogo para una especie, en orden alfabético.
List<String> razasDeEspecie(String especie) => [
      for (final raza in catalogoRazas)
        if (raza.especie == especie) raza.nombre
    ]..sort((a, b) => normalizarTexto(a).compareTo(normalizarTexto(b)));
