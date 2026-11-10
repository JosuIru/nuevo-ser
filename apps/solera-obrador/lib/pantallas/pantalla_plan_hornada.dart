import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show DialogoConfirmacion, SoleraL10n, rellenoInferiorSeguro;

import '../datos/base_datos.dart';
import '../dominio/planificador_hornada.dart';
import '../dominio/tiempos_guia.dart';
import '../estado/cambios_datos.dart';
import '../modelos/plan_hornada.dart';
import '../modelos/receta.dart';
import '../servicios/avisos_obrador.dart';
import '../utiles/textos_obrador.dart';

/// Hora de una fase: «mié 20:20» (con el día: un plan cruza la noche).
String formatearHoraFase(DateTime hora) =>
    DateFormat('EEE HH:mm', SoleraL10n.idioma).format(hora);

/// Desde la ficha de una receta propia: si no tiene tiempos, primero se
/// ponen (y se guardan con la receta); luego, el planificador.
Future<void> abrirPlanificadorRecetaPropia(
    BuildContext context, Receta receta) async {
  final baseDatos = BaseDatosSoleraObrador.instancia;
  var plantilla = await baseDatos.obtenerTiemposReceta(receta.id!);
  if (!context.mounted) return;
  if (plantilla == null) {
    plantilla = await Navigator.push<PlantillaTiempos>(
        context,
        MaterialPageRoute(
            builder: (_) => PantallaTiemposReceta(
                nombre: receta.nombre,
                inicial: plantillaRecetaPropiaPorDefecto)));
    if (plantilla == null || !context.mounted) return;
    await baseDatos.guardarTiemposReceta(receta.id!, plantilla);
    if (!context.mounted) return;
  }
  await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => PantallaPlanificarHornada(
              nombre: receta.nombre,
              plantilla: plantilla!,
              recetaId: receta.id)));
}

/// «Quiero el pan listo a las HH:MM del día D»: elige hora y temperatura
/// de la cocina y ve las horas de cada fase.
class PantallaPlanificarHornada extends StatefulWidget {
  const PantallaPlanificarHornada({
    super.key,
    required this.nombre,
    required this.plantilla,
    this.recetaId,
    this.recetaGuiaId = '',
  });

  final String nombre;
  final PlantillaTiempos plantilla;
  final int? recetaId;
  final String recetaGuiaId;

  @override
  State<PantallaPlanificarHornada> createState() =>
      _PantallaPlanificarHornadaState();
}

class _PantallaPlanificarHornadaState extends State<PantallaPlanificarHornada> {
  late PlantillaTiempos _plantilla = widget.plantilla;
  late DateTime _listoA = _mananaALas(8);
  late double _temperaturaCocina = widget.plantilla.temperaturaReferenciaC;
  final Set<FaseHornada> _fasesEnNevera = {};
  bool _refrescoApuntado = false;
  bool _guardando = false;

  static DateTime _mananaALas(int hora) {
    final ahora = DateTime.now();
    return DateTime(ahora.year, ahora.month, ahora.day + 1, hora);
  }

  @override
  void initState() {
    super.initState();
    if (widget.plantilla.llevaMasaMadre) _usarRefrescosApuntados();
  }

  /// Con masa madre: si la persona apunta las horas hasta el pico de sus
  /// refrescos, el plan usa su media en vez de la estimación.
  Future<void> _usarRefrescosApuntados() async {
    final baseDatos = BaseDatosSoleraObrador.instancia;
    final masas = await baseDatos.listarMasasMadre();
    if (masas.isEmpty) return;
    final refrescos = await baseDatos.listarRefrescos(masas.first.id!);
    final apuntado = tiempoRefrescoApuntado([
      for (final refresco in refrescos)
        if (refresco.horasHastaPico != null) refresco.horasHastaPico!,
    ]);
    if (apuntado == null || !mounted) return;
    setState(() {
      _plantilla = conRefresco(_plantilla, apuntado);
      _refrescoApuntado = true;
    });
  }

  List<FasePlanificada> get _fases => planificarHaciaAtras(
        plantilla: _plantilla,
        listoA: _listoA,
        temperaturaCocinaC: _temperaturaCocina,
        fasesEnNevera: _fasesEnNevera,
      );

