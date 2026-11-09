// Contrato de la base de datos de Larrea Arbolado Urbano.
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
//   * Las migraciones viven en el `onUpgrade` (no hay `_aplicarMigraciones`).
//   * Los eventos (inspecciones, podas, tratamientos) y los técnicos no
//     tienen API de borrado, y no hay borrado de incidencias: las cascadas se
//     prueban borrando el árbol. `facturas` (v2) no tiene API: SQL directo.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart' show codificarContorno;
import 'package:solera_arbolado_urbano/datos/base_datos.dart';
import 'package:solera_arbolado_urbano/modelos/arbol.dart';
import 'package:solera_arbolado_urbano/modelos/incidencia.dart';
import 'package:solera_arbolado_urbano/modelos/inspeccion.dart';
import 'package:solera_arbolado_urbano/modelos/poda.dart';
import 'package:solera_arbolado_urbano/modelos/tecnico.dart';
import 'package:solera_arbolado_urbano/modelos/tratamiento.dart';
import 'package:solera_arbolado_urbano/modelos/zona.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'soporte_contrato_base_datos.dart';

/// Esquema v1 literal: copia de `_crearEsquemaInicial`.
const List<String> sentenciasEsquemaV1Arbolado = [
  '''
    CREATE TABLE zonas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      codigo_municipal TEXT NOT NULL DEFAULT '',
      latitud_centroide REAL,
      longitud_centroide REAL,
      color_entero INTEGER NOT NULL DEFAULT 3050327,
      notas TEXT NOT NULL DEFAULT '',
      fecha_creacion_ms INTEGER NOT NULL
    )''',
  '''
    CREATE TABLE arboles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      zona_id INTEGER,
      identificador_municipal TEXT NOT NULL UNIQUE,
      qr_payload TEXT NOT NULL DEFAULT '',
      especie_id TEXT NOT NULL DEFAULT '',
      edad_estimada_anos INTEGER,
      fecha_plantacion_ms INTEGER,
      perimetro_tronco_cm REAL,
      altura_estimada_metros REAL,
      riesgo_vta INTEGER,
      estado TEXT NOT NULL DEFAULT 'sano',
      tipo_alcorque_id TEXT NOT NULL DEFAULT '',
      latitud REAL,
      longitud REAL,
      notas TEXT NOT NULL DEFAULT '',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      fecha_creacion_ms INTEGER NOT NULL,
      FOREIGN KEY (zona_id) REFERENCES zonas(id) ON DELETE SET NULL
    )''',
  'CREATE INDEX idx_arboles_zona ON arboles (zona_id)',
  'CREATE INDEX idx_arboles_estado ON arboles (estado)',
  'CREATE INDEX idx_arboles_identificador ON arboles (identificador_municipal)',
  'CREATE INDEX idx_arboles_qr ON arboles (qr_payload)',
  '''
    CREATE TABLE inspecciones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      arbol_id INTEGER NOT NULL,
      tecnico_id INTEGER,
      fecha_ms INTEGER NOT NULL,
      estado TEXT NOT NULL DEFAULT 'sano',
      riesgo_vta INTEGER,
      fenologia TEXT NOT NULL DEFAULT '',
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (arbol_id) REFERENCES arboles(id) ON DELETE CASCADE,
      FOREIGN KEY (tecnico_id) REFERENCES tecnicos(id) ON DELETE SET NULL
    )''',
  'CREATE INDEX idx_inspecciones_arbol_fecha ON inspecciones (arbol_id, fecha_ms DESC)',
  '''
    CREATE TABLE podas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      arbol_id INTEGER NOT NULL,
      tecnico_id INTEGER,
      fecha_ms INTEGER NOT NULL,
      tipo_poda_id TEXT NOT NULL DEFAULT '',
      volumen_restos_m3 REAL,
      motivo TEXT NOT NULL DEFAULT '',
      rutas_fotos_antes_json TEXT NOT NULL DEFAULT '[]',
      rutas_fotos_despues_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (arbol_id) REFERENCES arboles(id) ON DELETE CASCADE,
      FOREIGN KEY (tecnico_id) REFERENCES tecnicos(id) ON DELETE SET NULL
    )''',
  'CREATE INDEX idx_podas_arbol_fecha ON podas (arbol_id, fecha_ms DESC)',
  '''
    CREATE TABLE tratamientos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      arbol_id INTEGER NOT NULL,
      tecnico_id INTEGER,
      fecha_ms INTEGER NOT NULL,
      sustancia_activa_id TEXT NOT NULL DEFAULT '',
      dosis TEXT NOT NULL DEFAULT '',
      motivo_id_plaga TEXT NOT NULL DEFAULT '',
      lote_producto TEXT NOT NULL DEFAULT '',
      numero_factura TEXT NOT NULL DEFAULT '',
      plazo_seguridad_dias INTEGER,
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (arbol_id) REFERENCES arboles(id) ON DELETE CASCADE,
      FOREIGN KEY (tecnico_id) REFERENCES tecnicos(id) ON DELETE SET NULL
    )''',
  'CREATE INDEX idx_tratamientos_arbol_fecha ON tratamientos (arbol_id, fecha_ms DESC)',
  '''
    CREATE TABLE incidencias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      arbol_id INTEGER NOT NULL,
      tecnico_id INTEGER,
      fecha_ms INTEGER NOT NULL,
      tipo TEXT NOT NULL DEFAULT 'otro',
      descripcion TEXT NOT NULL DEFAULT '',
      severidad INTEGER,
      resuelta INTEGER NOT NULL DEFAULT 0,
      fecha_resolucion_ms INTEGER,
      rutas_fotos_json TEXT NOT NULL DEFAULT '[]',
      notas TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (arbol_id) REFERENCES arboles(id) ON DELETE CASCADE,
      FOREIGN KEY (tecnico_id) REFERENCES tecnicos(id) ON DELETE SET NULL
    )''',
  'CREATE INDEX idx_incidencias_arbol_fecha ON incidencias (arbol_id, fecha_ms DESC)',
  'CREATE INDEX idx_incidencias_abiertas ON incidencias (resuelta, fecha_ms DESC)',
  '''
    CREATE TABLE tecnicos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nif TEXT NOT NULL DEFAULT '',
      nombre TEXT NOT NULL DEFAULT '',
      empresa_contratista TEXT NOT NULL DEFAULT '',
      cif_empresa TEXT NOT NULL DEFAULT '',
      telefono TEXT NOT NULL DEFAULT '',
      email TEXT NOT NULL DEFAULT '',
      carnet_aplicador TEXT NOT NULL DEFAULT '',
      nivel_carnet_aplicador TEXT NOT NULL DEFAULT '',
      activo INTEGER NOT NULL DEFAULT 1
    )''',
  '''
    CREATE TABLE ayuntamientos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL DEFAULT '',
      cif TEXT NOT NULL DEFAULT '',
      direccion TEXT NOT NULL DEFAULT '',
      municipio TEXT NOT NULL DEFAULT '',
      provincia TEXT NOT NULL DEFAULT '',
      codigo_postal TEXT NOT NULL DEFAULT '',
      nombre_concejal TEXT NOT NULL DEFAULT '',
      concejalia TEXT NOT NULL DEFAULT '',
      email TEXT NOT NULL DEFAULT '',
      telefono TEXT NOT NULL DEFAULT ''
    )''',
];

