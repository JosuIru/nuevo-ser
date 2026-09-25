import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../nucleo/paleta.dart';
import 'pantalla_faro.dart' show parsearMarkdownLigero;

/// Página única de instrucciones del juego: tres secciones (de qué
/// trata, cómo se juega, para tutores y maestros). Reusa el parser de
/// markdown ligero del Faro (`**negrita**` y `*cursiva*`). El cuerpo
/// está hardcodeado en castellano; eu/ca caen al castellano hasta que
/// haya traducción humana revisada — coherente con el resto de
/// narrativa del juego, donde el castellano es la voz canónica.
class PantallaInstrucciones extends StatelessWidget {
  const PantallaInstrucciones({super.key});

  @override
  Widget build(BuildContext contexto) {
    final textos = AppLocalizations.of(contexto);
    final secciones = _seccionesParaLocale(
      Localizations.localeOf(contexto).languageCode,
    );
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      appBar: AppBar(
        backgroundColor: PaletaNeon.fondoProfundo,
        elevation: 0,
        iconTheme: const IconThemeData(color: PaletaNeon.textoTenue),
        title: Text(
          textos.tituloInstrucciones,
          style: const TextStyle(
            fontSize: 13,
            letterSpacing: 4,
            color: PaletaNeon.textoTenue,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final seccion in secciones) _BloqueSeccion(seccion: seccion),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeccionInstrucciones {
  final String titulo;
  final String cuerpo;
  const _SeccionInstrucciones({required this.titulo, required this.cuerpo});
}

class _BloqueSeccion extends StatelessWidget {
  final _SeccionInstrucciones seccion;
  const _BloqueSeccion({required this.seccion});

  @override
  Widget build(BuildContext contexto) {
    final parrafos = seccion.cuerpo.split('\n\n');
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: PaletaNeon.violetaNeon,
                  width: 0.6,
                ),
              ),
            ),
            child: Text(
              seccion.titulo,
              style: const TextStyle(
                fontSize: 12,
                letterSpacing: 3.5,
                color: PaletaNeon.violetaNeon,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          for (int i = 0; i < parrafos.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == parrafos.length - 1 ? 0 : 12,
              ),
              child: RichText(
                text: TextSpan(
                  children: parsearMarkdownLigero(
                    parrafos[i],
                    const TextStyle(
                      fontFamily: 'CormorantGaramond',
                      color: PaletaNeon.textoPrincipal,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Devuelve las tres secciones para el idioma activo. Por ahora `eu` y
/// `ca` caen al castellano — el contenido es largo y la traducción
/// humana se hará en una pasada posterior, con la misma criba que la
/// narrativa.
List<_SeccionInstrucciones> _seccionesParaLocale(String codigo) {
  switch (codigo) {
    case 'eu':
    case 'ca':
    default:
      return _instruccionesEs;
  }
}

const List<_SeccionInstrucciones> _instruccionesEs = [
  _SeccionInstrucciones(
    titulo: 'DE QUÉ TRATA',
    cuerpo:
        'Asha es una ciudad medio rota. Por las noches, trozos de algo más grande se sueltan y vagan por sus calles. Se llaman **Fragmentos**. No hacen daño, pero la ciudad respira peor cuando hay muchos.\n\n'
        'Tú eres un *Aprendiz*. Sales por la noche con Sora, que enseña sin levantar la voz. Vas aprendiendo a *desfragmentar* — a hacer que los trozos rotos vuelvan a encajar. Lo haces con matemáticas: fracciones, decimales, proporciones, geometría. Las matemáticas no son un peaje. Son cómo el mundo se sostiene.\n\n'
        'A medida que avanzas subes de rango: *Aprendiz I*, *II*, *III*, *Iniciado*. La historia se cuenta en cuatro arcos. No hay puntuación final. Hay una despedida.',
  ),
  _SeccionInstrucciones(
    titulo: 'CÓMO SE JUEGA',
    cuerpo:
        '**El cazadero.** En cada distrito aparecen Fragmentos. Tócalos cuando salgan. Se abre un puzzle pequeño: lee, piensa, responde. Si aciertas, el Fragmento se disuelve y queda una *esquirla* (un poco de claridad). Si fallas, el Fragmento se escapa. No pasa nada. Vendrá otro.\n\n'
        '**Cinemáticas.** A veces, en lugar de cazar, te encuentras con alguien — Sora, Kai, Irune, Rexán. Hay una pequeña escena. Toca la pantalla para pasar de plano. Si hay opciones, elige la que sientas. No hay opciones malas; algunas dejan flechas en el Cuaderno.\n\n'
        '**Fragmentos con nombre.** Algunos Fragmentos son más grandes y tienen nombre: *Kurz*, *Zafrán*, *Vorax*. Son retos calibrados — a veces estás hecho para perder, a veces para ganar. Está bien perder. Es parte de la historia. Volverás más fuerte.\n\n'
        '**Modo entrenar.** Si quieres practicar un dominio concreto (fracciones, geometría, decimales…), entra desde el icono de la pesa en el mapa. Eliges el dominio y entrenas sin avanzar la historia.\n\n'
        '**Mi cuaderno.** Lo que vives queda anotado. Personajes, lugares, ideas, momentos. Ábrelo desde el mapa cuando quieras releer.\n\n'
        '**El Faro de Azula.** Un periódico semanal del mundo. Sale los viernes. No es obligatorio leerlo. A veces hay un acertijo al final; si te apetece, lo respondes.\n\n'
        '**Eco.** Si te atascas con una habilidad, después de un Fragmento que se escapa Sora puede preguntarte si quieres hablar con *Eco*. Eco es alguien que explica con paciencia. Pregunta lo que quieras en una frase corta. No te dará la solución; te dará un hilo del que tirar.\n\n'
        '**Perfiles.** Si jugáis varios hermanos o amigos en el mismo aparato, cada uno tiene su perfil con su progreso. Se cambian desde la pantalla de Habilidades (mantén pulsado el encabezado del mapa).',
  ),
  _SeccionInstrucciones(
    titulo: 'PARA TUTORES Y MAESTROS',
    cuerpo:
        '**Qué entrena.** Uno Roto cubre **106 habilidades** de 4.º de Primaria a 2.º de ESO: fracciones (de la lectura a las cuatro operaciones, también con signo), decimales, proporciones (regla de tres directa e inversa, porcentajes encadenados, repartos, escala), divisibilidad (criterios, primos, factorización, MCM/MCD), números enteros y potencias (incluida la notación científica), jerarquía de operaciones, medidas, geometría (áreas de polígonos, Pitágoras, Tales, volúmenes de prismas, cilindros, pirámides, conos y esferas), álgebra (lenguaje algebraico, monomios y polinomios, identidades notables, ecuaciones de primer y segundo grado, sistemas y problemas), funciones (coordenadas, gráficas, función lineal) y estadística y probabilidad. Un motor adaptativo elige qué practicar en función de los aciertos, los fallos y el tiempo.\n\n'
        '**Cómo se adapta a la edad y al nivel.** El punto de partida lo pone una prueba corta con Sora (unas diez preguntas, sin marcador) o el adulto, que elige el curso desde la pantalla de Habilidades. Lo de los cursos anteriores se da por sabido y lo que viene grande no aparece todavía. A partir de ahí manda el motor: mide precisión y tiempo en cada intento, sube una habilidad de nivel cuando hay aciertos consistentes y la baja con el paso de los días si no se practica. El selector da prioridad a la **zona de desarrollo próximo** — lo que el niño está empezando a entender — y respeta las dependencias entre habilidades. Si algo dado por sabido cuesta, vuelve a salir. Sin punto de partida, el juego empieza por lo más básico.\n\n'
        '**No es un juego de puntos.** No hay rankings, ni medallas, ni racha de días. La única medida visible es el rango narrativo y un contador discreto de esquirlas, que es **proxy de progreso, no recompensa**. No se diseñó para enganchar; se diseñó para acompañar. Que el niño deje de jugar cuando le apetezca es un éxito, no un fracaso.\n\n'
        '**Privacidad por diseño.** El progreso vive en el aparato. No hay anuncios, no hay analítica, no hay compras integradas. Si un educador conecta el juego a un servidor (opcional), el niño tiene un identificador anónimo: el sistema separa hermanos y compañeros, pero no envía nombre real ni datos sensibles.\n\n'
        '**Sobre el tutor.** El juego incluye un tutor — *Eco* — al que el niño puede preguntar cuando se atasca. Lo que se le pregunta y lo que se le contesta no salen del juego con su nombre. Las preguntas anónimas se pueden cachear para que muchos niños se beneficien de la misma explicación. Eco no da soluciones directas: ofrece metáforas, analogías, hilos.\n\n'
        '**Errar forma parte del diseño.** Algunos combates están calibrados a la derrota — el guion lo necesita. Que el niño pierda con Kurz no es fallo del niño, es la historia. Si lo viven con frustración, conviene contarles esto.\n\n'
        '**Cómo acompañar.** La mejor compañía es el silencio interesado. Mire al niño jugar de vez en cuando. Pregúntele por la historia, por los personajes, por lo que está aprendiendo — no por las puntuaciones. Si se frustra con un Fragmento, ofrézcale parar. No está obligado a vencer en ningún momento.\n\n'
        '**Sin sesiones cronometradas.** Que juegue cuando le apetezca. Que pare cuando quiera. La cadencia la pone él.\n\n'
        '**Idiomas.** Castellano, euskera y catalán. Las traducciones de los textos largos pueden estar en revisión humana — el castellano es la voz canónica.\n\n'
        '**Edad recomendada.** De 9 a 14 años (de 4.º de Primaria a 2.º de ESO). Niños más pequeños pueden jugar acompañados.\n\n'
        '*Uno Roto* es uno de los juegos de la **Colección Nuevo Ser Kids**. Código abierto bajo AGPL-3.0; contenido bajo CC BY-SA 4.0.',
  ),
];
