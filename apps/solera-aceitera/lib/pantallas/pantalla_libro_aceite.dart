import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/base_datos.dart';
import '../modelos/campania.dart';
import '../modelos/lote_aceite.dart';
import '../modelos/movimiento.dart';
import '../modelos/titular.dart';
import '../servicios/generador_libro_aceite_pdf.dart';

/// Libro de movimientos del aceite — tabla cronológica de todas las
/// entradas/salidas/mezclas/envasados de cualquier lote, conforme al
/// seguimiento que exige AICA + RD 760/2021.
///
/// F1-A5 añade la exportación a PDF firmable (entrada en el AppBar)
/// con selector de campaña + lote opcional.
class PantallaLibroAceite extends StatefulWidget {
  const PantallaLibroAceite({super.key});

  @override
  State<PantallaLibroAceite> createState() => _PantallaLibroAceiteState();
}

class _PantallaLibroAceiteState extends State<PantallaLibroAceite> {
  final _formatoFecha = DateFormat('d/M/yyyy', 'es_ES');
  List<_FilaLibro> _filas = const [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final bd = BaseDatosSoleraAceitera();
    final lotes = await bd.listarLotesAceite();
    final mapaLotes = {for (final l in lotes) l.id!: l};
    final movimientos = await bd.listarMovimientos();
    final filas = movimientos
        .map((m) {
          final lote = mapaLotes[m.loteAceiteId];
          if (lote == null) return null;
          return _FilaLibro(movimiento: m, lote: lote);
        })
        .whereType<_FilaLibro>()
        .toList(growable: false);
    if (!mounted) return;
    setState(() => _filas = filas);
  }

  Future<void> _abrirExportPdf() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _PantallaExportLibroAceite(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Libro de movimientos del aceite'),
        actions: [
          IconButton(
            tooltip: 'Exportar PDF AICA',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _abrirExportPdf,
          ),
        ],
      ),
      body: _filas.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Sin movimientos registrados todavía.\n'
                  'Cada lote nuevo aporta una entrada al libro; mezclas, '
                  'envasados, ventas y autoconsumos también aparecen aquí.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: _filas.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final fila = _filas[i];
                  return ListTile(
                    leading: const Icon(Icons.swap_horiz,
                        color: Color(0xFF5C6B3A)),
                    title: Text(
                      '${_formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(fila.movimiento.fechaMs))}'
                      ' · Lote ${fila.lote.identificadorLote}',
                    ),
                    subtitle: Text(
                      '${fila.movimiento.tipo} · '
                      '${fila.movimiento.kgMovidos.toStringAsFixed(1)} kg'
                      '${fila.movimiento.ubicacionDestino.isEmpty ? "" : " → ${fila.movimiento.ubicacionDestino}"}',
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _FilaLibro {
  final Movimiento movimiento;
  final LoteAceite lote;

  const _FilaLibro({required this.movimiento, required this.lote});
}

/// Subpantalla de exportación del libro AICA en PDF. Se muestra con
/// `Navigator.push` desde la cabecera de `PantallaLibroAceite`.
class _PantallaExportLibroAceite extends StatefulWidget {
  const _PantallaExportLibroAceite();

  @override
  State<_PantallaExportLibroAceite> createState() =>
      _PantallaExportLibroAceiteState();
}

class _PantallaExportLibroAceiteState
    extends State<_PantallaExportLibroAceite> {
  List<Campania> _campanias = const [];
  List<LoteAceite> _lotes = const [];
  Campania? _campaniaSeleccionada;
  LoteAceite? _loteSeleccionado;
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
    final titular = await basedatos.obtenerTitular();
    final campania = _campaniaPorDefecto(campanias);
    final lotes = campania == null
        ? <LoteAceite>[]
        : await basedatos.listarLotesAceite(campaniaId: campania.id);
    if (!mounted) return;
    setState(() {
      _campanias = campanias;
      _campaniaSeleccionada = campania;
      _lotes = lotes;
      _titular = titular;
      _cargando = false;
    });
  }

  Campania? _campaniaPorDefecto(List<Campania> campanias) {
    if (campanias.isEmpty) return null;
    final abierta = campanias.where((c) => c.estaAbierta);
    if (abierta.isNotEmpty) return abierta.first;
    return campanias.first;
  }

  Future<void> _recargarLotes(Campania? campania) async {
    if (campania == null) {
      setState(() {
        _campaniaSeleccionada = null;
        _lotes = const [];
        _loteSeleccionado = null;
      });
      return;
    }
    final lotes = await BaseDatosSoleraAceitera.instancia
        .listarLotesAceite(campaniaId: campania.id);
    if (!mounted) return;
    setState(() {
      _campaniaSeleccionada = campania;
      _lotes = lotes;
      _loteSeleccionado = null;
    });
  }

  bool get _titularConfigurado {
    final t = _titular;
    if (t == null) return false;
    return t.razonSocial.isNotEmpty && t.nif.isNotEmpty;
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
              'Necesitas una campaña para generar el libro AICA.'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _generarYCompartir() async {
    if (!_validarPrecondiciones()) return;
    setState(() => _generando = true);
    try {
      final fichero = await generarLibroMovimientosAceite(
        campania: _campaniaSeleccionada!,
        lote: _loteSeleccionado,
      );
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(fichero.path)],
        text:
            'Libro de movimientos del aceite · campaña ${_campaniaSeleccionada!.anyoComercial}/${_campaniaSeleccionada!.anyoComercial + 1}',
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
      final fichero = await generarLibroMovimientosAceite(
        campania: _campaniaSeleccionada!,
        lote: _loteSeleccionado,
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

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Exportar libro AICA')),
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
                  'El libro AICA necesita razón social, NIF y n.º AICA del '
                  'titular. Edítalos desde Ajustes antes de generar el PDF.',
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
            onChanged: _recargarLotes,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<LoteAceite?>(
            initialValue: _loteSeleccionado,
            decoration: const InputDecoration(
              labelText: 'Lote (opcional)',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<LoteAceite?>(
                value: null,
                child: Text('Todos los lotes de la campaña'),
              ),
              for (final l in _lotes)
                DropdownMenuItem<LoteAceite?>(
                  value: l,
                  child: Text(
                    '${l.identificadorLote} · ${l.categoria}',
                  ),
                ),
            ],
            onChanged: (l) => setState(() => _loteSeleccionado = l),
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
              'El libro AICA v0.1 incluye tres secciones: lotes de la '
              'campaña con parámetros analíticos, molturaciones registradas '
              'y movimientos cronológicos (entradas, traslados, mezclas, '
              'envasados, ventas, autoconsumo, mermas).\n\n'
              'El subtítulo del PDF lleva el sello PROVISIONAL hasta que un '
              'auditor de la AICA revise el formato.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
