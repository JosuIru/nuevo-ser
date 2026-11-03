import 'package:flutter_test/flutter_test.dart';
import 'package:solera_zunbeltz/servicios/aviso_al_momento.dart';
import 'package:solera_zunbeltz/servicios/servicio_avisos_fcm.dart';

void main() {
  group('AvisoAlMomento.desdeDatos', () {
    test('lee el mensaje que manda el plugin', () {
      final aviso = AvisoAlMomento.desdeDatos({
        'clase': 'alarma',
        'clave': 'aviso|a1',
        'titulo': 'Alarma gunean',
        'texto': 'Vaca suelta',
      })!;
      expect(aviso.clase, 'alarma');
      expect(aviso.clave, 'aviso|a1');
      expect(aviso.titulo, 'Alarma gunean');
      expect(aviso.texto, 'Vaca suelta');
      expect(aviso.urgente, isTrue);
    });

    test('peticiones normales y tareas no van por el canal urgente', () {
      for (final clase in ['peticion', 'tarea']) {
        expect(
            AvisoAlMomento.desdeDatos({'clase': clase, 'titulo': 'x'})!.urgente,
            isFalse);
      }
      expect(
          AvisoAlMomento.desdeDatos(
                  {'clase': 'peticion_urgente', 'titulo': 'x'})!
              .urgente,
          isTrue);
    });

    test('rechaza lo que no es nuestro', () {
      expect(AvisoAlMomento.desdeDatos({}), isNull);
      expect(
          AvisoAlMomento.desdeDatos({'clase': 'otra', 'titulo': 'x'}), isNull);
      expect(AvisoAlMomento.desdeDatos({'clase': 'alarma', 'titulo': ' '}),
          isNull);
      expect(
          AvisoAlMomento.desdeDatos({'clase': 'alarma', 'titulo': 3}), isNull);
    });

    test('sin clave ni texto, vale igual', () {
      final aviso =
          AvisoAlMomento.desdeDatos({'clase': 'tarea', 'titulo': 'Cierre'})!;
      expect(aviso.clave, '');
      expect(aviso.texto, '');
    });
  });

  group('idNotificacion', () {
    AvisoAlMomento aviso(String clave) =>
        AvisoAlMomento(clase: 'alarma', clave: clave, titulo: 't', texto: '');

    test('estable, distinto por cosa y lejos de los ids fijos', () {
      final ids = {
        for (final clave in ['aviso|a1', 'aviso|a2', 'tarea|t1', 'peticion|p1'])
          aviso(clave).idNotificacion
      };
      expect(ids, hasLength(4));
      expect(
          aviso('aviso|a1').idNotificacion, aviso('aviso|a1').idNotificacion);
      for (final id in ids) {
        expect(id, greaterThanOrEqualTo(1000));
        expect(id, lessThan(0x7fffffff));
      }
    });
  });

  test('huella del registro: cambia con la persona, el idioma o el móvil', () {
    String huella(
            {String token = 'abc', String idioma = 'es', String movil = 'm'}) =>
        huellaRegistroFcm(
            url: 'https://app.zunbeltz.com/',
            token: token,
            tokenFcm: movil,
            idioma: idioma);
    expect(huella(), huella());
    expect(
        huellaRegistroFcm(
            url: 'https://app.zunbeltz.com',
            token: 'abc ',
            tokenFcm: 'm',
            idioma: 'es'),
        huella(),
        reason: 'barra final y espacios no cuentan');
    expect(huella(token: 'otra'), isNot(huella()));
    expect(huella(idioma: 'eu'), isNot(huella()));
    expect(huella(movil: 'n'), isNot(huella()));
    expect(huella(), isNot(contains('abc')), reason: 'no guarda el token');
  });
}
