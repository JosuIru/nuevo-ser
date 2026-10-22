import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../estado/apiario_activo.dart';
import '../modelos/apiario.dart';
import '../modelos/colmena.dart';
import '../utiles/permisos_gps.dart';

class PantallaMeteoApicola extends StatefulWidget {
  const PantallaMeteoApicola({super.key});

  @override
  State<PantallaMeteoApicola> createState() => _PantallaMeteoApicolaState();
}

class _PantallaMeteoApicolaState extends State<PantallaMeteoApicola> {
  final _servicio = ServicioMeteoAgro();
  final _persistenciaApiario = ApiarioActivoPersistido();
  Future<PrevisionAgro>? _futuro;
  String _origen = 'apiario';

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
    final db = BaseDatosSoleraApicola.instancia;
    final apiarioActivoId = await _persistenciaApiario.cargar();
    final Apiario? apiario = apiarioActivoId == null
        ? null
        : await db.obtenerApiario(apiarioActivoId);
    if (apiario?.latitudCentroide != null &&
        apiario?.longitudCentroide != null) {
      return _DestinoMeteo(
        nombre: apiario!.nombre,
        latitud: apiario.latitudCentroide!,
        longitud: apiario.longitudCentroide!,
      );
    }
    final colmenas = await db.listarColmenas(apiarioId: apiarioActivoId);
    final centroColmenas = _centroColmenas(colmenas);
    if (centroColmenas != null) return centroColmenas;

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

  _DestinoMeteo? _centroColmenas(List<Colmena> colmenas) {
    final conPosicion = colmenas
        .where((c) => c.ultimaLatitud != null && c.ultimaLongitud != null)
        .toList();
    if (conPosicion.isEmpty) return null;
    final lat =
        conPosicion.map((c) => c.ultimaLatitud!).reduce((a, b) => a + b) /
            conPosicion.length;
    final lng =
        conPosicion.map((c) => c.ultimaLongitud!).reduce((a, b) => a + b) /
            conPosicion.length;
    return _DestinoMeteo(
      nombre: 'centro de colmenas',
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
      appBar: AppBar(title: const Text('Meteo apícola')),
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
              'Previsión orientativa para vuelo, revisión de colmenas, trashumancia, golpes de calor y alimentación.',
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
      if (dia.vueloAbejasLimitado)
        const _Aviso(
          Icons.hive,
          'Vuelo limitado',
          'Frío, lluvia o viento pueden frenar pecoreo y manejo.',
        ),
      if ((dia.tempMax ?? 0) >= 34)
        const _Aviso(
          Icons.thermostat,
          'Calor fuerte',
          'Revisa agua, sombra, ventilación y alzas en apiarios expuestos.',
        ),
      if ((dia.vientoMaxKmh ?? 0) >= 30 || (dia.rachaMaxKmh ?? 0) >= 45)
        const _Aviso(
          Icons.air,
          'Viento para manejo o transporte',
          'Evita abrir colmenas si no es necesario y asegura tapas/material.',
        ),
      if ((dia.lluviaMm ?? 0) >= 5)
        const _Aviso(
          Icons.water,
          'Lluvia significativa',
          'Puede reducir vuelo y dificultar accesos; revisa reservas tras varios días.',
        ),
    ];
    if (avisos.isEmpty) {
      avisos.add(
        const _Aviso(
          Icons.check_circle,
          'Ventana razonable',
          'Sin señales fuertes de frío, lluvia, viento o calor extremo.',
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
