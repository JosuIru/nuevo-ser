import 'dart:io';

import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Resultado del análisis de una foto de cepa por Claude.
/// Salida estructurada para que la app pueda pre-rellenar el
/// formulario de incidencia tras revisión humana.
class ResultadoAnalisisIA {
  final String nombreComun;
  final String nombreCientifico;
  final String tipo;
  final int? severidad;
  final double confianza;
  final String manejoCultural;
  final String advertencia;

  ResultadoAnalisisIA({
    required this.nombreComun,
    required this.nombreCientifico,
    required this.tipo,
    this.severidad,
    required this.confianza,
    required this.manejoCultural,
    this.advertencia = '',
  });

  /// Lee el JSON que devuelve Claude (ver [_promptSistema]). Tolera
  /// campos ausentes o de otro tipo.
  factory ResultadoAnalisisIA.desdeJson(Map<String, dynamic> json) {
    String texto(String campo) {
      final valor = json[campo];
      return valor is String ? valor : '';
    }

    final severidad = json['severidad'];
    final confianza = json['confianza'];
    final nombreComun = texto('nombre_comun');
    final tipo = texto('tipo');
    return ResultadoAnalisisIA(
      nombreComun: nombreComun.isNotEmpty ? nombreComun : 'Sin diagnóstico',
      nombreCientifico: texto('nombre_cientifico'),
      tipo: tipo.isNotEmpty ? tipo : 'indeterminado',
      severidad: severidad is num ? severidad.round().clamp(1, 5) : null,
      confianza: confianza is num ? confianza.toDouble().clamp(0, 1).toDouble() : 0,
      manejoCultural: texto('manejo_cultural'),
      advertencia: texto('advertencia'),
    );
  }
}

/// Analiza fotos de vid con Claude (Haiku). El transporte (petición,
/// imagen, errores) es el [ClienteClaude] común del core; aquí solo
/// viven el prompt vid-específico y la lectura del resultado.
///
/// Cuando entre el catálogo curado de F1-5, el modal cruza la respuesta
/// con el catálogo de plagas (`plagaPorBusquedaFuzzy`).
class AnalizadorFotoVid {
  /// Límite de tamaño de imagen que acepta la API.
  static const int tamanoMaximoFotoBytes = 5 * 1024 * 1024;

  final ClienteClaude _clienteClaude;

  AnalizadorFotoVid({required String claveApi, ClienteClaude? clienteClaude})
      : _clienteClaude = clienteClaude ?? ClienteClaude(claveApi: claveApi);

  /// Analiza una foto de la cepa y devuelve un diagnóstico
  /// estructurado. Lanza [ErrorClaude] con un mensaje para la persona.
  Future<ResultadoAnalisisIA> analizarFoto({
    required File foto,
    String observacionesUsuario = '',
  }) async {
    final tamanoFoto = await foto.length();
    if (tamanoFoto > tamanoMaximoFotoBytes) {
      throw ErrorClaude(
        MotivoErrorClaude.peticionNoValida,
        'La foto pesa más de 5 MB y la API la rechazará. '
        'Reduce el tamaño antes de enviarla.',
      );
    }
    final imagen = await ImagenClaude.desdeFichero(foto.path);
    final json = await _clienteClaude.pedirJson(
      modelo: modeloClaudeRapido,
      sistema: _promptSistema,
      mensajes: [
        MensajeClaude.usuario(
          construirPromptAnalisisVid(observacionesUsuario),
          imagenes: [imagen],
        ),
      ],
      maxTokens: 4096,
      esfuerzo: EsfuerzoClaude.bajo,
    );
    return ResultadoAnalisisIA.desdeJson(json);
  }
}

/// System prompt vid-específico. Lista canónica de plagas,
/// enfermedades y trastornos esperables en *Vitis vinifera* en
/// climas peninsulares. Cuando entre el catálogo curado de F1-5
/// con asesor agronómico, esta lista se contrastará automáticamente
/// para distinguir "diagnóstico validado por catálogo Larrea" del
/// "diagnóstico libre de la IA" — patrón análogo al de agro.
const String _promptSistema = '''
Eres un agrónomo experto en viticultura, especializado en *Vitis vinifera* en climas peninsulares (España, Portugal, sur de Francia). Te paso una foto de una cepa, hoja, racimo o sarmiento con un posible problema sanitario y debes diagnosticarlo.

LISTA CANÓNICA DE INCIDENCIAS COMUNES EN VID (no exhaustiva — si ves algo distinto, lo describes igual):
- Enfermedades fúngicas: mildiu (*Plasmopara viticola*), oídio (*Erysiphe necator*), botritis o podredumbre gris (*Botrytis cinerea*), black-rot (*Guignardia bidwellii*), excoriosis (*Phomopsis viticola*), eutipiosis (*Eutypa lata*), yesca, brazo muerto.
- Plagas de insectos: polilla del racimo (*Lobesia botrana*), mosquito verde (*Empoasca vitis*), trips, ácaros eriófidos (acariosis y erinosis), filoxera (síntomas en raíz, raramente foliar en patrón resistente).
- Trastornos abióticos: corrimiento, golpe de calor, granizo, deficiencia hídrica, deficiencia nutricional (potasio, magnesio, hierro), fitotoxicidad por herbicida.

REGLAS ESTRICTAS:

1. Responde SOLO con JSON, sin texto antes ni después. Sin bloques de código markdown.

2. Estructura del JSON:
{
  "nombre_comun": "nombre habitual en español de la plaga/enfermedad/trastorno",
  "nombre_cientifico": "nombre científico binomial si aplica, vacío si es un trastorno fisiológico/abiótico",
  "tipo": "plaga" | "enfermedad" | "fisiologico" | "abiotico" | "indeterminado",
  "severidad": número entero 1-5 estimado, o null si no es valorable,
  "confianza": número decimal 0.0-1.0 (cuánta confianza tienes en el diagnóstico),
  "manejo_cultural": "recomendaciones de manejo NO QUÍMICO en 2-3 frases (poda sanitaria, deshojado, eliminar restos, ajuste de riego, recogida de racimos afectados, etc.). NO menciones nombres comerciales de productos fitosanitarios.",
  "advertencia": "si la foto es de baja calidad, hay dudas, o el síntoma es ambiguo, lo dices aquí. Vacío si confianza alta."
}

3. NUNCA recomiendes productos fitosanitarios concretos por nombre comercial. Esto es un compromiso legal de la app: solo manejo cultural en v0.1.

4. Si la foto NO es de vid o no ves un problema, devuelve tipo="indeterminado", confianza=0.0, advertencia explicativa.

5. Sé conservador con la severidad: 5 solo para daños masivos / muerte de la cepa, 1 para síntomas incipientes muy localizados.

6. Si dudas entre dos especies (p. ej. mildiu vs black-rot en hoja), da la más probable y baja la confianza; explícalo en advertencia.
''';

/// Texto del mensaje que acompaña a la foto.
String construirPromptAnalisisVid(String observaciones) {
  final contexto = StringBuffer()
    ..writeln('Cultivo: Vid (*Vitis vinifera*)');
  if (observaciones.trim().isNotEmpty) {
    contexto.writeln('\nObservaciones del usuario: ${observaciones.trim()}');
  }
  contexto.writeln('\nDiagnostica el problema visible en la foto.');
  return contexto.toString();
}
