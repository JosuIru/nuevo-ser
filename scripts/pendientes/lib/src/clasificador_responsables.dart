/// A quién se espera para desbloquear algo.
enum Responsable {
  asesorFiscal('Asesor fiscal'),
  asesorAgronomo('Asesor agrónomo'),
  tecnicoOca('Técnico OCA / PAC'),
  auditorAica('Auditor AICA'),
  veterinario('Veterinario / REGA'),
  apicultor('Apicultor asesor'),
  quesero('Quesero / inspector sanitario'),
  arborista('Arborista / ayuntamiento'),
  asesoriaLinguistica('Asesoría lingüística'),
  comiteHistorico('Comité histórico'),
  ilustracion('Ilustración / diseño'),
  musica('Música / sonido'),
  piloto('Grupo o centro piloto'),
  decisionPropia('Decisión propia (producto)'),
  sinClasificar('Sin clasificar');

  const Responsable(this.nombreVisible);

  final String nombreVisible;
}

/// Patrones sobre texto ya pasado por [quitarTildes]. `\b` delimita las
/// siglas cortas para no confundir «OCA» con «coloca».
final Map<Responsable, List<RegExp>> _patronesPorResponsable = {
  Responsable.asesorFiscal: _patrones([
    r'fiscal',
    r'\b347\b',
    r'reagp',
    r'\birpf\b',
    r'\biva\b',
    r'facturae',
    r'contab',
    r'libro economico',
    r'ingresos/gastos',
  ]),
  Responsable.asesorAgronomo: _patrones([
    r'agronom',
    r'enolog',
    r'fitosanitari',
    r'materias? activas?',
    r'\bbbch\b',
    r'fenolog',
    r'olivarer',
    r'plagas',
    r'portainjert',
  ]),
  Responsable.tecnicoOca: _patrones([
    r'\boca\b',
    r'cuaderno pac',
    r'libro oficial de tratamientos',
    r'1311/2012',
  ]),
  Responsable.auditorAica: _patrones([
    r'\baica\b',
    r'760/2021',
    r'libro de movimientos',
  ]),
  Responsable.veterinario: _patrones([
    r'veterinari',
    r'\brega\b',
    r'ganader',
    r'sanidad animal',
    r'crotal',
  ]),
  Responsable.apicultor: _patrones([r'apicultor', r'varroa']),
  Responsable.quesero: _patrones([
    r'queser',
    r'\bappcc\b',
    r'inspector',
    r'\baesan\b',
  ]),
  Responsable.arborista: _patrones([
    r'arborist',
    r'\bvta\b',
    r'parte municipal',
    r'tipos de poda',
  ]),
  Responsable.asesoriaLinguistica: _patrones([
    r'linguist',
    r'euskera',
    r'cooficial',
    r'revision nativa',
    r'\bnativ[oa]s?\b',
    r'traducci',
  ]),
  Responsable.comiteHistorico: _patrones([
    r'comite',
    r'histori',
    r'\bc14\b',
    r'dataci',
    r'guion canonico',
  ]),
  Responsable.ilustracion: _patrones([
    r'ilustrador',
    r'branding',
    r'\blogo',
    r'identidad visual',
  ]),
  Responsable.musica: _patrones([r'compositor', r'musica', r'banda sonora']),
  Responsable.piloto: _patrones([
    r'piloto',
    r'primera reunion',
    r'centros? escolar',
  ]),
  Responsable.decisionPropia: _patrones([
    r'monetizaci',
    r'modelo de negocio',
    r'applicationid',
    r'decision comercial',
    r'decision humana',
    r'precio',
  ]),
};

List<RegExp> _patrones(List<String> fuentes) =>
    [for (final fuente in fuentes) RegExp(fuente)];

/// Devuelve los responsables que aparecen en [texto], en el orden del enum.
/// Si no aparece ninguno, `[Responsable.sinClasificar]`.
List<Responsable> clasificarResponsables(String texto) {
  final textoNormalizado = quitarTildes(texto);
  final encontrados = [
    for (final entrada in _patronesPorResponsable.entries)
      if (entrada.value.any((patron) => patron.hasMatch(textoNormalizado)))
        entrada.key,
  ];
  return encontrados.isEmpty ? [Responsable.sinClasificar] : encontrados;
}

const Map<String, String> _sinTilde = {
  'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n',
  'à': 'a', 'è': 'e', 'ì': 'i', 'ò': 'o', 'ù': 'u', 'ç': 'c', 'ï': 'i',
};

/// Minúsculas y sin diacríticos (castellano, catalán, gallego, euskera).
String quitarTildes(String texto) {
  final minusculas = texto.toLowerCase();
  final resultado = StringBuffer();
  for (final caracter in minusculas.split('')) {
    resultado.write(_sinTilde[caracter] ?? caracter);
  }
  return resultado.toString();
}
