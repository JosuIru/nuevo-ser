import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TituloBloqueSolera, rellenoInferiorSeguro;

import '../branding.dart';
import '../estado/cambios_datos.dart';
import '../estado/datos_ganado.dart';
import '../modelos/ganado.dart';
import '../modelos/ganado_ecologico.dart';
import '../utiles/textos_ganadera.dart';
import 'formularios_ganado.dart';
import '../utiles/trayecto_movimiento.dart';
import 'lectura_receta.dart';
import 'pantalla_documentos.dart';
import 'pantalla_ficha_animal.dart';

/// Un rebaño: dónde está, sus animales, sus movimientos y su manejo.
class PantallaFichaLote extends StatefulWidget {
  const PantallaFichaLote({super.key, required this.loteId});

  final int loteId;

  @override
  State<PantallaFichaLote> createState() => _PantallaFichaLoteState();
}

class _PantallaFichaLoteState extends State<PantallaFichaLote> {
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
        final lote = datos?.lotesPorId[widget.loteId];
        if (datos == null || lote == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
                child: instantanea.hasError
                    ? Text(SoleraL10n.t('gana.error_cargar'))
                    : const CircularProgressIndicator()),
          );
        }
        return _construir(context, datos, lote);
      },
    );
  }

  Widget _construir(BuildContext context, DatosGanado datos, LoteGanado lote) {
    final ahora = DateTime.now();
    final animales =
        datos.animales.where((animal) => animal.loteId == lote.id).toList();
    final movimientos = datos.movimientos
        .where((movimiento) => movimiento.loteId == lote.id)
        .toList();
    final eventos = datos.eventos
        .where((evento) => evento.loteId == lote.id && evento.animalId == null)
        .toList();
    final piezas = datos.nombresPiezas;
    final piezaActual = piezaActualDeLote(movimientos);
    final cabezas = cabezasDeLote(lote, animales);
    final ugm = ugmDeLote(lote, animales, ahora, tablaUgmPantallas);
    final supresion =
        supresionVigente(eventos, ahora, ecologico: lote.ecologico);
    final ecologico = lote.ecologico
        ? estadoTratamientosEcologico(eventos, ahora,
            cicloCorto: lote.cicloCorto)
        : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(lote.nombre),
        actions: [
          IconButton(
            tooltip: SoleraL10n.t('editar'),
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => mostrarEdicionLote(context, lote),
          ),
        ],
      ),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 32)),
        children: [
          ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text(piezaActual == null
                ? SoleraL10n.t('gana.fuera_o_sin_ubicar')
                : piezas[piezaActual] ?? '—'),
            subtitle: Text([
              nombreEspecie(lote.especie),
              '$cabezas ${SoleraL10n.t('gana.cabezas')}',
              '${formatearNumero(ugm, decimales: 2)} ${SoleraL10n.t('gana.ugm_pac')}',
              if (lote.ecologico) SoleraL10n.t('gana.ecologico'),
            ].join(' · ')),
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
          if (ecologico != null)
            ListTile(
              leading: Icon(Icons.eco_outlined,
                  color: ecologico.superado ? colorAcentoGanadera : null),
              title: Text(SoleraL10n.tf('gana.tratamientos_ecologico', {
                'n': ecologico.tratamientos,
                'limite': ecologico.limite,
              })),
              subtitle: ecologico.superado
                  ? Text(SoleraL10n.t('gana.limite_ecologico_superado'))
                  : null,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(SoleraL10n.t('gana.mover')),
                  onPressed: () => mostrarAltaMovimiento(context, lote,
                      piezas: datos.piezas,
                      piezaActual: piezaActual,
                      cabezasActuales: cabezas),
                ),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.add),
                  label: Text(SoleraL10n.t('gana.nuevo_animal')),
                  onPressed: () => mostrarEdicionAnimal(context, lote),
                ),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.vaccines_outlined),
                  label: Text(SoleraL10n.t('gana.manejo_del_rebano')),
                  onPressed: () => mostrarAltaEvento(context, lote),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.document_scanner_outlined),
                  label: Text(SoleraL10n.t('gana.leer_receta_ia')),
                  onPressed: () => leerRecetaYApuntar(context, lote),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TituloBloqueSolera(SoleraL10n.t('gana.animales')),
          ),
          if (animales.isEmpty)
            ListTile(title: Text(SoleraL10n.t('gana.sin_animales')))
          else
            for (final animal in animales)
              ListTile(
                leading: Icon(animal.activo
                    ? Icons.label_outline
                    : Icons.label_off_outlined),
                title: Text(animal.rotulo.isEmpty ? '—' : animal.rotulo),
                subtitle: Text([
                  nombreSexo(animal.sexo),
                  animal.raza,
                  if (!animal.activo) nombreEstadoAnimal(animal.estado),
                ].where((parte) => parte.isNotEmpty).join(' · ')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            PantallaFichaAnimal(animalId: animal.id!))),
              ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TituloBloqueSolera(SoleraL10n.t('gana.movimientos')),
          ),
          if (movimientos.isEmpty)
            ListTile(title: Text(SoleraL10n.t('gana.sin_movimientos')))
          else
            for (final movimiento in movimientos.reversed)
              TarjetaMovimiento(
                movimiento: movimiento,
                piezas: piezas,
                alPulsar: movimiento.cambiaUbicacion &&
                        movimiento.tipo == tipoMovimientoTraslado
                    ? null
                    : () => compartirDocumentoMovimiento(
                        context, movimiento, lote, animales),
              ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TituloBloqueSolera(SoleraL10n.t('gana.manejo_del_rebano')),
          ),
          if (eventos.isEmpty)
            ListTile(title: Text(SoleraL10n.t('gana.sin_eventos')))
          else
            for (final evento in eventos) TarjetaEvento(evento: evento),
        ],
      ),
    );
  }
}

