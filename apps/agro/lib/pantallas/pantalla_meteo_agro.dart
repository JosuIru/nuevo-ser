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
  String _origen = 'ubicación de trabajo';

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<PrevisionAgro> _cargar() async {
    final destino = await _resolverDestino();
    _origen = destino.nombre;
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
        nombre: finca!.nombre,
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
          nombre: 'GPS reciente',
          latitud: ultima.latitude,
          longitud: ultima.longitude,
        );
      }
      final pos = await Geolocator.getCurrentPosition().timeout(
        const Duration(seconds: 8),
      );
      return _DestinoMeteo(
        nombre: 'GPS actual',
        latitud: pos.latitude,
        longitud: pos.longitude,
      );
    }
    return const _DestinoMeteo(
      nombre: 'centro de referencia',
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
      nombre: 'centro de plantas',
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
      appBar: AppBar(title: const Text('Meteo agro')),
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
              padding: const EdgeInsets.all(16),
              children: [
                _CabeceraMeteo(origen: _origen, prevision: prevision),
                const SizedBox(height: 12),
                if (prevision.hoy != null) _PanelDecision(dia: prevision.hoy!),
                const SizedBox(height: 12),
                for (final dia in prevision.dias) ...[
                  _TarjetaDiaMeteo(dia: dia),
                  const SizedBox(height: 8),
                ],
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
            const Text(
              'Previsión orientativa para riego, tratamientos, labores y actividad de colmenas.',
              style: TextStyle(fontSize: 12),
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
        const _AvisoMeteo(
          Icons.ac_unit,
          'Riesgo de helada',
          'Revisa floración, plantones y puntos bajos.',
        ),
      if (dia.malDiaTratamiento)
        const _AvisoMeteo(
          Icons.science,
          'Tratamientos delicados',
          'Viento o lluvia pueden reducir eficacia y aumentar deriva.',
        ),
      if (dia.estresHidrico)
        const _AvisoMeteo(
          Icons.water_drop,
          'Alta demanda hídrica',
          'ET0/VPD altos: prioriza riego y evita labores de estrés.',
        ),
      if (dia.vueloAbejasLimitado)
        const _AvisoMeteo(
          Icons.hive,
          'Vuelo de abejas limitado',
          'Frío, lluvia o viento pueden frenar pecoreo y manejo.',
        ),
    ];
    if (avisos.isEmpty) {
      avisos.add(
        const _AvisoMeteo(
          Icons.check_circle,
          'Ventana razonable',
          'Sin señales fuertes de helada, deriva, lluvia o estrés hídrico.',
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
    final fecha = DateFormat('EEE d MMM', 'es_ES').format(dia.fecha);
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
                      '${_fmt(dia.lluviaMm)} mm · ${_fmt(dia.probLluviaMax)}%',
                ),
                _DatoMeteo(
                  icono: Icons.air,
                  texto:
                      '${_fmt(dia.vientoMaxKmh)} km/h · racha ${_fmt(dia.rachaMaxKmh)}',
                ),
                _DatoMeteo(
                  icono: Icons.opacity,
                  texto: 'HR ${_fmt(dia.humedadMedia)}%',
                ),
                _DatoMeteo(
                  icono: Icons.wb_sunny,
                  texto: 'ET0 ${_fmt(dia.et0Mm)} mm',
                ),
                _DatoMeteo(
                  icono: Icons.grass,
                  texto:
                      'Suelo ${_fmt(dia.sueloTemp6cmMedia)} °C · ${_fmt(dia.sueloHumedad3a9Media, decimales: 2)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(double? v, {int decimales = 1}) =>
      v == null ? '--' : v.toStringAsFixed(decimales);
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

class _AvisoMeteo {
  final IconData icono;
  final String titulo;
  final String cuerpo;

  const _AvisoMeteo(this.icono, this.titulo, this.cuerpo);
}

class _DestinoMeteo {
  final String nombre;
  final double latitud;
  final double longitud;

  const _DestinoMeteo({
    required this.nombre,
    required this.latitud,
    required this.longitud,
  });
}
