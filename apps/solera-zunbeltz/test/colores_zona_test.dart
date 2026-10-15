import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/datos/espacio_generado.dart';
import 'package:solera_zunbeltz/modelos/constantes.dart';
import 'package:solera_zunbeltz/modelos/zona_finca.dart';
import 'package:solera_zunbeltz/utiles/estilos_tarea.dart';

import 'bd_en_memoria.dart';

void main() {
  test('el color elegido manda; sin elegir, el de su tipo', () {
    final elegido = ZonaFinca(fincaId: 1, tipo: 'monte', color: 'rojo');
    expect(colorDeZona(elegido), paletaZonas['rojo']);
    final automatico = ZonaFinca(fincaId: 1, tipo: 'monte');
    expect(colorDeZona(automatico), paletaZonas[colorPorTipoZona['monte']]);
    final raro = ZonaFinca(fincaId: 1, tipo: 'inventado', color: 'fucsia');
    expect(colorDeZona(raro), isA<Color>());
  });

  test('cada tipo de zona tiene color, y todos los de la paleta tienen nombre',
      () {
    for (final tipo in tiposZona) {
      expect(paletaZonas[colorPorTipoZona[tipo.codigo]], isNotNull,
          reason: tipo.codigo);
    }
    expect(paletaZonas.keys.toSet(),
        coloresZona.map((opcion) => opcion.codigo).toSet());
  });

  test('el estado se ve en la línea: continua, discontinua o de puntos', () {
    expect(patronEstadoZona('en_uso'), const StrokePattern.solid());
    expect(patronEstadoZona('descanso'), isNot(const StrokePattern.solid()));
    expect(patronEstadoZona('vedada'), isNot(patronEstadoZona('descanso')));
  });

  test('el color se guarda y se lee', () async {
    final zona = ZonaFinca(fincaId: 1, color: 'cian');
    expect(ZonaFinca.fromMap(zona.toMap()).color, 'cian');
    expect(ZonaFinca.fromMap({'finca_id': 1}).color, '');

    final bd = await abrirBdEnMemoria();
    final db = await bd.basedatos;
    final columnas = await db.rawQuery('PRAGMA table_info(zonas_finca)');
    expect(columnas.map((columna) => columna['name']), contains('color'));
  });

  test('las zonas de Zunbeltz vienen con los colores del mapa', () {
    final perimetro =
        zonasEspacio.singleWhere((z) => z.nombre == 'Cierre perimetral');
    expect(perimetro.color, 'amarillo');
    for (final zona in zonasEspacio) {
      expect(paletaZonas.containsKey(zona.color) || zona.color.isEmpty, isTrue,
          reason: zona.nombre);
    }
  });
}
