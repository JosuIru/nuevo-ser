import '../i18n/solera_l10n.dart';

/// Clave de [SoleraL10n] de cada texto (en castellano) del sistema de
/// actualizaciones.
const _clavesPorTextoEs = <String, String>{
  'Actualizaciones': 'core.act.titulo',
  'Versión instalada': 'core.act.version_instalada',
  'Última publicada': 'core.act.ultima_publicada',
  'sin conexión': 'core.act.sin_conexion',
  'ninguna todavía': 'core.act.ninguna_todavia',
  'Publicada el': 'core.act.publicada_el',
  'Comprobado el': 'core.act.comprobado_el',
  'Hay una versión nueva.': 'core.act.hay_version_nueva',
  'Tienes la última versión.': 'core.act.tienes_la_ultima',
  'Qué trae': 'core.act.que_trae',
  'Descargando…': 'core.act.descargando',
  'Descargar e instalar': 'core.act.descargar_e_instalar',
  'Buscar ahora': 'core.act.buscar_ahora',
  'Versión disponible': 'core.act.version_disponible',
  'Tienes instalada la': 'core.act.tienes_instalada',
  'Toca para actualizar.': 'core.act.toca_para_actualizar',
  'Actualizar': 'core.act.actualizar',
  'Descartar por ahora': 'core.act.descartar',
  'Se ha abierto el instalador. Confirma la actualización y vuelve a abrir la app.':
      'core.act.instalador_abierto',
  'Se ha abierto la descarga en el navegador.':
      'core.act.descarga_en_navegador',
  'No se ha podido descargar. Comprueba la conexión y vuelve a probar.':
      'core.act.error_descarga',
  'Descargada, pero Android no ha dejado abrir el instalador. Permite «instalar apps desconocidas» para esta app en los ajustes del móvil.':
      'core.act.error_instalador',
};

/// Traductor por defecto de los textos de actualizaciones: los pasa por
/// [SoleraL10n] en el idioma elegido. En las apps que no usan [SoleraL10n]
/// el idioma es siempre el castellano y el texto sale tal cual. Lo que no
/// reconoce lo devuelve igual.
String traducirActualizacionesSolera(String textoEs) {
  final clave = _clavesPorTextoEs[textoEs];
  return clave == null ? textoEs : SoleraL10n.t(clave);
}
