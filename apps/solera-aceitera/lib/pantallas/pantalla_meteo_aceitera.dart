import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
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
  String _origen = '';

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<PrevisionAceitera> _cargar() async {
    final destino = await resolverDestinoMeteoAceitera();
    _origen = destino.claveNombre ?? destino.nombre;
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
      appBar: AppBar(title: Text(SoleraL10n.t('acei.meteo_olivar'))),
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
                  SoleraL10n.t('acei.meteo_fuente_datos'),
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
            Text(nombreDestinoMeteoVisible(origen), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${prevision.latitud.toStringAsFixed(5)}, ${prevision.longitud.toStringAsFixed(5)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              SoleraL10n.t('acei.meteo_cabecera_texto'),
              style: const TextStyle(fontSize: 12),
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
    consejos.add(_ConsejoOlivar(
      Icons.ac_unit,
      SoleraL10n.t('acei.consejo_riesgo_helada_titulo'),
      SoleraL10n.t('acei.consejo_riesgo_helada_texto'),
      const Color(0xFF1976D2),
    ));
  }
  if (dia.golpeCalorAceituna) {
    consejos.add(_ConsejoOlivar(
      Icons.local_fire_department,
      SoleraL10n.t('acei.consejo_golpe_calor_titulo'),
      SoleraL10n.t('acei.consejo_golpe_calor_texto'),
      const Color(0xFFD84315),
    ));
  }
  if (dia.vueloMoscaOlivoActivo) {
    consejos.add(_ConsejoOlivar(
      Icons.bug_report,
      SoleraL10n.t('acei.consejo_mosca_titulo'),
      SoleraL10n.t('acei.consejo_mosca_texto'),
      const Color(0xFFE65100),
    ));
  }
  if (dia.malDiaTratamiento) {
    consejos.add(_ConsejoOlivar(
      Icons.science,
      SoleraL10n.t('acei.consejo_tratamiento_titulo'),
      SoleraL10n.t('acei.consejo_tratamiento_texto'),
      const Color(0xFFE65100),
    ));
  }
  if (dia.estresHidrico) {
    consejos.add(_ConsejoOlivar(
      Icons.water_drop,
      SoleraL10n.t('acei.consejo_estres_hidrico_titulo'),
      SoleraL10n.t('acei.consejo_estres_hidrico_texto'),
      const Color(0xFF0277BD),
    ));
  }
  if (dia.floracionEnRiesgo) {
    consejos.add(_ConsejoOlivar(
      Icons.local_florist,
      SoleraL10n.t('acei.consejo_floracion_titulo'),
      SoleraL10n.t('acei.consejo_floracion_texto'),
      const Color(0xFFE65100),
    ));
  }
  if (dia.buenDiaRecoleccion && dia.fecha.month >= 10 && dia.fecha.month <= 2) {
    consejos.add(_ConsejoOlivar(
      Icons.agriculture,
      SoleraL10n.t('acei.consejo_recoleccion_titulo'),
      SoleraL10n.t('acei.consejo_recoleccion_texto'),
      const Color(0xFF2E7D32),
    ));
  }
  if (consejos.isEmpty) {
    consejos.add(_ConsejoOlivar(
      Icons.check_circle,
      SoleraL10n.t('acei.consejo_ventana_razonable_titulo'),
      SoleraL10n.t('acei.consejo_ventana_razonable_texto'),
      const Color(0xFF2E7D32),
    ));
  }
  return consejos;
}

class _TarjetaDia extends StatelessWidget {
  final DiaMeteoOlivar dia;

  const _TarjetaDia({required this.dia});

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('EEE d MMM', SoleraL10n.idioma == 'es' ? 'es_ES' : SoleraL10n.idioma).format(dia.fecha);
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
                        SoleraL10n.tf('acei.viento_racha', {'viento': _fmt(dia.vientoMaxKmh), 'racha': _fmt(dia.rachaMaxKmh)})),
                _Dato(
                    icono: Icons.opacity,
                    texto: SoleraL10n.tf('acei.humedad_relativa_corta', {'hr': _fmt(dia.humedadMedia)})),
                _Dato(
                    icono: Icons.wb_sunny,
                    texto: 'ET0 ${_fmt(dia.et0Mm)} mm'),
                _Dato(
                    icono: Icons.grass,
                    texto:
                        SoleraL10n.tf('acei.suelo_temp_humedad', {'temp': _fmt(dia.sueloTemp6cmMedia), 'humedad': _fmt(dia.sueloHumedad3a9Media, decimales: 2)})),
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
            Text(SoleraL10n.t('acei.no_se_pudo_cargar_prevision')),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: alReintentar,
              icon: const Icon(Icons.refresh),
              label: Text(SoleraL10n.t('acei.reintentar')),
            ),
          ],
        ),
      ),
    );
  }
}
