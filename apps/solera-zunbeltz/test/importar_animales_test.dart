// Importar y exportar el ganado en hojas de cálculo: lectura de CSV y
// XLSX (BOM, `;` y `,`, Latin-1), cabeceras en castellano y en euskera,
// fechas y crotales a la española, qué se crea, qué se actualiza y qué
// falla, permisos como en el servidor, y la vuelta exportar → importar.

import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/modelos/ganado.dart';
import 'package:solera_zunbeltz/modelos/persona_espacio.dart';
import 'package:solera_zunbeltz/servicios/exportar_ganado.dart';
import 'package:solera_zunbeltz/servicios/generador_libro_explotacion.dart';
import 'package:solera_zunbeltz/servicios/politica_espacio.dart';
import 'package:solera_zunbeltz/utiles/importar_animales.dart';
import 'package:solera_zunbeltz/utiles/leer_tabla.dart';

import 'bd_en_memoria.dart';

final hoy = DateTime(2026, 10, 23);

PoliticaEspacio politicaDe(String uid, Set<String> capacidades) =>
    PoliticaEspacio(SesionEspacio(
        persona: PersonaEspacio(uid: uid, nombre: uid),
        capacidades: capacidades));

final coordinacion = politicaDe(
    'coord', {capacidadRegistrarGanado, capacidadGestionarGanado});
final tester = politicaDe('ane', {capacidadRegistrarGanado});
final sinGanado = politicaDe('mirona', const {});

final lotes = [
  LoteGanado(id: 1, nombre: 'Ovejas de Ane', especie: 'ovino'),
  LoteGanado(id: 2, nombre: 'Vacas pirenaicas', especie: 'vacuno'),
  LoteGanado(
      id: 3, nombre: 'Cerdos 2025', especie: 'porcino', estado: 'cerrado'),
];

AnalisisImportacion analizar(String contenido,
        {List<Animal> existentes = const [],
        PoliticaEspacio politica = const PoliticaEspacio(null)}) =>
    analizarImportacionAnimales(
      tabla: leerTablaDeFichero('animales.csv', utf8.encode(contenido)),
      existentes: existentes,
      lotes: lotes,
      politica: politica,
      hoy: hoy,
    );

List<int> xlsxDePrueba() {
  final archivo = Archive();
  void anadir(String ruta, String contenido) {
    final bytes = utf8.encode(contenido);
    archivo.addFile(ArchiveFile(ruta, bytes.length, bytes));
  }

  anadir('xl/workbook.xml',
      '<workbook xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="Animaliak" sheetId="1" r:id="rId7"/></sheets></workbook>');
  anadir('xl/_rels/workbook.xml.rels',
      '<Relationships><Relationship Id="rId7" Target="worksheets/hoja.xml"/></Relationships>');
  anadir('xl/sharedStrings.xml',
      '<sst><si><t>Krotala</t></si><si><t>Izena</t></si><si><t>Jaiotza</t></si><si><r><t>Mo</t></r><r><t>rena</t></r></si></sst>');
  anadir('xl/worksheets/hoja.xml',
      '<worksheet><sheetData>'
      '<row r="1"><c r="A1" t="s"><v>0</v></c><c r="B1" t="s"><v>1</v></c><c r="D1" t="s"><v>2</v></c></row>'
      // Crotal como número (Excel se come el cero), sin columna C, fecha
      // como número de serie.
      '<row r="2"><c r="A2"><v>12345678901</v></c><c r="B2" t="s"><v>3</v></c><c r="D2"><v>45953</v></c></row>'
      '<row r="3"><c r="A3" t="inlineStr"><is><t>ES098765432109</t></is></c></row>'
      '</sheetData></worksheet>');
  return ZipEncoder().encode(archivo)!;
}

