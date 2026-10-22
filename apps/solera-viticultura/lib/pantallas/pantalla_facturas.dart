import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/base_datos.dart';

const _claveEmailBackup = 'solera_viticultura.facturas.email_backup';

/// Pantalla de gestión de facturas emitidas.
/// Permite crear, listar, ver PDF y compartir cada factura.
class PantallaFacturas extends StatefulWidget {
  PantallaFacturas({super.key});

  @override
  State<PantallaFacturas> createState() => _PantallaFacturasState();
}

class _PantallaFacturasState extends State<PantallaFacturas> {
  final _bd = BaseDatosSoleraViticultura.instancia;
  final _generador = GeneradorFacturaPdf();
  final _formatter = DateFormat('d MMM yyyy', 'es_ES');

  List<Factura> _facturas = [];
  String? _emailBackup;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  Future<void> _recargar() async {
    final facturas = await _listarFacturas();
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_claveEmailBackup);
    if (mounted) {
      setState(() {
        _facturas = facturas;
        _emailBackup = email;
      });
    }
  }

  Future<List<Factura>> _listarFacturas() async {
    final db = await _bd.basedatos;
    final filas = await db.query('facturas', orderBy: 'fecha_emision_ms DESC');
    return filas.map(Factura.fromMap).toList();
  }

  Future<String> _siguienteNumero() async {
    final db = await _bd.basedatos;
    final anyo = DateTime.now().year;
    final filas = await db.rawQuery(
      "SELECT COUNT(*) AS n FROM facturas WHERE numero_factura LIKE ?",
      ['$anyo-%'],
    );
    final n = (filas.first['n'] as int) + 1;
    return '$anyo-${n.toString().padLeft(4, '0')}';
  }

  Future<void> _nuevaFactura() async {
    final sigNum = await _siguienteNumero();
    if (!mounted) return;
    final result = await Navigator.push<Factura>(
      context,
      MaterialPageRoute(
          builder: (_) => _PantallaNuevaFactura(
                siguienteNumero: sigNum,
              )),
    );
    if (result == null) return;
    final db = await _bd.basedatos;
    await db.insert('facturas', result.toMap()..remove('id'));
    await _recargar();
    if (_emailBackup != null && _emailBackup!.isNotEmpty) {
      _compartirFactura(result);
    }
  }

  Future<void> _verPdf(Factura f) async {
    final titular = await _bd.obtenerTitular();
    final doc = await _generador.generar(
      factura: f,
      emisor: DatosEmisorFactura(
        nombre: titular.nombre.isNotEmpty
            ? titular.nombre
            : 'Bodega (sin configurar)',
        nif: titular.nif,
        direccion: titular.direccion,
        telefono: titular.telefono,
        email: titular.email,
      ),
    );
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'factura_${f.numeroFactura}.pdf',
    );
  }

  Future<void> _compartirFactura(Factura f) async {
    final titular = await _bd.obtenerTitular();
    final doc = await _generador.generar(
      factura: f,
      emisor: DatosEmisorFactura(
        nombre: titular.nombre.isNotEmpty ? titular.nombre : 'Bodega',
        nif: titular.nif,
        direccion: titular.direccion,
      ),
    );
    final pdfBytes = await doc.save();
    final tmp = await getTemporaryDirectory();
    final file = File('${tmp.path}/factura_${f.numeroFactura}.pdf');
    await file.writeAsBytes(pdfBytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Factura ${f.numeroFactura} — ${f.clienteNombre}',
      text: _emailBackup != null && _emailBackup!.isNotEmpty
          ? 'Copia para: $_emailBackup'
          : '',
    );
  }

  Future<void> _configurarEmailBackup() async {
    final ctrl = TextEditingController(text: _emailBackup ?? '');
    final nuevo = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(SoleraL10n.t('email_de_respaldo')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Al crear una factura, podrás enviar una copia '
              'a esta dirección como respaldo.',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            TextField(
              controller: ctrl,
              decoration: InputDecoration(
                hintText: 'tucorreo@ejemplo.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(SoleraL10n.t('cancelar'))),
          TextButton(
              onPressed: () {
                Navigator.pop(context, ctrl.text.trim());
              },
              child: Text(SoleraL10n.t('guardar'))),
        ],
      ),
    );
    if (nuevo != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_claveEmailBackup, nuevo);
      setState(() => _emailBackup = nuevo.isNotEmpty ? nuevo : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('facturas')),
        actions: [
          IconButton(
            icon: Icon(
              Icons.email,
              color: _emailBackup != null && _emailBackup!.isNotEmpty
                  ? Colors.green
                  : null,
            ),
            tooltip: _emailBackup != null && _emailBackup!.isNotEmpty
                ? 'Backup: $_emailBackup'
                : 'Configurar email de respaldo',
            onPressed: _configurarEmailBackup,
          ),
        ],
      ),
      body: _facturas.isEmpty
          ? _buildVacio(theme)
          : RefreshIndicator(
              onRefresh: _recargar,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _facturas.length,
                itemBuilder: (_, i) => _buildItem(_facturas[i], theme),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_factura',
        onPressed: _nuevaFactura,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildItem(Factura f, ThemeData theme) {
    final colorEstado = f.estado == 'pagada'
        ? Colors.green
        : f.estado == 'vencida'
            ? Colors.red
            : Colors.blue;
    final iconoEstado = f.estado == 'pagada'
        ? Icons.check_circle
        : f.estado == 'vencida'
            ? Icons.error
            : Icons.pending;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorEstado.withAlpha(30),
          child: Icon(iconoEstado, color: colorEstado, size: 20),
        ),
        title: Text('${f.numeroFactura} — ${f.clienteNombre}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(
          '${_formatter.format(DateTime.fromMillisecondsSinceEpoch(f.fechaEmisionMs))} · '
          '${f.total.toStringAsFixed(2)}€ · ${f.estado}',
          style: TextStyle(fontSize: 12),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (a) async {
            if (a == 'pdf') await _verPdf(f);
            if (a == 'compartir') await _compartirFactura(f);
            if (a == 'pagada') await _marcarPagada(f);
            if (a == 'anular') await _anular(f);
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'pdf', child: ListTile(
                leading: Icon(Icons.picture_as_pdf), title: Text(SoleraL10n.t('ver_pdf')))),
            PopupMenuItem(value: 'compartir', child: ListTile(
                leading: Icon(Icons.share), title: Text(SoleraL10n.t('compartir')))),
            if (f.estado == 'emitida')
              PopupMenuItem(value: 'pagada', child: ListTile(
                  leading: Icon(Icons.check, color: Colors.green),
                  title: Text('Marcar pagada',
                      style: TextStyle(color: Colors.green)))),
            if (f.estado != 'anulada')
              PopupMenuItem(value: 'anular', child: ListTile(
                  leading: Icon(Icons.cancel, color: Colors.red),
                  title: Text('Anular',
                      style: TextStyle(color: Colors.red)))),
          ],
        ),
        onTap: () => _verPdf(f),
      ),
    );
  }

  Future<void> _marcarPagada(Factura f) async {
    if (f.id == null) return;
    final db = await _bd.basedatos;
    await db.update('facturas', {
      'estado': 'pagada',
      'fecha_pago_ms': DateTime.now().millisecondsSinceEpoch,
    }, where: 'id = ?', whereArgs: [f.id]);
    await _recargar();
  }

  Future<void> _anular(Factura f) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(SoleraL10n.t('anular_factura')),
        content: Text('¿Anular ${f.numeroFactura}? No se elimina, '
            'queda registrada como anulada.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: Text(SoleraL10n.t('cancelar'))),
          FilledButton(onPressed: () => Navigator.pop(context, true),
              child: Text('Anular',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true || f.id == null) return;
    final db = await _bd.basedatos;
    await db.update('facturas', {'estado': 'anulada'},
        where: 'id = ?', whereArgs: [f.id]);
    await _recargar();
  }

  Widget _buildVacio(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: theme.colorScheme.outline),
          SizedBox(height: 16),
          Text('No hay facturas', style: theme.textTheme.titleMedium),
          SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _nuevaFactura,
            icon: Icon(Icons.add),
            label: Text(SoleraL10n.t('emitir_primera_factura')),
          ),
        ],
      ),
    );
  }
}

