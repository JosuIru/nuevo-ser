import 'dart:io';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show
        ClienteClaude,
        EsfuerzoClaude,
        ErrorClaude,
        EstadoClaveAnthropic,
        ImagenClaude,
        MensajeClaude,
        MotivoErrorClaude,
        modeloClaudeRapido;

import '../datos/catalogo_cultivos.dart';
import '../datos/catalogo_plagas.dart';

/// Resultado del análisis de una foto por Claude vision. Salida
/// estructurada para que la app pueda contrastarla con el catálogo
/// curado y pre-rellenar el formulario de incidencia.
///
/// `coincidenciaCatalogo` se rellena por la app post-llamada cruzando
/// el `nombreCientifico` o `nombreComun` con `catalogo_plagas`. Si
/// hay match, la incidencia se etiqueta como "validada por catálogo
/// Larrea"; si no, advertencia visible al usuario.
class ResultadoAnalisisIA {
  final String nombreComun;
  final String nombreCientifico;
  final String tipo;
  final int? severidad;
  final double confianza;
  final String manejoCultural;
  final String advertencia;
  final String? coincidenciaCatalogo;

  ResultadoAnalisisIA({
    required this.nombreComun,
    required this.nombreCientifico,
    required this.tipo,
    this.severidad,
    required this.confianza,
    required this.manejoCultural,
    this.advertencia = '',
    this.coincidenciaCatalogo,
  });
}

/// Clave de Anthropic de Larrea: la misma preferencia de siempre
/// (`agro.anthropic.clave`), ahora con el estado común del core.
final EstadoClaveAnthropic estadoClaveAnthropicAgro = EstadoClaveAnthropic.paraApp('agro');

