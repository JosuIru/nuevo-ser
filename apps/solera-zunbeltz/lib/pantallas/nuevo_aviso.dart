import 'package:flutter/material.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/aviso_campo.dart';
import '../modelos/finca.dart';
import '../utiles/estilo_aviso.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/relleno_seguro.dart';

/// Dar un aviso al espacio: algo que pasa en el ganado o las instalaciones,
/// del seguimiento de un proyecto, o una noticia. Si es una alarma, al resto
/// le salta una notificación en cuanto sincroniza.
class NuevoAviso extends StatefulWidget {
  const NuevoAviso({super.key, this.categoria, this.fincaId, this.puntoId});

  final String? categoria;
  final int? fincaId;
  final int? puntoId;

  @override
  State<NuevoAviso> createState() => _NuevoAvisoState();
}

class _NuevoAvisoState extends State<NuevoAviso> {
  final _bd = BaseDatosSoleraZunbeltz();
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  List<Finca> _fincas = const [];
  late String _categoria = widget.categoria ?? categoriaAvisoInstalaciones;
  late int? _fincaId = widget.fincaId;
  bool _alarma = false;

  @override
  void initState() {
    super.initState();
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
    await _bd.guardarAviso(AvisoCampo(
      autorUid: sesionEspacio.value?.persona.uid ?? '',
      fincaId: _fincaId,
      puntoId: _fincaId == widget.fincaId ? widget.puntoId : null,
      categoria: _categoria,
      gravedad: _alarma ? gravedadAlarma : gravedadAviso,
      titulo: _titulo.text.trim(),
      descripcion: _descripcion.text.trim(),
      fechaMs: DateTime.now().millisecondsSinceEpoch,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.avisoGuardado)));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(textos.avisoNuevo)),
      body: CuerpoResponsivo(
        child: ListView(
          padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
          children: [
            Text(textos.avisoCategoria,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final categoria in categoriasAviso)
                  ChoiceChip(
                    avatar: Icon(iconoCategoriaAviso(categoria), size: 18),
                    label: Text(etiquetaCategoriaAviso(categoria, textos)),
                    selected: _categoria == categoria,
                    onSelected: (_) => setState(() => _categoria = categoria),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titulo,
              decoration: InputDecoration(labelText: textos.avisoTitulo),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descripcion,
              maxLines: 3,
              decoration: InputDecoration(labelText: textos.avisoDescripcion),
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
              secondary: Icon(Icons.notification_important_outlined,
                  color: _alarma ? colorSenalZunbeltz : null),
              title: Text(textos.avisoEsAlarma),
              value: _alarma,
              onChanged: (valor) => setState(() => _alarma = valor),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.campaign_outlined),
              label: Text(textos.comunGuardar),
            ),
          ],
        ),
      ),
    );
  }
}
