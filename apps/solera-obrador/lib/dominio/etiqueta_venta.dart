import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../modelos/alergenos.dart';
import '../modelos/ingrediente.dart';
import '../modelos/receta.dart';
import '../modelos/titular.dart';
import 'composicion_receta.dart';

// Etiqueta de venta de un producto del obrador. Fuentes leídas el
// 2026-11-10 (texto del DOUE L 304 de 22.11.2011 en el BOE y textos
// consolidados del BOE):
//
// - Reglamento (UE) 1169/2011, art. 9.1 (menciones obligatorias), art. 18.1
//   (ingredientes en orden decreciente de peso, título «ingredientes»),
//   art. 21.1 (alérgenos destacados tipográficamente; sin lista,
//   «contiene»), art. 22 y anexo VIII (cantidad de un ingrediente; punto
//   4.a: producto que pierde humedad al cocer → sobre el producto acabado),
//   art. 24 y anexo X (fechas; 1.d: sin fecha la panadería y repostería que
//   se consume en 24 h), art. 25 (conservación), art. 44 (no envasados:
//   solo alérgenos, salvo medidas nacionales), anexo IX.1 (cantidad neta no
//   obligatoria en ciertos casos), anexo V.19 (exención de la información
//   nutricional), anexo XV (orden de la tabla nutricional).
// - RD 126/2015: art. 4.1 (no envasados y envasados a petición del
//   comprador: denominación, alérgenos —salvo si la denominación ya lo
//   dice—, cantidad de ingredientes del art. 22), art. 5 (envasados por el
//   minorista para su venta inmediata: arts. 9 y 10 del Reglamento salvo la
//   9.1.l, la información nutricional), art. 6 (etiqueta o cartel junto al
//   alimento), art. 10 (al menos en castellano).
// - RD 308/2019: art. 13 (denominación legal del pan, arts. 4 y 6), art.
//   15.1 (pan común de más de 24 h: cartel) y art. 15.2 (a granel, con el
//   peso de la pieza).
// - RD 1808/1991: art. 3 (lote precedido de «L»), art. 2.2.b (no hace falta
//   en el producto sin envasar o envasado para venta inmediata).
//
// PROVISIONAL: el tamaño de letra mínimo (art. 13.2 y 13.3) se estima con
// la proporción de la altura de la x de la letra del PDF; el cálculo de si
// el texto cabe en la etiqueta es aproximado; los nombres de los alérgenos
// y la forma de destacarlos esperan la revisión de un técnico.

/// Envasado (etiqueta completa del art. 9) o granel/cartel (art. 44 y RD
/// 126/2015 art. 4).
enum ModoEtiqueta { envasado, granel }

/// Fecha de la etiqueta (anexo X).
enum TipoFechaEtiqueta {
  consumoPreferente,
  caducidad,

  /// Anexo X.1.d: panadería o repostería que se consume normalmente en las
  /// 24 h siguientes a su fabricación.
  sinFecha24h,
}

/// Hojas A4 con varias etiquetas en rejilla, o una sola por hoja (cartel).
enum FormatoEtiqueta {
  rejilla3x8(columnas: 3, filas: 8, tamanoLetraPt: 7),
  rejilla2x4(columnas: 2, filas: 4, tamanoLetraPt: 9),
  suelta(columnas: 1, filas: 1, tamanoLetraPt: 16);

  const FormatoEtiqueta({
    required this.columnas,
    required this.filas,
    required this.tamanoLetraPt,
  });

  final int columnas;
  final int filas;

  /// Tamaño del texto general. La denominación va más grande.
  final double tamanoLetraPt;

  int get porHoja => columnas * filas;
}

/// A4 en milímetros.
const double anchoA4Mm = 210;
const double altoA4Mm = 297;

/// Proporción altura de la x / cuerpo de la letra Archivo del core.
/// PROVISIONAL: medida aproximada (0,5); el técnico debe comprobarla en una
/// impresión.
const double proporcionAlturaX = 0.5;
const double milimetrosPorPunto = 25.4 / 72;

