/// Recuento de una urna según las reglas del asunto. Funciones puras: el
/// mismo resultado se puede rehacer a mano con el acta delante, y por eso
/// cada resultado lleva las cifras con las que se calculó.
///
/// Papeletas de la app y conteos presenciales se suman; el acta enseña las
/// dos partes por separado (`docs/04-concejo.md` §4.5).
library;

import 'reglas_decision.dart';
import 'urna.dart';

/// Marcas por opción de las papeletas emitidas en la app.
Map<String, int> marcasEnLaApp(Urna urna) {
  final marcas = <String, int>{};
  for (final papeleta in urna.papeletas) {
    for (final opcion in papeleta.opcionesMarcadas) {
      marcas[opcion] = (marcas[opcion] ?? 0) + 1;
    }
  }
  return marcas;
}

/// Marcas por opción de los conteos en papel.
Map<String, int> marcasEnPapel(Urna urna) {
  final marcas = <String, int>{};
  for (final conteo in urna.conteosPresenciales) {
    conteo.marcasPorOpcion.forEach((opcion, cantidad) {
      marcas[opcion] = (marcas[opcion] ?? 0) + cantidad;
    });
  }
  return marcas;
}

/// Marcas por opción sumando app y papel.
Map<String, int> marcasPorOpcion(Urna urna) {
  final marcas = marcasEnLaApp(urna);
  marcasEnPapel(urna).forEach((opcion, cantidad) {
    marcas[opcion] = (marcas[opcion] ?? 0) + cantidad;
  });
  return marcas;
}

int papeletasTotales(Urna urna) =>
    urna.papeletas.length + urna.papeletasPresencialesContadas;

bool hayQuorum(ReglasDecision reglas, Urna urna) =>
    urna.personasQueHanParticipado >= reglas.quorumPersonas;

// ---------------------------------------------------------------- votación

enum DesenlaceVotacion { aprobada, rechazada, sinQuorum }

class ResultadoVotacion {
  const ResultadoVotacion({
    required this.desenlace,
    required this.si,
    required this.no,
    required this.abstenciones,
    required this.participantes,
  });

  final DesenlaceVotacion desenlace;
  final int si;
  final int no;
  final int abstenciones;
  final int participantes;
  int get emitidos => si + no + abstenciones;
}

ResultadoVotacion contarVotacion(ReglasDecision reglas, Urna urna) {
  assert(reglas.forma == FormaDecision.votacion);
  final marcas = marcasPorOpcion(urna);
  final si = marcas[votoSi] ?? 0;
  final no = marcas[votoNo] ?? 0;
  final abstenciones = marcas[votoAbstencion] ?? 0;
  final emitidos = si + no + abstenciones;

  final aprobada = switch (reglas.mayoria) {
    Mayoria.simple => si > no,
    Mayoria.absoluta => si * 2 > emitidos,
    // si / (si + no) >= 2/3, sin decimales.
    Mayoria.dosTercios => si + no > 0 && si * 3 >= (si + no) * 2,
  };
  return ResultadoVotacion(
    desenlace: !hayQuorum(reglas, urna)
        ? DesenlaceVotacion.sinQuorum
        : aprobada
            ? DesenlaceVotacion.aprobada
            : DesenlaceVotacion.rechazada,
    si: si,
    no: no,
    abstenciones: abstenciones,
    participantes: urna.personasQueHanParticipado,
  );
}

// ------------------------------------------------- elección entre opciones

class ResultadoEleccion {
  const ResultadoEleccion({
    required this.aceptacionesPorOpcion,
    required this.ganadoras,
    required this.hayQuorum,
    required this.papeletas,
  });

  /// En el orden de las opciones del asunto.
  final Map<String, int> aceptacionesPorOpcion;

  /// Una si hay ganadora clara; varias si empatan (lo resuelve la mesa o
  /// una segunda vuelta: la app **no sortea**); vacía si nadie aceptó nada.
  final List<String> ganadoras;
  final bool hayQuorum;
  final int papeletas;

