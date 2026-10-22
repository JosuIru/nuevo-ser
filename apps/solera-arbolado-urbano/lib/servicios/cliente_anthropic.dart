import 'dart:io';

import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Resultado del análisis de una foto de arbolado urbano por Claude
/// vision. Salida estructurada para que la app pueda pre-rellenar el
/// formulario de incidencia o tratamiento tras revisión humana.
class ResultadoAnalisisIA {
  /// Tipo del análisis: "especie" si pidió identificar la especie del
  /// árbol, "plaga" si pidió diagnóstico fitosanitario.
  final String tipoAnalisis;

  // Identificación de especie (sólo si tipoAnalisis = 'especie').
  final String especieNombreComun;
  final String especieNombreCientifico;

  // Diagnóstico fitosanitario (sólo si tipoAnalisis = 'plaga').
  final String plagaNombreComun;
  final String plagaNombreCientifico;
  final String tipoPlaga;
  final int? severidad;
  final String manejoCultural;
  final bool declaracionOficialSugerida;
  final bool riesgoSanitarioPublicoSugerido;

  // Comunes a ambos tipos.
  final double confianza;
  final String advertencia;

  ResultadoAnalisisIA({
    required this.tipoAnalisis,
    this.especieNombreComun = '',
    this.especieNombreCientifico = '',
    this.plagaNombreComun = '',
    this.plagaNombreCientifico = '',
    this.tipoPlaga = '',
    this.severidad,
    this.manejoCultural = '',
    this.declaracionOficialSugerida = false,
    this.riesgoSanitarioPublicoSugerido = false,
    required this.confianza,
    this.advertencia = '',
  });
}

/// Error propio de la app antes de llamar a Claude (p. ej. foto demasiado
/// grande). Los de la API llegan como [ErrorClaude].
class ErrorIA implements Exception {
  final String mensaje;
  ErrorIA(this.mensaje);
  @override
  String toString() => 'ErrorIA: $mensaje';
}

/// Prefijo de las preferencias de la app (la clave de Anthropic vive en
/// `solera_arbolado_urbano.anthropic.clave`, como siempre).
const String prefijoPreferenciasArbolado = 'solera_arbolado_urbano';

/// Clave de Anthropic de esta app (instancia única).
final EstadoClaveAnthropic estadoClaveAnthropic =
    EstadoClaveAnthropic.paraApp(prefijoPreferenciasArbolado);

/// Prueba [clave] con una llamada mínima a Claude. Devuelve null si
/// funciona o el mensaje del error si no.
Future<String?> probarClaveAnthropic(String clave,
    {ClienteClaude? clienteClaude}) async {
  final cliente = clienteClaude ?? ClienteClaude(claveApi: clave);
  try {
    await cliente.pedirTexto(
      modelo: modeloClaudeRapido,
      mensajes: [MensajeClaude.usuario('Responde solo: ok')],
      maxTokens: 1024,
      esfuerzo: EsfuerzoClaude.bajo,
    );
    return null;
  } on ErrorClaude catch (error) {
    return error.mensaje;
  }
}

/// Modo de análisis de la foto. La cámara apícola es una sola foto y un
/// solo prompt; aquí distinguimos porque el operario puede querer
/// identificar la **especie** (al censar un árbol nuevo sin chapa) o
/// diagnosticar una **plaga** (al levantar una incidencia).
enum ModoAnalisisIA { identificarEspecie, diagnosticarPlaga }

/// Análisis de fotos de arbolado urbano con Claude (visión). Identifica
/// especies arbóreas urbanas habituales en Iberia o diagnostica plagas y
/// enfermedades. El transporte (petición, imagen, errores) es el
/// [ClienteClaude] del core; aquí quedan el prompt y la lectura del JSON a
/// [ResultadoAnalisisIA]. Los fallos de la API llegan como [ErrorClaude],
/// con su mensaje ya listo para enseñar.
class ClienteAnthropic {
  ClienteAnthropic(String claveApi, {ClienteClaude? clienteClaude})
      : _clienteClaude = clienteClaude ?? ClienteClaude(claveApi: claveApi);

  final ClienteClaude _clienteClaude;

  /// Tope de tamaño de la foto que acepta la API.
  static const int tamanoMaximoFotoBytes = 5 * 1024 * 1024;

