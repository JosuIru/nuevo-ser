import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_roto/datos/repositorio_ciudad.dart';
import 'package:uno_roto/datos/repositorio_progreso.dart';
import 'package:uno_roto/dominio/catalogo_distritos.dart';
import 'package:uno_roto/dominio/taller_ciudad.dart';

/// Tests del taller de restauración (doc 16, eje B): coherencia del
/// catálogo de piezas y contrato del repositorio (saldo disponible,
/// doble compra, gasto que nunca toca las esquirlas ganadas).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CatalogoTaller — coherencia', () {
    test('los ids son únicos', () {
      final ids = CatalogoTaller.todas.map((p) => p.id).toSet();
      expect(ids.length, CatalogoTaller.todas.length);
    });

    test('toda pieza pertenece a un distrito del catálogo', () {
      final distritos =
          CatalogoDistritos.todos.map((d) => d.identificador).toSet();
      for (final pieza in CatalogoTaller.todas) {
        expect(distritos.contains(pieza.idDistrito), isTrue,
            reason: '${pieza.id} apunta a un distrito inexistente');
        expect(pieza.id.startsWith('${pieza.idDistrito}.'), isTrue,
            reason: '${pieza.id} debe llevar su distrito como prefijo');
      }
    });

    test('todo distrito tiene piezas y sin tipos repetidos', () {
      for (final distrito in CatalogoDistritos.todos) {
        final piezas = CatalogoTaller.delDistrito(distrito.identificador);
        expect(piezas, isNotEmpty,
            reason: '${distrito.identificador} se quedó sin piezas');
        final tipos = piezas.map((p) => p.tipoVisual).toSet();
        expect(tipos.length, piezas.length,
            reason: 'En ${distrito.identificador} hay dos piezas del '
                'mismo tipo visual — el pintor las solaparía');
      }
    });

    test('posiciones dentro de la franja urbana del escenario', () {
      for (final pieza in CatalogoTaller.todas) {
        expect(pieza.xEscena, inInclusiveRange(0.05, 0.95));
        expect(pieza.yEscena, inInclusiveRange(0.65, 0.92),
            reason: '${pieza.id} caería fuera de la banda de ciudad');
      }
    });

    test('porId encuentra y devuelve null para desconocidos', () {
      expect(CatalogoTaller.porId('tejados.farola_esquina'), isNotNull);
      expect(CatalogoTaller.porId('inventada.pieza'), isNull);
    });
  });

  group('RepositorioCiudad', () {
    const precio = CatalogoTaller.precioPlano;

    test('restaurar descuenta del disponible sin tocar lo ganado', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = RepositorioProgreso();
      final resultado = await repo.ciudad.restaurarPieza(
        idPieza: 'tejados.farola_esquina',
        precio: precio,
        esquirlasGanadas: 25,
      );
      expect(resultado, ResultadoRestauracion.hecha);
      expect(await repo.ciudad.cargarEsquirlasGastadas(), precio);
      expect(
        await repo.ciudad.cargarPiezasRestauradas(),
        {'tejados.farola_esquina'},
      );
    });

    test('sin saldo suficiente no restaura ni apunta gasto', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = RepositorioProgreso();
      final resultado = await repo.ciudad.restaurarPieza(
        idPieza: 'tejados.farola_esquina',
        precio: precio,
        esquirlasGanadas: precio - 1,
      );
      expect(resultado, ResultadoRestauracion.sinEsquirlas);
      expect(await repo.ciudad.cargarEsquirlasGastadas(), 0);
      expect(await repo.ciudad.cargarPiezasRestauradas(), isEmpty);
    });

    test('el saldo disponible resta lo ya gastado', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = RepositorioProgreso();
      // Con 25 ganadas: la primera pieza (10) entra, la segunda (10)
      // entra, la tercera ya no (25 - 20 = 5 < 10).
      await repo.ciudad.restaurarPieza(
        idPieza: 'tejados.farola_esquina',
        precio: precio,
        esquirlasGanadas: 25,
      );
      await repo.ciudad.restaurarPieza(
        idPieza: 'tejados.ventanas_atico',
        precio: precio,
        esquirlasGanadas: 25,
      );
      final tercera = await repo.ciudad.restaurarPieza(
        idPieza: 'tejados.guirnalda_patio',
        precio: precio,
        esquirlasGanadas: 25,
      );
      expect(tercera, ResultadoRestauracion.sinEsquirlas);
      expect(await repo.ciudad.cargarEsquirlasGastadas(), 2 * precio);
    });

    test('una pieza no se paga dos veces', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = RepositorioProgreso();
      await repo.ciudad.restaurarPieza(
        idPieza: 'canales.farolillo_puente',
        precio: precio,
        esquirlasGanadas: 100,
      );
      final segunda = await repo.ciudad.restaurarPieza(
        idPieza: 'canales.farolillo_puente',
        precio: precio,
        esquirlasGanadas: 100,
      );
      expect(segunda, ResultadoRestauracion.yaRestaurada);
      expect(await repo.ciudad.cargarEsquirlasGastadas(), precio);
    });
  });
}
