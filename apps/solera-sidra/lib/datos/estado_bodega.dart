import '../dominio/saldo_kupelas.dart';
import '../modelos/embotellado.dart';
import '../modelos/kupela.dart';
import '../modelos/prensado.dart';
import '../modelos/sesion_txotx.dart';
import 'base_datos.dart';

/// Todo lo de la bodega cargado de una vez, con el saldo de cada kupela.
class EstadoBodega {
  EstadoBodega._(this.kupelas, this.prensados, this.trasiegos,
      this.sesionesTxotx, this.embotellados, this.saldo);

  final List<Kupela> kupelas;
  final List<Prensado> prensados;
  final List<Trasiego> trasiegos;
  final List<SesionTxotx> sesionesTxotx;
  final List<Embotellado> embotellados;
  final SaldoKupelas saldo;

  Kupela? kupela(int id) {
    for (final kupela in kupelas) {
      if (kupela.id == id) return kupela;
    }
    return null;
  }

  String etiquetaKupela(int? id) =>
      id == null ? '—' : (kupela(id)?.etiqueta ?? '#$id');

  /// Kupelas activas con algo dentro (para txotx, trasiego y embotellado).
  List<Kupela> get kupelasConContenido => kupelas
      .where((kupela) => kupela.activa && saldo.litrosEn(kupela.id!) > 0.5)
      .toList();

  static Future<EstadoBodega> cargar({int? hastaMs}) async {
    final baseDatos = BaseDatosSoleraSidra.instancia;
    final kupelas = await baseDatos.listarKupelas();
    final prensados = await baseDatos.listarPrensados();
    final trasiegos = await baseDatos.listarTrasiegos();
    final sesiones = await baseDatos.listarSesionesTxotx();
    final embotellados = await baseDatos.listarEmbotellados();
    return EstadoBodega._(
      kupelas,
      prensados,
      trasiegos,
      sesiones,
      embotellados,
      SaldoKupelas.calcular(
        prensados: prensados,
        trasiegos: trasiegos,
        sesionesTxotx: sesiones,
        embotellados: embotellados,
        hastaMs: hastaMs,
      ),
    );
  }
}
