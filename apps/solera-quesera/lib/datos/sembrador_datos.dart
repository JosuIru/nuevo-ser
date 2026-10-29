import 'dart:math';

import 'base_datos.dart';
import '../modelos/analitica.dart';
import '../modelos/control_limpieza.dart';
import '../modelos/control_plagas.dart';
import '../modelos/control_temperatura.dart';
import '../modelos/evento_curacion.dart';
import '../modelos/incidencia.dart';
import '../modelos/lote_produccion.dart';
import '../modelos/partida_leche.dart';
import '../modelos/proveedor_leche.dart';
import '../modelos/queseria.dart';
import '../modelos/receta.dart';
import '../modelos/venta.dart';

/// Sembrador de datos de demostración para Larrea Quesera.
///
/// Inserta una quesería ficticia con 2 proveedores, 2 recetas,
/// 10 partidas de leche, 4 lotes de producción con sus piezas,
/// eventos de curación, controles APPCC y 2 incidencias cerradas.
///
/// Toda la trazabilidad es coherente: las partidas alimentan lotes
/// y los lotes tienen ventas asociadas, para que la simulación de
/// trazabilidad funcione end-to-end.
class SembradorDatos {
  static final SembradorDatos instancia = SembradorDatos._interno();
  factory SembradorDatos() => instancia;
  SembradorDatos._interno();

  final _bd = BaseDatosSoleraQuesera.instancia;
  final _rng = Random(42); // semilla fija → datos reproducibles

  /// ¿Ya hay datos sembrados?
  Future<bool> hayDatos() async {
    final lotes = await _bd.listarLotes();
    return lotes.isNotEmpty;
  }

