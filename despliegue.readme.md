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
│    └── tar|ssh  →  Sube dist/ al VPS (usuario sakulito)  │
└──────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─ VPS (producción) ─────────────────────────────────────────┐
│  Servidor: 185.214.134.40 (SSH puerto 42932)              │
│  Usuario SSH: sakulito (sudo sin contraseña)              │
│                                                            │
│  /srv/clases/          ← Archivos servidos por Caddy       │
│    ├── index.html                                          │
│    ├── _astro/                                             │
│    ├── contacto/                                           │
│    ├── nivel/                                              │
│    └── escudo-el-ejido.svg                                 │
│                                                            │
│  Caddy (Docker)                                            │
│    ├── Puerto 80  → Redirige a HTTPS                       │
│    ├── Puerto 443 → Sirve con SSL automático               │
│    └── Config: /home/infra/stacks/caddy/Caddyfile          │
└──────────────────────────────────────────────────────────┘
```

## Requisitos previos

- **Local**: Node.js, pnpm, Git, clave `~/.ssh/id_ed25519` autorizada para `sakulito`
- **VPS**: Caddy en Docker, directorio `/srv/clases/` creado, `sakulito` con sudo sin contraseña
- **DNS**: Registro A de `clases.sakulazo.com` → `185.214.134.40`

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
tar -C dist -cf - . | ssh -i ~/.ssh/id_ed25519 -p 42932 sakulito@185.214.134.40 \
  'sudo tar -C /srv/clases -xf - && sudo chown -R vps-manager:vps-manager /srv/clases'

# 4. Verificar
curl -s -o /dev/null -w "%{http_code}\n" https://clases.sakulazo.com/
```

## Estructura del proyecto

```
~/dev/clases/
├── src/
│   ├── components/     ← Componentes reutilizables (Header, Footer, Hero, etc.)
│   ├── data/           ← Datos de cursos y niveles
│   ├── layouts/        ← Layouts de Astro
│   ├── pages/          ← Páginas del sitio
│   │   ├── index.astro
│   │   ├── contacto.astro
│   │   └── nivel/[id].astro
│   └── styles/         ← Estilos globales
├── public/             ← Archivos estáticos (svg, favicon, etc.)
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
| `ssh sakulito` no funciona | Clave no autorizada | Verificar `~/.ssh/id_ed25519.pub` en `/home/sakulito/.ssh/authorized_keys` |
| Push a `master` por error | Rama antigua ya borrada | Usar `git push origin main`; `master` fue eliminada el 2026-08-03 |
