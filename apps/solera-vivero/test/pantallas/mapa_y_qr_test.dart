import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart' show codificarContorno;
import 'package:solera_vivero/modelos/bandeja.dart';
import 'package:solera_vivero/modelos/zona_cultivo.dart';
import 'package:solera_vivero/pantallas/formularios.dart'
    show metrosCuadradosParaCampo;
import 'package:solera_vivero/pantallas/pantalla_mapa_zonas.dart';
import 'package:solera_vivero/servicios/etiquetas_qr_bandejas.dart';
import 'package:solera_vivero/utiles/textos_vivero.dart' show leerNumero;

void main() {
  test('el mapa se centra en las zonas con ubicación', () {
    final centro = centroDeZonas([
      ZonaCultivo(nombre: 'A', tipo: 'exterior', latitud: 42, longitud: -2),
      ZonaCultivo(nombre: 'B', tipo: 'exterior', latitud: 44, longitud: -4),
      ZonaCultivo(nombre: 'Nave'),
    ]);
    expect((centro.latitude, centro.longitude), (43, -3));
    expect(centroDeZonas([]).latitude, 40.4);
  });

  test('una zona con área y sin punto sale en el centro del área', () {
    final zona = ZonaCultivo(
        nombre: 'Área',
        tipo: 'exterior',
        contorno: codificarContorno(const [
          LatLng(42, -2),
          LatLng(42, -1.998),
          LatLng(42.002, -1.998),
          LatLng(42.002, -2),
        ]));
    final punto = puntoDeZona(zona)!;
    expect(punto.latitude, closeTo(42.001, 1e-6));
    expect(punto.longitude, closeTo(-1.999, 1e-6));
    expect(puntoDeZona(ZonaCultivo(nombre: 'Nave')), isNull);
  });

  test('la superficie del área pasa al campo en m² sin separador de miles', () {
    expect(metrosCuadradosParaCampo(0.1234 * 10000), '1234');
    expect(leerNumero(metrosCuadradosParaCampo(12345.6)), 12346);
  });

  test('el logo placeholder existe y está declarado; permisos en Android', () {
    expect(File('assets/icono-logo-vivero.png').existsSync(), isTrue);
    expect(File('pubspec.yaml').readAsStringSync(),
        contains('assets/icono-logo-vivero.png'));
    final manifiesto =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    for (final permiso in [
      'INTERNET',
      'ACCESS_FINE_LOCATION',
      'CAMERA',
    ]) {
      expect(manifiesto, contains('android.permission.$permiso'));
    }
    expect(manifiesto, contains('android:label="Larrea Vivero"'));
  });

  test('etiquetas QR: el QR lleva el código tal cual y 21 por página', () {
    final etiqueta = etiquetaDeBandeja(
        Bandeja(
            codigoQr: 'VIV-B-0007', numeroAlveolos: 104, ubicacion: 'Mesa 2'),
        nombreZona: 'Nave 1',
        nombreFormato: 'Alveolo');
    expect(etiqueta.codigoQr, 'VIV-B-0007');
    expect(etiqueta.linea, 'Alveolo · 104 · Nave 1 · Mesa 2');
    final paginas = paginasDeEtiquetas(
        List.generate(45, (indice) => EtiquetaBandeja('VIV-B-$indice', '')));
    expect(paginas.map((pagina) => pagina.length), [21, 21, 3]);
    expect(paginasDeEtiquetas(const []), isEmpty);
  });

  test('etiquetas QR en PDF', () async {
    final bytes = await generarEtiquetasQrBandejas(
        [const EtiquetaBandeja('VIV-B-0001', 'Alveolo')]);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
