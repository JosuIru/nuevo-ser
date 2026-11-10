import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, rellenoInferiorSeguro;

import '../datos/base_datos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/hornada.dart';
import '../modelos/ingrediente.dart';
import '../modelos/lote_ingrediente.dart';
import '../modelos/pedido_fijo.dart';
import '../modelos/receta.dart';
import '../utiles/textos_obrador.dart';
import 'hoja_formulario.dart';

/// Hornadas de los últimos 30 días, con los lotes de ingrediente usados.
class PantallaHornadas extends StatefulWidget {
  const PantallaHornadas({super.key});

  @override
  State<PantallaHornadas> createState() => _PantallaHornadasState();
}

class _DatosHornadas {
  _DatosHornadas(this.hornadas, this.recetas, this.lineas, this.ingredientes,
      this.lotes, this.pedidosDeHoy);

  final List<Hornada> hornadas;
  final Map<int, Receta> recetas;
  final Map<int, List<LineaReceta>> lineas;
  final Map<int, Ingrediente> ingredientes;
  final List<LoteIngrediente> lotes;
  final Map<int, int> pedidosDeHoy;
}

class _PantallaHornadasState extends State<PantallaHornadas> {
  late Future<_DatosHornadas> _datos = _cargar();

  Future<_DatosHornadas> _cargar() async {
    final baseDatos = BaseDatosSoleraObrador.instancia;
    final ahora = DateTime.now();
    return _DatosHornadas(
      await baseDatos.listarHornadas(
          desdeMs:
              ahora.subtract(const Duration(days: 30)).millisecondsSinceEpoch,
          hastaMs: ahora.millisecondsSinceEpoch),
      {
        for (final receta in await baseDatos.listarRecetas()) receta.id!: receta
      },
      await baseDatos.lineasPorReceta(),
      {
        for (final ingrediente in await baseDatos.listarIngredientes())
          ingrediente.id!: ingrediente
      },
      await baseDatos.listarLotesIngrediente(),
      piezasPedidasPara(ahora, await baseDatos.listarPedidosFijos()),
    );
  }

  /// Ingredientes directos de la receta (sin desplegar subrecetas: sus
  /// lotes se apuntan al hacer la base).
  Set<int> _ingredientesDe(_DatosHornadas datos, int recetaId) => {
        for (final linea in datos.lineas[recetaId] ?? const <LineaReceta>[])
          if (linea.ingredienteId != null) linea.ingredienteId!,
      };

  Future<void> _nueva(_DatosHornadas datos) async {
    int? recetaId;
    final piezas = TextEditingController();
    final temperatura = TextEditingController();
    final minutos = TextEditingController();
    final responsable = TextEditingController();
    final lotesUsados = <int>{};
    final hoy = DateTime.now();
    final hornadasDeHoy = datos.hornadas.where((hornada) {
      final fecha = DateTime.fromMillisecondsSinceEpoch(hornada.fechaMs);
      return fecha.year == hoy.year &&
          fecha.month == hoy.month &&
          fecha.day == hoy.day;
    }).length;
    final guardado = await mostrarHojaFormulario(
      context,
      controladores: [piezas, temperatura, minutos, responsable],
      titulo: SoleraL10n.t('obra.nueva_hornada'),
      construir: (refrescar) {
        final ingredientesReceta =
            recetaId == null ? <int>{} : _ingredientesDe(datos, recetaId!);
        final lotesPosibles = datos.lotes
            .where((lote) => ingredientesReceta.contains(lote.ingredienteId));
        return [
          DropdownButtonFormField<int>(
            initialValue: recetaId,
            decoration:
                InputDecoration(labelText: SoleraL10n.t('obra.producto')),
            items: [
              for (final receta in datos.recetas.values)
                DropdownMenuItem(value: receta.id, child: Text(receta.nombre)),
            ],
            onChanged: (valor) => refrescar(() {
              recetaId = valor;
              lotesUsados.clear();
              final pedidas = valor == null ? null : datos.pedidosDeHoy[valor];
              if (pedidas != null && piezas.text.isEmpty)
                piezas.text = '$pedidas';
            }),
          ),
          campoNumero(piezas, SoleraL10n.t('obra.piezas'), decimales: false),
          campoNumero(temperatura, SoleraL10n.t('obra.temperatura_horno')),
          campoNumero(minutos, SoleraL10n.t('obra.minutos_horno'),
              decimales: false),
          campoTexto(responsable, SoleraL10n.t('obra.responsable')),
          if (lotesPosibles.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(SoleraL10n.t('obra.lotes_usados')),
            Wrap(
              spacing: 6,
              children: [
                for (final lote in lotesPosibles)
                  FilterChip(
                    label: Text(
                        '${datos.ingredientes[lote.ingredienteId]?.nombre} · ${lote.codigoLote}'),
                    selected: lotesUsados.contains(lote.id),
                    onSelected: (marcado) => refrescar(() => marcado
                        ? lotesUsados.add(lote.id!)
                        : lotesUsados.remove(lote.id)),
                  ),
              ],
            ),
          ],
        ];
      },
      guardar: () async {
        final numeroPiezas = int.tryParse(piezas.text.trim());
        if (recetaId == null || numeroPiezas == null) return false;
        await BaseDatosSoleraObrador.instancia.guardarHornada(
          Hornada(
            recetaId: recetaId!,
            fechaMs: hoy.millisecondsSinceEpoch,
            piezas: numeroPiezas,
            codigoLote: codigoLoteHornada(hoy, recetaId!, hornadasDeHoy + 1),
            temperaturaHornoC: leerNumero(temperatura.text),
            minutosHorno: int.tryParse(minutos.text.trim()),
            responsable: responsable.text.trim(),
          ),
          lotesUsados: lotesUsados.toList(),
        );
        return true;
      },
    );
    if (guardado) {
      avisarCambioDatos();
      setState(() {
        _datos = _cargar();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formato = DateFormat.MMMd(SoleraL10n.idioma).add_Hm();
    return FutureBuilder<_DatosHornadas>(
      future: _datos,
      builder: (context, instantanea) {
        final datos = instantanea.data;
        return Scaffold(
          appBar: AppBar(title: Text(SoleraL10n.t('obra.hornadas'))),
          floatingActionButton: datos == null
              ? null
              : FloatingActionButton(
                  tooltip: SoleraL10n.t('obra.nueva_hornada'),
                  onPressed: () => _nueva(datos),
                  child: const Icon(Icons.add),
                ),
          body: datos == null
              ? const Center(child: CircularProgressIndicator())
              : datos.hornadas.isEmpty
                  ? Center(child: Text(SoleraL10n.t('obra.sin_hornadas')))
                  : ListView(
                      padding: rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 88)),
                      children: [
                        for (final hornada in datos.hornadas)
                          ListTile(
                            title: Text(
                                '${datos.recetas[hornada.recetaId]?.nombre ?? ''} · ${hornada.piezas}'),
                            subtitle: Text(
                                '${formato.format(DateTime.fromMillisecondsSinceEpoch(hornada.fechaMs))}'
                                ' · ${SoleraL10n.t('obra.lote')} ${hornada.codigoLote}'),
                          ),
                      ],
                    ),
        );
      },
    );
  }
}
