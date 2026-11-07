import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show DialogoConfirmacion, SoleraL10n, TituloBloqueSolera;

import '../datos/base_datos.dart';
import '../dominio/resumen_cosecha.dart';
import '../estado/cambios_datos.dart';
import '../modelos/cosecha.dart';
import '../modelos/parcela.dart';
import '../utiles/textos_frutal.dart';
import 'formularios_registros.dart';

class _DatosCosecha {
  _DatosCosecha(this.parcelas, this.cosechas);

  final Map<int, Parcela> parcelas;
  final List<Cosecha> cosechas;
}

/// Cosecha de una campaña: totales por parcela (kg en cáscara, grano,
/// rendimiento, humedad, kg/ha) y las entregas.
class PantallaCosecha extends StatefulWidget {
  const PantallaCosecha({super.key});

  @override
  State<PantallaCosecha> createState() => _PantallaCosechaState();
}

class _PantallaCosechaState extends State<PantallaCosecha> {
  int _campania = DateTime.now().year;
  late Future<_DatosCosecha> _datos;

  @override
  void initState() {
    super.initState();
    _datos = _cargar();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _datos = _cargar();
    });
  }

  Future<_DatosCosecha> _cargar() async {
    final baseDatos = BaseDatosSoleraFrutal.instancia;
    return _DatosCosecha(
      {
        for (final parcela in await baseDatos.listarParcelas())
          parcela.id!: parcela
      },
      await baseDatos.listarCosechas(campania: _campania),
    );
  }

  void _cambiarCampania(int desplazamiento) {
    setState(() {
      _campania += desplazamiento;
      _datos = _cargar();
    });
  }

  Future<void> _borrar(Cosecha cosecha) async {
    final confirmado = await DialogoConfirmacion.mostrar(context,
        titulo: SoleraL10n.t('borrar'),
        mensaje:
            '${formatearFecha(cosecha.fechaMs)} · ${formatearNumero(cosecha.kgCascara, decimales: 0)} kg',
        esPeligroso: true);
    if (!confirmado) return;
    await BaseDatosSoleraFrutal.instancia.borrarCosecha(cosecha.id!);
    avisarCambioDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('frut.cosecha')),
        actions: [
          IconButton(
              onPressed: () => _cambiarCampania(-1),
              icon: const Icon(Icons.chevron_left)),
          Center(child: Text('$_campania')),
          IconButton(
              onPressed: () => _cambiarCampania(1),
              icon: const Icon(Icons.chevron_right)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: SoleraL10n.t('frut.nueva_cosecha'),
        onPressed: () => mostrarAltaCosecha(context, campania: _campania),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<_DatosCosecha>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          if (datos == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (datos.cosechas.isEmpty) {
            return Center(child: Text(SoleraL10n.t('frut.sin_cosechas')));
          }
          final resumenes = ResumenCosechaParcela.calcular(datos.cosechas);
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TituloBloqueSolera(SoleraL10n.t('frut.por_parcela')),
              ),
              for (final resumen in resumenes)
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(datos.parcelas[resumen.parcelaId]?.nombre ??
                      '#${resumen.parcelaId}'),
                  subtitle: Text([
                    '${formatearNumero(resumen.kgCascara, decimales: 0)} kg',
                    if (resumen.rendimientoMedioPorcentaje != null)
                      '${SoleraL10n.t('frut.rendimiento')} ${formatearNumero(resumen.rendimientoMedioPorcentaje!)} %',
                    if (resumen.humedadMediaPorcentaje != null)
                      '${SoleraL10n.t('frut.humedad_corta')} ${formatearNumero(resumen.humedadMediaPorcentaje!)} %',
                    if (resumen.kgCascaraPorHectarea(
                            datos.parcelas[resumen.parcelaId]?.superficieHa ??
                                0)
                        case final porHectarea?)
                      '${formatearNumero(porHectarea, decimales: 0)} kg/ha',
                  ].join(' · ')),
                  trailing: resumen.rendimientoMedioPorcentaje == null
                      ? null
                      : Text(
                          '${formatearNumero(resumen.kgGrano, decimales: 0)} kg ${SoleraL10n.t('frut.grano')}'),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TituloBloqueSolera(SoleraL10n.t('frut.entregas')),
              ),
              for (final cosecha in datos.cosechas)
                ListTile(
                  title: Text(
                      '${formatearFecha(cosecha.fechaMs)} · ${datos.parcelas[cosecha.parcelaId]?.nombre ?? ''}'),
                  subtitle: Text([
                    '${formatearNumero(cosecha.kgCascara, decimales: 0)} kg',
                    if (cosecha.calibre.isNotEmpty) cosecha.calibre,
                    if (cosecha.destino.isNotEmpty) cosecha.destino,
                  ].join(' · ')),
                  onLongPress: () => _borrar(cosecha),
                ),
            ],
          );
        },
      ),
    );
  }
}
