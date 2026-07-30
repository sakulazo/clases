#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# deploy.sh - Despliegue automático de clases.sakulazo.com
# Uso:    ./deploy.sh "<mensaje del commit>"
# Ejemplo: ./deploy.sh "Añadida sección de contacto"
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# ── 1. Validar argumento ────────────────────────────────────
if [ $# -eq 0 ]; then
    echo "❌  Debes indicar un mensaje para el commit."
    echo "   Uso: $0 \"<mensaje del commit>\""
    exit 1
fi

COMMIT_MSG="$1"

echo ""
echo "🚀  Iniciando despliegue de clases.sakulazo.com"
echo "   Mensaje: $COMMIT_MSG"
echo ""

# ── 2. Verificar que estamos en el repo correcto ────────────
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "❌  No estamos dentro de un repositorio git."
    exit 1
fi

if ! git remote -v | grep -q 'github.com/sakulazo/clases'; then
    echo "⚠️   El remote no apunta a sakulazo/clases. ¿Estás en el repo correcto?"
fi

# ── 3. Git: add, commit, push ────────────────────────────────
echo "📦  Añadiendo cambios al stage..."
git add -A

if git diff --cached --quiet; then
    echo "📭  No hay cambios nuevos que commitear."
else
    echo "📝  Haciendo commit: $COMMIT_MSG"
    git commit -m "$COMMIT_MSG"

    echo "☁️   Subiendo a GitHub..."
    git push origin master
fi

# ── 4. Build ─────────────────────────────────────────────────
echo "🔨  Construyendo el sitio con pnpm..."
pnpm build

# ── 5. Copiar al VPS ────────────────────────────────────────
echo "📡  Copiando archivos al VPS (vps-manager)..."
scp -r dist/* vps-manager:/srv/clases/

# ── 6. Verificar ─────────────────────────────────────────────
echo ""
echo "🔍  Verificando despliegue..."
ssh vps-manager "ls -la /srv/clases/index.html" >/dev/null 2>&1 && \
    echo "✅  Archivos desplegados correctamente en /srv/clases/"

echo ""
echo "🎉  Despliegue completado con éxito."
echo "   https://clases.sakulazo.com"
echo ""

# ── 7. Limpieza opcional de ssh ──────────────────────────────
# (vacío a propósito)
