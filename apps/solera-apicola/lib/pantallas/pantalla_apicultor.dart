import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/apicultor.dart';

/// Datos del titular de la explotación apícola. Required por el libro
/// oficial REGA (RD 209/2002 + posibles desarrollos autonómicos) — sin
/// estos datos el PDF firmable que se genera en `generador_libro_rega.dart`
/// queda incompleto y no sirve para inspección.
///
/// Pantalla single-row: la BD nunca debe tener más de un apicultor en
/// v0.1; la operación es upsert idempotente.
class PantallaApicultor extends StatefulWidget {
  PantallaApicultor({super.key});

  @override
  State<PantallaApicultor> createState() => _PantallaApicultorState();
}

class _PantallaApicultorState extends State<PantallaApicultor> {
  final _claveFormulario = GlobalKey<FormState>();

  final _nif = TextEditingController();
  final _nombre = TextEditingController();
  final _direccion = TextEditingController();
  final _numeroRega = TextEditingController();
  final _numeroExplotacion = TextEditingController();
  final _telefono = TextEditingController();
  final _email = TextEditingController();

  final _nombreVeterinario = TextEditingController();
  final _nifVeterinario = TextEditingController();
  final _numeroColegiado = TextEditingController();
  final _telefonoVeterinario = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;
  Apicultor? _existente;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final apicultor = await BaseDatosSoleraApicola.instancia.obtenerApicultor();
    if (!mounted) return;
    _nif.text = apicultor.nif;
    _nombre.text = apicultor.nombre;
    _direccion.text = apicultor.direccion;
    _numeroRega.text = apicultor.numeroRega;
    _numeroExplotacion.text = apicultor.numeroExplotacionApicola;
    _telefono.text = apicultor.telefono;
    _email.text = apicultor.email;
    _nombreVeterinario.text = apicultor.nombreVeterinario;
    _nifVeterinario.text = apicultor.nifVeterinario;
    _numeroColegiado.text = apicultor.numeroColegiadoVeterinario;
    _telefonoVeterinario.text = apicultor.telefonoVeterinario;
    setState(() {
      _existente = apicultor;
      _cargando = false;
    });
  }

  @override
  void dispose() {
    for (final c in [
      _nif, _nombre, _direccion, _numeroRega, _numeroExplotacion, _telefono, _email,
      _nombreVeterinario, _nifVeterinario, _numeroColegiado, _telefonoVeterinario,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    final actualizado = Apicultor(
      id: _existente?.id,
      nif: _nif.text.trim(),
      nombre: _nombre.text.trim(),
      direccion: _direccion.text.trim(),
      numeroRega: _numeroRega.text.trim(),
      numeroExplotacionApicola: _numeroExplotacion.text.trim(),
      telefono: _telefono.text.trim(),
      email: _email.text.trim(),
      nombreVeterinario: _nombreVeterinario.text.trim(),
      nifVeterinario: _nifVeterinario.text.trim(),
      numeroColegiadoVeterinario: _numeroColegiado.text.trim(),
      telefonoVeterinario: _telefonoVeterinario.text.trim(),
    );
    await BaseDatosSoleraApicola.instancia.guardarApicultor(actualizado);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('api.titular_explotacion'))),
      body: Form(
        key: _claveFormulario,
        child: ListView(
          padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
          children: [
            _Cabecera(SoleraL10n.t('api.datos_personales')),
            _campo(_nif, '${SoleraL10n.t('api.sigla_nif')} *', validador: _obligatorio),
            _campo(_nombre, '${SoleraL10n.t('api.nombre_o_razon_social')} *', validador: _obligatorio),
            _campo(_direccion, SoleraL10n.t('api.direccion_explotacion')),
            _campo(_numeroRega, '${SoleraL10n.t('api.numero_rega')} *',
                hint: SoleraL10n.t('api.codigo_unificado_nacional'), validador: _obligatorio),
            _campo(_numeroExplotacion, SoleraL10n.t('api.numero_explotacion_apicola'),
                hint: SoleraL10n.t('api.codigo_autonomico_pista')),
            _campo(_telefono, SoleraL10n.t('api.telefono'), tipo: TextInputType.phone),
            _campo(_email, SoleraL10n.t('api.correo_electronico'), tipo: TextInputType.emailAddress),
            SizedBox(height: 16),
            _Cabecera(SoleraL10n.t('api.veterinario_asesor')),
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                SoleraL10n.t('api.veterinario_asesor_ayuda'),
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            _campo(_nombreVeterinario, SoleraL10n.t('api.nombre_veterinario')),
            _campo(_nifVeterinario, SoleraL10n.t('api.nif_veterinario')),
            _campo(_numeroColegiado, SoleraL10n.t('api.numero_colegiado')),
            _campo(_telefonoVeterinario, SoleraL10n.t('api.telefono_veterinario'),
                tipo: TextInputType.phone),
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

  String? _obligatorio(String? v) =>
      (v ?? '').trim().isEmpty ? SoleraL10n.t('api.campo_obligatorio') : null;
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