  Future<void> _elegirDia() async {
    final ahora = DateTime.now();
    final dia = await showDatePicker(
      context: context,
      initialDate: _listoA,
      firstDate: DateTime(ahora.year, ahora.month, ahora.day),
      lastDate: ahora.add(const Duration(days: 60)),
    );
    if (dia == null) return;
    setState(() {
      _listoA =
          DateTime(dia.year, dia.month, dia.day, _listoA.hour, _listoA.minute);
    });
  }

  Future<void> _elegirHora() async {
    final hora = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_listoA));
    if (hora == null) return;
    setState(() {
      _listoA = DateTime(
          _listoA.year, _listoA.month, _listoA.day, hora.hour, hora.minute);
    });
  }

  Future<void> _editarTiempos() async {
    final editada = await Navigator.push<PlantillaTiempos>(
        context,
        MaterialPageRoute(
            builder: (_) => PantallaTiemposReceta(
                nombre: widget.nombre, inicial: _plantilla)));
    if (editada == null) return;
    if (widget.recetaId != null) {
      await BaseDatosSoleraObrador.instancia
          .guardarTiemposReceta(widget.recetaId!, editada);
    }
    setState(() {
      _plantilla = editada;
      _fasesEnNevera.clear();
    });
  }

  Future<void> _guardar({required bool avisar}) async {
    setState(() => _guardando = true);
    final baseDatos = BaseDatosSoleraObrador.instancia;
    var plan = PlanHornada(
      nombre: widget.nombre,
      recetaId: widget.recetaId,
      recetaGuiaId: widget.recetaGuiaId,
      listoMs: _listoA.millisecondsSinceEpoch,
      temperaturaCocinaC: _temperaturaCocina,
      fases: _fases,
      creadoMs: DateTime.now().millisecondsSinceEpoch,
    );
    plan = plan.copiar(id: await baseDatos.guardarPlanHornada(plan));
    if (avisar && mounted) plan = await activarAvisos(context, plan);
    avisarCambioDatos();
    if (!mounted) return;
    await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => PantallaPlanHornada(planId: plan.id!)));
  }

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme;
    final fases = _fases;
    final tarde = empiezaEnElPasado(fases, DateTime.now());
    final conNevera = [
      for (final tiempo in _plantilla.fases)
        if (tiempo.alternativaNevera != null) tiempo,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('obra.plan_titulo')),
        actions: [
          IconButton(
            tooltip: SoleraL10n.t('obra.plan_editar_tiempos'),
            icon: const Icon(Icons.timer_outlined),
            onPressed: _editarTiempos,
          ),
        ],
      ),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.fromLTRB(16, 8, 16, 32)),
        children: [
          Text(widget.nombre, style: estilo.titleMedium),
          const SizedBox(height: 8),
          Text(SoleraL10n.t('obra.plan_listo_a'), style: estilo.titleSmall),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _elegirDia,
                icon: const Icon(Icons.calendar_today_outlined),
                label:
                    Text(DateFormat.MMMEd(SoleraL10n.idioma).format(_listoA)),
              ),
              OutlinedButton.icon(
                onPressed: _elegirHora,
                icon: const Icon(Icons.schedule),
                label: Text(DateFormat.Hm(SoleraL10n.idioma).format(_listoA)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
              '${SoleraL10n.t('obra.plan_temperatura_cocina')}: '
              '${formatearNumero(_temperaturaCocina, decimales: 0)} °C',
              style: estilo.titleSmall),
          Slider(
            value: _temperaturaCocina,
            min: 10,
            max: 35,
            divisions: 25,
            label: '${formatearNumero(_temperaturaCocina, decimales: 0)} °C',
            onChanged: (valor) => setState(() => _temperaturaCocina = valor),
          ),
          Text(
              SoleraL10n.tf('obra.plan_regla_temperatura', {
                'referencia': formatearNumero(_plantilla.temperaturaReferenciaC,
                    decimales: 0),
              }),
              style: estilo.bodySmall),
          if (temperaturaFueraDeLaRegla(_temperaturaCocina))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(SoleraL10n.t('obra.plan_fuera_de_rango'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          for (final tiempo in conNevera)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(SoleraL10n.tf('obra.plan_en_nevera',
                  {'fase': nombreFaseHornada(tiempo.fase)})),
              subtitle: Text(formatearRangoMinutos(
                  tiempo.alternativaNevera!.minutosMin,
                  tiempo.alternativaNevera!.minutosMax)),
              value: _fasesEnNevera.contains(tiempo.fase),
              onChanged: (activar) => setState(() {
                activar
                    ? _fasesEnNevera.add(tiempo.fase)
                    : _fasesEnNevera.remove(tiempo.fase);
              }),
            ),
          if (_plantilla.llevaMasaMadre)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                  SoleraL10n.t(_refrescoApuntado
                      ? 'obra.plan_refresco_apuntado'
                      : 'obra.plan_refresco_estimado'),
                  style: estilo.bodySmall),
            ),
          const Divider(height: 24),
          if (tarde)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(SoleraL10n.t('obra.plan_llega_tarde'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          LineaTiempoPlan(fases: fases),
          const SizedBox(height: 12),
          Text(SoleraL10n.t('obra.plan_orientativo'), style: estilo.bodySmall),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _guardando ? null : () => _guardar(avisar: true),
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(SoleraL10n.t('obra.plan_guardar_avisar')),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _guardando ? null : () => _guardar(avisar: false),
            child: Text(SoleraL10n.t('obra.plan_guardar_sin_avisos')),
          ),
        ],
      ),
    );
  }
}

