import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, separarCampoSolera;

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_especies.dart';
import '../datos/catalogos_generados/catalogo_sustancias_activas.dart';
import '../dominio/busqueda_catalogos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/ganado.dart';
import '../modelos/ganado_ecologico.dart';
import '../modelos/pieza_pasto.dart';
import '../utiles/crotal.dart';
import '../utiles/textos_ganadera.dart';
import 'hoja_formulario.dart';
import 'pantalla_manejo.dart' show selectorFecha;

/// Desplegable de un código con su nombre visible.
Widget desplegableCodigo({
  required String etiqueta,
  required String valor,
  required List<String> opciones,
  required String Function(String) nombre,
  required void Function(String) alCambiar,
  bool conVacio = false,
}) =>
    separarCampoSolera(DropdownButtonFormField<String>(
      initialValue: valor,
      decoration: InputDecoration(labelText: etiqueta),
      items: [
        if (conVacio) const DropdownMenuItem(value: '', child: Text('—')),
        for (final opcion in opciones)
          DropdownMenuItem(value: opcion, child: Text(nombre(opcion))),
      ],
      onChanged: (nuevo) {
        if (nuevo != null) alCambiar(nuevo);
      },
    ));

/// Campo de texto con sugerencias de una lista (la persona puede escribir
/// otra cosa).
Widget campoConSugerencias(TextEditingController controlador, String etiqueta,
        Iterable<String> sugerencias) =>
    separarCampoSolera(Autocomplete<String>(
      initialValue: controlador.value,
      optionsBuilder: (texto) {
        final buscado = texto.text.trim().toLowerCase();
        if (buscado.isEmpty) return const [];
        return sugerencias
            .where((opcion) => opcion.toLowerCase().contains(buscado));
      },
      onSelected: (opcion) => controlador.text = opcion,
      fieldViewBuilder: (contexto, controladorCampo, foco, alEnviar) {
        controladorCampo
            .addListener(() => controlador.text = controladorCampo.text);
        return TextField(
          controller: controladorCampo,
          focusNode: foco,
          decoration: InputDecoration(labelText: etiqueta),
        );
      },
    ));

/// Alta o edición de un rebaño.
Future<void> mostrarEdicionLote(BuildContext context,
    [LoteGanado? existente]) async {
  final nombre = TextEditingController(text: existente?.nombre);
  final sinIdentificar = TextEditingController(
      text: existente == null ? '' : '${existente.cabezasSinIdentificar}');
  final notas = TextEditingController(text: existente?.notas);
  var especie = existente?.especie.isNotEmpty == true
      ? existente!.especie
      : especiesGanado.first;
  var ecologico = existente?.ecologico ?? false;
  var cicloCorto = existente?.cicloCorto ?? false;
  var cerrado = existente?.activo == false;
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(
        existente == null ? 'gana.nuevo_rebano' : 'gana.editar_rebano'),
    construir: (refrescar) => [
      campoTexto(nombre, SoleraL10n.t('gana.nombre')),
      desplegableCodigo(
          etiqueta: SoleraL10n.t('gana.especie'),
          valor: especie,
          opciones: especiesGanado,
          nombre: nombreEspecie,
          alCambiar: (valor) => refrescar(() => especie = valor)),
      campoNumero(sinIdentificar, SoleraL10n.t('gana.cabezas_sin_identificar'),
          decimales: false),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('gana.ecologico_o_conversion')),
        value: ecologico,
        onChanged: (valor) => refrescar(() => ecologico = valor),
      ),
      if (ecologico)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(SoleraL10n.t('gana.ciclo_corto')),
          value: cicloCorto,
          onChanged: (valor) => refrescar(() => cicloCorto = valor),
        ),
      if (existente != null)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(SoleraL10n.t('gana.rebano_cerrado')),
          value: cerrado,
          onChanged: (valor) => refrescar(() => cerrado = valor),
        ),
      campoTexto(notas, SoleraL10n.t('gana.notas')),
    ],
    guardar: () async {
      if (nombre.text.trim().isEmpty) return false;
      await BaseDatosSoleraGanadera.instancia.guardarLote(LoteGanado(
        id: existente?.id,
        nombre: nombre.text.trim(),
        especie: especie,
        cabezasSinIdentificar: leerEntero(sinIdentificar.text) ?? 0,
        estado: cerrado ? estadoLoteCerrado : estadoLoteActivo,
        notas: notas.text.trim(),
        fechaCreacionMs:
            existente?.fechaCreacionMs ?? DateTime.now().millisecondsSinceEpoch,
        ecologico: ecologico,
        cicloCorto: ecologico && cicloCorto,
      ));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
}

