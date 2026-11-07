/// Lectura de `content/solera/plazos.csv` a [PlazoLegal].
///
/// Formato: líneas que empiezan por `#` son comentario (cabecera con
/// fuente y sello PROVISIONAL); después, una cabecera con las columnas
/// de [columnasPlazosCsv] y una fila por plazo. `verticales` se separa
/// con `|`. Según `periodicidad`:
///   - `anual`: `dia_fin`/`mes_fin` obligatorios; `dia_inicio`/
///     `mes_inicio` opcionales (vacíos = ventana de un solo día, cuando
///     la norma solo fija el límite).
///   - `mensual`: `dia_limite`.
///   - `trimestral`: `dia_limite` y, opcional, `dia_limite_cuarto_trimestre`.
///
/// Cualquier dato incoherente lanza [FormatException] con la línea: es
/// un fichero curado a mano y preferimos que el test lo pare antes que
/// avisar de una fecha equivocada.
library;

import '../csv/csv_io.dart';
import 'plazo_legal.dart';

const List<String> columnasPlazosCsv = [
  'identificador',
  'verticales',
  'nombre_visible',
  'norma_citada',
  'url_fuente',
  'periodicidad',
  'dia_inicio',
  'mes_inicio',
  'dia_fin',
  'mes_fin',
  'dia_limite',
  'dia_limite_cuarto_trimestre',
  'antelacion_aviso_dias',
  'nota',
];

/// Días máximos por mes contando el 29 de febrero (válido: se ajusta a
/// 28 en años no bisiestos al calcular).
const _diasMaximosPorMes = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

List<PlazoLegal> parsearPlazosCsv(String contenido) {
  final sinComentarios = contenido
      .split('\n')
      .where((linea) => !linea.trimLeft().startsWith('#'))
      .join('\n');
  final tabla = parsearTablaCsv(sinComentarios);
  final indices = indicesDeCabecera(tabla.cabecera);
  final columnasQueFaltan =
      columnasPlazosCsv.where((columna) => !indices.containsKey(columna));
  if (columnasQueFaltan.isNotEmpty) {
    throw FormatException(
        'plazos.csv: faltan columnas ${columnasQueFaltan.join(', ')}');
  }

  final plazos = <PlazoLegal>[];
  final identificadoresVistos = <String>{};
  for (var numeroFila = 0; numeroFila < tabla.filas.length; numeroFila++) {
    final fila = tabla.filas[numeroFila];
    String campo(String columna) => campoEnFila(fila, indices[columna]);
    final lector = _LectorFila(campo, numeroFila + 1);

    final identificador = lector.obligatorio('identificador');
    if (!identificadoresVistos.add(identificador)) {
      throw lector.error('identificador repetido «$identificador»');
    }

    final verticales = campo('verticales')
        .split('|')
        .map((vertical) => vertical.trim().toLowerCase())
        .where((vertical) => vertical.isNotEmpty)
        .toList();
    if (verticales.isEmpty) throw lector.error('sin verticales');
    for (final vertical in verticales) {
      if (!verticalesLarrea.contains(vertical)) {
        throw lector.error('vertical desconocida «$vertical»');
      }
    }

    final urlFuente = lector.obligatorio('url_fuente');
    final uriFuente = Uri.tryParse(urlFuente);
    if (uriFuente == null ||
        uriFuente.scheme != 'https' ||
        uriFuente.host.isEmpty) {
      throw lector.error('url_fuente debe ser https: «$urlFuente»');
    }

    plazos.add(PlazoLegal(
      identificador: identificador,
      verticales: verticales,
      nombreVisible: lector.obligatorio('nombre_visible'),
      normaCitada: lector.obligatorio('norma_citada'),
      urlFuente: urlFuente,
      periodicidad: _leerPeriodicidad(lector),
      antelacionAvisoDias:
          lector.entero('antelacion_aviso_dias', minimo: 0, maximo: 366) ?? 0,
      nota: campo('nota'),
    ));
  }
  return plazos;
}

PeriodicidadPlazo _leerPeriodicidad(_LectorFila lector) {
  final tipo = lector.obligatorio('periodicidad').toLowerCase();
  switch (tipo) {
    case 'anual':
      final mesFin = lector.enteroObligatorio('mes_fin', minimo: 1, maximo: 12);
      final diaFin = lector.enteroObligatorio('dia_fin',
          minimo: 1, maximo: _diasMaximosPorMes[mesFin - 1]);
      final mesInicio =
          lector.entero('mes_inicio', minimo: 1, maximo: 12) ?? mesFin;
      final diaInicio = lector.entero('dia_inicio',
              minimo: 1, maximo: _diasMaximosPorMes[mesInicio - 1]) ??
          (mesInicio == mesFin ? diaFin : null);
      if (diaInicio == null) {
        throw lector.error('mes_inicio sin dia_inicio');
      }
      return PeriodicidadAnual(
        diaInicio: diaInicio,
        mesInicio: mesInicio,
        diaFin: diaFin,
        mesFin: mesFin,
      );
    case 'mensual':
      return PeriodicidadMensual(
        diaLimite:
            lector.enteroObligatorio('dia_limite', minimo: 1, maximo: 31),
      );
    case 'trimestral':
      return PeriodicidadTrimestral(
        diaLimite:
            lector.enteroObligatorio('dia_limite', minimo: 1, maximo: 31),
        diaLimiteCuartoTrimestre:
            lector.entero('dia_limite_cuarto_trimestre', minimo: 1, maximo: 31),
      );
    default:
      throw lector.error('periodicidad desconocida «$tipo»');
  }
}

class _LectorFila {
  _LectorFila(this._campo, this._numeroFila);

  final String Function(String columna) _campo;
  final int _numeroFila;

  FormatException error(String motivo) =>
      FormatException('plazos.csv, fila de datos $_numeroFila: $motivo');

  String obligatorio(String columna) {
    final valor = _campo(columna);
    if (valor.isEmpty) throw error('$columna vacío');
    return valor;
  }

  int? entero(String columna, {required int minimo, required int maximo}) {
    final texto = _campo(columna);
    if (texto.isEmpty) return null;
    final valor = int.tryParse(texto);
    if (valor == null || valor < minimo || valor > maximo) {
      throw error('$columna fuera de rango ($minimo-$maximo): «$texto»');
    }
    return valor;
  }

  int enteroObligatorio(String columna,
      {required int minimo, required int maximo}) {
    final valor = entero(columna, minimo: minimo, maximo: maximo);
    if (valor == null) throw error('$columna vacío');
    return valor;
  }
}
