import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../utiles/textos_visibles.dart';

import '../datos/base_datos.dart';
import '../modelos/tercero.dart';

/// Listado de terceros (clientes + proveedores) con CRUD básico.
/// Cada apunte de ingreso/gasto puede referenciar un tercero — el
/// resumen anual usa el NIF para el modelo 347.
class PantallaTerceros extends StatefulWidget {
  const PantallaTerceros({super.key});

  @override
  State<PantallaTerceros> createState() => _PantallaTercerosState();
}

class _PantallaTercerosState extends State<PantallaTerceros> {
  List<Tercero> _terceros = const [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final t = await BaseDatosSoleraAceitera().listarTerceros();
    if (!mounted) return;
    setState(() {
      _terceros = t;
      _cargando = false;
    });
  }

  Future<void> _abrirEditor({Tercero? tercero}) async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditorTercero(tercero: tercero),
    );
    if (guardado == true) await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('acei.terceros_clientes_proveedores'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirEditor(),
        icon: const Icon(Icons.add),
        label: Text(SoleraL10n.t('acei.nuevo_tercero')),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _terceros.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      '${SoleraL10n.t('acei.sin_terceros')}\n'
                      '${SoleraL10n.t('acei.sin_terceros_ayuda')}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: _terceros.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final t = _terceros[i];
                    return ListTile(
                      leading: Icon(
                        t.esCliente && t.esProveedor
                            ? Icons.compare_arrows
                            : t.esCliente
                                ? Icons.shopping_cart
                                : Icons.local_shipping,
                        color: const Color(0xFF5C6B3A),
                      ),
                      title: Text(
                        t.nombre.isEmpty ? SoleraL10n.t('acei.sin_nombre') : t.nombre,
                      ),
                      subtitle: Text(
                        [
                          if (t.tieneNif) SoleraL10n.tf('acei.nif_valor', {'nif': t.nif}),
                          if (t.telefono.isNotEmpty) t.telefono,
                          if (t.email.isNotEmpty) t.email,
                        ].where((s) => s.isNotEmpty).join(' · '),
                      ),
                      trailing: Chip(label: Text(nombreTipoTercero(t.tipo))),
                      onTap: () => _abrirEditor(tercero: t),
                    );
                  },
                ),
    );
  }
}

class _EditorTercero extends StatefulWidget {
  final Tercero? tercero;

  const _EditorTercero({this.tercero});

  @override
  State<_EditorTercero> createState() => _EditorTerceroState();
}

class _EditorTerceroState extends State<_EditorTercero> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _nifCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _notasCtrl;
  String _tipo = 'ambos';

  @override
  void initState() {
    super.initState();
    final t = widget.tercero;
    _nombreCtrl = TextEditingController(text: t?.nombre ?? '');
    _nifCtrl = TextEditingController(text: t?.nif ?? '');
    _direccionCtrl = TextEditingController(text: t?.direccion ?? '');
    _telefonoCtrl = TextEditingController(text: t?.telefono ?? '');
    _emailCtrl = TextEditingController(text: t?.email ?? '');
    _notasCtrl = TextEditingController(text: t?.notas ?? '');
    _tipo = t?.tipo ?? 'ambos';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _nifCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  /// Evita que un doble toque en Guardar cree el tercero dos veces.
  bool _guardando = false;

  Future<void> _guardar() async {
    if (_guardando) return;
    setState(() => _guardando = true);
    try {
      await _guardarTercero();
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _guardarTercero() async {
    final t = Tercero(
      id: widget.tercero?.id,
      nombre: _nombreCtrl.text.trim(),
      nif: _nifCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      tipo: _tipo,
      notas: _notasCtrl.text.trim(),
    );
    await BaseDatosSoleraAceitera().insertarTercero(t);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(
            widget.tercero == null ? SoleraL10n.t('acei.nuevo_tercero') : SoleraL10n.t('acei.editar_tercero'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nombreCtrl,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('acei.nombre_o_razon_social'),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nifCtrl,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('acei.etiqueta_nif_cif'),
              hintText: SoleraL10n.t('acei.obligatorio_modelo_347'),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _tipo,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('acei.tipo'),
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'cliente', child: Text(SoleraL10n.t('acei.tercero_cliente'))),
              DropdownMenuItem(value: 'proveedor', child: Text(SoleraL10n.t('proveedor'))),
              DropdownMenuItem(value: 'ambos', child: Text(SoleraL10n.t('acei.tercero_ambos'))),
            ],
            onChanged: (v) => setState(() => _tipo = v ?? 'ambos'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _direccionCtrl,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('acei.direccion'),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _telefonoCtrl,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('acei.telefono'),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailCtrl,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('acei.email'),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notasCtrl,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('acei.notas'),
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _guardando ? null : _guardar,
            child: Text(SoleraL10n.t('acei.guardar_tercero')),
          ),
        ],
      ),
    );
  }
}
