import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/coordinador.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/balance_convenio.dart';
import '../modelos/constantes.dart';
import '../modelos/convenio.dart';
import '../modelos/desglose_gastos.dart';
import '../modelos/indicadores_seguimiento.dart';
import '../modelos/proyecto_test.dart';
import '../modelos/registro_actividad.dart';
import '../modelos/registro_comercializacion.dart';
import '../modelos/rentabilidad_proyecto.dart';
import '../modelos/validacion_producto.dart';
import '../servicios/alimentacion_por_dias.dart';
import '../servicios/documento_generado.dart';
import '../servicios/generador_csv_proyecto.dart';
import '../servicios/generador_informe_proyecto.dart';
import '../utiles/periodo.dart';
import '../utiles/resumen_proyecto.dart';
import 'nueva_actividad.dart';
import 'nueva_comercializacion.dart';
import 'nueva_validacion.dart';
import 'nuevo_apunte.dart';
import 'nuevo_proyecto.dart';
import 'pantalla_calculadora.dart';
import 'pantalla_convenio.dart';
import 'pantalla_informe_proyecto.dart';
import '../estado/datos_notificador.dart';
import 'widgets/confirmar_borrado.dart';
import 'widgets/proyecto_visual.dart';
import 'widgets/relleno_seguro.dart';

/// Detalle de un proyecto de test: análisis de rentabilidad + producción,
/// comercialización, validación de producto y económico, con informe PDF.
class ProyectoDetalle extends StatefulWidget {
  const ProyectoDetalle({super.key, required this.proyecto});

  final ProyectoTest proyecto;

  @override
  State<ProyectoDetalle> createState() => _ProyectoDetalleState();
}

class _ProyectoDetalleState extends State<ProyectoDetalle> {
  final _bd = BaseDatosSoleraZunbeltz();
  RentabilidadProyecto _rent = const RentabilidadProyecto();
  List<RegistroComercializacion> _ventas = const [];
  List<RegistroActividad> _produccion = const [];
  List<ValidacionProducto> _validaciones = const [];
  List<ApunteEconomico> _apuntes = const [];
  DesgloseGastos _desgloseGastos = DesgloseGastos.calcular(const []);
  TipoPeriodo _periodo = TipoPeriodo.todo;

  /// Cuentas del convenio en el periodo elegido (bloque del balance, quién
  /// asume, coste real) y de todo el test (presupuesto y fianza, que se
  /// comparan con lo previsto para todo el test).
  BalanceConvenio? _balancePeriodo;
  BalanceConvenio? _balanceTotal;
  EstadoFianza? _fianza;
  int _incidencias = 0;
  List<Acompanamiento> _acompanamientos = const [];

  /// Avisa a la pantalla de registros (abierta encima) de que hay datos
  /// nuevos.
  final _versionDatos = ValueNotifier<int>(0);
  bool _cargando = true;

  RangoPeriodo get _rango => rangoDePeriodo(_periodo, DateTime.now());

  /// Copia viva del proyecto: se relee al volver de editarlo o cerrarlo.
  late ProyectoTest _proyecto = widget.proyecto;

  /// Finca para los registros si el proyecto no tiene una propia (la
  /// columna es obligatoria y tiene que existir en todos los móviles).
  int? _fincaRespaldo;

  /// La finca del proyecto, para la cabecera.
  String? _nombreFinca;

  int get _proyectoId => widget.proyecto.id!;
  int get _fincaId => _proyecto.fincaId ?? _fincaRespaldo ?? 0;

