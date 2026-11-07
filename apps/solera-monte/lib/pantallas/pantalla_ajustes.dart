import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SelectorIdioma, SoleraL10n, TituloBloqueSolera;

import '../datos/base_datos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/monte.dart';
import '../utiles/textos_monte.dart';
import 'hoja_formulario.dart';
import 'identificar_con_ia.dart';
import 'pantalla_documentos.dart';
import 'pantalla_economia.dart';

class PantallaAjustes extends StatelessWidget {
  const PantallaAjustes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SelectorIdioma(),
          TituloBloqueSolera(SoleraL10n.t('mont.monte')),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.landscape_outlined),
            title: Text(SoleraL10n.t('mont.datos_monte')),
            subtitle: Text(SoleraL10n.t('mont.datos_monte_ayuda')),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaDatosMonte())),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(SoleraL10n.t('mont.documentos')),
            subtitle: Text(SoleraL10n.t('mont.documentos_ayuda')),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaDocumentos())),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.euro_outlined),
            title: Text(SoleraL10n.t('mont.ingresos_y_gastos')),
            subtitle: Text(SoleraL10n.t('mont.ingresos_y_gastos_ayuda')),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaEconomia())),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.auto_awesome_outlined),
            title: Text(SoleraL10n.t('mont.inteligencia_artificial')),
            subtitle: Text(SoleraL10n.t('mont.ia_que_hace')),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => pantallaClaveMonte())),
          ),
        ],
      ),
    );
  }
}

/// Datos del monte: titular, figura, comunidad autónoma, instrumento de
/// gestión, certificación y época de peligro de incendios.
class PantallaDatosMonte extends StatefulWidget {
  const PantallaDatosMonte({super.key});

  @override
  State<PantallaDatosMonte> createState() => _PantallaDatosMonteState();
}

class _PantallaDatosMonteState extends State<PantallaDatosMonte> {
  final _nombre = TextEditingController();
  final _titular = TextEditingController();
  final _nif = TextEditingController();
  final _comunidad = TextEditingController();
  final _municipio = TextEditingController();
  final _catalogo = TextEditingController();
  final _referencia = TextEditingController();
  final _certificado = TextEditingController();
  final _tecnico = TextEditingController();
  final _notas = TextEditingController();
  Monte _monte = Monte();
  String _figura = 'particular';
  String _instrumento = 'ninguno';
  String _certificacion = 'ninguna';
  DateTime? _finVigencia;
  int? _mesPeligro;
  int? _diaPeligro;
  bool _cargado = false;

