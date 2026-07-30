---
name: curso-generator
description: Genera una nueva página de nivel educativo y actualiza los datos necesarios en el sitio Astro
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: content-creation
---

## Qué hace
Crea un nuevo nivel educativo completo: datos en `cursos.ts`, y la ruta dinámica `[id].astro` lo detecta automáticamente.

## Pasos
1. Añadir entrada en `src/data/cursos.ts` siguiendo la interfaz `Nivel`
2opencode la ruta dinámica en `src/pages/nivel/[id].astro` ya genera la página
3. Ejecutar `npm run build` para verificar

## Ejemplo
```typescript
{
  id: 'nuevo-nivel',
  label: 'Nuevo Nivel',
  descripcion: 'Descripción',
  asignaturas: [{ nombre: 'Asignatura', descripcion: '...', icono: '📚' }],
  horarios: { dias: ['Lunes'], horas: ['16:00'] },
  precio: '15€/h'
}
```
