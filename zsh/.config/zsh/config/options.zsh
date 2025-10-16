# ==============================================================================
# OPTIONS - Opciones de comportamiento de la shell
# ==============================================================================

setopt autocd              # Cambia de directorio sin escribir 'cd'
setopt extendedglob        # Permite patrones avanzados de glob
setopt nomatch             # Error si glob no coincide
setopt notify              # Notifica inmediatamente sobre cambios en jobs
unsetopt beep              # Deshabilita beep

# Navegación de directorios
setopt AUTO_PUSHD          # Añade directorio actual a stack automáticamente
setopt PUSHD_SILENT        # No imprime el stack después de pushd/popd
setopt PUSHD_IGNORE_DUPS   # No añade duplicados al stack

# Jobs y procesos
setopt LONG_LIST_JOBS      # Lista jobs en formato largo por defecto

# Ordenamiento
setopt NUMERIC_GLOB_SORT   # Ordena archivos con números de forma numérica
