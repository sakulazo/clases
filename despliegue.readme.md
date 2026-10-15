# Despliegue de clases.sakulazo.com

## Arquitectura

```
┌─ Local (desarrollo) ─────────────────────────────────────┐
│  ~/dev/clases/                                           │
│    ├── src/          ← Código fuente (Astro)             │
│    ├── public/       ← Archivos estáticos                │
│    ├── dist/         ← Build generado (ignorado en git)  │
│    ├── Makefile      ← Despliegue (make deploy)          │
│    └── despliegue.readme.md  ← Este documento            │
├──────────────────────────────────────────────────────────┤
│  make deploy MSG="..."                                   │
│    ├── pnpm build  →  Genera dist/                       │
│    ├── git add/commit/push  →  GitHub (rama main)        │
│    └── tar|ssh  →  Sube dist/ al VPS (alias SSH: vps)    │
└──────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─ VPS (producción) ─────────────────────────────────────────┐
│  Servidor: VPS de producción (SSH por alias: vps)         │
│  Usuario SSH: sakulito (sudo sin contraseña)              │
│                                                            │
│  /srv/clases/          ← Archivos servidos por Caddy       │
│    ├── index.html                                          │
│    ├── _astro/                                             │
│    ├── logo.svg                                            │
│    ├── logo_clases_2colores_vertical.svg                   │
│    └── escudo-el-ejido.svg                                 │
│                                                            │
│  Caddy (Docker)                                            │
│    ├── Puerto 80  → Redirige a HTTPS                       │
│    ├── Puerto 443 → Sirve con SSL automático               │
│    └── Config: /home/infra/stacks/caddy/Caddyfile          │
└──────────────────────────────────────────────────────────┘
```

## Requisitos previos

- **Local**: Node.js, pnpm, Git y el alias SSH `vps` de `~/.ssh/config`
- **VPS**: Caddy en Docker, directorio `/srv/clases/` creado, `sakulito` con sudo sin contraseña
- **DNS**: Registro A de `clases.sakulazo.com` → IP del VPS

## Despliegue rápido (un solo comando)

```bash
cd ~/dev/clases
make deploy MSG="Descripción de los cambios realizados"
```

Esto ejecuta automáticamente:

| Paso | Comando | Descripción |
|------|---------|-------------|
| 1 | `pnpm build` | Compila el sitio Astro → `dist/` |
| 2 | `git add -A` | Añade todos los cambios al stage |
| 3 | `git commit -m "..."` | Commitea con el mensaje indicado |
| 4 | `git push origin main` | Sube los cambios a GitHub |
| 5 | `tar \| ssh` | Copia `dist/` a `/srv/clases/` (con permisos y propietario correctos) |
| 6 | `curl` | Verifica HTTP 200 en `https://clases.sakulazo.com/` |

> **Modelo (GitOps de escritura única)**: un solo escritor (tu máquina local); el
> VPS solo recibe el build, no clona el repo. Mismo patrón que `sakulazo/landing`,
> `sakulazo/portfolio` y `sakulazo/gestaller`. Documentado en `sakulazo/infra-vps`.

### Ejemplos

```bash
# Despliegue normal
make deploy MSG="Añadido nivel de bachillerato"

# Solo verificar el estado actual
make verify

# Ayuda de targets
make help
```

## Despliegue manual (paso a paso)

Si prefieres hacerlo manualmente:

```bash
# 1. Compilar
pnpm build

# 2. Guardar cambios en git
git add -A
git commit -m "Descripción de los cambios"
git push origin main

# 3. Copiar al VPS (tar evita sobrescribir con permisos rotos)
tar -C dist -cf - . | ssh vps \
  'sudo tar -C /srv/clases -xf - && sudo chown -R vps-manager:vps-manager /srv/clases'

# 4. Verificar
curl -s -o /dev/null -w "%{http_code}\n" https://clases.sakulazo.com/
```

## Estructura del proyecto

```
~/dev/clases/
├── src/
│   ├── components/     ← UI reutilizable (Header, Hero, NivelSection, Icon…)
│   ├── data/           ← cursos.ts (niveles y asignaturas: fuente de verdad)
│   ├── layouts/        ← BaseLayout.astro
│   ├── pages/          ← index.astro (sitio de una sola página)
│   └── styles/         ← global.css
├── public/             ← Archivos estáticos (logo.svg, escudo-el-ejido.svg…)
├── dist/               ← Build generado (no se sube a git)
├── astro.config.mjs    ← Configuración de Astro
├── tailwind.config.mjs ← Configuración de Tailwind CSS
├── package.json
├── Makefile            ← Despliegue (make deploy)
└── despliegue.readme.md ← Este documento
```

## Notas importantes

- **Caddy gestiona SSL automáticamente**: Al añadir un nuevo dominio al Caddyfile, Caddy obtiene y renueva certificados Let's Encrypt sin intervención manual.
- **No hace falta reiniciar Caddy** tras copiar archivos, porque sirve contenido estático directamente desde el disco.
- **Los cambios en el Caddyfile** (como añadir un nuevo dominio) sí requieren reiniciar el contenedor: `docker compose -f /home/infra/stacks/caddy/compose.yml up -d --force-recreate caddy`
- **El sitio es 100% estático** (SSG), generado por Astro. No necesita Node.js ni base de datos en producción.
- **Rama `main`**: el proyecto vive en `main` (2026-08-03: se eliminó el residual de la antigua `main` y se unificó; `master` ya no existe).

## Solución de problemas

| Problema | Posible causa | Solución |
|----------|--------------|----------|
| `sudo: Permission denied` | `sakulito` sin sudo NOPASSWD | Verificar `/etc/sudoers.d/` |
| Caddy no sirve el sitio | Falta el mount en compose.yml | Añadir `- /srv/clases:/srv/clases:ro` en `volumes` y recrear contenedor |
| SSL no se emite | DNS no resuelve | Verificar registro A de `clases.sakulazo.com` |
| `ssh vps` no funciona | Clave no autorizada | Comprobar la clave del alias (`~/.ssh/config` → `IdentityFile`) en el `authorized_keys` de `sakulito` |
| Push a `master` por error | Rama antigua ya borrada | Usar `git push origin main`; `master` fue eliminada el 2026-08-03 |
