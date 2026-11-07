import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SelectorIdioma, SoleraL10n;

import '../datos/base_datos.dart';
import '../modelos/monte.dart';

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  final _controladorNombre = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final monte = await BaseDatosSoleraMonte.instancia.obtenerMonte();
      if (mounted) _controladorNombre.text = monte.titular;
    } catch (error) {
      debugPrint('No se pudo leer el titular: $error');
    }
  }

  Future<void> _guardar() async {
    await BaseDatosSoleraMonte.instancia
        .guardarMonte(Monte(titular: _controladorNombre.text.trim()));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(SoleraL10n.t('mont.guardado'))));
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SelectorIdioma(),
          const SizedBox(height: 24),
          Text(SoleraL10n.t('mont.titular'),
              style: Theme.of(context).textTheme.titleMedium),
          TextField(
            controller: _controladorNombre,
            decoration:
                InputDecoration(labelText: SoleraL10n.t('mont.nombre_titular')),
          ),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: _guardar, child: Text(SoleraL10n.t('guardar'))),
        ],
      ),
    );
  }
}