  Future<ResultadoAnalisisIA> analizarFoto({
    required File foto,
    required ModoAnalisisIA modo,
    String observacionesUsuario = '',
  }) async {
    final imagen = await ImagenClaude.desdeFichero(foto.path);
    if (imagen.bytes.length > tamanoMaximoFotoBytes) {
      throw ErrorIA(
        'La foto pesa más de 5 MB y la API la rechazará. '
        'Reduce el tamaño antes de enviarla.',
      );
    }
    final json = await _clienteClaude.pedirJson(
      modelo: modeloClaudeRapido,
      sistema: modo == ModoAnalisisIA.identificarEspecie
          ? _promptEspecies
          : _promptPlagas,
      mensajes: [
        MensajeClaude.usuario(
          _construirPrompt(modo, observacionesUsuario),
          imagenes: [imagen],
        ),
      ],
      maxTokens: 4096,
      esfuerzo: EsfuerzoClaude.bajo,
    );
    return resultadoDesdeJson(json, modo);
  }
}

/// System prompt para identificación de especies arbóreas urbanas.
const String _promptEspecies = '''
Eres un ingeniero técnico forestal especializado en arbolado urbano peninsular (España, Portugal). Te paso una foto de un árbol urbano (tronco, corteza, hoja, fruto, copa) y debes identificar la especie.

LISTA CANÓNICA DE ESPECIES URBANAS FRECUENTES EN IBERIA (no exhaustiva — si ves algo distinto, lo describes igual):
- Plátano de sombra (Platanus × hispanica), tilo (Tilia), fresno (Fraxinus), arce negundo, almendro ornamental, robinia, jacarandá.
- Pino piñonero, pino carrasco, ciprés mediterráneo, cedro, ginkgo.
- Palmera datilera (Phoenix dactylifera), palmera canaria (Phoenix canariensis).
- Naranjo amargo, magnolio, ficus, sófora, lagerstroemia, paulownia, catalpa.
- Encina, alcornoque, melojo, olmo siberiano, olmo común, almez, abedul.

REGLAS ESTRICTAS:

1. Responde SOLO con JSON, sin texto antes ni después. Sin bloques de código markdown.

2. Estructura del JSON:
{
  "tipo_analisis": "especie",
  "especie_nombre_comun": "nombre habitual en español",
  "especie_nombre_cientifico": "binomial latino",
  "confianza": número decimal 0.0-1.0,
  "advertencia": "vacío si confianza alta; si la foto es ambigua o sólo se ve corteza, lo dices aquí"
}

3. Si la foto NO es de un árbol o no puedes identificar nada, devuelve confianza=0.0 y advertencia explicativa.

4. Si dudas entre dos especies similares (p. ej. tilo común vs tilo plateado), da la más probable y baja la confianza; explícalo en advertencia.
''';

