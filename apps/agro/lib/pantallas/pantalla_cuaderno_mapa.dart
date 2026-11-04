import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/base_datos.dart';
import '../modelos/finca.dart';
import '../servicios/generador_cuaderno_mapa.dart';
import 'pantalla_titular.dart';

/// Pantalla para emitir el Cuaderno de Explotación por finca y año.
///
/// Antes de generar el PDF se valida que el titular esté configurado y
/// que los datos de la finca y los tratamientos cumplan lo mínimo
/// para inspección. Si fallan validaciones se muestran y se ofrece
/// navegar a la pantalla pertinente (Datos del titular, Fincas, etc.)
/// — no generamos un PDF que no aguantaría una inspección.
class PantallaCuadernoMapa extends StatefulWidget {
  PantallaCuadernoMapa({super.key});

  @override
  State<PantallaCuadernoMapa> createState() => _PantallaCuadernoMapaState();
}

class _PantallaCuadernoMapaState extends State<PantallaCuadernoMapa> {
  List<Finca> _fincas = [];
  Finca? _fincaSeleccionada;
  int _ano = DateTime.now().year;
  bool _cargando = true;
  bool _generando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final fincas = await BaseDatosAgro.instancia.listarFincas();
    if (!mounted) return;
    setState(() {
      _fincas = fincas;
      _fincaSeleccionada = fincas.isNotEmpty ? fincas.first : null;
      _cargando = false;
    });
  }

  Future<void> _generar() async {
    setState(() => _generando = true);
    final db = BaseDatosAgro.instancia;
    final titular = await db.obtenerTitular();
    final desdeMs = DateTime(_ano, 1, 1).millisecondsSinceEpoch;
    final hastaMs = DateTime(_ano + 1, 1, 1).millisecondsSinceEpoch - 1;
    final tratamientos = await db.listarTratamientosPorFincaYRango(
      fincaId: _fincaSeleccionada?.id,
      desdeMs: desdeMs,
      hastaMs: hastaMs,
    );
    final plantasFinca = await db.listarPlantas(fincaId: _fincaSeleccionada?.id);
    final cultivoIdPorPlantaId = {
      for (final p in plantasFinca) p.id!: p.cultivoId,
    };
    final validacion = validarDatosCuaderno(
      titular: titular,
      finca: _fincaSeleccionada,
      tratamientos: tratamientos,
      cultivoIdPorPlantaId: cultivoIdPorPlantaId,
    );
    if (!mounted) return;
    if (!validacion.esValido) {
      setState(() => _generando = false);
      await _mostrarErrores(validacion);
      return;
    }
    if (validacion.avisos.isNotEmpty) {
      final continuar = await _mostrarAvisos(validacion);
      if (continuar != true) {
        if (mounted) setState(() => _generando = false);
        return;
      }
    }
    final fichero = await generarCuadernoMapa(
      finca: _fincaSeleccionada,
      ano: _ano,
    );
    if (!mounted) return;
    setState(() => _generando = false);
    await Share.shareXFiles(
      [XFile(fichero.path)],
      subject: 'Cuaderno de explotación ${_fincaSeleccionada?.nombre ?? 'Puntos sueltos'} $_ano',
    );
  }

  Future<void> _mostrarErrores(ValidacionCuadernoMapa v) async {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Faltan datos para el cuaderno'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final e in v.errores) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 18),
                    SizedBox(width: 6),
                    Expanded(child: Text(e)),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cerrar'),
          ),
          if (v.errores.any((e) => e.contains('titular')))
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PantallaTitular()),
                );
              },
              child: Text('Configurar titular'),
            ),
        ],
      ),
    );
  }

  Future<bool?> _mostrarAvisos(ValidacionCuadernoMapa v) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Avisos'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final a in v.avisos) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 18),
                    SizedBox(width: 6),
                    Expanded(child: Text(a)),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(SoleraL10n.t('cancelar')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Generar igualmente'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final anos = List.generate(10, (i) => DateTime.now().year - i);
    return Scaffold(
      appBar: AppBar(title: Text('Cuaderno de explotación')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cuaderno conforme RD 1311/2012',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Genera el PDF del cuaderno de explotación con tus datos de titular, '
                    'parcelas SIGPAC y tratamientos del año seleccionado. Listo para presentar '
                    'a inspección.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Datos del titular'),
            subtitle: Text('NIF, asesor, aplicador'),
            trailing: Icon(Icons.chevron_right),
            contentPadding: EdgeInsets.zero,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaTitular()),
            ),
          ),
          Divider(),
          SizedBox(height: 8),
          DropdownButtonFormField<Finca?>(
            initialValue: _fincaSeleccionada,
            decoration: InputDecoration(
              labelText: 'Finca',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<Finca?>(value: null, child: Text('Puntos sueltos (sin finca)')),
              for (final f in _fincas)
                DropdownMenuItem<Finca?>(
                  value: f,
                  child: Text(f.nombre),
                ),
            ],
            onChanged: (v) => setState(() => _fincaSeleccionada = v),
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _ano,
            decoration: InputDecoration(
              labelText: 'Campaña',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final a in anos) DropdownMenuItem(value: a, child: Text(a.toString())),
            ],
            onChanged: (v) => setState(() => _ano = v ?? _ano),
          ),
          SizedBox(height: 16),
          FilledButton.icon(
            icon: _generando
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.picture_as_pdf),
            onPressed: _generando ? null : _generar,
            label: Text(_generando ? 'Generando…' : 'Generar y compartir'),
          ),
          SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'La exportación XML oficial al SIEX/CUE llegará en una versión futura. '
              'El PDF cumple el requisito de tener el cuaderno disponible para '
              'inspección presencial.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
