import 'carga_ganadera.dart';
import 'ganado_ecologico.dart';

/// El ganado de la explotación: **rebaños** (el lote que se maneja junto),
/// **animales** identificados, **movimientos** de un rebaño entre piezas de
/// pasto (o fuera de la explotación) y **eventos** de manejo.
///
/// Copiado de Zunbeltz (`apps/solera-zunbeltz/lib/modelos/ganado.dart`,
/// commit `92ade2b`) sin sincronización ni permisos: sin `titular_uid` ni
/// `autor_uid` (la F1 es de un solo dispositivo). Cambios respecto al
/// original:
/// - las «zonas» son **piezas de pasto** (`pieza_origen_id`/`pieza_destino_id`);
/// - el movimiento lleva los datos del anexo de RD 728/2007 que modifica la
///   disposición final 3.ª del RD 787/2023 (explotación externa, código REMO,
///   transporte, certificado sanitario);
/// - hay **altas y bajas parciales** (entran o salen animales sin mover el
///   rebaño entero), que no cambian dónde está;
/// - el tratamiento lleva lo del art. 108.2 del Reglamento (UE) 2019/6
///   (medicamento, proveedor, prueba de compra, duración).
///
/// En extensivo el ganado se mueve por rebaños, así que un traslado es de un
/// rebaño entero; un animal cambia de sitio cambiando de rebaño. Dónde está
/// un rebaño no se guarda: es el destino de su último movimiento que mueve
/// el rebaño, así que historial y ubicación no pueden contradecirse.
///
/// **Hard limit de la suite**: la app no recomienda medicamentos ni dosis.
/// En un tratamiento se apunta lo que pone la receta del veterinario; la app
/// solo avisa de cuándo terminan los plazos.

// ─── Códigos (el nombre visible está en utiles/textos_ganadera.dart) ───

const List<String> especiesGanado = [
  'ovino',
  'caprino',
  'vacuno',
  'porcino',
  'equino',
];

const List<String> sexosAnimal = ['hembra', 'macho', 'castrado'];

const String estadoAnimalActivo = 'activo';
const List<String> estadosAnimal = [
  estadoAnimalActivo,
  'vendido',
  'sacrificado',
  'muerto',
  'baja',
];

/// Tipo de dispositivo de identificación (RD 787/2023, anexo V punto 8).
const List<String> dispositivosIdentificacion = [
  'crotal',
  'crotal_electronico',
  'bolo_ruminal',
  'marca_auricular',
  'tatuaje',
  'otro',
];

const String estadoLoteActivo = 'activo';
const String estadoLoteCerrado = 'cerrado';

const String tipoMovimientoTraslado = 'traslado';
const String tipoMovimientoEntrada = 'entrada';
const String tipoMovimientoSalida = 'salida';
const String tipoMovimientoAltaParcial = 'alta_parcial';
const String tipoMovimientoBajaParcial = 'baja_parcial';
const List<String> tiposMovimientoGanado = [
  tipoMovimientoTraslado,
  tipoMovimientoEntrada,
  tipoMovimientoSalida,
  tipoMovimientoAltaParcial,
  tipoMovimientoBajaParcial,
];

/// Tipos que cambian dónde está el rebaño.
const Set<String> tiposMovimientoQueUbican = {
  tipoMovimientoTraslado,
  tipoMovimientoEntrada,
  tipoMovimientoSalida,
};

const String tipoEventoTratamiento = 'tratamiento';
const String tipoEventoSaneamiento = 'saneamiento';
const String tipoEventoPesaje = 'pesaje';
const String tipoEventoParto = 'parto';
const String tipoEventoEnfermedad = 'enfermedad';
const String tipoEventoBienestar = 'bienestar';
const List<String> tiposEventoGanado = [
  tipoEventoTratamiento,
  tipoEventoSaneamiento,
  tipoEventoPesaje,
  tipoEventoParto,
  tipoEventoEnfermedad,
  tipoEventoBienestar,
  'incidencia',
  'otro',
];

/// Tipos de evento que llevan medicamento y plazos de supresión.
const Set<String> tiposEventoConMedicamento = {
  tipoEventoTratamiento,
  tipoEventoSaneamiento,
};

