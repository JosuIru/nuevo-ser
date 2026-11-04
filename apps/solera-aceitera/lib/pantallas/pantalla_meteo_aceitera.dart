import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../servicios/servicio_meteo_aceitera.dart';
import 'widgets/tarjeta_resumen_meteo.dart';

/// Pantalla completa de meteo del olivar — previsión a 7 días con
/// avisos olivareros: helada, mosca del olivo, golpe de calor en
/// aceituna, ventana de tratamiento y de recolección, demanda hídrica.
///
/// Reusa la misma resolución de destino que la tarjeta resumen
/// (centroide de parcelas → GPS reciente → fallback Jaén).
class PantallaMeteoAceitera extends StatefulWidget {
  const PantallaMeteoAceitera({super.key});

  @override
  State<PantallaMeteoAceitera> createState() => _PantallaMeteoAceiteraState();
}

class _PantallaMeteoAceiteraState extends State<PantallaMeteoAceitera> {
  final _servicio = ServicioMeteoAceitera();
  Future<PrevisionAceitera>? _futuro;
  String _origen = 'olivar';

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<PrevisionAceitera> _cargar() async {
    final destino = await resolverDestinoMeteoAceitera();
    _origen = destino.nombre;
    return _servicio.obtener(
      latitud: destino.latitud,
      longitud: destino.longitud,
    );
  }

