/// El ganado en hojas para Excel: censo de animales, movimientos y manejo
/// (curas, saneamientos, pesajes, partos, incidencias). Mismo formato que el
/// resto de exportaciones de la app: CSV con `;`, coma decimal, fechas
/// dd/mm/aaaa, UTF-8 con BOM y CRLF.
///
/// La hoja de animales usa las mismas columnas que entiende la importación
/// (`utiles/importar_animales.dart`): se puede exportar, corregir en Excel
/// y volver a importar.
library;

import '../modelos/constantes.dart';
import '../modelos/ganado.dart';
import '../modelos/ganado_ecologico.dart';
import '../utiles/importar_animales.dart';
import 'documento_generado.dart';
import 'generador_libro_explotacion.dart' show DatosGanado;

String _dosCifras(int valor) => valor.toString().padLeft(2, '0');

String _fecha(int? ms) {
  if (ms == null) return '';
  final fecha = DateTime.fromMillisecondsSinceEpoch(ms);
  return '${_dosCifras(fecha.day)}/${_dosCifras(fecha.month)}/${fecha.year}';
}

String _decimal(double? valor) {
  if (valor == null) return '';
  final texto = valor.toStringAsFixed(3).replaceAll(RegExp(r'\.?0+$'), '');
  return texto.replaceAll('.', ',');
}

/// Un texto libre listo para una celda: sin saltos de línea (el lector de
/// la app no los admite dentro de una celda) y sin que Excel lo tome por
/// una fórmula («=…», «+…», «@…»).
String _celda(String texto) {
  final enUnaLinea = texto.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
  if (enUnaLinea.isNotEmpty && '=+@'.contains(enUnaLinea[0])) {
    return "'$enUnaLinea";
  }
  return enUnaLinea;
}

String _etiqueta(List<OpcionCatalogo> catalogo, String codigo, String idioma) =>
    codigo.isEmpty
        ? ''
        : buscarOpcion(catalogo, codigo)?.etiqueta(idioma) ?? codigo;

/// Entre comillas solo si hace falta con `;` (no por una coma decimal:
/// «42,5» tiene que llegar a Excel como número).
String _campo(String texto) => RegExp(r'[;"\r\n]').hasMatch(texto)
    ? '"${texto.replaceAll('"', '""')}"'
    : texto;

String _csv(List<String> cabecera, List<List<String>> filas) {
  final lineas = [
    cabecera.map(_campo).join(';'),
    for (final fila in filas) fila.map((valor) => _campo(_celda(valor))).join(';'),
  ];
  return '${lineas.join('\r\n')}\r\n';
}

String _texto(String idioma, String castellano, String euskera) =>
    idioma == 'eu' ? euskera : castellano;

/// Censo de animales con las columnas de [ColumnaAnimal].
String animalesACsv(DatosGanado datos, String idioma) {
  final nombreLote = {
    for (final lote in datos.lotes)
      if (lote.id != null) lote.id!: lote.nombre
  };
  final animales = [...datos.animales]..sort((a, b) =>
      a.identificacion.toLowerCase().compareTo(b.identificacion.toLowerCase()));
  return _csv(
    [for (final columna in ColumnaAnimal.values) cabeceraColumnaAnimal(columna, idioma)],
    [
      for (final animal in animales)
        [
          for (final columna in ColumnaAnimal.values)
            switch (columna) {
              ColumnaAnimal.crotal => animal.identificacion,
              ColumnaAnimal.nombre => animal.nombre,
              ColumnaAnimal.especie =>
                _etiqueta(especiesGanado, animal.especie, idioma),
              ColumnaAnimal.raza => animal.raza,
              ColumnaAnimal.sexo => _etiqueta(sexosAnimal, animal.sexo, idioma),
              ColumnaAnimal.nacimiento => _fecha(animal.fechaNacimientoMs),
              ColumnaAnimal.madre => animal.madre,
              ColumnaAnimal.rebano => nombreLote[animal.loteId] ?? '',
              ColumnaAnimal.estado =>
                _etiqueta(estadosAnimal, animal.estado, idioma),
              ColumnaAnimal.fechaBaja =>
                animal.activo ? '' : _fecha(animal.fechaBajaMs),
              ColumnaAnimal.notas => animal.notas,
            },
        ],
    ],
  );
}

/// Los movimientos de los rebaños, del más antiguo al más reciente.
String movimientosACsv(DatosGanado datos, String idioma) {
  final nombreLote = {
    for (final lote in datos.lotes)
      if (lote.id != null) lote.id!: lote.nombre
  };
  final fueraDelEspacio =
      _texto(idioma, 'Fuera del espacio', 'Espaziotik kanpo');
  String externo(MovimientoGanado movimiento) =>
      movimiento.destinoExterno.isEmpty
          ? fueraDelEspacio
          : movimiento.destinoExterno;
  final movimientos = [...datos.movimientos]..sort((a, b) {
      final porFecha = a.fechaMs.compareTo(b.fechaMs);
      return porFecha != 0 ? porFecha : (a.id ?? 0).compareTo(b.id ?? 0);
    });
  return _csv(
    [
      _texto(idioma, 'Fecha', 'Data'),
      _texto(idioma, 'Rebaño', 'Taldea'),
      _texto(idioma, 'Tipo', 'Mota'),
      _texto(idioma, 'Origen', 'Jatorria'),
      _texto(idioma, 'Destino', 'Helmuga'),
      _texto(idioma, 'Cabezas', 'Buruak'),
      _texto(idioma, 'Guía', 'Gida'),
      _texto(idioma, 'Notas', 'Oharrak'),
    ],
    [
      for (final movimiento in movimientos)
        [
          _fecha(movimiento.fechaMs),
          nombreLote[movimiento.loteId] ?? '',
          _etiqueta(tiposMovimientoGanado, movimiento.tipo, idioma),
          movimiento.tipo == tipoMovimientoEntrada
              ? externo(movimiento)
              : datos.zonas[movimiento.zonaOrigenId] ?? '',
          movimiento.esSalida
              ? externo(movimiento)
              : datos.zonas[movimiento.zonaDestinoId] ?? '',
          movimiento.cabezas > 0 ? '${movimiento.cabezas}' : '',
          movimiento.guia,
          movimiento.notas,
        ],
    ],
  );
}

