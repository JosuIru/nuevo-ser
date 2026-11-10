import 'dart:convert';
import 'dart:math' as math;

/// Planificador hacia atrás: «quiero el pan listo a las HH:MM del día D»
/// → a qué hora empieza cada fase.
///
/// Lógica pura (sin Flutter) con tests en
/// `test/dominio/planificador_hornada_test.dart`.

/// Fases de una hornada, en orden. El nombre (`name`) se guarda en la BD:
/// no renombrar.
enum FaseHornada {
  refrescoMasaMadre,
  autolisis,
  amasado,
  primeraFermentacion,
  formado,
  fermentacionFinal,
  precalentarHorno,
  coccion,
  enfriado;

  /// Las que dependen de la temperatura de la cocina (levaduras y bacterias).
  bool get esFermentacion =>
      this == refrescoMasaMadre ||
      this == primeraFermentacion ||
      this == fermentacionFinal;

  /// Precalentar el horno se hace **a la vez** que la fermentación final:
  /// termina cuando empieza la cocción y no retrasa las fases anteriores.
  bool get vaEnParalelo => this == precalentarHorno;

  static FaseHornada? porNombre(String nombre) {
    for (final fase in values) {
      if (fase.name == nombre) return fase;
    }
    return null;
  }
}

/// Tiempo de una fase en una receta: un rango en minutos a la temperatura
/// de referencia de la receta. El plan usa el punto medio y enseña el
/// rango.
class TiempoFase {
  const TiempoFase(this.fase, this.minutosMin, this.minutosMax,
      {this.enNevera = false, this.alternativaNevera});

  final FaseHornada fase;
  final int minutosMin;
  final int minutosMax;

  /// La fase va en la nevera (unos 4 °C): no se ajusta por la temperatura
  /// de la cocina.
  final bool enNevera;

  /// Si la receta permite hacer esta fase en la nevera (de noche), su tiempo
  /// allí. La persona elige al planificar.
  final TiempoFase? alternativaNevera;

  int get minutosMedios => ((minutosMin + minutosMax) / 2).round();

  Map<String, Object?> aMapa() => {
        'fase': fase.name,
        'min': minutosMin,
        'max': minutosMax,
        if (enNevera) 'nevera': true,
        if (alternativaNevera case final alternativa?)
          'alternativa_nevera': alternativa.aMapa(),
      };

  static TiempoFase? deMapa(Map<String, Object?> mapa) {
    final fase = FaseHornada.porNombre('${mapa['fase']}');
    if (fase == null) return null;
    final alternativa = mapa['alternativa_nevera'];
    return TiempoFase(
      fase,
      (mapa['min'] as num).round(),
      (mapa['max'] as num).round(),
      enNevera: mapa['nevera'] == true,
      alternativaNevera: alternativa is Map<String, Object?>
          ? TiempoFase.deMapa(alternativa)
          : null,
    );
  }
}

/// Tiempos de todas las fases de una receta.
class PlantillaTiempos {
  const PlantillaTiempos(
      {required this.temperaturaReferenciaC, required this.fases});

  /// Temperatura (de la masa / de la cocina) a la que valen los tiempos.
  final double temperaturaReferenciaC;

  /// En el orden de [FaseHornada]. Una fase puede repetirse (brioche:
  /// primera fermentación a temperatura ambiente y luego en nevera).
  final List<TiempoFase> fases;

  bool get llevaMasaMadre =>
      fases.any((tiempo) => tiempo.fase == FaseHornada.refrescoMasaMadre);

  bool get admiteNevera =>
      fases.any((tiempo) => tiempo.alternativaNevera != null);

  String aJson() => jsonEncode({
        'temperatura_referencia_c': temperaturaReferenciaC,
        'fases': [for (final tiempo in fases) tiempo.aMapa()],
      });

  static PlantillaTiempos? deJson(String texto) {
    try {
      final mapa = jsonDecode(texto) as Map<String, Object?>;
      return PlantillaTiempos(
        temperaturaReferenciaC:
            (mapa['temperatura_referencia_c'] as num).toDouble(),
        fases: [
          for (final fase in mapa['fases'] as List)
            if (TiempoFase.deMapa((fase as Map).cast<String, Object?>())
                case final tiempo?)
              tiempo,
        ],
      );
    } catch (_) {
      return null;
    }
  }
}

// ─── Regla de temperatura ──────────────────────────────────────────────

/// Grados que duplican (o reducen a la mitad) el tiempo de fermentación.
///
/// Regla práctica **orientativa**: Peter Reinhart (Forno Bravo, «How to
/// control when your dough doubles in size») la da en unos 17 °F (≈ 9 °C);
/// otras fuentes dan entre 5 y 8 °C. Fuera de 16-32 °C deja de valer: por
/// debajo de unos 10 °C la levadura casi se para. Por eso se acota.
const double gradosQueDuplicanElTiempo = 9;
const double temperaturaMinimaReglaC = 16;
const double temperaturaMaximaReglaC = 32;

