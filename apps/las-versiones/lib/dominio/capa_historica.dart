/// Las ocho capas históricas del MVP (doc 05 §2, tabla de capas).
/// D-MOD y D-CONT quedan fuera del MVP.
enum CapaHistorica {
  paleo('D-PALEO', 'Paleolítica y Mesolítica'),
  neo('D-NEO', 'Neolítica y megalitos'),
  proto('D-PROTO', 'Edad del Bronce y del Hierro'),
  romana('D-ROMANA', 'Romana'),
  antiq('D-ANTIQ', 'Antigüedad Tardía'),
  form('D-FORM', 'Formación del Reino'),
  plena('D-PLENA', 'Navarra Plena'),
  dinastias('D-DINASTIAS', 'Dinastías francesas');

  const CapaHistorica(this.codigo, this.nombreVisible);

  /// Código del doc 05 (`D-NEO`…).
  final String codigo;
  final String nombreVisible;
}

/// Capa principal de cada Brecha jugable. Se usa para el color de los
/// acentos (doc 11 §2.3) y para elegir el fragmento musical (doc 12
/// §2.4); no se enseña como dato histórico.
///
/// Sale de cruzar el lugar de cada Brecha con la tabla de capas del
/// doc 05 (fechas de cada capa y «capa principal» de cada núcleo):
/// - 3.4 Roncesvalles → D-FORM: el doc 05 la ancla en la batalla de 778.
/// - 3.6 Tudela 1378 → D-DINASTIAS aunque sea del Arco 3: 1378 cae en
///   1234-1512.
const Map<String, CapaHistorica> capaPrincipalDeBrecha = {
  '1.1': CapaHistorica.neo, // dolmen de Aroztegi
  '1.2': CapaHistorica.neo, // crómlech
  '1.3': CapaHistorica.paleo, // cueva con grabados
  '1.4': CapaHistorica.proto, // Irulegi, poblado fortificado
  '2.1': CapaHistorica.romana, // ara de Aelio Attiano
  '2.2': CapaHistorica.romana, // Quintiliano de Calagurris
  '2.3': CapaHistorica.romana, // domus de los mosaicos
  '2.4': CapaHistorica.antiq, // Wamba contra los vascones
  '3.1': CapaHistorica.plena, // San Cernin, fuero de 1129
  '3.3': CapaHistorica.form, // Leyre, abad Virila
  '3.4': CapaHistorica.form, // Roncesvalles, 778
  '3.5': CapaHistorica.plena, // Estella en su esplendor
  '3.6': CapaHistorica.dinastias, // Tudela, 1378
  '4.1': CapaHistorica.dinastias, // Joana de Roncal, Olite
  '4.B': CapaHistorica.dinastias, // pared medianera de Estella, 1394
};
