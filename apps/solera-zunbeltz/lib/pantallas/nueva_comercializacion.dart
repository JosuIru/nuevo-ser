import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/registro_comercializacion.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/relleno_seguro.dart';
import '../utiles/numeros.dart';

/// Alta de una operación de comercialización (venta) de un proyecto de test.
class NuevaComercializacion extends StatefulWidget {
  const NuevaComercializacion({super.key, required this.proyectoId});

  final int proyectoId;

  @override
  State<NuevaComercializacion> createState() => _NuevaComercializacionState();
}

class _NuevaComercializacionState extends State<NuevaComercializacion> {
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
  final _producto = TextEditingController();
  final _cantidad = TextEditingController();
  final _unidad = TextEditingController(text: 'uds');
  final _precio = TextEditingController();
  final _ingreso = TextEditingController();

  String _canal = canalComercializacionPorDefecto;
  int _iva = ivaPorDefecto;
  DateTime _fecha = DateTime.now();

  @override
  void dispose() {
    _producto.dispose();
    _cantidad.dispose();
    _unidad.dispose();
    _precio.dispose();
    _ingreso.dispose();
    super.dispose();
  }


  Future<void> _elegirFecha() async {
    final ahora = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(ahora.year - 3),
      lastDate: DateTime(ahora.year + 1),
    );
    if (d != null) setState(() => _fecha = d);
  }

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final textos = AppLocalizations.of(context);
    if (_producto.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(textos.comProductoObligatorio)));
      return;
    }
    // Vacío vale 0; escrito y que no se entienda (o negativo), se avisa.
    final cantidad =
        _cantidad.text.trim().isEmpty
            ? 0.0
            : leerNumero(_cantidad.text, nullSiAmbiguo: true);
    final precioCent =
        _precio.text.trim().isEmpty ? 0 : centimosDesdeTexto(_precio.text);
    final ingresoEscrito = _ingreso.text.trim().isEmpty
        ? null
        : centimosDesdeTexto(_ingreso.text);
    if (cantidad == null ||
        precioCent == null ||
        cantidad < 0 ||
        precioCent < 0 ||
        (_ingreso.text.trim().isNotEmpty &&
            (ingresoEscrito == null || ingresoEscrito < 0))) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(textos.numeroNoValido)));
      return;
    }
    // Ingreso: el indicado, o cantidad × precio si se deja vacío.
    final ingresoCent = ingresoEscrito ?? (cantidad * precioCent).round();
    if (ingresoCent <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(textos.apuImporteObligatorio)));
      return;
    }
    await _bd.guardarComercializacion(RegistroComercializacion(
      proyectoId: widget.proyectoId,
      fechaMs: _fecha.millisecondsSinceEpoch,
      producto: _producto.text.trim(),
      canal: _canal,
      cantidad: cantidad,
      unidad: _unidad.text.trim().isEmpty ? 'uds' : _unidad.text.trim(),
      precioUnitarioCentimos: precioCent,
      ingresoCentimos: ingresoCent,
      ivaPorcentaje: _iva,
      fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.comGuardada)));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(textos.comNuevaTitulo)),
      body: CuerpoResponsivo(
        child: ListView(
          padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
          children: [
            TextField(
                controller: _producto,
                decoration: InputDecoration(labelText: textos.comProducto)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _canal,
              decoration: InputDecoration(labelText: textos.comCanal),
              items: [
                for (final c in canalesComercializacion)
                  DropdownMenuItem(
                      value: c.codigo, child: Text(c.etiqueta(idioma))),
              ],
              onChanged: (v) => setState(() => _canal = v ?? _canal),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cantidad,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        InputDecoration(labelText: textos.comCantidad),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _unidad,
                    decoration: InputDecoration(labelText: textos.comUnidad),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _precio,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: textos.comPrecio),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _ingreso,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: textos.comIngreso),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: _iva,
                    decoration: InputDecoration(labelText: textos.comIva),
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
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardarUnaVez,
              icon: const Icon(Icons.save),
              label: Text(textos.comunGuardar),
            ),
          ],
        ),
      ),
    );
  }
}
