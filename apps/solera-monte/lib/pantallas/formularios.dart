import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/aprovechamientos.dart';
import '../dominio/catalogos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/actuacion_plan.dart';
import '../modelos/aprovechamiento.dart';
import '../modelos/arbol_singular.dart';
import '../modelos/ejecucion.dart';
import '../modelos/incendios.dart';
import '../modelos/rodal.dart';
import '../modelos/sorteo_lena.dart';
import '../utiles/textos_monte.dart';
import 'campo_catalogo.dart';
import 'hoja_formulario.dart';

// Altas y ediciones en hojas inferiores. Cada función devuelve true si se
// guardó y avisa a las pestañas abiertas.

BaseDatosSoleraMonte get _bd => BaseDatosSoleraMonte.instancia;

List<(int, String)> _opcionesRodal(List<Rodal> rodales) =>
    [for (final rodal in rodales) (rodal.id!, rodal.etiqueta)];

/// Id del catálogo si el texto coincide con un nombre; si no, el texto.
String idEspecieDesdeTexto(String texto) {
  final limpio = texto.trim();
  for (final opcion in opcionesEspecies()) {
    if (opcion.nombre.toLowerCase() == limpio.toLowerCase()) return opcion.id;
  }
  return limpio;
}

// ─── Rodal ───────────────────────────────────────────────────────────

Future<bool> mostrarEdicionRodal(BuildContext context, {Rodal? rodal}) async {
  final codigo = TextEditingController(text: rodal?.codigo);
  final nombre = TextEditingController(text: rodal?.nombre);
  final especie = TextEditingController(
      text: rodal == null ? '' : nombreEspecie(rodal.especiePrincipalId));
  final anyo = TextEditingController(text: rodal?.anyoOrigen?.toString());
  final superficie = TextEditingController(
      text: numeroParaCampo(rodal?.superficieDeclaradaHa, decimales: 2));
  final notas = TextEditingController(text: rodal?.notas);
  var estado = rodal?.estadoMasa ?? 'fustal';
  String? error;
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(rodal == null ? 'mont.nuevo_rodal' : 'mont.rodal'),
    controladores: [codigo, nombre, especie, anyo, superficie, notas],
    construir: (refrescar) => [
      campoTexto(codigo, SoleraL10n.t('mont.codigo_rodal'),
          ayuda: SoleraL10n.t('mont.codigo_rodal_ayuda')),
      campoTexto(nombre, SoleraL10n.t('mont.nombre_paraje')),
      CampoCatalogo(
          controlador: especie,
          opciones: opcionesEspecies(),
          etiqueta: SoleraL10n.t('mont.especie_principal')),
      campoNumero(anyo, SoleraL10n.t('mont.anyo_origen'),
          decimales: false, ayuda: SoleraL10n.t('mont.anyo_origen_ayuda')),
      campoNumero(superficie, SoleraL10n.t('mont.superficie_declarada'),
          ayuda: SoleraL10n.t('mont.superficie_declarada_ayuda')),
      etiquetaGrupo(context, SoleraL10n.t('mont.estado_masa')),
      selectorChips(
          opciones: estadosMasa,
          valor: estado,
          nombre: nombreEstadoMasa,
          alCambiar: (valor) => refrescar(() => estado = valor)),
      campoTexto(notas, SoleraL10n.t('mont.notas'), lineas: 2),
      if (error != null) textoAviso(context, error!),
    ],
    guardar: () async {
      if (codigo.text.trim().isEmpty || especie.text.trim().isEmpty) {
        error = SoleraL10n.t('mont.falta_codigo_especie');
        return false;
      }
      try {
        await _bd.guardarRodal(Rodal(
          id: rodal?.id,
          codigo: codigo.text.trim(),
          nombre: nombre.text.trim(),
          especiePrincipalId: idEspecieDesdeTexto(especie.text),
          especiesSecundarias: rodal?.especiesSecundarias ?? const [],
          anyoOrigen: leerEntero(anyo.text),
          estadoMasa: estado,
          superficieDeclaradaHa: leerNumero(superficie.text),
          contorno: rodal?.contorno ?? const [],
          notas: notas.text.trim(),
        ));
      } catch (_) {
        error = SoleraL10n.t('mont.codigo_repetido');
        return false;
      }
      avisarCambioDatos();
      return true;
    },
  );
  return guardado;
}

