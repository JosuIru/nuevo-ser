import 'package:flutter/material.dart';

import '../datos/base_datos.dart';
import '../modelos/configuracion_fiscal.dart';

/// Configuración fiscal del titular — régimen IRPF + IVA + año fiscal
/// por defecto. Determina cómo se calculan los IVA repercutidos y la
/// compensación REAGP en los apuntes de ingreso/gasto.
///
/// **PROVISIONAL hasta asesor fiscal agroalimentario humano** —
/// banner persistente recuerda al operador que las reglas IVA por
/// defecto son orientativas (registrado en BLOQUEOS-PENDIENTES.md
/// F1-A9).
class PantallaConfiguracionFiscal extends StatefulWidget {
  const PantallaConfiguracionFiscal({super.key});

  @override
  State<PantallaConfiguracionFiscal> createState() =>
      _PantallaConfiguracionFiscalState();
}

class _PantallaConfiguracionFiscalState
    extends State<PantallaConfiguracionFiscal> {
  ConfiguracionFiscal _configuracion = ConfiguracionFiscal();
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final cargada = await BaseDatosSoleraAceitera().obtenerConfiguracionFiscal();
    if (!mounted) return;
    setState(() {
      _configuracion = cargada;
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    await BaseDatosSoleraAceitera().guardarConfiguracionFiscal(_configuracion);
    if (!mounted) return;
    setState(() => _guardando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración fiscal guardada.')),
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final anyoActual = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración fiscal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BannerProvisional(),
          const SizedBox(height: 16),
          const Text('Régimen IRPF',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          RadioListTile<String>(
            value: 'estimacion_directa_simplificada',
            groupValue: _configuracion.regimenIrpf,
            title: const Text('Estimación directa simplificada'),
            subtitle: const Text(
                'La más común si llevas contabilidad mínima al día.'),
            onChanged: (v) => setState(() {
              _configuracion = ConfiguracionFiscal(
                id: _configuracion.id,
                regimenIrpf: v!,
                regimenIva: _configuracion.regimenIva,
                anyoFiscalActivo: _configuracion.anyoFiscalActivo,
              );
            }),
          ),
          RadioListTile<String>(
            value: 'estimacion_directa_normal',
            groupValue: _configuracion.regimenIrpf,
            title: const Text('Estimación directa normal'),
            subtitle: const Text(
                'Cuando la simplificada no aplica por límites de facturación.'),
            onChanged: (v) => setState(() {
              _configuracion = ConfiguracionFiscal(
                id: _configuracion.id,
                regimenIrpf: v!,
                regimenIva: _configuracion.regimenIva,
                anyoFiscalActivo: _configuracion.anyoFiscalActivo,
              );
            }),
          ),
          const Divider(),
          const Text('Régimen IVA',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          RadioListTile<String>(
            value: 'reagp',
            groupValue: _configuracion.regimenIva,
            title: const Text('REAGP (compensación 12 % en aceituna)'),
            subtitle: const Text(
                'Régimen especial de agricultura. El comprador paga una compensación '
                'REAGP del 12 % en la venta de aceituna; el titular no repercute '
                'IVA en sus ventas agrícolas.'),
            onChanged: (v) => setState(() {
              _configuracion = ConfiguracionFiscal(
                id: _configuracion.id,
                regimenIrpf: _configuracion.regimenIrpf,
                regimenIva: v!,
                anyoFiscalActivo: _configuracion.anyoFiscalActivo,
              );
            }),
          ),
          RadioListTile<String>(
            value: 'general',
            groupValue: _configuracion.regimenIva,
            title: const Text('Régimen general'),
            subtitle: const Text(
                'IVA repercutido 4 % en aceituna y aceite (alimento básico). '
                'El IVA soportado en gastos es deducible.'),
            onChanged: (v) => setState(() {
              _configuracion = ConfiguracionFiscal(
                id: _configuracion.id,
                regimenIrpf: _configuracion.regimenIrpf,
                regimenIva: v!,
                anyoFiscalActivo: _configuracion.anyoFiscalActivo,
              );
            }),
          ),
          const Divider(),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: _configuracion.anyoFiscalActivo == 0
                ? anyoActual
                : _configuracion.anyoFiscalActivo,
            decoration: const InputDecoration(
              labelText: 'Año fiscal activo',
              border: OutlineInputBorder(),
              helperText:
                  'Año por defecto que se abre en el libro económico.',
            ),
            items: [
              for (var a = anyoActual + 1; a >= anyoActual - 5; a--)
                DropdownMenuItem(value: a, child: Text(a.toString())),
            ],
            onChanged: (v) => setState(() {
              _configuracion = ConfiguracionFiscal(
                id: _configuracion.id,
                regimenIrpf: _configuracion.regimenIrpf,
                regimenIva: _configuracion.regimenIva,
                anyoFiscalActivo: v ?? anyoActual,
              );
            }),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: _guardando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save),
            label: const Text('Guardar configuración'),
          ),
        ],
      ),
    );
  }
}

class _BannerProvisional extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.gavel, color: Colors.amber.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'PROVISIONAL hasta que lo valide un asesor fiscal agroalimentario. '
              'Las reglas de IVA por defecto se basan en la interpretación '
              'habitual del olivar; en cada apunte puedes sobrescribir el '
              'IVA repercutido manualmente.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber.shade900,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
