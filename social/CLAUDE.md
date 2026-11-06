# Línea social — CLAUDE.md

Cerebro persistente del apartado social. Se lee al empezar cualquier trabajo en `social/`.

## Qué es esto

Las herramientas digitales de la **Colección Nuevo Ser** para que la gente se organice en su día a día: pueblos, barrios, colectivos, ayuda vecinal, bienes comunes, cuidados y protección de la naturaleza.

No es Kids (juegos pedagógicos) ni Larrea (producto comercial). Es la tercera pata del monorepo, y la diferencia es de fondo:

- **No se mide por quién pagaría**, sino por cuánto ayuda a organizarse de forma más amable con las personas y con la naturaleza.
- **Útil desde el primer día.** Cada app resuelve una cosa concreta y pequeña que un grupo real necesita ya. Nada de plataformas que lo hacen todo.

> **La lección de Flavor Platform**: una plataforma tan grande que al final nadie quiere ni verla. Aquí se hace al revés: una herramienta pequeña que funciona, se prueba con un grupo real y solo después crece. Si una app no cabe en una frase, está mal cortada.

## De dónde viene

Sale de una conversación del **2026-11-06** que empezó con ideas para Larrea y acabó aquí. En orden:

1. Ideas de apps sociales (colectivos, barrios, cooperación, naturaleza, migración).
2. Corrección del autor: **no son para cobrar, son para cambiar las cosas**.
3. Lectura de los 7 libros de la Colección que tratan de estructuras y organización: resumen en `docs/02-fuentes-coleccion.md`.
4. La idea de un «WeChat social» se replantea como **red de herramientas pequeñas que se hablan entre sí**, no como una super app.
5. Criterio del autor: **los libros son orientación, no un manual que seguir al pie de la letra**. Hay que adaptar sus ideas a la realidad actual (leyes, móviles, cómo vive la gente en un pueblo hoy). Lo que no aporta se descarta. Por ejemplo, **sin blockchain**.

## Documentos

| Archivo | Qué contiene |
|---|---|
| `docs/01-criterios.md` | Los criterios de diseño que deben cumplir todas las apps sociales. Leer antes de proponer cualquier función |
| `docs/02-fuentes-coleccion.md` | Qué dicen los libros de la Colección, con referencias, y qué tomamos, qué adaptamos y qué descartamos |
| `docs/03-catalogo-apps.md` | Catálogo de apps posibles con su «primer día útil», y el orden propuesto |
| `docs/04-concejo.md` | Ficha de la primera app propuesta: **Concejo**, para que un pueblo debata, decida y siga sus asuntos |

Los libros están en `~/Projects/nuevo-ser/coleccion-nuevo-ser/www/books/<id>/book.json`. Los que importan aquí son `manifiesto`, `filosofia-nuevo-ser`, `manual-transicion`, `toolkit-transicion`, `ahora-instituciones`, `nacimiento` y `guia-acciones`.

## Lo que ya existe fuera de este apartado (no duplicar)

| Proyecto | Dónde | Qué hace | Relación |
|---|---|---|---|
| **Puente** | `~/Projects/puente/` (Next.js + NestJS, AGPL). **45 commits sin remoto**: subirlo | Acogida y ayuda mutua: tablón Necesito/Ofrezco, cruce, mensajería | Módulo hermano. Banco de tiempo, biblioteca de cosas y red de cuidados encajan **dentro** de Puente |
| **Flavor News Hub / app-colectivos** | `~/Projects/flavor/flavor-news-hub/` | De informarse a actuar: te lleva al colectivo que ya trabaja en un tema | Puerta de entrada. Su README dice que **no** es organización interna: ese hueco es nuestro |
| **Gestor de autoconsumo colectivo** | `~/Projects/clientes/gestorAutoconsumoColectivo/` | Comunidades energéticas | Ejemplo de herramienta pequeña y concreta |
| **Solera Zunbeltz** | `apps/solera-zunbeltz/` + `wp-plugin/solera-zunbeltz-sync/` | Personas con rol y token, tareas, sincronización, panel de WordPress, correos, versión web | **Base técnica reutilizable**: el patrón app Flutter + plugin WordPress alojado por el propio grupo |
| `nuevo_ser_core` | `packages/nuevo_ser_core/` | i18n, PDF, CSV, mapa, cliente API | Se reutiliza tal cual |

## Reglas de trabajo en este apartado

- Las del monorepo: nombres descriptivos en castellano, commits pequeños, tests antes del código no visual, verificar antes de inventar.
- **Antes de añadir una función, pasarla por `docs/01-criterios.md`.** Si no supera las preguntas, no entra.
- **Cada app tiene un grupo piloto real antes de pasar de la F1.** Sin piloto, no hay F2.
- **El marco legal manda**: lo que la app decide no tiene validez jurídica por sí solo. Cada ficha tiene que decir con claridad qué es vinculante y qué no (ver `docs/04-concejo.md` §3).
- **Idiomas**: es/eu de partida (como Zunbeltz) y ca/gl cuando haya revisión nativa. Euskera de borrador = pendiente de revisión.
- **Licencia**: AGPL-3.0, como Puente.

## Estado

| App | Estado |
|---|---|
| Concejo | `social/apps/concejo/` + `social/wp-plugin/concejo/`. v0.1.0 (2026-11-07): F1C-1 a F1C-6 (mesa, canal en papel, acta, servidor propio en WordPress y trabajo sin red). Siguiente: avisos y correo semanal, APK. Busca pueblo o concejo piloto. Ver `social/apps/concejo/CLAUDE.md` |
| Resto del catálogo | Ideas, ver `docs/03-catalogo-apps.md` |
