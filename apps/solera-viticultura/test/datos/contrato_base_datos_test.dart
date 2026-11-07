// Contrato de la base de datos de Larrea Viticultura.
//
// Fija lo que la futura `BaseDatosSolera` de `nuevo_ser_core` tendrá que
// respetar (deuda R5 de docs/auditoria-2026-05-12.md):
//   (a) singleton perezoso;
//   (b) BD nueva → versión actual con todas las tablas y columnas;
//   (c) BD de cada versión antigua → migración aditiva sin perder filas;
//   (d) CRUD de las tablas principales por la API pública.
//
// Complementa a base_datos_vacia_test.dart (que prueba `crearEsquemaCompleto`
// y `baseDatosSinRegistros` sobre una BD en memoria) sin repetirlo: aquí se
// pasa por el singleton real y su `openDatabase`.
//
// Limitaciones (no se toca lib/):
//   * La ruta sale de getApplicationDocumentsDirectory() sin inyección:
//     se simula el canal de path_provider (ver soporte_contrato_base_datos).
//   * Las migraciones viven dentro del `onUpgrade` (no hay
//     `_aplicarMigraciones`) y v2 usa CREATE TABLE sin IF NOT EXISTS: no son
//     idempotentes. Se documenta, no se prueba a romperlas.
//   * `facturas` (v3) no tiene API en la clase: se prueba con SQL directo.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_viticultura/datos/base_datos.dart';
import 'package:solera_viticultura/modelos/apunte_ingreso.dart';
import 'package:solera_viticultura/modelos/cepa.dart';
import 'package:solera_viticultura/modelos/configuracion_fiscal.dart';
import 'package:solera_viticultura/modelos/cosecha.dart';
import 'package:solera_viticultura/modelos/incidencia.dart';
import 'package:solera_viticultura/modelos/tercero.dart';
import 'package:solera_viticultura/modelos/titular.dart';
import 'package:solera_viticultura/modelos/tratamiento.dart';
import 'package:solera_viticultura/modelos/vinedo.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'soporte_contrato_base_datos.dart';

