import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/queseria.dart';
import 'pantalla_acerca.dart';
import 'pantalla_backup.dart';
import 'pantalla_facturas.dart';
import 'pantalla_ia_queso.dart';
import 'pantalla_libro_economico.dart';
import 'pantalla_lista_proveedores.dart';
import 'pantalla_lista_recetas.dart';
import 'pantalla_perfil_do.dart';

/// Pantalla agregadora de ajustes, por secciones como el resto de la
/// suite: Explotación · Registros y documentos · Inteligencia artificial ·
/// Preferencias · Datos · Aplicación.
class PantallaAjustes extends StatefulWidget {
  PantallaAjustes({super.key});
  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  Queseria _queseria = Queseria();
  int _numeroProveedores = 0;
  int _numeroRecetas = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final queseria = await _bd.obtenerQueseria();
    final proveedores = await _bd.listarProveedores();
    final recetas = await _bd.listarRecetas();
    if (mounted) {
      setState(() {
        _queseria = queseria;
        _numeroProveedores = proveedores.length;
        _numeroRecetas = recetas.length;
      });
    }
  }

  Future<void> _editarQueseria() async {
    final queseriaEditada = await Navigator.push<Queseria>(
      context,
      MaterialPageRoute(
          builder: (_) => _PantallaEditarQueseria(queseria: _queseria)),
    );
    if (queseriaEditada != null) {
      await _bd.guardarQueseria(queseriaEditada);
      await _cargar();
    }
  }

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final queseriaConfigurada = _queseria.id != null;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_explotacion')),
          ListTile(
            leading: const Icon(Icons.store),
            title: Text(SoleraL10n.t('queseria')),
            subtitle: Text(queseriaConfigurada
                ? [
                    _queseria.razonSocial,
                    if (_queseria.rgseaa.isNotEmpty)
                      'RGSEAA ${_queseria.rgseaa}',
                  ].where((parte) => parte.isNotEmpty).join(' · ')
                : SoleraL10n.t('sin_configurar')),
            trailing: const Icon(Icons.edit),
            onTap: _editarQueseria,
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(SoleraL10n.t('proveedores')),
            subtitle: Text('$_numeroProveedores registrados'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(PantallaListaProveedores()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_registros')),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: Text(SoleraL10n.t('facturas')),
            subtitle: const Text('Emisión, PDF y envío'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(PantallaFacturas()),
          ),
          ListTile(
            leading: const Icon(Icons.euro),
            title: Text(SoleraL10n.t('libro_economico')),
            subtitle: const Text('Ingresos, gastos y resumen fiscal'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(PantallaLibroEconomico()),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: Text(SoleraL10n.t('recetas')),
            subtitle: Text('$_numeroRecetas registradas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(PantallaListaRecetas()),
          ),
          ListTile(
            leading: const Icon(Icons.verified),
            title: Text(SoleraL10n.t('perfiles_do')),
            subtitle: const Text('Denominaciones de Origen activas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(PantallaPerfilDo()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_integraciones')),
          ListTile(
            leading: const Icon(Icons.visibility),
            title: Text(SoleraL10n.t('identificacion_con_ia')),
            subtitle: const Text(
                'Defectos en corte y corteza del queso con Claude Vision'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(PantallaIaQueso()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_preferencias')),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SelectorIdioma(),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_datos')),
          ListTile(
            leading: const Icon(Icons.backup),
            title: Text(SoleraL10n.t('backup')),
            subtitle: const Text('Exportar / importar base de datos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(PantallaBackup()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_aplicacion')),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: Text(SoleraL10n.t('comprobar_actualizaciones')),
            subtitle: const Text('Versión instalada y última publicada'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PantallaEstadoActualizaciones(
                  config: configActualizacionesMonorepo('solera-quesera'),
                  nombreApp: 'Solera Quesera',
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(SoleraL10n.t('acerca_de')),
            subtitle: const Text('Versión $versionSoleraQuesera'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaAcerca())),
          ),
        ],
      ),
    );
  }
}

class _PantallaEditarQueseria extends StatefulWidget {
  final Queseria queseria;
  _PantallaEditarQueseria({required this.queseria});
  @override
  State<_PantallaEditarQueseria> createState() =>
      _PantallaEditarQueseriaState();
}

class _PantallaEditarQueseriaState extends State<_PantallaEditarQueseria> {
  late final _razonCtrl, _nifCtrl, _dirCtrl, _rgseaaCtrl, _telCtrl, _emailCtrl;
  @override
  void initState() {
    super.initState();
    _razonCtrl = TextEditingController(text: widget.queseria.razonSocial);
    _nifCtrl = TextEditingController(text: widget.queseria.nif);
    _dirCtrl = TextEditingController(text: widget.queseria.direccion);
    _rgseaaCtrl = TextEditingController(text: widget.queseria.rgseaa);
    _telCtrl = TextEditingController(text: widget.queseria.telefono);
    _emailCtrl = TextEditingController(text: widget.queseria.email);
  }

  @override
  void dispose() {
    _razonCtrl.dispose();
    _nifCtrl.dispose();
    _dirCtrl.dispose();
    _rgseaaCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar quesería')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(
            controller: _razonCtrl,
            decoration: InputDecoration(
                labelText: 'Razón social', border: OutlineInputBorder())),
        SizedBox(height: 12),
        TextFormField(
            controller: _nifCtrl,
            decoration: InputDecoration(
                labelText: 'NIF', border: OutlineInputBorder())),
        SizedBox(height: 12),
        TextFormField(
            controller: _rgseaaCtrl,
            decoration: InputDecoration(
                labelText: 'RGSEAA',
                border: OutlineInputBorder(),
                helperText: 'Registro General Sanitario')),
        SizedBox(height: 12),
        TextFormField(
            controller: _dirCtrl,
            decoration: InputDecoration(
                labelText: 'Dirección', border: OutlineInputBorder())),
        SizedBox(height: 12),
        TextFormField(
            controller: _telCtrl,
            decoration: InputDecoration(
                labelText: 'Teléfono', border: OutlineInputBorder()),
            keyboardType: TextInputType.phone),
        SizedBox(height: 12),
        TextFormField(
            controller: _emailCtrl,
            decoration: InputDecoration(
                labelText: 'Email', border: OutlineInputBorder()),
            keyboardType: TextInputType.emailAddress),
        SizedBox(height: 24),
        FilledButton(
            onPressed: () => Navigator.pop(
                context,
                Queseria(
                    razonSocial: _razonCtrl.text,
                    nif: _nifCtrl.text,
                    direccion: _dirCtrl.text,
                    rgseaa: _rgseaaCtrl.text,
                    telefono: _telCtrl.text,
                    email: _emailCtrl.text)),
            child: Text('Guardar')),
      ]),
    );
  }
}
