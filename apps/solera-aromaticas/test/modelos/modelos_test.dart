import 'package:flutter_test/flutter_test.dart';
import 'package:solera_aromaticas/modelos/cosecha.dart';
import 'package:solera_aromaticas/modelos/destilacion.dart';
import 'package:solera_aromaticas/modelos/lista_ids.dart';
import 'package:solera_aromaticas/modelos/lote_producto.dart';
import 'package:solera_aromaticas/modelos/parcela.dart';
import 'package:solera_aromaticas/modelos/secado.dart';
import 'package:solera_aromaticas/modelos/titular.dart';
import 'package:solera_aromaticas/modelos/zona_recoleccion.dart';

int ms(int anyo, int mes, int dia, [int hora = 0]) =>
    DateTime(anyo, mes, dia, hora).millisecondsSinceEpoch;

void main() {
  test('titular y parcela: ida y vuelta', () {
    final titular = Titular.fromMap(Titular(
            nombre: 'Ane',
            comunidadAutonoma: 'Navarra',
            registroSanitario: 'RS-1')
        .toMap());
    expect((titular.comunidadAutonoma, titular.registroSanitario),
        ('Navarra', 'RS-1'));
    final parcela = Parcela.fromMap(Parcela(
            nombre: 'Ladera',
            especieId: 'lavandin',
            superficieHa: 1.5,
            ecologico: true,
            latitud: 42.1,
            longitud: -1.6)
        .toMap());
    expect((parcela.ecologico, parcela.superficieHa, parcela.tieneUbicacion),
        (true, 1.5, true));
    final movida = parcela.copiarConUbicacion(43, -2);
    expect((movida.latitud, movida.nombre), (43, 'Ladera'));
  });

  test('listas: barras y JSON, defensivas con datos rotos', () {
    expect(unirLista([' tomillo ', '', 'romero']), 'tomillo|romero');
    expect(separarLista('tomillo||romero '), ['tomillo', 'romero']);
    expect(separarLista(null), isEmpty);
    expect(decodificarIds(codificarIds([1, 4, 7])), [1, 4, 7]);
    expect(decodificarIds('no es json'), isEmpty);
    expect(decodificarIds('{"a":1}'), isEmpty);
  });

  test('zona: ida y vuelta, vigencia con extremos incluidos', () {
    final zona = ZonaRecoleccion.fromMap(ZonaRecoleccion(
      nombre: 'Monte comunal',
      numeroPermiso: 'AUT-23/45',
      inicioVigenciaMs: ms(2026, 5, 1, 10),
      finVigenciaMs: ms(2026, 9, 30),
      especiesPermitidas: ['tomillo_comun', 'romero'],
      limiteKg: 500,
    ).toMap());
    expect(zona.especiesPermitidas, ['tomillo_comun', 'romero']);
    expect(zona.limiteKg, 500);
    expect(zona.vigenteEn(DateTime(2026, 5, 1, 6)), isTrue,
        reason: 'el día de inicio cuenta entero');
    expect(zona.vigenteEn(DateTime(2026, 9, 30, 23, 59)), isTrue);
    expect(zona.vigenteEn(DateTime(2026, 10, 1)), isFalse);
    expect(zona.vigenteEn(DateTime(2026, 4, 30, 23)), isFalse);
    expect(zona.diasHastaFinVigencia(DateTime(2026, 9, 20, 18)), 10);
    expect(zona.cubreEspecie('romero'), isTrue);
    expect(zona.cubreEspecie('salvia'), isFalse);
  });

  test('zona sin permiso nunca está vigente; sin especies no se sabe', () {
    final zona = ZonaRecoleccion(nombre: 'Barranco');
    expect(zona.tienePermiso, isFalse);
    expect(zona.vigenteEn(DateTime(2026)), isFalse);
    expect(zona.dentroDeVigencia(DateTime(2026)), isTrue);
    expect(zona.cubreEspecie('romero'), isNull);
    expect(
        ZonaRecoleccion.fromMap({'nombre': 'x', 'tipo_terreno': 'raro'})
            .tipoTerreno,
        'otro');
  });

  test('cosecha: de parcela o de zona, nunca de las dos', () {
    final silvestre = Cosecha.fromMap(Cosecha(
            zonaRecoleccionId: 3,
            especieId: 'tomillo_comun',
            fechaMs: ms(2026, 6, 10),
            kgFrescos: 80,
            estadoFenologico: 'plena_floracion')
        .toMap());
    expect((silvestre.esSilvestre, silvestre.campania, silvestre.kgFrescos),
        (true, 2026, 80));
    expect(
        () => Cosecha(
            parcelaId: 1, zonaRecoleccionId: 2, especieId: 'x', fechaMs: 0),
        throwsA(isA<AssertionError>()));
    expect(() => Cosecha(especieId: 'x', fechaMs: 0),
        throwsA(isA<AssertionError>()));
  });

  test('secado y destilación: ida y vuelta con sus cosechas', () {
    final secado = Secado.fromMap(Secado(
            fechaInicioMs: 5,
            especieId: 'manzanilla',
            cosechasUsadasIds: [2, 3],
            kgFrescos: 100,
            kgSecos: 22,
            dias: 6,
            metodo: 'secadero_aire',
            loteProductoId: 9)
        .toMap());
    expect(secado.cosechasUsadasIds, [2, 3]);
    expect((secado.metodo, secado.loteProductoId), ('secadero_aire', 9));
    final destilacion = Destilacion.fromMap(Destilacion(
            fechaMs: 7,
            especieId: 'lavandin',
            cosechasUsadasIds: [4],
            kgPlanta: 300,
            mlAceiteEsencial: 3000,
            litrosHidrolato: 150,
            horas: 2.5,
            loteAceiteId: 1,
            loteHidrolatoId: 2)
        .toMap());
    expect((
      destilacion.mlAceiteEsencial,
      destilacion.litrosHidrolato,
      destilacion.horas,
      destilacion.loteHidrolatoId
    ), (
      3000,
      150,
      2.5,
      2
    ));
    expect(
        Destilacion.fromMap({
          'fecha_ms': 1,
          'estado_planta': 'congelada',
          'tipo_alambique': 'raro'
        }).estadoPlanta,
        'fresca');
  });

  test('lote: unidades por tipo, destinos sin medicamento, código', () {
    expect(destinosLote, isNot(contains('medicamento')));
    final lote = LoteProducto.fromMap(LoteProducto(
            codigo: 'AE-2026-001',
            tipo: 'aceite_esencial',
            especieId: 'lavandin',
            fechaMs: 1,
            destino: 'cosmetico',
            cantidad: 3000)
        .toMap());
    expect((lote.unidad, lote.disponible, lote.destino),
        ('ml', 3000, 'cosmetico'));
    expect(
        LoteProducto.fromMap(
            {'codigo': 'x', 'fecha_ms': 1, 'destino': 'medicamento'}).destino,
        'sin_decidir');
    expect(proponerCodigoLote('aceite_esencial', 2026, ['AE-2026-001']),
        'AE-2026-002');
    expect(proponerCodigoLote('hidrolato', 2027, const []), 'HI-2027-001');
  });
}