/// Esquema v1 literal: copia de `_crearEsquemaInicial` (que la app sigue
/// usando para las BD nuevas antes de los pasos v2 y v3).
const List<String> sentenciasEsquemaV1Viticultura = [
  '''
    CREATE TABLE vinedos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      latitud_centroide REAL,
      longitud_centroide REAL,
      color_entero INTEGER NOT NULL DEFAULT 8202794,
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL,
      sigpac_provincia TEXT NOT NULL DEFAULT '',
      sigpac_municipio TEXT NOT NULL DEFAULT '',
      sigpac_poligono TEXT NOT NULL DEFAULT '',
      sigpac_parcela TEXT NOT NULL DEFAULT '',
      sigpac_recinto TEXT NOT NULL DEFAULT '',
      superficie_hectareas REAL
    )''',
  '''
    CREATE TABLE cepas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      vinedo_id INTEGER,
      variedad_id TEXT NOT NULL,
      portainjerto_id TEXT NOT NULL DEFAULT '',
      latitud REAL NOT NULL,
      longitud REAL NOT NULL,
      precision_metros REAL,
      fecha_plantacion_ms INTEGER,
      etiqueta TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      fecha_creacion_ms INTEGER NOT NULL,
      FOREIGN KEY (vinedo_id) REFERENCES vinedos(id) ON DELETE SET NULL
    )''',
  'CREATE INDEX idx_cepas_vinedo ON cepas (vinedo_id)',
  'CREATE INDEX idx_cepas_variedad ON cepas (variedad_id)',
  'CREATE INDEX idx_cepas_creacion ON cepas (fecha_creacion_ms DESC)',
  '''
    CREATE TABLE cosechas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cepa_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      kilos REAL,
      unidades INTEGER,
      calidad INTEGER,
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (cepa_id) REFERENCES cepas(id) ON DELETE CASCADE
    )''',
  'CREATE INDEX idx_cosechas_cepa_fecha ON cosechas (cepa_id, fecha_ms DESC)',
  '''
    CREATE TABLE observaciones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cepa_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      salud INTEGER,
      etiquetas_json TEXT NOT NULL DEFAULT '[]',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (cepa_id) REFERENCES cepas(id) ON DELETE CASCADE
    )''',
  'CREATE INDEX idx_observaciones_cepa_fecha ON observaciones (cepa_id, fecha_ms DESC)',
  '''
    CREATE TABLE incidencias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cepa_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT 'otro',
      diagnostico TEXT NOT NULL DEFAULT '',
      severidad INTEGER,
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      resuelta INTEGER NOT NULL DEFAULT 0,
      fecha_resolucion_ms INTEGER,
      FOREIGN KEY (cepa_id) REFERENCES cepas(id) ON DELETE CASCADE
    )''',
  'CREATE INDEX idx_incidencias_cepa_fecha ON incidencias (cepa_id, fecha_ms DESC)',
  'CREATE INDEX idx_incidencias_abiertas ON incidencias (resuelta, fecha_ms DESC)',
  '''
    CREATE TABLE tratamientos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cepa_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT 'otro',
      producto TEXT NOT NULL DEFAULT '',
      dosis TEXT NOT NULL DEFAULT '',
      motivo TEXT NOT NULL DEFAULT '',
      plazo_seguridad_dias INTEGER,
      incidencia_id INTEGER,
      notas TEXT NOT NULL DEFAULT '',
      numero_registro_fitosanitario TEXT NOT NULL DEFAULT '',
      nif_aplicador TEXT NOT NULL DEFAULT '',
      superficie_tratada_hectareas REAL,
      FOREIGN KEY (cepa_id) REFERENCES cepas(id) ON DELETE CASCADE,
      FOREIGN KEY (incidencia_id) REFERENCES incidencias(id) ON DELETE SET NULL
    )''',
  'CREATE INDEX idx_tratamientos_cepa_fecha ON tratamientos (cepa_id, fecha_ms DESC)',
  '''
    CREATE TABLE titulares (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nif TEXT NOT NULL DEFAULT '',
      nombre TEXT NOT NULL DEFAULT '',
      direccion TEXT NOT NULL DEFAULT '',
      numero_regepa TEXT NOT NULL DEFAULT '',
      telefono TEXT NOT NULL DEFAULT '',
      email TEXT NOT NULL DEFAULT '',
      nombre_asesor TEXT NOT NULL DEFAULT '',
      nif_asesor TEXT NOT NULL DEFAULT '',
      numero_registro_asesor TEXT NOT NULL DEFAULT '',
      nombre_aplicador TEXT NOT NULL DEFAULT '',
      nif_aplicador TEXT NOT NULL DEFAULT '',
      carnet_aplicador TEXT NOT NULL DEFAULT '',
      nivel_carnet_aplicador TEXT NOT NULL DEFAULT ''
    )''',
];

/// Historial del `onUpgrade` (v2 contabilidad, v3 facturas).
const Map<int, CambioEsquema> historialMigracionesViticultura = {
  2: CambioEsquema(tablasNuevas: [
    'terceros',
    'configuraciones_fiscales',
    'apuntes_ingreso',
    'apuntes_gasto',
  ]),
  3: CambioEsquema(tablasNuevas: ['facturas']),
};

