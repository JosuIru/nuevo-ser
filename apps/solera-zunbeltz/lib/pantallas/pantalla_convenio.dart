import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/balance_convenio.dart';
import '../modelos/constantes.dart';
import '../modelos/convenio.dart';
import '../modelos/indicadores_seguimiento.dart';
import '../modelos/proyecto_test.dart';
import '../modelos/registro_comercializacion.dart';
import 'widgets/relleno_seguro.dart';

/// El proyecto visto desde el convenio tester: balance del test y del
/// proyecto con su reparto, presupuesto previsto, fianza, acompañamiento
/// (indicadores del anexo IV) e incidencias de cumplimiento. Coordinación lo
/// lleva; la persona tester lo consulta.
class PantallaConvenio extends StatefulWidget {
  const PantallaConvenio({super.key, required this.proyecto});

  final ProyectoTest proyecto;

  @override
  State<PantallaConvenio> createState() => _PantallaConvenioState();
}

class _PantallaConvenioState extends State<PantallaConvenio> {
  final _bd = BaseDatosSoleraZunbeltz();
  late ProyectoTest _proyecto = widget.proyecto;
  List<ApunteEconomico> _apuntes = const [];
  List<RegistroComercializacion> _ventas = const [];
  List<PartidaPresupuesto> _presupuesto = const [];
  List<MovimientoFianza> _movimientos = const [];
  List<Acompanamiento> _acompanamientos = const [];
  List<IncidenciaCumplimiento> _incidencias = const [];
  bool _cargando = true;