int _entero(Object? valor, [int porDefecto = 0]) =>
    (valor as num?)?.toInt() ?? porDefecto;
String _texto(Object? valor) => (valor as String?) ?? '';

/// Grupo de animales que se maneja junto (rebaño, lote de cerdos…).
class LoteGanado {
  LoteGanado({
    this.id,
    this.nombre = '',
    this.especie = '',
    this.cabezasSinIdentificar = 0,
    this.estado = estadoLoteActivo,
    this.notas = '',
    this.fechaCreacionMs = 0,
    this.ecologico = false,
    this.cicloCorto = false,
  });

  final int? id;
  final String nombre;

  /// Código de [especiesGanado].
  final String especie;

  /// Cabezas que no se llevan una a una (corderos de cebo, lechones…).
  final int cabezasSinIdentificar;

  /// `activo` o `cerrado` (el rebaño ya no existe).
  final String estado;
  final String notas;
  final int fechaCreacionMs;

  /// Ecológico o en conversión: los tratamientos alopáticos doblan el plazo
  /// y cuentan para el límite anual (`ganado_ecologico.dart`).
  final bool ecologico;

  /// Vida productiva menor de un año: límite ecológico de uno al año.
  final bool cicloCorto;

  bool get activo => estado != estadoLoteCerrado;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'especie': especie,
        'cabezas_sin_identificar': cabezasSinIdentificar,
        'estado': estado,
        'notas': notas,
        'fecha_creacion_ms': fechaCreacionMs,
        'ecologico': ecologico ? 1 : 0,
        'ciclo_corto': cicloCorto ? 1 : 0,
      };

  factory LoteGanado.fromMap(Map<String, Object?> mapa) => LoteGanado(
        id: mapa['id'] as int?,
        nombre: _texto(mapa['nombre']),
        especie: _texto(mapa['especie']),
        cabezasSinIdentificar: _entero(mapa['cabezas_sin_identificar']),
        estado: (mapa['estado'] as String?) ?? estadoLoteActivo,
        notas: _texto(mapa['notas']),
        fechaCreacionMs: _entero(mapa['fecha_creacion_ms']),
        ecologico: _entero(mapa['ecologico']) != 0,
        cicloCorto: _entero(mapa['ciclo_corto']) != 0,
      );
}

/// Un animal identificado (crotal, DIB, bolo…).
class Animal {
  Animal({
    this.id,
    this.identificacion = '',
    this.dispositivo = 'crotal',
    this.nombre = '',
    this.especie = '',
    this.raza = '',
    this.sexo = '',
    this.fechaNacimientoMs,
    this.madre = '',
    this.loteId,
    this.estado = estadoAnimalActivo,
    this.fechaBajaMs,
    this.notas = '',
  });

  final int? id;

  /// Código de identificación oficial.
  final String identificacion;

  /// Código de [dispositivosIdentificacion].
  final String dispositivo;
  final String nombre;
  final String especie;
  final String raza;

  /// Código de [sexosAnimal]; vacío = sin indicar.
  final String sexo;
  final int? fechaNacimientoMs;

  /// Identificación de la madre, si se conoce.
  final String madre;
  final int? loteId;

  /// Código de [estadosAnimal].
  final String estado;
  final int? fechaBajaMs;
  final String notas;

  bool get activo => estado == estadoAnimalActivo;

  /// Cómo se nombra en listas: «ES123… · Morena».
  String get rotulo => [
        if (identificacion.isNotEmpty) identificacion,
        if (nombre.isNotEmpty) nombre,
      ].join(' · ');

  Map<String, Object?> toMap() => {
        'id': id,
        'identificacion': identificacion,
        'dispositivo': dispositivo,
        'nombre': nombre,
        'especie': especie,
        'raza': raza,
        'sexo': sexo,
        'fecha_nacimiento_ms': fechaNacimientoMs,
        'madre': madre,
        'lote_id': loteId,
        'estado': estado,
        'fecha_baja_ms': fechaBajaMs,
        'notas': notas,
      };

