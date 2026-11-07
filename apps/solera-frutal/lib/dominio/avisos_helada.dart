import '../modelos/parcela.dart';
import 'catalogos.dart';

/// Umbral genérico (°C) cuando el catálogo no da temperatura crítica para
/// el estado: el mismo que usa `DiaMeteoAgro.riesgoHelada` del core.
const double umbralHeladaGenericoC = 2;

/// Un día de la previsión con su mínima.
typedef MinimaPrevista = ({DateTime fecha, double? minimaC});

/// Aviso orientativo: en [fecha] se prevé [minimaC] y la parcela puede
/// estar en un estado sensible ([estados]).
class AvisoHelada {
  AvisoHelada(this.parcela, this.fecha, this.minimaC, this.estados);

  final Parcela parcela;
  final DateTime fecha;
  final double minimaC;
  final List<String> estados;
}

/// Cruza la previsión con el calendario fenológico del catálogo. Es una
/// **orientación**: el estado real depende de la variedad y de la zona.
List<AvisoHelada> calcularAvisosHelada({
  required Iterable<Parcela> parcelas,
  required List<MinimaPrevista> prevision,
}) {
  final avisos = <AvisoHelada>[];
  for (final dia in prevision) {
    final minima = dia.minimaC;
    if (minima == null) continue;
    for (final parcela in parcelas) {
      final sensibles = estadosEnMes(parcela.especieId, dia.fecha.month)
          .where((estado) =>
              estado.sensibleHelada == true &&
              minima <= (estado.temperaturaCriticaC ?? umbralHeladaGenericoC))
          .toList();
      if (sensibles.isEmpty) continue;
      avisos.add(AvisoHelada(parcela, dia.fecha, minima, [
        for (final estado in sensibles)
          estado.codigo.isEmpty
              ? estado.estado
              : '${estado.codigo} · ${estado.estado}'
      ]));
    }
  }
  return avisos;
}
