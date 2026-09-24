import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:las_versiones/datos/registro_maestria_archivo.dart';
import 'package:nuevo_ser_core/src/calibration/nivel_confianza.dart';

GestorPerfiles _gestor() => GestorPerfiles(
      namespace: 'nuevoser.lasversiones',
      sufijoNombreVisible: 'nombre_jugador',
      clavesGlobalesNoMigrables: const {'nuevoser.lasversiones.idioma_app'},
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  RegistroMaestriaArchivo registro(RepositorioHabilidades repositorio) =>
      RegistroMaestriaArchivo(
        repositorio: repositorio,
        reloj: () => DateTime.utc(2026, 9, 24, 10),
      );

  test('un acierto de HF.02 queda guardado en el perfil activo', () async {
    final repositorio = RepositorioHabilidades(gestor: _gestor());
    final estado = await registro(repositorio).registrar(
        idHabilidad: 'HF.02', acierto: true, duracion: const Duration(seconds: 4));
    expect(estado, isNotNull);
    final guardado = await repositorio.cargar('HF.02');
    expect(guardado!.totalExposiciones, 1);
    expect(guardado.intentosRecientes.single.acierto, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(),
        contains('nuevoser.lasversiones.perfil.principal.habilidad.HF.02'));
  });

  test('registros seguidos sin esperar no se pisan', () async {
    final repositorio = RepositorioHabilidades(gestor: _gestor());
    final motor = registro(repositorio);
    await Future.wait([
      for (var i = 0; i < 5; i++)
        motor.registrar(idHabilidad: 'HF.04', acierto: i.isEven, duracion: Duration.zero),
    ]);
    expect((await repositorio.cargar('HF.04'))!.totalExposiciones, 5);
  });

  test('AH.03 (P4) guarda declarado y canónico en la escala 0/0.5/1', () async {
    final repositorio = RepositorioHabilidades(gestor: _gestor());
    final estado = await registro(repositorio).registrar(
      idHabilidad: 'AH.03',
      acierto: true, // se ignora en P4: manda la coincidencia de niveles
      nivelDeclarado: NivelConfianza.solido,
      nivelCanonico: NivelConfianza.disputado,
      duracion: Duration.zero,
    );
    final intento = estado!.intentosRecientes.single;
    expect(intento.acierto, isFalse);
    expect(intento.confianzaDeclarada, 1.0);
    expect(intento.fiabilidadReal, 0.0);
    expect(estado.precision, 0.0, reason: 'sobreconfianza máxima');
  });

  test('AH.03 sin niveles no se apunta', () async {
    final repositorio = RepositorioHabilidades(gestor: _gestor());
    final estado = await registro(repositorio)
        .registrar(idHabilidad: 'AH.03', acierto: true, duracion: Duration.zero);
    expect(estado, isNull);
    expect(RegistroMaestriaArchivo.registrable('AH.03'), isTrue);
  });

  test('una habilidad sin perfil asignado no se registra', () async {
    expect(RegistroMaestriaArchivo.registrable('XX.99'), isFalse);
  });

  test('cada perfil de perfilesOperativos existe en el motor', () {
    final motor = MasteryEngine();
    for (final perfil in perfilesOperativos) {
      expect(() => motor.perfil(perfil), returnsNormally);
    }
  });

  test('HF.09 (P2) guarda señal y predicción, y el acierto es que coincidan',
      () async {
    final repositorio = RepositorioHabilidades(gestor: _gestor());
    final estado = await registro(repositorio).registrar(
      idHabilidad: 'HF.09',
      acierto: true, // se ignora en P2: manda la coincidencia
      senalEsperada: true,
      clasePredicha: false,
      duracion: Duration.zero,
    );
    final intento = estado!.intentosRecientes.single;
    expect(intento.acierto, isFalse);
    expect(intento.senalEsperada, isTrue);
    expect(intento.clasePredicha, isFalse);
  });

  test('una habilidad P2 sin señal ni predicción no se apunta', () async {
    final repositorio = RepositorioHabilidades(gestor: _gestor());
    final estado = await registro(repositorio)
        .registrar(idHabilidad: 'HF.09', acierto: true, duracion: Duration.zero);
    expect(estado, isNull);
    expect(await repositorio.cargar('HF.09'), isNull);
  });
}
