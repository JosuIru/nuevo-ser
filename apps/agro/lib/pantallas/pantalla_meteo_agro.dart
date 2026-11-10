import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../estado/finca_activa.dart';
import '../modelos/finca.dart';
import '../modelos/planta.dart';
import '../utiles/permisos_gps.dart';

class PantallaMeteoAgro extends StatefulWidget {
  const PantallaMeteoAgro({super.key});

  @override
  State<PantallaMeteoAgro> createState() => _PantallaMeteoAgroState();
}

class _PantallaMeteoAgroState extends State<PantallaMeteoAgro> {
  final _servicio = ServicioMeteoAgro();
  final _persistenciaFinca = FincaActivaPersistida();
  Future<PrevisionAgro>? _futuro;
  _DestinoMeteo? _destino;
  String get _origen =>
      _destino?.nombreVisible ?? SoleraL10n.t('agro.origen_ubicacion_trabajo');

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<PrevisionAgro> _cargar() async {
    final destino = await _resolverDestino();
    _destino = destino;
    return _servicio.obtener(
      latitud: destino.latitud,
      longitud: destino.longitud,
    );
  }

  Future<_DestinoMeteo> _resolverDestino() async {
    final db = BaseDatosAgro.instancia;
    final fincaActivaId = await _persistenciaFinca.cargar();
    final Finca? finca = fincaActivaId == null
        ? null
        : await db.obtenerFinca(fincaActivaId);
    if (finca?.latitudCentroide != null && finca?.longitudCentroide != null) {
      return _DestinoMeteo(
        nombreFinca: finca!.nombre,
        latitud: finca.latitudCentroide!,
        longitud: finca.longitudCentroide!,
      );
    }
    final plantas = await db.listarPlantas(fincaId: fincaActivaId);
    final centroPlantas = _centroPlantas(plantas);
    if (centroPlantas != null) return centroPlantas;

    final permitido = await asegurarPermisoUbicacion();
    if (permitido) {
      final ultima = await Geolocator.getLastKnownPosition();
      if (ultima != null) {
        return _DestinoMeteo(
          claveOrigen: 'agro.origen_gps_reciente',
          latitud: ultima.latitude,
          longitud: ultima.longitude,
        );
      }
      final pos = await Geolocator.getCurrentPosition().timeout(
        const Duration(seconds: 8),
      );
      return _DestinoMeteo(
        claveOrigen: 'agro.origen_gps_actual',
        latitud: pos.latitude,
        longitud: pos.longitude,
      );
    }
    return const _DestinoMeteo(
      claveOrigen: 'agro.origen_centro_referencia',
      latitud: 40.4,
      longitud: -3.7,
    );
  }

  _DestinoMeteo? _centroPlantas(List<Planta> plantas) {
    if (plantas.isEmpty) return null;
    final lat =
        plantas.map((p) => p.latitud).reduce((a, b) => a + b) / plantas.length;
    final lng =
        plantas.map((p) => p.longitud).reduce((a, b) => a + b) / plantas.length;
    return _DestinoMeteo(
      claveOrigen: 'agro.origen_centro_plantas',
      latitud: lat,
      longitud: lng,
    );
  }

