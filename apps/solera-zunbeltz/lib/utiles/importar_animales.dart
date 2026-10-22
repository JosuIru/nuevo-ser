/// Importar animales desde una hoja de cálculo (CSV o XLSX): qué columnas
/// se reconocen, cómo se leen fechas y crotales escritos a la española, y
/// qué haría cada fila (crear, actualizar, nada o fallar y por qué) antes
/// de tocar la BD. Puro: la pantalla enseña el análisis y guarda.
///
/// Reglas:
/// - El **crotal es obligatorio** y es la clave: si ya hay un animal con
///   ese crotal se actualiza; si no, se crea.
/// - Una celda vacía **no borra** lo que ya hay: solo se cambia lo escrito.
/// - El rebaño se busca por su nombre entre los rebaños activos.
/// - Permisos como en el servidor (`includes/entidades.php`): quien
///   registra ganado da altas; la ficha de un animal ajeno solo la cambia
///   quien gestiona el ganado, y el resto solo puede tocarle el rebaño, la
///   baja y las notas (`SZS_CAMPOS_ANIMAL_MANEJO`).
library;

import 'package:nuevo_ser_core/nuevo_ser_core.dart' show TablaCsv;

import '../modelos/constantes.dart';
import '../modelos/ganado.dart';
import '../servicios/politica_espacio.dart';
import 'crotal.dart';

/// Columnas de la hoja de animales, en el orden en que se exportan.
enum ColumnaAnimal {
  crotal,
  nombre,
  especie,
  raza,
  sexo,
  nacimiento,
  madre,
  rebano,
  estado,
  fechaBaja,
  notas,
}

/// Cabecera de cada columna al exportar (castellano, euskera). Euskera:
/// borrador pendiente de revisión nativa.
const Map<ColumnaAnimal, (String, String)> cabecerasColumnaAnimal = {
  ColumnaAnimal.crotal: ('Crotal', 'Krotala'),
  ColumnaAnimal.nombre: ('Nombre', 'Izena'),
  ColumnaAnimal.especie: ('Especie', 'Espeziea'),
  ColumnaAnimal.raza: ('Raza', 'Arraza'),
  ColumnaAnimal.sexo: ('Sexo', 'Sexua'),
  ColumnaAnimal.nacimiento: ('Nacimiento', 'Jaiotza'),
  ColumnaAnimal.madre: ('Madre', 'Ama'),
  ColumnaAnimal.rebano: ('Rebaño', 'Taldea'),
  ColumnaAnimal.estado: ('Estado', 'Egoera'),
  ColumnaAnimal.fechaBaja: ('Fecha de baja', 'Baja-data'),
  ColumnaAnimal.notas: ('Notas', 'Oharrak'),
};

String cabeceraColumnaAnimal(ColumnaAnimal columna, String idioma) {
  final (castellano, euskera) = cabecerasColumnaAnimal[columna]!;
  return idioma == 'eu' ? euskera : castellano;
}

/// Otras formas de llamar a cada columna (ya normalizadas con
/// [claveTexto]: minúsculas, sin acentos ni paréntesis).
const Map<ColumnaAnimal, List<String>> _alias = {
  ColumnaAnimal.crotal: [
    'crotal', 'crotales', 'identificacion', 'dib', 'crotal dib',
    'crotal identificacion', 'n crotal', 'no crotal', 'num crotal',
    'numero crotal', 'numero de crotal', 'id', 'krotala', 'krotal',
    'identifikazioa', 'krotala identifikazioa', 'krotal zenbakia',
  ],
  ColumnaAnimal.nombre: ['nombre', 'apodo', 'izena'],
  ColumnaAnimal.especie: ['especie', 'espeziea'],
  ColumnaAnimal.raza: ['raza', 'arraza'],
  ColumnaAnimal.sexo: ['sexo', 'sexua'],
  ColumnaAnimal.nacimiento: [
    'nacimiento', 'fecha nacimiento', 'fecha de nacimiento', 'f nacimiento',
    'nacido', 'jaiotza', 'jaiotze data', 'jaiotza data', 'jaioteguna',
  ],
  ColumnaAnimal.madre: [
    'madre', 'crotal madre', 'crotal de la madre', 'ama', 'amaren krotala',
    'ama krotala',
  ],
  ColumnaAnimal.rebano: [
    'rebano', 'lote', 'grupo', 'taldea', 'talde', 'artaldea', 'artalde',
  ],
  ColumnaAnimal.estado: ['estado', 'situacion', 'egoera'],
  ColumnaAnimal.fechaBaja: [
    'fecha de baja', 'fecha baja', 'baja', 'f baja', 'baja data',
    'bajaren data', 'baja eguna',
  ],
  ColumnaAnimal.notas: ['notas', 'observaciones', 'oharrak'],
};

