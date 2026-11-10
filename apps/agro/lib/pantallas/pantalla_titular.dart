import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/titular.dart';

/// Pantalla para configurar los datos del titular de la explotación.
/// Estos datos son obligatorios en el Cuaderno de Explotación
/// digital (RD 1311/2012). Aparte del NIF, el resto se rellena según
/// el caso del agricultor:
///
/// - **Asesor**: sólo si está obligado por la ley (ATRIA, parcelas
///   cerca de viviendas, cultivos del Anexo).
/// - **Aplicador**: si quien aplica fitosanitarios es distinto del
///   titular (peón, contratista de servicios). Si los aplica el
///   propio titular, los campos del aplicador se dejan vacíos.
class PantallaTitular extends StatefulWidget {
  PantallaTitular({super.key});

  @override
  State<PantallaTitular> createState() => _PantallaTitularState();
}

class _PantallaTitularState extends State<PantallaTitular> {
  final _formulario = GlobalKey<FormState>();

  final _controladorNif = TextEditingController();
  final _controladorNombre = TextEditingController();
  final _controladorDireccion = TextEditingController();
  final _controladorRegepa = TextEditingController();
  final _controladorTelefono = TextEditingController();
  final _controladorEmail = TextEditingController();

  final _controladorNombreAsesor = TextEditingController();
  final _controladorNifAsesor = TextEditingController();
  final _controladorRegistroAsesor = TextEditingController();

  final _controladorNombreAplicador = TextEditingController();
  final _controladorNifAplicador = TextEditingController();
  final _controladorCarnetAplicador = TextEditingController();

