import 'dart:io';

import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/catalogos_generados/catalogo_plagas_olivo.dart';
import '../datos/catalogos_generados/catalogo_variedades_olivo.dart';

/// Resultado del análisis de una foto por Claude Vision en modo
/// "diagnosticar plaga". Salida estructurada para que la app pueda
/// pre-rellenar el formulario de tratamiento o incidencia tras la
/// revisión humana.
class ResultadoDiagnosticoPlaga {
  final String nombreComun;
  final String nombreCientifico;
  final String tipo;
  final int? severidad;
  final double confianza;
  final String manejoCultural;
  final String advertencia;

  /// `id` del catálogo `plagas_olivo` cuando el matching fuzzy lo
  /// encuentra; cadena vacía si la IA propuso algo fuera del catálogo
  /// (diagnóstico libre).
  final String idCatalogo;

  ResultadoDiagnosticoPlaga({
    required this.nombreComun,
    required this.nombreCientifico,
    required this.tipo,
    this.severidad,
    required this.confianza,
    required this.manejoCultural,
    this.advertencia = '',
    this.idCatalogo = '',
  });

  /// `true` cuando el diagnóstico coincide con una plaga del catálogo
  /// Solera (validada o provisional). La pantalla cliente muestra un
  /// chip distinto según este flag.
  bool get validadoPorCatalogo => idCatalogo.isNotEmpty;

  /// `true` si la plaga reconocida está marcada con
  /// `declaracion_oficial=si` en el catálogo (Xylella, verticilosis…).
  /// La app destaca este caso con un banner rojo.
  bool get esDeclaracionObligatoria {
    if (idCatalogo.isEmpty) return false;
    final plaga = plagaOlivoPorId(idCatalogo);
    return plaga != null && plaga.declaracionOficial;
  }
}

/// Resultado del análisis en modo "identificar variedad" de olivo.
class ResultadoIdentificacionVariedad {
  final String nombreCanonico;
  final double confianza;
  final String advertencia;
  /// `id` de la variedad del catálogo si la propuesta coincide; cadena
  /// vacía si la IA propuso algo fuera del catálogo (diagnóstico libre).
  final String idCatalogo;

  ResultadoIdentificacionVariedad({
    required this.nombreCanonico,
    required this.confianza,
    this.advertencia = '',
    this.idCatalogo = '',
  });

  bool get validadoPorCatalogo => idCatalogo.isNotEmpty;
}

/// Identificación por foto en el olivar con Claude (Haiku 5.5). El
/// transporte (petición, imagen, errores) es el `ClienteClaude` común
/// del core; aquí quedan los prompts y el cruce con los catálogos.
/// Dos modos:
///
///   * `diagnosticarPlaga` — la foto muestra hoja, aceituna, brote o
///     tronco con un posible problema sanitario. La IA devuelve un
///     diagnóstico estructurado (nombre, severidad, manejo cultural,
///     advertencia). La respuesta se contrasta con el catálogo
///     provisional `plagas_olivo` por matching fuzzy de nombre común
///     y nombre científico — si coincide, se marca como "validado
///     por catálogo" y, si la plaga es de declaración obligatoria, se
///     activa el banner rojo.
///
///   * `identificarVariedad` — la foto muestra una hoja u olivo en
///     duda. La IA devuelve la variedad más probable. La respuesta
///     se contrasta con el catálogo provisional `variedades_olivo`.
///
/// **Hard limit**: la IA NUNCA recomienda productos comerciales por
/// marca. Sólo manejo cultural + sustancias activas autorizadas en
/// olivar. Restringido a nivel de system prompt.
///
/// Los fallos llegan como [ErrorClaude], con el mensaje para la persona
/// (clave no válida, sin conexión, negativa por los filtros…).
class ClienteAnthropic {
  final ClienteClaude _clienteClaude;

  ClienteAnthropic(String claveApi)
      : _clienteClaude = ClienteClaude(claveApi: claveApi);

  Future<ResultadoDiagnosticoPlaga> diagnosticarPlaga({
    required File foto,
    String observacionesUsuario = '',
  }) async {
    final json = await _pedirJsonConFoto(
      foto: foto,
      promptSistema: _promptSistemaPlaga,
      promptUsuario: _construirPromptPlaga(observacionesUsuario),
    );
    final base = diagnosticoPlagaDesdeJson(json);
    return base.copyConCatalogo(
      idCatalogo: matchearPlagaConCatalogo(
        nombreComun: base.nombreComun,
        nombreCientifico: base.nombreCientifico,
      ),
    );
  }