// ─── Plan de gestión ─────────────────────────────────────────────────

Future<bool> mostrarEdicionActuacion(BuildContext context,
    {ActuacionPlan? actuacion}) async {
  final rodales = await _bd.listarRodales();
  if (!context.mounted) return false;
  var rodalId = actuacion?.rodalId;
  var tipo = actuacion?.tipo ?? 'clara';
  var cancelada = actuacion?.cancelada ?? false;
  final anyo = TextEditingController(
      text: '${actuacion?.anyoPrevisto ?? DateTime.now().year}');
  final superficie = TextEditingController(
      text: numeroParaCampo(actuacion?.superficiePrevistaHa, decimales: 2));
  final volumen = TextEditingController(
      text: numeroParaCampo(actuacion?.volumenPrevistoM3));
  final descripcion = TextEditingController(text: actuacion?.descripcion);
  String? error;
  return mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(
        actuacion == null ? 'mont.nueva_actuacion' : 'mont.actuacion'),
    controladores: [anyo, superficie, volumen, descripcion],
    construir: (refrescar) => [
      campoNumero(anyo, SoleraL10n.t('mont.anyo_previsto'), decimales: false),
      selectorId(
          etiqueta: SoleraL10n.t('mont.rodal'),
          valor: rodalId,
          opciones: _opcionesRodal(rodales),
          textoNinguno: SoleraL10n.t('mont.todo_el_monte'),
          alCambiar: (valor) => refrescar(() => rodalId = valor)),
      etiquetaGrupo(context, SoleraL10n.t('mont.tipo_actuacion')),
      selectorChips(
          opciones: tiposActuacion,
          valor: tipo,
          nombre: nombreTipoActuacion,
          alCambiar: (valor) => refrescar(() => tipo = valor)),
      if (tipo == 'senalamiento')
        textoAviso(context, SoleraL10n.t('mont.senalamiento_tecnico'),
            grave: false),
      campoNumero(superficie, SoleraL10n.t('mont.superficie_ha')),
      campoNumero(volumen, SoleraL10n.t('mont.volumen_previsto_m3'),
          ayuda: SoleraL10n.t('mont.volumen_previsto_ayuda')),
      campoTexto(descripcion, SoleraL10n.t('mont.descripcion'), lineas: 2),
      if (actuacion != null)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(SoleraL10n.t('mont.cancelada')),
          value: cancelada,
          onChanged: (valor) => refrescar(() => cancelada = valor),
        ),
      if (error != null) textoAviso(context, error!),
    ],
    guardar: () async {
      final anyoLeido = leerEntero(anyo.text);
      if (anyoLeido == null || anyoLeido < 1900 || anyoLeido > 2200) {
        error = SoleraL10n.t('mont.falta_anyo');
        return false;
      }
      await _bd.guardarActuacion(ActuacionPlan(
        id: actuacion?.id,
        rodalId: rodalId,
        anyoPrevisto: anyoLeido,
        tipo: tipo,
        superficiePrevistaHa: leerNumero(superficie.text),
        volumenPrevistoM3: leerNumero(volumen.text),
        descripcion: descripcion.text.trim(),
        cancelada: cancelada,
      ));
      avisarCambioDatos();
      return true;
    },
  );
}

