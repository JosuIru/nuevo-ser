import 'package:flutter/material.dart';

import '../datos/base_datos.dart';
import '../modelos/campania.dart';
import '../modelos/partida_aceituna.dart';
import 'pantalla_nueva_molturacion.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Formulario de recepción de aceituna en almazara. Una partida
/// puede ser de finca propia (recoleccion_id link futuro) o de socio
/// cooperativista externo. Al guardar, ofrece pasar a registrar la
/// molturación inmediatamente.
class PantallaNuevaPartida extends StatefulWidget {
  const PantallaNuevaPartida({super.key});

  @override
  State<PantallaNuevaPartida> createState() => _PantallaNuevaPartidaState();
}

class _PantallaNuevaPartidaState extends State<PantallaNuevaPartida> {
  final _formKey = GlobalKey<FormState>();
  final _kgCtrl = TextEditingController();
  final _defectoCtrl = TextEditingController(text: '0');
  final _albaranCtrl = TextEditingController();
  final _catadorCtrl = TextEditingController();
  final _socioCtrl = TextEditingController();
  bool _origenEsSocio = false;
  Campania? _campaniaActiva;
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _resolverCampania();
  }

  Future<void> _resolverCampania() async {
    final cs = await BaseDatosSoleraAceitera().listarCampanias();
    final activa = cs.where((c) => c.estaAbierta).cast<Campania?>().firstWhere(
          (_) => true,
          orElse: () => null,
        );
    if (!mounted) return;
    setState(() {
      _campaniaActiva = activa;
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final c = _campaniaActiva;
    if (c == null) return;
    setState(() => _guardando = true);
    final partidaId = await BaseDatosSoleraAceitera().insertarPartidaAceituna(
      PartidaAceituna(
        campaniaId: c.id!,
        fechaMs: DateTime.now().millisecondsSinceEpoch,
        kgNetosBascula:
            leerNumero(_kgCtrl.text, nullSiAmbiguo: true) ?? 0,
        porcentajeAceitunaDefectuosa:
            leerNumero(_defectoCtrl.text) ?? 0,
        catador: _catadorCtrl.text.trim(),
        numeroAlbaran: _albaranCtrl.text.trim(),
        origenEsSocio: _origenEsSocio,
        socioExterno: _origenEsSocio ? _socioCtrl.text.trim() : '',
      ),
    );
    if (!mounted) return;
    final iraMolturacion = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(SoleraL10n.t('partida_registrada')),
        content: Text(SoleraL10n.t('acei.pasar_a_molturacion')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(SoleraL10n.t('acei.ahora_no')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(SoleraL10n.t('acei.si_molturar')),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (iraMolturacion == true) {
      await Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => PantallaNuevaMolturacion(partidaInicialId: partidaId),
      ));
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_campaniaActiva == null) {
      return Scaffold(
        appBar: AppBar(title: Text(SoleraL10n.t('acei.nueva_partida'))),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              SoleraL10n.t('acei.sin_campania_abierta_partidas'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('acei.nueva_partida_de_aceituna'))),
      bottomNavigationBar: BarraGuardarSolera(botones: [
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: textoOGuardando(SoleraL10n.t('guardar_partida'),
              guardando: _guardando),
        ),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: CuerpoResponsivoSolera(child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _kgCtrl,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('acei.kilos_netos_bascula'),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return SoleraL10n.t('acei.obligatorio');
                  final n = leerNumero(v, nullSiAmbiguo: true);
                  if (n == null) return SoleraL10n.t('numero_no_valido');
                  if (n <= 0) return SoleraL10n.t('mayor_que_cero');
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _albaranCtrl,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('acei.numero_de_albaran'),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? SoleraL10n.t('acei.obligatorio') : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _defectoCtrl,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('acei.porcentaje_aceituna_defectuosa'),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: validarNumeroOpcional,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _catadorCtrl,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('acei.catador'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _origenEsSocio,
                onChanged: (v) => setState(() => _origenEsSocio = v),
                title: Text(SoleraL10n.t('acei.procede_de_socio_externo')),
                contentPadding: EdgeInsets.zero,
              ),
              if (_origenEsSocio) ...[
                const SizedBox(height: 4),
                TextFormField(
                  controller: _socioCtrl,
                  decoration: InputDecoration(
                    labelText: SoleraL10n.t('acei.nombre_del_socio'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          )),
        ),
      ),
    );
  }
}
