import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart' show exigeAvisoAutoridad;
import '../estado/cambios_datos.dart';
import '../modelos/bandeja.dart';
import '../modelos/inspeccion_plagas.dart';
import '../modelos/lote_material.dart';
import '../modelos/partida_planta.dart';
import '../modelos/salida.dart';
import '../modelos/siembra.dart';
import '../modelos/tratamiento.dart';
import '../modelos/zona_cultivo.dart';
import '../utiles/permisos_gps.dart';
import '../utiles/textos_vivero.dart';
import 'campos_especie.dart';
import 'hoja_formulario.dart';

// Altas y ediciones en hojas inferiores. Cada función devuelve true si se
// guardó y avisa a las pestañas abiertas.

BaseDatosSoleraVivero get _bd => BaseDatosSoleraVivero.instancia;

Future<bool> _terminar(Future<void> Function() accion) async {
  await accion();
  avisarCambioDatos();
  return true;
}

// ─── Zonas ─────────────────────────────────────────────────────────

Future<bool> mostrarFormularioZona(BuildContext context,
    {ZonaCultivo? existente}) async {
  var tipo = existente?.tipo ?? 'nave';
  final nombre = TextEditingController(text: existente?.nombre ?? '');
  final superficie = TextEditingController(
      text: existente?.superficieM2 == null
          ? ''
          : formatearNumero(existente!.superficieM2!, decimales: 0));
  final sigpac = TextEditingController(text: existente?.codigoSigpac ?? '');
  final notas = TextEditingController(text: existente?.notas ?? '');
  var latitud = existente?.latitud;
  var longitud = existente?.longitud;
  var localizando = false;
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(
        existente == null ? 'vive.nueva_zona' : 'vive.editar_zona'),
    construir: (refrescar) => [
      campoTexto(nombre, SoleraL10n.t('vive.nombre')),
      selectorOpcion<String>(
          etiqueta: SoleraL10n.t('vive.tipo_zona'),
          valor: tipo,
          opciones: tiposZonaCultivo,
          nombre: nombreTipoZona,
          alCambiar: (valor) => refrescar(() => tipo = valor ?? 'nave')),
      campoNumero(superficie, SoleraL10n.t('vive.superficie_m2')),
      if (tipo == 'exterior')
        campoTexto(sigpac, SoleraL10n.t('vive.codigo_sigpac')),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.my_location_outlined),
        title: Text(SoleraL10n.t('vive.ubicacion_gps')),
        subtitle: Text(latitud == null || longitud == null
            ? SoleraL10n.t('vive.sin_ubicacion')
            : '${latitud!.toStringAsFixed(5)}, ${longitud!.toStringAsFixed(5)}'),
        trailing: localizando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : TextButton(
                onPressed: () async {
                  refrescar(() => localizando = true);
                  final posicion = await leerPosicionActual(context);
                  refrescar(() {
                    localizando = false;
                    if (posicion != null) {
                      latitud = posicion.$1;
                      longitud = posicion.$2;
                    }
                  });
                },
                child: Text(SoleraL10n.t('vive.usar_mi_ubicacion'))),
      ),
      campoTexto(notas, SoleraL10n.t('vive.notas')),
    ],
    guardar: () async {
      if (nombre.text.trim().isEmpty) return false;
      return _terminar(() => _bd.guardarZona(ZonaCultivo(
            id: existente?.id,
            nombre: nombre.text.trim(),
            tipo: tipo,
            superficieM2: leerNumero(superficie.text),
            codigoSigpac: tipo == 'exterior' ? sigpac.text.trim() : '',
            latitud: latitud,
            longitud: longitud,
            notas: notas.text.trim(),
          )));
    },
  );
  liberarControladores([nombre, superficie, sigpac, notas]);
  return guardado;
}

// ─── Lotes de material ─────────────────────────────────────────────

