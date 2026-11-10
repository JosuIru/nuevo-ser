import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

import '../utiles/textos_visibles.dart';

import '../datos/base_datos.dart';
import '../modelos/parcela.dart';
import '../modelos/recoleccion.dart';
import '../modelos/tratamiento.dart';
import 'pantalla_nueva_parcela.dart'
    show paqueteAppAceitera, puntoOCentroDelArea;
import 'pantalla_nueva_recoleccion.dart';
import 'pantalla_nuevo_tratamiento.dart';

/// Ficha de una parcela: datos + timeline de recolecciones y
/// tratamientos vinculados. Botón "+" abre un menú con los tipos de
/// evento aplicables.
class PantallaFichaParcela extends StatefulWidget {
  final Parcela parcela;

  const PantallaFichaParcela({super.key, required this.parcela});

  @override
  State<PantallaFichaParcela> createState() => _PantallaFichaParcelaState();
}

class _PantallaFichaParcelaState extends State<PantallaFichaParcela> {
  final _formatoFecha = DateFormat('d/M/yyyy', 'es_ES');
  List<Recoleccion> _recolecciones = const [];
  List<Tratamiento> _tratamientos = const [];
  late double? _latitud = widget.parcela.latitud;
  late double? _longitud = widget.parcela.longitud;
  late List<LatLng> _area = widget.parcela.vertices;
  late double _superficieHa = widget.parcela.superficieHa;

  /// Guarda el punto y el área en cuanto se marcan (la ficha no tiene
  /// botón de guardar). Si hay área y no punto, el punto es su centro.
  Future<void> _guardarUbicacion({
    required double? latitud,
    required double? longitud,
    required List<LatLng> area,
    double? superficieHa,
  }) async {
    final (latitudGuardada, longitudGuardada) =
        puntoOCentroDelArea(latitud, longitud, area);
    await BaseDatosSoleraAceitera().actualizarParcelaUbicacion(
      id: widget.parcela.id!,
      latitud: latitudGuardada,
      longitud: longitudGuardada,
      contorno: codificarContorno(area),
      superficieHa: superficieHa,
    );
    if (!mounted) return;
    setState(() {
      _latitud = latitudGuardada;
      _longitud = longitudGuardada;
      _area = area;
      if (superficieHa != null) _superficieHa = superficieHa;
    });
  }

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final bd = BaseDatosSoleraAceitera();
    final rs = await bd.listarRecolecciones().then(
        (rs) => rs.where((r) => r.parcelaId == widget.parcela.id).toList());
    final ts = await bd.listarTratamientos(parcelaId: widget.parcela.id);
    if (!mounted) return;
    setState(() {
      _recolecciones = rs;
      _tratamientos = ts;
    });
  }

  Future<void> _registrarEvento() async {
    final tipo = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.agriculture),
              title: Text(SoleraL10n.t('acei.recoleccion')),
              onTap: () => Navigator.of(context).pop('recoleccion'),
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: Text(SoleraL10n.t('acei.tratamiento')),
              onTap: () => Navigator.of(context).pop('tratamiento'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || tipo == null) return;
    if (tipo == 'recoleccion') {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PantallaNuevaRecoleccion(parcelaId: widget.parcela.id!),
      ));
    } else {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PantallaNuevoTratamiento(parcelaId: widget.parcela.id!),
      ));
    }
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.parcela;
    return Scaffold(
      appBar: AppBar(
          title: Text(p.nombre.isEmpty
              ? SoleraL10n.t('acei.parcela_sin_nombre')
              : p.nombre)),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(SoleraL10n.tf('acei.superficie_valor',
                      {'ha': formatearNumero(_superficieHa, decimales: 2)})),
                  Text(SoleraL10n.tf('acei.variedad_valor', {
                    'variedad': p.variedadMayoritariaId.isEmpty
                        ? SoleraL10n.t('acei.sin_definir')
                        : p.variedadMayoritariaId
                  })),
                  Text(SoleraL10n.tf('acei.marco_valor', {
                    'marco': p.marcoPlantacion.isEmpty
                        ? SoleraL10n.t('acei.sin_definir')
                        : p.marcoPlantacion
                  })),
                  Text(SoleraL10n.tf(
                      'acei.edad_media_valor', {'anyos': p.edadMediaAnyos})),
                  Text(SoleraL10n.tf('acei.riego_valor',
                      {'riego': nombreSistemaRiego(p.sistemaRiego)})),
                  if (p.codigoSigpac.isNotEmpty)
                    Text('SIGPAC: ${p.codigoSigpac}'),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CampoPunto(
                    latitud: _latitud,
                    longitud: _longitud,
                    centro: centroide(_area),
                    areasDeFondo: [(nombre: p.nombre, vertices: _area)],
                    paqueteApp: paqueteAppAceitera,
                    alCambiar: (latitud, longitud) => _guardarUbicacion(
                        latitud: latitud, longitud: longitud, area: _area),
                  ),
                  const SizedBox(height: 8),
                  CampoArea(
                    vertices: _area,
                    centro: _latitud == null || _longitud == null
                        ? null
                        : LatLng(_latitud!, _longitud!),
                    paqueteApp: paqueteAppAceitera,
                    alCambiar: (vertices) => _guardarUbicacion(
                        latitud: _latitud, longitud: _longitud, area: vertices),
                    alUsarSuperficie: (hectareas) => _guardarUbicacion(
                        latitud: _latitud,
                        longitud: _longitud,
                        area: _area,
                        superficieHa:
                            double.parse(hectareas.toStringAsFixed(2))),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(SoleraL10n.t('acei.recolecciones'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          if (_recolecciones.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(SoleraL10n.t('acei.sin_recolecciones')),
            )
          else
            ..._recolecciones.map((r) => Card(
                  child: ListTile(
                    leading:
                        const Icon(Icons.agriculture, color: Color(0xFF5C6B3A)),
                    title: Text(
                      '${formatearNumero(r.kgEstimados, decimales: 0)} kg · ${nombreTipoAceituna(r.tipoAceituna)}',
                    ),
                    subtitle: Text(
                      '${_formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(r.fechaMs))} · ${nombreMetodoRecoleccion(r.metodo)}',
                    ),
                  ),
                )),
          const SizedBox(height: 16),
          Text(SoleraL10n.t('acei.tratamientos'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          if (_tratamientos.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(SoleraL10n.t('acei.sin_tratamientos')),
            )
          else
            ..._tratamientos.map((t) => Card(
                  child: ListTile(
                    leading:
                        const Icon(Icons.bug_report, color: Color(0xFF5C6B3A)),
                    title: Text(t.sustanciaActivaId.isEmpty
                        ? SoleraL10n.t('acei.sustancia_no_indicada')
                        : t.sustanciaActivaId),
                    subtitle: Text(
                      '${_formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(t.fechaMs))}'
                      ' · ${formatearNumero(t.dosisLitrosPorHa, decimales: 2)} L/ha'
                      '${t.plagaObjetivoId.isEmpty ? "" : " · ${SoleraL10n.tf('acei.contra_plaga', {
                              'plaga': t.plagaObjetivoId
                            })}"}',
                    ),
                  ),
                )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _registrarEvento,
        icon: const Icon(Icons.add),
        label: Text(SoleraL10n.t('acei.registrar')),
      ),
    );
  }
}