class TarjetaMovimiento extends StatelessWidget {
  const TarjetaMovimiento(
      {super.key,
      required this.movimiento,
      required this.piezas,
      this.alPulsar});

  final MovimientoGanado movimiento;
  final Map<int, String> piezas;

  /// Con explotación externa: abre su documento de movimiento.
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Icon(Icons.swap_horiz),
        trailing:
            alPulsar == null ? null : const Icon(Icons.picture_as_pdf_outlined),
        onTap: alPulsar,
        title: Text(trayectoMovimiento(movimiento, piezas)),
        subtitle: Text([
          formatearFecha(movimiento.fechaMs),
          nombreTipoMovimiento(movimiento.tipo),
          if (movimiento.cabezas > 0)
            '${movimiento.cabezas} ${SoleraL10n.t('gana.cabezas')}',
          if (movimiento.codigoRemo.isNotEmpty) movimiento.codigoRemo,
        ].join(' · ')),
      );
}

class TarjetaEvento extends StatelessWidget {
  const TarjetaEvento({super.key, required this.evento});

  final EventoGanado evento;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(evento.llevaMedicamento
            ? Icons.vaccines_outlined
            : Icons.event_outlined),
        title: Text([
          nombreTipoEvento(evento.tipo),
          if (evento.sustanciaActiva.isNotEmpty) evento.sustanciaActiva,
        ].join(' · ')),
        subtitle: Text([
          formatearFecha(evento.fechaMs),
          if (evento.descripcion.isNotEmpty) evento.descripcion,
          if (evento.plazoSupresionCarneDias > 0)
            '${SoleraL10n.t('gana.espera_carne_dias')}: ${evento.plazoSupresionCarneDias}',
          if (evento.plazoSupresionLecheDias > 0)
            '${SoleraL10n.t('gana.espera_leche_dias')}: ${evento.plazoSupresionLecheDias}',
          if (evento.pesoKg != null) '${formatearNumero(evento.pesoKg!)} kg',
          if (evento.crias > 0) '${evento.crias} ${SoleraL10n.t('gana.crias')}',
        ].join(' · ')),
      );
}
