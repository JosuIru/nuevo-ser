import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, separarCampoSolera;

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../dominio/recoleccion.dart';
import '../dominio/rendimientos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/cosecha.dart';
import '../modelos/destilacion.dart';
import '../modelos/lote_producto.dart';
import '../modelos/parcela.dart';
import '../modelos/secado.dart';
import '../modelos/tratamiento.dart';
import '../modelos/zona_recoleccion.dart';
import '../utiles/textos_aromaticas.dart';
import 'campo_catalogo.dart';
import 'hoja_formulario.dart';

// Altas de los registros en hojas inferiores. Cada función devuelve true si
// se guardó y avisa a las pestañas abiertas.

BaseDatosSoleraAromaticas get _bd => BaseDatosSoleraAromaticas.instancia;

void _liberar(List<TextEditingController> controladores) {
  for (final controlador in controladores) {
    controlador.dispose();
  }
}

void _avisar(BuildContext context, String clave) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(SoleraL10n.t(clave))));

/// Origen de una cosecha: «p» + id (parcela) o «z» + id (zona).
String _claveOrigen({int? parcelaId, int? zonaId}) =>
    parcelaId != null ? 'p$parcelaId' : 'z$zonaId';

/// Pregunta si se guarda a pesar de los avisos. True si no hay avisos.
Future<bool> confirmarAvisos(BuildContext context, List<String> avisos) async {
  if (avisos.isEmpty) return true;
  final seguir = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      icon: const Icon(Icons.warning_amber_outlined),
      title: Text(SoleraL10n.t('arom.revisa_antes_de_guardar')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final aviso in avisos) Text('• $aviso')],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: Text(SoleraL10n.t('cancelar'))),
        FilledButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: Text(SoleraL10n.t('arom.guardar_igualmente'))),
      ],
    ),
  );
  return seguir == true;
}

