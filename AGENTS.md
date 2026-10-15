# AGENTS.md

Web estática Astro 4 + Tailwind (SSG) de clases particulares — clases.sakulazo.com.
Sin backend ni base de datos. El contenido y la documentación están en español.

## Comandos
- Instalar: `pnpm install`
- Servidor de desarrollo: `pnpm dev`
- Build (paso de verificación): `pnpm build`   # genera dist/
- Previsualizar build: `pnpm preview`
- Desplegar: `make deploy MSG="descripción del cambio"`
  - Ejecuta build -> commit/push en `main` -> subida tar|ssh al VPS, y comprueba HTTP 200.
  - `make verify` = solo comprobar estado; `make help` = ver targets.
- NO hay scripts de test, lint, typecheck ni `astro check`. `pnpm build` es la única comprobación.

## Trampas / gotchas
- Usa **pnpm**, no npm. Los agentes/skills/comandos de `.opencode/` dicen `npm run …`: está obsoleto/incorrecto.
  La fuente de verdad es `pnpm-lock.yaml`; `package-lock.json` es un residuo.
- Fuente de verdad única de niveles/cursos = `src/data/cursos.ts` (`Nivel`, `Asignatura`, `Especialidad`).
  Basta con añadir una entrada en `cursos.ts`; `src/pages/nivel/[id].astro` genera la página vía `getStaticPaths()`.
- `src/content/clases/` está VACÍO y sin uso (no hay config de content collections). No poner contenido ahí.
- `.opencode/config.yml` y el skill `deploy-checker` contienen valores de VPS de ejemplo
  (vps.example.com, /var/www/...). Ignóralos; lo correcto es el `Makefile` + `despliegue.readme.md`.
- El deploy es destructivo: borra `/srv/clases` antes de copiar dist/. Rama por defecto única `main` (`master` ya no existe).

## Convenciones
- El alias `@/*` apunta a `src/*`.
- Todas las páginas usan `BaseLayout.astro` (props title/description) para las meta etiquetas.
- El modo oscuro usa la estrategia `class`; usar variantes `dark:` de Tailwind.
- La UI reutilizable vive en `src/components/`; los estilos globales en `src/styles/global.css`.