/// Altura de la x en mm para un cuerpo de letra en puntos.
double alturaXMm(double tamanoPt) =>
    tamanoPt * milimetrosPorPunto * proporcionAlturaX;

/// Art. 13.2: altura de la x ≥ 1,2 mm; art. 13.3: ≥ 0,9 mm si la superficie
/// mayor del envase es menor de 80 cm².
double alturaXMinimaMm({required bool superficieMenorDe80cm2}) =>
    superficieMenorDe80cm2 ? 0.9 : 1.2;

/// Hojas necesarias para [copias] etiquetas.
int hojasNecesarias(int copias, FormatoEtiqueta formato) =>
    copias <= 0 ? 0 : (copias + formato.porHoja - 1) ~/ formato.porHoja;

/// Rectángulo de una etiqueta en la hoja, en mm desde la esquina superior
/// izquierda.
class CeldaEtiqueta {
  const CeldaEtiqueta({
    required this.hoja,
    required this.izquierdaMm,
    required this.arribaMm,
    required this.anchoMm,
    required this.altoMm,
  });

  final int hoja;
  final double izquierdaMm;
  final double arribaMm;
  final double anchoMm;
  final double altoMm;
}

/// Celda de la etiqueta número [indice] (desde 0): se llena por filas.
/// Las rejillas ocupan la hoja entera (hojas de etiquetas adhesivas
/// 70 × 37 y 105 × 74 mm); la suelta deja 15 mm de margen.
CeldaEtiqueta celdaEtiqueta(int indice, FormatoEtiqueta formato) {
  final margen = formato == FormatoEtiqueta.suelta ? 15.0 : 0.0;
  final ancho = (anchoA4Mm - 2 * margen) / formato.columnas;
  final alto = (altoA4Mm - 2 * margen) / formato.filas;
  final enHoja = indice % formato.porHoja;
  return CeldaEtiqueta(
    hoja: indice ~/ formato.porHoja,
    izquierdaMm: margen + (enHoja % formato.columnas) * ancho,
    arribaMm: margen + (enHoja ~/ formato.columnas) * alto,
    anchoMm: ancho,
    altoMm: alto,
  );
}

/// Información nutricional por 100 g (art. 30.1, orden del anexo XV). Solo
/// la que introduce la persona: la app no la calcula.
class InfoNutricional {
  const InfoNutricional({
    required this.energiaKj,
    required this.energiaKcal,
    required this.grasas,
    required this.saturadas,
    required this.hidratos,
    required this.azucares,
    required this.proteinas,
    required this.sal,
  });

  final double energiaKj;
  final double energiaKcal;
  final double grasas;
  final double saturadas;
  final double hidratos;
  final double azucares;
  final double proteinas;
  final double sal;

  Map<String, Object?> aMapa() => {
        'energia_kj': energiaKj,
        'energia_kcal': energiaKcal,
        'grasas': grasas,
        'saturadas': saturadas,
        'hidratos': hidratos,
        'azucares': azucares,
        'proteinas': proteinas,
        'sal': sal,
      };

  /// Null si falta algún valor: la tabla va completa o no va.
  static InfoNutricional? deMapa(Object? mapa) {
    if (mapa is! Map) return null;
    double? valor(String clave) => (mapa[clave] as num?)?.toDouble();
    final valores = [
      for (final clave in [
        'energia_kj',
        'energia_kcal',
        'grasas',
        'saturadas',
        'hidratos',
        'azucares',
        'proteinas',
        'sal',
      ])
        valor(clave),
    ];
    if (valores.contains(null)) return null;
    return InfoNutricional(
      energiaKj: valores[0]!,
      energiaKcal: valores[1]!,
      grasas: valores[2]!,
      saturadas: valores[3]!,
      hidratos: valores[4]!,
      azucares: valores[5]!,
      proteinas: valores[6]!,
      sal: valores[7]!,
    );
  }
}

