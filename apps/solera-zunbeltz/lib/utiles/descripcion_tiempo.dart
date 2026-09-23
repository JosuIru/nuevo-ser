/// Descripción bilingüe de los códigos de tiempo WMO que devuelve Open-Meteo
/// y de la dirección del viento. Euskera pendiente de revisión nativa, como
/// el resto de catálogos.
library;

/// Familia de cielo de un código WMO; la interfaz le asigna el icono.
enum FamiliaTiempo {
  despejado,
  pocoNuboso,
  cubierto,
  niebla,
  llovizna,
  lluvia,
  nieve,
  tormenta,
}

FamiliaTiempo familiaTiempo(int? codigo) {
  final c = codigo ?? 0;
  if (c <= 1) return FamiliaTiempo.despejado;
  if (c == 2) return FamiliaTiempo.pocoNuboso;
  if (c == 3) return FamiliaTiempo.cubierto;
  if (c == 45 || c == 48) return FamiliaTiempo.niebla;
  if (c >= 51 && c <= 57) return FamiliaTiempo.llovizna;
  if ((c >= 71 && c <= 77) || c == 85 || c == 86) return FamiliaTiempo.nieve;
  if (c >= 95) return FamiliaTiempo.tormenta;
  return FamiliaTiempo.lluvia; // 61-67, 80-82
}

String descripcionTiempo(int? codigo, String idioma) {
  final eu = idioma == 'eu';
  switch (codigo ?? 0) {
    case 0:
      return eu ? 'Oskarbi' : 'Despejado';
    case 1:
      return eu ? 'Ia oskarbi' : 'Casi despejado';
    case 2:
      return eu ? 'Hodei gutxi' : 'Poco nuboso';
    case 3:
      return eu ? 'Estalita' : 'Cubierto';
    case 45:
    case 48:
      return eu ? 'Lainoa' : 'Niebla';
    case 51:
    case 53:
    case 55:
      return eu ? 'Zirimiria' : 'Llovizna';
    case 56:
    case 57:
      return eu ? 'Zirimiri izoztua' : 'Llovizna helada';
    case 61:
    case 63:
      return eu ? 'Euria' : 'Lluvia';
    case 65:
      return eu ? 'Euri handia' : 'Lluvia fuerte';
    case 66:
    case 67:
      return eu ? 'Euri izoztua' : 'Lluvia helada';
    case 71:
    case 73:
    case 75:
      return eu ? 'Elurra' : 'Nieve';
    case 77:
      return eu ? 'Elur-aleak' : 'Granos de nieve';
    case 80:
    case 81:
      return eu ? 'Zaparradak' : 'Chubascos';
    case 82:
      return eu ? 'Zaparrada handiak' : 'Chubascos fuertes';
    case 85:
    case 86:
      return eu ? 'Elur-zaparradak' : 'Chubascos de nieve';
    case 95:
      return eu ? 'Ekaitza' : 'Tormenta';
    case 96:
    case 99:
      return eu ? 'Ekaitza txingorrarekin' : 'Tormenta con granizo';
    default:
      return '—';
  }
}

/// Punto cardinal (de 8) desde el que sopla el viento.
String direccionViento(double? grados, String idioma) {
  if (grados == null) return '';
  const castellano = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
  const euskera = ['I', 'IE', 'E', 'HE', 'H', 'HM', 'M', 'IM'];
  final sector = ((grados % 360) / 45).round() % 8;
  return (idioma == 'eu' ? euskera : castellano)[sector];
}