/// Curas, tratamientos, saneamientos, pesajes, partos e incidencias, de
/// cada animal o de un rebaño entero (crotal vacío), del más antiguo al más
/// reciente. Los plazos de supresión son los de la receta.
String manejoACsv(DatosGanado datos, String idioma) {
  final lotePorId = {
    for (final lote in datos.lotes)
      if (lote.id != null) lote.id!: lote
  };
  final animalPorId = {
    for (final animal in datos.animales)
      if (animal.id != null) animal.id!: animal
  };
  final eventos = [...datos.eventos]..sort((a, b) {
      final porFecha = a.fechaMs.compareTo(b.fechaMs);
      return porFecha != 0 ? porFecha : (a.id ?? 0).compareTo(b.id ?? 0);
    });
  return _csv(
    [
      _texto(idioma, 'Fecha', 'Data'),
      _texto(idioma, 'Crotal', 'Krotala'),
      _texto(idioma, 'Nombre', 'Izena'),
      _texto(idioma, 'Rebaño', 'Taldea'),
      _texto(idioma, 'Tipo', 'Mota'),
      _texto(idioma, 'Descripción', 'Deskribapena'),
      _texto(idioma, 'Sustancia activa', 'Substantzia aktiboa'),
      _texto(idioma, 'Clase de medicamento', 'Sendagai mota'),
      _texto(idioma, 'Dosis', 'Dosia'),
      _texto(idioma, 'Supresión carne (días)', 'Kentze-epea haragia (egun)'),
      _texto(idioma, 'Supresión leche (días)', 'Kentze-epea esnea (egun)'),
      _texto(idioma, 'Veterinario/a', 'Albaitaria'),
      _texto(idioma, 'Receta', 'Errezeta'),
      _texto(idioma, 'Peso (kg)', 'Pisua (kg)'),
      _texto(idioma, 'Crías', 'Kumeak'),
      _texto(idioma, 'Cabezas', 'Buruak'),
    ],
    [
      for (final evento in eventos)
        () {
          final animal = animalPorId[evento.animalId];
          final lote = lotePorId[evento.loteId ?? animal?.loteId];
          final conMedicamento =
              tiposEventoConMedicamento.contains(evento.tipo);
          return [
            _fecha(evento.fechaMs),
            animal?.identificacion ?? '',
            animal?.nombre ?? '',
            lote?.nombre ?? '',
            _etiqueta(tiposEventoGanado, evento.tipo, idioma),
            evento.descripcion,
            evento.sustanciaActiva,
            _etiqueta(clasesMedicamento, evento.claseMedicamento, idioma),
            evento.dosis,
            conMedicamento ? '${evento.plazoSupresionCarneDias}' : '',
            conMedicamento ? '${evento.plazoSupresionLecheDias}' : '',
            evento.veterinario,
            evento.receta,
            _decimal(evento.pesoKg),
            evento.crias > 0 ? '${evento.crias}' : '',
            evento.cabezas > 0 ? '${evento.cabezas}' : '',
          ];
        }(),
    ],
  );
}

String _hoy(DateTime ahora) =>
    '${ahora.year}-${_dosCifras(ahora.month)}-${_dosCifras(ahora.day)}';

/// Las tres hojas, listas para compartir o descargar.
List<DocumentoGenerado> documentosGanado(
    DatosGanado datos, String idioma, DateTime ahora) {
  final fecha = _hoy(ahora);
  return [
    DocumentoGenerado.csv(
        '${_texto(idioma, 'ganado_animales', 'abereak_animaliak')}_$fecha.csv',
        animalesACsv(datos, idioma)),
    DocumentoGenerado.csv(
        '${_texto(idioma, 'ganado_movimientos', 'abereak_mugimenduak')}_$fecha.csv',
        movimientosACsv(datos, idioma)),
    DocumentoGenerado.csv(
        '${_texto(idioma, 'ganado_manejo', 'abereak_maneiua')}_$fecha.csv',
        manejoACsv(datos, idioma)),
  ];
}

/// Hoja vacía con las columnas que entiende la importación de animales.
DocumentoGenerado plantillaImportacionAnimales(String idioma) =>
    DocumentoGenerado.csv(
      '${_texto(idioma, 'plantilla_animales', 'animalien_txantiloia')}.csv',
      _csv([
        for (final columna in ColumnaAnimal.values)
          cabeceraColumnaAnimal(columna, idioma)
      ], const []),
    );
