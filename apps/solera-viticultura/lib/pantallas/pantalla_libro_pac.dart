import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/base_datos.dart';
import '../modelos/titular.dart';
import '../modelos/vinedo.dart';
import '../servicios/generador_libro_pac.dart';
import 'pantalla_titular.dart';

/// Exporta el libro oficial de tratamientos fitosanitarios (PAC) en
/// PDF para una campaña concreta + un viñedo opcional. Comparte con
/// `share_plus` o abre con `printing` (visor del SO).
///
/// Si el titular no está configurado, fuerza al usuario a abrir
/// PantallaTitular antes — sin esos datos el PDF queda incompleto y
/// no es válido para inspección.
class PantallaLibroPac extends StatefulWidget {
  const PantallaLibroPac({super.key});

  @override
  State<PantallaLibroPac> createState() => _PantallaLibroPacState();
}

class _PantallaLibroPacState extends State<PantallaLibroPac> {
  List<Vinedo> _vinedos = [];
  Vinedo? _vinedoSeleccionado;
  int _ano = DateTime.now().year;
  Titular? _titular;
  bool _cargando = true;
  bool _generando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final db = BaseDatosSoleraViticultura.instancia;
    final vinedos = await db.listarVinedos();
    final titular = await db.obtenerTitular();
    if (!mounted) return;
    setState(() {
      _vinedos = vinedos;
      _titular = titular;
      _cargando = false;
    });
  }

  Future<void> _abrirTitular() async {
    final cambio = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PantallaTitular()),
    );
    if (cambio == true) _cargar();
  }

  Future<void> _generarYCompartir() async {
    if (_titular == null || !_titular!.estaConfigurado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Configura primero el titular de la explotación.')),
      );
      return;
    }
    setState(() => _generando = true);
    try {
      final desdeMs = DateTime(_ano, 1, 1).millisecondsSinceEpoch;
      final hastaMs = DateTime(_ano + 1, 1, 1).millisecondsSinceEpoch;
      final fichero = await generarLibroPac(
        vinedo: _vinedoSeleccionado,
        desdeMs: desdeMs,
        hastaMs: hastaMs,
        ano: _ano,
      );
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(fichero.path)],
        text: 'Libro de tratamientos · campaña $_ano',
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
    if (_titular == null || !_titular!.estaConfigurado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Configura primero el titular de la explotación.')),
      );
      return;
    }
    setState(() => _generando = true);
    try {
      final desdeMs = DateTime(_ano, 1, 1).millisecondsSinceEpoch;
      final hastaMs = DateTime(_ano + 1, 1, 1).millisecondsSinceEpoch;
      final fichero = await generarLibroPac(
        vinedo: _vinedoSeleccionado,
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
    final titularOk = _titular?.estaConfigurado ?? false;
    final anoActual = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: Text('Libro de tratamientos PAC')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!titularOk) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(Icons.warning),
                title: Text('Titular sin configurar'),
                subtitle: Text(
                  'El libro oficial requiere los datos del titular '
                  '(NIF, nombre, dirección, REGEPA…). Configúralos antes de generar.',
                ),
                onTap: _abrirTitular,
              ),
            ),
            SizedBox(height: 12),
          ],
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.person),
            title: Text(titularOk ? _titular!.nombre : 'Sin titular configurado'),
            subtitle: titularOk ? Text('NIF ${_titular!.nif}') : null,
            trailing: TextButton(onPressed: _abrirTitular, child: Text(SoleraL10n.t('editar'))),
          ),
          Divider(),
          SizedBox(height: 8),
          DropdownButtonFormField<Vinedo?>(
            initialValue: _vinedoSeleccionado,
            decoration: InputDecoration(
              labelText: 'Viñedo',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<Vinedo?>(value: null, child: Text('Todos los viñedos')),
              for (final v in _vinedos) DropdownMenuItem<Vinedo?>(value: v, child: Text(v.nombre)),
            ],
            onChanged: (v) => setState(() => _vinedoSeleccionado = v),
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
              'El libro recoge únicamente los tratamientos fitosanitarios '
              'registrados en el periodo. El manejo cultural (poda, riego, '
              'abonado) no se incluye en el libro oficial.\n\n'
              'Verifica el formato vigente del MAPA antes de presentar el '
              'documento en inspección — la regulación se actualiza '
              'periódicamente.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
