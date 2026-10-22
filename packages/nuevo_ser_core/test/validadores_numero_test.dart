import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

void main() {
  setUp(() => SoleraL10n.idioma = 'es');

  test('número opcional: vacío vale, basura avisa, negativo solo si se permite',
      () {
    expect(validarNumeroOpcional(''), isNull);
    expect(validarNumeroOpcional('12,5'), isNull);
    expect(validarNumeroOpcional('doce'), SoleraL10n.t('numero_no_valido'));
    expect(validarNumeroOpcional('-3'), SoleraL10n.t('no_puede_ser_negativo'));
    expect(validarNumeroOpcional('-3', permitirNegativos: true), isNull);
    expect(validarNumeroOpcional('1.200', nullSiAmbiguo: true),
        SoleraL10n.t('numero_no_valido'));
  });

  test('importes', () {
    expect(validarImporteOpcional('1.200,50'), isNull);
    expect(validarImporteOpcional('1,2,3'), SoleraL10n.t('importe_no_valido'));
    expect(validarImporteObligatorio(''), SoleraL10n.t('importe_obligatorio'));
    expect(validarImporteObligatorio('0'), SoleraL10n.t('mayor_que_cero'));
    expect(validarImporteObligatorio('12'), isNull);
  });

  test('enteros', () {
    expect(leerEntero('12'), 12);
    expect(leerEntero('2,5'), isNull);
    expect(leerEntero('1.200'), isNull);
    expect(validarEnteroOpcional('2,5'),
        SoleraL10n.t('numero_entero_no_valido'));
    expect(validarEnteroOpcional(''), isNull);
  });

  test('numeroParaEditar usa coma y no deja puntos que parezcan millares', () {
    expect(numeroParaEditar(1.234), '1,234');
    expect(numeroParaEditar(1200), '1200');
    expect(numeroParaEditar(12.5), '12,5');
  });

  test('los avisos salen traducidos', () {
    SoleraL10n.idioma = 'eu';
    expect(validarNumeroOpcional('x'), 'Zenbaki okerra (adib. 12,5)');
  });
}
