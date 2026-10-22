import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../servicios/generador_extracto_economico.dart';

/// Genera el extracto económico anual (libro registro de
/// ingresos/gastos + modelo 347 + apuntes sin NIF + detalle
/// cronológico) en PDF para el asesor fiscal.
///
/// **Provisional** — pendiente de firma de asesor fiscal antes de
/// quitar el banner.
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
          SnackBar(content: Text('Error generando el PDF: $e')),
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
      text: 'Extracto económico viticultura · $_ano',
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
      appBar: AppBar(title: const Text('Extracto económico anual')),
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
              'PROVISIONAL. Este extracto es una herramienta de apoyo para el '
              'asesor fiscal — el formato exacto del libro registro y del modelo '
              '347 está pendiente de firma de asesor fiscal antes de presentar '
              'nada en una declaración.',
              style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
            ),
          ),
          DropdownButtonFormField<int>(
            initialValue: _ano,
            decoration: const InputDecoration(
              labelText: 'Ejercicio fiscal',
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
            label: const Text('Generar y compartir'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _generando ? null : _generarYAbrir,
            icon: const Icon(Icons.print),
            label: const Text('Generar y abrir'),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              'El extracto incluye:\n'
              '• Bullets resumen con totales del ejercicio.\n'
              '• Tabla mensual de ingresos (uva, vino, ayudas PAC, IVA, '
              'compensación REAGP).\n'
              '• Tabla mensual de gastos (base, IVA soportado, total).\n'
              '• Modelo 347 — terceros con suma >3.005,06 € en el ejercicio.\n'
              '• Apuntes sin NIF que NO entran al modelo 347.\n'
              '• Detalle cronológico de ingresos con variedad y lote.\n'
              '• Detalle cronológico de gastos con imputación.\n\n'
              'Los gastos imputados a "variedad general" se listan tal cual con '
              'el importe íntegro — el reparto proporcional por superficie '
              'entre parcelas con esa variedad está pendiente de validación de '
              'método por asesor fiscal.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
