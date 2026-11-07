// Contrato de la base de datos de Larrea Aceitera.
//
// Fija lo que la futura `BaseDatosSolera` de `nuevo_ser_core` tendrá que
// respetar (deuda R5 de docs/auditoria-2026-05-12.md):
//   (a) singleton perezoso;
//   (b) BD nueva → versión actual con todas las tablas y columnas;
//   (c) BD de cada versión antigua → migración aditiva sin perder filas;
//   (d) CRUD de las tablas principales por la API pública.
//
// Limitaciones (no se toca lib/):
//   * La ruta sale de getApplicationDocumentsDirectory() sin inyección:
//     se simula el canal de path_provider (ver soporte_contrato_base_datos).
//   * La API pública solo inserta y lista (más `actualizarParcelaCoords` y
//     el upsert de configuración fiscal). No hay métodos de actualizar ni de
//     borrar, así que las bajas y sus cascadas FK se prueban con SQL directo
//     sobre `basedatos`.
//   * `_aplicarMigracionV2` usa CREATE TABLE sin IF NOT EXISTS: no es
//     idempotente (a diferencia de agro). Se documenta, no se prueba a
//     romperla.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_aceitera/datos/base_datos.dart';
import 'package:solera_aceitera/modelos/analitica.dart';
import 'package:solera_aceitera/modelos/apunte_gasto.dart';
import 'package:solera_aceitera/modelos/apunte_ingreso.dart';
import 'package:solera_aceitera/modelos/campania.dart';
import 'package:solera_aceitera/modelos/configuracion_fiscal.dart';
import 'package:solera_aceitera/modelos/lote_aceite.dart';
import 'package:solera_aceitera/modelos/movimiento.dart';
import 'package:solera_aceitera/modelos/olivar.dart';
import 'package:solera_aceitera/modelos/parcela.dart';
import 'package:solera_aceitera/modelos/tercero.dart';
import 'package:solera_aceitera/modelos/titular.dart';
import 'package:solera_aceitera/modelos/tratamiento.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'soporte_contrato_base_datos.dart';

