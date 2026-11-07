import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../dominio/composicion_cestas.dart';
import '../dominio/prevision_cosecha.dart';
import '../estado/cambios_datos.dart';
import '../estado/datos_huerta.dart';
import '../provisional_core/venta_directa/cesta.dart';
import '../provisional_core/venta_directa/entrega.dart';
import '../provisional_core/venta_directa/reparto_cestas.dart';
import '../provisional_core/venta_directa/semanas.dart';
import '../provisional_core/venta_directa/socio.dart';
import '../provisional_core/venta_directa/suscripcion.dart';
import '../utiles/textos_huerta.dart';
import 'hoja_formulario.dart';
import 'pantalla_socios.dart';

/// Todo lo de una semana de cestas, ya cargado.
class SemanaCestas {
  SemanaCestas({
    required this.lunes,
    required this.datos,
    required this.socios,
    required this.suscripciones,
    required this.cestas,
    required this.lineas,
    required this.entregas,
    required this.real,
    required this.prevista,
  });

  final DateTime lunes;
  final DatosHuerta datos;
  final List<Socio> socios;
  final List<Suscripcion> suscripciones;
  final List<Cesta> cestas;
  final List<LineaCesta> lineas;
  final List<Entrega> entregas;
  final Map<int, ({double kg, int unidades})> real;
  final Map<int, double> prevista;

  static Future<SemanaCestas> cargar(DateTime lunes) async {
    final bd = BaseDatosSoleraHuerta.instancia;
    final semana = lunesDeSemana(lunes);
    final (inicio, fin) = intervaloSemana(semana);
    final datos = await DatosHuerta.cargar();
    final cestas =
        await bd.listarCestas(semanaLunesMs: semana.millisecondsSinceEpoch);
    final ids = [for (final cesta in cestas) cesta.id!];
    return SemanaCestas(
      lunes: semana,
      datos: datos,
      socios: await bd.listarSocios(),
      suscripciones: await bd.listarSuscripciones(),
      cestas: cestas,
      lineas: await bd.listarLineasCesta(cestaIds: ids),
      entregas: await bd.listarEntregas(cestaIds: ids),
      real: cosechaRealParaCestas(
          cosechas: await bd.listarCosechas(desdeMs: inicio, hastaMs: fin),
          lunes: semana),
      prevista: cosechaPrevistaSemana(
          siembras: datos.siembras,
          lunes: semana,
          cicloDe: datos.cicloDeCultivo),
    );
  }

  Socio? socio(int id) {
    for (final socio in socios) {
      if (socio.id == id) return socio;
    }
    return null;
  }

  /// Suscripciones a las que les toca cesta esta semana.
  List<Suscripcion> get queTocan => [
        for (final suscripcion in suscripciones)
          if (suscripcion.tocaEnSemana(lunes) &&
              (socio(suscripcion.socioId)?.activo ?? false))
            suscripcion
      ];

  Cesta? cestaDe(int suscripcionId) {
    for (final cesta in cestas) {
      if (cesta.suscripcionId == suscripcionId) return cesta;
    }
    return null;
  }

  List<LineaCesta> lineasDe(int cestaId) => [
        for (final linea in lineas)
          if (linea.cestaId == cestaId) linea
      ];

  Entrega? entregaDe(int cestaId) {
    for (final entrega in entregas) {
      if (entrega.cestaId == cestaId) return entrega;
    }
    return null;
  }

  String nombreSuscripcion(Suscripcion suscripcion) =>
      '${socio(suscripcion.socioId)?.nombre ?? '?'} · '
      '${nombreTamanoCesta(suscripcion.tamano)}';

  /// «Tomate 1,2 kg, Lechuga 2 pzas».
  String resumenLineas(int cestaId) => lineasDe(cestaId)
      .map((linea) => '${datos.nombreDeCultivo(linea.cultivoId)} '
          '${linea.porUnidades ? SoleraL10n.tf('huer.n_piezas', {
                  'n': linea.unidades
                }) : formatearKilos(linea.kg)}')
      .join(', ');
}