/// System prompt para diagnóstico de plagas urbanas.
const String _promptPlagas = '''
Eres un ingeniero técnico forestal especializado en sanidad de arbolado urbano peninsular (España, Portugal). Te paso una foto de un árbol urbano con un posible problema sanitario (hoja con manchas, tronco con galerías, ramas marchitas, bolsones, etc.) y debes diagnosticarlo.

LISTA CANÓNICA DE PATOLOGÍAS URBANAS COMUNES EN IBERIA:
- Plagas de insectos: procesionaria del pino (Thaumetopoea pityocampa) — RIESGO SANITARIO PÚBLICO, picudo rojo de las palmeras (Rhynchophorus ferrugineus) — DECLARACIÓN OBLIGATORIA, lagarta peluda (Lymantria dispar) — RIESGO SANITARIO, escolítidos del olmo, mineradores foliares, cochinilla algodonosa, psyla de la acacia.
- Enfermedades fúngicas: anthracnosis del plátano, oídio del plátano, mancha negra del peral, grafiosis del olmo (Ophiostoma), chancro del ciprés, hongos de pudrición de madera.
- Enfermedades bacterianas: fuego bacteriano (Erwinia amylovora) — DECLARACIÓN OBLIGATORIA.
- Trastornos abióticos: salinidad, heridas de máquina de siega, golpe de calor urbano, fitotoxicidad por herbicida, contaminación atmosférica.

REGLAS ESTRICTAS:

1. Responde SOLO con JSON, sin texto antes ni después. Sin bloques de código markdown.

2. Estructura del JSON:
{
  "tipo_analisis": "plaga",
  "plaga_nombre_comun": "nombre habitual en español",
  "plaga_nombre_cientifico": "binomial latino o vacío para abióticos",
  "tipo_plaga": "plaga_insecto" | "enfermedad_fungica" | "enfermedad_bacteriana" | "plaga_invasora" | "trastorno_abiotico" | "indeterminado",
  "severidad": número entero 1-5 estimado (5 = mortalidad / colapso, 1 = síntomas incipientes), o null,
  "confianza": número decimal 0.0-1.0,
  "manejo_cultural": "recomendaciones de manejo NO QUÍMICO en 2-3 frases (poda sanitaria, retirada de hoja caída, trampeo de feromonas, mejora de riego, etc.). NO menciones marcas comerciales de fitosanitarios.",
  "declaracion_oficial_sugerida": true | false (true SOLO para picudo rojo, fuego bacteriano u otras patologías reguladas),
  "riesgo_sanitario_publico_sugerido": true | false (true para procesionaria del pino, lagarta peluda — pelos urticantes en personas),
  "advertencia": "vacío si confianza alta; si la foto es ambigua o sólo es daño abiótico ambiguo, lo dices aquí"
}

3. NUNCA recomiendes productos fitosanitarios concretos por nombre comercial. Esto es un compromiso legal de la app: solo manejo cultural.

4. Si la foto NO es de arbolado urbano o no se ve patología, devuelve tipo_plaga="indeterminado", confianza=0.0, advertencia explicativa.

5. Sé conservador con la severidad: 5 sólo para mortalidad o colapso inminente, 1 para síntomas muy localizados.

6. Si dudas entre plagas similares (p. ej. anthracnosis vs oídio del plátano), da la más probable, baja la confianza y explícalo en advertencia.
''';

String _construirPrompt(ModoAnalisisIA modo, String observaciones) {
  final ctx = StringBuffer()
    ..writeln('Cultivo: Arbolado urbano peninsular');
  if (observaciones.trim().isNotEmpty) {
    ctx.writeln('\nObservaciones del usuario: ${observaciones.trim()}');
  }
  ctx.writeln(modo == ModoAnalisisIA.identificarEspecie
      ? '\nIdentifica la especie del árbol visible en la foto.'
      : '\nDiagnostica el problema sanitario visible en la foto.');
  return ctx.toString();
}

/// Lee el JSON que devuelve Claude a un [ResultadoAnalisisIA]. Tolera
/// campos ausentes o de tipo inesperado.
ResultadoAnalisisIA resultadoDesdeJson(
    Map<String, dynamic> json, ModoAnalisisIA modo) {
  String texto(String clave) {
    final valor = json[clave];
    return valor is String ? valor : '';
  }

  bool booleano(String clave) => json[clave] == true;
  final confianza =
      ((json['confianza'] as num?)?.toDouble() ?? 0).clamp(0, 1).toDouble();
  final severidad = json['severidad'];
  if (modo == ModoAnalisisIA.identificarEspecie) {
    return ResultadoAnalisisIA(
      tipoAnalisis: 'especie',
      especieNombreComun: texto('especie_nombre_comun'),
      especieNombreCientifico: texto('especie_nombre_cientifico'),
      confianza: confianza,
      advertencia: texto('advertencia'),
    );
  }
  final tipoPlaga = texto('tipo_plaga');
  return ResultadoAnalisisIA(
    tipoAnalisis: 'plaga',
    plagaNombreComun: texto('plaga_nombre_comun'),
    plagaNombreCientifico: texto('plaga_nombre_cientifico'),
    tipoPlaga: tipoPlaga.isEmpty ? 'indeterminado' : tipoPlaga,
    severidad: severidad is num ? severidad.toInt() : null,
    confianza: confianza,
    manejoCultural: texto('manejo_cultural'),
    declaracionOficialSugerida: booleano('declaracion_oficial_sugerida'),
    riesgoSanitarioPublicoSugerido: booleano('riesgo_sanitario_publico_sugerido'),
    advertencia: texto('advertencia'),
  );
}