  bool get _puedeRegistrar => politicaEspacioActual.puedeRegistrarEnProyecto(
      personaUidProyecto: _proyecto.personaUid, cerrado: _proyecto.cerrado);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _versionDatos.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final desde = _rango.desdeMs;
    final hasta = _rango.hastaMs;
    try {
      final proyecto = await _bd.obtenerProyecto(_proyectoId);
      if (proyecto != null) _proyecto = proyecto;
      final fincas = await _bd.listarFincas();
      _fincaRespaldo ??= fincas.firstOrNull?.id;
      _nombreFinca = fincas
          .where((finca) => finca.id == _proyecto.fincaId)
          .firstOrNull
          ?.nombre;
      final rent = await _bd.rentabilidadProyecto(_proyectoId,
          desdeMs: desde, hastaMs: hasta);
      final ventas = await _bd.listarComercializacion(
          proyectoId: _proyectoId, desdeMs: desde, hastaMs: hasta);
      final produccion = await _bd.listarRegistros(
          proyectoId: _proyectoId, desdeMs: desde, hastaMs: hasta);
      final validaciones =
          await _bd.listarValidaciones(proyectoId: _proyectoId);
      final apuntes = await _bd.listarApuntes(
          proyectoId: _proyectoId, desdeMs: desde, hastaMs: hasta);
      final cuotasInventario = await _bd.amortizacionesDelInventario(_proyecto,
          desdeMs: desde, hastaMs: hasta);
      final desglose =
          DesgloseGastos.calcular([...apuntes, ...cuotasInventario]);
      final presupuesto = await _bd.listarPresupuesto(_proyectoId);
      final todasLasVentas =
          await _bd.listarComercializacion(proyectoId: _proyectoId);
      final todosLosApuntes = [
        ...await _bd.listarApuntes(proyectoId: _proyectoId),
        ...await _bd.amortizacionesDelInventario(_proyecto),
      ];
      final incidencias = await _bd.listarIncidencias(_proyectoId);
      final fianza = EstadoFianza.calcular(
          await _bd.listarMovimientosFianza(_proyectoId), incidencias);
      final acompanamientos = await _bd.listarAcompanamientos(_proyectoId)
        ..sort((a, b) => b.fechaMs.compareTo(a.fechaMs));
      if (!mounted) return;
      setState(() {
        _balancePeriodo = BalanceConvenio.calcular(
            proyecto: _proyecto,
            apuntes: [...apuntes, ...cuotasInventario],
            ventas: ventas);
        _balanceTotal = BalanceConvenio.calcular(
            proyecto: _proyecto,
            apuntes: todosLosApuntes,
            ventas: todasLasVentas,
            presupuesto: presupuesto);
        _fianza = fianza;
        _incidencias = incidencias.length;
        _acompanamientos = acompanamientos;
        _rent = rent;
        _ventas = ventas;
        _produccion = produccion;
        _validaciones = validaciones;
        _apuntes = apuntes;
        _desgloseGastos = desglose;
        _cargando = false;
      });
      _versionDatos.value++;
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _borrarElemento(Future<void> Function() borrado) async {
    if (!await confirmarBorrado(context)) return;
    await borrado();
    avisarCambioDatos();
    await _cargar();
  }

  int? _diasPeriodo() => diasParaExtrapolar(
        rango: _rango,
        inicioProyectoMs: _proyecto.fechaInicioMs,
        finProyectoMs: _proyecto.fechaFinMs,
        ahoraMs: DateTime.now().millisecondsSinceEpoch,
      );

  /// IVA soportado (gastos) y repercutido (ventas + otros ingresos), céntimos.
  (int, int) _ivaTotales() {
    var soportado = 0;
    for (final a in _apuntes) {
      if (a.tipo == 'gasto') {
        soportado += cuotaIva(a.importeCentimos, a.ivaPorcentaje);
      }
    }
    var repercutido = 0;
    for (final v in _ventas) {
      repercutido += cuotaIva(v.ingresoCentimos, v.ivaPorcentaje);
    }
    for (final a in _apuntes) {
      if (a.tipo == 'ingreso') {
        repercutido += cuotaIva(a.importeCentimos, a.ivaPorcentaje);
      }
    }
    return (soportado, repercutido);
  }

  Future<void> _abrir(Widget pantalla) async {
    final creado = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => pantalla));
    if (creado == true) await _cargar();
  }

  Future<void> _anadir(int pestana) async {
    switch (pestana) {
      case 0:
        await _abrir(
            NuevaActividad(proyectoId: _proyectoId, fincaId: _fincaId));
      case 1:
        await _abrir(NuevaComercializacion(proyectoId: _proyectoId));
      case 2:
        await _abrir(NuevaValidacion(proyectoId: _proyectoId));
      case 3:
        await _abrir(NuevoApunte(proyectoId: _proyectoId, fincaId: _fincaId));
    }
  }

  Future<void> _editar() async {
    final cambiado = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => FutureBuilder(
              future: _bd.listarFincas(),
              builder: (contexto, fincas) => fincas.hasData
                  ? NuevoProyecto(fincas: fincas.data!, proyecto: _proyecto)
                  : const Scaffold(
                      body: Center(child: CircularProgressIndicator())),
            )));
    if (cambiado == true) await _cargar();
  }

  /// Cerrar lo deja en solo lectura para la persona tester y hace que los
  /// informes salgan como versión definitiva (sin marca de borrador).
  Future<void> _cambiarCierre({required bool cerrar}) async {
    final textos = AppLocalizations.of(context);
    if (cerrar) {
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (contexto) => AlertDialog(
          title: Text(textos.proyectoCerrar),
          content: Text(textos.proyectoCerrarPregunta),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(contexto, false),
                child: Text(textos.comunCancelar)),
            FilledButton(
                onPressed: () => Navigator.pop(contexto, true),
                child: Text(textos.proyectoCerrar)),
          ],
        ),
      );
      if (confirmado != true) return;
    }
    await _bd.actualizarProyecto(_proyectoId, {
      'estado': cerrar ? estadoProyectoCerrado : estadoProyectoAbierto,
      'cerrado_ms': cerrar ? DateTime.now().millisecondsSinceEpoch : null,
    });
    await _cargar();
  }

  Future<void> _borrar() async {
    final textos = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(textos.proyectoBorrar),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(textos.comunCancelar)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(textos.comunBorrar)),
        ],
      ),
    );
    if (ok != true) return;
    await _bd.borrarProyecto(_proyectoId);
    if (mounted) Navigator.of(context).pop(true);
  }

  /// Informe del proyecto con las cuentas del convenio. Sin marca de
  /// BORRADOR solo si lo genera coordinación con el proyecto cerrado.
  Future<DocumentoGenerado> _generarInforme(
      AppLocalizations textos, String idioma) async {
    final (ivaSoportado, ivaRepercutido) = _ivaTotales();
    final todosLosApuntes = [
      ...await _bd.listarApuntes(proyectoId: _proyectoId),
      ...await _bd.amortizacionesDelInventario(_proyecto),
    ];
    final todasLasVentas =
        await _bd.listarComercializacion(proyectoId: _proyectoId);
    final incidencias = await _bd.listarIncidencias(_proyectoId);
    final inicio = _proyecto.fechaInicioMs == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(_proyecto.fechaInicioMs!);
    final fin = _proyecto.fechaFinMs == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(_proyecto.fechaFinMs!);
    final formatoPeriodo = DateFormat('dd/MM/yyyy', idioma);
    final desdeMs = _rango.desdeMs, hastaMs = _rango.hastaMs;
    final periodo = desdeMs == null || hastaMs == null
        ? null
        : '${formatoPeriodo.format(DateTime.fromMillisecondsSinceEpoch(desdeMs))} – '
            '${formatoPeriodo.format(DateTime.fromMillisecondsSinceEpoch(hastaMs))}';
    return generarInformeProyectoPdf(
      periodo: periodo,
      textos: textos,
      idioma: idioma,
      proyecto: _proyecto,
      rentabilidad: _rent,
      comercializacion: _ventas,
      validaciones: _validaciones,
      actividades: _produccion,
      desgloseGastos: _desgloseGastos,
      ivaSoportadoCentimos: ivaSoportado,
      ivaRepercutidoCentimos: ivaRepercutido,
      balance: BalanceConvenio.calcular(
        proyecto: _proyecto,
        apuntes: todosLosApuntes,
        ventas: todasLasVentas,
        presupuesto: await _bd.listarPresupuesto(_proyectoId),
      ),
      fianza: EstadoFianza.calcular(
          await _bd.listarMovimientosFianza(_proyectoId), incidencias),
      indicadores: IndicadoresAcompanamiento.calcular(
          await _bd.listarAcompanamientos(_proyectoId),
          inicio: inicio,
          fin: fin),
      incidencias: incidencias,
      definitivo: politicaEspacioActual.documentoDefinitivo(
          proyectoCerrado: _proyecto.cerrado),
    );
  }

  /// Vista previa del informe con el periodo elegible; desde ella se
  /// comparte o se manda a coordinación.
  Future<void> _informe() async {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PantallaInformeProyecto(
        periodoInicial: _periodo,
        definitivo: politicaEspacioActual.documentoDefinitivo(
            proyectoCerrado: _proyecto.cerrado),
        generar: (periodo) async {
          if (periodo != _periodo) {
            setState(() => _periodo = periodo);
            await _cargar();
          }
          return _generarInforme(textos, idioma);
        },
        alEnviar: _enviarDocumento,
      ),
    ));
  }

  /// Kg de alimentación por día y lote de todo el proyecto, para Excel.
  Future<void> _exportarAlimentacion() async {
    final registros = await _bd.listarRegistros(proyectoId: _proyectoId);
    final documento = documentoAlimentacion(_proyecto.nombre, registros);
    try {
      await compartirDocumentos([documento], asunto: _proyecto.nombre);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(documento.nombreFichero)));
      }
    }
  }

  Future<void> _exportarCsv() async {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final documento = await generarCsvProyecto(
      textos: textos,
      idioma: idioma,
      proyecto: _proyecto,
      apuntes: _apuntes,
      ventas: _ventas,
    );
    try {
      await compartirDocumentos([documento], asunto: _proyecto.nombre);
    } catch (_) {
      // En escritorio el menú de compartir puede no estar disponible.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('CSV: ${documento.nombreFichero}')));
      }
    }
  }

  /// Genera el informe y lo comparte indicando el coordinador (opción B, sin
  /// backend): el envío real lo hace la app de correo/mensajería que elija el
  /// usuario; el correo del coordinador se sugiere en el cuerpo.
  Future<void> _enviarDocumento(DocumentoGenerado documento) async {
    final textos = AppLocalizations.of(context);
    final correo = await Coordinador.cargarCorreo();
    if (!mounted) return;
    if (correo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(textos.enviarCoordinadorSinDestino)));
      return;
    }
    final asunto = 'Larrea Zunbeltz · ${_proyecto.nombre}'
        '${_proyecto.persona.isEmpty ? '' : ' (${_proyecto.persona})'}';
    try {
      // Móvil: hoja de compartir con el PDF adjunto (eliges tu correo).
      await compartirDocumentos([documento],
          asunto: asunto, texto: '${textos.enviarCoordinadorTexto}\n$correo');
    } catch (_) {
      // Escritorio (sin hoja de compartir): primero se ofrece guardar el
      // PDF y después se abre el cliente de correo ya dirigido al
      // coordinador; mailto no admite adjuntos, se adjunta a mano.
      await Printing.sharePdf(
          bytes: documento.bytes, filename: documento.nombreFichero);
      final uri = Uri(
        scheme: 'mailto',
        path: correo,
        query: 'subject=${Uri.encodeComponent(asunto)}'
            '&body=${Uri.encodeComponent('${textos.enviarCoordinadorTexto}\n\n${textos.enviarCoordinadorAdjuntar}')}',
      );
      try {
        await launchUrl(uri);
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(documento.nombreFichero)));
      }
    }
  }

  Future<void> _abrirConvenio(int pestana) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            PantallaConvenio(proyecto: _proyecto, pestanaInicial: pestana)));
    await _cargar();
  }

  void _cambiarPeriodo(TipoPeriodo periodo) {
    if (periodo == _periodo) return;
    setState(() => _periodo = periodo);
    _cargar();
  }

  /// Producción, comercialización, validación y apuntes: cada uno en su
  /// pestaña, con su botón de añadir. Mantener pulsado borra.
  void _abrirRegistros(int pestana) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DefaultTabController(
        length: 4,
        initialIndex: pestana,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_proyecto.nombre),
            bottom: TabBar(isScrollable: true, tabs: [
              Tab(text: textos.detProduccion),
              Tab(text: textos.detComercial),
              Tab(text: textos.detValidacion),
              Tab(text: textos.detEconomico),
            ]),
          ),
          floatingActionButton: _puedeRegistrar
              ? Builder(
                  builder: (contexto) => FloatingActionButton(
                    onPressed: () =>
                        _anadir(DefaultTabController.of(contexto).index),
                    child: const Icon(Icons.add),
                  ),
                )
              : null,
          body: ListenableBuilder(
            listenable: _versionDatos,
            builder: (contexto, _) => TabBarView(children: [
              _ListaProduccion(
                  items: _produccion,
                  idioma: idioma,
                  textos: textos,
                  alBorrar: _puedeRegistrar
                      ? (id) => _borrarElemento(() => _bd.borrarRegistro(id))
                      : null),
              _ListaVentas(
                  items: _ventas,
                  idioma: idioma,
                  textos: textos,
                  alBorrar: _puedeRegistrar
                      ? (id) =>
                          _borrarElemento(() => _bd.borrarComercializacion(id))
                      : null),
              _ListaValidacion(
                  items: _validaciones,
                  idioma: idioma,
                  textos: textos,
                  alBorrar: _puedeRegistrar
                      ? (id) => _borrarElemento(() => _bd.borrarValidacion(id))
                      : null),
              _ListaApuntes(
                  items: _apuntes,
                  idioma: idioma,
                  textos: textos,
                  alBorrar: _puedeRegistrar
                      ? (id) => _borrarElemento(() => _bd.borrarApunte(id))
                      : null),
            ]),
          ),
        ),
      ),
    ));
  }

  void _accionMenu(_AccionProyecto accion) {
    switch (accion) {
      case _AccionProyecto.csv:
        _exportarCsv();
      case _AccionProyecto.enviar:
        _informe();
      case _AccionProyecto.alimentacion:
        _exportarAlimentacion();
      case _AccionProyecto.calculadora:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => PantallaCalculadora(proyecto: _proyecto)));
      case _AccionProyecto.convenio:
        _abrirConvenio(0);
      case _AccionProyecto.editar:
        _editar();
      case _AccionProyecto.cerrar:
        _cambiarCierre(cerrar: true);
      case _AccionProyecto.reabrir:
        _cambiarCierre(cerrar: false);
      case _AccionProyecto.borrar:
        _borrar();
    }
  }

  Widget _cabecera(AppLocalizations textos, String idioma) {
    final p = _proyecto;
    final esquema = context.esquemaZunbeltz;
    final colores = context.coloresZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final finca = _nombreFinca;
    final subtitulo = [
      if (p.persona.isNotEmpty) p.persona,
      if (buscarOpcion(especiesGanado, p.especie) case final especie?
          when p.especie != 'varias')
        especie.etiqueta(idioma)
      else if (p.actividad.isNotEmpty)
        p.actividad,
      if (finca != null && finca.isNotEmpty) finca,
    ].join(' · ');
    final mes = mesDelTest(p);
    final mesAnio = DateFormat.yMMMM(idioma);
    String? fechaLarga(int? ms) => ms == null || ms == 0
        ? null
        : mesAnio
            .format(DateTime.fromMillisecondsSinceEpoch(ms))
            .replaceAll(' de ', ' ')
            .toLowerCase();
    final inicio = fechaLarga(p.fechaInicioMs);
    final fin = fechaLarga(p.fechaFinMs);
    final lineaMes = [
      if (mes != null)
        mes.mesActual == 0
            ? textos.proyEmpieza(inicio ?? '')
            : mes.mesesTotales == null
                ? textos.proyMes('${mes.mesActual}')
                : textos.proyMesDe('${mes.mesActual}', '${mes.mesesTotales}'),
      if (inicio != null && fin != null) textos.proyDeA(inicio, fin),
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.nombre.isEmpty ? '—' : p.nombre, style: estilos.headlineMedium),
        if (subtitulo.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(subtitulo,
                style: estilos.bodyLarge
                    ?.copyWith(color: esquema.onSurfaceVariant)),
          ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: Text(lineaMes,
                style:
                    estilos.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Text(p.cerrado ? textos.proyectoCerradoEtiqueta : textos.proyAbierto,
              style: estilos.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: p.cerrado ? esquema.onSurfaceVariant : colores.hecha)),
        ]),
        if (mes?.mesesTotales != null) ...[
          const SizedBox(height: 8),
          BarraMesesTest(hechos: mes!.mesActual, totales: mes.mesesTotales!),
        ],
      ]),
    );
  }

  Widget _chipsPeriodo(AppLocalizations textos) {
    final opciones = {
      TipoPeriodo.todo: textos.proyPeriodoTodo,
      TipoPeriodo.anio: textos.periodoAnio,
      TipoPeriodo.trimestre: textos.periodoTrimestre,
      TipoPeriodo.trimestreAnterior: textos.periodoTrimestreAnterior,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        for (final MapEntry(key: periodo, value: etiqueta) in opciones.entries)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(etiqueta),
              selected: _periodo == periodo,
              onSelected: (_) => _cambiarPeriodo(periodo),
            ),
          ),
      ]),
    );
  }

  /// Título de sección con enlace a la derecha («Reparto ›»).
  Widget _titulo(String texto, {String? enlace, VoidCallback? alPulsar}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 4, 8),
      child: Row(children: [
        Expanded(
          child: Text(texto, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (enlace != null)
          TextButton(
            onPressed: alPulsar,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(enlace),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 20),
            ]),
          ),
      ]),
    );
  }

  Widget _quienAsume(AppLocalizations textos, BalanceConvenio balance) {
    final reparto = repartoDeGastos(balance);
    final estilos = Theme.of(context).textTheme;
    final esquema = context.esquemaZunbeltz;
    final colores = coloresReparto(context);
    Widget fila(Color color, String quien, int porcentaje, int centimos) =>
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(quien, style: estilos.bodyLarge)),
            Text('$porcentaje %',
                style: estilos.bodyMedium
                    ?.copyWith(color: esquema.onSurfaceVariant)),
            const SizedBox(width: 12),
            SizedBox(
              width: 92,
              child: Text(eurosRedondos(centimos),
                  textAlign: TextAlign.end,
                  style: estilos.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
          ]),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: reparto == null
          ? Text(textos.proySinGastos)
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              BarraRepartoGastos(
                  tester: reparto.tester, zunbeltz: reparto.zunbeltz, alto: 14),
              const SizedBox(height: 4),
              fila(colores.tester, textos.proyLaPersonaTester, reparto.tester,
                  balance.gastosAsumidosTesterCentimos),
              fila(colores.zunbeltz, 'Zunbeltz', reparto.zunbeltz,
                  balance.gastosAsumidosZunbeltzCentimos),
            ]),
    );
  }

  Widget _presupuesto(
      AppLocalizations textos, String idioma, BalanceConvenio balance) {
    final estilos = Theme.of(context).textTheme;
    final esquema = context.esquemaZunbeltz;
    final bloques = [
      for (final bloque in balance.categoriasComparadas)
        if ((balance.previstoPorCategoria[bloque] ?? 0) > 0) bloque,
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
      ),
      child: Column(children: [
        for (final bloque in bloques) ...[
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Text(
                  buscarOpcion(categoriasGasto, bloque)?.etiqueta(idioma) ??
                      bloque,
                  style: estilos.bodyLarge),
            ),
            const SizedBox(width: 8),
            Text(
                textos.proyDeTotal(
                    eurosRedondos(balance.realPorCategoria[bloque] ?? 0),
                    eurosRedondos(balance.previstoPorCategoria[bloque] ?? 0)),
                style: estilos.bodyMedium),
          ]),
          const SizedBox(height: 6),
          BarraPrevisto(
              real: balance.realPorCategoria[bloque] ?? 0,
              previsto: balance.previstoPorCategoria[bloque] ?? 0),
        ],
      ]),
    );
  }

  Widget _costeReal(AppLocalizations textos, BalanceConvenio balance) {
    final estilos = Theme.of(context).textTheme;
    final esquema = context.esquemaZunbeltz;
    final colores = context.coloresZunbeltz;
    final valor = balance.balanceProyectoCentimos;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: esquema.outlineVariant),
        borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
      ),
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(textos.balanceProyecto,
                style:
                    estilos.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            if (balance.amortizacionesCentimos > 0)
              Text(
                  textos.proySumaAmortizacion(
                      eurosRedondos(balance.amortizacionesCentimos)),
                  style: estilos.bodyMedium
                      ?.copyWith(color: esquema.onSurfaceVariant)),
          ]),
        ),
        const SizedBox(width: 12),
        Text(eurosConSigno(valor),
            style: estilos.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: valor < 0 ? colores.bloqueada : colores.hecha)),
      ]),
    );
  }

  Widget _fianzaTarjetas(AppLocalizations textos, BalanceConvenio balance) {
    final fianza = _fianza;
    Widget tarjeta(String rotulo, String valor, String detalle) => Expanded(
          child: Material(
            color: context.esquemaZunbeltz.surfaceContainerLow,
            borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _abrirConvenio(3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rotulo, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(valor,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(detalle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.esquemaZunbeltz.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          tarjeta(
              textos.proyDeReferencia,
              eurosRedondos(balance.fianzaReferenciaCentimos),
              textos.proyDiezPorCiento),
          const SizedBox(width: 12),
          tarjeta(
              textos.proyRetenido,
              eurosRedondos(fianza?.retenidoCentimos ?? 0),
              _incidencias == 0
                  ? textos.proySinIncidencias
                  : textos.proyIncidencias('$_incidencias')),
        ]),
      ),
    );
  }

  Widget _acompanamiento(AppLocalizations textos, String idioma) {
    final estilos = Theme.of(context).textTheme;
    final esquema = context.esquemaZunbeltz;
    if (_acompanamientos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(textos.proySinAcompanamiento,
            style:
                estilos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant)),
      );
    }
    final dia = DateFormat('d', idioma);
    final mes = DateFormat('MMM', idioma);
    return Column(children: [
      for (final actividad in _acompanamientos.take(2))
        InkWell(
          onTap: () => _abrirConvenio(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              SizedBox(
                width: 44,
                child: Column(children: [
                  Text(
                      dia.format(DateTime.fromMillisecondsSinceEpoch(
                          actividad.fechaMs)),
                      style: estilos.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                      mes
                          .format(DateTime.fromMillisecondsSinceEpoch(
                              actividad.fechaMs))
                          .replaceAll('.', ''),
                      style: estilos.bodySmall
                          ?.copyWith(color: esquema.onSurfaceVariant)),
                ]),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: esquema.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconoAcompanamiento(actividad.tipo),
                    color: esquema.onSecondaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        buscarOpcion(tiposAcompanamiento, actividad.tipo)
                                ?.etiqueta(idioma) ??
                            actividad.tipo,
                        style: estilos.titleMedium),
                    if (actividad.descripcion.isNotEmpty ||
                        actividad.horas != null)
                      Text(
                        [
                          if (actividad.descripcion.isNotEmpty)
                            actividad.descripcion,
                          if (actividad.horas != null)
                            textos.proyHoras(cantidadBonita(actividad.horas!)),
                        ].join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: estilos.bodyMedium
                            ?.copyWith(color: esquema.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
            ]),
          ),
        ),
    ]);
  }

  /// Margen, proyección anual y desglose de gastos con IVA (lo que antes
  /// enseñaba la cabecera).
  Widget _rentabilidad(AppLocalizations textos, String idioma) {
    final dias = _diasPeriodo();
    final proyeccion =
        dias == null ? null : _rent.balanceAnualExtrapoladoCentimos(dias);
    final estilos = Theme.of(context).textTheme;
    Widget cifra(String rotulo, String valor) => Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rotulo,
                style: estilos.bodyMedium?.copyWith(
                    color: context.esquemaZunbeltz.onSurfaceVariant)),
            Text(valor,
                style:
                    estilos.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          ]),
        );
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          cifra(textos.rentMargen,
              '${_rent.margenPorcentaje.toStringAsFixed(0)} %'),
          if (proyeccion != null)
            cifra(textos.rentProyeccion, eurosConSigno(proyeccion)),
        ]),
      ),
      if (_desgloseGastos.isNotEmpty)
        _DesgloseIva(
          desgloseGastos: _desgloseGastos,
          ivaTotales: _ivaTotales(),
          idioma: idioma,
          textos: textos,
        ),
    ]);
  }

  Widget _registros(AppLocalizations textos) {
    final esquema = context.esquemaZunbeltz;
    final filas = [
      (Icons.grass_outlined, textos.detProduccion, _produccion.length),
      (Icons.storefront_outlined, textos.detComercial, _ventas.length),
      (Icons.verified_outlined, textos.detValidacion, _validaciones.length),
      (Icons.receipt_long_outlined, textos.detEconomico, _apuntes.length),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        for (var indice = 0; indice < filas.length; indice++) ...[
          if (indice > 0)
            Divider(height: 1, indent: 56, color: esquema.outlineVariant),
          ListTile(
            leading: Icon(filas[indice].$1),
            title: Text(filas[indice].$2),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('${filas[indice].$3}',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right),
            ]),
            onTap: () => _abrirRegistros(indice),
          ),
        ],
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final p = _proyecto;
    if (_cargando) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final balance = _balancePeriodo;
    final total = _balanceTotal;
    final gestiona = politicaEspacioActual.puedeGestionarProyectos;
    final hayPresupuesto =
        total != null && total.previstoPorCategoria.values.any((v) => v > 0);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: textos.detInformePdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: _informe,
          ),
          PopupMenuButton<_AccionProyecto>(
            tooltip: textos.proyMasAcciones,
            onSelected: _accionMenu,
            itemBuilder: (_) {
              PopupMenuItem<_AccionProyecto> opcion(
                      _AccionProyecto valor, IconData icono, String texto) =>
                  PopupMenuItem(
                    value: valor,
                    child: ListTile(
                        leading: Icon(icono),
                        title: Text(texto),
                        contentPadding: EdgeInsets.zero),
                  );
              return [
                opcion(_AccionProyecto.convenio, Icons.handshake_outlined,
                    textos.convenioTitulo),
                opcion(_AccionProyecto.calculadora, Icons.calculate_outlined,
                    textos.calculadoraTitulo),
                opcion(_AccionProyecto.csv, Icons.table_view_outlined,
                    textos.detExportarCsv),
                opcion(_AccionProyecto.enviar, Icons.outgoing_mail,
                    textos.enviarCoordinador),
                opcion(_AccionProyecto.alimentacion, Icons.grass_outlined,
                    textos.alimentacionExcel),
                if (gestiona) ...[
                  const PopupMenuDivider(),
                  opcion(_AccionProyecto.editar, Icons.edit_outlined,
                      textos.proyectoEditar),
                  if (p.cerrado)
                    opcion(_AccionProyecto.reabrir, Icons.lock_open_outlined,
                        textos.proyectoReabrir)
                  else
                    opcion(_AccionProyecto.cerrar, Icons.lock_outline,
                        textos.proyectoCerrar),
                  opcion(_AccionProyecto.borrar, Icons.delete_outline,
                      textos.proyectoBorrar),
                ],
              ];
            },
          ),
        ],
      ),
      floatingActionButton: _puedeRegistrar
          ? FloatingActionButton.extended(
              onPressed: () => _anadir(3),
              icon: const Icon(Icons.add),
              label: Text(textos.proyApuntarGastoIngreso),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: rellenoSobreBarraSistema(
              context, const EdgeInsets.only(bottom: 104)),
          children: [
            if (p.cerrado)
              MaterialBanner(
                leading: const Icon(Icons.lock_outline),
                content: Text(textos.proyectoCerradoAviso(p.cerradoMs == null
                    ? '—'
                    : DateFormat('dd/MM/yyyy', idioma).format(
                        DateTime.fromMillisecondsSinceEpoch(p.cerradoMs!)))),
                actions: const [SizedBox.shrink()],
              ),
            _cabecera(textos, idioma),
            const SizedBox(height: 16),
            _chipsPeriodo(textos),
            if (balance != null) ...[
              const SizedBox(height: 16),
              _BloqueBalance(balance: balance),
              _titulo(textos.proyQuienAsume,
                  enlace: textos.proyReparto,
                  alPulsar: () => _abrirConvenio(0)),
              _quienAsume(textos, balance),
            ],
            if (hayPresupuesto) ...[
              _titulo(textos.proyPresupuestoAnexo,
                  enlace: textos.proyPartidas,
                  alPulsar: () => _abrirConvenio(1)),
              _presupuesto(textos, idioma, total),
            ],
            if (balance != null) _costeReal(textos, balance),
            if (total != null) ...[
              _titulo(textos.convenioFianza),
              _fianzaTarjetas(textos, total),
            ],
            _titulo(textos.convenioAcompanamiento,
                enlace: textos.proyTodo, alPulsar: () => _abrirConvenio(4)),
            _acompanamiento(textos, idioma),
            _titulo(textos.proyRentabilidad),
            _rentabilidad(textos, idioma),
            _titulo(textos.proyRegistros),
            _registros(textos),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline,
                    size: 18, color: context.esquemaZunbeltz.onSurfaceVariant),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(textos.convenioProvisional,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.esquemaZunbeltz.onSurfaceVariant)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconoAcompanamiento(String tipo) => switch (tipo) {
      'formacion' => Icons.school_outlined,
      'visita_referencia' => Icons.travel_explore,
      'asesoramiento' => Icons.support_agent,
      'reunion' => Icons.groups_outlined,
      'visita_finca' => Icons.agriculture_outlined,
      'visita_recibida' => Icons.waving_hand_outlined,
      'mercado' => Icons.storefront_outlined,
      'difusion' => Icons.campaign_outlined,
      'busqueda_canales' => Icons.alt_route,
      'apoyo_tareas' => Icons.handyman_outlined,
      _ => Icons.event_note_outlined,
    };

/// El bloque destacado: balance del test en grande sobre pino, con
/// ingresos y gastos del test debajo.
class _BloqueBalance extends StatelessWidget {
  const _BloqueBalance({required this.balance});

  final BalanceConvenio balance;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final estilos = Theme.of(context).textTheme;
    final oscuro = context.esquemaZunbeltz.brightness == Brightness.dark;
    final fondo = oscuro ? const Color(0xFF0E3A2B) : colorCuadroPino;
    const tinta = Colors.white;
    final tintaSuave = Colors.white.withValues(alpha: 0.78);
    Widget cifra(String rotulo, int centimos) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rotulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: estilos.bodyMedium?.copyWith(color: tintaSuave)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(eurosRedondos(centimos),
                    style: estilos.headlineSmall
                        ?.copyWith(color: tinta, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        );
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: bordeDestacadoZunbeltz,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(textos.balanceTest,
            style: estilos.titleSmall?.copyWith(color: tintaSuave)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(eurosConSigno(balance.balanceTestCentimos),
              style: estilos.displayMedium
                  ?.copyWith(color: tinta, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 12),
        Row(children: [
          cifra(textos.balanceIngresos, balance.ingresosCentimos),
          const SizedBox(width: 12),
          cifra(textos.proyGastosDelTest, balance.gastosTestCentimos),
        ]),
        const SizedBox(height: 14),
        Text(textos.proySinAmortizaciones,
            style: estilos.bodySmall?.copyWith(color: tintaSuave)),
      ]),
    );
  }
}