/// Esquema v1 literal: copia de `_crearEsquemaV1` (que la app sigue usando
/// tal cual para las BD nuevas).
const List<String> sentenciasEsquemaV1Aceitera = [
  '''
      CREATE TABLE titulares (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        razon_social TEXT NOT NULL DEFAULT '',
        nif TEXT NOT NULL DEFAULT '',
        rgseaa TEXT NOT NULL DEFAULT '',
        numero_aica TEXT NOT NULL DEFAULT '',
        direccion TEXT NOT NULL DEFAULT '',
        telefono TEXT NOT NULL DEFAULT '',
        email TEXT NOT NULL DEFAULT '',
        iban_reagp TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT '',
        rutas_fotos_json TEXT NOT NULL DEFAULT '[]'
      )''',
  '''
      CREATE TABLE olivares (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL DEFAULT '',
        titular_id INTEGER NOT NULL,
        municipio TEXT NOT NULL DEFAULT '',
        provincia TEXT NOT NULL DEFAULT '',
        comarca TEXT NOT NULL DEFAULT '',
        certificacion_ecologico INTEGER NOT NULL DEFAULT 0,
        certificacion_integrada INTEGER NOT NULL DEFAULT 0,
        dop_id TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT '',
        rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
        FOREIGN KEY (titular_id) REFERENCES titulares(id) ON DELETE RESTRICT
      )''',
  '''
      CREATE TABLE parcelas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        olivar_id INTEGER NOT NULL,
        nombre TEXT NOT NULL DEFAULT '',
        codigo_sigpac TEXT NOT NULL DEFAULT '',
        superficie_ha REAL NOT NULL DEFAULT 0,
        variedad_mayoritaria_id TEXT NOT NULL DEFAULT '',
        marco_plantacion TEXT NOT NULL DEFAULT '',
        edad_media_anyos INTEGER NOT NULL DEFAULT 0,
        sistema_riego TEXT NOT NULL DEFAULT 'secano',
        latitud REAL,
        longitud REAL,
        poligono_geojson TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT '',
        rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
        fecha_creacion_ms INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (olivar_id) REFERENCES olivares(id) ON DELETE CASCADE
      )''',
  'CREATE INDEX idx_parcelas_olivar ON parcelas(olivar_id)',
  '''
      CREATE TABLE olivos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parcela_id INTEGER NOT NULL,
        identificador_interno TEXT NOT NULL DEFAULT '',
        variedad_id TEXT NOT NULL DEFAULT '',
        edad_anyos INTEGER NOT NULL DEFAULT 0,
        estado TEXT NOT NULL DEFAULT 'productivo',
        fecha_plantacion_ms INTEGER,
        notas TEXT NOT NULL DEFAULT '',
        fecha_creacion_ms INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (parcela_id) REFERENCES parcelas(id) ON DELETE CASCADE
      )''',
  'CREATE INDEX idx_olivos_parcela ON olivos(parcela_id)',
  '''
      CREATE TABLE campanias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        olivar_id INTEGER NOT NULL,
        anyo_comercial INTEGER NOT NULL,
        fecha_inicio_ms INTEGER NOT NULL,
        fecha_fin_ms INTEGER,
        produccion_total_kg_aceituna REAL NOT NULL DEFAULT 0,
        produccion_total_kg_aceite REAL NOT NULL DEFAULT 0,
        rendimiento_medio_porcentaje REAL NOT NULL DEFAULT 0,
        observaciones_meteorologicas TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (olivar_id) REFERENCES olivares(id) ON DELETE CASCADE
      )''',
  'CREATE INDEX idx_campanias_olivar ON campanias(olivar_id)',
  'CREATE INDEX idx_campanias_anyo ON campanias(anyo_comercial)',
  '''
      CREATE TABLE recolecciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parcela_id INTEGER NOT NULL,
        campania_id INTEGER NOT NULL,
        fecha_ms INTEGER NOT NULL,
        kg_estimados REAL NOT NULL DEFAULT 0,
        tipo_aceituna TEXT NOT NULL DEFAULT 'envero',
        metodo TEXT NOT NULL DEFAULT 'vibrador',
        cuadrilla TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT '',
        rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
        FOREIGN KEY (parcela_id) REFERENCES parcelas(id) ON DELETE CASCADE,
        FOREIGN KEY (campania_id) REFERENCES campanias(id) ON DELETE CASCADE
      )''',
  'CREATE INDEX idx_recolecciones_campania ON recolecciones(campania_id)',
  'CREATE INDEX idx_recolecciones_parcela ON recolecciones(parcela_id)',
  'CREATE INDEX idx_recolecciones_fecha ON recolecciones(fecha_ms)',
  '''
      CREATE TABLE partidas_aceituna (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        campania_id INTEGER NOT NULL,
        recoleccion_id INTEGER,
        fecha_ms INTEGER NOT NULL,
        kg_netos_bascula REAL NOT NULL DEFAULT 0,
        porcentaje_aceituna_defectuosa REAL NOT NULL DEFAULT 0,
        catador TEXT NOT NULL DEFAULT '',
        numero_albaran TEXT NOT NULL DEFAULT '',
        origen_es_socio INTEGER NOT NULL DEFAULT 0,
        socio_externo TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT '',
        rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
        FOREIGN KEY (campania_id) REFERENCES campanias(id) ON DELETE CASCADE,
        FOREIGN KEY (recoleccion_id) REFERENCES recolecciones(id) ON DELETE SET NULL
      )''',
  'CREATE INDEX idx_partidas_campania ON partidas_aceituna(campania_id)',
  'CREATE INDEX idx_partidas_recoleccion ON partidas_aceituna(recoleccion_id)',
  'CREATE INDEX idx_partidas_fecha ON partidas_aceituna(fecha_ms)',
  '''
      CREATE TABLE molturaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        campania_id INTEGER NOT NULL,
        fecha_ms INTEGER NOT NULL,
        kg_molturados REAL NOT NULL DEFAULT 0,
        rendimiento_porcentaje REAL NOT NULL DEFAULT 0,
        aceite_obtenido_kg REAL NOT NULL DEFAULT 0,
        lote_aceite_id INTEGER,
        alperujo_kg REAL NOT NULL DEFAULT 0,
        batidora_referencia TEXT NOT NULL DEFAULT '',
        decanter_referencia TEXT NOT NULL DEFAULT '',
        partidas_usadas_json TEXT NOT NULL DEFAULT '[]',
        notas TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (campania_id) REFERENCES campanias(id) ON DELETE CASCADE,
        FOREIGN KEY (lote_aceite_id) REFERENCES lotes_aceite(id) ON DELETE SET NULL
      )''',
  'CREATE INDEX idx_molturaciones_campania ON molturaciones(campania_id)',
  'CREATE INDEX idx_molturaciones_lote ON molturaciones(lote_aceite_id)',
  '''
      CREATE TABLE lotes_aceite (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        campania_id INTEGER NOT NULL,
        identificador_lote TEXT NOT NULL,
        fecha_creacion_ms INTEGER NOT NULL,
        kg_netos REAL NOT NULL DEFAULT 0,
        acidez REAL,
        peroxidos REAL,
        k232 REAL,
        k270 REAL,
        polifenoles_mg_kg REAL,
        panel_test_puntuacion REAL,
        panel_test_notas TEXT NOT NULL DEFAULT '',
        categoria TEXT NOT NULL DEFAULT 'por_clasificar',
        dop_id TEXT NOT NULL DEFAULT '',
        ubicacion_fisica TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (campania_id) REFERENCES campanias(id) ON DELETE CASCADE
      )''',
  'CREATE INDEX idx_lotes_campania ON lotes_aceite(campania_id)',
  'CREATE UNIQUE INDEX idx_lotes_identificador ON lotes_aceite(campania_id, identificador_lote)',
  '''
      CREATE TABLE movimientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lote_aceite_id INTEGER NOT NULL,
        fecha_ms INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        kg_movidos REAL NOT NULL DEFAULT 0,
        ubicacion_destino TEXT NOT NULL DEFAULT '',
        venta_id INTEGER,
        lote_destino_mezcla_id INTEGER,
        notas TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (lote_aceite_id) REFERENCES lotes_aceite(id) ON DELETE CASCADE,
        FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE SET NULL,
        FOREIGN KEY (lote_destino_mezcla_id) REFERENCES lotes_aceite(id) ON DELETE SET NULL
      )''',
  'CREATE INDEX idx_movimientos_lote ON movimientos(lote_aceite_id)',
  'CREATE INDEX idx_movimientos_fecha ON movimientos(fecha_ms)',
  'CREATE INDEX idx_movimientos_tipo ON movimientos(tipo)',
  '''
      CREATE TABLE ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha_ms INTEGER NOT NULL,
        tipo_cliente TEXT NOT NULL DEFAULT 'particular',
        nombre_cliente TEXT NOT NULL DEFAULT '',
        identificador_fiscal_cliente TEXT NOT NULL DEFAULT '',
        numero_factura TEXT NOT NULL DEFAULT '',
        lineas_json TEXT NOT NULL DEFAULT '[]',
        total_sin_iva REAL NOT NULL DEFAULT 0,
        iva_porcentaje REAL NOT NULL DEFAULT 0,
        total_con_iva REAL NOT NULL DEFAULT 0,
        destino_pais_iso TEXT NOT NULL DEFAULT 'ES',
        notas TEXT NOT NULL DEFAULT ''
      )''',
  'CREATE INDEX idx_ventas_fecha ON ventas(fecha_ms)',
  '''
      CREATE TABLE tratamientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parcela_id INTEGER NOT NULL,
        fecha_ms INTEGER NOT NULL,
        producto_comercial_referencia TEXT NOT NULL DEFAULT '',
        sustancia_activa_id TEXT NOT NULL DEFAULT '',
        dosis_litros_por_ha REAL NOT NULL DEFAULT 0,
        plaga_objetivo_id TEXT NOT NULL DEFAULT '',
        aplicador_nombre TEXT NOT NULL DEFAULT '',
        carnet_aplicador_numero TEXT NOT NULL DEFAULT '',
        observaciones TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT '',
        rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
        FOREIGN KEY (parcela_id) REFERENCES parcelas(id) ON DELETE CASCADE
      )''',
  'CREATE INDEX idx_tratamientos_parcela ON tratamientos(parcela_id)',
  'CREATE INDEX idx_tratamientos_fecha ON tratamientos(fecha_ms)',
  '''
      CREATE TABLE incidencias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha_ms INTEGER NOT NULL,
        ambito TEXT NOT NULL DEFAULT 'olivar',
        parcela_id INTEGER,
        lote_aceite_id INTEGER,
        tipo TEXT NOT NULL DEFAULT 'otro',
        descripcion TEXT NOT NULL DEFAULT '',
        severidad TEXT NOT NULL DEFAULT 'leve',
        accion_correctiva TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT '',
        rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
        FOREIGN KEY (parcela_id) REFERENCES parcelas(id) ON DELETE SET NULL,
        FOREIGN KEY (lote_aceite_id) REFERENCES lotes_aceite(id) ON DELETE SET NULL
      )''',
  'CREATE INDEX idx_incidencias_fecha ON incidencias(fecha_ms)',
  'CREATE INDEX idx_incidencias_ambito ON incidencias(ambito)',
  '''
      CREATE TABLE analiticas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lote_aceite_id INTEGER NOT NULL,
        fecha_ms INTEGER NOT NULL,
        acidez REAL,
        peroxidos REAL,
        k232 REAL,
        k270 REAL,
        polifenoles_mg_kg REAL,
        color REAL,
        humedad REAL,
        panel_test_puntuacion REAL,
        panel_test_notas TEXT NOT NULL DEFAULT '',
        laboratorio TEXT NOT NULL DEFAULT '',
        notas TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (lote_aceite_id) REFERENCES lotes_aceite(id) ON DELETE CASCADE
      )''',
  'CREATE INDEX idx_analiticas_lote ON analiticas(lote_aceite_id)',
  'CREATE INDEX idx_analiticas_fecha ON analiticas(fecha_ms)',
];

