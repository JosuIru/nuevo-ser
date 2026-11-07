import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show DialogoConfirmacion, SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/resumen_economico.dart';
import '../modelos/apunte_economico.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_extracto_economico_pdf.dart';
import '../utiles/textos_obrador.dart';
import 'hoja_formulario.dart';

/// Libro de ingresos y gastos, mes a mes.
class PantallaEconomia extends StatefulWidget {
  const PantallaEconomia({super.key});

  @override
  State<PantallaEconomia> createState() => _PantallaEconomiaState();
}

class _PantallaEconomiaState extends State<PantallaEconomia> {
  DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month);
  late Future<List<ApunteEconomico>> _apuntes = _cargar();

  Future<List<ApunteEconomico>> _cargar() =>
      BaseDatosSoleraObrador.instancia.listarApuntesEconomicos(
          desdeMs: _mes.millisecondsSinceEpoch,
          hastaMs:
              DateTime(_mes.year, _mes.month + 1).millisecondsSinceEpoch - 1);

  void _cambiarMes(int desplazamiento) => setState(() {
        _mes = DateTime(_mes.year, _mes.month + desplazamiento);
        _apuntes = _cargar();
      });

  Future<void> _nuevo(bool esIngreso) async {
    final concepto = TextEditingController();
    final base = TextEditingController();
    final tercero = TextEditingController();
    final categorias = esIngreso ? categoriasIngreso : categoriasGasto;
    var categoria = categorias.first;
    var tipoIva = esIngreso ? 4 : 21;
    final guardado = await mostrarHojaFormulario(
      context,
      titulo:
          SoleraL10n.t(esIngreso ? 'obra.nuevo_ingreso' : 'obra.nuevo_gasto'),
      construir: (refrescar) => [
        campoTexto(concepto, SoleraL10n.t('obra.concepto')),
        DropdownButtonFormField<String>(
          initialValue: categoria,
          decoration:
              InputDecoration(labelText: SoleraL10n.t('obra.categoria')),
          items: [
            for (final opcion in categorias)
              DropdownMenuItem(
                  value: opcion, child: Text(nombreCategoriaEconomica(opcion))),
          ],
          onChanged: (valor) => refrescar(() => categoria = valor ?? categoria),
        ),
        campoNumero(base, SoleraL10n.t('obra.base_euros')),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: [
            for (final tipo in tiposIvaPorcentaje)
              ChoiceChip(
                label: Text('${SoleraL10n.t('obra.iva')} $tipo %'),
                selected: tipoIva == tipo,
                onSelected: (_) => refrescar(() => tipoIva = tipo),
              ),
          ],
        ),
        campoTexto(tercero,
            SoleraL10n.t(esIngreso ? 'obra.cliente' : 'obra.proveedor')),
      ],
      guardar: () async {
        final importe = leerNumero(base.text);
        if (concepto.text.trim().isEmpty || importe == null) return false;
        final ahora = DateTime.now();
        final enMesVisible =
            ahora.year == _mes.year && ahora.month == _mes.month;
        await BaseDatosSoleraObrador.instancia
            .guardarApunteEconomico(ApunteEconomico(
          esIngreso: esIngreso,
          fechaMs: (enMesVisible ? ahora : _mes).millisecondsSinceEpoch,
          concepto: concepto.text.trim(),
          categoria: categoria,
          baseCentimos: (importe * 100).round(),
          tipoIvaPorcentaje: tipoIva,
          tercero: tercero.text.trim(),
        ));
        return true;
      },
    );
    for (final controlador in [concepto, base, tercero]) {
      controlador.dispose();
    }
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
    await BaseDatosSoleraObrador.instancia.borrarApunteEconomico(apunte.id!);
    setState(() {
      _apuntes = _cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nombreMes = DateFormat.yMMMM(SoleraL10n.idioma).format(_mes);
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('obra.ingresos_y_gastos')),
        actions: [
          IconButton(
            tooltip: SoleraL10n.t('obra.extracto_pdf'),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => compartirDocumentoPdf(
              context,
              nombreFichero:
                  'ingresos_gastos_${DateFormat('yyyy_MM').format(_mes)}.pdf',
              generar: (tema) async => generarExtractoEconomicoPdf(
                periodo: nombreMes,
                titular:
                    await BaseDatosSoleraObrador.instancia.obtenerTitular(),
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
            tooltip: SoleraL10n.t('obra.nuevo_gasto'),
            onPressed: () => _nuevo(false),
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'ingreso',
            tooltip: SoleraL10n.t('obra.nuevo_ingreso'),
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
            padding: const EdgeInsets.only(bottom: 140),
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
                title: Text(SoleraL10n.t('obra.resultado')),
                subtitle: Text(
                    '${SoleraL10n.t('obra.ingresos')} ${formatearEuros(resumen.ingresosBase)}'
                    ' · ${SoleraL10n.t('obra.gastos')} ${formatearEuros(resumen.gastosBase)}'),
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
                  subtitle: Text('${nombreCategoriaEconomica(apunte.categoria)}'
                      ' · ${DateFormat.MMMd(SoleraL10n.idioma).format(DateTime.fromMillisecondsSinceEpoch(apunte.fechaMs))}'),
                  trailing: Text(formatearEuros(apunte.totalCentimos)),
                  onLongPress: () => _borrar(apunte),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(SoleraL10n.t('obra.aviso_fiscal'),
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          );
        },
      ),
    );
  }
}
