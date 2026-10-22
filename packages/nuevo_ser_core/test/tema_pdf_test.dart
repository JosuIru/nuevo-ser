import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('la letra de los PDF tiene «€» y «—» y el documento se genera',
      () async {
    final tema = await temaPdfSolera();
    for (final estilo in [
      tema.defaultTextStyle,
      tema.defaultTextStyle.copyWith(fontWeight: pw.FontWeight.bold)
    ]) {
      final fuente = estilo.font as pw.TtfFont;
      final glifos = TtfParser(fuente.data).charToGlyphIndexMap;
      expect(glifos.containsKey('€'.runes.first), isTrue);
      expect(glifos.containsKey('—'.runes.first), isTrue);
    }
    final documento = pw.Document(theme: tema);
    documento.addPage(pw.Page(build: (_) => pw.Text('1.200,00 € — total')));
    expect(await documento.save(), isNotEmpty);
  });
}
