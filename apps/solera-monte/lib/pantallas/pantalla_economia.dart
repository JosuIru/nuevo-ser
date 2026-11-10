import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, rellenoInferiorSeguro;

import '../datos/base_datos.dart';
import '../dominio/resumen_economico.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/rodal.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_extracto_economico_pdf.dart';
import '../utiles/textos_monte.dart';
import 'hoja_formulario.dart';

class _DatosEconomia {
  _DatosEconomia(this.regimen, this.apuntes, this.rodales);

  final String regimen;
  final List<ApunteEconomico> apuntes;
  final Map<int, Rodal> rodales;
}

/// Libro de ingresos y gastos del monte por año (subastas, lotes, pastos,
/// ayudas, trabajos), con el margen por rodal. PROVISIONAL hasta el asesor
/// fiscal: la fiscalidad de una comunidad de montes o de una junta vecinal
/// está por verificar.
class PantallaEconomia extends StatefulWidget {
  const PantallaEconomia({super.key});

  @override
  State<PantallaEconomia> createState() => _PantallaEconomiaState();
}

class _PantallaEconomiaState extends State<PantallaEconomia> {
  int _anyo = DateTime.now().year;
  late Future<_DatosEconomia> _datos = _cargar();

  BaseDatosSoleraMonte get _bd => BaseDatosSoleraMonte.instancia;

  Future<_DatosEconomia> _cargar() async {
    final (desde, hasta) = intervaloAnyo(_anyo);
    return _DatosEconomia(
      await _bd.obtenerRegimenFiscal(),
      await _bd.listarApuntesEconomicos(desdeMs: desde, hastaMs: hasta),
      {for (final rodal in await _bd.listarRodales()) rodal.id!: rodal},
    );
  }

  void _recargar() {
    setState(() {
      _datos = _cargar();
    });
  }

