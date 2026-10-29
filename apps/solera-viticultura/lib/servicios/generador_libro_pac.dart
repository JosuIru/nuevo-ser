import 'dart:io';

import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/cepa.dart';
import '../modelos/tratamiento.dart';
import '../modelos/vinedo.dart';

/// Genera el libro oficial de tratamientos fitosanitarios (PAC,
/// RD 1311/2012) en PDF firmable. Usa la plantilla `informe_periodico`
/// del core para mantener cabecera, footer y tablas consistentes con
/// el resto de informes de la suite Larrea.
///
/// **Limitación v0.1**: el formato exacto vigente del libro PAC
/// cambia con cada actualización del MAPA. Hasta validar con la
/// cooperativa o un PDF de inspección reciente, este generador
/// produce un informe **funcional pero no garantizado conforme** a
/// la última circular del MAPA. Registrado en
/// `BLOQUEOS-PENDIENTES.md` como bloqueo F1-7.
///
/// Si `vinedoId` es null se genera el libro global (todas las cepas,
/// incluidos puntos sueltos). Si `desdeMs/hastaMs` es null se hace
/// histórico completo.
Future<File> generarLibroPac({
  required Vinedo? vinedo,
  required int? desdeMs,
  required int? hastaMs,
  required int ano,
}) async {
  final db = BaseDatosSoleraViticultura.instancia;
  final titular = await db.obtenerTitular();
  final cepas = await db.listarCepas(vinedoId: vinedo?.id);
  final indiceCepasPorId = <int, Cepa>{for (final c in cepas) c.id!: c};

  // Tratamientos en el rango. Si desdeMs/hastaMs son null se queda
  // sin filtro (histórico). Para el filtro por viñedo se llama al
  // método de BD que ya lo soporta.
  final tratamientos = (desdeMs != null && hastaMs != null)
      ? await db.listarTratamientosPorVinedoYRango(
          vinedoId: vinedo?.id,
          desdeMs: desdeMs,
          hastaMs: hastaMs,
        )
      : await _listarTratamientosHistoricoDelVinedo(db, vinedo?.id, indiceCepasPorId);

  // Filtramos a tratamientos fitosanitarios — el libro PAC sólo
  // incluye productos del registro oficial. Manejo cultural (poda,
  // riego) se exporta aparte si hace falta para auditoría completa.
  final fitosanitarios = tratamientos.where((t) => t.tipo == 'fitosanitario').toList();

  final formatoFecha = DateFormat('dd/MM/yyyy');
  final tituloCabecera = vinedo == null
      ? 'Libro de tratamientos · todas las parcelas'
      : 'Libro de tratamientos · ${vinedo.nombre}';
  final subtituloCabecera = 'Campaña $ano · RD 1311/2012';

  final bullets = <String>[
    'Titular: ${titular.nombre.isEmpty ? "—" : titular.nombre} · NIF ${titular.nif.isEmpty ? "—" : titular.nif}',
    if (titular.numeroRegepa.isNotEmpty) 'REGEPA: ${titular.numeroRegepa}',
    if (titular.direccion.isNotEmpty) 'Dirección: ${titular.direccion}',
    if (titular.nombreAsesor.isNotEmpty)
      'Asesor: ${titular.nombreAsesor} · NIF ${titular.nifAsesor.isEmpty ? "—" : titular.nifAsesor} · Reg. ${titular.numeroRegistroAsesor.isEmpty ? "—" : titular.numeroRegistroAsesor}',
    if (titular.nombreAplicador.isNotEmpty)
      'Aplicador: ${titular.nombreAplicador} · NIF ${titular.nifAplicador.isEmpty ? "—" : titular.nifAplicador} · Carnet ${titular.carnetAplicador.isEmpty ? "—" : titular.carnetAplicador} (${titular.nivelCarnetAplicador.isEmpty ? "—" : titular.nivelCarnetAplicador})',
    if (vinedo != null && vinedo.referenciaSigpac.isNotEmpty) 'SIGPAC: ${vinedo.referenciaSigpac}',
    if (vinedo != null && vinedo.superficieHectareas != null)
      'Superficie: ${vinedo.superficieHectareas!.toStringAsFixed(2)} ha',
    'Tratamientos fitosanitarios registrados: ${fitosanitarios.length}',
  ];

  // Tabla principal: cada fila un tratamiento fitosanitario con los
  // 9 campos exigidos por inspección PAC en el formato de papel
  // común (mantenemos columnas estándar del libro de campo).
  final filasTratamientos = [
    for (final t in fitosanitarios)
      [
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(t.fechaMs)),
        _etiquetaCepa(indiceCepasPorId[t.cepaId]),
        t.producto,
        t.numeroRegistroFitosanitario.isEmpty ? '—' : t.numeroRegistroFitosanitario,
        t.dosis,
        t.motivo,
        t.plazoSeguridadDias?.toString() ?? '—',
        t.superficieTratadaHectareas?.toStringAsFixed(2) ?? '—',
        t.nifAplicador.isEmpty ? (titular.nifAplicador.isEmpty ? '—' : titular.nifAplicador) : t.nifAplicador,
      ],
  ];

  return generarInformePeriodicoPdf(
    tema: await temaPdfSolera(),
    tituloCabecera: tituloCabecera,
    subtituloCabecera: subtituloCabecera,
    bulletsResumen: bullets,
    tablas: [
      TablaInforme(
        titulo: 'Tratamientos fitosanitarios',
        headers: const [
          'Fecha',
          'Cepa',
          'Producto',
          'Nº reg.',
          'Dosis',
          'Motivo',
          'PS (días)',
          'Sup. (ha)',
          'NIF aplicador',
        ],
        filas: filasTratamientos,
        mensajeSiVacia: 'Sin tratamientos fitosanitarios registrados en el periodo.',
      ),
    ],
    prefijoNombreFichero: 'libro_pac-${vinedo?.nombre ?? "todas"}-$ano',
    operador: titular.nombre.isEmpty ? null : titular.nombre,
  );
}

String _etiquetaCepa(Cepa? cepa) {
  if (cepa == null) return '—';
  if (cepa.etiqueta.isNotEmpty) return cepa.etiqueta;
  return '#${cepa.id}';
}

/// Histórico completo del viñedo (sin filtro de fechas). Recolecta
/// tratamientos por cepa y los agrega. N+1 consultas — comportamiento
/// heredado de la suite Larrea, aceptable para volúmenes de <10k cepas.
Future<List<Tratamiento>> _listarTratamientosHistoricoDelVinedo(
  BaseDatosSoleraViticultura db,
  int? vinedoId,
  Map<int, Cepa> indiceCepas,
) async {
  final cepas = vinedoId == null
      ? indiceCepas.values.toList()
      : indiceCepas.values.where((c) => c.vinedoId == vinedoId).toList();
  final todos = <Tratamiento>[];
  for (final c in cepas) {
    todos.addAll(await db.listarTratamientosDeCepa(c.id!));
  }
  todos.sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
  return todos;
}
