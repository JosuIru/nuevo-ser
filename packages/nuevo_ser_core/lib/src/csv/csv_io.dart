/// Lectura y escritura de tablas CSV de bajo nivel.
///
/// El parser está deliberadamente recortado a las particularidades
/// que aparecen en las exportaciones reales que reciben las apps
/// del monorepo (Excel ES, LibreOffice, exportaciones a mano):
///   - delimitador `,` o `;` auto-detectado leyendo la primera línea
///   - BOM UTF-8 al inicio (Excel suele añadirlo en exportaciones ES)
///   - saltos de línea LF y CRLF
///   - campos entrecomillados con `"` y comillas escapadas dobles `""`
///
/// No tiramos del paquete `csv` para no añadir dependencia por algo
/// del orden de 100 líneas. Si el formato se complica (p. ej. campos
/// con salto de línea dentro de comillas) sustituimos por la dep.
///
/// El módulo es agnóstico al dominio: produce/consume `List<String>`
/// y la app que lo use mapea a sus propios modelos. Extraído de
/// `apps/agro/lib/servicios/csv_plantas.dart` para uso compartido por
/// la suite Solera (agro, viticultura, apícola, arbolado).
library;

/// Resultado de parsear un fichero CSV crudo: cabecera y filas, sin
/// interpretación del dominio. La cabecera es la primera línea no
/// vacía con sus campos en el orden original; `filas` excluye la
/// cabecera.
typedef TablaCsv = ({List<String> cabecera, List<List<String>> filas});

/// Parsea el contenido completo de un fichero CSV. Devuelve cabecera
/// vacía y filas vacías si el contenido está en blanco. No valida
/// contra ningún esquema — eso es trabajo del consumidor.
TablaCsv parsearTablaCsv(String contenido) {
  if (contenido.isEmpty) {
    return (cabecera: const [], filas: const []);
  }
  // BOM UTF-8 (Excel suele añadirlo en exportaciones ES).
  if (contenido.codeUnitAt(0) == 0xFEFF) {
    contenido = contenido.substring(1);
  }
  // Detectar delimitador en la primera línea: `;` solo si está y `,`
  // no está; en cualquier otro caso usa `,`. Heurística simple
  // suficiente para Excel ES vs Excel EN.
  final primeraLinea = contenido.split('\n').first;
  final delim =
      primeraLinea.contains(';') && !primeraLinea.contains(',') ? ';' : ',';
  final filasCrudas = <List<String>>[];
  for (final linea in contenido.split('\n')) {
    final limpia =
        linea.endsWith('\r') ? linea.substring(0, linea.length - 1) : linea;
    if (limpia.isEmpty) continue;
    filasCrudas.add(_parsearLinea(limpia, delim));
  }
  if (filasCrudas.isEmpty) {
    return (cabecera: const [], filas: const []);
  }
  return (cabecera: filasCrudas.first, filas: filasCrudas.sublist(1));
}

List<String> _parsearLinea(String linea, String delim) {
  final campos = <String>[];
  final actual = StringBuffer();
  var dentroComillas = false;
  for (var i = 0; i < linea.length; i++) {
    final c = linea[i];
    if (c == '"') {
      if (dentroComillas && i + 1 < linea.length && linea[i + 1] == '"') {
        actual.write('"');
        i++;
      } else {
        dentroComillas = !dentroComillas;
      }
    } else if (c == delim && !dentroComillas) {
      campos.add(actual.toString());
      actual.clear();
    } else {
      actual.write(c);
    }
  }
  campos.add(actual.toString());
  return campos;
}

/// Devuelve un mapa nombre→índice de las cabeceras, en minúsculas y
/// con espacios trimados. En caso de duplicados, el último gana
/// (comportamiento histórico de `apps/agro`). Los consumidores
/// pueden buscar alias con varias claves: `idx['cultivo_id'] ?? idx['cultivo']`.
Map<String, int> indicesDeCabecera(List<String> cabecera) {
  return {
    for (var i = 0; i < cabecera.length; i++)
      cabecera[i].trim().toLowerCase(): i,
  };
}

/// Devuelve el campo en el índice indicado, trimado. Si el índice es
/// `null` o cae fuera de la fila, devuelve cadena vacía. Pensado para
/// usarse después de `indicesDeCabecera` cuando algunas columnas son
/// opcionales y pueden no estar.
String campoEnFila(List<String> fila, int? indice) {
  if (indice == null || indice >= fila.length) return '';
  return fila[indice].trim();
}

/// Escapa un campo para incluirlo en una línea CSV. Si contiene
/// coma, comillas o salto de línea, lo entrecomilla y duplica las
/// comillas internas. En cualquier otro caso devuelve el campo tal
/// cual.
///
/// Se entrecomilla también si el campo contiene el [delim] en uso (con
/// `;` para Excel en castellano, un «Pienso; 2 sacos» partiría la fila) o
/// un retorno de carro.
String escaparCampoCsv(String campo, {String delim = ','}) {
  if (campo.contains(',') ||
      campo.contains(delim) ||
      campo.contains('"') ||
      campo.contains('\n') ||
      campo.contains('\r')) {
    return '"${campo.replaceAll('"', '""')}"';
  }
  return campo;
}

/// Construye una línea CSV uniendo los campos con el delimitador
/// indicado, escapando cada campo con `escaparCampoCsv`. No añade
/// salto de línea final — eso lo decide el consumidor.
String filaCsvAString(List<String> campos, {String delim = ','}) {
  return campos
      .map((campo) => escaparCampoCsv(campo, delim: delim))
      .join(delim);
}
