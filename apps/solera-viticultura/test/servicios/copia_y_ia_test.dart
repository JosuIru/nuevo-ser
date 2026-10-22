import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:solera_viticultura/datos/base_datos.dart';
import 'package:solera_viticultura/estado/clave_ia.dart';
import 'package:solera_viticultura/pantallas/pantalla_backup.dart';
import 'package:solera_viticultura/servicios/analizador_foto_vid.dart';
import 'package:solera_viticultura/servicios/backup_servicio.dart';

void main() {
  group('Configuración de la copia de seguridad', () {
    final configuracion = configuracionCopiaSeguridadViticultura();

    test('conserva identificador, BD y nombre de ZIP de siempre', () {
      expect(configuracion.identificadorApp, 'solera_viticultura');
      expect(configuracion.nombreFicheroBaseDatos, 'solera_viticultura.db');
      expect(configuracion.prefijoNombreCopia, 'solera-viticultura-backup');
      expect(configuracion.carpetasExtra, contains('fotos'));
    });

    test('el esquema es el que abre la BD', () {
      expect(configuracion.versionEsquemaActual, versionEsquemaBaseDatosViticultura);
      expect(versionEsquemaBaseDatosViticultura, 3);
    });

    test('no copia preferencias (la clave de Anthropic no viaja)', () {
      expect(configuracion.prefijosPreferencias, isEmpty);
      expect(configuracion.clavesPreferencias, isEmpty);
      expect(configuracion.comprobarIntegridad, isNotNull);
    });
  });

  group('Clave de Anthropic', () {
    test('se lee de la preferencia de siempre', () {
      expect(estadoClaveAnthropicViticultura.claveAlmacenamiento,
          'solera_viticultura.anthropic.clave');
    });
  });

  group('Textos de error de la copia', () {
    test('dice que los datos no se han tocado solo si es verdad', () {
      const rechazada = ErrorCopiaSeguridad(MotivoErrorCopiaSeguridad.deOtraApp, 'x');
      expect(textoErrorCopiaSeguridad(rechazada), contains('no se han tocado'));

      final fallidaSinVuelta = ErrorCopiaSeguridad(
        MotivoErrorCopiaSeguridad.reversionFallida,
        'x',
        respaldoPrevio: File('/datos/copias_automaticas/antes-de-restaurar.zip'),
      );
      final texto = textoErrorCopiaSeguridad(fallidaSinVuelta);
      expect(texto, isNot(contains('no se han tocado')));
      expect(texto, contains('antes-de-restaurar.zip'));
    });

    test('todos los motivos tienen texto', () {
      for (final motivo in MotivoErrorCopiaSeguridad.values) {
        expect(textoErrorCopiaSeguridad(ErrorCopiaSeguridad(motivo, 'x')), isNotEmpty);
      }
    });
  });

  group('Lectura del diagnóstico de la IA', () {
    test('lee un JSON completo', () {
      final resultado = ResultadoAnalisisIA.desdeJson({
        'nombre_comun': 'Mildiu',
        'nombre_cientifico': 'Plasmopara viticola',
        'tipo': 'enfermedad',
        'severidad': 3,
        'confianza': 0.8,
        'manejo_cultural': 'Deshojado.',
        'advertencia': '',
      });
      expect(resultado.nombreComun, 'Mildiu');
      expect(resultado.tipo, 'enfermedad');
      expect(resultado.severidad, 3);
      expect(resultado.confianza, 0.8);
    });

    test('tolera campos ausentes o raros', () {
      final resultado = ResultadoAnalisisIA.desdeJson({'severidad': 9, 'confianza': 1.7});
      expect(resultado.nombreComun, 'Sin diagnóstico');
      expect(resultado.tipo, 'indeterminado');
      expect(resultado.severidad, 5);
      expect(resultado.confianza, 1.0);
    });

    test('el prompt incluye las observaciones', () {
      expect(construirPromptAnalisisVid('manchas aceitosas'), contains('manchas aceitosas'));
    });
  });
}