/// Lo que la persona apunta para la etiqueta de una receta (se guarda en
/// `etiquetas_receta` como JSON).
class DatosEtiquetaReceta {
  const DatosEtiquetaReceta({
    this.denominacion = '',
    this.cantidadNetaGramos,
    this.tipoFecha = TipoFechaEtiqueta.sinFecha24h,
    this.diasDuracion,
    this.conservacion = '',
    this.ingredientesConPorcentaje = const {},
    this.trazasIndicadas = const {},
    this.infoNutricional,
  });

  /// Vacía: el nombre de la receta.
  final String denominacion;

  /// Null: el peso de la pieza calculado.
  final double? cantidadNetaGramos;
  final TipoFechaEtiqueta tipoFecha;
  final int? diasDuracion;
  final String conservacion;

  /// Ingredientes con su porcentaje (art. 22: los que dan nombre al
  /// producto o se destacan). Los elige la persona.
  final Set<int> ingredientesConPorcentaje;

  /// «Puede contener»: solo lo que la persona indica. La app no lo deduce.
  final Set<String> trazasIndicadas;
  final InfoNutricional? infoNutricional;

  String aJson() => jsonEncode({
        'denominacion': denominacion,
        'cantidad_neta_g': cantidadNetaGramos,
        'tipo_fecha': tipoFecha.name,
        'dias_duracion': diasDuracion,
        'conservacion': conservacion,
        'ingredientes_con_porcentaje': ingredientesConPorcentaje.toList(),
        'trazas': codificarAlergenos(trazasIndicadas),
        'info_nutricional': infoNutricional?.aMapa(),
      });

  factory DatosEtiquetaReceta.deJson(String texto) {
    final mapa = jsonDecode(texto) as Map<String, Object?>;
    return DatosEtiquetaReceta(
      denominacion: (mapa['denominacion'] as String?) ?? '',
      cantidadNetaGramos: (mapa['cantidad_neta_g'] as num?)?.toDouble(),
      tipoFecha: TipoFechaEtiqueta.values.firstWhere(
        (tipo) => tipo.name == mapa['tipo_fecha'],
        orElse: () => TipoFechaEtiqueta.sinFecha24h,
      ),
      diasDuracion: mapa['dias_duracion'] as int?,
      conservacion: (mapa['conservacion'] as String?) ?? '',
      ingredientesConPorcentaje: {
        for (final id
            in (mapa['ingredientes_con_porcentaje'] as List?) ?? const [])
          id as int,
      },
      trazasIndicadas: decodificarAlergenos(mapa['trazas'] as String?),
      infoNutricional: InfoNutricional.deMapa(mapa['info_nutricional']),
    );
  }
}

/// Trozo de texto de la etiqueta; [destacado] va en negrita (art. 21.1.b).
class FragmentoEtiqueta {
  const FragmentoEtiqueta(this.texto, {this.destacado = false});

  final String texto;
  final bool destacado;

  @override
  bool operator ==(Object other) =>
      other is FragmentoEtiqueta &&
      other.texto == texto &&
      other.destacado == destacado;

  @override
  int get hashCode => Object.hash(texto, destacado);

  @override
  String toString() => destacado ? '**$texto**' : texto;
}

/// Una mención: «Título: contenido».
class LineaEtiqueta {
  const LineaEtiqueta(this.titulo, this.fragmentos);

  final String? titulo;
  final List<FragmentoEtiqueta> fragmentos;

  String get textoPlano =>
      '${titulo == null ? '' : '$titulo: '}${fragmentos.map((f) => f.texto).join()}';
}

/// Lo que se imprime en una etiqueta.
class ContenidoEtiqueta {
  const ContenidoEtiqueta({
    required this.denominacion,
    required this.lineas,
    this.tablaNutricional = const [],
    this.tituloNutricional,
  });

  final String denominacion;
  final List<LineaEtiqueta> lineas;

