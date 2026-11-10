import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, rellenoInferiorSeguro;

import '../datos/base_datos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/pedido_fijo.dart';
import '../modelos/receta.dart';
import 'hoja_formulario.dart';

/// Pedidos que se repiten cada semana (bares, tiendas, comedores).
class PantallaPedidosFijos extends StatefulWidget {
  const PantallaPedidosFijos({super.key});

  @override
  State<PantallaPedidosFijos> createState() => _PantallaPedidosFijosState();
}

class _PantallaPedidosFijosState extends State<PantallaPedidosFijos> {
  late Future<(List<PedidoFijo>, Map<int, Receta>)> _datos = _cargar();

  Future<(List<PedidoFijo>, Map<int, Receta>)> _cargar() async {
    final baseDatos = BaseDatosSoleraObrador.instancia;
    return (
      await baseDatos.listarPedidosFijos(),
      {
        for (final receta in await baseDatos.listarRecetas()) receta.id!: receta
      },
    );
  }

  /// «lun, mié, vie» en el idioma de la app (1 = lunes).
  String _dias(Set<int> dias) {
    final lunes = DateTime(2026, 1, 5);
    final formato = DateFormat.E(SoleraL10n.idioma);
    return (dias.toList()..sort())
        .map((dia) => formato.format(lunes.add(Duration(days: dia - 1))))
        .join(', ');
  }

  Future<void> _editar(Map<int, Receta> recetas, [PedidoFijo? pedido]) async {
    final cliente = TextEditingController(text: pedido?.cliente ?? '');
    final piezas =
        TextEditingController(text: pedido == null ? '' : '${pedido.piezas}');
    var recetaId = pedido?.recetaId;
    final dias = {...?pedido?.diasSemana};
    var activo = pedido?.activo ?? true;
    final productos =
        recetas.values.where((receta) => !receta.esSubreceta).toList();
    final guardado = await mostrarHojaFormulario(
      context,
      controladores: [cliente, piezas],
      titulo: pedido == null
          ? SoleraL10n.t('obra.nuevo_pedido_fijo')
          : pedido.cliente,
      construir: (refrescar) => [
        campoTexto(cliente, SoleraL10n.t('obra.cliente')),
        DropdownButtonFormField<int>(
          initialValue: recetaId,
          decoration: InputDecoration(labelText: SoleraL10n.t('obra.producto')),
          items: [
            for (final receta in productos)
              DropdownMenuItem(value: receta.id, child: Text(receta.nombre)),
          ],
          onChanged: (valor) => refrescar(() => recetaId = valor),
        ),
        campoNumero(piezas, SoleraL10n.t('obra.piezas'), decimales: false),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          children: [
            for (var dia = 1; dia <= 7; dia++)
              FilterChip(
                label: Text(_dias({dia})),
                selected: dias.contains(dia),
                onSelected: (marcado) =>
                    refrescar(() => marcado ? dias.add(dia) : dias.remove(dia)),
              ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(SoleraL10n.t('obra.activo')),
          value: activo,
          onChanged: (valor) => refrescar(() => activo = valor),
        ),
      ],
      guardar: () async {
        final numeroPiezas = int.tryParse(piezas.text.trim());
        if (cliente.text.trim().isEmpty ||
            recetaId == null ||
            numeroPiezas == null ||
            dias.isEmpty) {
          return false;
        }
        await BaseDatosSoleraObrador.instancia.guardarPedidoFijo(PedidoFijo(
          id: pedido?.id,
          cliente: cliente.text.trim(),
          recetaId: recetaId!,
          piezas: numeroPiezas,
          diasSemana: dias,
          activo: activo,
          notas: pedido?.notas ?? '',
        ));
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
    return FutureBuilder<(List<PedidoFijo>, Map<int, Receta>)>(
      future: _datos,
      builder: (context, instantanea) {
        final datos = instantanea.data;
        return Scaffold(
          appBar: AppBar(title: Text(SoleraL10n.t('obra.pedidos_fijos'))),
          floatingActionButton: datos == null
              ? null
              : FloatingActionButton(
                  tooltip: SoleraL10n.t('obra.nuevo_pedido_fijo'),
                  onPressed: () => _editar(datos.$2),
                  child: const Icon(Icons.add),
                ),
          body: datos == null
              ? const Center(child: CircularProgressIndicator())
              : datos.$1.isEmpty
                  ? Center(child: Text(SoleraL10n.t('obra.sin_pedidos_fijos')))
                  : ListView(
                      padding: rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 88)),
                      children: [
                        for (final pedido in datos.$1)
                          ListTile(
                            enabled: pedido.activo,
                            title: Text(
                                '${pedido.cliente} · ${datos.$2[pedido.recetaId]?.nombre ?? ''}'),
                            subtitle: Text(_dias(pedido.diasSemana)),
                            trailing: Text('${pedido.piezas}'),
                            onTap: () => _editar(datos.$2, pedido),
                          ),
                      ],
                    ),
        );
      },
    );
  }
}
