// Tests del módulo libro económico de Larrea Aceitera (F1-A9).
// Cubren round-trip POJO y la lógica derivada de IVA/compensación
// REAGP. No tocan sqflite — el contrato del CRUD se valida cuando
// entre la pantalla de configuración y los formularios.

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_aceitera/modelos/apunte_gasto.dart';
import 'package:solera_aceitera/modelos/apunte_ingreso.dart';
import 'package:solera_aceitera/modelos/configuracion_fiscal.dart';
import 'package:solera_aceitera/modelos/tercero.dart';

void main() {
  group('Tercero', () {
    test('Round-trip preserva tipo, NIF y derivados', () {
      final t = Tercero(
        nif: 'B12345678',
        nombre: 'Cooperativa Olivarera del Sur',
        direccion: 'Carretera de Lucena km 5',
        telefono: '957 000 000',
        email: 'cooperativa@example.com',
        tipo: 'cliente',
        notas: 'Recepción de aceituna campaña 2026/2027',
      );
      final reconstruido = Tercero.fromMap(t.toMap());
      expect(reconstruido.nif, equals('B12345678'));
      expect(reconstruido.nombre, contains('Olivarera'));
      expect(reconstruido.tipo, equals('cliente'));
      expect(reconstruido.esCliente, isTrue);
      expect(reconstruido.esProveedor, isFalse);
      expect(reconstruido.tieneNif, isTrue);
    });

    test('tipo=ambos es cliente y proveedor', () {
      final t = Tercero(nombre: 'Suministros Agrícolas', tipo: 'ambos');
      expect(t.esCliente, isTrue);
      expect(t.esProveedor, isTrue);
    });

    test('Sin NIF: no entra al modelo 347', () {
      final t = Tercero(nombre: 'Particular', tipo: 'cliente');
      expect(t.tieneNif, isFalse);
    });
  });

  group('ConfiguracionFiscal — reglas IVA olivar', () {
    test('REAGP: aceituna 0% IVA + 12% compensación; aceite 4% sin compensación',
        () {
      final c = ConfiguracionFiscal(
        regimenIrpf: 'estimacion_directa_simplificada',
        regimenIva: 'reagp',
      );
      expect(c.estaConfigurado, isTrue);
      expect(c.tieneCompensacionReagp, isTrue);
      expect(c.tipoIvaVentaAceituna, equals(0.0));
      expect(c.tipoCompensacionReagpAceituna, closeTo(0.12, 1e-9));
      expect(c.tipoIvaVentaAceiteEnvasado, closeTo(0.04, 1e-9));
      expect(c.tipoIvaVentaAceiteGranel, closeTo(0.04, 1e-9));
    });

    test('Régimen general: aceituna 4% IVA, sin compensación REAGP', () {
      final c = ConfiguracionFiscal(
        regimenIrpf: 'estimacion_directa_normal',
        regimenIva: 'general',
      );
      expect(c.tipoIvaVentaAceituna, closeTo(0.04, 1e-9));
      expect(c.tipoCompensacionReagpAceituna, equals(0.0));
      expect(c.tieneCompensacionReagp, isFalse);
    });

    test('Sin elegir: estaConfigurado = false y todos los tipos a 0', () {
      final c = ConfiguracionFiscal();
      expect(c.estaConfigurado, isFalse);
      expect(c.tipoIvaVentaAceituna, equals(0.0));
      expect(c.tipoCompensacionReagpAceituna, equals(0.0));
    });

    test('Alquiler terreno con uso agrícola siempre exento', () {
      final reagp = ConfiguracionFiscal(regimenIva: 'reagp');
      final general = ConfiguracionFiscal(regimenIva: 'general');
      expect(reagp.tipoIvaAlquilerTerreno, equals(0.0));
      expect(general.tipoIvaAlquilerTerreno, equals(0.0));
    });

    test('Round-trip POJO', () {
      final c = ConfiguracionFiscal(
        regimenIrpf: 'estimacion_directa_simplificada',
        regimenIva: 'reagp',
        anyoFiscalActivo: 2026,
      );
      final reconstruido = ConfiguracionFiscal.fromMap(c.toMap());
      expect(reconstruido.regimenIrpf,
          equals('estimacion_directa_simplificada'));
      expect(reconstruido.regimenIva, equals('reagp'));
      expect(reconstruido.anyoFiscalActivo, equals(2026));
    });
  });

  group('ApunteIngreso', () {
    test('Venta aceituna REAGP: total = base + 0 IVA + 12% compensación',
        () {
      final apunte = ApunteIngreso(
        fechaMs: 1700000000000,
        concepto: 'Aceituna picual a cooperativa',
        tipoIngreso: 'venta_aceituna',
        importeBaseCentimos: 250000, // 2.500,00 €
        ivaRepercutidoCentimos: 0,
        compensacionReagpCentimos: 30000, // 300,00 €
        cantidad: 5000, // 5.000 kg
        unidad: 'kg',
      );
      expect(apunte.importeTotalCentimos, equals(280000));
      expect(apunte.esVentaAceituna, isTrue);
      expect(apunte.esVentaAceite, isFalse);
      expect(apunte.esAyudaOSubvencion, isFalse);
    });

    test('Venta aceite envasado: total = base + 4% IVA, sin compensación',
        () {
      final apunte = ApunteIngreso(
        fechaMs: 1700000000000,
        tipoIngreso: 'venta_aceite_envasado',
        importeBaseCentimos: 100000, // 1.000 €
        ivaRepercutidoCentimos: 4000, // 40 € (4 %)
        cantidad: 200,
        unidad: 'botellas',
      );
      expect(apunte.esVentaAceite, isTrue);
      expect(apunte.esVentaAceituna, isFalse);
      expect(apunte.importeTotalCentimos, equals(104000));
    });

    test('Round-trip preserva FK opcional al lote', () {
      final apunte = ApunteIngreso(
        fechaMs: 1700000000000,
        tipoIngreso: 'venta_aceite_envasado',
        importeBaseCentimos: 50000,
        ivaRepercutidoCentimos: 2000,
        loteAceiteId: 42,
        parcelaId: 7,
        variedadId: 'picual',
        numeroFactura: 'F-2026-001',
      );
      final reconstruido = ApunteIngreso.fromMap(apunte.toMap());
      expect(reconstruido.loteAceiteId, equals(42));
      expect(reconstruido.parcelaId, equals(7));
      expect(reconstruido.variedadId, equals('picual'));
      expect(reconstruido.numeroFactura, equals('F-2026-001'));
    });

    test('Ayuda PAC: esAyudaOSubvencion=true', () {
      final apunte = ApunteIngreso(
        fechaMs: 1700000000000,
        tipoIngreso: 'ayuda_pac',
        importeBaseCentimos: 80000,
      );
      expect(apunte.esAyudaOSubvencion, isTrue);
      expect(apunte.esVentaAceituna, isFalse);
    });

    test('Alperujo: subproducto reconocido', () {
      final apunte = ApunteIngreso(
        fechaMs: 1700000000000,
        tipoIngreso: 'subproducto_alperujo',
        importeBaseCentimos: 20000,
      );
      expect(apunte.tipoIngreso, equals('subproducto_alperujo'));
      expect(apunte.esVentaAceituna, isFalse);
      expect(apunte.esVentaAceite, isFalse);
    });
  });

  group('ApunteGasto', () {
    test('Imputación parcela concreta', () {
      final gasto = ApunteGasto(
        fechaMs: 1700000000000,
        concepto: 'Tratamiento mosca olivo',
        tipoGasto: 'fitosanitarios',
        importeBaseCentimos: 12000,
        ivaSoportadoCentimos: 2520,
        imputacion: 'parcela_concreta',
        parcelaId: 3,
        tratamientoId: 17,
      );
      expect(gasto.esParcelaConcreta, isTrue);
      expect(gasto.esVariedadGeneral, isFalse);
      expect(gasto.importeTotalCentimos, equals(14520));
    });

    test('Gasoil agrícola: esGasoilAgricola=true', () {
      final gasto = ApunteGasto(
        fechaMs: 1700000000000,
        tipoGasto: 'combustible',
        importeBaseCentimos: 35000,
      );
      expect(gasto.esGasoilAgricola, isTrue);
    });

    test('Round-trip preserva imputación general', () {
      final gasto = ApunteGasto(
        fechaMs: 1700000000000,
        tipoGasto: 'cuota_dop',
        importeBaseCentimos: 30000,
        imputacion: 'general',
      );
      final reconstruido = ApunteGasto.fromMap(gasto.toMap());
      expect(reconstruido.tipoGasto, equals('cuota_dop'));
      expect(reconstruido.imputacion, equals('general'));
      expect(reconstruido.esParcelaConcreta, isFalse);
      expect(reconstruido.esGasoilAgricola, isFalse);
    });

    test('Imputación variedad_general requiere variedadId no vacío', () {
      final con = ApunteGasto(
        fechaMs: 1700000000000,
        tipoGasto: 'insumos_olivar',
        imputacion: 'variedad_general',
        variedadId: 'hojiblanca',
      );
      final sin = ApunteGasto(
        fechaMs: 1700000000000,
        tipoGasto: 'insumos_olivar',
        imputacion: 'variedad_general',
      );
      expect(con.esVariedadGeneral, isTrue);
      expect(sin.esVariedadGeneral, isFalse);
    });
  });
}
