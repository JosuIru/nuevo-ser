import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, rellenoInferiorSeguro;

import '../datos/base_datos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/masa_madre.dart';
import '../servicios/avisos_obrador.dart';
import '../utiles/textos_obrador.dart';
import 'hoja_formulario.dart';

/// Masas madre y sus refrescos.
class PantallaMasaMadre extends StatefulWidget {
  const PantallaMasaMadre({super.key});

  @override
  State<PantallaMasaMadre> createState() => _PantallaMasaMadreState();
}

class _PantallaMasaMadreState extends State<PantallaMasaMadre> {
  late Future<List<(MasaMadre, List<RefrescoMasaMadre>)>> _masas = _cargar();

  Future<List<(MasaMadre, List<RefrescoMasaMadre>)>> _cargar() async {
    final baseDatos = BaseDatosSoleraObrador.instancia;
    return [
      for (final masa in await baseDatos.listarMasasMadre())
        (masa, await baseDatos.listarRefrescos(masa.id!)),
    ];
  }

  void _recargar() {
    avisarCambioDatos();
    setState(() {
      _masas = _cargar();
    });
  }

  Future<void> _nuevaMasa() async {
    final nombre = TextEditingController();
    final harina = TextEditingController();
    final guardado = await mostrarHojaFormulario(
      context,
      controladores: [nombre, harina],
      titulo: SoleraL10n.t('obra.nueva_masa_madre'),
      construir: (_) => [
        campoTexto(nombre, SoleraL10n.t('obra.nombre')),
        campoTexto(harina, SoleraL10n.t('obra.harina_base')),
      ],
      guardar: () async {
        if (nombre.text.trim().isEmpty) return false;
        await BaseDatosSoleraObrador.instancia.guardarMasaMadre(MasaMadre(
            nombre: nombre.text.trim(),
            harinaBase: harina.text.trim(),
            creadaMs: DateTime.now().millisecondsSinceEpoch));
        return true;
      },
    );
    if (guardado) _recargar();
  }

  Future<void> _nuevoRefresco(
      MasaMadre masa, RefrescoMasaMadre? anterior) async {
    String previo(double? valor) =>
        valor == null ? '' : formatearNumero(valor, decimales: 0);
    final controladores = {
      'masa': TextEditingController(text: previo(anterior?.gramosMasaMadre)),
      'harina': TextEditingController(text: previo(anterior?.gramosHarina)),
      'agua': TextEditingController(text: previo(anterior?.gramosAgua)),
      'temperatura': TextEditingController(),
      'pico': TextEditingController(),
    };
    final guardado = await mostrarHojaFormulario(
      context,
      controladores: controladores.values.toList(),
      titulo: '${SoleraL10n.t('obra.nuevo_refresco')} · ${masa.nombre}',
      construir: (_) => [
        campoNumero(
            controladores['masa']!, SoleraL10n.t('obra.gramos_masa_madre')),
        campoNumero(
            controladores['harina']!, SoleraL10n.t('obra.gramos_harina')),
        campoNumero(controladores['agua']!, SoleraL10n.t('obra.gramos_agua')),
        campoNumero(
            controladores['temperatura']!, SoleraL10n.t('obra.temperatura_c')),
        campoNumero(
            controladores['pico']!, SoleraL10n.t('obra.horas_hasta_pico')),
      ],
      guardar: () async {
        final masaMadre = leerNumero(controladores['masa']!.text);
        final harina = leerNumero(controladores['harina']!.text);
        final agua = leerNumero(controladores['agua']!.text);
        if (masaMadre == null || harina == null || agua == null) return false;
        final fechaMs = DateTime.now().millisecondsSinceEpoch;
        await BaseDatosSoleraObrador.instancia
            .guardarRefresco(RefrescoMasaMadre(
          masaMadreId: masa.id!,
          fechaMs: fechaMs,
          gramosMasaMadre: masaMadre,
          gramosHarina: harina,
          gramosAgua: agua,
          temperaturaC: leerNumero(controladores['temperatura']!.text),
          horasHastaPico: leerNumero(controladores['pico']!.text),
        ));
        // El recordatorio cuenta desde este refresco.
        await programarRecordatorioRefresco(
            masa, DateTime.fromMillisecondsSinceEpoch(fechaMs));
        return true;
      },
    );
    if (guardado) _recargar();
  }

  /// Opciones del recordatorio de refresco, en horas (null: sin aviso).
  static const _opcionesRecordatorio = <int?>[null, 12, 24, 48, 72, 168];

