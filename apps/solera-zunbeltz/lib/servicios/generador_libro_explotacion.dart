import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../l10n/app_localizations.dart';
import '../modelos/carga_ganadera.dart';
import '../modelos/constantes.dart';
import '../modelos/ganado.dart';
import '../modelos/ganado_ecologico.dart';
import 'documento_generado.dart';
import 'tema_pdf.dart';

/// El ganado del espacio, tal como está en este móvil, para el libro de
/// explotación y la hoja de movimiento.
class DatosGanado {
  const DatosGanado({
    required this.lotes,
    required this.animales,
    required this.movimientos,
    required this.eventos,
    required this.zonas,
  });

  final List<LoteGanado> lotes;
  final List<Animal> animales;
  final List<MovimientoGanado> movimientos;
  final List<EventoGanado> eventos;

  /// Nombre de cada pieza por id.
  final Map<int, String> zonas;
}

String _etiqueta(List<OpcionCatalogo> catalogo, String codigo, String idioma) =>
    codigo.isEmpty
        ? ''
        : buscarOpcion(catalogo, codigo)?.etiqueta(idioma) ?? codigo;

String _coma(double valor) => valor.toStringAsFixed(2).replaceAll('.', ',');

/// «Pasillo → Los Avellanos», «Fuera del espacio → Pasillo».
String _trayecto(MovimientoGanado movimiento, Map<int, String> zonas,
    String fueraDelEspacio) {
  String externo() => movimiento.destinoExterno.isEmpty
      ? fueraDelEspacio
      : movimiento.destinoExterno;
  final origen = movimiento.tipo == tipoMovimientoEntrada
      ? externo()
      : (zonas[movimiento.zonaOrigenId] ?? '—');
  final destino = movimiento.esSalida
      ? externo()
      : (zonas[movimiento.zonaDestinoId] ?? '—');
  return '$origen → $destino';
}

