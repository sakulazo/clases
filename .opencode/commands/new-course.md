---
description: Crea un nuevo nivel educativo en el sitio (datos + ruta dinámica)
agent: web-builder
subtask: true
---

Añade un nuevo nivel educativo al sitio. Sigue estos pasos:
1. Añade la entrada en `src/data/cursos.ts` siguiendo la interfaz `Nivel`
2. La ruta dinámica `src/pages/nivel/[id].astro` lo generará automáticamente
3. Verifica con `npm run build`

El nombre del nivel es: $ARGUMENTS