  Future<ResultadoIdentificacionVariedad> identificarVariedad({
    required File foto,
    String observacionesUsuario = '',
  }) async {
    final json = await _pedirJsonConFoto(
      foto: foto,
      promptSistema: _promptSistemaVariedad,
      promptUsuario: _construirPromptVariedad(observacionesUsuario),
    );
    final base = identificacionVariedadDesdeJson(json);
    return base.copyConCatalogo(
      idCatalogo: matchearVariedadConCatalogo(base.nombreCanonico),
    );
  }

  Future<Map<String, dynamic>> _pedirJsonConFoto({
    required File foto,
    required String promptSistema,
    required String promptUsuario,
  }) async {
    final imagen = await ImagenClaude.desdeFichero(foto.path);
    return _clienteClaude.pedirJson(
      modelo: modeloClaudeRapido,
      sistema: promptSistema,
      mensajes: [MensajeClaude.usuario(promptUsuario, imagenes: [imagen])],
      maxTokens: 4096,
      esfuerzo: EsfuerzoClaude.bajo,
    );
  }
}

extension on ResultadoDiagnosticoPlaga {
  ResultadoDiagnosticoPlaga copyConCatalogo({required String idCatalogo}) =>
      ResultadoDiagnosticoPlaga(
        nombreComun: nombreComun,
        nombreCientifico: nombreCientifico,
        tipo: tipo,
        severidad: severidad,
        confianza: confianza,
        manejoCultural: manejoCultural,
        advertencia: advertencia,
        idCatalogo: idCatalogo,
      );
}

extension on ResultadoIdentificacionVariedad {
  ResultadoIdentificacionVariedad copyConCatalogo(
          {required String idCatalogo}) =>
      ResultadoIdentificacionVariedad(
        nombreCanonico: nombreCanonico,
        confianza: confianza,
        advertencia: advertencia,
        idCatalogo: idCatalogo,
      );
}

// ────────────────────── Prompts ──────────────────────

/// Prompt curado para diagnóstico de plagas y enfermedades del olivar.
/// Lista canónica de incidencias esperables en olivar peninsular. La
/// app contrasta la respuesta con el catálogo provisional
/// `plagas_olivo.csv` por matching fuzzy.
const String _promptSistemaPlaga = '''
Eres un agrónomo experto en olivicultura, especializado en *Olea europaea* en climas peninsulares (España, Portugal, sur de Francia, norte de Marruecos). Te paso una foto de hoja, aceituna, brote, ramillo o tronco con un posible problema sanitario y debes diagnosticarlo.

LISTA CANÓNICA DE INCIDENCIAS COMUNES EN OLIVAR (no exhaustiva — si ves algo distinto, lo describes igual):
- Plagas de insectos: mosca del olivo (*Bactrocera oleae*), polilla del olivo (*Prays oleae*), glifodes (*Palpita unionalis*), algodoncillo (*Euphyllura olivina*), taladrillo (*Phloeotribus scarabaeoides*), cochinillas (*Saissetia oleae*, *Parlatoria oleae*), mosquito del olivo (*Dasineura oleae*), arañuela del olivo (*Tetranychus urticae*).
- Enfermedades fúngicas: repilo (*Spilocaea oleaginea*), emplomado (*Pseudocercospora cladosporioides*), antracnosis o aceituna jabonosa (*Colletotrichum spp.*), escudete (*Camarosporium dalmaticum*), verticilosis (*Verticillium dahliae*).
- Enfermedades bacterianas: tuberculosis del olivo (*Pseudomonas savastanoi*), Xylella o decaimiento rápido (*Xylella fastidiosa*).
- Trastornos abióticos y fisiológicos: helada invernal, sequía severa, viento de levante/poniente, clorosis férrica, defoliación otoñal, abigarrado o mancha estrellada (sin agente).

REGLAS ESTRICTAS:

1. Responde SOLO con JSON, sin texto antes ni después. Sin bloques de código markdown.

2. Estructura del JSON:
{
  "nombre_comun": "nombre habitual en español de la plaga/enfermedad/trastorno",
  "nombre_cientifico": "nombre científico binomial si aplica, vacío si es un trastorno fisiológico/abiótico",
  "tipo": "plaga" | "enfermedad" | "fisiologico" | "abiotico" | "indeterminado",
  "severidad": número entero 1-5 estimado, o null si no es valorable,
  "confianza": número decimal 0.0-1.0 (cuánta confianza tienes en el diagnóstico),
  "manejo_cultural": "recomendaciones de manejo NO QUÍMICO en 2-3 frases (aclareo de copa, eliminación de restos, monitoreo, adelantar recolección, manejo de cubiertas, etc.). NO menciones nombres comerciales de productos fitosanitarios.",
  "advertencia": "si la foto es de baja calidad, hay dudas, o el síntoma es ambiguo, lo dices aquí. Vacío si confianza alta."
}

3. NUNCA recomiendes productos fitosanitarios concretos por nombre comercial. Esto es un compromiso legal de la app: solo manejo cultural en v0.1.

4. Si la foto NO es de olivo o no ves un problema, devuelve tipo="indeterminado", confianza=0.0, advertencia explicativa.

5. Sé conservador con la severidad: 5 solo para daños masivos / muerte del árbol, 1 para síntomas incipientes muy localizados.

6. Si dudas entre dos especies (p. ej. repilo vs emplomado en hoja), da la más probable y baja la confianza; explícalo en advertencia.

7. Si ves síntomas compatibles con Xylella (decaimiento rápido, secado generalizado), márcalo aunque la confianza sea baja — es de declaración obligatoria y el agricultor debe avisar al servicio fitosanitario CCAA en cualquier caso.
''';

