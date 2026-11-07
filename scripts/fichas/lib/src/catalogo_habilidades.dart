import 'dart:convert';

/// Una habilidad tal como la describe `skills.json` de Uno Roto. Solo
/// guarda lo que la ficha necesita: el resto (umbrales, rangos,
/// distritos) es del motor de maestría del juego y aquí no pinta nada.
class Habilidad {
  final String id;
  final String nombre;
  final String dominio;
  final String? curso;

  const Habilidad({
    required this.id,
    required this.nombre,
    required this.dominio,
    this.curso,
  });

  factory Habilidad.desdeMapa(Map<String, dynamic> mapa) => Habilidad(
        id: mapa['id'] as String,
        nombre: mapa['name'] as String,
        dominio: mapa['domain'] as String,
        curso: mapa['course'] as String?,
      );
}

/// Catálogo leído de `skills.json`: habilidades en el orden del fichero
/// y nombres legibles de los dominios.
class CatalogoHabilidades {
  final List<Habilidad> habilidades;
  final Map<String, String> nombresDominio;

  const CatalogoHabilidades({
    required this.habilidades,
    required this.nombresDominio,
  });

  factory CatalogoHabilidades.desdeJson(String textoJson) {
    final raiz = jsonDecode(textoJson) as Map<String, dynamic>;
    final listaHabilidades = (raiz['skills'] as List)
        .cast<Map<String, dynamic>>()
        .map(Habilidad.desdeMapa)
        .toList();
    final dominios = (raiz['domains'] as Map<String, dynamic>? ?? const {})
        .map((clave, valor) => MapEntry(clave, valor as String));
    return CatalogoHabilidades(
      habilidades: listaHabilidades,
      nombresDominio: dominios,
    );
  }

  Habilidad? porId(String id) {
    final idNormalizado = id.trim().toUpperCase();
    for (final habilidad in habilidades) {
      if (habilidad.id == idNormalizado) return habilidad;
    }
    return null;
  }

  List<Habilidad> porDominio(String dominio) {
    final dominioNormalizado = dominio.trim().toUpperCase();
    return habilidades.where((h) => h.dominio == dominioNormalizado).toList();
  }

  String nombreDominio(String dominio) => nombresDominio[dominio] ?? dominio;
}
