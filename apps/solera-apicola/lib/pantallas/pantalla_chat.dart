import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../servicios/cliente_anthropic.dart';
import 'pantalla_ajustes.dart';

/// Asistente de apicultura por chat (Claude Haiku 5.5 con la clave de
/// Anthropic de la app, vía `ServicioChat` del core). Admite una foto por
/// mensaje. Se abre desde Hoy.
///
/// Mismos límites que la identificación por foto: sin marcas comerciales
/// de medicamentos zoosanitarios y siempre derivando al veterinario
/// asesor para tratamientos.
class PantallaChat extends StatefulWidget {
  const PantallaChat({super.key, this.sistemaPrompt = sistemaApicola});

  final String sistemaPrompt;

  static const sistemaApicola =
      'Eres un asistente para apicultores profesionales y aficionados de la península ibérica '
      '(*Apis mellifera*): manejo de colmenas, calendario apícola, trashumancia, cosecha, '
      'sanidad (varroa, nosema, loques, vespa velutina…), libro de explotación REGA y buenas prácticas. '
      'Hablas con precisión técnica pero en tono accesible. '
      'NUNCA recomiendas medicamentos zoosanitarios por marca comercial: como mucho hablas de '
      'manejo y recuerdas que todo tratamiento necesita la receta del veterinario asesor. '
      'Si algo apunta a una patología de declaración obligatoria (loque americana, escarabajo de '
      'las colmenas, vespa velutina), lo dices claramente y recuerdas notificarlo a los Servicios '
      'Veterinarios oficiales. Cuando no estés seguro, lo dices. '
      'Respondes en castellano. Sé conciso (máximo 3 párrafos salvo que te pidan detalle).';

  @override
  State<PantallaChat> createState() => _PantallaChatState();
}

class _PantallaChatState extends State<PantallaChat> {
  final _controladorMensaje = TextEditingController();
  final _controladorDesplazamiento = ScrollController();
  final _selectorImagen = ImagePicker();
  final List<MensajeChat> _mensajes = [];

  /// Mensajes de error que se enseñan pero no se mandan como historial.
  final Set<MensajeChat> _mensajesDeError = {};
  bool _enviando = false;
  String? _imagenAdjunta;

  @override
  void dispose() {
    _controladorMensaje.dispose();
    _controladorDesplazamiento.dispose();
    super.dispose();
  }

  Future<void> _hacerFoto() async {
    final foto = await _selectorImagen.pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 1200);
    if (foto != null) setState(() => _imagenAdjunta = foto.path);
  }

  Future<void> _elegirDeGaleria() async {
    final foto = await _selectorImagen.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1200);
    if (foto != null) setState(() => _imagenAdjunta = foto.path);
  }

  void _anadirError(String texto) {
    final mensajeError = MensajeChat(texto: texto, esUsuario: false);
    _mensajesDeError.add(mensajeError);
    _mensajes.add(mensajeError);
  }

  Future<void> _enviar() async {
    final texto = _controladorMensaje.text.trim();
    final imagen = _imagenAdjunta;
    if ((texto.isEmpty && imagen == null) || _enviando) return;

    final clave = await estadoClaveAnthropicApicola.cargar();
    if (!mounted) return;
    if (clave == null || !estadoClaveAnthropicApicola.pareceValida(clave)) {
      setState(() => _anadirError(
          'Falta la clave de Anthropic. Añádela en Ajustes → Identificación con IA.'));
      _bajarAlFinal();
      return;
    }
    _controladorMensaje.clear();

    final historial = _mensajes.where((mensaje) => !_mensajesDeError.contains(mensaje)).toList();
    final textoAEnviar = texto.isNotEmpty ? texto : '¿Qué ves en esta imagen?';
    setState(() {
      _mensajes.add(MensajeChat(texto: textoAEnviar, esUsuario: true, rutaImagen: imagen));
      _imagenAdjunta = null;
      _enviando = true;
    });
    _bajarAlFinal();

    try {
      final servicio = ServicioChat(apiKeyClaude: clave, apiKeyDeepseek: '');
      final respuesta = await servicio.enviarMensaje(
        textoAEnviar,
        proveedor: ProveedorChat.claude,
        historial: historial.isEmpty ? null : historial,
        sistemaPrompt: widget.sistemaPrompt,
        rutaImagen: imagen,
      );
      if (!mounted) return;
      setState(() {
        _mensajes.add(MensajeChat(texto: respuesta, esUsuario: false, proveedor: ProveedorChat.claude));
        _enviando = false;
      });
    } catch (error) {
      if (!mounted) return;
      // ServicioChat devuelve el mensaje de ErrorClaude dentro de un Exception.
      final mensaje = error.toString().replaceFirst('Exception: ', '');
      setState(() {
        _anadirError(mensaje);
        _enviando = false;
      });
    }
    _bajarAlFinal();
  }

  void _bajarAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controladorDesplazamiento.hasClients) {
        _controladorDesplazamiento.animateTo(
          _controladorDesplazamiento.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente (chat)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.key_outlined),
            tooltip: 'Clave de Anthropic',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => pantallaClaveAnthropicApicola()),
            ),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: _mensajes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: esquema.primary.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        const Text(
                          'Pregunta sobre manejo, calendario, sanidad o el libro REGA.\n'
                          'Puedes adjuntar una foto. Usa tu clave de Anthropic.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _controladorDesplazamiento,
                  padding: const EdgeInsets.all(12),
                  itemCount: _mensajes.length + (_enviando ? 1 : 0),
                  itemBuilder: (_, indice) {
                    if (indice >= _mensajes.length) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(),
                      );
                    }
                    final mensaje = _mensajes[indice];
                    final esUsuario = mensaje.esUsuario;
                    final esError = _mensajesDeError.contains(mensaje);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Align(
                        alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: esError
                                ? esquema.errorContainer
                                : esUsuario
                                    ? esquema.primary.withValues(alpha: 0.1)
                                    : esquema.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12).copyWith(
                              bottomRight: esUsuario ? Radius.zero : null,
                              bottomLeft: esUsuario ? null : Radius.zero,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (mensaje.tieneImagen)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(File(mensaje.rutaImagen!),
                                        height: 200, width: double.infinity, fit: BoxFit.cover),
                                  ),
                                ),
                              if (mensaje.texto.isNotEmpty)
                                SelectableText(mensaje.texto, style: const TextStyle(fontSize: 14, height: 1.4)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_imagenAdjunta != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(File(_imagenAdjunta!), height: 48, width: 48, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Foto adjunta: se enviará con el mensaje',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: 'Quitar la foto',
                      onPressed: () => setState(() => _imagenAdjunta = null),
                      visualDensity: VisualDensity.compact,
                    ),
                  ]),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt, size: 22),
                    tooltip: 'Hacer foto',
                    onPressed: _hacerFoto,
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_library, size: 22),
                    tooltip: 'Galería',
                    onPressed: _elegirDeGaleria,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controladorMensaje,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu pregunta…',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviar(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Enviar',
                    onPressed: _enviando ? null : _enviar,
                    icon: _enviando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