Future<bool> mostrarEdicionEjecucion(BuildContext context,
    {Ejecucion? ejecucion, ActuacionPlan? deActuacion}) async {
  final rodales = await _bd.listarRodales();
  final actuaciones = await _bd.listarActuaciones();
  if (!context.mounted) return false;
  var actuacionId = ejecucion?.actuacionPlanId ?? deActuacion?.id;
  var rodalId = ejecucion?.rodalId ?? deActuacion?.rodalId;
  var tipo = ejecucion?.tipo ?? deActuacion?.tipo ?? 'desbroce';
  var completa = ejecucion?.completa ?? true;
  var fecha = ejecucion == null
      ? DateTime.now()
      : DateTime.fromMillisecondsSinceEpoch(ejecucion.fechaMs);
  final superficie = TextEditingController(
      text: numeroParaCampo(
          ejecucion?.superficieHa ?? deActuacion?.superficiePrevistaHa,
          decimales: 2));
  final ejecutor = TextEditingController(text: ejecucion?.ejecutor);
  final notas = TextEditingController(text: ejecucion?.notas);
  final opcionesActuacion = [
    for (final actuacion in actuaciones.where((a) => !a.cancelada))
      (
        actuacion.id!,
        '${actuacion.anyoPrevisto} · ${nombreTipoActuacion(actuacion.tipo)}'
            '${actuacion.rodalId == null ? '' : ' · ${rodales.where((r) => r.id == actuacion.rodalId).firstOrNull?.codigo ?? ''}'}'
      )
  ];
  return mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(
        ejecucion == null ? 'mont.nueva_ejecucion' : 'mont.ejecucion'),
    controladores: [superficie, ejecutor, notas],
    construir: (refrescar) => [
      selectorFecha(context,
          fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
      selectorId(
          etiqueta: SoleraL10n.t('mont.actuacion_del_plan'),
          valor: actuacionId,
          opciones: opcionesActuacion,
          textoNinguno: SoleraL10n.t('mont.no_prevista'),
          alCambiar: (valor) => refrescar(() {
                actuacionId = valor;
                final elegida =
                    actuaciones.where((a) => a.id == valor).firstOrNull;
                if (elegida != null) {
                  tipo = elegida.tipo;
                  rodalId = elegida.rodalId;
                }
              })),
      selectorId(
          etiqueta: SoleraL10n.t('mont.rodal'),
          valor: rodalId,
          opciones: _opcionesRodal(rodales),
          textoNinguno: SoleraL10n.t('mont.todo_el_monte'),
          alCambiar: (valor) => refrescar(() => rodalId = valor)),
      etiquetaGrupo(context, SoleraL10n.t('mont.tipo_actuacion')),
      selectorChips(
          opciones: tiposActuacion,
          valor: tipo,
          nombre: nombreTipoActuacion,
          alCambiar: (valor) => refrescar(() => tipo = valor)),
      campoNumero(superficie, SoleraL10n.t('mont.superficie_ha')),
      campoTexto(ejecutor, SoleraL10n.t('mont.ejecutor'),
          ayuda: SoleraL10n.t('mont.ejecutor_ayuda')),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('mont.completa')),
        subtitle: Text(SoleraL10n.t('mont.completa_ayuda')),
        value: completa,
        onChanged: (valor) => refrescar(() => completa = valor),
      ),
      campoTexto(notas, SoleraL10n.t('mont.notas'), lineas: 2),
    ],
    guardar: () async {
      await _bd.guardarEjecucion(Ejecucion(
        id: ejecucion?.id,
        actuacionPlanId: actuacionId,
        rodalId: rodalId,
        fechaMs: fecha.millisecondsSinceEpoch,
        tipo: tipo,
        superficieHa: leerNumero(superficie.text),
        ejecutor: ejecutor.text.trim(),
        completa: completa,
        notas: notas.text.trim(),
      ));
      avisarCambioDatos();
      return true;
    },
  );
}

// ─── Aprovechamientos ────────────────────────────────────────────────

