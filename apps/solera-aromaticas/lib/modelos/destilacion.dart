import 'lista_ids.dart';

/// Tipos de alambique o de proceso.
const List<String> tiposAlambique = [
  'arrastre_vapor',
  'hidrodestilacion',
  'vapor_y_agua',
  'otro',
];

/// Estado de la planta que entra en el alambique.
const List<String> estadosPlantaDestilacion = ['fresca', 'oreada', 'seca'];

/// Destilación: kg de planta → ml de aceite esencial + litros de hidrolato.
///
/// Sigue la estructura de la `Molturacion` de aceitera (planta → producto
/// con rendimiento): las cosechas que entran ([cosechasUsadasIds]), lo que
/// sale y los lotes que genera (uno de aceite esencial y otro de hidrolato).
class Destilacion {
  Destilacion({
    this.id,
    required this.fechaMs,
    required this.especieId,
    this.cosechasUsadasIds = const [],
    this.kgPlanta = 0,
    this.estadoPlanta = 'fresca',
    this.mlAceiteEsencial = 0,
    this.litrosHidrolato = 0,
    this.horas,
    this.tipoAlambique = 'arrastre_vapor',
    this.capacidadAlambiqueLitros,
    this.loteAceiteId,
    this.loteHidrolatoId,
    this.notas = '',
  });

  final int? id;
  final int fechaMs;
  final String especieId;
  final List<int> cosechasUsadasIds;
  final double kgPlanta;

  /// Uno de [estadosPlantaDestilacion]: el rendimiento no es comparable
  /// entre planta fresca y seca.
  final String estadoPlanta;
  final double mlAceiteEsencial;
  final double litrosHidrolato;
  final double? horas;

  /// Uno de [tiposAlambique].
  final String tipoAlambique;
  final double? capacidadAlambiqueLitros;
  final int? loteAceiteId;
  final int? loteHidrolatoId;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'fecha_ms': fechaMs,
        'especie_id': especieId,
        'cosechas_usadas_json': codificarIds(cosechasUsadasIds),
        'kg_planta': kgPlanta,
        'estado_planta': estadoPlanta,
        'ml_aceite_esencial': mlAceiteEsencial,
        'litros_hidrolato': litrosHidrolato,
        'horas': horas,
        'tipo_alambique': tipoAlambique,
        'capacidad_alambique_l': capacidadAlambiqueLitros,
        'lote_aceite_id': loteAceiteId,
        'lote_hidrolato_id': loteHidrolatoId,
        'notas': notas,
      };

  factory Destilacion.fromMap(Map<String, Object?> mapa) => Destilacion(
        id: mapa['id'] as int?,
        fechaMs: mapa['fecha_ms'] as int,
        especieId: (mapa['especie_id'] as String?) ?? '',
        cosechasUsadasIds:
            decodificarIds(mapa['cosechas_usadas_json'] as String?),
        kgPlanta: (mapa['kg_planta'] as num?)?.toDouble() ?? 0,
        estadoPlanta: estadosPlantaDestilacion.contains(mapa['estado_planta'])
            ? mapa['estado_planta'] as String
            : 'fresca',
        mlAceiteEsencial: (mapa['ml_aceite_esencial'] as num?)?.toDouble() ?? 0,
        litrosHidrolato: (mapa['litros_hidrolato'] as num?)?.toDouble() ?? 0,
        horas: (mapa['horas'] as num?)?.toDouble(),
        tipoAlambique: tiposAlambique.contains(mapa['tipo_alambique'])
            ? mapa['tipo_alambique'] as String
            : 'otro',
        capacidadAlambiqueLitros:
            (mapa['capacidad_alambique_l'] as num?)?.toDouble(),
        loteAceiteId: mapa['lote_aceite_id'] as int?,
        loteHidrolatoId: mapa['lote_hidrolato_id'] as int?,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