  int get _proyectoId => widget.proyecto.id!;
  bool get _gestiona => politicaEspacioActual.puedeGestionarProyectos;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final proyecto = await _bd.obtenerProyecto(_proyectoId);
    final apuntes = await _bd.listarApuntes(proyectoId: _proyectoId);
    final ventas = await _bd.listarComercializacion(proyectoId: _proyectoId);
    final presupuesto = await _bd.listarPresupuesto(_proyectoId);
    final movimientos = await _bd.listarMovimientosFianza(_proyectoId);
    final acompanamientos = await _bd.listarAcompanamientos(_proyectoId);
    final incidencias = await _bd.listarIncidencias(_proyectoId);
    if (!mounted) return;
    setState(() {
      if (proyecto != null) _proyecto = proyecto;
      _apuntes = apuntes;
      _ventas = ventas;
      _presupuesto = presupuesto;
      _movimientos = movimientos;
      _acompanamientos = acompanamientos;
      _incidencias = incidencias;
      _cargando = false;
    });
  }

  BalanceConvenio get _balance => BalanceConvenio.calcular(
      proyecto: _proyecto,
      apuntes: _apuntes,
      ventas: _ventas,
      presupuesto: _presupuesto);

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${textos.convenioTitulo} · ${_proyecto.nombre}'),
          bottom: TabBar(isScrollable: true, tabs: [
            Tab(text: textos.convenioBalance),
            Tab(text: textos.convenioPresupuesto),
            Tab(text: textos.convenioFianza),
            Tab(text: textos.convenioAcompanamiento),
            Tab(text: textos.convenioIncidencias),
          ]),
        ),
        body: _cargando
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(children: [
                _pestanaBalance(textos),
                _pestanaPresupuesto(textos),
                _pestanaFianza(textos),
                _pestanaAcompanamiento(textos),
                _pestanaIncidencias(textos),
              ]),
      ),
    );
  }

  String get _idioma => Localizations.localeOf(context).languageCode;

  String _euros(int centimos) => '${eurosDesdeCentimos(centimos)} €';

  String _fecha(int ms) => ms == 0
      ? '—'
      : DateFormat('dd/MM/yyyy', _idioma)
          .format(DateTime.fromMillisecondsSinceEpoch(ms));

  Widget _lista(List<Widget> hijos) => ListView(
        padding: rellenoSobreBarraSistema(
            context, const EdgeInsets.fromLTRB(16, 12, 16, 24)),
        children: hijos,
      );

  Widget _fila(String etiqueta, String valor, {bool destacado = false}) {
    final estilo = destacado
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text(etiqueta, style: estilo)),
        Text(valor, style: estilo),
      ]),
    );
  }

  Widget _tarjeta(List<Widget> hijos) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: hijos),
        ),
      );

  Widget _botonAnadir(String texto, VoidCallback accion) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: OutlinedButton.icon(
          onPressed: accion,
          icon: const Icon(Icons.add),
          label: Text(texto),
        ),
      );

  // ─── Balance ───

  Widget _pestanaBalance(AppLocalizations textos) {
    final balance = _balance;
    final porcentajeZunbeltz = balance.hayBeneficio
        ? _proyecto.porcentajeBeneficioZunbeltz
        : _proyecto.porcentajePerdidaZunbeltz;
    return _lista([
      Text(textos.convenioProvisional,
          style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 8),
      _tarjeta([
        _fila(textos.balanceIngresos, _euros(balance.ingresosCentimos)),
        _fila(textos.balanceGastosTest, _euros(-balance.gastosTestCentimos)),
        const Divider(),
        _fila(textos.balanceTest, _euros(balance.balanceTestCentimos),
            destacado: true),
        _fila(textos.balanceAmortizaciones,
            _euros(-balance.amortizacionesCentimos)),
        _fila(textos.balanceProyecto, _euros(balance.balanceProyectoCentimos),
            destacado: true),
      ]),
      _tarjeta([
        _fila(textos.balanceAsumeTester,
            _euros(balance.gastosAsumidosTesterCentimos)),
        _fila(textos.balanceAsumeZunbeltz,
            _euros(balance.gastosAsumidosZunbeltzCentimos)),
      ]),
      _tarjeta([
        Text(textos.balanceReparto,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(textos.balanceRepartoDetalle(
            balance.hayBeneficio
                ? textos.balanceBeneficio
                : textos.balancePerdida,
            porcentajeZunbeltz,
            100 - porcentajeZunbeltz)),
        const SizedBox(height: 6),
        _fila(
            textos.balanceParteZunbeltz, _euros(balance.parteZunbeltzCentimos)),
        _fila(textos.balanceParteTester, _euros(balance.parteTesterCentimos)),
        if (_gestiona)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _cambiarPorcentajes,
              child: Text(textos.balancePorcentajes),
            ),
          ),
      ]),
      if (balance.categoriasComparadas.isNotEmpty)
        _tarjeta([
          Text(textos.balancePrevistoReal,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Row(children: [
            const Expanded(child: SizedBox()),
            SizedBox(
                width: 90,
                child: Text(textos.balancePrevisto, textAlign: TextAlign.end)),
            SizedBox(
                width: 90,
                child: Text(textos.balanceReal, textAlign: TextAlign.end)),
          ]),
          for (final categoria in balance.categoriasComparadas)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Expanded(
                    child: Text(buscarOpcion(categoriasGasto, categoria)
                            ?.etiqueta(_idioma) ??
                        categoria)),
                SizedBox(
                    width: 90,
                    child: Text(
                        _euros(balance.previstoPorCategoria[categoria] ?? 0),
                        textAlign: TextAlign.end)),
                SizedBox(
                  width: 90,
                  child: Text(
                    _euros(balance.realPorCategoria[categoria] ?? 0),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        color: (balance.realPorCategoria[categoria] ?? 0) >
                                (balance.previstoPorCategoria[categoria] ?? 0)
                            ? colorSenalZunbeltz
                            : null),
                  ),
                ),
              ]),
            ),
        ]),
    ]);
  }

  Future<void> _cambiarPorcentajes() async {
    final textos = AppLocalizations.of(context);
    final beneficio =
        TextEditingController(text: '${_proyecto.porcentajeBeneficioZunbeltz}');
    final perdida =
        TextEditingController(text: '${_proyecto.porcentajePerdidaZunbeltz}');
    final aceptado = await _dialogo(textos.balancePorcentajes, [
      TextField(
          controller: beneficio,
          keyboardType: TextInputType.number,
          decoration:
              InputDecoration(labelText: textos.balancePorcentajeBeneficio)),
      TextField(
          controller: perdida,
          keyboardType: TextInputType.number,
          decoration:
              InputDecoration(labelText: textos.balancePorcentajePerdida)),
    ]);
    if (!aceptado) return;
    int acotar(String texto, int porDefecto) =>
        (int.tryParse(texto.trim()) ?? porDefecto).clamp(0, 100);
    await _bd.actualizarProyecto(_proyectoId, {
      'porcentaje_beneficio_zunbeltz':
          acotar(beneficio.text, _proyecto.porcentajeBeneficioZunbeltz),
      'porcentaje_perdida_zunbeltz':
          acotar(perdida.text, _proyecto.porcentajePerdidaZunbeltz),
    });
    await _cargar();
  }

  // ─── Presupuesto ───

  Widget _pestanaPresupuesto(AppLocalizations textos) {
    var total = 0;
    for (final partida in _presupuesto) {
      total += partida.importeCentimos;
    }
    return _lista([
      if (_presupuesto.isEmpty)
        Text(textos.presupuestoVacio)
      else ...[
        for (final partida in _presupuesto)
          Card(
            child: ListTile(
              title: Text(partida.concepto.isEmpty
                  ? (buscarOpcion(categoriasGasto, partida.categoria)
                          ?.etiqueta(_idioma) ??
                      partida.categoria)
                  : partida.concepto),
              subtitle: Text([
                buscarOpcion(categoriasGasto, partida.categoria)
                        ?.etiqueta(_idioma) ??
                    partida.categoria,
                buscarOpcion(asumidoPorOpciones, partida.asumidoPor)
                        ?.etiqueta(_idioma) ??
                    '',
                if (partida.esAmortizacion) textos.balanceAmortizaciones,
              ].join(' · ')),
              trailing: Text(_euros(partida.importeCentimos)),
              onLongPress: !_gestiona || partida.id == null
                  ? null
                  : () async {
                      await _bd.borrarPartidaPresupuesto(partida.id!);
                      await _cargar();
                    },
            ),
          ),
        _fila(textos.presupuestoTotal, _euros(total), destacado: true),
      ],
      if (_gestiona)
        _botonAnadir(textos.presupuestoNuevaPartida, _nuevaPartida),
    ]);
  }

  Future<void> _nuevaPartida() async {
    final textos = AppLocalizations.of(context);
    var categoria = categoriasGasto.first.codigo;
    var asumidoPor = asumidoPorDefecto(categoria);
    var esAmortizacion = false;
    final concepto = TextEditingController();
    final importe = TextEditingController();
    final aceptado = await _dialogo(
      textos.presupuestoNuevaPartida,
      const [],
      constructor: (actualizar) => [
        DropdownButtonFormField<String>(
          initialValue: categoria,
          decoration: InputDecoration(labelText: textos.apuCategoria),
          items: [
            for (final opcion in categoriasGasto)
              DropdownMenuItem(
                  value: opcion.codigo, child: Text(opcion.etiqueta(_idioma))),
          ],
          onChanged: (valor) => actualizar(() {
            categoria = valor ?? categoria;
            asumidoPor = asumidoPorDefecto(categoria);
          }),
        ),
        TextField(
            controller: concepto,
            decoration: InputDecoration(labelText: textos.convenioConcepto)),
        TextField(
            controller: importe,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: textos.convenioImporte)),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            for (final opcion in asumidoPorOpciones)
              ButtonSegment(
                  value: opcion.codigo, label: Text(opcion.etiqueta(_idioma))),
          ],
          selected: {asumidoPor},
          onSelectionChanged: (seleccion) =>
              actualizar(() => asumidoPor = seleccion.first),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: esAmortizacion,
          title: Text(textos.apuAmortizacion),
          onChanged: (valor) =>
              actualizar(() => esAmortizacion = valor ?? false),
        ),
      ],
    );
    if (!aceptado) return;
    await _bd.guardarPartidaPresupuesto(PartidaPresupuesto(
      proyectoId: _proyectoId,
      categoria: categoria,
      concepto: concepto.text.trim(),
      asumidoPor: asumidoPor,
      esAmortizacion: esAmortizacion,
      importeCentimos: _centimos(importe.text),
    ));
    await _cargar();
  }

  // ─── Fianza ───

  Widget _pestanaFianza(AppLocalizations textos) {
    final estado = EstadoFianza.calcular(_movimientos, _incidencias);
    return _lista([
      _tarjeta([
        _fila(
            textos.fianzaReferencia, _euros(_balance.fianzaReferenciaCentimos)),
        const Divider(),
        _fila(textos.fianzaDepositado, _euros(estado.depositadoCentimos)),
        _fila(textos.fianzaDevuelto, _euros(estado.devueltoCentimos)),
        _fila(textos.fianzaRetenido, _euros(estado.retenidoCentimos)),
        _fila(textos.fianzaPendiente, _euros(estado.pendienteCentimos),
            destacado: true),
      ]),
      for (final movimiento in _movimientos)
        Card(
          child: ListTile(
            title: Text(buscarOpcion(tiposMovimientoFianza, movimiento.tipo)
                    ?.etiqueta(_idioma) ??
                movimiento.tipo),
            subtitle: Text([
              _fecha(movimiento.fechaMs),
              if (movimiento.notas.isNotEmpty) movimiento.notas,
            ].join(' · ')),
            trailing: Text(_euros(movimiento.importeCentimos)),
            onLongPress: !_gestiona || movimiento.id == null
                ? null
                : () async {
                    await _bd.borrarMovimientoFianza(movimiento.id!);
                    await _cargar();
                  },
          ),
        ),
      if (_gestiona)
        _botonAnadir(textos.fianzaNuevoMovimiento, _nuevoMovimiento),
    ]);
  }

  Future<void> _nuevoMovimiento() async {
    final textos = AppLocalizations.of(context);
    var tipo = tiposMovimientoFianza.first.codigo;
    var fecha = DateTime.now();
    final importe = TextEditingController();
    final notas = TextEditingController();
    final aceptado = await _dialogo(
      textos.fianzaNuevoMovimiento,
      const [],
      constructor: (actualizar) => [
        DropdownButtonFormField<String>(
          initialValue: tipo,
          decoration: InputDecoration(labelText: textos.convenioTipo),
          items: [
            for (final opcion in tiposMovimientoFianza)
              DropdownMenuItem(
                  value: opcion.codigo, child: Text(opcion.etiqueta(_idioma))),
          ],
          onChanged: (valor) => actualizar(() => tipo = valor ?? tipo),
        ),
        TextField(
            controller: importe,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: textos.convenioImporte)),
        _selectorFecha(
            textos, fecha, (nueva) => actualizar(() => fecha = nueva)),
        TextField(
            controller: notas,
            decoration: InputDecoration(labelText: textos.convenioDescripcion)),
      ],
    );
    if (!aceptado) return;
    await _bd.guardarMovimientoFianza(MovimientoFianza(
      proyectoId: _proyectoId,
      tipo: tipo,
      importeCentimos: _centimos(importe.text),
      fechaMs: fecha.millisecondsSinceEpoch,
      notas: notas.text.trim(),
    ));
    await _cargar();
  }

  // ─── Acompañamiento ───

  Widget _pestanaAcompanamiento(AppLocalizations textos) {
    final inicio = _proyecto.fechaInicioMs == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(_proyecto.fechaInicioMs!);
    final fin = _proyecto.fechaFinMs == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(_proyecto.fechaFinMs!);
    final indicadores = IndicadoresAcompanamiento.calcular(_acompanamientos,
        inicio: inicio, fin: fin);
    Widget indicador(String texto, bool cumple) => ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(
              cumple ? Icons.check_circle : Icons.radio_button_unchecked,
              color: cumple ? colorEstadoHecha : null),
          title: Text(texto),
          trailing:
              Text(cumple ? textos.convenioCumple : textos.convenioNoCumple),
        );
    return _lista([
      _tarjeta([
        Text(textos.acompanamientoIndicadores(indicadores.meses),
            style: Theme.of(context).textTheme.titleMedium),
        indicador(
            textos.acompanamientoSoporte, indicadores.cumpleSoporteIntegral),
        indicador(textos.acompanamientoDifusion, indicadores.cumpleDifusion),
        indicador(
            textos.acompanamientoSeguimiento, indicadores.cumpleSeguimiento),
        indicador(textos.acompanamientoVenta, indicadores.cumpleVenta),
        const Divider(),
        for (final tipo in tiposAcompanamiento)
          if (indicadores.propuestasDe(tipo.codigo) > 0)
            _fila(
                tipo.etiqueta(_idioma),
                textos.acompanamientoAsistidas(
                    indicadores.asistidasDe(tipo.codigo),
                    indicadores.propuestasDe(tipo.codigo))),
      ]),
      _tarjeta([
        Text(textos.acompanamientoValoraciones,
            style: Theme.of(context).textTheme.titleMedium),
        _fila(textos.acompanamientoValoracionZunbeltz,
            _proyecto.valoracionZunbeltz?.toString() ?? '—'),
        _fila(textos.acompanamientoValoracionTester,
            _proyecto.valoracionTester?.toString() ?? '—'),
        if (_gestiona)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
                onPressed: _cambiarValoraciones,
                child: Text(textos.acompanamientoValoraciones)),
          ),
      ]),
      if (_acompanamientos.isEmpty) Text(textos.acompanamientoVacio),
      for (final actividad in _acompanamientos)
        Card(
          child: ListTile(
            title: Text(buscarOpcion(tiposAcompanamiento, actividad.tipo)
                    ?.etiqueta(_idioma) ??
                actividad.tipo),
            subtitle: Text([
              _fecha(actividad.fechaMs),
              buscarOpcion(asistenciasAcompanamiento, actividad.asistencia)
                      ?.etiqueta(_idioma) ??
                  actividad.asistencia,
              if (actividad.horas != null) '${actividad.horas} h',
              if (actividad.descripcion.isNotEmpty) actividad.descripcion,
            ].join(' · ')),
            onTap: !_gestiona || actividad.id == null
                ? null
                : () => _cambiarAsistencia(actividad),
            onLongPress: !_gestiona || actividad.id == null
                ? null
                : () async {
                    await _bd.borrarAcompanamiento(actividad.id!);
                    await _cargar();
                  },
          ),
        ),
      if (_gestiona)
        _botonAnadir(textos.acompanamientoNuevo, _nuevoAcompanamiento),
    ]);
  }

  Future<void> _cambiarAsistencia(Acompanamiento actividad) async {
    final indice = asistenciasAcompanamiento
        .indexWhere((opcion) => opcion.codigo == actividad.asistencia);
    final siguiente = asistenciasAcompanamiento[
        (indice + 1) % asistenciasAcompanamiento.length];
    await _bd.actualizarAcompanamiento(
        actividad.id!, {'asistencia': siguiente.codigo});
    await _cargar();
  }

  Future<void> _cambiarValoraciones() async {
    final textos = AppLocalizations.of(context);
    final zunbeltz = TextEditingController(
        text: _proyecto.valoracionZunbeltz?.toString() ?? '');
    final tester = TextEditingController(
        text: _proyecto.valoracionTester?.toString() ?? '');
    final aceptado = await _dialogo(textos.acompanamientoValoraciones, [
      TextField(
          controller: zunbeltz,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText: textos.acompanamientoValoracionZunbeltz)),
      TextField(
          controller: tester,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText: textos.acompanamientoValoracionTester)),
    ]);
    if (!aceptado) return;
    int? nota(String texto) => int.tryParse(texto.trim())?.clamp(0, 10);
    await _bd.actualizarProyecto(_proyectoId, {
      'valoracion_zunbeltz': nota(zunbeltz.text),
      'valoracion_tester': nota(tester.text),
    });
    await _cargar();
  }

  Future<void> _nuevoAcompanamiento() async {
    final textos = AppLocalizations.of(context);
    var tipo = tiposAcompanamiento.first.codigo;
    var asistencia = asistenciasAcompanamiento.first.codigo;
    var fecha = DateTime.now();
    final descripcion = TextEditingController();
    final horas = TextEditingController();
    final aceptado = await _dialogo(
      textos.acompanamientoNuevo,
      const [],
      constructor: (actualizar) => [
        DropdownButtonFormField<String>(
          initialValue: tipo,
          isExpanded: true,
          decoration: InputDecoration(labelText: textos.convenioTipo),
          items: [
            for (final opcion in tiposAcompanamiento)
              DropdownMenuItem(
                  value: opcion.codigo, child: Text(opcion.etiqueta(_idioma))),
          ],
          onChanged: (valor) => actualizar(() => tipo = valor ?? tipo),
        ),
        DropdownButtonFormField<String>(
          initialValue: asistencia,
          decoration:
              InputDecoration(labelText: textos.acompanamientoAsistencia),
          items: [
            for (final opcion in asistenciasAcompanamiento)
              DropdownMenuItem(
                  value: opcion.codigo, child: Text(opcion.etiqueta(_idioma))),
          ],
          onChanged: (valor) =>
              actualizar(() => asistencia = valor ?? asistencia),
        ),
        _selectorFecha(
            textos, fecha, (nueva) => actualizar(() => fecha = nueva)),
        TextField(
            controller: descripcion,
            decoration: InputDecoration(labelText: textos.convenioDescripcion)),
        TextField(
            controller: horas,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: textos.acompanamientoHoras)),
      ],
    );
    if (!aceptado) return;
    await _bd.guardarAcompanamiento(Acompanamiento(
      proyectoId: _proyectoId,
      tipo: tipo,
      asistencia: asistencia,
      fechaMs: fecha.millisecondsSinceEpoch,
      descripcion: descripcion.text.trim(),
      horas: double.tryParse(horas.text.trim().replaceAll(',', '.')),
    ));
    await _cargar();
  }

  // ─── Incidencias de cumplimiento ───

  Widget _pestanaIncidencias(AppLocalizations textos) => _lista([
        Text(textos.incidenciasPrivado,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        if (_incidencias.isEmpty) Text(textos.incidenciasVacio),
        for (final incidencia in _incidencias)
          Card(
            child: ListTile(
              leading: Icon(Icons.report_outlined,
                  color:
                      incidencia.nivel == 'leve' ? null : colorSenalZunbeltz),
              title: Text(incidencia.descripcion.isEmpty
                  ? (buscarOpcion(nivelesIncidencia, incidencia.nivel)
                          ?.etiqueta(_idioma) ??
                      incidencia.nivel)
                  : incidencia.descripcion),
              subtitle: Text([
                buscarOpcion(nivelesIncidencia, incidencia.nivel)
                        ?.etiqueta(_idioma) ??
                    incidencia.nivel,
                _fecha(incidencia.fechaMs),
                if (incidencia.retencionCentimos > 0)
                  '${textos.convenioFianza}: −${_euros(incidencia.retencionCentimos)}',
              ].join(' · ')),
              onLongPress: !_gestiona || incidencia.id == null
                  ? null
                  : () async {
                      await _bd.borrarIncidencia(incidencia.id!);
                      await _cargar();
                    },
            ),
          ),
        if (_gestiona) _botonAnadir(textos.incidenciaNueva, _nuevaIncidencia),
      ]);

  Future<void> _nuevaIncidencia() async {
    final textos = AppLocalizations.of(context);
    var nivel = nivelesIncidencia.first.codigo;
    var fecha = DateTime.now();
    final descripcion = TextEditingController();
    final retencion = TextEditingController();
    final aceptado = await _dialogo(
      textos.incidenciaNueva,
      const [],
      constructor: (actualizar) => [
        SegmentedButton<String>(
          segments: [
            for (final opcion in nivelesIncidencia)
              ButtonSegment(
                  value: opcion.codigo, label: Text(opcion.etiqueta(_idioma))),
          ],
          selected: {nivel},
          onSelectionChanged: (seleccion) =>
              actualizar(() => nivel = seleccion.first),
        ),
        TextField(
            controller: descripcion,
            maxLines: 3,
            decoration: InputDecoration(labelText: textos.convenioDescripcion)),
        _selectorFecha(
            textos, fecha, (nueva) => actualizar(() => fecha = nueva)),
        TextField(
            controller: retencion,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: textos.incidenciaRetencion)),
      ],
    );
    if (!aceptado) return;
    await _bd.guardarIncidencia(IncidenciaCumplimiento(
      proyectoId: _proyectoId,
      nivel: nivel,
      fechaMs: fecha.millisecondsSinceEpoch,
      descripcion: descripcion.text.trim(),
      retencionCentimos: _centimos(retencion.text),
    ));
    await _cargar();
  }

  // ─── Utilidades de formulario ───

  int _centimos(String texto) =>
      ((double.tryParse(texto.trim().replaceAll(',', '.')) ?? 0) * 100).round();

  Widget _selectorFecha(AppLocalizations textos, DateTime fecha,
          ValueChanged<DateTime> alCambiar) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.event_outlined),
        title: Text(textos.convenioFecha),
        subtitle: Text(_fecha(fecha.millisecondsSinceEpoch)),
        onTap: () async {
          final elegida = await showDatePicker(
            context: context,
            initialDate: fecha,
            firstDate: DateTime(fecha.year - 3),
            lastDate: DateTime(fecha.year + 3),
          );
          if (elegida != null) alCambiar(elegida);
        },
      );

  /// Diálogo de formulario. Con [constructor] los campos se reconstruyen al
  /// cambiar (desplegables, interruptores).
  Future<bool> _dialogo(
    String titulo,
    List<Widget> campos, {
    List<Widget> Function(void Function(VoidCallback) actualizar)? constructor,
  }) async {
    final textos = AppLocalizations.of(context);
    final aceptado = await showDialog<bool>(
      context: context,
      builder: (contexto) => StatefulBuilder(
        builder: (contextoInterno, actualizar) => AlertDialog(
          title: Text(titulo),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: constructor == null ? campos : constructor(actualizar),
            ),
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
      ),
    );
    return aceptado == true;
  }
}
