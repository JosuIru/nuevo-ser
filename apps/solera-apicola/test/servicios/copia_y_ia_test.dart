import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solera_apicola/datos/base_datos.dart';
import 'package:solera_apicola/pantallas/pantalla_backup.dart';
import 'package:solera_apicola/pantallas/pantalla_registros.dart';
import 'package:solera_apicola/servicios/cliente_anthropic.dart';
import 'package:solera_apicola/servicios/copia_seguridad_apicola.dart';

void main() {
  group('Copia de seguridad', () {
    test('conserva identificador, BD, prefijo y esquema de siempre', () {
      final configuracion = configuracionCopiaSeguridadApicola();
      expect(configuracion.identificadorApp, 'solera_apicola');
      expect(configuracion.nombreFicheroBaseDatos, 'solera_apicola.db');
      expect(configuracion.nombreFicheroBaseDatos, nombreFicheroBaseDatosApicola);
      expect(configuracion.prefijoNombreCopia, 'solera-apicola-backup');
      expect(configuracion.versionEsquemaActual, versionEsquemaBaseDatosApicola);
      expect(versionEsquemaBaseDatosApicola, 2);
      expect(configuracion.comprobarIntegridad, isNotNull);
    });

    test('la fecha de la última copia se lee de la preferencia antigua', () async {
      final fecha = DateTime(2026, 9, 1, 10, 30);
      SharedPreferences.setMockInitialValues({
        'solera_apicola.backup.ultimo_ms': fecha.millisecondsSinceEpoch,
      });
      expect(await servicioCopiaSeguridadApicola.ultimaCopia(), fecha);
    });

    test('solo dice que los datos no se han tocado cuando es verdad', () {
      const revertida = ErrorCopiaSeguridad(
          MotivoErrorCopiaSeguridad.restauracionRevertida, 'x');
      const sinVuelta = ErrorCopiaSeguridad(
          MotivoErrorCopiaSeguridad.reversionFallida, 'x');
      expect(textoErrorCopiaSeguridad(revertida), contains('no se han tocado'));
      expect(textoErrorCopiaSeguridad(sinVuelta), isNot(contains('no se han tocado')));
      for (final motivo in MotivoErrorCopiaSeguridad.values) {
        expect(textoErrorCopiaSeguridad(ErrorCopiaSeguridad(motivo, 'x')), isNotEmpty);
      }
    });
  });

  group('IA', () {
    test('la clave se sigue leyendo de solera_apicola.anthropic.clave', () async {
      SharedPreferences.setMockInitialValues({
        'solera_apicola.anthropic.clave': 'sk-ant-1234567890abcdef',
      });
      expect(estadoClaveAnthropicApicola.claveAlmacenamiento, 'solera_apicola.anthropic.clave');
      expect(await estadoClaveAnthropicApicola.tieneClave(), isTrue);
    });

    test('el diagnóstico se lee del JSON y acota la confianza', () {
      final resultado = ResultadoAnalisisIA.desdeJson({
        'nombre_comun': 'Loque americana',
        'nombre_cientifico': 'Paenibacillus larvae',
        'tipo': 'infeccion',
        'severidad': 4,
        'confianza': 1.7,
        'manejo_cultural': 'Aislar la colmena.',
        'declaracion_oficial_sugerida': true,
      });
      expect(resultado.nombreComun, 'Loque americana');
      expect(resultado.severidad, 4);
      expect(resultado.confianza, 1.0);
      expect(resultado.advertencia, '');
      expect(resultado.declaracionOficialSugerida, isTrue);

      final vacio = ResultadoAnalisisIA.desdeJson({});
      expect(vacio.tipo, 'indeterminado');
      expect(vacio.severidad, isNull);
      expect(vacio.confianza, 0);
    });
  });

  testWidgets('Registros lista los libros y documentos', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaRegistros()));
    expect(find.text('Libro REGA'), findsOneWidget);
    expect(find.text('Extracto económico'), findsOneWidget);
    expect(find.text(SoleraL10n.t('facturas')), findsOneWidget);
    expect(find.text(SoleraL10n.t('libro_economico')), findsOneWidget);
  });
}
