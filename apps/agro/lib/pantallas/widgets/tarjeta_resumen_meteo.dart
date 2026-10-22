import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:geolocator/geolocator.dart';

import '../../datos/base_datos.dart';
import '../../estado/finca_activa.dart';
import '../../modelos/finca.dart';
import '../../modelos/planta.dart';
import '../../utiles/permisos_gps.dart';
import '../pantalla_meteo_agro.dart';

/// Tarjeta compacta de meteo del día para el dashboard "Hoy".
/// Sustituye la antigua pestaña Meteo del NavigationBar: muestra
/// temperaturas, lluvia y avisos clave (helada / tratamientos / estrés
/// hídrico / vuelo de abejas) y al pulsarla abre la `PantallaMeteoAgro`
/// completa en push.
class TarjetaResumenMeteo extends StatefulWidget {
  const TarjetaResumenMeteo({super.key});

  @override
  State<TarjetaResumenMeteo> createState() => _TarjetaResumenMeteoState();
}

class _TarjetaResumenMeteoState extends State<TarjetaResumenMeteo> {
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

  void _abrirCompleta() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PantallaMeteoAgro()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: _abrirCompleta,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FutureBuilder<PrevisionAgro>(
            future: _futuro,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Row(
                  children: [
                    Icon(Icons.cloud_outlined, color: Color(0xFF558B2F)),
                    SizedBox(width: 12),
                    Text('Cargando previsión meteo…'),
                  ],
                );
              }
              if (snapshot.hasError || snapshot.data == null) {
                return const Row(
                  children: [
                    Icon(Icons.cloud_off, color: Colors.grey),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No se pudo cargar la previsión. Toca para reintentar.',
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                );
              }
              final prevision = snapshot.data!;
              final hoy = prevision.hoy;
              if (hoy == null) {
                return const Text('Sin datos meteo para hoy.');
              }
              final avisos = _avisosClave(hoy);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud, color: Color(0xFF558B2F)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Meteo hoy · $_origen',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _Chip(
                        icono: Icons.thermostat,
                        texto:
                            '${_fmt(hoy.tempMin)} / ${_fmt(hoy.tempMax)} °C',
                      ),
                      _Chip(
                        icono: Icons.water,
                        texto:
                            '${_fmt(hoy.lluviaMm)} mm · ${_fmt(hoy.probLluviaMax)} %',
                      ),
                      _Chip(
                        icono: Icons.air,
                        texto:
                            '${_fmt(hoy.vientoMaxKmh)} km/h',
                      ),
                    ],
                  ),
                  if (avisos.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    for (final aviso in avisos)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(aviso.icono,
                                size: 18, color: const Color(0xFFE65100)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                aviso.titulo,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<_AvisoMeteo> _avisosClave(DiaMeteoAgro dia) {
    final avisos = <_AvisoMeteo>[];
    if (dia.riesgoHelada) {
      avisos.add(const _AvisoMeteo(Icons.ac_unit, 'Riesgo de helada'));
    }
    if (dia.malDiaTratamiento) {
      avisos.add(const _AvisoMeteo(
          Icons.science, 'Tratamientos delicados (viento / lluvia)'));
    }
    if (dia.estresHidrico) {
      avisos.add(const _AvisoMeteo(
          Icons.water_drop, 'Alta demanda hídrica'));
    }
    return avisos;
  }

  static String _fmt(double? v, {int decimales = 1}) =>
      v == null ? '--' : v.toStringAsFixed(decimales);
}

class _Chip extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _Chip({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icono, size: 16),
      label: Text(texto, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _AvisoMeteo {
  final IconData icono;
  final String titulo;
  const _AvisoMeteo(this.icono, this.titulo);
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
