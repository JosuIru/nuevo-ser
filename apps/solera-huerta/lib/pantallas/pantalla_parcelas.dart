import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../estado/cambios_datos.dart';
import '../estado/datos_huerta.dart';
import '../utiles/textos_huerta.dart';
import 'formularios_huerta.dart';
import 'pantalla_ficha_parcela.dart';
import 'pantalla_mapa.dart';

/// Lista de parcelas con sus bancales y su situación ecológica.
class PantallaParcelas extends StatefulWidget {
  const PantallaParcelas({super.key});

  @override
  State<PantallaParcelas> createState() => _PantallaParcelasState();
}

class _PantallaParcelasState extends State<PantallaParcelas> {
  late Future<DatosHuerta> _datos;

  @override
  void initState() {
    super.initState();
    _datos = DatosHuerta.cargar();
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
      _datos = DatosHuerta.cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('huer.parcelas')),
        actions: [
          IconButton(
            tooltip: SoleraL10n.t('huer.mapa'),
            icon: const Icon(Icons.map_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaMapa())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: SoleraL10n.t('huer.nueva_parcela'),
        onPressed: () => mostrarFormularioParcela(context),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<DatosHuerta>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          if (datos == null) {
            return const SizedBox.shrink();
          }
          if (datos.parcelas.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(SoleraL10n.t('huer.sin_parcelas'),
                    textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              for (final parcela in datos.parcelas)
                ListTile(
                  leading: const Icon(Icons.grass_outlined),
                  title: Text(parcela.nombre),
                  subtitle: Text([
                    nombreEstadoEcologico(parcela.estadoEcologico),
                    SoleraL10n.tf('huer.n_bancales', {
                      'n': datos.bancales
                          .where((bancal) => bancal.parcelaId == parcela.id)
                          .length
                    }),
                  ].join(' · ')),
                  trailing: parcela.superficieHa > 0
                      ? Text(
                          '${formatearNumero(parcela.superficieHa, decimales: 2)} ha')
                      : null,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              PantallaFichaParcela(parcelaId: parcela.id!))),
                ),
            ],
          );
        },
      ),
    );
  }
}
