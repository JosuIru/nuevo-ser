import 'dart:io';

import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';

import '../datos/base_datos.dart';
import '../datos/catalogo_cultivos.dart';
import '../modelos/finca.dart';
import '../modelos/planta.dart';

/// Resultado del parseo de un CSV: filas válidas listas para guardar y
/// filas con error con mensaje legible. Permite mostrar al usuario un
/// preview antes de importar para que pueda cancelar si hay muchos
/// errores. Mejor que importar a ciegas y dejar la BD sucia.
class ResultadoParseoCsv {
  final List<FilaParseada> filasValidas;
  final List<FilaInvalida> filasInvalidas;
  final List<String> nombresFincasNuevas;

  ResultadoParseoCsv({
    required this.filasValidas,
    required this.filasInvalidas,
    required this.nombresFincasNuevas,
  });

  int get total => filasValidas.length + filasInvalidas.length;
}

class FilaParseada {
  final String cultivoId;
  final String variedad;
  final double latitud;
  final double longitud;
  final String etiqueta;
  final String? fincaNombre;
  final int? fechaPlantacionMs;
  final String patron;
  final String notas;
  FilaParseada({
    required this.cultivoId,
    required this.variedad,
    required this.latitud,
    required this.longitud,
    required this.etiqueta,
    required this.fincaNombre,
    required this.fechaPlantacionMs,
    required this.patron,
    required this.notas,
  });
}

class FilaInvalida {
  final int numeroLinea;
  final String motivo;
  FilaInvalida(this.numeroLinea, this.motivo);
}

/// Parsea el contenido de un CSV exportado de Larrea. Cabeceras
/// esperadas (en cualquier orden, case-insensitive): cultivo_id,
/// variedad, latitud, longitud, etiqueta, finca, fecha_plantacion
/// (formato YYYY-MM-DD), patron, notas.
///
/// Solo `cultivo_id`, `latitud` y `longitud` son obligatorios. El resto
/// son opcionales. `cultivo_id` se valida contra el catálogo; si no
/// existe se cae a 'generico' (no se rechaza la fila — el usuario
/// puede corregir luego).
///
/// El parser de bajo nivel (BOM, delim auto-detect, comillas, CRLF)
/// vive en `nuevo_ser_core` (`parsearTablaCsv`); aquí solo va el
/// mapeo a Planta + validación específica del dominio.
ResultadoParseoCsv parsearCsvPlantas(String contenido) {
  final tabla = parsearTablaCsv(contenido);
  if (tabla.cabecera.isEmpty) {
    return ResultadoParseoCsv(filasValidas: const [], filasInvalidas: const [], nombresFincasNuevas: const []);
  }
  final indices = indicesDeCabecera(tabla.cabecera);
  final iCultivo = indices['cultivo_id'] ?? indices['cultivo'];
  final iLat = indices['latitud'] ?? indices['lat'];
  final iLon = indices['longitud'] ?? indices['lon'] ?? indices['lng'];
  if (iCultivo == null || iLat == null || iLon == null) {
    return ResultadoParseoCsv(
      filasValidas: const [],
      filasInvalidas: [FilaInvalida(1, 'Faltan columnas obligatorias: cultivo_id, latitud, longitud.')],
      nombresFincasNuevas: const [],
    );
  }

  final iVar = indices['variedad'];
  final iEtq = indices['etiqueta'];
  final iFinca = indices['finca'] ?? indices['finca_nombre'];
  final iFecha = indices['fecha_plantacion'] ?? indices['plantada'];
  final iPat = indices['patron'] ?? indices['hospedero'];
  final iNot = indices['notas'];

  final validas = <FilaParseada>[];
  final invalidas = <FilaInvalida>[];
  final fincas = <String>{};
  final formatoFecha = DateFormat('yyyy-MM-dd');

  for (var i = 0; i < tabla.filas.length; i++) {
    final fila = tabla.filas[i];
    if (fila.every((c) => c.trim().isEmpty)) continue;
    final numeroLineaUsuario = i + 2; // +1 cabecera +1 base-1

    final cultivoCrudo = campoEnFila(fila, iCultivo);
    final lat = double.tryParse(campoEnFila(fila, iLat).replaceAll(',', '.'));
    final lon = double.tryParse(campoEnFila(fila, iLon).replaceAll(',', '.'));
    if (cultivoCrudo.isEmpty) {
      invalidas.add(FilaInvalida(numeroLineaUsuario, 'cultivo_id vacío'));
      continue;
    }
    if (lat == null || lon == null) {
      invalidas.add(FilaInvalida(numeroLineaUsuario, 'latitud/longitud no son números válidos'));
      continue;
    }
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      invalidas.add(FilaInvalida(numeroLineaUsuario, 'latitud/longitud fuera de rango'));
      continue;
    }

    final cultivoExiste = catalogoCultivos.any((c) => c.id == cultivoCrudo);
    final cultivoFinal = cultivoExiste ? cultivoCrudo : 'generico';

    int? fechaMs;
    final fechaTexto = campoEnFila(fila, iFecha);
    if (fechaTexto.isNotEmpty) {
      try {
        fechaMs = formatoFecha.parseStrict(fechaTexto).millisecondsSinceEpoch;
      } catch (_) {
        // Toleramos fecha inválida — la dejamos vacía y avisamos en el preview.
        fechaMs = null;
      }
    }

    final fincaNombre = campoEnFila(fila, iFinca);
    if (fincaNombre.isNotEmpty) fincas.add(fincaNombre);

    validas.add(FilaParseada(
      cultivoId: cultivoFinal,
      variedad: campoEnFila(fila, iVar),
      latitud: lat,
      longitud: lon,
      etiqueta: campoEnFila(fila, iEtq),
      fincaNombre: fincaNombre.isEmpty ? null : fincaNombre,
      fechaPlantacionMs: fechaMs,
      patron: campoEnFila(fila, iPat),
      notas: campoEnFila(fila, iNot),
    ));
  }

  return ResultadoParseoCsv(
    filasValidas: validas,
    filasInvalidas: invalidas,
    nombresFincasNuevas: fincas.toList()..sort(),
  );
}

