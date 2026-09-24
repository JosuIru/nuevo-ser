import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/campania.dart';
import '../modelos/lote_aceite.dart';
import '../modelos/olivar.dart';
import 'widgets/banner_catalogos_provisionales.dart';
import 'widgets/tarjeta_resumen_meteo.dart';

/// Dashboard de "hoy". Muestra el estado de la campaña activa, el
/// número de lotes y de parcelas, y los últimos lotes creados.
class PantallaHoy extends StatefulWidget {
  const PantallaHoy({super.key});

  @override
  State<PantallaHoy> createState() => _PantallaHoyState();
}

class _PantallaHoyState extends State<PantallaHoy> {
  final _formatoFecha = DateFormat('d/M/yyyy', 'es_ES');

  Olivar? _olivar;
  Campania? _campaniaActiva;
  List<LoteAceite> _ultimosLotes = const [];
  int _conteoParcelas = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final bd = BaseDatosSoleraAceitera();
    final olivar = await bd.obtenerOlivar();
    final campanias = await bd.listarCampanias();
    final activa =
        campanias.where((c) => c.estaAbierta).cast<Campania?>().firstWhere(
              (_) => true,
              orElse: () => null,
            );
    final lotes = await bd.listarLotesAceite();
    final parcelas = await bd.listarParcelas();
    if (!mounted) return;
    setState(() {
      _olivar = olivar;
      _campaniaActiva = activa;
      _ultimosLotes = lotes.take(5).toList(growable: false);
      _conteoParcelas = parcelas.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_olivar?.nombre ?? 'Solera Aceitera')),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Aviso de versión nueva: si no la hay, no ocupa sitio.
            AvisoActualizaciones(
              config: configActualizacionesMonorepo('solera-aceitera'),
              nombreApp: 'Solera Aceitera',
              margen: const EdgeInsets.only(bottom: 12),
            ),
            const BannerCatalogosProvisionales(),
            const TarjetaResumenMeteo(),
            const SizedBox(height: 12),
            _TarjetaCampania(
              campania: _campaniaActiva,
              formatoFecha: _formatoFecha,
            ),
            const SizedBox(height: 12),
            _TarjetaConteos(
              parcelas: _conteoParcelas,
              lotes: _ultimosLotes.length,
            ),
            const SizedBox(height: 24),
            const Text(
              'Últimos lotes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (_ultimosLotes.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Todavía no hay lotes de aceite. Crea uno desde "Lotes".',
                  ),
                ),
              )
            else
              ..._ultimosLotes.map((l) => Card(
                    child: ListTile(
                      title: Text(l.identificadorLote),
                      subtitle: Text(
                        '${l.kgNetos.toStringAsFixed(0)} kg · ${l.categoria}',
                      ),
                      trailing: Text(_formatoFecha
                          .format(DateTime.fromMillisecondsSinceEpoch(
                              l.fechaCreacionMs))),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _TarjetaCampania extends StatelessWidget {
  final Campania? campania;
  final DateFormat formatoFecha;

  const _TarjetaCampania({required this.campania, required this.formatoFecha});

  @override
  Widget build(BuildContext context) {
    if (campania == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.calendar_today, color: Color(0xFF5C6B3A)),
          title: Text('Sin campaña abierta'),
          subtitle: Text('Crea una desde Ajustes para empezar a registrar.'),
        ),
      );
    }
    final c = campania!;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_fire_department,
            color: Color(0xFF5C6B3A)),
        title: Text('Campaña ${c.anyoComercial}/${c.anyoComercial + 1}'),
        subtitle: Text(
          'Inicio: ${formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(c.fechaInicioMs))}'
          ' · Rendimiento medio: ${c.rendimientoMedioPorcentaje.toStringAsFixed(1)} %',
        ),
      ),
    );
  }
}

class _TarjetaConteos extends StatelessWidget {
  final int parcelas;
  final int lotes;

  const _TarjetaConteos({required this.parcelas, required this.lotes});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Bloque(numero: parcelas, etiqueta: 'Parcelas'),
            _Bloque(numero: lotes, etiqueta: 'Lotes'),
          ],
        ),
      ),
    );
  }
}

class _Bloque extends StatelessWidget {
  final int numero;
  final String etiqueta;

  const _Bloque({required this.numero, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$numero',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5C6B3A),
          ),
        ),
        Text(etiqueta),
      ],
    );
  }
}