/// Texto para comparar: minúsculas, sin acentos, sin lo que va entre
/// paréntesis y con cualquier signo convertido en un espacio.
/// «Madre (crotal)» → «madre»; «Baja-data» → «baja data».
String claveTexto(String texto) {
  const conAcento = 'áàäâéèëêíìïîóòöôúùüûñç';
  const sinAcento = 'aaaaeeeeiiiioooouuuunc';
  final minusculas = texto.toLowerCase().replaceAll(RegExp(r'\([^)]*\)'), ' ');
  final resultado = StringBuffer();
  for (final caracter in minusculas.split('')) {
    final posicion = conAcento.indexOf(caracter);
    resultado.write(posicion >= 0 ? sinAcento[posicion] : caracter);
  }
  return resultado
      .toString()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
}

/// Qué columna de la hoja es cada [ColumnaAnimal] (la primera que case) y
/// qué cabeceras no se han reconocido.
({Map<ColumnaAnimal, int> indices, List<String> ignoradas})
    reconocerColumnasAnimal(List<String> cabecera) {
  final indices = <ColumnaAnimal, int>{};
  final ignoradas = <String>[];
  for (var posicion = 0; posicion < cabecera.length; posicion++) {
    final clave = claveTexto(cabecera[posicion]);
    if (clave.isEmpty) continue;
    ColumnaAnimal? reconocida;
    for (final entrada in _alias.entries) {
      if (entrada.value.contains(clave)) {
        reconocida = entrada.key;
        break;
      }
    }
    if (reconocida == null || indices.containsKey(reconocida)) {
      ignoradas.add(cabecera[posicion].trim());
    } else {
      indices[reconocida] = posicion;
    }
  }
  return (indices: indices, ignoradas: ignoradas);
}

// ─── Fechas ───

final _fechaDiaMesAnio =
    RegExp(r'^(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{2}|\d{4})(?:[ T].*)?$');
final _fechaIso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})(?:[ T].*)?$');
final _serieExcel = RegExp(r'^(\d{5})(?:[.,]\d+)?$');

/// Fecha escrita a la española («23/10/2026», «3-2-24», «23.10.2026»), en
/// ISO («2026-10-23») o como número de serie de Excel (45953: lo que queda
/// cuando una fecha pierde su formato). Null si no se entiende o no existe
/// (31/02). Un año de dos cifras se lee en este siglo salvo que quede en
/// el futuro respecto a [hoy].
DateTime? leerFechaHoja(String texto, DateTime hoy) {
  final limpio = texto.trim();
  int? anio;
  int? mes;
  int? dia;
  if (_fechaIso.firstMatch(limpio) case final iso?) {
    anio = int.parse(iso.group(1)!);
    mes = int.parse(iso.group(2)!);
    dia = int.parse(iso.group(3)!);
  } else if (_fechaDiaMesAnio.firstMatch(limpio) case final espanola?) {
    dia = int.parse(espanola.group(1)!);
    mes = int.parse(espanola.group(2)!);
    anio = int.parse(espanola.group(3)!);
    if (espanola.group(3)!.length == 2) {
      anio += anio + 2000 > hoy.year ? 1900 : 2000;
    }
  } else if (_serieExcel.firstMatch(limpio) case final serie?) {
    final dias = int.parse(serie.group(1)!);
    // De 10000 (1927) a 80000 (2119): fuera de eso no es una fecha.
    if (dias < 10000 || dias > 80000) return null;
    final fecha = DateTime.utc(1899, 12, 30).add(Duration(days: dias));
    return DateTime(fecha.year, fecha.month, fecha.day);
  } else {
    return null;
  }
  final fecha = DateTime(anio, mes, dia);
  if (fecha.year != anio || fecha.month != mes || fecha.day != dia) {
    return null;
  }
  return fecha;
}

