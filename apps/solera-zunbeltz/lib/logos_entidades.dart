/// Logos de las entidades que impulsan, apoyan y colaboran con Zunbeltz,
/// tal como salen en el pie de zunbeltz.com (de ahí se tomaron, el
/// 2026-10-13). Van teñidos en un solo color para que se lean sobre el
/// papel de la app; si Zunbeltz pide los oficiales en color, se cambian
/// los ficheros de `assets/logos/` sin tocar el código.
library;

const String rutaLogoZunbeltz = 'assets/logos/zunbeltz.png';

class LogoEntidad {
  const LogoEntidad(this.nombre, this.fichero);

  final String nombre;
  final String fichero;

  String get ruta => 'assets/logos/$fichero.png';
}

/// Grupos del pie de la web, en su orden.
enum GrupoEntidades { impulsan, apoyan, colaboran, miembroDe }

const Map<GrupoEntidades, List<LogoEntidad>> logosPorGrupo = {
  GrupoEntidades.impulsan: [
    LogoEntidad('Mancomunidad de Andía', 'andia'),
    LogoEntidad('Ayuntamiento de Abárzuza', 'abarzuza'),
    LogoEntidad('Ayuntamiento de Lezaun', 'lezaun'),
    LogoEntidad('Ayuntamiento de Guesálaz', 'guesalaz'),
    LogoEntidad('Ayuntamiento de Yerri', 'yerri'),
    LogoEntidad('Ayuntamiento de Salinas de Oro', 'salinas'),
  ],
  GrupoEntidades.apoyan: [
    LogoEntidad('Fundación Daniel y Nina Carasso', 'carasso'),
    LogoEntidad('Gobierno de Navarra', 'gobierno_navarra'),
    LogoEntidad('Unión Europea · FEADER', 'ue_feader'),
    LogoEntidad('Ministerio para la Transición Ecológica y el Reto Demográfico',
        'miteco'),
    LogoEntidad('Innova', 'innova'),
    LogoEntidad('Fundación «la Caixa»', 'fundacion_la_caixa'),
    LogoEntidad('Fundación Caja Navarra', 'fundacion_caja_navarra'),
  ],
  GrupoEntidades.colaboran: [
    LogoEntidad('CPAEN / NNPEK', 'cpaen'),
    LogoEntidad('Universidad Pública de Navarra', 'upna'),
    LogoEntidad('CI Agroforestal', 'ci_agroforestal'),
  ],
  GrupoEntidades.miembroDe: [
    LogoEntidad('Red de Espacios Test Agrarios', 'reta'),
    LogoEntidad('Kalaska', 'kalaska'),
    LogoEntidad('Deierriko Ostatua', 'deierriko_ostatua'),
  ],
};

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
