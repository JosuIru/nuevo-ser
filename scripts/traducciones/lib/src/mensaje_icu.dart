/// Análisis mínimo de mensajes ICU tal y como los usa `flutter gen-l10n`
/// (placeholders `{x}`, `plural`, `select`), suficiente para comprobar que una
/// traducción conserva la estructura del español.
///
/// Los apóstrofos se tratan como texto literal, igual que `gen-l10n` con
/// `use-escaping: false` (su valor por defecto), porque el catalán y el
/// gallego los usan constantemente.
library;

/// Error de sintaxis en un mensaje ICU.
class ErrorIcu implements Exception {
  ErrorIcu(this.mensaje);
  final String mensaje;
  @override
  String toString() => 'ErrorIcu: $mensaje';
}

/// Un argumento `{nombre}` o `{nombre, tipo, casos...}` dentro del mensaje.
class ArgumentoIcu {
  ArgumentoIcu(this.nombre, {this.tipo, this.casos = const {}});

  final String nombre;

  /// `plural`, `select`, `selectordinal`, `number`... o `null` si es un
  /// placeholder simple.
  final String? tipo;

  /// Submensajes de cada caso (`=1`, `other`...), solo en plural/select.
  final Map<String, List<ArgumentoIcu>> casos;

  bool get tieneCasos =>
      tipo == 'plural' || tipo == 'select' || tipo == 'selectordinal';
}

const _tiposConCasos = {'plural', 'select', 'selectordinal'};
const _categoriasPlural = {'zero', 'one', 'two', 'few', 'many', 'other'};

/// Analiza [mensaje] y devuelve los argumentos de primer nivel (con sus
/// casos anidados). Lanza [ErrorIcu] si la sintaxis no es válida.
List<ArgumentoIcu> analizarMensajeIcu(String mensaje) {
  final analizador = _AnalizadorIcu(mensaje);
  final argumentos = analizador.leerMensaje(dentroDeCaso: false);
  if (analizador.posicion < mensaje.length) {
    throw ErrorIcu('llave de cierre «}» sobrante en la posición '
        '${analizador.posicion + 1}');
  }
  return argumentos;
}

class _AnalizadorIcu {
  _AnalizadorIcu(this.texto);

  final String texto;
  int posicion = 0;

  List<ArgumentoIcu> leerMensaje({required bool dentroDeCaso}) {
    final argumentos = <ArgumentoIcu>[];
    while (posicion < texto.length) {
      final caracter = texto[posicion];
      if (caracter == '{') {
        posicion++;
        argumentos.add(_leerArgumento());
      } else if (caracter == '}') {
        if (dentroDeCaso) return argumentos;
        throw ErrorIcu('llave de cierre «}» sobrante en la posición '
            '${posicion + 1}');
      } else {
        posicion++;
      }
    }
    if (dentroDeCaso) {
      throw ErrorIcu('falta una llave de cierre «}» al final');
    }
    return argumentos;
  }

  ArgumentoIcu _leerArgumento() {
    final nombre = _leerHasta({',', '}'}).trim();
    if (nombre.isEmpty) throw ErrorIcu('hay un placeholder «{}» sin nombre');
    if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(nombre)) {
      throw ErrorIcu('«{$nombre}» no es un nombre de placeholder válido');
    }
    if (_caracterActual() == '}') {
      posicion++;
      return ArgumentoIcu(nombre);
    }
    posicion++; // coma
    final tipo = _leerHasta({',', '}'}).trim();
    if (!_tiposConCasos.contains(tipo)) {
      // {n, number} u otros formatos: se tratan como placeholder con tipo.
      if (_caracterActual() == ',') _leerHasta({'}'});
      posicion++;
      return ArgumentoIcu(nombre, tipo: tipo);
    }
    if (_caracterActual() != ',') {
      throw ErrorIcu('«{$nombre, $tipo}» no tiene casos');
    }
    posicion++; // coma
    final casos = <String, List<ArgumentoIcu>>{};
    while (true) {
      _saltarEspacios();
      if (_caracterActual() == '}') {
        posicion++;
        break;
      }
      final claveCaso = _leerHasta({'{', '}'}).trim();
      if (_caracterActual() != '{' || claveCaso.isEmpty) {
        throw ErrorIcu('caso mal formado en «{$nombre, $tipo, ...}»');
      }
      if (claveCaso.startsWith('offset:')) {
        throw ErrorIcu('«offset:» no está soportado');
      }
      posicion++; // llave de apertura del caso
      casos[claveCaso] = leerMensaje(dentroDeCaso: true);
      posicion++; // llave de cierre del caso
    }
    if (casos.isEmpty) throw ErrorIcu('«{$nombre, $tipo}» no tiene casos');
    return ArgumentoIcu(nombre, tipo: tipo, casos: casos);
  }

  String? _caracterActual() => posicion < texto.length ? texto[posicion] : null;

  void _saltarEspacios() {
    while (posicion < texto.length && texto[posicion].trim().isEmpty) {
      posicion++;
    }
  }

  String _leerHasta(Set<String> delimitadores) {
    final inicio = posicion;
    while (
        posicion < texto.length && !delimitadores.contains(texto[posicion])) {
      if (texto[posicion] == '{') {
        throw ErrorIcu('llave «{» inesperada en la posición ${posicion + 1}');
      }
      posicion++;
    }
    if (posicion >= texto.length) {
      throw ErrorIcu('falta una llave de cierre «}» al final');
    }
    return texto.substring(inicio, posicion);
  }
}

