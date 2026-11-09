// Contrato de la base de datos de Larrea Apícola.
//
// Fija lo que la futura `BaseDatosSolera` de `nuevo_ser_core` tendrá que
// respetar (deuda R5 de docs/auditoria-2026-05-12.md):
//   (a) singleton perezoso;
//   (b) BD nueva → versión actual con todas las tablas y columnas;
//   (c) BD de cada versión antigua → migración aditiva sin perder filas;
//   (d) CRUD de las tablas principales por la API pública.
//
// Complementa a base_datos_vacia_test.dart (esquema en memoria) pasando por
// el singleton real y su `openDatabase`.
//
// Limitaciones (no se toca lib/):
//   * La ruta sale de getApplicationDocumentsDirectory() sin inyección:
//     se simula el canal de path_provider (ver soporte_contrato_base_datos).
//   * Las migraciones viven en el `onUpgrade` (no hay `_aplicarMigraciones`)
//     y v2 usa CREATE TABLE sin IF NOT EXISTS: no son idempotentes.
//   * `facturas` no tiene API en la clase: se prueba con SQL directo.
//
// **Desajuste corregido el 2026-11-07** (mismo fallo que agro corrigió al
// subir a v7): la versión valía 2 pero `facturas` se creaba en el paso
// `if (viejaVersion < 3)`, así que una BD que ya estuviera en v2 sin esa
// tabla no la recibía nunca. Ahora la versión es 3; lo fija el test
// «v2 sin facturas → recibe la tabla al abrir».

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart' show codificarContorno;
import 'package:solera_apicola/datos/base_datos.dart';
import 'package:solera_apicola/modelos/apiario.dart';
import 'package:solera_apicola/modelos/apicultor.dart';
import 'package:solera_apicola/modelos/apunte_gasto.dart';
import 'package:solera_apicola/modelos/colmena.dart';
import 'package:solera_apicola/modelos/configuracion_fiscal.dart';
import 'package:solera_apicola/modelos/cosecha_miel.dart';
import 'package:solera_apicola/modelos/incidencia_apicola.dart';
import 'package:solera_apicola/modelos/movimiento.dart';
import 'package:solera_apicola/modelos/revision.dart';
import 'package:solera_apicola/modelos/tercero.dart';
import 'package:solera_apicola/modelos/tratamiento_varroa.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'soporte_contrato_base_datos.dart';

