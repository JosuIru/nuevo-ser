import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TituloBloqueSolera, rellenoInferiorSeguro;

import '../branding.dart';
import '../estado/cambios_datos.dart';
import '../estado/datos_ganado.dart';
import '../modelos/carga_ganadera.dart';
import '../modelos/ganado.dart';
import '../modelos/historial_animal.dart';
import '../utiles/crotal.dart';
import '../utiles/textos_ganadera.dart';
import 'formularios_ganado.dart';
import 'pantalla_ficha_lote.dart';

/// Un animal: sus datos, la supresión que tiene y su historia.
class PantallaFichaAnimal extends StatefulWidget {
  const PantallaFichaAnimal({super.key, required this.animalId});

  final int animalId;

  @override
  State<PantallaFichaAnimal> createState() => _PantallaFichaAnimalState();
}

class _PantallaFichaAnimalState extends State<PantallaFichaAnimal> {
  late Future<DatosGanado> _datos = DatosGanado.cargar();

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
    setState(() {
      _datos = DatosGanado.cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DatosGanado>(
      future: _datos,
      builder: (context, instantanea) {
        final datos = instantanea.data;
        final animal = datos?.animales
            .where((animal) => animal.id == widget.animalId)
            .firstOrNull;
        if (datos == null || animal == null) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()));
        }
        final lote = datos.lotesPorId[animal.loteId];
        final ahora = DateTime.now();
        final eventos = datos.eventos
            .where((evento) =>
                evento.animalId == animal.id ||
                (evento.animalId == null && evento.loteId == animal.loteId))
            .toList();
        final supresion = supresionVigente(eventos, ahora,
            ecologico: lote?.ecologico ?? false);
        final hitos = historialDeAnimal(
            animal: animal, movimientos: datos.movimientos, eventos: eventos);
        final piezas = datos.nombresPiezas;
        return Scaffold(
          appBar: AppBar(
            title: Text(crotalLegible(animal.identificacion).isEmpty
                ? animal.nombre
                : crotalLegible(animal.identificacion)),
            actions: [
              if (lote != null)
                IconButton(
                  tooltip: SoleraL10n.t('editar'),
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => mostrarEdicionAnimal(context, lote, animal),
                ),
            ],
          ),
          floatingActionButton: lote == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () =>
                      mostrarAltaEvento(context, lote, animal: animal),
                  icon: const Icon(Icons.add),
                  label: Text(SoleraL10n.t('gana.nuevo_evento')),
                ),
          body: ListView(
            padding: rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 96)),
            children: [
              ListTile(
                title: Text(animal.rotulo),
                subtitle: Text([
                  nombreEspecie(animal.especie),
                  nombreSexo(animal.sexo),
                  animal.raza,
                  nombreDispositivo(animal.dispositivo),
                  if (animal.fechaNacimientoMs != null)
                    '${mesesCumplidos(DateTime.fromMillisecondsSinceEpoch(animal.fechaNacimientoMs!), ahora)} ${SoleraL10n.t('gana.meses')}',
                  if (lote != null) lote.nombre,
                  nombreEstadoAnimal(animal.estado),
                ].where((parte) => parte.isNotEmpty).join(' · ')),
              ),
              if (supresion.hayAlguna)
                ListTile(
                  leading: const Icon(Icons.no_food_outlined,
                      color: colorAcentoGanadera),
                  title: Text(SoleraL10n.t('gana.supresion_vigente')),
                  subtitle: Text([
                    if (supresion.carneHasta != null)
                      '${SoleraL10n.t('gana.carne_hasta')} ${formatearDia(supresion.carneHasta!)}',
                    if (supresion.lecheHasta != null)
                      '${SoleraL10n.t('gana.leche_hasta')} ${formatearDia(supresion.lecheHasta!)}',
                  ].join(' · ')),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TituloBloqueSolera(SoleraL10n.t('gana.historia')),
              ),
              for (final hito in hitos)
                switch (hito.tipo) {
                  TipoHitoAnimal.nacimiento => ListTile(
                      leading: const Icon(Icons.cake_outlined),
                      title: Text(SoleraL10n.t('gana.nacimiento')),
                      subtitle: Text(formatearFecha(hito.fechaMs)),
                    ),
                  TipoHitoAnimal.baja => ListTile(
                      leading: const Icon(Icons.logout),
                      title: Text(nombreEstadoAnimal(animal.estado)),
                      subtitle: Text(formatearFecha(hito.fechaMs)),
                    ),
                  TipoHitoAnimal.movimientoRebano => TarjetaMovimiento(
                      movimiento: hito.movimiento!, piezas: piezas),
                  TipoHitoAnimal.evento => TarjetaEvento(evento: hito.evento!),
                },
            ],
          ),
        );
      },
    );
  }
}