/// Esquema esperado en la versión actual (v3).
const Map<String, Set<String>> columnasEsperadasViticultura = {
  'vinedos': {
    'id',
    'nombre',
    'latitud_centroide',
    'longitud_centroide',
    'color_entero',
    'notas',
    'fecha_creacion_ms',
    'sigpac_provincia',
    'sigpac_municipio',
    'sigpac_poligono',
    'sigpac_parcela',
    'sigpac_recinto',
    'superficie_hectareas'
  },
  'cepas': {
    'id',
    'vinedo_id',
    'variedad_id',
    'portainjerto_id',
    'latitud',
    'longitud',
    'precision_metros',
    'fecha_plantacion_ms',
    'etiqueta',
    'notas',
    'rutas_fotos_json',
    'fecha_creacion_ms'
  },
  'cosechas': {
    'id',
    'cepa_id',
    'fecha_ms',
    'kilos',
    'unidades',
    'calidad',
    'rutas_fotos_json',
    'notas'
  },
  'observaciones': {
    'id',
    'cepa_id',
    'fecha_ms',
    'salud',
    'etiquetas_json',
    'rutas_fotos_json',
    'notas'
  },
  'incidencias': {
    'id',
    'cepa_id',
    'fecha_ms',
    'tipo',
    'diagnostico',
    'severidad',
    'rutas_fotos_json',
    'notas',
    'resuelta',
    'fecha_resolucion_ms'
  },
  'tratamientos': {
    'id',
    'cepa_id',
    'fecha_ms',
    'tipo',
    'producto',
    'dosis',
    'motivo',
    'plazo_seguridad_dias',
    'incidencia_id',
    'notas',
    'numero_registro_fitosanitario',
    'nif_aplicador',
    'superficie_tratada_hectareas'
  },
  'titulares': {
    'id',
    'nif',
    'nombre',
    'direccion',
    'numero_regepa',
    'telefono',
    'email',
    'nombre_asesor',
    'nif_asesor',
    'numero_registro_asesor',
    'nombre_aplicador',
    'nif_aplicador',
    'carnet_aplicador',
    'nivel_carnet_aplicador'
  },
  'terceros': {
    'id',
    'nif',
    'nombre',
    'direccion',
    'telefono',
    'email',
    'tipo',
    'notas'
  },
  'configuraciones_fiscales': {
    'id',
    'regimen_irpf',
    'regimen_iva',
    'ano_fiscal_activo'
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
    'vinedo_id',
    'variedad_id',
    'lote_vino',
    'ruta_foto_factura',
    'numero_factura',
    'notas'
  },
  'apuntes_gasto': {
    'id',
    'fecha_ms',
    'concepto',
    'tipo_gasto',
    'importe_base_centimos',
    'iva_soportado_centimos',
    'imputacion',
    'vinedo_id',
    'variedad_id',
    'tercero_id',
    'ruta_foto_factura',
    'numero_factura',
    'tratamiento_id',
    'notas'
  },
  'facturas': {
    'id', 'numero_factura', 'fecha_emision_ms', 'fecha_vencimiento_ms', //
    'fecha_pago_ms', 'cliente_nombre', 'cliente_nif', 'cliente_direccion',
    'lineas_json', 'base_imponible', 'iva_porcentaje', 'total', 'estado',
    'notas', 'fecha_creacion_ms',
  },
};

