// Guía de especies: une el catálogo de especies con las fichas de la guía
// (rasgos para reconocerla, hábitat, artículo de Wikipedia para las fotos).
// Lógica pura, sin Flutter.

import '../datos/catalogos_generados/catalogo_especies.dart';
import '../datos/catalogos_generados/catalogo_guia.dart';

/// Una especie del catálogo con su ficha de la guía (puede faltar).
typedef EntradaGuia = ({EspecieCatalogo especie, FichaGuiaEspecie? ficha});

final Map<String, FichaGuiaEspecie> _fichas = {
  for (final ficha in catalogoGuia) ficha.id: ficha
};

FichaGuiaEspecie? fichaGuiaDe(String especieId) => _fichas[especieId];

/// La especie con su ficha, para abrirla en la guía.
EntradaGuia entradaGuiaDe(EspecieCatalogo especie) =>
    (especie: especie, ficha: _fichas[especie.id]);

/// Artículo de Wikipedia de la especie: el de la ficha o, si no hay, el
/// nombre científico sin la sinonimia entre paréntesis.
String tituloWikipediaDe(EspecieCatalogo especie) {
  final deFicha = _fichas[especie.id]?.tituloWikipedia ?? '';
  if (deFicha.isNotEmpty) return deFicha;
  return especie.nombreCientifico.split('(').first.trim();
}

String _sinAcentos(String texto) {
  const conAcento = 'áéíóúüàèìòùñç';
  const sinAcento = 'aeiouuaeiounc';
  final minusculas = texto.toLowerCase();
  final salida = StringBuffer();
  for (final letra in minusculas.split('')) {
    final posicion = conAcento.indexOf(letra);
    salida.write(posicion < 0 ? letra : sinAcento[posicion]);
  }
  return salida.toString();
}

/// La entrada coincide con [consulta] (sin distinguir mayúsculas ni
/// acentos) en nombre, nombre científico, familia, rasgos o hábitat.
bool coincideConConsulta(EntradaGuia entrada, String consulta) {
  final buscada = _sinAcentos(consulta.trim());
  if (buscada.isEmpty) return true;
  final especie = entrada.especie;
  final texto = _sinAcentos([
    especie.nombre,
    especie.nombreCientifico,
    especie.familia,
    especie.parteUsada,
    ...?entrada.ficha?.rasgos,
    entrada.ficha?.habitat ?? '',
  ].join(' '));
  return texto.contains(buscada);
}

/// Entradas de la guía que coinciden con [consulta], agrupadas por familia
/// botánica (familias por orden alfabético; dentro, especies por nombre).
List<({String familia, List<EntradaGuia> entradas})> guiaPorFamilia(
    {String consulta = ''}) {
  final porFamilia = <String, List<EntradaGuia>>{};
  for (final especie in catalogoEspecies) {
    final EntradaGuia entrada = (especie: especie, ficha: _fichas[especie.id]);
    if (!coincideConConsulta(entrada, consulta)) continue;
    porFamilia.putIfAbsent(especie.familia, () => []).add(entrada);
  }
  final familias = porFamilia.keys.toList()..sort();
  return [
    for (final familia in familias)
      (
        familia: familia,
        entradas: porFamilia[familia]!
          ..sort((a, b) => a.especie.nombre.compareTo(b.especie.nombre)),
      ),
  ];
}