/// Alta o edición de un animal de un rebaño.
Future<void> mostrarEdicionAnimal(BuildContext context, LoteGanado lote,
    [Animal? existente]) async {
  final identificacion = TextEditingController(text: existente?.identificacion);
  final nombre = TextEditingController(text: existente?.nombre);
  final raza = TextEditingController(text: existente?.raza);
  final madre = TextEditingController(text: existente?.madre);
  final especieAnimal =
      existente?.especie.isNotEmpty == true ? existente!.especie : lote.especie;
  var dispositivo = existente?.dispositivo ??
      catalogoEspecies
          .where((especie) => especie.id == especieAnimal)
          .map((especie) => especie.dispositivoHabitual)
          .firstWhere((_) => true, orElse: () => 'crotal');
  var sexo = existente?.sexo ?? '';
  var estado = existente?.estado ?? estadoAnimalActivo;
  DateTime? nacimiento = existente?.fechaNacimientoMs == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(existente!.fechaNacimientoMs!);
  final razas = razasDeEspecie(especieAnimal);
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t(
        existente == null ? 'gana.nuevo_animal' : 'gana.editar_animal'),
    construir: (refrescar) => [
      campoTexto(identificacion, SoleraL10n.t('gana.identificacion')),
      desplegableCodigo(
          etiqueta: SoleraL10n.t('gana.dispositivo'),
          valor: dispositivo,
          opciones: dispositivosIdentificacion,
          nombre: nombreDispositivo,
          alCambiar: (valor) => refrescar(() => dispositivo = valor)),
      campoTexto(nombre, SoleraL10n.t('gana.nombre_o_apodo')),
      campoConSugerencias(raza, SoleraL10n.t('gana.raza'), razas),
      desplegableCodigo(
          etiqueta: SoleraL10n.t('gana.sexo'),
          valor: sexo,
          opciones: sexosAnimal,
          nombre: nombreSexo,
          conVacio: true,
          alCambiar: (valor) => refrescar(() => sexo = valor)),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.cake_outlined),
        title: Text(SoleraL10n.t('gana.fecha_nacimiento')),
        subtitle: Text(nacimiento == null
            ? SoleraL10n.t('gana.sin_indicar')
            : formatearDia(nacimiento!)),
        onTap: () async {
          final elegida = await showDatePicker(
              context: context,
              initialDate: nacimiento ?? DateTime.now(),
              firstDate: DateTime(1990),
              lastDate: DateTime.now());
          if (elegida != null) refrescar(() => nacimiento = elegida);
        },
      ),
      campoTexto(madre, SoleraL10n.t('gana.madre')),
      if (existente != null)
        desplegableCodigo(
            etiqueta: SoleraL10n.t('gana.estado'),
            valor: estado,
            opciones: estadosAnimal,
            nombre: nombreEstadoAnimal,
            alCambiar: (valor) => refrescar(() => estado = valor)),
    ],
    guardar: () async {
      final lectura = interpretarCodigoCrotal(identificacion.text);
      if (lectura.identificacion.isEmpty && nombre.text.trim().isEmpty) {
        return false;
      }
      final seDaDeBaja =
          estado != estadoAnimalActivo && existente?.activo != false;
      await BaseDatosSoleraGanadera.instancia.guardarAnimal(Animal(
        id: existente?.id,
        identificacion: lectura.identificacion,
        dispositivo: dispositivo,
        nombre: nombre.text.trim(),
        especie: especieAnimal,
        raza: raza.text.trim(),
        sexo: sexo,
        fechaNacimientoMs: nacimiento?.millisecondsSinceEpoch,
        madre: madre.text.trim(),
        loteId: existente?.loteId ?? lote.id,
        estado: estado,
        fechaBajaMs: estado == estadoAnimalActivo
            ? null
            : seDaDeBaja
                ? DateTime.now().millisecondsSinceEpoch
                : existente?.fechaBajaMs,
        notas: existente?.notas ?? '',
      ));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
}

