import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../estado/datos_ganado.dart';
import '../modelos/explotacion.dart';
import '../modelos/ganado.dart';
import '../modelos/ganado_ecologico.dart';
import '../modelos/titular.dart';
import '../modelos/visita.dart';
import '../utiles/textos_ganadera.dart';
import '../utiles/trayecto_movimiento.dart';

/// Sello hasta que un veterinario asesor valide el formato con el anexo V
/// del RD 787/2023 y el modelo de la comunidad autónoma. Lo vigila
/// test/sello_provisional_test.dart.
const String selloLibroRegistro = 'PROVISIONAL';

/// Fuente con la que se ha montado el libro (se imprime en el PDF).
const String fuenteLibroRegistro =
    'RD 787/2023, art. 23 y anexo V (BOE-A-2023-22499, consolidado '
    '24/12/2024); RD 666/2023, art. 41, y Reglamento (UE) 2019/6, art. 108.2, '
    'consultados el 2026-11-07';

bool _enPeriodo(int fechaMs, DateTime desde, DateTime hasta) {
  final fecha = DateTime.fromMillisecondsSinceEpoch(fechaMs);
  return !fecha.isBefore(desde) && fecha.isBefore(hasta);
}

/// Las tablas del libro de registro de la explotación (pura). Siguen los
/// puntos del anexo V del RD 787/2023: datos de la explotación (1-5),
/// incidencias de enfermedad (6), cambios de producción o bienestar (7),
/// identificación (8), entradas (9), salidas (10) y visitas (11); más el
/// registro de tratamientos del art. 41 del RD 666/2023.
List<TablaInforme> tablasLibroRegistro({
  required Titular titular,
  required Explotacion explotacion,
  required DatosGanado datos,
  required List<Visita> visitas,
  required DateTime desde,
  required DateTime hasta,
  required DateTime ahora,
}) {
  String t(String clave) => SoleraL10n.t(clave);
  final lotes = datos.lotesPorId;
  final animales = {
    for (final animal in datos.animales)
      if (animal.id != null) animal.id!: animal
  };
  final piezas = datos.nombresPiezas;
  String aQuien(EventoGanado evento) =>
      animales[evento.animalId]?.rotulo ?? lotes[evento.loteId]?.nombre ?? '';
  LoteGanado? loteDe(EventoGanado evento) => evento.animalId == null
      ? lotes[evento.loteId]
      : lotes[animales[evento.animalId]?.loteId];
  final movimientos = [
    ...datos.movimientos
        .where((movimiento) => _enPeriodo(movimiento.fechaMs, desde, hasta))
  ]..sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
  final eventos = [
    ...datos.eventos.where((evento) => _enPeriodo(evento.fechaMs, desde, hasta))
  ]..sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
  List<String> filaExterna(MovimientoGanado movimiento) => [
        formatearFecha(movimiento.fechaMs),
        lotes[movimiento.loteId]?.nombre ?? '',
        movimiento.explotacionExterna,
        [movimiento.titularExterno, movimiento.municipioExterno]
            .where((parte) => parte.isNotEmpty)
            .join(', '),
        movimiento.codigoRemo,
        movimiento.cabezas > 0 ? '${movimiento.cabezas}' : '',
        movimiento.identificaciones,
      ];
  final cabeceraExterna = [
    t('gana.fecha'),
    t('gana.rebano'),
    t('gana.col_rega'),
    t('gana.col_titular_direccion'),
    t('gana.col_remo'),
    t('gana.col_numero'),
    t('gana.col_identificacion'),
  ];
  String espera(EventoGanado evento, int legal) {
    final ecologico = loteDe(evento)?.ecologico ?? false;
    final efectiva = plazoEfectivoDias(legal,
        ecologico: ecologico, clase: evento.claseMedicamento);
    return efectiva == legal ? '$legal' : '$legal → $efectiva (eco)';
  }

  List<String> filaIncidencia(EventoGanado evento) => [
        formatearFecha(evento.fechaMs),
        aQuien(evento),
        evento.descripcion,
      ];
  final cabeceraIncidencia = [
    t('gana.fecha'),
    t('gana.col_animales_afectados'),
    t('gana.descripcion'),
  ];

  return [
    TablaInforme(
      titulo: t('gana.libro_datos_explotacion'),
      headers: [t('gana.col_dato'), t('gana.col_valor')],
      filas: [
        [t('gana.codigo_rega'), explotacion.codigoRega],
        [
          t('gana.nombre_explotacion'),
          [
            explotacion.nombre,
            explotacion.direccion,
            explotacion.municipio,
            explotacion.provincia
          ].where((parte) => parte.isNotEmpty).join(', ')
        ],
        if (explotacion.latitud != null && explotacion.longitud != null)
          [
            t('gana.col_coordenadas'),
            '${explotacion.latitud!.toStringAsFixed(5)}, '
                '${explotacion.longitud!.toStringAsFixed(5)}'
          ],
        [
          t('gana.titular'),
          [
            titular.nombre,
            titular.nif,
            titular.telefono,
            titular.correo,
            titular.direccion
          ].where((parte) => parte.isNotEmpty).join(' · ')
        ],
        [
          t('gana.especies_autorizadas'),
          (explotacion.especies.toList()..sort()).map(nombreEspecie).join(', ')
        ],
        [t('gana.clasificacion'), explotacion.clasificacion],
        if (explotacion.capacidadMaxima > 0)
          [t('gana.capacidad_maxima'), '${explotacion.capacidadMaxima}'],
      ],
    ),
    TablaInforme(
      titulo: t('gana.libro_censo'),
      headers: [
        t('gana.rebano'),
        t('gana.especie'),
        t('gana.col_pieza'),
        t('gana.cabezas'),
        t('gana.cabezas_sin_identificar'),
        t('gana.ugm_pac'),
        t('gana.ecologico'),
      ],
      filas: [
        for (final lote in datos.lotes.where((lote) => lote.activo))
          () {
            final suyos = datos.animales
                .where((animal) => animal.loteId == lote.id)
                .toList();
            final pieza = piezaActualDeLote(datos.movimientos
                .where((movimiento) => movimiento.loteId == lote.id));
            return [
              lote.nombre,
              nombreEspecie(lote.especie),
              pieza == null ? '—' : piezas[pieza] ?? '—',
              '${cabezasDeLote(lote, suyos)}',
              '${lote.cabezasSinIdentificar}',
              formatearNumero(ugmDeLote(lote, suyos, ahora, tablaUgmPantallas),
                  decimales: 2),
              lote.ecologico ? t('gana.si') : t('gana.no'),
            ];
          }(),
      ],
      mensajeSiVacia: t('gana.sin_rebanos'),
    ),
    TablaInforme(
      titulo: t('gana.libro_identificacion'),
      headers: [
        t('gana.col_identificacion'),
        t('gana.dispositivo'),
        t('gana.especie'),
        t('gana.raza'),
        t('gana.sexo'),
        t('gana.fecha_nacimiento'),
        t('gana.madre'),
        t('gana.rebano'),
        t('gana.estado'),
      ],
      filas: [
        for (final animal in datos.animales)
          [
            animal.identificacion,
            nombreDispositivo(animal.dispositivo),
            nombreEspecie(animal.especie),
            animal.raza,
            nombreSexo(animal.sexo),
            formatearFecha(animal.fechaNacimientoMs),
            animal.madre,
            lotes[animal.loteId]?.nombre ?? '',
            [
              nombreEstadoAnimal(animal.estado),
              if (!animal.activo) formatearFecha(animal.fechaBajaMs),
            ].join(' '),
          ],
      ],
      mensajeSiVacia: t('gana.sin_animales'),
    ),
    TablaInforme(
      titulo: t('gana.libro_entradas'),
      headers: cabeceraExterna,
      filas: [
        for (final movimiento in movimientos)
          if (movimiento.esEntradaEnExplotacion) filaExterna(movimiento)
      ],
      mensajeSiVacia: t('gana.sin_movimientos'),
    ),
    TablaInforme(
      titulo: t('gana.libro_salidas'),
      headers: cabeceraExterna,
      filas: [
        for (final movimiento in movimientos)
          if (movimiento.esSalidaDeExplotacion) filaExterna(movimiento)
      ],
      mensajeSiVacia: t('gana.sin_movimientos'),
    ),
    TablaInforme(
      titulo: t('gana.libro_traslados_internos'),
      headers: [
        t('gana.fecha'),
        t('gana.rebano'),
        t('gana.col_trayecto'),
        t('gana.cabezas'),
      ],
      filas: [
        for (final movimiento in movimientos)
          if (movimiento.tipo == tipoMovimientoTraslado)
            [
              formatearFecha(movimiento.fechaMs),
              lotes[movimiento.loteId]?.nombre ?? '',
              trayectoMovimiento(movimiento, piezas),
              movimiento.cabezas > 0 ? '${movimiento.cabezas}' : '',
            ]
      ],
      mensajeSiVacia: t('gana.sin_movimientos'),
    ),
    TablaInforme(
      titulo: t('gana.libro_tratamientos'),
      headers: [
        t('gana.col_fecha_primera'),
        t('gana.col_animales_tratados'),
        t('gana.col_medicamento'),
        t('gana.sustancia_activa'),
        t('gana.col_cantidad'),
        t('gana.col_duracion'),
        t('gana.col_espera_carne'),
        t('gana.col_espera_leche'),
        t('gana.col_veterinario_receta'),
        t('gana.col_proveedor_compra'),
      ],
      filas: [
        for (final evento in eventos)
          if (evento.llevaMedicamento)
            [
              formatearFecha(evento.fechaMs),
              [
                aQuien(evento),
                if (evento.cabezas > 0) '(${evento.cabezas})',
              ].join(' '),
              evento.medicamento,
              evento.sustanciaActiva,
              evento.dosis,
              evento.duracionDias > 0 ? '${evento.duracionDias}' : '',
              espera(evento, evento.plazoSupresionCarneDias),
              espera(evento, evento.plazoSupresionLecheDias),
              [evento.veterinario, evento.receta]
                  .where((parte) => parte.isNotEmpty)
                  .join(' · '),
              [evento.proveedor, evento.pruebaCompra]
                  .where((parte) => parte.isNotEmpty)
                  .join(' · '),
            ]
      ],
      mensajeSiVacia: t('gana.sin_tratamientos'),
    ),
    TablaInforme(
      titulo: t('gana.libro_enfermedades'),
      headers: cabeceraIncidencia,
      filas: [
        for (final evento in eventos)
          if (evento.tipo == tipoEventoEnfermedad) filaIncidencia(evento)
      ],
      mensajeSiVacia: t('gana.sin_incidencias'),
    ),
    TablaInforme(
      titulo: t('gana.libro_bienestar'),
      headers: cabeceraIncidencia,
      filas: [
        for (final evento in eventos)
          if (evento.tipo == tipoEventoBienestar) filaIncidencia(evento)
      ],
      mensajeSiVacia: t('gana.sin_incidencias'),
    ),
    TablaInforme(
      titulo: t('gana.libro_visitas'),
      headers: [
        t('gana.fecha'),
        t('gana.quien'),
        t('gana.motivo'),
        t('gana.matricula_vehiculo'),
        t('gana.col_veterinaria'),
      ],
      filas: [
        for (final visita in visitas)
          if (_enPeriodo(visita.fechaMs, desde, hasta))
            [
              formatearFecha(visita.fechaMs),
              visita.persona,
              visita.motivo,
              visita.vehiculo,
              visita.esVeterinaria ? t('gana.si') : t('gana.no'),
            ]
      ],
      mensajeSiVacia: t('gana.sin_visitas'),
    ),
  ];
}