/// Factor por el que se multiplica el tiempo de una fermentación hecha a
/// [temperaturaCocinaC] en vez de a [temperaturaReferenciaC]:
/// 2^((referencia − cocina) / 9). Más frío → más de 1 (más lento).
double factorTemperatura(
    {required double temperaturaReferenciaC,
    required double temperaturaCocinaC}) {
  final acotada = temperaturaCocinaC.clamp(
      temperaturaMinimaReglaC, temperaturaMaximaReglaC);
  return math
      .pow(2, (temperaturaReferenciaC - acotada) / gradosQueDuplicanElTiempo)
      .toDouble();
}

bool temperaturaFueraDeLaRegla(double temperaturaCocinaC) =>
    temperaturaCocinaC < temperaturaMinimaReglaC ||
    temperaturaCocinaC > temperaturaMaximaReglaC;

// ─── Plan ──────────────────────────────────────────────────────────────

/// Una fase con su hora. Los minutos min/max ya van ajustados por la
/// temperatura.
class FasePlanificada {
  const FasePlanificada({
    required this.fase,
    required this.inicio,
    required this.fin,
    required this.minutosMin,
    required this.minutosMax,
    this.enNevera = false,
    this.hechaEn,
  });

  final FaseHornada fase;
  final DateTime inicio;
  final DateTime fin;
  final int minutosMin;
  final int minutosMax;
  final bool enNevera;
  final DateTime? hechaEn;

  bool get hecha => hechaEn != null;
  bool get enParalelo => fase.vaEnParalelo;
  Duration get duracion => fin.difference(inicio);

  FasePlanificada copiar(
          {DateTime? inicio, DateTime? fin, DateTime? hechaEn}) =>
      FasePlanificada(
        fase: fase,
        inicio: inicio ?? this.inicio,
        fin: fin ?? this.fin,
        minutosMin: minutosMin,
        minutosMax: minutosMax,
        enNevera: enNevera,
        hechaEn: hechaEn ?? this.hechaEn,
      );

  Map<String, Object?> aMapa() => {
        'fase': fase.name,
        'inicio_ms': inicio.millisecondsSinceEpoch,
        'fin_ms': fin.millisecondsSinceEpoch,
        'min': minutosMin,
        'max': minutosMax,
        if (enNevera) 'nevera': true,
        if (hechaEn != null) 'hecha_ms': hechaEn!.millisecondsSinceEpoch,
      };

  static FasePlanificada? deMapa(Map<String, Object?> mapa) {
    final fase = FaseHornada.porNombre('${mapa['fase']}');
    if (fase == null) return null;
    DateTime fecha(Object? milisegundos) =>
        DateTime.fromMillisecondsSinceEpoch((milisegundos as num).toInt());
    return FasePlanificada(
      fase: fase,
      inicio: fecha(mapa['inicio_ms']),
      fin: fecha(mapa['fin_ms']),
      minutosMin: (mapa['min'] as num).round(),
      minutosMax: (mapa['max'] as num).round(),
      enNevera: mapa['nevera'] == true,
      hechaEn: mapa['hecha_ms'] == null ? null : fecha(mapa['hecha_ms']),
    );
  }
}

String fasesAJson(List<FasePlanificada> fases) =>
    jsonEncode([for (final fase in fases) fase.aMapa()]);

List<FasePlanificada> fasesDeJson(String texto) {
  try {
    return [
      for (final mapa in jsonDecode(texto) as List)
        if (FasePlanificada.deMapa((mapa as Map).cast<String, Object?>())
            case final fase?)
          fase,
    ];
  } catch (_) {
    return const [];
  }
}

