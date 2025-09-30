# Configuración de Zsh

Configuración completa de Zsh con aliases modernos, plugins y optimizaciones de rendimiento.

## Características

- **Editor predeterminado:** Neovim
- **Modo de edición:** Vi/Vim
- **Historial:** 10,000 comandos persistentes
- **Autocompletado:** Menú interactivo con colores
- **Plugins:** Autosuggestions, syntax highlighting, substring search
- **Integración:** Starship, Zoxide, FZF, NVM

## Estructura

```
zsh/
└── .zshrc    # Configuración principal
```

## Instalación

### 1. Aplicar con Stow

```bash
cd ~/dotfiles
stow zsh
```

### 2. Cambiar Shell a Zsh (si no está configurado)

```bash
chsh -s $(which zsh)
```

Cierra sesión y vuelve a entrar.

### 3. Instalar Dependencias

**Herramientas CLI modernas (recomendadas):**
```bash
# Ubuntu/Debian
sudo apt install eza bat fd-find ripgrep fzf

# Homebrew (Linux/macOS)
brew install eza bat fd ripgrep fzf
```

**Zoxide (navegación inteligente):**
```bash
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
```

**NVM (Node Version Manager):**
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

## Aliases Principales

### Navegación de Archivos (eza)

```bash
ls          # Listar archivos con iconos
l           # Lista detallada
la          # Lista detallada con archivos ocultos
ll          # Lista con estado de Git
lt          # Vista de árbol (2 niveles)
llt         # Vista de árbol (3 niveles)
```

### Git

```bash
g           # git
lg          # lazygit

# Estados
gs          # git status (corto)
gst         # git status (completo)

# Staging
ga          # git add
gaa         # git add -A

# Commits
gc          # git commit -m
gca         # git commit -am

# Sincronización
gp          # git push
gpl         # git pull

# Ramas
gco         # git checkout
gcb         # git checkout -b (crear rama)
gb          # git branch

# Historial
gl          # git log (formato gráfico)
```

### Tmux

```bash
tn <nombre>  # Crear sesión nueva
ta <nombre>  # Adjuntar a sesión
tl           # Listar sesiones
tk <nombre>  # Matar sesión
tks          # Matar todas las sesiones
```

### Navegación de Directorios

```bash
..          # cd ..
...         # cd ../..
....        # cd ../../..
~           # cd ~

# Zoxide (cd inteligente)
z <carpeta> # Saltar a carpeta frecuente
zi          # Búsqueda interactiva
zq          # Ver base de datos de carpetas
zrm         # Eliminar carpeta de base de datos
```

### Edición

```bash
v           # nvim
vim         # nvim
sv          # sudo nvim

# Configuraciones
zshrc       # Editar ~/.zshrc
tmuxconf    # Editar ~/.tmux.conf
nvimconf    # Abrir config de Neovim
```

### Utilidades

```bash
cat         # bat (syntax highlighting)
ff          # fd (buscar archivos, incluye ocultos)
rg          # ripgrep (case-insensitive)
yz          # yazi (file manager)

c           # clear
e           # exit
t           # touch

ducks       # Mostrar carpetas más pesadas
myip        # Obtener IP pública
```

## Características Avanzadas

### Historial Inteligente

```bash
# Buscar en historial mientras escribes
# Usa ↑/↓ para buscar comandos que empiecen con lo que escribiste
```

Configurado con:
- Compartido entre sesiones
- Ignora duplicados
- Ignora comandos que empiezan con espacio
- Persistencia de 10,000 comandos

### Modo Vi

El shell usa modo Vi para edición de línea:
- `ESC` - Modo normal
- `i` - Modo inserción
- `hjkl` - Navegación en modo normal
- `/` - Buscar en historial

### Autocompletado Mejorado

- **Tab** - Mostrar sugerencias
- **Tab Tab** - Navegar menú interactivo
- Colores para distinguir tipos de archivos
- Descripciones de comandos

## Plugins Cargados

### zsh-autosuggestions
Sugiere comandos basados en tu historial.
- Usa `→` para aceptar sugerencia completa
- Usa `Ctrl+→` para aceptar palabra por palabra

### zsh-syntax-highlighting
Resalta comandos mientras escribes:
- Verde: comando válido
- Rojo: comando inválido
- Azul: path existente

### zsh-history-substring-search
Busca en historial con `↑/↓` filtrando por lo que escribiste.

## Variables de Entorno

```bash
EDITOR=nvim          # Editor predeterminado
PAGER=less           # Paginador
FUNCNEST=1000        # Límite de anidamiento (para Starship)
```

## Opciones de Shell Configuradas

```bash
autocd                 # cd solo con el nombre del directorio
extendedglob          # Patrones avanzados de glob
AUTO_PUSHD            # cd automático añade a stack
PUSHD_IGNORE_DUPS     # No duplica entradas en stack
SHARE_HISTORY         # Comparte historial entre sesiones
HIST_IGNORE_DUPS      # Ignora comandos duplicados
```

## Personalización

### Añadir Aliases Personalizados

Edita `.zshrc` en la sección 2:
```bash
alias mi_alias='mi comando'
```

Recarga la configuración:
```bash
source ~/.zshrc
```

### Cambiar a Modo Emacs

Si prefieres atajos de Emacs en lugar de Vi:
```bash
# En .zshrc, cambia:
bindkey -v    # por:
bindkey -e
```

### Modificar Prompt

El prompt es manejado por Starship. Ver `starship/README.md` para personalización.

## Integración con Otras Herramientas

### FZF (Fuzzy Finder)
```bash
Ctrl+R    # Buscar en historial
Ctrl+T    # Buscar archivos
Alt+C     # Cambiar directorio
```

### Zoxide
Aprende los directorios que más usas:
```bash
z dotfiles     # Salta a ~/dotfiles
z conf nv      # Salta a ~/.config/nvim (fuzzy)
```

### NVM
```bash
nvm install --lts    # Instalar última versión LTS de Node
nvm use 18           # Usar Node v18
nvm ls               # Listar versiones instaladas
```

## Solución de Problemas

### Los aliases no funcionan
```bash
# Verifica que .zshrc está siendo cargado
echo $SHELL
# Debería mostrar: /usr/bin/zsh o similar

# Recarga la configuración
source ~/.zshrc
```

### Autocompletado no funciona
```bash
# Limpia la caché de completado
rm ~/.zcompdump*
exec zsh
```

### Plugins no se cargan
Verifica que los plugins estén instalados:
```bash
ls ~/.zsh/
# Deberías ver:
# zsh-autosuggestions/
# zsh-syntax-highlighting/
# zsh-history-substring-search/
```

Si faltan, aplica stow de zsh-plugins:
```bash
cd ~/dotfiles
stow zsh-plugins
```

### Eza/bat no funcionan
```bash
# Verifica que estén instalados
which eza
which bat

# Si no están instalados:
sudo apt install eza bat
# o
brew install eza bat
```

### Historial no se guarda
```bash
# Verifica permisos del archivo
ls -la ~/.zsh_history

# Si no existe, créalo
touch ~/.zsh_history
```

## Performance

La configuración está optimizada para carga rápida:
- Caché de autocompletado con check de 24 horas
- Plugins cargados al final
- Compinit con opción `-i` para evitar checks inseguros

## Referencias

- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [Eza](https://github.com/eza-community/eza)
- [Bat](https://github.com/sharkdp/bat)
- [Ripgrep](https://github.com/BurntSushi/ripgrep)
- [FZF](https://github.com/junegunn/fzf)
- [Zoxide](https://github.com/ajeetdsouza/zoxide)
- [Starship](https://starship.rs/)
