import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/queseria.dart';
import 'pantalla_backup.dart';
import 'pantalla_facturas.dart';
import 'pantalla_ia_queso.dart';
import 'pantalla_libro_economico.dart';
import 'pantalla_lista_proveedores.dart';
import 'pantalla_lista_recetas.dart';
import 'pantalla_perfil_do.dart';

class PantallaAjustes extends StatefulWidget {
  PantallaAjustes({super.key});
  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  Queseria _queseria = Queseria();
  int _numProveedores = 0, _numRecetas = 0, _numLotes = 0;

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    final q = await _bd.obtenerQueseria();
    final p = await _bd.listarProveedores();
    final r = await _bd.listarRecetas();
    final l = await _bd.listarLotes();
    if (mounted) setState(() { _queseria = q; _numProveedores = p.length; _numRecetas = r.length; _numLotes = l.length; });
  }

  Future<void> _editarQueseria() async {
    final r = await Navigator.push<Queseria>(context, MaterialPageRoute(builder: (_) => _PantallaEditarQueseria(queseria: _queseria)));
    if (r != null) { await _bd.guardarQueseria(r); await _cargar(); }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(SoleraL10n.t('queseria'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          if (_queseria.id == null) Text(SoleraL10n.t('sin_configurar'), style: TextStyle(color: Colors.grey))
          else ...[_info('Razón social', _queseria.razonSocial), _info('NIF', _queseria.nif), _info('RGSEAA', _queseria.rgseaa), _info('Dirección', _queseria.direccion)],
          SizedBox(height: 8),
          FilledButton.icon(onPressed: _editarQueseria, icon: Icon(Icons.edit), label: Text(_queseria.id == null ? 'Configurar' : 'Editar')),
        ]))),
        SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Resumen', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _info('Proveedores', '$_numProveedores'), _info('Recetas', '$_numRecetas'), _info('Lotes registrados', '$_numLotes'),
        ]))),
        SizedBox(height: 12),
        Card(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Idioma / Language', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          SelectorIdioma(),
        ]))),
        SizedBox(height: 12),
        ListTile(leading: Icon(Icons.visibility), title: Text('IA — Defectos en queso'), subtitle: Text('Identificar defectos con Claude Vision'), trailing: Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaIaQueso())).then((_) => _cargar())),
        Divider(height: 1),
        ListTile(leading: Icon(Icons.receipt), title: Text(SoleraL10n.t('facturas')), subtitle: Text('Emisión, PDF y envío'), trailing: Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaFacturas())).then((_) => _cargar())),
        Divider(height: 1),
        ListTile(leading: Icon(Icons.euro), title: Text(SoleraL10n.t('libro_economico')), subtitle: Text('Ingresos, gastos y resumen fiscal'), trailing: Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaLibroEconomico())).then((_) => _cargar())),
        Divider(height: 1),
        ListTile(leading: Icon(Icons.person), title: Text(SoleraL10n.t('proveedores')), subtitle: Text('$_numProveedores registrados'), trailing: Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaListaProveedores())).then((_) => _cargar())),
        Divider(height: 1),
        ListTile(leading: Icon(Icons.restaurant_menu), title: Text(SoleraL10n.t('recetas')), subtitle: Text('$_numRecetas registradas'), trailing: Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaListaRecetas())).then((_) => _cargar())),
        Divider(height: 1),
        ListTile(leading: Icon(Icons.verified), title: Text(SoleraL10n.t('perfiles_do')), subtitle: Text('Denominaciones de Origen activas'), trailing: Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaPerfilDo())).then((_) => _cargar())),
        Divider(height: 1),
        ListTile(leading: Icon(Icons.backup), title: Text(SoleraL10n.t('backup')), subtitle: Text('Exportar / importar base de datos'), trailing: Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaBackup())).then((_) => _cargar())),
        Divider(height: 1),
        ListTile(leading: Icon(Icons.system_update), title: Text('Actualizaciones'), subtitle: Text('Versión instalada y última publicada'), trailing: Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaEstadoActualizaciones(config: configActualizacionesMonorepo('solera-quesera'), nombreApp: 'Solera Quesera')))),
        Divider(height: 1),
        ListTile(leading: Icon(Icons.info_outline), title: Text('Acerca de Solera Quesera'), trailing: Icon(Icons.chevron_right), onTap: () => _mostrarAcerca(context)),
      ]),
    );
  }

  Widget _info(String e, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [SizedBox(width: 110, child: Text(e, style: TextStyle(color: Colors.grey))), Expanded(child: Text(v))]));

  void _mostrarAcerca(BuildContext context) {
    showAboutDialog(context: context, applicationName: 'Solera Quesera', applicationVersion: '0.1.0', applicationLegalese: 'Suite Solera · Colección Nuevo Ser Kids © 2026\n\nApp para queserías artesanales.');
  }
}

class _PantallaEditarQueseria extends StatefulWidget {
  final Queseria queseria;
  _PantallaEditarQueseria({required this.queseria});
  @override
  State<_PantallaEditarQueseria> createState() => _PantallaEditarQueseriaState();
}

class _PantallaEditarQueseriaState extends State<_PantallaEditarQueseria> {
  late final _razonCtrl, _nifCtrl, _dirCtrl, _rgseaaCtrl, _telCtrl, _emailCtrl;
  @override
  void initState() { super.initState(); _razonCtrl = TextEditingController(text: widget.queseria.razonSocial); _nifCtrl = TextEditingController(text: widget.queseria.nif); _dirCtrl = TextEditingController(text: widget.queseria.direccion); _rgseaaCtrl = TextEditingController(text: widget.queseria.rgseaa); _telCtrl = TextEditingController(text: widget.queseria.telefono); _emailCtrl = TextEditingController(text: widget.queseria.email); }
  @override
  void dispose() { _razonCtrl.dispose(); _nifCtrl.dispose(); _dirCtrl.dispose(); _rgseaaCtrl.dispose(); _telCtrl.dispose(); _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar quesería')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(controller: _razonCtrl, decoration: InputDecoration(labelText: 'Razón social', border: OutlineInputBorder())),
        SizedBox(height: 12),
        TextFormField(controller: _nifCtrl, decoration: InputDecoration(labelText: 'NIF', border: OutlineInputBorder())),
        SizedBox(height: 12),
        TextFormField(controller: _rgseaaCtrl, decoration: InputDecoration(labelText: 'RGSEAA', border: OutlineInputBorder(), helperText: 'Registro General Sanitario')),
        SizedBox(height: 12),
        TextFormField(controller: _dirCtrl, decoration: InputDecoration(labelText: 'Dirección', border: OutlineInputBorder())),
        SizedBox(height: 12),
        TextFormField(controller: _telCtrl, decoration: InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
        SizedBox(height: 12),
        TextFormField(controller: _emailCtrl, decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
        SizedBox(height: 24),
        FilledButton(onPressed: () => Navigator.pop(context, Queseria(razonSocial: _razonCtrl.text, nif: _nifCtrl.text, direccion: _dirCtrl.text, rgseaa: _rgseaaCtrl.text, telefono: _telCtrl.text, email: _emailCtrl.text)), child: Text('Guardar')),
      ]),
    );
  }
}
