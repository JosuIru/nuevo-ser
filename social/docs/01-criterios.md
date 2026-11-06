# Criterios de diseño de la línea social

> v0.1 · 2026-11-06. Inspirados en los libros de la Colección (ver `02-fuentes-coleccion.md`), adaptados a la realidad actual. **Son una herramienta, no un dogma**: si un criterio estorba en un caso real, se discute y se cambia.

## A. Las preguntas de control

Cada función nueva tiene que pasar por estas preguntas antes de entrar. Si alguna respuesta es mala, la función no entra o se rediseña.

1. **¿Sirve desde el primer día a un grupo real?** Si necesita que «todo el pueblo esté dentro» para valer algo, está mal planteada.
2. **¿Reparte poder o lo concentra?** ¿Quién gana control con esto: el grupo, una persona administradora o nosotros?
3. **¿Ayuda a la gente o la vigila?** La transparencia es de las **decisiones y el dinero**, nunca de las personas.
4. **¿Se entiende y se puede comprobar?** Nada de cálculos opacos que decidan o que ordenen lo que ve la gente.
5. **¿Se puede apagar?** Si la app desaparece mañana, ¿el grupo sigue funcionando? Tiene que poder exportar todo y tirar de papel.
6. **¿Pide participar o pide pagar?** Si una función empuja a comprar algo, sobra.
7. **¿Formaliza lo justo?** Cada trámite que añade la app es energía que le quita al grupo.

## B. Reglas de diseño

**Tamaño y alcance**
- Una app hace una cosa. Si hace falta otra, es otra app o un módulo que se puede apagar.
- La F1 se usa de verdad en **2-4 semanas de desarrollo**, no en meses.
- Se piensa para grupos de **10 a 300 personas** (los libros proponen nodos pequeños que se federan). Un pueblo o un barrio, no una ciudad.

**De quién es**
- **El grupo aloja su instancia** o comparte una con otros grupos de confianza. Patrón probado en Zunbeltz: un plugin de WordPress en un hosting barato más la app.
- **Exportar todo siempre**, en formatos abiertos (CSV, PDF y JSON).
- Software libre (AGPL-3.0).

**Personas**
- **Datos mínimos.** Nombre o alias y forma de contacto. Nunca salud, situación migratoria, ideología ni religión (categorías especiales del RGPD).
- **Voto secreto de verdad** cuando lo es: el registro de quién ha votado y el voto en sí van **separados y sin vínculo**.
- **Sin rankings, puntos, rachas ni «la persona más activa».** Lo que aporta cada persona puede verse, pero no se convierte en marcador.
- **Sin muro infinito ni contadores de «me gusta».**

**Avisos**
- Solo se avisa de lo que **necesita a esa persona**: se abre una votación de su pueblo, le toca un turno, vence un plazo.
- El resto va a un **resumen periódico** que cada cual elige (diario, semanal o nunca).
- Nada de avisos para que «vuelvas a la app».

**Inclusión**
- **Siempre un canal sin móvil.** Hojas imprimibles, voto presencial que apunta una persona de la mesa y aviso en el tablón físico. En un pueblo, mucha gente mayor no usará la app, y la decisión no puede quedarse sin ellos.
- Funciona con **mala cobertura** y en **móviles viejos**. Versión web para el ordenador del ayuntamiento o de la asociación.
- **Lectura fácil**: frases cortas, sin jerga. Cada asunto con un resumen de tres líneas arriba.
- Multilingüe desde el día uno.

**Lo que no hace la app**
- **Lo relacional va en persona**: mediación de conflictos, círculos de apoyo, escucha. La app puede convocar, pero no sustituye. Lo que se dice en un círculo **no se registra**.
- **No automatiza decisiones.** Puede resumir argumentos o contar votos, pero decide la gente.
- **Sin blockchain.** No resuelve nada que no resuelva una base de datos con actas exportables y personas de confianza.

## C. Cómo saber si una app funciona

No se mide con cifras de uso («usuarios activos», «tiempo en la app»), porque premian lo contrario de lo que se busca. Se pregunta al grupo piloto:

- ¿Decidís más cosas, o mejor, que antes?
- ¿Participa gente que antes no participaba?
- ¿Se cumplen los acuerdos?
- ¿Os quita tiempo o os lo devuelve?
- ¿La seguiríais usando si no estuviéramos nosotros?

## D. Lo que tomamos de los libros y lo que no

Los libros son orientación. En concreto:

- **Tomamos**: decisión por consentimiento como **una** opción entre varias, roles rotativos, bienes comunes con reglas propias, subsidiariedad, red de grupos pequeños, transparencia de decisiones, dar voz a la naturaleza en las decisiones.
- **Adaptamos**: la «democracia líquida» (delegación de voto) solo como opción y para asuntos concretos, porque en un pueblo puede convertirse en caciquismo con otro nombre. La «transparencia radical», solo de decisiones y dinero.
- **Descartamos**: blockchain, fórmulas numéricas de poder (que más ayuda dé más voto) y monedas programables en la F1.
