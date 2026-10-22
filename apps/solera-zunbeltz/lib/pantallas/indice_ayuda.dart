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
    'ayudaWidget',
    'ayudaActualizaciones',
  ],
  'ayudaGrupoFincas': [
    'ayudaFincas',
    'ayudaZonas',
    'ayudaEditarMapa',
    'ayudaImportar',
    'ayudaCierres',
    'ayudaTareas',
    'ayudaRecurrentes',
    'ayudaTablero',
  ],
  'ayudaGrupoGanado': [
    'ayudaGanadoLotes',
    'ayudaGanadoMover',
    'ayudaGanadoManejo',
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

/// Apartados que tienen además una versión para personas tester
/// (`<clave>TesterT` / `<clave>TesterB`): la pantalla enseña una u otra
/// según el rol y el manual imprime las dos.
const Set<String> apartadosConVersionTester = {
  'ayudaZonas',
  'ayudaEditarMapa',
  'ayudaTareas',
  'ayudaRecurrentes',
  'ayudaTablero',
};