/// Las tablas del libro de explotación: censo por rebaño, animales con
/// crotal, movimientos, tratamientos y, si hay rebaños ecológicos, cómo va
/// cada uno respecto al límite de tratamientos. Pura (se prueba sin PDF).
List<TablaInforme> tablasLibroExplotacion({
  required AppLocalizations textos,
  required String idioma,
  required DatosGanado datos,
  required DateTime ahora,
}) {
  final fecha = DateFormat('dd/MM/yyyy', idioma);
  String dia(int? ms) =>
      ms == null ? '' : fecha.format(DateTime.fromMillisecondsSinceEpoch(ms));
  final lotePorId = {
    for (final lote in datos.lotes)
      if (lote.id != null) lote.id!: lote
  };
  final animalPorId = {
    for (final animal in datos.animales)
      if (animal.id != null) animal.id!: animal
  };
  List<Animal> animalesDe(LoteGanado lote) =>
      datos.animales.where((animal) => animal.loteId == lote.id).toList();
  List<EventoGanado> eventosDeLote(LoteGanado lote) => datos.eventos
      .where((evento) =>
          evento.loteId == lote.id ||
          (evento.animalId != null &&
              animalPorId[evento.animalId]?.loteId == lote.id))
      .toList();
  LoteGanado? loteDeEvento(EventoGanado evento) => evento.animalId == null
      ? lotePorId[evento.loteId]
      : lotePorId[animalPorId[evento.animalId]?.loteId];

  final censo = TablaInforme(
    titulo: textos.libroCenso,
    headers: [
      textos.libroColRebano,
      textos.libroColEspecie,
      textos.libroColPieza,
      textos.libroColCabezas,
      textos.libroColSinCrotal,
      textos.libroColUgm,
      textos.libroColEco,
    ],
    filas: [
      for (final lote in datos.lotes.where((lote) => lote.activo))
        [
          lote.nombre,
          _etiqueta(especiesGanado, lote.especie, idioma),
          () {
            final propios = datos.movimientos
                .where((movimiento) => movimiento.loteId == lote.id);
            final ultimo = ultimoMovimiento(propios);
            if (ultimo == null) return '—';
            if (ultimo.esSalida) {
              return ultimo.destinoExterno.isEmpty
                  ? textos.ganFueraDelEspacio
                  : ultimo.destinoExterno;
            }
            return datos.zonas[ultimo.zonaDestinoId] ?? '—';
          }(),
          '${cabezasDeLote(lote, animalesDe(lote))}',
          '${lote.cabezasSinIdentificar}',
          _coma(ugmDeLote(lote, animalesDe(lote), ahora)),
          lote.ecologico ? textos.libroSi : textos.libroNo,
        ],
    ],
    mensajeSiVacia: textos.ganSinLotes,
  );

  final animales = TablaInforme(
    titulo: textos.libroAnimales,
    headers: [
      textos.libroColCrotal,
      textos.libroColNombre,
      textos.libroColEspecie,
      textos.libroColRaza,
      textos.libroColSexo,
      textos.libroColNacimiento,
      textos.libroColMadre,
      textos.libroColRebano,
      textos.libroColEstado,
    ],
    filas: [
      for (final animal in datos.animales)
        [
          animal.identificacion,
          animal.nombre,
          _etiqueta(especiesGanado, animal.especie, idioma),
          animal.raza,
          _etiqueta(sexosAnimal, animal.sexo, idioma),
          dia(animal.fechaNacimientoMs),
          animal.madre,
          lotePorId[animal.loteId]?.nombre ?? '',
          [
            _etiqueta(estadosAnimal, animal.estado, idioma),
            if (!animal.activo && animal.fechaBajaMs != null)
              dia(animal.fechaBajaMs),
          ].join(' '),
        ],
    ],
  );

  final movimientos = TablaInforme(
    titulo: textos.libroMovimientos,
    headers: [
      textos.libroColFecha,
      textos.libroColRebano,
      textos.libroColTipo,
      textos.libroColTrayecto,
      textos.libroColCabezas,
      textos.libroColGuia,
    ],
    filas: [
      for (final movimiento in [
        ...datos.movimientos
      ]..sort((a, b) => a.fechaMs.compareTo(b.fechaMs)))
        [
          dia(movimiento.fechaMs),
          lotePorId[movimiento.loteId]?.nombre ?? '',
          _etiqueta(tiposMovimientoGanado, movimiento.tipo, idioma),
          _trayecto(movimiento, datos.zonas, textos.ganFueraDelEspacio),
          movimiento.cabezas > 0 ? '${movimiento.cabezas}' : '',
          movimiento.guia,
        ],
    ],
  );

  String espera(EventoGanado evento, int legal, bool ecologico) {
    final efectiva = plazoEfectivoDias(legal,
        ecologico: ecologico, clase: evento.claseMedicamento);
    if (efectiva == legal) return '$legal';
    return textos.libroEsperaEco(legal, efectiva);
  }

  final conMedicamento = [
    ...datos.eventos
        .where((evento) => tiposEventoConMedicamento.contains(evento.tipo))
  ]..sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
  final tratamientos = TablaInforme(
    titulo: textos.libroTratamientos,
    headers: [
      textos.libroColFecha,
      textos.libroColAQuien,
      textos.libroColTipo,
      textos.libroColSustancia,
      textos.libroColClase,
      textos.libroColDosis,
      textos.libroColEsperaCarne,
      textos.libroColEsperaLeche,
      textos.libroColVeterinario,
      textos.libroColReceta,
    ],
    filas: [
      for (final evento in conMedicamento)
        () {
          final ecologico = loteDeEvento(evento)?.ecologico ?? false;
          final animal = animalPorId[evento.animalId];
          return [
            dia(evento.fechaMs),
            animal != null
                ? animal.rotulo
                : lotePorId[evento.loteId]?.nombre ?? '',
            _etiqueta(tiposEventoGanado, evento.tipo, idioma),
            evento.sustanciaActiva,
            _etiqueta(clasesMedicamento, evento.claseMedicamento, idioma),
            evento.dosis,
            espera(evento, evento.plazoSupresionCarneDias, ecologico),
            espera(evento, evento.plazoSupresionLecheDias, ecologico),
            evento.veterinario,
            evento.receta,
          ];
        }(),
    ],
  );

  final lotesEcologicos =
      datos.lotes.where((lote) => lote.activo && lote.ecologico).toList();
  final ecologico = TablaInforme(
    titulo: textos.libroEcologico,
    headers: [
      textos.libroColAQuien,
      textos.libroColTratamientos,
      textos.libroColLimite,
      textos.libroColSituacion,
    ],
    filas: [
      for (final lote in lotesEcologicos) ...[
        for (final (rotulo, eventos) in [
          (lote.nombre, eventosDeLote(lote).where((e) => e.animalId == null)),
          for (final animal in animalesDe(lote).where((a) => a.activo))
            (
              animal.rotulo,
              eventosDeLote(lote)
                  .where((e) => e.animalId == null || e.animalId == animal.id)
            ),
        ])
          () {
            final estado = estadoTratamientosEcologico(eventos, ahora,
                cicloCorto: lote.cicloCorto);
            return [
              rotulo,
              '${estado.tratamientos}',
              '${estado.limite}',
              estado.superado
                  ? textos.libroEcoSuperado
                  : estado.enElLimite
                      ? textos.libroEcoEnLimite
                      : textos.libroEcoBien,
            ];
          }(),
      ],
    ],
  );

  return [
    censo,
    animales,
    movimientos,
    tratamientos,
    if (lotesEcologicos.isNotEmpty) ecologico,
  ];
}

