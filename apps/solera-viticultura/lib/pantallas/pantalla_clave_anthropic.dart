import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../estado/clave_anthropic.dart';

/// Configuración de la clave Anthropic. La clave se guarda solo en
/// SharedPreferences local del dispositivo. Las llamadas a Claude
/// vision van directas desde el móvil del usuario — Solera
/// Viticultura no tiene servidor intermedio en v0.1.
///
/// Tradeoff explícito: el usuario paga su propio uso de Anthropic
/// (~0,001-0,01 € por análisis con haiku). A cambio no hay
/// suscripción que cobrar todavía. Cuando entre la fase de backend
/// nube, podemos ofrecer modo "Solera paga" con suscripción.
class PantallaClaveAnthropic extends StatefulWidget {
  const PantallaClaveAnthropic({super.key});

  @override
  State<PantallaClaveAnthropic> createState() => _PantallaClaveAnthropicState();
}

class _PantallaClaveAnthropicState extends State<PantallaClaveAnthropic> {
  final _persistencia = ClaveAnthropic();
  final _controlador = TextEditingController();
  bool _ofuscar = true;
  bool _cargando = true;
  bool _hayClave = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final actual = await _persistencia.cargar();
    if (!mounted) return;
    setState(() {
      _hayClave = actual != null;
      _controlador.text = actual ?? '';
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    final clave = _controlador.text.trim();
    if (clave.isEmpty) {
      await _persistencia.borrar();
      if (!mounted) return;
      setState(() => _hayClave = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clave borrada — la identificación con IA queda desactivada.')),
      );
      return;
    }
    if (clave.length < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La clave parece demasiado corta — comprueba que la copiaste entera.')),
      );
      return;
    }
    await _persistencia.guardar(clave);
    if (!mounted) return;
    setState(() => _hayClave = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clave guardada localmente.')),
    );
  }

  Future<void> _abrirConsola() async {
    final uri = Uri.parse('https://console.anthropic.com/');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Identificación con IA')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Identifica mildiu, oídio, botritis y otras incidencias por foto',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Solera Viticultura puede usar Claude AI de Anthropic para analizar la foto que adjuntas a una incidencia y proponer un diagnóstico, severidad y recomendaciones de manejo cultural.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Privacidad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text(
            '· Tu clave Anthropic se guarda solo en este dispositivo. Nunca la compartimos ni la subimos a ningún servidor de Solera.\n'
            '· Las fotos se envían directamente de tu móvil a Anthropic, sin pasar por servidores intermedios.\n'
            '· Tú pagas el uso de la API a Anthropic con tu clave (~0,001 € por análisis con Claude Haiku).\n'
            '· La identificación es opcional: la app funciona sin clave, simplemente no muestra el botón de IA.',
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          const Text('Cómo obtener una clave', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            icon: const Icon(Icons.open_in_new),
            onPressed: _abrirConsola,
            label: const Text('Abrir console.anthropic.com'),
          ),
          const SizedBox(height: 4),
          const Text(
            'Crea cuenta, añade un método de pago y genera una API Key. Cópiala y pégala abajo.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controlador,
            obscureText: _ofuscar,
            decoration: InputDecoration(
              labelText: 'Tu clave Anthropic',
              hintText: 'sk-ant-...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_ofuscar ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _ofuscar = !_ofuscar),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.save),
                  onPressed: _guardar,
                  label: const Text('Guardar clave'),
                ),
              ),
              if (_hayClave) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    _controlador.clear();
                    await _guardar();
                  },
                  label: const Text('Borrar', style: TextStyle(color: Colors.red)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          if (_hayClave)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                    'Clave configurada. La identificación con IA está activa.',
                    style: TextStyle(color: Colors.green.shade900),
                  )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
