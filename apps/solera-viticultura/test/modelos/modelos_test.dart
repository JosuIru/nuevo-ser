import 'package:flutter_test/flutter_test.dart';
import 'package:solera_viticultura/modelos/cepa.dart';
import 'package:solera_viticultura/modelos/cosecha.dart';
import 'package:solera_viticultura/modelos/incidencia.dart';
import 'package:solera_viticultura/modelos/observacion.dart';
import 'package:solera_viticultura/modelos/titular.dart';
import 'package:solera_viticultura/modelos/tratamiento.dart';
import 'package:solera_viticultura/modelos/vinedo.dart';

/// Tests POJO ida-y-vuelta toMap/fromMap para los 6 modelos del
/// dominio. Validan que el shape sqflite es preservado y que las
/// claves snake_case coinciden con lo que la futura `BaseDatos`
/// (F1-2 chunk SQL) consumirá.
void main() {
  group('Vinedo', () {
    test('round-trip mínimo', () {
      final original = Vinedo(
        id: 1,
        nombre: 'Pago La Larrea',
        colorEntero: 0xFF7D2A2A,
        fechaCreacionMs: 1700000000000,
      );
      final ida = Vinedo.fromMap(original.toMap());
      expect(ida.nombre, 'Pago La Larrea');
      expect(ida.colorEntero, 0xFF7D2A2A);
      expect(ida.fechaCreacionMs, 1700000000000);
      expect(ida.referenciaSigpac, '');
    });

    test('round-trip con SIGPAC + superficie', () {
      final original = Vinedo(
        id: 2,
        nombre: 'Carrascal',
        colorEntero: 0xFF000000,
        fechaCreacionMs: 1700000000000,
        sigpacProvincia: '26',
        sigpacMunicipio: '008',
        sigpacPoligono: '14',
        sigpacParcela: '21',
        sigpacRecinto: '3',
        superficieHectareas: 4.75,
      );
      final ida = Vinedo.fromMap(original.toMap());
      expect(ida.referenciaSigpac, '26:008:14:21:3');
      expect(ida.superficieHectareas, 4.75);
    });

    test('referenciaSigpac con campos parcialmente vacíos usa "—"', () {
      final v = Vinedo(
        nombre: 'X',
        colorEntero: 0,
        fechaCreacionMs: 0,
        sigpacProvincia: '26',
        sigpacRecinto: '3',
      );
      expect(v.referenciaSigpac, '26:—:—:—:3');
    });
  });

  group('Cepa', () {
    test('round-trip de punto suelto (sin viñedo)', () {
      final original = Cepa(
        variedadId: 'tempranillo',
        latitud: 42.5,
        longitud: -2.5,
        fechaCreacionMs: 1700000000000,
      );
      final ida = Cepa.fromMap(original.toMap());
      expect(ida.vinedoId, isNull);
      expect(ida.variedadId, 'tempranillo');
      expect(ida.portainjertoId, '');
      expect(ida.latitud, 42.5);
      expect(ida.longitud, -2.5);
    });

    test('round-trip completo con portainjerto, etiqueta, fecha', () {
      final original = Cepa(
        id: 7,
        vinedoId: 1,
        variedadId: 'garnacha',
        portainjertoId: '110-R',
        latitud: 42.501,
        longitud: -2.503,
        precisionMetros: 3.5,
        fechaPlantacionMs: 1500000000000,
        etiqueta: 'F3-12',
        notas: 'Cabezas alta, vigor medio.',
        fechaCreacionMs: 1700000000000,
      );
      final ida = Cepa.fromMap(original.toMap());
      expect(ida.portainjertoId, '110-R');
      expect(ida.etiqueta, 'F3-12');
      expect(ida.fechaPlantacionMs, 1500000000000);
      expect(ida.precisionMetros, 3.5);
    });
  });

  group('Cosecha / Observacion / Incidencia', () {
    test('Cosecha en kilos sobrevive', () {
      final original = Cosecha(cepaId: 5, fechaMs: 1700000000000, kilos: 4.25, calidad: 4);
      final ida = Cosecha.fromMap(original.toMap());
      expect(ida.cepaId, 5);
      expect(ida.kilos, 4.25);
      expect(ida.calidad, 4);
    });

    test('Observacion con etiquetas BBCH', () {
      final original = Observacion(
        cepaId: 5,
        fechaMs: 1700000000000,
        salud: 4,
        etiquetasJson: '["floración","cuajado"]',
      );
      final ida = Observacion.fromMap(original.toMap());
      expect(ida.salud, 4);
      expect(ida.etiquetasJson, '["floración","cuajado"]');
    });

    test('Incidencia con resuelta=true preserva el flag', () {
      final original = Incidencia(
        cepaId: 5,
        fechaMs: 1700000000000,
        tipo: 'enfermedad',
        diagnostico: 'mildiu',
        severidad: 3,
        resuelta: true,
        fechaResolucionMs: 1701000000000,
      );
      final ida = Incidencia.fromMap(original.toMap());
      expect(ida.tipo, 'enfermedad');
      expect(ida.diagnostico, 'mildiu');
      expect(ida.resuelta, true);
      expect(ida.fechaResolucionMs, 1701000000000);
    });

    test('Incidencia con resuelta=false por defecto', () {
      final original = Incidencia(cepaId: 5, fechaMs: 1700000000000);
      final ida = Incidencia.fromMap(original.toMap());
      expect(ida.resuelta, false);
      expect(ida.fechaResolucionMs, isNull);
    });
  });

  group('Titular PAC', () {
    test('estaConfigurado false sin nif/nombre', () {
      expect(Titular().estaConfigurado, false);
      expect(Titular(nif: '12345678Z').estaConfigurado, false);
      expect(Titular(nombre: 'Antonio').estaConfigurado, false);
    });

    test('estaConfigurado true con nif + nombre', () {
      expect(Titular(nif: '12345678Z', nombre: 'Antonio').estaConfigurado, true);
    });

    test('round-trip preserva todos los campos PAC', () {
      final original = Titular(
        nif: '12345678Z',
        nombre: 'Antonio Beltrán',
        direccion: 'Bodega Pago La Larrea, Logroño',
        numeroRegepa: 'REG-26-2025-0042',
        telefono: '600123456',
        email: 'antonio@bodegasolera.es',
        nombreAplicador: 'Antonio Beltrán',
        nifAplicador: '12345678Z',
        carnetAplicador: 'AP-26-2024-1234',
        nivelCarnetAplicador: 'cualificado',
      );
      final ida = Titular.fromMap(original.toMap());
      expect(ida.nif, '12345678Z');
      expect(ida.nivelCarnetAplicador, 'cualificado');
      expect(ida.numeroRegepa, 'REG-26-2025-0042');
      expect(ida.estaConfigurado, true);
    });
  });

  group('Tratamiento PAC', () {
    test('Tratamiento fitosanitario con campos PAC completos', () {
      final original = Tratamiento(
        cepaId: 5,
        fechaMs: 1700000000000,
        tipo: 'fitosanitario',
        producto: 'Folpan 80 WG',
        dosis: '150 g/hl',
        motivo: 'Control mildiu preventivo',
        plazoSeguridadDias: 28,
        incidenciaId: 12,
        numeroRegistroFitosanitario: '15858',
        nifAplicador: '12345678Z',
        superficieTratadaHectareas: 1.25,
      );
      final ida = Tratamiento.fromMap(original.toMap());
      expect(ida.tipo, 'fitosanitario');
      expect(ida.producto, 'Folpan 80 WG');
      expect(ida.numeroRegistroFitosanitario, '15858');
      expect(ida.nifAplicador, '12345678Z');
      expect(ida.superficieTratadaHectareas, 1.25);
      expect(ida.plazoSeguridadDias, 28);
      expect(ida.incidenciaId, 12);
    });

    test('Tratamiento manejo cultural sin PAC', () {
      final original = Tratamiento(
        cepaId: 5,
        fechaMs: 1700000000000,
        tipo: 'poda',
        motivo: 'Despunte',
      );
      final ida = Tratamiento.fromMap(original.toMap());
      expect(ida.tipo, 'poda');
      expect(ida.numeroRegistroFitosanitario, '');
      expect(ida.nifAplicador, '');
      expect(ida.superficieTratadaHectareas, isNull);
    });
  });
}
