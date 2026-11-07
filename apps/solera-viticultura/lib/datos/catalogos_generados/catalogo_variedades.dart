// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/viticultura/variedades.csv
// Generado: 2026-11-07
// Filas: 44 (0 revisadas, 44 pendientes de revisión)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR AGRONÓMICA/ENOLÓGICAMENTE.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-viticultura && dart run tool/compilar_catalogos.dart

/// Color visual de la variedad. Las rosadas son raras pero existen.
enum ColorVariedad { tinta, blanca, rosada }

class Variedad {
  final String id;
  final String nombreCanonico;
  final ColorVariedad color;
  final List<String> sinonimias;

  const Variedad({
    required this.id,
    required this.nombreCanonico,
    required this.color,
    this.sinonimias = const [],
  });
}

const List<Variedad> catalogoVariedades = [
  Variedad(
    id: 'tempranillo',
    nombreCanonico: 'Tempranillo',
    color: ColorVariedad.tinta,
    sinonimias: ['cencibel', 'tinto fino', 'tinta de toro', 'tinta del país', 'ull de llebre'],
  ),
  Variedad(
    id: 'garnacha_tinta',
    nombreCanonico: 'Garnacha tinta',
    color: ColorVariedad.tinta,
    sinonimias: ['lledoner', 'garnatxa', 'aragonés'],
  ),
  Variedad(
    id: 'mencia',
    nombreCanonico: 'Mencía',
    color: ColorVariedad.tinta,
    sinonimias: ['jaen'],
  ),
  Variedad(
    id: 'monastrell',
    nombreCanonico: 'Monastrell',
    color: ColorVariedad.tinta,
    sinonimias: ['mourvèdre', 'murviedro'],
  ),
  Variedad(
    id: 'bobal',
    nombreCanonico: 'Bobal',
    color: ColorVariedad.tinta,
    sinonimias: ['requena'],
  ),
  Variedad(
    id: 'cariñena',
    nombreCanonico: 'Cariñena',
    color: ColorVariedad.tinta,
    sinonimias: ['mazuelo', 'samsó', 'carignan'],
  ),
  Variedad(
    id: 'graciano',
    nombreCanonico: 'Graciano',
    color: ColorVariedad.tinta,
    sinonimias: ['morrastel', 'tintilla'],
  ),
  Variedad(
    id: 'prieto_picudo',
    nombreCanonico: 'Prieto picudo',
    color: ColorVariedad.tinta,
  ),
  Variedad(
    id: 'listan_negro',
    nombreCanonico: 'Listán negro',
    color: ColorVariedad.tinta,
    sinonimias: ['negramoll'],
  ),
  Variedad(
    id: 'caiño_tinto',
    nombreCanonico: 'Caíño tinto',
    color: ColorVariedad.tinta,
  ),
  Variedad(
    id: 'trepat',
    nombreCanonico: 'Trepat',
    color: ColorVariedad.tinta,
  ),
  Variedad(
    id: 'callet',
    nombreCanonico: 'Callet',
    color: ColorVariedad.tinta,
  ),
  Variedad(
    id: 'juan_garcia',
    nombreCanonico: 'Juan García',
    color: ColorVariedad.tinta,
    sinonimias: ['mouratón'],
  ),
  Variedad(
    id: 'hondarrabi_beltza',
    nombreCanonico: 'Hondarrabi beltza',
    color: ColorVariedad.tinta,
  ),
  Variedad(
    id: 'albillo_real',
    nombreCanonico: 'Albillo real',
    color: ColorVariedad.blanca,
  ),
  Variedad(
    id: 'albariño',
    nombreCanonico: 'Albariño',
    color: ColorVariedad.blanca,
    sinonimias: ['alvarinho'],
  ),
  Variedad(
    id: 'godello',
    nombreCanonico: 'Godello',
    color: ColorVariedad.blanca,
    sinonimias: ['verdelho'],
  ),
  Variedad(
    id: 'verdejo',
    nombreCanonico: 'Verdejo',
    color: ColorVariedad.blanca,
  ),
  Variedad(
    id: 'viura',
    nombreCanonico: 'Viura',
    color: ColorVariedad.blanca,
    sinonimias: ['macabeo', 'maccabeu'],
  ),
  Variedad(
    id: 'treixadura',
    nombreCanonico: 'Treixadura',
    color: ColorVariedad.blanca,
    sinonimias: ['trajadura'],
  ),
  Variedad(
    id: 'xarello',
    nombreCanonico: 'Xarel·lo',
    color: ColorVariedad.blanca,
    sinonimias: ['pansal', 'cartoixà'],
  ),
  Variedad(
    id: 'parellada',
    nombreCanonico: 'Parellada',
    color: ColorVariedad.blanca,
    sinonimias: ['montonega'],
  ),
  Variedad(
    id: 'garnacha_blanca',
    nombreCanonico: 'Garnacha blanca',
    color: ColorVariedad.blanca,
    sinonimias: ['garnatxa blanca', 'grenache blanc'],
  ),
  Variedad(
    id: 'palomino_fino',
    nombreCanonico: 'Palomino fino',
    color: ColorVariedad.blanca,
    sinonimias: ['listán blanco'],
  ),
  Variedad(
    id: 'pedro_ximenez',
    nombreCanonico: 'Pedro Ximénez',
    color: ColorVariedad.blanca,
  ),
  Variedad(
    id: 'malvasia',
    nombreCanonico: 'Malvasía',
    color: ColorVariedad.blanca,
  ),
  Variedad(
    id: 'moscatel_alejandría',
    nombreCanonico: 'Moscatel de Alejandría',
    color: ColorVariedad.blanca,
    sinonimias: ['moscatel romano'],
  ),
  Variedad(
    id: 'moscatel_grano_menudo',
    nombreCanonico: 'Moscatel de grano menudo',
    color: ColorVariedad.blanca,
    sinonimias: ['muscat à petits grains'],
  ),
  Variedad(
    id: 'airen',
    nombreCanonico: 'Airén',
    color: ColorVariedad.blanca,
    sinonimias: ['manchega'],
  ),
  Variedad(
    id: 'hondarrabi_zuri',
    nombreCanonico: 'Hondarrabi zuri',
    color: ColorVariedad.blanca,
  ),
  Variedad(
    id: 'cabernet_sauvignon',
    nombreCanonico: 'Cabernet Sauvignon',
    color: ColorVariedad.tinta,
  ),
  Variedad(
    id: 'merlot',
    nombreCanonico: 'Merlot',
    color: ColorVariedad.tinta,
  ),
  Variedad(
    id: 'syrah',
    nombreCanonico: 'Syrah',
    color: ColorVariedad.tinta,
    sinonimias: ['shiraz'],
  ),
  Variedad(
    id: 'pinot_noir',
    nombreCanonico: 'Pinot Noir',
    color: ColorVariedad.tinta,
    sinonimias: ['pinot negro'],
  ),
  Variedad(
    id: 'petit_verdot',
    nombreCanonico: 'Petit Verdot',
    color: ColorVariedad.tinta,
  ),
  Variedad(
    id: 'malbec',
    nombreCanonico: 'Malbec',
    color: ColorVariedad.tinta,
    sinonimias: ['cot', 'côt'],
  ),
  Variedad(
    id: 'chardonnay',
    nombreCanonico: 'Chardonnay',
    color: ColorVariedad.blanca,
  ),
  Variedad(
    id: 'sauvignon_blanc',
    nombreCanonico: 'Sauvignon Blanc',
    color: ColorVariedad.blanca,
  ),
  Variedad(
    id: 'riesling',
    nombreCanonico: 'Riesling',
    color: ColorVariedad.blanca,
  ),
  Variedad(
    id: 'gewurztraminer',
    nombreCanonico: 'Gewürztraminer',
    color: ColorVariedad.blanca,
  ),
  Variedad(
    id: 'garnacha_rosada',
    nombreCanonico: 'Garnacha rosada',
    color: ColorVariedad.rosada,
    sinonimias: ['garnacha gris', 'garnatxa roja', 'grenache gris'],
  ),
  Variedad(
    id: 'pinot_gris',
    nombreCanonico: 'Pinot gris',
    color: ColorVariedad.rosada,
    sinonimias: ['pinot grigio', 'grauburgunder'],
  ),
  Variedad(
    id: 'moscatel_grano_menudo_rosado',
    nombreCanonico: 'Moscatel de grano menudo rosado',
    color: ColorVariedad.rosada,
    sinonimias: ['muscat à petits grains roses'],
  ),
  Variedad(
    id: 'treixadura_rosada',
    nombreCanonico: 'Treixadura rosada',
    color: ColorVariedad.rosada,
  ),
];

Variedad? variedadPorId(String id) {
  for (final v in catalogoVariedades) {
    if (v.id == id) return v;
  }
  return null;
}

/// Búsqueda fuzzy: id exacto > nombre canónico > sinonimias > coincidencia parcial.
/// Usado por el modal IA para validar diagnósticos contra el catálogo y por
/// el `Autocomplete` de la pantalla nueva cepa.
List<Variedad> buscarVariedades(String texto) {
  final q = _normalizar(texto);
  if (q.isEmpty) return const [];
  return catalogoVariedades.where((v) {
    if (v.id == q) return true;
    if (_normalizar(v.nombreCanonico).contains(q)) return true;
    for (final s in v.sinonimias) {
      if (_normalizar(s).contains(q)) return true;
    }
    return false;
  }).toList();
}

String _normalizar(String texto) {
  return texto
      .toLowerCase()
      .replaceAll(RegExp(r'[áàä]'), 'a')
      .replaceAll(RegExp(r'[éèë]'), 'e')
      .replaceAll(RegExp(r'[íìï]'), 'i')
      .replaceAll(RegExp(r'[óòö]'), 'o')
      .replaceAll(RegExp(r'[úùü]'), 'u')
      .replaceAll('ñ', 'n')
      .trim();
}