/// Pide permiso, programa los avisos del [plan] y lo guarda con
/// `avisosProgramados`. Si no hay permiso, lo dice: las horas siguen en la
/// app.
Future<PlanHornada> activarAvisos(
    BuildContext context, PlanHornada plan) async {
  final mensajero = ScaffoldMessenger.of(context);
  final permiso = await avisosObrador.pedirPermiso();
  final programados = permiso ? await programarAvisosPlan(plan) : 0;
  final actualizado = plan.copiar(avisosProgramados: programados > 0);
  await BaseDatosSoleraObrador.instancia.guardarPlanHornada(actualizado);
  mensajero.showSnackBar(SnackBar(
      content: Text(programados > 0
          ? SoleraL10n.tf('avisos.programados_n', {'n': programados})
          : SoleraL10n.t('avisos.sin_permiso'))));
  return actualizado;
}

/// Línea de tiempo: una fila por fase con su hora de inicio, duración y
/// rango. Con [alMarcar], cada fila lleva una casilla de «hecha».
class LineaTiempoPlan extends StatelessWidget {
  const LineaTiempoPlan({super.key, required this.fases, this.alMarcar});

  final List<FasePlanificada> fases;
  final void Function(int indice)? alMarcar;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme;
    final siguiente = siguienteFasePendiente(fases);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (indice, fase) in fases.indexed)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: alMarcar == null
                ? Icon(_iconoFase(fase.fase))
                : Checkbox(
                    value: fase.hecha,
                    onChanged: fase.hecha ? null : (_) => alMarcar!(indice),
                  ),
            selected: alMarcar != null && identical(fase, siguiente),
            title: Text([
              formatearHoraFase(fase.inicio),
              nombreFaseHornada(fase.fase),
            ].join('  ·  ')),
            subtitle: Text([
              formatearDuracion(fase.duracion),
              if (fase.minutosMin != fase.minutosMax)
                '(${formatearRangoMinutos(fase.minutosMin, fase.minutosMax)})',
              if (fase.enNevera) SoleraL10n.t('obra.plan_nevera'),
              if (fase.enParalelo) SoleraL10n.t('obra.plan_en_paralelo'),
              if (fase.hechaEn != null)
                '✓ ${DateFormat.Hm(SoleraL10n.idioma).format(fase.hechaEn!)}',
            ].join(' ')),
          ),
        if (finDelPlan(fases) case final fin?)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.bakery_dining_outlined),
            title: Text(
                '${formatearHoraFase(fin)}  ·  ${SoleraL10n.t('obra.plan_listo')}',
                style: estilo.titleSmall),
          ),
      ],
    );
  }

  static IconData _iconoFase(FaseHornada fase) => switch (fase) {
        FaseHornada.refrescoMasaMadre => Icons.bubble_chart_outlined,
        FaseHornada.autolisis => Icons.water_drop_outlined,
        FaseHornada.amasado => Icons.back_hand_outlined,
        FaseHornada.primeraFermentacion => Icons.hourglass_top_outlined,
        FaseHornada.formado => Icons.circle_outlined,
        FaseHornada.fermentacionFinal => Icons.hourglass_bottom_outlined,
        FaseHornada.precalentarHorno => Icons.thermostat_outlined,
        FaseHornada.coccion => Icons.local_fire_department_outlined,
        FaseHornada.enfriado => Icons.ac_unit_outlined,
      };
}