  Future<void> _refrescar() async {
    setState(() => _futuro = _cargar());
    await _futuro;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meteo olivar')),
      body: FutureBuilder<PrevisionAceitera>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return _EstadoError(alReintentar: _refrescar);
          final prevision = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refrescar,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Cabecera(origen: _origen, prevision: prevision),
                const SizedBox(height: 12),
                if (prevision.hoy != null) _PanelDecisionOlivar(dia: prevision.hoy!),
                const SizedBox(height: 12),
                for (final dia in prevision.dias) ...[
                  _TarjetaDia(dia: dia),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
                Text(
                  'Datos de Open-Meteo (modelos ECMWF/GFS) — orientativos. '
                  'Para decisiones de tratamiento o recolección verifica con '
                  'la Estación de Avisos Fitosanitarios y AEMET de tu zona.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  final String origen;
  final PrevisionAceitera prevision;

  const _Cabecera({required this.origen, required this.prevision});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(origen, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${prevision.latitud.toStringAsFixed(5)}, ${prevision.longitud.toStringAsFixed(5)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Previsión orientativa para tratamientos, heladas, mosca del olivo, '
              'golpe de calor en aceituna, riego y ventanas de recolección.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelDecisionOlivar extends StatelessWidget {
  final DiaMeteoOlivar dia;

  const _PanelDecisionOlivar({required this.dia});

  @override
  Widget build(BuildContext context) {
    final consejos = consejosDelDia(dia);
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (final consejo in consejos)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(consejo.icono, color: consejo.color),
                title: Text(
                  consejo.titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(consejo.cuerpo),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConsejoOlivar {
  final IconData icono;
  final String titulo;
  final String cuerpo;
  final Color color;
  const _ConsejoOlivar(this.icono, this.titulo, this.cuerpo, this.color);
}

/// Consejos contextualizados al olivar para el día indicado. Los
/// avisos negativos (helada, mosca, golpe de calor…) tienen
/// prioridad; si no hay ninguno, devolvemos uno verde indicando
/// ventana razonable.
List<_ConsejoOlivar> consejosDelDia(DiaMeteoOlivar dia) {
  final consejos = <_ConsejoOlivar>[];
  if (dia.riesgoHelada) {
    consejos.add(const _ConsejoOlivar(
      Icons.ac_unit,
      'Riesgo de helada',
      'Olivos jóvenes y plantaciones de altura sufren con temperatura ≤0 °C. '
          'Vigila brotes y hojas amarillentas en los próximos días.',
      Color(0xFF1976D2),
    ));
  }
  if (dia.golpeCalorAceituna) {
    consejos.add(const _ConsejoOlivar(
      Icons.local_fire_department,
      'Golpe de calor en aceituna',
      'Temperatura ≥38 °C en envero provoca arrugado, mancha jabonosa y caída '
          'de fruto. Si tienes goteo, programa pulso largo nocturno.',
      Color(0xFFD84315),
    ));
  }
  if (dia.vueloMoscaOlivoActivo) {
    consejos.add(const _ConsejoOlivar(
      Icons.bug_report,
      'Vuelo activo de mosca del olivo',
      'Temperatura y humedad favorecen la actividad de Bactrocera oleae. '
          'Revisa trampeo masivo, mosqueros y picado en aceituna en envero o ya enverada.',
      Color(0xFFE65100),
    ));
  }
  if (dia.malDiaTratamiento) {
    consejos.add(const _ConsejoOlivar(
      Icons.science,
      'Tratamiento poco favorable',
      'Viento ≥18 km/h o lluvia (real o probable) provocan deriva, lavado y '
          'baja eficacia. Considera aplazar la aplicación con turboatomizador.',
      Color(0xFFE65100),
    ));
  }
  if (dia.estresHidrico) {
    consejos.add(const _ConsejoOlivar(
      Icons.water_drop,
      'Demanda hídrica alta',
      'ET0 elevada o déficit de presión de vapor alto. Si tienes goteo, '
          'programa riego de apoyo; en secano evita labores que aumenten estrés.',
      Color(0xFF0277BD),
    ));
  }
  if (dia.floracionEnRiesgo) {
    consejos.add(const _ConsejoOlivar(
      Icons.local_florist,
      'Floración en riesgo',
      'Humedad alta o lluvia durante la floración perjudica el cuajado. '
          'Controla repilo y prepara seguimiento del cuajado en próximas semanas.',
      Color(0xFFE65100),
    ));
  }
  if (dia.buenDiaRecoleccion && dia.fecha.month >= 10 && dia.fecha.month <= 2) {
    consejos.add(const _ConsejoOlivar(
      Icons.agriculture,
      'Día apto para recolección',
      'Sin lluvia significativa, viento moderado y temperatura por encima de '
          '5 °C. Buena ventana para vareo, vibrador o paraguas invertido.',
      Color(0xFF2E7D32),
    ));
  }
  if (consejos.isEmpty) {
    consejos.add(const _ConsejoOlivar(
      Icons.check_circle,
      'Ventana razonable',
      'Sin señales fuertes de helada, golpe de calor, mosca, deriva ni estrés '
          'hídrico. Día apto para labores normales en olivar.',
      Color(0xFF2E7D32),
    ));
  }
  return consejos;
}

class _TarjetaDia extends StatelessWidget {
  final DiaMeteoOlivar dia;

  const _TarjetaDia({required this.dia});

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('EEE d MMM', 'es_ES').format(dia.fecha);
    final avisos = avisosClaveOlivar(dia);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fecha.replaceFirstMapped(
                RegExp(r'^.'),
                (m) => m.group(0)!.toUpperCase(),
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Dato(
                    icono: Icons.thermostat,
                    texto: '${_fmt(dia.tempMin)} / ${_fmt(dia.tempMax)} °C'),
                _Dato(
                    icono: Icons.water,
                    texto:
                        '${_fmt(dia.lluviaMm)} mm · ${_fmt(dia.probLluviaMax)} %'),
                _Dato(
                    icono: Icons.air,
                    texto:
                        '${_fmt(dia.vientoMaxKmh)} km/h · racha ${_fmt(dia.rachaMaxKmh)}'),
                _Dato(
                    icono: Icons.opacity,
                    texto: 'HR ${_fmt(dia.humedadMedia)} %'),
                _Dato(
                    icono: Icons.wb_sunny,
                    texto: 'ET0 ${_fmt(dia.et0Mm)} mm'),
                _Dato(
                    icono: Icons.grass,
                    texto:
                        'Suelo ${_fmt(dia.sueloTemp6cmMedia)} °C · ${_fmt(dia.sueloHumedad3a9Media, decimales: 2)}'),
              ],
            ),
            if (avisos.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final aviso in avisos)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(aviso.icono, size: 16, color: aviso.color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          aviso.titulo,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  static String _fmt(double? v, {int decimales = 1}) =>
      v == null ? '--' : v.toStringAsFixed(decimales);
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _Dato({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icono, size: 18),
      label: Text(texto),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EstadoError extends StatelessWidget {
  final Future<void> Function() alReintentar;

  const _EstadoError({required this.alReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 42),
            const SizedBox(height: 12),
            const Text('No se pudo cargar la previsión.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: alReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