  factory Animal.fromMap(Map<String, Object?> mapa) => Animal(
        id: mapa['id'] as int?,
        identificacion: _texto(mapa['identificacion']),
        dispositivo: (mapa['dispositivo'] as String?) ?? 'crotal',
        nombre: _texto(mapa['nombre']),
        especie: _texto(mapa['especie']),
        raza: _texto(mapa['raza']),
        sexo: _texto(mapa['sexo']),
        fechaNacimientoMs: (mapa['fecha_nacimiento_ms'] as num?)?.toInt(),
        madre: _texto(mapa['madre']),
        loteId: mapa['lote_id'] as int?,
        estado: (mapa['estado'] as String?) ?? estadoAnimalActivo,
        fechaBajaMs: (mapa['fecha_baja_ms'] as num?)?.toInt(),
        notas: _texto(mapa['notas']),
      );
}

/// Movimiento de un rebaño: de una pieza a otra, entrada o salida de la
/// explotación, o alta/baja parcial de animales.
class MovimientoGanado {
  MovimientoGanado({
    this.id,
    required this.loteId,
    required this.fechaMs,
    this.tipo = tipoMovimientoTraslado,
    this.piezaOrigenId,
    this.piezaDestinoId,
    this.cabezas = 0,
    this.identificaciones = '',
    this.explotacionExterna = '',
    this.titularExterno = '',
    this.municipioExterno = '',
    this.provinciaExterna = '',
    this.codigoRemo = '',
    this.fechaLlegadaPrevistaMs,
    this.codigoTransporte = '',
    this.tipoTransporte = '',
    this.autorizacionTransportista = '',
    this.certificadoSanitario = '',
    this.fechaCertificadoMs,
    this.notas = '',
  });

  final int? id;
  final int loteId;
  final int fechaMs;

  /// Código de [tiposMovimientoGanado].
  final String tipo;
  final int? piezaOrigenId;

  /// Pieza a la que va; null en una salida.
  final int? piezaDestinoId;

  /// Cabezas que se movieron, o que tenía el rebaño en ese momento.
  final int cabezas;

  /// Crotales de los animales que entran o salen, separados por comas.
  final String identificaciones;

  /// Código REGA de la explotación de origen (entrada) o destino (salida).
  final String explotacionExterna;
  final String titularExterno;
  final String municipioExterno;
  final String provinciaExterna;

  /// Código REMO del movimiento (lo da SITRAN o la OCA).
  final String codigoRemo;
  final int? fechaLlegadaPrevistaMs;

  /// Matrícula o código del medio de transporte.
  final String codigoTransporte;
  final String tipoTransporte;
  final String autorizacionTransportista;
  final String certificadoSanitario;
  final int? fechaCertificadoMs;
  final String notas;

  bool get esSalida => tipo == tipoMovimientoSalida;

  bool get esEntradaEnExplotacion =>
      tipo == tipoMovimientoEntrada || tipo == tipoMovimientoAltaParcial;

  bool get esSalidaDeExplotacion =>
      tipo == tipoMovimientoSalida || tipo == tipoMovimientoBajaParcial;

  bool get cambiaUbicacion => tiposMovimientoQueUbican.contains(tipo);

  Map<String, Object?> toMap() => {
        'id': id,
        'lote_id': loteId,
        'fecha_ms': fechaMs,
        'tipo': tipo,
        'pieza_origen_id': piezaOrigenId,
        'pieza_destino_id': piezaDestinoId,
        'cabezas': cabezas,
        'identificaciones': identificaciones,
        'explotacion_externa': explotacionExterna,
        'titular_externo': titularExterno,
        'municipio_externo': municipioExterno,
        'provincia_externa': provinciaExterna,
        'codigo_remo': codigoRemo,
        'fecha_llegada_prevista_ms': fechaLlegadaPrevistaMs,
        'codigo_transporte': codigoTransporte,
        'tipo_transporte': tipoTransporte,
        'autorizacion_transportista': autorizacionTransportista,
        'certificado_sanitario': certificadoSanitario,
        'fecha_certificado_ms': fechaCertificadoMs,
        'notas': notas,
      };

