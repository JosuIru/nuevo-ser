import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/arbol.dart';
import '../servicios/generador_qr_arbol.dart';

/// Pantalla para generar e imprimir códigos QR de los árboles.
/// Permite seleccionar árboles individuales o generar por zonas.
class PantallaGenerarQr extends StatefulWidget {
  PantallaGenerarQr({super.key});

  @override
  State<PantallaGenerarQr> createState() => _PantallaGenerarQrState();
}

class _PantallaGenerarQrState extends State<PantallaGenerarQr> {
  final _bd = BaseDatosSoleraArbolado.instancia;
  final _generador = GeneradorQrArbol();

  List<Arbol> _arboles = [];
  List<Arbol> _seleccionados = [];
  String _municipio = '';
  bool _generando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final arboles = await _bd.listarArboles();
    final ayto = await _bd.obtenerAyuntamiento();
    if (mounted) {
      setState(() {
        _arboles = arboles;
        _municipio = ayto.nombre;
        _seleccionados = List.from(arboles);
      });
    }
  }

  Future<void> _generarPdf() async {
    if (_seleccionados.isEmpty) return;
    setState(() => _generando = true);
    try {
      await _generador.imprimir(
        arboles: _seleccionados,
        municipio: _municipio.isNotEmpty ? _municipio : 'Sin municipio',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${SoleraL10n.t('error')}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Generar QR'),
        actions: [
          if (_arboles.isNotEmpty)
            Text('${_seleccionados.length}/${_arboles.length}',
                style: theme.textTheme.bodySmall),
        ],
      ),
      body: _arboles.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_2_outlined,
                      size: 64, color: theme.colorScheme.outline),
                  SizedBox(height: 16),
                  Text('No hay árboles', style: theme.textTheme.titleMedium),
                  SizedBox(height: 8),
                  Text('Añade árboles desde el mapa primero',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Municipio: $_municipio',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(
                          'Se genera un PDF con los QR de los árboles seleccionados, '
                          'listo para imprimir y colocar como chapa.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    setState(() => _seleccionados = List.from(_arboles)),
                                child: Text('Seleccionar todos'),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    setState(() => _seleccionados.clear()),
                                child: Text('Deseleccionar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _arboles.length,
                    itemBuilder: (_, i) {
                      final a = _arboles[i];
                      final sel = _seleccionados.contains(a);
                      return CheckboxListTile(
                        dense: true,
                        value: sel,
                        title: Text(a.identificadorMunicipal,
                            style: TextStyle(fontSize: 13)),
                        subtitle: Text(
                          '${a.especieId} · ${a.estado.toString().split('.').last}',
                          style: TextStyle(fontSize: 11),
                        ),
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _seleccionados.add(a);
                            } else {
                              _seleccionados.remove(a);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: _arboles.isEmpty || _seleccionados.isEmpty
          ? null
          : FloatingActionButton.extended(
              heroTag: 'fab_generar_qr',
              onPressed: _generando ? null : _generarPdf,
              icon: _generando
                  ? SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.picture_as_pdf),
              label: Text(_generando
                  ? 'Generando…'
                  : 'Generar PDF (${_seleccionados.length})'),
            ),
    );
  }
}