/// El libro de explotación en PDF. PROVISIONAL: no sustituye al libro de
/// registro oficial.
Future<DocumentoGenerado> generarLibroExplotacionPdf({
  required AppLocalizations textos,
  required String idioma,
  required DatosGanado datos,
  bool definitivo = false,
}) async {
  final ahora = DateTime.now();
  final activos = datos.lotes.where((lote) => lote.activo).toList();
  var cabezas = 0;
  var ugm = 0.0;
  for (final lote in activos) {
    final suyos = datos.animales.where((animal) => animal.loteId == lote.id);
    cabezas += cabezasDeLote(lote, suyos);
    ugm += ugmDeLote(lote, suyos, ahora);
  }
  final logos = await logosPdfZunbeltz();
  final bytes = await generarInformePeriodicoPdfBytes(
    tema: await temaPdfZunbeltz(),
    logoCabecera: logos.cabecera,
    logosPie: logos.pie,
    marcaAgua: definitivo ? null : textos.marcaBorrador,
    tituloCabecera: textos.libroTitulo,
    subtituloCabecera: textos.libroSubtitulo,
    bulletsResumen: [
      textos.libroProvisional,
      textos.libroResumen(activos.length, cabezas, _coma(ugm)),
      textos.libroUgmFuente(fuenteCoeficientesUgm),
    ],
    tablas: tablasLibroExplotacion(
        textos: textos, idioma: idioma, datos: datos, ahora: ahora),
  );
  return DocumentoGenerado.pdf('libro_explotacion', bytes);
}

/// Las tablas de la hoja de un movimiento: sus datos y los animales con
/// crotal que tiene ahora el rebaño. Pura.
List<TablaInforme> tablasHojaMovimiento({
  required AppLocalizations textos,
  required String idioma,
  required MovimientoGanado movimiento,
  required LoteGanado lote,
  required List<Animal> animalesDelLote,
  required Map<int, String> zonas,
}) {
  final fecha = DateFormat('dd/MM/yyyy', idioma);
  return [
    TablaInforme(
      titulo: textos.hojaDatos,
      headers: [textos.hojaColDato, textos.hojaColValor],
      filas: [
        [
          textos.libroColFecha,
          fecha.format(DateTime.fromMillisecondsSinceEpoch(movimiento.fechaMs))
        ],
        [textos.libroColRebano, lote.nombre],
        [
          textos.libroColEspecie,
          _etiqueta(especiesGanado, lote.especie, idioma)
        ],
        [
          textos.libroColTipo,
          _etiqueta(tiposMovimientoGanado, movimiento.tipo, idioma)
        ],
        [
          textos.libroColTrayecto,
          _trayecto(movimiento, zonas, textos.ganFueraDelEspacio)
        ],
        [
          textos.libroColCabezas,
          movimiento.cabezas > 0 ? '${movimiento.cabezas}' : '—'
        ],
        [textos.libroColGuia, movimiento.guia.isEmpty ? '—' : movimiento.guia],
        [textos.libroColEco, lote.ecologico ? textos.libroSi : textos.libroNo],
        if (movimiento.notas.isNotEmpty) [textos.ganNotas, movimiento.notas],
      ],
    ),
    TablaInforme(
      titulo: textos.hojaAnimales,
      headers: [
        textos.libroColCrotal,
        textos.libroColNombre,
        textos.libroColRaza,
        textos.libroColSexo,
      ],
      filas: [
        for (final animal in animalesDelLote.where((animal) => animal.activo))
          [
            animal.identificacion,
            animal.nombre,
            animal.raza,
            _etiqueta(sexosAnimal, animal.sexo, idioma),
          ],
      ],
    ),
  ];
}

/// La hoja de un movimiento en PDF, para acompañar el traslado. No es la
/// guía oficial (la emite SITRAN).
Future<DocumentoGenerado> generarHojaMovimientoPdf({
  required AppLocalizations textos,
  required String idioma,
  required MovimientoGanado movimiento,
  required LoteGanado lote,
  required List<Animal> animalesDelLote,
  required Map<int, String> zonas,
}) async {
  final fecha = DateFormat('dd/MM/yyyy', idioma)
      .format(DateTime.fromMillisecondsSinceEpoch(movimiento.fechaMs));
  final logos = await logosPdfZunbeltz();
  final bytes = await generarInformePeriodicoPdfBytes(
    tema: await temaPdfZunbeltz(),
    logoCabecera: logos.cabecera,
    logosPie: logos.pie,
    tituloCabecera: textos.hojaTitulo,
    subtituloCabecera: textos.hojaSubtitulo(lote.nombre, fecha),
    bulletsResumen: [textos.hojaNoGuia],
    tablas: tablasHojaMovimiento(
        textos: textos,
        idioma: idioma,
        movimiento: movimiento,
        lote: lote,
        animalesDelLote: animalesDelLote,
        zonas: zonas),
  );
  return DocumentoGenerado.pdf('hoja_movimiento', bytes);
}
