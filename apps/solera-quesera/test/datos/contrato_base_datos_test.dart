// Contrato de la base de datos de Larrea Quesera.
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
//   * Las migraciones viven en el `onUpgrade` con `if (viejaVersion < N)`
//     (no hay `_aplicarMigraciones`). v2-v4 usan IF NOT EXISTS.
//   * No hay `rutaBaseDatos()` ni `estaVacia()` como en viticultura/apícola.
//   * `facturas` (v4) no tiene API en la clase: se prueba con SQL directo.
//   * Varias tablas solo tienen guardar/listar (analíticas, ventas,
//     controles APPCC, formación, ingresos y gastos): no hay actualizar ni
//     borrar que probar.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_quesera/datos/base_datos.dart';
import 'package:solera_quesera/modelos/apunte_ingreso.dart';
import 'package:solera_quesera/modelos/configuracion_fiscal.dart';
import 'package:solera_quesera/modelos/evento_curacion.dart';
import 'package:solera_quesera/modelos/incidencia.dart';
import 'package:solera_quesera/modelos/lote_produccion.dart';
import 'package:solera_quesera/modelos/partida_leche.dart';
import 'package:solera_quesera/modelos/proveedor_leche.dart';
import 'package:solera_quesera/modelos/queseria.dart';
import 'package:solera_quesera/modelos/receta.dart';
import 'package:solera_quesera/modelos/simulacion_trazabilidad.dart';
import 'package:solera_quesera/modelos/tercero.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'soporte_contrato_base_datos.dart';

