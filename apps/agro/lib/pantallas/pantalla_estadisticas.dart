import 'package:flutter/material.dart';

import '../datos/base_datos.dart';
import '../datos/catalogo_cultivos.dart';
import '../estado/finca_activa.dart';
import '../modelos/finca.dart';

/// Resúmenes agregados: nº de plantas por cultivo, kg cosechados por
/// año (campaña), incidencias abiertas. Sin librería de gráficos —
/// barras simples con CustomPaint mantendría dependencias bajas.
/// En F1 con barras de texto basta para validar la utilidad y luego
/// decidir si entra `fl_chart` u otro paquete real.
class PantallaEstadisticas extends StatefulWidget {
  const PantallaEstadisticas({super.key});

  @override
  State<PantallaEstadisticas> createState() => _PantallaEstadisticasState();
}

class _PantallaEstadisticasState extends State<PantallaEstadisticas> {
  final _persistenciaFinca = FincaActivaPersistida();
  List<Finca> _fincas = [];
  int? _fincaActivaId;

  Map<String, int> _conteoPorCultivo = {};
  Map<int, _ResumenCampana> _resumenesPorAno = {};
  int _incidenciasAbiertas = 0;

  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final db = BaseDatosAgro.instancia;
    final fincas = await db.listarFincas();
    final fincaActivaId = await _persistenciaFinca.cargar();
    final conteo = await db.contarPlantasPorCultivo(fincaId: fincaActivaId);
    final plantas = await db.listarPlantas(fincaId: fincaActivaId);
    final incidenciasAbiertas = await db.listarIncidenciasAbiertas(fincaId: fincaActivaId);

    // Agregamos cosechas por año = campaña.
    final resumenes = <int, _ResumenCampana>{};
    for (final p in plantas) {
      final cosechas = await db.listarCosechasDePlanta(p.id!);
      for (final c in cosechas) {
        final ano = DateTime.fromMillisecondsSinceEpoch(c.fechaMs).year;
        final r = resumenes.putIfAbsent(ano, () => _ResumenCampana(ano));
        r.kilos += c.kilos ?? 0;
        r.unidades += c.unidades ?? 0;
        r.numCosechas++;
      }
    }

    if (!mounted) return;
    setState(() {
      _fincas = fincas;
      _fincaActivaId = fincaActivaId;
      _conteoPorCultivo = conteo;
      _resumenesPorAno = resumenes;
      _incidenciasAbiertas = incidenciasAbiertas.length;
      _cargando = false;
    });
  }

  Future<void> _cambiarFincaActiva(int? nuevaId) async {
    await _persistenciaFinca.guardar(nuevaId);
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final totalPlantas = _conteoPorCultivo.values.fold<int>(0, (a, b) => a + b);
    final maxConteo = _conteoPorCultivo.values.fold<int>(0, (a, b) => a > b ? a : b);
    final anosOrdenados = _resumenesPorAno.keys.toList()..sort((a, b) => b.compareTo(a));
    final maxKilos = _resumenesPorAno.values.fold<double>(0, (a, b) => a > b.kilos ? a : b.kilos);

    return Scaffold(
      appBar: AppBar(
        title: DropdownButtonHideUnderline(
          child: DropdownButton<int?>(
            value: _fincaActivaId,
            isDense: true,
            onChanged: _cambiarFincaActiva,
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('Todas las fincas')),
              for (final f in _fincas) DropdownMenuItem<int?>(value: f.id, child: Text(f.nombre)),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Tarjeta(
              titulo: 'Total de plantas',
              valor: '$totalPlantas',
              color: Colors.green,
              icono: Icons.eco,
            ),
            const SizedBox(height: 12),
            _Tarjeta(
              titulo: 'Incidencias abiertas',
              valor: '$_incidenciasAbiertas',
              color: _incidenciasAbiertas == 0 ? Colors.grey : Colors.orange,
              icono: Icons.warning_amber,
            ),
            const SizedBox(height: 24),
            const Text('Plantas por cultivo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            if (_conteoPorCultivo.isEmpty)
              const Text('Aún no hay plantas registradas.', style: TextStyle(color: Colors.grey))
            else
              for (final entrada in _conteoPorCultivo.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
                _BarraConteo(
                  cultivoId: entrada.key,
                  conteo: entrada.value,
                  maxConteo: maxConteo,
                ),
            const SizedBox(height: 24),
            const Text('Cosecha por campaña', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            if (anosOrdenados.isEmpty)
              const Text('Aún no hay cosechas registradas.', style: TextStyle(color: Colors.grey))
            else
              for (final ano in anosOrdenados)
                _BarraCampana(
                  resumen: _resumenesPorAno[ano]!,
                  maxKilos: maxKilos,
                ),
          ],
        ),
      ),
    );
  }
}

class _ResumenCampana {
  final int ano;
  double kilos = 0;
  int unidades = 0;
  int numCosechas = 0;
  _ResumenCampana(this.ano);
}

class _Tarjeta extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color color;
  final IconData icono;
  const _Tarjeta({required this.titulo, required this.valor, required this.color, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, child: Icon(icono, color: Colors.white)),
        title: Text(titulo),
        trailing: Text(valor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _BarraConteo extends StatelessWidget {
  final String cultivoId;
  final int conteo;
  final int maxConteo;
  const _BarraConteo({required this.cultivoId, required this.conteo, required this.maxConteo});

  @override
  Widget build(BuildContext context) {
    final cultivo = cultivoPorId(cultivoId);
    final fraccion = maxConteo == 0 ? 0.0 : conteo / maxConteo;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(cultivo.icono, color: cultivo.color, size: 20),
          const SizedBox(width: 8),
          SizedBox(width: 110, child: Text(cultivo.nombreVisible, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(height: 18, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4))),
                FractionallySizedBox(
                  widthFactor: fraccion,
                  child: Container(height: 18, decoration: BoxDecoration(color: cultivo.color, borderRadius: BorderRadius.circular(4))),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 36, child: Text('$conteo', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _BarraCampana extends StatelessWidget {
  final _ResumenCampana resumen;
  final double maxKilos;
  const _BarraCampana({required this.resumen, required this.maxKilos});

  @override
  Widget build(BuildContext context) {
    final fraccion = maxKilos == 0 ? 0.0 : resumen.kilos / maxKilos;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text('${resumen.ano}', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: Stack(
              children: [
                Container(height: 24, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4))),
                FractionallySizedBox(
                  widthFactor: fraccion,
                  child: Container(height: 24, decoration: BoxDecoration(color: const Color(0xFF689F38), borderRadius: BorderRadius.circular(4))),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              [
                if (resumen.kilos > 0) '${resumen.kilos.toStringAsFixed(1)} kg',
                if (resumen.unidades > 0) '${resumen.unidades} ud',
              ].join(' · '),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