/// Cosecha de una parcela o recolección en una zona silvestre. Con una zona,
/// comprueba el permiso y avisa (no bloquea).
Future<bool> mostrarAltaCosecha(BuildContext context,
    {int? parcelaId,
    int? zonaId,
    Cosecha? cosecha,
    String? especiePropuesta}) async {
  final parcelas = await _bd.listarParcelas();
  final zonas = await _bd.listarZonasRecoleccion();
  if (!context.mounted) return false;
  if (parcelas.isEmpty && zonas.isEmpty) {
    _avisar(context, 'arom.primero_un_origen');
    return false;
  }
  final titular = await _bd.obtenerTitular();
  if (!context.mounted) return false;
  var origen = cosecha != null
      ? _claveOrigen(
          parcelaId: cosecha.parcelaId, zonaId: cosecha.zonaRecoleccionId)
      : parcelaId != null || zonaId != null
          ? _claveOrigen(parcelaId: parcelaId, zonaId: zonaId)
          : parcelas.isNotEmpty
              ? 'p${parcelas.first.id}'
              : 'z${zonas.first.id}';
  Parcela? parcelaDe(String clave) => clave.startsWith('p')
      ? parcelas.where((p) => 'p${p.id}' == clave).firstOrNull
      : null;
  ZonaRecoleccion? zonaDe(String clave) => clave.startsWith('z')
      ? zonas.where((z) => 'z${z.id}' == clave).firstOrNull
      : null;
  String especieInicial() {
    final zona = zonaDe(origen);
    if (zona != null && zona.especiesPermitidas.length == 1) {
      return nombreEspecie(zona.especiesPermitidas.first);
    }
    return nombreEspecie(parcelaDe(origen)?.especieId ?? '');
  }

  var fecha = cosecha == null
      ? DateTime.now()
      : DateTime.fromMillisecondsSinceEpoch(cosecha.fechaMs);
  var estado = cosecha?.estadoFenologico ?? '';
  final especie = TextEditingController(
      text: cosecha != null
          ? nombreEspecie(cosecha.especieId)
          : especiePropuesta != null
              ? nombreEspecie(especiePropuesta)
              : especieInicial());
  final kg = TextEditingController(
      text: numeroParaCampo(cosecha?.kgFrescos, decimales: 1));
  final parte = TextEditingController(text: cosecha?.parteRecolectada);
  final recolector =
      TextEditingController(text: cosecha?.recolector ?? titular.nombre);
  final notas = TextEditingController(text: cosecha?.notas);
  final opciones = opcionesEspecies();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(
        cosecha == null ? 'arom.nueva_cosecha' : 'arom.editar_cosecha'),
    construir: (refrescar) {
      final especieId = idDesdeTexto(especie.text, opciones);
      final zona = zonaDe(origen);
      final confundibles = confundiblesDe(especieId);
      return [
        separarCampoSolera(DropdownButtonFormField<String>(
          initialValue: origen,
          isExpanded: true,
          decoration: InputDecoration(labelText: SoleraL10n.t('arom.origen')),
          items: [
            for (final parcela in parcelas)
              DropdownMenuItem(
                  value: 'p${parcela.id}',
                  child: Text(
                      '${SoleraL10n.t('arom.cultivo')}: ${parcela.nombre}')),
            for (final zona in zonas)
              DropdownMenuItem(
                  value: 'z${zona.id}',
                  child: Text(
                      '${SoleraL10n.t('arom.silvestre')}: ${zona.nombre}')),
          ],
          onChanged: (valor) => refrescar(() => origen = valor ?? origen),
        )),
        selectorFecha(context,
            fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
        CampoCatalogo(
            controlador: especie,
            opciones: opciones,
            etiqueta: SoleraL10n.t('arom.especie'),
            alElegir: (_) => refrescar(() {})),
        if (zona != null && especieConProteccion(especieId))
          textoAviso(context, SoleraL10n.t('arom.aviso_especie_protegida')),
        if (zona != null && confundibles.isNotEmpty)
          textoAviso(
              context,
              SoleraL10n.tf('arom.aviso_confundibles',
                  {'especies': confundibles.map(nombreConfundible).join(', ')}),
              grave: false),
        campoNumero(kg, SoleraL10n.t('arom.kg_frescos')),
        etiquetaGrupo(context, SoleraL10n.t('arom.estado_fenologico')),
        selectorChips(
            opciones: estadosFenologicosCosecha,
            valor: estado,
            nombre: nombreEstadoFenologico,
            permitirVacio: true,
            alCambiar: (valor) => refrescar(() => estado = valor)),
        campoTexto(parte, SoleraL10n.t('arom.parte_recolectada'),
            ayuda: especiePorId(especieId)?.parteUsada),
        campoTexto(recolector, SoleraL10n.t('arom.recolector')),
        campoTexto(notas, SoleraL10n.t('arom.notas')),
      ];
    },
    guardar: () async {
      final kgFrescos = leerNumero(kg.text);
      if (especie.text.trim().isEmpty || kgFrescos == null || kgFrescos <= 0) {
        return false;
      }
      final especieId = idDesdeTexto(especie.text, opciones);
      final zona = zonaDe(origen);
      if (zona != null) {
        final previas = (await _bd.listarCosechas(zonaId: zona.id))
            .where((previa) => previa.id != cosecha?.id);
        final avisos = comprobarRecoleccion(
          zona: zona,
          especieId: especieId,
          fecha: fecha,
          kgNuevos: kgFrescos,
          previas: previas,
          especieConProteccion: especieConProteccion(especieId),
        );
        if (!context.mounted) return false;
        if (!await confirmarAvisos(
            context, avisos.map(textoAvisoRecoleccion).toList())) {
          return false;
        }
      }
      await _bd.guardarCosecha(Cosecha(
        id: cosecha?.id,
        parcelaId: parcelaDe(origen)?.id,
        zonaRecoleccionId: zona?.id,
        especieId: especieId,
        fechaMs: fecha.millisecondsSinceEpoch,
        kgFrescos: kgFrescos,
        estadoFenologico: estado,
        parteRecolectada: parte.text.trim(),
        recolector: recolector.text.trim(),
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  _liberar([especie, kg, parte, recolector, notas]);
  if (guardado) avisarCambioDatos();
  return guardado;
}

/// Tratamiento fitosanitario en una parcela de cultivo. Producto, registro
/// y dosis se copian de la etiqueta: la app no los propone (no hay
/// catálogo de sustancias para aromáticas, ver BLOQUEOS).
Future<bool> mostrarAltaTratamiento(BuildContext context,
    {int? parcelaId}) async {
  final parcelas = await _bd.listarParcelas();
  final titular = await _bd.obtenerTitular();
  if (!context.mounted) return false;
  if (parcelas.isEmpty) {
    _avisar(context, 'arom.primero_una_parcela');
    return false;
  }
  var parcela = parcelaId ?? parcelas.first.id;
  var fecha = DateTime.now();
  var eficacia = '';
  final superficie = TextEditingController();
  final problema = TextEditingController();
  final sustancia = TextEditingController();
  final producto = TextEditingController();
  final registro = TextEditingController();
  final dosis = TextEditingController();
  final plazo = TextEditingController();
  final aplicador = TextEditingController(text: titular.nombre);
  final carnet = TextEditingController();
  final equipo = TextEditingController();
  final observaciones = TextEditingController();
  String especieDe(int? id) =>
      parcelas
          .where((candidata) => candidata.id == id)
          .firstOrNull
          ?.especieId ??
      '';
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('arom.nuevo_tratamiento'),
    construir: (refrescar) => [
      separarCampoSolera(DropdownButtonFormField<int>(
        initialValue: parcela,
        isExpanded: true,
        decoration: InputDecoration(labelText: SoleraL10n.t('arom.parcela')),
        items: [
          for (final candidata in parcelas)
            DropdownMenuItem(
                value: candidata.id,
                child: Text(
                    '${candidata.nombre} · ${nombreEspecie(candidata.especieId)}')),
        ],
        onChanged: (valor) => refrescar(() => parcela = valor),
      )),
      selectorFecha(context,
          fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
      CampoCatalogo(
          controlador: problema,
          opciones: opcionesPlagas(especieDe(parcela)),
          etiqueta: SoleraL10n.t('arom.problema_fitosanitario')),
      campoTexto(sustancia, SoleraL10n.t('arom.sustancia_activa'),
          ayuda: SoleraL10n.t('arom.copiar_de_etiqueta')),
      campoTexto(producto, SoleraL10n.t('arom.nombre_producto'),
          ayuda: SoleraL10n.t('arom.copiar_de_etiqueta')),
      campoTexto(registro, SoleraL10n.t('arom.numero_registro')),
      campoTexto(dosis, SoleraL10n.t('arom.dosis_aplicada'),
          ayuda: SoleraL10n.t('arom.copiar_de_etiqueta')),
      campoNumero(superficie, SoleraL10n.t('arom.superficie_tratada_ha')),
      campoNumero(plazo, SoleraL10n.t('arom.plazo_seguridad_dias'),
          decimales: false),
      campoTexto(aplicador, SoleraL10n.t('arom.aplicador')),
      campoTexto(carnet, SoleraL10n.t('arom.carnet_aplicador')),
      campoTexto(equipo, SoleraL10n.t('arom.equipo_aplicacion')),
      etiquetaGrupo(context, SoleraL10n.t('arom.eficacia')),
      selectorChips(
          opciones: eficaciasTratamiento,
          valor: eficacia,
          nombre: nombreEficacia,
          permitirVacio: true,
          alCambiar: (valor) => refrescar(() => eficacia = valor)),
      campoTexto(observaciones, SoleraL10n.t('arom.observaciones')),
    ],
    guardar: () async {
      if (parcela == null || sustancia.text.trim().isEmpty) return false;
      await _bd.guardarTratamiento(Tratamiento(
        parcelaId: parcela!,
        fechaMs: fecha.millisecondsSinceEpoch,
        superficieTratadaHa: leerNumero(superficie.text) ?? 0,
        problemaFitosanitario:
            idDesdeTexto(problema.text, opcionesPlagas(especieDe(parcela))),
        sustanciaActivaId: sustancia.text.trim(),
        nombreProducto: producto.text.trim(),
        numeroRegistroProducto: registro.text.trim(),
        dosisAplicada: dosis.text.trim(),
        plazoSeguridadDias: leerEntero(plazo.text),
        aplicadorNombre: aplicador.text.trim(),
        carnetAplicador: carnet.text.trim(),
        equipoAplicacion: equipo.text.trim(),
        eficacia: eficacia,
        observaciones: observaciones.text.trim(),
      ));
      return true;
    },
  );
  _liberar([
    superficie,
    problema,
    sustancia,
    producto,
    registro,
    dosis,
    plazo,
    aplicador,
    carnet,
    equipo,
    observaciones
  ]);
  if (guardado) avisarCambioDatos();
  return guardado;
}

/// Lista de cosechas recientes de una especie para marcar las que entran en
/// un secado o una destilación.
Widget _selectorCosechas(
  BuildContext context, {
  required List<Cosecha> cosechas,
  required Set<int> marcadas,
  required StateSetter refrescar,
  required Map<int, String> nombreOrigen,
}) {
  if (cosechas.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(SoleraL10n.t('arom.sin_cosechas_de_especie')),
    );
  }
  return Column(
    children: [
      for (final cosecha in cosechas.take(12))
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          value: marcadas.contains(cosecha.id),
          title: Text(
              '${formatearFecha(cosecha.fechaMs)} · ${formatearNumero(cosecha.kgFrescos)} kg'),
          subtitle: Text(nombreOrigen[cosecha.id] ?? ''),
          onChanged: (valor) => refrescar(() {
            if (valor == true) {
              marcadas.add(cosecha.id!);
            } else {
              marcadas.remove(cosecha.id);
            }
          }),
        ),
    ],
  );
}

/// Nombre del origen de cada cosecha (parcela o zona), por id de cosecha.
Future<Map<int, String>> _origenesDeCosechas(List<Cosecha> cosechas) async {
  final parcelas = {
    for (final parcela in await _bd.listarParcelas()) parcela.id: parcela.nombre
  };
  final zonas = {
    for (final zona in await _bd.listarZonasRecoleccion()) zona.id: zona.nombre
  };
  return {
    for (final cosecha in cosechas)
      cosecha.id!: cosecha.esSilvestre
          ? '${SoleraL10n.t('arom.silvestre')}: ${zonas[cosecha.zonaRecoleccionId] ?? ''}'
          : '${SoleraL10n.t('arom.cultivo')}: ${parcelas[cosecha.parcelaId] ?? ''}',
  };
}

Future<List<String>> _codigosLote() async =>
    (await _bd.listarLotesProducto()).map((lote) => lote.codigo).toList();

/// Secado: kg frescos → kg secos. Con «crear lote», genera el lote de planta
/// seca con un código propuesto.
Future<bool> mostrarAltaSecado(BuildContext context) async {
  final cosechas = await _bd.listarCosechas();
  final origenes = await _origenesDeCosechas(cosechas);
  if (!context.mounted) return false;
  var fecha = DateTime.now();
  var metodo = metodosSecado.first;
  var crearLote = true;
  final marcadas = <int>{};
  final especie = TextEditingController(
      text: cosechas.isEmpty ? '' : nombreEspecie(cosechas.first.especieId));
  final kgFrescos = TextEditingController();
  final kgSecos = TextEditingController();
  final dias = TextEditingController();
  final temperatura = TextEditingController();
  final notas = TextEditingController();
  final opciones = opcionesEspecies();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('arom.nuevo_secado'),
    construir: (refrescar) {
      final especieId = idDesdeTexto(especie.text, opciones);
      final deEspecie =
          cosechas.where((cosecha) => cosecha.especieId == especieId).toList();
      final sumaMarcadas = deEspecie
          .where((cosecha) => marcadas.contains(cosecha.id))
          .fold<double>(0, (suma, cosecha) => suma + cosecha.kgFrescos);
      final rendimiento = rendimientoSecadoPorcentaje(
          leerNumero(kgFrescos.text) ?? sumaMarcadas,
          leerNumero(kgSecos.text) ?? 0);
      final orientativo =
          rendimientoOrientativo(especieId, producto: 'planta_seca');
      return [
        selectorFecha(context,
            fecha: fecha,
            etiqueta: SoleraL10n.t('arom.fecha_inicio'),
            alCambiar: (valor) => refrescar(() => fecha = valor)),
        CampoCatalogo(
            controlador: especie,
            opciones: opciones,
            etiqueta: SoleraL10n.t('arom.especie'),
            alElegir: (_) => refrescar(marcadas.clear)),
        etiquetaGrupo(context, SoleraL10n.t('arom.cosechas_que_entran')),
        _selectorCosechas(context,
            cosechas: deEspecie,
            marcadas: marcadas,
            refrescar: refrescar,
            nombreOrigen: origenes),
        campoNumero(kgFrescos, SoleraL10n.t('arom.kg_frescos'),
            ayuda: sumaMarcadas > 0
                ? SoleraL10n.tf(
                    'arom.suma_cosechas', {'kg': formatearNumero(sumaMarcadas)})
                : null),
        separarCampoSolera(TextField(
          controller: kgSecos,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: SoleraL10n.t('arom.kg_secos')),
          onChanged: (_) => refrescar(() {}),
        )),
        if (rendimiento != null && (leerNumero(kgSecos.text) ?? 0) > 0)
          textoAviso(
              context,
              [
                SoleraL10n.tf('arom.rendimiento_secado',
                    {'pct': formatearNumero(rendimiento)}),
                if (orientativo != null)
                  SoleraL10n.tf('arom.orientativo_intervalo', {
                    'min': formatearNumero(orientativo.minimo!),
                    'max': formatearNumero(orientativo.maximo!),
                    'unidad': orientativo.unidad,
                  }),
                textoComparacion(compararConOrientativo(
                    rendimiento, orientativo?.minimo, orientativo?.maximo)),
              ].where((texto) => texto.isNotEmpty).join(' · '),
              grave: false),
        campoNumero(dias, SoleraL10n.t('arom.dias_secado'), decimales: false),
        etiquetaGrupo(context, SoleraL10n.t('arom.metodo_secado')),
        selectorChips(
            opciones: metodosSecado,
            valor: metodo,
            nombre: nombreMetodoSecado,
            alCambiar: (valor) => refrescar(() => metodo = valor)),
        if (metodo == 'secadero_calor')
          campoNumero(temperatura, SoleraL10n.t('arom.temperatura_maxima')),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(SoleraL10n.t('arom.crear_lote_planta_seca')),
          value: crearLote,
          onChanged: (valor) => refrescar(() => crearLote = valor),
        ),
        campoTexto(notas, SoleraL10n.t('arom.notas')),
      ];
    },
    guardar: () async {
      final especieId = idDesdeTexto(especie.text, opciones);
      final secos = leerNumero(kgSecos.text);
      final usadas = cosechas
          .where((cosecha) =>
              marcadas.contains(cosecha.id) && cosecha.especieId == especieId)
          .toList();
      final frescos = leerNumero(kgFrescos.text) ??
          usadas.fold<double>(0, (suma, cosecha) => suma + cosecha.kgFrescos);
      if (especieId.isEmpty || secos == null || frescos <= 0) return false;
      int? loteId;
      if (crearLote) {
        loteId = await _bd.guardarLoteProducto(LoteProducto(
          codigo: proponerCodigoLote(
              'planta_seca', fecha.year, await _codigosLote()),
          tipo: 'planta_seca',
          especieId: especieId,
          fechaMs: fecha.millisecondsSinceEpoch,
          cantidad: secos,
        ));
      }
      await _bd.guardarSecado(Secado(
        fechaInicioMs: fecha.millisecondsSinceEpoch,
        especieId: especieId,
        cosechasUsadasIds: [for (final cosecha in usadas) cosecha.id!],
        kgFrescos: frescos,
        kgSecos: secos,
        dias: leerEntero(dias.text),
        metodo: metodo,
        temperaturaMaximaC:
            metodo == 'secadero_calor' ? leerNumero(temperatura.text) : null,
        loteProductoId: loteId,
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  _liberar([especie, kgFrescos, kgSecos, dias, temperatura, notas]);
  if (guardado) avisarCambioDatos();
  return guardado;
}

/// Destilación: kg de planta → ml de aceite + litros de hidrolato. Con
/// «crear lotes», genera el de aceite esencial y, si hay, el de hidrolato.
Future<bool> mostrarAltaDestilacion(BuildContext context) async {
  final cosechas = await _bd.listarCosechas();
  final origenes = await _origenesDeCosechas(cosechas);
  if (!context.mounted) return false;
  var fecha = DateTime.now();
  var estadoPlanta = estadosPlantaDestilacion.first;
  var alambique = tiposAlambique.first;
  var crearLotes = true;
  final marcadas = <int>{};
  final especie = TextEditingController(
      text: cosechas.isEmpty ? '' : nombreEspecie(cosechas.first.especieId));
  final kgPlanta = TextEditingController();
  final mlAceite = TextEditingController();
  final litrosHidrolato = TextEditingController();
  final horas = TextEditingController();
  final capacidad = TextEditingController();
  final notas = TextEditingController();
  final opciones = opcionesEspecies();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('arom.nueva_destilacion'),
    construir: (refrescar) {
      final especieId = idDesdeTexto(especie.text, opciones);
      final deEspecie =
          cosechas.where((cosecha) => cosecha.especieId == especieId).toList();
      final sumaMarcadas = deEspecie
          .where((cosecha) => marcadas.contains(cosecha.id))
          .fold<double>(0, (suma, cosecha) => suma + cosecha.kgFrescos);
      final kg = leerNumero(kgPlanta.text) ?? sumaMarcadas;
      final rendimiento = mlAceitePorKg(kg, leerNumero(mlAceite.text) ?? 0);
      final orientativo = rendimientoOrientativo(especieId,
          producto: 'aceite_esencial',
          estadoPlanta: estadoPlanta == 'seca' ? 'seca' : 'fresca');
      return [
        selectorFecha(context,
            fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
        CampoCatalogo(
            controlador: especie,
            opciones: opciones,
            etiqueta: SoleraL10n.t('arom.especie'),
            alElegir: (_) => refrescar(marcadas.clear)),
        etiquetaGrupo(context, SoleraL10n.t('arom.cosechas_que_entran')),
        _selectorCosechas(context,
            cosechas: deEspecie,
            marcadas: marcadas,
            refrescar: refrescar,
            nombreOrigen: origenes),
        campoNumero(kgPlanta, SoleraL10n.t('arom.kg_planta'),
            ayuda: sumaMarcadas > 0
                ? SoleraL10n.tf(
                    'arom.suma_cosechas', {'kg': formatearNumero(sumaMarcadas)})
                : null),
        etiquetaGrupo(context, SoleraL10n.t('arom.estado_planta')),
        selectorChips(
            opciones: estadosPlantaDestilacion,
            valor: estadoPlanta,
            nombre: nombreEstadoPlanta,
            alCambiar: (valor) => refrescar(() => estadoPlanta = valor)),
        separarCampoSolera(TextField(
          controller: mlAceite,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration:
              InputDecoration(labelText: SoleraL10n.t('arom.ml_aceite')),
          onChanged: (_) => refrescar(() {}),
        )),
        if (rendimiento != null && (leerNumero(mlAceite.text) ?? 0) > 0)
          textoAviso(
              context,
              [
                SoleraL10n.tf('arom.rendimiento_aceite',
                    {'ml': formatearNumero(rendimiento, decimales: 2)}),
                if (orientativo != null)
                  SoleraL10n.tf('arom.orientativo_intervalo', {
                    'min': formatearNumero(orientativo.minimo!),
                    'max': formatearNumero(orientativo.maximo!),
                    'unidad': orientativo.unidad,
                  }),
                textoComparacion(compararConOrientativo(
                    rendimiento, orientativo?.minimo, orientativo?.maximo)),
              ].where((texto) => texto.isNotEmpty).join(' · '),
              grave: false),
        campoNumero(litrosHidrolato, SoleraL10n.t('arom.litros_hidrolato')),
        campoNumero(horas, SoleraL10n.t('arom.horas_destilacion')),
        etiquetaGrupo(context, SoleraL10n.t('arom.tipo_alambique')),
        selectorChips(
            opciones: tiposAlambique,
            valor: alambique,
            nombre: nombreTipoAlambique,
            alCambiar: (valor) => refrescar(() => alambique = valor)),
        campoNumero(capacidad, SoleraL10n.t('arom.capacidad_alambique')),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(SoleraL10n.t('arom.crear_lotes_destilacion')),
          value: crearLotes,
          onChanged: (valor) => refrescar(() => crearLotes = valor),
        ),
        campoTexto(notas, SoleraL10n.t('arom.notas')),
      ];
    },
    guardar: () async {
      final especieId = idDesdeTexto(especie.text, opciones);
      final usadas = cosechas
          .where((cosecha) =>
              marcadas.contains(cosecha.id) && cosecha.especieId == especieId)
          .toList();
      final kg = leerNumero(kgPlanta.text) ??
          usadas.fold<double>(0, (suma, cosecha) => suma + cosecha.kgFrescos);
      final ml = leerNumero(mlAceite.text);
      if (especieId.isEmpty || kg <= 0 || ml == null) return false;
      final litros = leerNumero(litrosHidrolato.text) ?? 0;
      int? loteAceite;
      int? loteHidrolato;
      if (crearLotes) {
        final codigos = await _codigosLote();
        if (ml > 0) {
          final codigo =
              proponerCodigoLote('aceite_esencial', fecha.year, codigos);
          codigos.add(codigo);
          loteAceite = await _bd.guardarLoteProducto(LoteProducto(
              codigo: codigo,
              tipo: 'aceite_esencial',
              especieId: especieId,
              fechaMs: fecha.millisecondsSinceEpoch,
              cantidad: ml));
        }
        if (litros > 0) {
          loteHidrolato = await _bd.guardarLoteProducto(LoteProducto(
              codigo: proponerCodigoLote('hidrolato', fecha.year, codigos),
              tipo: 'hidrolato',
              especieId: especieId,
              fechaMs: fecha.millisecondsSinceEpoch,
              cantidad: litros));
        }
      }
      await _bd.guardarDestilacion(Destilacion(
        fechaMs: fecha.millisecondsSinceEpoch,
        especieId: especieId,
        cosechasUsadasIds: [for (final cosecha in usadas) cosecha.id!],
        kgPlanta: kg,
        estadoPlanta: estadoPlanta,
        mlAceiteEsencial: ml,
        litrosHidrolato: litros,
        horas: leerNumero(horas.text),
        tipoAlambique: alambique,
        capacidadAlambiqueLitros: leerNumero(capacidad.text),
        loteAceiteId: loteAceite,
        loteHidrolatoId: loteHidrolato,
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  _liberar(
      [especie, kgPlanta, mlAceite, litrosHidrolato, horas, capacidad, notas]);
  if (guardado) avisarCambioDatos();
  return guardado;
}

/// Edición de un lote: código, destino, lo que queda, envase y notas.
Future<bool> mostrarEdicionLote(BuildContext context, LoteProducto lote) async {
  var destino = lote.destino;
  final codigo = TextEditingController(text: lote.codigo);
  final disponible = TextEditingController(
      text: formatearNumero(lote.disponible, decimales: 1));
  final envase = TextEditingController(text: lote.envase);
  final notas = TextEditingController(text: lote.notas);
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.tf('arom.editar_lote', {'codigo': lote.codigo}),
    construir: (refrescar) => [
      campoTexto(codigo, SoleraL10n.t('arom.codigo_lote')),
      etiquetaGrupo(context, SoleraL10n.t('arom.destino')),
      selectorChips(
          opciones: destinosLote,
          valor: destino,
          nombre: nombreDestinoLote,
          alCambiar: (valor) => refrescar(() => destino = valor)),
      textoAviso(context, SoleraL10n.t('arom.destino_por_verificar'),
          grave: false),
      campoNumero(disponible,
          SoleraL10n.tf('arom.cantidad_disponible', {'unidad': lote.unidad})),
      campoTexto(envase, SoleraL10n.t('arom.envase')),
      campoTexto(notas, SoleraL10n.t('arom.notas')),
    ],
    guardar: () async {
      if (codigo.text.trim().isEmpty) return false;
      try {
        await _bd.guardarLoteProducto(LoteProducto(
          id: lote.id,
          codigo: codigo.text.trim(),
          tipo: lote.tipo,
          especieId: lote.especieId,
          fechaMs: lote.fechaMs,
          destino: destino,
          cantidad: lote.cantidad,
          cantidadDisponible: leerNumero(disponible.text),
          envase: envase.text.trim(),
          fechaConsumoPreferenteMs: lote.fechaConsumoPreferenteMs,
          notas: notas.text.trim(),
        ));
      } catch (error) {
        debugPrint('Lote no guardado: $error');
        if (context.mounted) _avisar(context, 'arom.codigo_repetido');
        return false;
      }
      return true;
    },
  );
  _liberar([codigo, disponible, envase, notas]);
  if (guardado) avisarCambioDatos();
  return guardado;
}

/// Pide confirmación y borra; avisa si la BD no lo permite (registros
/// que dependen de él).
Future<void> confirmarYBorrar(
    BuildContext context, Future<void> Function() borrar) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(SoleraL10n.t('arom.borrar_registro')),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: Text(SoleraL10n.t('cancelar'))),
        FilledButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: Text(SoleraL10n.t('borrar'))),
      ],
    ),
  );
  if (confirmado != true) return;
  try {
    await borrar();
    avisarCambioDatos();
  } catch (error) {
    debugPrint('No se pudo borrar: $error');
    if (context.mounted) _avisar(context, 'arom.no_se_puede_borrar');
  }
}
