import 'dart:io';

import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_plagas_apicolas.dart';
import '../datos/catalogos_generados/catalogo_sustancias_varroa.dart';
import '../modelos/apiario.dart';
import '../modelos/colmena.dart';

/// Genera el libro oficial de explotación apícola (REGA / SITRAN-AP) en PDF
/// firmable. Usa la plantilla `informe_periodico` del core para mantener
/// cabecera, footer y tablas consistentes con el resto de informes de la
/// suite Larrea.
///
/// **Limitación v0.1**: el formato exacto vigente del libro REGA cambia
/// con cada actualización del MAPA + decretos autonómicos (Andalucía,
/// Galicia, Castilla-La Mancha tienen variaciones). Hasta validar con
/// la cooperativa apícola o un PDF firmado de inspección reciente, este
/// generador produce un informe **funcional pero no garantizado conforme**
/// a la última circular del MAPA. Registrado en `BLOQUEOS-PENDIENTES.md`
/// como bloqueo F1A-5.
///
/// Si `apiario` es null se genera el libro global (todas las colmenas,
/// incluidos puntos sueltos).
Future<File> generarLibroRega({
  required Apiario? apiario,
  required int desdeMs,
  required int hastaMs,
  required int ano,
}) async {
  final db = BaseDatosSoleraApicola.instancia;
  final apicultor = await db.obtenerApicultor();
  final colmenas = await db.listarColmenas(apiarioId: apiario?.id);
  final indiceColmenasPorId = <int, Colmena>{for (final c in colmenas) c.id!: c};
  final apiariosTodos = await db.listarApiarios();
  final indiceApiariosPorId = <int, Apiario>{for (final a in apiariosTodos) a.id!: a};

  final tratamientos = await db.listarTratamientosPorApiarioYRango(
    apiarioId: apiario?.id,
    desdeMs: desdeMs,
    hastaMs: hastaMs,
  );
  final movimientos = await db.listarMovimientosPorApiarioYRango(
    apiarioId: apiario?.id,
    desdeMs: desdeMs,
    hastaMs: hastaMs,
  );
  final incidencias = await db.listarIncidenciasPorApiarioYRango(
    apiarioId: apiario?.id,
    desdeMs: desdeMs,
    hastaMs: hastaMs,
  );
  final cosechas = await db.listarCosechasPorApiarioYRango(
    apiarioId: apiario?.id,
    desdeMs: desdeMs,
    hastaMs: hastaMs,
  );

  final formatoFecha = DateFormat('dd/MM/yyyy');
  final tituloCabecera = apiario == null
      ? 'Libro de explotación apícola · todos los apiarios'
      : 'Libro de explotación apícola · ${apiario.nombre}';
  final subtituloCabecera = 'Campaña $ano · REGA / SITRAN-AP';

  final bullets = <String>[
    'Titular: ${apicultor.nombre.isEmpty ? "—" : apicultor.nombre} · NIF ${apicultor.nif.isEmpty ? "—" : apicultor.nif}',
    if (apicultor.numeroRega.isNotEmpty) 'Nº REGA: ${apicultor.numeroRega}',
    if (apicultor.numeroExplotacionApicola.isNotEmpty)
      'Nº explotación apícola: ${apicultor.numeroExplotacionApicola}',
    if (apicultor.direccion.isNotEmpty) 'Dirección: ${apicultor.direccion}',
    if (apicultor.nombreVeterinario.isNotEmpty)
      'Veterinario asesor: ${apicultor.nombreVeterinario} · NIF ${apicultor.nifVeterinario.isEmpty ? "—" : apicultor.nifVeterinario} · Colegiado ${apicultor.numeroColegiadoVeterinario.isEmpty ? "—" : apicultor.numeroColegiadoVeterinario}',
    if (apiario != null && apiario.codigoSitran.isNotEmpty)
      'Código SITRAN del asentamiento: ${apiario.codigoSitran}',
    if (apiario != null && apiario.superficieHectareas != null)
      'Superficie: ${apiario.superficieHectareas!.toStringAsFixed(2)} ha',
    'Colmenas en el ámbito del libro: ${colmenas.length}',
    'Tratamientos sanitarios registrados: ${tratamientos.length}',
    'Movimientos registrados: ${movimientos.length}',
    'Incidencias registradas: ${incidencias.length}',
  ];

  final filasTratamientos = [
    for (final t in tratamientos)
      [
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(t.fechaAplicacionMs)),
        _matricula(indiceColmenasPorId[t.colmenaId]),
        _nombreSustancia(t.sustanciaActivaId),
        t.dosis.isEmpty ? '—' : t.dosis,
        t.vehiculo.isEmpty ? '—' : t.vehiculo,
        t.loteProducto.isEmpty ? '—' : t.loteProducto,
        t.numeroFactura.isEmpty ? '—' : t.numeroFactura,
        t.plazoSeguridadDias?.toString() ?? '—',
        t.fechaRetiradaMs == null
            ? '—'
            : formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(t.fechaRetiradaMs!)),
      ],
  ];

  final filasMovimientos = [
    for (final m in movimientos)
      [
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(m.fechaMovimientoMs)),
        _etiquetaApiario(m.apiarioOrigenId, indiceApiariosPorId, m.latitudOrigen, m.longitudOrigen),
        _etiquetaApiario(
            m.apiarioDestinoId, indiceApiariosPorId, m.latitudDestino, m.longitudDestino),
        m.motivo,
        m.numeroColmenas.toString(),
        m.notas.isEmpty ? '—' : m.notas,
      ],
  ];

  final filasIncidencias = [
    for (final i in incidencias)
      [
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(i.fechaMs)),
        _matricula(indiceColmenasPorId[i.colmenaId]),
        i.tipo,
        _nombrePlaga(i.diagnostico),
        i.severidad?.toString() ?? '—',
        i.resuelta
            ? (i.fechaResolucionMs == null
                ? 'Resuelta'
                : 'Resuelta ${formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(i.fechaResolucionMs!))}')
            : 'Abierta',
      ],
  ];

  final filasCosechas = [
    for (final cm in cosechas)
      [
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(cm.fechaMs)),
        _matricula(indiceColmenasPorId[cm.colmenaId]),
        cm.kilosMiel?.toStringAsFixed(2) ?? '—',
        cm.kilosCera?.toStringAsFixed(2) ?? '—',
        cm.kilosPolen?.toStringAsFixed(2) ?? '—',
        cm.kilosPropoleo?.toStringAsFixed(2) ?? '—',
      ],
  ];

  return generarInformePeriodicoPdf(
    tema: await temaPdfSolera(),
    tituloCabecera: tituloCabecera,
    subtituloCabecera: subtituloCabecera,
    bulletsResumen: bullets,
    tablas: [
      TablaInforme(
        titulo: 'Tratamientos sanitarios',
        headers: const [
          'Fecha',
          'Colmena',
          'Sustancia',
          'Dosis',
          'Vehículo',
          'Lote',
          'Factura',
          'PS (días)',
          'Retirada',
        ],
        filas: filasTratamientos,
        mensajeSiVacia: 'Sin tratamientos sanitarios registrados en el periodo.',
      ),
      TablaInforme(
        titulo: 'Movimientos (trashumancia, altas, bajas)',
        headers: const [
          'Fecha',
          'Origen',
          'Destino',
          'Motivo',
          'Nº colmenas',
          'Notas',
        ],
        filas: filasMovimientos,
        mensajeSiVacia: 'Sin movimientos registrados en el periodo.',
      ),
      TablaInforme(
        titulo: 'Incidencias sanitarias',
        headers: const [
          'Fecha',
          'Colmena',
          'Tipo',
          'Diagnóstico',
          'Severidad',
          'Estado',
        ],
        filas: filasIncidencias,
        mensajeSiVacia: 'Sin incidencias registradas en el periodo.',
      ),
      TablaInforme(
        titulo: 'Cosechas',
        headers: const [
          'Fecha',
          'Colmena',
          'Miel (kg)',
          'Cera (kg)',
          'Polen (kg)',
          'Propóleo (kg)',
        ],
        filas: filasCosechas,
        mensajeSiVacia: 'Sin cosechas registradas en el periodo.',
      ),
    ],
    prefijoNombreFichero: 'libro_rega-${apiario?.nombre ?? "todos"}-$ano',
    operador: apicultor.nombre.isEmpty ? null : apicultor.nombre,
  );
}

String _matricula(Colmena? colmena) {
  if (colmena == null) return '—';
  return colmena.matricula;
}

/// Resuelve el nombre canónico de la sustancia desde el catálogo. Si no
/// está catalogada (texto libre legacy) devuelve el id literal para que
/// el inspector vea lo que el apicultor introdujo.
String _nombreSustancia(String id) {
  if (id.isEmpty) return '—';
  final canonica = sustanciaVarroaPorId(id);
  return canonica?.nombreCanonico ?? id;
}

String _nombrePlaga(String id) {
  if (id.isEmpty) return '—';
  final canonica = plagaApicolaPorId(id);
  return canonica?.nombreComun ?? id;
}

String _etiquetaApiario(
  int? apiarioId,
  Map<int, Apiario> indice,
  double? latitud,
  double? longitud,
) {
  if (apiarioId != null) {
    final a = indice[apiarioId];
    if (a != null) {
      return a.codigoSitran.isEmpty ? a.nombre : '${a.nombre} (${a.codigoSitran})';
    }
  }
  if (latitud != null && longitud != null) {
    return '${latitud.toStringAsFixed(4)}, ${longitud.toStringAsFixed(4)}';
  }
  return '—';
}
