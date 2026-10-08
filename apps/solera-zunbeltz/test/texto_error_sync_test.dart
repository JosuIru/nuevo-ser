import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/l10n/app_localizations_eu.dart';
import 'package:solera_zunbeltz/servicios/cliente_sync_zunbeltz.dart';
import 'package:solera_zunbeltz/utiles/texto_error_sync.dart';

void main() {
  final textos = AppLocalizationsEu();

  test('cada motivo tiene su texto traducido', () {
    expect(
        textoErrorSync(
            ErrorSyncZunbeltz('x', motivo: MotivoErrorSync.token), textos),
        textos.errorSyncToken);
    expect(
        textoErrorSync(
            ErrorSyncZunbeltz('x',
                motivo: MotivoErrorSync.servidor, codigoHttp: 502),
            textos),
        contains('502'));
  });

  test('un error cualquiera también tiene mensaje', () {
    expect(textoErrorSync(const FormatException('html'), textos),
        textos.errorSyncRespuesta);
  });
}
