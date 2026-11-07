import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/sagardotegi.dart';
import '../utiles/textos_sidra.dart';
import 'hoja_formulario.dart';

/// Primeros datos (onboarding) y, después, los datos de la casa desde
/// Ajustes: nombre, qué elabora, DOP y si abre txotx.
class PantallaBienvenida extends StatefulWidget {
  const PantallaBienvenida({super.key});

  @override
  State<PantallaBienvenida> createState() => _PantallaBienvenidaState();
}

class _PantallaBienvenidaState extends State<PantallaBienvenida> {
  final _nombre = TextEditingController();
  final _municipio = TextEditingController();
  final _territorio = TextEditingController();
  Sagardotegi _sagardotegi = Sagardotegi();
  String _perfil = 'sidra';
  String _dop = '';
  bool _abreTxotx = true;
  bool _cargada = false;

  @override
  void initState() {
    super.initState();
    BaseDatosSoleraSidra.instancia.obtenerSagardotegi().then((sagardotegi) {
      if (!mounted) return;
      setState(() {
        _sagardotegi = sagardotegi;
        _nombre.text = sagardotegi.nombre;
        _municipio.text = sagardotegi.municipio;
        _territorio.text = sagardotegi.territorio;
        _perfil = sagardotegi.perfil;
        _dop = sagardotegi.dopId;
        _abreTxotx = sagardotegi.abreTxotx;
        _cargada = true;
      });
    });
  }

  @override
  void dispose() {
    _nombre.dispose();
    _municipio.dispose();
    _territorio.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_nombre.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(SoleraL10n.t('sidr.falta_nombre'))));
      return;
    }
    await BaseDatosSoleraSidra.instancia.guardarSagardotegi(Sagardotegi(
      id: _sagardotegi.id,
      nombre: _nombre.text.trim(),
      municipio: _municipio.text.trim(),
      territorio: _territorio.text.trim(),
      perfil: _perfil,
      dopId: _dop,
      abreTxotx: _abreTxotx,
    ));
    avisarCambioDatos();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final denominaciones = [
      for (final dop in denominacionesOrigen)
        if ((_perfil != 'txakoli' && !dop.endsWith('_txakolina')) ||
            (_perfil != 'sidra' && dop.endsWith('_txakolina')))
          dop,
    ];
    if (!denominaciones.contains(_dop)) _dop = '';
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('sidr.datos_sagardotegi'))),
      body: !_cargada
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_sagardotegi.estaSinConfigurar)
                  Text(SoleraL10n.t('sidr.bienvenida_explicacion')),
                campoTexto(_nombre, SoleraL10n.t('sidr.nombre_sagardotegi')),
                campoTexto(_municipio, SoleraL10n.t('sidr.municipio')),
                campoTexto(_territorio, SoleraL10n.t('sidr.territorio')),
                const SizedBox(height: 12),
                Text(SoleraL10n.t('sidr.que_elaboras'),
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                SegmentedButton<String>(
                  segments: [
                    for (final perfil in perfilesElaboracion)
                      ButtonSegment(
                          value: perfil,
                          label: Text(nombreValor('perfil', perfil))),
                  ],
                  selected: {_perfil},
                  onSelectionChanged: (valor) =>
                      setState(() => _perfil = valor.first),
                ),
                campoDesplegable<String>(
                  key: ValueKey('dop-$_perfil'),
                  etiqueta: SoleraL10n.t('sidr.denominacion'),
                  valor: _dop,
                  opciones: [
                    ('', SoleraL10n.t('sidr.sin_dop')),
                    for (final dop in denominaciones)
                      (dop, nombreValor('dop', dop)),
                  ],
                  alCambiar: (valor) => setState(() => _dop = valor ?? ''),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _abreTxotx,
                  title: Text(SoleraL10n.t('sidr.abre_txotx')),
                  onChanged: (valor) => setState(() => _abreTxotx = valor),
                ),
                const SizedBox(height: 8),
                Text(SoleraL10n.t('sidr.aviso_no_certifica'),
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: _guardar, child: Text(SoleraL10n.t('guardar'))),
              ],
            ),
    );
  }
}
