import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_sidra/dominio/saldo_kupelas.dart';
import 'package:solera_sidra/modelos/embotellado.dart';
import 'package:solera_sidra/modelos/kupela.dart';
import 'package:solera_sidra/modelos/partida_manzana.dart';
import 'package:solera_sidra/modelos/pomarada.dart';
import 'package:solera_sidra/modelos/prensado.dart';
import 'package:solera_sidra/modelos/sesion_txotx.dart';
import 'package:solera_sidra/modelos/titular.dart';
import 'package:solera_sidra/modelos/tratamiento.dart';
import 'package:solera_sidra/servicios/generador_cuaderno_pomarada_pdf.dart';
import 'package:solera_sidra/servicios/generador_libro_elaboracion_pdf.dart';

void main() {
  setUpAll(initializeDateFormatting);

  final fecha = DateTime(2026, 10, 10).millisecondsSinceEpoch;
  final pomaradas = [
    Pomarada(
        id: 1,
        nombre: 'Goiko',
        poligono: '7',
        parcela: '12',
        recinto: '1',
        registradaDop: true,
        variedades: {'errezila'}),
  ];
  final tratamientos = [
    Tratamiento(
        pomaradaId: 1,
        fechaMs: fecha,
        sustanciaActivaId: 'captan',
        plagaObjetivoId: 'moteado',
        numeroRegistroProducto: '25.123',
        aplicador: 'Miren'),
    Tratamiento(pomaradaId: 1, fechaMs: fecha - 1000),
  ];
  final partidas = [
    PartidaManzana(id: 10, fechaEntregaMs: fecha, kilos: 1000, pomaradaId: 1),
    PartidaManzana(
        id: 11,
        fechaEntregaMs: fecha,
        kilos: 500,
        propia: false,
        proveedor: 'Auzoa'),
  ];
  final kupelas = [
    Kupela(id: 1, codigo: 'K1', capacidadLitros: 2000),
    Kupela(id: 2, codigo: 'K2', capacidadLitros: 2000),
  ];
  final prensados = [
    Prensado(
        id: 5,
        fechaMs: fecha,
        kupelaId: 1,
        kilosFruta: 1500,
        litrosMosto: 1000),
  ];
  final trasiegos = [
    Trasiego(
        fechaMs: fecha + 1, kupelaOrigenId: 1, kupelaDestinoId: 2, litros: 400),
  ];
  final sesiones = [
    SesionTxotx(fechaMs: fecha + 2, kupelaId: 1, litrosServidos: 100)
  ];
  final embotellados = [
    Embotellado(
        fechaMs: fecha + 3,
        kupelaId: 2,
        codigoLote: 'L1',
        botellas: 200,
        conDop: true,
        etiquetaDesde: 1,
        etiquetaHasta: 200),
  ];
  final datosLibro = DatosLibroElaboracion(
    campania: 2026,
    pomaradas: pomaradas,
    partidas: partidas,
    prensados: prensados,
    partidasPorPrensado: {
      5: [10, 11]
    },
    kupelas: kupelas,
    trasiegos: trasiegos,
    sesionesTxotx: sesiones,
    embotellados: embotellados,
    saldoAlCierre: SaldoKupelas.calcular(
        prensados: prensados,
        trasiegos: trasiegos,
        sesionesTxotx: sesiones,
        embotellados: embotellados),
  );

  test('cuaderno: tratamientos en orden y sin inventar datos', () {
    final tablas = tablasCuadernoPomarada(
        pomaradas: pomaradas,
        tratamientos: tratamientos,
        partidasPropias: partidas.where((partida) => partida.propia).toList());
    expect(tablas, hasLength(3));
    final filasTratamientos = tablas[1].filas;
    expect(filasTratamientos, hasLength(2));
    expect(filasTratamientos.last[1], 'Goiko (7/12/1)');
    expect(filasTratamientos.last[2], 'Manzano (pomarada): Errezila');
    expect(filasTratamientos.last[4], 'Captan');
    // Sin marca: el nombre comercial queda en blanco para escribirlo a mano.
    expect(filasTratamientos.last[5], startsWith('_____'));
    expect(filasTratamientos.last[5], endsWith('25.123'));
    expect(filasTratamientos.last[8], '—'); // sin equipo apuntado
    expect(filasTratamientos.last[9], 'Miren');
    // El incompleto (el primero por fecha) sale con «—», no con un valor.
    expect(filasTratamientos.first[4], '—');
    // Las parcelas llevan n.º de orden (anexo III, A.2.a).
    expect(tablas[0].filas.single.first, '1');
    expect(tablas[2].filas.single[3], '1.000');
  });

  test('libro: entradas, kupelas, embotellado y balance', () {
    final tablas = tablasLibroElaboracion(datosLibro);
    final entradas = tablas[0].filas;
    expect(entradas, hasLength(2));
    expect(entradas.map((fila) => fila.last), ['Sí', 'No']);
    final kupelasFilas = tablas[2].filas;
    // K1: entra 1000, sale 400 + 100 → 500. K2: entra 400, sale 150 → 250.
    expect(kupelasFilas[0].sublist(3, 6), ['1.000', '500', '500']);
    expect(kupelasFilas[1].sublist(3, 6), ['400', '150', '250']);
    final lote = tablas[5].filas.single;
    expect(lote[6], '1–200');
    expect(lote[7], '200');
    final balance = tablas.last.filas;
    expect(balance.last.last, '750 l');
    expect(datosLibro.contraetiquetasUsadas, 200);
  });

  test('los dos PDF se generan con el sello', () async {
    final titular = Titular(nombre: 'Zelaia', inscripcionDop: 'ES-7');
    final cuaderno = await generarCuadernoPomaradaPdf(
        campania: 2026,
        titular: titular,
        pomaradas: pomaradas,
        tratamientos: tratamientos,
        partidasPropias: const []);
    final libro =
        await generarLibroElaboracionPdf(titular: titular, datos: datosLibro);
    expect(cuaderno.length, greaterThan(1000));
    expect(libro.length, greaterThan(1000));
    expect(selloCuadernoPomarada, 'PROVISIONAL');
    expect(selloLibroElaboracion, 'PROVISIONAL');
  });
}
