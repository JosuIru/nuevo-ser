import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:geolocator/geolocator.dart';

import '../../datos/base_datos.dart';
import '../../servicios/servicio_meteo_aceitera.dart';
import '../../utiles/permisos_gps.dart';
import '../pantalla_meteo_aceitera.dart';

/// Tarjeta compacta de meteo del día para el dashboard "Hoy" de
/// aceitera. Muestra temperaturas, lluvia, viento y avisos clave
/// (helada, mosca del olivo, golpe de calor, mal día tratamiento) y al
/// pulsarla abre la `PantallaMeteoAceitera` completa con previsión a
/// 7 días y consejos olivareros.
class TarjetaResumenMeteo extends StatefulWidget {
  const TarjetaResumenMeteo({super.key});

  @override
  State<TarjetaResumenMeteo> createState() => _TarjetaResumenMeteoState();
}

class _TarjetaResumenMeteoState extends State<TarjetaResumenMeteo> {
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

  void _abrirCompleta() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PantallaMeteoAceitera()),
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
          child: FutureBuilder<PrevisionAceitera>(
            future: _futuro,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Row(
                  children: [
                    const Icon(Icons.cloud_outlined, color: Color(0xFF5C6B3A)),
                    const SizedBox(width: 12),
                    Text(SoleraL10n.t('acei.cargando_prevision_meteo')),
                  ],
                );
              }
              if (snapshot.hasError || snapshot.data == null) {
                return Row(
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(SoleraL10n.t(
                          'acei.no_se_pudo_cargar_prevision_reintentar')),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                );
              }
              final prevision = snapshot.data!;
              final hoy = prevision.hoy;
              if (hoy == null) {
                return Text(SoleraL10n.t('acei.sin_datos_meteo_hoy'));
              }
              final avisos = avisosClaveOlivar(hoy);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud, color: Color(0xFF5C6B3A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          SoleraL10n.tf('acei.meteo_hoy_origen',
                              {'origen': nombreDestinoMeteoVisible(_origen)}),
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
                      _ChipMeteo(
                        icono: Icons.thermostat,
                        texto:
                            '${_fmt(hoy.tempMin)} / ${_fmt(hoy.tempMax)} °C',
                      ),
                      _ChipMeteo(
                        icono: Icons.water,
                        texto:
                            '${_fmt(hoy.lluviaMm)} mm · ${_fmt(hoy.probLluviaMax)} %',
                      ),
                      _ChipMeteo(
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
                                size: 18, color: aviso.color),
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

  static String _fmt(double? v, {int decimales = 1}) =>
      v == null ? '--' : formatearNumero(v, decimales: decimales);
}

class _ChipMeteo extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _ChipMeteo({required this.icono, required this.texto});

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

/// Aviso clave del olivar para mostrar en el resumen de "Hoy". Cada
/// aviso lleva un icono, título corto y color (rojo para riesgo
/// agronómico, naranja para precaución, verde si conviene aprovechar
/// la ventana).
class AvisoOlivar {
  final IconData icono;
  final String titulo;
  final Color color;
  const AvisoOlivar(this.icono, this.titulo, this.color);
}