/// Prompt curado para identificación de variedades de olivo.
const String _promptSistemaVariedad = '''
Eres un agrónomo experto en olivicultura, especializado en *Olea europaea* peninsular. Te paso una foto de hoja, fruto o conjunto de árbol y debes proponer la variedad más probable.

VARIEDADES MÁS HABITUALES en olivar peninsular: picual, hojiblanca, arbequina, cornicabra, manzanilla (cacereña o sevillana), gordal sevillana, empeltre, farga, morrut, lechín (de Sevilla o Granada), picudo, royal de Cazorla, arróniz, mallorquina, blanqueta, villalonga, verdial (de Vélez-Málaga o Huévar), aloreña, etc. Hay variedades minoritarias regionales — si crees que es una, lo dices.

REGLAS ESTRICTAS:

1. Responde SOLO con JSON, sin texto antes ni después. Sin bloques de código markdown.

2. Estructura del JSON:
{
  "nombre_canonico": "nombre canónico de la variedad propuesta",
  "confianza": número decimal 0.0-1.0 (cuánta confianza tienes en el diagnóstico),
  "advertencia": "si la foto es de baja calidad, faltan elementos clave (no se ve la hoja con detalle, sólo la copa…) o hay confusión con variedades similares, lo dices aquí. Vacío si confianza alta."
}

3. Si la foto NO es de olivo o no permite identificación, devuelve nombre_canonico="indeterminado", confianza=0.0, advertencia explicativa.

4. La identificación visual de variedades de olivo a partir de foto es difícil incluso para humanos expertos. Sé honesto: baja la confianza si tienes dudas y explícalas en advertencia.
''';

String _construirPromptPlaga(String observaciones) {
  final ctx = StringBuffer()
    ..writeln('Cultivo: Olivar (*Olea europaea*)');
  if (observaciones.trim().isNotEmpty) {
    ctx.writeln('\nObservaciones del usuario: ${observaciones.trim()}');
  }
  ctx.writeln('\nDiagnostica el problema visible en la foto.');
  return ctx.toString();
}

String _construirPromptVariedad(String observaciones) {
  final ctx = StringBuffer()
    ..writeln('Cultivo: Olivar (*Olea europaea*)');
  if (observaciones.trim().isNotEmpty) {
    ctx.writeln('\nObservaciones del usuario: ${observaciones.trim()}');
  }
  ctx.writeln('\nPropón la variedad más probable visible en la foto.');
  return ctx.toString();
}

// ────────────────────── Parsing y matching ──────────────────────

/// Expone el parser de la respuesta de plagas como función pública
/// para que los tests puedan ejercerlo sin hacer HTTP. Tolera vallas
/// ```json``` y texto alrededor; si no hay objeto JSON lanza
/// [ErrorClaude] (`respuestaRara`).
ResultadoDiagnosticoPlaga parsearDiagnosticoPlaga(String texto) =>
    diagnosticoPlagaDesdeJson(_objetoJsonDe(texto));