/// Compara la estructura de [traduccion] con la de [referencia] (el español).
/// Devuelve `null` si coinciden o una explicación en castellano si no.
///
/// Se exige: sintaxis válida, el mismo conjunto de nombres de placeholder,
/// el mismo tipo (`plural`/`select`) en cada argumento con casos, `other` en
/// todo plural, solo categorías de plural válidas (`=N`, `zero`, `one`,
/// `two`, `few`, `many`, `other`) y, en `select`, exactamente los mismos
/// casos que el español. Los casos de un plural pueden diferir del español,
/// porque cada lengua tiene sus propias reglas de plural.
String? compararEstructuraIcu(String referencia, String traduccion) {
  final List<ArgumentoIcu> argumentosReferencia;
  try {
    argumentosReferencia = analizarMensajeIcu(referencia);
  } on ErrorIcu catch (error) {
    return 'el texto en español no es ICU válido (${error.mensaje})';
  }
  final List<ArgumentoIcu> argumentosTraduccion;
  try {
    argumentosTraduccion = analizarMensajeIcu(traduccion);
  } on ErrorIcu catch (error) {
    return 'error de sintaxis: ${error.mensaje}';
  }

  final nombresReferencia = _recogerNombres(argumentosReferencia);
  final nombresTraduccion = _recogerNombres(argumentosTraduccion);
  final nombresQueFaltan = nombresReferencia.difference(nombresTraduccion);
  final nombresQueSobran = nombresTraduccion.difference(nombresReferencia);
  if (nombresQueFaltan.isNotEmpty || nombresQueSobran.isNotEmpty) {
    final partes = [
      if (nombresQueFaltan.isNotEmpty)
        'faltan ${nombresQueFaltan.map((nombre) => '{$nombre}').join(', ')}',
      if (nombresQueSobran.isNotEmpty)
        'sobran ${nombresQueSobran.map((nombre) => '{$nombre}').join(', ')}',
    ];
    return 'placeholders distintos del español: ${partes.join('; ')}';
  }

  final conCasosReferencia = _recogerArgumentosConCasos(argumentosReferencia);
  final conCasosTraduccion = _recogerArgumentosConCasos(argumentosTraduccion);

  for (final MapEntry(key: nombre, value: usosReferencia)
      in conCasosReferencia.entries) {
    final tipoReferencia = usosReferencia.first.tipo;
    final usosTraduccion = conCasosTraduccion[nombre] ?? const [];
    if (usosTraduccion.isEmpty) {
      return '{$nombre} es un $tipoReferencia en español y aquí no';
    }
    for (final uso in usosTraduccion) {
      if (uso.tipo != tipoReferencia) {
        return '{$nombre} es un $tipoReferencia en español y aquí un ${uso.tipo}';
      }
    }
    if (tipoReferencia == 'select') {
      final casosReferencia = {
        for (final uso in usosReferencia) ...uso.casos.keys,
      };
      for (final uso in usosTraduccion) {
        final casosTraduccion = uso.casos.keys.toSet();
        if (casosTraduccion.length != casosReferencia.length ||
            !casosTraduccion.containsAll(casosReferencia)) {
          return 'el select {$nombre} debe tener los casos '
              '${casosReferencia.join(', ')} (tiene ${casosTraduccion.join(', ')})';
        }
      }
    }
  }
  for (final MapEntry(key: nombre, value: usosTraduccion)
      in conCasosTraduccion.entries) {
    if (!conCasosReferencia.containsKey(nombre)) {
      return '{$nombre} no es un ${usosTraduccion.first.tipo} en español';
    }
    for (final uso in usosTraduccion) {
      if (uso.tipo == 'select') continue;
      if (!uso.casos.containsKey('other')) {
        return 'el plural {$nombre} necesita el caso «other»';
      }
      for (final claveCaso in uso.casos.keys) {
        final esCasoValido = _categoriasPlural.contains(claveCaso) ||
            RegExp(r'^=\d+$').hasMatch(claveCaso);
        if (!esCasoValido) {
          return 'el plural {$nombre} tiene un caso no válido «$claveCaso» '
              '(valen =0, =1..., zero, one, two, few, many, other)';
        }
      }
    }
  }
  return null;
}

Set<String> _recogerNombres(List<ArgumentoIcu> argumentos) {
  final nombres = <String>{};
  for (final argumento in argumentos) {
    nombres.add(argumento.nombre);
    for (final submensaje in argumento.casos.values) {
      nombres.addAll(_recogerNombres(submensaje));
    }
  }
  return nombres;
}

Map<String, List<ArgumentoIcu>> _recogerArgumentosConCasos(
    List<ArgumentoIcu> argumentos,
    [Map<String, List<ArgumentoIcu>>? acumulado]) {
  final resultado = acumulado ?? <String, List<ArgumentoIcu>>{};
  for (final argumento in argumentos) {
    if (argumento.tieneCasos) {
      resultado.putIfAbsent(argumento.nombre, () => []).add(argumento);
    }
    for (final submensaje in argumento.casos.values) {
      _recogerArgumentosConCasos(submensaje, resultado);
    }
  }
  return resultado;
}
