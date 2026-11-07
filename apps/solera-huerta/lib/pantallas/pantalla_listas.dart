// Listas de lo que la huerta usa: cultivos, banco de semillas e insumos.

import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../estado/cambios_datos.dart';
import '../utiles/textos_huerta.dart';
import 'formularios_huerta.dart';
import 'hoja_formulario.dart';

/// Lista que se recarga sola cuando cambian los datos.
class _ListaRecargable<T> extends StatefulWidget {
  const _ListaRecargable({
    required this.titulo,
    required this.cargar,
    required this.fila,
    required this.alAnadir,
    required this.vacio,
    this.borrar,
    this.cabecera,
  });

  final String titulo;
  final Future<List<T>> Function() cargar;
  final Widget Function(BuildContext, T) fila;
  final Future<void> Function(BuildContext) alAnadir;
  final String vacio;
  final Future<void> Function(T)? borrar;
  final Widget? cabecera;

  @override
  State<_ListaRecargable<T>> createState() => _ListaRecargableState<T>();
}

class _ListaRecargableState<T> extends State<_ListaRecargable<T>> {
  late Future<List<T>> _elementos;

  @override
  void initState() {
    super.initState();
    _elementos = widget.cargar();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _elementos = widget.cargar();
    });
  }

  Future<void> _borrar(T elemento) async {
    if (!await confirmarBorrado(
        context, SoleraL10n.t('huer.borrar_registro'))) {
      return;
    }
    try {
      await widget.borrar!(elemento);
      avisarCambioDatos();
    } catch (_) {
      if (mounted) avisar(context, SoleraL10n.t('huer.en_uso_no_se_borra'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      floatingActionButton: FloatingActionButton(
        tooltip: SoleraL10n.t('huer.anadir'),
        onPressed: () => widget.alAnadir(context),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<T>>(
        future: _elementos,
        builder: (context, instantanea) {
          final elementos = instantanea.data ?? <T>[];
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              if (widget.cabecera != null) widget.cabecera!,
              if (instantanea.connectionState == ConnectionState.done &&
                  elementos.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(widget.vacio, textAlign: TextAlign.center),
                ),
              for (final elemento in elementos)
                GestureDetector(
                  onLongPress:
                      widget.borrar == null ? null : () => _borrar(elemento),
                  child: widget.fila(context, elemento),
                ),
            ],
          );
        },
      ),
    );
  }
}

class PantallaCultivos extends StatelessWidget {
  const PantallaCultivos({super.key});

  @override
  Widget build(BuildContext context) => _ListaRecargable(
        titulo: SoleraL10n.t('huer.cultivos'),
        cargar: BaseDatosSoleraHuerta.instancia.listarCultivos,
        vacio: SoleraL10n.t('huer.sin_cultivos'),
        alAnadir: (contexto) => mostrarFormularioCultivo(contexto),
        borrar: (cultivo) =>
            BaseDatosSoleraHuerta.instancia.borrarCultivo(cultivo.id!),
        fila: (contexto, cultivo) => ListTile(
          leading: Icon(cultivo.variedadLocal
              ? Icons.local_florist_outlined
              : Icons.eco_outlined),
          title: Text(nombreCultivo(cultivo)),
          subtitle: Text(cultivo.familiaId.isEmpty
              ? SoleraL10n.t('huer.familia_sin_indicar')
              : nombreFamilia(cultivo.familiaId)),
          onTap: () => mostrarFormularioCultivo(contexto, cultivo: cultivo),
        ),
      );
}

class PantallaSemillas extends StatelessWidget {
  const PantallaSemillas({super.key});

  @override
  Widget build(BuildContext context) => _ListaRecargable(
        titulo: SoleraL10n.t('huer.banco_semillas'),
        cargar: BaseDatosSoleraHuerta.instancia.listarLotesSemilla,
        vacio: SoleraL10n.t('huer.sin_lotes'),
        alAnadir: (contexto) => mostrarFormularioLoteSemilla(contexto),
        borrar: (lote) =>
            BaseDatosSoleraHuerta.instancia.borrarLoteSemilla(lote.id!),
        fila: (contexto, lote) => ListTile(
          leading: Icon(lote.faltaAutorizacion
              ? Icons.warning_amber_outlined
              : Icons.grain_outlined),
          title: Text('${lote.codigo} · ${nombreEspecie(lote.especieId)}'
              '${lote.variedad.isEmpty ? '' : ' ${lote.variedad}'}'),
          subtitle: Text([
            nombreOrigenSemilla(lote.origen),
            if (lote.anyoObtencion != null) '${lote.anyoObtencion}',
            if (lote.faltaAutorizacion) SoleraL10n.t('huer.falta_autorizacion'),
          ].join(' · ')),
          onTap: () => mostrarFormularioLoteSemilla(contexto, lote: lote),
        ),
      );
}

class PantallaInsumos extends StatelessWidget {
  const PantallaInsumos({super.key});

  @override
  Widget build(BuildContext context) => _ListaRecargable(
        titulo: SoleraL10n.t('huer.insumos'),
        cargar: BaseDatosSoleraHuerta.instancia.listarInsumos,
        vacio: SoleraL10n.t('huer.sin_insumos'),
        alAnadir: (contexto) => mostrarFormularioInsumo(contexto),
        borrar: (insumo) =>
            BaseDatosSoleraHuerta.instancia.borrarInsumo(insumo.id!),
        cabecera: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(SoleraL10n.t('huer.insumos_aviso')),
        ),
        fila: (contexto, insumo) => ListTile(
          leading: Icon(insumo.permitidoEcologico
              ? (insumo.faltaJustificante
                  ? Icons.warning_amber_outlined
                  : Icons.verified_outlined)
              : Icons.help_outline),
          title: Text(insumo.nombre),
          subtitle: Text([
            nombreTipoInsumo(insumo.tipo),
            if (insumo.categoriaEcologicaId.isNotEmpty)
              nombreCategoriaInsumo(insumo.categoriaEcologicaId),
            SoleraL10n.t(insumo.permitidoEcologico
                ? (insumo.faltaJustificante
                    ? 'huer.falta_justificante'
                    : 'huer.marcado_permitido')
                : 'huer.no_marcado_permitido'),
          ].join(' · ')),
          onTap: () => mostrarFormularioInsumo(contexto, insumo: insumo),
        ),
      );
}
