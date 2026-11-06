import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../branding.dart';
import '../estado/coordinador.dart';
import '../l10n/app_localizations.dart';
import '../servicios/documento_generado.dart';
import '../utiles/periodo.dart';
import 'widgets/barra_inferior_formulario.dart';

/// Vista previa del informe del proyecto antes de compartirlo o mandarlo a
/// coordinación, con el periodo elegible arriba y el aviso de borrador.
class PantallaInformeProyecto extends StatefulWidget {
  const PantallaInformeProyecto({
    super.key,
    required this.generar,
    required this.periodoInicial,
    required this.definitivo,
    required this.alEnviar,
  });

  /// Genera el informe del periodo (la ficha cambia también a ese periodo).
  final Future<DocumentoGenerado> Function(TipoPeriodo periodo) generar;
  final TipoPeriodo periodoInicial;

  /// Sin marca de BORRADOR: solo coordinación con el proyecto cerrado.
  final bool definitivo;

  /// Manda el documento al correo de coordinación.
  final Future<void> Function(DocumentoGenerado documento) alEnviar;

  @override
  State<PantallaInformeProyecto> createState() =>
      _PantallaInformeProyectoState();
}

class _PantallaInformeProyectoState extends State<PantallaInformeProyecto> {
  late TipoPeriodo _periodo = widget.periodoInicial;
  late Future<DocumentoGenerado> _documento = widget.generar(_periodo);
  String _correo = '';
  bool _ocupado = false;

  @override
  void initState() {
    super.initState();
    Coordinador.cargarCorreo().then((correo) {
      if (mounted) setState(() => _correo = correo);
    });
  }

  void _cambiarPeriodo(TipoPeriodo periodo) {
    if (periodo == _periodo) return;
    setState(() {
      _periodo = periodo;
      _documento = widget.generar(periodo);
    });
  }

  Future<void> _conDocumento(
      Future<void> Function(DocumentoGenerado documento) accion) async {
    final textos = AppLocalizations.of(context);
    setState(() => _ocupado = true);
    try {
      await accion(await _documento);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(textos.infNoSalio)));
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final esquema = context.esquemaZunbeltz;
    final colores = context.coloresZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final periodos = {
      TipoPeriodo.todo: textos.proyPeriodoTodo,
      TipoPeriodo.anio: textos.periodoAnio,
      TipoPeriodo.trimestre: textos.periodoTrimestre,
      TipoPeriodo.trimestreAnterior: textos.periodoTrimestreAnterior,
    };
    return Scaffold(
      backgroundColor: esquema.surfaceContainer,
      appBar: AppBar(
        backgroundColor: esquema.surfaceContainer,
        title: Text(textos.infTitulo),
      ),
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          decoration: BoxDecoration(
            color: esquema.surfaceContainerLow,
            border: Border(top: BorderSide(color: esquema.outlineVariant)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Row(children: [
            Icon(Icons.mail_outline, color: esquema.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(textos.infSeEnviaA,
                      style: estilos.bodyMedium
                          ?.copyWith(color: esquema.onSurfaceVariant)),
                  Text(
                      _correo.isEmpty
                          ? textos.enviarCoordinadorSinDestino
                          : _correo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: estilos.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ]),
        ),
        BarraInferiorFormulario(conRaya: false, botones: [
          OutlinedButton.icon(
            onPressed: _ocupado
                ? null
                : () => _conDocumento((documento) => Printing.sharePdf(
                    bytes: documento.bytes, filename: documento.nombreFichero)),
            icon: const Icon(Icons.share_outlined),
            label: Text(textos.infCompartir,
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          FilledButton.icon(
            onPressed: _ocupado || _correo.isEmpty
                ? null
                : () => _conDocumento(widget.alEnviar),
            icon: const Icon(Icons.send_outlined),
            label: FittedBox(
                fit: BoxFit.scaleDown, child: Text(textos.enviarCoordinador)),
          ),
        ]),
      ]),
      body: Column(children: [
        if (!widget.definitivo)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colores.fondoPendiente,
              borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
            ),
            child: Row(children: [
              Icon(Icons.description_outlined, color: colores.pendiente),
              const SizedBox(width: 14),
              Expanded(
                child: Text(textos.infBorrador, style: estilos.bodyLarge),
              ),
            ]),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            for (final MapEntry(key: periodo, value: etiqueta)
                in periodos.entries)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(etiqueta),
                  selected: _periodo == periodo,
                  onSelected: (_) => _cambiarPeriodo(periodo),
                ),
              ),
          ]),
        ),
        Expanded(
          child: PdfPreview(
            key: ValueKey(_periodo),
            build: (_) async => (await _documento).bytes,
            useActions: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            maxPageWidth: 640,
            scrollViewDecoration:
                BoxDecoration(color: esquema.surfaceContainer),
            pdfPreviewPageDecoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Color(0x33002117),
                    blurRadius: 12,
                    offset: Offset(0, 4)),
              ],
            ),
            loadingWidget: const Center(child: CircularProgressIndicator()),
            onError: (contexto, _) => Center(child: Text(textos.infNoSalio)),
          ),
        ),
      ]),
    );
  }
}
