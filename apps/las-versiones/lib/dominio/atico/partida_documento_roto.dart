import 'dart:math';

import '../brecha.dart';

/// Qué dice una tira de catalogación rasgada, y qué habilidad ejercita
/// ponerla en su documento (doc del ático §2).
enum TipoTira {
  tipoFuente('HF.02'),
  autor('HF.03'),
  fecha('HF.04'),
  publico('HF.05');

  const TipoTira(this.idHabilidad);

  final String idHabilidad;
}

/// Un documento sobre la mesa de luz: una fuente de una Brecha cerrada.
class DocumentoEnMesa {
  const DocumentoEnMesa({required this.brecha, required this.fuente});

  final Brecha brecha;
  final Fuente fuente;

  String get id => '${brecha.id}/${fuente.id}';

  /// El texto que tendría que llevar la tira de [tipo] de este documento.
  String valor(TipoTira tipo) {
    final propiedades = fuente.propiedadesCanonicas;
    switch (tipo) {
      case TipoTira.tipoFuente:
        return textoTipoFuente(propiedades.tipo);
      case TipoTira.autor:
        return propiedades.autor;
      case TipoTira.fecha:
        return propiedades.fecha;
      case TipoTira.publico:
        return propiedades.publico;
    }
  }
}

String textoTipoFuente(TipoFuente tipo) =>
    tipo == TipoFuente.primaria ? 'Primaria' : 'Secundaria';

/// Una tira rasgada. [idDocumentoOrigen] es el documento del que se
/// despegó; en la tira de sobra es un documento que no está en la mesa.
class Tira {
  const Tira({
    required this.id,
    required this.tipo,
    required this.texto,
    required this.idDocumentoOrigen,
    this.deSobra = false,
  });

  final String id;
  final TipoTira tipo;
  final String texto;
  final String idDocumentoOrigen;

  /// No es de ningún documento de la mesa: hay que dejarla en la caja.
  final bool deSobra;

  /// Encaja si el texto es el que corresponde a ese documento. Se
  /// compara por valor: si dos documentos comparten el mismo dato
  /// («Comunidad académica de la época»), la tira vale para los dos.
  bool encajaEn(DocumentoEnMesa documento) => documento.valor(tipo) == texto;
}

class RondaDocumentoRoto {
  const RondaDocumentoRoto({required this.documentos, required this.tiras});

  final List<DocumentoEnMesa> documentos;
  final List<Tira> tiras;

  List<Tira> get tirasQueSeColocan => tiras.where((t) => !t.deSobra).toList();
}

/// Resultado del primer intento con una tira: lo único que contaría
/// para la maestría (doc 01 de Uno Roto, principio 5, compartido).
class PrimerIntentoTira {
  const PrimerIntentoTira({required this.tira, required this.acierto});

  final Tira tira;
  final bool acierto;

  String get idHabilidad => tira.tipo.idHabilidad;
}

/// Partida de El documento roto. Pura: la vista llama a [colocar] y
/// avanza con [siguienteRonda].
class PartidaDocumentoRoto {
  PartidaDocumentoRoto._(this.rondas);

