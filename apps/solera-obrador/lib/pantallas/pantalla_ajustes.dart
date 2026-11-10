import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show
        PantallaClaveAnthropic, SelectorIdioma, SoleraL10n, separarCampoSolera;
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show PantallaEstadoActualizaciones, configActualizacionesMonorepo;

import '../datos/base_datos.dart';
import '../estado/clave_anthropic_obrador.dart';
import '../modelos/titular.dart';
import 'pantalla_documentos.dart';
import 'pantalla_ayuda.dart';
import 'pantalla_economia.dart';

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  final _controladorNombre = TextEditingController();
  final _controladorNif = TextEditingController();
  final _controladorRegistro = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final titular = await BaseDatosSoleraObrador.instancia.obtenerTitular();
      if (!mounted) return;
      _controladorNombre.text = titular.nombre;
      _controladorNif.text = titular.nif;
      _controladorRegistro.text = titular.registroSanitario;
    } catch (error) {
      debugPrint('No se pudo leer el titular: $error');
    }
  }

  Future<void> _guardar() async {
    await BaseDatosSoleraObrador.instancia.guardarTitular(Titular(
      nombre: _controladorNombre.text.trim(),
      nif: _controladorNif.text.trim(),
      registroSanitario: _controladorRegistro.text.trim(),
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(SoleraL10n.t('obra.guardado'))));
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorNif.dispose();
    _controladorRegistro.dispose();
    super.dispose();
  }

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
            title: Text(SoleraL10n.t('obra.documentos')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaDocumentos())),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.euro_outlined),
            title: Text(SoleraL10n.t('obra.ingresos_y_gastos')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaEconomia())),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.auto_awesome_outlined),
            title: Text(SoleraL10n.t('obra.inteligencia_artificial')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PantallaClaveAnthropic(
                          estado: estadoClaveObrador,
                          nombreApp: 'Larrea Obrador',
                          queIdentifica: SoleraL10n.t('obra.ia_que_hace'),
                        ))),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.system_update),
            title: Text(SoleraL10n.t('comprobar_actualizaciones')),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PantallaEstadoActualizaciones(
                          config:
                              configActualizacionesMonorepo('solera-obrador'),
                          nombreApp: 'Larrea Obrador',
                        ))),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.help_outline),
            title: Text(SoleraL10n.t('obra.ayuda')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaAyuda())),
          ),
          const SelectorIdioma(),
          const SizedBox(height: 24),
          Text(SoleraL10n.t('obra.titular'),
              style: Theme.of(context).textTheme.titleMedium),
          separarCampoSolera(TextField(
            controller: _controladorNombre,
            decoration:
                InputDecoration(labelText: SoleraL10n.t('obra.nombre_titular')),
          )),
          separarCampoSolera(TextField(
            controller: _controladorNif,
            decoration: const InputDecoration(labelText: 'NIF'),
          )),
          TextField(
            controller: _controladorRegistro,
            decoration: InputDecoration(
                labelText: SoleraL10n.t('obra.registro_sanitario')),
          ),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: _guardar, child: Text(SoleraL10n.t('guardar'))),
        ],
      ),
    );
  }
}
