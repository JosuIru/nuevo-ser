import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/resumen_economico.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/configuracion_fiscal.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_extracto_economico_pdf.dart';
import '../utiles/textos_vivero.dart';
import 'campos_especie.dart';
import 'hoja_formulario.dart';

class _DatosEconomia {
  _DatosEconomia(this.configuracion, this.apuntes, this.ventas);

  final ConfiguracionFiscal configuracion;
  final List<ApunteEconomico> apuntes;
  final List<VentaPlanta> ventas;
}

/// Ventas de planta del año: las salidas con importe.
Future<List<VentaPlanta>> cargarVentasPlanta(int desdeMs, int hastaMs) async {
  final bd = BaseDatosSoleraVivero.instancia;
  final partidas = {
    for (final partida in await bd.listarPartidas()) partida.id!: partida
  };
  return [
    for (final salida
        in await bd.listarSalidas(desdeMs: desdeMs, hastaMs: hastaMs))
      if (salida.importeCentimos > 0)
        VentaPlanta(
          fechaMs: salida.fechaMs,
          especieId: partidas[salida.partidaId]?.especieId ?? '',
          cantidad: salida.cantidad,
          baseCentimos: salida.importeCentimos,
          cliente: salida.clienteNombre,
        ),
  ];
}

/// Libro de ingresos y gastos por año: ventas de planta (de las salidas con
/// importe), otros ingresos y gastos, con el régimen de IVA (REAGP o
/// general). PROVISIONAL hasta el asesor fiscal.
class PantallaEconomia extends StatefulWidget {
  const PantallaEconomia({super.key});

  @override
  State<PantallaEconomia> createState() => _PantallaEconomiaState();
}

class _PantallaEconomiaState extends State<PantallaEconomia> {
  int _anyo = DateTime.now().year;
  late Future<_DatosEconomia> _datos = _cargar();

  Future<_DatosEconomia> _cargar() async {
    final bd = BaseDatosSoleraVivero.instancia;
    final (desde, hasta) = intervaloAnyo(_anyo);
    return _DatosEconomia(
      await bd.obtenerConfiguracionFiscal(),
      await bd.listarApuntesEconomicos(desdeMs: desde, hastaMs: hasta),
      await cargarVentasPlanta(desde, hasta),
    );
  }

  void _recargar() {
    setState(() {
      _datos = _cargar();
    });
  }

  void _cambiarAnyo(int desplazamiento) {
    _anyo += desplazamiento;
    _recargar();
  }

  Future<void> _cambiarRegimen(String regimen) async {
    await BaseDatosSoleraVivero.instancia
        .guardarConfiguracionFiscal(ConfiguracionFiscal(regimenIva: regimen));
    _recargar();
  }