Future<bool> mostrarFormularioLote(BuildContext context,
    {LoteMaterial? existente}) async {
  var tipo = existente?.tipo ?? 'semilla';
  var esPropio = existente?.esPropio ?? false;
  var categoriaForestal = existente?.categoriaForestal ?? '';
  var fecha = existente == null
      ? DateTime.now()
      : DateTime.fromMillisecondsSinceEpoch(existente.fechaEntradaMs);
  final codigo = TextEditingController(text: existente?.codigo ?? '');
  final especie = ControladoresEspecie.desde(
      especieId: existente?.especieId ?? '',
      nombreBotanico: existente?.nombreBotanico ?? '');
  final variedad = TextEditingController(text: existente?.variedad ?? '');
  final proveedor =
      TextEditingController(text: existente?.proveedorNombre ?? '');
  final ropvegProveedor =
      TextEditingController(text: existente?.proveedorCodigoRopveg ?? '');
  final pasaporte =
      TextEditingController(text: existente?.pasaporteRecibido ?? '');
  final pais = TextEditingController(text: existente?.paisOrigen ?? 'ES');
  final cantidad = TextEditingController(
      text: existente == null ? '' : formatearNumero(existente.cantidad));
  final unidad = TextEditingController(text: existente?.unidad ?? 'uds');
  final region =
      TextEditingController(text: existente?.regionProcedencia ?? '');
  final certificado =
      TextEditingController(text: existente?.certificadoPatron ?? '');
  final notas = TextEditingController(text: existente?.notas ?? '');
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(
        existente == null ? 'vive.nuevo_lote' : 'vive.editar_lote'),
    construir: (refrescar) => [
      campoTexto(codigo, SoleraL10n.t('vive.codigo_lote'),
          ayuda: SoleraL10n.t('vive.codigo_lote_ayuda')),
      selectorOpcion<String>(
          etiqueta: SoleraL10n.t('vive.tipo_material'),
          valor: tipo,
          opciones: tiposMaterial,
          nombre: nombreTipoMaterial,
          alCambiar: (valor) => refrescar(() => tipo = valor ?? 'semilla')),
      ...camposEspecie(especie, refrescar),
      campoTexto(variedad, SoleraL10n.t('vive.variedad')),
      selectorFecha(context,
          fecha: fecha,
          etiqueta: SoleraL10n.t('vive.fecha_entrada'),
          alCambiar: (valor) => refrescar(() => fecha = valor)),
      Row(children: [
        Expanded(child: campoNumero(cantidad, SoleraL10n.t('vive.cantidad'))),
        const SizedBox(width: 12),
        SizedBox(
            width: 96, child: campoTexto(unidad, SoleraL10n.t('vive.unidad'))),
      ]),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('vive.material_propio')),
        subtitle: Text(SoleraL10n.t('vive.material_propio_ayuda')),
        value: esPropio,
        onChanged: (valor) => refrescar(() => esPropio = valor),
      ),
      if (!esPropio) ...[
        campoTexto(proveedor, SoleraL10n.t('vive.proveedor')),
        campoTexto(ropvegProveedor, SoleraL10n.t('vive.proveedor_ropveg')),
        campoTexto(pasaporte, SoleraL10n.t('vive.pasaporte_recibido'),
            ayuda: SoleraL10n.t('vive.pasaporte_recibido_ayuda')),
      ],
      campoTexto(pais, SoleraL10n.t('vive.pais_origen'),
          ayuda: SoleraL10n.t('vive.pais_origen_ayuda')),
      selectorOpcion<String>(
          etiqueta: SoleraL10n.t('vive.categoria_forestal'),
          valor: categoriaForestal,
          opciones: ['', ...categoriasMaterialForestal],
          nombre: nombreCategoriaForestal,
          alCambiar: (valor) =>
              refrescar(() => categoriaForestal = valor ?? '')),
      if (categoriaForestal.isNotEmpty) ...[
        if (categoriaForestal == 'identificado' ||
            categoriaForestal == 'seleccionado')
          campoTexto(region, SoleraL10n.t('vive.region_procedencia'),
              ayuda: SoleraL10n.t('vive.region_procedencia_ayuda')),
        campoTexto(certificado, SoleraL10n.t('vive.certificado_patron')),
      ],
      campoTexto(notas, SoleraL10n.t('vive.notas')),
    ],
    guardar: () async {
      final especieElegida = especie.leer();
      if (codigo.text.trim().isEmpty || especieElegida.especieId.isEmpty) {
        return false;
      }
      try {
        return await _terminar(() => _bd.guardarLoteMaterial(LoteMaterial(
              id: existente?.id,
              codigo: codigo.text.trim(),
              tipo: tipo,
              especieId: especieElegida.especieId,
              nombreBotanico: especieElegida.nombreBotanico,
              variedad: variedad.text.trim(),
              esPropio: esPropio,
              proveedorNombre: esPropio ? '' : proveedor.text.trim(),
              proveedorCodigoRopveg:
                  esPropio ? '' : ropvegProveedor.text.trim(),
              pasaporteRecibido: esPropio ? '' : pasaporte.text.trim(),
              paisOrigen: pais.text.trim().toUpperCase(),
              fechaEntradaMs: fecha.millisecondsSinceEpoch,
              cantidad: leerNumero(cantidad.text) ?? 0,
              unidad: unidad.text.trim(),
              categoriaForestal: categoriaForestal,
              regionProcedencia: region.text.trim(),
              certificadoPatron: certificado.text.trim(),
              notas: notas.text.trim(),
            )));
      } catch (_) {
        if (context.mounted) {
          avisar(context, SoleraL10n.t('vive.codigo_repetido'));
        }
        return false;
      }
    },
  );
  liberarControladores([
    codigo,
    variedad,
    proveedor,
    ropvegProveedor,
    pasaporte,
    pais,
    cantidad,
    unidad,
    region,
    certificado,
    notas,
  ]);
  especie.liberar();
  return guardado;
}

