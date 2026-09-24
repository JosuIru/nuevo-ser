import 'catalogo_minijuegos.dart';

/// El reto de Rexán (semanal): una máquina que el niño ya tiene, con una
/// ronda especial fija toda la semana. Sin tabla de récords ni rachas
/// que se pierden: aparece un cartel en la sala y ya está.
///
/// Cada especial pide haber practicado alguna de sus [habilidades]: el
/// reto repasa lo visto, no estrena nada.
enum EspecialSemanal {
  atasco,
  ruedaLoca,
  bajoCero,
  puenteRoto,
  soloDivisores,
  sinTransportador,
  dobleNegacion,
  casaCompleta,
}

class DefinicionEspecial {
  final EspecialSemanal especial;
  final IdMinijuego maquina;
  final String nombre;
  final String descripcion;

  /// Basta con haber practicado una. Son también las que se juegan
  /// (cuando la máquina recibe la lista de habilidades).
  final List<String> habilidades;

  const DefinicionEspecial({
    required this.especial,
    required this.maquina,
    required this.nombre,
    required this.descripcion,
    required this.habilidades,
  });
}

const especialesSemanales = <DefinicionEspecial>[
  DefinicionEspecial(
    especial: EspecialSemanal.atasco,
    maquina: IdMinijuego.esclusas,
    nombre: 'El atasco',
    descripcion: 'Las barcas se han quedado quietas en el canal, de tres en '
        'tres. Nada corre: ordénalas de menor a mayor con calma.',
    habilidades: ['FR.08', 'DEC.03'],
  ),
  DefinicionEspecial(
    especial: EspecialSemanal.ruedaLoca,
    maquina: IdMinijuego.engranajes,
    nombre: 'La rueda loca',
    descripcion: 'Una de las ruedas tiene un número primo de dientes. Es de '
        'las cabezotas: casi nunca coincide con la otra.',
    habilidades: ['DIV.07'],
  ),
  DefinicionEspecial(
    especial: EspecialSemanal.bajoCero,
    maquina: IdMinijuego.serpiente,
    nombre: 'Bajo cero',
    descripcion: 'Esta semana la Serpiente sólo come cuentas que cruzan el '
        'cero. Cuidado con el signo.',
    habilidades: ['ARI.04'],
  ),
  DefinicionEspecial(
    especial: EspecialSemanal.puenteRoto,
    maquina: IdMinijuego.puentes,
    nombre: 'Los puentes rotos',
    descripcion: 'Todos los puentes salen largos. Quita justo lo que sobra.',
    habilidades: ['FR.15', 'FR.17'],
  ),
  DefinicionEspecial(
    especial: EspecialSemanal.soloDivisores,
    maquina: IdMinijuego.minas,
    nombre: 'Tierra de divisores',
    descripcion: 'En todos los tableros, las minas son los divisores de un '
        'número. Búscalos por parejas.',
    habilidades: ['DIV.02'],
  ),
  DefinicionEspecial(
    especial: EspecialSemanal.sinTransportador,
    maquina: IdMinijuego.rebote,
    nombre: 'Sin transportador',
    descripcion: 'Los ángulos se miden a ojo. Luego aparece el transportador '
        'y compruebas. Esta semana no puntúa: es para afinar el ojo.',
    habilidades: ['MED.04'],
  ),
  DefinicionEspecial(
    especial: EspecialSemanal.dobleNegacion,
    maquina: IdMinijuego.pozo,
    nombre: 'La doble negación',
    descripcion: 'Todos los viajes llevan un −(−n). Dos noes en la mina '
        'significan sí.',
    habilidades: ['ARI.04'],
  ),
  DefinicionEspecial(
    especial: EspecialSemanal.casaCompleta,
    maquina: IdMinijuego.planos,
    nombre: 'Casa completa',
    descripcion: 'Tres habitaciones que sumen justo lo que pide el encargo, '
        'sin pisarse ni pisar la maleza.',
    habilidades: ['GEO.03'],
  ),
];

/// Número de semana estable (lunes a domingo), contado desde una fecha
/// fija. Sirve para que el reto cambie cada lunes y sea el mismo toda la
/// semana en cualquier dispositivo.
int numeroDeSemana(DateTime fecha) {
  final dia = DateTime.utc(fecha.year, fecha.month, fecha.day);
  // 1970-01-05 fue lunes.
  return dia.difference(DateTime.utc(1970, 1, 5)).inDays ~/ 7;
}

/// El reto de la semana de [fecha], o null si ninguna especial está al
/// alcance. [practicadasPorMaquina]: las habilidades practicadas de cada
/// máquina encendida.
DefinicionEspecial? retoDeLaSemana(
    DateTime fecha, Map<IdMinijuego, List<String>> practicadasPorMaquina) {
  final semana = numeroDeSemana(fecha);
  for (var i = 0; i < especialesSemanales.length; i++) {
    final candidata = especialesSemanales[(semana + i) % especialesSemanales.length];
    if (habilidadesDelReto(candidata, practicadasPorMaquina[candidata.maquina] ?? const []).isNotEmpty) {
      return candidata;
    }
  }
  return null;
}

/// Las habilidades que el reto juega: las suyas que el niño ya practicó.
List<String> habilidadesDelReto(DefinicionEspecial reto, List<String> practicadas) =>
    [for (final id in reto.habilidades) if (practicadas.contains(id)) id];
