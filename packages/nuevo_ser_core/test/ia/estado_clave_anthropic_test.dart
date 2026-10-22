import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/src/ia/estado_clave_anthropic.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const claveDePrueba = 'sk-ant-api03-abcdefghijklmnop';

  test('lee sin migrar la clave guardada por agro', () async {
    SharedPreferences.setMockInitialValues(
        {'agro.anthropic.clave': '  $claveDePrueba '});
    final estado = EstadoClaveAnthropic.paraApp('agro');
    expect(estado.claveAlmacenamiento, 'agro.anthropic.clave');
    expect(await estado.cargar(), claveDePrueba);
    expect(await estado.tieneClave(), isTrue);
    expect(estado.hayClave.value, isTrue);
  });

  test('lee sin migrar la clave guardada por apícola', () async {
    SharedPreferences.setMockInitialValues(
        {'solera_apicola.anthropic.clave': claveDePrueba});
    final estado = EstadoClaveAnthropic(
        claveAlmacenamiento: 'solera_apicola.anthropic.clave');
    expect(await estado.cargar(), claveDePrueba);
    // La de otra app no se ve.
    expect(await EstadoClaveAnthropic.paraApp('agro').cargar(), isNull);
  });

  test('guarda, avisa y borra', () async {
    SharedPreferences.setMockInitialValues({});
    final estado = EstadoClaveAnthropic.paraApp('solera_quesera');
    expect(await estado.cargar(), isNull);
    expect(estado.hayClave.value, isFalse);

    await estado.guardar(' $claveDePrueba ');
    expect(estado.hayClave.value, isTrue);
    final preferencias = await SharedPreferences.getInstance();
    expect(preferencias.getString('solera_quesera.anthropic.clave'),
        claveDePrueba);

    await estado.borrar();
    expect(estado.hayClave.value, isFalse);
    expect(preferencias.containsKey('solera_quesera.anthropic.clave'), isFalse);
  });

  test('una clave corta se guarda pero no cuenta como válida', () async {
    SharedPreferences.setMockInitialValues({});
    final estado = EstadoClaveAnthropic.paraApp('agro');
    await estado.guardar('corta');
    expect(await estado.cargar(), 'corta');
    expect(await estado.tieneClave(), isFalse);
    expect(estado.hayClave.value, isFalse);
  });

  test('guardar vacío borra', () async {
    SharedPreferences.setMockInitialValues(
        {'agro.anthropic.clave': claveDePrueba});
    final estado = EstadoClaveAnthropic.paraApp('agro');
    await estado.guardar('   ');
    expect(await estado.cargar(), isNull);
  });
}