// ─── Bandejas ──────────────────────────────────────────────────────

Future<bool> mostrarFormularioBandeja(BuildContext context,
    {Bandeja? existente, String? codigoInicial}) async {
  final zonas = await _bd.listarZonas();
  final bandejas = await _bd.listarBandejas();
  if (!context.mounted) return false;
  var formato = existente?.formato ?? 'alveolo';
  var zonaId = existente?.zonaId ?? (zonas.isEmpty ? null : zonas.first.id);
  var activa = existente?.activa ?? true;
  final codigo = TextEditingController(
      text: existente?.codigoQr ??
          codigoInicial ??
          siguienteCodigoBandeja(bandejas.map((b) => b.codigoQr)));
  final alveolos = TextEditingController(
      text: existente == null || existente.numeroAlveolos == 0
          ? ''
          : '${existente.numeroAlveolos}');
  final ubicacion = TextEditingController(text: existente?.ubicacion ?? '');
  final notas = TextEditingController(text: existente?.notas ?? '');
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(
        existente == null ? 'vive.nueva_bandeja' : 'vive.editar_bandeja'),
    construir: (refrescar) => [
      campoTexto(codigo, SoleraL10n.t('vive.codigo_qr'),
          ayuda: SoleraL10n.t('vive.codigo_qr_ayuda')),
      selectorOpcion<String>(
          etiqueta: SoleraL10n.t('vive.formato'),
          valor: formato,
          opciones: formatosCultivo,
          nombre: nombreFormato,
          alCambiar: (valor) => refrescar(() => formato = valor ?? 'alveolo')),
      campoNumero(alveolos, SoleraL10n.t('vive.numero_alveolos'),
          decimales: false),
      if (zonas.isNotEmpty)
        selectorOpcion<int?>(
            etiqueta: SoleraL10n.t('vive.zona'),
            valor: zonaId,
            opciones: [null, ...zonas.map((zona) => zona.id)],
            nombre: (id) => id == null
                ? SoleraL10n.t('vive.sin_zona')
                : zonas.firstWhere((zona) => zona.id == id).nombre,
            alCambiar: (valor) => refrescar(() => zonaId = valor)),
      campoTexto(ubicacion, SoleraL10n.t('vive.ubicacion'),
          ayuda: SoleraL10n.t('vive.ubicacion_ayuda')),
      if (existente != null)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(SoleraL10n.t('vive.bandeja_activa')),
          value: activa,
          onChanged: (valor) => refrescar(() => activa = valor),
        ),
      campoTexto(notas, SoleraL10n.t('vive.notas')),
    ],
    guardar: () async {
      if (codigo.text.trim().isEmpty) return false;
      try {
        return await _terminar(() => _bd.guardarBandeja(Bandeja(
              id: existente?.id,
              codigoQr: codigo.text.trim(),
              formato: formato,
              numeroAlveolos: leerEntero(alveolos.text) ?? 0,
              zonaId: zonaId,
              ubicacion: ubicacion.text.trim(),
              activa: activa,
              notas: notas.text.trim(),
            )));
      } catch (_) {
        if (context.mounted) {
          avisar(context, SoleraL10n.t('vive.codigo_repetido'));
        }
        return false;
      }
    },
  );
  liberarControladores([codigo, alveolos, ubicacion, notas]);
  return guardado;
}

// ─── Siembra (crea la partida) ─────────────────────────────────────

