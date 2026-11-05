import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../datos/catalogo_cultivos.dart';
import '../datos/fenologia.dart';
import '../estado/finca_activa.dart';
import '../modelos/incidencia.dart';
import 'pantalla_ficha_planta.dart';
import 'pantalla_guia.dart';
import 'widgets/tarjeta_resumen_meteo.dart';

/// Pantalla "Hoy" — primera pestaña del NavBar. Resumen activo de:
/// - Incidencias abiertas (acción inmediata).
/// - Qué toca este mes según los cultivos que el usuario tiene
///   plantados (calendario fenológico orientativo).
/// - Próxima actividad estimada (kg cosechados últimos 30 días para
///   cultivos en plena campaña).
///
/// Diseño: la pestaña "Hoy" entra antes que el mapa porque es lo que
/// el agricultor quiere ver al abrir la app — qué ha pasado, qué tengo
/// que hacer hoy. El mapa sigue siendo la pestaña de exploración.
class PantallaHoy extends StatefulWidget {
  const PantallaHoy({super.key});

  @override
  State<PantallaHoy> createState() => _PantallaHoyState();
}

class _PantallaHoyState extends State<PantallaHoy> {
  final _persistenciaFinca = FincaActivaPersistida();
  bool _cargando = true;
  /// Nombre de la finca activa; null = todas las fincas.
  String? _nombreFincaActiva;
  List<Incidencia> _incidenciasAbiertas = [];
  Map<String, int> _conteoPorCultivo = {};
  double _kilosUltimos30Dias = 0;
  int _numCosechasUltimos30Dias = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    // try/finally garantiza que _cargando vuelve a false aunque una
    // query de BD falle (BD vacía recién migrada, foto rota en alguna
    // tabla, lo que sea). Antes una excepción aquí dejaba la pantalla
    // Hoy con spinner eterno y la tarjeta meteo nunca llegaba a
    // renderizarse.
    try {
      final db = BaseDatosAgro.instancia;
      final fincaActivaId = await _persistenciaFinca.cargar();
      final fincas = await db.listarFincas();
      final incidencias = await db.listarIncidenciasAbiertas(fincaId: fincaActivaId);
      final conteo = await db.contarPlantasPorCultivo(fincaId: fincaActivaId);
      final plantas = await db.listarPlantas(fincaId: fincaActivaId);
      final hace30 = DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
      double kilos = 0;
      int n = 0;
      for (final p in plantas) {
        final cosechas = await db.listarCosechasDePlanta(p.id!);
        for (final c in cosechas) {
          if (c.fechaMs < hace30) continue;
          kilos += c.kilos ?? 0;
          n++;
        }
      }
      final fincaActiva = fincas.where((f) => f.id == fincaActivaId).firstOrNull;
      if (!mounted) return;
      setState(() {
        _nombreFincaActiva = fincaActiva?.nombre;
        _incidenciasAbiertas = incidencias;
        _conteoPorCultivo = conteo;
        _kilosUltimos30Dias = kilos;
        _numCosechasUltimos30Dias = n;
      });
    } catch (_) {
      // BD vacía / migrando / corrupta: dejamos los valores por defecto
      // y dejamos que la UI se pinte (meteo + bloques vacíos).
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String get _fechaDeHoy {
    final texto = DateFormat.MMMMEEEEd(SoleraL10n.idioma).format(DateTime.now());
    return texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    // La pantalla se pinta siempre (también mientras carga la BD): la
    // tarjeta meteo tiene su propio FutureBuilder y los bloques que
    // dependen de la BD aparecen cuando _cargando vuelve a false.
    final tema = Theme.of(context);
    final colores = context.coloresSolera;
    final mesActual = DateTime.now().month;
    final cultivosActivos = _conteoPorCultivo.keys.toList()..sort();
    final tareasPorCultivo = <String, List<String>>{};
    for (final cultivoId in cultivosActivos) {
      final tareas = tareasParaCultivoEnMes(cultivoId, mesActual);
      if (tareas.isNotEmpty) tareasPorCultivo[cultivoId] = tareas;
    }
    final totalPlantas = _conteoPorCultivo.values.fold<int>(0, (a, b) => a + b);
    final estiloTextoSecundario =
        tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _cargar,
        edgeOffset: MediaQuery.paddingOf(context).top,
        child: ListView(
          padding: rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 24)),
          children: [
            CabeceraHoySolera(
              titulo: SoleraL10n.t('agro.hoy'),
              fecha: _fechaDeHoy,
              acciones: [
                IconButton(
                  icon: const Icon(Icons.menu_book_outlined),
                  tooltip: SoleraL10n.t('agro.guia_cultivos_plagas'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PantallaGuia()),
                  ),
                ),
              ],
              cifras: [
                CifraCabecera(
                  valor: '${_incidenciasAbiertas.length}',
                  etiqueta: SoleraL10n.t('agro.incidencias_abiertas'),
                ),
                CifraCabecera(
                  valor: '$totalPlantas',
                  etiqueta: SoleraL10n.t('agro.plantas'),
                ),
                CifraCabecera(
                  valor: _kilosUltimos30Dias == 0
                      ? '—'
                      : '${formatearNumero(_kilosUltimos30Dias, decimales: 1)} kg',
                  etiqueta: SoleraL10n.t('agro.cosecha_30_dias'),
                  detalle: _numCosechasUltimos30Dias == 0
                      ? null
                      : SoleraL10n.tf('agro.cosechas_n', {'n': _numCosechasUltimos30Dias}),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Aviso de versión nueva (no ocupa sitio si no hay).
                  AvisoActualizaciones(
                    config: configActualizacionesMonorepo('agro'),
                    nombreApp: 'Larrea',
                    margen: const EdgeInsets.only(bottom: 4),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                    child: Text(
                      _nombreFincaActiva == null
                          ? SoleraL10n.t('agro.en_todas_las_fincas')
                          : SoleraL10n.tf('agro.en_finca', {'finca': _nombreFincaActiva}),
                      style: estiloTextoSecundario,
                    ),
                  ),
                  const TarjetaResumenMeteo(),
                  if (_incidenciasAbiertas.isNotEmpty) _BloqueIncidencias(incidencias: _incidenciasAbiertas),
                  if (tareasPorCultivo.isNotEmpty)
                    _BloqueQueToca(
                      mes: mesActual,
                      tareasPorCultivo: tareasPorCultivo,
                      conteoPorCultivo: _conteoPorCultivo,
                    ),
                  if (!_cargando && _conteoPorCultivo.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(children: [
                        Icon(Icons.eco_outlined, size: 40, color: tema.colorScheme.onSurfaceVariant),
                        const SizedBox(height: 8),
                        Text(
                          '${SoleraL10n.t('agro.aun_no_hay_plantas')}\n${SoleraL10n.t('agro.ve_al_mapa_anadir_aqui')}',
                          textAlign: TextAlign.center,
                          style: estiloTextoSecundario,
                        ),
                      ]),
                    )
                  else if (!_cargando && _incidenciasAbiertas.isEmpty && tareasPorCultivo.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(children: [
                        Icon(Icons.task_alt, size: 40, color: colores.hecho),
                        const SizedBox(height: 8),
                        Text(
                          SoleraL10n.t('agro.hoy_nada_pendiente'),
                          textAlign: TextAlign.center,
                          style: estiloTextoSecundario,
                        ),
                      ]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BloqueIncidencias extends StatelessWidget {
  final List<Incidencia> incidencias;
  const _BloqueIncidencias({required this.incidencias});

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresSolera;
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloBloqueSolera(SoleraL10n.t('agro.incidencias_abiertas')),
        Card(
          child: Column(
            children: [
              for (final incidencia in incidencias.take(5))
                ListTile(
                  leading: Icon(Icons.bug_report_outlined, color: colores.peligro),
                  title: Text(incidencia.diagnostico.isEmpty
                      ? _nombreTipoIncidencia(incidencia.tipo).toUpperCase()
                      : incidencia.diagnostico),
                  subtitle: Text([
                    DateFormat('dd MMM', SoleraL10n.idioma)
                        .format(DateTime.fromMillisecondsSinceEpoch(incidencia.fechaMs)),
                    if (incidencia.severidad != null)
                      SoleraL10n.tf('agro.severidad_abrev_n', {'n': incidencia.severidad}),
                  ].join(' · ')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PantallaFichaPlanta(plantaId: incidencia.plantaId)),
                  ),
                ),
              if (incidencias.length > 5)
                ListTile(
                  dense: true,
                  title: Text(
                    SoleraL10n.tf('agro.y_n_mas', {'n': incidencias.length - 5}),
                    style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BloqueQueToca extends StatelessWidget {
  final int mes;
  final Map<String, List<String>> tareasPorCultivo;
  final Map<String, int> conteoPorCultivo;

  const _BloqueQueToca({
    required this.mes,
    required this.tareasPorCultivo,
    required this.conteoPorCultivo,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final nombreMes = DateFormat('LLLL', SoleraL10n.idioma).format(DateTime(2000, mes, 1));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloBloqueSolera(SoleraL10n.tf(
            'agro.que_toca_en_mes', {'mes': '${nombreMes[0].toUpperCase()}${nombreMes.substring(1)}'})),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final entrada in tareasPorCultivo.entries)
                _FilaCultivoTareas(
                  cultivoId: entrada.key,
                  tareas: entrada.value,
                  numPlantas: conteoPorCultivo[entrada.key] ?? 0,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  SoleraL10n.t('agro.calendario_orientativo_iberia'),
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilaCultivoTareas extends StatelessWidget {
  final String cultivoId;
  final List<String> tareas;
  final int numPlantas;

  const _FilaCultivoTareas({
    required this.cultivoId,
    required this.tareas,
    required this.numPlantas,
  });

  @override
  Widget build(BuildContext context) {
    final cultivo = cultivoPorId(cultivoId);
    return ListTile(
      leading: Icon(cultivo.icono, color: cultivo.color),
      title: Text(
        '${cultivo.nombreVisible} · ${numPlantas == 1 ? SoleraL10n.t('agro.una_planta') : SoleraL10n.tf('agro.plantas_n', {'n': numPlantas})}',
      ),
      subtitle: Text(tareas.map((tarea) => '•  $tarea').join('\n')),
    );
  }
}

/// Nombre visible del tipo de incidencia guardado en BD
/// ('plaga' | 'enfermedad' | 'estres' | 'fisiologico' | 'otro').
String _nombreTipoIncidencia(String tipo) => switch (tipo) {
      'plaga' => SoleraL10n.t('agro.tipo_incidencia_plaga'),
      'enfermedad' => SoleraL10n.t('agro.tipo_incidencia_enfermedad'),
      'estres' => SoleraL10n.t('agro.tipo_incidencia_estres'),
      'fisiologico' => SoleraL10n.t('agro.tipo_incidencia_fisiologico'),
      'otro' => SoleraL10n.t('agro.tipo_incidencia_otro'),
      _ => tipo,
    };
