import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/tercero.dart';

/// CRUD de terceros (clientes y proveedores) del agricultor. Una
/// sola pantalla con lista + FAB que abre un BottomSheet de
/// nuevo/editar — más compacto que dos pantallas separadas.
///
/// El NIF es lo que importa al modelo 347 (operaciones >3.005,06€
/// con un mismo NIF en el año). Los terceros sin NIF se guardan
/// igual (mercado local, vecino) pero el extracto anual los lista
/// aparte porque NO entran al 347.
class PantallaTerceros extends StatefulWidget {
  PantallaTerceros({super.key});

  @override
  State<PantallaTerceros> createState() => _PantallaTercerosState();
}

class _PantallaTercerosState extends State<PantallaTerceros> {
  final _busqueda = TextEditingController();
  List<Tercero> _terceros = const [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final filas = await BaseDatosAgro.instancia.listarTerceros();
    if (!mounted) return;
    setState(() {
      _terceros = filas;
      _cargando = false;
    });
  }

  List<Tercero> get _filtrados {
    final q = _busqueda.text.trim().toLowerCase();
    if (q.isEmpty) return _terceros;
    return _terceros.where((t) {
      return t.nombre.toLowerCase().contains(q) ||
          t.nif.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _editar(Tercero? existente) async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SheetEditarTercero(existente: existente),
    );
    if (guardado == true) await _cargar();
  }

  Future<void> _confirmarBorrado(Tercero t) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Borrar tercero'),
        content: Text(
          'Se borrará «${t.nombre}». Los apuntes asociados conservarán '
          'el importe, pero pierden la referencia al NIF — afectará al '
          'extracto del modelo 347 si es de un año aún declarado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(SoleraL10n.t('cancelar')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(SoleraL10n.t('borrar')),
          ),
        ],
      ),
    );
    if (confirmado == true && t.id != null) {
      await BaseDatosAgro.instancia.borrarTercero(t.id!);
      await _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clientes y proveedores')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editar(null),
        icon: Icon(Icons.add),
        label: Text('Nuevo'),
      ),
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _busqueda,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Buscar por nombre o NIF',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Expanded(
                  child: _filtrados.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Aún no hay terceros guardados. Añade clientes '
                              '(cooperativas, almazaras, hostelería, '
                              'distribuidores) y proveedores (insumos, '
                              'fitosanitarios, maquinaria) — el NIF de cada uno '
                              'permite generar el modelo 347 al cierre del '
                              'ejercicio.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filtrados.length,
                          separatorBuilder: (_, __) => Divider(height: 1),
                          itemBuilder: (_, i) {
                            final t = _filtrados[i];
                            return ListTile(
                              leading: Icon(_iconoTipo(t.tipo)),
                              title: Text(t.nombre.isEmpty ? '(sin nombre)' : t.nombre),
                              subtitle: Text(_subtitulo(t)),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline),
                                onPressed: () => _confirmarBorrado(t),
                              ),
                              onTap: () => _editar(t),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  IconData _iconoTipo(String tipo) {
    switch (tipo) {
      case 'cliente':
        return Icons.shopping_cart_outlined;
      case 'proveedor':
        return Icons.local_shipping_outlined;
      default:
        return Icons.swap_horiz;
    }
  }

  String _subtitulo(Tercero t) {
    final partes = <String>[];
    if (t.tieneNif) {
      partes.add(t.nif);
    } else {
      partes.add('sin NIF');
    }
    switch (t.tipo) {
      case 'cliente':
        partes.add('cliente');
        break;
      case 'proveedor':
        partes.add('proveedor');
        break;
      default:
        partes.add('cliente y proveedor');
    }
    return partes.join(' · ');
  }
}

class _SheetEditarTercero extends StatefulWidget {
  final Tercero? existente;
  _SheetEditarTercero({this.existente});

  @override
  State<_SheetEditarTercero> createState() => _SheetEditarTerceroState();
}

class _SheetEditarTerceroState extends State<_SheetEditarTercero> {
  final _claveFormulario = GlobalKey<FormState>();
  final _nif = TextEditingController();
  final _nombre = TextEditingController();
  final _direccion = TextEditingController();
  final _telefono = TextEditingController();
  final _email = TextEditingController();
  final _notas = TextEditingController();
  String _tipo = 'ambos';
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existente;
    if (e != null) {
      _nif.text = e.nif;
      _nombre.text = e.nombre;
      _direccion.text = e.direccion;
      _telefono.text = e.telefono;
      _email.text = e.email;
      _notas.text = e.notas;
      _tipo = e.tipo;
    }
  }

  @override
  void dispose() {
    for (final c in [_nif, _nombre, _direccion, _telefono, _email, _notas]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    final actualizado = Tercero(
      id: widget.existente?.id,
      nif: _nif.text.trim(),
      nombre: _nombre.text.trim(),
      direccion: _direccion.text.trim(),
      telefono: _telefono.text.trim(),
      email: _email.text.trim(),
      tipo: _tipo,
      notas: _notas.text.trim(),
    );
    final db = BaseDatosAgro.instancia;
    if (actualizado.id == null) {
      await db.guardarTercero(actualizado);
    } else {
      await db.actualizarTercero(actualizado.id!, actualizado.toMap()..remove('id'));
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final esNuevo = widget.existente == null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Form(
          key: _claveFormulario,
          child: ListView(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            children: [
              Text(
                esNuevo ? 'Nuevo tercero' : 'Editar tercero',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nombre,
                decoration: InputDecoration(
                  labelText: 'Nombre o razón social *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Nombre obligatorio' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _nif,
                decoration: InputDecoration(
                  labelText: 'NIF',
                  hintText: 'Vacío si es venta informal sin factura',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _tipo,
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                  DropdownMenuItem(value: 'proveedor', child: Text(SoleraL10n.t('proveedor'))),
                  const DropdownMenuItem(
                      value: 'ambos', child: Text('Cliente y proveedor')),
                ],
                onChanged: (v) => setState(() => _tipo = v ?? 'ambos'),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _direccion,
                decoration: InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _telefono,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _notas,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notas',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(Icons.check),
                label: Text(esNuevo ? 'Crear' : 'Guardar'),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