bool _mismoDia(int? a, int? b) {
  if (a == null || b == null) return a == b;
  final fechaA = DateTime.fromMillisecondsSinceEpoch(a);
  final fechaB = DateTime.fromMillisecondsSinceEpoch(b);
  return fechaA.year == fechaB.year &&
      fechaA.month == fechaB.month &&
      fechaA.day == fechaB.day;
}

/// Para comparar textos: un salto de línea guardado sale como espacio en
/// la hoja exportada y no es un cambio.
String _sinEspaciosDeMas(String texto) =>
    texto.replaceAll(RegExp(r'\s+'), ' ').trim();

// ─── Crotales ───

final _notacionCientifica = RegExp(r'^\d+(?:[.,]\d+)?E\+?\d+$', caseSensitive: false);

/// Lo leído de una celda de crotal: la identificación normalizada, o el
/// problema que impide usarla, y los avisos.
({String identificacion, MotivoImportacion? error, List<MotivoImportacion> avisos})
    leerCrotalHoja(String texto) {
  var limpio = texto.trim();
  // Excel marca con apóstrofo un número escrito como texto.
  if (limpio.startsWith("'")) limpio = limpio.substring(1).trim();
  if (limpio.isEmpty) {
    return (identificacion: '', error: MotivoImportacion.crotalVacio, avisos: const []);
  }
  if (_notacionCientifica.hasMatch(limpio.replaceAll(' ', ''))) {
    return (
      identificacion: '',
      error: MotivoImportacion.crotalNumeroExcel,
      avisos: const []
    );
  }
  final avisos = <MotivoImportacion>[];
  final soloDigitos = limpio.replaceAll(RegExp(r'[\s\-\. _/]'), '');
  if (RegExp(r'^\d{11}$').hasMatch(soloDigitos)) {
    // Excel guarda «012345678901» como número y se come el cero.
    limpio = '0$soloDigitos';
    avisos.add(MotivoImportacion.avisoCeroRecuperado);
  }
  final lectura = interpretarCodigoCrotal(limpio);
  if (!lectura.reconocido) avisos.add(MotivoImportacion.avisoCrotalNoOficial);
  return (identificacion: lectura.identificacion, error: null, avisos: avisos);
}

// ─── Catálogos ───

const Map<String, String> _aliasEspecie = {
  'vaca': 'vacuno', 'vacas': 'vacuno', 'bovino': 'vacuno', 'behia': 'vacuno',
  'oveja': 'ovino', 'ovejas': 'ovino', 'ardia': 'ovino', 'ardi': 'ovino',
  'cabra': 'caprino', 'cabras': 'caprino', 'ahuntza': 'caprino',
  'cerdo': 'porcino', 'cerdos': 'porcino', 'txerria': 'porcino',
  'caballo': 'equino', 'yegua': 'equino', 'zaldia': 'equino',
  'ave': 'aves', 'gallina': 'aves', 'gallinas': 'aves', 'hegaztia': 'aves',
};

const Map<String, String> _aliasSexo = {
  'h': 'hembra', 'f': 'hembra', 'hembras': 'hembra',
  'm': 'macho', 'machos': 'macho',
  'c': 'castrado', 'buey': 'castrado',
};

const Map<String, String> _aliasEstado = {
  'activo': estadoAnimalActivo, 'alta': estadoAnimalActivo,
  'en el espacio': estadoAnimalActivo, 'aktibo': estadoAnimalActivo,
  'venta': 'vendido', 'muerte': 'muerto', 'matadero': 'sacrificado',
};

/// El código del catálogo para lo escrito: el código, la etiqueta en
/// castellano o en euskera, o un alias. Null si no se reconoce.
String? _codigoDe(List<OpcionCatalogo> catalogo, String texto,
    [Map<String, String> alias = const {}]) {
  final clave = claveTexto(texto);
  for (final opcion in catalogo) {
    if (claveTexto(opcion.codigo) == clave ||
        claveTexto(opcion.es) == clave ||
        claveTexto(opcion.eu) == clave) {
      return opcion.codigo;
    }
  }
  return alias[clave];
}

// ─── Análisis ───

