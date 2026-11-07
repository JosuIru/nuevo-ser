import 'package:flutter_test/flutter_test.dart';
import 'package:solera_huerta/modelos/bancal.dart';
import 'package:solera_huerta/modelos/cosecha.dart';
import 'package:solera_huerta/modelos/cultivo.dart';
import 'package:solera_huerta/modelos/insumo.dart';
import 'package:solera_huerta/modelos/lote_semilla.dart';
import 'package:solera_huerta/modelos/parcela.dart';
import 'package:solera_huerta/modelos/siembra.dart';
import 'package:solera_huerta/modelos/titular.dart';
import 'package:solera_huerta/modelos/tratamiento.dart';
import 'package:solera_huerta/provisional_core/venta_directa/cesta.dart';
import 'package:solera_huerta/provisional_core/venta_directa/entrega.dart';
import 'package:solera_huerta/provisional_core/venta_directa/socio.dart';
import 'package:solera_huerta/provisional_core/venta_directa/suscripcion.dart';

/// Ida y vuelta: toMap → fromMap → toMap da lo mismo.
void idaYVuelta<T>(
    String nombre,
    T modelo,
    Map<String, Object?> Function(T) aMapa,
    T Function(Map<String, Object?>) desdeMapa) {
  test('$nombre: ida y vuelta', () {
    final mapa = aMapa(modelo);
    expect(aMapa(desdeMapa(mapa)), mapa);
  });
}

