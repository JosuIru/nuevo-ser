import '../modelos/bandeja.dart';
import '../modelos/lote_material.dart';
import '../modelos/partida_planta.dart';
import '../modelos/siembra.dart';

/// Un paso de la cadena, de la planta vendida hacia el material de partida.
class EslabonTrazabilidad {
  const EslabonTrazabilidad.partida(this.partida)
      : siembra = null,
        bandeja = null,
        lote = null;
  const EslabonTrazabilidad.siembra(this.siembra, this.bandeja)
      : partida = null,
        lote = null;
  const EslabonTrazabilidad.lote(this.lote)
      : partida = null,
        siembra = null,
        bandeja = null;

  final PartidaPlanta? partida;
  final Siembra? siembra;
  final Bandeja? bandeja;
  final LoteMaterial? lote;
}

/// Resultado: la cadena y si llega hasta un lote de material.
class CadenaTrazabilidad {
  const CadenaTrazabilidad(this.eslabones, {required this.completa});

  /// De la partida pedida (primero) al lote (último).
  final List<EslabonTrazabilidad> eslabones;

  /// Llega hasta un lote de material. Si no, falta algún dato (una partida
  /// dada de alta sin siembra, un lote borrado…) y hay que completarlo.
  final bool completa;

  LoteMaterial? get lote => completa ? eslabones.last.lote : null;
}

/// Reconstruye la cadena de la partida hacia atrás: repicados (partida de
/// origen), siembra en bandeja y lote de material. Lógica pura sobre los
/// datos ya cargados; corta si encuentra un ciclo.
CadenaTrazabilidad reconstruirTrazabilidad(
  int partidaId, {
  required Map<int, PartidaPlanta> partidas,
  required Map<int, Siembra> siembras,
  required Map<int, Bandeja> bandejas,
  required Map<int, LoteMaterial> lotes,
}) {
  final eslabones = <EslabonTrazabilidad>[];
  final visitadas = <int>{};
  var partida = partidas[partidaId];
  while (partida != null && visitadas.add(partida.id ?? -1)) {
    eslabones.add(EslabonTrazabilidad.partida(partida));
    final origen = partida.partidaOrigenId;
    if (origen != null) {
      partida = partidas[origen];
      continue;
    }
    final siembra =
        partida.siembraId == null ? null : siembras[partida.siembraId];
    if (siembra == null) break;
    eslabones
        .add(EslabonTrazabilidad.siembra(siembra, bandejas[siembra.bandejaId]));
    final lote = lotes[siembra.loteMaterialId];
    if (lote == null) break;
    eslabones.add(EslabonTrazabilidad.lote(lote));
    return CadenaTrazabilidad(eslabones, completa: true);
  }
  return CadenaTrazabilidad(eslabones, completa: false);
}
