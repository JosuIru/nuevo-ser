import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../datos/catalogos_generados/do_quesos.dart';

const _clave = 'solera_quesera.do.activas';

class PantallaPerfilDo extends StatefulWidget {
  const PantallaPerfilDo({super.key});
  @override
  State<PantallaPerfilDo> createState() => _PantallaPerfilDoState();
}

class _PantallaPerfilDoState extends State<PantallaPerfilDo> {
  final Set<String> _activas = {};

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async { final p = await SharedPreferences.getInstance(); setState(() => _activas.addAll(p.getStringList(_clave) ?? [])); }

  Future<void> _toggle(String id) async {
    final p = await SharedPreferences.getInstance();
    setState(() { if (_activas.contains(id)) _activas.remove(id); else _activas.add(id); });
    await p.setStringList(_clave, _activas.toList());
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('perfiles_do'))),
      body: ListView(padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)), children: [
        Card(color: t.colorScheme.primaryContainer, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.verified, color: t.colorScheme.primary), const SizedBox(width: 8), Text(SoleraL10n.t('denominaciones_de_origen'), style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          Text(SoleraL10n.t('ques.activa_las_do'), style: const TextStyle(color: Colors.grey)),
        ]))),
        const SizedBox(height: 16),
        if (_activas.isNotEmpty) Wrap(spacing: 8, runSpacing: 4, children: _activas.map((id) {
          final dq = todosDoQuesos.firstWhere((d) => d.id == id);
          return Chip(avatar: const Icon(Icons.check, size: 16, color: Colors.green), label: Text(dq.nombre), onDeleted: () => _toggle(id));
        }).toList()),
        ...todosDoQuesos.map((dq) {
          final a = _activas.contains(dq.id);
          return Card(child: ListTile(
            leading: CircleAvatar(backgroundColor: a ? Colors.green : t.colorScheme.outline.withAlpha(40), child: Icon(a ? Icons.check : Icons.verified_outlined, color: a ? Colors.white : Colors.grey)),
            title: Text(dq.nombre, style: TextStyle(fontWeight: a ? FontWeight.bold : FontWeight.normal)),
            subtitle: Text('${dq.tipo} · ${dq.zona_geografica}\n${dq.tipo_leche} · ${SoleraL10n.tf('ques.minimo_dias_n', {'n': dq.curacion_minima_dias})}', style: const TextStyle(fontSize: 11)), isThreeLine: true,
            trailing: Switch(value: a, onChanged: (_) => _toggle(dq.id)),
            onTap: () => _detalle(dq),
          ));
        }),
      ]),
    );
  }

  void _detalle(DoQueso dq) => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => DraggableScrollableSheet(initialChildSize: 0.5, expand: false, builder: (contextoHoja, s) => ListView(controller: s, padding: margenHojaSegura(contextoHoja, const EdgeInsets.all(16)), children: [
    Text(dq.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    const SizedBox(height: 4), Text(dq.tipo, style: const TextStyle(color: Colors.grey)), const Divider(),
    _det(SoleraL10n.t('ques.zona_geografica'), dq.zona_geografica), _det(SoleraL10n.t('ques.tipo_de_leche'), dq.tipo_leche), _det(SoleraL10n.t('ques.razas_permitidas'), dq.razas_permitidas),
    _det(SoleraL10n.t('ques.coccion'), dq.coccion), _det(SoleraL10n.t('ques.curacion_minima'), SoleraL10n.tf('ques.dias_n', {'n': dq.curacion_minima_dias})), _det(SoleraL10n.t('ques.ahumado'), dq.ahumado_permitido),
  ])));

  Widget _det(String e, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 130, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey))), Expanded(child: Text(v))]));
}
