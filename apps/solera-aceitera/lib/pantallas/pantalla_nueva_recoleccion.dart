import 'package:flutter/material.dart';

import '../datos/base_datos.dart';
import '../modelos/campania.dart';
import '../modelos/recoleccion.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Formulario rápido para registrar una recolección sobre una parcela
/// concreta. Requiere una campaña abierta — si no hay, redirige al
/// usuario a Ajustes para crearla.
class PantallaNuevaRecoleccion extends StatefulWidget {
  final int parcelaId;

  const PantallaNuevaRecoleccion({super.key, required this.parcelaId});

  @override
  State<PantallaNuevaRecoleccion> createState() =>
      _PantallaNuevaRecoleccionState();
}

class _PantallaNuevaRecoleccionState extends State<PantallaNuevaRecoleccion> {
  final _formKey = GlobalKey<FormState>();
  final _kgCtrl = TextEditingController();
  final _cuadrillaCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  String _tipoAceituna = 'envero';
  String _metodo = 'vibrador';
  Campania? _campaniaActiva;
  bool _cargando = true;
  bool _guardando = false;

  static const _tiposAceituna = ['verde', 'envero', 'negra'];
  static const _metodos = ['vibrador', 'manual', 'paraguas', 'peine', 'vareo'];

  @override
  void initState() {
    super.initState();
    _resolverCampania();
  }

  Future<void> _resolverCampania() async {
    final cs = await BaseDatosSoleraAceitera().listarCampanias();
    final activa = cs.where((c) => c.estaAbierta).cast<Campania?>().firstWhere(
          (_) => true,
          orElse: () => null,
        );
    if (!mounted) return;
    setState(() {
      _campaniaActiva = activa;
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final c = _campaniaActiva;
    if (c == null) return;
    setState(() => _guardando = true);
    await BaseDatosSoleraAceitera().insertarRecoleccion(Recoleccion(
      parcelaId: widget.parcelaId,
      campaniaId: c.id!,
      fechaMs: DateTime.now().millisecondsSinceEpoch,
      kgEstimados: leerNumero(_kgCtrl.text, nullSiAmbiguo: true) ?? 0,
      tipoAceituna: _tipoAceituna,
      metodo: _metodo,
      cuadrilla: _cuadrillaCtrl.text.trim(),
      notas: _notasCtrl.text.trim(),
    ));
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_campaniaActiva == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nueva recolección')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No hay ninguna campaña abierta. Crea una desde Ajustes '
              'antes de registrar recolecciones.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva recolección')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _kgCtrl,
                decoration: const InputDecoration(
                  labelText: 'Kg estimados',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Obligatorio';
                  final n = leerNumero(v, nullSiAmbiguo: true);
                  if (n == null) return SoleraL10n.t('numero_no_valido');
                  if (n <= 0) return 'Debe ser un número > 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _tipoAceituna,
                decoration: const InputDecoration(
                  labelText: 'Tipo aceituna',
                  border: OutlineInputBorder(),
                ),
                items: _tiposAceituna
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _tipoAceituna = v ?? 'envero'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _metodo,
                decoration: const InputDecoration(
                  labelText: 'Método',
                  border: OutlineInputBorder(),
                ),
                items: _metodos
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _metodo = v ?? 'vibrador'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cuadrillaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Cuadrilla',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notasCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Guardar recolección'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