  factory MovimientoGanado.fromMap(Map<String, Object?> mapa) =>
      MovimientoGanado(
        id: mapa['id'] as int?,
        loteId: _entero(mapa['lote_id']),
        fechaMs: _entero(mapa['fecha_ms']),
        tipo: (mapa['tipo'] as String?) ?? tipoMovimientoTraslado,
        piezaOrigenId: mapa['pieza_origen_id'] as int?,
        piezaDestinoId: mapa['pieza_destino_id'] as int?,
        cabezas: _entero(mapa['cabezas']),
        identificaciones: _texto(mapa['identificaciones']),
        explotacionExterna: _texto(mapa['explotacion_externa']),
        titularExterno: _texto(mapa['titular_externo']),
        municipioExterno: _texto(mapa['municipio_externo']),
        provinciaExterna: _texto(mapa['provincia_externa']),
        codigoRemo: _texto(mapa['codigo_remo']),
        fechaLlegadaPrevistaMs:
            (mapa['fecha_llegada_prevista_ms'] as num?)?.toInt(),
        codigoTransporte: _texto(mapa['codigo_transporte']),
        tipoTransporte: _texto(mapa['tipo_transporte']),
        autorizacionTransportista: _texto(mapa['autorizacion_transportista']),
        certificadoSanitario: _texto(mapa['certificado_sanitario']),
        fechaCertificadoMs: (mapa['fecha_certificado_ms'] as num?)?.toInt(),
        notas: _texto(mapa['notas']),
      );
}

/// Algo que se le hace o le pasa a un animal o a un rebaño entero.
class EventoGanado {
  EventoGanado({
    this.id,
    this.animalId,
    this.loteId,
    required this.fechaMs,
    this.tipo = tipoEventoTratamiento,
    this.descripcion = '',
    this.medicamento = '',
    this.sustanciaActiva = '',
    this.claseMedicamento = '',
    this.dosis = '',
    this.duracionDias = 0,
    this.plazoSupresionCarneDias = 0,
    this.plazoSupresionLecheDias = 0,
    this.veterinario = '',
    this.receta = '',
    this.proveedor = '',
    this.pruebaCompra = '',
    this.pesoKg,
    this.crias = 0,
    this.cabezas = 0,
  });

  final int? id;

  /// Del animal, o del rebaño entero si [animalId] es null.
  final int? animalId;
  final int? loteId;

  /// En un tratamiento, la fecha de la primera administración.
  final int fechaMs;

  /// Código de [tiposEventoGanado].
  final String tipo;
  final String descripcion;

  /// Denominación del medicamento, tal como la pone la receta.
  final String medicamento;

  /// Lo que pone la receta. Nunca lo sugiere la app.
  final String sustanciaActiva;

  /// Código de `clasesMedicamento` ('' = sin indicar).
  final String claseMedicamento;

  /// Cantidad administrada, como la pone la receta.
  final String dosis;
  final int duracionDias;
  final int plazoSupresionCarneDias;
  final int plazoSupresionLecheDias;
  final String veterinario;

  /// Número de receta.
  final String receta;
  final String proveedor;

  /// Factura o albarán de compra.
  final String pruebaCompra;
  final double? pesoKg;
  final int crias;

  /// En un rebaño: cuántas cabezas se trataron (0 = todas).
  final int cabezas;

  bool get llevaMedicamento => tiposEventoConMedicamento.contains(tipo);

  Map<String, Object?> toMap() => {
        'id': id,
        'animal_id': animalId,
        'lote_id': loteId,
        'fecha_ms': fechaMs,
        'tipo': tipo,
        'descripcion': descripcion,
        'medicamento': medicamento,
        'sustancia_activa': sustanciaActiva,
        'clase_medicamento': claseMedicamento,
        'dosis': dosis,
        'duracion_dias': duracionDias,
        'plazo_supresion_carne_dias': plazoSupresionCarneDias,
        'plazo_supresion_leche_dias': plazoSupresionLecheDias,
        'veterinario': veterinario,
        'receta': receta,
        'proveedor': proveedor,
        'prueba_compra': pruebaCompra,
        'peso_kg': pesoKg,
        'crias': crias,
        'cabezas': cabezas,
      };

