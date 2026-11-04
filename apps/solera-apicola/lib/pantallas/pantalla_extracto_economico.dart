import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../servicios/generador_extracto_economico.dart';

/// Genera el extracto económico anual (libro registro de
/// ingresos/gastos + modelo 347 + apuntes sin NIF + detalle
/// cronológico) en PDF para el asesor fiscal o para el archivo del
/// titular.
///
/// **Provisional** — el formato del PDF está pendiente de firma de
/// asesor fiscal antes de quitar el banner.
class PantallaExtractoEconomico extends StatefulWidget {
  final int anoInicial;
  const PantallaExtractoEconomico({super.key, required this.anoInicial});

  @override
  State<PantallaExtractoEconomico> createState() =>
      _PantallaExtractoEconomicoState();
}

class _PantallaExtractoEconomicoState extends State<PantallaExtractoEconomico> {
  late int _ano;
  bool _generando = false;

  @override
  void initState() {
    super.initState();
    _ano = widget.anoInicial;
  }

  Future<File?> _generar() async {
    setState(() => _generando = true);
    try {
      final fichero = await generarExtractoEconomico(ano: _ano);
      return fichero;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(SoleraL10n.tf('api.eco_error_generar_pdf', {'error': e}))),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  Future<void> _generarYCompartir() async {
    final fichero = await _generar();
    if (fichero == null || !mounted) return;
    await Share.shareXFiles(
      [XFile(fichero.path)],
      text: SoleraL10n.tf('api.eco_extracto_compartir_ano', {'ano': _ano}),
    );
  }

  Future<void> _generarYAbrir() async {
    final fichero = await _generar();
    if (fichero == null || !mounted) return;
    await Printing.layoutPdf(
        onLayout: (_) => File(fichero.path).readAsBytes());
  }

  @override
  Widget build(BuildContext context) {
    final anoActual = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('api.eco_extracto_economico_anual'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade700),
            ),
            child: Text(
              SoleraL10n.t('api.eco_aviso_extracto_provisional'),
              style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
            ),
          ),
          DropdownButtonFormField<int>(
            initialValue: _ano,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('api.eco_ejercicio_fiscal'),
              border: OutlineInputBorder(),
            ),
            items: [
              for (var a = anoActual; a >= anoActual - 9; a--)
                DropdownMenuItem<int>(value: a, child: Text(a.toString())),
            ],
            onChanged: (v) => setState(() => _ano = v ?? anoActual),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _generando ? null : _generarYCompartir,
            icon: _generando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.share),
            label: Text(SoleraL10n.t('api.eco_generar_y_compartir')),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _generando ? null : _generarYAbrir,
            icon: const Icon(Icons.print),
            label: Text(SoleraL10n.t('api.eco_generar_y_abrir')),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              [
                SoleraL10n.t('api.eco_extracto_incluye'),
                '• ${SoleraL10n.t('api.eco_extracto_incluye_resumen')}',
                '• ${SoleraL10n.t('api.eco_extracto_incluye_ingresos')}',
                '• ${SoleraL10n.t('api.eco_extracto_incluye_gastos')}',
                '• ${SoleraL10n.t('api.eco_extracto_incluye_347')}',
                '• ${SoleraL10n.t('api.eco_extracto_incluye_sin_nif')}',
                '• ${SoleraL10n.t('api.eco_extracto_incluye_detalle')}',
                '',
                SoleraL10n.t('api.eco_extracto_reparto_pendiente'),
              ].join('\n'),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