/// Esquema v1 literal: copia de `_crearEsquemaInicial`.
const List<String> sentenciasEsquemaV1Apicola = [
  '''
    CREATE TABLE apiarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      latitud_centroide REAL,
      longitud_centroide REAL,
      color_entero INTEGER NOT NULL DEFAULT 12092683,
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL,
      codigo_sitran TEXT NOT NULL DEFAULT '',
      superficie_hectareas REAL
    )''',
  '''
    CREATE TABLE colmenas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      apiario_id INTEGER,
      matricula TEXT NOT NULL UNIQUE,
      tipo_colmena_id TEXT NOT NULL DEFAULT '',
      raza_id TEXT NOT NULL DEFAULT '',
      ano_reina INTEGER,
      estado TEXT NOT NULL DEFAULT 'viva',
      ultima_latitud REAL,
      ultima_longitud REAL,
      fecha_alta_ms INTEGER,
      notas TEXT NOT NULL DEFAULT '',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      fecha_creacion_ms INTEGER NOT NULL,
      FOREIGN KEY (apiario_id) REFERENCES apiarios(id) ON DELETE SET NULL
    )''',
  'CREATE INDEX idx_colmenas_apiario ON colmenas (apiario_id)',
  'CREATE INDEX idx_colmenas_estado ON colmenas (estado)',
  'CREATE INDEX idx_colmenas_matricula ON colmenas (matricula)',
  '''
    CREATE TABLE revisiones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      colmena_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      presencia_reina TEXT NOT NULL DEFAULT 'no_observada',
      nivel_postura INTEGER,
      nivel_cria_operculada INTEGER,
      nivel_miel INTEGER,
      nivel_polen INTEGER,
      varroa_caida_diaria INTEGER,
      etiquetas_json TEXT NOT NULL DEFAULT '[]',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (colmena_id) REFERENCES colmenas(id) ON DELETE CASCADE
    )''',
  'CREATE INDEX idx_revisiones_colmena_fecha ON revisiones (colmena_id, fecha_ms DESC)',
  '''
    CREATE TABLE cosechas_miel (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      colmena_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      kilos_miel REAL,
      kilos_cera REAL,
      kilos_polen REAL,
      kilos_propoleo REAL,
      kilos_jalea_real REAL,
      numero_alza INTEGER,
      calidad INTEGER,
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (colmena_id) REFERENCES colmenas(id) ON DELETE CASCADE
    )''',
  'CREATE INDEX idx_cosechas_colmena_fecha ON cosechas_miel (colmena_id, fecha_ms DESC)',
  '''
    CREATE TABLE tratamientos_varroa (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      colmena_id INTEGER NOT NULL,
      fecha_aplicacion_ms INTEGER NOT NULL,
      fecha_retirada_ms INTEGER,
      tipo TEXT NOT NULL DEFAULT 'varroa',
      sustancia_activa_id TEXT NOT NULL DEFAULT '',
      dosis TEXT NOT NULL DEFAULT '',
      vehiculo TEXT NOT NULL DEFAULT '',
      plazo_seguridad_dias INTEGER,
      lote_producto TEXT NOT NULL DEFAULT '',
      numero_factura TEXT NOT NULL DEFAULT '',
      motivo TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (colmena_id) REFERENCES colmenas(id) ON DELETE CASCADE
    )''',
  'CREATE INDEX idx_tratamientos_colmena_fecha ON tratamientos_varroa (colmena_id, fecha_aplicacion_ms DESC)',
  '''
    CREATE TABLE incidencias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      colmena_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT 'otro',
      diagnostico TEXT NOT NULL DEFAULT '',
      severidad INTEGER,
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      resuelta INTEGER NOT NULL DEFAULT 0,
      fecha_resolucion_ms INTEGER,
      FOREIGN KEY (colmena_id) REFERENCES colmenas(id) ON DELETE CASCADE
    )''',
  'CREATE INDEX idx_incidencias_colmena_fecha ON incidencias (colmena_id, fecha_ms DESC)',
  'CREATE INDEX idx_incidencias_abiertas ON incidencias (resuelta, fecha_ms DESC)',
  '''
    CREATE TABLE movimientos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      colmena_id INTEGER,
      apiario_origen_id INTEGER,
      apiario_destino_id INTEGER,
      fecha_movimiento_ms INTEGER NOT NULL,
      motivo TEXT NOT NULL DEFAULT 'otro',
      numero_colmenas INTEGER NOT NULL DEFAULT 1,
      latitud_origen REAL,
      longitud_origen REAL,
      latitud_destino REAL,
      longitud_destino REAL,
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (colmena_id) REFERENCES colmenas(id) ON DELETE SET NULL,
      FOREIGN KEY (apiario_origen_id) REFERENCES apiarios(id) ON DELETE SET NULL,
      FOREIGN KEY (apiario_destino_id) REFERENCES apiarios(id) ON DELETE SET NULL
    )''',
  'CREATE INDEX idx_movimientos_fecha ON movimientos (fecha_movimiento_ms DESC)',
  'CREATE INDEX idx_movimientos_colmena ON movimientos (colmena_id)',
  '''
    CREATE TABLE apicultores (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nif TEXT NOT NULL DEFAULT '',
      nombre TEXT NOT NULL DEFAULT '',
      direccion TEXT NOT NULL DEFAULT '',
      numero_rega TEXT NOT NULL DEFAULT '',
      numero_explotacion_apicola TEXT NOT NULL DEFAULT '',
      telefono TEXT NOT NULL DEFAULT '',
      email TEXT NOT NULL DEFAULT '',
      nombre_veterinario TEXT NOT NULL DEFAULT '',
      nif_veterinario TEXT NOT NULL DEFAULT '',
      numero_colegiado_veterinario TEXT NOT NULL DEFAULT '',
      telefono_veterinario TEXT NOT NULL DEFAULT ''
    )''',
];

