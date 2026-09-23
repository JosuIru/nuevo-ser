import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../l10n/app_localizations.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/constantes.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/relleno_seguro.dart';

/// Alta de un apunte económico (ingreso o gasto) de un proyecto de test.
class NuevoApunte extends StatefulWidget {
  const NuevoApunte({
    super.key,
    required this.proyectoId,
    required this.fincaId,
  });

  final int proyectoId;
  final int fincaId;

  @override
  State<NuevoApunte> createState() => _NuevoApunteState();
}

class _NuevoApunteState extends State<NuevoApunte> {
  final _bd = BaseDatosSoleraZunbeltz();
  final _concepto = TextEditingController();
  final _importe = TextEditingController();
  final _notas = TextEditingController();

  String _tipo = tipoApuntePorDefecto;
  String _categoria = categoriaGastoPorDefecto;
  int _iva = ivaPorDefecto;
  DateTime _fecha = DateTime.now();

  void _cambiarTipo(String? v) {
    if (v == null) return;
    setState(() {
      _tipo = v;
      // Al cambiar gasto/ingreso, la categoría debe ser del catálogo correcto.
      _categoria = categoriasDe(v).first.codigo;
    });
  }

  @override
  void dispose() {
    _concepto.dispose();
    _importe.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(_fecha.year - 2),
      lastDate: DateTime(_fecha.year + 1),
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final textos = AppLocalizations.of(context);
    final euros = double.tryParse(_importe.text.trim().replaceAll(',', '.'));
    if (euros == null || euros <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(textos.apuImporteObligatorio)));
      return;
    }
    await _bd.guardarApunte(ApunteEconomico(
      fincaId: widget.fincaId,
      proyectoId: widget.proyectoId,
      tipo: _tipo,
      categoria: _categoria,
      concepto: _concepto.text.trim(),
      importeCentimos: (euros * 100).round(),
      ivaPorcentaje: _iva,
      fechaMs: _fecha.millisecondsSinceEpoch,
      notas: _notas.text.trim(),
      fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.apuGuardado)));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(textos.apuNuevoTitulo)),
      body: CuerpoResponsivo(
        child: ListView(
          padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _tipo,
              decoration: InputDecoration(labelText: textos.apuTipo),
              items: [
                for (final t in tiposApunte)
                  DropdownMenuItem(
                      value: t.codigo, child: Text(t.etiqueta(idioma))),
              ],
              onChanged: _cambiarTipo,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey(_tipo),
              initialValue: _categoria,
              decoration: InputDecoration(labelText: textos.apuCategoria),
              items: [
                for (final c in categoriasDe(_tipo))
                  DropdownMenuItem(
                      value: c.codigo, child: Text(c.etiqueta(idioma))),
              ],
              onChanged: (v) => setState(() => _categoria = v ?? _categoria),
            ),
            const SizedBox(height: 12),
            TextField(
                controller: _concepto,
                decoration: InputDecoration(labelText: textos.apuConcepto)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _importe,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: textos.apuImporte, suffixText: '€'),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: DropdownButtonFormField<int>(
                    initialValue: _iva,
                    decoration: InputDecoration(labelText: textos.apuIva),
                    items: [
                      for (final v in tiposIva)
                        DropdownMenuItem(value: v, child: Text('$v %')),
                    ],
                    onChanged: (v) => setState(() => _iva = v ?? _iva),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(textos.comunFecha),
              subtitle: Text(DateFormat('dd/MM/yyyy', idioma).format(_fecha)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _elegirFecha,
            ),
            const SizedBox(height: 12),
            TextField(
                controller: _notas,
                maxLines: 2,
                decoration: InputDecoration(labelText: textos.apuNotas)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: Text(textos.comunGuardar),
            ),
          ],
        ),
      ),
    );
  }
}
