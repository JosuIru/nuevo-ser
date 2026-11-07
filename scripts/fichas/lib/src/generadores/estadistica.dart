import 'dart:math' as math;

import '../ejercicio.dart';
import '../utilidades.dart';

/// Fichas del dominio EST (estadística y probabilidad). Los gráficos de
/// líneas y circulares necesitan dibujo y se saltan en v0.1; las tablas sí
/// se imprimen.

const _encuestas = [
  ('Fruta favorita', ['Manzana', 'Plátano', 'Naranja', 'Pera', 'Uva']),
  ('Cómo venimos al cole', ['Andando', 'Bici', 'Autobús', 'Coche']),
  ('Deporte favorito', ['Fútbol', 'Baloncesto', 'Natación', 'Pelota', 'Atletismo']),
  ('Animal que más nos gusta', ['Perro', 'Gato', 'Conejo', 'Tortuga']),
];

List<int> _datos(math.Random azar, int cantidad, int minimo, int maximo) =>
    List.generate(cantidad, (_) => azar.entre(minimo, maximo));

String _listaDatos(List<int> datos) => datos.join(',  ');

double _mediana(List<int> datos) {
  final ordenados = [...datos]..sort();
  final mitad = ordenados.length ~/ 2;
  return ordenados.length.isOdd
      ? ordenados[mitad].toDouble()
      : (ordenados[mitad - 1] + ordenados[mitad]) / 2;
}

/// Moda única o null si hay empate.
int? _modaUnica(List<int> datos) {
  final recuento = <int, int>{};
  for (final dato in datos) {
    recuento[dato] = (recuento[dato] ?? 0) + 1;
  }
  final maximo = recuento.values.reduce(math.max);
  final modas = recuento.entries.where((e) => e.value == maximo).toList();
  return modas.length == 1 ? modas.first.key : null;
}

/// Color de las bolas en plural y en singular.
const _bolsas = [
  ('rojas', 'roja'),
  ('azules', 'azul'),
  ('verdes', 'verde'),
  ('amarillas', 'amarilla'),
];

