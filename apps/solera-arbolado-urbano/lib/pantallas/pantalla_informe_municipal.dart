import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/base_datos.dart';
import '../modelos/tecnico.dart';
import '../modelos/zona.dart';
import '../servicios/generador_informe_municipal.dart';
import 'pantalla_ayuntamiento.dart';

/// Exporta el informe municipal de actuaciones sobre arbolado urbano
/// en PDF para una campaña concreta + una zona opcional. Comparte con
/// `share_plus` o abre con `printing` (visor del SO).
///
/// Si los datos del ayuntamiento no están configurados, fuerza al
/// usuario a abrir PantallaAyuntamiento antes — sin esos datos el PDF
/// queda incompleto y no es válido para presentar a concejalía.
class PantallaInformeMunicipal extends StatefulWidget {
  PantallaInformeMunicipal({super.key});

  @override
  State<PantallaInformeMunicipal> createState() => _PantallaInformeMunicipalState();
}

class _PantallaInformeMunicipalState extends State<PantallaInformeMunicipal> {
  List<Zona> _zonas = [];
  Zona? _zonaSeleccionada;
  int _ano = DateTime.now().year;
  Ayuntamiento? _ayuntamiento;
  bool _cargando = true;
  bool _generando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final db = BaseDatosSoleraArbolado.instancia;
    final zonas = await db.listarZonas();
    final ayto = await db.obtenerAyuntamiento();
    if (!mounted) return;
    setState(() {
      _zonas = zonas;
      _ayuntamiento = ayto;
      _cargando = false;
    });
  }

  Future<void> _abrirAyuntamiento() async {
    final cambio = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PantallaAyuntamiento()),
    );
    if (cambio == true) _cargar();
  }

  Future<void> _generarYCompartir() async {
    if (_ayuntamiento == null || !_ayuntamiento!.estaConfigurado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('arb.configura_primero_ayuntamiento'))),
      );
      return;
    }
    setState(() => _generando = true);
    try {
      final desdeMs = DateTime(_ano, 1, 1).millisecondsSinceEpoch;
      final hastaMs = DateTime(_ano + 1, 1, 1).millisecondsSinceEpoch;
      final fichero = await generarInformeMunicipal(
        zona: _zonaSeleccionada,
        desdeMs: desdeMs,
        hastaMs: hastaMs,
        ano: _ano,
      );
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(fichero.path)],
        text: SoleraL10n.tf('arb.texto_compartir_informe', {'ano': _ano}),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.tf('arb.error_generar_pdf', {'error': e}))),
      );
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  Future<void> _generarYAbrir() async {
    if (_ayuntamiento == null || !_ayuntamiento!.estaConfigurado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('arb.configura_primero_ayuntamiento'))),
      );
      return;
    }
    setState(() => _generando = true);
    try {
      final desdeMs = DateTime(_ano, 1, 1).millisecondsSinceEpoch;
      final hastaMs = DateTime(_ano + 1, 1, 1).millisecondsSinceEpoch;
      final fichero = await generarInformeMunicipal(
        zona: _zonaSeleccionada,
        desdeMs: desdeMs,
        hastaMs: hastaMs,
        ano: _ano,
      );
      if (!mounted) return;
      await Printing.layoutPdf(onLayout: (_) => File(fichero.path).readAsBytes());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.tf('arb.error_abrir_pdf', {'error': e}))),
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
    final aytoOk = _ayuntamiento?.estaConfigurado ?? false;
    final anoActual = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('arb.informe_municipal'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!aytoOk) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(Icons.warning),
                title: Text(SoleraL10n.t('arb.ayuntamiento_sin_configurar')),
                subtitle: Text(
                  SoleraL10n.t('arb.informe_requiere_datos_ayuntamiento'),
                ),
                onTap: _abrirAyuntamiento,
              ),
            ),
            SizedBox(height: 12),
          ],
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.account_balance),
            title: Text(aytoOk ? _ayuntamiento!.nombre : SoleraL10n.t('arb.sin_ayuntamiento_configurado')),
            subtitle: aytoOk
                ? Text('${SoleraL10n.t('arb.sigla_cif')} ${_ayuntamiento!.cif} · ${_ayuntamiento!.municipio}')
                : null,
            trailing: TextButton(onPressed: _abrirAyuntamiento, child: Text(SoleraL10n.t('editar'))),
          ),
          Divider(),
          SizedBox(height: 8),
          DropdownButtonFormField<Zona?>(
            initialValue: _zonaSeleccionada,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('arb.zona'),
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem<Zona?>(
                  value: null, child: Text(SoleraL10n.t('arb.todo_el_municipio'))),
              for (final z in _zonas)
                DropdownMenuItem<Zona?>(value: z, child: Text(z.nombre)),
            ],
            onChanged: (v) => setState(() => _zonaSeleccionada = v),
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _ano,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('arb.campana'),
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
            label: Text(SoleraL10n.t('arb.generar_y_compartir')),
          ),
          SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _generando ? null : _generarYAbrir,
            icon: Icon(Icons.print),
            label: Text(SoleraL10n.t('arb.generar_y_abrir')),
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
              '${SoleraL10n.t('arb.informe_recoge')}\n\n'
              '${SoleraL10n.t('arb.informe_verifica_formato')}',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