Future<bool> mostrarEdicionAprovechamiento(BuildContext context,
    {Aprovechamiento? aprovechamiento, int? campanya}) async {
  final rodales = await _bd.listarRodales();
  if (!context.mounted) return false;
  var tipo = aprovechamiento?.tipo ?? 'lena';
  var unidad = aprovechamiento?.unidad ?? 'estereos';
  var modalidad = aprovechamiento?.modalidad ?? 'lotes_vecinales';
  var tramite = aprovechamiento?.tramite ?? 'pendiente';
  var comercializado = aprovechamiento?.comercializado ?? false;
  var rodalId = aprovechamiento?.rodalId;
  var inicio = aprovechamiento == null
      ? DateTime.now()
      : DateTime.fromMillisecondsSinceEpoch(aprovechamiento.fechaInicioMs);
  DateTime? fin = aprovechamiento?.fechaFinMs == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(aprovechamiento!.fechaFinMs!);
  DateTime? comunicada = aprovechamiento?.fechaComunicacionCuantiaMs == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(
          aprovechamiento!.fechaComunicacionCuantiaMs!);
  final anyoCampanya = TextEditingController(
      text: '${aprovechamiento?.campanya ?? campanya ?? DateTime.now().year}');
  final prevista = TextEditingController(
      text: numeroParaCampo(aprovechamiento?.cantidadPrevista));
  final obtenida =
      TextEditingController(text: numeroParaCampo(aprovechamiento?.cantidad));
  final adjudicatario =
      TextEditingController(text: aprovechamiento?.adjudicatario);
  final referencia =
      TextEditingController(text: aprovechamiento?.referenciaTramite);
  final notas = TextEditingController(text: aprovechamiento?.notas);
  String? error;
  Aprovechamiento leer(int anyoLeido) => Aprovechamiento(
        id: aprovechamiento?.id,
        campanya: anyoLeido,
        rodalId: rodalId,
        tipo: tipo,
        fechaInicioMs: inicio.millisecondsSinceEpoch,
        fechaFinMs: fin?.millisecondsSinceEpoch,
        cantidadPrevista: leerNumero(prevista.text),
        cantidad: leerNumero(obtenida.text) ?? 0,
        unidad: unidad,
        modalidad: modalidad,
        adjudicatario: adjudicatario.text.trim(),
        tramite: tramite,
        referenciaTramite: referencia.text.trim(),
        comercializado: comercializado,
        fechaComunicacionCuantiaMs: comunicada?.millisecondsSinceEpoch,
        notas: notas.text.trim(),
      );
  return mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(aprovechamiento == null
        ? 'mont.nuevo_aprovechamiento'
        : 'mont.aprovechamiento'),
    controladores: [
      anyoCampanya,
      prevista,
      obtenida,
      adjudicatario,
      referencia,
      notas
    ],
    construir: (refrescar) {
      final borrador = leer(leerEntero(anyoCampanya.text) ?? 0);
      return [
        etiquetaGrupo(context, SoleraL10n.t('mont.tipo_aprovechamiento')),
        selectorChips(
            opciones: tiposAprovechamiento,
            valor: tipo,
            nombre: nombreTipoAprovechamiento,
            alCambiar: (valor) => refrescar(() {
                  tipo = valor;
                  if (valor == 'madera') unidad = 'm3';
                  if (valor == 'lena') unidad = 'estereos';
                })),
        campoNumero(anyoCampanya, SoleraL10n.t('mont.campanya'),
            decimales: false),
        selectorId(
            etiqueta: SoleraL10n.t('mont.rodal'),
            valor: rodalId,
            opciones: _opcionesRodal(rodales),
            textoNinguno: SoleraL10n.t('mont.todo_el_monte'),
            alCambiar: (valor) => refrescar(() => rodalId = valor)),
        selectorFecha(context,
            etiqueta: SoleraL10n.t('mont.fecha_inicio'),
            fecha: inicio,
            alCambiar: (valor) => refrescar(() => inicio = valor)),
        selectorFecha(context,
            etiqueta: SoleraL10n.t('mont.fecha_fin'),
            fecha: fin,
            alCambiar: (valor) => refrescar(() => fin = valor),
            alQuitar: () => refrescar(() => fin = null)),
        etiquetaGrupo(context, SoleraL10n.t('mont.unidad')),
        selectorChips(
            opciones: unidadesAprovechamiento,
            valor: unidad,
            nombre: nombreUnidad,
            alCambiar: (valor) => refrescar(() => unidad = valor)),
        campoNumero(prevista, SoleraL10n.t('mont.cantidad_prevista')),
        campoNumero(obtenida, SoleraL10n.t('mont.cantidad_obtenida')),
        etiquetaGrupo(context, SoleraL10n.t('mont.modalidad')),
        selectorChips(
            opciones: modalidadesAprovechamiento,
            valor: modalidad,
            nombre: nombreModalidad,
            alCambiar: (valor) => refrescar(() => modalidad = valor)),
        campoTexto(adjudicatario, SoleraL10n.t('mont.adjudicatario')),
        etiquetaGrupo(context, SoleraL10n.t('mont.tramite')),
        selectorChips(
            opciones: tramitesAprovechamiento,
            valor: tramite,
            nombre: nombreTramite,
            alCambiar: (valor) => refrescar(() => tramite = valor)),
        textoAviso(context, SoleraL10n.t('mont.tramite_lo_decide_ca'),
            grave: false),
        campoTexto(referencia, SoleraL10n.t('mont.referencia_tramite')),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(SoleraL10n.t('mont.comercializado')),
          subtitle: Text(SoleraL10n.t('mont.comercializado_ayuda')),
          value: comercializado,
          onChanged: (valor) => refrescar(() => comercializado = valor),
        ),
        if (comercializado && borrador.esMaderableOLenoso)
          selectorFecha(context,
              etiqueta: SoleraL10n.t('mont.fecha_comunicacion_cuantia'),
              fecha: comunicada,
              alCambiar: (valor) => refrescar(() => comunicada = valor),
              alQuitar: () => refrescar(() => comunicada = null)),
        if (superaMenorCuantia(borrador))
          textoAviso(context, SoleraL10n.t('mont.aviso_menor_cuantia')),
        campoTexto(notas, SoleraL10n.t('mont.notas'), lineas: 2),
        if (error != null) textoAviso(context, error!),
      ];
    },
    guardar: () async {
      final anyoLeido = leerEntero(anyoCampanya.text);
      if (anyoLeido == null || anyoLeido < 1900 || anyoLeido > 2200) {
        error = SoleraL10n.t('mont.falta_anyo');
        return false;
      }
      await _bd.guardarAprovechamiento(leer(anyoLeido));
      avisarCambioDatos();
      return true;
    },
  );
}

