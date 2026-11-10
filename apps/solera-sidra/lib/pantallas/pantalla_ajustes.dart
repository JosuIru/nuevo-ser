import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SelectorIdioma, SoleraL10n;
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show PantallaEstadoActualizaciones, configActualizacionesMonorepo;

import '../datos/base_datos.dart';
import '../modelos/titular.dart';
import '../utiles/textos_sidra.dart';
import 'boton_diagnostico_ia.dart' show pantallaClaveSidra;
import 'hoja_formulario.dart';
import 'pantalla_ayuda.dart';
import 'pantalla_bienvenida.dart';
import 'pantalla_documentos.dart';
import 'pantalla_economia.dart';

/// Ajustes: datos de la casa y del titular, idioma y el resto de apartados.
class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  final _nombre = TextEditingController();
  final _nif = TextEditingController();
  final _registroSanitario = TextEditingController();
  final _inscripcionDop = TextEditingController();
  final _registroExplotacion = TextEditingController();
  Titular _titular = Titular();
  String _regimen = 'general';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final titular = await BaseDatosSoleraSidra.instancia.obtenerTitular();
      if (!mounted) return;
      setState(() {
        _titular = titular;
        _nombre.text = titular.nombre;
        _nif.text = titular.nif;
        _registroSanitario.text = titular.registroSanitario;
        _inscripcionDop.text = titular.inscripcionDop;
        _registroExplotacion.text = titular.registroExplotacion;
        _regimen = titular.regimenFiscal;
      });
    } catch (error) {
      debugPrint('No se pudo leer el titular: $error');
    }
  }

  Future<void> _guardar() async {
    await BaseDatosSoleraSidra.instancia.guardarTitular(Titular(
      id: _titular.id,
      nombre: _nombre.text.trim(),
      nif: _nif.text.trim(),
      registroSanitario: _registroSanitario.text.trim(),
      inscripcionDop: _inscripcionDop.text.trim(),
      registroExplotacion: _registroExplotacion.text.trim(),
      regimenFiscal: _regimen,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(SoleraL10n.t('sidr.guardado'))));
  }

  @override
  void dispose() {
    _nombre.dispose();
    _nif.dispose();
    _registroSanitario.dispose();
    _inscripcionDop.dispose();
    _registroExplotacion.dispose();
    super.dispose();
  }

  Widget _apartado(IconData icono, String clave, Widget pantalla) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icono),
        title: Text(SoleraL10n.t(clave)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => pantalla)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _apartado(Icons.storefront_outlined, 'sidr.datos_sagardotegi',
              const PantallaBienvenida()),
          _apartado(Icons.picture_as_pdf_outlined, 'sidr.documentos',
              const PantallaDocumentos()),
          _apartado(Icons.euro_outlined, 'sidr.ingresos_y_gastos',
              const PantallaEconomia()),
          _apartado(Icons.auto_awesome_outlined, 'sidr.inteligencia_artificial',
              pantallaClaveSidra()),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: Text(SoleraL10n.t('comprobar_actualizaciones')),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PantallaEstadoActualizaciones(
                          config: configActualizacionesMonorepo('solera-sidra'),
                          nombreApp: 'Larrea Sagardoa',
                        ))),
          ),
          _apartado(Icons.help_outline, 'sidr.ayuda', const PantallaAyuda()),
          const SelectorIdioma(),
          const SizedBox(height: 24),
          Text(SoleraL10n.t('sidr.titular'),
              style: Theme.of(context).textTheme.titleMedium),
          campoTexto(_nombre, SoleraL10n.t('sidr.nombre_titular')),
          campoTexto(_nif, 'NIF'),
          campoTexto(
              _registroSanitario, SoleraL10n.t('sidr.registro_sanitario')),
          campoTexto(_inscripcionDop, SoleraL10n.t('sidr.inscripcion_dop')),
          campoTexto(
              _registroExplotacion, SoleraL10n.t('sidr.registro_explotacion')),
          campoDesplegable<String>(
            etiqueta: SoleraL10n.t('sidr.regimen_fiscal'),
            valor: _regimen,
            opciones: [
              for (final regimen in regimenesFiscales)
                (regimen, nombreValor('regimen', regimen)),
            ],
            alCambiar: (valor) => setState(() => _regimen = valor ?? _regimen),
          ),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: _guardar, child: Text(SoleraL10n.t('guardar'))),
        ],
      ),
    );
  }
}