/// Historial de migraciones: contabilidad en v2, facturas en v3 y el área
/// del colmenar en v4.
const Map<int, CambioEsquema> historialMigracionesApicola = {
  2: CambioEsquema(
    tablasNuevas: [
      'terceros',
      'configuraciones_fiscales',
      'apuntes_ingreso',
      'apuntes_gasto',
    ],
  ),
  3: CambioEsquema(tablasNuevas: ['facturas']),
  4: CambioEsquema(columnasNuevas: {
    'apiarios': ['contorno'],
  }),
};

/// Último paso escrito en el `onUpgrade` (= versión declarada).
const int ultimoPasoMigracionApicola = 4;

/// Esquema esperado en una BD nueva.
const Map<String, Set<String>> columnasEsperadasApicola = {
  'apiarios': {
    'id',
    'nombre',
    'latitud_centroide',
    'longitud_centroide',
    'color_entero',
    'notas',
    'fecha_creacion_ms',
    'codigo_sitran',
    'superficie_hectareas',
    'contorno',
  },
  'colmenas': {
    'id',
    'apiario_id',
    'matricula',
    'tipo_colmena_id',
    'raza_id',
    'ano_reina',
    'estado',
    'ultima_latitud',
    'ultima_longitud',
    'fecha_alta_ms',
    'notas',
    'rutas_fotos_json',
    'fecha_creacion_ms',
  },
  'revisiones': {
    'id',
    'colmena_id',
    'fecha_ms',
    'presencia_reina',
    'nivel_postura',
    'nivel_cria_operculada',
    'nivel_miel',
    'nivel_polen',
    'varroa_caida_diaria',
    'etiquetas_json',
    'rutas_fotos_json',
    'notas',
  },
  'cosechas_miel': {
    'id',
    'colmena_id',
    'fecha_ms',
    'kilos_miel',
    'kilos_cera',
    'kilos_polen',
    'kilos_propoleo',
    'kilos_jalea_real',
    'numero_alza',
    'calidad',
    'rutas_fotos_json',
    'notas',
  },
  'tratamientos_varroa': {
    'id',
    'colmena_id',
    'fecha_aplicacion_ms',
    'fecha_retirada_ms',
    'tipo',
    'sustancia_activa_id',
    'dosis',
    'vehiculo',
    'plazo_seguridad_dias',
    'lote_producto',
    'numero_factura',
    'motivo',
    'notas',
  },
  'incidencias': {
    'id',
    'colmena_id',
    'fecha_ms',
    'tipo',
    'diagnostico',
    'severidad',
    'rutas_fotos_json',
    'notas',
    'resuelta',
    'fecha_resolucion_ms',
  },
  'movimientos': {
    'id',
    'colmena_id',
    'apiario_origen_id',
    'apiario_destino_id',
    'fecha_movimiento_ms',
    'motivo',
    'numero_colmenas',
    'latitud_origen',
    'longitud_origen',
    'latitud_destino',
    'longitud_destino',
    'notas',
  },
  'apicultores': {
    'id',
    'nif',
    'nombre',
    'direccion',
    'numero_rega',
    'numero_explotacion_apicola',
    'telefono',
    'email',
    'nombre_veterinario',
    'nif_veterinario',
    'numero_colegiado_veterinario',
    'telefono_veterinario',
  },
  'terceros': {
    'id',
    'nif',
    'nombre',
    'direccion',
    'telefono',
    'email',
    'tipo',
    'notas',
  },
  'configuraciones_fiscales': {
    'id',
    'regimen_irpf',
    'regimen_iva',
    'ano_fiscal_activo',
  },
  'apuntes_ingreso': {
    'id',
    'fecha_ms',
    'concepto',
    'tipo_ingreso',
    'importe_base_centimos',
    'iva_repercutido_centimos',
    'compensacion_reagp_centimos',
    'cantidad',
    'unidad',
    'tercero_id',
    'apiario_id',
    'ruta_foto_factura',
    'numero_factura',
    'notas',
  },
  'apuntes_gasto': {
    'id',
    'fecha_ms',
    'concepto',
    'tipo_gasto',
    'importe_base_centimos',
    'iva_soportado_centimos',
    'imputacion',
    'apiario_id',
    'tercero_id',
    'ruta_foto_factura',
    'numero_factura',
    'tratamiento_varroa_id',
    'notas',
  },
  'facturas': {
    'id',
    'numero_factura',
    'fecha_emision_ms',
    'fecha_vencimiento_ms',
    'fecha_pago_ms',
    'cliente_nombre',
    'cliente_nif',
    'cliente_direccion',
    'lineas_json',
    'base_imponible',
    'iva_porcentaje',
    'total',
    'estado',
    'notas',
    'fecha_creacion_ms',
  },
};