/// Una fila por tabla v1 (en orden de dependencias FK).
const Map<String, Map<String, Object?>> filasV1Viticultura = {
  'vinedos': {
    'id': 1,
    'nombre': 'Pago Alto',
    'fecha_creacion_ms': 1000,
    'sigpac_provincia': '26',
  },
  'cepas': {
    'id': 1,
    'vinedo_id': 1,
    'variedad_id': 'tempranillo',
    'latitud': 42.4,
    'longitud': -2.5,
    'fecha_creacion_ms': 2000,
  },
  'cosechas': {'id': 1, 'cepa_id': 1, 'fecha_ms': 3000, 'kilos': 3.2},
  'observaciones': {'id': 1, 'cepa_id': 1, 'fecha_ms': 3100},
  'incidencias': {'id': 1, 'cepa_id': 1, 'fecha_ms': 3200, 'tipo': 'mildiu'},
  'tratamientos': {
    'id': 1,
    'cepa_id': 1,
    'fecha_ms': 3300,
    'incidencia_id': 1,
    'producto': 'cobre',
  },
  'titulares': {'id': 1, 'nif': '12345678Z', 'nombre': 'Bodega'},
};

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatosViticultura = BaseDatosSoleraViticultura.instancia;

  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatosViticultura.cerrar();
    await entorno.limpiar();
  });

  group('(a) singleton', () {
    test('el constructor factory devuelve siempre la misma instancia', () {
      expect(
          identical(BaseDatosSoleraViticultura(), BaseDatosSoleraViticultura()),
          isTrue);
      expect(
          identical(BaseDatosSoleraViticultura(),
              BaseDatosSoleraViticultura.instancia),
          isTrue);
    });

    test('la Database se abre una vez y se reutiliza', () async {
      final primera = await baseDatosViticultura.basedatos;
      expect(identical(primera, await baseDatosViticultura.basedatos), isTrue);
    });

    test('dos accesos simultáneos en frío comparten la misma Database',
        () async {
      final accesos = await Future.wait(
          [baseDatosViticultura.basedatos, baseDatosViticultura.basedatos]);
      expect(identical(accesos[0], accesos[1]), isTrue);
    });

    test('cerrar() y reiniciar() liberan la Database; luego se reabre',
        () async {
      final primera = await baseDatosViticultura.basedatos;
      await baseDatosViticultura.cerrar();
      expect(primera.isOpen, isFalse);
      final segunda = await baseDatosViticultura.basedatos;
      await baseDatosViticultura.reiniciar();
      expect(segunda.isOpen, isFalse);
      expect((await baseDatosViticultura.basedatos).isOpen, isTrue);
    });
  });

  group('(b) BD nueva', () {
    test('el fichero se llama solera_viticultura.db (sin sufijo de versión)',
        () async {
      expect(nombreFicheroBaseDatosViticultura, 'solera_viticultura.db');
      expect(await baseDatosViticultura.rutaBaseDatos(),
          entorno.ruta('solera_viticultura.db'));
      expect(File(entorno.ruta('solera_viticultura.db')).existsSync(), isTrue);
    });

    test('llega a la versión actual con todas las tablas y columnas', () async {
      final baseDatos = await baseDatosViticultura.basedatos;
      expect(await baseDatos.getVersion(), versionEsquemaBaseDatosViticultura);
      expect(versionEsquemaBaseDatosViticultura, 3);
      expect(
          await leerColumnasPorTabla(baseDatos), columnasEsperadasViticultura);
    });

    test('el historial declarado reproduce el esquema actual', () async {
      final columnasV1 =
          await columnasDeEsquemaV1(sentenciasEsquemaV1Viticultura);
      expect(
        columnasDeclaradasEnVersion(
          columnasV1: columnasV1,
          historial: historialMigracionesViticultura,
          columnasActuales: columnasEsperadasViticultura,
          version: versionEsquemaBaseDatosViticultura,
        ),
        columnasEsperadasViticultura,
      );
    });

    test('las claves foráneas están activas (onConfigure)', () async {
      final baseDatos = await baseDatosViticultura.basedatos;
      final filas = await baseDatos.rawQuery('PRAGMA foreign_keys');
      expect(filas.single.values.single, 1);
    });

    test('recién creada está vacía (estaVacia)', () async {
      expect(await baseDatosViticultura.estaVacia(), isTrue);
    });
  });

  group('(c) migraciones desde versiones antiguas', () {
    for (var versionAntigua = 1;
        versionAntigua < versionEsquemaBaseDatosViticultura;
        versionAntigua++) {
      test(
          'v$versionAntigua → v$versionEsquemaBaseDatosViticultura '
          'sin perder filas', () async {
        await crearBaseDatosHistorica(
          ruta: entorno.ruta(nombreFicheroBaseDatosViticultura),
          version: versionAntigua,
          sentenciasEsquemaV1: sentenciasEsquemaV1Viticultura,
          historial: historialMigracionesViticultura,
          columnasActuales: columnasEsperadasViticultura,
          filasPorTabla: filasV1Viticultura,
        );

        final baseDatos = await baseDatosViticultura.basedatos;
        expect(
            await baseDatos.getVersion(), versionEsquemaBaseDatosViticultura);
        expect(await leerColumnasPorTabla(baseDatos),
            columnasEsperadasViticultura);
        await comprobarFilasConservadas(baseDatos, filasV1Viticultura);
        expect((await baseDatosViticultura.obtenerCepa(1))!.variedadId,
            'tempranillo');
        expect(await baseDatosViticultura.estaVacia(), isFalse);
      });
    }

    test('desde v1, el esquema migrado es idéntico al de una BD nueva',
        () async {
      final baseDatosNueva = await baseDatosViticultura.basedatos;
      final detalleNueva = await leerDetalleColumnasPorTabla(baseDatosNueva);
      final indicesNueva = await leerNombresIndices(baseDatosNueva);
      await baseDatosViticultura.cerrar();
      await File(entorno.ruta(nombreFicheroBaseDatosViticultura)).delete();

      await crearBaseDatosHistorica(
        ruta: entorno.ruta(nombreFicheroBaseDatosViticultura),
        version: 1,
        sentenciasEsquemaV1: sentenciasEsquemaV1Viticultura,
        historial: historialMigracionesViticultura,
        columnasActuales: columnasEsperadasViticultura,
        filasPorTabla: filasV1Viticultura,
      );
      final baseDatosMigrada = await baseDatosViticultura.basedatos;
      expect(await leerDetalleColumnasPorTabla(baseDatosMigrada), detalleNueva);
      expect(await leerNombresIndices(baseDatosMigrada), indicesNueva);
    });

    test('reabrir una BD ya actual conserva los datos', () async {
      await baseDatosViticultura.guardarVinedo(
          Vinedo(nombre: 'Prueba', colorEntero: 1, fechaCreacionMs: 1));
      await baseDatosViticultura.cerrar();
      final reabierta = await baseDatosViticultura.basedatos;
      expect(await reabierta.getVersion(), versionEsquemaBaseDatosViticultura);
      expect(
          (await baseDatosViticultura.listarVinedos()).single.nombre, 'Prueba');
    });
  });

  group('(d) CRUD por la API pública', () {
    test('viñedos: alta, lectura, cambio y baja que desasocia cepas', () async {
      final idVinedo = await baseDatosViticultura.guardarVinedo(
          Vinedo(nombre: 'La Solana', colorEntero: 5, fechaCreacionMs: 10));
      await baseDatosViticultura
          .actualizarVinedo(idVinedo, {'nombre': 'La Solana Baja'});
      expect((await baseDatosViticultura.obtenerVinedo(idVinedo))!.nombre,
          'La Solana Baja');

      final idCepa = await baseDatosViticultura.guardarCepa(Cepa(
        vinedoId: idVinedo,
        variedadId: 'garnacha',
        latitud: 1,
        longitud: 2,
        fechaCreacionMs: 11,
      ));
      expect(await baseDatosViticultura.listarCepas(vinedoId: idVinedo),
          hasLength(1));
      await baseDatosViticultura.borrarVinedo(idVinedo);
      expect(await baseDatosViticultura.obtenerVinedo(idVinedo), isNull);
      expect(
          (await baseDatosViticultura.obtenerCepa(idCepa))!.vinedoId, isNull);
      expect(
          (await baseDatosViticultura.listarPuntosSueltos()).single.id, idCepa);
    });

    test('cepas y eventos: borrar la cepa arrastra sus eventos (CASCADE)',
        () async {
      final idCepa = await baseDatosViticultura.guardarCepa(Cepa(
        variedadId: 'verdejo',
        latitud: 1,
        longitud: 2,
        fechaCreacionMs: 20,
      ));
      await baseDatosViticultura.actualizarCepa(idCepa, {'etiqueta': 'F3-12'});
      expect(
          (await baseDatosViticultura.obtenerCepa(idCepa))!.etiqueta, 'F3-12');
      expect(
          await baseDatosViticultura.contarCepasPorVariedad(), {'verdejo': 1});

      final idCosecha = await baseDatosViticultura
          .guardarCosecha(Cosecha(cepaId: idCepa, fechaMs: 30, kilos: 2));
      await baseDatosViticultura.actualizarCosecha(idCosecha, {'kilos': 2.5});
      expect(
          (await baseDatosViticultura.obtenerCosecha(idCosecha))!.kilos, 2.5);
      final idIncidencia = await baseDatosViticultura
          .guardarIncidencia(Incidencia(cepaId: idCepa, fechaMs: 31));
      expect((await baseDatosViticultura.listarIncidenciasAbiertas()).single.id,
          idIncidencia);
      await baseDatosViticultura.guardarTratamiento(
          Tratamiento(cepaId: idCepa, fechaMs: 32, incidenciaId: idIncidencia));

      await baseDatosViticultura.borrarCosecha(idCosecha);
      expect(await baseDatosViticultura.obtenerCosecha(idCosecha), isNull);
      await baseDatosViticultura.borrarCepa(idCepa);
      expect(
          await baseDatosViticultura.listarIncidenciasDeCepa(idCepa), isEmpty);
      expect(
          await baseDatosViticultura.listarTratamientosDeCepa(idCepa), isEmpty);
    });

    test('titular y configuración fiscal son de una sola fila (upsert)',
        () async {
      await baseDatosViticultura.guardarTitular(Titular(nif: '1A'));
      await baseDatosViticultura.guardarTitular(Titular(nif: '2B'));
      final baseDatos = await baseDatosViticultura.basedatos;
      expect(await baseDatos.query('titulares'), hasLength(1));
      expect((await baseDatosViticultura.obtenerTitular()).nif, '2B');

      await baseDatosViticultura.guardarConfiguracionFiscal(
          ConfiguracionFiscal(anoFiscalActivo: 2025));
      await baseDatosViticultura.guardarConfiguracionFiscal(
          ConfiguracionFiscal(anoFiscalActivo: 2026));
      expect(await baseDatos.query('configuraciones_fiscales'), hasLength(1));
      expect(
          (await baseDatosViticultura.obtenerConfiguracionFiscal())
              .anoFiscalActivo,
          2026);
    });

    test('terceros y apuntes de ingreso', () async {
      final idTercero = await baseDatosViticultura
          .guardarTercero(Tercero(nif: 'B9', nombre: 'Cooperativa'));
      await baseDatosViticultura
          .actualizarTercero(idTercero, {'tipo': 'cliente'});
      expect((await baseDatosViticultura.obtenerTercero(idTercero))!.tipo,
          'cliente');

      final fecha = DateTime(2026, 9, 20).millisecondsSinceEpoch;
      final idIngreso = await baseDatosViticultura.guardarApunteIngreso(
          ApunteIngreso(
              fechaMs: fecha,
              importeBaseCentimos: 500,
              terceroId: idTercero,
              loteVino: 'L1'));
      await baseDatosViticultura
          .actualizarApunteIngreso(idIngreso, {'importe_base_centimos': 900});
      expect(
          (await baseDatosViticultura.obtenerApunteIngreso(idIngreso))!
              .importeBaseCentimos,
          900);
      expect(await baseDatosViticultura.listarApuntesIngresoPorAno(2026),
          hasLength(1));

      await baseDatosViticultura.borrarTercero(idTercero);
      expect(
          (await baseDatosViticultura.obtenerApunteIngreso(idIngreso))!
              .terceroId,
          isNull);
      await baseDatosViticultura.borrarApunteIngreso(idIngreso);
      expect(
          await baseDatosViticultura.obtenerApunteIngreso(idIngreso), isNull);
    });

    test('facturas (sin API: SQL directo)', () async {
      final baseDatos = await baseDatosViticultura.basedatos;
      final idFactura = await baseDatos.insert('facturas', {
        'numero_factura': '2026-001',
        'fecha_emision_ms': 1,
        'fecha_creacion_ms': 1,
      });
      expect((await baseDatos.query('facturas')).single['estado'], 'emitida');
      expect(await baseDatosViticultura.estaVacia(), isFalse);
      await baseDatos
          .delete('facturas', where: 'id = ?', whereArgs: [idFactura]);
      expect(await baseDatosViticultura.estaVacia(), isTrue);
    });
  });
}
