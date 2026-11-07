// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/aceitera/do_aceite.csv
// Generado: 2026-11-07
// Filas: 29 (0 firmadas por persona, 29 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR AGRONÓMICAMENTE.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-aceitera && dart run tool/compilar_catalogos.dart

class DopAceite {
  final String id;
  final String nombreCanonico;
  final String provincia;
  /// IDs de variedades_olivo principales del pliego.
  final List<String> variedadesPrincipales;
  /// Acidez máxima permitida (grados sobre 100 g de aceite).
  final double? acidezMax;
  final String notas;

  const DopAceite({
    required this.id,
    required this.nombreCanonico,
    required this.provincia,
    required this.variedadesPrincipales,
    this.acidezMax,
    this.notas = '',
  });
}

const List<DopAceite> catalogoDopAceite = [
  DopAceite(
    id: 'dop_aceite_de_la_alcarria',
    nombreCanonico: 'Aceite de la Alcarria',
    provincia: 'Cuenca / Guadalajara',
    variedadesPrincipales: ['castellana'],
    acidezMax: 0.5,
    notas: 'DOP centro peninsular; producción limitada',
  ),
  DopAceite(
    id: 'dop_aceite_de_la_rioja',
    nombreCanonico: 'Aceite de La Rioja',
    provincia: 'La Rioja',
    variedadesPrincipales: ['arroniz'],
    acidezMax: 0.8,
    notas: 'Variedad arróniz como base característica',
  ),
  DopAceite(
    id: 'dop_aceite_de_lucena',
    nombreCanonico: 'Aceite de Lucena',
    provincia: 'Córdoba',
    variedadesPrincipales: ['hojiblanca', 'picudo'],
    acidezMax: 0.5,
    notas: 'Subbética cordobesa',
  ),
  DopAceite(
    id: 'dop_aceite_de_mallorca',
    nombreCanonico: 'Aceite de Mallorca',
    provincia: 'Mallorca',
    variedadesPrincipales: ['mallorquina_mallorquina'],
    acidezMax: 0.4,
    notas: 'Predominio empeltre mallorquí',
  ),
  DopAceite(
    id: 'dop_aceite_del_baix_ebre_montsia',
    nombreCanonico: 'Aceite del Baix Ebre-Montsià',
    provincia: 'Tarragona',
    variedadesPrincipales: ['morrut', 'sevillenca', 'farga'],
    acidezMax: 0.5,
    notas: 'Sur Cataluña',
  ),
  DopAceite(
    id: 'dop_aceite_del_bajo_aragon',
    nombreCanonico: 'Aceite del Bajo Aragón',
    provincia: 'Teruel / Zaragoza',
    variedadesPrincipales: ['empeltre'],
    acidezMax: 0.5,
    notas: 'Empeltre dominante',
  ),
  DopAceite(
    id: 'dop_aceite_del_emporda',
    nombreCanonico: 'Aceite del Empordà',
    provincia: 'Girona',
    variedadesPrincipales: ['argudell', 'corbella'],
    acidezMax: 0.5,
    notas: 'Cataluña norte',
  ),
  DopAceite(
    id: 'dop_aceite_de_madrid',
    nombreCanonico: 'Aceite de Madrid',
    provincia: 'Madrid',
    variedadesPrincipales: ['cornicabra', 'castellana'],
    acidezMax: 0.5,
    notas: 'Comunidad de Madrid',
  ),
  DopAceite(
    id: 'dop_aceite_de_navarra',
    nombreCanonico: 'Aceite de Navarra',
    provincia: 'Navarra',
    variedadesPrincipales: ['arroniz'],
    acidezMax: 0.8,
    notas: 'Producción ligada a la variedad local arróniz',
  ),
  DopAceite(
    id: 'dop_aceite_de_terra_alta',
    nombreCanonico: 'Aceite de Terra Alta',
    provincia: 'Tarragona',
    variedadesPrincipales: ['empeltre'],
    acidezMax: 0.5,
    notas: 'Sur Cataluña interior',
  ),
  DopAceite(
    id: 'dop_aceite_monterrubio',
    nombreCanonico: 'Aceite Monterrubio',
    provincia: 'Badajoz',
    variedadesPrincipales: ['cornezuelo', 'jabata'],
    acidezMax: 0.8,
    notas: 'Comarca de La Serena',
  ),
  DopAceite(
    id: 'dop_baena',
    nombreCanonico: 'Baena',
    provincia: 'Córdoba',
    variedadesPrincipales: ['picudo', 'hojiblanca', 'picual'],
    acidezMax: 0.5,
    notas: 'Subbética cordobesa',
  ),
  DopAceite(
    id: 'dop_estepa',
    nombreCanonico: 'Estepa',
    provincia: 'Sevilla',
    variedadesPrincipales: ['hojiblanca', 'arbequina'],
    acidezMax: 0.3,
    notas: 'Pliego restrictivo en acidez',
  ),
  DopAceite(
    id: 'dop_gata_hurdes',
    nombreCanonico: 'Gata-Hurdes',
    provincia: 'Cáceres',
    variedadesPrincipales: ['manzanilla_cacerena'],
    acidezMax: 0.5,
    notas: 'Norte de Extremadura',
  ),
  DopAceite(
    id: 'dop_les_garrigues',
    nombreCanonico: 'Les Garrigues',
    provincia: 'Lleida',
    variedadesPrincipales: ['arbequina', 'verdiell'],
    acidezMax: 0.5,
    notas: 'Cataluña interior; arbequina histórica',
  ),
  DopAceite(
    id: 'dop_montes_de_granada',
    nombreCanonico: 'Montes de Granada',
    provincia: 'Granada',
    variedadesPrincipales: ['picual', 'loaime'],
    acidezMax: 0.5,
    notas: 'Norte de Granada',
  ),
  DopAceite(
    id: 'dop_montes_de_toledo',
    nombreCanonico: 'Montes de Toledo',
    provincia: 'Toledo / Ciudad Real',
    variedadesPrincipales: ['cornicabra'],
    acidezMax: 0.7,
    notas: 'Cornicabra como variedad principal',
  ),
  DopAceite(
    id: 'dop_montoro_adamuz',
    nombreCanonico: 'Montoro-Adamuz',
    provincia: 'Córdoba',
    variedadesPrincipales: ['nevadillo_negro', 'picual'],
    acidezMax: 0.5,
    notas: 'Sierra cordobesa',
  ),
  DopAceite(
    id: 'dop_oli_de_lurgell',
    nombreCanonico: 'Oli de l\'Urgell',
    provincia: 'Lleida',
    variedadesPrincipales: ['arbequina'],
    acidezMax: 0.5,
    notas: 'Llanura urgelense',
  ),
  DopAceite(
    id: 'dop_priego_de_cordoba',
    nombreCanonico: 'Priego de Córdoba',
    provincia: 'Córdoba',
    variedadesPrincipales: ['picuda', 'hojiblanca', 'picual'],
    acidezMax: 0.3,
    notas: 'Pliego restrictivo en acidez',
  ),
  DopAceite(
    id: 'dop_poniente_de_granada',
    nombreCanonico: 'Poniente de Granada',
    provincia: 'Granada',
    variedadesPrincipales: ['picual', 'hojiblanca'],
    acidezMax: 0.8,
    notas: 'Loja - Alhama',
  ),
  DopAceite(
    id: 'dop_sierra_de_cadiz',
    nombreCanonico: 'Sierra de Cádiz',
    provincia: 'Cádiz',
    variedadesPrincipales: ['lechin_sevilla', 'manzanillo_cadiz'],
    acidezMax: 0.7,
    notas: 'Sur Andalucía',
  ),
  DopAceite(
    id: 'dop_sierra_de_cazorla',
    nombreCanonico: 'Sierra de Cazorla',
    provincia: 'Jaén',
    variedadesPrincipales: ['picual', 'royal_cazorla'],
    acidezMax: 0.5,
    notas: 'Picual + variedad local royal',
  ),
  DopAceite(
    id: 'dop_sierra_de_segura',
    nombreCanonico: 'Sierra de Segura',
    provincia: 'Jaén',
    variedadesPrincipales: ['picual'],
    acidezMax: 0.5,
    notas: 'Picual jiennense',
  ),
  DopAceite(
    id: 'dop_sierra_magina',
    nombreCanonico: 'Sierra Mágina',
    provincia: 'Jaén',
    variedadesPrincipales: ['picual'],
    acidezMax: 0.5,
    notas: 'Picual de altura',
  ),
  DopAceite(
    id: 'dop_siurana',
    nombreCanonico: 'Siurana',
    provincia: 'Tarragona',
    variedadesPrincipales: ['arbequina'],
    acidezMax: 0.5,
    notas: 'Cataluña; cuna histórica de la arbequina',
  ),
  DopAceite(
    id: 'dop_aceite_campo_calatrava',
    nombreCanonico: 'Aceite Campo de Calatrava',
    provincia: 'Ciudad Real',
    variedadesPrincipales: ['cornicabra', 'picual'],
    acidezMax: 0.7,
    notas: 'La Mancha occidental',
  ),
  DopAceite(
    id: 'dop_aceite_campo_montiel',
    nombreCanonico: 'Aceite Campo de Montiel',
    provincia: 'Ciudad Real / Albacete',
    variedadesPrincipales: ['cornicabra'],
    acidezMax: 0.7,
    notas: 'La Mancha sur',
  ),
  DopAceite(
    id: 'dop_antequera',
    nombreCanonico: 'Antequera',
    provincia: 'Málaga',
    variedadesPrincipales: ['hojiblanca'],
    acidezMax: 0.5,
    notas: 'Comarca de Antequera',
  ),
];

DopAceite? dopAceitePorId(String id) {
  for (final d in catalogoDopAceite) {
    if (d.id == id) return d;
  }
  return null;
}

List<DopAceite> buscarDopAceite(String texto) {
  final q = _normalizar(texto);
  if (q.isEmpty) return const [];
  return catalogoDopAceite.where((d) {
    return _normalizar(d.nombreCanonico).contains(q) ||
        _normalizar(d.provincia).contains(q) ||
        _normalizar(d.id).contains(q);
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