  /// (nutriente, valor por 100 g), en el orden del anexo XV.
  final List<(String, String)> tablaNutricional;
  final String? tituloNutricional;

  /// Todo el texto, para buscar y para los tests.
  String get textoPlano => [
        denominacion,
        ...lineas.map((linea) => linea.textoPlano),
        if (tituloNutricional != null) tituloNutricional!,
        for (final (nombre, valor) in tablaNutricional) '$nombre $valor',
      ].join('\n');
}

/// Raíces que, en castellano, ya nombran la sustancia del anexo II en el
/// nombre de un ingrediente («harina de trigo», «mantequilla» no).
const Map<String, List<String>> _raicesAlergeno = {
  'gluten': [
    'trigo',
    'centeno',
    'cebada',
    'avena',
    'espelta',
    'kamut',
    'gluten',
  ],
  'crustaceos': ['crustace'],
  'huevos': ['huevo'],
  'pescado': ['pescado'],
  'cacahuetes': ['cacahuete'],
  'soja': ['soja'],
  'lacteos': ['leche', 'lacteo', 'lactosa'],
  'frutos_cascara': [
    'almendra',
    'avellana',
    'nuez',
    'nueces',
    'anacardo',
    'pacana',
    'pistacho',
    'alfoncigo',
    'macadamia',
    'frutos de cascara',
  ],
  'apio': ['apio'],
  'mostaza': ['mostaza'],
  'sesamo': ['sesamo'],
  'sulfitos': ['sulfito', 'azufre'],
  'altramuces': ['altramuz', 'altramuces'],
  'moluscos': ['molusco'],
};

String _sinTildes(String texto) {
  const conTilde = 'áéíóúüÁÉÍÓÚÜ';
  const sinTilde = 'aeiouuAEIOUU';
  final buffer = StringBuffer();
  for (final caracter in texto.split('')) {
    final posicion = conTilde.indexOf(caracter);
    buffer.write(posicion < 0 ? caracter : sinTilde[posicion]);
  }
  return buffer.toString().toLowerCase();
}

/// ¿El nombre del ingrediente ya nombra el alérgeno? Solo en castellano:
/// si no se reconoce, se añade entre paréntesis (redundante, nunca falta).
bool nombreNombraAlergeno(String nombreIngrediente, String alergeno) {
  final nombre = _sinTildes(nombreIngrediente);
  return (_raicesAlergeno[alergeno] ?? const []).any(
    (raiz) => nombre.contains(raiz),
  );
}

/// Nombre del alérgeno para la etiqueta, como en el anexo II.
String nombreAlergenoEtiqueta(
  String id, {
  String idioma = 'es',
}) =>
    switch (id) {
      'gluten' => SoleraL10n.t('obra.etiq_l_alergeno_gluten', idioma: idioma),
      'crustaceos' => SoleraL10n.t(
          'obra.etiq_l_alergeno_crustaceos',
          idioma: idioma,
        ),
      'huevos' => SoleraL10n.t('obra.etiq_l_alergeno_huevos', idioma: idioma),
      'pescado' => SoleraL10n.t('obra.etiq_l_alergeno_pescado', idioma: idioma),
      'cacahuetes' => SoleraL10n.t(
          'obra.etiq_l_alergeno_cacahuetes',
          idioma: idioma,
        ),
      'soja' => SoleraL10n.t('obra.etiq_l_alergeno_soja', idioma: idioma),
      'lacteos' => SoleraL10n.t('obra.etiq_l_alergeno_lacteos', idioma: idioma),
      'frutos_cascara' => SoleraL10n.t(
          'obra.etiq_l_alergeno_frutos_cascara',
          idioma: idioma,
        ),
      'apio' => SoleraL10n.t('obra.etiq_l_alergeno_apio', idioma: idioma),
      'mostaza' => SoleraL10n.t('obra.etiq_l_alergeno_mostaza', idioma: idioma),
      'sesamo' => SoleraL10n.t('obra.etiq_l_alergeno_sesamo', idioma: idioma),
      'sulfitos' =>
        SoleraL10n.t('obra.etiq_l_alergeno_sulfitos', idioma: idioma),
      'altramuces' => SoleraL10n.t(
          'obra.etiq_l_alergeno_altramuces',
          idioma: idioma,
        ),
      'moluscos' =>
        SoleraL10n.t('obra.etiq_l_alergeno_moluscos', idioma: idioma),
      _ => id,
    };

