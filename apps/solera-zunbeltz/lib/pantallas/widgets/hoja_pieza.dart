import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../branding.dart';
import '../../datos/base_datos.dart';
import '../../estado/datos_notificador.dart';
import '../../estado/sesion_espacio.dart';
import '../../l10n/app_localizations.dart';
import '../../modelos/constantes.dart';
import '../../modelos/tarea_mantenimiento.dart';
import '../../modelos/zona_finca.dart';
import '../../utiles/estilos_tarea.dart';
import '../../utiles/geodesia.dart';
import '../../utiles/recinto_sigpac.dart';
import '../ficha_lote.dart';
import '../ficha_zona.dart';
import '../nueva_peticion.dart';
import '../nueva_tarea.dart';
import '../pantalla_ganado.dart' show numeroConComa;
import 'acciones_tarea.dart';
import 'fila_tarea.dart';

/// Tareas abiertas que caben en la hoja; el resto, en la ficha completa.
const _tareasEnHoja = 3;

/// Hoja de una pieza sobre el mapa (pantalla 06 de la propuesta): nombre,
/// tipo y estado, superficie, perímetro y SIGPAC, el ganado que hay, sus
/// tareas abiertas y los botones de nueva tarea y de la ficha completa.
/// El lápiz devuelve al mapa la acción elegida (`editar_datos`, `ajustar`,
/// `redibujar`), porque es el mapa quien sabe editar contornos.
class HojaPieza extends StatefulWidget {
  const HojaPieza({
    super.key,
    required this.zona,
    required this.alCerrar,
    required this.alVerFicha,
    required this.alAccion,
    required this.alCambiarDatos,
  });

  final ZonaFinca zona;
  final VoidCallback alCerrar;
  final VoidCallback alVerFicha;
  final ValueChanged<String> alAccion;

  /// Para que el mapa repinte (cabezas por pieza, contador de tareas).
  final Future<void> Function() alCambiarDatos;

  @override
  State<HojaPieza> createState() => _HojaPiezaState();
}

class _HojaPiezaState extends State<HojaPieza> {
  final _bd = BaseDatosSoleraZunbeltz();
  List<TareaMantenimiento> _abiertas = const [];
  List<ResumenLote> _ganado = const [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    notificadorDatos.addListener(_cargar);
    _cargar();
  }

  @override
  void dispose() {
    notificadorDatos.removeListener(_cargar);
    super.dispose();
  }

  Future<void> _cargar() async {
    final zonaId = widget.zona.id;
    if (zonaId == null) return;
    var tareas = const <TareaMantenimiento>[];
    var ganado = const <ResumenLote>[];
    try {
      tareas = await _bd.listarTareas(zonaId: zonaId);
      ganado = (await _bd.lotesPorZona())[zonaId] ?? const [];
    } catch (_) {
      // Sin BD (tests sin plugins): la hoja sale vacía.
    }
    if (!mounted) return;
    setState(() {
      _abiertas = tareas.where((tarea) => tarea.estado != 'hecha').toList();
      _ganado = ganado;
      _cargando = false;
    });
  }

  Future<void> _recargarTodo() async {
    await _cargar();
    await widget.alCambiarDatos();
  }

