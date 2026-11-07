import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../datos/estado_bodega.dart';
import '../dominio/catalogos.dart';
import '../dominio/comprobacion_dop.dart';
import '../estado/cambios_datos.dart';
import '../modelos/partida_manzana.dart';
import '../modelos/prensado.dart';
import '../utiles/textos_sidra.dart';
import 'hoja_formulario.dart';
import 'pantalla_kupela.dart' show textoAviso;

/// Prensados: qué partidas entraron y a qué kupela fue el mosto.
class PantallaPrensados extends StatefulWidget {
  const PantallaPrensados({super.key});

  @override
  State<PantallaPrensados> createState() => _PantallaPrensadosState();
}

class _DatosPrensados {
  _DatosPrensados(
      this.estado, this.partidas, this.partidasPorPrensado, this.prensadas);

  final EstadoBodega estado;
  final List<PartidaManzana> partidas;
  final Map<int, List<int>> partidasPorPrensado;
  final Set<int> prensadas;
}

class _PantallaPrensadosState extends State<PantallaPrensados> {
  late Future<_DatosPrensados> _datos = _cargar();

  Future<_DatosPrensados> _cargar() async {
    final baseDatos = BaseDatosSoleraSidra.instancia;
    return _DatosPrensados(
      await EstadoBodega.cargar(),
      await baseDatos.listarPartidas(),
      await baseDatos.partidasPorPrensado(),
      await baseDatos.partidasPrensadas(),
    );
  }

  void _recargar() {
    avisarCambioDatos();
    setState(() {
      _datos = _cargar();
    });
  }

  Future<void> _nuevoPrensado(_DatosPrensados datos) async {
    final pendientes = datos.partidas
        .where((partida) => !datos.prensadas.contains(partida.id))
        .toList();
    final elegidas = <int>{};
    int? kupelaId;
    var fechaMs = DateTime.now().millisecondsSinceEpoch;
    final kilos = TextEditingController();
    final litros = TextEditingController();
    final presion = TextEditingController();
    final densidad = TextEditingController();
    final temperatura = TextEditingController();
    void sumarKilos() {
      final suma = pendientes
          .where((partida) => elegidas.contains(partida.id))
          .fold<double>(0, (total, partida) => total + partida.kilos);
      kilos.text = suma > 0 ? formatearNumero(suma, decimales: 0) : '';
    }

    final guardado = await mostrarHojaFormulario(
      controladores: [kilos, litros, presion, densidad, temperatura],
      context,
      titulo: SoleraL10n.t('sidr.nuevo_prensado'),
      construir: (refrescar) => [
        SelectorFecha(
          etiqueta: SoleraL10n.t('sidr.fecha'),
          fechaMs: fechaMs,
          alCambiar: (fecha) => refrescar(() => fechaMs = fecha ?? fechaMs),
        ),
        Text(SoleraL10n.t('sidr.partidas_que_entran'),
            style: Theme.of(context).textTheme.titleSmall),
        if (pendientes.isEmpty)
          Text(SoleraL10n.t('sidr.sin_partidas_pendientes')),
        for (final partida in pendientes)
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: elegidas.contains(partida.id),
            title: Text(
                '${formatearNumero(partida.kilos, decimales: 0)} kg · ${formatearFecha(partida.fechaEntregaMs)}'),
            subtitle: Text(partida.propia
                ? SoleraL10n.t('sidr.propia')
                : partida.proveedor),
            onChanged: (marcada) => refrescar(() {
              if (marcada == true) {
                elegidas.add(partida.id!);
              } else {
                elegidas.remove(partida.id);
              }
              sumarKilos();
            }),
          ),
        campoNumero(kilos, SoleraL10n.t('sidr.kilos'), sufijo: 'kg'),
        campoNumero(litros, SoleraL10n.t('sidr.litros_mosto'), sufijo: 'l'),
        campoDesplegable<int?>(
          etiqueta: SoleraL10n.t('sidr.kupela_destino'),
          valor: kupelaId,
          opciones: [
            for (final kupela in datos.estado.kupelas)
              if (kupela.activa) (kupela.id, kupela.etiqueta),
          ],
          alCambiar: (valor) => refrescar(() => kupelaId = valor),
        ),
        campoNumero(presion, SoleraL10n.t('sidr.presion'), sufijo: 'bar'),
        campoNumero(densidad, SoleraL10n.t('sidr.densidad_mosto')),
        campoNumero(temperatura, SoleraL10n.t('sidr.temperatura'),
            sufijo: '°C'),
      ],
      guardar: () async {
        final kilosFruta = leerNumero(kilos.text);
        final litrosMosto = leerNumero(litros.text);
        if (kupelaId == null ||
            kilosFruta == null ||
            litrosMosto == null ||
            litrosMosto <= 0) {
          return false;
        }
        await BaseDatosSoleraSidra.instancia.guardarPrensado(
          Prensado(
            fechaMs: fechaMs,
            kupelaId: kupelaId!,
            kilosFruta: kilosFruta,
            litrosMosto: litrosMosto,
            presionBar: leerNumero(presion.text),
            densidadMosto: leerNumero(densidad.text),
            temperaturaMostoC: leerNumero(temperatura.text),
          ),
          partidas: elegidas.toList(),
        );
        return true;
      },
    );
    if (guardado) _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DatosPrensados>(
      future: _datos,
      builder: (context, instantanea) {
        final datos = instantanea.data;
        return Scaffold(
          appBar: AppBar(title: Text(SoleraL10n.t('sidr.prensados'))),
          floatingActionButton: datos == null
              ? null
              : FloatingActionButton(
                  tooltip: SoleraL10n.t('sidr.nuevo_prensado'),
                  onPressed: () => _nuevoPrensado(datos),
                  child: const Icon(Icons.add),
                ),
          body: datos == null
              ? const Center(child: CircularProgressIndicator())
              : datos.estado.prensados.isEmpty
                  ? Center(child: Text(SoleraL10n.t('sidr.sin_prensados')))
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 88),
                      children: [
                        for (final prensado in datos.estado.prensados)
                          _filaPrensado(datos, prensado),
                      ],
                    ),
        );
      },
    );
  }

  Widget _filaPrensado(_DatosPrensados datos, Prensado prensado) {
    final producto = productoDopPorId(
        datos.estado.kupela(prensado.kupelaId)?.productoDopId ?? '');
    final avisos = producto == null
        ? const <AvisoDop>[]
        : avisosPrensado(prensado, producto);
    final rendimiento = prensado.rendimientoPorcentaje;
    return ListTile(
      leading: Icon(avisos.isEmpty
          ? Icons.compress_outlined
          : Icons.warning_amber_outlined),
      title: Text(
          '${formatearNumero(prensado.kilosFruta, decimales: 0)} kg → ${formatearLitros(prensado.litrosMosto)} · ${datos.estado.etiquetaKupela(prensado.kupelaId)}'),
      subtitle: Text([
        [
          formatearFecha(prensado.fechaMs),
          if (rendimiento != null)
            '${formatearNumero(rendimiento, decimales: 0)} %',
          if (prensado.densidadMosto != null)
            '${SoleraL10n.t('sidr.densidad')} ${formatearNumero(prensado.densidadMosto!, decimales: 0)}',
          SoleraL10n.tf('sidr.n_partidas',
              {'n': datos.partidasPorPrensado[prensado.id]?.length ?? 0}),
        ].join(' · '),
        for (final aviso in avisos) textoAviso(aviso),
      ].join('\n')),
    );
  }
}
