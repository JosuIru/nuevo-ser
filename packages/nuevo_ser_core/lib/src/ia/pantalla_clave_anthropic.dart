import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../i18n/solera_l10n.dart';
import 'estado_clave_anthropic.dart';

/// Comprueba una clave contra la API. Devuelve **null si la clave
/// funciona** o un mensaje de error legible si no.
typedef ProbadorClaveAnthropic = Future<String?> Function(String clave);

/// Pantalla de Ajustes para poner, probar y borrar la clave de Anthropic
/// que la persona trae de su cuenta (identificación por foto).
///
/// La clave se guarda solo en el dispositivo ([EstadoClaveAnthropic]) y
/// las fotos van directas del dispositivo a `api.anthropic.com`.
class PantallaClaveAnthropic extends StatefulWidget {
  const PantallaClaveAnthropic({
    super.key,
    required this.estado,
    this.nombreApp = 'La app',
    this.titulo = 'Identificación con IA',
    this.queIdentifica = 'Identifica plagas y enfermedades por foto',
    this.descripcion,
    this.probarClave,
  });

  /// Dónde se guarda la clave (cada app con su clave de almacenamiento).
  final EstadoClaveAnthropic estado;

  /// Nombre visible de la app, para los textos («Larrea Apícola puede…»).
  final String nombreApp;

  /// Título de la barra superior.
  final String titulo;

  /// Titular de la tarjeta de explicación.
  final String queIdentifica;

  /// Texto de la tarjeta de explicación. Si es null se usa uno genérico
  /// con [nombreApp].
  final String? descripcion;

  /// Si se pasa, aparece el botón «Probar la clave».
  final ProbadorClaveAnthropic? probarClave;

  static const direccionConsolaAnthropic = 'https://console.anthropic.com/';

  @override
  State<PantallaClaveAnthropic> createState() => _PantallaClaveAnthropicState();
}

class _PantallaClaveAnthropicState extends State<PantallaClaveAnthropic> {
  final _controladorClave = TextEditingController();
  bool _ocultarClave = true;
  bool _cargando = true;
  bool _guardando = false;
  bool _probando = false;
  bool _hayClaveGuardada = false;

  /// Resultado de la última prueba: null sin probar; true bien; false mal.
  bool? _pruebaCorrecta;
  String? _mensajePrueba;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _controladorClave.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final claveActual = await widget.estado.cargar();
    if (!mounted) return;
    setState(() {
      _hayClaveGuardada = claveActual != null;
      _controladorClave.text = claveActual ?? '';
      _cargando = false;
    });
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _guardar() async {
    final clave = _controladorClave.text.trim();
    if (clave.isEmpty) {
      await _borrar();
      return;
    }
    if (!widget.estado.pareceValida(clave)) {
      _avisar(SoleraL10n.t('core.ia.clave_corta'));
      return;
    }
    setState(() => _guardando = true);
    await widget.estado.guardar(clave);
    if (!mounted) return;
    setState(() {
      _guardando = false;
      _hayClaveGuardada = true;
    });
    _avisar(SoleraL10n.t('core.ia.clave_guardada_dispositivo'));
  }

  Future<void> _borrar() async {
    await widget.estado.borrar();
    if (!mounted) return;
    setState(() {
      _controladorClave.clear();
      _hayClaveGuardada = false;
      _pruebaCorrecta = null;
      _mensajePrueba = null;
    });
    _avisar(SoleraL10n.t('core.ia.clave_borrada'));
  }

  Future<void> _probar() async {
    final probador = widget.probarClave;
    final clave = _controladorClave.text.trim();
    if (probador == null) return;
    if (!widget.estado.pareceValida(clave)) {
      _avisar(SoleraL10n.t('core.ia.escribe_clave_completa'));
      return;
    }
    setState(() {
      _probando = true;
      _pruebaCorrecta = null;
      _mensajePrueba = null;
    });
    String? error;
    try {
      error = await probador(clave);
    } catch (excepcion) {
      error = SoleraL10n.tf('core.ia.no_se_pudo_probar', {'error': excepcion});
    }
    if (!mounted) return;
    setState(() {
      _probando = false;
      _pruebaCorrecta = error == null;
      _mensajePrueba = error ?? SoleraL10n.t('core.ia.la_clave_funciona');
    });
  }

