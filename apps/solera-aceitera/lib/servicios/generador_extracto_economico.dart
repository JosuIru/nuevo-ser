import 'dart:io';

import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/apunte_gasto.dart';
import '../modelos/tercero.dart';
import '../modelos/titular.dart';

/// Genera el extracto económico anual del titular (olivar + almazara)
/// en PDF reusando la plantilla `informe_periodico` del core. Pensado
/// para entregarlo al asesor fiscal con el cierre del ejercicio.
///
/// **Limitación PROVISIONAL v0.1**: las reglas de IVA/REAGP olivar
/// están sujetas a confirmación del asesor fiscal agroalimentario.
/// El subtítulo del PDF lleva el sello `PROVISIONAL` literal hasta
/// que un asesor humano valide la casuística (registrado como bloqueo
/// F1-A9 en `BLOQUEOS-PENDIENTES.md` y custodiado por el guardrail
/// `test/sello_provisional_test.dart`).
Future<File> generarExtractoEconomicoAnual({
  required int anyo,
}) async {
  final basedatos = BaseDatosSoleraAceitera.instancia;
  final titular = await basedatos.obtenerTitular();
  final configuracion = await basedatos.obtenerConfiguracionFiscal();
  final terceros = await basedatos.listarTerceros();
  final indiceTercerosPorId = <int, Tercero>{
    for (final t in terceros)
      if (t.id != null) t.id!: t,
  };

  final desdeMs = DateTime(anyo, 1, 1).millisecondsSinceEpoch;
  final hastaMs = DateTime(anyo + 1, 1, 1).millisecondsSinceEpoch - 1;
  final ingresos = await basedatos.listarApuntesIngreso(
    desdeMs: desdeMs,
    hastaMs: hastaMs,
  );
  final gastos = await basedatos.listarApuntesGasto(
    desdeMs: desdeMs,
    hastaMs: hastaMs,
  );

  final formatoFecha = DateFormat('dd/MM/yyyy');
  final formatoEuros = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '€',
    decimalDigits: 2,
  );

  final totalBaseIngresos = ingresos.fold<int>(
      0, (acc, a) => acc + a.importeBaseCentimos);
  final totalIvaRepercutido = ingresos.fold<int>(
      0, (acc, a) => acc + a.ivaRepercutidoCentimos);
  final totalCompensacionReagp = ingresos.fold<int>(
      0, (acc, a) => acc + a.compensacionReagpCentimos);
  final totalBaseGastos =
      gastos.fold<int>(0, (acc, a) => acc + a.importeBaseCentimos);
  final totalIvaSoportado =
      gastos.fold<int>(0, (acc, a) => acc + a.ivaSoportadoCentimos);

  // Desglose por tipo de ingreso — la separación aceituna vs aceite vs
  // ayudas es la información clave que un fiscal pide al cerrar el año.
  final subtotalesIngresos = <String, int>{};
  for (final a in ingresos) {
    subtotalesIngresos.update(
      a.tipoIngreso,
      (existente) => existente + a.importeBaseCentimos,
      ifAbsent: () => a.importeBaseCentimos,
    );
  }

  // Desglose por tipo de gasto.
  final subtotalesGastos = <String, int>{};
  for (final a in gastos) {
    subtotalesGastos.update(
      a.tipoGasto,
      (existente) => existente + a.importeBaseCentimos,
      ifAbsent: () => a.importeBaseCentimos,
    );
  }

  final modelo347 = <int, int>{};
  for (final a in ingresos) {
    final t = a.terceroId == null ? null : indiceTercerosPorId[a.terceroId];
    if (t == null || !t.tieneNif) continue;
    modelo347.update(
      a.terceroId!,
      (existente) => existente + a.importeTotalCentimos,
      ifAbsent: () => a.importeTotalCentimos,
    );
  }
  for (final a in gastos) {
    final t = a.terceroId == null ? null : indiceTercerosPorId[a.terceroId];
    if (t == null || !t.tieneNif) continue;
    modelo347.update(
      a.terceroId!,
      (existente) => existente + a.importeTotalCentimos,
      ifAbsent: () => a.importeTotalCentimos,
    );
  }

  // Sólo entran al modelo 347 las operaciones que con un mismo NIF
  // superen los 3.005,06 € en el año (umbral oficial vigente).
  const umbral347Centimos = 300506;
  final filas347 = modelo347.entries
      .where((e) => e.value >= umbral347Centimos)
      .map((e) {
    final t = indiceTercerosPorId[e.key]!;
    return [
      t.nif,
      t.nombre.isEmpty ? '(sin nombre)' : t.nombre,
      formatoEuros.format(e.value / 100),
    ];
  }).toList(growable: false);

  final sinNifIngresos = ingresos.where((a) {
    if (a.terceroId == null) return true;
    final t = indiceTercerosPorId[a.terceroId];
    return t == null || !t.tieneNif;
  }).toList();

  final tituloCabecera = 'Extracto económico · $anyo';
  final subtituloCabecera =
      'REAGP/general olivar · PROVISIONAL hasta validación fiscal';

  final bulletsResumen = <String>[
    'Titular: ${_etiquetaTitularRazonSocial(titular)} · NIF ${_etiquetaNif(titular)}',
    if (titular != null && titular.numeroAica.isNotEmpty)
      'AICA: ${titular.numeroAica}',
    'Régimen IRPF: ${_etiquetaRegimenIrpf(configuracion.regimenIrpf)}',
    'Régimen IVA: ${_etiquetaRegimenIva(configuracion.regimenIva)}',
    'Total ingresos (base): ${formatoEuros.format(totalBaseIngresos / 100)}',
    'Total IVA repercutido: ${formatoEuros.format(totalIvaRepercutido / 100)}',
    if (totalCompensacionReagp > 0)
      'Total compensación REAGP cobrada: ${formatoEuros.format(totalCompensacionReagp / 100)}',
    'Total gastos (base): ${formatoEuros.format(totalBaseGastos / 100)}',
    'Total IVA soportado: ${formatoEuros.format(totalIvaSoportado / 100)}',
    'Resultado bruto (ingresos − gastos): '
        '${formatoEuros.format((totalBaseIngresos - totalBaseGastos) / 100)}',
    'Apuntes sin NIF (no entran al modelo 347): ${sinNifIngresos.length}',
  ];

  // Tabla 1: desglose por tipo de ingreso.
  final filasIngresosPorTipo = subtotalesIngresos.entries
      .map((e) => [
            _etiquetaTipoIngreso(e.key),
            formatoEuros.format(e.value / 100),
          ])
      .toList();

  // Tabla 2: desglose por tipo de gasto.
  final filasGastosPorTipo = subtotalesGastos.entries
      .map((e) => [
            _etiquetaTipoGasto(e.key),
            formatoEuros.format(e.value / 100),
          ])
      .toList();

  // Tabla 3: detalle de ingresos.
  final filasDetalleIngresos = [
    for (final a in ingresos)
      [
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(a.fechaMs)),
        _etiquetaTipoIngreso(a.tipoIngreso),
        a.concepto,
        _etiquetaTerceroDeApunte(a.terceroId, indiceTercerosPorId),
        a.numeroFactura.isEmpty ? '—' : a.numeroFactura,
        formatoEuros.format(a.importeBaseCentimos / 100),
        formatoEuros.format(a.ivaRepercutidoCentimos / 100),
        formatoEuros.format(a.compensacionReagpCentimos / 100),
        formatoEuros.format(a.importeTotalCentimos / 100),
      ],
  ];

  // Tabla 4: detalle de gastos.
  final filasDetalleGastos = [
    for (final a in gastos)
      [
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(a.fechaMs)),
        _etiquetaTipoGasto(a.tipoGasto),
        a.concepto,
        _etiquetaTerceroDeApunte(a.terceroId, indiceTercerosPorId),
        a.numeroFactura.isEmpty ? '—' : a.numeroFactura,
        _etiquetaImputacion(a),
        formatoEuros.format(a.importeBaseCentimos / 100),
        formatoEuros.format(a.ivaSoportadoCentimos / 100),
        formatoEuros.format(a.importeTotalCentimos / 100),
      ],
  ];

  return generarInformePeriodicoPdf(
    tema: await temaPdfSolera(),
    tituloCabecera: tituloCabecera,
    subtituloCabecera: subtituloCabecera,
    bulletsResumen: bulletsResumen,
    tablas: [
      TablaInforme(
        titulo: 'Ingresos por tipo',
        headers: const ['Tipo', 'Base imponible'],
        filas: filasIngresosPorTipo,
        mensajeSiVacia: 'Sin ingresos registrados en $anyo.',
      ),
      TablaInforme(
        titulo: 'Gastos por tipo',
        headers: const ['Tipo', 'Base imponible'],
        filas: filasGastosPorTipo,
        mensajeSiVacia: 'Sin gastos registrados en $anyo.',
      ),
      TablaInforme(
        titulo: 'Modelo 347 (> 3.005,06 €/año por NIF)',
        headers: const ['NIF', 'Nombre', 'Total operaciones'],
        filas: filas347,
        mensajeSiVacia:
            'Ningún tercero supera el umbral del modelo 347 este año.',
      ),
      TablaInforme(
        titulo: 'Detalle de ingresos',
        headers: const [
          'Fecha',
          'Tipo',
          'Concepto',
          'Tercero',
          'Factura',
          'Base',
          'IVA rep.',
          'Comp. REAGP',
          'Total',
        ],
        filas: filasDetalleIngresos,
        mensajeSiVacia: 'Sin ingresos registrados en $anyo.',
      ),
      TablaInforme(
        titulo: 'Detalle de gastos',
        headers: const [
          'Fecha',
          'Tipo',
          'Concepto',
          'Tercero',
          'Factura',
          'Imputación',
          'Base',
          'IVA sop.',
          'Total',
        ],
        filas: filasDetalleGastos,
        mensajeSiVacia: 'Sin gastos registrados en $anyo.',
      ),
    ],
    prefijoNombreFichero: 'extracto_economico-$anyo',
    operador: (titular == null || titular.razonSocial.isEmpty)
        ? null
        : titular.razonSocial,
  );
}

