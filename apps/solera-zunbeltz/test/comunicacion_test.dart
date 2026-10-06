// Peticiones de tarea y avisos de campo en la BD local.

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/modelos/aviso_campo.dart';
import 'package:solera_zunbeltz/modelos/finca.dart';
import 'package:solera_zunbeltz/modelos/peticion_tarea.dart';
import 'package:solera_zunbeltz/modelos/tarea_mantenimiento.dart';

import 'bd_en_memoria.dart';

void main() {
  late BaseDatosSoleraZunbeltz bd;
  late int fincaId;

  setUp(() async {
    bd = await abrirBdEnMemoria();
    fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
  });

  test('las peticiones pendientes y urgentes van delante', () async {
    await bd.guardarPeticion(PeticionTarea(titulo: 'Vieja', estado: estadoPeticionDescartada, fechaCreacionMs: 3));
    await bd.guardarPeticion(PeticionTarea(titulo: 'Normal', fechaCreacionMs: 2));
    await bd.guardarPeticion(PeticionTarea(titulo: 'Urgente', urgente: true, fechaCreacionMs: 1));
    final titulos = (await bd.listarPeticiones()).map((p) => p.titulo);
    expect(titulos, ['Urgente', 'Normal', 'Vieja']);
    expect(await bd.contarPeticionesPendientes(), 2);
  });

  test('aceptar una petición crea su tarea y la enlaza', () async {
    final peticionId = await bd.guardarPeticion(
        PeticionTarea(titulo: 'Falta pienso', fincaId: fincaId));
    final tarea = TareaMantenimiento(fincaId: fincaId, titulo: 'Comprar pienso');
    await bd.aceptarPeticion(peticionId, tarea);
    final peticion = (await bd.listarPeticiones()).single;
    expect(peticion.estado, estadoPeticionAceptada);
    expect(peticion.tareaUid, tarea.uid);
    expect((await bd.listarTareas()).single.titulo, 'Comprar pienso');
  });

  test('avisos: abiertos y alarmas primero; filtro por categoría', () async {
    await bd.guardarAviso(AvisoCampo(titulo: 'Resuelto', estado: estadoAvisoResuelto, fechaMs: 9));
    await bd.guardarAviso(AvisoCampo(titulo: 'Aviso', fechaMs: 8));
    await bd.guardarAviso(AvisoCampo(
        titulo: 'Oveja coja', gravedad: gravedadAlarma, categoria: categoriaAvisoGanado, fechaMs: 1));
    expect((await bd.listarAvisos()).map((a) => a.titulo), ['Oveja coja', 'Aviso', 'Resuelto']);
    expect((await bd.listarAvisos(categoria: categoriaAvisoGanado)).single.esAlarma, isTrue);
    expect((await bd.listarAvisos(soloAbiertos: true)).length, 2);
  });

  test('peticiones y avisos se suben con su finca por uid', () async {
    await bd.guardarAviso(AvisoCampo(titulo: 'Cierre roto', fincaId: fincaId));
    final entidades = await bd.entidadesPendientesDeSubir(0);
    final aviso = entidades.firstWhere((e) => e['tipo'] == 'aviso');
    expect((aviso['datos'] as Map)['finca_uid'], await bd.uidDeFila('fincas', fincaId));
  });
}