/// Por qué una fila falla (o un aviso que no impide importarla).
enum MotivoImportacion {
  crotalVacio,
  crotalNumeroExcel,
  crotalRepetido,
  fechaNoValida,
  nacimientoFuturo,
  bajaAntesDeNacimiento,
  especieDesconocida,
  sexoDesconocido,
  estadoDesconocido,
  rebanoDesconocido,
  sinPermisoAlta,
  sinPermisoFicha,
  avisoCrotalNoOficial,
  avisoCeroRecuperado;

  bool get esAviso =>
      this == avisoCrotalNoOficial || this == avisoCeroRecuperado;
}

/// Un problema de una fila, con la columna y lo escrito si vienen al caso.
class ProblemaImportacion {
  const ProblemaImportacion(this.motivo, {this.columna, this.valor = ''});
  final MotivoImportacion motivo;
  final ColumnaAnimal? columna;
  final String valor;
}

enum AccionImportacion { crear, actualizar, sinCambios, error }

/// Lo que se hará con una fila de la hoja.
class FilaImportacion {
  const FilaImportacion({
    required this.numeroFila,
    required this.identificacion,
    required this.accion,
    this.existente,
    this.datos = const {},
    this.problemas = const [],
  });

  /// Número de fila como lo enseña la hoja (la cabecera es la 1).
  final int numeroFila;
  final String identificacion;
  final AccionImportacion accion;

  /// El animal que se actualiza (o que ya está igual).
  final Animal? existente;

  /// Crear: el mapa completo para `Animal.fromMap`. Actualizar: solo las
  /// columnas que cambian (nombres de la tabla `animales`).
  final Map<String, Object?> datos;

  /// Errores (si [accion] es `error`) y avisos.
  final List<ProblemaImportacion> problemas;

  Iterable<ProblemaImportacion> get errores =>
      problemas.where((problema) => !problema.motivo.esAviso);
  Iterable<ProblemaImportacion> get avisos =>
      problemas.where((problema) => problema.motivo.esAviso);
}

class AnalisisImportacion {
  const AnalisisImportacion({
    required this.filas,
    required this.columnasIgnoradas,
    required this.sinColumnaCrotal,
  });

  final List<FilaImportacion> filas;

  /// Cabeceras de la hoja que no se han reconocido (no se importan).
  final List<String> columnasIgnoradas;

  /// La hoja no tiene columna de crotal: no se puede importar nada.
  final bool sinColumnaCrotal;

  List<FilaImportacion> _con(AccionImportacion accion) =>
      filas.where((fila) => fila.accion == accion).toList();
  List<FilaImportacion> get aCrear => _con(AccionImportacion.crear);
  List<FilaImportacion> get aActualizar => _con(AccionImportacion.actualizar);
  List<FilaImportacion> get sinCambios => _con(AccionImportacion.sinCambios);
  List<FilaImportacion> get conErrores => _con(AccionImportacion.error);

  bool get hayAlgoQueGuardar => aCrear.isNotEmpty || aActualizar.isNotEmpty;
}

/// Campos de un animal ajeno que puede cambiar quien solo maneja ganado.
const Set<String> camposAnimalManejo = {
  'lote_id',
  'estado',
  'fecha_baja_ms',
  'notas'
};