/// Aplica el resultado de un parseo a la BD: crea fincas que no
/// existían y persiste todas las plantas válidas. Devuelve cuántas
/// plantas se insertaron.
Future<int> importarPlantasDesdeParseo(ResultadoParseoCsv parseo) async {
  final db = BaseDatosAgro.instancia;
  // Cachear fincas existentes por nombre para evitar O(n) consultas.
  final fincasExistentes = await db.listarFincas();
  final indicePorNombre = <String, int>{
    for (final f in fincasExistentes) f.nombre.toLowerCase(): f.id!,
  };
  final ahora = DateTime.now().millisecondsSinceEpoch;
  // Crear las fincas nuevas que aparecen en el CSV pero no existen.
  for (final nombre in parseo.nombresFincasNuevas) {
    if (!indicePorNombre.containsKey(nombre.toLowerCase())) {
      final id = await db.guardarFinca(Finca(
        nombre: nombre,
        colorEntero: 0xFF5E7D3A,
        fechaCreacionMs: ahora,
      ));
      indicePorNombre[nombre.toLowerCase()] = id;
    }
  }
  var insertadas = 0;
  for (final fila in parseo.filasValidas) {
    final fincaId = fila.fincaNombre == null
        ? null
        : indicePorNombre[fila.fincaNombre!.toLowerCase()];
    await db.guardarPlanta(Planta(
      fincaId: fincaId,
      cultivoId: fila.cultivoId,
      variedad: fila.variedad,
      latitud: fila.latitud,
      longitud: fila.longitud,
      fechaPlantacionMs: fila.fechaPlantacionMs,
      patron: fila.patron,
      etiqueta: fila.etiqueta,
      notas: fila.notas,
      fechaCreacionMs: ahora,
    ));
    insertadas++;
  }
  return insertadas;
}

/// Genera un CSV con todas las plantas (con o sin finca). Devuelve la
/// ruta del fichero temporal listo para compartir con share_plus.
Future<File> exportarPlantasACsv() async {
  final db = BaseDatosAgro.instancia;
  final fincas = await db.listarFincas();
  final indiceFincas = {for (final f in fincas) f.id!: f.nombre};
  final plantas = await db.listarPlantas();
  final formatoFecha = DateFormat('yyyy-MM-dd');
  final buffer = StringBuffer()
    ..writeln('cultivo_id,variedad,latitud,longitud,etiqueta,finca,fecha_plantacion,patron,notas');
  for (final p in plantas) {
    final fecha = p.fechaPlantacionMs == null
        ? ''
        : formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(p.fechaPlantacionMs!));
    buffer.writeln(filaCsvAString([
      p.cultivoId,
      p.variedad,
      p.latitud.toStringAsFixed(7),
      p.longitud.toStringAsFixed(7),
      p.etiqueta,
      p.fincaId != null ? (indiceFincas[p.fincaId] ?? '') : '',
      fecha,
      p.patron,
      p.notas,
    ]));
  }
  final dir = await getTemporaryDirectory();
  final ahora = DateTime.now();
  final nombre = 'plantas-${ahora.year}${ahora.month.toString().padLeft(2, '0')}${ahora.day.toString().padLeft(2, '0')}.csv';
  final fichero = File(path_lib.join(dir.path, nombre));
  await fichero.writeAsString(buffer.toString());
  return fichero;
}