// ─── Sorteos y lotes de leña ─────────────────────────────────────────

Future<int?> mostrarNuevoSorteo(BuildContext context) async {
  final nombre = TextEditingController();
  final anyo = TextEditingController(text: '${DateTime.now().year}');
  int? creado;
  await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('mont.nuevo_sorteo'),
    controladores: [nombre, anyo],
    construir: (_) => [
      Text(SoleraL10n.t('mont.sorteo_explicacion')),
      campoTexto(nombre, SoleraL10n.t('mont.nombre_sorteo'),
          ayuda: SoleraL10n.t('mont.nombre_sorteo_ayuda')),
      campoNumero(anyo, SoleraL10n.t('mont.campanya'), decimales: false),
    ],
    guardar: () async {
      final anyoLeido = leerEntero(anyo.text) ?? DateTime.now().year;
      creado = await _bd.guardarSorteo(
          SorteoLena(campanya: anyoLeido, nombre: nombre.text.trim()));
      avisarCambioDatos();
      return true;
    },
  );
  return creado;
}

Future<bool> mostrarEdicionLote(BuildContext context,
    {required int sorteoId, LoteLena? lote, int? numeroPropuesto}) async {
  final rodales = await _bd.listarRodales();
  if (!context.mounted) return false;
  var rodalId = lote?.rodalId;
  final numero =
      TextEditingController(text: '${lote?.numero ?? numeroPropuesto ?? 1}');
  final cantidad = TextEditingController(text: numeroParaCampo(lote?.cantidad));
  final descripcion = TextEditingController(text: lote?.descripcion);
  String? error;
  return mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(lote == null ? 'mont.nuevo_lote' : 'mont.lote'),
    controladores: [numero, cantidad, descripcion],
    construir: (refrescar) => [
      campoNumero(numero, SoleraL10n.t('mont.numero_lote'), decimales: false),
      selectorId(
          etiqueta: SoleraL10n.t('mont.rodal'),
          valor: rodalId,
          opciones: _opcionesRodal(rodales),
          alCambiar: (valor) => refrescar(() => rodalId = valor)),
      campoNumero(cantidad, SoleraL10n.t('mont.estereos_lote'),
          ayuda: SoleraL10n.t('mont.estereos_lote_ayuda')),
      campoTexto(descripcion, SoleraL10n.t('mont.donde_esta_lote'), lineas: 2),
      if (error != null) textoAviso(context, error!),
    ],
    guardar: () async {
      final numeroLeido = leerEntero(numero.text);
      if (numeroLeido == null || numeroLeido < 1) {
        error = SoleraL10n.t('mont.falta_numero_lote');
        return false;
      }
      try {
        await _bd.guardarLote(LoteLena(
          id: lote?.id,
          sorteoId: sorteoId,
          numero: numeroLeido,
          rodalId: rodalId,
          cantidad: leerNumero(cantidad.text),
          descripcion: descripcion.text.trim(),
          adjudicatario: lote?.adjudicatario ?? '',
        ));
      } catch (_) {
        error = SoleraL10n.t('mont.numero_lote_repetido');
        return false;
      }
      avisarCambioDatos();
      return true;
    },
  );
}

