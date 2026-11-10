import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, rellenoInferiorSeguro;

import '../datos/base_datos.dart';
import '../dominio/resumen_economico.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/parcela.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_extracto_economico_pdf.dart';
import '../utiles/textos_huerta.dart';
import 'hoja_formulario.dart';

class _DatosEconomia {
  _DatosEconomia(this.configuracion, this.apuntes, this.parcelas);

  final ConfiguracionFiscal configuracion;
  final List<ApunteEconomico> apuntes;
  final Map<int, Parcela> parcelas;
}

/// Libro de ingresos y gastos por año, con el régimen de IVA (REAGP o
/// general), las ventas por canal y el margen por parcela. PROVISIONAL
/// hasta el asesor fiscal.
class PantallaEconomia extends StatefulWidget {
  const PantallaEconomia({super.key});

  @override
  State<PantallaEconomia> createState() => _PantallaEconomiaState();
}

class _PantallaEconomiaState extends State<PantallaEconomia> {
  int _anyo = DateTime.now().year;
  late Future<_DatosEconomia> _datos = _cargar();

  BaseDatosSoleraHuerta get _bd => BaseDatosSoleraHuerta.instancia;

  Future<_DatosEconomia> _cargar() async {
    final (desde, hasta) = intervaloAnyo(_anyo);
    return _DatosEconomia(
      await _bd.obtenerConfiguracionFiscal(),
      await _bd.listarApuntesEconomicos(desdeMs: desde, hastaMs: hasta),
      {for (final parcela in await _bd.listarParcelas()) parcela.id!: parcela},
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
    await _bd
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
    var empresario = false;
    (int, double) impuestos() => esIngreso && esCategoriaVenta(categoria)
        ? datos.configuracion.impuestosVenta(compradorEmpresario: empresario)
        : (esIngreso ? 0 : 21, 0.0);
    var (tipoIva, compensacion) = impuestos();
    void recalcular() => (tipoIva, compensacion) = impuestos();
    final guardado = await mostrarHojaFormulario(
      context,
      titulo:
          SoleraL10n.t(esIngreso ? 'huer.nuevo_ingreso' : 'huer.nuevo_gasto'),
      controladores: [concepto, base, tercero],
      construir: (refrescar) => [
        selectorFecha(context,
            fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
        campoTexto(concepto, SoleraL10n.t('huer.concepto')),
        desplegable<String>(
          etiqueta: SoleraL10n.t('huer.categoria'),
          valor: categoria,
          opciones: categorias,
          nombre: nombreCategoriaEconomica,
          alCambiar: (valor) => refrescar(() {
            categoria = valor ?? categoria;
            recalcular();
          }),
        ),
        if (esIngreso && esCategoriaVenta(categoria))
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(SoleraL10n.t('huer.comprador_empresario')),
            subtitle: Text(SoleraL10n.t('huer.comprador_empresario_ayuda')),
            value: empresario,
            onChanged: (valor) => refrescar(() {
              empresario = valor;
              recalcular();
            }),
          ),
        desplegable<int?>(
          etiqueta: SoleraL10n.t('huer.parcela'),
          valor: parcelaId,
          opciones: [null, ...datos.parcelas.keys],
          nombre: (id) => id == null
              ? SoleraL10n.t('huer.toda_la_huerta')
              : datos.parcelas[id]!.nombre,
          alCambiar: (valor) => refrescar(() => parcelaId = valor),
        ),
        campoNumero(base, SoleraL10n.t('huer.base_euros')),
        if (compensacion > 0)
          Text(SoleraL10n.tf('huer.con_compensacion_reagp',
              {'n': formatearNumero(compensacion, decimales: 0)}))
        else if (esIngreso &&
            esCategoriaVenta(categoria) &&
            datos.configuracion.esReagp)
          Text(SoleraL10n.t('huer.reagp_sin_compensacion'))
        else
          Wrap(
            spacing: 6,
            children: [
              for (final tipo in tiposIvaPorcentaje)
                ChoiceChip(
                  label: Text('${SoleraL10n.t('huer.iva')} $tipo %'),
                  selected: tipoIva == tipo,
                  onSelected: (_) => refrescar(() => tipoIva = tipo),
                ),
            ],
          ),
        campoTexto(tercero,
            SoleraL10n.t(esIngreso ? 'huer.cliente' : 'huer.proveedor')),
      ],
      guardar: () async {
        final importe = leerNumero(base.text);
        if (concepto.text.trim().isEmpty || importe == null) return false;
        await _bd.guardarApunteEconomico(ApunteEconomico(
          esIngreso: esIngreso,
          fechaMs: fecha.millisecondsSinceEpoch,
          concepto: concepto.text.trim(),
          categoria: categoria,
          baseCentimos: (importe * 100).round(),
          tipoIvaPorcentaje: compensacion > 0 ? 0 : tipoIva,
          compensacionReagpPorcentaje: compensacion,
          compradorEmpresario: esIngreso && empresario,
          parcelaId: parcelaId,
          tercero: tercero.text.trim(),
        ));
        return true;
      },
    );
    if (guardado) _recargar();
  }

  Future<void> _borrar(ApunteEconomico apunte) async {
    if (!await confirmarBorrado(context, apunte.concepto)) return;
    await _bd.borrarApunteEconomico(apunte.id!);
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
            title: Text(SoleraL10n.t('huer.ingresos_y_gastos')),
            actions: [
              IconButton(
                tooltip: SoleraL10n.t('huer.extracto_pdf'),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: datos == null
                    ? null
                    : () => compartirDocumentoPdf(
                          context,
                          nombreFichero: 'ingresos_gastos_$_anyo.pdf',
                          generar: (tema) async => generarExtractoEconomicoPdf(
                            anyo: _anyo,
                            titular: await _bd.obtenerTitular(),
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
                      tooltip: SoleraL10n.t('huer.nuevo_gasto'),
                      onPressed: () => _nuevo(false, datos),
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton(
                      heroTag: 'ingreso',
                      tooltip: SoleraL10n.t('huer.nuevo_ingreso'),
                      onPressed: () => _nuevo(true, datos),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
          body:
              datos == null ? const SizedBox.shrink() : _cuerpo(context, datos),
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
          child: desplegable<String>(
            etiqueta: SoleraL10n.t('huer.regimen_iva'),
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
                tooltip: SoleraL10n.t('huer.anyo_anterior'),
                onPressed: () => _cambiarAnyo(-1),
                icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Text('$_anyo',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            IconButton(
                tooltip: SoleraL10n.t('huer.anyo_siguiente'),
                onPressed: () => _cambiarAnyo(1),
                icon: const Icon(Icons.chevron_right)),
          ],
        ),
        ListTile(
          title: Text(SoleraL10n.t('huer.resultado')),
          subtitle: Text(
              '${SoleraL10n.t('huer.ingresos')} ${formatearEuros(resumen.ingresosBase)}'
              ' · ${SoleraL10n.t('huer.gastos')} ${formatearEuros(resumen.gastosBase)}'
              '${resumen.compensacionesReagp > 0 ? ' · REAGP ${formatearEuros(resumen.compensacionesReagp)}' : ''}'),
          trailing: Text(formatearEuros(resumen.resultado),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color:
                      resumen.resultado < 0 ? esquema.error : esquema.primary)),
        ),
        for (final categoria in categoriasIngreso)
          if (esCategoriaVenta(categoria) &&
              resumen.basePorCategoria.containsKey(categoria))
            ListTile(
              dense: true,
              leading: const Icon(Icons.storefront_outlined),
              title: Text(nombreCategoriaEconomica(categoria)),
              trailing:
                  Text(formatearEuros(resumen.basePorCategoria[categoria]!)),
            ),
        for (final parcela in datos.parcelas.values)
          if (resumen.ingresosPorParcela.containsKey(parcela.id) ||
              resumen.gastosPorParcela.containsKey(parcela.id))
            ListTile(
              dense: true,
              leading: const Icon(Icons.grass_outlined),
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
          child: Text(SoleraL10n.t('huer.aviso_fiscal'),
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
