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
            _campo(_regepa, 'N.º REGEPA', hint: 'Registro General de la Producción Agrícola'),
            _campo(_telefono, 'Teléfono', tipo: TextInputType.phone),
            _campo(_email, 'Email', tipo: TextInputType.emailAddress),
            SizedBox(height: 16),
            _Cabecera('Asesor (si aplica)'),
            _campo(_nombreAsesor, 'Nombre del asesor'),
            _campo(_nifAsesor, 'NIF del asesor'),
            _campo(_registroAsesor, 'N.º de registro del asesor', hint: 'ROPO/equivalente'),
            SizedBox(height: 16),
            _Cabecera('Aplicador'),
            _campo(_nombreAplicador, 'Nombre del aplicador'),
            _campo(_nifAplicador, 'NIF del aplicador',
                hint: 'Puede ser distinto del titular'),
            _campo(_carnetAplicador, 'N.º de carnet de aplicador'),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _nivelCarnet.isEmpty ? null : _nivelCarnet,
              decoration: InputDecoration(
                labelText: 'Nivel del carnet de aplicador',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'basico', child: Text('Básico')),
                DropdownMenuItem(value: 'cualificado', child: Text('Cualificado')),
                DropdownMenuItem(value: 'fumigador', child: Text('Fumigador')),
                DropdownMenuItem(value: 'piloto', child: Text('Piloto aplicador')),
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
