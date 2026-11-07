import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

PlazoLegal _plazoAnual({
  String identificador = 'anual',
  List<String> verticales = const ['agro'],
  required int diaInicio,
  required int mesInicio,
  required int diaFin,
  required int mesFin,
  int antelacionAvisoDias = 0,
}) {
  return PlazoLegal(
    identificador: identificador,
    verticales: verticales,
    nombreVisible: 'Plazo anual de prueba',
    normaCitada: 'Norma de prueba',
    urlFuente: 'https://www.boe.es/',
    periodicidad: PeriodicidadAnual(
      diaInicio: diaInicio,
      mesInicio: mesInicio,
      diaFin: diaFin,
      mesFin: mesFin,
    ),
    antelacionAvisoDias: antelacionAvisoDias,
  );
}

PlazoLegal _plazoMensual({
  String identificador = 'mensual',
  List<String> verticales = const ['aceitera'],
  required int diaLimite,
  int antelacionAvisoDias = 0,
}) {
  return PlazoLegal(
    identificador: identificador,
    verticales: verticales,
    nombreVisible: 'Plazo mensual de prueba',
    normaCitada: 'Norma de prueba',
    urlFuente: 'https://www.boe.es/',
    periodicidad: PeriodicidadMensual(diaLimite: diaLimite),
    antelacionAvisoDias: antelacionAvisoDias,
  );
}

PlazoLegal _plazoTrimestral({
  String identificador = 'trimestral',
  List<String> verticales = const ['agro', 'quesera'],
  int diaLimite = 20,
  int? diaLimiteCuartoTrimestre = 30,
  int antelacionAvisoDias = 0,
}) {
  return PlazoLegal(
    identificador: identificador,
    verticales: verticales,
    nombreVisible: 'Plazo trimestral de prueba',
    normaCitada: 'Norma de prueba',
    urlFuente: 'https://www.boe.es/',
    periodicidad: PeriodicidadTrimestral(
      diaLimite: diaLimite,
      diaLimiteCuartoTrimestre: diaLimiteCuartoTrimestre,
    ),
    antelacionAvisoDias: antelacionAvisoDias,
  );
}