/// Porcentaje de un ingrediente para la etiqueta (anexo VIII): sobre el
/// producto acabado si la receta pierde agua al cocer (4.a), si no sobre la
/// masa (3.a).
double porcentajeIngrediente(ComposicionReceta composicion, int id) {
  final gramos = composicion.gramosPorIngrediente[id] ?? 0;
  final base = composicion.gramosProductoCocido > 0
      ? composicion.gramosProductoCocido
      : composicion.gramosMasa;
  return base == 0 ? 0 : gramos / base * 100;
}

String _numero(num valor, {int decimales = 0}) =>
    NumberFormat.decimalPatternDigits(
      locale: 'es',
      decimalDigits: decimales,
    ).format(valor);

/// Lista de ingredientes por peso (art. 18.1) con los alérgenos destacados
/// (art. 21.1.b). Si el nombre no nombra la sustancia del anexo II, se
/// añade entre paréntesis y destacada. Con [conPorcentaje] (art. 22) se
/// añade el porcentaje; si la suma pasa de 100, en g por 100 g (anexo VIII
/// 4.a).
List<FragmentoEtiqueta> listaIngredientesDestacada(
  ComposicionReceta composicion,
  Map<int, Ingrediente> ingredientes, {
  Set<int> conPorcentaje = const {},
  String idioma = 'es',
}) {
  final porcentajes = {
    for (final id in conPorcentaje)
      if (composicion.gramosPorIngrediente.containsKey(id))
        id: porcentajeIngrediente(composicion, id),
  };
  final sumaPorcentajes = porcentajes.values.fold<double>(
    0,
    (suma, valor) => suma + valor,
  );
  final enGramosPor100 = sumaPorcentajes > 100;
  final fragmentos = <FragmentoEtiqueta>[];
  final orden = composicion.ingredientesPorPeso;
  for (var posicion = 0; posicion < orden.length; posicion++) {
    final id = orden[posicion];
    final ingrediente = ingredientes[id]!;
    if (posicion > 0) fragmentos.add(const FragmentoEtiqueta(', '));
    final alergenos =
        alergenosObligatorios.where(ingrediente.alergenos.contains).toList();
    final sinNombrar = alergenos
        .where(
          (alergeno) => !nombreNombraAlergeno(ingrediente.nombre, alergeno),
        )
        .toList();
    final nombreDestacado = alergenos.isNotEmpty && sinNombrar.isEmpty;
    fragmentos.add(
      FragmentoEtiqueta(ingrediente.nombre, destacado: nombreDestacado),
    );
    if (sinNombrar.isNotEmpty) {
      fragmentos.add(const FragmentoEtiqueta(' ('));
      for (var indice = 0; indice < sinNombrar.length; indice++) {
        if (indice > 0) fragmentos.add(const FragmentoEtiqueta(', '));
        fragmentos.add(
          FragmentoEtiqueta(
            nombreAlergenoEtiqueta(sinNombrar[indice], idioma: idioma),
            destacado: true,
          ),
        );
      }
      fragmentos.add(const FragmentoEtiqueta(')'));
    }
    final porcentaje = porcentajes[id];
    if (porcentaje != null) {
      fragmentos.add(
        FragmentoEtiqueta(
          enGramosPor100
              ? ' (${_numero(porcentaje)} g/100 g)'
              : ' (${_numero(porcentaje, decimales: porcentaje < 10 ? 1 : 0)} %)',
        ),
      );
    }
  }
  return _unirContiguos(fragmentos);
}