  String _textoRecordatorio(int? horas) => switch (horas) {
        null => SoleraL10n.t('obra.plan_recordatorio_no'),
        168 => SoleraL10n.t('obra.plan_recordatorio_semana'),
        final int horas when horas % 24 == 0 && horas > 24 =>
          SoleraL10n.tf('obra.plan_recordatorio_dias', {'n': horas ~/ 24}),
        final int horas =>
          SoleraL10n.tf('obra.plan_recordatorio_horas', {'n': horas}),
      };

  Future<void> _elegirRecordatorio(
      MasaMadre masa, RefrescoMasaMadre? ultimo) async {
    final elegido = await showDialog<(int?,)>(
      context: context,
      builder: (contexto) => SimpleDialog(
        title: Text(SoleraL10n.t('obra.plan_recordatorio_titulo')),
        children: [
          for (final horas in _opcionesRecordatorio)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(contexto, (horas,)),
              child: Text(_textoRecordatorio(horas)),
            ),
        ],
      ),
    );
    if (elegido == null || !mounted) return;
    final mensajero = ScaffoldMessenger.of(context);
    final actualizada = masa.conRecordatorio(elegido.$1);
    await BaseDatosSoleraObrador.instancia.guardarMasaMadre(actualizada);
    DateTime? programado;
    if (actualizada.recordatorioHoras != null &&
        await avisosObrador.pedirPermiso()) {
      programado = await programarRecordatorioRefresco(
          actualizada,
          ultimo == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(ultimo.fechaMs));
    } else {
      await programarRecordatorioRefresco(actualizada.conRecordatorio(null), null);
    }
    if (actualizada.recordatorioHoras != null) {
      mensajero.showSnackBar(SnackBar(
          content: Text(programado == null
              ? SoleraL10n.t('avisos.sin_permiso')
              : SoleraL10n.tf('obra.plan_recordatorio_programado',
                  {'hora': DateFormat.MMMEd(SoleraL10n.idioma).add_Hm().format(programado)}))));
    }
    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    final formato = DateFormat.MMMd(SoleraL10n.idioma).add_Hm();
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('obra.masa_madre'))),
      floatingActionButton: FloatingActionButton(
        tooltip: SoleraL10n.t('obra.nueva_masa_madre'),
        onPressed: _nuevaMasa,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<(MasaMadre, List<RefrescoMasaMadre>)>>(
        future: _masas,
        builder: (context, instantanea) {
          final masas = instantanea.data;
          if (masas == null)
            return const Center(child: CircularProgressIndicator());
          if (masas.isEmpty)
            return Center(child: Text(SoleraL10n.t('obra.sin_masas_madre')));
          return ListView(
            padding: rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 88)),
            children: [
              for (final (masa, refrescos) in masas)
                Card(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(masa.nombre),
                        subtitle: Text([
                          if (masa.harinaBase.isNotEmpty) masa.harinaBase,
                          if (masa.recordatorioHoras != null)
                            '${SoleraL10n.t('obra.plan_recordatorio_titulo')}: '
                                '${_textoRecordatorio(masa.recordatorioHoras)}',
                        ].join(' · ')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip:
                                  SoleraL10n.t('obra.plan_recordatorio_titulo'),
                              icon: Icon(masa.recordatorioHoras == null
                                  ? Icons.alarm_add_outlined
                                  : Icons.alarm_on_outlined),
                              onPressed: () => _elegirRecordatorio(masa,
                                  refrescos.isEmpty ? null : refrescos.first),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: () => _nuevoRefresco(masa,
                                  refrescos.isEmpty ? null : refrescos.first),
                              icon: const Icon(Icons.water_drop_outlined),
                              label: Text(SoleraL10n.t('obra.refrescar')),
                            ),
                          ],
                        ),
                      ),
                      for (final refresco in refrescos.take(7))
                        ListTile(
                          dense: true,
                          title: Text('${refresco.proporcion} · '
                              '${formatearNumero(refresco.hidratacionPorcentaje, decimales: 0)} %'),
                          subtitle: Text([
                            formato.format(DateTime.fromMillisecondsSinceEpoch(
                                refresco.fechaMs)),
                            if (refresco.temperaturaC != null)
                              '${formatearNumero(refresco.temperaturaC!)} °C',
                            if (refresco.horasHastaPico != null)
                              '${formatearNumero(refresco.horasHastaPico!)} h',
                          ].join(' · ')),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