void main() {
  group('proximaOcurrencia — anual con ventana fija', () {
    final plazoPac =
        _plazoAnual(diaInicio: 1, mesInicio: 2, diaFin: 30, mesFin: 4);

    test('antes de abrir la ventana devuelve la de este año', () {
      final ocurrencia = proximaOcurrencia(plazoPac, DateTime(2027, 1, 10));
      expect(ocurrencia.inicio, DateTime(2027, 2, 1));
      expect(ocurrencia.fin, DateTime(2027, 4, 30));
    });

    test('dentro de la ventana devuelve la vigente', () {
      final ocurrencia = proximaOcurrencia(plazoPac, DateTime(2027, 3, 15));
      expect(ocurrencia.inicio, DateTime(2027, 2, 1));
      expect(ocurrencia.fin, DateTime(2027, 4, 30));
      expect(ocurrencia.estaAbierta(DateTime(2027, 3, 15)), isTrue);
    });

    test('el propio día límite sigue siendo la ocurrencia vigente', () {
      final ocurrencia = proximaOcurrencia(plazoPac, DateTime(2027, 4, 30));
      expect(ocurrencia.fin, DateTime(2027, 4, 30));
      expect(ocurrencia.estaAbierta(DateTime(2027, 4, 30)), isTrue);
    });

    test('la hora del día no cuenta: el día límite a las 23:59 vale', () {
      final ocurrencia =
          proximaOcurrencia(plazoPac, DateTime(2027, 4, 30, 23, 59));
      expect(ocurrencia.fin, DateTime(2027, 4, 30));
    });

    test('el día siguiente al límite salta al año próximo', () {
      final ocurrencia = proximaOcurrencia(plazoPac, DateTime(2027, 5, 1));
      expect(ocurrencia.inicio, DateTime(2028, 2, 1));
      expect(ocurrencia.fin, DateTime(2028, 4, 30));
    });

    test('ventana de un solo día (inicio = fin)', () {
      final plazoUnDia =
          _plazoAnual(diaInicio: 10, mesInicio: 12, diaFin: 10, mesFin: 12);
      final ocurrencia = proximaOcurrencia(plazoUnDia, DateTime(2026, 12, 10));
      expect(ocurrencia.inicio, DateTime(2026, 12, 10));
      expect(ocurrencia.fin, DateTime(2026, 12, 10));
      expect(proximaOcurrencia(plazoUnDia, DateTime(2026, 12, 11)).fin,
          DateTime(2027, 12, 10));
    });
  });

  group('proximaOcurrencia — ventana que cruza fin de año', () {
    final plazoInvierno =
        _plazoAnual(diaInicio: 15, mesInicio: 11, diaFin: 15, mesFin: 2);

    test('en diciembre la ventana abierta termina el año siguiente', () {
      final ocurrencia =
          proximaOcurrencia(plazoInvierno, DateTime(2026, 12, 20));
      expect(ocurrencia.inicio, DateTime(2026, 11, 15));
      expect(ocurrencia.fin, DateTime(2027, 2, 15));
    });

    test('en enero sigue vigente la ventana abierta el año anterior', () {
      final ocurrencia = proximaOcurrencia(plazoInvierno, DateTime(2027, 1, 5));
      expect(ocurrencia.inicio, DateTime(2026, 11, 15));
      expect(ocurrencia.fin, DateTime(2027, 2, 15));
    });

    test('tras cerrar en febrero la próxima abre en noviembre', () {
      final ocurrencia =
          proximaOcurrencia(plazoInvierno, DateTime(2027, 2, 16));
      expect(ocurrencia.inicio, DateTime(2027, 11, 15));
      expect(ocurrencia.fin, DateTime(2028, 2, 15));
    });

    test('mismo mes con día fin anterior al de inicio también cruza', () {
      final plazoCasiAnual =
          _plazoAnual(diaInicio: 20, mesInicio: 3, diaFin: 10, mesFin: 3);
      final ocurrencia =
          proximaOcurrencia(plazoCasiAnual, DateTime(2027, 1, 1));
      expect(ocurrencia.inicio, DateTime(2026, 3, 20));
      expect(ocurrencia.fin, DateTime(2027, 3, 10));
    });
  });

  group('proximaOcurrencia — 29 de febrero', () {
    // «Antes del 1 de marzo»: el último día es el 29 en bisiesto y el
    // 28 en los demás años.
    final plazoCenso =
        _plazoAnual(diaInicio: 1, mesInicio: 1, diaFin: 29, mesFin: 2);

    test('en año bisiesto el límite es el 29 de febrero', () {
      final ocurrencia = proximaOcurrencia(plazoCenso, DateTime(2028, 2, 10));
      expect(ocurrencia.fin, DateTime(2028, 2, 29));
    });

    test('en año no bisiesto se ajusta al 28 de febrero', () {
      final ocurrencia = proximaOcurrencia(plazoCenso, DateTime(2027, 2, 10));
      expect(ocurrencia.fin, DateTime(2027, 2, 28));
    });

    test('el 28 de febrero de año bisiesto aún no ha vencido', () {
      final ocurrencia = proximaOcurrencia(plazoCenso, DateTime(2028, 2, 28));
      expect(ocurrencia.fin, DateTime(2028, 2, 29));
    });

    test('el 1 de marzo de año no bisiesto pasa al año siguiente', () {
      final ocurrencia = proximaOcurrencia(plazoCenso, DateTime(2027, 3, 1));
      expect(ocurrencia.fin, DateTime(2028, 2, 29));
    });

    test('ventana que empieza el 29 de febrero se ajusta al 28', () {
      final plazoRaro =
          _plazoAnual(diaInicio: 29, mesInicio: 2, diaFin: 31, mesFin: 3);
      final ocurrencia = proximaOcurrencia(plazoRaro, DateTime(2027, 1, 1));
      expect(ocurrencia.inicio, DateTime(2027, 2, 28));
    });
  });

  group('proximaOcurrencia — mensual', () {
    final plazoAica = _plazoMensual(diaLimite: 10);

    test('antes del día límite devuelve el de este mes', () {
      final ocurrencia = proximaOcurrencia(plazoAica, DateTime(2026, 11, 7));
      expect(ocurrencia.inicio, DateTime(2026, 11, 1));
      expect(ocurrencia.fin, DateTime(2026, 11, 10));
    });

    test('el propio día límite sigue vigente', () {
      final ocurrencia = proximaOcurrencia(plazoAica, DateTime(2026, 11, 10));
      expect(ocurrencia.fin, DateTime(2026, 11, 10));
    });

    test('pasado el día límite salta al mes siguiente', () {
      final ocurrencia = proximaOcurrencia(plazoAica, DateTime(2026, 11, 11));
      expect(ocurrencia.fin, DateTime(2026, 12, 10));
    });

    test('pasado el límite de diciembre salta a enero del año próximo', () {
      final ocurrencia = proximaOcurrencia(plazoAica, DateTime(2026, 12, 15));
      expect(ocurrencia.inicio, DateTime(2027, 1, 1));
      expect(ocurrencia.fin, DateTime(2027, 1, 10));
    });

    test('día límite 31 se ajusta al último día de meses cortos', () {
      final plazoFinDeMes = _plazoMensual(diaLimite: 31);
      expect(proximaOcurrencia(plazoFinDeMes, DateTime(2027, 2, 3)).fin,
          DateTime(2027, 2, 28));
      expect(proximaOcurrencia(plazoFinDeMes, DateTime(2028, 2, 3)).fin,
          DateTime(2028, 2, 29));
      expect(proximaOcurrencia(plazoFinDeMes, DateTime(2027, 4, 30)).fin,
          DateTime(2027, 4, 30));
    });
  });

  group('proximaOcurrencia — trimestral', () {
    final plazoIva = _plazoTrimestral();

    test('en febrero el próximo es el 20 de abril (1T)', () {
      final ocurrencia = proximaOcurrencia(plazoIva, DateTime(2027, 2, 14));
      expect(ocurrencia.inicio, DateTime(2027, 4, 1));
      expect(ocurrencia.fin, DateTime(2027, 4, 20));
    });

    test('el 20 de abril es el propio día límite', () {
      final ocurrencia = proximaOcurrencia(plazoIva, DateTime(2027, 4, 20));
      expect(ocurrencia.fin, DateTime(2027, 4, 20));
    });

    test('el 21 de abril salta al 20 de julio', () {
      final ocurrencia = proximaOcurrencia(plazoIva, DateTime(2027, 4, 21));
      expect(ocurrencia.fin, DateTime(2027, 7, 20));
    });

    test('tras octubre el próximo es el 30 de enero (4T)', () {
      final ocurrencia = proximaOcurrencia(plazoIva, DateTime(2026, 11, 7));
      expect(ocurrencia.inicio, DateTime(2027, 1, 1));
      expect(ocurrencia.fin, DateTime(2027, 1, 30));
    });

    test('el 25 de enero sigue abierto el 4T del año anterior', () {
      final ocurrencia = proximaOcurrencia(plazoIva, DateTime(2027, 1, 25));
      expect(ocurrencia.fin, DateTime(2027, 1, 30));
      expect(ocurrencia.estaAbierta(DateTime(2027, 1, 25)), isTrue);
    });

    test('sin día especial del 4T usa el mismo día límite en enero', () {
      final plazoUniforme = _plazoTrimestral(diaLimiteCuartoTrimestre: null);
      final ocurrencia =
          proximaOcurrencia(plazoUniforme, DateTime(2026, 12, 1));
      expect(ocurrencia.fin, DateTime(2027, 1, 20));
    });
  });

  group('plazosQueAvisanHoy', () {
    final plazoPac = _plazoAnual(
        identificador: 'pac',
        diaInicio: 1,
        mesInicio: 2,
        diaFin: 30,
        mesFin: 4,
        antelacionAvisoDias: 15);
    final plazoAica = _plazoMensual(
        identificador: 'aica', diaLimite: 10, antelacionAvisoDias: 5);
    final plazoSinAntelacion =
        _plazoMensual(identificador: 'sin_antelacion', diaLimite: 20);
    final todos = [plazoPac, plazoAica, plazoSinAntelacion];

    test('avisa dentro de la antelación y no fuera', () {
      final avisos = plazosQueAvisanHoy(todos, DateTime(2027, 4, 15));
      expect(avisos.map((aviso) => aviso.plazo.identificador), ['pac']);
      expect(avisos.single.diasRestantes, 15);
    });

    test('el día anterior a la antelación no avisa', () {
      expect(plazosQueAvisanHoy([plazoPac], DateTime(2027, 4, 14)), isEmpty);
    });

    test('el propio día límite avisa con 0 días restantes', () {
      final avisos = plazosQueAvisanHoy(todos, DateTime(2027, 4, 30));
      final avisoPac =
          avisos.singleWhere((aviso) => aviso.plazo.identificador == 'pac');
      expect(avisoPac.diasRestantes, 0);
      expect(avisoPac.ocurrencia.fin, DateTime(2027, 4, 30));
    });

    test('pasado el día límite deja de avisar', () {
      expect(plazosQueAvisanHoy([plazoPac], DateTime(2027, 5, 1)), isEmpty);
    });

    test('antelación 0 avisa solo el día límite', () {
      expect(plazosQueAvisanHoy([plazoSinAntelacion], DateTime(2027, 3, 19)),
          isEmpty);
      expect(
          plazosQueAvisanHoy([plazoSinAntelacion], DateTime(2027, 3, 20))
              .single
              .diasRestantes,
          0);
    });

    test('ordena los avisos por día límite más cercano', () {
      final plazoPacTardio = _plazoAnual(
          identificador: 'pac_tardio',
          diaInicio: 1,
          mesInicio: 2,
          diaFin: 30,
          mesFin: 4,
          antelacionAvisoDias: 40);
      final avisos =
          plazosQueAvisanHoy([plazoPacTardio, plazoAica], DateTime(2027, 4, 6));
      expect(avisos.map((aviso) => aviso.plazo.identificador),
          ['aica', 'pac_tardio']);
    });

    test('antelación que cruza el fin de año', () {
      final plazoEnero =
          _plazoTrimestral(identificador: 'iva', antelacionAvisoDias: 35);
      final avisos = plazosQueAvisanHoy([plazoEnero], DateTime(2026, 12, 26));
      expect(avisos.single.ocurrencia.fin, DateTime(2027, 1, 30));
      expect(avisos.single.diasRestantes, 35);
    });

    test('lista vacía no avisa de nada', () {
      expect(plazosQueAvisanHoy(const [], DateTime(2027, 4, 30)), isEmpty);
    });
  });

  group('plazosDeVertical', () {
    final plazoAgro = _plazoAnual(
        identificador: 'solo_agro',
        verticales: ['agro'],
        diaInicio: 1,
        mesInicio: 1,
        diaFin: 2,
        mesFin: 1);
    final plazoCompartido = _plazoTrimestral(
        identificador: 'compartido', verticales: ['agro', 'quesera']);
    final plazoAceitera = _plazoMensual(
        identificador: 'solo_aceitera',
        verticales: ['aceitera'],
        diaLimite: 10);
    final todos = [plazoAgro, plazoCompartido, plazoAceitera];

    test('devuelve los que aplican a la vertical, en el orden original', () {
      expect(plazosDeVertical(todos, 'agro').map((p) => p.identificador),
          ['solo_agro', 'compartido']);
      expect(plazosDeVertical(todos, 'quesera').map((p) => p.identificador),
          ['compartido']);
    });

    test('vertical sin plazos devuelve lista vacía', () {
      expect(plazosDeVertical(todos, 'apicola'), isEmpty);
    });

    test('vertical inexistente devuelve lista vacía, sin excepción', () {
      expect(plazosDeVertical(todos, 'pesca'), isEmpty);
      expect(plazosDeVertical(todos, ''), isEmpty);
    });

    test('no distingue mayúsculas ni espacios alrededor', () {
      expect(plazosDeVertical(todos, ' Aceitera ').map((p) => p.identificador),
          ['solo_aceitera']);
    });
  });
}