/// Cestas de la semana: cosecha disponible, propuesta de reparto y cesta de
/// cada suscripción con su entrega.
class PantallaCestas extends StatefulWidget {
  const PantallaCestas({super.key});

  @override
  State<PantallaCestas> createState() => _PantallaCestasState();
}

class _PantallaCestasState extends State<PantallaCestas> {
  DateTime _lunes = lunesDeSemana(DateTime.now());
  late Future<SemanaCestas> _semana;

  @override
  void initState() {
    super.initState();
    _semana = SemanaCestas.cargar(_lunes);
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _semana = SemanaCestas.cargar(_lunes);
    });
  }

  void _moverSemana(int semanas) {
    setState(() {
      _lunes = DateTime(_lunes.year, _lunes.month, _lunes.day + 7 * semanas);
      _semana = SemanaCestas.cargar(_lunes);
    });
  }

  Future<void> _proponerReparto(SemanaCestas semana) async {
    final suscripciones = semana.queTocan;
    if (suscripciones.isEmpty) {
      avisar(context, SoleraL10n.t('huer.sin_cestas_semana'));
      return;
    }
    final composicion = existenciasParaReparto(
      real: semana.real,
      prevista: semana.prevista,
      porUnidades: (cultivoId) {
        final cultivo = semana.datos.cultivo(cultivoId);
        return cultivo != null && seRepartePorUnidades(cultivo.especieId);
      },
    );
    if (composicion.fuente == FuenteReparto.nada) {
      avisar(context, SoleraL10n.t('huer.sin_cosecha_para_cestas'));
      return;
    }
    final preparadas = [
      for (final suscripcion in suscripciones)
        if (semana.cestaDe(suscripcion.id!) != null) suscripcion
    ];
    if (preparadas.isNotEmpty) {
      final seguir = await showDialog<bool>(
        context: context,
        builder: (contexto) => AlertDialog(
          content: Text(SoleraL10n.t('huer.reparto_sustituye')),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(contexto, false),
                child: Text(SoleraL10n.t('cancelar'))),
            FilledButton(
                onPressed: () => Navigator.pop(contexto, true),
                child: Text(SoleraL10n.t('huer.repartir'))),
          ],
        ),
      );
      if (seguir != true) return;
    }
    final propuesta = repartirCosecha(
      existencias: composicion.existencias,
      cestas: [
        for (final suscripcion in suscripciones)
          CestaEnReparto(
              suscripcionId: suscripcion.id!, partes: suscripcion.partes)
      ],
      semilla: numeroSemanaIso(semana.lunes),
    );
    final bd = BaseDatosSoleraHuerta.instancia;
    for (final suscripcion in suscripciones) {
      final existente = semana.cestaDe(suscripcion.id!);
      await bd.guardarCestaConLineas(
        Cesta(
          id: existente?.id,
          suscripcionId: suscripcion.id!,
          semanaLunesMs: semana.lunes.millisecondsSinceEpoch,
          estado: 'prevista',
          notas: existente?.notas ?? '',
        ),
        [
          for (final linea in propuesta.lineas[suscripcion.id!]!)
            LineaCesta(
                cestaId: 0,
                cultivoId: linea.cultivoId,
                kg: linea.kg,
                unidades: linea.unidades),
        ],
      );
    }
    avisarCambioDatos();
    if (!mounted) return;
    final sobrante = propuesta.sobrante.values
        .map((linea) => '${semana.datos.nombreDeCultivo(linea.cultivoId)} '
            '${linea.unidades != null ? SoleraL10n.tf('huer.n_piezas', {
                    'n': linea.unidades
                  }) : formatearKilos(linea.kg)}')
        .join(', ');
    avisar(
        context,
        [
          SoleraL10n.t(composicion.fuente == FuenteReparto.real
              ? 'huer.repartido_real'
              : 'huer.repartido_previsto'),
          if (sobrante.isNotEmpty)
            SoleraL10n.tf('huer.sobra', {'sobrante': sobrante}),
        ].join(' '));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('huer.cestas')),
        actions: [
          IconButton(
            tooltip: SoleraL10n.t('huer.socios'),
            icon: const Icon(Icons.people_outline),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaSocios())),
          ),
        ],
      ),
      body: FutureBuilder<SemanaCestas>(
        future: _semana,
        builder: (context, instantanea) {
          final semana = instantanea.data;
          if (semana == null) {
            return const SizedBox.shrink();
          }
          final suscripciones = semana.queTocan;
          final hayPrevista = semana.prevista.isNotEmpty;
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      tooltip: SoleraL10n.t('huer.semana_anterior'),
                      onPressed: () => _moverSemana(-1),
                      icon: const Icon(Icons.chevron_left)),
                  Text(SoleraL10n.tf('huer.semana_de', {
                    'n': numeroSemanaIso(semana.lunes),
                    'fecha': formatearFechaDia(semana.lunes),
                  })),
                  IconButton(
                      tooltip: SoleraL10n.t('huer.semana_siguiente'),
                      onPressed: () => _moverSemana(1),
                      icon: const Icon(Icons.chevron_right)),
                ],
              ),
              ListTile(
                title: Text(SoleraL10n.t('huer.cosecha_para_cestas'),
                    style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text(semana.real.isNotEmpty
                    ? semana.real.entries
                        .map((entrada) =>
                            '${semana.datos.nombreDeCultivo(entrada.key)} '
                            '${[
                              if (entrada.value.kg > 0)
                                formatearKilos(entrada.value.kg),
                              if (entrada.value.unidades > 0)
                                SoleraL10n.tf('huer.n_piezas',
                                    {'n': entrada.value.unidades}),
                            ].join(' + ')}')
                        .join(', ')
                    : SoleraL10n.t('huer.sin_cosecha_real')),
              ),
              if (hayPrevista)
                ListTile(
                  title: Text(SoleraL10n.t('huer.cosecha_prevista')),
                  subtitle: Text(semana.prevista.entries
                      .map((entrada) =>
                          '${semana.datos.nombreDeCultivo(entrada.key)} '
                          '${formatearKilos(entrada.value)}')
                      .join(', ')),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  onPressed: () => _proponerReparto(semana),
                  icon: const Icon(Icons.call_split),
                  label: Text(SoleraL10n.t('huer.proponer_reparto')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(SoleraL10n.t('huer.reparto_ayuda'),
                    style: Theme.of(context).textTheme.bodySmall),
              ),
              const Divider(),
              ListTile(
                title: Text(
                    SoleraL10n.tf(
                        'huer.cestas_semana', {'n': suscripciones.length}),
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              if (suscripciones.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(SoleraL10n.t('huer.sin_cestas_semana')),
                ),
              for (final suscripcion in suscripciones)
                _filaCesta(context, semana, suscripcion),
            ],
          );
        },
      ),
    );
  }

  Widget _filaCesta(
      BuildContext context, SemanaCestas semana, Suscripcion suscripcion) {
    final cesta = semana.cestaDe(suscripcion.id!);
    final entrega = cesta == null ? null : semana.entregaDe(cesta.id!);
    final estado = entrega != null
        ? nombreResultadoEntrega(entrega.resultado)
        : cesta == null
            ? SoleraL10n.t('huer.sin_componer')
            : nombreEstadoCesta(cesta.estado);
    return ListTile(
      leading: Icon(entrega?.entregada == true
          ? Icons.task_alt
          : Icons.shopping_basket_outlined),
      title: Text(semana.nombreSuscripcion(suscripcion)),
      subtitle: Text([
        estado,
        if (cesta != null && semana.lineasDe(cesta.id!).isNotEmpty)
          semana.resumenLineas(cesta.id!),
      ].join(' · ')),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PantallaCesta(
                  suscripcionId: suscripcion.id!, lunes: semana.lunes))),
    );
  }
}