/// Apunta un movimiento del rebaño (traslado, entrada, salida, alta o baja
/// parcial) con los datos que pide el documento de movimiento.
Future<void> mostrarAltaMovimiento(BuildContext context, LoteGanado lote,
    {required List<PiezaPasto> piezas,
    required int? piezaActual,
    required int cabezasActuales}) async {
  var tipo =
      piezaActual == null ? tipoMovimientoEntrada : tipoMovimientoTraslado;
  int? destino;
  var fecha = DateTime.now();
  final cabezas = TextEditingController(text: '$cabezasActuales');
  final identificaciones = TextEditingController();
  final explotacion = TextEditingController();
  final titular = TextEditingController();
  final municipio = TextEditingController();
  final provincia = TextEditingController();
  final remo = TextEditingController();
  final transporte = TextEditingController();
  final autorizacion = TextEditingController();
  final certificado = TextEditingController();
  final notas = TextEditingController();
  final activas = piezas.where((pieza) => pieza.activa).toList();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: '${SoleraL10n.t('gana.nuevo_movimiento')} · ${lote.nombre}',
    construir: (refrescar) {
      final externo = tipo != tipoMovimientoTraslado;
      final necesitaDestino =
          tipo == tipoMovimientoTraslado || tipo == tipoMovimientoEntrada;
      return [
        desplegableCodigo(
            etiqueta: SoleraL10n.t('gana.tipo'),
            valor: tipo,
            opciones: tiposMovimientoGanado,
            nombre: nombreTipoMovimiento,
            alCambiar: (valor) => refrescar(() => tipo = valor)),
        selectorFecha(context, SoleraL10n.t('gana.fecha'), fecha,
            (elegida) => refrescar(() => fecha = elegida)),
        if (necesitaDestino)
          separarCampoSolera(DropdownButtonFormField<int?>(
            initialValue: destino,
            decoration:
                InputDecoration(labelText: SoleraL10n.t('gana.pieza_destino')),
            items: [
              for (final pieza in activas)
                DropdownMenuItem<int?>(
                    value: pieza.id, child: Text(pieza.nombre)),
            ],
            onChanged: (valor) => refrescar(() => destino = valor),
          )),
        campoNumero(cabezas, SoleraL10n.t('gana.cabezas'), decimales: false),
        if (externo) ...[
          campoTexto(identificaciones, SoleraL10n.t('gana.crotales_movidos')),
          campoTexto(explotacion, SoleraL10n.t('gana.rega_externa')),
          campoTexto(titular, SoleraL10n.t('gana.titular_externo')),
          campoTexto(municipio, SoleraL10n.t('gana.municipio')),
          campoTexto(provincia, SoleraL10n.t('gana.provincia')),
          campoTexto(remo, SoleraL10n.t('gana.codigo_remo')),
          campoTexto(transporte, SoleraL10n.t('gana.medio_transporte')),
          campoTexto(
              autorizacion, SoleraL10n.t('gana.autorizacion_transportista')),
          campoTexto(certificado, SoleraL10n.t('gana.certificado_sanitario')),
        ],
        campoTexto(notas, SoleraL10n.t('gana.notas')),
      ];
    },
    guardar: () async {
      final necesitaDestino =
          tipo == tipoMovimientoTraslado || tipo == tipoMovimientoEntrada;
      if (necesitaDestino && destino == null) return false;
      await BaseDatosSoleraGanadera.instancia
          .guardarMovimiento(MovimientoGanado(
        loteId: lote.id!,
        fechaMs: fecha.millisecondsSinceEpoch,
        tipo: tipo,
        piezaOrigenId: piezaActual,
        piezaDestinoId: necesitaDestino ? destino : null,
        cabezas: leerEntero(cabezas.text) ?? 0,
        identificaciones: identificaciones.text.trim(),
        explotacionExterna: explotacion.text.trim().toUpperCase(),
        titularExterno: titular.text.trim(),
        municipioExterno: municipio.text.trim(),
        provinciaExterna: provincia.text.trim(),
        codigoRemo: remo.text.trim(),
        codigoTransporte: transporte.text.trim(),
        autorizacionTransportista: autorizacion.text.trim(),
        certificadoSanitario: certificado.text.trim(),
        notas: notas.text.trim(),
      ));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
}

/// Valores que se pueden dejar ya rellenos al abrir el formulario de un
/// evento (los que propone la lectura de la receta con IA).
class PropuestaEvento {
  const PropuestaEvento({
    this.medicamento = '',
    this.sustanciaActiva = '',
    this.dosis = '',
    this.duracionDias,
    this.esperaCarneDias,
    this.esperaLecheDias,
    this.veterinario = '',
    this.receta = '',
    this.fecha,
  });

  final String medicamento;
  final String sustanciaActiva;
  final String dosis;
  final int? duracionDias;
  final int? esperaCarneDias;
  final int? esperaLecheDias;
  final String veterinario;
  final String receta;
  final DateTime? fecha;
}

/// Apunta un evento de manejo de un animal o del rebaño. En los
/// tratamientos, **lo que pone la receta**: la app no sugiere nada.
Future<void> mostrarAltaEvento(BuildContext context, LoteGanado lote,
    {Animal? animal,
    PropuestaEvento propuesta = const PropuestaEvento()}) async {
  var tipo = tipoEventoTratamiento;
  var clase = '';
  var fecha = propuesta.fecha ?? DateTime.now();
  final descripcion = TextEditingController();
  final medicamento = TextEditingController(text: propuesta.medicamento);
  final sustancia = TextEditingController(text: propuesta.sustanciaActiva);
  final dosis = TextEditingController(text: propuesta.dosis);
  final duracion = TextEditingController(
      text: propuesta.duracionDias == null ? '' : '${propuesta.duracionDias}');
  final esperaCarne = TextEditingController(
      text: propuesta.esperaCarneDias == null
          ? ''
          : '${propuesta.esperaCarneDias}');
  final esperaLeche = TextEditingController(
      text: propuesta.esperaLecheDias == null
          ? ''
          : '${propuesta.esperaLecheDias}');
  final veterinario = TextEditingController(text: propuesta.veterinario);
  final receta = TextEditingController(text: propuesta.receta);
  final proveedor = TextEditingController();
  final pruebaCompra = TextEditingController();
  final peso = TextEditingController();
  final crias = TextEditingController();
  final cabezas = TextEditingController();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: '${SoleraL10n.t('gana.nuevo_evento')} · '
        '${animal?.rotulo ?? lote.nombre}',
    construir: (refrescar) {
      final conMedicamento = tiposEventoConMedicamento.contains(tipo);
      return [
        desplegableCodigo(
            etiqueta: SoleraL10n.t('gana.tipo'),
            valor: tipo,
            opciones: tiposEventoGanado,
            nombre: nombreTipoEvento,
            alCambiar: (valor) => refrescar(() => tipo = valor)),
        selectorFecha(
            context,
            SoleraL10n.t(conMedicamento
                ? 'gana.fecha_primera_administracion'
                : 'gana.fecha'),
            fecha,
            (elegida) => refrescar(() => fecha = elegida)),
        if (conMedicamento) ...[
          Text(SoleraL10n.t('gana.lo_que_pone_la_receta'),
              style: Theme.of(context).textTheme.bodySmall),
          campoTexto(medicamento, SoleraL10n.t('gana.medicamento')),
          campoConSugerencias(sustancia, SoleraL10n.t('gana.sustancia_activa'),
              catalogoSustanciasActivas.map((fila) => fila.nombre)),
          desplegableCodigo(
              etiqueta: SoleraL10n.t('gana.clase_medicamento'),
              valor: clase,
              opciones: clasesMedicamento,
              nombre: nombreClaseMedicamento,
              conVacio: true,
              alCambiar: (valor) => refrescar(() => clase = valor)),
          campoTexto(dosis, SoleraL10n.t('gana.cantidad_administrada')),
          campoNumero(duracion, SoleraL10n.t('gana.duracion_dias'),
              decimales: false),
          campoNumero(esperaCarne, SoleraL10n.t('gana.espera_carne_dias'),
              decimales: false),
          campoNumero(esperaLeche, SoleraL10n.t('gana.espera_leche_dias'),
              decimales: false),
          campoTexto(veterinario, SoleraL10n.t('gana.veterinario')),
          campoTexto(receta, SoleraL10n.t('gana.numero_receta')),
          campoTexto(proveedor, SoleraL10n.t('gana.proveedor')),
          campoTexto(pruebaCompra, SoleraL10n.t('gana.prueba_compra')),
          if (animal == null)
            campoNumero(cabezas, SoleraL10n.t('gana.cabezas_tratadas'),
                decimales: false),
        ],
        if (tipo == tipoEventoPesaje)
          campoNumero(peso, SoleraL10n.t('gana.peso_kg')),
        if (tipo == tipoEventoParto)
          campoNumero(crias, SoleraL10n.t('gana.crias'), decimales: false),
        campoTexto(descripcion, SoleraL10n.t('gana.descripcion')),
      ];
    },
    guardar: () async {
      await BaseDatosSoleraGanadera.instancia.guardarEvento(EventoGanado(
        animalId: animal?.id,
        loteId: animal == null ? lote.id : null,
        fechaMs: fecha.millisecondsSinceEpoch,
        tipo: tipo,
        descripcion: descripcion.text.trim(),
        medicamento: medicamento.text.trim(),
        sustanciaActiva: sustancia.text.trim(),
        // Sin clase indicada, la del catálogo si la sustancia está en él.
        claseMedicamento: clase.isNotEmpty
            ? clase
            : buscarSustanciaActiva(sustancia.text)?.clase ?? '',
        dosis: dosis.text.trim(),
        duracionDias: leerEntero(duracion.text) ?? 0,
        plazoSupresionCarneDias: leerEntero(esperaCarne.text) ?? 0,
        plazoSupresionLecheDias: leerEntero(esperaLeche.text) ?? 0,
        veterinario: veterinario.text.trim(),
        receta: receta.text.trim(),
        proveedor: proveedor.text.trim(),
        pruebaCompra: pruebaCompra.text.trim(),
        pesoKg: leerNumero(peso.text),
        crias: leerEntero(crias.text) ?? 0,
        cabezas: leerEntero(cabezas.text) ?? 0,
      ));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
}
