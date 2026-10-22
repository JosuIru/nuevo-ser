import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../estado/clave_anthropic_quesera.dart';
import '../servicios/cliente_anthropic_quesero.dart';

class PantallaIaQueso extends StatefulWidget {
  const PantallaIaQueso({super.key});
  @override
  State<PantallaIaQueso> createState() => _PantallaIaQuesoState();
}

class _PantallaIaQuesoState extends State<PantallaIaQueso> {
  final _picker = ImagePicker();
  File? _foto;
  bool _analizando = false;
  ResultadoAnalisisIA? _resultado;
  String? _error, _claveApi;
  final _obsC = TextEditingController();

  @override
  void initState() { super.initState(); _cargarClave(); }
  Future<void> _cargarClave() async {
    final clave = await estadoClaveAnthropicQuesera.cargar();
    if (mounted) setState(() => _claveApi = clave);
  }

  /// Abre la pantalla común de la clave (poner, probar, borrar) y relee
  /// la clave al volver.
  Future<void> _configClave() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => pantallaClaveAnthropicQuesera()));
    await _cargarClave();
  }

  Future<void> _tomarFoto() async {
    final f = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024);
    if (f != null) setState(() { _foto = File(f.path); _resultado = null; _error = null; });
  }

  Future<void> _selFoto() async {
    final f = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);
    if (f != null) setState(() { _foto = File(f.path); _resultado = null; _error = null; });
  }

  Future<void> _analizar() async {
    if (_foto == null || _claveApi == null || _claveApi!.isEmpty) return;
    setState(() { _analizando = true; _resultado = null; _error = null; });
    try {
      _resultado = await ClienteAnthropicQuesero(_claveApi!).analizarFoto(foto: _foto!, observaciones: _obsC.text);
    } catch (e) { _error = e.toString(); }
    finally { if (mounted) setState(() => _analizando = false); }
  }

  @override
  void dispose() { _obsC.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tk = _claveApi != null && _claveApi!.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('IA — Defectos en queso'), actions: [IconButton(icon: const Icon(Icons.key), tooltip: 'Configurar clave API', onPressed: _configClave)]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(color: tk ? Colors.green.withAlpha(15) : Colors.orange.withAlpha(15), child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Icon(tk ? Icons.check_circle : Icons.warning, color: tk ? Colors.green : Colors.orange),
          const SizedBox(width: 8), Expanded(child: Text(tk ? 'Clave de Anthropic configurada' : 'Configura tu clave de Anthropic', style: TextStyle(color: tk ? Colors.green : Colors.orange))),
          TextButton(onPressed: _configClave, child: Text(tk ? 'Cambiar' : 'Configurar')),
        ]))),
        const SizedBox(height: 16),
        if (_foto != null) ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_foto!, height: 200, width: double.infinity, fit: BoxFit.cover)),
        Row(children: [Expanded(child: OutlinedButton.icon(onPressed: _tomarFoto, icon: const Icon(Icons.camera_alt), label: const Text('Cámara'))), const SizedBox(width: 12), Expanded(child: OutlinedButton.icon(onPressed: _selFoto, icon: const Icon(Icons.photo_library), label: const Text('Galería')))]),
        const SizedBox(height: 12),
        TextFormField(controller: _obsC, decoration: const InputDecoration(labelText: 'Observaciones (opcional)', hintText: 'Tipo de queso, días de curación…', border: OutlineInputBorder()), maxLines: 2),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: (_foto == null || !tk || _analizando) ? null : _analizar, icon: _analizando ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.visibility), label: Text(_analizando ? 'Analizando…' : 'Analizar')),
        if (_error != null) Card(color: Colors.red.withAlpha(15), child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [const Icon(Icons.error, color: Colors.red), const SizedBox(width: 8), Expanded(child: Text(_error!))]))),
        if (_resultado != null) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.search, color: t.colorScheme.primary), const SizedBox(width: 8), Text('Diagnóstico', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), const Spacer(), Chip(label: Text('${(_resultado!.confianza * 100).toStringAsFixed(0)}%'), avatar: const Icon(Icons.science, size: 14))]),
          const Divider(),
          _campo('Defecto', _resultado!.nombreDefecto),
          _campo('Tipo', _resultado!.tipo),
          if (_resultado!.severidad != null) Row(children: [const Text('Severidad: ', style: TextStyle(fontWeight: FontWeight.w500)), ...List.generate(5, (i) => Icon(i < _resultado!.severidad! ? Icons.circle : Icons.circle_outlined, size: 14, color: i < _resultado!.severidad! ? (_resultado!.severidad! >= 4 ? Colors.red : Colors.orange) : Colors.grey)), Text(' (${_resultado!.severidad}/5)', style: const TextStyle(fontSize: 12))]),
          if (_resultado!.descripcion.isNotEmpty) _campo('Descripción', _resultado!.descripcion),
          if (_resultado!.posibleCausa.isNotEmpty) _campo('Causa posible', _resultado!.posibleCausa),
          if (_resultado!.accionRecomendada.isNotEmpty) _campo('Acción recomendada', _resultado!.accionRecomendada),
          if (_resultado!.advertencia.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.warning, color: Colors.orange, size: 16), const SizedBox(width: 4), Expanded(child: Text(_resultado!.advertencia, style: const TextStyle(color: Colors.orange, fontSize: 12)))])),
        ]))),
      ]),
    );
  }

  Widget _campo(String e, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey)), Text(v, style: const TextStyle(fontSize: 13))]));
}
