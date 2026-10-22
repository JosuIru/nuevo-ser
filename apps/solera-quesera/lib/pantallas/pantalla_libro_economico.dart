import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import '../datos/base_datos.dart';
import '../modelos/apunte_gasto.dart';
import '../modelos/apunte_ingreso.dart';
import '../modelos/tercero.dart';
import '../utiles/validar_numero.dart';

class PantallaLibroEconomico extends StatefulWidget {
  const PantallaLibroEconomico({super.key});
  @override
  State<PantallaLibroEconomico> createState() => _PantallaLibroEconomicoState();
}

class _PantallaLibroEconomicoState extends State<PantallaLibroEconomico> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  final _fd = DateFormat('d MMM yyyy', 'es_ES');
  int _anyo = DateTime.now().year, _tab = 0;
  List<ApunteIngreso> _ingresos = []; List<ApunteGasto> _gastos = []; List<Tercero> _terceros = [];

  @override
  void initState() { super.initState(); _recargar(); }

  Future<void> _recargar() async {
    final ini = DateTime(_anyo, 1, 1).millisecondsSinceEpoch;
    final fin = DateTime(_anyo, 12, 31, 23, 59).millisecondsSinceEpoch;
    final r = await Future.wait([_bd.listarIngresos(desdeMs: ini, hastaMs: fin), _bd.listarGastos(desdeMs: ini, hastaMs: fin), _bd.listarTerceros()]);
    if (mounted) setState(() { _ingresos = r[0] as List<ApunteIngreso>; _gastos = r[1] as List<ApunteGasto>; _terceros = r[2] as List<Tercero>; });
  }

  Future<void> _nuevoIng() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => _NuevoApunte(tipo: 'ingreso', terceros: _terceros)));
    _recargar();
  }

  Future<void> _nuevoGas() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => _NuevoApunte(tipo: 'gasto', terceros: _terceros)));
    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final ti = _ingresos.fold(0.0, (s, i) => s + i.total);
    final tg = _gastos.fold(0.0, (s, g) => s + g.total);
    final bal = ti - tg;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('libro_economico')),
        actions: [PopupMenuButton<int>(icon: const Icon(Icons.date_range), onSelected: (a) { setState(() => _anyo = a); _recargar(); },
          itemBuilder: (_) => List.generate(5, (i) { final y = DateTime.now().year - 2 + i; return PopupMenuItem(value: y, child: Text(y.toString(), style: TextStyle(fontWeight: y == _anyo ? FontWeight.bold : FontWeight.normal))); }))]),
      body: Column(children: [
        Container(width: double.infinity, color: Colors.amber.withAlpha(30), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [const Icon(Icons.warning_amber, size: 16, color: Colors.orange), const SizedBox(width: 4), Text(SoleraL10n.t('provisional___validar_con_asesor_fiscal'), style: const TextStyle(fontSize: 11, color: Colors.orange))])),
        TabBar(tabs: const [Tab(text: 'Ingresos'), Tab(text: 'Gastos'), Tab(text: 'Resumen')], onTap: (i) => setState(() => _tab = i)),
        Expanded(child: IndexedStack(index: _tab, children: [
          _listaIng(t, ti), _listaGas(t, tg), _resumen(t, bal, ti, tg),
        ])),
      ]),
      floatingActionButton: FloatingActionButton(heroTag: 'fab_eco', onPressed: _tab == 0 ? _nuevoIng : _nuevoGas, child: Icon(_tab == 0 ? Icons.add_circle : Icons.remove_circle)),
    );
  }

  Widget _totalCard(ThemeData t, String tit, double v, Color c) => Card(color: c.withAlpha(15), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Text(tit, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), const Spacer(), Text('${v.toStringAsFixed(2)}€', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: c))])));

  Widget _listaIng(ThemeData t, double tot) => ListView(padding: const EdgeInsets.all(16), children: [
    _totalCard(t, 'Ingresos $_anyo', tot, Colors.green),
    if (_ingresos.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(24), child: Text('Sin ingresos', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))))
    else ..._ingresos.map((i) => Card(child: ListTile(dense: true, leading: CircleAvatar(backgroundColor: Colors.green.withAlpha(30), child: const Icon(Icons.arrow_downward, color: Colors.green, size: 18)), title: Text('${i.categoria} · ${i.total.toStringAsFixed(2)}€', style: const TextStyle(fontSize: 13)), subtitle: Text('${_fd.format(DateTime.fromMillisecondsSinceEpoch(i.fechaMs))} · ${i.numeroFactura}', style: const TextStyle(fontSize: 11))))),
  ]);

  Widget _listaGas(ThemeData t, double tot) => ListView(padding: const EdgeInsets.all(16), children: [
    _totalCard(t, 'Gastos $_anyo', tot, Colors.red),
    if (_gastos.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(24), child: Text('Sin gastos', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))))
    else ..._gastos.map((g) => Card(child: ListTile(dense: true, leading: CircleAvatar(backgroundColor: Colors.red.withAlpha(30), child: const Icon(Icons.arrow_upward, color: Colors.red, size: 18)), title: Text('${g.categoria} · ${g.total.toStringAsFixed(2)}€', style: const TextStyle(fontSize: 13)), subtitle: Text('${_fd.format(DateTime.fromMillisecondsSinceEpoch(g.fechaMs))} · ${g.numeroFactura}', style: const TextStyle(fontSize: 11))))),
  ]);

  Widget _resumen(ThemeData t, double bal, double ti, double tg) => ListView(padding: const EdgeInsets.all(16), children: [
    _totalCard(t, 'Balance $_anyo', bal, bal >= 0 ? Colors.green : Colors.red),
    const Divider(),
    Text('⚠️ Datos provisionales — validar con asesor fiscal', style: TextStyle(color: Colors.orange, fontSize: 12), textAlign: TextAlign.center),
  ]);
}

