import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, separarCampoSolera;

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../dominio/resumen_cosecha.dart';
import '../estado/cambios_datos.dart';
import '../modelos/abonado.dart';
import '../modelos/contrato_polinizacion.dart';
import '../modelos/cosecha.dart';
import '../modelos/fila_arboles.dart';
import '../modelos/helada.dart';
import '../modelos/observacion_plaga.dart';
import '../modelos/parcela.dart';
import '../modelos/riego.dart';
import '../modelos/tratamiento.dart';
import '../utiles/textos_frutal.dart';
import 'campo_catalogo.dart';
import 'hoja_formulario.dart';

// Altas de los registros del cuaderno en hojas inferiores. Cada función
// devuelve true si se guardó y avisa a las pestañas abiertas.

Future<List<Parcela>> _parcelas() =>
    BaseDatosSoleraFrutal.instancia.listarParcelas();

void _avisarSinParcelas(BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('frut.primero_una_parcela'))));

String _especieDe(List<Parcela> parcelas, int parcelaId) => parcelas
    .firstWhere((parcela) => parcela.id == parcelaId,
        orElse: () => parcelas.first)
    .especieId;

void _liberar(List<TextEditingController> controladores) {
  for (final controlador in controladores) {
    controlador.dispose();
  }
}

/// Tratamiento fitosanitario. Producto, registro y dosis se copian de la
/// etiqueta: la app no los propone.
Future<bool> mostrarAltaTratamiento(BuildContext context,
    {int? parcelaId}) async {
  final parcelas = await _parcelas();
  if (!context.mounted) return false;
  if (parcelas.isEmpty) {
    _avisarSinParcelas(context);
    return false;
  }
  final titular = await BaseDatosSoleraFrutal.instancia.obtenerTitular();
  if (!context.mounted) return false;
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
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('frut.nuevo_tratamiento'),
    construir: (refrescar) => [
      selectorParcela(
          parcelas: parcelas,
          parcelaId: parcela,
          alCambiar: (valor) => refrescar(() => parcela = valor)),
      selectorFecha(context,
          fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
      ...() {
        final especie = parcelas
            .firstWhere((candidata) => candidata.id == parcela,
                orElse: () => parcelas.first)
            .especieId;
        final opcionesPlaga = opcionesPlagas(especie);
        final plagaId = idDesdeTexto(problema.text, opcionesPlaga);
        final sustanciaId =
            idDesdeTexto(sustancia.text, opcionesSustancias(especie));
        final datosSustancia = sustanciaPorId(sustanciaId);
        final uso = usoRegistrado(sustanciaId, especie, plagaId);
        return [
          CampoCatalogo(
              controlador: problema,
              opciones: opcionesPlaga,
              etiqueta: SoleraL10n.t('frut.problema_fitosanitario'),
              alElegir: (_) => refrescar(() {})),
          CampoCatalogo(
              controlador: sustancia,
              opciones: opcionesSustancias(especie, plagaId: plagaId),
              etiqueta: SoleraL10n.t('frut.sustancia_activa'),
              ayuda: SoleraL10n.t('frut.sustancia_ayuda'),
              alElegir: (_) => refrescar(() {})),
          if (datosSustancia != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                [
                  datosSustancia.plazoSeguridadMaximoDias == null
                      ? SoleraL10n.t('frut.ps_no_procede_registro')
                      : SoleraL10n.tf('frut.ps_maximo_registro',
                          {'n': datosSustancia.plazoSeguridadMaximoDias}),
                  if (uso == false) SoleraL10n.t('frut.uso_no_registrado'),
                ].join(' '),
                style: TextStyle(
                    color: uso == false
                        ? Theme.of(context).colorScheme.error
                        : null),
              ),
            ),
        ];
      }(),
      campoTexto(producto, SoleraL10n.t('frut.nombre_producto'),
          ayuda: SoleraL10n.t('frut.copiar_de_etiqueta')),
      campoTexto(registro, SoleraL10n.t('frut.numero_registro')),
      campoTexto(dosis, SoleraL10n.t('frut.dosis_aplicada'),
          ayuda: SoleraL10n.t('frut.copiar_de_etiqueta')),
      campoNumero(superficie, SoleraL10n.t('frut.superficie_tratada_ha')),
      campoNumero(plazo, SoleraL10n.t('frut.plazo_seguridad_dias'),
          decimales: false),
      campoTexto(aplicador, SoleraL10n.t('frut.aplicador')),
      campoTexto(carnet, SoleraL10n.t('frut.carnet_aplicador')),
      campoTexto(equipo, SoleraL10n.t('frut.equipo_aplicacion')),
      Text(SoleraL10n.t('frut.eficacia')),
      Wrap(
        spacing: 6,
        children: [
          for (final opcion in eficaciasTratamiento)
            ChoiceChip(
              label: Text(nombreEficacia(opcion)),
              selected: eficacia == opcion,
              onSelected: (marcado) =>
                  refrescar(() => eficacia = marcado ? opcion : ''),
            ),
        ],
      ),
      campoTexto(observaciones, SoleraL10n.t('frut.observaciones')),
    ],
    guardar: () async {
      if (parcela == null || sustancia.text.trim().isEmpty) return false;
      await BaseDatosSoleraFrutal.instancia.guardarTratamiento(Tratamiento(
        parcelaId: parcela!,
        fechaMs: fecha.millisecondsSinceEpoch,
        superficieTratadaHa: leerNumero(superficie.text) ?? 0,
        problemaFitosanitario: idDesdeTexto(
            problema.text, opcionesPlagas(_especieDe(parcelas, parcela!))),
        sustanciaActivaId: idDesdeTexto(
            sustancia.text, opcionesSustancias(_especieDe(parcelas, parcela!))),
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

Future<bool> mostrarAltaAbonado(BuildContext context, {int? parcelaId}) async {
  final parcelas = await _parcelas();
  if (!context.mounted) return false;
  if (parcelas.isEmpty) {
    _avisarSinParcelas(context);
    return false;
  }
  var parcela = parcelaId ?? parcelas.first.id;
  var fecha = DateTime.now();
  var metodo = metodosAbonado.first;
  final tipo = TextEditingController();
  final riqueza = TextEditingController();
  final cantidad = TextEditingController();
  final superficie = TextEditingController();
  final notas = TextEditingController();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('frut.nuevo_abonado'),
    construir: (refrescar) => [
      selectorParcela(
          parcelas: parcelas,
          parcelaId: parcela,
          alCambiar: (valor) => refrescar(() => parcela = valor)),
      selectorFecha(context,
          fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
      campoTexto(tipo, SoleraL10n.t('frut.tipo_abono')),
      campoTexto(riqueza, SoleraL10n.t('frut.riqueza_npk')),
      campoNumero(cantidad, SoleraL10n.t('frut.cantidad_kg_ha')),
      campoNumero(superficie, SoleraL10n.t('frut.superficie_ha')),
      Wrap(
        spacing: 6,
        children: [
          for (final opcion in metodosAbonado)
            ChoiceChip(
              label: Text(nombreMetodoAbonado(opcion)),
              selected: metodo == opcion,
              onSelected: (_) => refrescar(() => metodo = opcion),
            ),
        ],
      ),
      campoTexto(notas, SoleraL10n.t('frut.notas')),
    ],
    guardar: () async {
      if (parcela == null || tipo.text.trim().isEmpty) return false;
      await BaseDatosSoleraFrutal.instancia.guardarAbonado(Abonado(
        parcelaId: parcela!,
        fechaMs: fecha.millisecondsSinceEpoch,
        tipoAbono: tipo.text.trim(),
        riquezaNpk: riqueza.text.trim(),
        cantidadKgPorHa: leerNumero(cantidad.text) ?? 0,
        metodo: metodo,
        superficieHa: leerNumero(superficie.text) ?? 0,
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  _liberar([tipo, riqueza, cantidad, superficie, notas]);
  if (guardado) avisarCambioDatos();
  return guardado;
}

Future<bool> mostrarAltaRiego(BuildContext context, {int? parcelaId}) async {
  final parcelas =
      (await _parcelas()).where((parcela) => parcela.regadio).toList();
  if (!context.mounted) return false;
  if (parcelas.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('frut.sin_parcelas_regadio'))));
    return false;
  }
  var parcela = parcelas.any((candidata) => candidata.id == parcelaId)
      ? parcelaId
      : parcelas.first.id;
  var fecha = DateTime.now();
  final volumen = TextEditingController();
  final horas = TextEditingController();
  final origen = TextEditingController();
  final notas = TextEditingController();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('frut.nuevo_riego'),
    construir: (refrescar) => [
      selectorParcela(
          parcelas: parcelas,
          parcelaId: parcela,
          alCambiar: (valor) => refrescar(() => parcela = valor)),
      selectorFecha(context,
          fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
      campoNumero(volumen, SoleraL10n.t('frut.volumen_m3')),
      campoNumero(horas, SoleraL10n.t('frut.horas')),
      campoTexto(origen, SoleraL10n.t('frut.origen_agua')),
      campoTexto(notas, SoleraL10n.t('frut.notas')),
    ],
    guardar: () async {
      final metros = leerNumero(volumen.text);
      if (parcela == null || metros == null) return false;
      await BaseDatosSoleraFrutal.instancia.guardarRiego(Riego(
        parcelaId: parcela!,
        fechaMs: fecha.millisecondsSinceEpoch,
        volumenM3: metros,
        horas: leerNumero(horas.text),
        origenAgua: origen.text.trim(),
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  _liberar([volumen, horas, origen, notas]);
  if (guardado) avisarCambioDatos();
  return guardado;
}

/// Entrega de cosecha. Avisa si algún tratamiento de la parcela sigue
/// dentro de su plazo de seguridad en la fecha elegida.
Future<bool> mostrarAltaCosecha(BuildContext context,
    {int? parcelaId, int? campania}) async {
  final baseDatos = BaseDatosSoleraFrutal.instancia;
  final parcelas = await _parcelas();
  if (!context.mounted) return false;
  if (parcelas.isEmpty) {
    _avisarSinParcelas(context);
    return false;
  }
  final tratamientos = await baseDatos.listarTratamientos();
  if (!context.mounted) return false;
  var parcela = parcelaId ?? parcelas.first.id;
  var fecha = DateTime.now();
  final anyo =
      TextEditingController(text: '${campania ?? DateTime.now().year}');
  final kilos = TextEditingController();
  final rendimiento = TextEditingController();
  final calibre = TextEditingController();
  final humedad = TextEditingController();
  final destino = TextEditingController();
  final albaran = TextEditingController();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('frut.nueva_cosecha'),
    construir: (refrescar) {
      final abiertos = parcela == null
          ? const <Tratamiento>[]
          : tratamientosConPlazoAbierto(tratamientos,
              parcelaId: parcela!, fecha: fecha);
      return [
        selectorParcela(
            parcelas: parcelas,
            parcelaId: parcela,
            alCambiar: (valor) => refrescar(() => parcela = valor)),
        selectorFecha(context,
            fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
        if (abiertos.isNotEmpty)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(
              leading: const Icon(Icons.warning_amber_outlined),
              title: Text(SoleraL10n.t('frut.aviso_plazo_seguridad')),
              subtitle: Text(abiertos
                  .map((tratamiento) =>
                      '${nombreSustancia(tratamiento.sustanciaActivaId)} · ${formatearFecha(tratamiento.finPlazoSeguridad!.millisecondsSinceEpoch)}')
                  .join('\n')),
            ),
          ),
        campoNumero(anyo, SoleraL10n.t('frut.campania'), decimales: false),
        campoNumero(kilos, SoleraL10n.t('frut.kg_cascara')),
        campoNumero(rendimiento, SoleraL10n.t('frut.rendimiento_grano'),
            ayuda: SoleraL10n.t('frut.rendimiento_ayuda')),
        campoTexto(calibre, SoleraL10n.t('frut.calibre')),
        campoNumero(humedad, SoleraL10n.t('frut.humedad')),
        campoTexto(destino, SoleraL10n.t('frut.destino')),
        campoTexto(albaran, SoleraL10n.t('frut.numero_albaran')),
      ];
    },
    guardar: () async {
      final peso = leerNumero(kilos.text);
      final campaniaElegida = leerEntero(anyo.text);
      if (parcela == null || peso == null || campaniaElegida == null) {
        return false;
      }
      await baseDatos.guardarCosecha(Cosecha(
        parcelaId: parcela!,
        campania: campaniaElegida,
        fechaMs: fecha.millisecondsSinceEpoch,
        kgCascara: peso,
        rendimientoGranoPorcentaje: leerNumero(rendimiento.text),
        calibre: calibre.text.trim(),
        humedadPorcentaje: leerNumero(humedad.text),
        destino: destino.text.trim(),
        numeroAlbaran: albaran.text.trim(),
      ));
      return true;
    },
  );
  _liberar([anyo, kilos, rendimiento, calibre, humedad, destino, albaran]);
  if (guardado) avisarCambioDatos();
  return guardado;
}

/// Helada o pedrisco. Sin parcela = toda la explotación.
Future<bool> mostrarAltaHelada(BuildContext context, {int? parcelaId}) async {
  final parcelas = await _parcelas();
  if (!context.mounted) return false;
  int? parcela = parcelaId;
  var fecha = DateTime.now();
  var esPedrisco = false;
  var comunicada = false;
  final temperatura = TextEditingController();
  final estado = TextEditingController();
  final danio = TextEditingController();
  final notas = TextEditingController();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('frut.nueva_helada'),
    construir: (refrescar) => [
      separarCampoSolera(DropdownButtonFormField<int?>(
        initialValue: parcela,
        decoration: InputDecoration(labelText: SoleraL10n.t('frut.parcela')),
        items: [
          DropdownMenuItem<int?>(
              value: null, child: Text(SoleraL10n.t('frut.toda_explotacion'))),
          for (final candidata in parcelas)
            DropdownMenuItem<int?>(
                value: candidata.id, child: Text(candidata.nombre)),
        ],
        onChanged: (valor) => refrescar(() => parcela = valor),
      )),
      selectorFecha(context,
          fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('frut.es_pedrisco')),
        value: esPedrisco,
        onChanged: (valor) => refrescar(() => esPedrisco = valor),
      ),
      campoNumero(temperatura, SoleraL10n.t('frut.temperatura_minima')),
      campoTexto(estado, SoleraL10n.t('frut.estado_fenologico')),
      campoNumero(danio, SoleraL10n.t('frut.danio_estimado')),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('frut.comunicada_seguro')),
        value: comunicada,
        onChanged: (valor) => refrescar(() => comunicada = valor),
      ),
      campoTexto(notas, SoleraL10n.t('frut.notas')),
    ],
    guardar: () async {
      await BaseDatosSoleraFrutal.instancia.guardarHelada(Helada(
        parcelaId: parcela,
        fechaMs: fecha.millisecondsSinceEpoch,
        temperaturaMinimaC: leerNumero(temperatura.text),
        estadoFenologico: estado.text.trim(),
        danioEstimadoPorcentaje: leerNumero(danio.text),
        esPedrisco: esPedrisco,
        comunicadaAlSeguro: comunicada,
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  _liberar([temperatura, estado, danio, notas]);
  if (guardado) avisarCambioDatos();
  return guardado;
}

/// Muestreo de una plaga. [plagaPropuesta] la rellena la IA (bloque 7).
Future<bool> mostrarAltaObservacion(BuildContext context,
    {required int parcelaId,
    required String especieId,
    String plagaPropuesta = '',
    String notasPropuestas = ''}) async {
  var fecha = DateTime.now();
  var superaUmbral = false;
  final plaga = TextEditingController(
      text: plagaPropuesta.isEmpty ? '' : nombrePlaga(plagaPropuesta));
  final opcionesPlaga = opcionesPlagas(especieId);
  final recuento = TextEditingController();
  final notas = TextEditingController(text: notasPropuestas);
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('frut.nueva_observacion'),
    construir: (refrescar) => [
      selectorFecha(context,
          fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
      CampoCatalogo(
          controlador: plaga,
          opciones: opcionesPlaga,
          etiqueta: SoleraL10n.t('frut.plaga'),
          alElegir: (_) => refrescar(() {})),
      if (plagaPorId(idDesdeTexto(plaga.text, opcionesPlaga)) case final datos?
          when datos.umbral.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('${SoleraL10n.t('frut.umbral_guia')}: ${datos.umbral}',
              style: Theme.of(context).textTheme.bodySmall),
        ),
      campoNumero(recuento, SoleraL10n.t('frut.recuento'),
          ayuda: SoleraL10n.t('frut.recuento_ayuda')),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('frut.supera_umbral')),
        subtitle: Text(SoleraL10n.t('frut.umbral_lo_decides')),
        value: superaUmbral,
        onChanged: (valor) => refrescar(() => superaUmbral = valor),
      ),
      campoTexto(notas, SoleraL10n.t('frut.notas')),
    ],
    guardar: () async {
      if (plaga.text.trim().isEmpty) return false;
      await BaseDatosSoleraFrutal.instancia
          .guardarObservacionPlaga(ObservacionPlaga(
        parcelaId: parcelaId,
        fechaMs: fecha.millisecondsSinceEpoch,
        plagaId: idDesdeTexto(plaga.text, opcionesPlaga),
        recuento: leerNumero(recuento.text),
        superaUmbral: superaUmbral,
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  _liberar([plaga, recuento, notas]);
  if (guardado) avisarCambioDatos();
  return guardado;
}

Future<bool> mostrarAltaFila(BuildContext context,
    {required int parcelaId, required String especieId}) async {
  final opcionesVariedad = opcionesVariedades(especieId);
  var esPolinizadora = false;
  final etiqueta = TextEditingController();
  final variedad = TextEditingController();
  final arboles = TextEditingController();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('frut.nueva_fila'),
    construir: (refrescar) => [
      campoTexto(etiqueta, SoleraL10n.t('frut.etiqueta_fila'),
          ayuda: SoleraL10n.t('frut.etiqueta_fila_ayuda')),
      CampoCatalogo(
          controlador: variedad,
          opciones: opcionesVariedad,
          etiqueta: SoleraL10n.t('frut.variedad')),
      campoNumero(arboles, SoleraL10n.t('frut.numero_arboles'),
          decimales: false),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('frut.es_polinizadora')),
        value: esPolinizadora,
        onChanged: (valor) => refrescar(() => esPolinizadora = valor),
      ),
    ],
    guardar: () async {
      if (etiqueta.text.trim().isEmpty || variedad.text.trim().isEmpty) {
        return false;
      }
      await BaseDatosSoleraFrutal.instancia.guardarFilaArboles(FilaArboles(
        parcelaId: parcelaId,
        etiqueta: etiqueta.text.trim(),
        variedadId: idDesdeTexto(variedad.text, opcionesVariedad),
        numeroArboles: leerEntero(arboles.text) ?? 0,
        esPolinizadora: esPolinizadora,
      ));
      return true;
    },
  );
  _liberar([etiqueta, variedad, arboles]);
  if (guardado) avisarCambioDatos();
  return guardado;
}

Future<bool> mostrarAltaContratoPolinizacion(BuildContext context,
    {required int parcelaId}) async {
  var entrada = DateTime.now();
  DateTime? salida;
  final campania = TextEditingController(text: '${DateTime.now().year}');
  final apicultor = TextEditingController();
  final rega = TextEditingController();
  final colmenas = TextEditingController();
  final precio = TextEditingController();
  final notas = TextEditingController();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('frut.nuevo_contrato'),
    construir: (refrescar) => [
      campoNumero(campania, SoleraL10n.t('frut.campania'), decimales: false),
      campoTexto(apicultor, SoleraL10n.t('frut.apicultor')),
      campoTexto(rega, SoleraL10n.t('frut.codigo_rega'),
          ayuda: SoleraL10n.t('frut.codigo_rega_ayuda')),
      campoNumero(colmenas, SoleraL10n.t('frut.numero_colmenas'),
          decimales: false),
      campoNumero(precio, SoleraL10n.t('frut.precio_colmena')),
      selectorFecha(context,
          etiqueta: SoleraL10n.t('frut.fecha_entrada'),
          fecha: entrada,
          alCambiar: (valor) => refrescar(() => entrada = valor)),
      selectorFecha(context,
          etiqueta: SoleraL10n.t('frut.fecha_salida'),
          fecha: salida ?? entrada,
          alCambiar: (valor) => refrescar(() => salida = valor)),
      campoTexto(notas, SoleraL10n.t('frut.notas')),
    ],
    guardar: () async {
      final numero = leerEntero(colmenas.text);
      final anyo = leerEntero(campania.text);
      if (apicultor.text.trim().isEmpty || numero == null || anyo == null) {
        return false;
      }
      await BaseDatosSoleraFrutal.instancia
          .guardarContratoPolinizacion(ContratoPolinizacion(
        parcelaId: parcelaId,
        campania: anyo,
        apicultorNombre: apicultor.text.trim(),
        apicultorCodigoRega: rega.text.trim(),
        numeroColmenas: numero,
        fechaEntradaMs: entrada.millisecondsSinceEpoch,
        fechaSalidaMs: salida?.millisecondsSinceEpoch,
        precioCentimosPorColmena:
            ((leerNumero(precio.text) ?? 0) * 100).round(),
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  _liberar([campania, apicultor, rega, colmenas, precio, notas]);
  if (guardado) avisarCambioDatos();
  return guardado;
}
