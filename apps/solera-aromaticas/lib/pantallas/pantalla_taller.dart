import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TituloBloqueSolera;

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../dominio/rendimientos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/destilacion.dart';
import '../modelos/secado.dart';
import '../utiles/textos_aromaticas.dart';
import 'formularios.dart';

class _DatosTaller {
  _DatosTaller(this.secados, this.destilaciones);

  final List<Secado> secados;
  final List<Destilacion> destilaciones;
}

/// Transformación del año: secados y destilaciones con sus rendimientos,
/// comparados con el orientativo del catálogo.
class PantallaTaller extends StatefulWidget {
  const PantallaTaller({super.key});

  @override
  State<PantallaTaller> createState() => _PantallaTallerState();
}

class _PantallaTallerState extends State<PantallaTaller> {
  late Future<_DatosTaller> _datos = _cargar();

  @override
  void initState() {
    super.initState();
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

  Future<_DatosTaller> _cargar() async {
    final bd = BaseDatosSoleraAromaticas.instancia;
    final (desde, hasta) = intervaloAnyo(DateTime.now().year);
    return _DatosTaller(
      await bd.listarSecados(desdeMs: desde, hastaMs: hasta),
      await bd.listarDestilaciones(desdeMs: desde, hastaMs: hasta),
    );
  }

  Future<void> _nuevo() async {
    final opcion = await showModalBottomSheet<String>(
      context: context,
      builder: (contexto) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: Text(SoleraL10n.t('arom.nuevo_secado')),
              onTap: () => Navigator.pop(contexto, 'secado'),
            ),
            ListTile(
              leading: const Icon(Icons.water_drop_outlined),
              title: Text(SoleraL10n.t('arom.nueva_destilacion')),
              onTap: () => Navigator.pop(contexto, 'destilacion'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (opcion == 'secado') await mostrarAltaSecado(context);
    if (opcion == 'destilacion' && mounted) {
      await mostrarAltaDestilacion(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('arom.taller'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevo,
        icon: const Icon(Icons.add),
        label: Text(SoleraL10n.t('arom.nuevo_proceso')),
      ),
      body: FutureBuilder<_DatosTaller>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          if (instantanea.hasError) {
            return Center(child: Text(SoleraL10n.t('arom.error_cargar')));
          }
          if (datos == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (datos.secados.isEmpty && datos.destilaciones.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(SoleraL10n.t('arom.sin_procesos'),
                    textAlign: TextAlign.center),
              ),
            );
          }
          final resumen = resumirDestilaciones(datos.destilaciones);
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              if (resumen.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TituloBloqueSolera(
                      SoleraL10n.t('arom.rendimiento_por_especie')),
                ),
                for (final MapEntry(key: clave, value: total)
                    in resumen.entries)
                  ListTile(
                    dense: true,
                    title: Text(
                        '${nombreEspecie(total.especieId)} · ${nombreEstadoPlanta(clave.split('|').last)}'),
                    subtitle: Text(SoleraL10n.tf('arom.resumen_destilacion', {
                      'n': total.numeroDestilaciones,
                      'kg': formatearNumero(total.kgPlanta),
                      'ml': formatearNumero(total.mlAceite, decimales: 0),
                      'rend': formatearNumero(total.rendimientoAceiteMedio ?? 0,
                          decimales: 2),
                      'litros': formatearNumero(total.litrosHidrolato),
                    })),
                  ),
              ],
              if (datos.destilaciones.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TituloBloqueSolera(SoleraL10n.t('arom.destilaciones')),
                ),
              for (final destilacion in datos.destilaciones)
                ListTile(
                  leading: const Icon(Icons.water_drop_outlined),
                  title: Text(
                      '${nombreEspecie(destilacion.especieId)} · ${formatearNumero(destilacion.kgPlanta)} kg → ${formatearNumero(destilacion.mlAceiteEsencial, decimales: 0)} ml'),
                  subtitle: Text(_lineaDestilacion(destilacion)),
                  onLongPress: () => confirmarYBorrar(
                      context,
                      () => BaseDatosSoleraAromaticas.instancia
                          .borrarDestilacion(destilacion.id!)),
                ),
              if (datos.secados.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TituloBloqueSolera(SoleraL10n.t('arom.secados')),
                ),
              for (final secado in datos.secados)
                ListTile(
                  leading: const Icon(Icons.wb_sunny_outlined),
                  title: Text(
                      '${nombreEspecie(secado.especieId)} · ${formatearNumero(secado.kgFrescos)} → ${formatearNumero(secado.kgSecos)} kg'),
                  subtitle: Text(_lineaSecado(secado)),
                  onLongPress: () => confirmarYBorrar(
                      context,
                      () => BaseDatosSoleraAromaticas.instancia
                          .borrarSecado(secado.id!)),
                ),
            ],
          );
        },
      ),
    );
  }
}

String _lineaDestilacion(Destilacion destilacion) {
  final rendimiento = destilacion.rendimientoAceite;
  final orientativo = rendimientoOrientativo(destilacion.especieId,
      producto: 'aceite_esencial',
      estadoPlanta: destilacion.estadoPlanta == 'seca' ? 'seca' : 'fresca');
  return [
    formatearFecha(destilacion.fechaMs),
    if (rendimiento != null)
      SoleraL10n.tf('arom.rendimiento_aceite',
          {'ml': formatearNumero(rendimiento, decimales: 2)}),
    if (destilacion.litrosHidrolato > 0)
      SoleraL10n.tf('arom.litros_hidrolato_n',
          {'litros': formatearNumero(destilacion.litrosHidrolato)}),
    textoComparacion(compararConOrientativo(
        rendimiento, orientativo?.minimo, orientativo?.maximo)),
  ].where((texto) => texto.isNotEmpty).join(' · ');
}

String _lineaSecado(Secado secado) {
  final rendimiento = secado.rendimientoPorcentaje;
  final orientativo =
      rendimientoOrientativo(secado.especieId, producto: 'planta_seca');
  return [
    formatearFecha(secado.fechaInicioMs),
    nombreMetodoSecado(secado.metodo),
    if (rendimiento != null)
      SoleraL10n.tf(
          'arom.rendimiento_secado', {'pct': formatearNumero(rendimiento)}),
    textoComparacion(compararConOrientativo(
        rendimiento, orientativo?.minimo, orientativo?.maximo)),
  ].where((texto) => texto.isNotEmpty).join(' · ');
}
