---
name: curso-manager
description: Gestiona los datos maestros de cursos, niveles y asignaturas del sitio web de clases particulares
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: content-management
---

## Qué hace
Mantiene la lógica de negocio y datos centralizados de los cursos particulares. Los datos están en `src/data/cursos.ts` con interfaces TypeScript.

## Estructura de datos
```typescript
interface Nivel {
  id: string        // 'eso', 'bachillerato', 'cfgs'
  label: string     // Nombre visible
  descripcion: string
  asignaturas: Array<{ nombre: string, descripcion: string, icono: string }>
  horarios: { dias: string[], horas: string[] }
  precio: string
}
```

## Cuándo usarme
- Para añadir o modificar niveles educativos
- Para cambiar horarios o precios
- Para consultar la estructura de datos del proyecto