  Future<void> _nuevo(bool esIngreso, _DatosEconomia datos) async {
    final concepto = TextEditingController();
    final base = TextEditingController();
    final tercero = TextEditingController();
    final categorias = esIngreso ? categoriasIngreso : categoriasGasto;
    var categoria = categorias.first;
    var fecha = DateTime.now();
    if (fecha.year != _anyo) fecha = DateTime(_anyo, 12, 31);
    final (ivaVenta, compensacionVenta) =
        datos.configuracion.impuestosVentaPlanta();
    var tipoIva = esIngreso ? ivaVenta : 21;
    var compensacion = esIngreso ? compensacionVenta : 0.0;
    final guardado = await mostrarHojaFormulario(
      context,
      titulo:
          SoleraL10n.t(esIngreso ? 'vive.nuevo_ingreso' : 'vive.nuevo_gasto'),
      construir: (refrescar) => [
        selectorFecha(context,
            fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
        campoTexto(concepto, SoleraL10n.t('vive.concepto')),
        selectorOpcion<String>(
          etiqueta: SoleraL10n.t('vive.categoria'),
          valor: categoria,
          opciones: categorias,
          nombre: nombreCategoriaEconomica,
          alCambiar: (valor) => refrescar(() {
            categoria = valor ?? categoria;
            // La compensación REAGP solo va en la venta de producto propio.
            if (esIngreso) {
              compensacion =
                  categoria == 'otras_ventas' ? compensacionVenta : 0;
              tipoIva = categoria == 'otras_ventas' ? ivaVenta : 0;
            }
          }),
        ),
        campoNumero(base, SoleraL10n.t('vive.base_euros')),
        const SizedBox(height: 8),
        if (compensacion > 0)
          Text(SoleraL10n.tf('vive.con_compensacion_reagp',
              {'n': formatearNumero(compensacion, decimales: 0)}))
        else
          Wrap(
            spacing: 6,
            children: [
              for (final tipo in tiposIvaPorcentaje)
                ChoiceChip(
                  label: Text('${SoleraL10n.t('vive.iva')} $tipo %'),
                  selected: tipoIva == tipo,
                  onSelected: (_) => refrescar(() => tipoIva = tipo),
                ),
            ],
          ),
        campoTexto(tercero,
            SoleraL10n.t(esIngreso ? 'vive.cliente' : 'vive.proveedor')),
      ],
      guardar: () async {
        final importe = leerNumero(base.text);
        if (concepto.text.trim().isEmpty || importe == null) return false;
        await BaseDatosSoleraVivero.instancia
            .guardarApunteEconomico(ApunteEconomico(
          esIngreso: esIngreso,
          fechaMs: fecha.millisecondsSinceEpoch,
          concepto: concepto.text.trim(),
          categoria: categoria,
          baseCentimos: (importe * 100).round(),
          tipoIvaPorcentaje: compensacion > 0 ? 0 : tipoIva,
          compensacionReagpPorcentaje: compensacion,
          tercero: tercero.text.trim(),
        ));
        return true;
      },
    );
    liberarControladores([concepto, base, tercero]);
    if (guardado) _recargar();
  }

  Future<void> _borrar(ApunteEconomico apunte) async {
    if (!await confirmar(context, SoleraL10n.t('vive.borrar_registro'))) {
      return;
    }
    await BaseDatosSoleraVivero.instancia.borrarApunteEconomico(apunte.id!);
    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DatosEconomia>(
      future: _datos,
      builder: (context, instantanea) {
        final datos = instantanea.data;
        return Scaffold(
          appBar: AppBar(
            title: Text(SoleraL10n.t('vive.ingresos_y_gastos')),
            actions: [
              IconButton(
                tooltip: SoleraL10n.t('vive.extracto_pdf'),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: datos == null
                    ? null
                    : () => compartirDocumentoPdf(
                          context,
                          nombreFichero: 'ingresos_gastos_$_anyo.pdf',
                          generar: (tema) async => generarExtractoEconomicoPdf(
                            anyo: _anyo,
                            vivero: await BaseDatosSoleraVivero.instancia
                                .obtenerVivero(),
                            configuracion: datos.configuracion,
                            apuntes: datos.apuntes,
                            ventas: datos.ventas,
                            nombreEspecie: nombreEspecieVisible,
                            tema: tema,
                          ),
                        ),
              ),
            ],
          ),
          floatingActionButton: datos == null
              ? null
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'gasto',
                      tooltip: SoleraL10n.t('vive.nuevo_gasto'),
                      onPressed: () => _nuevo(false, datos),
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton(
                      heroTag: 'ingreso',
                      tooltip: SoleraL10n.t('vive.nuevo_ingreso'),
                      onPressed: () => _nuevo(true, datos),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
          body: datos == null
              ? const Center(child: CircularProgressIndicator())
              : _cuerpo(context, datos),
        );
      },
    );
  }

  Widget _cuerpo(BuildContext context, _DatosEconomia datos) {
    final resumen = ResumenEconomico.calcular(
        apuntes: datos.apuntes,
        ventas: datos.ventas,
        configuracion: datos.configuracion);
    final esquema = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.only(bottom: 140),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: selectorOpcion<String>(
            etiqueta: SoleraL10n.t('vive.regimen_iva'),
            valor: datos.configuracion.regimenIva,
            opciones: regimenesIva,
            nombre: nombreRegimenIva,
            alCambiar: (valor) {
              if (valor != null) _cambiarRegimen(valor);
            },
          ),
        ),
        Row(
          children: [
            IconButton(
                tooltip: '${_anyo - 1}',
                onPressed: () => _cambiarAnyo(-1),
                icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Text('$_anyo',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            IconButton(
                tooltip: '${_anyo + 1}',
                onPressed: () => _cambiarAnyo(1),
                icon: const Icon(Icons.chevron_right)),
          ],
        ),
        ListTile(
          title: Text(SoleraL10n.t('vive.resultado')),
          subtitle: Text(
              '${SoleraL10n.t('vive.ingresos')} ${formatearEuros(resumen.ingresosBase)}'
              ' · ${SoleraL10n.t('vive.gastos')} ${formatearEuros(resumen.gastosBase)}'
              '${resumen.compensacionesReagp > 0 ? ' · REAGP ${formatearEuros(resumen.compensacionesReagp)}' : ''}'),
          trailing: Text(formatearEuros(resumen.resultado),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color:
                      resumen.resultado < 0 ? esquema.error : esquema.primary)),
        ),
        for (final entrada in resumen.ventasPorEspecie.entries)
          ListTile(
            dense: true,
            leading: const Icon(Icons.local_florist_outlined),
            title: Text(nombreEspecieVisible(entrada.key)),
            trailing: Text(formatearEuros(entrada.value)),
          ),
        const Divider(),
        for (final apunte in datos.apuntes)
          ListTile(
            leading: Icon(
                apunte.esIngreso ? Icons.arrow_downward : Icons.arrow_upward,
                color: apunte.esIngreso ? esquema.primary : esquema.error),
            title: Text(apunte.concepto),
            subtitle: Text('${nombreCategoriaEconomica(apunte.categoria)}'
                ' · ${formatearFecha(apunte.fechaMs)}'),
            trailing: Text(formatearEuros(apunte.totalCentimos)),
            onLongPress: () => _borrar(apunte),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(SoleraL10n.t('vive.aviso_fiscal'),
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