class _ListaProduccion extends StatelessWidget {
  const _ListaProduccion(
      {required this.items,
      required this.idioma,
      required this.textos,
      this.alBorrar});
  final List<RegistroActividad> items;
  final Future<void> Function(int id)? alBorrar;
  final String idioma;
  final AppLocalizations textos;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Center(child: Text(textos.detSinDatos));
    final f = DateFormat('dd/MM/yyyy', idioma);
    return ListView(children: [
      for (final a in items)
        ListTile(
          onLongPress:
              alBorrar == null || a.id == null ? null : () => alBorrar!(a.id!),
          leading: const Icon(Icons.grass_outlined),
          title: Text(
              '${buscarOpcion(tiposActividad, a.tipo)?.etiqueta(idioma) ?? a.tipo} · ${cantidadBonita(a.cantidad)} ${unidadActividad(a.tipo, idioma)}'),
          subtitle:
              Text(f.format(DateTime.fromMillisecondsSinceEpoch(a.fechaMs))),
        ),
    ]);
  }
}

class _ListaVentas extends StatelessWidget {
  const _ListaVentas(
      {required this.items,
      required this.idioma,
      required this.textos,
      this.alBorrar});
  final List<RegistroComercializacion> items;
  final Future<void> Function(int id)? alBorrar;
  final String idioma;
  final AppLocalizations textos;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Center(child: Text(textos.detSinDatos));
    final f = DateFormat('dd/MM/yyyy', idioma);
    return ListView(children: [
      for (final c in items)
        ListTile(
          onLongPress:
              alBorrar == null || c.id == null ? null : () => alBorrar!(c.id!),
          leading: const Icon(Icons.storefront_outlined),
          title: Text(c.producto.isEmpty
              ? (buscarOpcion(canalesComercializacion, c.canal)
                      ?.etiqueta(idioma) ??
                  c.canal)
              : c.producto),
          subtitle: Text(
              '${buscarOpcion(canalesComercializacion, c.canal)?.etiqueta(idioma) ?? c.canal} · ${cantidadBonita(c.cantidad)} ${c.unidad} · ${f.format(DateTime.fromMillisecondsSinceEpoch(c.fechaMs))}'),
          trailing: Text('${eurosDesdeCentimos(c.ingresoCentimos)} €',
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
    ]);
  }
}

class _ListaValidacion extends StatelessWidget {
  const _ListaValidacion(
      {required this.items,
      required this.idioma,
      required this.textos,
      this.alBorrar});
  final List<ValidacionProducto> items;
  final Future<void> Function(int id)? alBorrar;
  final String idioma;
  final AppLocalizations textos;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Center(child: Text(textos.detSinDatos));
    final f = DateFormat('dd/MM/yyyy', idioma);
    return ListView(children: [
      for (final v in items)
        ListTile(
          onLongPress:
              alBorrar == null || v.id == null ? null : () => alBorrar!(v.id!),
          leading: const Icon(Icons.verified_outlined),
          title: Text(v.descripcion.isEmpty
              ? (buscarOpcion(resultadosValidacion, v.resultado)
                      ?.etiqueta(idioma) ??
                  v.resultado)
              : v.descripcion),
          subtitle: Text([
            buscarOpcion(resultadosValidacion, v.resultado)?.etiqueta(idioma) ??
                v.resultado,
            if (v.valoracion > 0) '${v.valoracion}/5',
            f.format(DateTime.fromMillisecondsSinceEpoch(v.fechaMs)),
          ].join(' · ')),
        ),
    ]);
  }
}