  factory EventoGanado.fromMap(Map<String, Object?> mapa) => EventoGanado(
        id: mapa['id'] as int?,
        animalId: mapa['animal_id'] as int?,
        loteId: mapa['lote_id'] as int?,
        fechaMs: _entero(mapa['fecha_ms']),
        tipo: (mapa['tipo'] as String?) ?? tipoEventoTratamiento,
        descripcion: _texto(mapa['descripcion']),
        medicamento: _texto(mapa['medicamento']),
        sustanciaActiva: _texto(mapa['sustancia_activa']),
        claseMedicamento: _texto(mapa['clase_medicamento']),
        dosis: _texto(mapa['dosis']),
        duracionDias: _entero(mapa['duracion_dias']),
        plazoSupresionCarneDias: _entero(mapa['plazo_supresion_carne_dias']),
        plazoSupresionLecheDias: _entero(mapa['plazo_supresion_leche_dias']),
        veterinario: _texto(mapa['veterinario']),
        receta: _texto(mapa['receta']),
        proveedor: _texto(mapa['proveedor']),
        pruebaCompra: _texto(mapa['prueba_compra']),
        pesoKg: (mapa['peso_kg'] as num?)?.toDouble(),
        crias: _entero(mapa['crias']),
        cabezas: _entero(mapa['cabezas']),
      );
}

// ─── Cálculos ───

/// El último movimiento (por fecha; a igual fecha, el último apuntado).
/// Null si no hay ninguno.
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

/// Pieza en la que está el rebaño: el destino de su último movimiento que
/// lo ubica (null si ha salido de la explotación o no se sabe).
int? piezaActualDeLote(Iterable<MovimientoGanado> movimientos) {
  final ultimo = ultimoMovimiento(
      movimientos.where((movimiento) => movimiento.cambiaUbicacion));
  if (ultimo == null || ultimo.esSalida) return null;
  return ultimo.piezaDestinoId;
}

/// Cabezas de un rebaño: sus animales activos más las sin identificar.
int cabezasDeLote(LoteGanado lote, Iterable<Animal> animalesDelLote) =>
    animalesDelLote.where((animal) => animal.activo).length +
    lote.cabezasSinIdentificar;

/// UGM de un rebaño según la [tabla] de un trámite: cada animal por su
/// especie, sexo y edad, y las cabezas sin crotal como adultas hembras de la
/// especie del rebaño (lo prudente en un rebaño de cría).
double ugmDeLote(LoteGanado lote, Iterable<Animal> animalesDelLote,
    DateTime ahora, List<CoeficienteUgm> tabla) {
  var total = 0.0;
  for (final animal in animalesDelLote.where((animal) => animal.activo)) {
    total += ugmPorCabeza(
        tabla: tabla,
        especie: animal.especie.isEmpty ? lote.especie : animal.especie,
        sexo: animal.sexo,
        fechaNacimientoMs: animal.fechaNacimientoMs,
        ahora: ahora);
  }
  return total +
      lote.cabezasSinIdentificar *
          ugmPorCabeza(
              tabla: tabla,
              especie: lote.especie,
              sexo: 'hembra',
              ahora: ahora);
}

/// Día (local) en que termina un plazo de [dias] contado desde [fechaMs].
DateTime finDePlazo(int fechaMs, int dias) {
  final fecha = DateTime.fromMillisecondsSinceEpoch(fechaMs);
  return DateTime(fecha.year, fecha.month, fecha.day + dias);
}

/// Hasta cuándo no puede ir a matadero (carne) o venderse la leche.
class SupresionVigente {
  const SupresionVigente({this.carneHasta, this.lecheHasta});

  final DateTime? carneHasta;
  final DateTime? lecheHasta;

  bool get hayAlguna => carneHasta != null || lecheHasta != null;
}

/// La supresión vigente en [ahora] por los [eventosRegistrados]: el final más
/// tardío de cada plazo. En [ecologico] los plazos son los dobles (mínimo
/// 48 h).
SupresionVigente supresionVigente(
    Iterable<EventoGanado> eventosRegistrados, DateTime ahora,
    {bool ecologico = false}) {
  final eventos = eventosRegistrados
      .map((evento) => eventoConPlazosEfectivos(evento, ecologico: ecologico));
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
