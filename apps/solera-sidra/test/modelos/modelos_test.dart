import 'package:flutter_test/flutter_test.dart';
import 'package:solera_sidra/modelos/apunte_economico.dart';
import 'package:solera_sidra/modelos/codificacion.dart';
import 'package:solera_sidra/modelos/embotellado.dart';
import 'package:solera_sidra/modelos/kupela.dart';
import 'package:solera_sidra/modelos/partida_manzana.dart';
import 'package:solera_sidra/modelos/pomarada.dart';
import 'package:solera_sidra/modelos/prensado.dart';
import 'package:solera_sidra/modelos/sagardotegi.dart';
import 'package:solera_sidra/modelos/sesion_txotx.dart';
import 'package:solera_sidra/modelos/titular.dart';
import 'package:solera_sidra/modelos/tratamiento.dart';

void main() {
  test('los conjuntos de ids se codifican ordenados y sin vacíos', () {
    expect(
      codificarIds(['urtebi_txiki', ' ', 'errezila', 'errezila']),
      'errezila|urtebi_txiki',
    );
    expect(decodificarIds('a||b| '), {'a', 'b'});
    expect(decodificarIds(null), isEmpty);
  });

  test('titular y sagardotegi: ida y vuelta y valores fuera de lista', () {
    final titular = Titular.fromMap(
      Titular(
        nombre: 'Etxeberria',
        inscripcionDop: 'ES-12',
        regimenFiscal: 'reagp',
      ).toMap(),
    );
    expect(titular.inscripcionDop, 'ES-12');
    expect(titular.regimenFiscal, 'reagp');
    expect(
      Titular.fromMap({'regimen_fiscal': 'inventado'}).regimenFiscal,
      'general',
    );
    final sagardotegi = Sagardotegi.fromMap(
      Sagardotegi(
        nombre: 'Zapiain',
        perfil: 'txakoli',
        abreTxotx: false,
      ).toMap(),
    );
    expect(sagardotegi.elaboraSidra, isFalse);
    expect(sagardotegi.abreTxotx, isFalse);
    expect(Sagardotegi().estaSinConfigurar, isTrue);
    expect(Sagardotegi.fromMap({'perfil': 'x'}).perfil, 'sidra');
  });

  test('pomarada: SIGPAC, densidad y variedades', () {
    final pomarada = Pomarada.fromMap(
      Pomarada(
        nombre: 'Sagastia',
        poligono: '7',
        parcela: '112',
        recinto: '3',
        superficieHa: 0.5,
        numeroArboles: 150,
        variedades: {'errezila', 'goikoetxe'},
        registradaDop: true,
        latitud: 43.2,
      ).toMap(),
    );
    expect(pomarada.referenciaSigpac, '7/112/3');
    expect(pomarada.densidadArbolesHa, 300);
    expect(pomarada.variedades, {'errezila', 'goikoetxe'});
    expect(pomarada.registradaDop, isTrue);
    expect(pomarada.latitud, 43.2);
    expect(Pomarada(nombre: 'x').referenciaSigpac, '');
    expect(Pomarada(nombre: 'x').densidadArbolesHa, isNull);
    final manzano = Manzano.fromMap(
      Manzano(pomaradaId: 1, etiqueta: 'Fila 3', variedadId: 'moko').toMap(),
    );
    expect(manzano.variedadId, 'moko');
  });

  test('tratamiento: completo o incompleto para el cuaderno', () {
    final tratamiento = Tratamiento.fromMap(
      Tratamiento(
        pomaradaId: 1,
        fechaMs: 5,
        sustanciaActivaId: 'captan',
        numeroRegistroProducto: '12345',
        aplicador: 'Miren',
        eficacia: 'buena',
        superficieTratadaHa: 0.4,
      ).toMap(),
    );
    expect(tratamiento.estaIncompleto, isFalse);
    expect(tratamiento.eficacia, 'buena');
    expect(tratamiento.superficieTratadaHa, 0.4);
    expect(Tratamiento(pomaradaId: 1, fechaMs: 1).estaIncompleto, isTrue);
  });

  test('partida: propia o comprada decide de dónde sale el registro DOP', () {
    final comprada = PartidaManzana.fromMap(
      PartidaManzana(
        fechaEntregaMs: 1,
        kilos: 350.5,
        propia: false,
        proveedor: 'Auzokoa',
        proveedorRegistradoDop: true,
        variedades: {'errezila'},
        estadoFruta: 'danos_leves',
      ).toMap(),
    );
    expect(comprada.kilos, 350.5);
    expect(comprada.procedenciaRegistrada(), isTrue);
    expect(comprada.estadoFruta, 'danos_leves');
    final propia = PartidaManzana(fechaEntregaMs: 1, kilos: 1, pomaradaId: 2);
    expect(propia.procedenciaRegistrada(), isFalse);
    expect(propia.procedenciaRegistrada(pomaradaRegistrada: true), isTrue);
    expect(
      PartidaManzana.fromMap(propia.toMap()..['fruta'] = 'uva').fruta,
      'uva',
    );
  });

  test('prensado: rendimiento en litros por 100 kg', () {
    final prensado = Prensado.fromMap(
      Prensado(
        fechaMs: 1,
        kupelaId: 1,
        kilosFruta: 1000,
        litrosMosto: 650,
        densidadMosto: 1048,
      ).toMap(),
    );
    expect(prensado.rendimientoPorcentaje, 65);
    expect(prensado.densidadMosto, 1048);
    expect(
      Prensado(
        fechaMs: 1,
        kupelaId: 1,
        kilosFruta: 0,
        litrosMosto: 1,
      ).rendimientoPorcentaje,
      isNull,
    );
  });

  test('kupela, medición y trasiego: ida y vuelta', () {
    final kupela = Kupela.fromMap(
      Kupela(
        codigo: 'K7',
        nombre: 'Aitona',
        capacidadLitros: 12000,
        calificacion: 'apta',
      ).toMap(),
    );
    expect(kupela.etiqueta, 'K7 · Aitona');
    expect(kupela.calificacion, 'apta');
    expect(Kupela.fromMap({'codigo': 'x', 'material': '?'}).material, 'otro');
    final medicion = MedicionKupela.fromMap(
      MedicionKupela(
        kupelaId: 1,
        fechaMs: 1,
        acidezVolatilGL: 1.1,
        densidad: 999,
      ).toMap(),
    );
    expect(medicion.acidezVolatilGL, 1.1);
    expect(medicion.estaVacia, isFalse);
    expect(MedicionKupela(kupelaId: 1, fechaMs: 1).estaVacia, isTrue);
    final trasiego = Trasiego.fromMap(
      Trasiego(
        fechaMs: 1,
        kupelaOrigenId: 1,
        kupelaDestinoId: 2,
        litros: 9,
      ).toMap(),
    );
    expect(trasiego.esRetirada, isFalse);
  });

  test('embotellado: litros, contraetiquetas y código de lote', () {
    final embotellado = Embotellado.fromMap(
      Embotellado(
        fechaMs: 1,
        kupelaId: 1,
        codigoLote: 'L',
        botellas: 120,
        mililitrosBotella: 700,
        conDop: true,
        etiquetaDesde: 1001,
        etiquetaHasta: 1120,
      ).toMap(),
    );
    expect(embotellado.litros, 84);
    expect(embotellado.etiquetasUsadas, 120);
    expect(embotellado.etiquetasDescuadradas, isFalse);
    expect(
      Embotellado(
        fechaMs: 1,
        kupelaId: 1,
        codigoLote: 'L',
        botellas: 10,
        conDop: true,
        etiquetaDesde: 1,
        etiquetaHasta: 12,
      ).etiquetasDescuadradas,
      isTrue,
    );
    expect(codigoLoteEmbotellado(DateTime(2027, 3, 4), 'K-7'), '20270304-K7');
  });

  test('sesión de txotx: ida y vuelta', () {
    final sesion = SesionTxotx.fromMap(
      SesionTxotx(
        fechaMs: 1,
        kupelaId: 3,
        litrosServidos: 180.5,
        comensales: 60,
      ).toMap(),
    );
    expect(sesion.litrosServidos, 180.5);
    expect(sesion.comensales, 60);
  });

  test('apunte: IVA o compensación del REAGP, nunca los dos', () {
    final conIva = ApunteEconomico(
      esIngreso: true,
      fechaMs: 1,
      concepto: 'Botellas',
      categoria: 'venta_sidra_botella',
      baseCentimos: 10000,
      tipoIvaPorcentaje: 21,
    );
    expect(conIva.cuotaIvaCentimos, 2100);
    expect(conIva.totalCentimos, 12100);
    final reagp = ApunteEconomico.fromMap(
      ApunteEconomico(
        esIngreso: true,
        fechaMs: 1,
        concepto: 'Manzana a Petritegi',
        categoria: 'venta_manzana',
        baseCentimos: 10000,
        tipoIvaPorcentaje: 4,
        conCompensacionReagp: true,
      ).toMap(),
    );
    expect(reagp.cuotaIvaCentimos, 0);
    expect(reagp.compensacionReagpCentimos, 1200);
    expect(reagp.totalCentimos, 11200);
  });
}
