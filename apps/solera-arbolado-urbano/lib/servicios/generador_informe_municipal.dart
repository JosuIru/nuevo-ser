import 'dart:io';

import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_especies_arboreas.dart';
import '../datos/catalogos_generados/catalogo_plagas_urbanas.dart';
import '../datos/catalogos_generados/catalogo_tipos_poda.dart';
import '../modelos/arbol.dart';
import '../modelos/tecnico.dart';
import '../modelos/zona.dart';

/// Genera el informe municipal de actuaciones sobre arbolado urbano en
/// PDF firmable. Usa la plantilla `informe_periodico` del core para
/// mantener cabecera, footer y tablas consistentes con el resto de la
/// suite Solera.
///
/// **Limitación v0.1**: el formato exacto del parte municipal varía
/// entre ayuntamientos (Madrid, Barcelona, Vitoria, Iruña… cada uno
/// tiene su pliego). Hasta validar con un ayuntamiento real, este
/// generador produce un informe **funcional pero no garantizado
/// conforme** a un pliego concreto. Registrado en
/// `BLOQUEOS-PENDIENTES.md` como bloqueo F1U-5.
///
/// Si `zona` es null se genera el informe global (todos los árboles
/// del municipio).
Future<File> generarInformeMunicipal({
  required Zona? zona,
  required int desdeMs,
  required int hastaMs,
  required int ano,
}) async {
  final db = BaseDatosSoleraArbolado.instancia;
  final ayuntamiento = await db.obtenerAyuntamiento();
  final arboles = await db.listarArboles(zonaId: zona?.id);
  final indiceArbolesPorId = <int, Arbol>{for (final a in arboles) a.id!: a};
  final tecnicos = await db.listarTecnicos();
  final indiceTecnicosPorId = <int, Tecnico>{for (final t in tecnicos) t.id!: t};

  final inspecciones = await db.listarInspeccionesPorZonaYRango(
    zonaId: zona?.id,
    desdeMs: desdeMs,
    hastaMs: hastaMs,
  );
  final podas = await db.listarPodasPorZonaYRango(
    zonaId: zona?.id,
    desdeMs: desdeMs,
    hastaMs: hastaMs,
  );
  final tratamientos = await db.listarTratamientosPorZonaYRango(
    zonaId: zona?.id,
    desdeMs: desdeMs,
    hastaMs: hastaMs,
  );
  final incidencias = await db.listarIncidenciasPorZonaYRango(
    zonaId: zona?.id,
    desdeMs: desdeMs,
    hastaMs: hastaMs,
  );

  final formatoFecha = DateFormat('dd/MM/yyyy');
  final tituloCabecera = zona == null
      ? 'Informe municipal · todo el municipio'
      : 'Informe municipal · ${zona.nombre}';
  final subtituloCabecera = 'Campaña $ano';

  final bullets = <String>[
    'Ayuntamiento: ${ayuntamiento.nombre.isEmpty ? "—" : ayuntamiento.nombre} · CIF ${ayuntamiento.cif.isEmpty ? "—" : ayuntamiento.cif}',
    if (ayuntamiento.municipio.isNotEmpty)
      'Municipio: ${ayuntamiento.municipio}'
          '${ayuntamiento.provincia.isEmpty ? "" : " (${ayuntamiento.provincia})"}',
    if (ayuntamiento.concejalia.isNotEmpty)
      'Concejalía: ${ayuntamiento.concejalia}'
          '${ayuntamiento.nombreConcejal.isEmpty ? "" : " · responsable ${ayuntamiento.nombreConcejal}"}',
    if (zona != null && zona.codigoMunicipal.isNotEmpty)
      'Código municipal de la zona: ${zona.codigoMunicipal}',
    'Árboles censados en el ámbito: ${arboles.length}',
    'Inspecciones registradas: ${inspecciones.length}',
    'Podas registradas: ${podas.length}',
    'Tratamientos fitosanitarios registrados: ${tratamientos.length}',
    'Incidencias registradas: ${incidencias.length}',
  ];

  final filasInspecciones = [
    for (final i in inspecciones)
      [
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(i.fechaMs)),
        _identificadorArbol(indiceArbolesPorId[i.arbolId]),
        i.estado,
        i.riesgoVta?.toString() ?? '—',
        i.fenologia.isEmpty ? '—' : i.fenologia,
        _firmaTecnico(i.tecnicoId, indiceTecnicosPorId),
      ],
  ];

  final filasPodas = [
    for (final p in podas)
      [
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(p.fechaMs)),
        _identificadorArbol(indiceArbolesPorId[p.arbolId]),
        _nombreTipoPoda(p.tipoPodaId),
        p.volumenRestosM3?.toStringAsFixed(2) ?? '—',
        p.motivo.isEmpty ? '—' : p.motivo,
        _firmaTecnico(p.tecnicoId, indiceTecnicosPorId),
      ],
  ];

  final filasTratamientos = [
    for (final t in tratamientos)
      [
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(t.fechaMs)),
        _identificadorArbol(indiceArbolesPorId[t.arbolId]),
        t.sustanciaActivaId.isEmpty ? '—' : t.sustanciaActivaId,
        t.dosis.isEmpty ? '—' : t.dosis,
        _nombrePlaga(t.motivoIdPlaga),
        t.loteProducto.isEmpty ? '—' : t.loteProducto,
        _firmaTecnico(t.tecnicoId, indiceTecnicosPorId),
      ],
  ];

  final filasIncidencias = [
    for (final i in incidencias)
      [
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(i.fechaMs)),
        _identificadorArbol(indiceArbolesPorId[i.arbolId]),
        i.tipo,
        i.descripcion.isEmpty ? '—' : i.descripcion,
        i.severidad?.toString() ?? '—',
        i.resuelta
            ? (i.fechaResolucionMs == null
                ? 'Resuelta'
                : 'Resuelta ${formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(i.fechaResolucionMs!))}')
            : 'Abierta',
      ],
  ];

  // Resumen del censo: contar árboles por especie. Útil para concejalía.
  final conteoEspecies = <String, int>{};
  for (final a in arboles) {
    if (a.especieId.isEmpty) continue;
    conteoEspecies[a.especieId] = (conteoEspecies[a.especieId] ?? 0) + 1;
  }
  final filasCenso = conteoEspecies.entries
      .map((e) => [_nombreEspecie(e.key), e.value.toString()])
      .toList()
    ..sort((a, b) => int.parse(b[1]).compareTo(int.parse(a[1])));

  return generarInformePeriodicoPdf(
    tema: await temaPdfSolera(),
    tituloCabecera: tituloCabecera,
    subtituloCabecera: subtituloCabecera,
    bulletsResumen: bullets,
    tablas: [
      TablaInforme(
        titulo: 'Censo por especie',
        headers: const ['Especie', 'Nº de árboles'],
        filas: filasCenso,
        mensajeSiVacia: 'Sin árboles censados con especie identificada.',
      ),
      TablaInforme(
        titulo: 'Inspecciones',
        headers: const ['Fecha', 'Árbol', 'Estado', 'VTA', 'Fenología', 'Técnico'],
        filas: filasInspecciones,
        mensajeSiVacia: 'Sin inspecciones registradas en el periodo.',
      ),
      TablaInforme(
        titulo: 'Podas',
        headers: const ['Fecha', 'Árbol', 'Tipo', 'Restos (m³)', 'Motivo', 'Técnico'],
        filas: filasPodas,
        mensajeSiVacia: 'Sin podas registradas en el periodo.',
      ),
      TablaInforme(
        titulo: 'Tratamientos fitosanitarios',
        headers: const [
          'Fecha',
          'Árbol',
          'Sustancia',
          'Dosis',
          'Plaga objetivo',
          'Lote',
          'Técnico',
        ],
        filas: filasTratamientos,
        mensajeSiVacia: 'Sin tratamientos fitosanitarios registrados en el periodo.',
      ),
      TablaInforme(
        titulo: 'Incidencias',
        headers: const ['Fecha', 'Árbol', 'Tipo', 'Descripción', 'Severidad', 'Estado'],
        filas: filasIncidencias,
        mensajeSiVacia: 'Sin incidencias registradas en el periodo.',
      ),
    ],
    prefijoNombreFichero: 'informe_municipal-${zona?.nombre ?? "todo"}-$ano',
    operador: ayuntamiento.nombre.isEmpty ? null : ayuntamiento.nombre,
  );
}

String _identificadorArbol(Arbol? arbol) {
  if (arbol == null) return '—';
  return arbol.identificadorMunicipal;
}

String _firmaTecnico(int? tecnicoId, Map<int, Tecnico> indice) {
  if (tecnicoId == null) return 'Sin firmar';
  final t = indice[tecnicoId];
  if (t == null) return 'Sin firmar';
  return t.empresaContratista.isEmpty
      ? t.nombre
      : '${t.nombre} (${t.empresaContratista})';
}

String _nombreEspecie(String id) {
  if (id.isEmpty) return '—';
  final canonica = especiePorId(id);
  return canonica?.nombreCanonico ?? id;
}

String _nombrePlaga(String id) {
  if (id.isEmpty) return '—';
  final canonica = plagaUrbanaPorId(id);
  return canonica?.nombreComun ?? id;
}

String _nombreTipoPoda(String id) {
  if (id.isEmpty) return '—';
  final canonica = tipoPodaPorId(id);
  return canonica?.nombreCanonico ?? id;
}
