import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/tecnico.dart';

/// CRUD básico de técnicos / operarios autorizados a firmar partes.
/// Cada actuación lleva el `tecnicoId` de quien la firmó. La aplicación
/// es B2B — varios operarios pueden trabajar contra la misma BD.
class PantallaTecnicos extends StatefulWidget {
  PantallaTecnicos({super.key});

  @override
  State<PantallaTecnicos> createState() => _PantallaTecnicosState();
}

class _PantallaTecnicosState extends State<PantallaTecnicos> {
  List<Tecnico> _tecnicos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final t = await BaseDatosSoleraArbolado.instancia.listarTecnicos();
    if (!mounted) return;
    setState(() {
      _tecnicos = t;
      _cargando = false;
    });
  }

  Future<void> _editar({Tecnico? existente}) async {
    final cambio = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogoEditarTecnico(existente: existente),
    );
    if (cambio == true) _cargar();
  }

  Future<void> _alternarActivo(Tecnico t) async {
    await BaseDatosSoleraArbolado.instancia
        .actualizarTecnico(t.id!, {'activo': t.activo ? 0 : 1});
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('arb.tecnicos_operarios'))),
      body: _tecnicos.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  '${SoleraL10n.t('arb.aun_no_hay_tecnicos')}\n\n'
                  '${SoleraL10n.t('arb.aun_no_hay_tecnicos_explicacion')}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          : ListView.separated(
              itemCount: _tecnicos.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (_, i) {
                final t = _tecnicos[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: t.activo ? Colors.green : Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(t.nombre),
                  subtitle: Text([
                    if (t.nif.isNotEmpty) 'NIF ${t.nif}',
                    if (t.empresaContratista.isNotEmpty) t.empresaContratista,
                    if (t.puedeAplicarFitosanitarios)
                      SoleraL10n.tf('arb.carnet_nivel', {'nivel': _etiquetaNivelCarnet(t.nivelCarnetAplicador)}),
                  ].join(' · ')),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'editar') _editar(existente: t);
                      if (v == 'alternar') _alternarActivo(t);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'editar', child: Text(SoleraL10n.t('editar'))),
                      PopupMenuItem(
                          value: 'alternar',
                          child: Text(t.activo ? SoleraL10n.t('arb.desactivar') : SoleraL10n.t('arb.reactivar'))),
                    ],
                  ),
                  onTap: () => _editar(existente: t),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editar(),
        icon: Icon(Icons.person_add),
        label: Text(SoleraL10n.t('arb.nuevo_tecnico')),
      ),
    );
  }
}

/// Valores guardados en BD del nivel de carnet de aplicador.
const _nivelesCarnet = ['basico', 'cualificado', 'fumigador', 'piloto'];

/// Nombre visible de un nivel de carnet; si no es uno conocido, tal cual.
String _etiquetaNivelCarnet(String nivel) {
  switch (nivel) {
    case 'basico':
      return SoleraL10n.t('arb.carnet_basico');
    case 'cualificado':
      return SoleraL10n.t('arb.carnet_cualificado');
    case 'fumigador':
      return SoleraL10n.t('arb.carnet_fumigador');
    case 'piloto':
      return SoleraL10n.t('arb.carnet_piloto_aplicador');
    default:
      return nivel;
  }
}

class _DialogoEditarTecnico extends StatefulWidget {
  final Tecnico? existente;
  _DialogoEditarTecnico({this.existente});

  @override
  State<_DialogoEditarTecnico> createState() => _DialogoEditarTecnicoState();
}

class _DialogoEditarTecnicoState extends State<_DialogoEditarTecnico> {
  final _claveFormulario = GlobalKey<FormState>();
  final _nif = TextEditingController();
  final _nombre = TextEditingController();
  final _empresa = TextEditingController();
  final _cifEmpresa = TextEditingController();
  final _telefono = TextEditingController();
  final _email = TextEditingController();
  final _carnet = TextEditingController();
  String _nivelCarnet = '';

