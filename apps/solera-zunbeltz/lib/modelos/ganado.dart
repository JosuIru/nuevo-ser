import 'constantes.dart';

/// El ganado de las fincas (FZ-4, primera versión para probar con
/// Zunbeltz): **lotes** (el rebaño o grupo que se maneja junto), **animales**
/// identificados con su crotal, **movimientos** de un lote entre piezas (o
/// fuera del espacio: a la sierra, al matadero) y **eventos** de manejo
/// (curas y tratamientos, pesajes, partos, incidencias).
///
/// En extensivo el ganado se mueve por lotes, así que un movimiento es de
/// un lote entero; un animal cambia de sitio cambiando de lote. Dónde está
/// un lote no se guarda: es el destino de su último movimiento, de modo que
/// el historial y la ubicación no pueden contradecirse.
///
/// **Hard limit de la suite**: la app no recomienda medicamentos. En un
/// tratamiento se apunta la sustancia activa, la dosis y los plazos de
/// supresión que marca la receta del veterinario; la app solo avisa de
/// cuándo terminan. Todo PROVISIONAL hasta co-diseñarlo con Zunbeltz.

/// Grupo de animales que se maneja junto (rebaño, lote de cerdos…).
class LoteGanado {
  LoteGanado({
    this.id,
    this.nombre = '',
    this.especie = '',
    this.titularUid = '',
    this.cabezasSinIdentificar = 0,
    this.estado = estadoLoteActivo,
    this.notas = '',
    this.autorUid = '',
    this.fechaCreacionMs = 0,
  });

  final int? id;
  final String nombre;

  /// Código de `especiesGanado`.
  final String especie;

  /// Persona del espacio de quien es el ganado; vacío = del espacio.
  final String titularUid;

  /// Cabezas que no se llevan una a una (aves, cerdos de cebo…): cuentan
  /// en el lote sin ficha propia.
  final int cabezasSinIdentificar;

  /// `activo` o `cerrado` (el lote ya no existe: se vendió, se deshizo).
  final String estado;
  final String notas;
  final String autorUid;
  final int fechaCreacionMs;

  bool get activo => estado != estadoLoteCerrado;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'especie': especie,
        'titular_uid': titularUid,
        'cabezas_sin_identificar': cabezasSinIdentificar,
        'estado': estado,
        'notas': notas,
        'autor_uid': autorUid,
        'fecha_creacion_ms': fechaCreacionMs,
      };

  factory LoteGanado.fromMap(Map<String, Object?> mapa) => LoteGanado(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        especie: (mapa['especie'] as String?) ?? '',
        titularUid: (mapa['titular_uid'] as String?) ?? '',
        cabezasSinIdentificar:
            (mapa['cabezas_sin_identificar'] as num?)?.toInt() ?? 0,
        estado: (mapa['estado'] as String?) ?? estadoLoteActivo,
        notas: (mapa['notas'] as String?) ?? '',
        autorUid: (mapa['autor_uid'] as String?) ?? '',
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as num?)?.toInt() ?? 0,
      );
}

const String estadoLoteActivo = 'activo';
const String estadoLoteCerrado = 'cerrado';

/// Un animal identificado (crotal / DIB / REIA).
class Animal {
  Animal({
    this.id,
    this.identificacion = '',
    this.nombre = '',
    this.especie = '',
    this.raza = '',
    this.sexo = '',
    this.fechaNacimientoMs,
    this.madre = '',
    this.loteId,
    this.estado = estadoAnimalActivo,
    this.fechaBajaMs,
    this.titularUid = '',
    this.notas = '',
    this.autorUid = '',
  });

  final int? id;

  /// Crotal o número de identificación oficial.
  final String identificacion;

  /// Nombre o apodo, si lo tiene.
  final String nombre;
  final String especie;
  final String raza;

  /// Código de `sexosAnimal`; vacío = sin indicar.
  final String sexo;
  final int? fechaNacimientoMs;

  /// Identificación de la madre, si se conoce.
  final String madre;
  final int? loteId;

  /// Código de `estadosAnimal`.
  final String estado;

  /// Cuándo salió (venta, muerte, baja).
  final int? fechaBajaMs;
  final String titularUid;
  final String notas;
  final String autorUid;

  bool get activo => estado == estadoAnimalActivo;

