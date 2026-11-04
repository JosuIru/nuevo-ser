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

  @override
  Widget build(BuildContext context) {
    // Antes: si _cargando == true, devolvíamos Scaffold pantalla
    // completa con spinner → tarjeta meteo invisible mientras
    // cargaba la BD. Ahora pintamos la pantalla siempre; la tarjeta
    // meteo tiene su propio FutureBuilder y los bloques que
    // dependen de la BD se muestran cuando _cargando vuelve a false.
    final ahora = DateTime.now();
    final mesActual = ahora.month;
    final cultivosActivos = _conteoPorCultivo.keys.toList()..sort();
    final tareasPorCultivo = <String, List<String>>{};
    for (final cultivoId in cultivosActivos) {
      final tareas = tareasParaCultivoEnMes(cultivoId, mesActual);
      if (tareas.isNotEmpty) tareasPorCultivo[cultivoId] = tareas;
    }
    final saludo = _saludo(ahora.hour);
    return Scaffold(
      appBar: AppBar(
        title: Text(saludo),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: SoleraL10n.t('agro.guia_cultivos_plagas'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PantallaGuia()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Aviso de versión nueva (no ocupa sitio si no hay).
            AvisoActualizaciones(
              config: configActualizacionesMonorepo('agro'),
              nombreApp: 'Larrea',
              margen: const EdgeInsets.only(bottom: 12),
            ),
            Text(
              DateFormat.yMMMMEEEEd(SoleraL10n.idioma).format(ahora).replaceFirstMapped(
                    RegExp(r'^.'),
                    (m) => m.group(0)!.toUpperCase(),
                  ),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
                _nombreFincaActiva == null
                    ? SoleraL10n.t('agro.en_todas_las_fincas')
                    : SoleraL10n.tf('agro.en_finca', {'finca': _nombreFincaActiva}),
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            const TarjetaResumenMeteo(),
            const SizedBox(height: 12),
            if (_incidenciasAbiertas.isNotEmpty) _BloqueIncidencias(incidencias: _incidenciasAbiertas),
            if (tareasPorCultivo.isNotEmpty) ...[
              const SizedBox(height: 12),
              _BloqueQueToca(
                mes: mesActual,
                tareasPorCultivo: tareasPorCultivo,
                conteoPorCultivo: _conteoPorCultivo,
              ),
            ],
            const SizedBox(height: 12),
            _BloqueResumen(
              totalPlantas: _conteoPorCultivo.values.fold<int>(0, (a, b) => a + b),
              kilosUltimos30: _kilosUltimos30Dias,
              numCosechasUltimos30: _numCosechasUltimos30Dias,
            ),
            if (_conteoPorCultivo.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    '${SoleraL10n.t('agro.aun_no_hay_plantas')}\n${SoleraL10n.t('agro.ve_al_mapa_anadir_aqui')}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _saludo(int hora) {
    if (hora < 6) return SoleraL10n.t('agro.madrugada');
    if (hora < 12) return SoleraL10n.t('agro.buenos_dias');
    if (hora < 19) return SoleraL10n.t('agro.buenas_tardes');
    return SoleraL10n.t('agro.buenas_noches');
  }
}

class _BloqueIncidencias extends StatelessWidget {
  final List<Incidencia> incidencias;
  const _BloqueIncidencias({required this.incidencias});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Color(0xFFE65100)),
                const SizedBox(width: 8),
                Text(
                  SoleraL10n.tf('agro.incidencias_abiertas_n', {'n': incidencias.length}),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final i in incidencias.take(5))
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.bug_report, color: Color(0xFFE65100)),
                title: Text(i.diagnostico.isEmpty ? _nombreTipoIncidencia(i.tipo).toUpperCase() : i.diagnostico),
                subtitle: Text([
                  DateFormat('dd MMM', SoleraL10n.idioma).format(DateTime.fromMillisecondsSinceEpoch(i.fechaMs)),
                  if (i.severidad != null) SoleraL10n.tf('agro.severidad_abrev_n', {'n': i.severidad}),
                ].join(' · ')),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PantallaFichaPlanta(plantaId: i.plantaId)),
                ),
              ),
            if (incidencias.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(SoleraL10n.tf('agro.y_n_mas', {'n': incidencias.length - 5}), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ),
          ],
        ),
      ),
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
    final nombreMes = DateFormat('LLLL', SoleraL10n.idioma).format(DateTime(2000, mes, 1));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Color(0xFF558B2F)),
                const SizedBox(width: 8),
                Text(
                  SoleraL10n.tf('agro.que_toca_en_mes', {'mes': '${nombreMes[0].toUpperCase()}${nombreMes.substring(1)}'}),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              SoleraL10n.t('agro.calendario_orientativo_iberia'),
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            for (final entrada in tareasPorCultivo.entries) ...[
              _BloqueCultivoTareas(
                cultivoId: entrada.key,
                tareas: entrada.value,
                numPlantas: conteoPorCultivo[entrada.key] ?? 0,
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _BloqueCultivoTareas extends StatelessWidget {
  final String cultivoId;
  final List<String> tareas;
  final int numPlantas;

  const _BloqueCultivoTareas({
    required this.cultivoId,
    required this.tareas,
    required this.numPlantas,
  });

  @override
  Widget build(BuildContext context) {
    final cultivo = cultivoPorId(cultivoId);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cultivo.color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cultivo.color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(cultivo.icono, color: cultivo.color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${cultivo.nombreVisible} · ${numPlantas == 1 ? SoleraL10n.t('agro.una_planta') : SoleraL10n.tf('agro.plantas_n', {'n': numPlantas})}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final t in tareas)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(child: Text(t, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BloqueResumen extends StatelessWidget {
  final int totalPlantas;
  final double kilosUltimos30;
  final int numCosechasUltimos30;

  const _BloqueResumen({
    required this.totalPlantas,
    required this.kilosUltimos30,
    required this.numCosechasUltimos30,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: _Estadistica(
                etiqueta: SoleraL10n.t('agro.plantas'),
                valor: '$totalPlantas',
                icono: Icons.eco,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Estadistica(
                etiqueta: SoleraL10n.t('agro.cosecha_30_dias'),
                valor: kilosUltimos30 == 0 ? '—' : '${kilosUltimos30.toStringAsFixed(1)} kg',
                icono: Icons.shopping_basket,
                color: const Color(0xFF689F38),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Estadistica(
                etiqueta: SoleraL10n.t('agro.registros'),
                valor: '$numCosechasUltimos30',
                icono: Icons.format_list_numbered,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Estadistica extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final IconData icono;
  final Color color;
  const _Estadistica({required this.etiqueta, required this.valor, required this.icono, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, color: color),
        const SizedBox(height: 4),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(etiqueta, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
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
