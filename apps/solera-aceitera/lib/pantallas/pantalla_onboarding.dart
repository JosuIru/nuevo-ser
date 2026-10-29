import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../datos/base_datos.dart';
import '../modelos/olivar.dart';
import '../modelos/titular.dart';

const String _claveOnboardingVisto = 'aceitera.onboarding_visto';

/// Onboarding primer arranque: explica brevemente la app y registra
/// los datos mínimos del titular y del olivar (single-row en v0.1).
/// El flag de "ya visto" se persiste en SharedPreferences.
class PantallaOnboarding extends StatefulWidget {
  final VoidCallback alTerminar;

  const PantallaOnboarding({super.key, required this.alTerminar});

  static Future<bool> yaVisto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_claveOnboardingVisto) ?? false;
  }

  @override
  State<PantallaOnboarding> createState() => _PantallaOnboardingState();
}

class _PantallaOnboardingState extends State<PantallaOnboarding> {
  final _formKey = GlobalKey<FormState>();
  final _razonSocialCtrl = TextEditingController();
  final _nifCtrl = TextEditingController();
  final _nombreOlivarCtrl = TextEditingController();
  final _municipioCtrl = TextEditingController();
  final _provinciaCtrl = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    _razonSocialCtrl.dispose();
    _nifCtrl.dispose();
    _nombreOlivarCtrl.dispose();
    _municipioCtrl.dispose();
    _provinciaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final bd = BaseDatosSoleraAceitera();
    final titularId = await bd.insertarTitular(Titular(
      razonSocial: _razonSocialCtrl.text.trim(),
      nif: _nifCtrl.text.trim(),
    ));
    await bd.insertarOlivar(Olivar(
      nombre: _nombreOlivarCtrl.text.trim(),
      titularId: titularId,
      municipio: _municipioCtrl.text.trim(),
      provincia: _provinciaCtrl.text.trim(),
    ));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claveOnboardingVisto, true);
    if (mounted) widget.alTerminar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido a Larrea Aceitera')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.eco, size: 72, color: Color(0xFF5C6B3A)),
              const SizedBox(height: 16),
              const Text(
                'Cuaderno de explotación olivarera y libro de movimientos del aceite para tu almazara.',
                style: TextStyle(fontSize: 16, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text(
                'Datos del titular',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _razonSocialCtrl,
                decoration: const InputDecoration(
                  labelText: 'Razón social',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nifCtrl,
                decoration: const InputDecoration(
                  labelText: 'NIF / CIF',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Datos del olivar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreOlivarCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del olivar',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _municipioCtrl,
                decoration: const InputDecoration(
                  labelText: 'Municipio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _provinciaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Provincia',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Empezar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