String _etiquetaTitularRazonSocial(Titular? t) =>
    (t == null || t.razonSocial.isEmpty) ? '—' : t.razonSocial;

String _etiquetaNif(Titular? t) =>
    (t == null || t.nif.isEmpty) ? '—' : t.nif;

String _etiquetaRegimenIrpf(String regimen) {
  switch (regimen) {
    case 'estimacion_directa_simplificada':
      return 'Estimación directa simplificada';
    case 'estimacion_directa_normal':
      return 'Estimación directa normal';
    default:
      return 'Sin elegir';
  }
}

String _etiquetaRegimenIva(String regimen) {
  switch (regimen) {
    case 'reagp':
      return 'REAGP (compensación 12 % en aceituna)';
    case 'general':
      return 'Régimen general';
    default:
      return 'Sin elegir';
  }
}

String _etiquetaTipoIngreso(String tipo) {
  switch (tipo) {
    case 'venta_aceituna':
      return 'Venta de aceituna';
    case 'venta_aceite_envasado':
      return 'Venta de aceite envasado';
    case 'venta_aceite_granel':
      return 'Venta de aceite a granel';
    case 'alquiler_terreno':
      return 'Alquiler de terreno';
    case 'ayuda_pac':
      return 'Ayuda PAC';
    case 'subvencion_autonomica':
      return 'Subvención autonómica';
    case 'subproducto_alperujo':
      return 'Subproducto alperujo';
    default:
      return tipo;
  }
}

