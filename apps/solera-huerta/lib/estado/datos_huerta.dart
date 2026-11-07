import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../dominio/prevision_cosecha.dart';
import '../dominio/rotacion.dart';
import '../modelos/bancal.dart';
import '../modelos/cultivo.dart';
import '../modelos/insumo.dart';
import '../modelos/lote_semilla.dart';
import '../modelos/parcela.dart';
import '../modelos/siembra.dart';

/// Lo que casi todas las pantallas necesitan a la vez: parcelas, bancales,
/// cultivos, lotes, insumos y siembras, con búsquedas por id. Una huerta
/// pequeña cabe entera en memoria.
class DatosHuerta {
  DatosHuerta({
    required this.parcelas,
    required this.bancales,
    required this.cultivos,
    required this.lotes,
    required this.insumos,
    required this.siembras,
  });

  final List<Parcela> parcelas;
  final List<Bancal> bancales;
  final List<Cultivo> cultivos;
  final List<LoteSemilla> lotes;
  final List<Insumo> insumos;
  final List<Siembra> siembras;

  late final Map<int, Parcela> _parcelas = {
    for (final parcela in parcelas) parcela.id!: parcela
  };
  late final Map<int, Bancal> _bancales = {
    for (final bancal in bancales) bancal.id!: bancal
  };
  late final Map<int, Cultivo> _cultivos = {
    for (final cultivo in cultivos) cultivo.id!: cultivo
  };
  late final Map<int, Insumo> _insumos = {
    for (final insumo in insumos) insumo.id!: insumo
  };
  late final Map<int, LoteSemilla> _lotes = {
    for (final lote in lotes) lote.id!: lote
  };

  static Future<DatosHuerta> cargar() async {
    final baseDatos = BaseDatosSoleraHuerta.instancia;
    return DatosHuerta(
      parcelas: await baseDatos.listarParcelas(),
      bancales: await baseDatos.listarBancales(),
      cultivos: await baseDatos.listarCultivos(),
      lotes: await baseDatos.listarLotesSemilla(),
      insumos: await baseDatos.listarInsumos(),
      siembras: await baseDatos.listarSiembras(),
    );
  }

  Parcela? parcela(int? id) => id == null ? null : _parcelas[id];
  Bancal? bancal(int? id) => id == null ? null : _bancales[id];
  Cultivo? cultivo(int? id) => id == null ? null : _cultivos[id];
  Insumo? insumo(int? id) => id == null ? null : _insumos[id];
  LoteSemilla? lote(int? id) => id == null ? null : _lotes[id];

  String nombreDeCultivo(int id) {
    final encontrado = cultivo(id);
    return encontrado == null ? '?' : nombreCultivo(encontrado);
  }

  /// «Vega · B3».
  String nombreDeBancal(int id) {
    final encontrado = bancal(id);
    if (encontrado == null) return '?';
    final suParcela = parcela(encontrado.parcelaId);
    return suParcela == null
        ? encontrado.nombre
        : '${suParcela.nombre} · ${encontrado.nombre}';
  }

  /// Bancales que se pueden elegir (activos), en el orden de la lista.
  List<Bancal> get bancalesActivos =>
      bancales.where((bancal) => bancal.activo).toList();

  /// Historial de familias por bancal, para la rotación.
  List<PasoPorBancal> get historialRotacion => [
        for (final siembra in siembras)
          if (cultivo(siembra.cultivoId) != null)
            PasoPorBancal(
              bancalId: siembra.bancalId,
              familiaId: cultivo(siembra.cultivoId)!.familiaId,
              fecha: DateTime.fromMillisecondsSinceEpoch(
                  siembra.fechaReferenciaMs),
              siembraId: siembra.id,
            ),
      ];

  /// Aviso de rotación de una siembra (ya guardada o en el formulario).
  AvisoRotacion? avisoRotacion({
    required int bancalId,
    required int cultivoId,
    required DateTime fecha,
    int? excluirSiembraId,
  }) {
    final elegido = cultivo(cultivoId);
    if (elegido == null) return null;
    return comprobarRotacion(
      bancalId: bancalId,
      familiaId: elegido.familiaId,
      fecha: fecha,
      historial: historialRotacion,
      aniosMinimosPorFamilia: aniosMinimosPorFamilia(),
      excluirSiembraId: excluirSiembraId,
    );
  }

  /// Ciclo del cultivo según su especie en el catálogo.
  CicloCultivo? cicloDeCultivo(int cultivoId) {
    final elegido = cultivo(cultivoId);
    return elegido == null ? null : cicloDeEspecie(elegido.especieId);
  }

  /// Siembras en el bancal ahora: hechas y sin levantar.
  List<Siembra> ocupacionDe(int bancalId) => [
        for (final siembra in siembras)
          if (siembra.bancalId == bancalId &&
              siembra.realizada &&
              siembra.fechaLevantadaMs == null)
            siembra,
      ];
}