/// Formulario de nueva factura.
class _PantallaNuevaFactura extends StatefulWidget {
  final String siguienteNumero;
  _PantallaNuevaFactura({required this.siguienteNumero});

  @override
  State<_PantallaNuevaFactura> createState() =>
      _PantallaNuevaFacturaState();
}

class _PantallaNuevaFacturaState extends State<_PantallaNuevaFactura> {
  final _formKey = GlobalKey<FormState>();

  late final _numCtrl;
  late final _clienteCtrl;
  late final _nifCtrl;
  late final _dirCtrl;
  final _lineas = <Map<String, dynamic>>[];
  final _descCtrl = TextEditingController();
  final _cantCtrl = TextEditingController(text: '1');
  final _precioCtrl = TextEditingController();
  double _iva = 10;

  @override
  void initState() {
    super.initState();
    _numCtrl = TextEditingController(text: widget.siguienteNumero);
    _clienteCtrl = TextEditingController();
    _nifCtrl = TextEditingController();
    _dirCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _numCtrl.dispose();
    _clienteCtrl.dispose();
    _nifCtrl.dispose();
    _dirCtrl.dispose();
    _descCtrl.dispose();
    _cantCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  void _anadirLinea() {
    final desc = _descCtrl.text.trim();
    if (desc.isEmpty) return;
    // Cantidad entera de unidades; precio en euros a la española («1.200,50»).
    final cantidadLeida =
        _cantCtrl.text.trim().isEmpty ? 1 : leerEntero(_cantCtrl.text);
    final precio = leerNumero(_precioCtrl.text, puntoDeMillares: true);
    if (cantidadLeida == null || precio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('numero_no_valido'))),
      );
      return;
    }
    final cant = cantidadLeida;
    setState(() {
      _lineas.add({
        'descripcion': desc,
        'cantidad': cant,
        'precioUnitario': precio,
        'importe': cant * precio,
      });
      _descCtrl.clear();
      _precioCtrl.clear();
    });
  }

  double get _baseImponible =>
      _lineas.fold(0.0, (s, l) => s + (l['importe'] as double));
  double get _total => _baseImponible * (1 + _iva / 100);

  void _emitir() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clienteCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('nombre_del_cliente_requerido'))),
      );
      return;
    }
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final factura = Factura(
      numeroFactura: _numCtrl.text,
      fechaEmisionMs: ahora,
      fechaVencimientoMs: ahora + 30 * 86400000, // 30 días
      clienteNombre: _clienteCtrl.text,
      clienteNif: _nifCtrl.text,
      clienteDireccion: _dirCtrl.text,
      lineasJson: jsonEncode(_lineas),
      baseImponible: _baseImponible,
      ivaPorcentaje: _iva,
      total: _total,
      estado: 'emitida',
      fechaCreacionMs: ahora,
    );
    Navigator.pop(context, factura);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('nueva_factura'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nº factura
            TextFormField(
              controller: _numCtrl,
              decoration: InputDecoration(
                  labelText: 'Nº factura',
                  border: OutlineInputBorder(),
                  isDense: true),
            ),
            SizedBox(height: 12),

            // Cliente
            TextFormField(
              controller: _clienteCtrl,
              decoration: InputDecoration(
                  labelText: 'Cliente',
                  border: OutlineInputBorder(),
                  isDense: true),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nifCtrl,
                    decoration: InputDecoration(
                        labelText: 'NIF (opcional)',
                        border: OutlineInputBorder(),
                        isDense: true),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _dirCtrl,
                    decoration: InputDecoration(
                        labelText: 'Dirección (opcional)',
                        border: OutlineInputBorder(),
                        isDense: true),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Líneas
            Text('Líneas de factura',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ..._lineas.map((l) => Card(
                  child: ListTile(
                    dense: true,
                    title: Text(l['descripcion']),
                    subtitle: Text(
                        '${l['cantidad']} x ${l['precioUnitario']}€ = ${l['importe']}€'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: () =>
                          setState(() => _lineas.remove(l)),
                    ),
                  ),
                )),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _descCtrl,
                    decoration: InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                        isDense: true),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cantCtrl,
                    decoration: InputDecoration(
                        labelText: 'Cantidad',
                        border: OutlineInputBorder(),
                        isDense: true),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _precioCtrl,
                    decoration: InputDecoration(
                        labelText: 'Precio (€)',
                        border: OutlineInputBorder(),
                        isDense: true),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                SizedBox(width: 8),
                FilledButton(
                  onPressed: _anadirLinea,
                  child: Text('+'),
                ),
              ],
            ),
            SizedBox(height: 16),

            // IVA
            DropdownButtonFormField<double>(
              decoration: InputDecoration(
                  labelText: 'IVA',
                  border: OutlineInputBorder(),
                  isDense: true),
              initialValue: _iva,
              items: [
                DropdownMenuItem(value: 4.0, child: Text(SoleraL10n.t('4%_(tipo_reducido)'))),
                DropdownMenuItem(value: 10.0, child: Text(SoleraL10n.t('10%_(alimento)'))),
                DropdownMenuItem(value: 21.0, child: Text(SoleraL10n.t('21%_(general)'))),
              ],
              onChanged: (v) => setState(() => _iva = v ?? 10),
            ),
            SizedBox(height: 16),

            // Totales
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _filaTotal('Base imponible', _baseImponible),
                    _filaTotal(
                        'IVA $_iva%', _baseImponible * _iva / 100),
                    Divider(),
                    _filaTotal('TOTAL', _total, bold: true),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            FilledButton(
              onPressed: _emitir,
              child: Text(SoleraL10n.t('emitir_factura')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaTotal(String etiqueta, double valor, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: bold ? 16 : 14)),
          Text('${valor.toStringAsFixed(2)}€',
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: bold ? 16 : 14)),
        ],
      ),
    );
  }
}
