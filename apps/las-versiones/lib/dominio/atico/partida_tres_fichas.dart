import 'dart:math';

import 'package:nuevo_ser_core/src/calibration/evaluador_calibracion.dart';

import '../brecha.dart';
import '../capa_historica.dart';

/// Una tarjeta de Tres fichas: una afirmación de una Brecha cerrada con
/// las fuentes que la anclan cosidas debajo.
class TarjetaAfirmacion {
  const TarjetaAfirmacion({
    required this.brecha,
    required this.afirmacion,
    required this.fuentesAnclaje,
  });

  final Brecha brecha;
  final AfirmacionCanonica afirmacion;
  final List<Fuente> fuentesAnclaje;

  String get id => '${brecha.id}/${afirmacion.id}';
  NivelConfianza get nivelCanonico => afirmacion.calibracionCorrecta;
  CapaHistorica? get capa => capaPrincipalDeBrecha[brecha.id];
}

/// Tipo de ronda (doc del ático §1).
enum TipoRondaTresFichas {
  /// Afirmaciones de una sola Brecha, con las fuentes a la vista.
  unaBrecha,

  /// Mezcla de dos Brechas de capas distintas si las hay.
  dosCapas,

  /// Las fuentes vienen guardadas en el cajón: hay que ir a buscarlas
  /// antes de clasificar. No puntúa: entrena el hábito de mirar.
  tarjetaSuelta,
}

class RondaTresFichas {
  const RondaTresFichas({required this.tipo, required this.tarjetas});

  final TipoRondaTresFichas tipo;
  final List<TarjetaAfirmacion> tarjetas;

  bool get fuentesOcultas => tipo == TipoRondaTresFichas.tarjetaSuelta;
  bool get puntua => tipo != TipoRondaTresFichas.tarjetaSuelta;
}

/// Hacia dónde se inclina la balanza al cerrar.
enum InclinacionBalanza { equilibrio, sobreconfianza, timidez }

/// Una tarjeta mal calibrada, para que Andrés comente una.
class DesviacionTarjeta {
  const DesviacionTarjeta({required this.tarjeta, required this.declarado});

  final TarjetaAfirmacion tarjeta;
  final NivelConfianza declarado;

  /// Positivo = se declaró más seguro de lo que es.
  int get pasos => _certeza(declarado) - _certeza(tarjeta.nivelCanonico);
}

int _certeza(NivelConfianza nivel) {
  switch (nivel) {
    case NivelConfianza.solido:
      return 2;
    case NivelConfianza.probable:
      return 1;
    case NivelConfianza.disputado:
      return 0;
  }
}

/// Resultado de una partida: la balanza, no un marcador.
class CierreTresFichas {
  const CierreTresFichas({
    required this.inclinacion,
    required this.desviaciones,
    required this.scoreCalibracion,
    required this.capaParaFragmento,
  });

  final InclinacionBalanza inclinacion;

  /// Tarjetas mal calibradas de las rondas que puntúan, de mayor a
  /// menor desviación.
  final List<DesviacionTarjeta> desviaciones;

  /// Brier normalizado medio (core), en [0, 1]. Para la maestría, no
  /// se enseña.
  final double scoreCalibracion;

  /// Capa cuyo fragmento suena al cerrar (la de la Brecha más usada).
  final CapaHistorica? capaParaFragmento;

  /// La desviación que comenta Andrés: la mayor, y a igualdad la de
  /// sobreconfianza (es la que más importa al oficio, doc 14 §1).
  DesviacionTarjeta? get paraComentar =>
      desviaciones.isEmpty ? null : desviaciones.first;
}

/// Partida de Tres fichas. Pura: la vista declara niveles con
/// [declarar] y pide [cerrar] al final.
class PartidaTresFichas {
  PartidaTresFichas._(this.rondas);

