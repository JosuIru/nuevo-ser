import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

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
      SnackBar(content: Text(SoleraL10n.t('acei.configuracion_fiscal_guardada'))),
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
      appBar: AppBar(title: Text(SoleraL10n.t('configuracion_fiscal'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BannerProvisional(),
          const SizedBox(height: 16),
          Text(SoleraL10n.t('acei.regimen_irpf'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          RadioListTile<String>(
            value: 'estimacion_directa_simplificada',
            groupValue: _configuracion.regimenIrpf,
            title: Text(SoleraL10n.t('acei.estimacion_directa_simplificada')),
            subtitle: Text(
                SoleraL10n.t('acei.estimacion_simplificada_ayuda')),
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
            title: Text(SoleraL10n.t('acei.estimacion_directa_normal')),
            subtitle: Text(
                SoleraL10n.t('acei.estimacion_normal_ayuda')),
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
          Text(SoleraL10n.t('acei.regimen_iva'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          RadioListTile<String>(
            value: 'reagp',
            groupValue: _configuracion.regimenIva,
            title: Text(SoleraL10n.t('acei.regimen_reagp')),
            subtitle: Text(
                SoleraL10n.t('acei.regimen_reagp_ayuda')),
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
            title: Text(SoleraL10n.t('acei.regimen_general')),
            subtitle: Text(
                SoleraL10n.t('acei.regimen_general_ayuda')),
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
            decoration: InputDecoration(
              labelText: SoleraL10n.t('acei.anyo_fiscal_activo'),
              border: OutlineInputBorder(),
              helperText:
                  SoleraL10n.t('acei.anyo_fiscal_activo_ayuda'),
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
            label: Text(SoleraL10n.t('acei.guardar_configuracion')),
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
              SoleraL10n.t('acei.aviso_fiscal_provisional'),
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
