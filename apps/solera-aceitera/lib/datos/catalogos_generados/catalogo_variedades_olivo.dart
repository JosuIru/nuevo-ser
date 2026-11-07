// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/aceitera/variedades_olivo.csv
// Generado: 2026-11-07
// Filas: 40 (0 firmadas por persona, 40 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR AGRONÓMICAMENTE.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-aceitera && dart run tool/compilar_catalogos.dart

/// Color predominante de la aceituna en madurez. Útil para destacar
/// variedades de mesa frente a almazara en el formulario.
enum ColorAceituna { verde, negra, morada }

/// Aptitud principal de la variedad. Algunas (manzanilla cacereña,
/// hojiblanca, verdial) son de doble aptitud.
enum UsoOlivar { almazara, mesa, mesaAlmazara }

class VariedadOlivo {
  final String id;
  final String nombreCanonico;
  final ColorAceituna color;
  final UsoOlivar uso;
  final String zonaPrincipal;
  final List<String> sinonimias;

  const VariedadOlivo({
    required this.id,
    required this.nombreCanonico,
    required this.color,
    required this.uso,
    this.zonaPrincipal = '',
    this.sinonimias = const [],
  });
}

const List<VariedadOlivo> catalogoVariedadesOlivo = [
  VariedadOlivo(
    id: 'picual',
    nombreCanonico: 'Picual',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Jaén / Córdoba',
    sinonimias: ['marteño', 'nevadillo blanco'],
  ),
  VariedadOlivo(
    id: 'hojiblanca',
    nombreCanonico: 'Hojiblanca',
    color: ColorAceituna.negra,
    uso: UsoOlivar.mesaAlmazara,
    zonaPrincipal: 'Antequera / Estepa / Lucena',
    sinonimias: ['lucentina'],
  ),
  VariedadOlivo(
    id: 'arbequina',
    nombreCanonico: 'Arbequina',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Lleida / Tarragona / Andalucía superintensivo',
    sinonimias: ['arbequí'],
  ),
  VariedadOlivo(
    id: 'cornicabra',
    nombreCanonico: 'Cornicabra',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Toledo / Ciudad Real / Madrid',
    sinonimias: ['cornezuelo'],
  ),
  VariedadOlivo(
    id: 'manzanilla_cacerena',
    nombreCanonico: 'Manzanilla Cacereña',
    color: ColorAceituna.negra,
    uso: UsoOlivar.mesaAlmazara,
    zonaPrincipal: 'Cáceres / Badajoz',
    sinonimias: ['manzanilla del norte'],
  ),
  VariedadOlivo(
    id: 'manzanilla_sevillana',
    nombreCanonico: 'Manzanilla de Sevilla',
    color: ColorAceituna.verde,
    uso: UsoOlivar.mesa,
    zonaPrincipal: 'Sevilla / Huelva',
    sinonimias: ['manzanilla fina'],
  ),
  VariedadOlivo(
    id: 'gordal_sevillana',
    nombreCanonico: 'Gordal Sevillana',
    color: ColorAceituna.verde,
    uso: UsoOlivar.mesa,
    zonaPrincipal: 'Sevilla',
    sinonimias: ['gordal', 'reina'],
  ),
  VariedadOlivo(
    id: 'empeltre',
    nombreCanonico: 'Empeltre',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Aragón / Baleares / Tarragona',
    sinonimias: ['injerto'],
  ),
  VariedadOlivo(
    id: 'farga',
    nombreCanonico: 'Farga',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Castellón / Tarragona / sur Aragón',
  ),
  VariedadOlivo(
    id: 'morrut',
    nombreCanonico: 'Morrut',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Tarragona / Castellón',
    sinonimias: ['morrudo'],
  ),
  VariedadOlivo(
    id: 'sevillenca',
    nombreCanonico: 'Sevillenca',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Tarragona',
  ),
  VariedadOlivo(
    id: 'verdial_huevar',
    nombreCanonico: 'Verdial de Huévar',
    color: ColorAceituna.verde,
    uso: UsoOlivar.mesaAlmazara,
    zonaPrincipal: 'Huelva / Sevilla',
  ),
  VariedadOlivo(
    id: 'verdial_velez_malaga',
    nombreCanonico: 'Verdial de Vélez-Málaga',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Málaga / Granada',
  ),
  VariedadOlivo(
    id: 'aloreña',
    nombreCanonico: 'Aloreña de Málaga',
    color: ColorAceituna.verde,
    uso: UsoOlivar.mesa,
    zonaPrincipal: 'Valle del Guadalhorce',
  ),
  VariedadOlivo(
    id: 'royal_cazorla',
    nombreCanonico: 'Royal de Cazorla',
    color: ColorAceituna.morada,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Sierra de Cazorla',
    sinonimias: ['royuela'],
  ),
  VariedadOlivo(
    id: 'nevadillo_negro',
    nombreCanonico: 'Nevadillo Negro',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Jaén / Córdoba',
  ),
  VariedadOlivo(
    id: 'lechin_sevilla',
    nombreCanonico: 'Lechín de Sevilla',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Sevilla / Cádiz / Huelva',
    sinonimias: ['zorzaleño'],
  ),
  VariedadOlivo(
    id: 'lechin_granada',
    nombreCanonico: 'Lechín de Granada',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Granada / Almería',
  ),
  VariedadOlivo(
    id: 'picudo',
    nombreCanonico: 'Picudo',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Córdoba / Jaén / Granada',
    sinonimias: ['carrasqueño de Córdoba'],
  ),
  VariedadOlivo(
    id: 'picuda',
    nombreCanonico: 'Picuda',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Sierras Subbéticas',
  ),
  VariedadOlivo(
    id: 'chorruo',
    nombreCanonico: 'Chorrúo',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Jaén',
  ),
  VariedadOlivo(
    id: 'blanqueta',
    nombreCanonico: 'Blanqueta',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Alicante / Valencia',
  ),
  VariedadOlivo(
    id: 'villalonga',
    nombreCanonico: 'Villalonga',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Valencia',
  ),
  VariedadOlivo(
    id: 'changlot_real',
    nombreCanonico: 'Changlot Real',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Valencia',
  ),
  VariedadOlivo(
    id: 'serrana_espadan',
    nombreCanonico: 'Serrana de Espadán',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Castellón',
  ),
  VariedadOlivo(
    id: 'mallorquina_mallorquina',
    nombreCanonico: 'Mallorquina',
    color: ColorAceituna.negra,
    uso: UsoOlivar.mesaAlmazara,
    zonaPrincipal: 'Mallorca',
    sinonimias: ['empeltre mallorquí'],
  ),
  VariedadOlivo(
    id: 'arbosana',
    nombreCanonico: 'Arbosana',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Tarragona / superintensivo',
  ),
  VariedadOlivo(
    id: 'arroniz',
    nombreCanonico: 'Arróniz',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Navarra / La Rioja',
  ),
  VariedadOlivo(
    id: 'nyam_de_perol',
    nombreCanonico: 'Nyam de Perol',
    color: ColorAceituna.negra,
    uso: UsoOlivar.mesa,
    zonaPrincipal: 'Empordà',
  ),
  VariedadOlivo(
    id: 'argudell',
    nombreCanonico: 'Argudell',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Girona / Empordà',
  ),
  VariedadOlivo(
    id: 'corbella',
    nombreCanonico: 'Corbella',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Empordà',
  ),
  VariedadOlivo(
    id: 'verdeja',
    nombreCanonico: 'Verdeja',
    color: ColorAceituna.verde,
    uso: UsoOlivar.mesaAlmazara,
    zonaPrincipal: 'Tierra de Campos',
  ),
  VariedadOlivo(
    id: 'cobrancosa',
    nombreCanonico: 'Cobrançosa',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Trás-os-Montes (PT) + frontera Zamora',
  ),
  VariedadOlivo(
    id: 'galega_vulgar',
    nombreCanonico: 'Galega Vulgar',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Portugal interior + frontera Salamanca',
  ),
  VariedadOlivo(
    id: 'cordovil_serpa',
    nombreCanonico: 'Cordovil de Serpa',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Bajo Alentejo',
  ),
  VariedadOlivo(
    id: 'carrasqueña_extremadura',
    nombreCanonico: 'Carrasqueña de Extremadura',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Badajoz / Cáceres',
  ),
  VariedadOlivo(
    id: 'morisca_extremadura',
    nombreCanonico: 'Morisca',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Badajoz',
  ),
  VariedadOlivo(
    id: 'verdial_badajoz',
    nombreCanonico: 'Verdial de Badajoz',
    color: ColorAceituna.verde,
    uso: UsoOlivar.mesa,
    zonaPrincipal: 'Badajoz',
  ),
  VariedadOlivo(
    id: 'ocal',
    nombreCanonico: 'Ocal',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Badajoz / Cáceres',
  ),
  VariedadOlivo(
    id: 'torcio_cabra',
    nombreCanonico: 'Torcio de Cabra',
    color: ColorAceituna.negra,
    uso: UsoOlivar.almazara,
    zonaPrincipal: 'Sierras Subbéticas',
  ),
];

VariedadOlivo? variedadOlivoPorId(String id) {
  for (final v in catalogoVariedadesOlivo) {
    if (v.id == id) return v;
  }
  return null;
}

/// Búsqueda fuzzy: id exacto > nombre canónico > sinonimias.
List<VariedadOlivo> buscarVariedadesOlivo(String texto) {
  final q = _normalizar(texto);
  if (q.isEmpty) return const [];
  return catalogoVariedadesOlivo.where((v) {
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