  /// Inserta datos de demostración.
  Future<void> sembrar() async {
    if (await hayDatos()) return;

    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    // ─── Quesería ─────────────────────────────────
    await _bd.guardarQueseria(Queseria(
      razonSocial: 'Quesería Artzai Gazta',
      nif: '12345678A',
      rgseaa: '10.01234/SS',
      direccion: 'Barrio Olabide 12, 20200 Beasain, Gipuzkoa',
      telefono: '943 12 34 56',
      email: 'info@artzaigazta.eus',
      latitud: 43.05,
      longitud: -2.18,
    ));

    // ─── Proveedores ──────────────────────────────
    final rebanioPropio = await _bd.guardarProveedor(ProveedorLeche(
      nombre: 'Rebaño propio — Artzai',
      esPropio: true,
      tipoLeche: 'oveja',
      razaId: 'latxa',
      numAnimales: 120,
      explotacionGanadera: 'ES-20-12345',
      latitud: 43.05,
      longitud: -2.18,
      fechaCreacionMs: hoy
          .subtract(const Duration(days: 365))
          .millisecondsSinceEpoch,
    ));

    final proveedorGorriti = await _bd.guardarProveedor(ProveedorLeche(
      nombre: 'Gorriti Ane — Gorriti Ganadera',
      nif: '87654321B',
      tipoLeche: 'oveja',
      razaId: 'latxa',
      numAnimales: 80,
      explotacionGanadera: 'ES-20-54321',
      latitud: 42.98,
      longitud: -2.25,
      fechaCreacionMs: hoy
          .subtract(const Duration(days: 200))
          .millisecondsSinceEpoch,
    ));

    // ─── Recetas ──────────────────────────────────
    await _bd.guardarReceta(Receta(
      nombre: 'Idiazabal semicurado',
      tipoQuesoId: 'idiazabal_semicurado',
      doId: 'idiazabal',
      tipoLeche: 'oveja',
      fermento: 'Lactococcus lactis + Lc. cremoris',
      tipoCuajo: 'animal (cordero)',
      tempCoagulacion: 30,
      tiempoCoagMinutos: 35,
      tamCuajada: 'grano medio',
      tempCocion: 38,
      rendimientoEsperado: 8,
      curacionMinimaDias: 60,
    ));

    await _bd.guardarReceta(Receta(
      nombre: 'Idiazabal curado',
      tipoQuesoId: 'idiazabal_curado',
      doId: 'idiazabal',
      tipoLeche: 'oveja',
      fermento: 'Lactococcus lactis + Lc. cremoris',
      tipoCuajo: 'animal (cordero)',
      tempCoagulacion: 30,
      tiempoCoagMinutos: 40,
      tamCuajada: 'grano fino',
      tempCocion: 40,
      rendimientoEsperado: 9,
      curacionMinimaDias: 120,
    ));

    // ─── Partidas de leche (10 partidas en 10 días) ──
    final partidaIds = <int>[];
    for (int i = 0; i < 10; i++) {
      final dia = hoy.subtract(Duration(days: 80 - i));
      final proveedor = i % 3 == 0 ? rebanioPropio : proveedorGorriti;
      final volumen = 80 + _rng.nextInt(60);
      final id = await _bd.guardarPartidaLeche(PartidaLeche(
        proveedorId: proveedor,
        fechaMs: dia.millisecondsSinceEpoch,
        volumenLitros: volumen.toDouble(),
        temperaturaRecepcion: 4.0 + _rng.nextDouble(),
        ph: 6.6 + _rng.nextDouble() * 0.2,
        grasa: 6.0 + _rng.nextDouble(),
        proteina: 5.0 + _rng.nextDouble() * 0.5,
        extractoSeco: 16 + _rng.nextDouble() * 2,
        celulasSomaticas: 100 + _rng.nextDouble() * 300,
        bacterias: 5 + _rng.nextDouble() * 15,
        antibioticosPositivos: false,
      ));
      partidaIds.add(id);
    }

    // Recuperar recetas para usar sus IDs
    final recetas = await _bd.listarRecetas();
    final recetaSemicurado = recetas[0].id!;
    final recetaCurado = recetas[1].id!;

    // ─── Lotes de producción (4 lotes) ─────────────
    final lotesData = [
      {
        'numLote': '${_fmtFecha(hoy.subtract(const Duration(days: 75)))}-001',
        'fecha': hoy.subtract(const Duration(days: 75)),
        'recetaId': recetaSemicurado,
        'tipo': 'idiazabal_semicurado',
        'doId': 'idiazabal',
        'volumen': 200,
        'peso': 24.5,
        'piezas': 12,
        'partidas': [partidaIds[0], partidaIds[1]],
      },
      {
        'numLote': '${_fmtFecha(hoy.subtract(const Duration(days: 70)))}-001',
        'fecha': hoy.subtract(const Duration(days: 70)),
        'recetaId': recetaCurado,
        'tipo': 'idiazabal_curado',
        'doId': 'idiazabal',
        'volumen': 180,
        'peso': 20.0,
        'piezas': 10,
        'partidas': [partidaIds[2], partidaIds[3]],
      },
      {
        'numLote': '${_fmtFecha(hoy.subtract(const Duration(days: 60)))}-001',
        'fecha': hoy.subtract(const Duration(days: 60)),
        'recetaId': recetaSemicurado,
        'tipo': 'idiazabal_semicurado',
        'doId': 'idiazabal',
        'volumen': 220,
        'peso': 27.0,
        'piezas': 14,
        'partidas': [partidaIds[4], partidaIds[5], partidaIds[6]],
      },
      {
        'numLote': '${_fmtFecha(hoy.subtract(const Duration(days: 45)))}-001',
        'fecha': hoy.subtract(const Duration(days: 45)),
        'recetaId': recetaSemicurado,
        'tipo': 'idiazabal_semicurado',
        'doId': 'idiazabal',
        'volumen': 190,
        'peso': 23.0,
        'piezas': 11,
        'partidas': [partidaIds[7], partidaIds[8]],
      },
    ];

    for (final ld in lotesData) {
      final loteId = await _bd.guardarLote(LoteProduccion(
        numeroLote: ld['numLote'] as String,
        fechaMs: (ld['fecha'] as DateTime).millisecondsSinceEpoch,
        recetaId: ld['recetaId'] as int,
        tipoQuesoId: ld['tipo'] as String,
        doId: ld['doId'] as String,
        partidasLecheUsadasJson:
            (ld['partidas'] as List<int>).toString(),
        volumenLecheTotal: (ld['volumen'] as int).toDouble(),
        pesoTotalObtenido: (ld['peso'] as num).toDouble(),
        rendimientoReal: (ld['volumen'] as int) / (ld['peso'] as num),
        numPiezasProducidas: ld['piezas'] as int,
        pesoMedioPieza: (ld['peso'] as num) / (ld['piezas'] as int),
        fermentoNombre: 'Lactococcus lactis + Lc. cremoris',
        fermentoLoteComercial: 'CHR-HANSEN-F201-${_rng.nextInt(999)}',
        cuajoTipo: 'animal (cordero)',
        cuajoLoteComercial: 'CU-2026-${_rng.nextInt(99)}',
        salLote: 'SAL-GIP-2025-${_rng.nextInt(99)}',
        tempCoagulacion: 30,
        tiempoCoagMinutos: 35,
        phCuajada: 6.3 + _rng.nextDouble() * 0.2,
        estado: 'lista',
        fechaCreacionMs: (ld['fecha'] as DateTime)
            .millisecondsSinceEpoch,
      ));

      // Crear piezas
      final numPiezas = ld['piezas'] as int;
      final pesoInicial = (ld['peso'] as num) / numPiezas;
      await _bd.generarPiezasParaLote(
          loteId, ld['numLote'] as String, numPiezas, pesoInicial);

      // Eventos de curación (volteos cada 15 días)
      final piezas = await _bd.listarPiezas(loteId: loteId);
      for (final p in piezas) {
        final fechaLote = ld['fecha'] as DateTime;
        for (int v = 15; v <= 60; v += 15) {
          await _bd.guardarEventoCuracion(EventoCuracion(
            piezaId: p.id!,
            fechaMs: fechaLote
                .add(Duration(days: v))
                .millisecondsSinceEpoch,
            tipo: 'volteo',
            pesoActual: pesoInicial * (1 - 0.02 * v / 15),
            fechaCreacionMs: fechaLote
                .add(Duration(days: v))
                .millisecondsSinceEpoch,
          ));
        }
      }

      // Analíticas
      await _bd.guardarAnalitica(Analitica(
        fechaMs: (ld['fecha'] as DateTime)
            .add(const Duration(days: 7))
            .millisecondsSinceEpoch,
        tipo: 'microbiologica',
        laboratorio: 'LAB-ALAI S.L.',
        loteProduccionId: loteId,
        parametrosJson:
            '{"E. coli": "<10 ufc/g", "Listeria": "ausencia/25g", "Salmonella": "ausencia/25g"}',
        conforme: true,
      ));
    }

    // ─── Controles APPCC ──────────────────────────
    for (int i = 0; i < 15; i++) {
      final dia = hoy.subtract(Duration(days: i * 2));
      await _bd.guardarControlTemperatura(ControlTemperatura(
        fechaMs: dia.millisecondsSinceEpoch,
        cavaId: 'Cava principal',
        temperatura: 10 + _rng.nextDouble() * 2,
        humedadRelativa: 82 + _rng.nextDouble() * 8,
      ));
    }

    // Limpieza
    for (int i = 0; i < 5; i++) {
      final dia = hoy.subtract(Duration(days: i * 7));
      await _bd.guardarControlLimpieza(ControlLimpieza(
        fechaMs: dia.millisecondsSinceEpoch,
        zona: 'produccion',
        tarea: 'Limpieza completa sala de elaboración',
        productoUsado: 'Detergente alcalino + desinfectante',
        responsable: 'Mikel',
        verificado: true,
      ));
    }

    // Plagas
    await _bd.guardarControlPlagas(ControlPlagas(
      fechaMs: hoy.subtract(const Duration(days: 15)).millisecondsSinceEpoch,
      tipo: 'roedores',
      medida: 'Revisión cebos estación 1-4',
      responsable: 'Mikel',
      resultado: 'Sin incidencias',
      proximaRevisionMs:
          hoy.add(const Duration(days: 30)).millisecondsSinceEpoch,
    ));

    // ─── Incidencias cerradas ──────────────────────
    final lotes = await _bd.listarLotes();
    if (lotes.isNotEmpty) {
      await _bd.guardarIncidencia(Incidencia(
        fechaMs: hoy
            .subtract(const Duration(days: 30))
            .millisecondsSinceEpoch,
        tipo: 'defecto',
        loteProduccionId: lotes[0].id,
        descripcion:
            'Peso inferior al esperado en 2 piezas del lote (-150g cada una)',
        causa: 'Exceso de desuerado en el molde',
        accionCorrectiva: 'Ajustar tiempo de prensado',
        cerrada: true,
        fechaCreacionMs: hoy
            .subtract(const Duration(days: 30))
            .millisecondsSinceEpoch,
      ));
    }

    // ─── Ventas ────────────────────────────────────
    await _bd.guardarVenta(Venta(
      fechaMs: hoy.subtract(const Duration(days: 10)).millisecondsSinceEpoch,
      clienteNombre: 'Restaurante Aralar Jatetxea',
      clienteNif: 'B12345678',
      tipo: 'directa',
      lineasJson:
          '[{"loteProduccionId": 1, "cantidad": 2, "precioUnitario": 28.50}]',
      numeroFactura: 'F-2026-001',
      baseImponible: 57.00,
      ivaPorcentaje: 10,
      total: 62.70,
      fechaCreacionMs: hoy
          .subtract(const Duration(days: 10))
          .millisecondsSinceEpoch,
    ));

    await _bd.guardarVenta(Venta(
      fechaMs: hoy.subtract(const Duration(days: 5)).millisecondsSinceEpoch,
      clienteNombre: 'Tienda Gozo Gastronomia',
      clienteNif: 'F87654321',
      tipo: 'tienda',
      lineasJson:
          '[{"loteProduccionId": 1, "cantidad": 4, "precioUnitario": 26.00}]',
      numeroFactura: 'F-2026-002',
      baseImponible: 104.00,
      ivaPorcentaje: 10,
      total: 114.40,
      fechaCreacionMs: hoy
          .subtract(const Duration(days: 5))
          .millisecondsSinceEpoch,
    ));
  }

  String _fmtFecha(DateTime d) =>
      '${d.year}${_p(d.month)}${_p(d.day)}';
  String _p(int n) => n.toString().padLeft(2, '0');
}