/// Historial de `_aplicarMigraciones` (solo v2: libro económico).
const Map<int, CambioEsquema> historialMigracionesAceitera = {
  2: CambioEsquema(tablasNuevas: [
    'terceros',
    'configuracion_fiscal',
    'apuntes_ingreso',
    'apuntes_gasto',
  ]),
};

/// Esquema esperado en la versión actual (v2).
const Map<String, Set<String>> columnasEsperadasAceitera = {
  'titulares': {
    'id',
    'razon_social',
    'nif',
    'rgseaa',
    'numero_aica',
    'direccion',
    'telefono',
    'email',
    'iban_reagp',
    'notas',
    'rutas_fotos_json'
  },
  'olivares': {
    'id',
    'nombre',
    'titular_id',
    'municipio',
    'provincia',
    'comarca',
    'certificacion_ecologico',
    'certificacion_integrada',
    'dop_id',
    'notas',
    'rutas_fotos_json'
  },
  'parcelas': {
    'id',
    'olivar_id',
    'nombre',
    'codigo_sigpac',
    'superficie_ha',
    'variedad_mayoritaria_id',
    'marco_plantacion',
    'edad_media_anyos',
    'sistema_riego',
    'latitud',
    'longitud',
    'poligono_geojson',
    'notas',
    'rutas_fotos_json',
    'fecha_creacion_ms'
  },
  'olivos': {
    'id',
    'parcela_id',
    'identificador_interno',
    'variedad_id',
    'edad_anyos',
    'estado',
    'fecha_plantacion_ms',
    'notas',
    'fecha_creacion_ms'
  },
  'campanias': {
    'id',
    'olivar_id',
    'anyo_comercial',
    'fecha_inicio_ms',
    'fecha_fin_ms',
    'produccion_total_kg_aceituna',
    'produccion_total_kg_aceite',
    'rendimiento_medio_porcentaje',
    'observaciones_meteorologicas',
    'notas'
  },
  'recolecciones': {
    'id',
    'parcela_id',
    'campania_id',
    'fecha_ms',
    'kg_estimados',
    'tipo_aceituna',
    'metodo',
    'cuadrilla',
    'notas',
    'rutas_fotos_json'
  },
  'partidas_aceituna': {
    'id',
    'campania_id',
    'recoleccion_id',
    'fecha_ms',
    'kg_netos_bascula',
    'porcentaje_aceituna_defectuosa',
    'catador',
    'numero_albaran',
    'origen_es_socio',
    'socio_externo',
    'notas',
    'rutas_fotos_json'
  },
  'molturaciones': {
    'id',
    'campania_id',
    'fecha_ms',
    'kg_molturados',
    'rendimiento_porcentaje',
    'aceite_obtenido_kg',
    'lote_aceite_id',
    'alperujo_kg',
    'batidora_referencia',
    'decanter_referencia',
    'partidas_usadas_json',
    'notas'
  },
  'lotes_aceite': {
    'id',
    'campania_id',
    'identificador_lote',
    'fecha_creacion_ms',
    'kg_netos',
    'acidez',
    'peroxidos',
    'k232',
    'k270',
    'polifenoles_mg_kg',
    'panel_test_puntuacion',
    'panel_test_notas',
    'categoria',
    'dop_id',
    'ubicacion_fisica',
    'notas'
  },
  'movimientos': {
    'id',
    'lote_aceite_id',
    'fecha_ms',
    'tipo',
    'kg_movidos',
    'ubicacion_destino',
    'venta_id',
    'lote_destino_mezcla_id',
    'notas'
  },
  'ventas': {
    'id',
    'fecha_ms',
    'tipo_cliente',
    'nombre_cliente',
    'identificador_fiscal_cliente',
    'numero_factura',
    'lineas_json',
    'total_sin_iva',
    'iva_porcentaje',
    'total_con_iva',
    'destino_pais_iso',
    'notas'
  },
  'tratamientos': {
    'id',
    'parcela_id',
    'fecha_ms',
    'producto_comercial_referencia',
    'sustancia_activa_id',
    'dosis_litros_por_ha',
    'plaga_objetivo_id',
    'aplicador_nombre',
    'carnet_aplicador_numero',
    'observaciones',
    'notas',
    'rutas_fotos_json'
  },
  'incidencias': {
    'id',
    'fecha_ms',
    'ambito',
    'parcela_id',
    'lote_aceite_id',
    'tipo',
    'descripcion',
    'severidad',
    'accion_correctiva',
    'notas',
    'rutas_fotos_json'
  },
  'analiticas': {
    'id',
    'lote_aceite_id',
    'fecha_ms',
    'acidez',
    'peroxidos',
    'k232',
    'k270',
    'polifenoles_mg_kg',
    'color',
    'humedad',
    'panel_test_puntuacion',
    'panel_test_notas',
    'laboratorio',
    'notas'
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
  'configuracion_fiscal': {
    'id',
    'regimen_irpf',
    'regimen_iva',
    'anyo_fiscal_activo'
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
    'parcela_id',
    'variedad_id',
    'lote_aceite_id',
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
    'parcela_id',
    'variedad_id',
    'tercero_id',
    'ruta_foto_factura',
    'numero_factura',
    'tratamiento_id',
    'notas'
  },
};

/// Una fila por tabla v1 con dependencias (FK), en orden.
const Map<String, Map<String, Object?>> filasV1Aceitera = {
  'titulares': {'id': 1, 'razon_social': 'Almazara Sierra', 'nif': 'B1'},
  'olivares': {'id': 1, 'nombre': 'Los Llanos', 'titular_id': 1},
  'parcelas': {'id': 1, 'olivar_id': 1, 'nombre': 'P-1', 'superficie_ha': 2.5},
  'campanias': {
    'id': 1,
    'olivar_id': 1,
    'anyo_comercial': 2025,
    'fecha_inicio_ms': 100,
  },
  'lotes_aceite': {
    'id': 1,
    'campania_id': 1,
    'identificador_lote': 'L-25-01',
    'fecha_creacion_ms': 200,
    'kg_netos': 900.0,
  },
  'movimientos': {
    'id': 1,
    'lote_aceite_id': 1,
    'fecha_ms': 300,
    'tipo': 'traslado_deposito',
    'kg_movidos': 100.0,
  },
  'tratamientos': {'id': 1, 'parcela_id': 1, 'fecha_ms': 400},
};

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatosAceitera = BaseDatosSoleraAceitera.instancia;

  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatosAceitera.cerrar();
    await entorno.limpiar();
  });

  /// Titular → olivar → parcela → campaña, que casi todo cuelga de ahí.
  Future<({int olivarId, int parcelaId, int campaniaId})>
      crearExplotacionMinima() async {
    final titularId =
        await baseDatosAceitera.insertarTitular(Titular(razonSocial: 'A'));
    final olivarId = await baseDatosAceitera
        .insertarOlivar(Olivar(titularId: titularId, nombre: 'Olivar'));
    final parcelaId = await baseDatosAceitera.insertarParcela(
        Parcela(olivarId: olivarId, nombre: 'P', fechaCreacionMs: 1));
    final campaniaId = await baseDatosAceitera.insertarCampania(
        Campania(olivarId: olivarId, anyoComercial: 2025, fechaInicioMs: 1));
    return (olivarId: olivarId, parcelaId: parcelaId, campaniaId: campaniaId);
  }

  group('(a) singleton', () {
    test('el constructor factory devuelve siempre la misma instancia', () {
      expect(identical(BaseDatosSoleraAceitera(), BaseDatosSoleraAceitera()),
          isTrue);
      expect(
          identical(
              BaseDatosSoleraAceitera(), BaseDatosSoleraAceitera.instancia),
          isTrue);
    });

    test('la Database se abre una vez y se reutiliza', () async {
      final primera = await baseDatosAceitera.basedatos;
      expect(identical(primera, await baseDatosAceitera.basedatos), isTrue);
    });

    test('dos accesos simultáneos en frío comparten la misma Database',
        () async {
      final accesos = await Future.wait(
          [baseDatosAceitera.basedatos, baseDatosAceitera.basedatos]);
      expect(identical(accesos[0], accesos[1]), isTrue);
    });

    test('cerrar() libera la Database y el siguiente acceso la reabre',
        () async {
      final antes = await baseDatosAceitera.basedatos;
      await baseDatosAceitera.cerrar();
      expect(antes.isOpen, isFalse);
      expect((await baseDatosAceitera.basedatos).isOpen, isTrue);
    });
  });

  group('(b) BD nueva', () {
    test('el fichero se llama solera_aceitera.db (sin sufijo de versión)',
        () async {
      await baseDatosAceitera.basedatos;
      expect(nombreFicheroBaseDatosAceitera, 'solera_aceitera.db');
      expect(File(entorno.ruta('solera_aceitera.db')).existsSync(), isTrue);
    });

    test('llega a la versión actual con todas las tablas y columnas', () async {
      final baseDatos = await baseDatosAceitera.basedatos;
      expect(await baseDatos.getVersion(), versionEsquemaSoleraAceitera);
      expect(versionEsquemaSoleraAceitera, 2);
      expect(await leerColumnasPorTabla(baseDatos), columnasEsperadasAceitera);
    });

    test('el historial declarado reproduce el esquema actual', () async {
      final columnasV1 = await columnasDeEsquemaV1(sentenciasEsquemaV1Aceitera);
      expect(
        columnasDeclaradasEnVersion(
          columnasV1: columnasV1,
          historial: historialMigracionesAceitera,
          columnasActuales: columnasEsperadasAceitera,
          version: versionEsquemaSoleraAceitera,
        ),
        columnasEsperadasAceitera,
      );
    });

    test('las claves foráneas están activas (onConfigure)', () async {
      final baseDatos = await baseDatosAceitera.basedatos;
      final filas = await baseDatos.rawQuery('PRAGMA foreign_keys');
      expect(filas.single.values.single, 1);
    });
  });

  group('(c) migraciones desde versiones antiguas', () {
    for (var versionAntigua = 1;
        versionAntigua < versionEsquemaSoleraAceitera;
        versionAntigua++) {
      test('v$versionAntigua → v$versionEsquemaSoleraAceitera sin perder filas',
          () async {
        await crearBaseDatosHistorica(
          ruta: entorno.ruta(nombreFicheroBaseDatosAceitera),
          version: versionAntigua,
          sentenciasEsquemaV1: sentenciasEsquemaV1Aceitera,
          historial: historialMigracionesAceitera,
          columnasActuales: columnasEsperadasAceitera,
          filasPorTabla: filasV1Aceitera,
        );

        final baseDatos = await baseDatosAceitera.basedatos;
        expect(await baseDatos.getVersion(), versionEsquemaSoleraAceitera);
        expect(
            await leerColumnasPorTabla(baseDatos), columnasEsperadasAceitera);
        await comprobarFilasConservadas(baseDatos, filasV1Aceitera);
        expect(
            (await baseDatosAceitera.listarLotesAceite())
                .single
                .identificadorLote,
            'L-25-01');
        // Las tablas nuevas de v2 están vacías y listas para usarse.
        expect(await baseDatosAceitera.listarTerceros(), isEmpty);
      });
    }

    test('desde v1, el esquema migrado es idéntico al de una BD nueva',
        () async {
      final baseDatosNueva = await baseDatosAceitera.basedatos;
      final detalleNueva = await leerDetalleColumnasPorTabla(baseDatosNueva);
      final indicesNueva = await leerNombresIndices(baseDatosNueva);
      await baseDatosAceitera.cerrar();
      await File(entorno.ruta(nombreFicheroBaseDatosAceitera)).delete();

      await crearBaseDatosHistorica(
        ruta: entorno.ruta(nombreFicheroBaseDatosAceitera),
        version: 1,
        sentenciasEsquemaV1: sentenciasEsquemaV1Aceitera,
        historial: historialMigracionesAceitera,
        columnasActuales: columnasEsperadasAceitera,
        filasPorTabla: filasV1Aceitera,
      );
      final baseDatosMigrada = await baseDatosAceitera.basedatos;
      expect(await leerDetalleColumnasPorTabla(baseDatosMigrada), detalleNueva);
      expect(await leerNombresIndices(baseDatosMigrada), indicesNueva);
    });

    test('reabrir una BD ya actual conserva los datos', () async {
      await crearExplotacionMinima();
      await baseDatosAceitera.cerrar();
      final reabierta = await baseDatosAceitera.basedatos;
      expect(await reabierta.getVersion(), versionEsquemaSoleraAceitera);
      expect(await baseDatosAceitera.listarParcelas(), hasLength(1));
    });
  });

  group('(d) CRUD por la API pública', () {
    test('titular, olivar y parcelas: alta, lectura y cambio de coordenadas',
        () async {
      expect(await baseDatosAceitera.obtenerTitular(), isNull);
      final explotacion = await crearExplotacionMinima();
      expect((await baseDatosAceitera.obtenerTitular())!.razonSocial, 'A');
      expect(
          (await baseDatosAceitera.obtenerOlivar())!.id, explotacion.olivarId);

      final parcelas = await baseDatosAceitera.listarParcelas(
          olivarId: explotacion.olivarId);
      expect(parcelas.single.latitud, isNull);
      await baseDatosAceitera.actualizarParcelaCoords(
          id: explotacion.parcelaId, latitud: 37.9, longitud: -3.8);
      expect((await baseDatosAceitera.listarParcelas()).single.latitud, 37.9);
    });

    test('lotes, movimientos y analíticas; borrar la campaña los arrastra',
        () async {
      final explotacion = await crearExplotacionMinima();
      final loteId = await baseDatosAceitera.insertarLoteAceite(LoteAceite(
        campaniaId: explotacion.campaniaId,
        identificadorLote: 'L-1',
        fechaCreacionMs: 2,
      ));
      await baseDatosAceitera.insertarMovimiento(Movimiento(
          loteAceiteId: loteId, fechaMs: 3, tipo: 'traslado_deposito'));
      await baseDatosAceitera.insertarAnalitica(
          Analitica(loteAceiteId: loteId, fechaMs: 4, acidez: 0.2));
      expect(
          await baseDatosAceitera.listarLotesAceite(
              campaniaId: explotacion.campaniaId),
          hasLength(1));
      expect(await baseDatosAceitera.listarMovimientos(loteAceiteId: loteId),
          hasLength(1));
      expect(
          (await baseDatosAceitera.listarAnaliticas(loteAceiteId: loteId))
              .single
              .acidez,
          0.2);

      // Identificador de lote único por campaña.
      expect(
        () => baseDatosAceitera.insertarLoteAceite(LoteAceite(
          campaniaId: explotacion.campaniaId,
          identificadorLote: 'L-1',
          fechaCreacionMs: 5,
        )),
        throwsA(isA<DatabaseException>()),
      );

      // Sin API de borrado: SQL directo para fijar las cascadas.
      final baseDatos = await baseDatosAceitera.basedatos;
      await baseDatos.delete('campanias',
          where: 'id = ?', whereArgs: [explotacion.campaniaId]);
      expect(await baseDatosAceitera.listarLotesAceite(), isEmpty);
      expect(await baseDatosAceitera.listarMovimientos(), isEmpty);
      expect(await baseDatosAceitera.listarAnaliticas(), isEmpty);
    });

    test('un titular con olivares no se puede borrar (ON DELETE RESTRICT)',
        () async {
      await crearExplotacionMinima();
      final baseDatos = await baseDatosAceitera.basedatos;
      expect(() => baseDatos.delete('titulares'),
          throwsA(isA<DatabaseException>()));
    });

    test('tratamientos por parcela', () async {
      final explotacion = await crearExplotacionMinima();
      await baseDatosAceitera.insertarTratamiento(
          Tratamiento(parcelaId: explotacion.parcelaId, fechaMs: 9));
      expect(
          await baseDatosAceitera.listarTratamientos(
              parcelaId: explotacion.parcelaId),
          hasLength(1));
    });

    test('libro económico: terceros, apuntes y configuración de una fila',
        () async {
      final terceroId = await baseDatosAceitera
          .insertarTercero(Tercero(nombre: 'Envasadora', tipo: 'cliente'));
      expect(
          (await baseDatosAceitera.listarTerceros(tipo: 'cliente')).single.id,
          terceroId);

      await baseDatosAceitera.insertarApunteIngreso(ApunteIngreso(
          fechaMs: 50, importeBaseCentimos: 1000, terceroId: terceroId));
      await baseDatosAceitera.insertarApunteGasto(
          ApunteGasto(fechaMs: 60, importeBaseCentimos: 7));
      expect(
          await baseDatosAceitera.listarApuntesIngreso(desdeMs: 0, hastaMs: 55),
          hasLength(1));
      expect(await baseDatosAceitera.listarApuntesGasto(), hasLength(1));

      final primerId = await baseDatosAceitera.guardarConfiguracionFiscal(
          ConfiguracionFiscal(anyoFiscalActivo: 2025));
      final segundoId = await baseDatosAceitera.guardarConfiguracionFiscal(
          ConfiguracionFiscal(anyoFiscalActivo: 2026));
      expect(segundoId, primerId);
      expect(
          (await baseDatosAceitera.obtenerConfiguracionFiscal())
              .anyoFiscalActivo,
          2026);

      // Borrar el tercero deja el ingreso sin tercero (ON DELETE SET NULL).
      final baseDatos = await baseDatosAceitera.basedatos;
      await baseDatos
          .delete('terceros', where: 'id = ?', whereArgs: [terceroId]);
      expect((await baseDatosAceitera.listarApuntesIngreso()).single.terceroId,
          isNull);
    });
  });
}
