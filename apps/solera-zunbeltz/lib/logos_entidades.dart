/// Logos de las entidades que impulsan, apoyan y colaboran con Zunbeltz,
/// tal como salen en el pie de zunbeltz.com (de ahí se tomaron, el
/// 2026-10-13). Van teñidos en un solo color para que se lean sobre el
/// papel de la app.
///
/// Esta es la lista **de partida**, la que va dentro de la app. Coordinación
/// la cambia en el panel de WordPress (Solera Zunbeltz → Entidades y logos)
/// y la app baja la suya con `ServicioLogosEntidades`. Los logos de
/// partida se buscan por la clave en `assets/logos/<clave>.png`: así se ven
/// sin cobertura aunque la lista venga del servidor.
library;

import 'modelos/entidad_colaboradora.dart';

const String rutaLogoZunbeltz = 'assets/logos/zunbeltz.png';

/// Grupos del pie de la web, en su orden. El código es el del servidor.
enum GrupoEntidades {
  impulsan('impulsan'),
  apoyan('apoyan'),
  colaboran('colaboran'),
  miembroDe('miembro_de');

  const GrupoEntidades(this.codigo);

  final String codigo;

  static GrupoEntidades? desdeCodigo(String codigo) {
    for (final grupo in values) {
      if (grupo.codigo == codigo) return grupo;
    }
    return null;
  }
}

/// Claves que tienen logo empaquetado en `assets/logos/`.
const Set<String> clavesLogosEmpaquetados = {
  'andia',
  'abarzuza',
  'lezaun',
  'guesalaz',
  'yerri',
  'salinas',
  'carasso',
  'gobierno_navarra',
  'ue_feader',
  'miteco',
  'innova',
  'fundacion_la_caixa',
  'fundacion_caja_navarra',
  'cpaen',
  'upna',
  'ci_agroforestal',
  'reta',
  'kalaska',
  'deierriko_ostatua',
};

String rutaLogoEmpaquetado(String clave) => 'assets/logos/$clave.png';

const List<EntidadColaboradora> entidadesDePartida = [
  EntidadColaboradora(
      clave: 'andia', nombre: 'Mancomunidad de Andía', grupo: 'impulsan'),
  EntidadColaboradora(
      clave: 'abarzuza', nombre: 'Ayuntamiento de Abárzuza', grupo: 'impulsan'),
  EntidadColaboradora(
      clave: 'lezaun', nombre: 'Ayuntamiento de Lezaun', grupo: 'impulsan'),
  EntidadColaboradora(
      clave: 'guesalaz', nombre: 'Ayuntamiento de Guesálaz', grupo: 'impulsan'),
  EntidadColaboradora(
      clave: 'yerri', nombre: 'Ayuntamiento de Yerri', grupo: 'impulsan'),
  EntidadColaboradora(
      clave: 'salinas',
      nombre: 'Ayuntamiento de Salinas de Oro',
      grupo: 'impulsan'),
  EntidadColaboradora(
      clave: 'carasso',
      nombre: 'Fundación Daniel y Nina Carasso',
      grupo: 'apoyan'),
  EntidadColaboradora(
      clave: 'gobierno_navarra', nombre: 'Gobierno de Navarra', grupo: 'apoyan'),
  EntidadColaboradora(
      clave: 'ue_feader', nombre: 'Unión Europea · FEADER', grupo: 'apoyan'),
  EntidadColaboradora(
      clave: 'miteco',
      nombre: 'Ministerio para la Transición Ecológica y el Reto Demográfico',
      grupo: 'apoyan'),
  EntidadColaboradora(clave: 'innova', nombre: 'Innova', grupo: 'apoyan'),
  EntidadColaboradora(
      clave: 'fundacion_la_caixa',
      nombre: 'Fundación «la Caixa»',
      grupo: 'apoyan'),
  EntidadColaboradora(
      clave: 'fundacion_caja_navarra',
      nombre: 'Fundación Caja Navarra',
      grupo: 'apoyan'),
  EntidadColaboradora(
      clave: 'cpaen', nombre: 'CPAEN / NNPEK', grupo: 'colaboran'),
  EntidadColaboradora(
      clave: 'upna',
      nombre: 'Universidad Pública de Navarra',
      grupo: 'colaboran'),
  EntidadColaboradora(
      clave: 'ci_agroforestal', nombre: 'CI Agroforestal', grupo: 'colaboran'),
  EntidadColaboradora(
      clave: 'reta',
      nombre: 'Red de Espacios Test Agrarios',
      grupo: 'miembro_de'),
  EntidadColaboradora(clave: 'kalaska', nombre: 'Kalaska', grupo: 'miembro_de'),
  EntidadColaboradora(
      clave: 'deierriko_ostatua',
      nombre: 'Deierriko Ostatua',
      grupo: 'miembro_de'),
];

/// Los que van al pie de los informes PDF: quien gestiona las fincas, la
/// administración y los fondos públicos, el principal apoyo privado y la
/// red. Todos los grupos no caben en una franja legible.
const List<String> ficherosLogosPiePdf = [
  'andia',
  'gobierno_navarra',
  'ue_feader',
  'carasso',
  'reta',
];
