import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/partida_leche.dart';

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
    bottomNavigationBar: BarraGuardarSolera(botones: [
      FilledButton(onPressed: _guardando ? null : _guardar, child: textoOGuardando(SoleraL10n.t('guardar_partida'), guardando: _guardando)),
    ]),
    body: Form(key: _fk, child: CuerpoResponsivoSolera(child: ListView(padding: const EdgeInsets.all(16), children: [
      DropdownButtonFormField<int>(decoration: InputDecoration(labelText: SoleraL10n.t('proveedor'), border: const OutlineInputBorder()), items: _proveedores.map((p) => DropdownMenuItem<int>(value: p.id as int, child: Text(p.nombre as String))).toList(), onChanged: (id) => _proveedorId = id, validator: (v) => v == null ? SoleraL10n.t('ques.requerido') : null),
      const SizedBox(height: 12),
      TextFormField(controller: _volC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.volumen_litros'), border: const OutlineInputBorder(), suffixText: 'L'), keyboardType: TextInputType.number, validator: (v) => (v == null || v.trim().isEmpty) ? SoleraL10n.t('ques.requerido') : validarNumeroOpcional(v, nullSiAmbiguo: true)),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: TextFormField(controller: _tempC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.temperatura_recepcion_c'), border: const OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, validator: (v) => validarNumeroOpcional(v, permitirNegativos: true))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _phC, decoration: const InputDecoration(labelText: 'pH', border: OutlineInputBorder(), isDense: true), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: validarNumeroOpcional))]),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: TextFormField(controller: _grasaC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.grasa_pct'), border: const OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, validator: validarNumeroOpcional)), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _protC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.proteina_pct'), border: const OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, validator: validarNumeroOpcional))]),
      const SizedBox(height: 12),
      CheckboxListTile(title: Text(SoleraL10n.t('antibioticos_positivos')), value: _antib, onChanged: (v) => setState(() => _antib = v ?? false)),
      const SizedBox(height: 12),
      TextFormField(controller: _notasC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.notas'), border: const OutlineInputBorder()), maxLines: 3),
    ]))),
  );
}
