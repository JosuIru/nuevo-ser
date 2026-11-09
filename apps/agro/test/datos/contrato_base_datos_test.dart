// Contrato de la base de datos de Larrea (agro), la app madre de la suite.
//
// Fija lo que la futura `BaseDatosSolera` de `nuevo_ser_core` tendrá que
// respetar (deuda R5 de docs/auditoria-2026-05-12.md):
//   (a) singleton perezoso;
//   (b) BD nueva → versión actual con todas las tablas y columnas;
//   (c) BD de cada versión antigua → migración aditiva sin perder filas;
//   (d) CRUD de las tablas principales por la API pública de BaseDatosAgro.
//
// Limitaciones (no se toca lib/):
//   * La ruta sale de getApplicationDocumentsDirectory() sin inyección:
//     se simula el canal de path_provider (ver soporte_contrato_base_datos).
//   * El singleton no se puede reiniciar salvo con `cerrar()`, que es lo
//     que se usa entre tests.
//   * `facturas` (v7) no tiene API en BaseDatosAgro: la pantalla de
//     facturas escribe SQL directo. Se prueba con SQL a mano.

import 'dart:io';

import 'package:agro/datos/base_datos.dart';
import 'package:agro/modelos/apunte_gasto.dart';
import 'package:agro/modelos/configuracion_fiscal.dart';
import 'package:agro/modelos/cosecha.dart';
import 'package:agro/modelos/finca.dart';
import 'package:agro/modelos/incidencia.dart';
import 'package:agro/modelos/planta.dart';
import 'package:agro/modelos/tercero.dart';
import 'package:agro/modelos/titular.dart';
import 'package:agro/modelos/track.dart';
import 'package:agro/modelos/tratamiento.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart' show codificarContorno;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'soporte_contrato_base_datos.dart';

