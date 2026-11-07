import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_tabla_ugm.dart';
import '../modelos/carga_ganadera.dart';
import '../modelos/ganado.dart';
import '../modelos/pieza_pasto.dart';
import '../modelos/tarea_sanitaria.dart';

/// Todo el ganado de la explotación, tal como está en el móvil. Lo cargan las
/// pantallas y los documentos (la explotación pequeña cabe entera en memoria).
class DatosGanado {
  const DatosGanado({
    required this.piezas,
    required this.lotes,
    required this.animales,
    required this.movimientos,
    required this.eventos,
    required this.tareas,
  });

  final List<PiezaPasto> piezas;
  final List<LoteGanado> lotes;
  final List<Animal> animales;
  final List<MovimientoGanado> movimientos;
  final List<EventoGanado> eventos;
  final List<TareaSanitaria> tareas;

  Map<int, String> get nombresPiezas => {
        for (final pieza in piezas)
          if (pieza.id != null) pieza.id!: pieza.nombre
      };

  Map<int, LoteGanado> get lotesPorId => {
        for (final lote in lotes)
          if (lote.id != null) lote.id!: lote
      };

  static Future<DatosGanado> cargar() async {
    final baseDatos = BaseDatosSoleraGanadera.instancia;
    return DatosGanado(
      piezas: await baseDatos.listarPiezas(),
      lotes: await baseDatos.listarLotes(),
      animales: await baseDatos.listarAnimales(),
      movimientos: await baseDatos.listarMovimientos(),
      eventos: await baseDatos.listarEventos(),
      tareas: await baseDatos.listarTareasSanitarias(),
    );
  }
}

/// La tabla UGM con la que las pantallas enseñan la carga: la de la PAC.
/// El informe del eco-régimen deja elegir trámite.
final List<CoeficienteUgm> tablaUgmPantallas =
    tablaDeTramite(catalogoCoeficientesUgm, tramitePac);
