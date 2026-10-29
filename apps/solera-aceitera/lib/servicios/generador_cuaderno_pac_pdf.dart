import 'dart:io';

import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/campania.dart';
import '../modelos/parcela.dart';
import '../modelos/titular.dart';

/// Genera el Cuaderno de Explotación PAC del olivar en PDF firmable.
/// Cubre los dos bloques de eventos que la inspección OCA / OAPN
/// revisa al abrir el cuaderno de campo:
///
///  1. **Tratamientos fitosanitarios** (RD 1311/2012) — sustancia
///     activa, plaga objetivo, dosis, fecha, NIF/carnet del aplicador,
///     parcela y código SIGPAC.
///  2. **Recolección** — parte diario por parcela: kg estimados,
///     tipo de aceituna (verde/envero/negra), método (vibrador,
///     manual, paraguas, peine, vareo) y cuadrilla.
///
/// La plantilla `informe_periodico` del core mantiene cabecera,
/// footer y tablas en el mismo estilo que el resto de la suite
/// Larrea. Si `parcela` es null se genera el cuaderno global
/// (todas las parcelas del olivar).
///
/// **Limitación PROVISIONAL v0.1**: el formato exacto vigente del
/// Cuaderno PAC olivar cambia con cada actualización del MAPA. El
/// subtítulo del PDF lleva el sello `PROVISIONAL` literal hasta que
/// un técnico OCA real lo audite — registrado como bloqueo F1-A4
/// en `BLOQUEOS-PENDIENTES.md` y custodiado por el test guardrail
/// `test/sello_provisional_test.dart`.
Future<File> generarCuadernoPacOlivar({
  required Campania campania,
  required Parcela? parcela,
}) async {
  final basedatos = BaseDatosSoleraAceitera.instancia;
  final titular = await basedatos.obtenerTitular();
  final olivar = await basedatos.obtenerOlivar();
  final parcelas = await basedatos.listarParcelas();
  final indiceParcelasPorId = <int, Parcela>{
    for (final p in parcelas)
      if (p.id != null) p.id!: p,
  };

  // Recolecciones de la campaña filtradas por parcela si procede.
  final recoleccionesCampania =
      await basedatos.listarRecolecciones(campaniaId: campania.id);
  final recoleccionesFiltradas = parcela == null
      ? recoleccionesCampania
      : recoleccionesCampania.where((r) => r.parcelaId == parcela.id).toList();

  // Tratamientos del periodo de la campaña filtrados por parcela si
  // procede. `listarTratamientos` admite filtro por parcela; el
  // filtro temporal lo aplicamos en memoria sobre el rango de la
  // campaña, que en una almazara pequeña no supera unos cientos
  // por año.
  final desdeMs = campania.fechaInicioMs;
  final hastaMs = campania.fechaFinMs ?? DateTime.now().millisecondsSinceEpoch;
  final tratamientosTodos = parcela == null
      ? await basedatos.listarTratamientos()
      : await basedatos.listarTratamientos(parcelaId: parcela.id);
  final tratamientosFiltrados = tratamientosTodos
      .where((t) => t.fechaMs >= desdeMs && t.fechaMs <= hastaMs)
      .toList();

  final formatoFecha = DateFormat('dd/MM/yyyy');

  final ambito = parcela == null
      ? 'todas las parcelas'
      : (parcela.nombre.isEmpty ? 'parcela sin nombre' : parcela.nombre);
  final tituloCabecera = 'Cuaderno de Explotación PAC olivar · $ambito';
  final subtituloCabecera =
      'Campaña ${campania.anyoComercial}/${campania.anyoComercial + 1}'
      ' · RD 1311/2012 · PROVISIONAL';

  final bulletsResumen = <String>[
    'Titular: ${_etiquetaTitularRazonSocial(titular)} · NIF ${_etiquetaNif(titular)}',
    if (titular != null && titular.numeroAica.isNotEmpty)
      'AICA: ${titular.numeroAica}',
    if (titular != null && titular.rgseaa.isNotEmpty)
      'RGSEAA: ${titular.rgseaa}',
    if (titular != null && titular.direccion.isNotEmpty)
      'Dirección: ${titular.direccion}',
    if (olivar != null && olivar.nombre.isNotEmpty)
      'Olivar: ${olivar.nombre}'
          '${olivar.municipio.isNotEmpty ? " · ${olivar.municipio}" : ""}'
          '${olivar.provincia.isNotEmpty ? " (${olivar.provincia})" : ""}',
    if (olivar != null && olivar.certificacionEcologico)
      'Certificación: ecológico',
    if (olivar != null && olivar.certificacionIntegrada)
      'Certificación: producción integrada',
    if (olivar != null && olivar.dopId.isNotEmpty) 'DOP: ${olivar.dopId}',
    if (parcela != null && parcela.codigoSigpac.isNotEmpty)
      'SIGPAC: ${parcela.codigoSigpac}',
    if (parcela != null && parcela.superficieHa > 0)
      'Superficie: ${parcela.superficieHa.toStringAsFixed(2)} ha',
    'Recolecciones registradas en la campaña: ${recoleccionesFiltradas.length}',
    'Tratamientos fitosanitarios registrados en la campaña: ${tratamientosFiltrados.length}',
  ];

  final filasTratamientos = [
    for (final t in tratamientosFiltrados)
      [
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(t.fechaMs)),
        _etiquetaParcela(indiceParcelasPorId[t.parcelaId]),
        t.productoComercialReferencia.isEmpty
            ? '—'
            : t.productoComercialReferencia,
        t.sustanciaActivaId.isEmpty ? '—' : t.sustanciaActivaId,
        t.dosisLitrosPorHa > 0 ? t.dosisLitrosPorHa.toStringAsFixed(2) : '—',
        t.plagaObjetivoId.isEmpty ? '—' : t.plagaObjetivoId,
        t.aplicadorNombre.isEmpty ? '—' : t.aplicadorNombre,
        t.carnetAplicadorNumero.isEmpty ? '—' : t.carnetAplicadorNumero,
      ],
  ];

  final filasRecolecciones = [
    for (final r in recoleccionesFiltradas)
      [
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(r.fechaMs)),
        _etiquetaParcela(indiceParcelasPorId[r.parcelaId]),
        r.kgEstimados > 0 ? r.kgEstimados.toStringAsFixed(0) : '—',
        r.tipoAceituna,
        r.metodo,
        r.cuadrilla.isEmpty ? '—' : r.cuadrilla,
      ],
  ];

  final prefijoCampania = '${campania.anyoComercial}-${campania.anyoComercial + 1}';
  final prefijoParcela = parcela == null
      ? 'todas'
      : (parcela.nombre.isEmpty ? 'sin-nombre' : _slug(parcela.nombre));

  return generarInformePeriodicoPdf(
    tema: await temaPdfSolera(),
    tituloCabecera: tituloCabecera,
    subtituloCabecera: subtituloCabecera,
    bulletsResumen: bulletsResumen,
    tablas: [
      TablaInforme(
        titulo: 'Tratamientos fitosanitarios',
        headers: const [
          'Fecha',
          'Parcela',
          'Producto',
          'Sustancia activa',
          'Dosis (l/ha)',
          'Plaga objetivo',
          'Aplicador',
          'Carnet',
        ],
        filas: filasTratamientos,
        mensajeSiVacia:
            'Sin tratamientos fitosanitarios registrados en esta campaña.',
      ),
      TablaInforme(
        titulo: 'Recolección',
        headers: const [
          'Fecha',
          'Parcela',
          'Kg estimados',
          'Tipo aceituna',
          'Método',
          'Cuadrilla',
        ],
        filas: filasRecolecciones,
        mensajeSiVacia:
            'Sin partes de recolección registrados en esta campaña.',
      ),
    ],
    prefijoNombreFichero: 'cuaderno_pac_olivar-$prefijoParcela-$prefijoCampania',
    operador: (titular == null || titular.razonSocial.isEmpty)
        ? null
        : titular.razonSocial,
  );
}

String _etiquetaTitularRazonSocial(Titular? titular) {
  if (titular == null || titular.razonSocial.isEmpty) return '—';
  return titular.razonSocial;
}

String _etiquetaNif(Titular? titular) {
  if (titular == null || titular.nif.isEmpty) return '—';
  return titular.nif;
}

String _etiquetaParcela(Parcela? parcela) {
  if (parcela == null) return '—';
  if (parcela.nombre.isNotEmpty) return parcela.nombre;
  if (parcela.codigoSigpac.isNotEmpty) return parcela.codigoSigpac;
  return '#${parcela.id ?? "—"}';
}

/// Slug minimalista para el nombre del fichero — evita espacios y
/// caracteres conflictivos en el sistema de ficheros sin meter
/// dependencias extra.
String _slug(String entrada) {
  final sinAcentos = entrada
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâã]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöôõ]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll('ñ', 'n');
  final filtrado = sinAcentos.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  return filtrado.replaceAll(RegExp(r'^-+|-+$'), '');
}
