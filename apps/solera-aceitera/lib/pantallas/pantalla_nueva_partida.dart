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
        title: const Text('Partida registrada'),
        content: const Text('¿Pasamos a registrar la molturación de esta partida?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ahora no'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí, molturar'),
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
        appBar: AppBar(title: const Text('Nueva partida')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No hay ninguna campaña abierta. Crea una en Registros → '
              'Campañas de recolección '
              'antes de registrar partidas.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva partida de aceituna')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _kgCtrl,
                decoration: const InputDecoration(
                  labelText: 'Kg netos (báscula)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Obligatorio';
                  final n = leerNumero(v, nullSiAmbiguo: true);
                  if (n == null) return SoleraL10n.t('numero_no_valido');
                  if (n <= 0) return 'Debe ser un número > 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _albaranCtrl,
                decoration: const InputDecoration(
                  labelText: 'Número de albarán',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _defectoCtrl,
                decoration: const InputDecoration(
                  labelText: '% aceituna defectuosa',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: validarNumeroOpcional,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _catadorCtrl,
                decoration: const InputDecoration(
                  labelText: 'Catador',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _origenEsSocio,
                onChanged: (v) => setState(() => _origenEsSocio = v),
                title: const Text('Procede de socio cooperativista externo'),
                contentPadding: EdgeInsets.zero,
              ),
              if (_origenEsSocio) ...[
                const SizedBox(height: 4),
                TextFormField(
                  controller: _socioCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del socio',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Guardar partida'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
