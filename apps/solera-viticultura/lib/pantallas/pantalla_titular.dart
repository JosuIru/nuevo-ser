import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/titular.dart';

/// Datos del titular de la explotación. Required por el libro oficial
/// de tratamientos PAC (RD 1311/2012) — sin estos datos el PDF
/// firmable que se genera en `generar_libro_pac.dart` queda
/// incompleto y no sirve para inspección.
///
/// Pantalla single-row: la BD nunca debe tener más de un titular en
/// v0.1; la operación es upsert idempotente.
class PantallaTitular extends StatefulWidget {
  PantallaTitular({super.key});

  @override
  State<PantallaTitular> createState() => _PantallaTitularState();
}

class _PantallaTitularState extends State<PantallaTitular> {
  final _claveFormulario = GlobalKey<FormState>();

  final _nif = TextEditingController();
  final _nombre = TextEditingController();
  final _direccion = TextEditingController();
  final _regepa = TextEditingController();
  final _telefono = TextEditingController();
  final _email = TextEditingController();

  final _nombreAsesor = TextEditingController();
  final _nifAsesor = TextEditingController();
  final _registroAsesor = TextEditingController();

  final _nombreAplicador = TextEditingController();
  final _nifAplicador = TextEditingController();
  final _carnetAplicador = TextEditingController();
  String _nivelCarnet = '';

  bool _cargando = true;
  bool _guardando = false;
  Titular? _existente;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final t = await BaseDatosSoleraViticultura.instancia.obtenerTitular();
    if (!mounted) return;
    _nif.text = t.nif;
    _nombre.text = t.nombre;
    _direccion.text = t.direccion;
    _regepa.text = t.numeroRegepa;
    _telefono.text = t.telefono;
    _email.text = t.email;
    _nombreAsesor.text = t.nombreAsesor;
    _nifAsesor.text = t.nifAsesor;
    _registroAsesor.text = t.numeroRegistroAsesor;
    _nombreAplicador.text = t.nombreAplicador;
    _nifAplicador.text = t.nifAplicador;
    _carnetAplicador.text = t.carnetAplicador;
    _nivelCarnet = t.nivelCarnetAplicador;
    setState(() {
      _existente = t;
      _cargando = false;
    });
  }

  @override
  void dispose() {
    for (final c in [
      _nif, _nombre, _direccion, _regepa, _telefono, _email,
      _nombreAsesor, _nifAsesor, _registroAsesor,
      _nombreAplicador, _nifAplicador, _carnetAplicador,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    final actualizado = Titular(
      id: _existente?.id,
      nif: _nif.text.trim(),
      nombre: _nombre.text.trim(),
      direccion: _direccion.text.trim(),
      numeroRegepa: _regepa.text.trim(),
      telefono: _telefono.text.trim(),
      email: _email.text.trim(),
      nombreAsesor: _nombreAsesor.text.trim(),
      nifAsesor: _nifAsesor.text.trim(),
      numeroRegistroAsesor: _registroAsesor.text.trim(),
      nombreAplicador: _nombreAplicador.text.trim(),
      nifAplicador: _nifAplicador.text.trim(),
      carnetAplicador: _carnetAplicador.text.trim(),
      nivelCarnetAplicador: _nivelCarnet,
    );
    await BaseDatosSoleraViticultura.instancia.guardarTitular(actualizado);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('viti.titular_de_la_explotacion'))),
      body: Form(
        key: _claveFormulario,
        child: ListView(
          padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
          children: [
            _Cabecera(SoleraL10n.t('viti.datos_personales')),
            _campo(_nif, SoleraL10n.t('viti.nif_obligatorio_etiqueta'), validador: _obligatorio(SoleraL10n.t('viti.nif'))),
            _campo(_nombre, SoleraL10n.t('viti.nombre_o_razon_social_obligatorio'), validador: _obligatorio(SoleraL10n.t('viti.nombre'))),
            _campo(_direccion, SoleraL10n.t('viti.direccion_de_la_explotacion')),
            _campo(_regepa, SoleraL10n.t('viti.numero_regepa'), hint: SoleraL10n.t('viti.regepa_ayuda')),
            _campo(_telefono, SoleraL10n.t('viti.telefono'), tipo: TextInputType.phone),
            _campo(_email, SoleraL10n.t('viti.email'), tipo: TextInputType.emailAddress),
            SizedBox(height: 16),
            _Cabecera(SoleraL10n.t('viti.asesor_si_aplica')),
            _campo(_nombreAsesor, SoleraL10n.t('viti.nombre_del_asesor')),
            _campo(_nifAsesor, SoleraL10n.t('viti.nif_del_asesor')),
            _campo(_registroAsesor, SoleraL10n.t('viti.numero_registro_asesor'), hint: SoleraL10n.t('viti.ropo_equivalente')),
            SizedBox(height: 16),
            _Cabecera(SoleraL10n.t('viti.aplicador')),
            _campo(_nombreAplicador, SoleraL10n.t('viti.nombre_del_aplicador')),
            _campo(_nifAplicador, SoleraL10n.t('viti.nif_del_aplicador'),
                hint: SoleraL10n.t('viti.puede_ser_distinto_del_titular')),
            _campo(_carnetAplicador, SoleraL10n.t('viti.numero_carnet_aplicador')),
            DropdownButtonFormField<String>(
              initialValue: _nivelCarnet.isEmpty ? null : _nivelCarnet,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('viti.nivel_carnet_aplicador'),
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'basico', child: Text(SoleraL10n.t('viti.carnet_basico'))),
                DropdownMenuItem(value: 'cualificado', child: Text(SoleraL10n.t('viti.carnet_cualificado'))),
                DropdownMenuItem(value: 'fumigador', child: Text(SoleraL10n.t('viti.carnet_fumigador'))),
                DropdownMenuItem(value: 'piloto', child: Text(SoleraL10n.t('viti.carnet_piloto_aplicador'))),
              ],
              onChanged: (v) => setState(() => _nivelCarnet = v ?? ''),
            ),
            SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(Icons.check),
              label: Text(SoleraL10n.t('guardar')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController controlador,
    String etiqueta, {
    String? hint,
    TextInputType? tipo,
    String? Function(String?)? validador,
  }) {
    return separarCampoSolera(
      TextFormField(
        controller: controlador,
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

  String? Function(String?) _obligatorio(String campo) =>
      (v) => (v ?? '').trim().isEmpty
          ? SoleraL10n.tf('viti.campo_obligatorio', {'campo': campo})
          : null;
}

class _Cabecera extends StatelessWidget {
  final String texto;
  _Cabecera(this.texto);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(texto, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
