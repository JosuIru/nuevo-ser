import 'package:flutter/material.dart';

import '../datos/base_datos.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/agenda.dart';
import '../modelos/calculo_transformacion.dart';
import '../modelos/indicadores_seguimiento.dart';
import '../modelos/proyecto_test.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/relleno_seguro.dart';

/// Calculadora de transformación de un proyecto: de un animal de X kg a kg
/// de producto, ingreso, costes y margen, con caminos guardados para
/// compararlos. Los rendimientos de referencia los pone coordinación.
class PantallaCalculadora extends StatefulWidget {
  const PantallaCalculadora({super.key, required this.proyecto});

  final ProyectoTest proyecto;

  @override
  State<PantallaCalculadora> createState() => _PantallaCalculadoraState();
}

class _PantallaCalculadoraState extends State<PantallaCalculadora> {
  final _bd = BaseDatosSoleraZunbeltz();
  final _pesoVivo = TextEditingController();
  final _animales = TextEditingController(text: '1');
  final _rendimientoCanal = TextEditingController();
  final _rendimientoProducto = TextEditingController(text: '100');
  final _precioKg = TextEditingController();
  final _costeSacrificio = TextEditingController();
  final _costeTransformacion = TextEditingController();
  final _otrosCostes = TextEditingController();

  List<RendimientoReferencia> _referencias = const [];
  List<EscenarioTransformacion> _escenarios = const [];
  int? _referenciaElegida;

  List<TextEditingController> get _campos => [
        _pesoVivo,
        _animales,
        _rendimientoCanal,
        _rendimientoProducto,
        _precioKg,
        _costeSacrificio,
        _costeTransformacion,
        _otrosCostes,
      ];

  bool get _puedeGuardar => politicaEspacioActual.puedeRegistrarEnProyecto(
      personaUidProyecto: widget.proyecto.personaUid,
      cerrado: widget.proyecto.cerrado);

  @override
  void initState() {
    super.initState();
    for (final campo in _campos) {
      campo.addListener(_recalcular);
    }
    _cargar();
  }

  @override
  void dispose() {
    for (final campo in _campos) {
      campo.dispose();
    }
    super.dispose();
  }

  void _recalcular() => setState(() {});

  Future<void> _cargar() async {
    final referencias = await _bd.listarRendimientos();
    final escenarios = widget.proyecto.id == null
        ? const <EscenarioTransformacion>[]
        : await _bd.listarEscenarios(widget.proyecto.id!);
    if (!mounted) return;
    setState(() {
      _referencias = referencias;
      _escenarios = escenarios;
    });
  }

  double _decimal(TextEditingController campo) =>
      double.tryParse(campo.text.trim().replaceAll(',', '.')) ?? 0;

  int _centimos(TextEditingController campo) => (_decimal(campo) * 100).round();

  CalculoTransformacion get _calculo => CalculoTransformacion(
        pesoVivoKg: _decimal(_pesoVivo),
        animales: _decimal(_animales).round().clamp(1, 100000),
        rendimientoCanalPorcentaje: _decimal(_rendimientoCanal),
        rendimientoProductoPorcentaje: _decimal(_rendimientoProducto),
        precioKgCentimos: _centimos(_precioKg),
        costeSacrificioCentimos: _centimos(_costeSacrificio),
        costeTransformacionKgCentimos: _centimos(_costeTransformacion),
        otrosCostesCentimos: _centimos(_otrosCostes),
      );

  String _numero(double valor) => valor
      .toStringAsFixed(1)
      .replaceAll('.', ',')
      .replaceAll(RegExp(r',0$'), '');

  String _texto(double valor) => valor == valor.roundToDouble()
      ? valor.toStringAsFixed(0)
      : valor.toString();

  void _aplicarReferencia(int? indice) {
    setState(() => _referenciaElegida = indice);
    if (indice == null) return;
    final referencia = _referencias[indice];
    _rendimientoCanal.text = _texto(referencia.rendimientoCanal);
    _rendimientoProducto.text = _texto(referencia.rendimientoProducto);
  }

