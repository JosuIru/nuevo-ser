import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../datos/estado_bodega.dart';
import '../dominio/campania.dart';
import '../estado/cambios_datos.dart';
import '../modelos/sesion_txotx.dart';
import '../utiles/textos_sidra.dart';
import 'hoja_formulario.dart';

/// Temporada de txotx: qué kupela se abre cada día y cuánto se sirve.
class PantallaTxotx extends StatefulWidget {
  const PantallaTxotx({super.key});

  @override
  State<PantallaTxotx> createState() => _PantallaTxotxState();
}

class _PantallaTxotxState extends State<PantallaTxotx> {
  late Future<EstadoBodega> _estado;

  @override
  void initState() {
    super.initState();
    _estado = EstadoBodega.cargar();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() {
    setState(() {
      _estado = EstadoBodega.cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final campania = campaniaDe(DateTime.now());
    final rango = rangoCampania(campania);
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('sidr.txotx')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(SoleraL10n.tf(
                'sidr.temporada', {'campania': nombreCampania(campania)})),
          ),
        ),
      ),
      floatingActionButton: FutureBuilder<EstadoBodega>(
        future: _estado,
        builder: (context, instantanea) => FloatingActionButton.extended(
          onPressed: instantanea.data == null
              ? null
              : () => mostrarAltaSesionTxotx(context, instantanea.data!),
          icon: const Icon(Icons.local_bar_outlined),
          label: Text(SoleraL10n.t('sidr.abrir_kupela')),
        ),
      ),
      body: FutureBuilder<EstadoBodega>(
        future: _estado,
        builder: (context, instantanea) {
          final estado = instantanea.data;
          if (estado == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final sesiones = estado.sesionesTxotx
              .where((sesion) =>
                  sesion.fechaMs >= rango.desdeMs &&
                  sesion.fechaMs <= rango.hastaMs)
              .toList();
          if (sesiones.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(SoleraL10n.t('sidr.sin_txotx'),
                    textAlign: TextAlign.center),
              ),
            );
          }
          final porKupela = <int, double>{};
          for (final sesion in sesiones) {
            porKupela.update(
                sesion.kupelaId, (suma) => suma + sesion.litrosServidos,
                ifAbsent: () => sesion.litrosServidos);
          }
          final total = porKupela.values.fold<double>(0, (a, b) => a + b);
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              ListTile(
                title: Text(SoleraL10n.tf('sidr.resumen_txotx', {
                  'dias': sesiones
                      .map((s) => formatearFecha(s.fechaMs))
                      .toSet()
                      .length,
                  'litros': formatearLitros(total),
                })),
              ),
              for (final MapEntry(key: kupelaId, value: litros)
                  in porKupela.entries)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.propane_tank_outlined),
                  title: Text(estado.etiquetaKupela(kupelaId)),
                  trailing: Text(
                      '${formatearLitros(litros)} · ${SoleraL10n.tf('sidr.quedan', {
                        'litros':
                            formatearLitros(estado.saldo.litrosEn(kupelaId))
                      })}'),
                ),
              const Divider(),
              for (final sesion in sesiones)
                ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: Text(
                      '${formatearFecha(sesion.fechaMs)} · ${estado.etiquetaKupela(sesion.kupelaId)}'),
                  subtitle: Text([
                    formatearLitros(sesion.litrosServidos),
                    if (sesion.comensales != null)
                      SoleraL10n.tf(
                          'sidr.n_comensales', {'n': sesion.comensales}),
                    if (sesion.notas.isNotEmpty) sesion.notas,
                  ].join(' · ')),
                  trailing: IconButton(
                    tooltip: SoleraL10n.t('borrar'),
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await BaseDatosSoleraSidra.instancia
                          .borrarSesionTxotx(sesion.id!);
                      avisarCambioDatos();
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Hoja para apuntar un día de txotx.
Future<void> mostrarAltaSesionTxotx(
    BuildContext context, EstadoBodega estado) async {
  final kupelas = estado.kupelasConContenido;
  if (kupelas.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('sidr.sin_kupelas_llenas'))));
    return;
  }
  int? kupelaId = kupelas.first.id;
  var fechaMs = DateTime.now().millisecondsSinceEpoch;
  final litros = TextEditingController();
  final comensales = TextEditingController();
  final notas = TextEditingController();
  final guardado = await mostrarHojaFormulario(
    controladores: [litros, comensales, notas],
    context,
    titulo: SoleraL10n.t('sidr.abrir_kupela'),
    construir: (refrescar) => [
      SelectorFecha(
        etiqueta: SoleraL10n.t('sidr.fecha'),
        fechaMs: fechaMs,
        alCambiar: (fecha) => refrescar(() => fechaMs = fecha ?? fechaMs),
      ),
      campoDesplegable<int?>(
        etiqueta: SoleraL10n.t('sidr.kupela'),
        valor: kupelaId,
        opciones: [
          for (final kupela in kupelas)
            (
              kupela.id,
              '${kupela.etiqueta} (${formatearLitros(estado.saldo.litrosEn(kupela.id!))})'
            ),
        ],
        alCambiar: (valor) => refrescar(() => kupelaId = valor),
      ),
      campoNumero(litros, SoleraL10n.t('sidr.litros_servidos'), sufijo: 'l'),
      campoNumero(comensales, SoleraL10n.t('sidr.comensales'),
          decimales: false),
      campoTexto(notas, SoleraL10n.t('sidr.notas')),
    ],
    guardar: () async {
      final cantidad = leerNumero(litros.text);
      if (kupelaId == null || cantidad == null || cantidad < 0) return false;
      await BaseDatosSoleraSidra.instancia.guardarSesionTxotx(SesionTxotx(
        fechaMs: fechaMs,
        kupelaId: kupelaId!,
        litrosServidos: cantidad,
        comensales: leerEntero(comensales.text),
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
}