  Future<void> _refrescar() async {
    setState(() => _futuro = _cargar());
    await _futuro;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('agro.meteo_agro'))),
      body: FutureBuilder<PrevisionAgro>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _EstadoError(alReintentar: _refrescar);
          }
          final prevision = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refrescar,
            child: ListView(
              padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
              children: [
                _CabeceraMeteo(origen: _origen, prevision: prevision),
                const SizedBox(height: 12),
                if (prevision.hoy != null) _PanelDecision(dia: prevision.hoy!),
                const SizedBox(height: 12),
                for (final dia in prevision.dias) ...[
                  _TarjetaDiaMeteo(dia: dia),
                  const SizedBox(height: 8),
                ],
                const AtribucionMeteo(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CabeceraMeteo extends StatelessWidget {
  final String origen;
  final PrevisionAgro prevision;

  const _CabeceraMeteo({required this.origen, required this.prevision});

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
            Text(
              SoleraL10n.t('agro.prevision_orientativa'),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelDecision extends StatelessWidget {
  final DiaMeteoAgro dia;

  const _PanelDecision({required this.dia});

  @override
  Widget build(BuildContext context) {
    final avisos = <_AvisoMeteo>[
      if (dia.riesgoHelada)
        _AvisoMeteo(
          Icons.ac_unit,
          SoleraL10n.t('agro.riesgo_de_helada'),
          SoleraL10n.t('agro.riesgo_helada_cuerpo'),
        ),
      if (dia.malDiaTratamiento)
        _AvisoMeteo(
          Icons.science,
          SoleraL10n.t('agro.tratamientos_delicados'),
          SoleraL10n.t('agro.tratamientos_delicados_cuerpo'),
        ),
      if (dia.estresHidrico)
        _AvisoMeteo(
          Icons.water_drop,
          SoleraL10n.t('agro.alta_demanda_hidrica'),
          SoleraL10n.t('agro.alta_demanda_hidrica_cuerpo'),
        ),
      if (dia.vueloAbejasLimitado)
        _AvisoMeteo(
          Icons.hive,
          SoleraL10n.t('agro.vuelo_abejas_limitado'),
          SoleraL10n.t('agro.vuelo_abejas_limitado_cuerpo'),
        ),
    ];
    if (avisos.isEmpty) {
      avisos.add(
        _AvisoMeteo(
          Icons.check_circle,
          SoleraL10n.t('agro.ventana_razonable'),
          SoleraL10n.t('agro.ventana_razonable_cuerpo'),
        ),
      );
    }
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (final aviso in avisos)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(aviso.icono),
                title: Text(
                  aviso.titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(aviso.cuerpo),
              ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaDiaMeteo extends StatelessWidget {
  final DiaMeteoAgro dia;

  const _TarjetaDiaMeteo({required this.dia});

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('EEE d MMM', SoleraL10n.idioma).format(dia.fecha);
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
                _DatoMeteo(
                  icono: Icons.thermostat,
                  texto: '${_fmt(dia.tempMin)} / ${_fmt(dia.tempMax)} °C',
                ),
                _DatoMeteo(
                  icono: Icons.water,
                  texto:
                      '${_fmt(dia.lluviaMm)} mm · ${_fmt(dia.probLluviaMax)} %',
                ),
                _DatoMeteo(
                  icono: Icons.air,
                  texto:
                      '${_fmt(dia.vientoMaxKmh)} km/h · ${SoleraL10n.tf('agro.racha_n', {'n': _fmt(dia.rachaMaxKmh)})}',
                ),
                _DatoMeteo(
                  icono: Icons.opacity,
                  texto: SoleraL10n.tf('agro.humedad_relativa_n', {'n': _fmt(dia.humedadMedia)}),
                ),
                _DatoMeteo(
                  icono: Icons.wb_sunny,
                  texto: 'ET0 ${_fmt(dia.et0Mm)} mm',
                ),
                _DatoMeteo(
                  icono: Icons.grass,
                  texto:
                      SoleraL10n.tf('agro.suelo_temp_humedad', {
                        'temp': _fmt(dia.sueloTemp6cmMedia),
                        'humedad': _fmt(dia.sueloHumedad3a9Media, decimales: 2),
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(double? v, {int decimales = 1}) =>
      v == null ? '--' : formatearNumero(v, decimales: decimales);
}

class _DatoMeteo extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _DatoMeteo({required this.icono, required this.texto});

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
            Text(SoleraL10n.t('agro.no_se_pudo_cargar_prevision')),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: alReintentar,
              icon: const Icon(Icons.refresh),
              label: Text(SoleraL10n.t('agro.reintentar')),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisoMeteo {
  final IconData icono;
  final String titulo;
  final String cuerpo;

  const _AvisoMeteo(this.icono, this.titulo, this.cuerpo);
}

class _DestinoMeteo {
  /// Nombre de la finca, o null si el destino es otro origen.
  final String? nombreFinca;

  /// Clave de traducción del origen cuando no es una finca.
  final String? claveOrigen;
  final double latitud;
  final double longitud;

  const _DestinoMeteo({
    this.nombreFinca,
    this.claveOrigen,
    required this.latitud,
    required this.longitud,
  });

  String get nombreVisible =>
      nombreFinca ?? SoleraL10n.t(claveOrigen ?? 'agro.origen_ubicacion_trabajo');
}
