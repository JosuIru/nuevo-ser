import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/partida_leche.dart';
import '../utiles/validar_numero.dart';

class PantallaNuevaPartida extends StatefulWidget {
  const PantallaNuevaPartida({super.key});
  @override
  State<PantallaNuevaPartida> createState() => _PantallaNuevaPartidaState();
}

class _PantallaNuevaPartidaState extends State<PantallaNuevaPartida> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  final _fk = GlobalKey<FormState>();
  int? _proveedorId;
  final _volC = TextEditingController(), _tempC = TextEditingController(), _phC = TextEditingController();
  final _grasaC = TextEditingController(), _protC = TextEditingController(), _notasC = TextEditingController();
  bool _antib = false;
  List _proveedores = [];
  bool _guardando = false;

  @override
  void initState() { super.initState(); _bd.listarProveedores().then((p) { if (mounted) setState(() => _proveedores = p); }); }

  Future<void> _guardar() async {
    if (!_fk.currentState!.validate()) return;
    if (_proveedorId == null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(SoleraL10n.t('selecciona_un_proveedor')))); return; }
    setState(() => _guardando = true);
    await _bd.guardarPartidaLeche(PartidaLeche(proveedorId: _proveedorId!, fechaMs: DateTime.now().millisecondsSinceEpoch,
      volumenLitros: leerNumero(_volC.text, nullSiAmbiguo: true) ?? 0, temperaturaRecepcion: leerNumero(_tempC.text), ph: leerNumero(_phC.text),
      grasa: leerNumero(_grasaC.text), proteina: leerNumero(_protC.text), antibioticosPositivos: _antib, notas: _notasC.text));
    if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(SoleraL10n.t('partida_registrada')))); Navigator.pop(context); }
  }

  @override
  void dispose() { _volC.dispose(); _tempC.dispose(); _phC.dispose(); _grasaC.dispose(); _protC.dispose(); _notasC.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(SoleraL10n.t('nueva_partida_de_leche'))),
    body: Form(key: _fk, child: ListView(padding: const EdgeInsets.all(16), children: [
      DropdownButtonFormField<int>(decoration: const InputDecoration(labelText: 'Proveedor', border: OutlineInputBorder()), items: _proveedores.map((p) => DropdownMenuItem<int>(value: p.id as int, child: Text(p.nombre as String))).toList(), onChanged: (id) => _proveedorId = id, validator: (v) => v == null ? 'Requerido' : null),
      const SizedBox(height: 12),
      TextFormField(controller: _volC, decoration: const InputDecoration(labelText: 'Volumen (litros)', border: OutlineInputBorder(), suffixText: 'L'), keyboardType: TextInputType.number, validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : avisoNumeroNoValido(v, nullSiAmbiguo: true)),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: TextFormField(controller: _tempC, decoration: const InputDecoration(labelText: 'Temperatura recepción (°C)', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, validator: avisoNumeroNoValido)), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _phC, decoration: const InputDecoration(labelText: 'pH', border: OutlineInputBorder(), isDense: true), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: avisoNumeroNoValido))]),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: TextFormField(controller: _grasaC, decoration: const InputDecoration(labelText: 'Grasa (%)', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, validator: avisoNumeroNoValido)), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _protC, decoration: const InputDecoration(labelText: 'Proteína (%)', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, validator: avisoNumeroNoValido))]),
      const SizedBox(height: 12),
      CheckboxListTile(title: Text(SoleraL10n.t('antibioticos_positivos')), value: _antib, onChanged: (v) => setState(() => _antib = v ?? false)),
      const SizedBox(height: 12),
      TextFormField(controller: _notasC, decoration: const InputDecoration(labelText: 'Notas', border: OutlineInputBorder()), maxLines: 3),
      const SizedBox(height: 24),
      FilledButton(onPressed: _guardando ? null : _guardar, child: _guardando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(SoleraL10n.t('guardar_partida'))),
    ])),
  );
}
