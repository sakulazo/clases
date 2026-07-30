# Despliegue de clases.sakulazo.com

## Arquitectura

```
┌─ Local (desarrollo) ─────────────────────────────────────┐
│  ~/dev/clases/                                           │
│    ├── src/          ← Código fuente (Astro)             │
│    ├── public/       ← Archivos estáticos                │
│    ├── dist/         ← Build generado (ignorado en git)  │
│    ├── deploy.sh     ← Script de despliegue              │
│    └── despliegue.readme.md  ← Este documento            │
├──────────────────────────────────────────────────────────┤
│  pnpm build  →  Genera dist/                             │
│  scp         →  Copia dist/ al VPS                       │
└──────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─ VPS (producción) ─────────────────────────────────────────┐
│  Servidor: 185.214.134.40                                  │
│  Usuario SSH: vps-manager                                  │
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

- **Local**: Node.js, pnpm, Git, SSH configurado con `vps-manager`
- **VPS**: Caddy en Docker, directorio `/srv/clases/` creado
- **DNS**: Registro A de `clases.sakulazo.com` → `185.214.134.40`

## Despliegue rápido (un solo comando)

```bash
cd ~/dev/clases
./deploy.sh "Descripción de los cambios realizados"
```

Esto ejecuta automáticamente:

| Paso | Comando | Descripción |
|------|---------|-------------|
| 1 | `git add -A` | Añade todos los cambios al stage |
| 2 | `git commit -m "..."` | Commitea con el mensaje indicado |
| 3 | `git push origin master` | Sube los cambios a GitHub |
| 4 | `pnpm build` | Compila el sitio Astro → `dist/` |
| 5 | `scp -r dist/* vps-manager:/srv/clases/` | Copia los archivos al VPS |
| 6 | `ssh vps-manager "ls ..."` | Verifica que los archivos llegaron |

### Ejemplos

```bash
# Despliegue normal
./deploy.sh "Añadido nivel de bachillerato"

# Si no hay cambios nuevos, igualmente reconstruye y despliega
./deploy.sh "Re-build sin cambios en código"
```

## Despliegue manual (paso a paso)

Si prefieres hacerlo manualmente:

```bash
# 1. Guardar cambios en git
cd ~/dev/clases
git add -A
git commit -m "Descripción de los cambios"
git push origin master

# 2. Compilar
pnpm build

# 3. Copiar al VPS
scp -r dist/* vps-manager:/srv/clases/

# 4. Verificar
ssh vps-manager "ls -la /srv/clases/"
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
├── deploy.sh           ← Script de despliegue automático
└── despliegue.readme.md ← Este documento
```

## Notas importantes

- **Caddy gestiona SSL automáticamente**: Al añadir un nuevo dominio al Caddyfile, Caddy obtiene y renueva certificados Let's Encrypt sin intervención manual.
- **No hace falta reiniciar Caddy** tras copiar archivos, porque sirve contenido estático directamente desde el disco.
- **Los cambios en el Caddyfile** (como añadir un nuevo dominio) sí requieren reiniciar el contenedor: `docker compose -f /home/infra/stacks/caddy/compose.yml up -d --force-recreate caddy`
- **El sitio es 100% estático** (SSG), generado por Astro. No necesita Node.js ni base de datos en producción.

## Solución de problemas

| Problema | Posible causa | Solución |
|----------|--------------|----------|
| `scp: Permission denied` | Permisos incorrectos en `/srv/clases/` | `ssh vps "sudo chmod 755 /srv/clases && sudo find /srv/clases -type f -exec chmod 644 {} \;"` |
| Caddy no sirve el sitio | Falta el mount en compose.yml | Añadir `- /srv/clases:/srv/clases:ro` en `volumes` y recrear contenedor |
| SSL no se emite | DNS no resuelve | Verificar registro A de `clases.sakulazo.com` |
| `ssh vps-manager` no funciona | Config SSH incorrecta | Verificar `~/.ssh/config` |
