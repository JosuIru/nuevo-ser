import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, rellenoInferiorSeguro;

import '../datos/base_datos.dart';
import '../dominio/resumen_economico.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/titular.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_extracto_economico_pdf.dart';
import '../utiles/textos_sidra.dart';
import 'hoja_formulario.dart';

/// Ingresos y gastos del mes, separando la venta de manzana (actividad
/// agraria, REAGP posible) de la sidra y el txotx (transformación y
/// servicios). PROVISIONAL: no es una liquidación de impuestos.
class PantallaEconomia extends StatefulWidget {
  const PantallaEconomia({super.key});

  @override
  State<PantallaEconomia> createState() => _PantallaEconomiaState();
}

class _PantallaEconomiaState extends State<PantallaEconomia> {
  DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month);
  late Future<(Titular, List<ApunteEconomico>)> _datos = _cargar();

  Future<(Titular, List<ApunteEconomico>)> _cargar() async {
    final baseDatos = BaseDatosSoleraSidra.instancia;
    return (
      await baseDatos.obtenerTitular(),
      await baseDatos.listarApuntesEconomicos(
          desdeMs: _mes.millisecondsSinceEpoch,
          hastaMs:
              DateTime(_mes.year, _mes.month + 1).millisecondsSinceEpoch - 1),
    );
  }

  void _recargar() {
    setState(() {
      _datos = _cargar();
    });
  }

  void _cambiarMes(int desplazamiento) {
    _mes = DateTime(_mes.year, _mes.month + desplazamiento);
    _recargar();
  }

  Future<void> _nuevoApunte(Titular titular) async {
    var esIngreso = true;
    var categoria = categoriasIngreso.first;
    var tipoIva = tipoIvaPropuesto(categoria);
    var compensacion = compensacionPropuesta(categoria, titular.regimenFiscal);
    var fechaMs = DateTime.now().millisecondsSinceEpoch;
    final concepto = TextEditingController();
    final base = TextEditingController();
    final tercero = TextEditingController();
    void elegirCategoria(String nueva) {
      categoria = nueva;
      tipoIva = tipoIvaPropuesto(nueva);
      compensacion = compensacionPropuesta(nueva, titular.regimenFiscal);
    }

    final guardado = await mostrarHojaFormulario(
      context,
      controladores: [concepto, base, tercero],
      titulo: SoleraL10n.t('sidr.nuevo_apunte'),
      construir: (refrescar) => [
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(
                value: true, label: Text(SoleraL10n.t('sidr.ingreso'))),
            ButtonSegment(
                value: false, label: Text(SoleraL10n.t('sidr.gasto'))),
          ],
          selected: {esIngreso},
          onSelectionChanged: (valor) => refrescar(() {
            esIngreso = valor.first;
            elegirCategoria(
                (esIngreso ? categoriasIngreso : categoriasGasto).first);
          }),
        ),
        SelectorFecha(
          etiqueta: SoleraL10n.t('sidr.fecha'),
          fechaMs: fechaMs,
          alCambiar: (fecha) => refrescar(() => fechaMs = fecha ?? fechaMs),
        ),
        campoTexto(concepto, SoleraL10n.t('sidr.concepto')),
        campoDesplegable<String>(
          key: ValueKey('categoria-$esIngreso'),
          etiqueta: SoleraL10n.t('sidr.categoria'),
          valor: categoria,
          opciones: [
            for (final valor in esIngreso ? categoriasIngreso : categoriasGasto)
              (valor, nombreValor('categoria', valor)),
          ],
          alCambiar: (valor) =>
              refrescar(() => elegirCategoria(valor ?? categoria)),
        ),
        campoNumero(base, SoleraL10n.t('sidr.base_sin_iva'), sufijo: '€'),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: compensacion,
          title: Text(SoleraL10n.t('sidr.con_compensacion_reagp')),
          subtitle: Text(SoleraL10n.t('sidr.con_compensacion_reagp_ayuda')),
          onChanged: (valor) => refrescar(() => compensacion = valor),
        ),
        if (!compensacion)
          campoDesplegable<int>(
            key: ValueKey('iva-$categoria'),
            etiqueta: SoleraL10n.t('sidr.tipo_iva'),
            valor: tipoIva,
            opciones: [
              for (final tipo in tiposIvaPorcentaje) (tipo, '$tipo %'),
            ],
            alCambiar: (valor) => refrescar(() => tipoIva = valor ?? tipoIva),
          ),
        campoTexto(tercero, SoleraL10n.t('sidr.tercero')),
      ],
      guardar: () async {
        final euros = leerNumero(base.text);
        if (concepto.text.trim().isEmpty || euros == null || euros <= 0) {
          return false;
        }
        await BaseDatosSoleraSidra.instancia.guardarApunteEconomico(
          ApunteEconomico(
            esIngreso: esIngreso,
            fechaMs: fechaMs,
            concepto: concepto.text.trim(),
            categoria: categoria,
            baseCentimos: (euros * 100).round(),
            tipoIvaPorcentaje: compensacion ? 0 : tipoIva,
            conCompensacionReagp: compensacion,
            tercero: tercero.text.trim(),
          ),
        );
        return true;
      },
    );
    if (guardado) _recargar();
  }

  Future<void> _extracto(Titular titular, List<ApunteEconomico> apuntes) =>
      compartirDocumentoPdf(
        context,
        nombreFichero:
            'ingresos_gastos_${DateFormat('yyyy_MM').format(_mes)}.pdf',
        generar: (tema) => generarExtractoEconomicoPdf(
            mes: _mes, titular: titular, apuntes: apuntes, tema: tema),
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(Titular, List<ApunteEconomico>)>(
      future: _datos,
      builder: (context, instantanea) {
        final datos = instantanea.data;
        return Scaffold(
          appBar: AppBar(
            title: Text(SoleraL10n.t('sidr.ingresos_y_gastos')),
            actions: [
              if (datos != null)
                IconButton(
                  tooltip: SoleraL10n.t('sidr.extracto_pdf'),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  onPressed: () => _extracto(datos.$1, datos.$2),
                ),
            ],
          ),
          floatingActionButton: datos == null
              ? null
              : FloatingActionButton(
                  tooltip: SoleraL10n.t('sidr.nuevo_apunte'),
                  onPressed: () => _nuevoApunte(datos.$1),
                  child: const Icon(Icons.add),
                ),
          body: datos == null
              ? const Center(child: CircularProgressIndicator())
              : _cuerpo(context, datos.$1, datos.$2),
        );
      },
    );
  }

  Widget _cuerpo(
      BuildContext context, Titular titular, List<ApunteEconomico> apuntes) {
    final resumen = ResumenEconomico.calcular(apuntes);
    return ListView(
      padding: rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 88)),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () => _cambiarMes(-1),
                icon: const Icon(Icons.chevron_left)),
            Text(DateFormat.yMMMM(SoleraL10n.idioma).format(_mes),
                style: Theme.of(context).textTheme.titleMedium),
            IconButton(
                onPressed: () => _cambiarMes(1),
                icon: const Icon(Icons.chevron_right)),
          ],
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${SoleraL10n.t('sidr.resultado')}: ${formatearEuros(resumen.resultado)}',
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                    '${SoleraL10n.t('sidr.actividad_agraria')}: ${formatearEuros(resumen.ingresosActividadAgraria)} · '
                    '${SoleraL10n.t('sidr.transformacion')}: ${formatearEuros(resumen.ingresosTransformacion)}'),
                Text(
                    '${SoleraL10n.t('sidr.iva_repercutido')}: ${formatearEuros(resumen.ivaRepercutido)} · '
                    '${SoleraL10n.t('sidr.iva_soportado')}: ${formatearEuros(resumen.ivaSoportado)}'),
                if (resumen.compensacionesCobradas > 0 ||
                    resumen.compensacionesPagadas > 0)
                  Text(
                      '${SoleraL10n.t('sidr.compensaciones_reagp')}: +${formatearEuros(resumen.compensacionesCobradas)} / −${formatearEuros(resumen.compensacionesPagadas)}'),
                const SizedBox(height: 4),
                Text(SoleraL10n.t('sidr.aviso_fiscal_provisional'),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
        if (apuntes.isEmpty)
          ListTile(title: Text(SoleraL10n.t('sidr.sin_apuntes'))),
        for (final apunte in apuntes)
          ListTile(
            leading: Icon(
                apunte.esIngreso ? Icons.arrow_downward : Icons.arrow_upward),
            title: Text(apunte.concepto),
            subtitle: Text([
              formatearFecha(apunte.fechaMs),
              nombreValor('categoria', apunte.categoria),
              apunte.conCompensacionReagp
                  ? SoleraL10n.t('sidr.compensacion_corto')
                  : '${SoleraL10n.t('sidr.iva')} ${apunte.tipoIvaPorcentaje} %',
            ].join(' · ')),
            trailing: Text(
                '${apunte.esIngreso ? '+' : '−'}${formatearEuros(apunte.totalCentimos)}'),
            onLongPress: () async {
              final borrar = await showDialog<bool>(
                context: context,
                builder: (contexto) => AlertDialog(
                  title: Text(SoleraL10n.t('sidr.borrar_apunte')),
                  content: Text(apunte.concepto),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(contexto, false),
                        child: Text(SoleraL10n.t('cancelar'))),
                    FilledButton(
                        onPressed: () => Navigator.pop(contexto, true),
                        child: Text(SoleraL10n.t('borrar'))),
                  ],
                ),
              );
              if (borrar != true) return;
              await BaseDatosSoleraSidra.instancia
                  .borrarApunteEconomico(apunte.id!);
              _recargar();
            },
          ),
      ],
    );
  }
}
