import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/base_datos.dart';
import '../modelos/factura.dart';
import '../servicios/generador_factura_pdf.dart';

const _claveEmail = 'solera_quesera.facturas.email_backup';

class PantallaFacturas extends StatefulWidget {
  const PantallaFacturas({super.key});
  @override
  State<PantallaFacturas> createState() => _PantallaFacturasState();
}

class _PantallaFacturasState extends State<PantallaFacturas> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  final _gen = GeneradorFacturaPdf();
  final _f = DateFormat('d MMM yyyy', 'es_ES');
  List<Factura> _facturas = [];
  String? _emailBackup;

  @override
  void initState() { super.initState(); _recargar(); }

  Future<void> _recargar() async {
    final db = await _bd.basedatos;
    final filas = await db.query('facturas', orderBy: 'fecha_emision_ms DESC');
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() { _facturas = filas.map(Factura.fromMap).toList(); _emailBackup = prefs.getString(_claveEmail); });
  }

  Future<String> _sigNum() async {
    final db = await _bd.basedatos;
    final a = DateTime.now().year;
    final r = await db.rawQuery("SELECT COUNT(*) AS n FROM facturas WHERE numero_factura LIKE ?", ['$a-%']);
    return '$a-${((r.first['n'] as int) + 1).toString().padLeft(4, '0')}';
  }

  Future<void> _nueva() async {
    final sn = await _sigNum(); if (!mounted) return;
    final r = await Navigator.push<Factura>(context, MaterialPageRoute(builder: (_) => _NuevaFactura(sigNum: sn)));
    if (r == null) return;
    final db = await _bd.basedatos; await db.insert('facturas', r.toMap()..remove('id'));
    await _recargar();
  }

  Future<void> _verPdf(Factura f) async {
    final doc = await _gen.generar(factura: f, emisorNombre: 'Solera Quesera', emisorNif: '', emisorDireccion: '');
    await Printing.sharePdf(bytes: await doc.save(), filename: 'factura_${f.numeroFactura}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('facturas')), actions: [
        IconButton(icon: Icon(Icons.email, color: _emailBackup != null ? Colors.green : null),
          tooltip: _emailBackup != null ? 'Backup: $_emailBackup' : 'Configurar email', onPressed: _configEmail),
      ]),
      body: _facturas.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.receipt_long_outlined, size: 64, color: t.colorScheme.outline), const SizedBox(height: 16), Text('No hay facturas', style: t.textTheme.titleMedium), const SizedBox(height: 8), FilledButton.icon(onPressed: _nueva, icon: const Icon(Icons.add), label: const Text('Emitir primera factura'))]))
        : RefreshIndicator(onRefresh: _recargar, child: ListView.builder(padding: const EdgeInsets.all(8), itemCount: _facturas.length, itemBuilder: (_, i) { final f = _facturas[i];
            final c = f.estado == 'pagada' ? Colors.green : f.estado == 'vencida' ? Colors.red : Colors.blue;
            return Card(child: ListTile(
              leading: CircleAvatar(backgroundColor: c.withAlpha(30), child: Icon(f.estado == 'pagada' ? Icons.check_circle : f.estado == 'vencida' ? Icons.error : Icons.pending, color: c, size: 20)),
              title: Text('${f.numeroFactura} — ${f.clienteNombre}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('${_f.format(DateTime.fromMillisecondsSinceEpoch(f.fechaEmisionMs))} · ${f.total.toStringAsFixed(2)}€ · ${f.estado}', style: const TextStyle(fontSize: 12)),
              trailing: PopupMenuButton<String>(onSelected: (a) async {
                if (a == 'pdf') await _verPdf(f);
                if (a == 'pagada' && f.id != null) { final db = await _bd.basedatos; await db.update('facturas', {'estado': 'pagada', 'fecha_pago_ms': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [f.id]); await _recargar(); }
                if (a == 'anular' && f.id != null) { final db = await _bd.basedatos; await db.update('facturas', {'estado': 'anulada'}, where: 'id = ?', whereArgs: [f.id]); await _recargar(); }
              }, itemBuilder: (_) => [
                const PopupMenuItem(value: 'pdf', child: ListTile(leading: Icon(Icons.picture_as_pdf), title: Text('Ver PDF'))),
                if (f.estado == 'emitida') const PopupMenuItem(value: 'pagada', child: ListTile(leading: Icon(Icons.check, color: Colors.green), title: Text('Marcar pagada', style: TextStyle(color: Colors.green)))),
                if (f.estado != 'anulada') const PopupMenuItem(value: 'anular', child: ListTile(leading: Icon(Icons.cancel, color: Colors.red), title: Text('Anular', style: TextStyle(color: Colors.red)))),
              ]),
              onTap: () => _verPdf(f),
            ));
          })),
      floatingActionButton: FloatingActionButton(heroTag: 'fab_fact', onPressed: _nueva, child: const Icon(Icons.add)),
    );
  }

  void _configEmail() async {
    final c = TextEditingController(text: _emailBackup ?? '');
    final r = await showDialog<String>(context: context, builder: (_) => AlertDialog(title: const Text('Email de respaldo'), content: TextField(controller: c, decoration: const InputDecoration(hintText: 'tucorreo@ejemplo.com', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), TextButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Guardar'))]));
    if (r != null) { (await SharedPreferences.getInstance()).setString(_claveEmail, r); setState(() => _emailBackup = r.isNotEmpty ? r : null); }
  }
}

class _NuevaFactura extends StatefulWidget {
  final String sigNum;
  const _NuevaFactura({required this.sigNum});
  @override
  State<_NuevaFactura> createState() => _NuevaFacturaState();
}

class _NuevaFacturaState extends State<_NuevaFactura> {
  final _fk = GlobalKey<FormState>();
  late final _numC, _cliC, _nifC, _dirC;
  final _lineas = <Map<String, dynamic>>[];
  final _descC = TextEditingController(), _cantC = TextEditingController(text: '1'), _precioC = TextEditingController();
  double _iva = 10;

  @override
  void initState() { super.initState();
    _numC = TextEditingController(text: widget.sigNum); _cliC = TextEditingController(); _nifC = TextEditingController(); _dirC = TextEditingController();
  }
  @override
  void dispose() { _numC.dispose(); _cliC.dispose(); _nifC.dispose(); _dirC.dispose(); _descC.dispose(); _cantC.dispose(); _precioC.dispose(); super.dispose(); }

  void _addLinea() {
    final d = _descC.text.trim();
    if (d.isEmpty) return;
    final textoCantidad = _cantC.text.trim();
    final cantidadLeida = leerEntero(textoCantidad);
    if (textoCantidad.isNotEmpty && (cantidadLeida == null || cantidadLeida <= 0)) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cantidad no válida: escribe un número entero (p. ej. 3)'))); return; }
    final c = cantidadLeida ?? 1;
    final textoPrecio = _precioC.text.trim();
    final precioLeido = leerNumero(textoPrecio, puntoDeMillares: true);
    if (textoPrecio.isNotEmpty && precioLeido == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Precio no válido (p. ej. 12,50)'))); return; }
    final p = precioLeido ?? 0;
    setState(() { _lineas.add({'descripcion': d, 'cantidad': c, 'precioUnitario': p, 'importe': c * p}); _descC.clear(); _precioC.clear(); });
  }

  double get _base => _lineas.fold(0.0, (s, l) => s + (l['importe'] as double));
  double get _tot => _base * (1 + _iva / 100);

  void _emitir() {
    if (!_fk.currentState!.validate()) return;
    if (_cliC.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre del cliente requerido'))); return; }
    final a = DateTime.now().millisecondsSinceEpoch;
    Navigator.pop(context, Factura(numeroFactura: _numC.text, fechaEmisionMs: a, fechaVencimientoMs: a + 30*86400000, clienteNombre: _cliC.text, clienteNif: _nifC.text, clienteDireccion: _dirC.text, lineasJson: jsonEncode(_lineas), baseImponible: _base, ivaPorcentaje: _iva, total: _tot, estado: 'emitida', fechaCreacionMs: a));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nueva factura')),
    body: Form(key: _fk, child: ListView(padding: const EdgeInsets.all(16), children: [
      TextFormField(controller: _numC, decoration: const InputDecoration(labelText: 'Nº factura', border: OutlineInputBorder(), isDense: true)),
      const SizedBox(height: 12),
      TextFormField(controller: _cliC, decoration: const InputDecoration(labelText: 'Cliente', border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: TextFormField(controller: _nifC, decoration: const InputDecoration(labelText: 'NIF (opcional)', border: OutlineInputBorder(), isDense: true))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _dirC, decoration: const InputDecoration(labelText: 'Dirección (opcional)', border: OutlineInputBorder(), isDense: true)))]),
      const SizedBox(height: 16),
      Text('Líneas de factura', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      ..._lineas.map((l) => Card(child: ListTile(dense: true, title: Text(l['descripcion']), subtitle: Text('${l['cantidad']} x ${l['precioUnitario']}€ = ${l['importe']}€'), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 18), onPressed: () => setState(() => _lineas.remove(l)))))),
      Row(children: [Expanded(child: TextFormField(controller: _descC, decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder(), isDense: true)))]),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: TextFormField(controller: _cantC, decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _precioC, decoration: const InputDecoration(labelText: 'Precio (€)', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)), const SizedBox(width: 8), FilledButton(onPressed: _addLinea, child: const Text('+'))]),
      const SizedBox(height: 16),
      DropdownButtonFormField<double>(decoration: const InputDecoration(labelText: 'IVA', border: OutlineInputBorder()), initialValue: _iva, items: const [DropdownMenuItem(value: 4.0, child: Text('4% (tipo reducido)')), DropdownMenuItem(value: 10.0, child: Text('10% (alimento)')), DropdownMenuItem(value: 21.0, child: Text('21% (general)'))], onChanged: (v) => setState(() => _iva = v ?? 10)),
      const SizedBox(height: 16),
      Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Base imponible'), Text('${_base.toStringAsFixed(2)}€')]), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('IVA $_iva%'), Text('${(_base * _iva / 100).toStringAsFixed(2)}€')]), const Divider(), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text('${_tot.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))])]))),
      const SizedBox(height: 16),
      FilledButton(onPressed: _emitir, child: const Text('Emitir factura')),
    ])),
  );
}
