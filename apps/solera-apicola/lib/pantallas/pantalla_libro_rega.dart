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
        SnackBar(content: Text(SoleraL10n.t('api.configura_primero_titular'))),
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
        SnackBar(content: Text('${SoleraL10n.t('api.error_al_generar_el_pdf')}: $e')),
      );
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  Future<void> _generarYAbrir() async {
    if (_apicultor == null || !_apicultor!.estaConfigurado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('api.configura_primero_titular'))),
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
        SnackBar(content: Text('${SoleraL10n.t('api.error_al_abrir_el_pdf')}: $e')),
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
      appBar: AppBar(title: Text(SoleraL10n.t('api.libro_rega'))),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
        children: [
          if (!apicultorOk) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(Icons.warning),
                title: Text(SoleraL10n.t('api.titular_sin_configurar')),
                subtitle: Text(SoleraL10n.t('api.libro_rega_requiere_titular')),
                onTap: _abrirApicultor,
              ),
            ),
            SizedBox(height: 12),
          ],
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.person),
            title: Text(apicultorOk ? _apicultor!.nombre : SoleraL10n.t('api.sin_titular_configurado')),
            subtitle: apicultorOk
                ? Text('${SoleraL10n.t('api.sigla_nif')} ${_apicultor!.nif} · REGA ${_apicultor!.numeroRega}')
                : null,
            trailing: TextButton(onPressed: _abrirApicultor, child: Text(SoleraL10n.t('editar'))),
          ),
          Divider(),
          SizedBox(height: 8),
          DropdownButtonFormField<Apiario?>(
            initialValue: _apiarioSeleccionado,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('api.apiario'),
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem<Apiario?>(
                  value: null, child: Text(SoleraL10n.t('api.todos_los_apiarios'))),
              for (final a in _apiarios)
                DropdownMenuItem<Apiario?>(value: a, child: Text(a.nombre)),
            ],
            onChanged: (v) => setState(() => _apiarioSeleccionado = v),
          ),
          SizedBox(height: separacionCamposSolera),
          DropdownButtonFormField<int>(
            initialValue: _ano,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('api.campana'),
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
            label: Text(SoleraL10n.t('api.generar_y_compartir')),
          ),
          SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _generando ? null : _generarYAbrir,
            icon: Icon(Icons.print),
            label: Text(SoleraL10n.t('api.generar_y_abrir')),
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
              '${SoleraL10n.t('api.libro_rega_contenido')}\n\n'
              '${SoleraL10n.t('api.libro_rega_verifica_formato')}',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
