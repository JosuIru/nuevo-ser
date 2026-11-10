import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, rellenoInferiorSeguro;

import '../datos/base_datos.dart';
import '../estado/cambios_datos.dart';
import '../provisional_core/venta_directa/socio.dart';
import '../provisional_core/venta_directa/suscripcion.dart';
import '../utiles/textos_huerta.dart';
import 'hoja_formulario.dart';

BaseDatosSoleraHuerta get _bd => BaseDatosSoleraHuerta.instancia;

Future<bool> mostrarFormularioSocio(BuildContext context,
    {Socio? socio}) async {
  final nombre = TextEditingController(text: socio?.nombre);
  final telefono = TextEditingController(text: socio?.telefono);
  final correo = TextEditingController(text: socio?.correo);
  final grupo = TextEditingController(text: socio?.grupoConsumo);
  final punto = TextEditingController(text: socio?.puntoEntrega);
  final notas = TextEditingController(text: socio?.notas);
  var activo = socio?.activo ?? true;
  final guardado = await mostrarHojaFormulario(
    context,
    titulo:
        SoleraL10n.t(socio == null ? 'huer.nuevo_socio' : 'huer.editar_socio'),
    controladores: [nombre, telefono, correo, grupo, punto, notas],
    construir: (refrescar) => [
      campoTexto(nombre, SoleraL10n.t('huer.nombre')),
      campoTexto(telefono, SoleraL10n.t('huer.telefono')),
      campoTexto(correo, SoleraL10n.t('huer.correo')),
      campoTexto(grupo, SoleraL10n.t('huer.grupo_consumo')),
      campoTexto(punto, SoleraL10n.t('huer.punto_entrega')),
      campoTexto(notas, SoleraL10n.t('huer.notas_socio')),
      if (socio != null)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(SoleraL10n.t('huer.socio_activo')),
          value: activo,
          onChanged: (valor) => refrescar(() => activo = valor),
        ),
    ],
    guardar: () async {
      if (nombre.text.trim().isEmpty) return false;
      await _bd.guardarSocio(Socio(
        id: socio?.id,
        nombre: nombre.text.trim(),
        telefono: telefono.text.trim(),
        correo: correo.text.trim(),
        grupoConsumo: grupo.text.trim(),
        puntoEntrega: punto.text.trim(),
        activo: activo,
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
  return guardado;
}

Future<bool> mostrarFormularioSuscripcion(BuildContext context,
    {required int socioId, Suscripcion? suscripcion}) async {
  final precio = TextEditingController(
      text: suscripcion == null || suscripcion.precioCentimosCesta == 0
          ? ''
          : numeroParaCampo(suscripcion.precioCentimosCesta / 100));
  final notas = TextEditingController(text: suscripcion?.notas);
  var tamano = suscripcion?.tamano ?? 'mediana';
  var frecuencia = suscripcion?.frecuencia ?? frecuenciasSuscripcion.first;
  var inicio = suscripcion == null
      ? DateTime.now()
      : DateTime.fromMillisecondsSinceEpoch(suscripcion.fechaInicioMs);
  DateTime? fin = suscripcion?.fechaFinMs == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(suscripcion!.fechaFinMs!);
  var activa = suscripcion?.activa ?? true;
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(suscripcion == null
        ? 'huer.nueva_suscripcion'
        : 'huer.editar_suscripcion'),
    controladores: [precio, notas],
    construir: (refrescar) => [
      desplegable<String>(
        etiqueta: SoleraL10n.t('huer.tamano_cesta'),
        valor: tamano,
        opciones: partesPorTamanoCesta.keys.toList(),
        nombre: nombreTamanoCesta,
        alCambiar: (valor) => refrescar(() => tamano = valor ?? tamano),
      ),
      desplegable<String>(
        etiqueta: SoleraL10n.t('huer.frecuencia'),
        valor: frecuencia,
        opciones: frecuenciasSuscripcion,
        nombre: nombreFrecuencia,
        alCambiar: (valor) => refrescar(() => frecuencia = valor ?? frecuencia),
      ),
      selectorFecha(context,
          fecha: inicio,
          etiqueta: SoleraL10n.t('huer.fecha_inicio'),
          alCambiar: (valor) => refrescar(() => inicio = valor)),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('huer.con_fecha_fin')),
        value: fin != null,
        onChanged: (valor) => refrescar(() => fin =
            valor ? DateTime(inicio.year, inicio.month + 6, inicio.day) : null),
      ),
      if (fin != null)
        selectorFecha(context,
            fecha: fin!,
            etiqueta: SoleraL10n.t('huer.fecha_fin'),
            alCambiar: (valor) => refrescar(() => fin = valor)),
      campoNumero(precio, SoleraL10n.t('huer.precio_cesta')),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('huer.suscripcion_activa')),
        subtitle: Text(SoleraL10n.t('huer.suscripcion_activa_ayuda')),
        value: activa,
        onChanged: (valor) => refrescar(() => activa = valor),
      ),
      campoTexto(notas, SoleraL10n.t('huer.notas')),
    ],
    guardar: () async {
      await _bd.guardarSuscripcion(Suscripcion(
        id: suscripcion?.id,
        socioId: socioId,
        tamano: tamano,
        frecuencia: frecuencia,
        fechaInicioMs: inicio.millisecondsSinceEpoch,
        fechaFinMs: fin?.millisecondsSinceEpoch,
        precioCentimosCesta: ((leerNumero(precio.text) ?? 0) * 100).round(),
        activa: activa,
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
  return guardado;
}

/// Socios con sus suscripciones.
class PantallaSocios extends StatefulWidget {
  const PantallaSocios({super.key});

  @override
  State<PantallaSocios> createState() => _PantallaSociosState();
}

class _PantallaSociosState extends State<PantallaSocios> {
  late Future<(List<Socio>, List<Suscripcion>)> _datos;

  @override
  void initState() {
    super.initState();
    _datos = _cargar();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  Future<(List<Socio>, List<Suscripcion>)> _cargar() async =>
      (await _bd.listarSocios(), await _bd.listarSuscripciones());

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _datos = _cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('huer.socios'))),
      floatingActionButton: FloatingActionButton(
        tooltip: SoleraL10n.t('huer.nuevo_socio'),
        onPressed: () => mostrarFormularioSocio(context),
        child: const Icon(Icons.person_add_alt),
      ),
      body: FutureBuilder<(List<Socio>, List<Suscripcion>)>(
        future: _datos,
        builder: (context, instantanea) {
          final socios = instantanea.data?.$1 ?? const <Socio>[];
          final suscripciones = instantanea.data?.$2 ?? const <Suscripcion>[];
          if (instantanea.connectionState == ConnectionState.done &&
              socios.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(SoleraL10n.t('huer.sin_socios'),
                    textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            padding: rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 88)),
            children: [
              for (final socio in socios) ...[
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  enabled: socio.activo,
                  title: Text(socio.nombre),
                  subtitle: Text([
                    if (socio.grupoConsumo.isNotEmpty) socio.grupoConsumo,
                    if (socio.telefono.isNotEmpty) socio.telefono,
                    if (!socio.activo) SoleraL10n.t('huer.de_baja'),
                  ].join(' · ')),
                  trailing: IconButton(
                    tooltip: SoleraL10n.t('huer.nueva_suscripcion'),
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () => mostrarFormularioSuscripcion(context,
                        socioId: socio.id!),
                  ),
                  onTap: () => mostrarFormularioSocio(context, socio: socio),
                ),
                for (final suscripcion in suscripciones)
                  if (suscripcion.socioId == socio.id)
                    ListTile(
                      contentPadding:
                          const EdgeInsets.only(left: 72, right: 16),
                      dense: true,
                      title: Text([
                        nombreTamanoCesta(suscripcion.tamano),
                        nombreFrecuencia(suscripcion.frecuencia),
                        if (suscripcion.precioCentimosCesta > 0)
                          formatearEuros(suscripcion.precioCentimosCesta),
                      ].join(' · ')),
                      subtitle: Text([
                        SoleraL10n.tf('huer.desde_fecha', {
                          'fecha': formatearFecha(suscripcion.fechaInicioMs)
                        }),
                        if (suscripcion.fechaFinMs != null)
                          SoleraL10n.tf('huer.hasta_fecha', {
                            'fecha': formatearFecha(suscripcion.fechaFinMs!)
                          }),
                        if (!suscripcion.activa) SoleraL10n.t('huer.en_pausa'),
                      ].join(' · ')),
                      onTap: () => mostrarFormularioSuscripcion(context,
                          socioId: socio.id!, suscripcion: suscripcion),
                    ),
              ],
            ],
          );
        },
      ),
    );
  }
}
