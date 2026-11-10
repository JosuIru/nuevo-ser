import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show DialogoConfirmacion, SoleraL10n, rellenoInferiorSeguro;

import '../datos/base_datos.dart';
import '../dominio/resumen_economico.dart';
import '../modelos/apunte_economico.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_extracto_economico_pdf.dart';
import '../utiles/textos_ganadera.dart';
import 'formularios_ganado.dart' show desplegableCodigo;
import 'hoja_formulario.dart';
import 'pantalla_manejo.dart' show selectorFecha;

/// Libro de ingresos y gastos, mes a mes. PROVISIONAL fiscal.
class PantallaEconomia extends StatefulWidget {
  const PantallaEconomia({super.key});

  @override
  State<PantallaEconomia> createState() => _PantallaEconomiaState();
}

class _PantallaEconomiaState extends State<PantallaEconomia> {
  DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month);
  late Future<List<ApunteEconomico>> _apuntes = _cargar();

  Future<List<ApunteEconomico>> _cargar() =>
      BaseDatosSoleraGanadera.instancia.listarApuntesEconomicos(
          desdeMs: _mes.millisecondsSinceEpoch,
          hastaMs:
              DateTime(_mes.year, _mes.month + 1).millisecondsSinceEpoch - 1);

  void _cambiarMes(int desplazamiento) {
    setState(() {
      _mes = DateTime(_mes.year, _mes.month + desplazamiento);
      _apuntes = _cargar();
    });
  }

  Future<void> _nuevo(bool esIngreso) async {
    final concepto = TextEditingController();
    final base = TextEditingController();
    final tercero = TextEditingController();
    final compensacion = TextEditingController(
        text: formatearNumero(compensacionReagpGanaderaPorDefecto));
    final categorias = esIngreso ? categoriasIngreso : categoriasGasto;
    var categoria = categorias.first;
    var regimen = esIngreso ? regimenReagp : regimenIva;
    var tipoIva = esIngreso ? 10.0 : 21.0;
    final ahora = DateTime.now();
    var fecha =
        ahora.year == _mes.year && ahora.month == _mes.month ? ahora : _mes;
    final guardado = await mostrarHojaFormulario(
      context,
      titulo:
          SoleraL10n.t(esIngreso ? 'gana.nuevo_ingreso' : 'gana.nuevo_gasto'),
      construir: (refrescar) => [
        campoTexto(concepto, SoleraL10n.t('gana.concepto')),
        desplegableCodigo(
            etiqueta: SoleraL10n.t('gana.categoria'),
            valor: categoria,
            opciones: categorias,
            nombre: nombreCategoriaEconomica,
            alCambiar: (valor) => refrescar(() => categoria = valor)),
        selectorFecha(context, SoleraL10n.t('gana.fecha'), fecha,
            (elegida) => refrescar(() => fecha = elegida)),
        campoNumero(base, SoleraL10n.t('gana.base_euros')),
        if (esIngreso)
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: regimenReagp, label: const Text('REAGP')),
              ButtonSegment(
                  value: regimenIva, label: Text(SoleraL10n.t('gana.iva'))),
            ],
            selected: {regimen},
            onSelectionChanged: (elegido) =>
                refrescar(() => regimen = elegido.first),
          ),
        if (regimen == regimenReagp)
          campoNumero(
              compensacion, SoleraL10n.t('gana.porcentaje_compensacion'))
        else
          Wrap(
            spacing: 6,
            children: [
              for (final tipo in tiposIvaPorcentaje)
                ChoiceChip(
                  label: Text(
                      '${SoleraL10n.t('gana.iva')} ${formatearNumero(tipo, decimales: 0)} %'),
                  selected: tipoIva == tipo,
                  onSelected: (_) => refrescar(() => tipoIva = tipo),
                ),
            ],
          ),
        campoTexto(tercero,
            SoleraL10n.t(esIngreso ? 'gana.cliente' : 'gana.proveedor_simple')),
      ],
      guardar: () async {
        final importe = leerNumero(base.text);
        if (concepto.text.trim().isEmpty || importe == null) return false;
        await BaseDatosSoleraGanadera.instancia
            .guardarApunteEconomico(ApunteEconomico(
          esIngreso: esIngreso,
          fechaMs: fecha.millisecondsSinceEpoch,
          concepto: concepto.text.trim(),
          categoria: categoria,
          baseCentimos: (importe * 100).round(),
          regimen: regimen,
          porcentaje: regimen == regimenReagp
              ? leerNumero(compensacion.text) ??
                  compensacionReagpGanaderaPorDefecto
              : tipoIva,
          tercero: tercero.text.trim(),
        ));
        return true;
      },
    );
    if (guardado) {
      setState(() {
        _apuntes = _cargar();
      });
    }
  }

  Future<void> _borrar(ApunteEconomico apunte) async {
    final confirmado = await DialogoConfirmacion.mostrar(context,
        titulo: SoleraL10n.t('borrar'),
        mensaje: apunte.concepto,
        esPeligroso: true);
    if (!confirmado) return;
    await BaseDatosSoleraGanadera.instancia.borrarApunteEconomico(apunte.id!);
    setState(() {
      _apuntes = _cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nombreMes = DateFormat.yMMMM(SoleraL10n.idioma).format(_mes);
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('gana.ingresos_y_gastos')),
        actions: [
          IconButton(
            tooltip: SoleraL10n.t('gana.extracto_pdf'),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => compartirDocumentoPdf(
              context,
              nombreFichero:
                  'ingresos_gastos_${DateFormat('yyyy_MM').format(_mes)}.pdf',
              generar: (tema) async => generarExtractoEconomicoPdf(
                periodo: nombreMes,
                titular:
                    await BaseDatosSoleraGanadera.instancia.obtenerTitular(),
                apuntes: await _cargar(),
                tema: tema,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'gasto',
            tooltip: SoleraL10n.t('gana.nuevo_gasto'),
            onPressed: () => _nuevo(false),
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'ingreso',
            tooltip: SoleraL10n.t('gana.nuevo_ingreso'),
            onPressed: () => _nuevo(true),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<List<ApunteEconomico>>(
        future: _apuntes,
        builder: (context, instantanea) {
          final apuntes = instantanea.data ?? const <ApunteEconomico>[];
          final resumen = ResumenEconomico.calcular(apuntes);
          final esquema = Theme.of(context).colorScheme;
          return ListView(
            padding: rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 140)),
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () => _cambiarMes(-1),
                      icon: const Icon(Icons.chevron_left)),
                  Expanded(
                    child: Text(nombreMes,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  IconButton(
                      onPressed: () => _cambiarMes(1),
                      icon: const Icon(Icons.chevron_right)),
                ],
              ),
              ListTile(
                title: Text(SoleraL10n.t('gana.resultado')),
                subtitle: Text(
                    '${SoleraL10n.t('gana.ingresos')} ${formatearEuros(resumen.ingresosBase)}'
                    ' · ${SoleraL10n.t('gana.gastos')} ${formatearEuros(resumen.gastosBase)}'
                    ' · ${SoleraL10n.t('gana.compensacion_reagp')} ${formatearEuros(resumen.compensacionReagp)}'),
                trailing: Text(formatearEuros(resumen.resultado),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: resumen.resultado < 0
                            ? esquema.error
                            : esquema.primary)),
              ),
              const Divider(),
              for (final apunte in apuntes)
                ListTile(
                  leading: Icon(
                      apunte.esIngreso
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color:
                          apunte.esIngreso ? esquema.primary : esquema.error),
                  title: Text(apunte.concepto),
                  subtitle: Text(filaExtracto(apunte).take(4).join(' · ')),
                  trailing: Text(formatearEuros(apunte.totalCentimos)),
                  onLongPress: () => _borrar(apunte),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(SoleraL10n.t('gana.aviso_fiscal'),
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          );
        },
      ),
    );
  }
}