  Future<void> _guardarEscenario() async {
    final textos = AppLocalizations.of(context);
    final nombre = TextEditingController();
    final aceptado = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text(textos.calculadoraGuardar),
        content: TextField(
          controller: nombre,
          autofocus: true,
          decoration:
              InputDecoration(labelText: textos.calculadoraNombreEscenario),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(contexto, false),
              child: Text(textos.comunCancelar)),
          FilledButton(
              onPressed: () => Navigator.pop(contexto, true),
              child: Text(textos.comunGuardar)),
        ],
      ),
    );
    if (aceptado != true || widget.proyecto.id == null) return;
    final calculo = _calculo;
    await _bd.guardarEscenario(EscenarioTransformacion(
      proyectoId: widget.proyecto.id!,
      nombre: nombre.text.trim(),
      pesoVivoKg: calculo.pesoVivoKg,
      animales: calculo.animales,
      rendimientoCanal: calculo.rendimientoCanalPorcentaje,
      rendimientoProducto: calculo.rendimientoProductoPorcentaje,
      precioKgCentimos: calculo.precioKgCentimos,
      costeSacrificioCentimos: calculo.costeSacrificioCentimos,
      costeTransformacionKgCentimos: calculo.costeTransformacionKgCentimos,
      otrosCostesCentimos: calculo.otrosCostesCentimos,
      fechaMs: DateTime.now().millisecondsSinceEpoch,
    ));
    await _cargar();
  }

  Widget _campo(TextEditingController controlador, String etiqueta) => SizedBox(
        width: 260,
        child: TextField(
          controller: controlador,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: etiqueta),
        ),
      );

  Widget _fila(String etiqueta, String valor, {bool destacado = false}) {
    final estilo = destacado
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(child: Text(etiqueta, style: estilo)),
        Text(valor, style: estilo),
      ]),
    );
  }

  Widget _resultados(CalculoTransformacion calculo, AppLocalizations textos) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _fila(textos.calculadoraKgCanal, '${_numero(calculo.kgCanal)} kg'),
        _fila(
            textos.calculadoraKgProducto, '${_numero(calculo.kgProducto)} kg'),
        _fila(textos.calculadoraIngreso,
            '${eurosDesdeCentimos(calculo.ingresoCentimos)} €'),
        _fila(textos.calculadoraCostes,
            '−${eurosDesdeCentimos(calculo.costesCentimos)} €'),
        const Divider(),
        _fila(textos.calculadoraMargen,
            '${eurosDesdeCentimos(calculo.margenCentimos)} €',
            destacado: true),
        _fila(textos.calculadoraMargenKgVivo,
            '${eurosDesdeCentimos(calculo.margenPorKgVivoCentimos)} €/kg'),
      ]);

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final calculo = _calculo;
    return Scaffold(
      appBar: AppBar(title: Text(textos.calculadoraTitulo)),
      body: CuerpoResponsivo(
        child: ListView(
          padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
          children: [
            Text(textos.calculadoraIntro),
            const SizedBox(height: 16),
            if (_referencias.isEmpty)
              Text(textos.calculadoraSinReferencias,
                  style: Theme.of(context).textTheme.bodySmall)
            else
              DropdownButtonFormField<int?>(
                isExpanded: true,
                initialValue: _referenciaElegida,
                decoration:
                    InputDecoration(labelText: textos.calculadoraReferencia),
                items: [
                  DropdownMenuItem(
                      value: null, child: Text(textos.calculadoraNinguna)),
                  for (var indice = 0; indice < _referencias.length; indice++)
                    DropdownMenuItem(
                      value: indice,
                      child: Text(
                          '${_referencias[indice].nombre} · ${_texto(_referencias[indice].rendimientoCanal)} % / ${_texto(_referencias[indice].rendimientoProducto)} %'),
                    ),
                ],
                onChanged: _aplicarReferencia,
              ),
            const SizedBox(height: 12),
            Wrap(spacing: 16, runSpacing: 8, children: [
              _campo(_pesoVivo, textos.calculadoraPesoVivo),
              _campo(_animales, textos.calculadoraAnimales),
              _campo(_rendimientoCanal, textos.calculadoraRendimientoCanal),
              _campo(
                  _rendimientoProducto, textos.calculadoraRendimientoProducto),
              _campo(_precioKg, textos.calculadoraPrecioKg),
              _campo(_costeSacrificio, textos.calculadoraCosteSacrificio),
              _campo(
                  _costeTransformacion, textos.calculadoraCosteTransformacion),
              _campo(_otrosCostes, textos.calculadoraOtrosCostes),
            ]),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: _resultados(calculo, textos),
              ),
            ),
            Text(textos.calculadoraOrientativo,
                style: Theme.of(context).textTheme.bodySmall),
            if (_puedeGuardar) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: calculo.kgProducto > 0 ? _guardarEscenario : null,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: Text(textos.calculadoraGuardar),
                ),
              ),
            ],
            if (_escenarios.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(textos.calculadoraEscenarios,
                  style: Theme.of(context).textTheme.titleMedium),
              for (final escenario in _escenarios)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(escenario.nombre,
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                          if (_puedeGuardar && escenario.id != null)
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                await _bd.borrarEscenario(escenario.id!);
                                await _cargar();
                              },
                            ),
                        ]),
                        Text(
                            '${_numero(escenario.pesoVivoKg)} kg × ${escenario.animales} · ${_texto(escenario.rendimientoCanal)} % / ${_texto(escenario.rendimientoProducto)} % · ${eurosDesdeCentimos(escenario.precioKgCentimos)} €/kg',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 6),
                        _resultados(escenario.calculo, textos),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
