import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/tecnico.dart';
import '../utiles/etiquetas_l10n.dart';

/// Datos del ayuntamiento titular de la instancia. Required por el
/// informe municipal — sin estos datos el PDF que se genera queda
/// incompleto y no sirve para presentar a concejalía.
///
/// Pantalla single-row: la BD nunca debe tener más de un ayuntamiento
/// en v0.1; la operación es upsert idempotente.
class PantallaAyuntamiento extends StatefulWidget {
  PantallaAyuntamiento({super.key});

  @override
  State<PantallaAyuntamiento> createState() => _PantallaAyuntamientoState();
}

class _PantallaAyuntamientoState extends State<PantallaAyuntamiento> {
  final _claveFormulario = GlobalKey<FormState>();

  final _nombre = TextEditingController();
  final _cif = TextEditingController();
  final _direccion = TextEditingController();
  final _municipio = TextEditingController();
  final _provincia = TextEditingController();
  final _codigoPostal = TextEditingController();
  final _nombreConcejal = TextEditingController();
  final _concejalia = TextEditingController();
  final _email = TextEditingController();
  final _telefono = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;
  Ayuntamiento? _existente;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final ayto = await BaseDatosSoleraArbolado.instancia.obtenerAyuntamiento();
    if (!mounted) return;
    _nombre.text = ayto.nombre;
    _cif.text = ayto.cif;
    _direccion.text = ayto.direccion;
    _municipio.text = ayto.municipio;
    _provincia.text = ayto.provincia;
    _codigoPostal.text = ayto.codigoPostal;
    _nombreConcejal.text = ayto.nombreConcejal;
    _concejalia.text = ayto.concejalia;
    _email.text = ayto.email;
    _telefono.text = ayto.telefono;
    setState(() {
      _existente = ayto;
      _cargando = false;
    });
  }

  @override
  void dispose() {
    for (final c in [
      _nombre, _cif, _direccion, _municipio, _provincia, _codigoPostal,
      _nombreConcejal, _concejalia, _email, _telefono,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    final actualizado = Ayuntamiento(
      id: _existente?.id,
      nombre: _nombre.text.trim(),
      cif: _cif.text.trim(),
      direccion: _direccion.text.trim(),
      municipio: _municipio.text.trim(),
      provincia: _provincia.text.trim(),
      codigoPostal: _codigoPostal.text.trim(),
      nombreConcejal: _nombreConcejal.text.trim(),
      concejalia: _concejalia.text.trim(),
      email: _email.text.trim(),
      telefono: _telefono.text.trim(),
    );
    await BaseDatosSoleraArbolado.instancia.guardarAyuntamiento(actualizado);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('arb.ayuntamiento'))),
      body: Form(
        key: _claveFormulario,
        child: ListView(
          padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
          children: [
            _Cabecera(SoleraL10n.t('arb.datos_del_ayuntamiento')),
            _campo(_nombre, '${SoleraL10n.t('arb.nombre_del_ayuntamiento')} *',
                validador: validadorObligatorio(SoleraL10n.t('arb.nombre'))),
            _campo(_cif, '${SoleraL10n.t('arb.sigla_cif')} *',
                validador: validadorObligatorio(SoleraL10n.t('arb.sigla_cif'))),
            _campo(_municipio, '${SoleraL10n.t('arb.municipio')} *',
                validador: validadorObligatorio(SoleraL10n.t('arb.municipio'))),
            _campo(_provincia, SoleraL10n.t('arb.provincia')),
            _campo(_direccion, SoleraL10n.t('arb.direccion')),
            _campo(_codigoPostal, SoleraL10n.t('arb.codigo_postal')),
            _campo(_email, SoleraL10n.t('arb.email'), tipo: TextInputType.emailAddress),
            _campo(_telefono, SoleraL10n.t('arb.telefono'), tipo: TextInputType.phone),
            SizedBox(height: 16),
            _Cabecera(SoleraL10n.t('arb.concejalia_responsable')),
            _campo(_concejalia, SoleraL10n.t('arb.concejalia'),
                hint: SoleraL10n.t('arb.concejalia_hint')),
            _campo(_nombreConcejal, SoleraL10n.t('arb.nombre_concejal_responsable')),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
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

}

class _Cabecera extends StatelessWidget {
  final String texto;
  _Cabecera(this.texto);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(texto,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
