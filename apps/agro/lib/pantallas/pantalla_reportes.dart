import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/base_datos.dart';
import '../modelos/finca.dart';
import '../servicios/generador_pdf.dart';

class PantallaReportes extends StatefulWidget {
  const PantallaReportes({super.key});

  @override
  State<PantallaReportes> createState() => _PantallaReportesState();
}

class _PantallaReportesState extends State<PantallaReportes> {
  List<Finca> _fincas = [];
  Finca? _fincaSeleccionada;
  int? _ano;
  final _controladorOperador = TextEditingController();
  bool _generando = false;

  @override
  void initState() {
    super.initState();
    _ano = DateTime.now().year;
    _cargarFincas();
  }

  @override
  void dispose() {
    _controladorOperador.dispose();
    super.dispose();
  }

  Future<void> _cargarFincas() async {
    final fincas = await BaseDatosAgro.instancia.listarFincas();
    if (!mounted) return;
    setState(() => _fincas = fincas);
  }

  Future<void> _generarYCompartir() async {
    setState(() => _generando = true);
    try {
      final fichero = await generarPdfCampana(
        finca: _fincaSeleccionada,
        ano: _ano,
        operador: _controladorOperador.text.trim(),
      );
      if (!mounted) return;
      await Share.shareXFiles([XFile(fichero.path)], subject: SoleraL10n.t('agro.informe_de_campana'));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(SoleraL10n.tf('agro.error_al_generar_pdf', {'error': e}))));
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final anoActual = DateTime.now().year;
    final anosDisponibles = [for (var a = anoActual; a >= anoActual - 10; a--) a];
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('agro.informe_de_campana'))),
      body: AbsorbPointer(
        absorbing: _generando,
        child: ListView(
          padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
          children: [
            DropdownButtonFormField<Finca?>(
              initialValue: _fincaSeleccionada,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('agro.finca'),
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem<Finca?>(value: null, child: Text(SoleraL10n.t('agro.todas_las_fincas_con_sueltos'))),
                for (final f in _fincas) DropdownMenuItem<Finca?>(value: f, child: Text(f.nombre)),
              ],
              onChanged: (v) => setState(() => _fincaSeleccionada = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _ano,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('agro.campana'),
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem<int?>(value: null, child: Text(SoleraL10n.t('agro.historico_todas_campanas'))),
                for (final a in anosDisponibles) DropdownMenuItem<int?>(value: a, child: Text('$a')),
              ],
              onChanged: (v) => setState(() => _ano = v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controladorOperador,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('agro.nombre_operador_opcional'),
                hintText: SoleraL10n.t('agro.nombre_operador_ayuda'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _generando ? null : _generarYCompartir,
              label: Text(_generando ? SoleraL10n.t('agro.generando') : SoleraL10n.t('agro.generar_y_compartir_pdf')),
            ),
          ],
        ),
      ),
    );
  }
}