  Future<void> _abrirConsola() async {
    final direccion = Uri.parse(PantallaClaveAnthropic.direccionConsolaAnthropic);
    try {
      await launchUrl(direccion, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        _avisar(SoleraL10n.t('core.ia.no_se_pudo_abrir_navegador'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.titulo)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final estiloApartado =
        tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    final descripcion = widget.descripcion ??
        SoleraL10n.tf('core.ia.descripcion_generica', {'app': widget.nombreApp});

    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: colores.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: colores.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.queIdentifica,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colores.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(descripcion,
                      style: TextStyle(color: colores.onPrimaryContainer)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(SoleraL10n.t('core.ia.privacidad'), style: estiloApartado),
          const SizedBox(height: 4),
          Text(
            [
              SoleraL10n.tf('core.ia.privacidad_1', {'app': widget.nombreApp}),
              SoleraL10n.t('core.ia.privacidad_2'),
              SoleraL10n.t('core.ia.privacidad_3'),
              SoleraL10n.t('core.ia.privacidad_4'),
            ].map((linea) => '· $linea').join('\n'),
            style: tema.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(SoleraL10n.t('core.ia.como_conseguir_clave'), style: estiloApartado),
          const SizedBox(height: 4),
          Text(
            SoleraL10n.t('core.ia.como_conseguir_clave_texto'),
            style: tema.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.open_in_new),
              onPressed: _abrirConsola,
              label: Text(SoleraL10n.t('core.ia.abrir_consola')),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('campo_clave_anthropic'),
            controller: _controladorClave,
            obscureText: _ocultarClave,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: (_) {
              if (_pruebaCorrecta != null) {
                setState(() {
                  _pruebaCorrecta = null;
                  _mensajePrueba = null;
                });
              }
            },
            decoration: InputDecoration(
              labelText: SoleraL10n.t('core.ia.tu_clave_anthropic'),
              hintText: 'sk-ant-…',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: SoleraL10n.t(_ocultarClave ? 'core.ia.mostrar_clave' : 'core.ia.ocultar_clave'),
                icon: Icon(
                    _ocultarClave ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _ocultarClave = !_ocultarClave),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(SoleraL10n.t('core.ia.guardar_clave')),
              ),
              if (widget.probarClave != null)
                OutlinedButton.icon(
                  onPressed: _probando ? null : _probar,
                  icon: _probando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.network_check),
                  label: Text(SoleraL10n.t('core.ia.probar_clave')),
                ),
              if (_hayClaveGuardada)
                OutlinedButton.icon(
                  onPressed: _borrar,
                  icon: Icon(Icons.delete_outline, color: colores.error),
                  label: Text(SoleraL10n.t('borrar'),
                      style: TextStyle(color: colores.error)),
                ),
            ],
          ),
          if (_mensajePrueba != null) ...[
            const SizedBox(height: 12),
            _AvisoEstado(
              correcto: _pruebaCorrecta ?? false,
              texto: _mensajePrueba!,
            ),
          ],
          if (_hayClaveGuardada) ...[
            const SizedBox(height: 12),
            _AvisoEstado(
              correcto: true,
              texto: SoleraL10n.t('core.ia.clave_activa'),
            ),
          ],
        ],
      ),
    );
  }
}

class _AvisoEstado extends StatelessWidget {
  const _AvisoEstado({required this.correcto, required this.texto});

  final bool correcto;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final colorPrincipal = correcto ? Colors.green.shade800 : colores.error;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorPrincipal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorPrincipal.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(correcto ? Icons.check_circle : Icons.error_outline,
              color: colorPrincipal),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