/// Un plan guardado: marcar fases hechas (las siguientes se mueven si va
/// con retraso), avisos y terminar.
class PantallaPlanHornada extends StatefulWidget {
  const PantallaPlanHornada({super.key, required this.planId});

  final int planId;

  @override
  State<PantallaPlanHornada> createState() => _PantallaPlanHornadaState();
}

class _PantallaPlanHornadaState extends State<PantallaPlanHornada> {
  PlanHornada? _plan;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final plan = await BaseDatosSoleraObrador.instancia
        .obtenerPlanHornada(widget.planId);
    if (mounted) setState(() => _plan = plan);
  }

  Future<void> _guardar(PlanHornada plan) async {
    await BaseDatosSoleraObrador.instancia.guardarPlanHornada(plan);
    avisarCambioDatos();
    if (mounted) setState(() => _plan = plan);
  }

  Future<void> _marcar(int indice) async {
    final plan = _plan!;
    final fases = marcarHechaYReplanificar(plan.fases, indice, DateTime.now());
    final actualizado = plan.copiar(
        fases: fases, terminado: siguienteFasePendiente(fases) == null);
    await _guardar(actualizado);
    if (actualizado.avisosProgramados) {
      actualizado.terminado
          ? await quitarAvisosPlan(actualizado.id!)
          : await programarAvisosPlan(actualizado);
    }
  }

  Future<void> _alternarAvisos() async {
    final plan = _plan!;
    if (plan.avisosProgramados) {
      await quitarAvisosPlan(plan.id!);
      await _guardar(plan.copiar(avisosProgramados: false));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(SoleraL10n.t('avisos.quitados'))));
      }
      return;
    }
    final actualizado = await activarAvisos(context, plan);
    avisarCambioDatos();
    if (mounted) setState(() => _plan = actualizado);
  }

  Future<void> _terminar() async {
    final plan = _plan!;
    await quitarAvisosPlan(plan.id!);
    await _guardar(plan.copiar(terminado: true, avisosProgramados: false));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _borrar() async {
    final confirmado = await DialogoConfirmacion.mostrar(context,
        titulo: SoleraL10n.t('obra.plan_borrar'),
        mensaje: _plan!.nombre,
        esPeligroso: true);
    if (!confirmado) return;
    await quitarAvisosPlan(widget.planId);
    await BaseDatosSoleraObrador.instancia.borrarPlanHornada(widget.planId);
    avisarCambioDatos();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    if (plan == null) {
      return Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()));
    }
    final estilo = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(plan.nombre),
        actions: [
          IconButton(
            tooltip: SoleraL10n.t(
                plan.avisosProgramados ? 'avisos.quitar' : 'avisos.avisarme'),
            icon: Icon(plan.avisosProgramados
                ? Icons.notifications_off_outlined
                : Icons.notifications_active_outlined),
            onPressed: plan.terminado ? null : _alternarAvisos,
          ),
          IconButton(
            tooltip: SoleraL10n.t('borrar'),
            icon: const Icon(Icons.delete_outline),
            onPressed: _borrar,
          ),
        ],
      ),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.fromLTRB(16, 8, 16, 32)),
        children: [
          Text(
              '${formatearNumero(plan.temperaturaCocinaC, decimales: 0)} °C · '
              '${SoleraL10n.t(plan.avisosProgramados ? 'obra.plan_con_avisos' : 'obra.plan_sin_avisos')}',
              style: estilo.bodySmall),
          const SizedBox(height: 4),
          Text(SoleraL10n.t('obra.plan_marcar_ayuda'), style: estilo.bodySmall),
          LineaTiempoPlan(
              fases: plan.fases, alMarcar: plan.terminado ? null : _marcar),
          const SizedBox(height: 12),
          if (!plan.terminado)
            OutlinedButton.icon(
              onPressed: _terminar,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(SoleraL10n.t('obra.plan_terminar')),
            )
          else
            Text(SoleraL10n.t('obra.plan_terminado'), style: estilo.titleSmall),
          const SizedBox(height: 12),
          Text(SoleraL10n.t('obra.plan_orientativo'), style: estilo.bodySmall),
        ],
      ),
    );
  }
}

/// Tiempos de cada fase de una receta propia: incluir o no la fase, rango
/// en minutos y si va en la nevera.
class PantallaTiemposReceta extends StatefulWidget {
  const PantallaTiemposReceta(
      {super.key, required this.nombre, required this.inicial});