/// Siembra, estaquillado o plantación de un lote en una bandeja. Crea la
/// partida de planta a la vez, con el código del año.
Future<bool> mostrarFormularioSiembra(BuildContext context,
    {int? bandejaId, int? loteId}) async {
  final lotes = await _bd.listarLotesMaterial();
  final bandejas = await _bd.listarBandejas(soloActivas: true);
  final partidas = await _bd.listarPartidas();
  if (!context.mounted) return false;
  if (lotes.isEmpty || bandejas.isEmpty) {
    avisar(context, SoleraL10n.t('vive.primero_lote_y_bandeja'));
    return false;
  }
  var lote = loteId ?? lotes.first.id;
  var bandeja = bandejaId ?? bandejas.first.id;
  var metodo = 'siembra';
  var fecha = DateTime.now();
  final alveolos = TextEditingController();
  final porAlveolo = TextEditingController(text: '1');
  final usada = TextEditingController();
  final plantas = TextEditingController();
  final notas = TextEditingController();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('vive.nueva_siembra'),
    construir: (refrescar) => [
      selectorOpcion<int?>(
          etiqueta: SoleraL10n.t('vive.lote'),
          valor: lote,
          opciones: lotes.map((l) => l.id).toList(),
          nombre: (id) {
            final elegido = lotes.firstWhere((l) => l.id == id);
            return '${elegido.codigo} · ${nombreEspecieVisible(elegido.especieId)}';
          },
          alCambiar: (valor) => refrescar(() => lote = valor)),
      selectorOpcion<int?>(
          etiqueta: SoleraL10n.t('vive.bandeja'),
          valor: bandeja,
          opciones: bandejas.map((b) => b.id).toList(),
          nombre: (id) => bandejas.firstWhere((b) => b.id == id).codigoQr,
          alCambiar: (valor) => refrescar(() => bandeja = valor)),
      selectorOpcion<String>(
          etiqueta: SoleraL10n.t('vive.metodo'),
          valor: metodo,
          opciones: metodosSiembra,
          nombre: nombreMetodoSiembra,
          alCambiar: (valor) => refrescar(() => metodo = valor ?? 'siembra')),
      selectorFecha(context,
          fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
      campoNumero(alveolos, SoleraL10n.t('vive.alveolos_ocupados'),
          decimales: false),
      campoNumero(porAlveolo, SoleraL10n.t('vive.unidades_por_alveolo'),
          decimales: false),
      campoNumero(usada, SoleraL10n.t('vive.cantidad_material_usada')),
      campoNumero(plantas, SoleraL10n.t('vive.plantas_esperadas'),
          decimales: false,
          ayuda: SoleraL10n.t('vive.plantas_esperadas_ayuda')),
      campoTexto(notas, SoleraL10n.t('vive.notas')),
    ],
    guardar: () async {
      final elegido = lotes.firstWhere((l) => l.id == lote);
      final bandejaElegida = bandejas.firstWhere((b) => b.id == bandeja);
      final ocupados = leerEntero(alveolos.text) ?? 0;
      if (ocupados <= 0) return false;
      final siembra = Siembra(
        loteMaterialId: elegido.id!,
        bandejaId: bandejaElegida.id!,
        fechaMs: fecha.millisecondsSinceEpoch,
        metodo: metodo,
        alveolosOcupados: ocupados,
        unidadesPorAlveolo: leerEntero(porAlveolo.text) ?? 1,
        cantidadMaterialUsada: leerNumero(usada.text) ?? 0,
        notas: notas.text.trim(),
      );
      return _terminar(() => _bd.sembrar(
          siembra,
          PartidaPlanta(
            codigo: siguienteCodigoPartida(
                partidas.map((p) => p.codigo), fecha.year),
            especieId: elegido.especieId,
            nombreBotanico: elegido.nombreBotanico,
            variedad: elegido.variedad,
            formato: bandejaElegida.formato,
            cantidadInicial: leerEntero(plantas.text) ?? ocupados,
            bandejaId: bandejaElegida.id,
            zonaId: bandejaElegida.zonaId,
            paisOrigen: elegido.paisOrigen.isEmpty ? 'ES' : elegido.paisOrigen,
            fechaAltaMs: fecha.millisecondsSinceEpoch,
          )));
    },
  );
  liberarControladores([alveolos, porAlveolo, usada, plantas, notas]);
  return guardado;
}

// ─── Partidas: mermas, repicado y lista para venta ─────────────────

Future<bool> mostrarFormularioMerma(
    BuildContext context, PartidaPlanta partida) async {
  final perdidas = TextEditingController();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('vive.apuntar_merma'),
    construir: (_) => [
      Text(SoleraL10n.tf('vive.mermas_hasta_hoy', {'n': partida.mermas})),
      campoNumero(perdidas, SoleraL10n.t('vive.plantas_perdidas'),
          decimales: false),
    ],
    guardar: () async {
      final numero = leerEntero(perdidas.text) ?? 0;
      if (numero <= 0) return false;
      return _terminar(() => _bd
          .guardarPartida(partida.copiarCon(mermas: partida.mermas + numero)));
    },
  );
  liberarControladores([perdidas]);
  return guardado;
}

