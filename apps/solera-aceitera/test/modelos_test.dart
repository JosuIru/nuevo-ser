// Tests POJO de los 14 modelos de Larrea Aceitera (F1-A2).
// Round-trip toMap/fromMap por cada modelo + lógica derivada
// (getters calculados). NO ejercita sqflite — esos llegan en F1-A3
// cuando entren las pantallas o cuando se incorpore sqflite_common_ffi
// al entorno de tests.

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_aceitera/modelos/analitica.dart';
import 'package:solera_aceitera/modelos/campania.dart';
import 'package:solera_aceitera/modelos/incidencia.dart';
import 'package:solera_aceitera/modelos/lote_aceite.dart';
import 'package:solera_aceitera/modelos/molturacion.dart';
import 'package:solera_aceitera/modelos/movimiento.dart';
import 'package:solera_aceitera/modelos/olivar.dart';
import 'package:solera_aceitera/modelos/olivo.dart';
import 'package:solera_aceitera/modelos/parcela.dart';
import 'package:solera_aceitera/modelos/partida_aceituna.dart';
import 'package:solera_aceitera/modelos/recoleccion.dart';
import 'package:solera_aceitera/modelos/titular.dart';
import 'package:solera_aceitera/modelos/tratamiento.dart';
import 'package:solera_aceitera/modelos/venta.dart';

