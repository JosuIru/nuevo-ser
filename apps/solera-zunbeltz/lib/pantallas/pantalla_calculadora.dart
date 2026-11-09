import 'package:flutter/material.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/agenda.dart';
import '../modelos/calculo_transformacion.dart';
import '../modelos/constantes.dart';
import '../modelos/indicadores_seguimiento.dart';
import '../modelos/proyecto_test.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/relleno_seguro.dart';
import '../utiles/numeros.dart';
import 'widgets/confirmar_borrado.dart';

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
  final _nombreCamino = TextEditingController();

  /// Camino guardado que se está viendo arriba (se resalta en la lista).
  int? _caminoVisto;

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
      uidsTesterProyecto: widget.proyecto.uidsTester,
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
    _nombreCamino.dispose();
    super.dispose();
  }

  /// Al tocar una cifra, lo de arriba ya no es el camino guardado.
  void _recalcular() => setState(() => _caminoVisto = null);

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

  double _decimal(TextEditingController campo) => leerNumero(campo.text) ?? 0;

  // Euros a la española: «1.500» son mil quinientos, no 1,50.
  int _centimos(TextEditingController campo) =>
      centimosDesdeTexto(campo.text) ?? 0;

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
    if (widget.proyecto.id == null) return;
    final calculo = _calculo;
    final nombre = _nombreCamino.text.trim().isEmpty
        ? textos.simCaminoN('${_escenarios.length + 1}')
        : _nombreCamino.text.trim();
    final id = await _bd.guardarEscenario(EscenarioTransformacion(
      proyectoId: widget.proyecto.id!,
      nombre: nombre,
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
    if (mounted) setState(() => _caminoVisto = id);
  }

  /// Pone arriba las cifras de un camino guardado.
  void _verCamino(EscenarioTransformacion escenario) {
    _pesoVivo.text = _texto(escenario.pesoVivoKg).replaceAll('.', ',');
    _animales.text = '${escenario.animales}';
    _rendimientoCanal.text =
        _texto(escenario.rendimientoCanal).replaceAll('.', ',');
    _rendimientoProducto.text =
        _texto(escenario.rendimientoProducto).replaceAll('.', ',');
    String euros(int centimos) =>
        centimos == 0 ? '' : eurosDesdeCentimos(centimos);
    _precioKg.text = euros(escenario.precioKgCentimos);
    _costeSacrificio.text = euros(escenario.costeSacrificioCentimos);
    _costeTransformacion.text = euros(escenario.costeTransformacionKgCentimos);
    _otrosCostes.text = euros(escenario.otrosCostesCentimos);
    _nombreCamino.text = escenario.nombre;
    setState(() => _caminoVisto = escenario.id);
  }

  Widget _campo(TextEditingController controlador, String etiqueta) =>
      TextField(
        controller: controlador,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: etiqueta),
      );

  /// Dos campos en una fila.
  Widget _parCampos(Widget izquierdo, Widget derecho) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: izquierdo),
          const SizedBox(width: 12),
          Expanded(child: derecho),
        ]),
      );

  /// Peso vivo → canal → producto vendible, con barras proporcionales.
  Widget _embudo(CalculoTransformacion calculo, AppLocalizations textos) {
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final vivo = calculo.kgVivosTotales;
    Widget paso(String rotulo, String? detalle, double kilos, Color color) {
      final proporcion = vivo <= 0 ? 0.0 : (kilos / vivo).clamp(0.0, 1.0);
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rotulo,
                      style: estilos.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  if (detalle != null)
                    Text(detalle,
                        style: estilos.bodySmall
                            ?.copyWith(color: esquema.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('${_numero(kilos)} kg',
                style:
                    estilos.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: proporcion == 0 ? 0.01 : proporcion,
              child: Container(
                height: 18,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(5)),
              ),
            ),
          ),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(children: [
        paso(textos.simPesoVivo, null, vivo, colorCuadroSalvia),
        paso(
            textos.simCanal,
            textos.simACanal(_numero(calculo.rendimientoCanalPorcentaje)),
            calculo.kgCanal,
            colorCuadroEsmeralda),
        paso(
            textos.simProducto,
            textos
                .simSobreCanal(_numero(calculo.rendimientoProductoPorcentaje)),
            calculo.kgProducto,
            esquema.brightness == Brightness.dark
                ? esquema.primary
                : colorCuadroPino),
      ]),
    );
  }

  /// Bloque destacado con ingreso, margen y margen por kg vivo.
  Widget _resultado(CalculoTransformacion calculo, AppLocalizations textos) {
    final estilos = Theme.of(context).textTheme;
    final suave = Colors.white.withValues(alpha: 0.8);
    final oscuro = context.esquemaZunbeltz.brightness == Brightness.dark;
    Widget cifra(String rotulo, int centimos) => Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rotulo, style: estilos.bodyMedium?.copyWith(color: suave)),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text('${eurosDesdeCentimos(centimos)} €',
                  style: estilos.headlineSmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ]),
        );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: oscuro ? const Color(0xFF0E3A2B) : colorCuadroPino,
        borderRadius: bordeDestacadoZunbeltz,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          cifra(textos.calculadoraIngreso, calculo.ingresoCentimos),
          const SizedBox(width: 12),
          cifra(textos.calculadoraMargen, calculo.margenCentimos),
        ]),
        const SizedBox(height: 14),
        Text(textos.calculadoraMargenKgVivo,
            style: estilos.bodyMedium?.copyWith(color: suave)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
              '${eurosDesdeCentimos(calculo.margenPorKgVivoCentimos)} €/kg',
              style: estilos.displaySmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        if (_puedeGuardar) ...[
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
                backgroundColor: colorCuadroSalvia,
                foregroundColor: colorSobreCuadroClaro),
            onPressed: calculo.kgProducto > 0 ? _guardarEscenario : null,
            icon: const Icon(Icons.bookmark_add_outlined),
            label: Text(textos.calculadoraGuardar),
          ),
        ],
      ]),
    );
  }

  /// Los caminos guardados, con su margen por kg vivo en barras.
  Widget _caminos(AppLocalizations textos) {
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final ordenados = [..._escenarios]..sort((a, b) => b
        .calculo.margenPorKgVivoCentimos
        .compareTo(a.calculo.margenPorKgVivoCentimos));
    final mayor = ordenados
        .map((escenario) => escenario.calculo.margenPorKgVivoCentimos.abs())
        .fold(0, (a, b) => a > b ? a : b);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final escenario in ordenados)
        Builder(builder: (contexto) {
          final margen = escenario.calculo.margenPorKgVivoCentimos;
          final visto = escenario.id != null && escenario.id == _caminoVisto;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: visto ? esquema.secondaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _verCamino(escenario),
                onLongPress: !_puedeGuardar || escenario.id == null
                    ? null
                    : () async {
                        if (!await confirmarBorrado(context)) return;
                        await _bd.borrarEscenario(escenario.id!);
                        await _cargar();
                      },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(escenario.nombre,
                              style: estilos.titleMedium?.copyWith(
                                  fontWeight: visto ? FontWeight.w700 : null)),
                        ),
                        const SizedBox(width: 12),
                        Text(
                            textos.simPorKgVivo(
                                '${eurosDesdeCentimos(margen)} €'),
                            style: estilos.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: mayor == 0
                              ? 0.01
                              : (margen.abs() / mayor).clamp(0.01, 1.0),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: margen < 0
                                  ? context.coloresZunbeltz.bloqueada
                                  : visto
                                      ? (esquema.brightness == Brightness.dark
                                          ? esquema.primary
                                          : colorCuadroPino)
                                      : colorCuadroEsmeralda,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final calculo = _calculo;
    final proyecto = widget.proyecto;
    final subtitulo = [
      if (proyecto.nombre.isNotEmpty) proyecto.nombre,
      if (buscarOpcion(especiesGanado, proyecto.especie) case final especie?
          when proyecto.especie != 'varias')
        especie.etiqueta(idioma).toLowerCase(),
    ].join(' · ');
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(textos.simTitulo),
          if (subtitulo.isNotEmpty)
            Text(subtitulo,
                style: estilos.bodyMedium
                    ?.copyWith(color: esquema.onSurfaceVariant)),
        ]),
      ),
      body: CuerpoResponsivo(
        child: ListView(
          padding: rellenoSobreBarraSistema(
              context, const EdgeInsets.fromLTRB(16, 4, 16, 24)),
          children: [
            Text(textos.calculadoraIntro, style: estilos.bodyLarge),
            const SizedBox(height: 16),
            _embudo(calculo, textos),
            const SizedBox(height: 20),
            if (_referencias.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(textos.calculadoraSinReferencias,
                    style: estilos.bodySmall
                        ?.copyWith(color: esquema.onSurfaceVariant)),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<int?>(
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
              ),
            if (_puedeGuardar)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _nombreCamino,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      labelText: textos.simNombreCamino,
                      hintText: textos.simCaminoN('${_escenarios.length + 1}')),
                ),
              ),
            _parCampos(_campo(_pesoVivo, textos.calculadoraPesoVivo),
                _campo(_animales, textos.calculadoraAnimales)),
            _parCampos(
                _campo(_rendimientoCanal, textos.calculadoraRendimientoCanal),
                _campo(_rendimientoProducto,
                    textos.calculadoraRendimientoProducto)),
            _parCampos(_campo(_precioKg, textos.calculadoraPrecioKg),
                _campo(_costeSacrificio, textos.calculadoraCosteSacrificio)),
            _parCampos(
                _campo(_costeTransformacion,
                    textos.calculadoraCosteTransformacion),
                _campo(_otrosCostes, textos.calculadoraOtrosCostes)),
            const SizedBox(height: 8),
            _resultado(calculo, textos),
            if (_escenarios.isNotEmpty) ...[
              const SizedBox(height: 28),
              Text(textos.calculadoraEscenarios, style: estilos.titleLarge),
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 10),
                child: Text(textos.simTocaCamino,
                    style: estilos.bodySmall
                        ?.copyWith(color: esquema.onSurfaceVariant)),
              ),
              _caminos(textos),
            ],
            const SizedBox(height: 20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline,
                  size: 18, color: esquema.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text(textos.calculadoraOrientativo,
                    style: estilos.bodySmall
                        ?.copyWith(color: esquema.onSurfaceVariant)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
