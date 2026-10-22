import 'dart:convert';

import 'package:flutter/material.dart';

import '../datos/base_datos.dart';
import '../modelos/campania.dart';
import '../modelos/lote_aceite.dart';
import '../modelos/molturacion.dart';
import '../modelos/movimiento.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Registra una molturación: kg molturados, rendimiento, aceite
/// obtenido. Crea automáticamente el LoteAceite resultante y el
/// Movimiento `entrada_molturacion` que inaugura el libro de
/// movimientos para ese lote.
class PantallaNuevaMolturacion extends StatefulWidget {
  /// ID de la partida inicial que dispara esta molturación (la primera
  /// recibida). Se incluye en `partidasUsadasJson`. El usuario puede
  /// añadir más partidas a la lista en una iteración futura — F1-A3
  /// asume una partida por molturación para mantener el flujo simple.
  final int partidaInicialId;

  const PantallaNuevaMolturacion({super.key, required this.partidaInicialId});

  @override
  State<PantallaNuevaMolturacion> createState() =>
      _PantallaNuevaMolturacionState();
}

class _PantallaNuevaMolturacionState extends State<PantallaNuevaMolturacion> {
  final _formKey = GlobalKey<FormState>();
  final _kgMolturadosCtrl = TextEditingController();
  final _rendimientoCtrl = TextEditingController();
  final _identificadorLoteCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  final _batidoraCtrl = TextEditingController();
  final _decanterCtrl = TextEditingController();
  Campania? _campaniaActiva;
  bool _cargando = true;
  bool _guardando = false;

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
      // Sugerencia: identificador correlativo "<año>-<contador>".
      if (activa != null) {
        _identificadorLoteCtrl.text = '${activa.anyoComercial}-001';
      }
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final c = _campaniaActiva;
    if (c == null) return;
    setState(() => _guardando = true);

    final ahora = DateTime.now().millisecondsSinceEpoch;
    final kgMolt = leerNumero(_kgMolturadosCtrl.text, nullSiAmbiguo: true) ?? 0;
    final rend = leerNumero(_rendimientoCtrl.text) ?? 0;
    final aceiteKg = kgMolt * rend / 100.0;

    final bd = BaseDatosSoleraAceitera();
    // 1) Crear el lote de aceite resultante.
    final loteId = await bd.insertarLoteAceite(LoteAceite(
      campaniaId: c.id!,
      identificadorLote: _identificadorLoteCtrl.text.trim(),
      fechaCreacionMs: ahora,
      kgNetos: aceiteKg,
      ubicacionFisica: _ubicacionCtrl.text.trim(),
    ));
    // 2) Crear la molturación con la partida inicial.
    await bd.insertarMolturacion(Molturacion(
      campaniaId: c.id!,
      fechaMs: ahora,
      kgMolturados: kgMolt,
      rendimientoPorcentaje: rend,
      aceiteObtenidoKg: aceiteKg,
      loteAceiteId: loteId,
      batidoraReferencia: _batidoraCtrl.text.trim(),
      decanterReferencia: _decanterCtrl.text.trim(),
      partidasUsadasJson: jsonEncode([widget.partidaInicialId]),
    ));
    // 3) Crear el movimiento `entrada_molturacion` que inaugura el
    //    libro del lote.
    await bd.insertarMovimiento(Movimiento(
      loteAceiteId: loteId,
      fechaMs: ahora,
      tipo: 'entrada_molturacion',
      kgMovidos: aceiteKg,
      ubicacionDestino: _ubicacionCtrl.text.trim(),
      notas: 'Nacimiento del lote tras molturación.',
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
        appBar: AppBar(title: const Text('Nueva molturación')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No hay ninguna campaña abierta. Crea una desde Ajustes.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva molturación')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _identificadorLoteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Identificador del lote',
                  hintText: '2026-001',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kgMolturadosCtrl,
                decoration: const InputDecoration(
                  labelText: 'Kg molturados',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Obligatorio';
                  final n = leerNumero(v, nullSiAmbiguo: true);
                  if (n == null) return SoleraL10n.t('numero_no_valido');
                  if (n <= 0) return 'Debe ser un número > 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rendimientoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Rendimiento (%)',
                  hintText: 'Típico 18-22',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Obligatorio';
                  final n = leerNumero(v);
                  if (n == null) return SoleraL10n.t('numero_no_valido');
                  if (n < 0 || n > 100) return '0-100';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ubicacionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ubicación del depósito',
                  hintText: 'depósito D-3',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _batidoraCtrl,
                decoration: const InputDecoration(
                  labelText: 'Batidora (referencia)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _decanterCtrl,
                decoration: const InputDecoration(
                  labelText: 'Decanter (referencia)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Guardar molturación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