/// Historial de migraciones: facturas en v2 y el área de la zona en v3.
const Map<int, CambioEsquema> historialMigracionesArbolado = {
  2: CambioEsquema(tablasNuevas: ['facturas']),
  3: CambioEsquema(columnasNuevas: {
    'zonas': ['contorno'],
  }),
};

/// Esquema esperado en la versión actual (v3).
const Map<String, Set<String>> columnasEsperadasArbolado = {
  'zonas': {
    'id',
    'nombre',
    'codigo_municipal',
    'latitud_centroide',
    'longitud_centroide',
    'color_entero',
    'notas',
    'fecha_creacion_ms',
    'contorno'
  },
  'arboles': {
    'id',
    'zona_id',
    'identificador_municipal',
    'qr_payload',
    'especie_id',
    'edad_estimada_anos',
    'fecha_plantacion_ms',
    'perimetro_tronco_cm',
    'altura_estimada_metros',
    'riesgo_vta',
    'estado',
    'tipo_alcorque_id',
    'latitud',
    'longitud',
    'notas',
    'rutas_fotos_json',
    'fecha_creacion_ms'
  },
  'inspecciones': {
    'id',
    'arbol_id',
    'tecnico_id',
    'fecha_ms',
    'estado',
    'riesgo_vta',
    'fenologia',
    'rutas_fotos_json',
    'notas'
  },
  'podas': {
    'id',
    'arbol_id',
    'tecnico_id',
    'fecha_ms',
    'tipo_poda_id',
    'volumen_restos_m3',
    'motivo',
    'rutas_fotos_antes_json',
    'rutas_fotos_despues_json',
    'notas'
  },
  'tratamientos': {
    'id',
    'arbol_id',
    'tecnico_id',
    'fecha_ms',
    'sustancia_activa_id',
    'dosis',
    'motivo_id_plaga',
    'lote_producto',
    'numero_factura',
    'plazo_seguridad_dias',
    'rutas_fotos_json',
    'notas'
  },
  'incidencias': {
    'id',
    'arbol_id',
    'tecnico_id',
    'fecha_ms',
    'tipo',
    'descripcion',
    'severidad',
    'resuelta',
    'fecha_resolucion_ms',
    'rutas_fotos_json',
    'notas'
  },
  'tecnicos': {
    'id',
    'nif',
    'nombre',
    'empresa_contratista',
    'cif_empresa',
    'telefono',
    'email',
    'carnet_aplicador',
    'nivel_carnet_aplicador',
    'activo'
  },
  'ayuntamientos': {
    'id',
    'nombre',
    'cif',
    'direccion',
    'municipio',
    'provincia',
    'codigo_postal',
    'nombre_concejal',
    'concejalia',
    'email',
    'telefono'
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
const Map<String, Map<String, Object?>> filasV1Arbolado = {
  'zonas': {'id': 1, 'nombre': 'Parque Norte', 'fecha_creacion_ms': 100},
  'tecnicos': {'id': 1, 'nombre': 'Ane', 'nif': '1A'},
  'arboles': {
    'id': 1,
    'zona_id': 1,
    'identificador_municipal': 'PN-0001',
    'qr_payload': 'qr:PN-0001',
    'fecha_creacion_ms': 200,
  },
  'inspecciones': {'id': 1, 'arbol_id': 1, 'tecnico_id': 1, 'fecha_ms': 300},
  'podas': {'id': 1, 'arbol_id': 1, 'fecha_ms': 310},
  'tratamientos': {'id': 1, 'arbol_id': 1, 'fecha_ms': 320},
  'incidencias': {'id': 1, 'arbol_id': 1, 'fecha_ms': 330},
  'ayuntamientos': {'id': 1, 'nombre': 'Ayuntamiento de Prueba'},
};

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatosArbolado = BaseDatosSoleraArbolado.instancia;

  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatosArbolado.cerrar();
    await entorno.limpiar();
  });

  group('(a) singleton', () {
    test('el constructor factory devuelve siempre la misma instancia', () {
      expect(identical(BaseDatosSoleraArbolado(), BaseDatosSoleraArbolado()),
          isTrue);
      expect(
          identical(
              BaseDatosSoleraArbolado(), BaseDatosSoleraArbolado.instancia),
          isTrue);
    });

    test('la Database se abre una vez y se reutiliza', () async {
      final primera = await baseDatosArbolado.basedatos;
      expect(identical(primera, await baseDatosArbolado.basedatos), isTrue);
    });

    test('dos accesos simultáneos en frío comparten la misma Database',
        () async {
      final accesos = await Future.wait(
          [baseDatosArbolado.basedatos, baseDatosArbolado.basedatos]);
      expect(identical(accesos[0], accesos[1]), isTrue);
    });

    test('cerrar() libera la Database y el siguiente acceso la reabre',
        () async {
      final antes = await baseDatosArbolado.basedatos;
      await baseDatosArbolado.cerrar();
      expect(antes.isOpen, isFalse);
      expect((await baseDatosArbolado.basedatos).isOpen, isTrue);
    });
  });

  group('(b) BD nueva', () {
    test('el fichero se llama solera_arbolado_urbano.db (sin sufijo)',
        () async {
      final baseDatos = await baseDatosArbolado.basedatos;
      expect(nombreFicheroBaseDatosArbolado, 'solera_arbolado_urbano.db');
      expect(baseDatos.path, entorno.ruta('solera_arbolado_urbano.db'));
      expect(
          File(entorno.ruta('solera_arbolado_urbano.db')).existsSync(), isTrue);
    });

    test('llega a la versión actual con todas las tablas y columnas', () async {
      final baseDatos = await baseDatosArbolado.basedatos;
      expect(await baseDatos.getVersion(), versionEsquemaArbolado);
      expect(versionEsquemaArbolado, 3);
      expect(await leerColumnasPorTabla(baseDatos), columnasEsperadasArbolado);
    });

    test('el historial declarado reproduce el esquema actual', () async {
      final columnasV1 = await columnasDeEsquemaV1(sentenciasEsquemaV1Arbolado);
      expect(
        columnasDeclaradasEnVersion(
          columnasV1: columnasV1,
          historial: historialMigracionesArbolado,
          columnasActuales: columnasEsperadasArbolado,
          version: versionEsquemaArbolado,
        ),
        columnasEsperadasArbolado,
      );
    });

    test('las claves foráneas están activas (onConfigure)', () async {
      final baseDatos = await baseDatosArbolado.basedatos;
      final filas = await baseDatos.rawQuery('PRAGMA foreign_keys');
      expect(filas.single.values.single, 1);
    });
  });

  group('(c) migraciones desde versiones antiguas', () {
    for (var versionAntigua = 1;
        versionAntigua < versionEsquemaArbolado;
        versionAntigua++) {
      test('v$versionAntigua → v$versionEsquemaArbolado sin perder filas',
          () async {
        await crearBaseDatosHistorica(
          ruta: entorno.ruta(nombreFicheroBaseDatosArbolado),
          version: versionAntigua,
          sentenciasEsquemaV1: sentenciasEsquemaV1Arbolado,
          historial: historialMigracionesArbolado,
          columnasActuales: columnasEsperadasArbolado,
          filasPorTabla: filasV1Arbolado,
        );

        final baseDatos = await baseDatosArbolado.basedatos;
        expect(await baseDatos.getVersion(), versionEsquemaArbolado);
        expect(
            await leerColumnasPorTabla(baseDatos), columnasEsperadasArbolado);
        await comprobarFilasConservadas(baseDatos, filasV1Arbolado);
        expect(
            (await baseDatosArbolado.obtenerArbolPorQrPayload('qr:PN-0001'))!
                .id,
            1);
        // La zona migrada llega sin área.
        expect((await baseDatosArbolado.listarZonas()).single.contorno, '[]');
      });
    }

    test('desde v1, el esquema migrado es idéntico al de una BD nueva',
        () async {
      final baseDatosNueva = await baseDatosArbolado.basedatos;
      final detalleNueva = await leerDetalleColumnasPorTabla(baseDatosNueva);
      final indicesNueva = await leerNombresIndices(baseDatosNueva);
      await baseDatosArbolado.cerrar();
      await File(entorno.ruta(nombreFicheroBaseDatosArbolado)).delete();

      await crearBaseDatosHistorica(
        ruta: entorno.ruta(nombreFicheroBaseDatosArbolado),
        version: 1,
        sentenciasEsquemaV1: sentenciasEsquemaV1Arbolado,
        historial: historialMigracionesArbolado,
        columnasActuales: columnasEsperadasArbolado,
        filasPorTabla: filasV1Arbolado,
      );
      final baseDatosMigrada = await baseDatosArbolado.basedatos;
      expect(await leerDetalleColumnasPorTabla(baseDatosMigrada), detalleNueva);
      expect(await leerNombresIndices(baseDatosMigrada), indicesNueva);
    });

    test('reabrir una BD ya actual conserva los datos', () async {
      await baseDatosArbolado
          .guardarZona(Zona(nombre: 'Prueba', fechaCreacionMs: 1));
      await baseDatosArbolado.cerrar();
      final reabierta = await baseDatosArbolado.basedatos;
      expect(await reabierta.getVersion(), versionEsquemaArbolado);
      expect((await baseDatosArbolado.listarZonas()).single.nombre, 'Prueba');
    });
  });

  group('(d) CRUD por la API pública', () {
    test('zonas: alta, lectura, cambio y baja que desasocia árboles', () async {
      final idZona = await baseDatosArbolado
          .guardarZona(Zona(nombre: 'Alameda', fechaCreacionMs: 1));
      await baseDatosArbolado
          .actualizarZona(idZona, {'codigo_municipal': 'Z-7'});
      expect((await baseDatosArbolado.obtenerZona(idZona))!.codigoMunicipal,
          'Z-7');
      final idArbol = await baseDatosArbolado.guardarArbol(Arbol(
          zonaId: idZona, identificadorMunicipal: 'AL-1', fechaCreacionMs: 2));
      expect(
          await baseDatosArbolado.listarArboles(zonaId: idZona), hasLength(1));

      await baseDatosArbolado.borrarZona(idZona);
      expect(await baseDatosArbolado.obtenerZona(idZona), isNull);
      expect((await baseDatosArbolado.obtenerArbol(idArbol))!.zonaId, isNull);
    });

    test('el área de una zona se guarda, se cambia y se lee', () async {
      const area = [
        LatLng(42.0, -1.0),
        LatLng(42.0, -0.999),
        LatLng(42.001, -0.999),
      ];
      final idZona = await baseDatosArbolado.guardarZona(Zona(
          nombre: 'Barrio Viejo',
          fechaCreacionMs: 1,
          contorno: codificarContorno(area)));
      expect((await baseDatosArbolado.obtenerZona(idZona))!.vertices, area);
      await baseDatosArbolado.actualizarZona(idZona, {'contorno': '[]'});
      expect((await baseDatosArbolado.obtenerZona(idZona))!.vertices, isEmpty);
    });

    test('árboles: identificador municipal único y búsquedas', () async {
      final idArbol = await baseDatosArbolado.guardarArbol(Arbol(
          identificadorMunicipal: 'X-1',
          qrPayload: 'qr:X-1',
          fechaCreacionMs: 1));
      await baseDatosArbolado.actualizarArbol(idArbol, {'estado': 'riesgo'});
      expect(await baseDatosArbolado.contarArbolesPorEstado(), {'riesgo': 1});
      expect(
          (await baseDatosArbolado
                  .obtenerArbolPorIdentificadorMunicipal('X-1'))!
              .id,
          idArbol);
      // Un payload vacío nunca casa (árboles sin chapa QR).
      expect(await baseDatosArbolado.obtenerArbolPorQrPayload(''), isNull);
      expect(
        () => baseDatosArbolado.guardarArbol(
            Arbol(identificadorMunicipal: 'X-1', fechaCreacionMs: 2)),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('eventos del árbol; borrarlo los arrastra (CASCADE)', () async {
      final idTecnico =
          await baseDatosArbolado.guardarTecnico(Tecnico(nombre: 'Iker'));
      final idArbol = await baseDatosArbolado.guardarArbol(
          Arbol(identificadorMunicipal: 'E-1', fechaCreacionMs: 1));
      await baseDatosArbolado.guardarInspeccion(
          Inspeccion(arbolId: idArbol, tecnicoId: idTecnico, fechaMs: 2));
      await baseDatosArbolado.guardarPoda(Poda(arbolId: idArbol, fechaMs: 3));
      await baseDatosArbolado
          .guardarTratamiento(Tratamiento(arbolId: idArbol, fechaMs: 4));
      final idIncidencia = await baseDatosArbolado
          .guardarIncidencia(Incidencia(arbolId: idArbol, fechaMs: 5));
      expect((await baseDatosArbolado.listarIncidenciasAbiertas()).single.id,
          idIncidencia);
      await baseDatosArbolado
          .actualizarIncidencia(idIncidencia, {'resuelta': 1});
      expect(await baseDatosArbolado.listarIncidenciasAbiertas(), isEmpty);

      await baseDatosArbolado.borrarArbol(idArbol);
      expect(await baseDatosArbolado.obtenerArbol(idArbol), isNull);
      expect(
          await baseDatosArbolado.listarInspeccionesDeArbol(idArbol), isEmpty);
      expect(await baseDatosArbolado.listarPodasDeArbol(idArbol), isEmpty);
      expect(
          await baseDatosArbolado.listarTratamientosDeArbol(idArbol), isEmpty);
      expect(
          await baseDatosArbolado.listarIncidenciasDeArbol(idArbol), isEmpty);
      // El técnico no depende del árbol.
      expect(
          (await baseDatosArbolado.obtenerTecnico(idTecnico))!.nombre, 'Iker');
    });

    test('técnicos: alta, cambio y filtro de activos', () async {
      final idTecnico =
          await baseDatosArbolado.guardarTecnico(Tecnico(nombre: 'Miren'));
      expect(await baseDatosArbolado.listarTecnicos(soloActivos: true),
          hasLength(1));
      await baseDatosArbolado.actualizarTecnico(idTecnico, {'activo': 0});
      expect(
          await baseDatosArbolado.listarTecnicos(soloActivos: true), isEmpty);
      expect(await baseDatosArbolado.listarTecnicos(), hasLength(1));
    });

    test('ayuntamiento de una sola fila (upsert)', () async {
      expect((await baseDatosArbolado.obtenerAyuntamiento()).id, isNull);
      await baseDatosArbolado.guardarAyuntamiento(Ayuntamiento(nombre: 'A'));
      await baseDatosArbolado.guardarAyuntamiento(Ayuntamiento(nombre: 'B'));
      final baseDatos = await baseDatosArbolado.basedatos;
      expect(await baseDatos.query('ayuntamientos'), hasLength(1));
      expect((await baseDatosArbolado.obtenerAyuntamiento()).nombre, 'B');
    });

    test('facturas (sin API: SQL directo)', () async {
      final baseDatos = await baseDatosArbolado.basedatos;
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
