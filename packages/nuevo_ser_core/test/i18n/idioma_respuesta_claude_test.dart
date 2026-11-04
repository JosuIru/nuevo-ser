import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

void main() {
  tearDown(() => SoleraL10n.idioma = 'es');

  test('pide contestar en el idioma elegido en la app', () {
    expect(instruccionIdiomaRespuestaClaude(), contains('castellano'));
    SoleraL10n.idioma = 'eu';
    expect(instruccionIdiomaRespuestaClaude(), contains('euskera'));
    expect(instruccionIdiomaRespuestaClaude(idioma: 'gl'), contains('gallego'));
  });

  test('un idioma desconocido cae en castellano', () {
    expect(instruccionIdiomaRespuestaClaude(idioma: 'xx'), contains('castellano'));
  });
}
