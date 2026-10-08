import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'widgets/selector_fotos_app.dart';
import '../datos/base_datos.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/finca.dart';
import '../modelos/punto_infraestructura.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/relleno_seguro.dart';
import '../utiles/numeros.dart';

/// Alta de un punto de infraestructura. Recibe las fincas disponibles y,
/// opcionalmente, una finca y unas coordenadas iniciales (del GPS o del
/// centro del mapa).
class NuevoPunto extends StatefulWidget {
  const NuevoPunto({
    super.key,
    required this.fincas,
    this.fincaIdInicial,
    this.latitudInicial,
    this.longitudInicial,
  });

  final List<Finca> fincas;
  final int? fincaIdInicial;
  final double? latitudInicial;
  final double? longitudInicial;

  @override
  State<NuevoPunto> createState() => _NuevoPuntoState();
}

class _NuevoPuntoState extends State<NuevoPunto> {
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
  final _nombre = TextEditingController();
  final _notas = TextEditingController();
  late final TextEditingController _latitud;
  late final TextEditingController _longitud;

  late int? _fincaId;
  String _tipo = tipoPuntoPorDefecto;
  String _estado = estadoPuntoPorDefecto;
  List<String> _fotos = const [];

  @override
  void initState() {
    super.initState();
    _fincaId = widget.fincaIdInicial ??
        (widget.fincas.isNotEmpty ? widget.fincas.first.id : null);
    _latitud = TextEditingController(
        text: widget.latitudInicial?.toStringAsFixed(6) ?? '');
    _longitud = TextEditingController(
        text: widget.longitudInicial?.toStringAsFixed(6) ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _notas.dispose();
    _latitud.dispose();
    _longitud.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final fincaId = _fincaId;
    if (fincaId == null) return;
    // Sin coordenadas el punto no sale en el mapa y no se podría encontrar:
    // si se escriben, tienen que entenderse las dos y estar en rango.
    final hayCoordenadas =
        _latitud.text.trim().isNotEmpty || _longitud.text.trim().isNotEmpty;
    final latitud = leerNumero(_latitud.text);
    final longitud = leerNumero(_longitud.text);
    if (hayCoordenadas &&
        (latitud == null ||
            longitud == null ||
            latitud.abs() > 90 ||
            longitud.abs() > 180)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              AppLocalizations.of(context).puntoCoordenadasNoValidas)));
      return;
    }
    final punto = PuntoInfraestructura(
      fincaId: fincaId,
      tipo: _tipo,
      nombre: _nombre.text.trim(),
      estado: _estado,
      latitud: latitud,
      longitud: longitud,
      notas: _notas.text.trim(),
      rutasFotosJson: GestorFotos.codificar(_fotos),
      fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _bd.guardarPunto(punto);
    if (!mounted) return;
    final textos = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.puntoGuardado)));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(textos.puntoNuevoTitulo)),
      body: CuerpoResponsivo(child: ListView(
        padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
        children: [
          DropdownButtonFormField<int>(
            initialValue: _fincaId,
            decoration: InputDecoration(labelText: textos.puntoFinca),
            items: [
              for (final f in widget.fincas)
                DropdownMenuItem(value: f.id, child: Text(f.nombre)),
            ],
            onChanged: (v) => setState(() => _fincaId = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _tipo,
            decoration: InputDecoration(labelText: textos.puntoTipo),
            items: [
              for (final t in tiposPunto)
                DropdownMenuItem(value: t.codigo, child: Text(t.etiqueta(idioma))),
            ],
            onChanged: (v) => setState(() => _tipo = v ?? _tipo),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nombre,
            decoration: InputDecoration(labelText: textos.puntoNombre),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _estado,
            decoration: InputDecoration(labelText: textos.puntoEstado),
            items: [
              for (final e in estadosPunto)
                DropdownMenuItem(value: e.codigo, child: Text(e.etiqueta(idioma))),
            ],
            onChanged: (v) => setState(() => _estado = v ?? _estado),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _latitud,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(labelText: textos.puntoLatitud),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _longitud,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(labelText: textos.puntoLongitud),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notas,
            maxLines: 3,
            decoration: InputDecoration(labelText: textos.puntoNotas),
          ),
          const SizedBox(height: 16),
          Text(textos.puntoFotos, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SelectorFotosApp(
            rutas: _fotos,
            alCambiar: (nuevas) => setState(() => _fotos = nuevas),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _fincaId == null || _guardando ? null : _guardarUnaVez,
            icon: const Icon(Icons.save),
            label: Text(textos.comunGuardar),
          ),
        ],
      )),
    );
  }
}