String _etiquetaTipoGasto(String tipo) {
  switch (tipo) {
    case 'insumos_olivar':
      return 'Insumos olivar';
    case 'fitosanitarios':
      return 'Fitosanitarios';
    case 'recoleccion':
      return 'Recolección';
    case 'molturacion_externa':
      return 'Molturación externa';
    case 'envasado':
      return 'Envasado';
    case 'analiticas':
      return 'Analíticas';
    case 'cuota_dop':
      return 'Cuota DOP';
    case 'maquinaria':
      return 'Maquinaria';
    case 'mano_obra':
      return 'Mano de obra';
    case 'combustible':
      return 'Combustible';
    case 'seguros':
      return 'Seguros';
    case 'transporte':
      return 'Transporte';
    case 'certificacion':
      return 'Certificación';
    default:
      return tipo;
  }
}

String _etiquetaTerceroDeApunte(
    int? terceroId, Map<int, Tercero> indice) {
  if (terceroId == null) return '—';
  final t = indice[terceroId];
  if (t == null) return '#$terceroId';
  return t.nombre.isEmpty ? '#$terceroId' : t.nombre;
}

String _etiquetaImputacion(ApunteGasto a) {
  if (a.esParcelaConcreta) return 'Parcela #${a.parcelaId}';
  if (a.esVariedadGeneral) return 'Variedad ${a.variedadId}';
  return 'General';
}
