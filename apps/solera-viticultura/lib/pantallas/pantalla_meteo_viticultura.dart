import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../estado/vinedo_activo.dart';
import '../modelos/cepa.dart';
import '../modelos/vinedo.dart';
import '../utiles/permisos_gps.dart';

class PantallaMeteoViticultura extends StatefulWidget {
  const PantallaMeteoViticultura({super.key});

  @override
  State<PantallaMeteoViticultura> createState() =>
      _PantallaMeteoViticulturaState();
}

class _PantallaMeteoViticulturaState extends State<PantallaMeteoViticultura> {
  final _servicio = ServicioMeteoAgro();
  final _persistenciaVinedo = VinedoActivoPersistido();
  Future<PrevisionAgro>? _futuro;
  String _origen = 'viñedo';

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
    final db = BaseDatosSoleraViticultura.instancia;
    final vinedoActivoId = await _persistenciaVinedo.cargar();
    final Vinedo? vinedo =
        vinedoActivoId == null ? null : await db.obtenerVinedo(vinedoActivoId);
    if (vinedo?.latitudCentroide != null && vinedo?.longitudCentroide != null) {
      return _DestinoMeteo(
        nombre: vinedo!.nombre,
        latitud: vinedo.latitudCentroide!,
        longitud: vinedo.longitudCentroide!,
      );
    }
    final cepas = await db.listarCepas(vinedoId: vinedoActivoId);
    final centroCepas = _centroCepas(cepas);
    if (centroCepas != null) return centroCepas;

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

  _DestinoMeteo? _centroCepas(List<Cepa> cepas) {
    if (cepas.isEmpty) return null;
    final lat =
        cepas.map((c) => c.latitud).reduce((a, b) => a + b) / cepas.length;
    final lng =
        cepas.map((c) => c.longitud).reduce((a, b) => a + b) / cepas.length;
    return _DestinoMeteo(
        nombre: 'centro de cepas', latitud: lat, longitud: lng);
  }

  Future<void> _refrescar() async {
    setState(() => _futuro = _cargar());
    await _futuro;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meteo vitícola')),
      body: FutureBuilder<PrevisionAgro>(
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
                if (prevision.hoy != null) _PanelDecision(dia: prevision.hoy!),
                const SizedBox(height: 12),
                for (final dia in prevision.dias) ...[
                  _TarjetaDia(dia: dia),
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

class _Cabecera extends StatelessWidget {
  final String origen;
  final PrevisionAgro prevision;

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
              'Previsión orientativa para tratamientos, heladas, riego, estrés hídrico y ventanas de trabajo en viña.',
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
    final avisos = <_Aviso>[
      if (dia.riesgoHelada)
        const _Aviso(
          Icons.ac_unit,
          'Riesgo de helada',
          'Vigila brotación, floración, plantones y vaguadas.',
        ),
      if (dia.malDiaTratamiento)
        const _Aviso(
          Icons.science,
          'Tratamiento poco favorable',
          'Viento o lluvia pueden provocar deriva, lavado o baja eficacia.',
        ),
      if (dia.estresHidrico)
        const _Aviso(
          Icons.water_drop,
          'Demanda hídrica alta',
          'ET0/VPD altos: revisa riego y evita labores que aumenten estrés.',
        ),
      if ((dia.humedadMedia ?? 0) >= 85 && (dia.tempMax ?? 0) >= 12)
        const _Aviso(
          Icons.bug_report,
          'Ambiente sensible a hongos',
          'Humedad alta con temperatura templada: revisar mildiu, oidio y botritis según estado BBCH.',
        ),
    ];
    if (avisos.isEmpty) {
      avisos.add(
        const _Aviso(
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

class _TarjetaDia extends StatelessWidget {
  final DiaMeteoAgro dia;

  const _TarjetaDia({required this.dia});

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
                _Dato(
                    icono: Icons.thermostat,
                    texto: '${_fmt(dia.tempMin)} / ${_fmt(dia.tempMax)} °C'),
                _Dato(
                    icono: Icons.water,
                    texto:
                        '${_fmt(dia.lluviaMm)} mm · ${_fmt(dia.probLluviaMax)}%'),
                _Dato(
                    icono: Icons.air,
                    texto:
                        '${_fmt(dia.vientoMaxKmh)} km/h · racha ${_fmt(dia.rachaMaxKmh)}'),
                _Dato(
                    icono: Icons.opacity,
                    texto: 'HR ${_fmt(dia.humedadMedia)}%'),
                _Dato(
                    icono: Icons.wb_sunny, texto: 'ET0 ${_fmt(dia.et0Mm)} mm'),
                _Dato(
                    icono: Icons.grass,
                    texto:
                        'Suelo ${_fmt(dia.sueloTemp6cmMedia)} °C · ${_fmt(dia.sueloHumedad3a9Media, decimales: 2)}'),
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

class _Aviso {
  final IconData icono;
  final String titulo;
  final String cuerpo;

  const _Aviso(this.icono, this.titulo, this.cuerpo);
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