  String _nivelCarnet = '';
  bool _cargando = true;
  bool _tieneAsesor = false;
  bool _aplicadorDistinto = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final t = await BaseDatosAgro.instancia.obtenerTitular();
    if (!mounted) return;
    setState(() {
      _controladorNif.text = t.nif;
      _controladorNombre.text = t.nombre;
      _controladorDireccion.text = t.direccion;
      _controladorRegepa.text = t.numeroRegepa;
      _controladorTelefono.text = t.telefono;
      _controladorEmail.text = t.email;
      _controladorNombreAsesor.text = t.nombreAsesor;
      _controladorNifAsesor.text = t.nifAsesor;
      _controladorRegistroAsesor.text = t.numeroRegistroAsesor;
      _controladorNombreAplicador.text = t.nombreAplicador;
      _controladorNifAplicador.text = t.nifAplicador;
      _controladorCarnetAplicador.text = t.carnetAplicador;
      _nivelCarnet = t.nivelCarnetAplicador;
      _tieneAsesor = t.tieneAsesor;
      _aplicadorDistinto = t.tieneAplicadorDistinto;
      _cargando = false;
    });
  }

  @override
  void dispose() {
    _controladorNif.dispose();
    _controladorNombre.dispose();
    _controladorDireccion.dispose();
    _controladorRegepa.dispose();
    _controladorTelefono.dispose();
    _controladorEmail.dispose();
    _controladorNombreAsesor.dispose();
    _controladorNifAsesor.dispose();
    _controladorRegistroAsesor.dispose();
    _controladorNombreAplicador.dispose();
    _controladorNifAplicador.dispose();
    _controladorCarnetAplicador.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final titular = Titular(
      nif: _controladorNif.text.trim().toUpperCase(),
      nombre: _controladorNombre.text.trim(),
      direccion: _controladorDireccion.text.trim(),
      numeroRegepa: _controladorRegepa.text.trim(),
      telefono: _controladorTelefono.text.trim(),
      email: _controladorEmail.text.trim(),
      nombreAsesor: _tieneAsesor ? _controladorNombreAsesor.text.trim() : '',
      nifAsesor: _tieneAsesor ? _controladorNifAsesor.text.trim().toUpperCase() : '',
      numeroRegistroAsesor: _tieneAsesor ? _controladorRegistroAsesor.text.trim() : '',
      nombreAplicador: _aplicadorDistinto ? _controladorNombreAplicador.text.trim() : '',
      nifAplicador: _aplicadorDistinto ? _controladorNifAplicador.text.trim().toUpperCase() : '',
      carnetAplicador: _aplicadorDistinto ? _controladorCarnetAplicador.text.trim() : '',
      nivelCarnetAplicador: _aplicadorDistinto ? _nivelCarnet : '',
    );
    await BaseDatosAgro.instancia.guardarTitular(titular);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(SoleraL10n.t('agro.datos_titular_guardados'))),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('agro.datos_del_titular'))),
      body: Form(
        key: _formulario,
        child: ListView(
          padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
          children: [
            _Seccion(SoleraL10n.t('agro.titular_de_la_explotacion')),
            TextFormField(
              controller: _controladorNombre,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('agro.nombre_o_razon_social_obligatorio'),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? SoleraL10n.t('agro.requerido_por_mapa') : null,
            ),
            SizedBox(height: separacionCamposSolera),
            TextFormField(
              controller: _controladorNif,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('agro.nif_cif_obligatorio'),
                hintText: '12345678A',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? SoleraL10n.t('agro.requerido_por_mapa') : null,
            ),
            SizedBox(height: separacionCamposSolera),
            TextFormField(
              controller: _controladorDireccion,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('agro.direccion'),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SizedBox(height: separacionCamposSolera),
            TextFormField(
              controller: _controladorRegepa,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('agro.numero_regepa'),
                hintText: SoleraL10n.t('agro.regepa_nombre_completo'),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: separacionCamposSolera),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controladorTelefono,
                    decoration: InputDecoration(
                      labelText: SoleraL10n.t('agro.telefono'),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _controladorEmail,
                    decoration: InputDecoration(
                      labelText: SoleraL10n.t('agro.email'),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            SwitchListTile(
              title: Text(SoleraL10n.t('agro.obligado_asesor_agronomico')),
              subtitle: Text(SoleraL10n.t('agro.ejemplos_asesor')),
              value: _tieneAsesor,
              onChanged: (v) => setState(() => _tieneAsesor = v),
            ),
            if (_tieneAsesor) ...[
              SizedBox(height: 8),
              TextFormField(
                controller: _controladorNombreAsesor,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('agro.nombre_del_asesor'),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: separacionCamposSolera),
              TextFormField(
                controller: _controladorNifAsesor,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('agro.nif_del_asesor'),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: separacionCamposSolera),
              TextFormField(
                controller: _controladorRegistroAsesor,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('agro.numero_registro_asesor'),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            SizedBox(height: 24),
            SwitchListTile(
              title: Text(SoleraL10n.t('agro.aplicador_distinto_del_titular')),
              subtitle: Text(SoleraL10n.t('agro.ejemplos_aplicador')),
              value: _aplicadorDistinto,
              onChanged: (v) => setState(() => _aplicadorDistinto = v),
            ),
            if (_aplicadorDistinto) ...[
              SizedBox(height: 8),
              TextFormField(
                controller: _controladorNombreAplicador,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('agro.nombre_del_aplicador'),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: separacionCamposSolera),
              TextFormField(
                controller: _controladorNifAplicador,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('agro.nif_del_aplicador'),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: separacionCamposSolera),
              TextFormField(
                controller: _controladorCarnetAplicador,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('agro.numero_carnet_manipulador'),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: separacionCamposSolera),
              DropdownButtonFormField<String>(
                initialValue: _nivelCarnet.isEmpty ? null : _nivelCarnet,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('agro.nivel_del_carnet'),
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'basico', child: Text(SoleraL10n.t('agro.carnet_basico'))),
                  DropdownMenuItem(value: 'cualificado', child: Text(SoleraL10n.t('agro.carnet_cualificado'))),
                  DropdownMenuItem(value: 'fumigador', child: Text(SoleraL10n.t('agro.carnet_fumigador'))),
                  DropdownMenuItem(value: 'piloto', child: Text(SoleraL10n.t('agro.carnet_piloto_aplicador'))),
                ],
                onChanged: (v) => setState(() => _nivelCarnet = v ?? ''),
              ),
            ],
            SizedBox(height: 24),
            FilledButton.icon(
              icon: Icon(Icons.save),
              onPressed: _guardar,
              label: Text(SoleraL10n.t('guardar')),
            ),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                SoleraL10n.t('agro.titular_datos_solo_locales'),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  _Seccion(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        titulo,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
