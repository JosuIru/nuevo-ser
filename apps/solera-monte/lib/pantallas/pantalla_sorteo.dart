import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TituloBloqueSolera, rellenoInferiorSeguro;

import '../datos/base_datos.dart';
import '../dominio/sorteo_lena.dart';
import '../estado/cambios_datos.dart';
import '../modelos/sorteo_lena.dart';
import '../utiles/textos_monte.dart';
import 'formularios.dart';
import 'hoja_formulario.dart';
import 'pantalla_documentos.dart';

/// Un sorteo de lotes de leña, en tres pasos a la vista de todos: cerrar la
/// lista (con su huella), fijar la semilla pública y sortear. Después queda
/// bloqueado y la app lo vuelve a comprobar cada vez que se abre.
class PantallaSorteo extends StatefulWidget {
  const PantallaSorteo({super.key, required this.sorteoId});

  final int sorteoId;

  @override
  State<PantallaSorteo> createState() => _PantallaSorteoState();
}

class _PantallaSorteoState extends State<PantallaSorteo> {
  final _lista = TextEditingController();
  final _semilla = TextEditingController();
  final _origenSemilla = TextEditingController();
  SorteoLena? _sorteo;
  List<LoteLena> _lotes = const [];
  bool _cargando = true;

  BaseDatosSoleraMonte get _bd => BaseDatosSoleraMonte.instancia;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _lista.dispose();
    _semilla.dispose();
    _origenSemilla.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final sorteo = await _bd.obtenerSorteo(widget.sorteoId);
    final lotes = await _bd.listarLotes(sorteoId: widget.sorteoId);
    if (!mounted) return;
    setState(() {
      _sorteo = sorteo;
      _lotes = lotes;
      _cargando = false;
      if (sorteo != null) {
        _lista.text = sorteo.participantes.join('\n');
        _semilla.text = sorteo.semilla;
        _origenSemilla.text = sorteo.origenSemilla;
      }
    });
  }

  Future<void> _guardar(SorteoLena sorteo) async {
    await _bd.guardarSorteo(sorteo);
    avisarCambioDatos();
    await _cargar();
  }

  Future<void> _guardarLista() async {
    await _guardar(
        _sorteo!.copiarCon(participantes: leerListaParticipantes(_lista.text)));
    if (mounted) avisarConMensaje(context, 'mont.guardado');
  }

  Future<void> _cerrarLista() async {
    final participantes = leerListaParticipantes(_lista.text);
    if (participantes.isEmpty) {
      avisarConMensaje(context, 'mont.lista_vacia');
      return;
    }
    if (participantes.map((p) => p.toLowerCase()).toSet().length !=
        participantes.length) {
      avisarConMensaje(context, 'mont.lista_con_repetidos');
      return;
    }
    if (!await confirmar(context, 'mont.cerrar_lista_pregunta',
        detalle: SoleraL10n.t('mont.cerrar_lista_detalle'))) {
      return;
    }
    await _guardar(_sorteo!.copiarCon(
      participantes: participantes,
      fechaCierreListaMs: DateTime.now().millisecondsSinceEpoch,
      huellaParticipantes: huellaLista(participantes),
    ));
  }

  Future<void> _sortear() async {
    final sorteo = _sorteo!;
    final semilla = _semilla.text.trim();
    if (semilla.isEmpty) {
      avisarConMensaje(context, 'mont.falta_semilla');
      return;
    }
    if (_lotes.isEmpty) {
      avisarConMensaje(context, 'mont.faltan_lotes');
      return;
    }
    if (!await confirmar(context, 'mont.sortear_pregunta',
        detalle: SoleraL10n.t('mont.sortear_detalle'))) {
      return;
    }
    final ResultadoSorteo resultado;
    try {
      resultado = sortear(
          semilla: semilla,
          participantes: sorteo.participantes,
          numerosLote: [for (final lote in _lotes) lote.numero]);
    } on SorteoNoValido {
      if (mounted) avisarConMensaje(context, 'mont.sorteo_no_valido');
      return;
    }
    final adjudicacion = resultado.adjudicacionPorLote;
    await _bd.guardarResultadoSorteo(
      sorteo.copiarCon(
        semilla: semilla,
        origenSemilla: _origenSemilla.text.trim(),
        fechaSorteoMs: DateTime.now().millisecondsSinceEpoch,
        huellaParticipantes: resultado.huella,
        realizado: true,
      ),
      [
        for (final lote in _lotes)
          lote.conAdjudicatario(adjudicacion[lote.numero] ?? '')
      ],
    );
    avisarCambioDatos();
    await _cargar();
  }

  Future<void> _borrar() async {
    if (!await confirmar(context, 'mont.borrar_sorteo')) return;
    await _bd.borrarSorteo(widget.sorteoId);
    avisarCambioDatos();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final sorteo = _sorteo;
    if (_cargando || sorteo == null) {
      return Scaffold(
          appBar: AppBar(),
          body: Center(
              child: _cargando
                  ? const CircularProgressIndicator()
                  : Text(SoleraL10n.t('mont.error_cargar'))));
    }
    final cerrada = sorteo.fechaCierreListaMs != null;
    final estilo = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(sorteo.nombre.isEmpty
            ? SoleraL10n.tf('mont.sorteo_de', {'anyo': '${sorteo.campanya}'})
            : sorteo.nombre),
        actions: [
          if (sorteo.realizado)
            IconButton(
              tooltip: SoleraL10n.t('mont.acta_sorteo'),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: () => compartirActaSorteo(context, sorteo),
            ),
          if (!sorteo.realizado)
            IconButton(
              tooltip: SoleraL10n.t('borrar'),
              icon: const Icon(Icons.delete_outline),
              onPressed: _borrar,
            ),
        ],
      ),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.fromLTRB(16, 8, 16, 32)),
        children: [
          Text(SoleraL10n.t('mont.sorteo_explicacion'),
              style: estilo.bodySmall),
          TituloBloqueSolera(SoleraL10n.t('mont.paso_lista')),
          if (!cerrada) ...[
            campoTexto(_lista, SoleraL10n.t('mont.participantes'),
                ayuda: SoleraL10n.t('mont.participantes_ayuda'), lineas: 5),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              OutlinedButton(
                  onPressed: _guardarLista,
                  child: Text(SoleraL10n.t('mont.guardar_lista'))),
              FilledButton.icon(
                  onPressed: _cerrarLista,
                  icon: const Icon(Icons.lock_outline),
                  label: Text(SoleraL10n.t('mont.cerrar_lista'))),
            ]),
          ] else ...[
            for (final (indice, participante) in sorteo.participantes.indexed)
              Text('${indice + 1}. $participante'),
            const SizedBox(height: 8),
            SelectableText(
                '${SoleraL10n.t('mont.huella_lista')}: ${sorteo.huellaParticipantes}',
                style: estilo.bodySmall),
            Text(
                SoleraL10n.tf('mont.lista_cerrada_el',
                    {'fecha': formatearFecha(sorteo.fechaCierreListaMs!)}),
                style: estilo.bodySmall),
          ],
          TituloBloqueSolera(
              SoleraL10n.tf('mont.lotes_n', {'n': '${_lotes.length}'})),
          for (final lote in _lotes)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text('${lote.numero}')),
              title: Text(lote.adjudicado
                  ? lote.adjudicatario
                  : (lote.descripcion.isEmpty
                      ? SoleraL10n.t('mont.sin_adjudicar')
                      : lote.descripcion)),
              subtitle: Text([
                if (lote.cantidad != null)
                  '${formatearNumero(lote.cantidad!)} ${nombreUnidad(lote.unidad)}',
                if (lote.adjudicado && lote.descripcion.isNotEmpty)
                  lote.descripcion,
              ].join(' · ')),
              onTap: sorteo.realizado
                  ? null
                  : () => mostrarEdicionLote(context,
                          sorteoId: sorteo.id!, lote: lote)
                      .then((_) => _cargar()),
            ),
          if (!sorteo.realizado)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => mostrarEdicionLote(context,
                        sorteoId: sorteo.id!,
                        numeroPropuesto: _lotes.isEmpty
                            ? 1
                            : _lotes
                                    .map((l) => l.numero)
                                    .reduce((a, b) => a > b ? a : b) +
                                1)
                    .then((_) => _cargar()),
                icon: const Icon(Icons.add),
                label: Text(SoleraL10n.t('mont.nuevo_lote')),
              ),
            ),
          if (cerrada) ...[
            TituloBloqueSolera(SoleraL10n.t('mont.paso_semilla')),
            if (!sorteo.realizado) ...[
              Text(SoleraL10n.t('mont.semilla_ayuda'), style: estilo.bodySmall),
              campoTexto(_semilla, SoleraL10n.t('mont.semilla')),
              campoTexto(_origenSemilla, SoleraL10n.t('mont.origen_semilla'),
                  ayuda: SoleraL10n.t('mont.origen_semilla_ayuda')),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _sortear,
                icon: const Icon(Icons.casino_outlined),
                label: Text(SoleraL10n.t('mont.sortear')),
              ),
            ] else ...[
              SelectableText(
                  '${SoleraL10n.t('mont.semilla')}: ${sorteo.semilla}'),
              if (sorteo.origenSemilla.isNotEmpty)
                Text(sorteo.origenSemilla, style: estilo.bodySmall),
            ],
          ],
          if (sorteo.realizado) ..._resultado(context, sorteo),
        ],
      ),
    );
  }

  List<Widget> _resultado(BuildContext context, SorteoLena sorteo) {
    final numeros = [for (final lote in _lotes) lote.numero];
    ResultadoSorteo? repetido;
    try {
      repetido = sortear(
          semilla: sorteo.semilla,
          participantes: sorteo.participantes,
          numerosLote: numeros);
    } on SorteoNoValido {
      repetido = null;
    }
    final coincide = repetido != null &&
        verificarSorteo(
            semilla: sorteo.semilla,
            participantes: sorteo.participantes,
            numerosLote: numeros,
            adjudicacionPublicada: {
              for (final lote in _lotes)
                if (lote.adjudicado) lote.numero: lote.adjudicatario
            }) &&
        huellaLista(sorteo.participantes) == sorteo.huellaParticipantes;
    final estilo = Theme.of(context).textTheme;
    return [
      TituloBloqueSolera(SoleraL10n.t('mont.resultado')),
      Card(
        color: coincide
            ? Theme.of(context).colorScheme.secondaryContainer
            : Theme.of(context).colorScheme.errorContainer,
        child: ListTile(
          leading: Icon(coincide ? Icons.verified : Icons.error_outline),
          title: Text(SoleraL10n.t(
              coincide ? 'mont.sorteo_verificado' : 'mont.sorteo_no_coincide')),
          subtitle: sorteo.fechaSorteoMs == null
              ? null
              : Text(formatearFecha(sorteo.fechaSorteoMs!)),
        ),
      ),
      if (repetido != null)
        for (final puesto in repetido.orden)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Text('${puesto.posicion}.'),
            title: Text(puesto.participante),
            subtitle: Text(huellaCorta(puesto.clave)),
            trailing: Text(puesto.numeroLote == null
                ? SoleraL10n.t('mont.lista_espera')
                : SoleraL10n.tf('mont.lote_n', {'n': '${puesto.numeroLote}'})),
          ),
      const SizedBox(height: 8),
      Text(SoleraL10n.t('mont.como_verificar'), style: estilo.bodySmall),
    ];
  }
}