/// Calcula hacia atrás desde [listoA] (fin del enfriado, o de la cocción si
/// la receta no tiene enfriado).
///
/// - Fermentaciones a temperatura ambiente: tiempo × [factorTemperatura].
/// - Fases en [fasesEnNevera] que tienen alternativa de nevera: se usa ese
///   tiempo, sin ajuste por temperatura.
/// - Precalentar el horno va en paralelo (ver [FaseHornada.vaEnParalelo]).
/// - Las fechas son instantes: cruzar medianoche o un cambio de hora no
///   cambia la duración real de nada.
List<FasePlanificada> planificarHaciaAtras({
  required PlantillaTiempos plantilla,
  required DateTime listoA,
  required double temperaturaCocinaC,
  Set<FaseHornada> fasesEnNevera = const {},
}) {
  final factor = factorTemperatura(
      temperaturaReferenciaC: plantilla.temperaturaReferenciaC,
      temperaturaCocinaC: temperaturaCocinaC);
  final planificadas = <FasePlanificada>[];
  var cursor = listoA;
  for (final original in plantilla.fases.reversed) {
    final tiempo = fasesEnNevera.contains(original.fase) &&
            original.alternativaNevera != null
        ? original.alternativaNevera!
        : original;
    final ajustar = tiempo.fase.esFermentacion && !tiempo.enNevera;
    int ajustado(int minutos) => ajustar ? (minutos * factor).round() : minutos;
    final minutosPlan = ajustado(tiempo.minutosMedios);
    final fin = cursor;
    final inicio = fin.subtract(Duration(minutes: minutosPlan));
    planificadas.add(FasePlanificada(
      fase: tiempo.fase,
      inicio: inicio,
      fin: fin,
      minutosMin: ajustado(tiempo.minutosMin),
      minutosMax: ajustado(tiempo.minutosMax),
      enNevera: tiempo.enNevera,
    ));
    if (!tiempo.fase.vaEnParalelo) cursor = inicio;
  }
  return planificadas.reversed.toList();
}

/// La persona marca hecha la fase [indice] a [horaHecha]. Si es una fase
/// de la secuencia (no el horno, que va en paralelo), las siguientes que
/// falten se mueven lo que se haya adelantado o retrasado, con sus
/// duraciones: el pan estará listo más tarde (o antes).
List<FasePlanificada> marcarHechaYReplanificar(
    List<FasePlanificada> fases, int indice, DateTime horaHecha) {
  final marcada = fases[indice];
  final desfase =
      marcada.enParalelo ? Duration.zero : horaHecha.difference(marcada.fin);
  return [
    for (final (posicion, fase) in fases.indexed)
      if (posicion == indice)
        fase.copiar(hechaEn: horaHecha)
      else if (posicion > indice && !fase.hecha)
        fase.copiar(
            inicio: fase.inicio.add(desfase), fin: fase.fin.add(desfase))
      else
        fase,
  ];
}

/// Siguiente fase que falta (la primera sin marcar), o null si ya está todo.
FasePlanificada? siguienteFasePendiente(List<FasePlanificada> fases) {
  for (final fase in fases) {
    if (!fase.hecha) return fase;
  }
  return null;
}

/// Fin del plan: el de la última fase de la secuencia.
DateTime? finDelPlan(List<FasePlanificada> fases) =>
    fases.isEmpty ? null : fases.last.fin;

/// La primera fase empieza antes de [ahora]: no da tiempo para llegar a la
/// hora pedida.
bool empiezaEnElPasado(List<FasePlanificada> fases, DateTime ahora) =>
    fases.isNotEmpty && fases.first.inicio.isBefore(ahora);

/// Clave de aviso estable de una fase de un plan (para nuevo_ser_avisos).
String claveAvisoFase(int planId, int indice) => 'obrador.plan.$planId.$indice';
String prefijoAvisosPlan(int planId) => 'obrador.plan.$planId.';
String claveAvisoRefresco(int masaMadreId) => 'obrador.masa_madre.$masaMadreId';

// ─── Masa madre ────────────────────────────────────────────────────────

/// Próximo recordatorio de refresco: [cadaHoras] después del último
/// refresco (o de [ahora] si no hay ninguno o ya pasó).
DateTime proximoRefresco(
    {DateTime? ultimoRefresco,
    required int cadaHoras,
    required DateTime ahora}) {
  final intervalo = Duration(hours: cadaHoras);
  var proximo = (ultimoRefresco ?? ahora).add(intervalo);
  if (!proximo.isAfter(ahora)) proximo = ahora.add(intervalo);
  return proximo;
}

/// Refresco de la masa madre antes de amasar: la media de horas hasta el
/// pico de los últimos refrescos apuntados (si los hay), como rango ±25 %.
TiempoFase? tiempoRefrescoApuntado(List<double> horasHastaPico) {
  final validas = horasHastaPico.where((horas) => horas > 0).take(5).toList();
  if (validas.isEmpty) return null;
  final media = validas.reduce((a, b) => a + b) / validas.length;
  final minutos = media * 60;
  return TiempoFase(FaseHornada.refrescoMasaMadre, (minutos * 0.75).round(),
      (minutos * 1.25).round());
}

/// Sustituye el refresco de [plantilla] por [refresco] (el de la masa madre
/// de la persona).
PlantillaTiempos conRefresco(PlantillaTiempos plantilla, TiempoFase refresco) =>
    PlantillaTiempos(
      temperaturaReferenciaC: plantilla.temperaturaReferenciaC,
      fases: [
        for (final tiempo in plantilla.fases)
          tiempo.fase == FaseHornada.refrescoMasaMadre ? refresco : tiempo,
      ],
    );