List<FragmentoEtiqueta> _unirContiguos(List<FragmentoEtiqueta> fragmentos) {
  final unidos = <FragmentoEtiqueta>[];
  for (final fragmento in fragmentos) {
    if (unidos.isNotEmpty && unidos.last.destacado == fragmento.destacado) {
      unidos.last = FragmentoEtiqueta(
        unidos.last.texto + fragmento.texto,
        destacado: fragmento.destacado,
      );
    } else {
      unidos.add(fragmento);
    }
  }
  return unidos;
}

/// Fragmentos de una lista de alérgenos, todos destacados.
List<FragmentoEtiqueta> _alergenosDestacados(
  Iterable<String> ids, {
  String idioma = 'es',
}) {
  final ordenados = alergenosObligatorios.where(ids.contains).toList();
  return _unirContiguos([
    for (var indice = 0; indice < ordenados.length; indice++) ...[
      if (indice > 0) const FragmentoEtiqueta(', '),
      FragmentoEtiqueta(
        nombreAlergenoEtiqueta(ordenados[indice], idioma: idioma),
        destacado: true,
      ),
    ],
  ]);
}

/// Fecha límite: la de elaboración más [dias] días naturales.
DateTime fechaLimite(DateTime elaboracion, int dias) =>
    DateTime(elaboracion.year, elaboracion.month, elaboracion.day + dias);

/// Hueco para escribir a mano lo que no se sabe al imprimir.
const String huecoAMano = '____________';

/// ¿La receta tiene denominación de pan? Todo el catálogo
/// (`denominaciones_pan.csv`) es de pan; RD 308/2019 art. 15.2: a granel,
/// el peso de la pieza.
bool esDenominacionDePan(String denominacion) => denominacion.isNotEmpty;

/// Título con el segundo idioma si lo hay: «Ingredientes / Osagaiak».
String _titulo(String clave, String idioma, String? segundoIdioma) {
  final principal = SoleraL10n.t(clave, idioma: idioma);
  if (segundoIdioma == null || segundoIdioma == idioma) return principal;
  final segundo = SoleraL10n.t(clave, idioma: segundoIdioma);
  return segundo == principal ? principal : '$principal / $segundo';
}

