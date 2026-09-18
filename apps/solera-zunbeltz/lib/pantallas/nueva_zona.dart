import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/finca.dart';
import '../modelos/zona_finca.dart';
import '../utiles/geodesia.dart';
import 'widgets/cuerpo_responsivo.dart';

/// Alta de una zona a partir del trazado dibujado en el mapa. Llega con los
/// vértices ya marcados: aquí solo se le pone nombre, tipo y estado.
///
/// La superficie del trazado se muestra pero no se edita (la calcula la
/// app). La oficial de SIGPAC sí se teclea, y manda sobre la calculada.
class NuevaZona extends StatefulWidget {
  const NuevaZona({
    super.key,
    required this.fincas,
    required this.vertices,
    this.fincaIdInicial,
  });

  final List<Finca> fincas;
  final List<LatLng> vertices;
  final int? fincaIdInicial;

  @override
  State<NuevaZona> createState() => _NuevaZonaState();
}

class _NuevaZonaState extends State<NuevaZona> {
  final _bd = BaseDatosSoleraZunbeltz();
  final _nombre = TextEditingController();
  final _notas = TextEditingController();
  final _recintoSigpac = TextEditingController();
  final _superficieOficial = TextEditingController();

  late int? _fincaId;
  String _tipo = tipoZonaPorDefecto;
  String _estado = estadoZonaPorDefecto;
  List<String> _fotos = const [];
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _fincaId = widget.fincaIdInicial ??
        (widget.fincas.isNotEmpty ? widget.fincas.first.id : null);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _notas.dispose();
    _recintoSigpac.dispose();
    _superficieOficial.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final fincaId = _fincaId;
    if (fincaId == null || _guardando) return;
    setState(() => _guardando = true);

    final oficial =
        double.tryParse(_superficieOficial.text.trim().replaceAll(',', '.'));
    final zona = ZonaFinca.desdeTrazado(
      fincaId: fincaId,
      vertices: widget.vertices,
      tipo: _tipo,
      nombre: _nombre.text.trim(),
      estado: _estado,
      superficieHaOficial: oficial != null && oficial > 0 ? oficial : null,
      recintoSigpac: _recintoSigpac.text.trim(),
      notas: _notas.text.trim(),
      rutasFotosJson: GestorFotos.codificar(_fotos),
      fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _bd.guardarZona(zona);
    if (!mounted) return;
    final textos = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.zonaGuardada)));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final hectareas = superficieHectareas(widget.vertices);
    final metrosPerimetro = perimetroMetros(widget.vertices);

    return Scaffold(
      appBar: AppBar(title: Text(textos.zonaNuevaTitulo)),
      body: CuerpoResponsivo(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.crop_square, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${textos.zonaSuperficie}: '
                          '${hectareas.toStringAsFixed(2)} ha '
                          '(${textos.zonaOrientativa})',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${textos.zonaPerimetro}: '
                      '${metrosPerimetro.toStringAsFixed(0)} m · '
                      '${textos.dibujoEsquinas(widget.vertices.length)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _fincaId,
              decoration: InputDecoration(labelText: textos.zonaFinca),
              items: [
                for (final finca in widget.fincas)
                  DropdownMenuItem(value: finca.id, child: Text(finca.nombre)),
              ],
              onChanged: (v) => setState(() => _fincaId = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _tipo,
              decoration: InputDecoration(labelText: textos.zonaTipo),
              items: [
                for (final tipo in tiposZona)
                  DropdownMenuItem(
                      value: tipo.codigo, child: Text(tipo.etiqueta(idioma))),
              ],
              onChanged: (v) => setState(() => _tipo = v ?? _tipo),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nombre,
              decoration: InputDecoration(labelText: textos.zonaNombre),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _estado,
              decoration: InputDecoration(labelText: textos.zonaEstado),
              items: [
                for (final estado in estadosZona)
                  DropdownMenuItem(
                      value: estado.codigo,
                      child: Text(estado.etiqueta(idioma))),
              ],
              onChanged: (v) => setState(() => _estado = v ?? _estado),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _recintoSigpac,
              decoration:
                  InputDecoration(labelText: textos.zonaRecintoSigpac),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _superficieOficial,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: textos.zonaSuperficieOficial,
                helperText: textos.zonaAvisoSuperficie,
                helperMaxLines: 4,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notas,
              maxLines: 3,
              decoration: InputDecoration(labelText: textos.zonaNotas),
            ),
            const SizedBox(height: 16),
            Text(textos.zonaFotos,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SelectorFotos(
              rutas: _fotos,
              alCambiar: (nuevas) => setState(() => _fotos = nuevas),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _fincaId == null || _guardando ? null : _guardar,
              icon: const Icon(Icons.save),
              label: Text(textos.comunGuardar),
            ),
          ],
        ),
      ),
    );
  }
}