/// El libro de registro de la explotación del periodo [desde, hasta).
Future<Uint8List> generarLibroRegistroPdf({
  required Titular titular,
  required Explotacion explotacion,
  required DatosGanado datos,
  required List<Visita> visitas,
  required DateTime desde,
  required DateTime hasta,
  pw.ThemeData? tema,
}) {
  final ahora = DateTime.now();
  return generarInformePeriodicoPdfBytes(
    tituloCabecera: SoleraL10n.t('gana.libro_registro'),
    subtituloCabecera: [
      explotacion.codigoRega,
      titular.nombre,
      '${formatearDia(desde)} – '
          '${formatearDia(hasta.subtract(const Duration(days: 1)))}',
      selloLibroRegistro,
    ].where((parte) => parte.isNotEmpty).join(' · '),
    bulletsResumen: [
      SoleraL10n.t('gana.libro_aviso_provisional'),
      SoleraL10n.t('gana.aviso_no_sustituye'),
      '${SoleraL10n.t('gana.fuente')}: $fuenteLibroRegistro',
    ],
    tablas: tablasLibroRegistro(
        titular: titular,
        explotacion: explotacion,
        datos: datos,
        visitas: visitas,
        desde: desde,
        hasta: hasta,
        ahora: ahora),
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    marcaAgua: selloLibroRegistro,
    tema: tema,
  );
}
