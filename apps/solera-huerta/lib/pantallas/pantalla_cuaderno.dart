import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../estado/cambios_datos.dart';
import '../estado/datos_huerta.dart';
import '../modelos/cosecha.dart';
import '../modelos/tratamiento.dart';
import '../utiles/textos_huerta.dart';
import 'formularios_huerta.dart';
import 'hoja_formulario.dart';
import 'pantalla_listas.dart';

/// Cuaderno del año: siembras, cosechas y aplicaciones de insumos. Desde el
/// menú, los cultivos, el banco de semillas y los insumos.
class PantallaCuaderno extends StatefulWidget {
  const PantallaCuaderno({super.key});

  @override
  State<PantallaCuaderno> createState() => _PantallaCuadernoState();
}

typedef _DatosCuaderno = ({
  DatosHuerta datos,
  List<Cosecha> cosechas,
  List<Tratamiento> aplicaciones,
});

class _PantallaCuadernoState extends State<PantallaCuaderno> {
  int _anyo = DateTime.now().year;
  late Future<_DatosCuaderno> _datos;

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

  Future<_DatosCuaderno> _cargar() async {
    final bd = BaseDatosSoleraHuerta.instancia;
    final (desde, hasta) = intervaloAnyo(_anyo);
    return (
      datos: await DatosHuerta.cargar(),
      cosechas: await bd.listarCosechas(desdeMs: desde, hastaMs: hasta),
      aplicaciones: await bd.listarTratamientos(desdeMs: desde, hastaMs: hasta),
    );
  }

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _datos = _cargar();
    });
  }

  void _cambiarAnyo(int desplazamiento) {
    setState(() {
      _anyo += desplazamiento;
      _datos = _cargar();
    });
  }

  void _abrir(Widget pantalla) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));

  Future<void> _borrar(Future<void> Function() borrado) async {
    if (!await confirmarBorrado(
        context, SoleraL10n.t('huer.borrar_registro'))) {
      return;
    }
    await borrado();
    avisarCambioDatos();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(SoleraL10n.t('huer.cuaderno')),
            IconButton(
                tooltip: SoleraL10n.t('huer.anyo_anterior'),
                onPressed: () => _cambiarAnyo(-1),
                icon: const Icon(Icons.chevron_left)),
            Text('$_anyo'),
            IconButton(
                tooltip: SoleraL10n.t('huer.anyo_siguiente'),
                onPressed: () => _cambiarAnyo(1),
                icon: const Icon(Icons.chevron_right)),
          ]),
          actions: [
            PopupMenuButton<String>(
              onSelected: (opcion) => switch (opcion) {
                'cultivos' => _abrir(const PantallaCultivos()),
                'semillas' => _abrir(const PantallaSemillas()),
                _ => _abrir(const PantallaInsumos()),
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                    value: 'cultivos',
                    child: Text(SoleraL10n.t('huer.cultivos'))),
                PopupMenuItem(
                    value: 'semillas',
                    child: Text(SoleraL10n.t('huer.banco_semillas'))),
                PopupMenuItem(
                    value: 'insumos',
                    child: Text(SoleraL10n.t('huer.insumos'))),
              ],
            ),
          ],
          bottom: TabBar(tabs: [
            Tab(text: SoleraL10n.t('huer.siembras')),
            Tab(text: SoleraL10n.t('huer.cosechas')),
            Tab(text: SoleraL10n.t('huer.aplicaciones')),
          ]),
        ),
        body: FutureBuilder<_DatosCuaderno>(
          future: _datos,
          builder: (context, instantanea) {
            final cargado = instantanea.data;
            if (cargado == null) {
              return const SizedBox.shrink();
            }
            final datos = cargado.datos;
            final (desde, hasta) = intervaloAnyo(_anyo);
            final siembras = [
              for (final siembra in datos.siembras)
                if (siembra.fechaReferenciaMs >= desde &&
                    siembra.fechaReferenciaMs <= hasta)
                  siembra
            ]..sort(
                (a, b) => a.fechaReferenciaMs.compareTo(b.fechaReferenciaMs));
            return TabBarView(children: [
              _Lista(
                vacio: SoleraL10n.t('huer.sin_siembras'),
                alAnadir: () => mostrarFormularioSiembra(context, datos: datos),
                textoAnadir: SoleraL10n.t('huer.nueva_siembra'),
                filas: [
                  for (final siembra in siembras)
                    ListTile(
                      leading: Icon(siembra.realizada
                          ? Icons.spa_outlined
                          : Icons.schedule_outlined),
                      title: Text(datos.nombreDeCultivo(siembra.cultivoId)),
                      subtitle: Text([
                        datos.nombreDeBancal(siembra.bancalId),
                        nombreTipoSiembra(siembra.tipo),
                        if (!siembra.realizada)
                          SoleraL10n.t('huer.planificada'),
                      ].join(' · ')),
                      trailing: Text(formatearFecha(siembra.fechaReferenciaMs)),
                      onTap: () => mostrarFormularioSiembra(context,
                          datos: datos, siembra: siembra),
                      onLongPress: () => _borrar(() => BaseDatosSoleraHuerta
                          .instancia
                          .borrarSiembra(siembra.id!)),
                    ),
                ],
              ),
              _Lista(
                vacio: SoleraL10n.t('huer.sin_cosechas'),
                alAnadir: () => mostrarFormularioCosecha(context, datos: datos),
                textoAnadir: SoleraL10n.t('huer.nueva_cosecha'),
                filas: [
                  for (final cosecha in cargado.cosechas)
                    ListTile(
                      leading: const Icon(Icons.shopping_basket_outlined),
                      title: Text(datos.nombreDeCultivo(cosecha.cultivoId)),
                      subtitle: Text([
                        datos.nombreDeBancal(cosecha.bancalId),
                        formatearFecha(cosecha.fechaMs),
                        nombreDestinoCosecha(cosecha.destino),
                      ].join(' · ')),
                      trailing: Text([
                        if (cosecha.kg > 0) formatearKilos(cosecha.kg),
                        if (cosecha.porUnidades)
                          SoleraL10n.tf(
                              'huer.n_piezas', {'n': cosecha.unidades}),
                      ].join(' · ')),
                      onTap: () => mostrarFormularioCosecha(context,
                          datos: datos, cosecha: cosecha),
                      onLongPress: () => _borrar(() => BaseDatosSoleraHuerta
                          .instancia
                          .borrarCosecha(cosecha.id!)),
                    ),
                ],
              ),
              _Lista(
                vacio: SoleraL10n.t('huer.sin_aplicaciones'),
                alAnadir: () =>
                    mostrarFormularioTratamiento(context, datos: datos),
                textoAnadir: SoleraL10n.t('huer.nueva_aplicacion'),
                filas: [
                  for (final aplicacion in cargado.aplicaciones)
                    ListTile(
                      leading: Icon(
                          datos.insumo(aplicacion.insumoId)?.esFitosanitario ==
                                  true
                              ? Icons.science_outlined
                              : Icons.compost_outlined),
                      title: Text(
                          datos.insumo(aplicacion.insumoId)?.nombre ?? '?'),
                      subtitle: Text([
                        aplicacion.bancalId == null
                            ? (datos.parcela(aplicacion.parcelaId)?.nombre ??
                                '?')
                            : datos.nombreDeBancal(aplicacion.bancalId!),
                        formatearFecha(aplicacion.fechaMs),
                        if (aplicacion.problema.isNotEmpty)
                          nombrePlaga(aplicacion.problema),
                      ].join(' · ')),
                      onTap: () => mostrarFormularioTratamiento(context,
                          datos: datos, tratamiento: aplicacion),
                      onLongPress: () => _borrar(() => BaseDatosSoleraHuerta
                          .instancia
                          .borrarTratamiento(aplicacion.id!)),
                    ),
                ],
              ),
            ]);
          },
        ),
      ),
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({
    required this.filas,
    required this.vacio,
    required this.alAnadir,
    required this.textoAnadir,
  });

  final List<Widget> filas;
  final String vacio;
  final VoidCallback alAnadir;
  final String textoAnadir;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: OutlinedButton.icon(
            onPressed: alAnadir,
            icon: const Icon(Icons.add),
            label: Text(textoAnadir),
          ),
        ),
        if (filas.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(vacio, textAlign: TextAlign.center),
          ),
        ...filas,
      ],
    );
  }
}
