import 'dart:io';

import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_variedades.dart';
import '../modelos/apunte_gasto.dart';
import '../modelos/tercero.dart';

/// Genera el extracto económico anual del viticultor/bodega (libro
/// registro de ingresos y gastos para el asesor fiscal). Reusa la
/// plantilla `informe_periodico_pdf` del core para mantener
/// cabecera/footer/tablas consistentes con el resto de la suite
/// Larrea.
///
/// Contenido del extracto:
///  1. Cabecera con datos del titular + régimen fiscal del año.
///  2. Bullets resumen con totales (uva vs vino vs ayudas).
///  3. Tabla mensual de ingresos.
///  4. Tabla mensual de gastos.
///  5. Modelo 347 — terceros con suma >3.005,06€/año.
///  6. Apuntes sin NIF — alerta porque no entran al 347.
///  7. Detalle cronológico de ingresos con variedad y lote.
///  8. Detalle cronológico de gastos con imputación.
///
/// **Limitaciones v1 provisional**:
///  - El reparto proporcional por superficie de gastos imputados a
///    `variedad_general` entre las parcelas con esa variedad NO se
///    calcula — los apuntes con esa imputación se listan tal cual
///    con el importe íntegro asignable a la variedad. Cuando el
///    asesor fiscal valide el método de reparto, el cálculo se
///    mueve aquí (registrado en BLOQUEOS-PENDIENTES.md F1-12).
///  - El formato exacto del libro registro / formato del 347 está
///    pendiente de firma de asesor fiscal. El PDF lleva banner
///    "PROVISIONAL" en cabecera hasta entonces.
Future<File> generarExtractoEconomico({
  required int ano,
}) async {
  final db = BaseDatosSoleraViticultura.instancia;
  final titular = await db.obtenerTitular();
  final configFiscal = await db.obtenerConfiguracionFiscal();
  final ingresos = await db.listarApuntesIngresoPorAno(ano);
  final gastos = await db.listarApuntesGastoPorAno(ano);
  final filasTerceros = await db.listarTerceros();
  final terceros = <int, Tercero>{
    for (final t in filasTerceros)
      if (t.id != null) t.id!: t,
  };

  final formatoFecha = DateFormat('dd/MM/yyyy');

  // ─── Bullets resumen ───────────────────────────────────
  final ingresosOrdinarios = ingresos
      .where((a) => !a.esAyudaOSubvencion)
      .map((a) => a.importeBaseCentimos)
      .fold<int>(0, (s, n) => s + n);
  final ayudas = ingresos
      .where((a) => a.esAyudaOSubvencion)
      .map((a) => a.importeBaseCentimos)
      .fold<int>(0, (s, n) => s + n);
  final ingresosUva = ingresos
      .where((a) => a.esVentaUva)
      .map((a) => a.importeBaseCentimos)
      .fold<int>(0, (s, n) => s + n);
  final ingresosVino = ingresos
      .where((a) => a.esVentaVino)
      .map((a) => a.importeBaseCentimos)
      .fold<int>(0, (s, n) => s + n);
  final compensacionReagp = ingresos
      .map((a) => a.compensacionReagpCentimos)
      .fold<int>(0, (s, n) => s + n);
  final ivaRepercutido = ingresos
      .map((a) => a.ivaRepercutidoCentimos)
      .fold<int>(0, (s, n) => s + n);
  final gastosBase =
      gastos.map((g) => g.importeBaseCentimos).fold<int>(0, (s, n) => s + n);
  final ivaSoportado =
      gastos.map((g) => g.ivaSoportadoCentimos).fold<int>(0, (s, n) => s + n);

  final bullets = <String>[
    'PROVISIONAL — Pendiente de validación por asesor fiscal.',
    'Titular: ${titular.nombre.isEmpty ? "—" : titular.nombre} · NIF ${titular.nif.isEmpty ? "—" : titular.nif}',
    if (titular.numeroRegepa.isNotEmpty) 'Nº REGEPA: ${titular.numeroRegepa}',
    'Régimen IRPF: ${_etiquetaIrpf(configFiscal.regimenIrpf)}',
    'Régimen IVA: ${_etiquetaIva(configFiscal.regimenIva)}',
    'Ingresos por uva (base): ${_euros(ingresosUva)}',
    'Ingresos por vino (base): ${_euros(ingresosVino)}',
    'Ayudas PAC y subvenciones: ${_euros(ayudas)}',
    'Gastos (base): ${_euros(gastosBase)}',
    'Diferencia ordinaria: ${_euros(ingresosOrdinarios - gastosBase)}',
    if (configFiscal.tieneCompensacionReagp)
      'Compensación REAGP cobrada (uva): ${_euros(compensacionReagp)}',
    'IVA repercutido: ${_euros(ivaRepercutido)}',
    'IVA soportado: ${_euros(ivaSoportado)}'
        '${configFiscal.tieneCompensacionReagp ? " (no recuperable, mayor coste en REAGP)" : ""}',
    'Apuntes de ingreso: ${ingresos.length} · de gasto: ${gastos.length}',
  ];

  // ─── Tabla mensual de ingresos ────────────────────────
  final filasMensualIngresos = <List<String>>[];
  for (var mes = 1; mes <= 12; mes++) {
    final desde = DateTime(ano, mes, 1).millisecondsSinceEpoch;
    final hasta = DateTime(ano, mes + 1, 1).millisecondsSinceEpoch - 1;
    final delMes =
        ingresos.where((a) => a.fechaMs >= desde && a.fechaMs <= hasta);
    final uva = delMes
        .where((a) => a.esVentaUva)
        .fold<int>(0, (s, a) => s + a.importeBaseCentimos);
    final vino = delMes
        .where((a) => a.esVentaVino)
        .fold<int>(0, (s, a) => s + a.importeBaseCentimos);
    final ayudasMes = delMes
        .where((a) => a.esAyudaOSubvencion)
        .fold<int>(0, (s, a) => s + a.importeBaseCentimos);
    final ivaMes =
        delMes.fold<int>(0, (s, a) => s + a.ivaRepercutidoCentimos);
    final reagMes =
        delMes.fold<int>(0, (s, a) => s + a.compensacionReagpCentimos);
    if (uva + vino + ayudasMes + ivaMes + reagMes == 0) continue;
    filasMensualIngresos.add([
      _nombreMes(mes),
      _euros(uva),
      _euros(vino),
      _euros(ayudasMes),
      _euros(ivaMes),
      _euros(reagMes),
    ]);
  }

  // ─── Tabla mensual de gastos ──────────────────────────
  final filasMensualGastos = <List<String>>[];
  for (var mes = 1; mes <= 12; mes++) {
    final desde = DateTime(ano, mes, 1).millisecondsSinceEpoch;
    final hasta = DateTime(ano, mes + 1, 1).millisecondsSinceEpoch - 1;
    final delMes = gastos.where((g) => g.fechaMs >= desde && g.fechaMs <= hasta);
    final base = delMes.fold<int>(0, (s, g) => s + g.importeBaseCentimos);
    final iva = delMes.fold<int>(0, (s, g) => s + g.ivaSoportadoCentimos);
    if (base + iva == 0) continue;
    filasMensualGastos.add([
      _nombreMes(mes),
      _euros(base),
      _euros(iva),
      _euros(base + iva),
    ]);
  }

  // ─── Modelo 347 ─────────────────────────────────────
  const umbral347 = 300506; // céntimos
  final acumuladoPorTercero = <int, _AcumuladoTercero>{};
  for (final a in ingresos) {
    if (a.terceroId == null) continue;
    final acc = acumuladoPorTercero.putIfAbsent(
        a.terceroId!, () => _AcumuladoTercero());
    acc.ingresos += a.importeTotalCentimos;
  }
  for (final g in gastos) {
    if (g.terceroId == null) continue;
    final acc = acumuladoPorTercero.putIfAbsent(
        g.terceroId!, () => _AcumuladoTercero());
    acc.gastos += g.importeTotalCentimos;
  }

  final filas347 = <List<String>>[];
  for (final entrada in acumuladoPorTercero.entries) {
    final t = terceros[entrada.key];
    final acc = entrada.value;
    final total = acc.ingresos + acc.gastos;
    if (total < umbral347) continue;
    if (t == null) continue;
    filas347.add([
      t.nif.isEmpty ? '(sin NIF)' : t.nif,
      t.nombre.isEmpty ? '(sin nombre)' : t.nombre,
      _euros(acc.ingresos),
      _euros(acc.gastos),
      _euros(total),
    ]);
  }
  filas347.sort((a, b) => b[4].compareTo(a[4])); // por total desc

  // ─── Apuntes sin NIF ────────────────────────────────
  final filasSinNif = <List<String>>[];
  for (final a in ingresos) {
    final t = a.terceroId == null ? null : terceros[a.terceroId];
    if (t != null && t.tieneNif) continue;
    filasSinNif.add([
      formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(a.fechaMs)),
      'Ingreso',
      a.concepto.isEmpty ? '—' : a.concepto,
      _euros(a.importeTotalCentimos),
    ]);
  }
  for (final g in gastos) {
    final t = g.terceroId == null ? null : terceros[g.terceroId];
    if (t != null && t.tieneNif) continue;
    filasSinNif.add([
      formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(g.fechaMs)),
      'Gasto',
      g.concepto.isEmpty ? '—' : g.concepto,
      _euros(g.importeTotalCentimos),
    ]);
  }

  // ─── Detalle de ingresos ────────────────────────────
  final filasDetalleIngresos = <List<String>>[
    for (final a in ingresos.toList()
      ..sort((x, y) => x.fechaMs.compareTo(y.fechaMs)))
      [
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(a.fechaMs)),
        _etiquetaTipoIngreso(a.tipoIngreso),
        a.concepto.isEmpty ? '—' : a.concepto,
        _nombreTercero(terceros[a.terceroId]),
        _nombreVariedad(a.variedadId),
        a.loteVino.isEmpty ? '—' : a.loteVino,
        _euros(a.importeBaseCentimos),
        _euros(a.ivaRepercutidoCentimos),
        _euros(a.compensacionReagpCentimos),
        _euros(a.importeTotalCentimos),
      ],
  ];

  // ─── Detalle de gastos ──────────────────────────────
  final filasDetalleGastos = <List<String>>[
    for (final g in gastos.toList()
      ..sort((x, y) => x.fechaMs.compareTo(y.fechaMs)))
      [
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(g.fechaMs)),
        _etiquetaTipoGasto(g.tipoGasto),
        g.concepto.isEmpty ? '—' : g.concepto,
        _nombreTercero(terceros[g.terceroId]),
        _etiquetaImputacion(g),
        _euros(g.importeBaseCentimos),
        _euros(g.ivaSoportadoCentimos),
        _euros(g.importeTotalCentimos),
      ],
  ];

  return generarInformePeriodicoPdf(
    tema: await temaPdfSolera(),
    tituloCabecera: 'Extracto económico · $ano',
    subtituloCabecera:
        'Viticultura · Libro registro provisional · Asesor fiscal pendiente',
    bulletsResumen: bullets,
    tablas: [
      TablaInforme(
        titulo: 'Ingresos por mes',
        headers: const [
          'Mes',
          'Uva',
          'Vino',
          'Ayudas/Subv.',
          'IVA rep.',
          'Comp. REAGP',
        ],
        filas: filasMensualIngresos,
        mensajeSiVacia: 'Sin ingresos registrados en el ejercicio.',
      ),
      TablaInforme(
        titulo: 'Gastos por mes',
        headers: const ['Mes', 'Base', 'IVA sop.', 'Total'],
        filas: filasMensualGastos,
        mensajeSiVacia: 'Sin gastos registrados en el ejercicio.',
      ),
      TablaInforme(
        titulo: 'Modelo 347 — operaciones >3.005,06 € con un mismo NIF',
        headers: const [
          'NIF',
          'Tercero',
          'Ingresos',
          'Gastos',
          'Total',
        ],
        filas: filas347,
        mensajeSiVacia:
            'Ningún tercero supera el umbral del 347 en este ejercicio.',
      ),
      TablaInforme(
        titulo: 'Apuntes sin NIF — NO entran al modelo 347',
        headers: const ['Fecha', 'Tipo', 'Concepto', 'Importe'],
        filas: filasSinNif,
        mensajeSiVacia: 'Todos los apuntes tienen NIF asociado.',
      ),
      TablaInforme(
        titulo: 'Detalle cronológico de ingresos',
        headers: const [
          'Fecha',
          'Tipo',
          'Concepto',
          'Cliente',
          'Variedad',
          'Lote',
          'Base',
          'IVA',
          'Comp. REAGP',
          'Total',
        ],
        filas: filasDetalleIngresos,
        mensajeSiVacia: 'Sin ingresos.',
      ),
      TablaInforme(
        titulo: 'Detalle cronológico de gastos',
        headers: const [
          'Fecha',
          'Tipo',
          'Concepto',
          'Proveedor',
          'Imputación',
          'Base',
          'IVA',
          'Total',
        ],
        filas: filasDetalleGastos,
        mensajeSiVacia: 'Sin gastos.',
      ),
    ],
    prefijoNombreFichero: 'extracto_economico-$ano',
    operador: titular.nombre.isEmpty ? null : titular.nombre,
  );
}