/// Esquema v1 literal: copia de `_crearEsquemaV1`.
const List<String> sentenciasEsquemaV1Quesera = [
  '''
    CREATE TABLE queserias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      razon_social TEXT NOT NULL DEFAULT '',
      nif TEXT NOT NULL DEFAULT '',
      direccion TEXT NOT NULL DEFAULT '',
      latitud REAL,
      longitud REAL,
      rgseaa TEXT NOT NULL DEFAULT '',
      telefono TEXT NOT NULL DEFAULT '',
      email TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]'
    )''',
  '''
    CREATE TABLE proveedores_leche (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL DEFAULT '',
      nif TEXT NOT NULL DEFAULT '',
      direccion TEXT NOT NULL DEFAULT '',
      explotacion_ganadera TEXT NOT NULL DEFAULT '',
      tipo_leche TEXT NOT NULL DEFAULT 'oveja',
      raza_id TEXT NOT NULL DEFAULT '',
      num_animales INTEGER,
      es_propio INTEGER NOT NULL DEFAULT 0,
      latitud REAL,
      longitud REAL,
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL
    )''',
  '''
    CREATE TABLE partidas_leche (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      proveedor_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      volumen_litros REAL NOT NULL DEFAULT 0,
      temperatura_recepcion REAL,
      ph REAL,
      grasa REAL,
      proteina REAL,
      extracto_seco REAL,
      celulas_somaticas REAL,
      bacterias REAL,
      antibioticos_positivos INTEGER NOT NULL DEFAULT 0,
      incidencia TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (proveedor_id) REFERENCES proveedores_leche(id) ON DELETE CASCADE
    )''',
  '''
    CREATE TABLE recetas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL DEFAULT '',
      tipo_queso_id TEXT NOT NULL DEFAULT '',
      do_id TEXT,
      tipo_leche TEXT NOT NULL DEFAULT 'oveja',
      fermento TEXT NOT NULL DEFAULT '',
      tipo_cuajo TEXT NOT NULL DEFAULT 'animal',
      temp_coagulacion REAL NOT NULL DEFAULT 30,
      tiempo_coag_minutos INTEGER NOT NULL DEFAULT 30,
      tam_cuajada TEXT NOT NULL DEFAULT 'medio',
      temp_cocion REAL,
      ph_salado REAL,
      rendimiento_esperado REAL NOT NULL DEFAULT 8,
      curacion_minima_dias INTEGER NOT NULL DEFAULT 60,
      notas TEXT NOT NULL DEFAULT ''
    )''',
  '''
    CREATE TABLE lotes_produccion (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      numero_lote TEXT NOT NULL,
      fecha_ms INTEGER NOT NULL,
      receta_id INTEGER NOT NULL,
      tipo_queso_id TEXT NOT NULL DEFAULT '',
      do_id TEXT,
      partidas_leche_usadas_json TEXT NOT NULL DEFAULT '[]',
      volumen_leche_total REAL NOT NULL DEFAULT 0,
      peso_total_obtenido REAL NOT NULL DEFAULT 0,
      rendimiento_real REAL NOT NULL DEFAULT 0,
      num_piezas_producidas INTEGER NOT NULL DEFAULT 0,
      peso_medio_pieza REAL NOT NULL DEFAULT 0,
      fermento_nombre TEXT NOT NULL DEFAULT '',
      fermento_lote_comercial TEXT NOT NULL DEFAULT '',
      cuajo_tipo TEXT NOT NULL DEFAULT 'animal',
      cuajo_lote_comercial TEXT NOT NULL DEFAULT '',
      sal_lote TEXT NOT NULL DEFAULT '',
      temp_coagulacion REAL NOT NULL DEFAULT 30,
      tiempo_coag_minutos INTEGER NOT NULL DEFAULT 30,
      ph_cuajada REAL,
      estado TEXT NOT NULL DEFAULT 'fresca',
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL,
      FOREIGN KEY (receta_id) REFERENCES recetas(id) ON DELETE RESTRICT
    )''',
  '''
    CREATE TABLE piezas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      lote_produccion_id INTEGER NOT NULL,
      numero_pieza TEXT NOT NULL,
      peso_inicial REAL NOT NULL DEFAULT 0,
      peso_actual REAL,
      ubicacion_actual TEXT NOT NULL DEFAULT '',
      estado TEXT NOT NULL DEFAULT 'afinando',
      fecha_expedicion_ms INTEGER,
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL,
      FOREIGN KEY (lote_produccion_id) REFERENCES lotes_produccion(id) ON DELETE CASCADE
    )''',
  '''
    CREATE TABLE eventos_curacion (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pieza_id INTEGER NOT NULL,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL,
      peso_actual REAL,
      madera_ahumado TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL,
      FOREIGN KEY (pieza_id) REFERENCES piezas(id) ON DELETE CASCADE
    )''',
  '''
    CREATE TABLE analiticas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT '',
      laboratorio TEXT NOT NULL DEFAULT '',
      lote_produccion_id INTEGER,
      parametros_json TEXT NOT NULL DEFAULT '{}',
      conforme INTEGER NOT NULL DEFAULT 1,
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (lote_produccion_id) REFERENCES lotes_produccion(id) ON DELETE SET NULL
    )''',
  '''
    CREATE TABLE incidencias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT 'otra',
      lote_produccion_id INTEGER,
      pieza_id INTEGER,
      descripcion TEXT NOT NULL DEFAULT '',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      causa TEXT NOT NULL DEFAULT '',
      accion_correctiva TEXT NOT NULL DEFAULT '',
      cerrada INTEGER NOT NULL DEFAULT 0,
      fecha_creacion_ms INTEGER NOT NULL,
      FOREIGN KEY (lote_produccion_id) REFERENCES lotes_produccion(id) ON DELETE SET NULL,
      FOREIGN KEY (pieza_id) REFERENCES piezas(id) ON DELETE SET NULL
    )''',
  '''
    CREATE TABLE ventas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      cliente_nombre TEXT NOT NULL DEFAULT '',
      cliente_nif TEXT NOT NULL DEFAULT '',
      cliente_direccion TEXT NOT NULL DEFAULT '',
      tipo TEXT NOT NULL DEFAULT 'directa',
      lineas_json TEXT NOT NULL DEFAULT '[]',
      numero_factura TEXT NOT NULL DEFAULT '',
      base_imponible REAL NOT NULL DEFAULT 0,
      iva_porcentaje REAL NOT NULL DEFAULT 10,
      total REAL NOT NULL DEFAULT 0,
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL
    )''',
  '''
    CREATE TABLE controles_temperatura (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      cava_id TEXT NOT NULL DEFAULT '',
      temperatura REAL NOT NULL DEFAULT 10,
      humedad_relativa REAL NOT NULL DEFAULT 85,
      responsable TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT ''
    )''',
  '''
    CREATE TABLE controles_limpieza (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      zona TEXT NOT NULL DEFAULT '',
      tarea TEXT NOT NULL DEFAULT '',
      producto_usado TEXT NOT NULL DEFAULT '',
      responsable TEXT NOT NULL DEFAULT '',
      verificado INTEGER NOT NULL DEFAULT 1,
      accion_correctiva TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT ''
    )''',
  '''
    CREATE TABLE controles_plagas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT '',
      medida TEXT NOT NULL DEFAULT '',
      responsable TEXT NOT NULL DEFAULT '',
      resultado TEXT NOT NULL DEFAULT '',
      proxima_revision_ms INTEGER,
      notas TEXT NOT NULL DEFAULT ''
    )''',
  '''
    CREATE TABLE formacion (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      empleado TEXT NOT NULL DEFAULT '',
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT '',
      impartido_por TEXT NOT NULL DEFAULT '',
      duracion_minutos INTEGER NOT NULL DEFAULT 0,
      documento TEXT NOT NULL DEFAULT '',
      notas TEXT NOT NULL DEFAULT ''
    )''',
  'CREATE INDEX idx_partidas_fecha ON partidas_leche(fecha_ms DESC)',
  'CREATE INDEX idx_partidas_proveedor ON partidas_leche(proveedor_id)',
  'CREATE INDEX idx_lotes_fecha ON lotes_produccion(fecha_ms DESC)',
  'CREATE INDEX idx_lotes_estado ON lotes_produccion(estado)',
  'CREATE INDEX idx_piezas_lote ON piezas(lote_produccion_id)',
  'CREATE INDEX idx_piezas_estado ON piezas(estado)',
  'CREATE INDEX idx_piezas_ubicacion ON piezas(ubicacion_actual)',
  'CREATE INDEX idx_eventos_pieza ON eventos_curacion(pieza_id)',
  'CREATE INDEX idx_ventas_fecha ON ventas(fecha_ms DESC)',
  'CREATE INDEX idx_temp_fecha ON controles_temperatura(fecha_ms DESC)',
  'CREATE INDEX idx_incidencias_abiertas ON incidencias(cerrada) WHERE cerrada = 0',
];