class _ListaApuntes extends StatelessWidget {
  const _ListaApuntes(
      {required this.items,
      required this.idioma,
      required this.textos,
      this.alBorrar});
  final List<ApunteEconomico> items;
  final Future<void> Function(int id)? alBorrar;
  final String idioma;
  final AppLocalizations textos;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Center(child: Text(textos.detSinDatos));
    final f = DateFormat('dd/MM/yyyy', idioma);
    return ListView(children: [
      for (final a in items)
        ListTile(
          onLongPress:
              alBorrar == null || a.id == null ? null : () => alBorrar!(a.id!),
          leading: Icon(
              a.tipo == 'ingreso' ? Icons.south_west : Icons.north_east,
              color: a.tipo == 'ingreso'
                  ? context.coloresZunbeltz.hecha
                  : context.coloresZunbeltz.bloqueada),
          title: Text(a.concepto.isNotEmpty
              ? a.concepto
              : a.partida.isNotEmpty
                  ? etiquetaPartida(a.categoria, a.partida, idioma)
                  : (buscarOpcion(tiposApunte, a.tipo)?.etiqueta(idioma) ??
                      a.tipo)),
          subtitle: Text([
            f.format(DateTime.fromMillisecondsSinceEpoch(a.fechaMs)),
            buscarOpcion(categoriasDe(a.tipo), a.categoria)?.etiqueta(idioma) ??
                a.categoria,
            if (a.partida.isNotEmpty && a.concepto.isNotEmpty)
              etiquetaPartida(a.categoria, a.partida, idioma),
          ].where((parte) => parte.isNotEmpty).join(' · ')),
          trailing: Text('${eurosDesdeCentimos(a.importeCentimos)} €',
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
    ]);
  }
}

class _DesgloseIva extends StatelessWidget {
  const _DesgloseIva({
    required this.desgloseGastos,
    required this.ivaTotales,
    required this.idioma,
    required this.textos,
  });