void main() {
  final ahora = DateTime.now().millisecondsSinceEpoch;

  group('Titular', () {
    test('toMap / fromMap ida y vuelta', () {
      final original = Titular(
        razonSocial: 'Cooperativa Aceitera La Era',
        nif: 'F12345678',
        rgseaa: '12.04567/J',
        numeroAica: 'AICA-J-001234',
        direccion: 'Carretera de Baeza s/n',
        telefono: '953123456',
        email: 'info@laera.coop',
        ibanReagp: 'ES7621000000010000000000',
      );
      final recuperado = Titular.fromMap(original.toMap());
      expect(recuperado.razonSocial, original.razonSocial);
      expect(recuperado.nif, original.nif);
      expect(recuperado.rgseaa, original.rgseaa);
      expect(recuperado.numeroAica, original.numeroAica);
      expect(recuperado.ibanReagp, original.ibanReagp);
    });

    test('valores por defecto vacíos', () {
      final t = Titular();
      expect(t.razonSocial, '');
      expect(t.id, null);
      expect(t.rutasFotosJson, '[]');
    });
  });

  group('Olivar', () {
    test('toMap / fromMap conserva flags de certificación', () {
      final o = Olivar(
        nombre: 'Olivar El Cortijuelo',
        titularId: 1,
        municipio: 'Úbeda',
        provincia: 'Jaén',
        comarca: 'La Loma',
        certificacionEcologico: true,
        certificacionIntegrada: false,
        dopId: 'sierra_de_cazorla',
      );
      final mapa = o.toMap();
      expect(mapa['certificacion_ecologico'], 1);
      expect(mapa['certificacion_integrada'], 0);
      final rec = Olivar.fromMap(mapa);
      expect(rec.certificacionEcologico, true);
      expect(rec.certificacionIntegrada, false);
      expect(rec.dopId, 'sierra_de_cazorla');
    });
  });

  group('Parcela', () {
    test('round-trip preserva superficieHa, sistemaRiego y coords', () {
      final original = Parcela(
        olivarId: 1,
        nombre: 'Parcela Norte',
        codigoSigpac: '23:077:001:00074:0001:WX',
        superficieHa: 4.85,
        variedadMayoritariaId: 'picual',
        marcoPlantacion: '8x6',
        edadMediaAnyos: 32,
        sistemaRiego: 'goteo',
        latitud: 37.9876,
        longitud: -3.2345,
        fechaCreacionMs: ahora,
      );
      final rec = Parcela.fromMap(original.toMap());
      expect(rec.superficieHa, 4.85);
      expect(rec.sistemaRiego, 'goteo');
      expect(rec.latitud, 37.9876);
      expect(rec.longitud, -3.2345);
      expect(rec.variedadMayoritariaId, 'picual');
    });

    test('fromMap nullable seguro (coords pueden ser null)', () {
      final rec = Parcela.fromMap({
        'olivar_id': 1,
        'fecha_creacion_ms': ahora,
      });
      expect(rec.latitud, isNull);
      expect(rec.longitud, isNull);
      expect(rec.sistemaRiego, 'secano');
      expect(rec.superficieHa, 0);
    });
  });

  group('Olivo', () {
    test('round-trip preserva identificadorInterno y fechaPlantacion', () {
      final original = Olivo(
        parcelaId: 3,
        identificadorInterno: 'Olivo de la Era',
        variedadId: 'picual',
        edadAnyos: 200,
        estado: 'productivo',
        fechaPlantacionMs: ahora - Duration.millisecondsPerDay * 365 * 200,
        fechaCreacionMs: ahora,
      );
      final rec = Olivo.fromMap(original.toMap());
      expect(rec.identificadorInterno, 'Olivo de la Era');
      expect(rec.edadAnyos, 200);
      expect(rec.fechaPlantacionMs, original.fechaPlantacionMs);
    });
  });

  group('Campania', () {
    test('estaAbierta = true sin fechaFinMs, false con fechaFinMs', () {
      final abierta = Campania(
        olivarId: 1,
        anyoComercial: 2026,
        fechaInicioMs: ahora,
      );
      expect(abierta.estaAbierta, isTrue);
      expect(abierta.fechaFinMs, isNull);

      final cerrada = Campania(
        olivarId: 1,
        anyoComercial: 2025,
        fechaInicioMs: ahora - Duration.millisecondsPerDay * 200,
        fechaFinMs: ahora,
      );
      expect(cerrada.estaAbierta, isFalse);
    });

    test('round-trip preserva rendimiento y produccion', () {
      final original = Campania(
        olivarId: 1,
        anyoComercial: 2026,
        fechaInicioMs: ahora,
        produccionTotalKgAceituna: 125000,
        produccionTotalKgAceite: 25000,
        rendimientoMedioPorcentaje: 20.0,
      );
      final rec = Campania.fromMap(original.toMap());
      expect(rec.produccionTotalKgAceituna, 125000);
      expect(rec.produccionTotalKgAceite, 25000);
      expect(rec.rendimientoMedioPorcentaje, 20.0);
    });
  });

  group('Recoleccion', () {
    test('round-trip preserva tipoAceituna y método', () {
      final original = Recoleccion(
        parcelaId: 1,
        campaniaId: 1,
        fechaMs: ahora,
        kgEstimados: 850.5,
        tipoAceituna: 'verde',
        metodo: 'paraguas',
        cuadrilla: 'Cuadrilla Pérez',
      );
      final rec = Recoleccion.fromMap(original.toMap());
      expect(rec.tipoAceituna, 'verde');
      expect(rec.metodo, 'paraguas');
      expect(rec.kgEstimados, 850.5);
    });
  });

  group('PartidaAceituna', () {
    test('preserva flag origenEsSocio y socioExterno', () {
      final original = PartidaAceituna(
        campaniaId: 1,
        fechaMs: ahora,
        kgNetosBascula: 1240.0,
        porcentajeAceitunaDefectuosa: 3.5,
        catador: 'Sebastián Ruiz',
        numeroAlbaran: 'A-2026-0042',
        origenEsSocio: true,
        socioExterno: 'Hermanos Molina',
      );
      final mapa = original.toMap();
      expect(mapa['origen_es_socio'], 1);
      final rec = PartidaAceituna.fromMap(mapa);
      expect(rec.origenEsSocio, true);
      expect(rec.socioExterno, 'Hermanos Molina');
      expect(rec.recoleccionId, isNull);
    });

    test('finca propia: origenEsSocio false + recoleccionId presente', () {
      final original = PartidaAceituna(
        campaniaId: 1,
        recoleccionId: 7,
        fechaMs: ahora,
        kgNetosBascula: 980.0,
      );
      final rec = PartidaAceituna.fromMap(original.toMap());
      expect(rec.origenEsSocio, false);
      expect(rec.recoleccionId, 7);
    });
  });

  group('Molturacion', () {
    test('partidasUsadasIds parsea JSON válido', () {
      final m = Molturacion(
        campaniaId: 1,
        fechaMs: ahora,
        kgMolturados: 5400,
        partidasUsadasJson: '[3, 7, 12]',
      );
      expect(m.partidasUsadasIds, [3, 7, 12]);
    });

    test('partidasUsadasIds tolera JSON corrupto (devuelve vacío)', () {
      final m = Molturacion(
        campaniaId: 1,
        fechaMs: ahora,
        partidasUsadasJson: 'esto-no-es-json',
      );
      expect(m.partidasUsadasIds, isEmpty);
    });

    test('partidasUsadasIds ignora elementos no numéricos', () {
      final m = Molturacion(
        campaniaId: 1,
        fechaMs: ahora,
        partidasUsadasJson: '[1, "abc", 4, null, 5]',
      );
      expect(m.partidasUsadasIds, [1, 4, 5]);
    });

    test('round-trip preserva rendimiento y alperujo', () {
      final original = Molturacion(
        campaniaId: 1,
        fechaMs: ahora,
        kgMolturados: 5400,
        rendimientoPorcentaje: 21.3,
        aceiteObtenidoKg: 1150,
        loteAceiteId: 42,
        alperujoKg: 4250,
        batidoraReferencia: 'Pieralisi DMF',
        decanterReferencia: 'Pieralisi DMS-1',
      );
      final rec = Molturacion.fromMap(original.toMap());
      expect(rec.rendimientoPorcentaje, 21.3);
      expect(rec.alperujoKg, 4250);
      expect(rec.loteAceiteId, 42);
    });
  });

  group('LoteAceite', () {
    test('round-trip con parámetros analíticos completos', () {
      final original = LoteAceite(
        campaniaId: 1,
        identificadorLote: '2026-001',
        fechaCreacionMs: ahora,
        kgNetos: 1150,
        acidez: 0.4,
        peroxidos: 8,
        k232: 1.8,
        k270: 0.12,
        polifenolesMgKg: 450,
        panelTestPuntuacion: 7.5,
        panelTestNotas: 'frutado intenso, almendrado',
        categoria: 'virgen_extra',
        dopId: 'sierra_de_cazorla',
        ubicacionFisica: 'depósito D-3',
      );
      final rec = LoteAceite.fromMap(original.toMap());
      expect(rec.acidez, 0.4);
      expect(rec.categoria, 'virgen_extra');
      expect(rec.panelTestPuntuacion, 7.5);
      expect(rec.dopId, 'sierra_de_cazorla');
    });

    test('round-trip con parámetros nullables vacíos', () {
      final original = LoteAceite(
        campaniaId: 1,
        identificadorLote: '2026-099',
        fechaCreacionMs: ahora,
        kgNetos: 800,
      );
      final rec = LoteAceite.fromMap(original.toMap());
      expect(rec.acidez, isNull);
      expect(rec.peroxidos, isNull);
      expect(rec.panelTestPuntuacion, isNull);
      expect(rec.categoria, 'por_clasificar');
    });
  });

  group('Movimiento', () {
    test('round-trip preserva tipo y referencias', () {
      final original = Movimiento(
        loteAceiteId: 42,
        fechaMs: ahora,
        tipo: 'envasado',
        kgMovidos: 320,
        ubicacionDestino: 'envasado 500ml x 640',
        ventaId: 17,
      );
      final rec = Movimiento.fromMap(original.toMap());
      expect(rec.tipo, 'envasado');
      expect(rec.ventaId, 17);
      expect(rec.loteDestinoMezclaId, isNull);
    });

    test('mezcla guarda loteDestinoMezclaId', () {
      final original = Movimiento(
        loteAceiteId: 42,
        fechaMs: ahora,
        tipo: 'mezcla_lotes',
        kgMovidos: 100,
        loteDestinoMezclaId: 50,
      );
      final rec = Movimiento.fromMap(original.toMap());
      expect(rec.tipo, 'mezcla_lotes');
      expect(rec.loteDestinoMezclaId, 50);
      expect(rec.ventaId, isNull);
    });
  });

  group('Venta', () {
    test('round-trip preserva totales e IVA', () {
      final original = Venta(
        fechaMs: ahora,
        tipoCliente: 'empresa_es',
        nombreCliente: 'Restaurante Buena Mesa',
        identificadorFiscalCliente: 'B12345678',
        numeroFactura: 'F-2026-0042',
        lineasJson: '[{"lote_id":42,"kg":50,"precio_kg":12.5}]',
        totalSinIva: 625.0,
        ivaPorcentaje: 10.0,
        totalConIva: 687.5,
        destinoPaisIso: 'ES',
      );
      final rec = Venta.fromMap(original.toMap());
      expect(rec.totalSinIva, 625.0);
      expect(rec.totalConIva, 687.5);
      expect(rec.ivaPorcentaje, 10.0);
      expect(rec.destinoPaisIso, 'ES');
    });

    test('default sin factura: tipoCliente particular y país ES', () {
      final v = Venta(fechaMs: ahora);
      expect(v.tipoCliente, 'particular');
      expect(v.destinoPaisIso, 'ES');
      expect(v.numeroFactura, '');
      expect(v.lineasJson, '[]');
    });
  });

  group('Tratamiento', () {
    test('round-trip preserva sustancia activa y carnet', () {
      final original = Tratamiento(
        parcelaId: 1,
        fechaMs: ahora,
        productoComercialReferencia: 'Producto X',
        sustanciaActivaId: 'deltametrina',
        dosisLitrosPorHa: 0.5,
        plagaObjetivoId: 'mosca_olivo',
        aplicadorNombre: 'Juan García',
        carnetAplicadorNumero: 'AND-12345-CUAL',
      );
      final rec = Tratamiento.fromMap(original.toMap());
      expect(rec.sustanciaActivaId, 'deltametrina');
      expect(rec.plagaObjetivoId, 'mosca_olivo');
      expect(rec.carnetAplicadorNumero, 'AND-12345-CUAL');
      expect(rec.dosisLitrosPorHa, 0.5);
    });
  });

  group('Incidencia', () {
    test('ámbito olivar con parcelaId; loteAceiteId null', () {
      final original = Incidencia(
        fechaMs: ahora,
        ambito: 'olivar',
        parcelaId: 3,
        tipo: 'sequia',
        severidad: 'grave',
        descripcion: '40 días sin lluvia con temperaturas >38°C',
      );
      final rec = Incidencia.fromMap(original.toMap());
      expect(rec.ambito, 'olivar');
      expect(rec.parcelaId, 3);
      expect(rec.loteAceiteId, isNull);
      expect(rec.severidad, 'grave');
    });

    test('ámbito almazara con loteAceiteId; parcelaId null', () {
      final original = Incidencia(
        fechaMs: ahora,
        ambito: 'almazara',
        loteAceiteId: 42,
        tipo: 'sobrefermentacion',
      );
      final rec = Incidencia.fromMap(original.toMap());
      expect(rec.ambito, 'almazara');
      expect(rec.loteAceiteId, 42);
      expect(rec.parcelaId, isNull);
    });
  });

  group('Analitica', () {
    test('round-trip preserva todos los parámetros del aceite', () {
      final original = Analitica(
        loteAceiteId: 42,
        fechaMs: ahora,
        acidez: 0.38,
        peroxidos: 7.2,
        k232: 1.75,
        k270: 0.11,
        polifenolesMgKg: 480,
        color: 70,
        humedad: 0.15,
        panelTestPuntuacion: 7.8,
        panelTestNotas: 'frutado verde intenso',
        laboratorio: 'Laboratorio Agroalimentario Jaén',
      );
      final rec = Analitica.fromMap(original.toMap());
      expect(rec.acidez, 0.38);
      expect(rec.k232, 1.75);
      expect(rec.polifenolesMgKg, 480);
      expect(rec.panelTestPuntuacion, 7.8);
      expect(rec.laboratorio, 'Laboratorio Agroalimentario Jaén');
    });
  });
}
