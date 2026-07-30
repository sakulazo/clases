---
name: deploy-checker
description: Verifica que el proyecto Astro está listo para desplegar en el VPS
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: deployment
---

## Qué hace
Checklist pre-despliegue y comando rsync para subir al VPS.

## Pre-deploy
- [ ] `npm run build` sin errores
- [ ] Enlaces internos funcionan
- [ ] Meta tags SEO presentes
- [ ] Contenido actualizado

## Deploy
```bash
rsync -avz --delete dist/ user@vps:/var/www/clasesparticulares/
```
