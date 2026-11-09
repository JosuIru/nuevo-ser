// Altas y ediciones en hojas inferiores: parcela, bancal, cultivo, lote de
// semilla, insumo, siembra (con serie escalonada y aviso de rotación),
// cosecha y aplicación de insumo. Cada una devuelve true si guardó.

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../dominio/rotacion.dart';
import '../dominio/siembras_escalonadas.dart';
import '../estado/cambios_datos.dart';
import '../estado/datos_huerta.dart';
import '../modelos/bancal.dart';
import '../modelos/cosecha.dart';
import '../modelos/cultivo.dart';
import '../modelos/insumo.dart';
import '../modelos/lote_semilla.dart';
import '../modelos/parcela.dart';
import '../modelos/siembra.dart';
import '../modelos/tratamiento.dart';
import '../utiles/textos_huerta.dart';
import 'campo_catalogo.dart';
import 'hoja_formulario.dart';

BaseDatosSoleraHuerta get _bd => BaseDatosSoleraHuerta.instancia;

int _ms(DateTime fecha) => fecha.millisecondsSinceEpoch;
DateTime _fecha(int ms) => DateTime.fromMillisecondsSinceEpoch(ms);

/// Texto del aviso de rotación, o null si no hay.
String? textoAvisoRotacion(AvisoRotacion? aviso) => aviso == null
    ? null
    : SoleraL10n.tf('huer.aviso_rotacion', {
        'familia': nombreFamilia(aviso.familiaId),
        'n': aviso.aniosMinimos,
        'fecha': formatearFechaDia(aviso.fechaAnterior),
      });

Widget _tarjetaAviso(BuildContext context, String texto) => Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        leading: const Icon(Icons.warning_amber_outlined),
        title: Text(texto),
      ),
    );

// ─── Parcela ─────────────────────────────────────────────────────────

/// Paquete de la app, para identificarse ante OpenStreetMap.
const String paqueteAppHuerta = 'com.coleccionnuevoser.solera_huerta';

/// Si hay área y no punto, el punto es el centro del área (el mapa usa el
/// punto).
(double?, double?) puntoOCentroDelArea(
    double? latitud, double? longitud, List<LatLng> area) {
  if (latitud != null && longitud != null) return (latitud, longitud);
  final centro = centroide(area);
  return (centro?.latitude, centro?.longitude);
}

