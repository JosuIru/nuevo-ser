import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show CabeceraHoySolera, CifraCabecera, SoleraL10n, TituloBloqueSolera;

import '../branding.dart';
import '../datos/catalogos_generados/flag_revision.dart';
import '../dominio/calendario_sanitario.dart';
import '../dominio/ocupacion_pastos.dart';
import '../estado/cambios_datos.dart';
import '../estado/datos_ganado.dart';
import '../utiles/textos_ganadera.dart';
import 'pantalla_manejo.dart';

/// Lo del día: dónde está cada rebaño y con qué carga, y lo que toca del
/// calendario sanitario (tareas y fin de supresiones).
class PantallaHoy extends StatefulWidget {
  const PantallaHoy({super.key});

  @override
  State<PantallaHoy> createState() => _PantallaHoyState();
}

class _PantallaHoyState extends State<PantallaHoy> {
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
    return Scaffold(
      body: FutureBuilder<DatosGanado>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          final ahora = DateTime.now();
          final estados = datos == null
              ? const <EstadoLote>[]
              : estadosDeLotes(
                  lotes: datos.lotes,
                  animales: datos.animales,
                  movimientos: datos.movimientos,
                  tabla: tablaUgmPantallas,
                  ahora: ahora);
          final cabezas =
              estados.fold<int>(0, (suma, estado) => suma + estado.cabezas);
          final ugm =
              estados.fold<double>(0, (suma, estado) => suma + estado.ugm);
          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              CabeceraHoySolera(
                titulo: 'Larrea Ganadera',
                rutaLogo: rutaLogoGanadera,
                fecha: DateFormat.MMMMEEEEd(SoleraL10n.idioma).format(ahora),
                cifras: [
                  CifraCabecera(
                      valor: '$cabezas',
                      etiqueta: SoleraL10n.t('gana.cabezas')),
                  CifraCabecera(
                      valor: formatearNumero(ugm, decimales: 1),
                      etiqueta: SoleraL10n.t('gana.ugm_pac')),
                  CifraCabecera(
                      valor: '${estados.length}',
                      etiqueta: SoleraL10n.t('gana.rebanos')),
                ],
              ),
              if (!catalogosCompletamenteRevisados)
                Card(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(SoleraL10n.t('gana.catalogos_provisionales')),
                  ),
                ),
              if (instantanea.hasError)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(SoleraL10n.t('gana.error_cargar')),
                ),
              if (datos != null) ..._bloques(context, datos, estados, ahora),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(SoleraL10n.t('gana.aviso_no_sustituye'),
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _bloques(BuildContext context, DatosGanado datos,
      List<EstadoLote> estados, DateTime ahora) {
    final piezas = datos.nombresPiezas;
    final superficies = {
      for (final pieza in datos.piezas) pieza.id: pieza.superficieHa
    };
    final avisos = avisosSanitarios(
        tareas: datos.tareas,
        eventos: datos.eventos,
        lotes: datos.lotes,
        animales: datos.animales,
        ahora: ahora,
        diasHorizonte: 14);
    return [
      if (datos.lotes.isEmpty && datos.piezas.isEmpty)
        Card(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: Text(SoleraL10n.t('gana.primeros_pasos')),
            subtitle: Text(SoleraL10n.t('gana.primeros_pasos_texto')),
          ),
        ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TituloBloqueSolera(SoleraL10n.t('gana.donde_esta_cada_rebano')),
      ),
      if (estados.isEmpty)
        ListTile(title: Text(SoleraL10n.t('gana.sin_rebanos')))
      else
        for (final estado in estados)
          ListTile(
            leading: const Icon(Icons.pets_outlined),
            title: Text(estado.lote.nombre),
            subtitle: Text([
              estado.piezaId == null
                  ? SoleraL10n.t('gana.fuera_o_sin_ubicar')
                  : piezas[estado.piezaId] ?? '—',
              '${estado.cabezas} ${SoleraL10n.t('gana.cabezas')}',
              () {
                final carga = estado.piezaId == null
                    ? null
                    : superficies[estado.piezaId] == null
                        ? null
                        : estado.ugm / superficies[estado.piezaId]!;
                return carga == null
                    ? '${formatearNumero(estado.ugm, decimales: 2)} UGM'
                    : '${formatearNumero(carga, decimales: 2)} UGM/ha';
              }(),
            ].join(' · ')),
          ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TituloBloqueSolera(SoleraL10n.t('gana.proximos_14_dias')),
      ),
      if (avisos.isEmpty)
        ListTile(title: Text(SoleraL10n.t('gana.sin_avisos')))
      else
        for (final aviso in avisos)
          TarjetaAvisoSanitario(
              aviso: aviso, lotes: datos.lotesPorId, ahora: ahora),
    ];
  }
}
