import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import '../datos/base_datos.dart';
import '../modelos/analitica.dart';
import '../modelos/incidencia.dart';
import '../modelos/lote_produccion.dart';
import '../modelos/pieza.dart';
import '../servicios/validador_do.dart';
import '../utiles/textos_quesera.dart';

class PantallaFichaLote extends StatefulWidget {
  final int loteId;
  const PantallaFichaLote({super.key, required this.loteId});
  @override
  State<PantallaFichaLote> createState() => _PantallaFichaLoteState();
}

class _PantallaFichaLoteState extends State<PantallaFichaLote> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  late Future<_Datos> _datos;
  DateFormat get _f => DateFormat('d MMM yyyy HH:mm', localeFechasQuesera());

  @override
  void initState() { super.initState(); _datos = _cargar(); }

  Future<_Datos> _cargar() async {
    final l = await _bd.obtenerLote(widget.loteId);
    final p = await _bd.listarPiezas(loteId: widget.loteId);
    final inc = (await _bd.listarIncidencias()).where((i) => i.loteProduccionId == widget.loteId).toList();
    final an = await _bd.listarAnaliticas(loteId: widget.loteId);
    return _Datos(lote: l, piezas: p, incidencias: inc, analiticas: an);
  }

  List<Widget> _validarDo(LoteProduccion l) {
    final r = ValidadorDo().validar(l); if (r == null) return [];
    return r.checks.map((c) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(c.correcto ? Icons.check_circle_outline : Icons.warning_amber, size: 16, color: c.correcto ? Colors.green : Colors.orange),
      const SizedBox(width: 6), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c.etiqueta, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: c.correcto ? Colors.green : Colors.orange)),
        Text(c.detalle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ])),
    ]))).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ques.ficha_de_lote')), actions: [
        PopupMenuButton<String>(onSelected: (a) async {
          if (a == 'listo') { await _bd.actualizarLote(widget.loteId, {'estado': 'lista'}); setState(() => _datos = _cargar()); }
          if (a == 'baja') { await _bd.actualizarLote(widget.loteId, {'estado': 'baja'}); setState(() => _datos = _cargar()); }
        }, itemBuilder: (_) => [
          PopupMenuItem(value: 'listo', child: Text(SoleraL10n.t('ques.marcar_como_listo'))),
          PopupMenuItem(value: 'baja', child: Text(SoleraL10n.t('ques.dar_de_baja'))),
        ]),
      ]),
      body: FutureBuilder<_Datos>(future: _datos, builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final d = snap.data; if (d == null || d.lote == null) return Center(child: Text(SoleraL10n.t('ques.lote_no_encontrado')));
        final l = d.lote!; final f = DateTime.fromMillisecondsSinceEpoch(l.fechaMs);
        return RefreshIndicator(onRefresh: () async { setState(() => _datos = _cargar()); }, child: ListView(padding: const EdgeInsets.all(16), children: [
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [_IconoEstadoLote(l.estado), const SizedBox(width: 12), Expanded(child: Text(l.numeroLote, style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)))]),
            const Divider(),
            _Campo(SoleraL10n.t('ques.fecha'), _f.format(f)), _Campo(SoleraL10n.t('ques.tipo_de_queso'), l.tipoQuesoId), _Campo('DO', l.doId ?? SoleraL10n.t('ques.sin_do')),
            if (l.doId != null) ..._validarDo(l),
          ]))),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(SoleraL10n.t('ques.parametros_de_produccion'), style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), const Divider(),
            _Campo(SoleraL10n.t('ques.volumen_de_leche'), '${l.volumenLecheTotal} L'), _Campo(SoleraL10n.t('ques.peso_obtenido'), '${l.pesoTotalObtenido} kg'),
            _Campo(SoleraL10n.t('ques.rendimiento'), '${formatearNumero(l.rendimientoReal, decimales: 2)} L/kg'), _Campo(SoleraL10n.t('ques.numero_de_piezas'), '${l.numPiezasProducidas}'),
            _Campo(SoleraL10n.t('ques.temp_coagulacion'), '${l.tempCoagulacion} °C'), _Campo(SoleraL10n.t('ques.tiempo_coag'), '${l.tiempoCoagMinutos} min'),
          ]))),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(SoleraL10n.t('ques.ingredientes_y_trazabilidad'), style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), const Divider(),
            _Campo(SoleraL10n.t('ques.fermento'), l.fermentoNombre), _Campo(SoleraL10n.t('ques.lote_del_fermento'), l.fermentoLoteComercial), _Campo(SoleraL10n.t('ques.cuajo'), textoTipoCuajo(l.cuajoTipo)), _Campo(SoleraL10n.t('ques.lote_del_cuajo'), l.cuajoLoteComercial),
          ]))),
          const SizedBox(height: 12),
          Text(SoleraL10n.tf('ques.piezas_entre_parentesis_n', {'n': d.piezas.length}), style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ...d.piezas.map((p) => Card(child: ListTile(dense: true, title: Text(p.numeroPieza), subtitle: Text('${formatearNumero(p.pesoActual ?? p.pesoInicial, decimales: 2)} kg · ${p.ubicacionActual}'), trailing: _IconoPieza(p.estado)))),
          if (d.analiticas.isNotEmpty) ...[const SizedBox(height: 12), Text(SoleraL10n.t('ques.analiticas'), style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), ...d.analiticas.map((a) => Card(child: ListTile(dense: true, leading: Icon(a.conforme ? Icons.check_circle : Icons.warning, color: a.conforme ? Colors.green : Colors.red), title: Text(textoTipoAnalitica(a.tipo)))))],
          if (d.incidencias.isNotEmpty) ...[const SizedBox(height: 12), Text(SoleraL10n.t('ques.incidencias'), style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), ...d.incidencias.map((i) => Card(child: ListTile(dense: true, leading: Icon(i.cerrada ? Icons.check_circle_outline : Icons.error_outline, color: i.cerrada ? Colors.green : Colors.red), title: Text(textoTipoIncidencia(i.tipo)), subtitle: Text(i.descripcion))))],
        ]));
      }),
    );
  }
}

Widget _Campo(String e, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 130, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey))), Expanded(child: Text(v))]));
Widget _IconoEstadoLote(String e) => CircleAvatar(child: Icon(e == 'fresca' ? Icons.water_drop : e == 'lista' ? Icons.check : Icons.schedule, color: Colors.white, size: 20), backgroundColor: e == 'fresca' ? Colors.blue : e == 'lista' ? Colors.green : Colors.orange);
Widget _IconoPieza(String e) => Chip(label: Text(textoEstadoPieza(e)), avatar: Icon(e == 'afinando' ? Icons.schedule : Icons.check, size: 16));

class _Datos {
  final LoteProduccion? lote; final List<Pieza> piezas; final List<Incidencia> incidencias; final List<Analitica> analiticas;
  _Datos({required this.lote, required this.piezas, required this.incidencias, required this.analiticas});
}