  final String nombre;
  final PlantillaTiempos inicial;

  @override
  State<PantallaTiemposReceta> createState() => _PantallaTiemposRecetaState();
}

class _FilaTiempo {
  _FilaTiempo(this.fase, TiempoFase? tiempo)
      : incluida = tiempo != null,
        enNevera = tiempo?.enNevera ?? false,
        minimo = TextEditingController(
            text: tiempo == null ? '' : '${tiempo.minutosMin}'),
        maximo = TextEditingController(
            text: tiempo == null ? '' : '${tiempo.minutosMax}');

  final FaseHornada fase;
  bool incluida;
  bool enNevera;
  final TextEditingController minimo;
  final TextEditingController maximo;
}

class _PantallaTiemposRecetaState extends State<PantallaTiemposReceta> {
  late final _referencia = TextEditingController(
      text:
          formatearNumero(widget.inicial.temperaturaReferenciaC, decimales: 0));
  late final List<_FilaTiempo> _filas = [
    for (final fase in FaseHornada.values)
      _FilaTiempo(fase, _primerTiempo(fase)),
  ];
  bool _error = false;

  TiempoFase? _primerTiempo(FaseHornada fase) {
    for (final tiempo in widget.inicial.fases) {
      if (tiempo.fase == fase) return tiempo;
    }
    return null;
  }

  @override
  void dispose() {
    _referencia.dispose();
    for (final fila in _filas) {
      fila.minimo.dispose();
      fila.maximo.dispose();
    }
    super.dispose();
  }

  void _guardar() {
    final referencia = leerNumero(_referencia.text);
    final fases = <TiempoFase>[];
    for (final fila in _filas.where((fila) => fila.incluida)) {
      final minimo = leerNumero(fila.minimo.text)?.round();
      final maximo = leerNumero(fila.maximo.text)?.round() ?? minimo;
      if (minimo == null || maximo == null || minimo < 0 || maximo < minimo) {
        setState(() => _error = true);
        return;
      }
      // Fases que la plantilla original repetía (brioche) se conservan.
      final repetidas = widget.inicial.fases
          .where((tiempo) => tiempo.fase == fila.fase)
          .skip(1);
      fases.add(TiempoFase(fila.fase, minimo, maximo,
          enNevera: fila.enNevera,
          alternativaNevera: _primerTiempo(fila.fase)?.alternativaNevera));
      fases.addAll(repetidas);
    }
    if (referencia == null || fases.isEmpty) {
      setState(() => _error = true);
      return;
    }
    Navigator.pop(context,
        PlantillaTiempos(temperaturaReferenciaC: referencia, fases: fases));
  }

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('obra.plan_tiempos_titulo'))),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.fromLTRB(16, 8, 16, 32)),
        children: [
          Text(widget.nombre, style: estilo.titleMedium),
          const SizedBox(height: 4),
          Text(SoleraL10n.t('obra.plan_tiempos_ayuda'),
              style: estilo.bodySmall),
          const SizedBox(height: 8),
          TextField(
            controller: _referencia,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
                labelText: SoleraL10n.t('obra.plan_temperatura_referencia'),
                suffixText: '°C'),
          ),
          for (final fila in _filas) ...[
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(nombreFaseHornada(fila.fase)),
              value: fila.incluida,
              onChanged: (valor) => setState(() => fila.incluida = valor!),
            ),
            if (fila.incluida)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: fila.minimo,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: SoleraL10n.t('obra.plan_minutos_min'),
                          suffixText: 'min'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: fila.maximo,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: SoleraL10n.t('obra.plan_minutos_max'),
                          suffixText: 'min'),
                    ),
                  ),
                  if (fila.fase.esFermentacion &&
                      fila.fase != FaseHornada.refrescoMasaMadre)
                    Column(
                      children: [
                        Text(SoleraL10n.t('obra.plan_nevera'),
                            style: estilo.labelSmall),
                        Switch(
                          value: fila.enNevera,
                          onChanged: (valor) =>
                              setState(() => fila.enNevera = valor),
                        ),
                      ],
                    ),
                ],
              ),
          ],
          if (_error)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(SoleraL10n.t('obra.plan_tiempos_error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 16),
          FilledButton(
              onPressed: _guardar, child: Text(SoleraL10n.t('guardar'))),
        ],
      ),
    );
  }
}