// ─── Árboles singulares ──────────────────────────────────────────────

Future<bool> mostrarEdicionArbol(BuildContext context,
    {ArbolSingular? arbol, String? codigoPropuesto}) async {
  final rodales = await _bd.listarRodales();
  if (!context.mounted) return false;
  var tipo = arbol?.tipo ?? 'arbol_singular';
  var rodalId = arbol?.rodalId;
  final codigo =
      TextEditingController(text: arbol?.codigo ?? codigoPropuesto ?? '');
  final nombre = TextEditingController(text: arbol?.nombre);
  final especie = TextEditingController(
      text: arbol == null ? '' : nombreEspecie(arbol.especieId));
  final perimetro =
      TextEditingController(text: numeroParaCampo(arbol?.perimetroCm));
  final altura = TextEditingController(text: numeroParaCampo(arbol?.alturaM));
  final radio =
      TextEditingController(text: numeroParaCampo(arbol?.radioParcelaM));
  final notas = TextEditingController(text: arbol?.notas);
  String? error;
  return mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(arbol == null ? 'mont.nuevo_arbol' : 'mont.arbol'),
    controladores: [codigo, nombre, especie, perimetro, altura, radio, notas],
    construir: (refrescar) => [
      selectorChips(
          opciones: tiposArbolInventario,
          valor: tipo,
          nombre: nombreTipoArbol,
          alCambiar: (valor) => refrescar(() => tipo = valor)),
      campoTexto(codigo, SoleraL10n.t('mont.codigo_chapa')),
      campoTexto(nombre, SoleraL10n.t('mont.nombre_arbol')),
      CampoCatalogo(
          controlador: especie,
          opciones: opcionesEspecies(),
          etiqueta: SoleraL10n.t('mont.especie')),
      selectorId(
          etiqueta: SoleraL10n.t('mont.rodal'),
          valor: rodalId,
          opciones: _opcionesRodal(rodales),
          alCambiar: (valor) => refrescar(() => rodalId = valor)),
      if (tipo == 'arbol_singular') ...[
        campoNumero(perimetro, SoleraL10n.t('mont.perimetro_cm')),
        campoNumero(altura, SoleraL10n.t('mont.altura_m')),
      ] else
        campoNumero(radio, SoleraL10n.t('mont.radio_parcela_m')),
      campoTexto(notas, SoleraL10n.t('mont.notas'), lineas: 2),
      if (error != null) textoAviso(context, error!),
    ],
    guardar: () async {
      if (codigo.text.trim().isEmpty) {
        error = SoleraL10n.t('mont.falta_codigo');
        return false;
      }
      try {
        await _bd.guardarArbol(ArbolSingular(
          id: arbol?.id,
          codigo: codigo.text.trim(),
          tipo: tipo,
          especieId: especie.text.trim().isEmpty
              ? ''
              : idEspecieDesdeTexto(especie.text),
          nombre: nombre.text.trim(),
          rodalId: rodalId,
          latitud: arbol?.latitud,
          longitud: arbol?.longitud,
          perimetroCm: leerNumero(perimetro.text),
          alturaM: leerNumero(altura.text),
          radioParcelaM: leerNumero(radio.text),
          fechaAltaMs:
              arbol?.fechaAltaMs ?? DateTime.now().millisecondsSinceEpoch,
          notas: notas.text.trim(),
        ));
      } catch (_) {
        error = SoleraL10n.t('mont.codigo_repetido');
        return false;
      }
      avisarCambioDatos();
      return true;
    },
  );
}

// ─── Incendios ───────────────────────────────────────────────────────