/// Conjunto de avisos a mostrar en el resumen de hoy. Los avisos
/// detallados (con descripción larga y manejo recomendado) viven en
/// `pantalla_meteo_aceitera.dart`.
List<AvisoOlivar> avisosClaveOlivar(DiaMeteoOlivar dia) {
  final avisos = <AvisoOlivar>[];
  if (dia.riesgoHelada) {
    avisos.add(AvisoOlivar(
      Icons.ac_unit,
      SoleraL10n.t('acei.aviso_corto_helada'),
      const Color(0xFF1976D2),
    ));
  }
  if (dia.golpeCalorAceituna) {
    avisos.add(AvisoOlivar(
      Icons.local_fire_department,
      SoleraL10n.t('acei.aviso_corto_golpe_calor'),
      const Color(0xFFD84315),
    ));
  }
  if (dia.vueloMoscaOlivoActivo) {
    avisos.add(AvisoOlivar(
      Icons.bug_report,
      SoleraL10n.t('acei.aviso_corto_mosca'),
      const Color(0xFFE65100),
    ));
  }
  if (dia.malDiaTratamiento) {
    avisos.add(AvisoOlivar(
      Icons.science,
      SoleraL10n.t('acei.aviso_corto_tratamientos'),
      const Color(0xFFE65100),
    ));
  }
  if (dia.estresHidrico) {
    avisos.add(AvisoOlivar(
      Icons.water_drop,
      SoleraL10n.t('acei.aviso_corto_estres_hidrico'),
      const Color(0xFF0277BD),
    ));
  }
  if (dia.floracionEnRiesgo) {
    avisos.add(AvisoOlivar(
      Icons.local_florist,
      SoleraL10n.t('acei.aviso_corto_floracion'),
      const Color(0xFFE65100),
    ));
  }
  return avisos;
}

/// Destino del meteo: nombre humano + coordenadas. Se calcula en
/// cascada desde el centroide de las parcelas con coordenadas hacia
/// el GPS reciente y, como fallback, hacia el centro del olivar
/// peninsular.
class DestinoMeteoAceitera {
  /// Nombre propio (el del olivar) o vacío si se usa [claveNombre].
  final String nombre;

  /// Clave de traducción del nombre cuando no es un nombre propio
  /// («GPS reciente», «centro de parcelas»…).
  final String? claveNombre;
  final double latitud;
  final double longitud;
  const DestinoMeteoAceitera({
    this.nombre = '',
    this.claveNombre,
    required this.latitud,
    required this.longitud,
  });
}

/// Texto visible del origen guardado por las pantallas de meteo: si es
/// una clave `acei.*` la traduce; si no, es un nombre propio.
String nombreDestinoMeteoVisible(String origen) =>
    origen.startsWith('acei.') ? SoleraL10n.t(origen) : origen;

Future<DestinoMeteoAceitera> resolverDestinoMeteoAceitera() async {
  final db = BaseDatosSoleraAceitera();
  final parcelas = await db.listarParcelas();
  final conCoords =
      parcelas.where((p) => p.latitud != null && p.longitud != null).toList();
  if (conCoords.isNotEmpty) {
    final lat = conCoords.map((p) => p.latitud!).reduce((a, b) => a + b) /
        conCoords.length;
    final lon = conCoords.map((p) => p.longitud!).reduce((a, b) => a + b) /
        conCoords.length;
    final olivar = await db.obtenerOlivar();
    return DestinoMeteoAceitera(
      nombre: olivar?.nombre ?? '',
      claveNombre: (olivar?.nombre.isNotEmpty == true)
          ? null
          : 'acei.centro_de_parcelas',
      latitud: lat,
      longitud: lon,
    );
  }

  final permitido = await asegurarPermisoUbicacion();
  if (permitido) {
    try {
      final ultima = await Geolocator.getLastKnownPosition();
      if (ultima != null) {
        return DestinoMeteoAceitera(
          claveNombre: 'acei.gps_reciente',
          latitud: ultima.latitude,
          longitud: ultima.longitude,
        );
      }
    } catch (_) {}
    try {
      final pos = await Geolocator.getCurrentPosition()
          .timeout(const Duration(seconds: 8));
      return DestinoMeteoAceitera(
        claveNombre: 'acei.gps_actual',
        latitud: pos.latitude,
        longitud: pos.longitude,
      );
    } catch (_) {}
  }
  // Fallback: centro aproximado del olivar peninsular (Jaén — el centro
  // de masa real de la producción olivarera ibérica).
  return const DestinoMeteoAceitera(
    claveNombre: 'acei.centro_olivar_peninsular',
    latitud: 37.78,
    longitud: -3.78,
  );
}