/// Una fila por tabla v1 (en orden de dependencias FK).
const Map<String, Map<String, Object?>> filasV1Apicola = {
  'apiarios': {
    'id': 1,
    'nombre': 'El Encinar',
    'fecha_creacion_ms': 1000,
    'codigo_sitran': 'ES-1',
  },
  'colmenas': {
    'id': 1,
    'apiario_id': 1,
    'matricula': 'C-001',
    'fecha_creacion_ms': 1100,
  },
  'revisiones': {'id': 1, 'colmena_id': 1, 'fecha_ms': 2000},
  'cosechas_miel': {'id': 1, 'colmena_id': 1, 'fecha_ms': 2100},
  'tratamientos_varroa': {
    'id': 1,
    'colmena_id': 1,
    'fecha_aplicacion_ms': 2200,
  },
  'incidencias': {'id': 1, 'colmena_id': 1, 'fecha_ms': 2300},
  'movimientos': {
    'id': 1,
    'colmena_id': 1,
    'apiario_origen_id': 1,
    'fecha_movimiento_ms': 2400,
  },
  'apicultores': {'id': 1, 'nif': '1A', 'numero_rega': 'REGA-9'},
};

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatosApicola = BaseDatosSoleraApicola.instancia;

  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatosApicola.cerrar();
    await entorno.limpiar();
  });

  group('(a) singleton', () {
    test('el constructor factory devuelve siempre la misma instancia', () {
      expect(
        identical(BaseDatosSoleraApicola(), BaseDatosSoleraApicola()),
        isTrue,
      );
      expect(
        identical(BaseDatosSoleraApicola(), BaseDatosSoleraApicola.instancia),
        isTrue,
      );
    });

    test('la Database se abre una vez y se reutiliza', () async {
      final primera = await baseDatosApicola.basedatos;
      expect(identical(primera, await baseDatosApicola.basedatos), isTrue);
    });

    test(
      'dos accesos simultáneos en frío comparten la misma Database',
      () async {
        final accesos = await Future.wait([
          baseDatosApicola.basedatos,
          baseDatosApicola.basedatos,
        ]);
        expect(identical(accesos[0], accesos[1]), isTrue);
      },
    );

    test(
      'cerrar() y reiniciar() liberan la Database; luego se reabre',
      () async {
        final primera = await baseDatosApicola.basedatos;
        await baseDatosApicola.cerrar();
        expect(primera.isOpen, isFalse);
        final segunda = await baseDatosApicola.basedatos;
        await baseDatosApicola.reiniciar();
        expect(segunda.isOpen, isFalse);
        expect((await baseDatosApicola.basedatos).isOpen, isTrue);
      },
    );
  });

  group('(b) BD nueva', () {
    test(
      'el fichero se llama solera_apicola.db (sin sufijo de versión)',
      () async {
        expect(nombreFicheroBaseDatosApicola, 'solera_apicola.db');
        expect(
          await baseDatosApicola.rutaBaseDatos(),
          entorno.ruta('solera_apicola.db'),
        );
        expect(File(entorno.ruta('solera_apicola.db')).existsSync(), isTrue);
      },
    );

    test('llega a la versión actual con todas las tablas y columnas', () async {
      final baseDatos = await baseDatosApicola.basedatos;
      expect(await baseDatos.getVersion(), versionEsquemaBaseDatosApicola);
      expect(versionEsquemaBaseDatosApicola, 4);
      expect(await leerColumnasPorTabla(baseDatos), columnasEsperadasApicola);
    });

    test(
      'el historial declarado reproduce el esquema de una BD nueva',
      () async {
        final columnasV1 = await columnasDeEsquemaV1(
          sentenciasEsquemaV1Apicola,
        );
        expect(
          columnasDeclaradasEnVersion(
            columnasV1: columnasV1,
            historial: historialMigracionesApicola,
            columnasActuales: columnasEsperadasApicola,
            version: ultimoPasoMigracionApicola,
          ),
          columnasEsperadasApicola,
        );
      },
    );

    test('las claves foráneas están activas (onConfigure)', () async {
      final baseDatos = await baseDatosApicola.basedatos;
      final filas = await baseDatos.rawQuery('PRAGMA foreign_keys');
      expect(filas.single.values.single, 1);
    });

    test('recién creada está vacía (estaVacia)', () async {
      expect(await baseDatosApicola.estaVacia(), isTrue);
    });
  });

  group('(c) migraciones desde versiones antiguas', () {
    test('v1 → v$versionEsquemaBaseDatosApicola sin perder filas', () async {
      await crearBaseDatosHistorica(
        ruta: entorno.ruta(nombreFicheroBaseDatosApicola),
        version: 1,
        sentenciasEsquemaV1: sentenciasEsquemaV1Apicola,
        historial: historialMigracionesApicola,
        columnasActuales: columnasEsperadasApicola,
        filasPorTabla: filasV1Apicola,
      );

      final baseDatos = await baseDatosApicola.basedatos;
      expect(await baseDatos.getVersion(), versionEsquemaBaseDatosApicola);
      expect(await leerColumnasPorTabla(baseDatos), columnasEsperadasApicola);
      await comprobarFilasConservadas(baseDatos, filasV1Apicola);
      expect(
        (await baseDatosApicola.obtenerColmenaPorMatricula('C-001'))!.id,
        1,
      );
      expect(await baseDatosApicola.estaVacia(), isFalse);
    });

    test(
      'v2 sin facturas → recibe la tabla al abrir',
      () async {
        await crearBaseDatosHistorica(
          ruta: entorno.ruta(nombreFicheroBaseDatosApicola),
          version: 2,
          sentenciasEsquemaV1: sentenciasEsquemaV1Apicola,
          historial: historialMigracionesApicola,
          columnasActuales: columnasEsperadasApicola,
          filasPorTabla: filasV1Apicola,
        );
        final baseDatos = await baseDatosApicola.basedatos;
        expect(await leerColumnasPorTabla(baseDatos), columnasEsperadasApicola);
        expect(await baseDatosApicola.estaVacia(), isFalse);
      },
    );

    test('v3 → v4: los apiarios conservan sus filas con el área vacía',
        () async {
      await crearBaseDatosHistorica(
        ruta: entorno.ruta(nombreFicheroBaseDatosApicola),
        version: 3,
        sentenciasEsquemaV1: sentenciasEsquemaV1Apicola,
        historial: historialMigracionesApicola,
        columnasActuales: columnasEsperadasApicola,
        filasPorTabla: filasV1Apicola,
      );
      final baseDatos = await baseDatosApicola.basedatos;
      expect(await baseDatos.getVersion(), versionEsquemaBaseDatosApicola);
      await comprobarFilasConservadas(baseDatos, filasV1Apicola);
      final apiario = (await baseDatosApicola.listarApiarios()).single;
      expect(apiario.contorno, '[]');
      expect(apiario.vertices, isEmpty);
    });

    test(
      'desde v1, el esquema migrado es idéntico al de una BD nueva',
      () async {
        final baseDatosNueva = await baseDatosApicola.basedatos;
        final detalleNueva = await leerDetalleColumnasPorTabla(baseDatosNueva);
        final indicesNueva = await leerNombresIndices(baseDatosNueva);
        await baseDatosApicola.cerrar();
        await File(entorno.ruta(nombreFicheroBaseDatosApicola)).delete();

        await crearBaseDatosHistorica(
          ruta: entorno.ruta(nombreFicheroBaseDatosApicola),
          version: 1,
          sentenciasEsquemaV1: sentenciasEsquemaV1Apicola,
          historial: historialMigracionesApicola,
          columnasActuales: columnasEsperadasApicola,
          filasPorTabla: filasV1Apicola,
        );
        final baseDatosMigrada = await baseDatosApicola.basedatos;
        expect(
          await leerDetalleColumnasPorTabla(baseDatosMigrada),
          detalleNueva,
        );
        expect(await leerNombresIndices(baseDatosMigrada), indicesNueva);
      },
    );

    test('reabrir una BD ya actual conserva los datos', () async {
      await baseDatosApicola.guardarApiario(
        Apiario(nombre: 'Prueba', colorEntero: 1, fechaCreacionMs: 1),
      );
      await baseDatosApicola.cerrar();
      final reabierta = await baseDatosApicola.basedatos;
      expect(await reabierta.getVersion(), versionEsquemaBaseDatosApicola);
      expect((await baseDatosApicola.listarApiarios()).single.nombre, 'Prueba');
    });
  });

  group('(d) CRUD por la API pública', () {
    test(
      'apiarios: alta, lectura, cambio y baja que desasocia colmenas',
      () async {
        final idApiario = await baseDatosApicola.guardarApiario(
          Apiario(nombre: 'La Umbría', colorEntero: 3, fechaCreacionMs: 10),
        );
        await baseDatosApicola.actualizarApiario(idApiario, {
          'codigo_sitran': 'ES-22',
        });
        expect(
          (await baseDatosApicola.obtenerApiario(idApiario))!.codigoSitran,
          'ES-22',
        );

        final idColmena = await baseDatosApicola.guardarColmena(
          Colmena(apiarioId: idApiario, matricula: 'M-1', fechaCreacionMs: 11),
        );
        expect(
          await baseDatosApicola.listarColmenas(apiarioId: idApiario),
          hasLength(1),
        );
        await baseDatosApicola.borrarApiario(idApiario);
        expect(await baseDatosApicola.obtenerApiario(idApiario), isNull);
        expect(
          (await baseDatosApicola.obtenerColmena(idColmena))!.apiarioId,
          isNull,
        );
        expect(
          (await baseDatosApicola.listarColmenasPuntoSuelto()).single.id,
          idColmena,
        );
      },
    );

    test('el área del colmenar se guarda, se cambia y se lee', () async {
      const area = [
        LatLng(42.0, -1.0),
        LatLng(42.0, -0.999),
        LatLng(42.001, -0.999),
      ];
      final idApiario = await baseDatosApicola.guardarApiario(Apiario(
        nombre: 'La Solana',
        colorEntero: 1,
        fechaCreacionMs: 1,
        contorno: codificarContorno(area),
      ));
      expect(
          (await baseDatosApicola.obtenerApiario(idApiario))!.vertices, area);
      await baseDatosApicola.actualizarApiario(
          idApiario, {'contorno': codificarContorno(area.take(2).toList())});
      expect(
          (await baseDatosApicola.obtenerApiario(idApiario))!.vertices.length,
          2);
    });

    test('la matrícula de colmena es única', () async {
      await baseDatosApicola.guardarColmena(
        Colmena(matricula: 'M-1', fechaCreacionMs: 1),
      );
      expect(
        () => baseDatosApicola.guardarColmena(
          Colmena(matricula: 'M-1', fechaCreacionMs: 2),
        ),
        throwsA(isA<DatabaseException>()),
      );
    });

    test(
      'colmena y eventos: borrarla arrastra eventos y suelta movimientos',
      () async {
        final idColmena = await baseDatosApicola.guardarColmena(
          Colmena(matricula: 'M-7', fechaCreacionMs: 1),
        );
        await baseDatosApicola.actualizarColmena(idColmena, {
          'estado': 'vacia',
        });
        expect(await baseDatosApicola.contarColmenasPorEstado(), {'vacia': 1});

        final idRevision = await baseDatosApicola.guardarRevision(
          Revision(colmenaId: idColmena, fechaMs: 2),
        );
        await baseDatosApicola.actualizarRevision(idRevision, {'notas': 'ok'});
        expect(
          (await baseDatosApicola.obtenerRevision(idRevision))!.notas,
          'ok',
        );
        await baseDatosApicola.guardarCosechaMiel(
          CosechaMiel(colmenaId: idColmena, fechaMs: 3),
        );
        await baseDatosApicola.guardarTratamientoVarroa(
          TratamientoVarroa(colmenaId: idColmena, fechaAplicacionMs: 4),
        );
        final idIncidencia = await baseDatosApicola.guardarIncidencia(
          IncidenciaApicola(colmenaId: idColmena, fechaMs: 5),
        );
        expect(
          (await baseDatosApicola.listarIncidenciasAbiertas()).single.id,
          idIncidencia,
        );
        final idMovimiento = await baseDatosApicola.guardarMovimiento(
          Movimiento(colmenaId: idColmena, fechaMovimientoMs: 6),
        );

        await baseDatosApicola.borrarRevision(idRevision);
        expect(await baseDatosApicola.obtenerRevision(idRevision), isNull);

        await baseDatosApicola.borrarColmena(idColmena);
        expect(
          await baseDatosApicola.listarCosechasDeColmena(idColmena),
          isEmpty,
        );
        expect(
          await baseDatosApicola.listarTratamientosDeColmena(idColmena),
          isEmpty,
        );
        expect(
          await baseDatosApicola.listarIncidenciasDeColmena(idColmena),
          isEmpty,
        );
        // El movimiento es parte del libro REGA: se queda, sin colmena.
        expect(
          (await baseDatosApicola.obtenerMovimiento(idMovimiento))!.colmenaId,
          isNull,
        );
        await baseDatosApicola.borrarMovimiento(idMovimiento);
        expect(await baseDatosApicola.obtenerMovimiento(idMovimiento), isNull);
      },
    );

    test(
      'apicultor y configuración fiscal son de una sola fila (upsert)',
      () async {
        await baseDatosApicola.guardarApicultor(Apicultor(nif: '1A'));
        await baseDatosApicola.guardarApicultor(Apicultor(nif: '2B'));
        final baseDatos = await baseDatosApicola.basedatos;
        expect(await baseDatos.query('apicultores'), hasLength(1));
        expect((await baseDatosApicola.obtenerApicultor()).nif, '2B');

        await baseDatosApicola.guardarConfiguracionFiscal(
          ConfiguracionFiscal(anoFiscalActivo: 2025),
        );
        await baseDatosApicola.guardarConfiguracionFiscal(
          ConfiguracionFiscal(anoFiscalActivo: 2026),
        );
        expect(await baseDatos.query('configuraciones_fiscales'), hasLength(1));
        expect(
          (await baseDatosApicola.obtenerConfiguracionFiscal()).anoFiscalActivo,
          2026,
        );
      },
    );

    test('terceros y apuntes de gasto', () async {
      final idTercero = await baseDatosApicola.guardarTercero(
        Tercero(nif: 'B5', nombre: 'Cerería'),
      );
      expect(
        (await baseDatosApicola.obtenerTerceroPorNif('B5'))!.id,
        idTercero,
      );
      final fecha = DateTime(2026, 6, 1).millisecondsSinceEpoch;
      final idGasto = await baseDatosApicola.guardarApunteGasto(
        ApunteGasto(
          fechaMs: fecha,
          importeBaseCentimos: 100,
          terceroId: idTercero,
        ),
      );
      await baseDatosApicola.actualizarApunteGasto(idGasto, {
        'importe_base_centimos': 200,
      });
      expect(
        (await baseDatosApicola.obtenerApunteGasto(
          idGasto,
        ))!
            .importeBaseCentimos,
        200,
      );
      expect(
        await baseDatosApicola.listarApuntesGastoDeTercero(idTercero),
        hasLength(1),
      );
      await baseDatosApicola.borrarTercero(idTercero);
      expect(
        (await baseDatosApicola.obtenerApunteGasto(idGasto))!.terceroId,
        isNull,
      );
      await baseDatosApicola.borrarApunteGasto(idGasto);
      expect(await baseDatosApicola.listarApuntesGastoPorAno(2026), isEmpty);
    });

    test('facturas (sin API: SQL directo)', () async {
      final baseDatos = await baseDatosApicola.basedatos;
      await baseDatos.insert('facturas', {
        'numero_factura': '2026-001',
        'fecha_emision_ms': 1,
        'fecha_creacion_ms': 1,
      });
      expect(await baseDatosApicola.estaVacia(), isFalse);
      await baseDatos.delete('facturas');
      expect(await baseDatosApicola.estaVacia(), isTrue);
    });
  });
}
