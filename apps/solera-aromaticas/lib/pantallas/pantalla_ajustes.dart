import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SelectorIdioma, SoleraL10n;

import '../datos/base_datos.dart';
import '../modelos/titular.dart';
import 'identificar_con_ia.dart';
import 'pantalla_documentos.dart';

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  final _nombre = TextEditingController();
  final _nif = TextEditingController();
  final _registro = TextEditingController();
  final _registroSanitario = TextEditingController();
  final _municipio = TextEditingController();
  final _comunidad = TextEditingController();
  final _asesor = TextEditingController();
  final _ropo = TextEditingController();

  List<TextEditingController> get _controladores => [
        _nombre,
        _nif,
        _registro,
        _registroSanitario,
        _municipio,
        _comunidad,
        _asesor,
        _ropo
      ];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final titular =
          await BaseDatosSoleraAromaticas.instancia.obtenerTitular();
      if (!mounted) return;
      _nombre.text = titular.nombre;
      _nif.text = titular.nif;
      _registro.text = titular.registroExplotacion;
      _registroSanitario.text = titular.registroSanitario;
      _municipio.text = titular.municipio;
      _comunidad.text = titular.comunidadAutonoma;
      _asesor.text = titular.asesorNombre;
      _ropo.text = titular.asesorNumeroRopo;
    } catch (error) {
      debugPrint('No se pudo leer el titular: $error');
    }
  }

  Future<void> _guardar() async {
    await BaseDatosSoleraAromaticas.instancia.guardarTitular(Titular(
      nombre: _nombre.text.trim(),
      nif: _nif.text.trim(),
      registroExplotacion: _registro.text.trim(),
      registroSanitario: _registroSanitario.text.trim(),
      municipio: _municipio.text.trim(),
      comunidadAutonoma: _comunidad.text.trim(),
      asesorNombre: _asesor.text.trim(),
      asesorNumeroRopo: _ropo.text.trim(),
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(SoleraL10n.t('arom.guardado'))));
  }

  @override
  void dispose() {
    for (final controlador in _controladores) {
      controlador.dispose();
    }
    super.dispose();
  }

  Widget _campo(TextEditingController controlador, String etiqueta,
          {String? ayuda}) =>
      TextField(
        controller: controlador,
        decoration: InputDecoration(labelText: etiqueta, helperText: ayuda),
      );

  Widget _acceso(BuildContext context, IconData icono, String clave,
          Widget Function() destino) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icono),
        title: Text(SoleraL10n.t(clave)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => destino())),
      );

  /// Entradas a otras pantallas.
  List<Widget> _accesos(BuildContext context) => [
        _acceso(context, Icons.picture_as_pdf_outlined, 'arom.documentos',
            () => const PantallaDocumentos()),
        _acceso(context, Icons.auto_awesome_outlined,
            'arom.inteligencia_artificial', pantallaClaveAromaticas),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._accesos(context),
          const SelectorIdioma(),
          const SizedBox(height: 24),
          Text(SoleraL10n.t('arom.titular'),
              style: Theme.of(context).textTheme.titleMedium),
          _campo(_nombre, SoleraL10n.t('arom.nombre_titular')),
          _campo(_nif, 'NIF'),
          _campo(_registro, SoleraL10n.t('arom.registro_explotacion')),
          _campo(_registroSanitario, SoleraL10n.t('arom.registro_sanitario'),
              ayuda: SoleraL10n.t('arom.registro_sanitario_ayuda')),
          _campo(_municipio, SoleraL10n.t('arom.municipio')),
          _campo(_comunidad, SoleraL10n.t('arom.comunidad_autonoma')),
          _campo(_asesor, SoleraL10n.t('arom.asesor')),
          _campo(_ropo, SoleraL10n.t('arom.asesor_ropo')),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: _guardar, child: Text(SoleraL10n.t('guardar'))),
        ],
      ),
    );
  }
}
