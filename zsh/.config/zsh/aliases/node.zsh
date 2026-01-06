# ==============================================================================
# NODE - Aliases para gestores de paquetes JavaScript/TypeScript
# ==============================================================================
# Soporte para npm, pnpm, yarn, y bun

# ==============================================================================
# NPM
# ==============================================================================
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nu='npm uninstall'
alias nup='npm update'
alias nr='npm run'
alias nrs='npm run start'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrt='npm run test'
alias nrl='npm run lint'
alias nrf='npm run format'
alias nci='npm ci'
alias nls='npm ls'
alias nout='npm outdated'
alias nau='npm audit'
alias nauf='npm audit fix'

# ==============================================================================
# PNPM (más rápido y eficiente)
# ==============================================================================
alias pi='pnpm install'
alias pid='pnpm install -D'
alias pig='pnpm install -g'
alias pu='pnpm uninstall'
alias pup='pnpm update'
alias pr='pnpm run'
alias prs='pnpm run start'
alias prd='pnpm run dev'
alias prb='pnpm run build'
alias prt='pnpm run test'
alias prl='pnpm run lint'
alias prf='pnpm run format'
alias pa='pnpm add'
alias pad='pnpm add -D'
alias pag='pnpm add -g'
alias px='pnpm dlx'  # Ejecutar paquetes sin instalar

# ==============================================================================
# YARN
# ==============================================================================
alias yi='yarn install'
alias ya='yarn add'
alias yad='yarn add -D'
alias yag='yarn global add'
alias yu='yarn upgrade'
alias yr='yarn run'
alias yrs='yarn start'
alias yrd='yarn dev'
alias yrb='yarn build'
alias yrt='yarn test'
alias yrl='yarn lint'

# ==============================================================================
# BUN (runtime ultra-rápido)
# ==============================================================================
alias bi='bun install'
alias ba='bun add'
alias bad='bun add -d'
alias br='bun run'
alias brs='bun run start'
alias brd='bun run dev'
alias brb='bun run build'
alias brt='bun run test'
alias bx='bunx'  # Ejecutar paquetes sin instalar

# ==============================================================================
# FUNCIONES ÚTILES
# ==============================================================================

# Detectar y usar el gestor de paquetes correcto del proyecto
pkg() {
  if [[ -f "bun.lockb" ]]; then
    bun "$@"
  elif [[ -f "pnpm-lock.yaml" ]]; then
    pnpm "$@"
  elif [[ -f "yarn.lock" ]]; then
    yarn "$@"
  elif [[ -f "package-lock.json" ]]; then
    npm "$@"
  else
    echo "No se detectó ningún lockfile. Usando npm por defecto."
    npm "$@"
  fi
}

# Instalar dependencias con el gestor correcto
pkgi() {
  if [[ -f "bun.lockb" ]]; then
    bun install
  elif [[ -f "pnpm-lock.yaml" ]]; then
    pnpm install
  elif [[ -f "yarn.lock" ]]; then
    yarn install
  elif [[ -f "package-lock.json" ]]; then
    npm install
  else
    echo "No se detectó ningún lockfile. Usando npm por defecto."
    npm install
  fi
}

# Ejecutar scripts con el gestor correcto
pkgr() {
  if [[ -f "bun.lockb" ]]; then
    bun run "$@"
  elif [[ -f "pnpm-lock.yaml" ]]; then
    pnpm run "$@"
  elif [[ -f "yarn.lock" ]]; then
    yarn run "$@"
  elif [[ -f "package-lock.json" ]]; then
    npm run "$@"
  else
    echo "No se detectó ningún lockfile. Usando npm por defecto."
    npm run "$@"
  fi
}

# Limpiar node_modules y reinstalar
pkgclean() {
  echo "Eliminando node_modules..."
  rm -rf node_modules
  echo "Reinstalando dependencias..."
  pkgi
}