/// Compone la etiqueta. Sin [fechaElaboracion] ni [codigoLote] (desde la
/// receta), deja un hueco para escribirlos a mano.
ContenidoEtiqueta componerEtiqueta({
  required ModoEtiqueta modo,
  required Receta receta,
  required ComposicionReceta composicion,
  required Map<int, Ingrediente> ingredientes,
  required DatosEtiquetaReceta datos,
  required Titular titular,
  DateTime? fechaElaboracion,
  String? codigoLote,
  bool cocidoHaceMasDe24h = false,
  String idioma = 'es',
  String? segundoIdioma,
}) {
  String titulo(String clave) => _titulo(clave, idioma, segundoIdioma);
  final denominacion = datos.denominacion.trim().isEmpty
      ? receta.nombre
      : datos.denominacion.trim();
  final trazas = datos.trazasIndicadas.difference(composicion.alergenos);
  final lineaTrazas = trazas.isEmpty
      ? null
      : LineaEtiqueta(
          titulo('obra.etiq_l_puede_contener'),
          _alergenosDestacados(trazas, idioma: idioma),
        );
  final gramosPieza = datos.cantidadNetaGramos ?? composicion.gramosPorPieza;
  final textoGramos =
      gramosPieza > 0 ? '${_numero(gramosPieza)} g' : huecoAMano;

  if (modo == ModoEtiqueta.granel) {
    return ContenidoEtiqueta(
      denominacion: denominacion,
      lineas: [
        if (composicion.alergenos.isNotEmpty)
          LineaEtiqueta(
            titulo('obra.etiq_l_contiene'),
            _alergenosDestacados(composicion.alergenos, idioma: idioma),
          ),
        if (lineaTrazas != null) lineaTrazas,
        if (datos.ingredientesConPorcentaje.isNotEmpty)
          // RD 126/2015 art. 4.1.c: la cantidad del ingrediente (art. 22).
          LineaEtiqueta(titulo('obra.etiq_l_ingredientes'), [
            FragmentoEtiqueta(
              composicion.ingredientesPorPeso
                  .where(datos.ingredientesConPorcentaje.contains)
                  .map(
                    (id) =>
                        '${ingredientes[id]!.nombre} ${_numero(porcentajeIngrediente(composicion, id))} %',
                  )
                  .join(', '),
            ),
          ]),
        if (esDenominacionDePan(receta.denominacion))
          LineaEtiqueta(titulo('obra.etiq_l_peso_pieza'), [
            FragmentoEtiqueta(textoGramos),
          ]),
        if (cocidoHaceMasDe24h && receta.denominacion == 'pan_comun')
          LineaEtiqueta(null, [
            FragmentoEtiqueta(
              SoleraL10n.t('obra.etiq_l_cocido_24h', idioma: idioma),
              destacado: true,
            ),
          ]),
      ],
    );
  }

  final formatoFecha = DateFormat('dd/MM/yyyy');
  String textoFecha() {
    final dias = datos.diasDuracion;
    if (fechaElaboracion == null || dias == null) return huecoAMano;
    return formatoFecha.format(fechaLimite(fechaElaboracion, dias));
  }

  final info = datos.infoNutricional;
  return ContenidoEtiqueta(
    denominacion: denominacion,
    lineas: [
      LineaEtiqueta(
        titulo('obra.etiq_l_ingredientes'),
        listaIngredientesDestacada(
          composicion,
          ingredientes,
          conPorcentaje: datos.ingredientesConPorcentaje,
          idioma: idioma,
        ),
      ),
      if (lineaTrazas != null) lineaTrazas,
      LineaEtiqueta(titulo('obra.etiq_l_peso_neto'), [
        FragmentoEtiqueta(textoGramos),
      ]),
      switch (datos.tipoFecha) {
        TipoFechaEtiqueta.consumoPreferente => LineaEtiqueta(
            titulo('obra.etiq_l_consumo_preferente'),
            [FragmentoEtiqueta(textoFecha())],
          ),
        TipoFechaEtiqueta.caducidad => LineaEtiqueta(
            titulo('obra.etiq_l_caducidad'),
            [FragmentoEtiqueta(textoFecha())],
          ),
        TipoFechaEtiqueta.sinFecha24h => null,
      },
      if (datos.conservacion.trim().isNotEmpty)
        LineaEtiqueta(titulo('obra.etiq_l_conservacion'), [
          FragmentoEtiqueta(datos.conservacion.trim()),
        ]),
      LineaEtiqueta(titulo('obra.etiq_l_lote'), [
        FragmentoEtiqueta('L ${codigoLote ?? huecoAMano}'),
      ]),
      LineaEtiqueta(titulo('obra.etiq_l_elaborado_por'), [
        FragmentoEtiqueta(
          [
            if (titular.nombre.trim().isNotEmpty) titular.nombre.trim(),
            if (titular.direccion.trim().isNotEmpty) titular.direccion.trim(),
            if (titular.registroSanitario.trim().isNotEmpty)
              titular.registroSanitario.trim(),
          ].join(' · '),
        ),
      ]),
    ].whereType<LineaEtiqueta>().toList(),
    tituloNutricional:
        info == null ? null : titulo('obra.etiq_l_nutricional_100g'),
    tablaNutricional: info == null
        ? const []
        : [
            (
              SoleraL10n.t('obra.etiq_l_energia', idioma: idioma),
              '${_numero(info.energiaKj)} kJ / ${_numero(info.energiaKcal)} kcal',
            ),
            (
              SoleraL10n.t('obra.etiq_l_grasas', idioma: idioma),
              '${_numero(info.grasas, decimales: 1)} g',
            ),
            (
              SoleraL10n.t('obra.etiq_l_saturadas', idioma: idioma),
              '${_numero(info.saturadas, decimales: 1)} g',
            ),
            (
              SoleraL10n.t('obra.etiq_l_hidratos', idioma: idioma),
              '${_numero(info.hidratos, decimales: 1)} g',
            ),
            (
              SoleraL10n.t('obra.etiq_l_azucares', idioma: idioma),
              '${_numero(info.azucares, decimales: 1)} g',
            ),
            (
              SoleraL10n.t('obra.etiq_l_proteinas', idioma: idioma),
              '${_numero(info.proteinas, decimales: 1)} g',
            ),
            (
              SoleraL10n.t('obra.etiq_l_sal', idioma: idioma),
              '${_numero(info.sal, decimales: 2)} g',
            ),
          ],
  );
}

