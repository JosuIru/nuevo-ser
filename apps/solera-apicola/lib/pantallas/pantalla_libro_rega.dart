import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/base_datos.dart';
import '../modelos/apiario.dart';
import '../modelos/apicultor.dart';
import '../servicios/generador_libro_rega.dart';
import 'pantalla_apicultor.dart';

/// Exporta el libro oficial de explotación apícola (REGA / SITRAN-AP) en
/// PDF para una campaña concreta + un apiario opcional. Comparte con
/// `share_plus` o abre con `printing` (visor del SO).
///
/// Si el apicultor no está configurado, fuerza al usuario a abrir
/// PantallaApicultor antes — sin esos datos el PDF queda incompleto y no
/// es válido para inspección.
class PantallaLibroRega extends StatefulWidget {
  const PantallaLibroRega({super.key});

  @override
  State<PantallaLibroRega> createState() => _PantallaLibroRegaState();
}

class _PantallaLibroRegaState extends State<PantallaLibroRega> {
  List<Apiario> _apiarios = [];
  Apiario? _apiarioSeleccionado;
  int _ano = DateTime.now().year;
  Apicultor? _apicultor;
  bool _cargando = true;
  bool _generando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final db = BaseDatosSoleraApicola.instancia;
    final apiarios = await db.listarApiarios();
    final apicultor = await db.obtenerApicultor();
    if (!mounted) return;
    setState(() {
      _apiarios = apiarios;
      _apicultor = apicultor;
      _cargando = false;
    });
  }

  Future<void> _abrirApicultor() async {
    final cambio = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PantallaApicultor()),
    );
    if (cambio == true) _cargar();
  }

  Future<void> _generarYCompartir() async {
    if (_apicultor == null || !_apicultor!.estaConfigurado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Configura primero los datos del titular.')),
      );
      return;
    }
    setState(() => _generando = true);
    try {
      final desdeMs = DateTime(_ano, 1, 1).millisecondsSinceEpoch;
      final hastaMs = DateTime(_ano + 1, 1, 1).millisecondsSinceEpoch;
      final fichero = await generarLibroRega(
        apiario: _apiarioSeleccionado,
        desdeMs: desdeMs,
        hastaMs: hastaMs,
        ano: _ano,
      );
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(fichero.path)],
        text: 'Libro de explotación apícola · campaña $_ano',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar el PDF: $e')),
      );
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  Future<void> _generarYAbrir() async {
    if (_apicultor == null || !_apicultor!.estaConfigurado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Configura primero los datos del titular.')),
      );
      return;
    }
    setState(() => _generando = true);
    try {
      final desdeMs = DateTime(_ano, 1, 1).millisecondsSinceEpoch;
      final hastaMs = DateTime(_ano + 1, 1, 1).millisecondsSinceEpoch;
      final fichero = await generarLibroRega(
        apiario: _apiarioSeleccionado,
        desdeMs: desdeMs,
        hastaMs: hastaMs,
        ano: _ano,
      );
      if (!mounted) return;
      await Printing.layoutPdf(onLayout: (_) => File(fichero.path).readAsBytes());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir el PDF: $e')),
      );
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final apicultorOk = _apicultor?.estaConfigurado ?? false;
    final anoActual = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: Text('Libro REGA')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!apicultorOk) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(Icons.warning),
                title: Text('Titular sin configurar'),
                subtitle: Text(
                  'El libro oficial REGA requiere los datos del titular '
                  '(NIF, nombre, N.º REGA, veterinario asesor…). Configúralos '
                  'antes de generar.',
                ),
                onTap: _abrirApicultor,
              ),
            ),
            SizedBox(height: 12),
          ],
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.person),
            title: Text(apicultorOk ? _apicultor!.nombre : 'Sin titular configurado'),
            subtitle: apicultorOk
                ? Text('NIF ${_apicultor!.nif} · REGA ${_apicultor!.numeroRega}')
                : null,
            trailing: TextButton(onPressed: _abrirApicultor, child: Text(SoleraL10n.t('editar'))),
          ),
          Divider(),
          SizedBox(height: 8),
          DropdownButtonFormField<Apiario?>(
            initialValue: _apiarioSeleccionado,
            decoration: InputDecoration(
              labelText: 'Apiario',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<Apiario?>(
                  value: null, child: Text('Todos los apiarios')),
              for (final a in _apiarios)
                DropdownMenuItem<Apiario?>(value: a, child: Text(a.nombre)),
            ],
            onChanged: (v) => setState(() => _apiarioSeleccionado = v),
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _ano,
            decoration: InputDecoration(
              labelText: 'Campaña',
              border: OutlineInputBorder(),
            ),
            items: [
              for (var a = anoActual; a >= anoActual - 9; a--)
                DropdownMenuItem<int>(value: a, child: Text(a.toString())),
            ],
            onChanged: (v) => setState(() => _ano = v ?? anoActual),
          ),
          SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _generando ? null : _generarYCompartir,
            icon: _generando
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(Icons.share),
            label: Text('Generar y compartir'),
          ),
          SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _generando ? null : _generarYAbrir,
            icon: Icon(Icons.print),
            label: Text('Generar y abrir'),
          ),
          SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              'El libro recoge tratamientos sanitarios, movimientos '
              '(trashumancia/altas/bajas), incidencias y cosechas del periodo. '
              'Las revisiones rutinarias no se incluyen en el libro oficial.\n\n'
              'Verifica el formato vigente del MAPA y de tu comunidad autónoma antes de '
              'presentar el documento en inspección — la regulación se '
              'actualiza periódicamente.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