void main() {
  idaYVuelta(
      'Titular',
      Titular(
          id: 1,
          nombre: 'Ane',
          organismoControl: 'ENEEK',
          codigoOperadorEcologico: 'ES-ECO-024-PV'),
      (modelo) => modelo.toMap(),
      Titular.fromMap);
  idaYVuelta(
      'Parcela',
      Parcela(
          id: 2,
          nombre: 'Vega',
          estadoEcologico: 'conversion',
          fechaInicioConversionMs: 9,
          regadio: true,
          sistemaRiego: 'goteo',
          latitud: 42.8,
          longitud: -1.6),
      (modelo) => modelo.toMap(),
      Parcela.fromMap);
  idaYVuelta(
      'Bancal',
      Bancal(
          id: 3,
          parcelaId: 2,
          nombre: 'B1',
          largoM: 10,
          anchoM: 1.2,
          invernadero: true),
      (modelo) => modelo.toMap(),
      Bancal.fromMap);
  idaYVuelta(
      'Cultivo',
      Cultivo(
          id: 4,
          especieId: 'tomate',
          familiaId: 'solanaceas',
          variedad: 'Corazón de buey',
          variedadLocal: true),
      (modelo) => modelo.toMap(),
      Cultivo.fromMap);
  idaYVuelta(
      'LoteSemilla',
      LoteSemilla(
          id: 5,
          codigo: 'L1',
          especieId: 'tomate',
          origen: 'no_ecologica_autorizada',
          numeroAutorizacion: 'A-1',
          germinacionPorcentaje: 85,
          anyoObtencion: 2025),
      (modelo) => modelo.toMap(),
      LoteSemilla.fromMap);
  idaYVuelta(
      'Siembra',
      Siembra(
          id: 6,
          bancalId: 3,
          cultivoId: 4,
          fechaPrevistaMs: 100,
          fechaRealMs: 110,
          tipo: 'plantacion',
          cantidad: 40,
          kgPrevistos: 60,
          inicioCosechaPrevistaMs: 500,
          serieEscalonada: 'S'),
      (modelo) => modelo.toMap(),
      Siembra.fromMap);
  idaYVuelta(
      'Cosecha',
      Cosecha(
          id: 7,
          bancalId: 3,
          cultivoId: 4,
          fechaMs: 9,
          kg: 2.5,
          unidades: 12,
          destino: 'mercado',
          loteCosecha: 'C-1'),
      (modelo) => modelo.toMap(),
      Cosecha.fromMap);
  idaYVuelta(
      'Insumo',
      Insumo(
          id: 8,
          nombre: 'Estiércol compostado',
          tipo: 'enmienda',
          permitidoEcologico: true,
          justificantePermitido: 'certificado del proveedor'),
      (modelo) => modelo.toMap(),
      Insumo.fromMap);
  idaYVuelta(
      'Tratamiento',
      Tratamiento(
          id: 9,
          parcelaId: 2,
          bancalId: 3,
          insumoId: 8,
          fechaMs: 50,
          plazoSeguridadDias: 3,
          superficieTratadaM2: 12,
          dosisAplicada: 'según etiqueta'),
      (modelo) => modelo.toMap(),
      Tratamiento.fromMap);
  idaYVuelta('Socio', Socio(id: 10, nombre: 'Mikel', activo: false),
      (modelo) => modelo.toMap(), Socio.fromMap);
  idaYVuelta(
      'Suscripcion',
      Suscripcion(
          id: 11,
          socioId: 10,
          fechaInicioMs: 0,
          fechaFinMs: 99,
          tamano: 'grande',
          frecuencia: 'quincenal',
          precioCentimosCesta: 1800),
      (modelo) => modelo.toMap(),
      Suscripcion.fromMap);
  idaYVuelta(
      'Cesta',
      Cesta(id: 12, suscripcionId: 11, semanaLunesMs: 7, estado: 'preparada'),
      (modelo) => modelo.toMap(),
      Cesta.fromMap);
  idaYVuelta(
      'LineaCesta',
      LineaCesta(id: 13, cestaId: 12, cultivoId: 4, unidades: 2),
      (modelo) => modelo.toMap(),
      LineaCesta.fromMap);
  idaYVuelta(
      'Entrega',
      Entrega(id: 14, cestaId: 12, fechaMs: 8, resultado: 'no_recogida'),
      (modelo) => modelo.toMap(),
      Entrega.fromMap);

  test('mapas vacíos dan valores por defecto, no nulos', () {
    expect(Titular.fromMap(const {}).nombre, '');
    expect(Parcela.fromMap(const {}).estadoEcologico, 'ecologica');
    expect(Insumo.fromMap(const {}).permitidoEcologico, isFalse);
    expect(Socio.fromMap(const {}).activo, isTrue);
  });

  test('bancal: superficie solo con las dos medidas', () {
    expect(
        Bancal(parcelaId: 1, nombre: 'B', largoM: 10, anchoM: 1.2).superficieM2,
        closeTo(12, 1e-9));
    expect(Bancal(parcelaId: 1, nombre: 'B', largoM: 10).superficieM2, isNull);
  });

  test('parcela de secano no guarda sistema de riego', () {
    expect(
        Parcela(nombre: 'S', regadio: false, sistemaRiego: 'goteo')
            .toMap()['sistema_riego'],
        '');
  });

  test('siembra: planificada hasta que tiene fecha real', () {
    final planificada = Siembra(bancalId: 1, cultivoId: 1, fechaPrevistaMs: 10);
    expect(planificada.realizada, isFalse);
    expect(planificada.fechaReferenciaMs, 10);
    final hecha = planificada.copiar(fechaRealMs: 12);
    expect(hecha.realizada, isTrue);
    expect(hecha.fechaReferenciaMs, 12);
  });

  test('semilla no ecológica sin autorización', () {
    expect(
        LoteSemilla(
                codigo: 'L', especieId: 'x', origen: 'no_ecologica_autorizada')
            .faltaAutorizacion,
        isTrue);
    expect(
        LoteSemilla(codigo: 'L', especieId: 'x', origen: 'propia')
            .faltaAutorizacion,
        isFalse);
  });

  test('insumo permitido sin justificante', () {
    expect(Insumo(nombre: 'X', permitidoEcologico: true).faltaJustificante,
        isTrue);
    expect(Insumo(nombre: 'X').faltaJustificante, isFalse);
  });

  test('tratamiento: fin del plazo de seguridad', () {
    final fecha = DateTime(2026, 5, 1);
    expect(
        Tratamiento(
                parcelaId: 1,
                insumoId: 1,
                fechaMs: fecha.millisecondsSinceEpoch,
                plazoSeguridadDias: 3)
            .finPlazoSeguridad,
        DateTime(2026, 5, 4));
    expect(Tratamiento(parcelaId: 1, insumoId: 1, fechaMs: 0).finPlazoSeguridad,
        isNull);
  });

  group('suscripción', () {
    final inicio = DateTime(2026, 3, 4); // miércoles
    test('semanal: desde la semana de inicio hasta la de fin', () {
      final suscripcion = Suscripcion(
          socioId: 1,
          fechaInicioMs: inicio.millisecondsSinceEpoch,
          fechaFinMs: DateTime(2026, 3, 20).millisecondsSinceEpoch);
      expect(suscripcion.tocaEnSemana(DateTime(2026, 2, 23)), isFalse);
      expect(suscripcion.tocaEnSemana(DateTime(2026, 3, 2)), isTrue);
      expect(suscripcion.tocaEnSemana(DateTime(2026, 3, 16)), isTrue);
      expect(suscripcion.tocaEnSemana(DateTime(2026, 3, 23)), isFalse);
    });
    test('quincenal: semanas alternas, también tras el cambio de hora', () {
      final suscripcion = Suscripcion(
          socioId: 1,
          frecuencia: 'quincenal',
          fechaInicioMs: inicio.millisecondsSinceEpoch);
      expect(suscripcion.tocaEnSemana(DateTime(2026, 3, 2)), isTrue);
      expect(suscripcion.tocaEnSemana(DateTime(2026, 3, 9)), isFalse);
      expect(suscripcion.tocaEnSemana(DateTime(2026, 3, 30)), isTrue);
      expect(suscripcion.tocaEnSemana(DateTime(2026, 4, 6)), isFalse);
    });
    test('en pausa no recibe', () {
      expect(
          Suscripcion(socioId: 1, fechaInicioMs: 0, activa: false)
              .tocaEnSemana(DateTime(2026, 3, 2)),
          isFalse);
    });
    test('partes por tamaño', () {
      expect(
          Suscripcion(socioId: 1, fechaInicioMs: 0, tamano: 'pequena').partes,
          2);
      expect(Suscripcion(socioId: 1, fechaInicioMs: 0, tamano: 'grande').partes,
          4);
      expect(
          Suscripcion(socioId: 1, fechaInicioMs: 0, tamano: 'rara').partes, 3);
    });
  });
}