Future<bool> mostrarFormularioParcela(BuildContext context,
    {Parcela? parcela}) async {
  final nombre = TextEditingController(text: parcela?.nombre);
  final sigpac = TextEditingController(text: parcela?.codigoSigpac);
  final superficie = TextEditingController(
      text: numeroParaCampo(
          parcela?.superficieHa == 0 ? null : parcela?.superficieHa,
          decimales: 4));
  final notas = TextEditingController(text: parcela?.notas);
  var estado = parcela?.estadoEcologico ?? estadosEcologicos.first;
  var inicioConversion = parcela?.fechaInicioConversionMs == null
      ? DateTime.now()
      : _fecha(parcela!.fechaInicioConversionMs!);
  var regadio = parcela?.regadio ?? true;
  var riego = parcela?.sistemaRiego.isNotEmpty == true
      ? parcela!.sistemaRiego
      : sistemasRiego.first;
  var latitud = parcela?.latitud;
  var longitud = parcela?.longitud;
  var area = parcela?.vertices ?? const <LatLng>[];
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(
        parcela == null ? 'huer.nueva_parcela' : 'huer.editar_parcela'),
    controladores: [nombre, sigpac, superficie, notas],
    construir: (refrescar) => [
      campoTexto(nombre, SoleraL10n.t('huer.nombre')),
      campoTexto(sigpac, SoleraL10n.t('huer.codigo_sigpac'),
          ayuda: SoleraL10n.t('huer.codigo_sigpac_ayuda')),
      campoNumero(superficie, SoleraL10n.t('huer.superficie_ha')),
      desplegable<String>(
        etiqueta: SoleraL10n.t('huer.estado_ecologico'),
        valor: estado,
        opciones: estadosEcologicos,
        nombre: nombreEstadoEcologico,
        alCambiar: (valor) => refrescar(() => estado = valor ?? estado),
      ),
      if (estado == 'conversion')
        selectorFecha(context,
            fecha: inicioConversion,
            etiqueta: SoleraL10n.t('huer.inicio_conversion'),
            alCambiar: (valor) => refrescar(() => inicioConversion = valor)),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('huer.regadio')),
        value: regadio,
        onChanged: (valor) => refrescar(() => regadio = valor),
      ),
      if (regadio)
        desplegable<String>(
          etiqueta: SoleraL10n.t('huer.sistema_riego'),
          valor: riego,
          opciones: sistemasRiego,
          nombre: nombreSistemaRiego,
          alCambiar: (valor) => refrescar(() => riego = valor ?? riego),
        ),
      CampoPunto(
        latitud: latitud,
        longitud: longitud,
        centro: centroide(area),
        areasDeFondo: [(nombre: '', vertices: area)],
        paqueteApp: paqueteAppHuerta,
        alCambiar: (nuevaLatitud, nuevaLongitud) => refrescar(() {
          latitud = nuevaLatitud;
          longitud = nuevaLongitud;
        }),
      ),
      const SizedBox(height: 8),
      CampoArea(
        vertices: area,
        centro: latitud == null || longitud == null
            ? null
            : LatLng(latitud!, longitud!),
        paqueteApp: paqueteAppHuerta,
        alCambiar: (vertices) => refrescar(() => area = vertices),
        alUsarSuperficie: (hectareas) => refrescar(
            () => superficie.text = numeroParaCampo(hectareas, decimales: 4)),
      ),
      const SizedBox(height: 8),
      campoTexto(notas, SoleraL10n.t('huer.notas')),
    ],
    guardar: () async {
      if (nombre.text.trim().isEmpty) return false;
      final (latitudGuardada, longitudGuardada) =
          puntoOCentroDelArea(latitud, longitud, area);
      await _bd.guardarParcela(Parcela(
        id: parcela?.id,
        nombre: nombre.text.trim(),
        codigoSigpac: sigpac.text.trim(),
        superficieHa: leerNumero(superficie.text) ?? 0,
        estadoEcologico: estado,
        fechaInicioConversionMs:
            estado == 'conversion' ? _ms(inicioConversion) : null,
        regadio: regadio,
        sistemaRiego: riego,
        latitud: latitudGuardada,
        longitud: longitudGuardada,
        contorno: codificarContorno(area),
        notas: notas.text.trim(),
        fechaCreacionMs: parcela?.fechaCreacionMs ?? _ms(DateTime.now()),
      ));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
  return guardado;
}

// ─── Bancal ──────────────────────────────────────────────────────────

