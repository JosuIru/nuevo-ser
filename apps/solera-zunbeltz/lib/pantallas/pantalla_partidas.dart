import 'package:flutter/material.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/proyecto_test.dart';
import '../utiles/comparativa_partidas.dart';
import 'pantalla_convenio.dart';
import 'widgets/proyecto_visual.dart';
import 'widgets/relleno_seguro.dart';

/// Partidas del presupuesto (anexo II) de un proyecto: lo previsto frente a
/// lo imputado por bloque y por partida. Las partidas se añaden y se
/// quitan en el Convenio (coordinación).
class PantallaPartidas extends StatefulWidget {
  const PantallaPartidas({super.key, required this.proyecto});

  final ProyectoTest proyecto;

  @override
  State<PantallaPartidas> createState() => _PantallaPartidasState();
}

class _PantallaPartidasState extends State<PantallaPartidas> {
  final _bd = BaseDatosSoleraZunbeltz();
  List<BloquePartidas> _bloques = const [];
  bool _cargando = true;

  /// Bloques desplegados; de partida, el primero con algo.
  Set<String>? _abiertos;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final proyecto = widget.proyecto;
    try {
      final presupuesto = await _bd.listarPresupuesto(proyecto.id!);
      final apuntes = [
        ...await _bd.listarApuntes(proyectoId: proyecto.id),
        ...await _bd.amortizacionesDelInventario(proyecto),
      ];
      if (!mounted) return;
      final bloques =
          compararPartidas(presupuesto: presupuesto, apuntes: apuntes);
      setState(() {
        _bloques = bloques;
        _abiertos ??= {
          if (bloques.where((bloque) => !bloque.vacio).firstOrNull
              case final primero?)
            primero.bloque,
        };
        _cargando = false;
      });
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _editarPartidas() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            PantallaConvenio(proyecto: widget.proyecto, pestanaInicial: 1)));
    await _cargar();
  }

  Widget _resumen(AppLocalizations textos) {
    final estilos = Theme.of(context).textTheme;
    final esquema = context.esquemaZunbeltz;
    final previsto = _bloques.fold(0, (suma, bloque) => suma + bloque.previsto);
    final imputado = _bloques.fold(0, (suma, bloque) => suma + bloque.real);
    final proporcion = previsto <= 0 ? null : imputado / previsto;
    Widget cifra(String rotulo, int centimos) => Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rotulo,
                style: estilos.bodyMedium
                    ?.copyWith(color: esquema.onSurfaceVariant)),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(eurosRedondos(centimos),
                  style: estilos.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
          ]),
        );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(children: [
        cifra(textos.presupuestoTotal, previsto),
        const SizedBox(width: 12),
        cifra(textos.partTotalImputado, imputado),
        if (proporcion != null) ...[
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(alignment: Alignment.center, children: [
              Positioned.fill(
                child: CircularProgressIndicator(
                  value: proporcion.clamp(0, 1).toDouble(),
                  strokeWidth: 9,
                  strokeCap: StrokeCap.round,
                  color: proporcion > 1
                      ? context.coloresZunbeltz.bloqueada
                      : colorCuadroEsmeralda,
                  backgroundColor: esquema.surfaceContainerHighest,
                ),
              ),
              Text('${(proporcion * 100).round()} %',
                  style: estilos.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _bloque(
      BloquePartidas bloque, AppLocalizations textos, String idioma) {
    final estilos = Theme.of(context).textTheme;
    final esquema = context.esquemaZunbeltz;
    final abierto = _abiertos!.contains(bloque.bloque);
    final esAmortizacion = bloque.bloque == categoriaAmortizacion;
    final resumen = bloque.vacio
        ? (esAmortizacion ? textos.partDesdeInventario : textos.partSinPartidas)
        : bloque.previsto > 0
            ? textos.proyDeTotal(
                eurosRedondos(bloque.real), eurosRedondos(bloque.previsto))
            : textos.partSinPrevisto(eurosRedondos(bloque.real));
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: abierto ? esquema.surfaceContainerLow : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: abierto
              ? BorderSide.none
              : BorderSide(color: esquema.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          InkWell(
            onTap: bloque.vacio
                ? null
                : () => setState(() => abierto
                    ? _abiertos!.remove(bloque.bloque)
                    : _abiertos!.add(bloque.bloque)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          buscarOpcion(categoriasGasto, bloque.bloque)
                                  ?.etiqueta(idioma) ??
                              bloque.bloque,
                          style: estilos.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      Text(resumen,
                          style: estilos.bodyMedium
                              ?.copyWith(color: esquema.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (!bloque.vacio)
                  Icon(abierto ? Icons.expand_less : Icons.expand_more,
                      color: esquema.onSurfaceVariant),
              ]),
            ),
          ),
          if (abierto)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: Column(children: [
                for (final fila in bloque.partidas) ...[
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Text(
                          fila.partida.isEmpty
                              ? textos.apuSinPartida
                              : etiquetaPartida(
                                  bloque.bloque, fila.partida, idioma),
                          style: estilos.bodyLarge),
                    ),
                    const SizedBox(width: 12),
                    Text(
                        fila.previsto > 0
                            ? textos.proyDeTotal(
                                eurosRedondos(fila.real)
                                    .replaceAll(' €', '')
                                    .replaceAll(' €', ''),
                                eurosRedondos(fila.previsto))
                            : textos.partSinPrevisto(eurosRedondos(fila.real)),
                        style: estilos.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 8),
                  BarraPrevisto(real: fila.real, previsto: fila.previsto),
                  const SizedBox(height: 14),
                ],
              ]),
            ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final esquema = context.esquemaZunbeltz;
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(textos.proyPartidas),
          Text(textos.partSubtitulo,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: esquema.onSurfaceVariant)),
        ]),
        actions: [
          if (politicaEspacioActual.puedeGestionarProyectos)
            IconButton(
              tooltip: textos.partEditar,
              icon: const Icon(Icons.edit_outlined),
              onPressed: _editarPartidas,
            ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView(
                padding: rellenoSobreBarraSistema(
                    context, const EdgeInsets.fromLTRB(16, 8, 16, 24)),
                children: [
                  _resumen(textos),
                  const SizedBox(height: 20),
                  for (final bloque in _bloques)
                    _bloque(bloque, textos, idioma),
                  Text(textos.partNota,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: esquema.onSurfaceVariant)),
                ],
              ),
            ),
    );
  }
}
