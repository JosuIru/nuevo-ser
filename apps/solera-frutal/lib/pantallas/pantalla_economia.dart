import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show
        DialogoConfirmacion,
        SoleraL10n,
        rellenoInferiorSeguro,
        separarCampoSolera;

import '../datos/base_datos.dart';
import '../dominio/resumen_economico.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/parcela.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_extracto_economico_pdf.dart';
import '../utiles/textos_frutal.dart';
import 'hoja_formulario.dart';

class _DatosEconomia {
  _DatosEconomia(this.configuracion, this.apuntes, this.parcelas);

  final ConfiguracionFiscal configuracion;
  final List<ApunteEconomico> apuntes;
  final Map<int, Parcela> parcelas;
}

/// Libro de ingresos y gastos por año, con el régimen de IVA (REAGP o
/// general) y el margen por parcela. PROVISIONAL hasta el asesor fiscal.
class PantallaEconomia extends StatefulWidget {
  const PantallaEconomia({super.key});

  @override
  State<PantallaEconomia> createState() => _PantallaEconomiaState();
}

class _PantallaEconomiaState extends State<PantallaEconomia> {
  int _anyo = DateTime.now().year;
  late Future<_DatosEconomia> _datos = _cargar();

  Future<_DatosEconomia> _cargar() async {
    final baseDatos = BaseDatosSoleraFrutal.instancia;
    final (desde, hasta) = intervaloAnyo(_anyo);
    return _DatosEconomia(
      await baseDatos.obtenerConfiguracionFiscal(),
      await baseDatos.listarApuntesEconomicos(desdeMs: desde, hastaMs: hasta),
      {
        for (final parcela in await baseDatos.listarParcelas())
          parcela.id!: parcela
      },
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
    await BaseDatosSoleraFrutal.instancia
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
    int? parcelaId;
    final (ivaVenta, compensacionVenta) =
        datos.configuracion.impuestosVentaCosecha();
    var tipoIva = esIngreso ? ivaVenta : 21;
    var compensacion = esIngreso ? compensacionVenta : 0.0;
    final guardado = await mostrarHojaFormulario(
      context,
      titulo:
          SoleraL10n.t(esIngreso ? 'frut.nuevo_ingreso' : 'frut.nuevo_gasto'),
      construir: (refrescar) => [
        selectorFecha(context,
            fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
        campoTexto(concepto, SoleraL10n.t('frut.concepto')),
        separarCampoSolera(DropdownButtonFormField<String>(
          initialValue: categoria,
          decoration:
              InputDecoration(labelText: SoleraL10n.t('frut.categoria')),
          items: [
            for (final opcion in categorias)
              DropdownMenuItem(
                  value: opcion, child: Text(nombreCategoriaEconomica(opcion))),
          ],
          onChanged: (valor) => refrescar(() {
            categoria = valor ?? categoria;
            // La compensación REAGP solo va en la venta de la cosecha.
            if (esIngreso) {
              compensacion =
                  categoria == 'venta_cosecha' ? compensacionVenta : 0;
              tipoIva = categoria == 'venta_cosecha' ? ivaVenta : 0;
            }
          }),
        )),
        separarCampoSolera(DropdownButtonFormField<int?>(
          initialValue: parcelaId,
          decoration: InputDecoration(labelText: SoleraL10n.t('frut.parcela')),
          items: [
            DropdownMenuItem<int?>(
                value: null,
                child: Text(SoleraL10n.t('frut.toda_explotacion'))),
            for (final parcela in datos.parcelas.values)
              DropdownMenuItem<int?>(
                  value: parcela.id, child: Text(parcela.nombre)),
          ],
          onChanged: (valor) => refrescar(() => parcelaId = valor),
        )),
        campoNumero(base, SoleraL10n.t('frut.base_euros')),
        if (compensacion > 0)
          Text(SoleraL10n.tf('frut.con_compensacion_reagp',
              {'n': formatearNumero(compensacion, decimales: 0)}))
        else
          Wrap(
            spacing: 6,
            children: [
              for (final tipo in tiposIvaPorcentaje)
                ChoiceChip(
                  label: Text('${SoleraL10n.t('frut.iva')} $tipo %'),
                  selected: tipoIva == tipo,
                  onSelected: (_) => refrescar(() => tipoIva = tipo),
                ),
            ],
          ),
        campoTexto(tercero,
            SoleraL10n.t(esIngreso ? 'frut.cliente' : 'frut.proveedor')),
      ],
      guardar: () async {
        final importe = leerNumero(base.text);
        if (concepto.text.trim().isEmpty || importe == null) return false;
        await BaseDatosSoleraFrutal.instancia
            .guardarApunteEconomico(ApunteEconomico(
          esIngreso: esIngreso,
          fechaMs: fecha.millisecondsSinceEpoch,
          concepto: concepto.text.trim(),
          categoria: categoria,
          baseCentimos: (importe * 100).round(),
          tipoIvaPorcentaje: compensacion > 0 ? 0 : tipoIva,
          compensacionReagpPorcentaje: compensacion,
          parcelaId: parcelaId,
          tercero: tercero.text.trim(),
        ));
        return true;
      },
    );
    for (final controlador in [concepto, base, tercero]) {
      controlador.dispose();
    }
    if (guardado) _recargar();
  }

  Future<void> _borrar(ApunteEconomico apunte) async {
    final confirmado = await DialogoConfirmacion.mostrar(context,
        titulo: SoleraL10n.t('borrar'),
        mensaje: apunte.concepto,
        esPeligroso: true);
    if (!confirmado) return;
    await BaseDatosSoleraFrutal.instancia.borrarApunteEconomico(apunte.id!);
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
            title: Text(SoleraL10n.t('frut.ingresos_y_gastos')),
            actions: [
              IconButton(
                tooltip: SoleraL10n.t('frut.extracto_pdf'),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: datos == null
                    ? null
                    : () => compartirDocumentoPdf(
                          context,
                          nombreFichero: 'ingresos_gastos_$_anyo.pdf',
                          generar: (tema) async => generarExtractoEconomicoPdf(
                            anyo: _anyo,
                            titular: await BaseDatosSoleraFrutal.instancia
                                .obtenerTitular(),
                            configuracion: datos.configuracion,
                            apuntes: datos.apuntes,
                            parcelas: datos.parcelas.values.toList(),
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
                      tooltip: SoleraL10n.t('frut.nuevo_gasto'),
                      onPressed: () => _nuevo(false, datos),
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton(
                      heroTag: 'ingreso',
                      tooltip: SoleraL10n.t('frut.nuevo_ingreso'),
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
    final resumen = ResumenEconomico.calcular(datos.apuntes);
    final esquema = Theme.of(context).colorScheme;
    return ListView(
      padding: rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 140)),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: DropdownButtonFormField<String>(
            initialValue: datos.configuracion.regimenIva,
            decoration:
                InputDecoration(labelText: SoleraL10n.t('frut.regimen_iva')),
            items: [
              for (final regimen in regimenesIva)
                DropdownMenuItem(
                    value: regimen, child: Text(nombreRegimenIva(regimen))),
            ],
            onChanged: (valor) {
              if (valor != null) _cambiarRegimen(valor);
            },
          ),
        ),
        Row(
          children: [
            IconButton(
                onPressed: () => _cambiarAnyo(-1),
                icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Text('$_anyo',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            IconButton(
                onPressed: () => _cambiarAnyo(1),
                icon: const Icon(Icons.chevron_right)),
          ],
        ),
        ListTile(
          title: Text(SoleraL10n.t('frut.resultado')),
          subtitle: Text(
              '${SoleraL10n.t('frut.ingresos')} ${formatearEuros(resumen.ingresosBase)}'
              ' · ${SoleraL10n.t('frut.gastos')} ${formatearEuros(resumen.gastosBase)}'
              '${resumen.compensacionesReagp > 0 ? ' · REAGP ${formatearEuros(resumen.compensacionesReagp)}' : ''}'),
          trailing: Text(formatearEuros(resumen.resultado),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color:
                      resumen.resultado < 0 ? esquema.error : esquema.primary)),
        ),
        for (final parcela in datos.parcelas.values)
          if (resumen.ingresosPorParcela.containsKey(parcela.id) ||
              resumen.gastosPorParcela.containsKey(parcela.id))
            ListTile(
              dense: true,
              leading: const Icon(Icons.park_outlined),
              title: Text(parcela.nombre),
              trailing: Text(formatearEuros(resumen.margenParcela(parcela.id))),
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
          child: Text(SoleraL10n.t('frut.aviso_fiscal'),
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