/// Esquema v1 literal, deducido de `_crearEsquemaInicial` quitando lo que
/// añaden las migraciones v2-v5 (rutas_fotos_json en plantas, tracks,
/// titulares, SIGPAC en fincas y datos MAPA en tratamientos).
const List<String> sentenciasEsquemaV1Agro = [
  '''
  CREATE TABLE fincas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    latitud_centroide REAL,
    longitud_centroide REAL,
    color_entero INTEGER NOT NULL DEFAULT 6249021,
    notas TEXT NOT NULL DEFAULT '',
    fecha_creacion_ms INTEGER NOT NULL
  )''',
  '''
  CREATE TABLE plantas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    finca_id INTEGER,
    cultivo_id TEXT NOT NULL,
    variedad TEXT NOT NULL DEFAULT '',
    latitud REAL NOT NULL,
    longitud REAL NOT NULL,
    precision_metros REAL,
    fecha_plantacion_ms INTEGER,
    patron TEXT NOT NULL DEFAULT '',
    etiqueta TEXT NOT NULL DEFAULT '',
    notas TEXT NOT NULL DEFAULT '',
    fecha_creacion_ms INTEGER NOT NULL,
    FOREIGN KEY (finca_id) REFERENCES fincas(id) ON DELETE SET NULL
  )''',
  'CREATE INDEX idx_plantas_finca ON plantas (finca_id)',
  'CREATE INDEX idx_plantas_cultivo ON plantas (cultivo_id)',
  'CREATE INDEX idx_plantas_creacion ON plantas (fecha_creacion_ms DESC)',
  '''
  CREATE TABLE cosechas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    planta_id INTEGER NOT NULL,
    fecha_ms INTEGER NOT NULL,
    kilos REAL,
    unidades INTEGER,
    calidad INTEGER,
    rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
    notas TEXT NOT NULL DEFAULT '',
    FOREIGN KEY (planta_id) REFERENCES plantas(id) ON DELETE CASCADE
  )''',
  'CREATE INDEX idx_cosechas_planta_fecha ON cosechas (planta_id, fecha_ms DESC)',
  '''
  CREATE TABLE observaciones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    planta_id INTEGER NOT NULL,
    fecha_ms INTEGER NOT NULL,
    salud INTEGER,
    etiquetas_json TEXT NOT NULL DEFAULT '[]',
    rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
    notas TEXT NOT NULL DEFAULT '',
    FOREIGN KEY (planta_id) REFERENCES plantas(id) ON DELETE CASCADE
  )''',
  'CREATE INDEX idx_observaciones_planta_fecha ON observaciones (planta_id, fecha_ms DESC)',
  '''
  CREATE TABLE incidencias (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    planta_id INTEGER NOT NULL,
    fecha_ms INTEGER NOT NULL,
    tipo TEXT NOT NULL DEFAULT 'otro',
    diagnostico TEXT NOT NULL DEFAULT '',
    severidad INTEGER,
    rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
    notas TEXT NOT NULL DEFAULT '',
    resuelta INTEGER NOT NULL DEFAULT 0,
    fecha_resolucion_ms INTEGER,
    FOREIGN KEY (planta_id) REFERENCES plantas(id) ON DELETE CASCADE
  )''',
  'CREATE INDEX idx_incidencias_planta_fecha ON incidencias (planta_id, fecha_ms DESC)',
  'CREATE INDEX idx_incidencias_abiertas ON incidencias (resuelta, fecha_ms DESC)',
  '''
  CREATE TABLE tratamientos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    planta_id INTEGER NOT NULL,
    fecha_ms INTEGER NOT NULL,
    tipo TEXT NOT NULL DEFAULT 'otro',
    producto TEXT NOT NULL DEFAULT '',
    dosis TEXT NOT NULL DEFAULT '',
    motivo TEXT NOT NULL DEFAULT '',
    plazo_seguridad_dias INTEGER,
    incidencia_id INTEGER,
    notas TEXT NOT NULL DEFAULT '',
    FOREIGN KEY (planta_id) REFERENCES plantas(id) ON DELETE CASCADE,
    FOREIGN KEY (incidencia_id) REFERENCES incidencias(id) ON DELETE SET NULL
  )''',
  'CREATE INDEX idx_tratamientos_planta_fecha ON tratamientos (planta_id, fecha_ms DESC)',
];

/// Historial de `_aplicarMigraciones` (v2…v8).
const Map<int, CambioEsquema> historialMigracionesAgro = {
  2: CambioEsquema(
    columnasNuevas: {
      'plantas': ['rutas_fotos_json'],
    },
  ),
  3: CambioEsquema(
    tablasNuevas: ['tracks', 'track_puntos', 'track_grabacion_buffer'],
  ),
  4: CambioEsquema(
    tablasNuevas: ['titulares'],
    columnasNuevas: {
      'fincas': [
        'sigpac_provincia',
        'sigpac_municipio',
        'sigpac_poligono',
        'sigpac_parcela',
        'sigpac_recinto',
        'superficie_hectareas',
      ],
    },
  ),
  5: CambioEsquema(
    columnasNuevas: {
      'tratamientos': [
        'numero_registro_fitosanitario',
        'nif_aplicador',
        'superficie_tratada_hectareas',
      ],
    },
  ),
  6: CambioEsquema(
    tablasNuevas: [
      'terceros',
      'configuraciones_fiscales',
      'apuntes_ingreso',
      'apuntes_gasto',
    ],
  ),
  7: CambioEsquema(tablasNuevas: ['facturas']),
  8: CambioEsquema(
    columnasNuevas: {
      'fincas': ['contorno'],
    },
  ),
};