void main() {
  group('lectura de la hoja', () {
    test('CSV con BOM, punto y coma y CRLF', () {
      final tabla = leerTablaDeFichero(
          'a.csv', utf8.encode('﻿Crotal;Nombre\r\nES012345678901;Morena\r\n'));
      expect(tabla.cabecera, ['Crotal', 'Nombre']);
      expect(tabla.filas, [
        ['ES012345678901', 'Morena']
      ]);
    });

    test('CSV con comas y comillas', () {
      final tabla = leerTablaDeFichero('a.csv',
          utf8.encode('Crotal,Notas\nES012345678901,"cojea, revisar"\n'));
      expect(tabla.filas.single, ['ES012345678901', 'cojea, revisar']);
    });

    test('CSV de Excel en Windows-1252 (Latin-1) con eñes y acentos', () {
      final tabla = leerTablaDeFichero(
          'a.csv', latin1.encode('Crotal;Rebaño;Notas\nES012345678901;Ovejas;Cañada\n'));
      expect(tabla.cabecera[1], 'Rebaño');
      expect(tabla.filas.single[2], 'Cañada');
    });

    test('XLSX: primera hoja por sus relaciones, textos y números', () {
      final tabla = leerTablaDeFichero('animales.xlsx', xlsxDePrueba());
      expect(tabla.cabecera, ['Krotala', 'Izena', '', 'Jaiotza']);
      expect(tabla.filas[0], ['12345678901', 'Morena', '', '45953']);
      expect(tabla.filas[1], ['ES098765432109']);
    });

    test('el .xls antiguo no se lee', () {
      expect(() => leerTablaDeFichero('viejo.xls', [0xD0, 0xCF, 0x11, 0xE0]),
          throwsA(isA<HojaNoLegible>()));
    });
  });

  group('columnas', () {
    test('cabeceras en castellano, en euskera y con variantes', () {
      final es = reconocerColumnasAnimal([
        'Crotal / DIB', 'Fecha de nacimiento', 'Madre (crotal)', 'Lote',
        'Fecha de baja', 'Observaciones', 'Peso'
      ]);
      expect(es.indices, {
        ColumnaAnimal.nacimiento: 1,
        ColumnaAnimal.madre: 2,
        ColumnaAnimal.rebano: 3,
        ColumnaAnimal.fechaBaja: 4,
        ColumnaAnimal.notas: 5,
      }..[ColumnaAnimal.crotal] = 0);
      expect(es.ignoradas, ['Peso']);

      final eu = reconocerColumnasAnimal([
        'Krotala', 'Izena', 'Espeziea', 'Arraza', 'Sexua', 'Jaiotza', 'Ama',
        'Taldea', 'Egoera', 'Baja-data', 'Oharrak'
      ]);
      expect(eu.indices.length, ColumnaAnimal.values.length);
      expect(eu.ignoradas, isEmpty);
    });

    test('las cabeceras que exporta la app se reconocen en los dos idiomas',
        () {
      for (final idioma in ['es', 'eu']) {
        final reconocidas = reconocerColumnasAnimal([
          for (final columna in ColumnaAnimal.values)
            cabeceraColumnaAnimal(columna, idioma)
        ]);
        expect(reconocidas.indices.keys.toSet(), ColumnaAnimal.values.toSet(),
            reason: idioma);
      }
    });
  });

  group('fechas', () {
    test('a la española, ISO y número de serie de Excel', () {
      expect(leerFechaHoja('23/10/2026', hoy), DateTime(2026, 10, 23));
      expect(leerFechaHoja('3-2-2024', hoy), DateTime(2024, 2, 3));
      expect(leerFechaHoja('03.02.2024', hoy), DateTime(2024, 2, 3));
      expect(leerFechaHoja('2024-02-03', hoy), DateTime(2024, 2, 3));
      expect(leerFechaHoja('2024-02-03T00:00:00', hoy), DateTime(2024, 2, 3));
      expect(leerFechaHoja('03/02/2024 0:00', hoy), DateTime(2024, 2, 3));
      expect(leerFechaHoja('45953', hoy), DateTime(2025, 10, 23));
      expect(leerFechaHoja('45953,5', hoy), DateTime(2025, 10, 23));
    });

    test('año de dos cifras: este siglo salvo que quede en el futuro', () {
      expect(leerFechaHoja('1/3/24', hoy), DateTime(2024, 3, 1));
      expect(leerFechaHoja('1/3/98', hoy), DateTime(1998, 3, 1));
    });

    test('lo que no es una fecha', () {
      expect(leerFechaHoja('31/02/2024', hoy), isNull);
      expect(leerFechaHoja('13/13/2024', hoy), isNull);
      expect(leerFechaHoja('ayer', hoy), isNull);
      expect(leerFechaHoja('2024', hoy), isNull);
      expect(leerFechaHoja('1.200', hoy), isNull);
    });
  });

  group('crotales', () {
    test('se normalizan como al escanear', () {
      expect(leerCrotalHoja('es 0123 4567 8901').identificacion,
          'ES012345678901');
      expect(leerCrotalHoja('012345678901').identificacion, 'ES012345678901');
      expect(leerCrotalHoja("'012345678901").identificacion, 'ES012345678901');
    });

    test('el cero que Excel se come se repone, con aviso', () {
      final lectura = leerCrotalHoja('12345678901');
      expect(lectura.identificacion, 'ES012345678901');
      expect(lectura.avisos, [MotivoImportacion.avisoCeroRecuperado]);
    });

    test('notación científica: error, se han perdido cifras', () {
      expect(leerCrotalHoja('1,23457E+11').error,
          MotivoImportacion.crotalNumeroExcel);
      expect(leerCrotalHoja('1.23457e11').error,
          MotivoImportacion.crotalNumeroExcel);
    });

    test('lo que no parece oficial se guarda con aviso', () {
      final lectura = leerCrotalHoja('Pinta-7');
      expect(lectura.identificacion, 'PINTA7');
      expect(lectura.error, isNull);
      expect(lectura.avisos, [MotivoImportacion.avisoCrotalNoOficial]);
    });
  });

  group('análisis', () {
    test('crea con lo escrito y la especie del rebaño', () {
      final analisis = analizar(
          'Crotal;Nombre;Sexo;Nacimiento;Rebaño;Raza\n'
          'ES012345678901;Morena;H;01/03/2024;ovejas de ane;Latxa\n',
          politica: tester);
      final fila = analisis.aCrear.single;
      expect(fila.numeroFila, 2);
      final animal = Animal.fromMap(fila.datos);
      expect(animal.identificacion, 'ES012345678901');
      expect(animal.nombre, 'Morena');
      expect(animal.sexo, 'hembra');
      expect(animal.especie, 'ovino');
      expect(animal.raza, 'Latxa');
      expect(animal.loteId, 1);
      expect(animal.fechaNacimientoMs,
          DateTime(2024, 3, 1).millisecondsSinceEpoch);
      expect(animal.estado, estadoAnimalActivo);
      expect(animal.autorUid, 'ane');
    });

    test('etiquetas en euskera y fecha de baja sin estado = baja', () {
      final analisis = analizar(
          'Krotala;Sexua;Espeziea;Baja-data\n'
          'ES012345678901;Arra;Behiak;02/10/2026\n');
      final animal = Animal.fromMap(analisis.aCrear.single.datos);
      expect(animal.sexo, 'macho');
      expect(animal.especie, 'vacuno');
      expect(animal.estado, 'baja');
      expect(animal.fechaBajaMs, DateTime(2026, 10, 2).millisecondsSinceEpoch);
    });

    test('actualiza solo lo escrito; una celda vacía no borra', () {
      final existente = Animal(
          id: 7,
          identificacion: 'ES012345678901',
          nombre: 'Morena',
          raza: 'Latxa',
          loteId: 1,
          autorUid: 'coord');
      final analisis = analizar(
          'Crotal;Nombre;Raza;Rebaño\n012345678901;;Sasi ardi;Vacas pirenaicas\n',
          existentes: [existente],
          politica: coordinacion);
      final fila = analisis.aActualizar.single;
      expect(fila.existente!.id, 7);
      expect(fila.datos, {'raza': 'Sasi ardi', 'lote_id': 2});
    });

    test('igual que lo guardado (misma fecha a otra hora): sin cambios', () {
      final existente = Animal(
          id: 7,
          identificacion: 'ES012345678901',
          nombre: 'Morena',
          fechaNacimientoMs:
              DateTime(2024, 3, 1, 15, 30).millisecondsSinceEpoch);
      final analisis = analizar(
          'Crotal;Nombre;Nacimiento\nES012345678901;Morena;01/03/2024\n',
          existentes: [existente]);
      expect(analisis.sinCambios.single.existente!.id, 7);
      expect(analisis.hayAlgoQueGuardar, isFalse);
    });

    test('filas que fallan y por qué', () {
      final analisis = analizar(
          'Crotal;Nacimiento;Sexo;Rebaño;Especie;Estado;Fecha de baja\n'
          ';;;;;;\n' // vacía del todo: se salta
          ';01/01/2024;;;;;\n'
          '1,23457E+11;;;;;;\n'
          'ES000000000001;31/02/2024;;;;;\n'
          'ES000000000002;01/01/2030;;;;;\n'
          'ES000000000003;;X;;;;\n'
          'ES000000000004;;;No existe;;;\n'
          'ES000000000005;;;Cerdos 2025;;;\n'
          'ES000000000006;;;;Jirafa;;\n'
          'ES000000000007;;;;;Perdido;\n'
          'ES000000000008;01/01/2025;;;;;01/01/2024\n'
          'ES000000000009;;;;;;\n'
          'ES000000000009;;;;;;\n');
      final motivos = {
        for (final fila in analisis.conErrores)
          fila.numeroFila: fila.errores.map((e) => e.motivo).toList()
      };
      expect(motivos, {
        3: [MotivoImportacion.crotalVacio],
        4: [MotivoImportacion.crotalNumeroExcel],
        5: [MotivoImportacion.fechaNoValida],
        6: [MotivoImportacion.nacimientoFuturo],
        7: [MotivoImportacion.sexoDesconocido],
        8: [MotivoImportacion.rebanoDesconocido],
        9: [MotivoImportacion.rebanoDesconocido], // cerrado
        10: [MotivoImportacion.especieDesconocida],
        11: [MotivoImportacion.estadoDesconocido],
        12: [MotivoImportacion.bajaAntesDeNacimiento],
        14: [MotivoImportacion.crotalRepetido],
      });
      expect(analisis.aCrear.map((fila) => fila.numeroFila), [13]);
      final fecha = analisis.conErrores
          .firstWhere((fila) => fila.numeroFila == 5)
          .errores
          .single;
      expect(fecha.columna, ColumnaAnimal.nacimiento);
      expect(fecha.valor, '31/02/2024');
    });

    test('sin columna de crotal no se analiza nada', () {
      final analisis = analizar('Nombre;Raza\nMorena;Latxa\n');
      expect(analisis.sinColumnaCrotal, isTrue);
      expect(analisis.filas, isEmpty);
    });

    test('xlsx en euskera con crotal numérico y fecha de serie', () {
      final analisis = analizarImportacionAnimales(
        tabla: leerTablaDeFichero('animaliak.xlsx', xlsxDePrueba()),
        existentes: const [],
        lotes: lotes,
        politica: const PoliticaEspacio(null),
        hoy: hoy,
      );
      expect(analisis.aCrear.length, 2);
      final morena = Animal.fromMap(analisis.aCrear.first.datos);
      expect(morena.identificacion, 'ES012345678901');
      expect(morena.nombre, 'Morena');
      expect(morena.fechaNacimientoMs,
          DateTime(2025, 10, 23).millisecondsSinceEpoch);
      expect(analisis.aCrear.first.avisos.single.motivo,
          MotivoImportacion.avisoCeroRecuperado);
    });
  });

  group('permisos', () {
    final ajeno = Animal(
        id: 1,
        identificacion: 'ES012345678901',
        nombre: 'Morena',
        loteId: 1,
        autorUid: 'coord');
    final propio = Animal(
        id: 2, identificacion: 'ES012345678902', nombre: 'Beltza',
        autorUid: 'ane');

    test('quien no registra ganado no da altas', () {
      final analisis =
          analizar('Crotal\nES012345678909\n', politica: sinGanado);
      expect(analisis.conErrores.single.errores.single.motivo,
          MotivoImportacion.sinPermisoAlta);
    });

    test('tester: a un animal ajeno solo rebaño, baja y notas', () {
      final manejo = analizar(
          'Crotal;Rebaño;Estado;Fecha de baja;Notas\n'
          'ES012345678901;Vacas pirenaicas;Vendido;20/10/2026;a Urbasa\n',
          existentes: [ajeno, propio],
          politica: tester);
      expect(manejo.aActualizar.single.datos.keys.toSet(),
          {'lote_id', 'estado', 'fecha_baja_ms', 'notas'});

      final ficha = analizar('Crotal;Nombre\nES012345678901;Gorria\n',
          existentes: [ajeno, propio], politica: tester);
      expect(ficha.conErrores.single.errores.single.motivo,
          MotivoImportacion.sinPermisoFicha);
    });

    test('tester cambia la ficha de lo suyo; coordinación, todo', () {
      expect(
          analizar('Crotal;Nombre\nES012345678902;Gorria\n',
                  existentes: [ajeno, propio], politica: tester)
              .aActualizar
              .length,
          1);
      expect(
          analizar('Crotal;Nombre\nES012345678901;Gorria\n',
                  existentes: [ajeno, propio], politica: coordinacion)
              .aActualizar
              .length,
          1);
    });

    test('volver a estar en el espacio quita la fecha de baja', () {
      final vendido = Animal(
          id: 3,
          identificacion: 'ES012345678903',
          estado: 'vendido',
          fechaBajaMs: DateTime(2026, 1, 1).millisecondsSinceEpoch);
      final analisis = analizar('Crotal;Estado\nES012345678903;En el espacio\n',
          existentes: [vendido]);
      expect(analisis.aActualizar.single.datos,
          {'estado': estadoAnimalActivo, 'fecha_baja_ms': null});
    });
  });

  group('exportación', () {
    final datos = DatosGanado(
      lotes: lotes,
      animales: [
        Animal(
            id: 1,
            identificacion: 'ES012345678901',
            nombre: 'Morena; la "jefa"',
            especie: 'ovino',
            raza: 'Latxa',
            sexo: 'hembra',
            fechaNacimientoMs: DateTime(2024, 3, 1).millisecondsSinceEpoch,
            madre: 'ES012345678900',
            loteId: 1,
            notas: '=cojea\nrevisar'),
        Animal(
            id: 2,
            identificacion: 'ES012345678902',
            loteId: 2,
            estado: 'vendido',
            fechaBajaMs: DateTime(2026, 10, 2).millisecondsSinceEpoch),
      ],
      movimientos: [
        MovimientoGanado(
            id: 1,
            loteId: 1,
            fechaMs: DateTime(2026, 5, 1).millisecondsSinceEpoch,
            tipo: tipoMovimientoEntrada,
            destinoExterno: 'Urbasa',
            zonaDestinoId: 10,
            cabezas: 12,
            guia: 'G-1'),
        MovimientoGanado(
            id: 2,
            loteId: 1,
            fechaMs: DateTime(2026, 9, 1).millisecondsSinceEpoch,
            tipo: tipoMovimientoSalida,
            zonaOrigenId: 10),
      ],
      eventos: [
        EventoGanado(
            id: 1,
            animalId: 1,
            fechaMs: DateTime(2026, 6, 1).millisecondsSinceEpoch,
            tipo: tipoEventoPesaje,
            pesoKg: 42.5),
        EventoGanado(
            id: 2,
            loteId: 1,
            fechaMs: DateTime(2026, 5, 2).millisecondsSinceEpoch,
            sustanciaActiva: 'Ivermectina',
            plazoSupresionCarneDias: 28,
            claseMedicamento: 'antiparasitario'),
      ],
      zonas: {10: 'Pasillo · Zunbeltz'},
    );

    test('animales: columnas de la importación, fechas y celdas seguras', () {
      final lineas = animalesACsv(datos, 'es').split('\r\n');
      expect(lineas[0],
          'Crotal;Nombre;Especie;Raza;Sexo;Nacimiento;Madre;Rebaño;Estado;Fecha de baja;Notas');
      expect(lineas[1],
          'ES012345678901;"Morena; la ""jefa""";Ovino;Latxa;Hembra;01/03/2024;ES012345678900;Ovejas de Ane;En el espacio;;\'=cojea revisar');
      expect(lineas[2],
          'ES012345678902;;;;;;;Vacas pirenaicas;Vendido;02/10/2026;');
    });

    test('movimientos y manejo, en orden y con coma decimal', () {
      final movimientos = movimientosACsv(datos, 'es').split('\r\n');
      expect(movimientos[0],
          'Fecha;Rebaño;Tipo;Origen;Destino;Cabezas;Guía;Notas');
      expect(movimientos[1],
          '01/05/2026;Ovejas de Ane;Entrada en el espacio;Urbasa;Pasillo · Zunbeltz;12;G-1;');
      expect(movimientos[2],
          '01/09/2026;Ovejas de Ane;Salida del espacio;Pasillo · Zunbeltz;Fuera del espacio;;;');

      final manejo = manejoACsv(datos, 'eu').split('\r\n');
      expect(manejo[0], startsWith('Data;Krotala;Izena;Taldea;Mota;'));
      expect(manejo[1], startsWith('02/05/2026;;;Ovejas de Ane;'));
      expect(manejo[1], contains(';Ivermectina;Antiparasitarioa;;28;0;'));
      expect(manejo[2], startsWith('01/06/2026;ES012345678901;'));
      expect(manejo[2], contains(';42,5;'));
    });

    test('tres ficheros con BOM', () {
      final documentos = documentosGanado(datos, 'es', hoy);
      expect(documentos.map((documento) => documento.nombreFichero), [
        'ganado_animales_2026-10-23.csv',
        'ganado_movimientos_2026-10-23.csv',
        'ganado_manejo_2026-10-23.csv',
      ]);
      expect(documentos.first.bytes.take(3), [0xEF, 0xBB, 0xBF]);
    });

    test('exportar y volver a importar: todo sin cambios', () {
      for (final idioma in ['es', 'eu']) {
        final documento = documentosGanado(datos, idioma, hoy).first;
        final analisis = analizarImportacionAnimales(
          tabla: leerTablaDeFichero(documento.nombreFichero, documento.bytes),
          existentes: datos.animales,
          lotes: lotes,
          politica: const PoliticaEspacio(null),
          hoy: hoy,
        );
        expect(analisis.columnasIgnoradas, isEmpty, reason: idioma);
        expect(analisis.sinCambios.length, 2, reason: idioma);
      }
    });

    test('la plantilla trae solo la cabecera', () {
      final plantilla = plantillaImportacionAnimales('eu');
      final tabla = leerTablaDeFichero(plantilla.nombreFichero, plantilla.bytes);
      expect(tabla.cabecera.first, 'Krotala');
      expect(tabla.filas, isEmpty);
    });
  });

  test('lo importado se guarda con uid y marca para sincronizar', () async {
    final bd = await abrirBdEnMemoria();
    final loteId =
        await bd.guardarLote(LoteGanado(nombre: 'Ovejas de Ane', especie: 'ovino'));
    final analisis = analizarImportacionAnimales(
      tabla: leerTablaDeFichero('a.csv',
          utf8.encode('Crotal;Rebaño\nES012345678901;Ovejas de Ane\n')),
      existentes: await bd.listarAnimales(),
      lotes: await bd.listarLotes(),
      politica: const PoliticaEspacio(null),
      hoy: hoy,
    );
    final id = await bd.guardarAnimal(Animal.fromMap(analisis.aCrear.single.datos));
    final fila = (await (await bd.basedatos)
            .query('animales', where: 'id = ?', whereArgs: [id]))
        .single;
    expect(fila['uid'], isNot(''));
    expect(fila['actualizado_ms'], greaterThan(0));
    expect(fila['lote_id'], loteId);

    final segunda = analizarImportacionAnimales(
      tabla: leerTablaDeFichero(
          'a.csv', utf8.encode('Crotal;Raza\nES012345678901;Latxa\n')),
      existentes: await bd.listarAnimales(),
      lotes: await bd.listarLotes(),
      politica: const PoliticaEspacio(null),
      hoy: hoy,
    );
    final cambio = segunda.aActualizar.single;
    await bd.actualizarAnimal(cambio.existente!.id!, cambio.datos);
    expect((await bd.obtenerAnimal(id))!.raza, 'Latxa');
  });
}
