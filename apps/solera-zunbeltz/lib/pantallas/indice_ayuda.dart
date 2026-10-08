/// Grupos y apartados de la ayuda, en orden: grupo → claves base de sus
/// apartados (cada una tiene `<clave>T` título y `<clave>B` cuerpo en el
/// ARB).
///
/// Lo usa `tool/generar_manual.dart` para el manual imprimible, y
/// `test/pantalla_ayuda_test.dart` comprueba que la pantalla de Ayuda
/// muestra exactamente esto. Dart puro (sin Flutter) para que el generador
/// pueda importarlo con `dart run`.
library;

const Map<String, List<String>> indiceAyuda = {
  'ayudaGrupoEmpezar': [
    'ayudaQueEs',
    'ayudaPestanas',
    'ayudaIdiomaDatos',
    'ayudaHoyAvisos',
    'ayudaActualizaciones',
  ],
  'ayudaGrupoFincas': [
    'ayudaFincas',
    'ayudaZonas',
    'ayudaEditarMapa',
    'ayudaTareas',
    'ayudaRecurrentes',
    'ayudaTablero',
  ],
  'ayudaGrupoProyectos': [
    'ayudaProyectos',
    'ayudaApuntar',
    'ayudaNumeros',
    'ayudaConvenio',
    'ayudaCalculadora',
    'ayudaInformes',
  ],
  'ayudaGrupoEquipo': [
    'ayudaSync',
    'ayudaWeb',
    'ayudaRoles',
    'ayudaPeticiones',
    'ayudaContactos',
    'ayudaNotificaciones',
  ],
  'ayudaGrupoProblemas': ['ayudaProblemas'],
};