/// Esquema esperado en la versión actual (v8).
const Map<String, Set<String>> columnasEsperadasAgro = {
  'fincas': {
    'id', 'nombre', 'latitud_centroide', 'longitud_centroide', //
    'color_entero', 'notas', 'fecha_creacion_ms', 'sigpac_provincia',
    'sigpac_municipio', 'sigpac_poligono', 'sigpac_parcela',
    'sigpac_recinto', 'superficie_hectareas', 'contorno',
  },
  'plantas': {
    'id', 'finca_id', 'cultivo_id', 'variedad', 'latitud', 'longitud', //
    'precision_metros', 'fecha_plantacion_ms', 'patron', 'etiqueta',
    'notas', 'rutas_fotos_json', 'fecha_creacion_ms',
  },
  'cosechas': {
    'id', 'planta_id', 'fecha_ms', 'kilos', 'unidades', 'calidad', //
    'rutas_fotos_json', 'notas',
  },
  'observaciones': {
    'id', 'planta_id', 'fecha_ms', 'salud', 'etiquetas_json', //
    'rutas_fotos_json', 'notas',
  },
  'incidencias': {
    'id', 'planta_id', 'fecha_ms', 'tipo', 'diagnostico', 'severidad', //
    'rutas_fotos_json', 'notas', 'resuelta', 'fecha_resolucion_ms',
  },
  'tratamientos': {
    'id', 'planta_id', 'fecha_ms', 'tipo', 'producto', 'dosis', 'motivo', //
    'plazo_seguridad_dias', 'incidencia_id', 'notas',
    'numero_registro_fitosanitario', 'nif_aplicador',
    'superficie_tratada_hectareas',
  },
  'tracks': {'id', 'fecha_ms', 'nombre', 'duracion_ms', 'distancia_metros'},
  'track_puntos': {
    'id', 'track_id', 'fecha_ms', 'latitud', 'longitud', 'altitud', //
    'precision',
  },
  'track_grabacion_buffer': {
    'id', 'inicio_ms', 'fecha_ms', 'latitud', 'longitud', 'altitud', //
    'precision',
  },
  'titulares': {
    'id', 'nif', 'nombre', 'direccion', 'numero_regepa', 'telefono', //
    'email', 'nombre_asesor', 'nif_asesor', 'numero_registro_asesor',
    'nombre_aplicador', 'nif_aplicador', 'carnet_aplicador',
    'nivel_carnet_aplicador',
  },
  'terceros': {
    'id', 'nif', 'nombre', 'direccion', 'telefono', 'email', 'tipo', //
    'notas',
  },
  'configuraciones_fiscales': {
    'id', 'regimen_irpf', 'regimen_iva', 'ano_fiscal_activo', //
  },
  'apuntes_ingreso': {
    'id', 'fecha_ms', 'concepto', 'tipo_ingreso', //
    'importe_base_centimos', 'iva_repercutido_centimos',
    'compensacion_reagp_centimos', 'cantidad', 'unidad', 'tercero_id',
    'finca_id', 'cultivo_id', 'ruta_foto_factura', 'numero_factura',
    'notas',
  },
  'apuntes_gasto': {
    'id', 'fecha_ms', 'concepto', 'tipo_gasto', 'importe_base_centimos', //
    'iva_soportado_centimos', 'imputacion', 'finca_id', 'cultivo_id',
    'tercero_id', 'ruta_foto_factura', 'numero_factura', 'tratamiento_id',
    'notas',
  },
  'facturas': {
    'id', 'numero_factura', 'fecha_emision_ms', 'fecha_vencimiento_ms', //
    'fecha_pago_ms', 'cliente_nombre', 'cliente_nif', 'cliente_direccion',
    'lineas_json', 'base_imponible', 'iva_porcentaje', 'total', 'estado',
    'notas', 'fecha_creacion_ms',
  },
};

