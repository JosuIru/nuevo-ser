import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/src/facturacion/factura.dart';
import 'package:nuevo_ser_core/src/facturacion/generador_factura_pdf.dart';
import 'package:nuevo_ser_core/src/pdf/tema_pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => initializeDateFormatting('es_ES'));

  test('cantidades: enteras sin decimales, decimales a la española', () {
    expect(textoCantidadFactura(null), '1');
    expect(textoCantidadFactura(2), '2');
    expect(textoCantidadFactura(3.0), '3');
    expect(textoCantidadFactura(2.5), '2,5');
    expect(textoCantidadFactura(0.75), '0,75');
  });

  test('genera el PDF de una factura con € y cantidades decimales', () async {
    final factura = Factura(
      numeroFactura: '2026-0004',
      fechaEmisionMs: DateTime(2026, 10, 22).millisecondsSinceEpoch,
      fechaVencimientoMs: DateTime(2026, 11, 21).millisecondsSinceEpoch,
      clienteNombre: 'Ayuntamiento de Ejemplo',
      lineasJson:
          '[{"descripcion":"Poda de plátanos — calle Mayor","cantidad":2.5,'
          '"precioUnitario":40,"importe":100}]',
      baseImponible: 100,
      ivaPorcentaje: 21,
      total: 121,
      estado: 'pagada',
      fechaCreacionMs: 0,
    );
    final generador = GeneradorFacturaPdf(
      marca: 'SOLERA QUESERA',
      tituloDocumento: 'Factura Simplificada',
      nombreAplicacion: 'Solera Quesera',
    );
    final bytes = await generador.generarBytes(
      factura: factura,
      emisor: const DatosEmisorFactura(nombre: 'Quesería Ejemplo', nif: ''),
      fechaGeneracion: DateTime(2026, 10, 22),
    );
    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');

    // La letra del tema (la que usa el generador) tiene «€» y «—».
    final tema = await temaPdfSolera();
    final fuente = tema.defaultTextStyle.font as pw.TtfFont;
    final glifos = TtfParser(fuente.data).charToGlyphIndexMap;
    expect(glifos.containsKey('€'.runes.first), isTrue);
    expect(glifos.containsKey('—'.runes.first), isTrue);
  });

  test('factura sin líneas ni datos del emisor no lanza', () async {
    final bytes = await GeneradorFacturaPdf().generarBytes(
      factura: Factura(
          numeroFactura: '1', fechaEmisionMs: 0, fechaCreacionMs: 0),
      emisor: const DatosEmisorFactura(nombre: 'Titular'),
    );
    expect(bytes, isNotEmpty);
  });

  test('importes a la española', () {
    expect(textoImporteFactura(12.5), '12,50 €');
    expect(textoImporteFactura(1234567.891), '1.234.567,89 €');
    expect(textoImporteFactura(null), '0,00 €');
    expect(textoImporteFactura(-3), '-3,00 €');
    expect(textoImporteFactura(999.999), '1.000,00 €');
  });
}