  /// Cómo se nombra en listas: «ES123… · Morena».
  String get rotulo => [
        if (identificacion.isNotEmpty) identificacion,
        if (nombre.isNotEmpty) nombre,
      ].join(' · ');

  Map<String, Object?> toMap() => {
        'id': id,
        'identificacion': identificacion,
        'nombre': nombre,
        'especie': especie,
        'raza': raza,
        'sexo': sexo,
        'fecha_nacimiento_ms': fechaNacimientoMs,
        'madre': madre,
        'lote_id': loteId,
        'estado': estado,
        'fecha_baja_ms': fechaBajaMs,
        'titular_uid': titularUid,
        'notas': notas,
        'autor_uid': autorUid,
      };

  factory Animal.fromMap(Map<String, Object?> mapa) => Animal(
        id: mapa['id'] as int?,
        identificacion: (mapa['identificacion'] as String?) ?? '',
        nombre: (mapa['nombre'] as String?) ?? '',
        especie: (mapa['especie'] as String?) ?? '',
        raza: (mapa['raza'] as String?) ?? '',
        sexo: (mapa['sexo'] as String?) ?? '',
        fechaNacimientoMs: (mapa['fecha_nacimiento_ms'] as num?)?.toInt(),
        madre: (mapa['madre'] as String?) ?? '',
        loteId: mapa['lote_id'] as int?,
        estado: (mapa['estado'] as String?) ?? estadoAnimalActivo,
        fechaBajaMs: (mapa['fecha_baja_ms'] as num?)?.toInt(),
        titularUid: (mapa['titular_uid'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
        autorUid: (mapa['autor_uid'] as String?) ?? '',
      );
}

const String estadoAnimalActivo = 'activo';

/// Movimiento de un lote: de una pieza a otra, entrada en el espacio o
/// salida (a la sierra, a otra explotación, al matadero).
class MovimientoGanado {
  MovimientoGanado({
    this.id,
    required this.loteId,
    required this.fechaMs,
    this.tipo = tipoMovimientoTraslado,
    this.zonaOrigenId,
    this.zonaDestinoId,
    this.destinoExterno = '',
    this.cabezas = 0,
    this.guia = '',
    this.notas = '',
    this.autorUid = '',
  });

  final int? id;
  final int loteId;
  final int fechaMs;

  /// Código de `tiposMovimientoGanado`.
  final String tipo;
  final int? zonaOrigenId;

  /// Pieza a la que va; null en una salida.
  final int? zonaDestinoId;

  /// Adónde sale o de dónde entra, si es fuera del espacio.
  final String destinoExterno;

  /// Cabezas que se movieron (lo que tenía el lote en ese momento).
  final int cabezas;

  /// Número de guía de movimiento, si la lleva.
  final String guia;
  final String notas;
  final String autorUid;

  bool get esSalida => tipo == tipoMovimientoSalida;

  Map<String, Object?> toMap() => {
        'id': id,
        'lote_id': loteId,
        'fecha_ms': fechaMs,
        'tipo': tipo,
        'zona_origen_id': zonaOrigenId,
        'zona_destino_id': zonaDestinoId,
        'destino_externo': destinoExterno,
        'cabezas': cabezas,
        'guia': guia,
        'notas': notas,
        'autor_uid': autorUid,
      };

  factory MovimientoGanado.fromMap(Map<String, Object?> mapa) =>
      MovimientoGanado(
        id: mapa['id'] as int?,
        loteId: (mapa['lote_id'] as int?) ?? 0,
        fechaMs: (mapa['fecha_ms'] as num?)?.toInt() ?? 0,
        tipo: (mapa['tipo'] as String?) ?? tipoMovimientoTraslado,
        zonaOrigenId: mapa['zona_origen_id'] as int?,
        zonaDestinoId: mapa['zona_destino_id'] as int?,
        destinoExterno: (mapa['destino_externo'] as String?) ?? '',
        cabezas: (mapa['cabezas'] as num?)?.toInt() ?? 0,
        guia: (mapa['guia'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
        autorUid: (mapa['autor_uid'] as String?) ?? '',
      );
}

const String tipoMovimientoTraslado = 'traslado';
const String tipoMovimientoEntrada = 'entrada';
const String tipoMovimientoSalida = 'salida';

/// Algo que se le hace o le pasa a un animal o a un lote entero.
class EventoGanado {
  EventoGanado({
    this.id,
    this.animalId,
    this.loteId,
    required this.fechaMs,
    this.tipo = tipoEventoTratamiento,
    this.descripcion = '',
    this.sustanciaActiva = '',
    this.dosis = '',
    this.plazoSupresionCarneDias = 0,
    this.plazoSupresionLecheDias = 0,
    this.veterinario = '',
    this.receta = '',
    this.pesoKg,
    this.crias = 0,
    this.cabezas = 0,
    this.autorUid = '',
  });

  final int? id;

  /// Del animal, o del lote entero si [animalId] es null.
  final int? animalId;
  final int? loteId;
  final int fechaMs;

  /// Código de `tiposEventoGanado`.
  final String tipo;
  final String descripcion;

  /// Tratamiento: lo que pone la receta. Nunca lo sugiere la app.
  final String sustanciaActiva;
  final String dosis;
  final int plazoSupresionCarneDias;
  final int plazoSupresionLecheDias;
  final String veterinario;

  /// Número de receta.
  final String receta;

  /// Pesaje.
  final double? pesoKg;

  /// Parto: crías nacidas.
  final int crias;

  /// En un lote: cuántas cabezas se trataron (0 = todas).
  final int cabezas;
  final String autorUid;

  Map<String, Object?> toMap() => {
        'id': id,
        'animal_id': animalId,
        'lote_id': loteId,
        'fecha_ms': fechaMs,
        'tipo': tipo,
        'descripcion': descripcion,
        'sustancia_activa': sustanciaActiva,
        'dosis': dosis,
        'plazo_supresion_carne_dias': plazoSupresionCarneDias,
        'plazo_supresion_leche_dias': plazoSupresionLecheDias,
        'veterinario': veterinario,
        'receta': receta,
        'peso_kg': pesoKg,
        'crias': crias,
        'cabezas': cabezas,
        'autor_uid': autorUid,
      };

  factory EventoGanado.fromMap(Map<String, Object?> mapa) => EventoGanado(
        id: mapa['id'] as int?,
        animalId: mapa['animal_id'] as int?,
        loteId: mapa['lote_id'] as int?,
        fechaMs: (mapa['fecha_ms'] as num?)?.toInt() ?? 0,
        tipo: (mapa['tipo'] as String?) ?? tipoEventoTratamiento,
        descripcion: (mapa['descripcion'] as String?) ?? '',
        sustanciaActiva: (mapa['sustancia_activa'] as String?) ?? '',
        dosis: (mapa['dosis'] as String?) ?? '',
        plazoSupresionCarneDias:
            (mapa['plazo_supresion_carne_dias'] as num?)?.toInt() ?? 0,
        plazoSupresionLecheDias:
            (mapa['plazo_supresion_leche_dias'] as num?)?.toInt() ?? 0,
        veterinario: (mapa['veterinario'] as String?) ?? '',
        receta: (mapa['receta'] as String?) ?? '',
        pesoKg: (mapa['peso_kg'] as num?)?.toDouble(),
        crias: (mapa['crias'] as num?)?.toInt() ?? 0,
        cabezas: (mapa['cabezas'] as num?)?.toInt() ?? 0,
        autorUid: (mapa['autor_uid'] as String?) ?? '',
      );
}

const String tipoEventoTratamiento = 'tratamiento';
const String tipoEventoPesaje = 'pesaje';
const String tipoEventoParto = 'parto';

// ─── Catálogos (euskera: borrador pendiente de revisión nativa) ───

const List<OpcionCatalogo> sexosAnimal = [
  OpcionCatalogo('hembra', 'Hembra', 'Emea'),
  OpcionCatalogo('macho', 'Macho', 'Arra'),
  OpcionCatalogo('castrado', 'Castrado', 'Zikiratua'),
];

const List<OpcionCatalogo> estadosAnimal = [
  OpcionCatalogo(estadoAnimalActivo, 'En el espacio', 'Espazioan'),
  OpcionCatalogo('vendido', 'Vendido', 'Saldua'),
  OpcionCatalogo('sacrificado', 'Sacrificado', 'Hilda (hiltegian)'),
  OpcionCatalogo('muerto', 'Muerto', 'Hila'),
  OpcionCatalogo(
      'baja', 'Baja por otro motivo', 'Beste arrazoi batengatik baja'),
];

const List<OpcionCatalogo> tiposMovimientoGanado = [
  OpcionCatalogo(tipoMovimientoTraslado, 'Cambio de pieza', 'Sail-aldaketa'),
  OpcionCatalogo(
      tipoMovimientoEntrada, 'Entrada en el espacio', 'Espaziora sarrera'),
  OpcionCatalogo(
      tipoMovimientoSalida, 'Salida del espacio', 'Espaziotik irteera'),
];

const List<OpcionCatalogo> tiposEventoGanado = [
  OpcionCatalogo(
      tipoEventoTratamiento, 'Cura o tratamiento', 'Sendaketa edo tratamendua'),
  OpcionCatalogo(
      'saneamiento', 'Saneamiento / vacunación', 'Saneamendua / txertaketa'),
  OpcionCatalogo(tipoEventoPesaje, 'Pesaje', 'Pisaketa'),
  OpcionCatalogo(tipoEventoParto, 'Parto', 'Erditzea'),
  OpcionCatalogo('incidencia', 'Incidencia (cojera, herida, ataque…)',
      'Gorabehera (herrena, zauria, erasoa…)'),
  OpcionCatalogo('otro', 'Otro manejo', 'Beste maneiu bat'),
];

/// Tipos de evento que llevan sustancia, dosis y plazos de supresión.
const Set<String> tiposEventoConMedicamento = {
  tipoEventoTratamiento,
  'saneamiento',
};

// ─── Cálculos ───

/// El último movimiento (por fecha; a igual fecha, el último apuntado), que
/// dice dónde está el lote. Null si nunca se ha movido.
MovimientoGanado? ultimoMovimiento(Iterable<MovimientoGanado> movimientos) {
  MovimientoGanado? ultimo;
  for (final movimiento in movimientos) {
    if (ultimo == null ||
        movimiento.fechaMs > ultimo.fechaMs ||
        (movimiento.fechaMs == ultimo.fechaMs &&
            (movimiento.id ?? 0) > (ultimo.id ?? 0))) {
      ultimo = movimiento;
    }
  }
  return ultimo;
}

/// Pieza en la que está el lote: el destino de su último movimiento (null
/// si ha salido del espacio o no se sabe).
int? zonaActualDeLote(Iterable<MovimientoGanado> movimientos) {
  final ultimo = ultimoMovimiento(movimientos);
  if (ultimo == null || ultimo.esSalida) return null;
  return ultimo.zonaDestinoId;
}

/// Cabezas de un lote: sus animales en el espacio más las que no se llevan
/// una a una.
int cabezasDeLote(LoteGanado lote, Iterable<Animal> animalesDelLote) =>
    animalesDelLote.where((animal) => animal.activo).length +
    lote.cabezasSinIdentificar;

/// Día (local) en que termina un plazo de [dias] contado desde [fechaMs]:
/// días de calendario, sin que el cambio de hora lo descuadre.
DateTime finDePlazo(int fechaMs, int dias) {
  final fecha = DateTime.fromMillisecondsSinceEpoch(fechaMs);
  return DateTime(fecha.year, fecha.month, fecha.day + dias);
}

/// Hasta cuándo no puede ir a matadero (carne) o venderse la leche lo
/// tratado. Null si no hay plazo vigente en [ahora].
class SupresionVigente {
  const SupresionVigente({this.carneHasta, this.lecheHasta});

  final DateTime? carneHasta;
  final DateTime? lecheHasta;

  bool get hayAlguna => carneHasta != null || lecheHasta != null;
}

/// La supresión que sigue vigente en [ahora] por los [eventos] (los de un
/// animal y los de su lote): el final más tardío de cada plazo.
SupresionVigente supresionVigente(
    Iterable<EventoGanado> eventos, DateTime ahora) {
  DateTime? carne;
  DateTime? leche;
  final hoy = DateTime(ahora.year, ahora.month, ahora.day);
  for (final evento in eventos) {
    if (evento.plazoSupresionCarneDias > 0) {
      final fin = finDePlazo(evento.fechaMs, evento.plazoSupresionCarneDias);
      if (fin.isAfter(hoy) && (carne == null || fin.isAfter(carne))) {
        carne = fin;
      }
    }
    if (evento.plazoSupresionLecheDias > 0) {
      final fin = finDePlazo(evento.fechaMs, evento.plazoSupresionLecheDias);
      if (fin.isAfter(hoy) && (leche == null || fin.isAfter(leche))) {
        leche = fin;
      }
    }
  }
  return SupresionVigente(carneHasta: carne, lecheHasta: leche);
}