  @override
  void initState() {
    super.initState();
    final e = widget.existente;
    if (e != null) {
      _nif.text = e.nif;
      _nombre.text = e.nombre;
      _empresa.text = e.empresaContratista;
      _cifEmpresa.text = e.cifEmpresa;
      _telefono.text = e.telefono;
      _email.text = e.email;
      _carnet.text = e.carnetAplicador;
      _nivelCarnet = e.nivelCarnetAplicador;
    }
  }

  @override
  void dispose() {
    for (final c in [_nif, _nombre, _empresa, _cifEmpresa, _telefono, _email, _carnet]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Evita que un doble toque en Guardar dé de alta al técnico dos veces.
  bool _guardando = false;

  Future<void> _guardar() async {
    if (_guardando) return;
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    try {
      await _guardarTecnico();
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _guardarTecnico() async {
    final db = BaseDatosSoleraArbolado.instancia;
    final actualizado = Tecnico(
      id: widget.existente?.id,
      nif: _nif.text.trim(),
      nombre: _nombre.text.trim(),
      empresaContratista: _empresa.text.trim(),
      cifEmpresa: _cifEmpresa.text.trim(),
      telefono: _telefono.text.trim(),
      email: _email.text.trim(),
      carnetAplicador: _carnet.text.trim(),
      nivelCarnetAplicador: _nivelCarnet,
      activo: widget.existente?.activo ?? true,
    );
    if (widget.existente == null) {
      await db.guardarTecnico(actualizado);
    } else {
      await db.actualizarTecnico(widget.existente!.id!, {
        'nif': actualizado.nif,
        'nombre': actualizado.nombre,
        'empresa_contratista': actualizado.empresaContratista,
        'cif_empresa': actualizado.cifEmpresa,
        'telefono': actualizado.telefono,
        'email': actualizado.email,
        'carnet_aplicador': actualizado.carnetAplicador,
        'nivel_carnet_aplicador': actualizado.nivelCarnetAplicador,
      });
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existente == null ? SoleraL10n.t('arb.nuevo_tecnico') : SoleraL10n.t('arb.editar_tecnico')),
      content: SingleChildScrollView(
        child: Form(
          key: _claveFormulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _campo(_nombre, '${SoleraL10n.t('arb.nombre')} *', validador: (v) => (v ?? '').trim().isEmpty ? SoleraL10n.t('arb.obligatorio') : null),
              _campo(_nif, 'NIF *', validador: (v) => (v ?? '').trim().isEmpty ? SoleraL10n.t('arb.obligatorio') : null),
              _campo(_empresa, SoleraL10n.t('arb.empresa_contratista'), hint: SoleraL10n.t('arb.empresa_contratista_hint')),
              _campo(_cifEmpresa, SoleraL10n.t('arb.cif_de_la_empresa')),
              _campo(_telefono, SoleraL10n.t('arb.telefono'), tipo: TextInputType.phone),
              _campo(_email, SoleraL10n.t('arb.email'), tipo: TextInputType.emailAddress),
              SizedBox(height: 8),
              _campo(_carnet, SoleraL10n.t('arb.carnet_de_aplicador'),
                  hint: SoleraL10n.t('arb.carnet_de_aplicador_hint')),
              DropdownButtonFormField<String>(
                initialValue: _nivelCarnet.isEmpty ? null : _nivelCarnet,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('arb.nivel_del_carnet'),
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final nivel in _nivelesCarnet)
                    DropdownMenuItem(value: nivel, child: Text(_etiquetaNivelCarnet(nivel))),
                ],
                onChanged: (v) => setState(() => _nivelCarnet = v ?? ''),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(SoleraL10n.t('cancelar'))),
        FilledButton(onPressed: _guardando ? null : _guardar, child: Text(SoleraL10n.t('guardar'))),
      ],
    );
  }

  Widget _campo(TextEditingController c, String etiqueta,
      {String? hint, TextInputType? tipo, String? Function(String?)? validador}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: c,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: etiqueta,
          hintText: hint,
          border: OutlineInputBorder(),
        ),
        validator: validador,
      ),
    );
  }
}