Future<bool> mostrarFormularioRepicado(
    BuildContext context, PartidaPlanta partida,
    {required int disponibles}) async {
  final bandejas = await _bd.listarBandejas(soloActivas: true);
  final partidas = await _bd.listarPartidas();
  if (!context.mounted) return false;
  var formato = 'maceta';
  int? bandeja;
  var fecha = DateTime.now();
  final cantidad = TextEditingController(text: '$disponibles');
  final notas = TextEditingController();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('vive.repicar'),
    construir: (refrescar) => [
      Text(SoleraL10n.tf('vive.disponibles_n', {'n': disponibles})),
      selectorFecha(context,
          fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
      campoNumero(cantidad, SoleraL10n.t('vive.plantas_repicadas'),
          decimales: false),
      selectorOpcion<String>(
          etiqueta: SoleraL10n.t('vive.formato_destino'),
          valor: formato,
          opciones: formatosCultivo,
          nombre: nombreFormato,
          alCambiar: (valor) => refrescar(() => formato = valor ?? 'maceta')),
      selectorOpcion<int?>(
          etiqueta: SoleraL10n.t('vive.bandeja_destino'),
          valor: bandeja,
          opciones: [null, ...bandejas.map((b) => b.id)],
          nombre: (id) => id == null
              ? SoleraL10n.t('vive.sin_bandeja')
              : bandejas.firstWhere((b) => b.id == id).codigoQr,
          alCambiar: (valor) => refrescar(() => bandeja = valor)),
      campoTexto(notas, SoleraL10n.t('vive.notas')),
    ],
    guardar: () async {
      final numero = leerEntero(cantidad.text) ?? 0;
      if (numero <= 0 || numero > disponibles) {
        if (context.mounted) {
          avisar(context, SoleraL10n.t('vive.cantidad_no_valida'));
        }
        return false;
      }
      final bandejaElegida =
          bandeja == null ? null : bandejas.firstWhere((b) => b.id == bandeja);
      return _terminar(() => _bd.repicar(
            partidaDestino: PartidaPlanta(
              codigo: siguienteCodigoPartida(
                  partidas.map((p) => p.codigo), fecha.year),
              especieId: partida.especieId,
              nombreBotanico: partida.nombreBotanico,
              variedad: partida.variedad,
              formato: formato,
              cantidadInicial: numero,
              bandejaId: bandejaElegida?.id,
              zonaId: bandejaElegida?.zonaId ?? partida.zonaId,
              paisOrigen: partida.paisOrigen,
              fechaAltaMs: fecha.millisecondsSinceEpoch,
            ),
            partidaOrigenId: partida.id!,
            fechaMs: fecha.millisecondsSinceEpoch,
            cantidad: numero,
            notas: notas.text.trim(),
          ));
    },
  );
  liberarControladores([cantidad, notas]);
  return guardado;
}

/// Corrige los datos de la partida que van al pasaporte (nombre botánico,
/// variedad, país de origen) y si está lista para venta.
Future<bool> mostrarFormularioPartida(
    BuildContext context, PartidaPlanta partida) async {
  var lista = partida.listaParaVenta;
  final especie = ControladoresEspecie.desde(
      especieId: partida.especieId, nombreBotanico: partida.nombreBotanico);
  final variedad = TextEditingController(text: partida.variedad);
  final pais = TextEditingController(text: partida.paisOrigen);
  final notas = TextEditingController(text: partida.notas);
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.tf('vive.editar_partida', {'codigo': partida.codigo}),
    construir: (refrescar) => [
      ...camposEspecie(especie, refrescar),
      campoTexto(variedad, SoleraL10n.t('vive.variedad')),
      campoTexto(pais, SoleraL10n.t('vive.pais_origen'),
          ayuda: SoleraL10n.t('vive.pais_origen_ayuda')),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('vive.lista_para_venta')),
        value: lista,
        onChanged: (valor) => refrescar(() => lista = valor),
      ),
      campoTexto(notas, SoleraL10n.t('vive.notas')),
    ],
    guardar: () async {
      final elegida = especie.leer();
      if (elegida.especieId.isEmpty) return false;
      return _terminar(() => _bd.guardarPartida(PartidaPlanta(
            id: partida.id,
            codigo: partida.codigo,
            especieId: elegida.especieId,
            nombreBotanico: elegida.nombreBotanico,
            variedad: variedad.text.trim(),
            formato: partida.formato,
            cantidadInicial: partida.cantidadInicial,
            mermas: partida.mermas,
            siembraId: partida.siembraId,
            partidaOrigenId: partida.partidaOrigenId,
            bandejaId: partida.bandejaId,
            zonaId: partida.zonaId,
            paisOrigen: pais.text.trim().toUpperCase(),
            fechaAltaMs: partida.fechaAltaMs,
            listaParaVenta: lista,
            notas: notas.text.trim(),
          )));
    },
  );
  liberarControladores([variedad, pais, notas]);
  especie.liberar();
  return guardado;
}