class _AcumuladoTercero {
  int ingresos = 0;
  int gastos = 0;
}

String _euros(int centimos) => '${(centimos / 100).toStringAsFixed(2)} €';

String _nombreMes(int mes) {
  const nombres = [
    '',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  return nombres[mes];
}

String _nombreTercero(Tercero? t) {
  if (t == null) return '(sin asociar)';
  if (t.nombre.isEmpty) return '(sin nombre)';
  return t.nombre;
}

String _nombreVariedad(String id) {
  if (id.isEmpty) return '—';
  for (final v in catalogoVariedades) {
    if (v.id == id) return v.nombreCanonico;
  }
  return id;
}

String _etiquetaIrpf(String codigo) {
  switch (codigo) {
    case 'estimacion_directa_simplificada':
      return 'Estimación directa simplificada';
    case 'estimacion_directa_normal':
      return 'Estimación directa normal';
    default:
      return 'Sin elegir';
  }
}

String _etiquetaIva(String codigo) {
  switch (codigo) {
    case 'reagp':
      return 'REAGP (compensación 12% en uva)';
    case 'general':
      return 'Régimen general';
    default:
      return 'Sin elegir';
  }
}

String _etiquetaTipoIngreso(String codigo) {
  switch (codigo) {
    case 'venta_uva':
      return 'Uva';
    case 'venta_vino_botella':
      return 'Vino botella';
    case 'venta_vino_granel':
      return 'Vino granel';
    case 'alquiler_terreno':
      return 'Alquiler';
    case 'ayuda_pac':
      return 'Ayuda PAC';
    case 'subvencion_autonomica':
      return 'Subvención';
    default:
      return 'Otro';
  }
}

String _etiquetaTipoGasto(String codigo) {
  switch (codigo) {
    case 'insumos_vid':
      return 'Insumos';
    case 'tratamientos_fitosanitarios':
      return 'Tratamiento';
    case 'vendimia':
      return 'Vendimia';
    case 'embotellado':
      return 'Embotellado';
    case 'etiquetado':
      return 'Etiquetado';
    case 'barricas':
      return 'Barricas';
    case 'maquinaria':
      return 'Maquinaria';
    case 'mano_obra':
      return 'Mano obra';
    case 'combustible':
      return 'Combustible';
    case 'seguros':
      return 'Seguros';
    case 'transporte':
      return 'Transporte';
    case 'certificacion':
      return 'Certificación';
    default:
      return 'Otro';
  }
}

String _etiquetaImputacion(ApunteGasto g) {
  if (g.esVinedoConcreto) return 'Viñedo';
  if (g.esVariedadGeneral) return _nombreVariedad(g.variedadId);
  return 'General';
}