class _NuevoApunte extends StatefulWidget {
  final String tipo; final List<Tercero> terceros;
  const _NuevoApunte({required this.tipo, required this.terceros});
  @override
  State<_NuevoApunte> createState() => _NuevoApunteState();
}

class _NuevoApunteState extends State<_NuevoApunte> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  final _fk = GlobalKey<FormState>();
  String _cat = 'venta_queso'; double _base = 0, _iva = 10, _tot = 0;
  final _facC = TextEditingController(), _notasC = TextEditingController();
  int _terceroId = 0;

  static const _catsIng = ['venta_queso', 'feria', 'suscripcion', 'distribuidor', 'subvencion_do', 'otro'];
  static const _catsGas = ['leche', 'fermentos_cuajo', 'energia_cava', 'etiquetado', 'analiticas', 'cuota_do', 'transporte', 'mano_obra', 'material_limpieza', 'seguros', 'otro'];

  @override
  void initState() { super.initState(); _cat = widget.tipo == 'ingreso' ? 'venta_queso' : 'leche'; }
  @override
  void dispose() { _facC.dispose(); _notasC.dispose(); super.dispose(); }

  void _calc() { setState(() => _tot = _base * (1 + _iva / 100)); }

  Future<void> _guardar() async {
    if (!_fk.currentState!.validate()) return; final a = DateTime.now().millisecondsSinceEpoch;
    if (widget.tipo == 'ingreso') await _bd.guardarIngreso(ApunteIngreso(fechaMs: a, terceroId: _terceroId, categoria: _cat, baseImponible: _base, ivaPorcentaje: _iva, total: _tot, numeroFactura: _facC.text, notas: _notasC.text, fechaCreacionMs: a));
    else await _bd.guardarGasto(ApunteGasto(fechaMs: a, terceroId: _terceroId, categoria: _cat, baseImponible: _base, ivaPorcentaje: _iva, total: _tot, numeroFactura: _facC.text, notas: _notasC.text, fechaCreacionMs: a));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.tipo == 'ingreso' ? 'Nuevo ingreso' : 'Nuevo gasto')),
    body: Form(key: _fk, child: ListView(padding: const EdgeInsets.all(16), children: [
      DropdownButtonFormField<String>(decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()), initialValue: _cat,
        items: (widget.tipo == 'ingreso' ? _catsIng : _catsGas).map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) => setState(() => _cat = v ?? _cat)),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Base imponible (€)', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, validator: (v) => avisoNumeroNoValido(v, puntoDeMillares: true), onChanged: (v) { _base = leerNumero(v, puntoDeMillares: true) ?? 0; _calc(); })), const SizedBox(width: 8), Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'IVA %', border: OutlineInputBorder(), isDense: true), initialValue: '10', keyboardType: TextInputType.number, validator: avisoNumeroNoValido, onChanged: (v) { _iva = leerNumero(v) ?? 10; _calc(); }))]),
      Text('Total: ${_tot.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      TextFormField(controller: _facC, decoration: const InputDecoration(labelText: 'Nº factura', border: OutlineInputBorder(), isDense: true)),
      TextFormField(controller: _notasC, decoration: const InputDecoration(labelText: 'Notas', border: OutlineInputBorder(), isDense: true), maxLines: 2),
      const SizedBox(height: 24),
      FilledButton(onPressed: _guardar, child: Text(widget.tipo == 'ingreso' ? 'Guardar ingreso' : 'Guardar gasto')),
    ])),
  );
}