/// Diagnóstico a partir del objeto JSON ya leído.
ResultadoDiagnosticoPlaga diagnosticoPlagaDesdeJson(
        Map<String, dynamic> json) =>
    ResultadoDiagnosticoPlaga(
      nombreComun: _textoDe(json['nombre_comun'], 'Sin diagnóstico'),
      nombreCientifico: _textoDe(json['nombre_cientifico'], ''),
      tipo: _textoDe(json['tipo'], 'indeterminado'),
      severidad: (json['severidad'] is num)
          ? (json['severidad'] as num).toInt()
          : null,
      confianza: _confianzaDe(json['confianza']),
      manejoCultural: _textoDe(json['manejo_cultural'], ''),
      advertencia: _textoDe(json['advertencia'], ''),
    );

/// Parser de la respuesta de identificación de variedades.
ResultadoIdentificacionVariedad parsearIdentificacionVariedad(String texto) =>
    identificacionVariedadDesdeJson(_objetoJsonDe(texto));

/// Identificación de variedad a partir del objeto JSON ya leído.
ResultadoIdentificacionVariedad identificacionVariedadDesdeJson(
        Map<String, dynamic> json) =>
    ResultadoIdentificacionVariedad(
      nombreCanonico: _textoDe(json['nombre_canonico'], 'indeterminado'),
      confianza: _confianzaDe(json['confianza']),
      advertencia: _textoDe(json['advertencia'], ''),
    );

Map<String, dynamic> _objetoJsonDe(String texto) {
  final objeto = ClienteClaude.extraerObjetoJson(texto);
  if (objeto == null) {
    throw ErrorClaude(MotivoErrorClaude.respuestaRara,
        'Claude no ha devuelto los datos en el formato esperado. Inténtalo de nuevo.');
  }
  return objeto;
}

String _textoDe(Object? valor, String porDefecto) =>
    valor is String ? valor : porDefecto;

double _confianzaDe(Object? valor) =>
    (valor is num ? valor.toDouble() : 0.0).clamp(0, 1).toDouble();

/// Devuelve el `id` de la plaga del catálogo que mejor case con los
/// nombres devueltos por la IA, o cadena vacía si no encuentra ninguna.
/// Prioridad: nombre científico exacto > nombre común exacto > coincidencia
/// parcial por sub-cadena.
String matchearPlagaConCatalogo({
  required String nombreComun,
  required String nombreCientifico,
}) {
  final qComun = _normalizar(nombreComun);
  final qCient = _normalizar(nombreCientifico);
  if (qComun.isEmpty && qCient.isEmpty) return '';
  // 1ª pasada: igualdad exacta normalizada.
  for (final plaga in catalogoPlagasOlivo) {
    if (qCient.isNotEmpty &&
        plaga.nombreCientifico.isNotEmpty &&
        _normalizar(plaga.nombreCientifico) == qCient) {
      return plaga.id;
    }
    if (qComun.isNotEmpty && _normalizar(plaga.nombreComun) == qComun) {
      return plaga.id;
    }
  }
  // 2ª pasada: contiene.
  for (final plaga in catalogoPlagasOlivo) {
    if (qCient.isNotEmpty &&
        plaga.nombreCientifico.isNotEmpty &&
        _normalizar(plaga.nombreCientifico).contains(qCient)) {
      return plaga.id;
    }
    if (qComun.isNotEmpty &&
        _normalizar(plaga.nombreComun).contains(qComun)) {
      return plaga.id;
    }
  }
  return '';
}

/// Devuelve el `id` de la variedad del catálogo que mejor case con el
/// nombre canónico devuelto por la IA, o cadena vacía.
String matchearVariedadConCatalogo(String nombreCanonico) {
  final q = _normalizar(nombreCanonico);
  if (q.isEmpty) return '';
  // 1ª pasada: igualdad exacta normalizada (sin acentos).
  for (final variedad in catalogoVariedadesOlivo) {
    if (_normalizar(variedad.nombreCanonico) == q) {
      return variedad.id;
    }
    if (variedad.id == q) return variedad.id;
  }
  // 2ª pasada: contiene en nombre o sinonimias.
  for (final variedad in catalogoVariedadesOlivo) {
    if (_normalizar(variedad.nombreCanonico).contains(q)) {
      return variedad.id;
    }
    for (final sin in variedad.sinonimias) {
      if (_normalizar(sin).contains(q)) return variedad.id;
    }
  }
  return '';
}

String _normalizar(String texto) {
  return texto
      .toLowerCase()
      .replaceAll(RegExp(r'[áàä]'), 'a')
      .replaceAll(RegExp(r'[éèë]'), 'e')
      .replaceAll(RegExp(r'[íìï]'), 'i')
      .replaceAll(RegExp(r'[óòö]'), 'o')
      .replaceAll(RegExp(r'[úùü]'), 'u')
      .replaceAll('ñ', 'n')
      .trim();
}
