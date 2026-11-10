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
        SnackBar(content: Text(SoleraL10n.t('viti.configura_primero_titular'))),
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
        text: SoleraL10n.tf('viti.libro_tratamientos_campana', {'ano': _ano}),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.tf('viti.error_generar_pdf', {'error': e}))),
      );
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  Future<void> _generarYAbrir() async {
    if (_titular == null || !_titular!.estaConfigurado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('viti.configura_primero_titular'))),
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
        SnackBar(content: Text(SoleraL10n.tf('viti.error_abrir_pdf', {'error': e}))),
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
      appBar: AppBar(title: Text(SoleraL10n.t('viti.libro_tratamientos_pac'))),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
        children: [
          if (!titularOk) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(Icons.warning),
                title: Text(SoleraL10n.t('viti.titular_sin_configurar')),
                subtitle: Text(
                  SoleraL10n.t('viti.titular_requerido_libro'),
                ),
                onTap: _abrirTitular,
              ),
            ),
            SizedBox(height: 12),
          ],
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.person),
            title: Text(titularOk ? _titular!.nombre : SoleraL10n.t('viti.sin_titular_configurado')),
            subtitle: titularOk ? Text(SoleraL10n.tf('viti.nif_valor', {'nif': _titular!.nif})) : null,
            trailing: TextButton(onPressed: _abrirTitular, child: Text(SoleraL10n.t('editar'))),
          ),
          Divider(),
          SizedBox(height: 8),
          DropdownButtonFormField<Vinedo?>(
            initialValue: _vinedoSeleccionado,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('viti.vinedo'),
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem<Vinedo?>(value: null, child: Text(SoleraL10n.t('viti.todos_los_vinedos'))),
              for (final v in _vinedos) DropdownMenuItem<Vinedo?>(value: v, child: Text(v.nombre)),
            ],
            onChanged: (v) => setState(() => _vinedoSeleccionado = v),
          ),
          SizedBox(height: separacionCamposSolera),
          DropdownButtonFormField<int>(
            initialValue: _ano,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('viti.campana'),
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
            label: Text(SoleraL10n.t('viti.generar_y_compartir')),
          ),
          SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _generando ? null : _generarYAbrir,
            icon: Icon(Icons.print),
            label: Text(SoleraL10n.t('viti.generar_y_abrir')),
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
              '${SoleraL10n.t('viti.libro_pac_alcance')}\n\n'
              '${SoleraL10n.t('viti.libro_pac_verifica_formato')}',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
