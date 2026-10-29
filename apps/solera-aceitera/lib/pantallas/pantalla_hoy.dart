import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/campania.dart';
import '../modelos/lote_aceite.dart';
import '../modelos/olivar.dart';
import 'pantalla_campanias.dart';
import 'pantalla_ficha_lote.dart';
import 'pantalla_lista_lotes.dart';
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
  int _conteoLotes = 0;
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
      _conteoLotes = lotes.length;
      _conteoParcelas = parcelas.length;
    });
  }

  /// Abre una pantalla encima y, al volver, recarga el resumen.
  Future<void> _abrir(WidgetBuilder construirPantalla) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: construirPantalla));
    if (mounted) await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_olivar?.nombre ?? 'Larrea Aceitera')),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Aviso de versión nueva: si no la hay, no ocupa sitio.
            AvisoActualizaciones(
              config: configActualizacionesMonorepo('solera-aceitera'),
              nombreApp: 'Larrea Aceitera',
              margen: const EdgeInsets.only(bottom: 12),
            ),
            const BannerCatalogosProvisionales(),
            const TarjetaResumenMeteo(),
            const SizedBox(height: 12),
            _TarjetaCampania(
              campania: _campaniaActiva,
              formatoFecha: _formatoFecha,
              alPulsar: () => _abrir((_) => const PantallaCampanias()),
            ),
            const SizedBox(height: 12),
            _TarjetaConteos(
              parcelas: _conteoParcelas,
              lotes: _conteoLotes,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Últimos lotes',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () => _abrir((_) => const PantallaListaLotes()),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_ultimosLotes.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Todavía no hay lotes de aceite. Nacen al molturar una '
                    'partida: Registros → Lotes de aceite.',
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
                      onTap: () => _abrir((_) => PantallaFichaLote(lote: l)),
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
  final VoidCallback alPulsar;

  const _TarjetaCampania({
    required this.campania,
    required this.formatoFecha,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    if (campania == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.calendar_today, color: Color(0xFF5C6B3A)),
          title: const Text('Sin campaña abierta'),
          subtitle: const Text('Toca para abrir una (también en Registros → '
              'Campañas de recolección).'),
          trailing: const Icon(Icons.chevron_right),
          onTap: alPulsar,
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
        trailing: const Icon(Icons.chevron_right),
        onTap: alPulsar,
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
