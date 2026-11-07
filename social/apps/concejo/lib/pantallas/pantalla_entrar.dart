import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../servidor/cliente_concejo.dart';

/// Primera vez: la dirección del pueblo y el código personal que la mesa
/// ha dado en papel. O ver el pueblo de ejemplo sin servidor.
class PantallaEntrar extends StatefulWidget {
  const PantallaEntrar(
      {super.key, required this.entrar, required this.verEjemplo});

  /// Lanza [CodigoIncorrecto] o [SinConexion] si no se puede.
  final Future<void> Function(String direccion, String codigo) entrar;
  final VoidCallback verEjemplo;

  @override
  State<PantallaEntrar> createState() => _PantallaEntrarState();
}

class _PantallaEntrarState extends State<PantallaEntrar> {
  final _direccion = TextEditingController();
  final _codigo = TextEditingController();
  var _entrando = false;
  String? _error;

  @override
  void dispose() {
    _direccion.dispose();
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _entrar(AppLocalizations textos) async {
    setState(() {
      _entrando = true;
      _error = null;
    });
    try {
      await widget.entrar(_direccion.text, _codigo.text);
    } on CodigoIncorrecto {
      _error = textos.errorCodigo;
    } catch (_) {
      _error = textos.errorConexion;
    }
    if (mounted) setState(() => _entrando = false);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final completo =
        _direccion.text.trim().isNotEmpty && _codigo.text.trim().isNotEmpty;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                Text(textos.nombreApp,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(textos.entrarTitulo,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(textos.entrarTexto),
                const SizedBox(height: 24),
                TextField(
                  controller: _direccion,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: textos.campoDireccion,
                    hintText: 'decidimos.ejemplo.org',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _codigo,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: textos.campoCodigo,
                    hintText: 'K7PM-3QXD-9TRA',
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed:
                      completo && !_entrando ? () => _entrar(textos) : null,
                  child: _entrando
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(textos.entrar),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: widget.verEjemplo,
                  child: Text(textos.verEjemplo),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