  final DesgloseGastos desgloseGastos;
  final (int, int) ivaTotales;
  final String idioma;
  final AppLocalizations textos;

  @override
  Widget build(BuildContext context) {
    final (soportado, repercutido) = ivaTotales;
    return ExpansionTile(
      title: Text(textos.detDesgloseGastos),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        for (final bloque in desgloseGastos.bloques) ...[
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Row(children: [
              Expanded(
                child: Text(
                    buscarOpcion(categoriasGasto, bloque)?.etiqueta(idioma) ??
                        bloque,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text('${eurosDesdeCentimos(desgloseGastos.totalDe(bloque))} €',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
          ),
          for (final partida in desgloseGastos.partidasDe(bloque))
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
              child: Row(children: [
                Expanded(
                  child: Text(partida.key.isEmpty
                      ? textos.apuSinPartida
                      : etiquetaPartida(bloque, partida.key, idioma)),
                ),
                Text('${eurosDesdeCentimos(partida.value)} €'),
              ]),
            ),
        ],
        const Divider(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(textos.detIvaSoportado),
          Text('${eurosDesdeCentimos(soportado)} €'),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(textos.detIvaRepercutido),
          Text('${eurosDesdeCentimos(repercutido)} €'),
        ]),
        const SizedBox(height: 6),
        Text(textos.ivaNoFiscal, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

enum _AccionProyecto {
  convenio,
  calculadora,
  csv,
  enviar,
  alimentacion,
  editar,
  cerrar,
  reabrir,
  borrar,
}