// ─── Salidas ───────────────────────────────────────────────────────

/// Venta, entrega o traslado. Las marcas de destino deciden si hace falta
/// pasaporte; la app lo dice con el motivo, la decisión es del operador.
Future<bool> mostrarFormularioSalida(BuildContext context,
    {required PartidaPlanta partida, required int disponibles}) async {
  var fecha = DateTime.now();
  var usuarioFinal = false;
  var distancia = false;
  var zonaProtegida = false;
  var trasladoPropio = false;
  final cantidad = TextEditingController();
  final cliente = TextEditingController();
  final nif = TextEditingController();
  final ropveg = TextEditingController();
  final trazabilidad = TextEditingController(text: partida.codigo);
  final importe = TextEditingController();
  final notas = TextEditingController();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.tf('vive.nueva_salida_de', {'codigo': partida.codigo}),
    construir: (refrescar) => [
      Text(SoleraL10n.tf('vive.disponibles_n', {'n': disponibles})),
      selectorFecha(context,
          fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
      campoNumero(cantidad, SoleraL10n.t('vive.cantidad'), decimales: false),
      campoTexto(cliente, SoleraL10n.t('vive.cliente')),
      campoTexto(nif, 'NIF'),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('vive.es_usuario_final')),
        subtitle: Text(SoleraL10n.t('vive.es_usuario_final_ayuda')),
        value: usuarioFinal,
        onChanged: (valor) => refrescar(() => usuarioFinal = valor),
      ),
      if (!usuarioFinal)
        campoTexto(ropveg, SoleraL10n.t('vive.cliente_ropveg')),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('vive.venta_a_distancia')),
        value: distancia,
        onChanged: (valor) => refrescar(() => distancia = valor),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('vive.destino_zona_protegida')),
        subtitle: Text(SoleraL10n.t('vive.destino_zona_protegida_ayuda')),
        value: zonaProtegida,
        onChanged: (valor) => refrescar(() => zonaProtegida = valor),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('vive.traslado_propio')),
        value: trasladoPropio,
        onChanged: (valor) => refrescar(() => trasladoPropio = valor),
      ),
      campoTexto(trazabilidad, SoleraL10n.t('vive.codigo_trazabilidad'),
          ayuda: SoleraL10n.t('vive.codigo_trazabilidad_ayuda')),
      campoNumero(importe, SoleraL10n.t('vive.importe_sin_iva')),
      campoTexto(notas, SoleraL10n.t('vive.notas')),
    ],
    guardar: () async {
      final numero = leerEntero(cantidad.text) ?? 0;
      if (numero <= 0 || numero > disponibles) {
        if (context.mounted) {
          avisar(context, SoleraL10n.t('vive.cantidad_no_valida'));
        }
        return false;
      }
      return _terminar(() => _bd.guardarSalida(Salida(
            partidaId: partida.id!,
            fechaMs: fecha.millisecondsSinceEpoch,
            cantidad: numero,
            clienteNombre: cliente.text.trim(),
            clienteNif: nif.text.trim(),
            clienteCodigoRopveg: usuarioFinal ? '' : ropveg.text.trim(),
            esUsuarioFinal: usuarioFinal,
            esVentaADistancia: distancia,
            destinoZonaProtegida: zonaProtegida,
            esTrasladoPropioMismaComunidad: trasladoPropio,
            codigoTrazabilidad: trazabilidad.text.trim(),
            importeCentimos: ((leerNumero(importe.text) ?? 0) * 100).round(),
            notas: notas.text.trim(),
          )));
    },
  );
  liberarControladores(
      [cantidad, cliente, nif, ropveg, trazabilidad, importe, notas]);
  return guardado;
}

// ─── Cuaderno: tratamientos e inspecciones ─────────────────────────