  Future<void> _nuevaTarea() async {
    final zona = widget.zona;
    final creada = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => NuevaTarea(fincaId: zona.fincaId, zonaId: zona.id)));
    if (creada == true) await _recargarTodo();
  }

  Future<void> _pedirTarea() async {
    final zona = widget.zona;
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => NuevaPeticion(fincaId: zona.fincaId, zonaId: zona.id)));
  }

  Future<void> _traerRebano() async {
    if (await traerRebanoAPieza(context, widget.zona.id!)) {
      await _recargarTodo();
    }
  }

  Future<void> _abrirLote(int loteId) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => FichaLote(loteId: loteId)));
    await _recargarTodo();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final esquema = context.esquemaZunbeltz;
    final colores = context.coloresZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final zona = widget.zona;
    final tipo =
        buscarOpcion(tiposZona, zona.tipo)?.etiqueta(idioma) ?? zona.tipo;
    final titulo = zona.nombre.isEmpty ? tipo : zona.nombre;
    final politicaEspacio = politicaEspacioActual;
    final politicaTareas = politicaTareasActual;
    final partesSigpac = partesRecintoSigpac(zona.recintoSigpac);
    final altoMaximo = MediaQuery.sizeOf(context).height * 0.62;

    final cifras = <Widget>[
      _CifraPieza(
        rotulo: textos.zonaSuperficie,
        valor:
            '${NumberFormat('#,##0.00', idioma).format(zona.superficieHa)} ha',
        detalle:
            zona.tieneSuperficieOficial ? 'SIGPAC' : textos.zonaOrientativa,
      ),
      _CifraPieza(
        rotulo: textos.zonaPerimetro,
        valor:
            '${NumberFormat('#,##0', idioma).format(perimetroMetros(zona.vertices))} m',
        detalle: textos.dibujoEsquinas(zona.vertices.length),
      ),
      if (zona.recintoSigpac.isNotEmpty)
        _CifraPieza(
          rotulo: 'SIGPAC',
          valor: partesSigpac?.join(' · ') ?? zona.recintoSigpac,
          detalle: partesSigpac == null
              ? null
              : partesSigpac.length == 3
                  ? textos.piezaSigpacPartes
                  : textos.piezaSigpacPartesSinSub,
        ),
    ];

    final botonPrincipal = politicaTareas.puedeCrear
        ? FilledButton.icon(
            onPressed: _nuevaTarea,
            icon: const Icon(Icons.add_task),
            label: Text(textos.zonaNuevaTarea),
          )
        : politicaEspacio.puedeEnviarPeticiones
            ? FilledButton.icon(
                onPressed: _pedirTarea,
                icon: const Icon(Icons.add_comment_outlined),
                label: Text(textos.peticionNueva),
              )
            : null;

    return Container(
      constraints: BoxConstraints(maxHeight: altoMaximo),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1F002117), blurRadius: 12, offset: Offset(0, -2)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: esquema.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: Text(titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: estilos.headlineSmall),
            ),
            if (politicaEspacio.puedeEditarEspacio)
              PopupMenuButton<String>(
                tooltip: textos.zonaEditar,
                icon: const Icon(Icons.edit_outlined),
                onSelected: widget.alAccion,
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'editar_datos',
                    child: ListTile(
                      leading: const Icon(Icons.edit_note),
                      title: Text(textos.zonaEditarDatos),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'ajustar',
                    child: ListTile(
                      leading: const Icon(Icons.polyline_outlined),
                      title: Text(textos.zonaAjustarContorno),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'redibujar',
                    child: ListTile(
                      leading: const Icon(Icons.draw_outlined),
                      title: Text(textos.zonaRedibujar),
                    ),
                  ),
                ],
              ),
            IconButton(
              tooltip: textos.piezaCerrar,
              icon: const Icon(Icons.close),
              onPressed: widget.alCerrar,
            ),
          ]),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              _ChipPieza(
                icono: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorDeZona(zona).withValues(alpha: 0.35),
                    border: Border.all(color: colorDeZona(zona), width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                texto: tipo,
                fondo: esquema.surfaceContainerHigh,
                color: esquema.onSurface,
              ),
              _ChipEstadoZona(estado: zona.estado),
            ]),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var indice = 0;
                          indice < cifras.length;
                          indice++) ...[
                        if (indice > 0) const SizedBox(width: 8),
                        Expanded(child: cifras[indice]),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  _GanadoEnPieza(
                    ganado: _ganado,
                    superficieHa: zona.superficieHa,
                    alTraer: politicaEspacio.puedeRegistrarGanado
                        ? _traerRebano
                        : null,
                    alAbrirLote: _abrirLote,
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child:
                          Text(textos.zonaTareas, style: estilos.titleMedium),
                    ),
                    if (!_cargando)
                      Text(textos.piezaPendientes(_abiertas.length),
                          style: estilos.labelLarge?.copyWith(
                              color: _abiertas.isEmpty
                                  ? esquema.onSurfaceVariant
                                  : colores.pendiente)),
                  ]),
                  if (!_cargando && _abiertas.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(textos.piezaSinTareasAbiertas,
                          style: estilos.bodyMedium
                              ?.copyWith(color: esquema.onSurfaceVariant)),
                    ),
                  for (final tarea in _abiertas.take(_tareasEnHoja))
                    FilaTarea(
                      tarea: tarea,
                      lugar: '',
                      margenIzquierdo: 0,
                      verResponsable: true,
                      alPulsar: () async {
                        if (await mostrarAccionesTarea(context, tarea)) {
                          await _recargarTodo();
                        }
                      },
                      alMarcarHecha: politicaTareas.puedeEjecutar(tarea)
                          ? () => marcarTareaHechaDesdeLista(
                              context, tarea, _recargarTodo)
                          : null,
                    ),
                  if (_abiertas.length > _tareasEnHoja)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: widget.alVerFicha,
                        child: Text(textos
                            .piezaMasTareas(_abiertas.length - _tareasEnHoja)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(children: [
              if (botonPrincipal != null) ...[
                Expanded(child: botonPrincipal),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.alVerFicha,
                  icon: const Icon(Icons.open_in_full),
                  label: Text(textos.piezaVerFicha),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

/// Una cifra de la pieza en su tarjeta: rótulo, valor grande y detalle.
class _CifraPieza extends StatelessWidget {
  const _CifraPieza({required this.rotulo, required this.valor, this.detalle});

  final String rotulo;
  final String valor;
  final String? detalle;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final apagado =
        estilos.bodySmall?.copyWith(color: esquema.onSurfaceVariant);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: esquema.surface,
        borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: apagado),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(valor,
                style: estilos.titleLarge?.copyWith(
                    fontFamily: familiaTextoZunbeltz,
                    fontWeight: FontWeight.w700)),
          ),
          if (detalle != null)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(detalle!, maxLines: 1, style: apagado),
            ),
        ],
      ),
    );
  }
}

