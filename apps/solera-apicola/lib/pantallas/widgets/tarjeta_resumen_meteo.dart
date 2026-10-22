import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../../datos/base_datos.dart';
import '../../estado/apiario_activo.dart';
import '../../modelos/apiario.dart';
import '../../modelos/colmena.dart';
import '../../utiles/permisos_gps.dart';
import '../pantalla_meteo_apicola.dart';

/// Tarjeta compacta de meteo del día para el dashboard "Hoy" de apícola.
/// Sustituye la antigua pestaña Meteo del NavigationBar: muestra
/// temperaturas, lluvia y avisos clave (vuelo de abejas limitado /
/// helada / tratamientos delicados) y al pulsarla abre la
/// `PantallaMeteoApicola` completa en push.
class TarjetaResumenMeteo extends StatefulWidget {
  const TarjetaResumenMeteo({super.key});

  @override
  State<TarjetaResumenMeteo> createState() => _TarjetaResumenMeteoState();
}

class _TarjetaResumenMeteoState extends State<TarjetaResumenMeteo> {
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

  void _abrirCompleta() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PantallaMeteoApicola()),
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
                    Icon(Icons.cloud_outlined, color: Color(0xFFB07A1F)),
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
                          'No se pudo cargar la previsión. Toca para reintentar.'),
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
                      const Icon(Icons.cloud, color: Color(0xFFB07A1F)),
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
                        texto: '${_fmt(hoy.vientoMaxKmh)} km/h',
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
    if (dia.vueloAbejasLimitado) {
      avisos.add(const _AvisoMeteo(
          Icons.hive, 'Vuelo de abejas limitado'));
    }
    if (dia.riesgoHelada) {
      avisos.add(const _AvisoMeteo(Icons.ac_unit, 'Riesgo de helada'));
    }
    if (dia.malDiaTratamiento) {
      avisos.add(const _AvisoMeteo(
          Icons.science, 'Manejo delicado (viento / lluvia)'));
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
