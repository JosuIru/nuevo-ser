import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/base_datos.dart';
import '../modelos/campania.dart';
import '../modelos/parcela.dart';
import '../modelos/titular.dart';
import '../servicios/generador_cuaderno_pac_pdf.dart';

/// Exporta el Cuaderno de Explotación PAC olivar en PDF para una
/// campaña concreta + una parcela opcional. Comparte con `share_plus`
/// o lo abre con `printing` (visor del SO).
///
/// Si el titular no está configurado fuerza al usuario a abrir
/// Ajustes antes — sin esos datos el PDF queda incompleto y no es
/// válido para inspección OCA.
class PantallaCuadernoPac extends StatefulWidget {
  const PantallaCuadernoPac({super.key});

  @override
  State<PantallaCuadernoPac> createState() => _PantallaCuadernoPacState();
}

class _PantallaCuadernoPacState extends State<PantallaCuadernoPac> {
  List<Campania> _campanias = const [];
  List<Parcela> _parcelas = const [];
  Campania? _campaniaSeleccionada;
  Parcela? _parcelaSeleccionada;
  Titular? _titular;
  bool _cargando = true;
  bool _generando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final basedatos = BaseDatosSoleraAceitera.instancia;
    final campanias = await basedatos.listarCampanias();
    final parcelas = await basedatos.listarParcelas();
    final titular = await basedatos.obtenerTitular();
    if (!mounted) return;
    setState(() {
      _campanias = campanias;
      _parcelas = parcelas;
      _titular = titular;
      _campaniaSeleccionada = _campaniaPorDefecto(campanias);
      _cargando = false;
    });
  }

  Campania? _campaniaPorDefecto(List<Campania> campanias) {
    if (campanias.isEmpty) return null;
    final abierta = campanias.where((c) => c.estaAbierta);
    if (abierta.isNotEmpty) return abierta.first;
    return campanias.first;
  }

  bool get _titularConfigurado {
    final t = _titular;
    if (t == null) return false;
    return t.razonSocial.isNotEmpty && t.nif.isNotEmpty;
  }

  Future<void> _generarYCompartir() async {
    if (!_validarPrecondiciones()) return;
    setState(() => _generando = true);
    try {
      final fichero = await generarCuadernoPacOlivar(
        campania: _campaniaSeleccionada!,
        parcela: _parcelaSeleccionada,
      );
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(fichero.path)],
        text:
            'Cuaderno PAC olivar · campaña ${_campaniaSeleccionada!.anyoComercial}/${_campaniaSeleccionada!.anyoComercial + 1}',
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
    if (!_validarPrecondiciones()) return;
    setState(() => _generando = true);
    try {
      final fichero = await generarCuadernoPacOlivar(
        campania: _campaniaSeleccionada!,
        parcela: _parcelaSeleccionada,
      );
      if (!mounted) return;
      await Printing.layoutPdf(
        onLayout: (_) => File(fichero.path).readAsBytes(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir el PDF: $e')),
      );
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  bool _validarPrecondiciones() {
    if (!_titularConfigurado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Configura primero la razón social y el NIF del titular en Ajustes.'),
        ),
      );
      return false;
    }
    if (_campaniaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Necesitas una campaña abierta para generar el cuaderno PAC.'),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Cuaderno PAC olivar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!_titularConfigurado)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: const ListTile(
                leading: Icon(Icons.warning),
                title: Text('Titular sin configurar'),
                subtitle: Text(
                  'El cuaderno oficial necesita razón social y NIF del titular. '
                  'Edítalos desde Ajustes antes de generar el PDF.',
                ),
              ),
            ),
          if (!_titularConfigurado) const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person),
            title: Text(
              _titularConfigurado
                  ? _titular!.razonSocial
                  : 'Sin titular configurado',
            ),
            subtitle: _titularConfigurado ? Text('NIF ${_titular!.nif}') : null,
          ),
          const Divider(),
          const SizedBox(height: 8),
          DropdownButtonFormField<Campania?>(
            initialValue: _campaniaSeleccionada,
            decoration: const InputDecoration(
              labelText: 'Campaña',
              border: OutlineInputBorder(),
            ),
            items: [
              if (_campanias.isEmpty)
                const DropdownMenuItem<Campania?>(
                  value: null,
                  child: Text('Sin campañas registradas'),
                ),
              for (final c in _campanias)
                DropdownMenuItem<Campania?>(
                  value: c,
                  child: Text(
                    '${c.anyoComercial}/${c.anyoComercial + 1}'
                    '${c.estaAbierta ? " · abierta" : ""}',
                  ),
                ),
            ],
            onChanged: (c) => setState(() => _campaniaSeleccionada = c),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Parcela?>(
            initialValue: _parcelaSeleccionada,
            decoration: const InputDecoration(
              labelText: 'Parcela',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<Parcela?>(
                value: null,
                child: Text('Todas las parcelas'),
              ),
              for (final p in _parcelas)
                DropdownMenuItem<Parcela?>(
                  value: p,
                  child: Text(
                    p.nombre.isEmpty ? 'Parcela #${p.id}' : p.nombre,
                  ),
                ),
            ],
            onChanged: (p) => setState(() => _parcelaSeleccionada = p),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _generando ? null : _generarYCompartir,
            icon: _generando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.share),
            label: const Text('Generar y compartir'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _generando ? null : _generarYAbrir,
            icon: const Icon(Icons.print),
            label: const Text('Generar y abrir'),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              'El cuaderno PAC olivar v0.1 incluye dos secciones: '
              'tratamientos fitosanitarios y partes de recolección de la '
              'campaña. El resto de eventos (podas, riegos, abonados) se '
              'añadirán cuando entren los modelos correspondientes.\n\n'
              'El subtítulo del PDF lleva el sello PROVISIONAL hasta que '
              'un técnico de OCA revise el formato.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