/// Una cesta: sus líneas (editables), su estado y su entrega.
class PantallaCesta extends StatefulWidget {
  const PantallaCesta(
      {super.key, required this.suscripcionId, required this.lunes});

  final int suscripcionId;
  final DateTime lunes;

  @override
  State<PantallaCesta> createState() => _PantallaCestaState();
}

class _PantallaCestaState extends State<PantallaCesta> {
  late Future<SemanaCestas> _semana;

  @override
  void initState() {
    super.initState();
    _semana = SemanaCestas.cargar(widget.lunes);
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _semana = SemanaCestas.cargar(widget.lunes);
    });
  }

  Cesta _cestaOVacia(SemanaCestas semana) =>
      semana.cestaDe(widget.suscripcionId) ??
      Cesta(
          suscripcionId: widget.suscripcionId,
          semanaLunesMs: semana.lunes.millisecondsSinceEpoch);

  Future<void> _guardarLineas(SemanaCestas semana, List<LineaCesta> lineas,
      {String? estado}) async {
    final cesta = _cestaOVacia(semana);
    await BaseDatosSoleraHuerta.instancia.guardarCestaConLineas(
        Cesta(
            id: cesta.id,
            suscripcionId: cesta.suscripcionId,
            semanaLunesMs: cesta.semanaLunesMs,
            estado: estado ?? cesta.estado,
            notas: cesta.notas),
        lineas);
    avisarCambioDatos();
  }

  Future<void> _editarLinea(SemanaCestas semana, {LineaCesta? linea}) async {
    final cultivos = semana.datos.cultivos;
    if (cultivos.isEmpty) {
      avisar(context, SoleraL10n.t('huer.falta_bancal_o_cultivo'));
      return;
    }
    final kilos = TextEditingController(
        text: linea == null || linea.porUnidades
            ? ''
            : numeroParaCampo(linea.kg));
    final piezas =
        TextEditingController(text: linea?.unidades?.toString() ?? '');
    var cultivo = linea?.cultivoId ?? cultivos.first.id!;
    final cesta = semana.cestaDe(widget.suscripcionId);
    final actuales =
        cesta == null ? <LineaCesta>[] : semana.lineasDe(cesta.id!);
    await mostrarHojaFormulario(
      context,
      titulo: SoleraL10n.t('huer.linea_cesta'),
      controladores: [kilos, piezas],
      construir: (refrescar) => [
        desplegable<int>(
          etiqueta: SoleraL10n.t('huer.cultivo'),
          valor: cultivo,
          opciones: [for (final opcion in cultivos) opcion.id!],
          nombre: semana.datos.nombreDeCultivo,
          alCambiar: (valor) => refrescar(() => cultivo = valor ?? cultivo),
        ),
        Row(children: [
          Expanded(child: campoNumero(kilos, SoleraL10n.t('huer.kg'))),
          const SizedBox(width: 12),
          Expanded(
              child: campoNumero(piezas, SoleraL10n.t('huer.piezas'),
                  decimales: false)),
        ]),
      ],
      guardar: () async {
        final kg = leerNumero(kilos.text) ?? 0;
        final unidades = leerEntero(piezas.text);
        if (kg <= 0 && (unidades == null || unidades <= 0)) return false;
        final nueva = LineaCesta(
            cestaId: 0,
            cultivoId: cultivo,
            kg: unidades != null && unidades > 0 ? 0 : kg,
            unidades: unidades != null && unidades > 0 ? unidades : null);
        await _guardarLineas(semana, [
          for (final actual in actuales)
            if (linea == null || actual.id != linea.id) actual,
          nueva,
        ]);
        return true;
      },
    );
  }

  Future<void> _quitarLinea(SemanaCestas semana, LineaCesta linea) async {
    final cesta = semana.cestaDe(widget.suscripcionId)!;
    await _guardarLineas(semana, [
      for (final actual in semana.lineasDe(cesta.id!))
        if (actual.id != linea.id) actual
    ]);
  }

  Future<void> _registrarEntrega(SemanaCestas semana) async {
    var cesta = semana.cestaDe(widget.suscripcionId);
    if (cesta == null) {
      await _guardarLineas(semana, const []);
      cesta = (await BaseDatosSoleraHuerta.instancia
              .listarCestas(semanaLunesMs: semana.lunes.millisecondsSinceEpoch))
          .firstWhere((c) => c.suscripcionId == widget.suscripcionId);
    }
    final anterior = semana.entregaDe(cesta.id!);
    final recogida = TextEditingController(text: anterior?.recogidaPor);
    final notas = TextEditingController(text: anterior?.notas);
    var resultado = anterior?.resultado ?? resultadosEntrega.first;
    var fecha = anterior == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(anterior.fechaMs);
    final cestaId = cesta.id!;
    if (!mounted) return;
    final guardado = await mostrarHojaFormulario(
      context,
      titulo: SoleraL10n.t('huer.entrega'),
      controladores: [recogida, notas],
      construir: (refrescar) => [
        desplegable<String>(
          etiqueta: SoleraL10n.t('huer.resultado_entrega'),
          valor: resultado,
          opciones: resultadosEntrega,
          nombre: nombreResultadoEntrega,
          alCambiar: (valor) => refrescar(() => resultado = valor ?? resultado),
        ),
        selectorFecha(context,
            fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
        campoTexto(recogida, SoleraL10n.t('huer.recogida_por')),
        campoTexto(notas, SoleraL10n.t('huer.notas')),
      ],
      guardar: () async {
        await BaseDatosSoleraHuerta.instancia.guardarEntrega(Entrega(
          id: anterior?.id,
          cestaId: cestaId,
          fechaMs: fecha.millisecondsSinceEpoch,
          resultado: resultado,
          recogidaPor: recogida.text.trim(),
          notas: notas.text.trim(),
        ));
        return true;
      },
    );
    if (guardado) avisarCambioDatos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SemanaCestas>(
      future: _semana,
      builder: (context, instantanea) {
        final semana = instantanea.data;
        Suscripcion? suscripcion;
        for (final candidata in semana?.suscripciones ?? <Suscripcion>[]) {
          if (candidata.id == widget.suscripcionId) suscripcion = candidata;
        }
        if (semana == null || suscripcion == null) {
          return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
        }
        final cesta = semana.cestaDe(widget.suscripcionId);
        final lineas =
            cesta == null ? <LineaCesta>[] : semana.lineasDe(cesta.id!);
        final entrega = cesta == null ? null : semana.entregaDe(cesta.id!);
        final socio = semana.socio(suscripcion.socioId);
        return Scaffold(
          appBar: AppBar(title: Text(semana.nombreSuscripcion(suscripcion))),
          floatingActionButton: FloatingActionButton(
            tooltip: SoleraL10n.t('huer.anadir'),
            onPressed: () => _editarLinea(semana),
            child: const Icon(Icons.add),
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              ListTile(
                title: Text(SoleraL10n.tf('huer.semana_de', {
                  'n': numeroSemanaIso(semana.lunes),
                  'fecha': formatearFechaDia(semana.lunes),
                })),
                subtitle: Text([
                  if (socio != null && socio.puntoEntrega.isNotEmpty)
                    socio.puntoEntrega,
                  if (socio != null && socio.notas.isNotEmpty) socio.notas,
                ].join(' · ')),
              ),
              if (lineas.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(SoleraL10n.t('huer.cesta_vacia')),
                ),
              for (final linea in lineas)
                ListTile(
                  title: Text(semana.datos.nombreDeCultivo(linea.cultivoId)),
                  trailing: Text(linea.porUnidades
                      ? SoleraL10n.tf('huer.n_piezas', {'n': linea.unidades})
                      : formatearKilos(linea.kg)),
                  onTap: () => _editarLinea(semana, linea: linea),
                  onLongPress: () => _quitarLinea(semana, linea),
                ),
              const Divider(),
              if (cesta != null && cesta.estado != 'preparada')
                ListTile(
                  leading: const Icon(Icons.inventory_outlined),
                  title: Text(SoleraL10n.t('huer.marcar_preparada')),
                  onTap: () =>
                      _guardarLineas(semana, lineas, estado: 'preparada'),
                ),
              ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: Text(entrega == null
                    ? SoleraL10n.t('huer.registrar_entrega')
                    : '${nombreResultadoEntrega(entrega.resultado)} · '
                        '${formatearFecha(entrega.fechaMs)}'),
                onTap: () => _registrarEntrega(semana),
              ),
            ],
          ),
        );
      },
    );
  }
}
