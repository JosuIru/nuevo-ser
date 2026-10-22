import 'package:flutter/material.dart';
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
      await Share.shareXFiles([XFile(fichero.path)], subject: 'Informe de campaña');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generando PDF: $e')));
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final anoActual = DateTime.now().year;
    final anosDisponibles = [for (var a = anoActual; a >= anoActual - 10; a--) a];
    return Scaffold(
      appBar: AppBar(title: const Text('Informe de campaña')),
      body: AbsorbPointer(
        absorbing: _generando,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<Finca?>(
              initialValue: _fincaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Finca',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<Finca?>(value: null, child: Text('Todas las fincas (incluye puntos sueltos)')),
                for (final f in _fincas) DropdownMenuItem<Finca?>(value: f, child: Text(f.nombre)),
              ],
              onChanged: (v) => setState(() => _fincaSeleccionada = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _ano,
              decoration: const InputDecoration(
                labelText: 'Campaña',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Histórico (todas las campañas)')),
                for (final a in anosDisponibles) DropdownMenuItem<int?>(value: a, child: Text('$a')),
              ],
              onChanged: (v) => setState(() => _ano = v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controladorOperador,
              decoration: const InputDecoration(
                labelText: 'Nombre del operador (opcional)',
                hintText: 'Tu nombre / nombre del agrónomo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _generando ? null : _generarYCompartir,
              label: Text(_generando ? 'Generando…' : 'Generar y compartir PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