/// Avisos antes de imprimir (claves de traducción): lo que falta o lo que
/// la persona debe comprobar. No bloquean.
List<String> avisosEtiqueta({
  required ModoEtiqueta modo,
  required DatosEtiquetaReceta datos,
  required Titular titular,
  required ContenidoEtiqueta contenido,
  required FormatoEtiqueta formato,
  required bool tieneFechaYLote,
}) {
  final avisos = <String>[];
  if (modo == ModoEtiqueta.envasado) {
    if (titular.nombre.trim().isEmpty || titular.direccion.trim().isEmpty) {
      avisos.add('obra.etiq_aviso_falta_titular');
    }
    if (datos.tipoFecha != TipoFechaEtiqueta.sinFecha24h &&
        datos.diasDuracion == null) {
      avisos.add('obra.etiq_aviso_falta_duracion');
    }
    if (datos.tipoFecha == TipoFechaEtiqueta.caducidad &&
        datos.conservacion.trim().isEmpty) {
      avisos.add('obra.etiq_aviso_caducidad_sin_conservacion');
    }
    if (!tieneFechaYLote) avisos.add('obra.etiq_aviso_a_mano');
    if (datos.infoNutricional == null) {
      avisos.add('obra.etiq_aviso_sin_nutricional');
    }
  }
  if (!cabeEnEtiqueta(contenido, formato)) {
    avisos.add('obra.etiq_aviso_no_cabe');
  }
  return avisos;
}

/// Estimación de si el texto cabe en la celda con el tamaño de letra del
/// formato (ancho medio de carácter ≈ 0,5 del cuerpo; interlineado 1,2).
/// PROVISIONAL: aproximada; mira la vista previa antes de imprimir.
bool cabeEnEtiqueta(ContenidoEtiqueta contenido, FormatoEtiqueta formato) {
  final celda = celdaEtiqueta(0, formato);
  const rellenoMm = 3.0;
  final anchoUtilPt = (celda.anchoMm - 2 * rellenoMm) / milimetrosPorPunto;
  final altoUtilPt = (celda.altoMm - 2 * rellenoMm) / milimetrosPorPunto;
  final letra = formato.tamanoLetraPt;
  final caracteresPorLinea = (anchoUtilPt / (letra * 0.5)).floor();
  int lineas(String texto, double tamano) {
    final porLinea = (anchoUtilPt / (tamano * 0.5)).floor();
    return porLinea <= 0 ? 999 : (texto.length / porLinea).ceil().clamp(1, 999);
  }

  var altoPt = lineas(contenido.denominacion, letra * 1.4) * letra * 1.4 * 1.2;
  for (final linea in contenido.lineas) {
    altoPt += lineas(linea.textoPlano, letra) * letra * 1.2;
  }
  if (contenido.tablaNutricional.isNotEmpty) {
    altoPt += (contenido.tablaNutricional.length + 1) * letra * 1.2;
  }
  return caracteresPorLinea > 0 && altoPt <= altoUtilPt;
}