/// Historial del `onUpgrade`.
const Map<int, CambioEsquema> historialMigracionesQuesera = {
  2: CambioEsquema(tablasNuevas: ['simulaciones_trazabilidad']),
  3: CambioEsquema(tablasNuevas: [
    'terceros',
    'configuraciones_fiscales',
    'apuntes_ingreso',
    'apuntes_gasto',
  ]),
  4: CambioEsquema(tablasNuevas: ['facturas']),
};

/// Esquema esperado en la versión actual (v4).
const Map<String, Set<String>> columnasEsperadasQuesera = {
  'queserias': {
    'id',
    'razon_social',
    'nif',
    'direccion',
    'latitud',
    'longitud',
    'rgseaa',
    'telefono',
    'email',
    'notas',
    'rutas_fotos_json'
  },
  'proveedores_leche': {
    'id',
    'nombre',
    'nif',
    'direccion',
    'explotacion_ganadera',
    'tipo_leche',
    'raza_id',
    'num_animales',
    'es_propio',
    'latitud',
    'longitud',
    'notas',
    'fecha_creacion_ms'
  },
  'partidas_leche': {
    'id',
    'proveedor_id',
    'fecha_ms',
    'volumen_litros',
    'temperatura_recepcion',
    'ph',
    'grasa',
    'proteina',
    'extracto_seco',
    'celulas_somaticas',
    'bacterias',
    'antibioticos_positivos',
    'incidencia',
    'notas'
  },
  'recetas': {
    'id',
    'nombre',
    'tipo_queso_id',
    'do_id',
    'tipo_leche',
    'fermento',
    'tipo_cuajo',
    'temp_coagulacion',
    'tiempo_coag_minutos',
    'tam_cuajada',
    'temp_cocion',
    'ph_salado',
    'rendimiento_esperado',
    'curacion_minima_dias',
    'notas'
  },
  'lotes_produccion': {
    'id',
    'numero_lote',
    'fecha_ms',
    'receta_id',
    'tipo_queso_id',
    'do_id',
    'partidas_leche_usadas_json',
    'volumen_leche_total',
    'peso_total_obtenido',
    'rendimiento_real',
    'num_piezas_producidas',
    'peso_medio_pieza',
    'fermento_nombre',
    'fermento_lote_comercial',
    'cuajo_tipo',
    'cuajo_lote_comercial',
    'sal_lote',
    'temp_coagulacion',
    'tiempo_coag_minutos',
    'ph_cuajada',
    'estado',
    'notas',
    'fecha_creacion_ms'
  },
  'piezas': {
    'id',
    'lote_produccion_id',
    'numero_pieza',
    'peso_inicial',
    'peso_actual',
    'ubicacion_actual',
    'estado',
    'fecha_expedicion_ms',
    'notas',
    'fecha_creacion_ms'
  },
  'eventos_curacion': {
    'id',
    'pieza_id',
    'fecha_ms',
    'tipo',
    'peso_actual',
    'madera_ahumado',
    'notas',
    'fecha_creacion_ms'
  },
  'analiticas': {
    'id',
    'fecha_ms',
    'tipo',
    'laboratorio',
    'lote_produccion_id',
    'parametros_json',
    'conforme',
    'notas'
  },
  'incidencias': {
    'id',
    'fecha_ms',
    'tipo',
    'lote_produccion_id',
    'pieza_id',
    'descripcion',
    'rutas_fotos_json',
    'causa',
    'accion_correctiva',
    'cerrada',
    'fecha_creacion_ms'
  },
  'ventas': {
    'id',
    'fecha_ms',
    'cliente_nombre',
    'cliente_nif',
    'cliente_direccion',
    'tipo',
    'lineas_json',
    'numero_factura',
    'base_imponible',
    'iva_porcentaje',
    'total',
    'rutas_fotos_json',
    'notas',
    'fecha_creacion_ms'
  },
  'controles_temperatura': {
    'id',
    'fecha_ms',
    'cava_id',
    'temperatura',
    'humedad_relativa',
    'responsable',
    'notas'
  },
  'controles_limpieza': {
    'id',
    'fecha_ms',
    'zona',
    'tarea',
    'producto_usado',
    'responsable',
    'verificado',
    'accion_correctiva',
    'notas'
  },
  'controles_plagas': {
    'id',
    'fecha_ms',
    'tipo',
    'medida',
    'responsable',
    'resultado',
    'proxima_revision_ms',
    'notas'
  },
  'formacion': {
    'id',
    'empleado',
    'fecha_ms',
    'tipo',
    'impartido_por',
    'duracion_minutos',
    'documento',
    'notas'
  },
  'simulaciones_trazabilidad': {
    'id',
    'fecha_ms',
    'tipo',
    'elemento_simulado',
    'aleatorio',
    'completa',
    'resumen',
    'resultado_json',
    'tiempo_segundos',
    'realizada_por',
    'firma_inspector',
    'notas',
    'fecha_creacion_ms'
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
    'regimen_iva',
    'regimen_irpf',
    'compensacion_reagp'
  },
  'apuntes_ingreso': {
    'id',
    'fecha_ms',
    'tercero_id',
    'categoria',
    'base_imponible',
    'iva_porcentaje',
    'total',
    'numero_factura',
    'lote_referencia',
    'notas',
    'fecha_creacion_ms'
  },
  'apuntes_gasto': {
    'id',
    'fecha_ms',
    'tercero_id',
    'categoria',
    'base_imponible',
    'iva_porcentaje',
    'total',
    'numero_factura',
    'notas',
    'fecha_creacion_ms'
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
    'fecha_creacion_ms'
  },
};

