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
      appBar: AppBar(title: Text('Titular de la explotación')),
      body: Form(
        key: _claveFormulario,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Cabecera('Datos personales'),
            _campo(_nif, 'NIF *', validador: _obligatorio('NIF')),
            _campo(_nombre, 'Nombre o razón social *', validador: _obligatorio('Nombre')),
            _campo(_direccion, 'Dirección de la explotación'),
            _campo(_numeroRega, 'N.º REGA *',
                hint: 'Código unificado nacional', validador: _obligatorio('N.º REGA')),
            _campo(_numeroExplotacion, 'N.º explotación apícola',
                hint: 'Código autonómico específico (si aplica)'),
            _campo(_telefono, 'Teléfono', tipo: TextInputType.phone),
            _campo(_email, 'Email', tipo: TextInputType.emailAddress),
            SizedBox(height: 16),
            _Cabecera('Veterinario asesor'),
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Obligatorio para tratamientos sanitarios. El número de colegiado debe constar en cualquier receta veterinaria.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            _campo(_nombreVeterinario, 'Nombre del veterinario'),
            _campo(_nifVeterinario, 'NIF del veterinario'),
            _campo(_numeroColegiado, 'N.º de colegiado'),
            _campo(_telefonoVeterinario, 'Teléfono del veterinario',
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

  String? Function(String?) _obligatorio(String campo) =>
      (v) => (v ?? '').trim().isEmpty ? '$campo obligatorio' : null;
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
