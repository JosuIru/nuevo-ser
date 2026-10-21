import 'package:flutter/material.dart';

import '../datos/base_datos.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/finca.dart';
import '../modelos/peticion_tarea.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/selector_plantilla_tarea.dart';
import 'widgets/relleno_seguro.dart';

/// Pedir una tarea a coordinación: lo que alguien ve que hace falta.
class NuevaPeticion extends StatefulWidget {
  const NuevaPeticion({super.key, this.fincaId, this.puntoId, this.zonaId});

  final int? fincaId;
  final int? puntoId;

  /// Pieza desde cuya ficha se pide: la tarea irá sobre ella.
  final int? zonaId;

  @override
  State<NuevaPeticion> createState() => _NuevaPeticionState();
}

class _NuevaPeticionState extends State<NuevaPeticion> {
  /// Un doble toque en Guardar no debe guardar dos veces.
  bool _guardando = false;

  Future<void> _guardarUnaVez() async {
    if (_guardando) return;
    setState(() => _guardando = true);
    try {
      await _guardar();
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  final _bd = BaseDatosSoleraZunbeltz();
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  List<Finca> _fincas = const [];
  int? _fincaId;
  bool _urgente = false;
  String? _tipoPunto;

  /// Nombre del punto o la pieza sobre la que se pide, para enseñarlo.
  String _lugar = '';

  @override
  void initState() {
    super.initState();
    _fincaId = widget.fincaId;
    final puntoId = widget.puntoId;
    if (puntoId != null) {
      _bd.obtenerPunto(puntoId).then((punto) {
        if (mounted && punto != null) {
          setState(() {
            _tipoPunto = punto.tipo;
            _lugar = punto.nombre;
          });
        }
      });
    }
    final zonaId = widget.zonaId;
    if (zonaId != null) {
      _bd.obtenerZona(zonaId).then((zona) {
        if (mounted && zona != null) setState(() => _lugar = zona.nombre);
      });
    }
    _bd.listarFincas().then((fincas) {
      if (mounted) setState(() => _fincas = fincas);
    });
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final textos = AppLocalizations.of(context);
    if (_titulo.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(textos.tareaTituloObligatorio)));
      return;
    }
    await _bd.guardarPeticion(PeticionTarea(
      autorUid: sesionEspacio.value?.persona.uid ?? '',
      fincaId: _fincaId,
      puntoId: _fincaId == widget.fincaId ? widget.puntoId : null,
      zonaId: _fincaId == widget.fincaId ? widget.zonaId : null,
      titulo: _titulo.text.trim(),
      descripcion: _descripcion.text.trim(),
      urgente: _urgente,
      fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.peticionEnviada)));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(textos.peticionNueva)),
      body: CuerpoResponsivo(
        child: ListView(
          padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
          children: [
            BotonPlantillaTarea(
              tipoPunto: _tipoPunto,
              alElegir: (eleccion) {
                final (plantilla, subtipo) = eleccion;
                _titulo.text = plantilla.titulo(
                    Localizations.localeOf(context).languageCode, subtipo);
              },
            ),
            if (_lugar.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(textos.peticionSobre(_lugar),
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _titulo,
              decoration: InputDecoration(labelText: textos.peticionQue),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descripcion,
              maxLines: 3,
              decoration: InputDecoration(labelText: textos.peticionDetalles),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              isExpanded: true,
              initialValue: _fincaId,
              decoration: InputDecoration(labelText: textos.peticionFinca),
              items: [
                DropdownMenuItem(
                    value: null, child: Text(textos.peticionSinFinca)),
                for (final finca in _fincas)
                  DropdownMenuItem(value: finca.id, child: Text(finca.nombre)),
              ],
              onChanged: (fincaId) => setState(() => _fincaId = fincaId),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(textos.peticionUrgente),
              value: _urgente,
              onChanged: (valor) => setState(() => _urgente = valor),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardarUnaVez,
              icon: const Icon(Icons.send_outlined),
              label: Text(textos.comunGuardar),
            ),
          ],
        ),
      ),
    );
  }
}