/// Analiza [tabla] contra los animales y rebaños que ya hay. No guarda.
AnalisisImportacion analizarImportacionAnimales({
  required TablaCsv tabla,
  required List<Animal> existentes,
  required List<LoteGanado> lotes,
  required PoliticaEspacio politica,
  required DateTime hoy,
}) {
  final columnas = reconocerColumnasAnimal(tabla.cabecera);
  final indices = columnas.indices;
  if (!indices.containsKey(ColumnaAnimal.crotal)) {
    return AnalisisImportacion(
        filas: const [],
        columnasIgnoradas: columnas.ignoradas,
        sinColumnaCrotal: true);
  }

  final porCrotal = <String, Animal>{};
  for (final animal in existentes) {
    if (animal.identificacion.trim().isEmpty) continue;
    porCrotal.putIfAbsent(
        interpretarCodigoCrotal(animal.identificacion).identificacion,
        () => animal);
  }
  final lotesPorNombre = <String, LoteGanado>{};
  for (final lote in lotes.where((lote) => lote.activo && lote.id != null)) {
    lotesPorNombre.putIfAbsent(claveTexto(lote.nombre), () => lote);
  }
  final hoyFin = DateTime(hoy.year, hoy.month, hoy.day + 1);

  final vistos = <String>{};
  final filas = <FilaImportacion>[];
  for (var posicion = 0; posicion < tabla.filas.length; posicion++) {
    final celdas = tabla.filas[posicion];
    String celda(ColumnaAnimal columna) {
      final indice = indices[columna];
      if (indice == null || indice >= celdas.length) return '';
      var valor = celdas[indice].trim();
      // Lo que la exportación protegió de Excel («'=…»).
      if (valor.startsWith("'") &&
          valor.length > 1 &&
          '=+@'.contains(valor[1])) {
        valor = valor.substring(1);
      }
      return valor;
    }

    if (celdas.every((valor) => valor.trim().isEmpty)) continue;
    final numeroFila = posicion + 2;
    final problemas = <ProblemaImportacion>[];
    void fallo(MotivoImportacion motivo, ColumnaAnimal columna) =>
        problemas.add(ProblemaImportacion(motivo,
            columna: columna, valor: celda(columna)));

    final crotal = leerCrotalHoja(celda(ColumnaAnimal.crotal));
    if (crotal.error != null) {
      fallo(crotal.error!, ColumnaAnimal.crotal);
    } else if (!vistos.add(crotal.identificacion)) {
      fallo(MotivoImportacion.crotalRepetido, ColumnaAnimal.crotal);
    }
    for (final aviso in crotal.avisos) {
      problemas.add(ProblemaImportacion(aviso,
          columna: ColumnaAnimal.crotal, valor: celda(ColumnaAnimal.crotal)));
    }

    // Lo escrito en cada columna (solo las que traen algo).
    final escritos = <String, Object?>{};
    for (final (columna, campo) in const [
      (ColumnaAnimal.nombre, 'nombre'),
      (ColumnaAnimal.raza, 'raza'),
      (ColumnaAnimal.notas, 'notas'),
    ]) {
      final valor = celda(columna);
      if (valor.isNotEmpty) escritos[campo] = valor;
    }
    if (celda(ColumnaAnimal.madre) case final madre when madre.isNotEmpty) {
      final lectura = leerCrotalHoja(madre);
      if (lectura.error != null) {
        fallo(lectura.error!, ColumnaAnimal.madre);
      } else {
        escritos['madre'] = lectura.identificacion;
      }
    }
    if (celda(ColumnaAnimal.especie) case final texto when texto.isNotEmpty) {
      final codigo = _codigoDe(especiesGanado, texto, _aliasEspecie);
      codigo == null
          ? fallo(MotivoImportacion.especieDesconocida, ColumnaAnimal.especie)
          : escritos['especie'] = codigo;
    }
    if (celda(ColumnaAnimal.sexo) case final texto when texto.isNotEmpty) {
      final codigo = _codigoDe(sexosAnimal, texto, _aliasSexo);
      codigo == null
          ? fallo(MotivoImportacion.sexoDesconocido, ColumnaAnimal.sexo)
          : escritos['sexo'] = codigo;
    }
    if (celda(ColumnaAnimal.estado) case final texto when texto.isNotEmpty) {
      final codigo = _codigoDe(estadosAnimal, texto, _aliasEstado);
      codigo == null
          ? fallo(MotivoImportacion.estadoDesconocido, ColumnaAnimal.estado)
          : escritos['estado'] = codigo;
    }
    if (celda(ColumnaAnimal.rebano) case final texto when texto.isNotEmpty) {
      final lote = lotesPorNombre[claveTexto(texto)];
      lote == null
          ? fallo(MotivoImportacion.rebanoDesconocido, ColumnaAnimal.rebano)
          : escritos['lote_id'] = lote.id;
    }
    DateTime? nacimiento;
    if (celda(ColumnaAnimal.nacimiento) case final texto
        when texto.isNotEmpty) {
      nacimiento = leerFechaHoja(texto, hoy);
      if (nacimiento == null) {
        fallo(MotivoImportacion.fechaNoValida, ColumnaAnimal.nacimiento);
      } else if (!nacimiento.isBefore(hoyFin)) {
        fallo(MotivoImportacion.nacimientoFuturo, ColumnaAnimal.nacimiento);
      } else {
        escritos['fecha_nacimiento_ms'] = nacimiento.millisecondsSinceEpoch;
      }
    }
    if (celda(ColumnaAnimal.fechaBaja) case final texto when texto.isNotEmpty) {
      final baja = leerFechaHoja(texto, hoy);
      if (baja == null) {
        fallo(MotivoImportacion.fechaNoValida, ColumnaAnimal.fechaBaja);
      } else if (nacimiento != null && baja.isBefore(nacimiento)) {
        fallo(MotivoImportacion.bajaAntesDeNacimiento, ColumnaAnimal.fechaBaja);
      } else {
        escritos['fecha_baja_ms'] = baja.millisecondsSinceEpoch;
      }
    }

    final existente = crotal.error == null ? porCrotal[crotal.identificacion] : null;
    if (problemas.any((problema) => !problema.motivo.esAviso)) {
      filas.add(FilaImportacion(
          numeroFila: numeroFila,
          identificacion: crotal.identificacion,
          accion: AccionImportacion.error,
          existente: existente,
          problemas: problemas));
      continue;
    }

    // Una fecha de baja sin estado da de baja a quien sigue en el espacio.
    final estadoActual = existente?.estado ?? estadoAnimalActivo;
    if (escritos.containsKey('fecha_baja_ms') &&
        !escritos.containsKey('estado') &&
        estadoActual == estadoAnimalActivo) {
      escritos['estado'] = 'baja';
    }
    // Volver a estar en el espacio quita la fecha de baja.
    if (escritos['estado'] == estadoAnimalActivo) {
      escritos['fecha_baja_ms'] = null;
    }

    if (existente == null) {
      if (!politica.puedeRegistrarGanado) {
        problemas.add(const ProblemaImportacion(MotivoImportacion.sinPermisoAlta));
        filas.add(FilaImportacion(
            numeroFila: numeroFila,
            identificacion: crotal.identificacion,
            accion: AccionImportacion.error,
            problemas: problemas));
        continue;
      }
      final loteId = escritos['lote_id'] as int?;
      final especieDelLote = lotes
              .where((lote) => lote.id != null && lote.id == loteId)
              .firstOrNull
              ?.especie ??
          '';
      filas.add(FilaImportacion(
        numeroFila: numeroFila,
        identificacion: crotal.identificacion,
        accion: AccionImportacion.crear,
        problemas: problemas,
        datos: {
          ...Animal(
            identificacion: crotal.identificacion,
            especie: especieDelLote,
            autorUid: politica.miUid,
          ).toMap()
            ..remove('id'),
          ...escritos,
        },
      ));
      continue;
    }

    final actual = existente.toMap();
    // El crotal guardado se respeta tal cual (es la clave con que casa).
    final cambios = <String, Object?>{};
    for (final MapEntry(key: campo, value: valor) in escritos.entries) {
      final igual = campo.endsWith('_ms')
          ? _mismoDia(actual[campo] as int?, valor as int?)
          : valor is String
              ? _sinEspaciosDeMas(actual[campo] as String? ?? '') ==
                  _sinEspaciosDeMas(valor)
              : actual[campo] == valor;
      if (!igual) cambios[campo] = valor;
    }
    if (cambios.isEmpty) {
      filas.add(FilaImportacion(
          numeroFila: numeroFila,
          identificacion: crotal.identificacion,
          accion: AccionImportacion.sinCambios,
          existente: existente,
          problemas: problemas));
      continue;
    }
    final permitido = politica.puedeEditarGanado(existente.autorUid) ||
        (politica.puedeManejarAnimales &&
            cambios.keys.every(camposAnimalManejo.contains));
    if (!permitido) {
      problemas.add(const ProblemaImportacion(MotivoImportacion.sinPermisoFicha));
    }
    filas.add(FilaImportacion(
      numeroFila: numeroFila,
      identificacion: crotal.identificacion,
      accion: permitido ? AccionImportacion.actualizar : AccionImportacion.error,
      existente: existente,
      datos: cambios,
      problemas: problemas,
    ));
  }
  return AnalisisImportacion(
      filas: filas,
      columnasIgnoradas: columnas.ignoradas,
      sinColumnaCrotal: false);
}
