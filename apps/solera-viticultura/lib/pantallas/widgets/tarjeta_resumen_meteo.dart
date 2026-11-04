import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../../datos/base_datos.dart';
import '../../estado/vinedo_activo.dart';
import '../../modelos/cepa.dart';
import '../../modelos/vinedo.dart';
import '../../utiles/permisos_gps.dart';
import '../pantalla_meteo_viticultura.dart';

/// Tarjeta compacta de meteo del día para el dashboard "Hoy" de
/// viticultura. Sustituye la antigua pestaña Meteo del NavigationBar:
/// muestra temperaturas, lluvia y avisos clave (helada / tratamientos
/// con riesgo / estrés hídrico) y al pulsarla abre la
/// `PantallaMeteoViticultura` completa en push.
class TarjetaResumenMeteo extends StatefulWidget {
  const TarjetaResumenMeteo({super.key});

  @override
  State<TarjetaResumenMeteo> createState() => _TarjetaResumenMeteoState();
}

class _TarjetaResumenMeteoState extends State<TarjetaResumenMeteo> {
  final _servicio = ServicioMeteoAgro();
  final _persistenciaVinedo = VinedoActivoPersistido();
  Future<PrevisionAgro>? _futuro;
  _DestinoMeteo? _destino;

  /// Nombre visible del origen de la previsión, en el idioma actual.
  String get _origen {
    final destino = _destino;
    if (destino == null) return SoleraL10n.t('viti.origen_vinedo');
    final claveNombre = destino.claveNombre;
    return claveNombre != null ? SoleraL10n.t(claveNombre) : destino.nombre;
  }

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
    final db = BaseDatosSoleraViticultura.instancia;
    final vinedoActivoId = await _persistenciaVinedo.cargar();
    final Vinedo? vinedo = vinedoActivoId == null
        ? null
        : await db.obtenerVinedo(vinedoActivoId);
    if (vinedo?.latitudCentroide != null && vinedo?.longitudCentroide != null) {
      return _DestinoMeteo(
        nombre: vinedo!.nombre,
        latitud: vinedo.latitudCentroide!,
        longitud: vinedo.longitudCentroide!,
      );
    }
    final cepas = await db.listarCepas(vinedoId: vinedoActivoId);
    final centro = _centroCepas(cepas);
    if (centro != null) return centro;

    final permitido = await asegurarPermisoUbicacion();
    if (permitido) {
      final ultima = await Geolocator.getLastKnownPosition();
      if (ultima != null) {
        return _DestinoMeteo(
          claveNombre: 'viti.origen_gps_reciente',
          latitud: ultima.latitude,
          longitud: ultima.longitude,
        );
      }
    }
    return const _DestinoMeteo(
      claveNombre: 'viti.origen_centro_referencia',
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
        claveNombre: 'viti.origen_centro_cepas', latitud: lat, longitud: lng);
  }

  void _abrirCompleta() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PantallaMeteoViticultura()),
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
                return Row(
                  children: [
                    const Icon(Icons.cloud_outlined, color: Color(0xFF6E2F3F)),
                    const SizedBox(width: 12),
                    Text(SoleraL10n.t('viti.cargando_prevision_meteo')),
                  ],
                );
              }
              if (snapshot.hasError || snapshot.data == null) {
                return Row(
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(SoleraL10n.t('viti.prevision_no_cargada_reintentar')),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                );
              }
              final prevision = snapshot.data!;
              final hoy = prevision.hoy;
              if (hoy == null) {
                return Text(SoleraL10n.t('viti.sin_datos_meteo_hoy'));
              }
              final avisos = _avisosClave(hoy);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud, color: Color(0xFF6E2F3F)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          SoleraL10n.tf('viti.meteo_hoy_origen', {'origen': _origen}),
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
    if (dia.riesgoHelada) {
      avisos.add(_AvisoMeteo(Icons.ac_unit, SoleraL10n.t('viti.riesgo_de_helada')));
    }
    if (dia.malDiaTratamiento) {
      avisos.add(_AvisoMeteo(
          Icons.science, SoleraL10n.t('viti.tratamientos_delicados_viento_lluvia')));
    }
    if (dia.estresHidrico) {
      avisos.add(_AvisoMeteo(
          Icons.water_drop, SoleraL10n.t('viti.alta_demanda_hidrica')));
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
  /// Nombre propio (el del viñedo) o vacío si se usa [claveNombre].
  final String nombre;

  /// Clave de traducción del nombre genérico («GPS reciente»…).
  final String? claveNombre;
  final double latitud;
  final double longitud;

  const _DestinoMeteo({
    this.nombre = '',
    this.claveNombre,
    required this.latitud,
    required this.longitud,
  });
}
