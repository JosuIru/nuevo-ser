import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:printing/printing.dart';
import '../datos/base_datos.dart';
import '../servicios/generador_libro_trazabilidad.dart';
import '../utiles/textos_quesera.dart';

/// Libro de trazabilidad APPCC en PDF por periodo. Se abre desde
/// Registros, junto a los registros APPCC, la simulación y la DO.
class PantallaTrazabilidad extends StatefulWidget {
  const PantallaTrazabilidad({super.key});
  @override
  State<PantallaTrazabilidad> createState() => _PantallaTrazabilidadState();
}

class _PantallaTrazabilidadState extends State<PantallaTrazabilidad> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  final _gen = GeneradorLibroTrazabilidad();
  DateFormat get _f => DateFormat('d MMM yyyy', localeFechasQuesera());
  DateTime _desde = DateTime.now().subtract(const Duration(days: 90)), _hasta = DateTime.now();
  bool _genPdf = false;

  Future<void> _generarPdf() async {
    setState(() => _genPdf = true);
    try {
      final doc = await _gen.generar(bd: _bd, desdeMs: _desde.millisecondsSinceEpoch, hastaMs: _hasta.millisecondsSinceEpoch);
      await Printing.sharePdf(bytes: await doc.save(), filename: 'libro_trazabilidad.pdf');
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${SoleraL10n.t('error')}: $e'))); }
    finally { if (mounted) setState(() => _genPdf = false); }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('libro_de_trazabilidad_appcc'))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.description, color: t.colorScheme.primary), const SizedBox(width: 8), Text(SoleraL10n.t('libro_de_trazabilidad_appcc'), style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))]),
          Text(SoleraL10n.t('ques.pdf_inspeccionable_7_secciones'), style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: OutlinedButton(onPressed: () async { final p = await showDatePicker(context: context, initialDate: _desde, firstDate: DateTime(2020), lastDate: DateTime.now()); if (p != null) setState(() => _desde = p); }, child: Text(SoleraL10n.tf('ques.desde_fecha', {'fecha': _f.format(_desde)})))), const SizedBox(width: 12), Expanded(child: OutlinedButton(onPressed: () async { final p = await showDatePicker(context: context, initialDate: _hasta, firstDate: DateTime(2020), lastDate: DateTime.now()); if (p != null) setState(() => _hasta = p); }, child: Text(SoleraL10n.tf('ques.hasta_fecha', {'fecha': _f.format(_hasta)}))))]),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: _genPdf ? null : _generarPdf, icon: _genPdf ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.picture_as_pdf), label: Text(_genPdf ? SoleraL10n.t('ques.generando') : SoleraL10n.t('ques.generar_y_compartir_pdf'))),
        ]))),
      ]),
    );
  }
}
