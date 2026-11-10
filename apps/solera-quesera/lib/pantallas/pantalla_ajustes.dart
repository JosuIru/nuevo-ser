import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart' show CampoPunto;

import '../datos/base_datos.dart';
import '../estado/clave_anthropic_quesera.dart';
import '../modelos/queseria.dart';
import 'pantalla_acerca.dart';
import 'pantalla_backup.dart';
import 'pantalla_lista_proveedores.dart';

/// Pantalla agregadora de ajustes, por secciones como el resto de la
/// suite: Explotación · Inteligencia artificial · Preferencias · Datos ·
/// Aplicación. Los libros y documentos están en la pestaña Registros.
class PantallaAjustes extends StatefulWidget {
  PantallaAjustes({super.key});
  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  Queseria _queseria = Queseria();
  int _numeroProveedores = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final queseria = await _bd.obtenerQueseria();
    final proveedores = await _bd.listarProveedores();
    if (mounted) {
      setState(() {
        _queseria = queseria;
        _numeroProveedores = proveedores.length;
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
            subtitle: Text(
                SoleraL10n.tf('ques.registrados_n', {'n': _numeroProveedores})),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(PantallaListaProveedores()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_integraciones')),
          ListTile(
            leading: const Icon(Icons.visibility),
            title: Text(SoleraL10n.t('identificacion_con_ia')),
            subtitle: Text(SoleraL10n.t('ques.ajustes_ia_ayuda')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(pantallaClaveAnthropicQuesera()),
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
            subtitle: Text(SoleraL10n.t('ques.exportar_importar_bd')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(PantallaBackup()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_aplicacion')),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: Text(SoleraL10n.t('comprobar_actualizaciones')),
            subtitle: Text(SoleraL10n.t('ques.version_instalada_y_ultima')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PantallaEstadoActualizaciones(
                  config: configActualizacionesMonorepo('solera-quesera'),
                  nombreApp: 'Larrea Quesera',
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(SoleraL10n.t('acerca_de')),
            subtitle: Text(SoleraL10n.tf(
                'ques.version_n', {'version': versionSoleraQuesera})),
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
  late double? _latitud = widget.queseria.latitud;
  late double? _longitud = widget.queseria.longitud;
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
      appBar: AppBar(title: Text(SoleraL10n.t('ques.editar_queseria'))),
      body: ListView(padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)), children: [
        TextFormField(
            controller: _razonCtrl,
            decoration: InputDecoration(
                labelText: SoleraL10n.t('ques.razon_social'),
                border: OutlineInputBorder())),
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
                helperText: SoleraL10n.t('ques.registro_general_sanitario'))),
        SizedBox(height: 12),
        TextFormField(
            controller: _dirCtrl,
            decoration: InputDecoration(
                labelText: SoleraL10n.t('ques.direccion'),
                border: OutlineInputBorder())),
        SizedBox(height: 12),
        TextFormField(
            controller: _telCtrl,
            decoration: InputDecoration(
                labelText: SoleraL10n.t('ques.telefono'),
                border: OutlineInputBorder()),
            keyboardType: TextInputType.phone),
        SizedBox(height: 12),
        TextFormField(
            controller: _emailCtrl,
            decoration: InputDecoration(
                labelText: SoleraL10n.t('ques.correo_electronico'),
                border: OutlineInputBorder()),
            keyboardType: TextInputType.emailAddress),
        SizedBox(height: 12),
        CampoPunto(
          latitud: _latitud,
          longitud: _longitud,
          titulo: SoleraL10n.t('ques.direccion'),
          paqueteApp: paqueteAppQuesera,
          alCambiar: (latitud, longitud) => setState(() {
            _latitud = latitud;
            _longitud = longitud;
          }),
        ),
        SizedBox(height: 24),
        FilledButton(
            onPressed: () => Navigator.pop(
                context,
                // Se guarda la fila entera: lo que no se edita aquí
                // (notas, fotos) se conserva.
                Queseria(
                    razonSocial: _razonCtrl.text,
                    nif: _nifCtrl.text,
                    direccion: _dirCtrl.text,
                    latitud: _latitud,
                    longitud: _longitud,
                    rgseaa: _rgseaaCtrl.text,
                    telefono: _telCtrl.text,
                    email: _emailCtrl.text,
                    notas: widget.queseria.notas,
                    rutasFotosJson: widget.queseria.rutasFotosJson)),
            child: Text(SoleraL10n.t('guardar'))),
      ]),
    );
  }
}
