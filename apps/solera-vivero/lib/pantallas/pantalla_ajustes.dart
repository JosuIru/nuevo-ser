import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SelectorIdioma, SoleraL10n;

import '../datos/base_datos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/vivero.dart';
import 'hoja_formulario.dart';
import 'identificar_plaga.dart';
import 'pantalla_economia.dart';
import 'pantalla_documentos.dart';

/// Ajustes: datos del vivero (los de las cabeceras y la letra B del
/// pasaporte), idioma y accesos a documentos, economía, IA y ayuda.
class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  final _nombre = TextEditingController();
  final _nif = TextEditingController();
  final _ropveg = TextEditingController();
  final _comunidad = TextEditingController();
  final _municipio = TextEditingController();
  final _contacto = TextEditingController();
  final _registro = TextEditingController();
  final _asesor = TextEditingController();
  final _ropo = TextEditingController();
  bool _autorizado = false;

  List<TextEditingController> get _controladores => [
        _nombre,
        _nif,
        _ropveg,
        _comunidad,
        _municipio,
        _contacto,
        _registro,
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
      final vivero = await BaseDatosSoleraVivero.instancia.obtenerVivero();
      if (!mounted) return;
      setState(() {
        _nombre.text = vivero.nombre;
        _nif.text = vivero.nif;
        _ropveg.text = vivero.codigoRopveg;
        _comunidad.text = vivero.comunidadAutonoma;
        _municipio.text = vivero.municipio;
        _contacto.text = vivero.personaContactoFitosanitaria;
        _registro.text = vivero.registroExplotacion;
        _asesor.text = vivero.asesorNombre;
        _ropo.text = vivero.asesorNumeroRopo;
        _autorizado = vivero.autorizadoPasaporte;
      });
    } catch (error) {
      debugPrint('No se pudo leer el vivero: $error');
    }
  }

  Future<void> _guardar() async {
    await BaseDatosSoleraVivero.instancia.guardarVivero(Vivero(
      nombre: _nombre.text.trim(),
      nif: _nif.text.trim(),
      codigoRopveg: normalizarCodigoRopveg(_ropveg.text),
      autorizadoPasaporte: _autorizado,
      comunidadAutonoma: _comunidad.text.trim(),
      municipio: _municipio.text.trim(),
      personaContactoFitosanitaria: _contacto.text.trim(),
      registroExplotacion: _registro.text.trim(),
      asesorNombre: _asesor.text.trim(),
      asesorNumeroRopo: _ropo.text.trim(),
    ));
    avisarCambioDatos();
    if (!mounted) return;
    _ropveg.text = normalizarCodigoRopveg(_ropveg.text);
    avisar(context, SoleraL10n.t('vive.guardado'));
  }

  @override
  void dispose() {
    liberarControladores(_controladores);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formaRopveg =
        _ropveg.text.isEmpty || tieneFormaCodigoRopveg(_ropveg.text);
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(SoleraL10n.t('vive.documentos')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaDocumentos())),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.euro_outlined),
            title: Text(SoleraL10n.t('vive.ingresos_y_gastos')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaEconomia())),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.auto_awesome_outlined),
            title: Text(SoleraL10n.t('vive.inteligencia_artificial')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => pantallaClaveVivero())),
          ),
          const SelectorIdioma(),
          const SizedBox(height: 24),
          Text(SoleraL10n.t('vive.datos_vivero'),
              style: Theme.of(context).textTheme.titleMedium),
          campoTexto(_nombre, SoleraL10n.t('vive.nombre_vivero')),
          campoTexto(_nif, 'NIF'),
          TextField(
            controller: _ropveg,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: SoleraL10n.t('vive.codigo_ropveg'),
              helperText: SoleraL10n.t('vive.codigo_ropveg_ayuda'),
              helperMaxLines: 3,
              errorText:
                  formaRopveg ? null : SoleraL10n.t('vive.codigo_ropveg_forma'),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(SoleraL10n.t('vive.autorizado_pasaporte')),
            subtitle: Text(SoleraL10n.t('vive.autorizado_pasaporte_ayuda')),
            value: _autorizado,
            onChanged: (valor) => setState(() {
              _autorizado = valor;
            }),
          ),
          campoTexto(_contacto, SoleraL10n.t('vive.persona_contacto')),
          campoTexto(_comunidad, SoleraL10n.t('vive.comunidad_autonoma')),
          campoTexto(_municipio, SoleraL10n.t('vive.municipio')),
          campoTexto(_registro, SoleraL10n.t('vive.registro_explotacion')),
          campoTexto(_asesor, SoleraL10n.t('vive.asesor')),
          campoTexto(_ropo, SoleraL10n.t('vive.asesor_ropo')),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: _guardar, child: Text(SoleraL10n.t('guardar'))),
        ],
      ),
    );
  }
}
