import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SelectorIdioma, SoleraL10n;

import '../datos/base_datos.dart';
import '../modelos/titular.dart';
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
  final _municipio = TextEditingController();
  final _asesor = TextEditingController();
  final _ropo = TextEditingController();

  List<TextEditingController> get _controladores =>
      [_nombre, _nif, _registro, _municipio, _asesor, _ropo];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final titular = await BaseDatosSoleraFrutal.instancia.obtenerTitular();
      if (!mounted) return;
      _nombre.text = titular.nombre;
      _nif.text = titular.nif;
      _registro.text = titular.registroExplotacion;
      _municipio.text = titular.municipio;
      _asesor.text = titular.asesorNombre;
      _ropo.text = titular.asesorNumeroRopo;
    } catch (error) {
      debugPrint('No se pudo leer el titular: $error');
    }
  }

  Future<void> _guardar() async {
    await BaseDatosSoleraFrutal.instancia.guardarTitular(Titular(
      nombre: _nombre.text.trim(),
      nif: _nif.text.trim(),
      registroExplotacion: _registro.text.trim(),
      municipio: _municipio.text.trim(),
      asesorNombre: _asesor.text.trim(),
      asesorNumeroRopo: _ropo.text.trim(),
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(SoleraL10n.t('frut.guardado'))));
  }

  @override
  void dispose() {
    for (final controlador in _controladores) {
      controlador.dispose();
    }
    super.dispose();
  }

  Widget _campo(TextEditingController controlador, String etiqueta) =>
      TextField(
        controller: controlador,
        decoration: InputDecoration(labelText: etiqueta),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(SoleraL10n.t('frut.documentos')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaDocumentos())),
          ),
          const SelectorIdioma(),
          const SizedBox(height: 24),
          Text(SoleraL10n.t('frut.titular'),
              style: Theme.of(context).textTheme.titleMedium),
          _campo(_nombre, SoleraL10n.t('frut.nombre_titular')),
          _campo(_nif, 'NIF'),
          _campo(_registro, SoleraL10n.t('frut.registro_explotacion')),
          _campo(_municipio, SoleraL10n.t('frut.municipio')),
          _campo(_asesor, SoleraL10n.t('frut.asesor')),
          _campo(_ropo, SoleraL10n.t('frut.asesor_ropo')),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: _guardar, child: Text(SoleraL10n.t('guardar'))),
        ],
      ),
    );
  }
}
