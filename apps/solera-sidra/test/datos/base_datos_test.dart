import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:solera_sidra/datos/base_datos.dart';
import 'package:solera_sidra/modelos/embotellado.dart';
import 'package:solera_sidra/modelos/kupela.dart';
import 'package:solera_sidra/modelos/partida_manzana.dart';
import 'package:solera_sidra/modelos/pomarada.dart';
import 'package:solera_sidra/modelos/prensado.dart';
import 'package:solera_sidra/modelos/sagardotegi.dart';
import 'package:solera_sidra/modelos/sesion_txotx.dart';
import 'package:solera_sidra/modelos/titular.dart';
import 'package:solera_sidra/modelos/tratamiento.dart';

import 'soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraSidra.instancia;

  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  test('crea $nombreFicheroBaseDatosSidra en la versión declarada', () async {
    final db = await baseDatos.basedatos;
    expect(await db.getVersion(), versionEsquemaSidra);
    expect(
      File(entorno.ruta(nombreFicheroBaseDatosSidra)).existsSync(),
      isTrue,
    );
  });

  test('titular y sagardotegi se guardan en una sola fila', () async {
    await baseDatos.guardarTitular(Titular(nombre: 'Primera'));
    await baseDatos.guardarTitular(
      Titular(nombre: 'Segunda', regimenFiscal: 'reagp'),
    );
    await baseDatos.guardarSagardotegi(Sagardotegi(nombre: 'Uno'));
    await baseDatos.guardarSagardotegi(
      Sagardotegi(nombre: 'Dos', perfil: 'ambos'),
    );
    final db = await baseDatos.basedatos;
    expect(await db.query('titulares'), hasLength(1));
    expect(await db.query('sagardotegis'), hasLength(1));
    expect((await baseDatos.obtenerTitular()).regimenFiscal, 'reagp');
    final sagardotegi = await baseDatos.obtenerSagardotegi();
    expect(sagardotegi.nombre, 'Dos');
    expect(sagardotegi.elaboraTxakoli, isTrue);
  });

  test('trazabilidad: el prensado guarda sus partidas sin repetir', () async {
    final pomarada = await baseDatos.guardarPomarada(
      Pomarada(nombre: 'Goiko soroa'),
    );
    final propia = await baseDatos.guardarPartida(
      PartidaManzana(fechaEntregaMs: 10, kilos: 800, pomaradaId: pomarada),
    );
    final comprada = await baseDatos.guardarPartida(
      PartidaManzana(
        fechaEntregaMs: 11,
        kilos: 400,
        propia: false,
        proveedor: 'Auzoa',
      ),
    );
    final kupela = await baseDatos.guardarKupela(
      Kupela(codigo: 'K1', capacidadLitros: 5000),
    );
    final prensado = await baseDatos.guardarPrensado(
      Prensado(
        fechaMs: 12,
        kupelaId: kupela,
        kilosFruta: 1200,
        litrosMosto: 780,
      ),
      partidas: [propia, comprada, propia],
    );
    expect(
      (await baseDatos.partidasPorPrensado())[prensado],
      unorderedEquals([propia, comprada]),
    );
    expect(await baseDatos.partidasPrensadas(), {propia, comprada});
    // Reguardar sustituye las partidas.
    await baseDatos.guardarPrensado(
      Prensado(
        id: prensado,
        fechaMs: 12,
        kupelaId: kupela,
        kilosFruta: 800,
        litrosMosto: 520,
      ),
      partidas: [propia],
    );
    expect((await baseDatos.partidasPorPrensado())[prensado], [propia]);
  });

  test(
    'no se borra una kupela con movimientos ni una pomarada con tratamientos',
    () async {
      final kupela = await baseDatos.guardarKupela(
        Kupela(codigo: 'K2', capacidadLitros: 1),
      );
      await baseDatos.guardarSesionTxotx(
        SesionTxotx(fechaMs: 1, kupelaId: kupela, litrosServidos: 50),
      );
      final pomarada = await baseDatos.guardarPomarada(
        Pomarada(nombre: 'Behe'),
      );
      await baseDatos.guardarTratamiento(
        Tratamiento(pomaradaId: pomarada, fechaMs: 1),
      );
      final db = await baseDatos.basedatos;
      await expectLater(
        db.delete('kupelas', where: 'id = ?', whereArgs: [kupela]),
        throwsA(anything),
      );
      await expectLater(
        db.delete('pomaradas', where: 'id = ?', whereArgs: [pomarada]),
        throwsA(anything),
      );
    },
  );

  test('el código de kupela es único y un trasiego no va a sí misma', () async {
    final kupela = await baseDatos.guardarKupela(
      Kupela(codigo: 'K3', capacidadLitros: 1),
    );
    await expectLater(
      baseDatos.guardarKupela(Kupela(codigo: 'K3', capacidadLitros: 2)),
      throwsA(anything),
    );
    await expectLater(
      baseDatos.guardarTrasiego(
        Trasiego(
          fechaMs: 1,
          kupelaOrigenId: kupela,
          kupelaDestinoId: kupela,
          litros: 10,
        ),
      ),
      throwsA(anything),
    );
    await baseDatos.guardarTrasiego(
      Trasiego(fechaMs: 2, kupelaOrigenId: kupela, litros: 10),
    );
    expect((await baseDatos.listarTrasiegos()).single.esRetirada, isTrue);
  });

  test('listas filtradas por fechas', () async {
    final kupela = await baseDatos.guardarKupela(
      Kupela(codigo: 'K4', capacidadLitros: 1),
    );
    for (final fecha in [5, 15, 25]) {
      await baseDatos.guardarEmbotellado(
        Embotellado(
          fechaMs: fecha,
          kupelaId: kupela,
          codigoLote: 'L$fecha',
          botellas: 6,
        ),
      );
      await baseDatos.guardarMedicion(
        MedicionKupela(kupelaId: kupela, fechaMs: fecha, densidad: 1010),
      );
    }
    expect(
      (await baseDatos.listarEmbotellados(
        desdeMs: 0,
        hastaMs: 20,
      ))
          .map((embotellado) => embotellado.codigoLote),
      ['L15', 'L5'],
    );
    expect(
      await baseDatos.listarMediciones(
        kupelaId: kupela,
        desdeMs: 10,
        hastaMs: 30,
      ),
      hasLength(2),
    );
  });
}