/// Una fila por tabla v1, en orden de dependencias (FK).
const Map<String, Map<String, Object?>> filasV1Agro = {
  'fincas': {
    'id': 1,
    'nombre': 'El Romeral',
    'color_entero': 123,
    'fecha_creacion_ms': 1000,
  },
  'plantas': {
    'id': 1,
    'finca_id': 1,
    'cultivo_id': 'nogal',
    'latitud': 42.1,
    'longitud': -1.6,
    'etiqueta': 'A-17',
    'fecha_creacion_ms': 2000,
  },
  'cosechas': {'id': 1, 'planta_id': 1, 'fecha_ms': 3000, 'kilos': 12.5},
  'observaciones': {'id': 1, 'planta_id': 1, 'fecha_ms': 3100, 'salud': 4},
  'incidencias': {
    'id': 1,
    'planta_id': 1,
    'fecha_ms': 3200,
    'diagnostico': 'pulgón',
  },
  'tratamientos': {
    'id': 1,
    'planta_id': 1,
    'fecha_ms': 3300,
    'producto': 'jabón potásico',
    'incidencia_id': 1,
  },
};

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatosAgro = BaseDatosAgro.instancia;

  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatosAgro.cerrar();
    await entorno.limpiar();
  });

  group('(a) singleton', () {
    test('el constructor factory devuelve siempre la misma instancia', () {
      expect(identical(BaseDatosAgro(), BaseDatosAgro()), isTrue);
      expect(identical(BaseDatosAgro(), BaseDatosAgro.instancia), isTrue);
    });

    test('la Database se abre una vez y se reutiliza', () async {
      final primera = await baseDatosAgro.basedatos;
      final segunda = await baseDatosAgro.basedatos;
      expect(identical(primera, segunda), isTrue);
    });

    test(
      'dos accesos simultáneos en frío comparten la misma Database',
      () async {
        // El getter perezoso no tiene cerrojo; hoy lo salva el
        // `singleInstance` de sqflite (misma ruta → misma Database).
        final accesos = await Future.wait([
          baseDatosAgro.basedatos,
          baseDatosAgro.basedatos,
        ]);
        expect(identical(accesos[0], accesos[1]), isTrue);
      },
    );

    test(
      'cerrar() libera la Database y el siguiente acceso la reabre',
      () async {
        final antes = await baseDatosAgro.basedatos;
        await baseDatosAgro.cerrar();
        expect(antes.isOpen, isFalse);
        final despues = await baseDatosAgro.basedatos;
        expect(despues.isOpen, isTrue);
      },
    );
  });

  group('(b) BD nueva', () {
    test('el fichero se llama agro.db (sin sufijo de versión)', () async {
      await baseDatosAgro.basedatos;
      expect(nombreFicheroBaseDatosAgro, 'agro.db');
      expect(File(entorno.ruta('agro.db')).existsSync(), isTrue);
    });

    test('llega a la versión actual con todas las tablas y columnas', () async {
      final baseDatos = await baseDatosAgro.basedatos;
      expect(await baseDatos.getVersion(), versionEsquemaAgro);
      expect(versionEsquemaAgro, 8);
      expect(await leerColumnasPorTabla(baseDatos), columnasEsperadasAgro);
    });

    test('el historial declarado reproduce el esquema actual', () async {
      final columnasV1 = await columnasDeEsquemaV1(sentenciasEsquemaV1Agro);
      expect(
        columnasDeclaradasEnVersion(
          columnasV1: columnasV1,
          historial: historialMigracionesAgro,
          columnasActuales: columnasEsperadasAgro,
          version: versionEsquemaAgro,
        ),
        columnasEsperadasAgro,
      );
    });

    test('las claves foráneas están activas (onConfigure)', () async {
      final baseDatos = await baseDatosAgro.basedatos;
      final filas = await baseDatos.rawQuery('PRAGMA foreign_keys');
      expect(filas.single.values.single, 1);
    });
  });

  group('(c) migraciones desde versiones antiguas', () {
    for (
      var versionAntigua = 1;
      versionAntigua < versionEsquemaAgro;
      versionAntigua++
    ) {
      test(
        'v$versionAntigua → v$versionEsquemaAgro sin perder filas',
        () async {
          await crearBaseDatosHistorica(
            ruta: entorno.ruta(nombreFicheroBaseDatosAgro),
            version: versionAntigua,
            sentenciasEsquemaV1: sentenciasEsquemaV1Agro,
            historial: historialMigracionesAgro,
            columnasActuales: columnasEsperadasAgro,
            filasPorTabla: filasV1Agro,
          );

          final baseDatos = await baseDatosAgro.basedatos;
          expect(await baseDatos.getVersion(), versionEsquemaAgro);
          expect(await leerColumnasPorTabla(baseDatos), columnasEsperadasAgro);
          await comprobarFilasConservadas(baseDatos, filasV1Agro);

          // Las columnas nuevas llegan con su valor por defecto.
          final planta = await baseDatosAgro.obtenerPlanta(1);
          expect(planta!.etiqueta, 'A-17');
          if (versionAntigua < 2) expect(planta.rutasFotosJson, '[]');
          if (versionAntigua < 4) {
            final finca = await baseDatosAgro.obtenerFinca(1);
            expect(finca!.sigpacProvincia, '');
            expect(finca.superficieHectareas, isNull);
          }
          if (versionAntigua < 8) {
            final finca = await baseDatosAgro.obtenerFinca(1);
            expect(finca!.contorno, '[]');
            expect(finca.vertices, isEmpty);
          }
        },
      );
    }

    test(
      'desde v1, el esquema migrado es idéntico al de una BD nueva',
      () async {
        final baseDatosNueva = await baseDatosAgro.basedatos;
        final detalleNueva = await leerDetalleColumnasPorTabla(baseDatosNueva);
        final indicesNueva = await leerNombresIndices(baseDatosNueva);
        await baseDatosAgro.cerrar();
        await File(entorno.ruta(nombreFicheroBaseDatosAgro)).delete();

        await crearBaseDatosHistorica(
          ruta: entorno.ruta(nombreFicheroBaseDatosAgro),
          version: 1,
          sentenciasEsquemaV1: sentenciasEsquemaV1Agro,
          historial: historialMigracionesAgro,
          columnasActuales: columnasEsperadasAgro,
          filasPorTabla: filasV1Agro,
        );
        final baseDatosMigrada = await baseDatosAgro.basedatos;
        expect(
          await leerDetalleColumnasPorTabla(baseDatosMigrada),
          detalleNueva,
        );
        expect(await leerNombresIndices(baseDatosMigrada), indicesNueva);
      },
    );

    test('abrir dos veces una BD ya actual no cambia nada', () async {
      final baseDatos = await baseDatosAgro.basedatos;
      await baseDatosAgro.guardarFinca(
        Finca(nombre: 'Prueba', colorEntero: 1, fechaCreacionMs: 1),
      );
      await baseDatosAgro.cerrar();
      final reabierta = await baseDatosAgro.basedatos;
      expect(identical(baseDatos, reabierta), isFalse);
      expect(await reabierta.getVersion(), versionEsquemaAgro);
      expect((await baseDatosAgro.listarFincas()).single.nombre, 'Prueba');
    });
  });

  group('(d) CRUD por la API pública', () {
    test(
      'fincas: alta, lectura, cambio y baja que desasocia plantas',
      () async {
        final idFinca = await baseDatosAgro.guardarFinca(
          Finca(
            nombre: 'La Vega',
            colorEntero: 42,
            fechaCreacionMs: 10,
            sigpacProvincia: '31',
          ),
        );
        expect(
          (await baseDatosAgro.obtenerFinca(idFinca))!.sigpacProvincia,
          '31',
        );

        await baseDatosAgro.actualizarFinca(idFinca, {
          'nombre': 'La Vega Alta',
        });
        expect(
          (await baseDatosAgro.listarFincas()).single.nombre,
          'La Vega Alta',
        );

        final idPlanta = await baseDatosAgro.guardarPlanta(
          Planta(
            fincaId: idFinca,
            cultivoId: 'olivo',
            latitud: 1,
            longitud: 2,
            fechaCreacionMs: 20,
          ),
        );
        await baseDatosAgro.borrarFinca(idFinca);
        expect(await baseDatosAgro.obtenerFinca(idFinca), isNull);
        // La planta sobrevive como punto suelto.
        expect((await baseDatosAgro.obtenerPlanta(idPlanta))!.fincaId, isNull);
        expect((await baseDatosAgro.listarPuntosSueltos()).single.id, idPlanta);
      },
    );

    test('fincas: el área marcada en el mapa se guarda y se lee', () async {
      const area = [
        LatLng(42.0, -1.0),
        LatLng(42.0, -0.999),
        LatLng(42.001, -0.999),
      ];
      final idFinca = await baseDatosAgro.guardarFinca(
        Finca(
          nombre: 'El Soto',
          colorEntero: 1,
          fechaCreacionMs: 1,
          contorno: codificarContorno(area),
        ),
      );
      expect((await baseDatosAgro.obtenerFinca(idFinca))!.vertices, area);

      // La ficha la cambia con actualizarFinca, como el resto de campos.
      await baseDatosAgro.actualizarFinca(idFinca, {
        'contorno': codificarContorno(area.take(2).toList()),
      });
      expect(
        (await baseDatosAgro.obtenerFinca(idFinca))!.vertices,
        hasLength(2),
      );
    });

    test(
      'plantas y eventos: borrar la planta arrastra sus eventos (CASCADE)',
      () async {
        final idPlanta = await baseDatosAgro.guardarPlanta(
          Planta(
            cultivoId: 'cerezo',
            latitud: 1,
            longitud: 2,
            fechaCreacionMs: 20,
          ),
        );
        await baseDatosAgro.actualizarPlanta(idPlanta, {'variedad': 'Picota'});
        expect(
          (await baseDatosAgro.obtenerPlanta(idPlanta))!.variedad,
          'Picota',
        );
        expect(await baseDatosAgro.contarPlantasPorCultivo(), {'cerezo': 1});

        final idCosecha = await baseDatosAgro.guardarCosecha(
          Cosecha(plantaId: idPlanta, fechaMs: 30, kilos: 4),
        );
        await baseDatosAgro.actualizarCosecha(idCosecha, {'kilos': 5.5});
        expect((await baseDatosAgro.obtenerCosecha(idCosecha))!.kilos, 5.5);

        final idIncidencia = await baseDatosAgro.guardarIncidencia(
          Incidencia(plantaId: idPlanta, fechaMs: 31),
        );
        expect(
          (await baseDatosAgro.listarIncidenciasAbiertas()).single.id,
          idIncidencia,
        );
        final idTratamiento = await baseDatosAgro.guardarTratamiento(
          Tratamiento(
            plantaId: idPlanta,
            fechaMs: 32,
            incidenciaId: idIncidencia,
            numeroRegistroFitosanitario: 'ES-123',
          ),
        );
        expect(
          (await baseDatosAgro.obtenerTratamiento(
            idTratamiento,
          ))!.numeroRegistroFitosanitario,
          'ES-123',
        );

        await baseDatosAgro.borrarCosecha(idCosecha);
        expect(await baseDatosAgro.listarCosechasDePlanta(idPlanta), isEmpty);

        await baseDatosAgro.borrarPlanta(idPlanta);
        expect(await baseDatosAgro.obtenerPlanta(idPlanta), isNull);
        expect(
          await baseDatosAgro.listarIncidenciasDePlanta(idPlanta),
          isEmpty,
        );
        expect(
          await baseDatosAgro.listarTratamientosDePlanta(idPlanta),
          isEmpty,
        );
      },
    );

    test(
      'titular y configuración fiscal son de una sola fila (upsert)',
      () async {
        expect((await baseDatosAgro.obtenerTitular()).id, isNull);
        await baseDatosAgro.guardarTitular(Titular(nif: '1A', nombre: 'Ana'));
        await baseDatosAgro.guardarTitular(Titular(nif: '2B', nombre: 'Ana'));
        final baseDatos = await baseDatosAgro.basedatos;
        expect(await baseDatos.query('titulares'), hasLength(1));
        expect((await baseDatosAgro.obtenerTitular()).nif, '2B');

        await baseDatosAgro.guardarConfiguracionFiscal(
          ConfiguracionFiscal(anoFiscalActivo: 2025),
        );
        await baseDatosAgro.guardarConfiguracionFiscal(
          ConfiguracionFiscal(anoFiscalActivo: 2026),
        );
        expect(await baseDatos.query('configuraciones_fiscales'), hasLength(1));
        expect(
          (await baseDatosAgro.obtenerConfiguracionFiscal()).anoFiscalActivo,
          2026,
        );
      },
    );

    test('terceros y apuntes de gasto', () async {
      final idTercero = await baseDatosAgro.guardarTercero(
        Tercero(nif: 'B123', nombre: 'Cooperativa'),
      );
      expect((await baseDatosAgro.obtenerTerceroPorNif('B123'))!.id, idTercero);
      await baseDatosAgro.actualizarTercero(idTercero, {'tipo': 'proveedor'});
      expect((await baseDatosAgro.listarTerceros(tipo: 'proveedor')).length, 1);

      final fecha = DateTime(2026, 3, 1).millisecondsSinceEpoch;
      final idGasto = await baseDatosAgro.guardarApunteGasto(
        ApunteGasto(
          fechaMs: fecha,
          importeBaseCentimos: 1000,
          terceroId: idTercero,
        ),
      );
      await baseDatosAgro.actualizarApunteGasto(idGasto, {
        'importe_base_centimos': 1500,
      });
      expect(
        (await baseDatosAgro.obtenerApunteGasto(idGasto))!.importeBaseCentimos,
        1500,
      );
      expect((await baseDatosAgro.listarApuntesGastoPorAno(2026)).length, 1);

      // Borrar el tercero deja el apunte sin tercero (ON DELETE SET NULL).
      await baseDatosAgro.borrarTercero(idTercero);
      expect(
        (await baseDatosAgro.obtenerApunteGasto(idGasto))!.terceroId,
        isNull,
      );
      await baseDatosAgro.borrarApunteGasto(idGasto);
      expect(await baseDatosAgro.obtenerApunteGasto(idGasto), isNull);
    });

    test('tracks: alta con puntos, lectura y baja', () async {
      final idTrack = await baseDatosAgro
          .guardarTrack(Track(fechaMs: 1, nombre: 'Ronda'), [
            TrackPunto(fechaMs: 1, latitud: 1, longitud: 1),
            TrackPunto(fechaMs: 2, latitud: 1.1, longitud: 1.1),
          ]);
      expect((await baseDatosAgro.listarTracks()).single.nombre, 'Ronda');
      expect(await baseDatosAgro.obtenerPuntosTrack(idTrack), hasLength(2));
      await baseDatosAgro.borrarTrack(idTrack);
      expect(await baseDatosAgro.listarTracks(), isEmpty);
      expect(await baseDatosAgro.obtenerPuntosTrack(idTrack), isEmpty);
    });

    test('facturas (sin API: SQL directo como pantalla_facturas)', () async {
      final baseDatos = await baseDatosAgro.basedatos;
      final idFactura = await baseDatos.insert('facturas', {
        'numero_factura': '2026-001',
        'fecha_emision_ms': 1,
        'fecha_creacion_ms': 1,
      });
      await baseDatos.update(
        'facturas',
        {'estado': 'anulada'},
        where: 'id = ?',
        whereArgs: [idFactura],
      );
      final filas = await baseDatos.query('facturas');
      expect(filas.single['estado'], 'anulada');
      expect(filas.single['iva_porcentaje'], 10);
      await baseDatos.delete(
        'facturas',
        where: 'id = ?',
        whereArgs: [idFactura],
      );
      expect(await baseDatos.query('facturas'), isEmpty);
    });
  });
}
