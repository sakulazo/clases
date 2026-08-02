# Makefile — despliegue de clases.sakulazo.com
# Uso: make deploy MSG="descripción del cambio"

MSG        ?=
SSH_HOST   := sakulito@185.214.134.40
SSH_PORT   := 42932
SSH_KEY    := $(HOME)/.ssh/id_ed25519
REMOTE_DIR := /srv/clases
GIT_REMOTE := origin
GIT_BRANCH := main

.PHONY: help build push deploy verify

help: ## Muestra la ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

build: ## Construye el sitio (genera dist/)
	pnpm build

push: ## Commit + push a GitHub (requiere MSG="descripción")
	@test -n "$(MSG)" || { echo "ERROR: falta MSG=... p.ej. make deploy MSG=\"fix: scroll\""; exit 1; }
	git add -A
	git diff --cached --quiet || git commit -m "$(MSG)"
	git push $(GIT_REMOTE) $(GIT_BRANCH)

deploy: build push ## Build + push + subida al VPS
	@echo ">> Subiendo build a $(SSH_HOST):$(REMOTE_DIR)"
	@tar -C dist -cf - . | ssh -i $(SSH_KEY) -p $(SSH_PORT) $(SSH_HOST) \
	  'sudo rm -rf $(REMOTE_DIR)/_astro $(REMOTE_DIR)/contacto $(REMOTE_DIR)/nivel $(REMOTE_DIR)/index.html $(REMOTE_DIR)/escudo-el-ejido.svg \
	   && sudo tar -C $(REMOTE_DIR) -xf - \
	   && sudo chown -R vps-manager:vps-manager $(REMOTE_DIR) \
	   && sudo find $(REMOTE_DIR) -type f -exec chmod 644 {} + \
	   && sudo find $(REMOTE_DIR) -type d -exec chmod 755 {} +'
	@$(MAKE) verify

verify: ## Comprueba que https://clases.sakulazo.com responde 200
	@ssh -i $(SSH_KEY) -p $(SSH_PORT) $(SSH_HOST) 'curl -s -o /dev/null -w "HTTP %{http_code}\n" https://clases.sakulazo.com/'