/// Tratamiento fitosanitario. Producto, registro y dosis se copian de la
/// etiqueta: la app no los propone.
Future<bool> mostrarFormularioTratamiento(BuildContext context,
    {int? partidaId}) async {
  final partidas = await _bd.listarPartidas();
  final zonas = await _bd.listarZonas();
  final vivero = await _bd.obtenerVivero();
  if (!context.mounted) return false;
  var partida = partidaId;
  int? zona = zonas.isEmpty ? null : zonas.first.id;
  var fecha = DateTime.now();
  var eficacia = '';
  final problema = TextEditingController();
  final sustancia = TextEditingController();
  final producto = TextEditingController();
  final registro = TextEditingController();
  final dosis = TextEditingController();
  final plazo = TextEditingController();
  final superficie = TextEditingController();
  final aplicador = TextEditingController(text: vivero.nombre);
  final carnet = TextEditingController();
  final equipo = TextEditingController();
  final observaciones = TextEditingController();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('vive.nuevo_tratamiento'),
    construir: (refrescar) => [
      selectorFecha(context,
          fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
      selectorOpcion<int?>(
          etiqueta: SoleraL10n.t('vive.partida'),
          valor: partida,
          opciones: [null, ...partidas.map((p) => p.id)],
          nombre: (id) => id == null
              ? SoleraL10n.t('vive.toda_la_zona')
              : etiquetaPartida(partidas.firstWhere((p) => p.id == id)),
          alCambiar: (valor) => refrescar(() => partida = valor)),
      if (zonas.isNotEmpty)
        selectorOpcion<int?>(
            etiqueta: SoleraL10n.t('vive.zona'),
            valor: zona,
            opciones: [null, ...zonas.map((z) => z.id)],
            nombre: (id) => id == null
                ? SoleraL10n.t('vive.sin_zona')
                : zonas.firstWhere((z) => z.id == id).nombre,
            alCambiar: (valor) => refrescar(() => zona = valor)),
      campoProblema(problema, partidas, partida),
      campoSustancia(sustancia, problema, partidas, partida, refrescar),
      campoTexto(producto, SoleraL10n.t('vive.nombre_producto'),
          ayuda: SoleraL10n.t('vive.copiar_de_etiqueta')),
      campoTexto(registro, SoleraL10n.t('vive.numero_registro')),
      campoTexto(dosis, SoleraL10n.t('vive.dosis_aplicada'),
          ayuda: SoleraL10n.t('vive.copiar_de_etiqueta')),
      campoNumero(plazo, SoleraL10n.t('vive.plazo_seguridad_dias'),
          decimales: false, ayuda: avisoPlazoSustancia(sustancia.text)),
      campoNumero(superficie, SoleraL10n.t('vive.superficie_m2')),
      campoTexto(aplicador, SoleraL10n.t('vive.aplicador')),
      campoTexto(carnet, SoleraL10n.t('vive.carnet_aplicador')),
      campoTexto(equipo, SoleraL10n.t('vive.equipo_aplicacion')),
      selectorOpcion<String>(
          etiqueta: SoleraL10n.t('vive.eficacia'),
          valor: eficacia,
          opciones: ['', ...eficaciasTratamiento],
          nombre: (id) => id.isEmpty ? '—' : nombreEficacia(id),
          alCambiar: (valor) => refrescar(() => eficacia = valor ?? '')),
      campoTexto(observaciones, SoleraL10n.t('vive.observaciones')),
    ],
    guardar: () async {
      if (sustancia.text.trim().isEmpty && producto.text.trim().isEmpty) {
        return false;
      }
      if (partida == null && zona == null) {
        if (context.mounted) {
          avisar(context, SoleraL10n.t('vive.elige_partida_o_zona'));
        }
        return false;
      }
      return _terminar(() => _bd.guardarTratamiento(Tratamiento(
            fechaMs: fecha.millisecondsSinceEpoch,
            partidaId: partida,
            zonaId: zona,
            superficieTratadaM2: leerNumero(superficie.text),
            problemaFitosanitario: idPlagaDesdeTexto(problema.text),
            sustanciaActivaId: idSustanciaDesdeTexto(sustancia.text),
            nombreProducto: producto.text.trim(),
            numeroRegistroProducto: registro.text.trim(),
            dosisAplicada: dosis.text.trim(),
            plazoSeguridadDias: leerEntero(plazo.text),
            aplicadorNombre: aplicador.text.trim(),
            carnetAplicador: carnet.text.trim(),
            equipoAplicacion: equipo.text.trim(),
            eficacia: eficacia,
            observaciones: observaciones.text.trim(),
          )));
    },
  );
  liberarControladores([
    problema,
    sustancia,
    producto,
    registro,
    dosis,
    plazo,
    superficie,
    aplicador,
    carnet,
    equipo,
    observaciones,
  ]);
  return guardado;
}