Future<bool> mostrarEdicionInfraestructura(BuildContext context,
    {InfraestructuraIncendios? infraestructura}) async {
  var tipo = infraestructura?.tipo ?? 'punto_agua';
  var activa = infraestructura?.activa ?? true;
  final nombre = TextEditingController(text: infraestructura?.nombre);
  final longitud =
      TextEditingController(text: numeroParaCampo(infraestructura?.longitudM));
  final ancho =
      TextEditingController(text: numeroParaCampo(infraestructura?.anchoM));
  final capacidad = TextEditingController(
      text: numeroParaCampo(infraestructura?.capacidadM3));
  final notas = TextEditingController(text: infraestructura?.notas);
  String? error;
  return mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(infraestructura == null
        ? 'mont.nueva_infraestructura'
        : 'mont.infraestructura'),
    controladores: [nombre, longitud, ancho, capacidad, notas],
    construir: (refrescar) => [
      selectorChips(
          opciones: tiposInfraestructuraIncendios,
          valor: tipo,
          nombre: nombreTipoInfraestructura,
          alCambiar: (valor) => refrescar(() => tipo = valor)),
      campoTexto(nombre, SoleraL10n.t('mont.nombre')),
      if (tipo == 'punto_agua')
        campoNumero(capacidad, SoleraL10n.t('mont.capacidad_m3'))
      else ...[
        campoNumero(longitud, SoleraL10n.t('mont.longitud_m'),
            ayuda: SoleraL10n.t('mont.longitud_ayuda')),
        campoNumero(ancho, SoleraL10n.t('mont.ancho_m')),
      ],
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('mont.activa')),
        value: activa,
        onChanged: (valor) => refrescar(() => activa = valor),
      ),
      campoTexto(notas, SoleraL10n.t('mont.notas'), lineas: 2),
      if (error != null) textoAviso(context, error!),
    ],
    guardar: () async {
      if (nombre.text.trim().isEmpty) {
        error = SoleraL10n.t('mont.falta_nombre');
        return false;
      }
      await _bd.guardarInfraestructura(InfraestructuraIncendios(
        id: infraestructura?.id,
        tipo: tipo,
        nombre: nombre.text.trim(),
        latitud: infraestructura?.latitud,
        longitud: infraestructura?.longitud,
        traza: infraestructura?.traza ?? const [],
        longitudM: leerNumero(longitud.text),
        anchoM: leerNumero(ancho.text),
        capacidadM3: leerNumero(capacidad.text),
        activa: activa,
        notas: notas.text.trim(),
      ));
      avisarCambioDatos();
      return true;
    },
  );
}

Future<bool> mostrarNuevaRevision(BuildContext context,
    {required InfraestructuraIncendios infraestructura,
    RevisionIncendios? revision}) async {
  var estado = revision?.estado ?? 'correcto';
  var fecha = revision == null
      ? DateTime.now()
      : DateTime.fromMillisecondsSinceEpoch(revision.fechaMs);
  final trabajos = TextEditingController(text: revision?.trabajosNecesarios);
  final revisor = TextEditingController(text: revision?.revisor);
  final notas = TextEditingController(text: revision?.notas);
  return mostrarHojaFormulario(
    context,
    titulo: '${SoleraL10n.t('mont.revision')} · ${infraestructura.nombre}',
    controladores: [trabajos, revisor, notas],
    construir: (refrescar) => [
      selectorFecha(context,
          fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
      selectorChips(
          opciones: estadosRevision,
          valor: estado,
          nombre: nombreEstadoRevision,
          alCambiar: (valor) => refrescar(() => estado = valor)),
      campoTexto(trabajos, SoleraL10n.t('mont.trabajos_necesarios'), lineas: 2),
      campoTexto(revisor, SoleraL10n.t('mont.revisor')),
      campoTexto(notas, SoleraL10n.t('mont.notas')),
    ],
    guardar: () async {
      await _bd.guardarRevision(RevisionIncendios(
        id: revision?.id,
        infraestructuraId: infraestructura.id!,
        fechaMs: fecha.millisecondsSinceEpoch,
        estado: estado,
        trabajosNecesarios: trabajos.text.trim(),
        revisor: revisor.text.trim(),
        notas: notas.text.trim(),
      ));
      avisarCambioDatos();
      return true;
    },
  );
}