final List<PlantillaFicha> plantillasEstadistica = [
  PlantillaFicha(
    idHabilidad: 'EST.01',
    descripcion:
        'Una tabla ordena datos en filas y columnas para leerlos de un vistazo. Para leerla, '
        'busca la fila y la columna que te interesan y mira dónde se cruzan. Con una tabla se puede '
        'dibujar un gráfico de barras: una barra por respuesta, tan alta como su número.\n'
        'Ejemplo: si Perro tiene 9 y Gato 4, la barra de Perro llega al 9 y la de Gato al 4: '
        'perro lo eligen 5 personas más.',
    preguntaExplicalo: '¿Qué pregunta harías tú a tu clase para hacer una tabla? ¿Qué esperas que salga?',
    generar: (azar) {
      final (titulo, categorias) = azar.elegir(_encuestas);
      late List<int> valores;
      do {
        valores = _datos(azar, categorias.length, 1, 12);
      } while (valores.where((v) => v == valores.reduce(math.max)).length > 1);
      final tipo = azar.nextInt(4);
      final indiceMaximo = valores.indexOf(valores.reduce(math.max));
      if (tipo == 3) {
        return Ejercicio(
          enunciado: '$titulo. Dibuja un gráfico de barras con los datos de la tabla: una barra '
              'por respuesta, tan alta como el número de personas.',
          tabla: [
            ['Respuesta', ...categorias],
            ['Personas', ...valores.map((v) => '$v')],
          ],
          solucion: 'barras de alturas ${valores.join(', ')}',
          renglones: 5,
        );
      }
      final (pregunta, solucion) = switch (tipo) {
        0 => ('¿Cuántas personas han respondido en total?', '${valores.reduce((a, b) => a + b)}'),
        1 => ('¿Qué respuesta es la más elegida? ¿Cuántas personas más la eligen que la menos elegida?',
            '${categorias[indiceMaximo]}; ${valores.reduce(math.max) - valores.reduce(math.min)} más'),
        _ => ('¿Qué diferencia hay entre las personas que eligen ${categorias[0]} y las que '
            'eligen ${categorias[1]}?', '${(valores[0] - valores[1]).abs()}'),
      };
      return Ejercicio(
        enunciado: '$titulo. Mira la tabla y responde: $pregunta',
        tabla: [
          ['Respuesta', ...categorias],
          ['Personas', ...valores.map((v) => '$v')],
        ],
        solucion: solucion,
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'EST.03',
    descripcion:
        'La media es el valor que tocaría a cada uno si se repartiera todo a partes iguales: se '
        'suman todos los datos y se divide entre cuántos hay.\n'
        'Ejemplo: la media de 4, 7 y 10 es (4 + 7 + 10) : 3 = 21 : 3 = 7.',
    preguntaExplicalo: 'Si a una lista de datos le añades uno muy grande, ¿qué le pasa a la media? ¿Por qué?',
    generar: (azar) {
      final cantidad = azar.entre(4, 6);
      final media = azar.entre(3, 20);
      // Datos alrededor de la media que sumen cantidad × media: media exacta.
      late List<int> datos;
      late int ultimo;
      do {
        datos = _datos(azar, cantidad - 1, math.max(0, media - 5), media + 5);
        ultimo = media * cantidad - datos.reduce((a, b) => a + b);
      } while (ultimo < 0 || ultimo > media + 8);
      datos.add(ultimo);
      final contexto = azar.elegir([
        'Puntos que ha marcado un equipo en cada partido',
        'Libros leídos por cada persona del grupo este trimestre',
        'Temperaturas (°C) a mediodía durante varios días',
        'Minutos que tarda cada persona en llegar al cole',
      ]);
      final suma = datos.reduce((a, b) => a + b);
      return Ejercicio(
        enunciado: '$contexto. Calcula la media:',
        destacado: _listaDatos(datos),
        solucion: formatearDecimal(suma / datos.length, cifras: 2),
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'EST.04',
    descripcion:
        'La moda es el dato que más se repite. La mediana es el que queda en el centro cuando '
        'ordenas los datos (si hay dos en el centro, la media de los dos).\n'
        'Ejemplo: en 3, 5, 5, 6, 9, la moda es 5 y la mediana también; en 2, 4, 6, 8, la mediana '
        'es (4 + 6) : 2 = 5.',
    preguntaExplicalo: '¿Por qué para hallar la mediana hay que ordenar primero los datos?',
    generar: (azar) {
      late List<int> datos;
      late int moda;
      do {
        datos = _datos(azar, azar.elegir([5, 7, 9, 6, 8]), 1, 10);
        moda = _modaUnica(datos) ?? -1;
      } while (moda < 0);
      return Ejercicio(
        enunciado: 'Notas de un juego de puntería (de 1 a 10). Halla la moda y la mediana:',
        destacado: _listaDatos(datos),
        solucion: 'moda $moda; mediana ${formatearDecimal(_mediana(datos))}',
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'EST.05',
    descripcion:
        'Si todos los resultados son igual de posibles, la probabilidad de un suceso es: casos '
        'favorables entre casos posibles. Va de 0 (imposible) a 1 (seguro).\n'
        'Ejemplo: con 3 bolas rojas y 5 azules, la probabilidad de sacar una roja es 3/8.',
    preguntaExplicalo: '¿Puede una probabilidad ser 3/2? Explica por qué sí o por qué no.',
    generar: (azar) {
      if (azar.nextInt(3) == 0) {
        final caras = azar.elegir([2, 3, 5]);
        final (descripcion, favorables) = switch (caras) {
          2 => ('un número par', 3),
          3 => ('un múltiplo de 3', 2),
          _ => ('un número mayor que 4', 2),
        };
        return Ejercicio(
          enunciado: 'Lanzas un dado normal de seis caras. ¿Qué probabilidad hay de sacar $descripcion?',
          solucion: Fraccion(favorables, 6).texto,
          renglones: 3,
        );
      }
      final colores = azar.barajar(_bolsas).take(azar.entre(2, 3)).toList();
      final cantidades = _datos(azar, colores.length, 1, 9);
      final total = cantidades.reduce((a, b) => a + b);
      final bolas = unirConY([
        for (var i = 0; i < colores.length; i++)
          cantidades[i] == 1 ? '1 bola ${colores[i].$2}' : '${cantidades[i]} bolas ${colores[i].$1}',
      ]);
      return Ejercicio(
        enunciado: 'En una bolsa hay $bolas. Sacas una sin mirar. '
            '¿Qué probabilidad hay de que sea ${colores[0].$2}?',
        solucion: Fraccion(cantidades[0], total).texto,
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'EST.06',
    descripcion:
        'Una probabilidad se puede escribir como fracción, como decimal o como porcentaje, y las '
        'tres dicen lo mismo.\n'
        'Ejemplo: 1/4 = 1 : 4 = 0,25 = 25 %.',
    preguntaExplicalo: 'Si la radio dice «70 % de probabilidad de lluvia», ¿va a llover seguro? Explícalo.',
    generar: (azar) {
      final (numerador, denominador) =
          azar.elegir([(1, 2), (1, 4), (3, 4), (1, 5), (2, 5), (3, 5), (4, 5), (1, 10), (3, 10), (7, 10), (1, 20), (9, 20)]);
      final fraccion = Fraccion(numerador, denominador);
      final decimal = formatearDecimal(fraccion.valor, cifras: 2);
      final porcentaje = '${formatearDecimal(fraccion.valor * 100)} %';
      final forma = azar.nextInt(3);
      final dado = [fraccion.texto, decimal, porcentaje][forma];
      return Ejercicio(
        enunciado: 'La probabilidad de un suceso es $dado. Escríbela de las otras dos formas '
            '(fracción, decimal, porcentaje).',
        solucion: '${fraccion.texto} = $decimal = $porcentaje',
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'EST.07',
    descripcion:
        'Una tabla de frecuencias cuenta cuántas veces sale cada dato (frecuencia absoluta). La '
        'frecuencia relativa es esa cuenta dividida entre el total de datos.\n'
        'Ejemplo: con 2, 0, 2, 1, 2 la tabla es: 0, una vez (1/5); 1, una vez (1/5); 2, tres veces (3/5).',
    preguntaExplicalo: '¿Cuánto suman todas las frecuencias relativas de una tabla? ¿Por qué?',
    generar: (azar) {
      final total = azar.elegir([10, 20]);
      final datos = _datos(azar, total, 0, 4);
      final contexto = azar.elegir([
        'Número de hermanos y hermanas de cada persona',
        'Mascotas que hay en cada casa',
        'Goles en cada partido de la liga del patio',
      ]);
      final recuento = [for (var valor = 0; valor <= 4; valor++) datos.where((d) => d == valor).length];
      return Ejercicio(
        enunciado: '$contexto. Haz la tabla de frecuencias absolutas y relativas:',
        destacado: _listaDatos(datos),
        solucion: [
          for (var valor = 0; valor <= 4; valor++)
            if (recuento[valor] > 0) '$valor: ${recuento[valor]} (${Fraccion(recuento[valor], total).simplificada().texto})',
        ].join('; '),
        renglones: 5,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'EST.08',
    descripcion:
        'En una tabla de frecuencias, la media se calcula multiplicando cada dato por su frecuencia, '
        'sumando y dividiendo entre el total. El rango (máximo − mínimo) dice cuánto se dispersan.\n'
        'Ejemplo: 2 personas leen 1 libro y 3 leen 6: media (2 · 1 + 3 · 6) : 5 = 20 : 5 = 4; '
        'rango 6 − 1 = 5.',
    preguntaExplicalo: 'Dos grupos tienen la misma media pero distinto rango. ¿En qué se diferencian?',
    generar: (azar) {
      final valores = [azar.entre(0, 2), azar.entre(3, 4), azar.entre(5, 6), azar.entre(7, 9)];
      final frecuencias = _datos(azar, valores.length, 1, 6);
      final total = frecuencias.reduce((a, b) => a + b);
      final suma = [for (var i = 0; i < valores.length; i++) valores[i] * frecuencias[i]]
          .reduce((a, b) => a + b);
      return Ejercicio(
        enunciado: 'Libros que ha leído cada persona de un grupo este verano. '
            'Calcula la media (redondea a las centésimas si no sale exacta) y el rango:',
        tabla: [
          ['Libros', ...valores.map((v) => '$v')],
          ['Personas', ...frecuencias.map((f) => '$f')],
        ],
        solucion: 'media ${formatearDecimal(suma / total, cifras: 2)}; rango ${valores.last - valores.first}',
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'EST.09',
    descripcion:
        'En un experimento compuesto (lanzar dos monedas, sacar dos bolas…), un diagrama de árbol '
        'ayuda a ver todos los casos. Si son independientes, se multiplican las probabilidades. Si '
        'no devuelves la primera bola, la segunda se calcula con las que quedan, y también se multiplican.\n'
        'Ejemplo: con 4 bolas rojas y 6 azules, sacar dos rojas sin devolver es 4/10 · 3/9 = 12/90 = 2/15.',
    preguntaExplicalo: '¿Por qué al sacar dos bolas sin devolver cambia la probabilidad de la segunda?',
    generar: (azar) {
      final tipo = azar.nextInt(3);
      if (tipo == 0) {
        final (descripcion, favorables) = azar.elegir([
          ('dos caras', 1),
          ('una cara y una cruz (en cualquier orden)', 2),
          ('al menos una cara', 3),
        ]);
        return Ejercicio(
          enunciado: 'Lanzas dos monedas. ¿Qué probabilidad hay de sacar $descripcion? Haz un diagrama de árbol.',
          solucion: Fraccion(favorables, 4).simplificada().texto,
          renglones: 4,
        );
      }
      if (tipo == 1) {
        final (descripcion, favorables) = azar.elegir([
          ('que sumen 7', 6),
          ('dos números iguales', 6),
          ('que sumen 10 o más', 6),
          ('que los dos sean pares', 9),
        ]);
        return Ejercicio(
          enunciado: 'Lanzas dos dados de seis caras. ¿Qué probabilidad hay de $descripcion? '
              'Una tabla de doble entrada (6 filas y 6 columnas) te puede ayudar.',
          solucion: Fraccion(favorables, 36).simplificada().texto,
          renglones: 4,
        );
      }
      final rojas = azar.entre(2, 5);
      final azules = azar.entre(2, 5);
      final total = rojas + azules;
      return Ejercicio(
        enunciado: 'En una bolsa hay $rojas bolas rojas y $azules azules. Sacas dos, una detrás de '
            'otra, sin devolver la primera. ¿Qué probabilidad hay de que las dos sean rojas?',
        solucion: (Fraccion(rojas, total) * Fraccion(rojas - 1, total - 1)).texto,
        renglones: 4,
      );
    },
  ),
];

const motivosSinPlantillaEstadistica = {
  'EST.02': 'los gráficos de líneas y circulares necesitan dibujo (v0.1 no dibuja)',
};