Future<bool> mostrarFormularioBancal(BuildContext context,
    {required int parcelaId, Bancal? bancal}) async {
  final nombre = TextEditingController(text: bancal?.nombre);
  final largo = TextEditingController(text: numeroParaCampo(bancal?.largoM));
  final ancho = TextEditingController(text: numeroParaCampo(bancal?.anchoM));
  final notas = TextEditingController(text: bancal?.notas);
  var invernadero = bancal?.invernadero ?? false;
  var activo = bancal?.activo ?? true;
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(
        bancal == null ? 'huer.nuevo_bancal' : 'huer.editar_bancal'),
    controladores: [nombre, largo, ancho, notas],
    construir: (refrescar) => [
      campoTexto(nombre, SoleraL10n.t('huer.nombre_bancal'),
          ayuda: SoleraL10n.t('huer.nombre_bancal_ayuda')),
      Row(children: [
        Expanded(child: campoNumero(largo, SoleraL10n.t('huer.largo_m'))),
        const SizedBox(width: 12),
        Expanded(child: campoNumero(ancho, SoleraL10n.t('huer.ancho_m'))),
      ]),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('huer.invernadero')),
        value: invernadero,
        onChanged: (valor) => refrescar(() => invernadero = valor),
      ),
      if (bancal != null)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(SoleraL10n.t('huer.bancal_activo')),
          value: activo,
          onChanged: (valor) => refrescar(() => activo = valor),
        ),
      campoTexto(notas, SoleraL10n.t('huer.notas')),
    ],
    guardar: () async {
      if (nombre.text.trim().isEmpty) return false;
      await _bd.guardarBancal(Bancal(
        id: bancal?.id,
        parcelaId: parcelaId,
        nombre: nombre.text.trim(),
        largoM: leerNumero(largo.text),
        anchoM: leerNumero(ancho.text),
        invernadero: invernadero,
        activo: activo,
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
  return guardado;
}

// ─── Cultivo ─────────────────────────────────────────────────────────

/// Devuelve el id del cultivo guardado, o null si se canceló.
Future<int?> mostrarFormularioCultivo(BuildContext context,
    {Cultivo? cultivo}) async {
  final especie =
      TextEditingController(text: nombreEspecie(cultivo?.especieId ?? ''));
  final variedad = TextEditingController(text: cultivo?.variedad);
  final notas = TextEditingController(text: cultivo?.notas);
  String? familia = cultivo?.familiaId.isNotEmpty == true
      ? normalizarFamilia(cultivo!.familiaId)
      : null;
  var variedadLocal = cultivo?.variedadLocal ?? false;
  int? guardadoId;
  final familias = opcionesFamilias();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(
        cultivo == null ? 'huer.nuevo_cultivo' : 'huer.editar_cultivo'),
    controladores: [especie, variedad, notas],
    construir: (refrescar) => [
      CampoCatalogo(
        controlador: especie,
        opciones: opcionesEspecies(),
        etiqueta: SoleraL10n.t('huer.especie'),
        ayuda: SoleraL10n.t('huer.especie_ayuda'),
        alElegir: (opcion) => refrescar(() {
          final deCatalogo = familiaDeEspecie(opcion.id);
          if (deCatalogo.isNotEmpty) familia = deCatalogo;
        }),
      ),
      desplegable<String>(
        key: ValueKey('familia-$familia'),
        etiqueta: SoleraL10n.t('huer.familia_botanica'),
        valor: familias.any((opcion) => opcion.id == familia) ? familia : null,
        opciones: [for (final opcion in familias) opcion.id],
        nombre: nombreFamilia,
        alCambiar: (valor) => refrescar(() => familia = valor),
      ),
      campoTexto(variedad, SoleraL10n.t('huer.variedad')),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('huer.variedad_local')),
        value: variedadLocal,
        onChanged: (valor) => refrescar(() => variedadLocal = valor),
      ),
      campoTexto(notas, SoleraL10n.t('huer.notas')),
    ],
    guardar: () async {
      final especieId = idDesdeTexto(especie.text, opcionesEspecies());
      if (especieId.isEmpty) return false;
      final familiaElegida = familia ?? familiaDeEspecie(especieId);
      guardadoId = await _bd.guardarCultivo(Cultivo(
        id: cultivo?.id,
        especieId: especieId,
        familiaId: familiaElegida,
        variedad: variedad.text.trim(),
        variedadLocal: variedadLocal,
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
  return guardado ? guardadoId : null;
}

// ─── Lote de semilla ─────────────────────────────────────────────────

Future<bool> mostrarFormularioLoteSemilla(BuildContext context,
    {LoteSemilla? lote, int? cosechaOrigenId, String? especieInicial}) async {
  final codigo = TextEditingController(text: lote?.codigo);
  final especie = TextEditingController(
      text: nombreEspecie(lote?.especieId ?? especieInicial ?? ''));
  final variedad = TextEditingController(text: lote?.variedad);
  final proveedor = TextEditingController(text: lote?.proveedor);
  final anyo = TextEditingController(
      text: (lote?.anyoObtencion ?? DateTime.now().year).toString());
  final cantidad = TextEditingController(text: lote?.cantidad);
  final germinacion =
      TextEditingController(text: numeroParaCampo(lote?.germinacionPorcentaje));
  final autorizacion = TextEditingController(text: lote?.numeroAutorizacion);
  final notas = TextEditingController(text: lote?.notas);
  var origen =
      lote?.origen ?? (cosechaOrigenId != null ? 'propia' : 'ecologica');
  var fecha = lote == null ? DateTime.now() : _fecha(lote.fechaMs);
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(
        lote == null ? 'huer.nuevo_lote_semilla' : 'huer.editar_lote_semilla'),
    controladores: [
      codigo,
      especie,
      variedad,
      proveedor,
      anyo,
      cantidad,
      germinacion,
      autorizacion,
      notas
    ],
    construir: (refrescar) => [
      campoTexto(codigo, SoleraL10n.t('huer.codigo_lote')),
      CampoCatalogo(
        controlador: especie,
        opciones: opcionesEspecies(),
        etiqueta: SoleraL10n.t('huer.especie'),
      ),
      campoTexto(variedad, SoleraL10n.t('huer.variedad')),
      desplegable<String>(
        etiqueta: SoleraL10n.t('huer.origen_semilla'),
        valor: origen,
        opciones: origenesSemilla,
        nombre: nombreOrigenSemilla,
        alCambiar: (valor) => refrescar(() => origen = valor ?? origen),
      ),
      if (origen == 'no_ecologica_autorizada')
        campoTexto(autorizacion, SoleraL10n.t('huer.numero_autorizacion'),
            ayuda: SoleraL10n.t('huer.numero_autorizacion_ayuda')),
      campoTexto(proveedor, SoleraL10n.t('huer.proveedor_semilla')),
      Row(children: [
        Expanded(
            child: campoNumero(anyo, SoleraL10n.t('huer.anyo_obtencion'),
                decimales: false)),
        const SizedBox(width: 12),
        Expanded(
            child: campoNumero(germinacion, SoleraL10n.t('huer.germinacion'))),
      ]),
      campoTexto(cantidad, SoleraL10n.t('huer.cantidad_semilla')),
      selectorFecha(context,
          fecha: fecha,
          etiqueta: SoleraL10n.t('huer.fecha_entrada'),
          alCambiar: (valor) => refrescar(() => fecha = valor)),
      campoTexto(notas, SoleraL10n.t('huer.notas')),
    ],
    guardar: () async {
      final especieId = idDesdeTexto(especie.text, opcionesEspecies());
      if (codigo.text.trim().isEmpty || especieId.isEmpty) return false;
      await _bd.guardarLoteSemilla(LoteSemilla(
        id: lote?.id,
        codigo: codigo.text.trim(),
        especieId: especieId,
        variedad: variedad.text.trim(),
        origen: origen,
        proveedor: proveedor.text.trim(),
        anyoObtencion: leerEntero(anyo.text),
        cantidad: cantidad.text.trim(),
        germinacionPorcentaje: leerNumero(germinacion.text),
        numeroAutorizacion:
            origen == 'no_ecologica_autorizada' ? autorizacion.text.trim() : '',
        cosechaOrigenId: lote?.cosechaOrigenId ?? cosechaOrigenId,
        fechaMs: _ms(fecha),
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
  return guardado;
}

// ─── Insumo ──────────────────────────────────────────────────────────

Future<bool> mostrarFormularioInsumo(BuildContext context,
    {Insumo? insumo}) async {
  final nombre = TextEditingController(text: insumo?.nombre);
  final categoria = TextEditingController(
      text: nombreCategoriaInsumo(insumo?.categoriaEcologicaId ?? ''));
  final justificante =
      TextEditingController(text: insumo?.justificantePermitido);
  final registro = TextEditingController(text: insumo?.numeroRegistro);
  final proveedor = TextEditingController(text: insumo?.proveedor);
  final notas = TextEditingController(text: insumo?.notas);
  var tipo = insumo?.tipo ?? tiposInsumo.first;
  var permitido = insumo?.permitidoEcologico ?? false;
  String tipoCatalogo() =>
      tipo == 'fitosanitario' ? 'fitosanitario' : 'fertilizante';
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(
        insumo == null ? 'huer.nuevo_insumo' : 'huer.editar_insumo'),
    controladores: [
      nombre,
      categoria,
      justificante,
      registro,
      proveedor,
      notas
    ],
    construir: (refrescar) => [
      campoTexto(nombre, SoleraL10n.t('huer.nombre_insumo'),
          ayuda: SoleraL10n.t('huer.nombre_insumo_ayuda')),
      desplegable<String>(
        etiqueta: SoleraL10n.t('huer.tipo_insumo'),
        valor: tipo,
        opciones: tiposInsumo,
        nombre: nombreTipoInsumo,
        alCambiar: (valor) => refrescar(() => tipo = valor ?? tipo),
      ),
      CampoCatalogo(
        key: ValueKey('categoria-${tipoCatalogo()}'),
        controlador: categoria,
        opciones: opcionesCategoriasInsumo(tipo: tipoCatalogo()),
        etiqueta: SoleraL10n.t('huer.categoria_anexo'),
        ayuda: SoleraL10n.t('huer.categoria_anexo_ayuda'),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('huer.permitido_ecologico')),
        subtitle: Text(SoleraL10n.t('huer.permitido_ecologico_ayuda')),
        value: permitido,
        onChanged: (valor) => refrescar(() => permitido = valor),
      ),
      if (permitido)
        campoTexto(justificante, SoleraL10n.t('huer.justificante'),
            ayuda: SoleraL10n.t('huer.justificante_ayuda')),
      campoTexto(registro, SoleraL10n.t('huer.numero_registro')),
      campoTexto(proveedor, SoleraL10n.t('huer.proveedor')),
      campoTexto(notas, SoleraL10n.t('huer.notas')),
    ],
    guardar: () async {
      if (nombre.text.trim().isEmpty) return false;
      await _bd.guardarInsumo(Insumo(
        id: insumo?.id,
        nombre: nombre.text.trim(),
        tipo: tipo,
        categoriaEcologicaId: idDesdeTexto(
            categoria.text, opcionesCategoriasInsumo(tipo: tipoCatalogo())),
        permitidoEcologico: permitido,
        justificantePermitido: permitido ? justificante.text.trim() : '',
        numeroRegistro: registro.text.trim(),
        proveedor: proveedor.text.trim(),
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
  return guardado;
}

// ─── Siembra ─────────────────────────────────────────────────────────

/// Alta o edición de una siembra o plantación. En el alta se puede pedir
/// una serie escalonada (N siembras cada X días). Muestra el aviso de
/// rotación según el bancal, el cultivo y la fecha elegidos.
Future<bool> mostrarFormularioSiembra(
  BuildContext context, {
  required DatosHuerta datos,
  Siembra? siembra,
  int? bancalId,
}) async {
  final bancales = datos.bancalesActivos;
  if (bancales.isEmpty || datos.cultivos.isEmpty) {
    avisar(context, SoleraL10n.t('huer.falta_bancal_o_cultivo'));
    return false;
  }
  final cantidad =
      TextEditingController(text: numeroParaCampo(siembra?.cantidad));
  final kilos =
      TextEditingController(text: numeroParaCampo(siembra?.kgPrevistos));
  final numeroSerie = TextEditingController(text: '1');
  final intervalo = TextEditingController(text: '14');
  final notas = TextEditingController(text: siembra?.notas);
  var bancal = siembra?.bancalId ?? bancalId ?? bancales.first.id!;
  var cultivo = siembra?.cultivoId ?? datos.cultivos.first.id!;
  var tipo = siembra?.tipo ?? tiposSiembra.first;
  var unidad = siembra?.unidad ?? unidadesSiembra.first;
  int? lote = siembra?.loteSemillaId;
  var fecha = siembra == null
      ? DateTime.now()
      : _fecha(siembra.fechaRealMs ?? siembra.fechaPrevistaMs);
  var hecha = siembra?.realizada ?? false;
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(
        siembra == null ? 'huer.nueva_siembra' : 'huer.editar_siembra'),
    controladores: [cantidad, kilos, numeroSerie, intervalo, notas],
    construir: (refrescar) {
      final aviso = textoAvisoRotacion(datos.avisoRotacion(
          bancalId: bancal,
          cultivoId: cultivo,
          fecha: fecha,
          excluirSiembraId: siembra?.id));
      final cultivoElegido = datos.cultivo(cultivo);
      final sinRegla = cultivoElegido != null &&
          !aniosMinimosPorFamilia()
              .containsKey(normalizarFamilia(cultivoElegido.familiaId));
      return [
        desplegable<int>(
          etiqueta: SoleraL10n.t('huer.bancal'),
          valor: bancal,
          opciones: [for (final opcion in bancales) opcion.id!],
          nombre: datos.nombreDeBancal,
          alCambiar: (valor) => refrescar(() => bancal = valor ?? bancal),
        ),
        desplegable<int>(
          etiqueta: SoleraL10n.t('huer.cultivo'),
          valor: cultivo,
          opciones: [for (final opcion in datos.cultivos) opcion.id!],
          nombre: datos.nombreDeCultivo,
          alCambiar: (valor) => refrescar(() => cultivo = valor ?? cultivo),
        ),
        if (aviso != null) _tarjetaAviso(context, aviso),
        if (sinRegla)
          Text(SoleraL10n.t('huer.rotacion_sin_dato'),
              style: Theme.of(context).textTheme.bodySmall),
        desplegable<String>(
          etiqueta: SoleraL10n.t('huer.tipo_siembra'),
          valor: tipo,
          opciones: tiposSiembra,
          nombre: nombreTipoSiembra,
          alCambiar: (valor) => refrescar(() => tipo = valor ?? tipo),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(SoleraL10n.t('huer.siembra_hecha')),
          subtitle: Text(SoleraL10n.t('huer.siembra_hecha_ayuda')),
          value: hecha,
          onChanged: (valor) => refrescar(() => hecha = valor),
        ),
        selectorFecha(context,
            fecha: fecha,
            etiqueta: SoleraL10n.t(
                hecha ? 'huer.fecha_siembra' : 'huer.fecha_prevista'),
            alCambiar: (valor) => refrescar(() => fecha = valor)),
        desplegable<int?>(
          etiqueta: SoleraL10n.t('huer.lote_semilla'),
          valor: lote,
          opciones: [null, for (final opcion in datos.lotes) opcion.id],
          nombre: (id) => id == null
              ? SoleraL10n.t('huer.sin_lote')
              : '${datos.lote(id)!.codigo} · ${nombreEspecie(datos.lote(id)!.especieId)}',
          alCambiar: (valor) => refrescar(() => lote = valor),
        ),
        Row(children: [
          Expanded(child: campoNumero(cantidad, SoleraL10n.t('huer.cantidad'))),
          const SizedBox(width: 12),
          Expanded(
            child: desplegable<String>(
              etiqueta: SoleraL10n.t('huer.unidad'),
              valor: unidad,
              opciones: unidadesSiembra,
              nombre: nombreUnidadSiembra,
              alCambiar: (valor) => refrescar(() => unidad = valor ?? unidad),
            ),
          ),
        ]),
        campoNumero(kilos, SoleraL10n.t('huer.kg_previstos'),
            ayuda: SoleraL10n.t('huer.kg_previstos_ayuda')),
        if (siembra == null && !hecha)
          Row(children: [
            Expanded(
                child: campoNumero(
                    numeroSerie, SoleraL10n.t('huer.numero_siembras'),
                    decimales: false)),
            const SizedBox(width: 12),
            Expanded(
                child: campoNumero(intervalo, SoleraL10n.t('huer.cada_dias'),
                    decimales: false)),
          ]),
        campoTexto(notas, SoleraL10n.t('huer.notas')),
      ];
    },
    guardar: () async {
      final base = Siembra(
        id: siembra?.id,
        bancalId: bancal,
        cultivoId: cultivo,
        tipo: tipo,
        fechaPrevistaMs: siembra?.fechaPrevistaMs ?? _ms(fecha),
        fechaRealMs: hecha ? _ms(fecha) : null,
        loteSemillaId: lote,
        cantidad: leerNumero(cantidad.text),
        unidad: unidad,
        superficieM2: siembra?.superficieM2,
        inicioCosechaPrevistaMs: siembra?.inicioCosechaPrevistaMs,
        kgPrevistos: leerNumero(kilos.text),
        fechaLevantadaMs: siembra?.fechaLevantadaMs,
        serieEscalonada: siembra?.serieEscalonada ?? '',
        notas: notas.text.trim(),
      );
      final numero = (leerEntero(numeroSerie.text) ?? 1).clamp(1, 52);
      if (siembra == null && !hecha && numero > 1) {
        await _bd.guardarSiembras(planificarSerieEscalonada(
          plantilla: Siembra(
            bancalId: base.bancalId,
            cultivoId: base.cultivoId,
            tipo: base.tipo,
            fechaPrevistaMs: _ms(fecha),
            loteSemillaId: base.loteSemillaId,
            cantidad: base.cantidad,
            unidad: base.unidad,
            kgPrevistos: base.kgPrevistos,
            notas: base.notas,
          ),
          numero: numero,
          intervaloDias: (leerEntero(intervalo.text) ?? 14).clamp(1, 365),
          serie: 'serie-${DateTime.now().millisecondsSinceEpoch}',
        ));
      } else {
        await _bd.guardarSiembra(siembra != null && !hecha
            ? Siembra.fromMap(base.toMap()
              ..['fecha_prevista_ms'] = _ms(fecha)
              ..['fecha_real_ms'] = null)
            : base);
      }
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
  return guardado;
}

// ─── Cosecha ─────────────────────────────────────────────────────────

Future<bool> mostrarFormularioCosecha(
  BuildContext context, {
  required DatosHuerta datos,
  Cosecha? cosecha,
  Siembra? siembra,
}) async {
  final bancales = datos.bancales;
  if (bancales.isEmpty || datos.cultivos.isEmpty) {
    avisar(context, SoleraL10n.t('huer.falta_bancal_o_cultivo'));
    return false;
  }
  final kilos = TextEditingController(
      text: numeroParaCampo(cosecha?.kg == 0 ? null : cosecha?.kg));
  final unidades =
      TextEditingController(text: cosecha?.unidades?.toString() ?? '');
  final lote = TextEditingController(text: cosecha?.loteCosecha);
  final notas = TextEditingController(text: cosecha?.notas);
  var bancal = cosecha?.bancalId ?? siembra?.bancalId ?? bancales.first.id!;
  var cultivo =
      cosecha?.cultivoId ?? siembra?.cultivoId ?? datos.cultivos.first.id!;
  var destino = cosecha?.destino ?? destinosCosecha.first;
  var fecha = cosecha == null ? DateTime.now() : _fecha(cosecha.fechaMs);
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(
        cosecha == null ? 'huer.nueva_cosecha' : 'huer.editar_cosecha'),
    controladores: [kilos, unidades, lote, notas],
    construir: (refrescar) => [
      desplegable<int>(
        etiqueta: SoleraL10n.t('huer.bancal'),
        valor: bancal,
        opciones: [for (final opcion in bancales) opcion.id!],
        nombre: datos.nombreDeBancal,
        alCambiar: (valor) => refrescar(() => bancal = valor ?? bancal),
      ),
      desplegable<int>(
        etiqueta: SoleraL10n.t('huer.cultivo'),
        valor: cultivo,
        opciones: [for (final opcion in datos.cultivos) opcion.id!],
        nombre: datos.nombreDeCultivo,
        alCambiar: (valor) => refrescar(() => cultivo = valor ?? cultivo),
      ),
      selectorFecha(context,
          fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
      Row(children: [
        Expanded(child: campoNumero(kilos, SoleraL10n.t('huer.kg'))),
        const SizedBox(width: 12),
        Expanded(
            child: campoNumero(unidades, SoleraL10n.t('huer.piezas'),
                decimales: false)),
      ]),
      desplegable<String>(
        etiqueta: SoleraL10n.t('huer.destino'),
        valor: destino,
        opciones: destinosCosecha,
        nombre: nombreDestinoCosecha,
        alCambiar: (valor) => refrescar(() => destino = valor ?? destino),
      ),
      campoTexto(lote, SoleraL10n.t('huer.lote_cosecha')),
      campoTexto(notas, SoleraL10n.t('huer.notas')),
    ],
    guardar: () async {
      final kg = leerNumero(kilos.text) ?? 0;
      final piezas = leerEntero(unidades.text);
      if (kg <= 0 && (piezas == null || piezas <= 0)) return false;
      await _bd.guardarCosecha(Cosecha(
        id: cosecha?.id,
        bancalId: bancal,
        cultivoId: cultivo,
        siembraId: cosecha?.siembraId ?? siembra?.id,
        fechaMs: _ms(fecha),
        kg: kg,
        unidades: piezas,
        destino: destino,
        loteCosecha: lote.text.trim(),
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
  return guardado;
}

// ─── Aplicación de insumo ────────────────────────────────────────────

Future<bool> mostrarFormularioTratamiento(
  BuildContext context, {
  required DatosHuerta datos,
  Tratamiento? tratamiento,
  int? parcelaId,
  String? problemaInicial,
}) async {
  if (datos.parcelas.isEmpty || datos.insumos.isEmpty) {
    avisar(context, SoleraL10n.t('huer.falta_parcela_o_insumo'));
    return false;
  }
  final problema = TextEditingController(
      text: nombrePlaga(tratamiento?.problema ?? problemaInicial ?? ''));
  final sustancia = TextEditingController(text: tratamiento?.sustanciaActivaId);
  final superficie = TextEditingController(
      text: numeroParaCampo(tratamiento?.superficieTratadaM2));
  final dosis = TextEditingController(text: tratamiento?.dosisAplicada);
  final total = TextEditingController(text: tratamiento?.cantidadTotal);
  final plazo = TextEditingController(
      text: tratamiento?.plazoSeguridadDias?.toString() ?? '');
  final aplicador = TextEditingController(text: tratamiento?.aplicadorNombre);
  final carnet = TextEditingController(text: tratamiento?.carnetAplicador);
  final equipo = TextEditingController(text: tratamiento?.equipoAplicacion);
  final observaciones = TextEditingController(text: tratamiento?.observaciones);
  var parcela = tratamiento?.parcelaId ?? parcelaId ?? datos.parcelas.first.id!;
  int? bancal = tratamiento?.bancalId;
  var insumo = tratamiento?.insumoId ?? datos.insumos.first.id!;
  var eficacia = tratamiento?.eficacia ?? '';
  var fecha =
      tratamiento == null ? DateTime.now() : _fecha(tratamiento.fechaMs);
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(tratamiento == null
        ? 'huer.nueva_aplicacion'
        : 'huer.editar_aplicacion'),
    controladores: [
      problema,
      sustancia,
      superficie,
      dosis,
      total,
      plazo,
      aplicador,
      carnet,
      equipo,
      observaciones
    ],
    construir: (refrescar) {
      final elegido = datos.insumo(insumo);
      final esFito = elegido?.esFitosanitario ?? false;
      final bancalesParcela = [
        for (final opcion in datos.bancales)
          if (opcion.parcelaId == parcela) opcion.id
      ];
      return [
        desplegable<int>(
          etiqueta: SoleraL10n.t('huer.insumo'),
          valor: insumo,
          opciones: [for (final opcion in datos.insumos) opcion.id!],
          nombre: (id) => datos.insumo(id)!.nombre,
          alCambiar: (valor) => refrescar(() => insumo = valor ?? insumo),
        ),
        if (elegido != null && !elegido.permitidoEcologico)
          _tarjetaAviso(context, SoleraL10n.t('huer.aviso_insumo_no_marcado')),
        desplegable<int>(
          etiqueta: SoleraL10n.t('huer.parcela'),
          valor: parcela,
          opciones: [for (final opcion in datos.parcelas) opcion.id!],
          nombre: (id) => datos.parcela(id)!.nombre,
          alCambiar: (valor) => refrescar(() {
            parcela = valor ?? parcela;
            bancal = null;
          }),
        ),
        desplegable<int?>(
          key: ValueKey('bancal-$parcela'),
          etiqueta: SoleraL10n.t('huer.bancal'),
          valor: bancalesParcela.contains(bancal) ? bancal : null,
          opciones: [null, ...bancalesParcela],
          nombre: (id) => id == null
              ? SoleraL10n.t('huer.toda_la_parcela')
              : datos.bancal(id)!.nombre,
          alCambiar: (valor) => refrescar(() => bancal = valor),
        ),
        selectorFecha(context,
            fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
        CampoCatalogo(
          controlador: problema,
          opciones: opcionesPlagas(),
          etiqueta: SoleraL10n.t(esFito ? 'huer.problema' : 'huer.motivo'),
        ),
        if (esFito)
          campoTexto(sustancia, SoleraL10n.t('huer.sustancia_activa')),
        campoNumero(superficie, SoleraL10n.t('huer.superficie_m2')),
        campoTexto(dosis, SoleraL10n.t('huer.dosis_aplicada'),
            ayuda: SoleraL10n.t('huer.dosis_ayuda')),
        campoTexto(total, SoleraL10n.t('huer.cantidad_total')),
        if (esFito) ...[
          campoNumero(plazo, SoleraL10n.t('huer.plazo_seguridad'),
              decimales: false, ayuda: SoleraL10n.t('huer.plazo_ayuda')),
          campoTexto(aplicador, SoleraL10n.t('huer.aplicador')),
          campoTexto(carnet, SoleraL10n.t('huer.carnet_aplicador')),
          campoTexto(equipo, SoleraL10n.t('huer.equipo_aplicacion')),
          desplegable<String>(
            etiqueta: SoleraL10n.t('huer.eficacia'),
            valor: eficacia,
            opciones: ['', ...eficaciasTratamiento],
            nombre: (id) => id.isEmpty
                ? SoleraL10n.t('huer.sin_valorar')
                : nombreEficacia(id),
            alCambiar: (valor) => refrescar(() => eficacia = valor ?? ''),
          ),
        ],
        campoTexto(observaciones, SoleraL10n.t('huer.observaciones')),
      ];
    },
    guardar: () async {
      await _bd.guardarTratamiento(Tratamiento(
        id: tratamiento?.id,
        parcelaId: parcela,
        bancalId: bancal,
        insumoId: insumo,
        fechaMs: _ms(fecha),
        superficieTratadaM2: leerNumero(superficie.text),
        problema: idDesdeTexto(problema.text, opcionesPlagas()),
        sustanciaActivaId: sustancia.text.trim(),
        dosisAplicada: dosis.text.trim(),
        cantidadTotal: total.text.trim(),
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
  if (guardado) avisarCambioDatos();
  return guardado;
}
