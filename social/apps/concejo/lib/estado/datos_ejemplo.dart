/// Un pueblo de ejemplo para ver la app funcionando antes de tener
/// servidor: un asunto en cada fase y cada forma de decidir. Las fechas se
/// calculan desde hoy para que siempre haya algo en debate y algo en
/// votación. Nombres y pueblo inventados.
library;

import 'dart:math';

import '../dominio/asunto.dart';
import '../dominio/compromiso.dart';
import '../dominio/consentimiento.dart';
import '../dominio/debate.dart';
import '../dominio/persona.dart';
import '../dominio/reglas_decision.dart';
import '../dominio/anuncio.dart';
import '../dominio/sesion.dart';
import '../dominio/tarea.dart';
import '../dominio/urna.dart';
import 'estado_concejo.dart';

EstadoConcejo estadoDeEjemplo({DateTime? hoy}) {
  final ahora = hoy ?? DateTime.now();
  DateTime dias(int cantidad) =>
      DateTime(ahora.year, ahora.month, ahora.day + cantidad);

  final personas = [
    Persona(uid: 'ane', nombre: 'Ane', rol: Rol.mesa, mandatoHasta: dias(40)),
    Persona(
        uid: 'mikel', nombre: 'Mikel', rol: Rol.mesa, mandatoHasta: dias(40)),
    const Persona(uid: 'maite', nombre: 'Maite'),
    const Persona(uid: 'josean', nombre: 'Josean'),
    const Persona(uid: 'pili', nombre: 'Pili'),
    const Persona(uid: 'iker', nombre: 'Iker'),
  ];

  final fiestas = Asunto(
    uid: 'fiestas',
    titulo: '¿Pasamos las fiestas a septiembre?',
    resumen: 'En agosto hay mucha gente fuera y el calor aprieta. La comisión '
        'propone mover las fiestas al primer fin de semana de septiembre.',
    texto: 'La comisión de fiestas lo ha hablado con la charanga y con el '
        'bar. En septiembre la orquesta es un 15 % más barata. A cambio, '
        'parte de la gente joven ya habrá vuelto a estudiar.',
    tipoDecision: TipoDecision.conCompromisoPrevio,
    compromisoPrevio: 'La junta se compromete a mover las fiestas si sale '
        'que sí y participan al menos 20 vecinas y vecinos.',
    efectoEntorno: 'Ninguno destacable.',
    reglas:
        const ReglasDecision(forma: FormaDecision.votacion, quorumPersonas: 20),
    inicioDebate: dias(-7),
    inicioDecision: dias(-1),
    finDecision: dias(5),
    creadoPorUid: 'ane',
    abierto: true,
  );

  final comunal = Asunto(
    uid: 'comunal',
    titulo: 'Normas para el uso de la leña del comunal',
    resumen: 'Proponemos un lote por casa y año, marcado por la guarda, y '
        'que no se corten árboles con nidos.',
    tipoDecision: TipoDecision.vinculante,
    efectoEntorno: 'Protege los árboles viejos y los nidos de rapaces del '
        'monte de Arriba.',
    reglas: const ReglasDecision(forma: FormaDecision.consentimiento),
    inicioDebate: dias(-2),
    inicioDecision: dias(6),
    finDecision: dias(13),
    creadoPorUid: 'mikel',
    abierto: true,
  );

  final presupuesto = Asunto(
    uid: 'presupuesto',
    titulo: 'Presupuesto participativo 2027',
    resumen: 'Hay 10.000 € para lo que decidamos entre todas. Apoya las '
        'propuestas que quieras: entran por apoyos mientras haya dinero.',
    tipoDecision: TipoDecision.conCompromisoPrevio,
    compromisoPrevio: 'El concejo ejecutará en 2027 las propuestas que '
        'entren, si participan al menos 15 personas.',
    efectoEntorno: 'La limpieza de la fuente vieja recupera un punto de agua '
        'para pájaros y anfibios.',
    costeEuros: 10000,
    reglas: const ReglasDecision(
      forma: FormaDecision.presupuesto,
      bolsaEuros: 10000,
      quorumPersonas: 15,
      opciones: [
        OpcionDecision(
            id: 'bancos',
            texto: 'Bancos y sombra en la plaza',
            costeEuros: 3000),
        OpcionDecision(
            id: 'fronton',
            texto: 'Arreglar el tejado del frontón',
            costeEuros: 8000),
        OpcionDecision(
            id: 'fuente', texto: 'Limpiar la fuente vieja', costeEuros: 1500),
        OpcionDecision(
            id: 'columpios', texto: 'Columpios nuevos', costeEuros: 5000),
      ],
    ),
    inicioDebate: dias(-3),
    inicioDecision: dias(4),
    finDecision: dias(15),
    creadoPorUid: 'ane',
    abierto: true,
  );

  final txoko = Asunto(
    uid: 'txoko',
    titulo: 'Horario del local vecinal',
    resumen: '¿Hasta qué hora se puede usar el local entre semana?',
    tipoDecision: TipoDecision.vinculante,
    efectoEntorno: 'Menos ruido de noche en la calle Mayor.',
    reglas: const ReglasDecision(
      forma: FormaDecision.eleccionEntreOpciones,
      opciones: [
        OpcionDecision(id: '22', texto: 'Hasta las 22:00'),
        OpcionDecision(id: '23', texto: 'Hasta las 23:00'),
        OpcionDecision(id: '24', texto: 'Hasta las 24:00'),
      ],
    ),
    inicioDebate: dias(-30),
    inicioDecision: dias(-20),
    finDecision: dias(-10),
    creadoPorUid: 'mikel',
    abierto: true,
  );

  var urnaTxoko = const Urna(asuntoUid: 'txoko');
  final azar = Random(7);
  for (final (persona, voto) in [
    ('maite', {'22', '23'}),
    ('josean', {'23', '24'}),
    ('pili', {'23'}),
    ('iker', {'24'}),
  ]) {
    urnaTxoko = urnaTxoko.votarEnLaApp(
      personaUid: persona,
      opcionesMarcadas: voto,
      ahora: dias(-15),
      secreta: true,
      azar: azar,
    );
  }
  urnaTxoko = urnaTxoko
      .anotarVotoPresencial(personaUid: 'ane', mesaUid: 'mikel')
      .anadirConteoPresencial(const ConteoPresencial(
        asuntoUid: 'txoko',
        papeletasTotales: 1,
        marcasPorOpcion: {'22': 1, '23': 1},
        firmadoPorUids: ['ane', 'mikel'],
      ));

  var debateFiestas = const Debate(asuntoUid: 'fiestas');
  for (final (uid, autor, tipo, texto, respondeA) in [
    (
      'f1',
      'maite',
      TipoAportacion.aFavor,
      'Con el calor de agosto la gente mayor no sale a la plaza.',
      null
    ),
    (
      'f2',
      'iker',
      TipoAportacion.enContra,
      'En septiembre muchos estudiamos fuera y no podríamos venir.',
      null
    ),
    (
      'f3',
      'josean',
      TipoAportacion.duda,
      '¿Se ha preguntado a los pueblos de al lado? Coincidiríamos con sus fiestas.',
      null
    ),
    (
      'f4',
      'ane',
      TipoAportacion.duda,
      'Lo hemos mirado: el de al lado las tiene a mediados de mes.',
      'f3'
    ),
    (
      'f5',
      'pili',
      TipoAportacion.propuestaDeCambio,
      'Probar un año y volver a decidir después.',
      null
    ),
  ]) {
    debateFiestas = debateFiestas.aportar(Aportacion(
      uid: uid,
      asuntoUid: 'fiestas',
      autorUid: autor,
      tipo: tipo,
      texto: texto,
      creada: dias(-5),
      respondeAUid: respondeA,
    ));
  }

  DateTime aLas(int dia, int hora) =>
      DateTime(ahora.year, ahora.month, ahora.day + dia, hora);
  final sesiones = [
    Sesion(
      uid: 'octubre',
      titulo: 'Asamblea de octubre',
      inicio: aLas(-12, 19),
      lugar: 'Local vecinal',
      convocadaPorUid: 'ane',
      puntos: const [
        PuntoOrdenDia(
          uid: 'oc1',
          texto: 'Horario del local vecinal',
          asuntoUid: 'txoko',
          notas: 'La calle de abajo pide cerrar antes entre semana. Se '
              'decide votarlo en la app con tres horarios.',
        ),
        PuntoOrdenDia(
          uid: 'oc2',
          texto: 'Ruegos y preguntas',
          notas: 'Piden arreglar la fuente de la plaza. La mesa lo '
              'traerá como asunto.',
        ),
      ],
      asistentesUids: const {'ane', 'mikel', 'maite', 'josean'},
      asistentesSinApp: 9,
    ),
    Sesion(
      uid: 'noviembre',
      titulo: 'Asamblea de noviembre',
      inicio: aLas(4, 19),
      lugar: 'Local vecinal',
      convocadaPorUid: 'ane',
      puntos: const [
        PuntoOrdenDia(
            uid: 'no1', texto: 'Fiestas en septiembre', asuntoUid: 'fiestas'),
        PuntoOrdenDia(
            uid: 'no2', texto: 'Leña del comunal', asuntoUid: 'comunal'),
        PuntoOrdenDia(
            uid: 'no3',
            texto: 'Presupuesto participativo 2027',
            asuntoUid: 'presupuesto'),
        PuntoOrdenDia(uid: 'no4', texto: 'Ruegos y preguntas'),
      ],
    ),
  ];

  final anuncios = [
    Anuncio(
      uid: 'agua',
      titulo: 'Corte de agua por la obra de la calle Mayor',
      texto: 'Pasado mañana, de 9 a 12. Llenad alguna garrafa la víspera.',
      autorUid: 'ane',
      publicado: aLas(-1, 10),
      hasta: dias(2),
      fijado: true,
    ),
    Anuncio(
      uid: 'poda',
      titulo: 'Taller de poda de frutales',
      texto: 'El sábado por la mañana en la huerta de Iker. Quien tenga '
          'tijeras, que las traiga.',
      autorUid: 'josean',
      publicado: aLas(-2, 20),
      hasta: dias(5),
    ),
    Anuncio(
      uid: 'nueces',
      titulo: 'Se regalan nueces',
      texto: 'Dos sacos de este año. Pasad por casa, al lado de la fuente, '
          'a partir de las seis.',
      autorUid: 'maite',
      publicado: aLas(-3, 18),
    ),
    Anuncio(
      uid: 'feria',
      titulo: 'Feria de artesanía en el valle',
      texto: 'Hay sitio en dos coches para ir juntos.',
      autorUid: 'mikel',
      publicado: aLas(-10, 12),
      hasta: dias(-3),
    ),
  ];

  final tareas = [
    Tarea(
      uid: 'fronton',
      titulo: 'Pintar la pared del frontón',
      inicio: aLas(-6, 10),
      lugar: 'Frontón',
      descripcion: 'La pintura la pone el concejo; traed brochas y rodillos.',
      plazas: 6,
      creadaPorUid: 'ane',
      apuntadosUids: const {'ane', 'maite', 'josean', 'iker'},
      estaHecha: true,
      notaHecha: 'Pintada. Sobró media lata: está en el almacén del local.',
    ),
    Tarea(
      uid: 'local',
      titulo: 'Abrir el local vecinal',
      inicio: aLas(4, 17),
      lugar: 'Local vecinal',
      descripcion: 'De 17:00 a 20:00. Las llaves están en el bar.',
      plazas: 1,
      creadaPorUid: 'ane',
      apuntadosUids: const {'pili'},
    ),
    Tarea(
      uid: 'camino',
      titulo: 'Auzolan: limpiar el camino del monte',
      inicio: aLas(5, 9),
      lugar: 'Salida del camino, junto al lavadero',
      descripcion: 'Desbrozar y quitar ramas caídas. Hay almuerzo al acabar.',
      plazas: 8,
      creadaPorUid: 'ane',
      apuntadosUids: const {'josean', 'iker', 'mikel'},
    ),
  ];

  return EstadoConcejo(
    nombreEspacio: 'Concejo de Ejemplo',
    personaActual: personas.first,
    personas: personas,
    asuntos: [fiestas, comunal, presupuesto, txoko],
    sesiones: sesiones,
    anuncios: anuncios,
    tareas: tareas,
    urnas: {'txoko': urnaTxoko},
    debates: {
      'fiestas': debateFiestas,
      'txoko': const Debate(
        asuntoUid: 'txoko',
        resumenMesa: 'Se habló en la reunión de octubre: la gente de la calle '
            'Mayor pedía cerrar antes; las cuadrillas, poder quedarse '
            'después de cenar. Se acordó votar entre tres horas.',
      ),
    },
    consentimientos: {
      'comunal':
          const EstadoConsentimiento(rondaActual: 1, rondasMaximas: 2).objetar(
              uid: 'o1',
              autorUid: 'josean',
              motivo: 'Un lote por casa deja sin leña a las casas grandes '
                  'que solo tienen leña para calentarse.'),
    },
    compromisos: [
      Compromiso(
        uid: 'c1',
        asuntoUid: 'txoko',
        que: 'Poner el cartel con el horario nuevo en la puerta del local',
        responsable: 'Mikel',
        fechaLimite: dias(-3),
      ),
      Compromiso(
        uid: 'c2',
        asuntoUid: 'txoko',
        que: 'Avisar a las cuadrillas del cambio de horario',
        responsable: 'La mesa',
        fechaLimite: dias(-8),
        estado: EstadoCompromiso.hecho,
        nota: 'Avisado por el bando y en el grupo.',
      ),
    ],
    reloj: hoy == null ? null : () => hoy,
    esEjemplo: true,
  );
}