  /// Monta tres rondas con las fuentes de las Brechas cerradas:
  /// 1. dos documentos de una Brecha y sus sellos Primaria/Secundaria;
  /// 2. tres documentos con sus tiras de autor y fecha;
  /// 3. tres documentos con la tira de público, más una tira de sobra
  ///    de una fuente que no está en la mesa.
  /// Devuelve `null` si no hay al menos tres fuentes.
  static PartidaDocumentoRoto? montar(List<Brecha> cerradas, {int? semilla}) {
    final azar = Random(semilla);
    final todas = [
      for (final brecha in cerradas)
        for (final fuente in brecha.fuentes)
          DocumentoEnMesa(brecha: brecha, fuente: fuente),
    ];
    if (todas.length < 3) return null;

    // Ronda 1: una Brecha, a ser posible con una primaria y una secundaria.
    final brechasBarajadas = [...cerradas]..shuffle(azar);
    final brechaPrimera = brechasBarajadas.firstWhere(
      (b) => b.fuentes.length >= 2,
      orElse: () => brechasBarajadas.first,
    );
    final deLaPrimera = todas.where((d) => d.brecha.id == brechaPrimera.id).toList()
      ..shuffle(azar);
    final primaria = deLaPrimera
        .where((d) => d.fuente.propiedadesCanonicas.tipo == TipoFuente.primaria)
        .toList();
    final secundaria = deLaPrimera
        .where((d) => d.fuente.propiedadesCanonicas.tipo == TipoFuente.secundaria)
        .toList();
    final documentosRonda1 = (primaria.isNotEmpty && secundaria.isNotEmpty)
        ? [primaria.first, secundaria.first]
        : deLaPrimera.take(2).toList();
    documentosRonda1.shuffle(azar);

    // Rondas 2 y 3: documentos que no se hayan visto, si quedan.
    final vistos = documentosRonda1.map((d) => d.id).toSet();
    List<DocumentoEnMesa> tomar(int cuantos) {
      final frescos = todas.where((d) => !vistos.contains(d.id)).toList()..shuffle(azar);
      final repetibles = todas.where((d) => vistos.contains(d.id)).toList()..shuffle(azar);
      final elegidos = [...frescos, ...repetibles].take(cuantos).toList();
      vistos.addAll(elegidos.map((d) => d.id));
      return elegidos;
    }

    final documentosRonda2 = tomar(3);
    final documentosRonda3 = tomar(3);

    List<Tira> tirasDe(List<DocumentoEnMesa> documentos, List<TipoTira> tipos, int ronda) => [
          for (final documento in documentos)
            for (final tipo in tipos)
              Tira(
                id: 'r$ronda/${documento.id}/${tipo.name}',
                tipo: tipo,
                texto: documento.valor(tipo),
                idDocumentoOrigen: documento.id,
              ),
        ];

    final tirasRonda3 = tirasDe(documentosRonda3, [TipoTira.publico], 3);
    final idsEnMesa3 = documentosRonda3.map((d) => d.id).toSet();
    final textosEnMesa3 = tirasRonda3.map((t) => t.texto).toSet();
    final candidatasSobra = todas
        .where((d) =>
            !idsEnMesa3.contains(d.id) &&
            !textosEnMesa3.contains(d.valor(TipoTira.publico)))
        .toList()
      ..shuffle(azar);
    if (candidatasSobra.isNotEmpty) {
      final origen = candidatasSobra.first;
      tirasRonda3.add(Tira(
        id: 'r3/sobra/${origen.id}',
        tipo: TipoTira.publico,
        texto: origen.valor(TipoTira.publico),
        idDocumentoOrigen: origen.id,
        deSobra: true,
      ));
    }

    return PartidaDocumentoRoto._([
      RondaDocumentoRoto(
        documentos: documentosRonda1,
        tiras: tirasDe(documentosRonda1, [TipoTira.tipoFuente], 1)..shuffle(azar),
      ),
      RondaDocumentoRoto(
        documentos: documentosRonda2,
        tiras: tirasDe(documentosRonda2, [TipoTira.autor, TipoTira.fecha], 2)..shuffle(azar),
      ),
      RondaDocumentoRoto(documentos: documentosRonda3, tiras: tirasRonda3..shuffle(azar)),
    ]);
  }

  final List<RondaDocumentoRoto> rondas;
  int _indiceRonda = 0;

  /// Tira → documento donde quedó pegada.
  final Map<String, String> _colocadas = {};
  final Map<String, PrimerIntentoTira> _primerosIntentos = {};
  final Map<TipoTira, int> _vueltasPorTipo = {};

  int get indiceRonda => _indiceRonda;
  RondaDocumentoRoto get rondaActual => rondas[_indiceRonda];
  bool get esUltimaRonda => _indiceRonda == rondas.length - 1;

  String? documentoDe(Tira tira) => _colocadas[tira.id];

  /// `true` si todavía no se ha intentado colocar [tira]: el próximo
  /// [colocar] es el que cuenta para la maestría.
  bool esPrimerIntento(Tira tira) => !_primerosIntentos.containsKey(tira.id);

  List<Tira> tirasPegadasA(DocumentoEnMesa documento) => [
        for (final tira in rondaActual.tiras)
          if (_colocadas[tira.id] == documento.id) tira,
      ];

  List<Tira> get tirasSueltas =>
      rondaActual.tiras.where((t) => !_colocadas.containsKey(t.id)).toList();

  /// Intenta pegar [tira] en [documento]. Si no encaja, la tira vuelve
  /// a la mesa (no se pega en ningún sitio). Sólo el primer intento de
  /// cada tira se apunta.
  bool colocar(Tira tira, DocumentoEnMesa documento) {
    if (_colocadas.containsKey(tira.id)) return true;
    final encaja = tira.encajaEn(documento);
    _primerosIntentos.putIfAbsent(
        tira.id, () => PrimerIntentoTira(tira: tira, acierto: encaja));
    if (encaja) {
      _colocadas[tira.id] = documento.id;
    } else {
      _vueltasPorTipo[tira.tipo] = (_vueltasPorTipo[tira.tipo] ?? 0) + 1;
    }
    return encaja;
  }

  /// La ronda se completa cuando están pegadas todas las tiras que son
  /// de la mesa. La de sobra se queda en la caja.
  bool get rondaCompleta =>
      rondaActual.tirasQueSeColocan.every((t) => _colocadas.containsKey(t.id));

  bool siguienteRonda() {
    if (!rondaCompleta || esUltimaRonda) return false;
    _indiceRonda++;
    return true;
  }

  List<PrimerIntentoTira> get primerosIntentos => _primerosIntentos.values.toList();

  /// El tipo de tira que más veces se volvió a la mesa, o `null` si
  /// todas encajaron a la primera. Es lo único que comenta Andrés.
  TipoTira? get tipoConMasVueltas {
    if (_vueltasPorTipo.isEmpty) return null;
    return _vueltasPorTipo.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}