class _ChipPieza extends StatelessWidget {
  const _ChipPieza({
    required this.icono,
    required this.texto,
    required this.fondo,
    required this.color,
  });

  final Widget icono;
  final String texto;
  final Color fondo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(radioZunbeltz),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        icono,
        const SizedBox(width: 8),
        Text(texto,
            style:
                Theme.of(context).textTheme.labelLarge?.copyWith(color: color)),
      ]),
    );
  }
}

/// En uso (verde), en descanso (marrón) o vedada (rojo), con su fondo.
class _ChipEstadoZona extends StatelessWidget {
  const _ChipEstadoZona({required this.estado});
  final String estado;

  @override
  Widget build(BuildContext context) {
    final idioma = Localizations.localeOf(context).languageCode;
    final colores = context.coloresZunbeltz;
    final (Color fondo, IconData icono) = switch (estado) {
      'descanso' => (colores.fondoPendiente, Icons.pause_circle_outline),
      'vedada' => (colores.fondoBloqueada, Icons.block),
      _ => (colores.fondoHecha, Icons.check_circle_outline),
    };
    final color = colorEstadoZona(estado, colores);
    return _ChipPieza(
      icono: Icon(icono, size: 18, color: color),
      texto: buscarOpcion(estadosZona, estado)?.etiqueta(idioma) ?? estado,
      fondo: fondo,
      color: color,
    );
  }
}

/// El ganado que hay ahora en la pieza, con «Traer un rebaño».
class _GanadoEnPieza extends StatelessWidget {
  const _GanadoEnPieza({
    required this.ganado,
    required this.superficieHa,
    required this.alTraer,
    required this.alAbrirLote,
  });

  final List<ResumenLote> ganado;
  final double superficieHa;
  final VoidCallback? alTraer;
  final ValueChanged<int> alAbrirLote;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final apagado =
        estilos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: colorCuadroSalvia,
          borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
        ),
        child: const Icon(Icons.pets, color: colorSobreCuadroClaro),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(textos.ganEnEstaPieza, style: estilos.titleMedium),
            if (ganado.isEmpty)
              Text(textos.ganPiezaSinGanado, style: apagado)
            else
              for (final resumen in ganado)
                InkWell(
                  onTap: resumen.lote.id == null
                      ? null
                      : () => alAbrirLote(resumen.lote.id!),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      [
                        resumen.lote.nombre,
                        textos.ganCabezas(resumen.cabezas),
                        if (superficieHa > 0 && resumen.ugm > 0)
                          textos.ganUgmPorHa(
                              numeroConComa(resumen.ugm / superficieHa)),
                      ].join(' · '),
                      style: apagado?.copyWith(
                          color: esquema.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: esquema.primary),
                    ),
                  ),
                ),
          ],
        ),
      ),
      if (alTraer != null)
        TextButton(onPressed: alTraer, child: Text(textos.ganTraerAqui)),
    ]);
  }
}