/// Una fila por tabla v1 con dependencias (FK), en orden.
const Map<String, Map<String, Object?>> filasV1Quesera = {
  'queserias': {'id': 1, 'razon_social': 'Quesería Aralar', 'nif': 'B1'},
  'proveedores_leche': {
    'id': 1,
    'nombre': 'Caserío Goikoa',
    'fecha_creacion_ms': 100,
  },
  'partidas_leche': {
    'id': 1,
    'proveedor_id': 1,
    'fecha_ms': 200,
    'volumen_litros': 300.0,
  },
  'recetas': {'id': 1, 'nombre': 'Idiazabal curado'},
  'lotes_produccion': {
    'id': 1,
    'numero_lote': '20260101-001',
    'fecha_ms': 300,
    'receta_id': 1,
    'partidas_leche_usadas_json': '[1]',
    'fecha_creacion_ms': 300,
  },
  'piezas': {
    'id': 1,
    'lote_produccion_id': 1,
    'numero_pieza': '20260101-001-01',
    'fecha_creacion_ms': 310,
  },
  'eventos_curacion': {
    'id': 1,
    'pieza_id': 1,
    'fecha_ms': 400,
    'tipo': 'volteo',
    'fecha_creacion_ms': 400,
  },
};

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatosQuesera = BaseDatosSoleraQuesera.instancia;

  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatosQuesera.cerrar();
    await entorno.limpiar();
  });

  /// Proveedor → partida → receta → lote, que casi todo cuelga de ahí.
  Future<({int proveedorId, int partidaId, int recetaId, int loteId})>
      crearProduccionMinima() async {
    final proveedorId = await baseDatosQuesera
        .guardarProveedor(ProveedorLeche(nombre: 'Propio', fechaCreacionMs: 1));
    final partidaId = await baseDatosQuesera.guardarPartidaLeche(
        PartidaLeche(proveedorId: proveedorId, fechaMs: 2, volumenLitros: 100));
    final recetaId =
        await baseDatosQuesera.guardarReceta(Receta(nombre: 'Tierno'));
    final loteId = await baseDatosQuesera.guardarLote(LoteProduccion(
      numeroLote:
          await baseDatosQuesera.siguienteNumeroLote(DateTime(2026, 11, 7)),
      fechaMs: 3,
      recetaId: recetaId,
      partidasLecheUsadasJson: '[$partidaId]',
      fechaCreacionMs: 3,
    ));
    return (
      proveedorId: proveedorId,
      partidaId: partidaId,
      recetaId: recetaId,
      loteId: loteId,
    );
  }

  group('(a) singleton', () {
    test('el constructor factory devuelve siempre la misma instancia', () {
      expect(identical(BaseDatosSoleraQuesera(), BaseDatosSoleraQuesera()),
          isTrue);
      expect(
          identical(BaseDatosSoleraQuesera(), BaseDatosSoleraQuesera.instancia),
          isTrue);
    });

    test('la Database se abre una vez y se reutiliza', () async {
      final primera = await baseDatosQuesera.basedatos;
      expect(identical(primera, await baseDatosQuesera.basedatos), isTrue);
    });

    test('dos accesos simultáneos en frío comparten la misma Database',
        () async {
      final accesos = await Future.wait(
          [baseDatosQuesera.basedatos, baseDatosQuesera.basedatos]);
      expect(identical(accesos[0], accesos[1]), isTrue);
    });

    test('cerrar() libera la Database y el siguiente acceso la reabre',
        () async {
      final antes = await baseDatosQuesera.basedatos;
      await baseDatosQuesera.cerrar();
      expect(antes.isOpen, isFalse);
      expect((await baseDatosQuesera.basedatos).isOpen, isTrue);
    });
  });

  group('(b) BD nueva', () {
    test('el fichero se llama solera_quesera.db (sin sufijo de versión)',
        () async {
      final baseDatos = await baseDatosQuesera.basedatos;
      expect(nombreFicheroBaseDatosSoleraQuesera, 'solera_quesera.db');
      expect(baseDatos.path, entorno.ruta('solera_quesera.db'));
      expect(File(entorno.ruta('solera_quesera.db')).existsSync(), isTrue);
    });

    test('llega a la versión actual con todas las tablas y columnas', () async {
      final baseDatos = await baseDatosQuesera.basedatos;
      expect(await baseDatos.getVersion(), versionEsquemaSoleraQuesera);
      expect(versionEsquemaSoleraQuesera, 4);
      expect(await leerColumnasPorTabla(baseDatos), columnasEsperadasQuesera);
    });

    test('el historial declarado reproduce el esquema actual', () async {
      final columnasV1 = await columnasDeEsquemaV1(sentenciasEsquemaV1Quesera);
      expect(
        columnasDeclaradasEnVersion(
          columnasV1: columnasV1,
          historial: historialMigracionesQuesera,
          columnasActuales: columnasEsperadasQuesera,
          version: versionEsquemaSoleraQuesera,
        ),
        columnasEsperadasQuesera,
      );
    });

    test('las claves foráneas están activas (onConfigure)', () async {
      final baseDatos = await baseDatosQuesera.basedatos;
      final filas = await baseDatos.rawQuery('PRAGMA foreign_keys');
      expect(filas.single.values.single, 1);
    });
  });

  group('(c) migraciones desde versiones antiguas', () {
    for (var versionAntigua = 1;
        versionAntigua < versionEsquemaSoleraQuesera;
        versionAntigua++) {
      test('v$versionAntigua → v$versionEsquemaSoleraQuesera sin perder filas',
          () async {
        await crearBaseDatosHistorica(
          ruta: entorno.ruta(nombreFicheroBaseDatosSoleraQuesera),
          version: versionAntigua,
          sentenciasEsquemaV1: sentenciasEsquemaV1Quesera,
          historial: historialMigracionesQuesera,
          columnasActuales: columnasEsperadasQuesera,
          filasPorTabla: filasV1Quesera,
        );

        final baseDatos = await baseDatosQuesera.basedatos;
        expect(await baseDatos.getVersion(), versionEsquemaSoleraQuesera);
        expect(await leerColumnasPorTabla(baseDatos), columnasEsperadasQuesera);
        await comprobarFilasConservadas(baseDatos, filasV1Quesera);
        // La trazabilidad hacia atrás sigue funcionando sobre datos viejos.
        final traza = await baseDatosQuesera.trazarAtras(1);
        expect(traza['lote'], '20260101-001');
        expect((traza['partidas_leche'] as List).single['proveedor'],
            'Caserío Goikoa');
      });
    }

    test('desde v1, el esquema migrado es idéntico al de una BD nueva',
        () async {
      final baseDatosNueva = await baseDatosQuesera.basedatos;
      final detalleNueva = await leerDetalleColumnasPorTabla(baseDatosNueva);
      final indicesNueva = await leerNombresIndices(baseDatosNueva);
      await baseDatosQuesera.cerrar();
      await File(entorno.ruta(nombreFicheroBaseDatosSoleraQuesera)).delete();

      await crearBaseDatosHistorica(
        ruta: entorno.ruta(nombreFicheroBaseDatosSoleraQuesera),
        version: 1,
        sentenciasEsquemaV1: sentenciasEsquemaV1Quesera,
        historial: historialMigracionesQuesera,
        columnasActuales: columnasEsperadasQuesera,
        filasPorTabla: filasV1Quesera,
      );
      final baseDatosMigrada = await baseDatosQuesera.basedatos;
      expect(await leerDetalleColumnasPorTabla(baseDatosMigrada), detalleNueva);
      expect(await leerNombresIndices(baseDatosMigrada), indicesNueva);
    });

    test('reabrir una BD ya actual conserva los datos', () async {
      await crearProduccionMinima();
      await baseDatosQuesera.cerrar();
      final reabierta = await baseDatosQuesera.basedatos;
      expect(await reabierta.getVersion(), versionEsquemaSoleraQuesera);
      expect(await baseDatosQuesera.listarLotes(), hasLength(1));
    });
  });

  group('(d) CRUD por la API pública', () {
    test('quesería y configuración fiscal son de una sola fila (upsert)',
        () async {
      expect((await baseDatosQuesera.obtenerQueseria()).id, isNull);
      await baseDatosQuesera.guardarQueseria(Queseria(razonSocial: 'A'));
      await baseDatosQuesera.guardarQueseria(Queseria(razonSocial: 'B'));
      final baseDatos = await baseDatosQuesera.basedatos;
      expect(await baseDatos.query('queserias'), hasLength(1));
      expect((await baseDatosQuesera.obtenerQueseria()).razonSocial, 'B');

      await baseDatosQuesera.guardarConfiguracionFiscal(
          ConfiguracionFiscal(regimenIva: 'general'));
      await baseDatosQuesera
          .guardarConfiguracionFiscal(ConfiguracionFiscal(regimenIva: 'reagp'));
      expect(await baseDatos.query('configuraciones_fiscales'), hasLength(1));
      expect((await baseDatosQuesera.obtenerConfiguracionFiscal()).regimenIva,
          'reagp');
    });

    test('lote con piezas y curación; borrarlo arrastra piezas y eventos',
        () async {
      final produccion = await crearProduccionMinima();
      final lote = await baseDatosQuesera.obtenerLote(produccion.loteId);
      expect(lote!.numeroLote, '20261107-001');
      expect(await baseDatosQuesera.siguienteNumeroLote(DateTime(2026, 11, 7)),
          '20261107-002');

      await baseDatosQuesera
          .actualizarLote(produccion.loteId, {'estado': 'curando'});
      expect(
          await baseDatosQuesera.listarLotes(estado: 'curando'), hasLength(1));

      final idsPiezas = await baseDatosQuesera.generarPiezasParaLote(
          produccion.loteId, lote.numeroLote, 3, 1.2);
      expect(idsPiezas, hasLength(3));
      await baseDatosQuesera.actualizarPieza(idsPiezas.first, {
        'estado': 'expedida',
      });
      expect(await baseDatosQuesera.contarPiezasPorEstado(),
          {'afinando': 2, 'expedida': 1});
      await baseDatosQuesera.guardarEventoCuracion(EventoCuracion(
          piezaId: idsPiezas.last,
          fechaMs: 5,
          tipo: 'volteo',
          fechaCreacionMs: 5));
      expect(await baseDatosQuesera.listarEventosDePieza(idsPiezas.last),
          hasLength(1));

      await baseDatosQuesera.borrarPieza(idsPiezas.first);
      expect(await baseDatosQuesera.obtenerPieza(idsPiezas.first), isNull);

      await baseDatosQuesera.borrarLote(produccion.loteId);
      expect(await baseDatosQuesera.obtenerLote(produccion.loteId), isNull);
      expect(await baseDatosQuesera.listarPiezas(), isEmpty);
      expect(
          await baseDatosQuesera.listarEventosDePieza(idsPiezas.last), isEmpty);
    });

    test('una receta con lotes no se puede borrar (ON DELETE RESTRICT)',
        () async {
      final produccion = await crearProduccionMinima();
      await baseDatosQuesera
          .actualizarReceta(produccion.recetaId, {'curacion_minima_dias': 90});
      expect(
          (await baseDatosQuesera.obtenerReceta(produccion.recetaId))!
              .curacionMinimaDias,
          90);
      expect(() => baseDatosQuesera.borrarReceta(produccion.recetaId),
          throwsA(isA<DatabaseException>()));
    });

    test('editar un proveedor guarda su punto sin duplicarlo', () async {
      final id = await baseDatosQuesera.guardarProveedor(
          ProveedorLeche(nombre: 'Caserío', fechaCreacionMs: 1));
      final original = (await baseDatosQuesera.obtenerProveedor(id))!;
      await baseDatosQuesera.actualizarProveedor(ProveedorLeche(
        id: original.id,
        nombre: original.nombre,
        latitud: 43.1,
        longitud: -2.2,
        fechaCreacionMs: original.fechaCreacionMs,
      ));
      final proveedores = await baseDatosQuesera.listarProveedores();
      expect(proveedores, hasLength(1));
      expect(proveedores.single.latitud, 43.1);
      expect(proveedores.single.longitud, -2.2);
    });

    test('borrar el proveedor arrastra sus partidas de leche (CASCADE)',
        () async {
      final produccion = await crearProduccionMinima();
      expect(
          (await baseDatosQuesera.obtenerPartidaLeche(produccion.partidaId))!
              .volumenLitros,
          100);
      await baseDatosQuesera.borrarLote(produccion.loteId);
      await baseDatosQuesera.borrarProveedor(produccion.proveedorId);
      expect(await baseDatosQuesera.obtenerProveedor(produccion.proveedorId),
          isNull);
      expect(await baseDatosQuesera.obtenerPartidaLeche(produccion.partidaId),
          isNull);
    });

    test('incidencias: alta, cierre y filtro de abiertas', () async {
      final idIncidencia = await baseDatosQuesera.guardarIncidencia(
          Incidencia(fechaMs: 1, tipo: 'temperatura', fechaCreacionMs: 1));
      expect(await baseDatosQuesera.listarIncidencias(soloAbiertas: true),
          hasLength(1));
      await baseDatosQuesera.actualizarIncidencia(idIncidencia, {'cerrada': 1});
      expect(await baseDatosQuesera.listarIncidencias(soloAbiertas: true),
          isEmpty);
      expect(await baseDatosQuesera.listarIncidencias(), hasLength(1));
    });

    test('simulaciones de trazabilidad (v2)', () async {
      final idSimulacion = await baseDatosQuesera.guardarSimulacion(
          SimulacionTrazabilidad(
              fechaMs: 1,
              tipo: 'atras',
              elementoSimulado: 'lote 1',
              fechaCreacionMs: 1));
      await baseDatosQuesera
          .actualizarSimulacion(idSimulacion, {'completa': 1});
      expect((await baseDatosQuesera.obtenerSimulacion(idSimulacion))!.completa,
          isTrue);
      expect(await baseDatosQuesera.contarSimulaciones(0, 10), 1);
      await baseDatosQuesera.borrarSimulacion(idSimulacion);
      expect(await baseDatosQuesera.listarSimulaciones(), isEmpty);
    });

    test('terceros e ingresos (v3)', () async {
      final idTercero = await baseDatosQuesera
          .guardarTercero(Tercero(nombre: 'Tienda', tipo: 'cliente'));
      expect(
          (await baseDatosQuesera.obtenerTercero(idTercero))!.nombre, 'Tienda');
      expect(
          await baseDatosQuesera.listarTerceros(tipo: 'cliente'), hasLength(1));
      await baseDatosQuesera.guardarIngreso(ApunteIngreso(
          fechaMs: 5, terceroId: idTercero, total: 121, fechaCreacionMs: 5));
      expect(await baseDatosQuesera.totalIngresosPeriodo(0, 10), 121);
      await baseDatosQuesera.borrarTercero(idTercero);
      expect(await baseDatosQuesera.listarTerceros(), isEmpty);
      // apuntes_ingreso.tercero_id no tiene FK: el apunte se queda con el id.
      expect((await baseDatosQuesera.listarIngresos()).single.terceroId,
          idTercero);
    });

    test('facturas (sin API: SQL directo)', () async {
      final baseDatos = await baseDatosQuesera.basedatos;
      final idFactura = await baseDatos.insert('facturas', {
        'numero_factura': '2026-001',
        'fecha_emision_ms': 1,
        'fecha_creacion_ms': 1,
      });
      expect((await baseDatos.query('facturas')).single['estado'], 'emitida');
      await baseDatos
          .delete('facturas', where: 'id = ?', whereArgs: [idFactura]);
      expect(await baseDatos.query('facturas'), isEmpty);
    });
  });
}
