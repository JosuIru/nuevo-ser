import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SelectorIdioma, SoleraL10n;

import '../datos/base_datos.dart';
import '../modelos/titular.dart';
import 'hoja_formulario.dart';
import 'pantalla_documentos.dart';
import 'pantalla_economia.dart';

/// Ajustes: idioma, datos de la huerta para los cuadernos y accesos.
class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  final _nombre = TextEditingController();
  final _nif = TextEditingController();
  final _nombreHuerta = TextEditingController();
  final _registro = TextEditingController();
  final _municipio = TextEditingController();
  final _comunidad = TextEditingController();
  final _organismo = TextEditingController();
  final _codigoOperador = TextEditingController();
  final _asesor = TextEditingController();
  final _ropo = TextEditingController();
  int? _idTitular;

  List<TextEditingController> get _controladores => [
        _nombre,
        _nif,
        _nombreHuerta,
        _registro,
        _municipio,
        _comunidad,
        _organismo,
        _codigoOperador,
        _asesor,
        _ropo,
      ];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final titular = await BaseDatosSoleraHuerta.instancia.obtenerTitular();
      if (!mounted) return;
      _idTitular = titular.id;
      _nombre.text = titular.nombre;
      _nif.text = titular.nif;
      _nombreHuerta.text = titular.nombreHuerta;
      _registro.text = titular.registroExplotacion;
      _municipio.text = titular.municipio;
      _comunidad.text = titular.comunidadAutonoma;
      _organismo.text = titular.organismoControl;
      _codigoOperador.text = titular.codigoOperadorEcologico;
      _asesor.text = titular.asesorNombre;
      _ropo.text = titular.asesorNumeroRopo;
    } catch (error) {
      debugPrint('No se pudo leer el titular: $error');
    }
  }

  Future<void> _guardar() async {
    await BaseDatosSoleraHuerta.instancia.guardarTitular(Titular(
      id: _idTitular,
      nombre: _nombre.text.trim(),
      nif: _nif.text.trim(),
      nombreHuerta: _nombreHuerta.text.trim(),
      registroExplotacion: _registro.text.trim(),
      municipio: _municipio.text.trim(),
      comunidadAutonoma: _comunidad.text.trim(),
      organismoControl: _organismo.text.trim(),
      codigoOperadorEcologico: _codigoOperador.text.trim(),
      asesorNombre: _asesor.text.trim(),
      asesorNumeroRopo: _ropo.text.trim(),
    ));
    if (!mounted) return;
    avisar(context, SoleraL10n.t('huer.guardado'));
  }

  @override
  void dispose() {
    for (final controlador in _controladores) {
      controlador.dispose();
    }
    super.dispose();
  }

  Widget _acceso(IconData icono, String clave, Widget pantalla) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icono),
        title: Text(SoleraL10n.t(clave)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => pantalla)),
      );

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _acceso(Icons.picture_as_pdf_outlined, 'huer.documentos',
              const PantallaDocumentos()),
          _acceso(Icons.euro_outlined, 'huer.ingresos_y_gastos',
              const PantallaEconomia()),
          const SelectorIdioma(),
          const SizedBox(height: 24),
          Text(SoleraL10n.t('huer.datos_huerta'), style: estilo),
          campoTexto(_nombreHuerta, SoleraL10n.t('huer.nombre_huerta')),
          campoTexto(_nombre, SoleraL10n.t('huer.nombre_titular')),
          campoTexto(_nif, SoleraL10n.t('huer.nif')),
          campoTexto(_registro, SoleraL10n.t('huer.registro_explotacion')),
          campoTexto(_municipio, SoleraL10n.t('huer.municipio')),
          campoTexto(_comunidad, SoleraL10n.t('huer.comunidad_autonoma')),
          const SizedBox(height: 16),
          Text(SoleraL10n.t('huer.certificacion_ecologica'), style: estilo),
          campoTexto(_organismo, SoleraL10n.t('huer.organismo_control'),
              ayuda: SoleraL10n.t('huer.organismo_control_ayuda')),
          campoTexto(
              _codigoOperador, SoleraL10n.t('huer.codigo_operador_ecologico')),
          const SizedBox(height: 16),
          Text(SoleraL10n.t('huer.asesor'), style: estilo),
          campoTexto(_asesor, SoleraL10n.t('huer.asesor_nombre')),
          campoTexto(_ropo, SoleraL10n.t('huer.asesor_ropo')),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: _guardar, child: Text(SoleraL10n.t('guardar'))),
        ],
      ),
    );
  }
}