  /// Monta las rondas con las Brechas cerradas. Devuelve `null` si no
  /// hay ninguna (el ático no debería haberse abierto).
  static PartidaTresFichas? montar(
    List<Brecha> cerradas, {
    int? semilla,
    int tarjetasPorRonda = 4,
  }) {
    final conAfirmaciones =
        cerradas.where((b) => b.afirmacionesCanonicas.isNotEmpty).toList();
    if (conAfirmaciones.isEmpty) return null;
    final azar = Random(semilla);
    final usadas = <String>{};

    List<TarjetaAfirmacion> sacar(List<Brecha> brechas, int cuantas) {
      final candidatas = [
        for (final brecha in brechas)
          for (final afirmacion in brecha.afirmacionesCanonicas)
            if (!usadas.contains('${brecha.id}/${afirmacion.id}'))
              _tarjeta(brecha, afirmacion),
      ]..shuffle(azar);
      final elegidas = candidatas.take(cuantas).toList();
      usadas.addAll(elegidas.map((t) => t.id));
      return elegidas;
    }

    final barajadas = [...conAfirmaciones]..shuffle(azar);
    final primera = barajadas.first;
    final otraCapa = barajadas.firstWhere(
      (b) => capaPrincipalDeBrecha[b.id] != capaPrincipalDeBrecha[primera.id],
      orElse: () => barajadas.length > 1 ? barajadas[1] : primera,
    );

    final rondas = <RondaTresFichas>[
      RondaTresFichas(
        tipo: TipoRondaTresFichas.unaBrecha,
        tarjetas: sacar([primera], tarjetasPorRonda),
      ),
      RondaTresFichas(
        tipo: TipoRondaTresFichas.dosCapas,
        // Repartidas entre las dos Brechas: si se sacaran del montón
        // conjunto, a veces saldrían todas de la misma.
        tarjetas: identical(otraCapa, primera)
            ? sacar([primera], tarjetasPorRonda + 1)
            : ([
                ...sacar([primera], (tarjetasPorRonda + 1) ~/ 2),
                ...sacar([otraCapa], tarjetasPorRonda + 1 - (tarjetasPorRonda + 1) ~/ 2),
              ]..shuffle(azar)),
      ),
      RondaTresFichas(
        tipo: TipoRondaTresFichas.tarjetaSuelta,
        tarjetas: sacar(barajadas, 2),
      ),
    ].where((ronda) => ronda.tarjetas.isNotEmpty).toList();
    return PartidaTresFichas._(rondas);
  }

  static TarjetaAfirmacion _tarjeta(Brecha brecha, AfirmacionCanonica afirmacion) {
    return TarjetaAfirmacion(
      brecha: brecha,
      afirmacion: afirmacion,
      fuentesAnclaje: [
        for (final idFuente in afirmacion.idsFuentesAnclaje)
          ...brecha.fuentes.where((fuente) => fuente.id == idFuente),
      ],
    );
  }

  final List<RondaTresFichas> rondas;
  final Map<String, NivelConfianza> _declarados = {};

  NivelConfianza? declarado(TarjetaAfirmacion tarjeta) => _declarados[tarjeta.id];

  /// Poner una tarjeta en una bandeja. Se puede cambiar de bandeja
  /// mientras la ronda está abierta: cuenta lo que haya al cerrar.
  void declarar(TarjetaAfirmacion tarjeta, NivelConfianza nivel) {
    _declarados[tarjeta.id] = nivel;
  }

  void retirar(TarjetaAfirmacion tarjeta) => _declarados.remove(tarjeta.id);

  bool rondaCompleta(int indiceRonda) =>
      rondas[indiceRonda].tarjetas.every((t) => _declarados.containsKey(t.id));

  CierreTresFichas cerrar() {
    final puntuables = [
      for (final ronda in rondas)
        if (ronda.puntua)
          for (final tarjeta in ronda.tarjetas)
            if (_declarados.containsKey(tarjeta.id)) tarjeta,
    ];
    final calibraciones = [
      for (final tarjeta in puntuables)
        CalibracionAfirmacion(
          nivelCorrecto: tarjeta.nivelCanonico,
          nivelDeclarado: _declarados[tarjeta.id]!,
        ),
    ];
    final resultado = const EvaluadorCalibracion().evaluar(calibraciones);

    final desviaciones = [
      for (final tarjeta in puntuables)
        if (_declarados[tarjeta.id] != tarjeta.nivelCanonico)
          DesviacionTarjeta(tarjeta: tarjeta, declarado: _declarados[tarjeta.id]!),
    ]..sort((a, b) {
        final porTamano = b.pasos.abs().compareTo(a.pasos.abs());
        return porTamano != 0 ? porTamano : b.pasos.compareTo(a.pasos);
      });

    final sumaPasos = desviaciones.fold<int>(0, (suma, d) => suma + d.pasos);
    final InclinacionBalanza inclinacion;
    if (puntuables.isEmpty || sumaPasos.abs() * 4 < puntuables.length) {
      // Menos de un paso cada cuatro tarjetas: ruido, no tendencia.
      inclinacion = InclinacionBalanza.equilibrio;
    } else {
      inclinacion = sumaPasos > 0
          ? InclinacionBalanza.sobreconfianza
          : InclinacionBalanza.timidez;
    }

    final usosPorCapa = <CapaHistorica, int>{};
    for (final ronda in rondas) {
      for (final tarjeta in ronda.tarjetas) {
        final capa = tarjeta.capa;
        if (capa != null) usosPorCapa[capa] = (usosPorCapa[capa] ?? 0) + 1;
      }
    }
    final capaMasUsada = usosPorCapa.entries.isEmpty
        ? null
        : usosPorCapa.entries.reduce((a, b) => b.value > a.value ? b : a).key;

    return CierreTresFichas(
      inclinacion: inclinacion,
      desviaciones: desviaciones,
      scoreCalibracion: resultado.scoreMedio,
      capaParaFragmento: capaMasUsada,
    );
  }
}