  List<TextEditingController> get _controladores => [
        _nombre,
        _titular,
        _nif,
        _comunidad,
        _municipio,
        _catalogo,
        _referencia,
        _certificado,
        _tecnico,
        _notas
      ];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    for (final controlador in _controladores) {
      controlador.dispose();
    }
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final monte = await BaseDatosSoleraMonte.instancia.obtenerMonte();
      if (!mounted) return;
      setState(() {
        _monte = monte;
        _nombre.text = monte.nombre;
        _titular.text = monte.titular;
        _nif.text = monte.nif;
        _comunidad.text = monte.comunidadAutonoma;
        _municipio.text = monte.municipio;
        _catalogo.text = monte.numeroCatalogo;
        _referencia.text = monte.referenciaInstrumento;
        _certificado.text = monte.codigoCertificado;
        _tecnico.text = monte.tecnicoForestal;
        _notas.text = monte.notas;
        _figura = monte.figura;
        _instrumento = monte.instrumentoGestion;
        _certificacion = monte.certificacion;
        _finVigencia = monte.finVigenciaInstrumentoMs == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                monte.finVigenciaInstrumentoMs!);
        _mesPeligro = monte.inicioEpocaPeligroMes;
        _diaPeligro = monte.inicioEpocaPeligroDia;
        _cargado = true;
      });
    } catch (error) {
      debugPrint('No se pudo leer el monte: $error');
    }
  }

  Future<void> _guardar() async {
    await BaseDatosSoleraMonte.instancia.guardarMonte(Monte(
      id: _monte.id,
      nombre: _nombre.text.trim(),
      titular: _titular.text.trim(),
      nif: _nif.text.trim(),
      figura: _figura,
      comunidadAutonoma: _comunidad.text.trim(),
      municipio: _municipio.text.trim(),
      numeroCatalogo: _catalogo.text.trim(),
      instrumentoGestion: _instrumento,
      referenciaInstrumento: _referencia.text.trim(),
      finVigenciaInstrumentoMs: _finVigencia?.millisecondsSinceEpoch,
      certificacion: _certificacion,
      codigoCertificado: _certificado.text.trim(),
      inicioEpocaPeligroMes: _mesPeligro,
      inicioEpocaPeligroDia: _mesPeligro == null ? null : _diaPeligro ?? 1,
      tecnicoForestal: _tecnico.text.trim(),
      notas: _notas.text.trim(),
    ));
    avisarCambioDatos();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(SoleraL10n.t('mont.guardado'))));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final meses = [
      for (var mes = 1; mes <= 12; mes++)
        (mes, DateFormat.MMMM(SoleraL10n.idioma).format(DateTime(2026, mes)))
    ];
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('mont.datos_monte'))),
      body: !_cargado
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                campoTexto(_nombre, SoleraL10n.t('mont.nombre_monte')),
                campoTexto(_titular, SoleraL10n.t('mont.titular'),
                    ayuda: SoleraL10n.t('mont.titular_ayuda')),
                campoTexto(_nif, SoleraL10n.t('mont.nif')),
                etiquetaGrupo(context, SoleraL10n.t('mont.figura')),
                selectorChips(
                    opciones: figurasMonte,
                    valor: _figura,
                    nombre: nombreFigura,
                    alCambiar: (valor) => setState(() => _figura = valor)),
                campoTexto(_comunidad, SoleraL10n.t('mont.comunidad_autonoma')),
                campoTexto(_municipio, SoleraL10n.t('mont.municipio')),
                campoTexto(_catalogo, SoleraL10n.t('mont.numero_catalogo'),
                    ayuda: SoleraL10n.t('mont.numero_catalogo_ayuda')),
                etiquetaGrupo(
                    context, SoleraL10n.t('mont.instrumento_gestion')),
                selectorChips(
                    opciones: tiposInstrumentoGestion,
                    valor: _instrumento,
                    nombre: nombreInstrumento,
                    alCambiar: (valor) => setState(() => _instrumento = valor)),
                if (_instrumento != 'ninguno') ...[
                  campoTexto(
                      _referencia, SoleraL10n.t('mont.referencia_instrumento')),
                  selectorFecha(context,
                      etiqueta: SoleraL10n.t('mont.vigente_hasta'),
                      fecha: _finVigencia,
                      alCambiar: (valor) =>
                          setState(() => _finVigencia = valor),
                      alQuitar: () => setState(() => _finVigencia = null)),
                ],
                textoAviso(context, SoleraL10n.t('mont.instrumento_tecnico'),
                    grave: false),
                etiquetaGrupo(context, SoleraL10n.t('mont.certificacion')),
                selectorChips(
                    opciones: sistemasCertificacion,
                    valor: _certificacion,
                    nombre: nombreCertificacion,
                    alCambiar: (valor) =>
                        setState(() => _certificacion = valor)),
                if (_certificacion != 'ninguna')
                  campoTexto(
                      _certificado, SoleraL10n.t('mont.codigo_certificado')),
                etiquetaGrupo(context, SoleraL10n.t('mont.epoca_peligro')),
                Text(SoleraL10n.t('mont.epoca_peligro_ca'),
                    style: Theme.of(context).textTheme.bodySmall),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: _mesPeligro,
                        decoration: InputDecoration(
                            labelText: SoleraL10n.t('mont.mes')),
                        items: [
                          DropdownMenuItem<int?>(
                              value: null,
                              child: Text(SoleraL10n.t('mont.sin_apuntar'))),
                          for (final (mes, texto) in meses)
                            DropdownMenuItem<int?>(
                                value: mes, child: Text(texto)),
                        ],
                        onChanged: (valor) =>
                            setState(() => _mesPeligro = valor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _diaPeligro ?? 1,
                        decoration: InputDecoration(
                            labelText: SoleraL10n.t('mont.dia')),
                        items: [
                          for (var dia = 1; dia <= 31; dia++)
                            DropdownMenuItem<int>(
                                value: dia, child: Text('$dia')),
                        ],
                        onChanged: _mesPeligro == null
                            ? null
                            : (valor) => setState(() => _diaPeligro = valor),
                      ),
                    ),
                  ],
                ),
                campoTexto(_tecnico, SoleraL10n.t('mont.tecnico_forestal')),
                campoTexto(_notas, SoleraL10n.t('mont.notas'), lineas: 2),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: _guardar, child: Text(SoleraL10n.t('guardar'))),
              ],
            ),
    );
  }
}
