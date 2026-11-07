import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../datos/estado_bodega.dart';
import '../dominio/catalogos.dart';
import '../dominio/comprobacion_dop.dart';
import '../estado/cambios_datos.dart';
import '../modelos/embotellado.dart';
import '../modelos/kupela.dart';
import '../utiles/textos_sidra.dart';
import 'hoja_formulario.dart';
import 'pantalla_bodega.dart';

/// Ficha de una kupela: lo que hay, sus movimientos y mediciones, y las
/// operaciones (medir, trasegar, embotellar, calificar).
class PantallaKupela extends StatefulWidget {
  const PantallaKupela({super.key, required this.kupelaId});

  final int kupelaId;

  @override
  State<PantallaKupela> createState() => _PantallaKupelaState();
}

class _DatosKupela {
  _DatosKupela(this.estado, this.mediciones);

  final EstadoBodega estado;
  final List<MedicionKupela> mediciones;
}

class _PantallaKupelaState extends State<PantallaKupela> {
  late Future<_DatosKupela> _datos = _cargar();

  Future<_DatosKupela> _cargar() async => _DatosKupela(
        await EstadoBodega.cargar(),
        await BaseDatosSoleraSidra.instancia
            .listarMediciones(kupelaId: widget.kupelaId),
      );

  void _recargar() {
    avisarCambioDatos();
    setState(() {
      _datos = _cargar();
    });
  }

  Future<void> _medir() async {
    final controladores = {
      for (final campo in ['densidad', 'temperatura', 'acidez', 'grado', 'so2'])
        campo: TextEditingController(),
    };
    var fechaMs = DateTime.now().millisecondsSinceEpoch;
    final guardado = await mostrarHojaFormulario(
      controladores: controladores.values.toList(),
      context,
      titulo: SoleraL10n.t('sidr.nueva_medicion'),
      construir: (refrescar) => [
        SelectorFecha(
          etiqueta: SoleraL10n.t('sidr.fecha'),
          fechaMs: fechaMs,
          alCambiar: (fecha) => refrescar(() => fechaMs = fecha ?? fechaMs),
        ),
        campoNumero(controladores['densidad']!, SoleraL10n.t('sidr.densidad')),
        campoNumero(
            controladores['temperatura']!, SoleraL10n.t('sidr.temperatura'),
            sufijo: '°C'),
        campoNumero(
            controladores['acidez']!, SoleraL10n.t('sidr.acidez_volatil'),
            sufijo: 'g/l'),
        campoNumero(
            controladores['grado']!, SoleraL10n.t('sidr.grado_alcoholico'),
            sufijo: '% vol'),
        campoNumero(controladores['so2']!, SoleraL10n.t('sidr.sulfuroso_total'),
            sufijo: 'mg/l'),
      ],
      guardar: () async {
        final medicion = MedicionKupela(
          kupelaId: widget.kupelaId,
          fechaMs: fechaMs,
          densidad: leerNumero(controladores['densidad']!.text),
          temperaturaC: leerNumero(controladores['temperatura']!.text),
          acidezVolatilGL: leerNumero(controladores['acidez']!.text),
          gradoAlcoholico: leerNumero(controladores['grado']!.text),
          sulfurosoTotalMgL: leerNumero(controladores['so2']!.text),
        );
        if (medicion.estaVacia) return false;
        await BaseDatosSoleraSidra.instancia.guardarMedicion(medicion);
        return true;
      },
    );
    if (guardado) _recargar();
  }

  Future<void> _trasegar(EstadoBodega estado) async {
    final litros = TextEditingController();
    final motivo = TextEditingController();
    int? destino;
    var fechaMs = DateTime.now().millisecondsSinceEpoch;
    final guardado = await mostrarHojaFormulario(
      controladores: [litros, motivo],
      context,
      titulo: SoleraL10n.t('sidr.trasiego'),
      construir: (refrescar) => [
        SelectorFecha(
          etiqueta: SoleraL10n.t('sidr.fecha'),
          fechaMs: fechaMs,
          alCambiar: (fecha) => refrescar(() => fechaMs = fecha ?? fechaMs),
        ),
        campoDesplegable<int?>(
          etiqueta: SoleraL10n.t('sidr.kupela_destino'),
          valor: destino,
          opciones: [
            (null, SoleraL10n.t('sidr.retirada_lias')),
            for (final kupela in estado.kupelas)
              if (kupela.id != widget.kupelaId && kupela.activa)
                (kupela.id, kupela.etiqueta),
          ],
          alCambiar: (valor) => refrescar(() => destino = valor),
        ),
        campoNumero(litros, SoleraL10n.t('sidr.litros'), sufijo: 'l'),
        campoTexto(motivo, SoleraL10n.t('sidr.motivo')),
      ],
      guardar: () async {
        final cantidad = leerNumero(litros.text);
        if (cantidad == null || cantidad <= 0) return false;
        await BaseDatosSoleraSidra.instancia.guardarTrasiego(Trasiego(
          fechaMs: fechaMs,
          kupelaOrigenId: widget.kupelaId,
          kupelaDestinoId: destino,
          litros: cantidad,
          motivo: motivo.text.trim(),
        ));
        return true;
      },
    );
    if (guardado) _recargar();
  }