/// Prueba una clave con una petición mínima. Devuelve null si funciona
/// o el mensaje de [ErrorClaude] si no.
Future<String?> probarClaveAnthropic(String clave) async {
  try {
    await ClienteClaude(claveApi: clave).pedirTexto(
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

/// Tamaño máximo de foto que acepta la API de Anthropic.
const int tamanoMaximoFotoBytes = 5 * 1024 * 1024;

/// Diagnóstico por foto con Claude (Haiku). El transporte (petición,
/// imagen, errores) es el `ClienteClaude` común; aquí quedan el prompt
/// agronómico y el cruce con el catálogo de plagas de Larrea.
class AnalizadorFotoCultivo {
  AnalizadorFotoCultivo({required String claveApi, ClienteClaude? cliente})
      : _cliente = cliente ?? ClienteClaude(claveApi: claveApi);

  final ClienteClaude _cliente;

  /// Analiza una foto de la planta y devuelve un diagnóstico
  /// estructurado. Lanza [ErrorClaude] con un mensaje para la persona.
  Future<ResultadoAnalisisIA> analizarFoto({
    required File foto,
    required Cultivo cultivoContexto,
    String observacionesUsuario = '',
  }) async {
    if (!esExtensionDeImagen(foto.path)) {
      throw ErrorClaude(
        MotivoErrorClaude.peticionNoValida,
        'El fichero adjunto no parece una imagen (extensión no reconocida). '
        'Acepto JPG, PNG, GIF o WEBP.',
      );
    }
    if (await foto.length() > tamanoMaximoFotoBytes) {
      throw ErrorClaude(
        MotivoErrorClaude.peticionNoValida,
        'La foto pesa más de 5 MB y la API la rechazará. '
        'Reduce el tamaño antes de enviarla.',
      );
    }
    final imagen = await ImagenClaude.desdeFichero(foto.path);
    final json = await _cliente.pedirJson(
      modelo: modeloClaudeRapido,
      sistema: _promptSistema,
      mensajes: [
        MensajeClaude.usuario(
          _construirPrompt(cultivoContexto, observacionesUsuario),
          imagenes: [imagen],
        ),
      ],
      maxTokens: 4096,
      esfuerzo: EsfuerzoClaude.bajo,
    );
    return resultadoDesdeJson(json);
  }
}

/// Convierte el JSON de Claude en [ResultadoAnalisisIA] y lo cruza con
/// el catálogo de plagas.
ResultadoAnalisisIA resultadoDesdeJson(Map<String, dynamic> json) {
  final nombreComun = (json['nombre_comun'] as String?) ?? 'Sin diagnóstico';
  final nombreCientifico = (json['nombre_cientifico'] as String?) ?? '';
  return ResultadoAnalisisIA(
    nombreComun: nombreComun,
    nombreCientifico: nombreCientifico,
    tipo: (json['tipo'] as String?) ?? 'indeterminado',
    severidad: (json['severidad'] as num?)?.toInt(),
    confianza: ((json['confianza'] as num?)?.toDouble() ?? 0).clamp(0, 1).toDouble(),
    manejoCultural: (json['manejo_cultural'] as String?) ?? '',
    advertencia: (json['advertencia'] as String?) ?? '',
    coincidenciaCatalogo: _buscarCoincidenciaCatalogo(nombreCientifico, nombreComun),
  );
}

const String _promptSistema = '''
Eres un agrónomo experto especializado en cultivos peninsulares (España, Portugal, sur de Francia). Te paso una foto de un cultivo con un posible problema sanitario y debes diagnosticarlo.

REGLAS ESTRICTAS:

1. Responde SOLO con JSON, sin texto antes ni después. Sin bloques de código markdown.

2. Estructura del JSON:
{
  "nombre_comun": "nombre habitual en español de la plaga/enfermedad/trastorno",
  "nombre_cientifico": "nombre científico binomial si aplica, vacío si es un trastorno fisiológico/abiótico",
  "tipo": "plaga" | "enfermedad" | "fisiologico" | "abiotico" | "indeterminado",
  "severidad": número entero 1-5 estimado, o null si no es valorable,
  "confianza": número decimal 0.0-1.0 (cuánta confianza tienes en el diagnóstico),
  "manejo_cultural": "recomendaciones de manejo NO QUÍMICO en 2-3 frases (poda, riego, trampeo, recogida, etc.). NO menciones nombres comerciales de productos fitosanitarios.",
  "advertencia": "si la foto es de baja calidad, hay dudas, o el síntoma es ambiguo, lo dices aquí. Vacío si confianza alta."
}

3. NUNCA recomiendes productos fitosanitarios concretos por nombre comercial. Esto es un compromiso legal de la app: solo manejo cultural en v1.

4. Si la foto NO es de un cultivo o no ves un problema, devuelve tipo="indeterminado", confianza=0.0, advertencia explicativa.

5. Sé conservador con la severidad: 5 solo para daños masivos / muerte de la planta, 1 para síntomas incipientes muy localizados.

6. Si dudas entre dos especies, da la más probable y baja la confianza.
''';

String _construirPrompt(Cultivo cultivo, String observaciones) {
  final ctx = StringBuffer()
    ..writeln('Cultivo: ${cultivo.nombreVisible} (${cultivo.nombreCientifico})')
    ..writeln('Categoría: ${cultivo.categoria.nombreVisible}');
  if (observaciones.trim().isNotEmpty) {
    ctx.writeln('\nObservaciones del usuario: ${observaciones.trim()}');
  }
  ctx.writeln('\nDiagnostica el problema visible en la foto.');
  return ctx.toString();
}

/// Busca una plaga en el catálogo curado de Larrea por matching de
/// nombre científico (preferente) o nombre común. Si encuentra,
/// devuelve el id; si no, null. Esto permite a la UI marcar el
/// diagnóstico como "validado por catálogo Larrea" cuando coincide
/// con una plaga conocida y avisar cuando es un diagnóstico libre.
String? _buscarCoincidenciaCatalogo(String nombreCientifico, String nombreComun) {
  final cientificoNorm = _normalizar(nombreCientifico);
  final comunNorm = _normalizar(nombreComun);
  if (cientificoNorm.isEmpty && comunNorm.isEmpty) return null;
  for (final plaga in catalogoPlagas) {
    if (cientificoNorm.isNotEmpty &&
        plaga.nombreCientifico.isNotEmpty &&
        _normalizar(plaga.nombreCientifico).contains(cientificoNorm)) {
      return plaga.id;
    }
    if (comunNorm.isNotEmpty && _normalizar(plaga.nombreComun).contains(comunNorm)) {
      return plaga.id;
    }
  }
  return null;
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

/// True si la extensión es de una imagen que acepta la API de
/// Anthropic (un PDF enviado como imagen daría un 400 confuso).
bool esExtensionDeImagen(String ruta) {
  final rutaMinusculas = ruta.toLowerCase();
  return const ['.jpg', '.jpeg', '.png', '.gif', '.webp'].any(rutaMinusculas.endsWith);
}
