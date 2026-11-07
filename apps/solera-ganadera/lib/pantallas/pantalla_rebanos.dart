import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../dominio/ocupacion_pastos.dart';
import '../estado/cambios_datos.dart';
import '../estado/datos_ganado.dart';
import '../utiles/textos_ganadera.dart';
import 'formularios_ganado.dart';
import 'pantalla_ficha_lote.dart';

/// Los rebaños activos, con dónde están y cuántas cabezas tienen.
class PantallaRebanos extends StatefulWidget {
  const PantallaRebanos({super.key});

  @override
  State<PantallaRebanos> createState() => _PantallaRebanosState();
}

class _PantallaRebanosState extends State<PantallaRebanos> {
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
      appBar: AppBar(title: Text(SoleraL10n.t('gana.rebanos'))),
      floatingActionButton: FloatingActionButton(
        tooltip: SoleraL10n.t('gana.nuevo_rebano'),
        onPressed: () => mostrarEdicionLote(context),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<DatosGanado>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          if (datos == null) {
            return instantanea.hasError
                ? Center(child: Text(SoleraL10n.t('gana.error_cargar')))
                : const Center(child: CircularProgressIndicator());
          }
          final estados = estadosDeLotes(
              lotes: datos.lotes,
              animales: datos.animales,
              movimientos: datos.movimientos,
              tabla: tablaUgmPantallas,
              ahora: DateTime.now());
          if (estados.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(SoleraL10n.t('gana.sin_rebanos'),
                    textAlign: TextAlign.center),
              ),
            );
          }
          final piezas = datos.nombresPiezas;
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              for (final estado in estados)
                ListTile(
                  leading: const Icon(Icons.pets_outlined),
                  title: Text(estado.lote.nombre),
                  subtitle: Text([
                    nombreEspecie(estado.lote.especie),
                    '${estado.cabezas} ${SoleraL10n.t('gana.cabezas')}',
                    estado.piezaId == null
                        ? SoleraL10n.t('gana.fuera_o_sin_ubicar')
                        : piezas[estado.piezaId] ?? '—',
                    if (estado.lote.ecologico) SoleraL10n.t('gana.ecologico'),
                  ].join(' · ')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              PantallaFichaLote(loteId: estado.lote.id!))),
                ),
            ],
          );
        },
      ),
    );
  }
}