  Future<void> _embotellar(Kupela kupela) async {
    var fechaMs = DateTime.now().millisecondsSinceEpoch;
    final lote = TextEditingController(
        text: codigoLoteEmbotellado(DateTime.now(), kupela.codigo));
    final botellas = TextEditingController();
    final mililitros = TextEditingController(text: '750');
    final desde = TextEditingController();
    final hasta = TextEditingController();
    final destino = TextEditingController();
    var conDop = kupela.productoDopId.isNotEmpty;
    final guardado = await mostrarHojaFormulario(
      controladores: [lote, botellas, mililitros, desde, hasta, destino],
      context,
      titulo: '${SoleraL10n.t('sidr.embotellar')} · ${kupela.codigo}',
      construir: (refrescar) => [
        SelectorFecha(
          etiqueta: SoleraL10n.t('sidr.fecha'),
          fechaMs: fechaMs,
          alCambiar: (fecha) => refrescar(() => fechaMs = fecha ?? fechaMs),
        ),
        campoTexto(lote, SoleraL10n.t('sidr.codigo_lote')),
        campoNumero(botellas, SoleraL10n.t('sidr.botellas'), decimales: false),
        campoNumero(mililitros, SoleraL10n.t('sidr.mililitros_botella'),
            decimales: false, sufijo: 'ml'),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: conDop,
          title: Text(SoleraL10n.t('sidr.con_contraetiqueta_dop')),
          onChanged: (valor) => refrescar(() => conDop = valor),
        ),
        if (conDop)
          Row(children: [
            Expanded(
                child: campoNumero(desde, SoleraL10n.t('sidr.etiqueta_desde'),
                    decimales: false)),
            const SizedBox(width: 8),
            Expanded(
                child: campoNumero(hasta, SoleraL10n.t('sidr.etiqueta_hasta'),
                    decimales: false)),
          ]),
        campoTexto(destino, SoleraL10n.t('sidr.destino')),
      ],
      guardar: () async {
        final numeroBotellas = leerEntero(botellas.text);
        final volumen = leerEntero(mililitros.text);
        if (lote.text.trim().isEmpty ||
            numeroBotellas == null ||
            numeroBotellas <= 0 ||
            volumen == null ||
            volumen <= 0) {
          return false;
        }
        await BaseDatosSoleraSidra.instancia.guardarEmbotellado(Embotellado(
          fechaMs: fechaMs,
          kupelaId: kupela.id!,
          codigoLote: lote.text.trim(),
          botellas: numeroBotellas,
          mililitrosBotella: volumen,
          conDop: conDop,
          fechaEtiquetadoMs: conDop ? fechaMs : null,
          etiquetaDesde: conDop ? leerEntero(desde.text) : null,
          etiquetaHasta: conDop ? leerEntero(hasta.text) : null,
          destino: destino.text.trim(),
        ));
        return true;
      },
    );
    if (guardado) _recargar();
  }

  Future<void> _calificar(Kupela kupela) async {
    final calificacion = await showDialog<String>(
      context: context,
      builder: (contexto) => SimpleDialog(
        title: Text(SoleraL10n.t('sidr.calificacion')),
        children: [
          for (final valor in calificacionesKupela)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(contexto, valor),
              child: Text(nombreValor('calificacion', valor)),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(SoleraL10n.t('sidr.calificacion_ayuda'),
                style: Theme.of(contexto).textTheme.bodySmall),
          ),
        ],
      ),
    );
    if (calificacion == null) return;
    await BaseDatosSoleraSidra.instancia.guardarKupela(Kupela(
      id: kupela.id,
      codigo: kupela.codigo,
      capacidadLitros: kupela.capacidadLitros,
      nombre: kupela.nombre,
      material: kupela.material,
      producto: kupela.producto,
      calificacion: calificacion,
      productoDopId: kupela.productoDopId,
      activa: kupela.activa,
      notas: kupela.notas,
    ));
    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DatosKupela>(
      future: _datos,
      builder: (context, instantanea) {
        final datos = instantanea.data;
        final kupela = datos?.estado.kupela(widget.kupelaId);
        if (datos == null || kupela == null) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()));
        }
        final estado = datos.estado;
        final litros = estado.saldo.litrosEn(kupela.id!);
        final producto = productoDopPorId(kupela.productoDopId);
        final movimientos =
            (estado.saldo.movimientos[kupela.id!] ?? const []).reversed;
        return Scaffold(
          appBar: AppBar(
            title: Text(kupela.etiqueta),
            actions: [
              IconButton(
                tooltip: SoleraL10n.t('editar'),
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  await mostrarEditarKupela(context, kupela: kupela);
                  _recargar();
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              TarjetaKupela(kupela: kupela, litros: litros),
              if (estado.saldo.quedaEnNegativo(kupela.id!))
                TarjetaAviso(SoleraL10n.t('sidr.aviso_negativo'),
                    icono: Icons.warning_amber_outlined),
              if (estado.saldo.superaCapacidad(kupela))
                TarjetaAviso(SoleraL10n.t('sidr.aviso_supera_capacidad'),
                    icono: Icons.warning_amber_outlined),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _medir,
                      icon: const Icon(Icons.thermostat_outlined),
                      label: Text(SoleraL10n.t('sidr.medir')),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _trasegar(estado),
                      icon: const Icon(Icons.swap_horiz),
                      label: Text(SoleraL10n.t('sidr.trasegar')),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _embotellar(kupela),
                      icon: const Icon(Icons.liquor_outlined),
                      label: Text(SoleraL10n.t('sidr.embotellar')),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _calificar(kupela),
                      icon: const Icon(Icons.verified_outlined),
                      label: Text(SoleraL10n.t('sidr.calificacion')),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text(SoleraL10n.t('sidr.mediciones'),
                    style: Theme.of(context).textTheme.titleMedium),
                subtitle: producto == null
                    ? null
                    : Text(SoleraL10n.tf(
                        'sidr.comparado_con', {'producto': producto.nombre})),
              ),
              if (datos.mediciones.isEmpty)
                ListTile(title: Text(SoleraL10n.t('sidr.sin_mediciones'))),
              for (final medicion in datos.mediciones)
                FilaMedicion(
                  medicion: medicion,
                  avisos: producto == null
                      ? const []
                      : avisosMedicion(medicion, producto),
                ),
              ListTile(
                title: Text(SoleraL10n.t('sidr.movimientos'),
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              for (final movimiento in movimientos)
                ListTile(
                  dense: true,
                  title: Text('${nombreValor('movimiento', movimiento.tipo)}'
                      '${movimiento.otraKupelaId == null ? '' : ' · ${estado.etiquetaKupela(movimiento.otraKupelaId)}'}'),
                  subtitle: Text(formatearFecha(movimiento.fechaMs)),
                  trailing: Text(
                      '${movimiento.litros > 0 ? '+' : ''}${formatearLitros(movimiento.litros)}'),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Una medición con sus avisos frente al pliego.
class FilaMedicion extends StatelessWidget {
  const FilaMedicion({super.key, required this.medicion, required this.avisos});

  final MedicionKupela medicion;
  final List<AvisoDop> avisos;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(avisos.isEmpty
          ? Icons.thermostat_outlined
          : Icons.warning_amber_outlined),
      title: Text([
        if (medicion.densidad != null)
          '${SoleraL10n.t('sidr.densidad')} ${formatearNumero(medicion.densidad!, decimales: 0)}',
        if (medicion.temperaturaC != null)
          '${formatearNumero(medicion.temperaturaC!)} °C',
        if (medicion.acidezVolatilGL != null)
          '${SoleraL10n.t('sidr.av')} ${formatearNumero(medicion.acidezVolatilGL!, decimales: 2)} g/l',
        if (medicion.gradoAlcoholico != null)
          '${formatearNumero(medicion.gradoAlcoholico!)} % vol',
        if (medicion.sulfurosoTotalMgL != null)
          'SO₂ ${formatearNumero(medicion.sulfurosoTotalMgL!, decimales: 0)} mg/l',
      ].join(' · ')),
      subtitle: Text([
        formatearFecha(medicion.fechaMs),
        for (final aviso in avisos) textoAviso(aviso),
      ].join('\n')),
    );
  }
}

/// «Acidez volátil 2,30 por encima del máximo del pliego (2,20)».
String textoAviso(AvisoDop aviso) {
  final clave = 'sidr.aviso_${aviso.codigo}';
  return SoleraL10n.tf(clave, {
    'valor': formatearNumero(aviso.valor, decimales: 2),
    'limite': formatearNumero(aviso.limite, decimales: 2),
  });
}