  Future<void> _nuevo(bool esIngreso, _DatosEconomia datos) async {
    final concepto = TextEditingController();
    final base = TextEditingController();
    final tercero = TextEditingController();
    final categorias = esIngreso ? categoriasIngreso : categoriasGasto;
    var categoria = categorias.first;
    var fecha = DateTime.now();
    if (fecha.year != _anyo) fecha = DateTime(_anyo, 12, 31);
    int? rodalId;
    var (tipoIva, compensacion) = esIngreso
        ? impuestosVenta(datos.regimen, categoria)
        : (tipoIvaVentaForestalPorDefecto, 0.0);
    String? error;
    final guardado = await mostrarHojaFormulario(
      context,
      titulo:
          SoleraL10n.t(esIngreso ? 'mont.nuevo_ingreso' : 'mont.nuevo_gasto'),
      controladores: [concepto, base, tercero],
      construir: (refrescar) => [
        selectorFecha(context,
            fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
        campoTexto(concepto, SoleraL10n.t('mont.concepto')),
        DropdownButtonFormField<String>(
          initialValue: categoria,
          isExpanded: true,
          decoration:
              InputDecoration(labelText: SoleraL10n.t('mont.categoria')),
          items: [
            for (final opcion in categorias)
              DropdownMenuItem(
                  value: opcion, child: Text(nombreCategoriaEconomica(opcion))),
          ],
          onChanged: (valor) => refrescar(() {
            categoria = valor ?? categoria;
            if (esIngreso) {
              (tipoIva, compensacion) =
                  impuestosVenta(datos.regimen, categoria);
            }
          }),
        ),
        selectorId(
            etiqueta: SoleraL10n.t('mont.rodal'),
            valor: rodalId,
            opciones: [
              for (final rodal in datos.rodales.values)
                (rodal.id!, rodal.etiqueta)
            ],
            textoNinguno: SoleraL10n.t('mont.todo_el_monte'),
            alCambiar: (valor) => refrescar(() => rodalId = valor)),
        campoNumero(base, SoleraL10n.t('mont.base_euros')),
        const SizedBox(height: 8),
        if (esIngreso && necesitaAvisoFiscal(datos.regimen, categoria))
          textoAviso(context, SoleraL10n.t('mont.aviso_fiscal_categoria')),
        if (compensacion > 0)
          Text(SoleraL10n.tf('mont.con_compensacion_reagp',
              {'n': formatearNumero(compensacion, decimales: 0)}))
        else
          Wrap(
            spacing: 6,
            children: [
              for (final tipo in tiposIvaPorcentaje)
                ChoiceChip(
                  label: Text('${SoleraL10n.t('mont.iva')} $tipo %'),
                  selected: tipoIva == tipo,
                  onSelected: (_) => refrescar(() => tipoIva = tipo),
                ),
            ],
          ),
        campoTexto(tercero, SoleraL10n.t('mont.tercero')),
        if (error != null) textoAviso(context, error!),
      ],
      guardar: () async {
        final importe = leerNumero(base.text);
        if (concepto.text.trim().isEmpty || importe == null) {
          error = SoleraL10n.t('mont.falta_concepto_importe');
          return false;
        }
        await _bd.guardarApunteEconomico(ApunteEconomico(
          esIngreso: esIngreso,
          fechaMs: fecha.millisecondsSinceEpoch,
          concepto: concepto.text.trim(),
          categoria: categoria,
          baseCentimos: (importe * 100).round(),
          tipoIvaPorcentaje: compensacion > 0 ? 0 : tipoIva,
          compensacionReagpPorcentaje: compensacion,
          rodalId: rodalId,
          tercero: tercero.text.trim(),
        ));
        return true;
      },
    );
    if (guardado) _recargar();
  }

  Future<void> _borrar(ApunteEconomico apunte) async {
    if (!await confirmar(context, 'mont.borrar_apunte',
        detalle: apunte.concepto)) {
      return;
    }
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
            title: Text(SoleraL10n.t('mont.ingresos_y_gastos')),
            actions: [
              IconButton(
                tooltip: SoleraL10n.t('mont.extracto_pdf'),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: datos == null
                    ? null
                    : () => compartirDocumentoPdf(
                          context,
                          nombreFichero: 'ingresos_gastos_monte_$_anyo.pdf',
                          generar: (tema) async => generarExtractoEconomicoPdf(
                            anyo: _anyo,
                            monte: await _bd.obtenerMonte(),
                            regimen: datos.regimen,
                            apuntes: datos.apuntes,
                            rodales: datos.rodales.values.toList(),
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
                      tooltip: SoleraL10n.t('mont.nuevo_gasto'),
                      onPressed: () => _nuevo(false, datos),
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton(
                      heroTag: 'ingreso',
                      tooltip: SoleraL10n.t('mont.nuevo_ingreso'),
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
            initialValue: datos.regimen,
            isExpanded: true,
            decoration:
                InputDecoration(labelText: SoleraL10n.t('mont.regimen_fiscal')),
            items: [
              for (final regimen in regimenesFiscalesMonte)
                DropdownMenuItem(
                    value: regimen, child: Text(nombreRegimenFiscal(regimen))),
            ],
            onChanged: (valor) async {
              if (valor == null) return;
              await _bd.guardarRegimenFiscal(valor);
              _recargar();
            },
          ),
        ),
        Row(
          children: [
            IconButton(
                onPressed: () {
                  _anyo--;
                  _recargar();
                },
                icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Text('$_anyo',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            IconButton(
                onPressed: () {
                  _anyo++;
                  _recargar();
                },
                icon: const Icon(Icons.chevron_right)),
          ],
        ),
        ListTile(
          title: Text(SoleraL10n.t('mont.resultado_economico')),
          subtitle: Text(
              '${SoleraL10n.t('mont.ingresos')} ${formatearEuros(resumen.ingresosBase)}'
              ' · ${SoleraL10n.t('mont.gastos')} ${formatearEuros(resumen.gastosBase)}'
              '${resumen.compensacionesReagp > 0 ? ' · REAGP ${formatearEuros(resumen.compensacionesReagp)}' : ''}'),
          trailing: Text(formatearEuros(resumen.resultado),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color:
                      resumen.resultado < 0 ? esquema.error : esquema.primary)),
        ),
        for (final rodal in datos.rodales.values)
          if (resumen.ingresosPorRodal.containsKey(rodal.id) ||
              resumen.gastosPorRodal.containsKey(rodal.id))
            ListTile(
              dense: true,
              leading: const Icon(Icons.pentagon_outlined),
              title: Text(rodal.etiqueta),
              trailing: Text(formatearEuros(resumen.margenRodal(rodal.id))),
            ),
        const Divider(),
        if (datos.apuntes.isEmpty)
          ListTile(title: Text(SoleraL10n.t('mont.sin_apuntes'))),
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
          child: Text(SoleraL10n.t('mont.aviso_fiscal'),
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
