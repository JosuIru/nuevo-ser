// Integración: un móvil que sembró el espacio con una versión anterior de la
// app recibe, al sincronizar, lo que el plugin ha puesto al día en el
// servidor (includes/actualizar-espacio-sembrado.php): renombres, zonas
// nuevas y las retiradas. Se salta sin servidor:
//
//   SZS_URL=http://zunbeltz-app.local SZS_COORDINACION=<token> \
//     flutter test test/integracion_espacio_sembrado_test.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/servicios/cliente_sync_zunbeltz.dart';

import 'bd_en_memoria.dart';

void main() {
  final url = Platform.environment['SZS_URL'] ?? '';
  final token = Platform.environment['SZS_COORDINACION'] ?? '';

  test('un móvil con la siembra antigua recibe el espacio al día', () async {
    final bd = await abrirBdEnMemoria();
    await bd.sembrarEspacioRealSiVacia();
    final db = await bd.basedatos;
    // Así quedaba la siembra de la 0.5.12: los parques con otro nombre y el
    // monte del norte, que ya no se siembra.
    await db.update('zonas_finca', {'nombre': 'Parques (por confirmar)'},
        where: 'uid = ?', whereArgs: ['zona-zunbeltz-parques-por-confirmar']);
    final fincaId = (await db
            .query('fincas', where: 'uid = ?', whereArgs: ['finca-zunbeltz']))
        .single['id'];
    await db.insert('zonas_finca', {
      'uid': 'zona-zunbeltz-monte-norte',
      'actualizado_ms': BaseDatosSoleraZunbeltz.marcaSembrado,
      'finca_id': fincaId,
      'tipo': 'monte',
      'nombre': 'Monte (norte)',
      'vertices_json': '[[42.82,-2.03],[42.821,-2.03],[42.821,-2.031]]',
      'estado': 'en_uso',
      'fecha_creacion_ms': 1,
    });

    await ClienteSyncZunbeltz(urlBase: url, token: token).sincronizar(bd);

    final nombres = (await bd.listarZonas()).map((zona) => zona.nombre).toSet();
    expect(
        nombres,
        containsAll([
          'Parque de cerdos 1',
          'Parque de cerdos 2',
          'Enfermería',
          'Pasillo',
          'Monte 1',
          'La Cañada',
        ]));
    expect(nombres, isNot(contains('Pieza sin nombre A (norte)')));
    expect(nombres, isNot(contains('Parques (por confirmar)')));
    expect(nombres, isNot(contains('Monte (norte)')));
  },
      skip: url.isEmpty || token.isEmpty
          ? 'sin SZS_URL / SZS_COORDINACION'
          : false);
}