  bool get empate => ganadoras.length > 1;
}

ResultadoEleccion contarEleccion(ReglasDecision reglas, Urna urna) {
  assert(reglas.forma == FormaDecision.eleccionEntreOpciones);
  final marcas = marcasPorOpcion(urna);
  final aceptaciones = {
    for (final opcion in reglas.opciones) opcion.id: marcas[opcion.id] ?? 0,
  };
  final maximo = aceptaciones.values.fold(0, (a, b) => a > b ? a : b);
  return ResultadoEleccion(
    aceptacionesPorOpcion: aceptaciones,
    ganadoras: maximo == 0
        ? const []
        : [
            for (final entrada in aceptaciones.entries)
              if (entrada.value == maximo) entrada.key,
          ],
    hayQuorum: hayQuorum(reglas, urna),
    papeletas: papeletasTotales(urna),
  );
}

// -------------------------------------------------------------- presupuesto

class LineaPresupuesto {
  const LineaPresupuesto({
    required this.opcion,
    required this.apoyos,
    required this.entra,
    required this.motivo,
  });

  final OpcionDecision opcion;
  final int apoyos;
  final bool entra;
  final MotivoPresupuesto motivo;
}

enum MotivoPresupuesto { entra, noCabe, sinApoyos }

class ResultadoPresupuesto {
  const ResultadoPresupuesto({
    required this.lineas,
    required this.bolsaEuros,
    required this.gastadoEuros,
    required this.hayQuorum,
  });

  /// Por orden de apoyos (el orden en que se reparte la bolsa).
  final List<LineaPresupuesto> lineas;
  final double bolsaEuros;
  final double gastadoEuros;
  final bool hayQuorum;
  double get sobranteEuros => bolsaEuros - gastadoEuros;
  List<OpcionDecision> get seleccionadas => [
        for (final linea in lineas)
          if (linea.entra) linea.opcion
      ];
}

/// Regla publicada antes de votar: las propuestas se ordenan por apoyos
/// (a igualdad, la más barata primero; y si no, la que va antes en el
/// asunto) y entran mientras quepan en la bolsa. Una que no cabe se salta
/// y se sigue con la siguiente. Sin apoyos no entra ninguna.
ResultadoPresupuesto contarPresupuesto(ReglasDecision reglas, Urna urna) {
  assert(reglas.forma == FormaDecision.presupuesto);
  final marcas = marcasPorOpcion(urna);
  final orden = [...reglas.opciones.indexed]..sort((a, b) {
      final porApoyos = (marcas[b.$2.id] ?? 0).compareTo(marcas[a.$2.id] ?? 0);
      if (porApoyos != 0) return porApoyos;
      final porCoste = a.$2.costeEuros!.compareTo(b.$2.costeEuros!);
      if (porCoste != 0) return porCoste;
      return a.$1.compareTo(b.$1);
    });

  final bolsa = reglas.bolsaEuros!;
  var gastado = 0.0;
  final lineas = <LineaPresupuesto>[];
  for (final (_, opcion) in orden) {
    final apoyos = marcas[opcion.id] ?? 0;
    final MotivoPresupuesto motivo;
    if (apoyos == 0) {
      motivo = MotivoPresupuesto.sinApoyos;
    } else if (gastado + opcion.costeEuros! <= bolsa + 1e-9) {
      motivo = MotivoPresupuesto.entra;
      gastado += opcion.costeEuros!;
    } else {
      motivo = MotivoPresupuesto.noCabe;
    }
    lineas.add(LineaPresupuesto(
      opcion: opcion,
      apoyos: apoyos,
      entra: motivo == MotivoPresupuesto.entra,
      motivo: motivo,
    ));
  }
  return ResultadoPresupuesto(
    lineas: lineas,
    bolsaEuros: bolsa,
    gastadoEuros: gastado,
    hayQuorum: hayQuorum(reglas, urna),
  );
}
