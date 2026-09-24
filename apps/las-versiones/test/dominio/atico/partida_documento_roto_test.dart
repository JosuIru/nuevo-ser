import 'package:flutter_test/flutter_test.dart';
import 'package:las_versiones/dominio/atico/oficios_atico.dart';
import 'package:las_versiones/dominio/atico/partida_documento_roto.dart';
import 'package:las_versiones/dominio/brecha.dart';
import 'package:las_versiones/dominio/catalogo_brechas.dart';

void main() {
  final soloPrimera = brechasCerradas({CatalogoBrechas.brecha11.flagDeCompletado});
  final varias = brechasCerradas({
    CatalogoBrechas.brecha11.flagDeCompletado,
    CatalogoBrechas.brecha21.flagDeCompletado,
    CatalogoBrechas.brecha31.flagDeCompletado,
  });

  DocumentoEnMesa? documentoDondeEncaja(PartidaDocumentoRoto partida, Tira tira) {
    for (final documento in partida.rondaActual.documentos) {
      if (tira.encajaEn(documento)) return documento;
    }
    return null;
  }

  void resolverRonda(PartidaDocumentoRoto partida) {
    for (final tira in partida.rondaActual.tirasQueSeColocan) {
      partida.colocar(tira, documentoDondeEncaja(partida, tira)!);
    }
  }

  test('sin fuentes suficientes no hay partida', () {
    expect(PartidaDocumentoRoto.montar(const []), isNull);
  });

  test('tres rondas con los tipos de tira del diseño', () {
    final partida = PartidaDocumentoRoto.montar(varias, semilla: 1)!;
    expect(partida.rondas, hasLength(3));
    expect(partida.rondas[0].tiras.map((t) => t.tipo).toSet(), {TipoTira.tipoFuente});
    expect(partida.rondas[1].tiras.map((t) => t.tipo).toSet(),
        {TipoTira.autor, TipoTira.fecha});
    expect(partida.rondas[2].tiras.map((t) => t.tipo).toSet(), {TipoTira.publico});
  });

  test('la primera mesa tiene una primaria y una secundaria si la Brecha las tiene', () {
    for (var semilla = 0; semilla < 10; semilla++) {
      final partida = PartidaDocumentoRoto.montar(soloPrimera, semilla: semilla)!;
      final tipos = partida.rondas.first.documentos
          .map((d) => d.fuente.propiedadesCanonicas.tipo)
          .toSet();
      expect(tipos, {TipoFuente.primaria, TipoFuente.secundaria}, reason: 'semilla $semilla');
    }
  });

  test('la tira de sobra no encaja en ningún documento de su mesa', () {
    for (var semilla = 0; semilla < 10; semilla++) {
      final ronda = PartidaDocumentoRoto.montar(varias, semilla: semilla)!.rondas.last;
      final sobras = ronda.tiras.where((t) => t.deSobra).toList();
      expect(sobras, hasLength(1), reason: 'semilla $semilla');
      for (final documento in ronda.documentos) {
        expect(sobras.single.encajaEn(documento), isFalse);
      }
    }
  });

  test('toda tira que se coloca tiene al menos un documento donde encaja', () {
    final partida = PartidaDocumentoRoto.montar(varias, semilla: 4)!;
    for (final ronda in partida.rondas) {
      for (final tira in ronda.tirasQueSeColocan) {
        expect(ronda.documentos.any(tira.encajaEn), isTrue, reason: tira.id);
      }
    }
  });

  test('una tira que no encaja vuelve a la mesa y se apunta el fallo una vez', () {
    final partida = PartidaDocumentoRoto.montar(varias, semilla: 2)!;
    final ronda = partida.rondaActual;
    final tira = ronda.tirasQueSeColocan.first;
    final equivocado = ronda.documentos.firstWhere((d) => !tira.encajaEn(d));

    expect(partida.colocar(tira, equivocado), isFalse);
    expect(partida.colocar(tira, equivocado), isFalse);
    expect(partida.documentoDe(tira), isNull);
    expect(partida.tirasSueltas, contains(tira));

    expect(partida.colocar(tira, documentoDondeEncaja(partida, tira)!), isTrue);
    final intento = partida.primerosIntentos.single;
    expect(intento.acierto, isFalse, reason: 'cuenta el primer intento');
    expect(intento.idHabilidad, 'HF.02');
    expect(partida.tipoConMasVueltas, TipoTira.tipoFuente);
  });

  test('no se avanza sin completar; la de sobra no hace falta colocarla', () {
    final partida = PartidaDocumentoRoto.montar(varias, semilla: 3)!;
    expect(partida.siguienteRonda(), isFalse);
    resolverRonda(partida);
    expect(partida.siguienteRonda(), isTrue);
    resolverRonda(partida);
    expect(partida.siguienteRonda(), isTrue);
    resolverRonda(partida);
    expect(partida.rondaCompleta, isTrue);
    expect(partida.tirasSueltas.single.deSobra, isTrue);
    expect(partida.siguienteRonda(), isFalse, reason: 'era la última');
    expect(partida.tipoConMasVueltas, isNull);
    expect(partida.primerosIntentos.every((i) => i.acierto), isTrue);
  });
}