/// Inspección de plagas reguladas. Si hay sospecha o detección de una
/// cuarentenaria, la ley pide avisar de inmediato a la autoridad: la app
/// lo recuerda, no lo hace.
Future<bool> mostrarFormularioInspeccion(BuildContext context,
    {int? partidaId,
    String? plagaInicial,
    String resultadoInicial = 'no_detectada',
    String notasIniciales = ''}) async {
  final partidas = await _bd.listarPartidas();
  final zonas = await _bd.listarZonas();
  final vivero = await _bd.obtenerVivero();
  if (!context.mounted) return false;
  var partida = partidaId;
  int? zona = partidaId != null || zonas.isEmpty ? null : zonas.first.id;
  var fecha = DateTime.now();
  var tipo = 'autoinspeccion';
  var resultado = resultadoInicial;
  var muestra = false;
  var notificada = false;
  final plaga = TextEditingController(text: plagaInicial ?? '');
  final inspector = TextEditingController(
      text: vivero.personaContactoFitosanitaria.isEmpty
          ? vivero.nombre
          : vivero.personaContactoFitosanitaria);
  final notas = TextEditingController(text: notasIniciales);
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('vive.nueva_inspeccion'),
    construir: (refrescar) => [
      selectorFecha(context,
          fecha: fecha, alCambiar: (valor) => refrescar(() => fecha = valor)),
      selectorOpcion<int?>(
          etiqueta: SoleraL10n.t('vive.partida'),
          valor: partida,
          opciones: [null, ...partidas.map((p) => p.id)],
          nombre: (id) => id == null
              ? SoleraL10n.t('vive.toda_la_zona')
              : etiquetaPartida(partidas.firstWhere((p) => p.id == id)),
          alCambiar: (valor) => refrescar(() => partida = valor)),
      if (zonas.isNotEmpty)
        selectorOpcion<int?>(
            etiqueta: SoleraL10n.t('vive.zona'),
            valor: zona,
            opciones: [null, ...zonas.map((z) => z.id)],
            nombre: (id) => id == null
                ? SoleraL10n.t('vive.sin_zona')
                : zonas.firstWhere((z) => z.id == id).nombre,
            alCambiar: (valor) => refrescar(() => zona = valor)),
      campoPlagaRegulada(plaga, partidas, partida),
      selectorOpcion<String>(
          etiqueta: SoleraL10n.t('vive.tipo_inspeccion'),
          valor: tipo,
          opciones: tiposInspeccion,
          nombre: nombreTipoInspeccion,
          alCambiar: (valor) =>
              refrescar(() => tipo = valor ?? 'autoinspeccion')),
      campoTexto(inspector, SoleraL10n.t('vive.inspector')),
      selectorOpcion<String>(
          etiqueta: SoleraL10n.t('vive.resultado'),
          valor: resultado,
          opciones: resultadosInspeccion,
          nombre: nombreResultadoInspeccion,
          alCambiar: (valor) =>
              refrescar(() => resultado = valor ?? 'no_detectada')),
      if (resultado != 'no_detectada' &&
          exigeAvisoAutoridad(idPlagaDesdeTexto(plaga.text)))
        Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(SoleraL10n.t('vive.aviso_notificar_autoridad')),
          ),
        ),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('vive.muestra_tomada')),
        value: muestra,
        onChanged: (valor) => refrescar(() => muestra = valor ?? false),
      ),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('vive.notificada_autoridad')),
        value: notificada,
        onChanged: (valor) => refrescar(() => notificada = valor ?? false),
      ),
      campoTexto(notas, SoleraL10n.t('vive.notas')),
    ],
    guardar: () async {
      if (plaga.text.trim().isEmpty) return false;
      if (partida == null && zona == null) {
        if (context.mounted) {
          avisar(context, SoleraL10n.t('vive.elige_partida_o_zona'));
        }
        return false;
      }
      return _terminar(() => _bd.guardarInspeccion(InspeccionPlagas(
            fechaMs: fecha.millisecondsSinceEpoch,
            partidaId: partida,
            zonaId: zona,
            plagaId: idPlagaDesdeTexto(plaga.text),
            tipo: tipo,
            inspectorNombre: inspector.text.trim(),
            resultado: resultado,
            muestraTomada: muestra,
            notificadaAutoridad: notificada,
            notas: notas.text.trim(),
          )));
    },
  );
  liberarControladores([plaga, inspector, notas]);
  return guardado;
}

/// «P26-0001 · Tomate (120)».
String etiquetaPartida(PartidaPlanta partida) =>
    '${partida.codigo} · ${nombreEspecieVisible(partida.especieId)}'
    '${partida.variedad.isEmpty ? '' : ' ${partida.variedad}'}';
