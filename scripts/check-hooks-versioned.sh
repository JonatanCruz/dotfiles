#!/usr/bin/env bash

# ==============================================================================
# CHECK: HOOKS CITADOS vs VERSIONADOS
# ==============================================================================
# settings.json cita hooks por ruta (~/.claude/hooks/x.sh). Si un hook existe
# solo en la máquina donde se escribió y nunca se versiona, en cualquier otro
# servidor Claude Code lo invoca, no lo encuentra y falla EN SILENCIO.
#
# Ese patrón ya se repitió tres veces (#14, #21, y una vez más al sincronizar
# un servidor a mano). Este script lo convierte en un fallo de CI.
#
# Detecta dos derivas, en direcciones opuestas:
#   - FANTASMA: citado en settings.json pero no versionado -> rompe otros servers
#   - HUÉRFANO: versionado pero que nadie cita -> código muerto (solo avisa)
#
# Uso: scripts/check-hooks-versioned.sh
# Salida: 0 si no hay fantasmas, 1 si hay al menos uno.
# ==============================================================================

set -euo pipefail

# Raíz del repo, sin depender del cwd desde el que se invoque.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly SETTINGS="$REPO_ROOT/claude/.claude/settings.json"
readonly HOOKS_DIR="$REPO_ROOT/claude/.claude/hooks"

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

if [ ! -f "$SETTINGS" ]; then
    echo -e "${RED}✗${NC} No existe $SETTINGS"
    exit 1
fi

# Los hooks citados salen de settings.json, no de un listado a mano: si mañana
# se agrega un evento nuevo (PostToolUse, Stop, ...) se recoge igual.
# Se toma solo el primer token del comando, que es la ruta; el resto son args.
mapfile -t cited < <(
    python3 -c '
import json, sys

with open(sys.argv[1]) as fh:
    settings = json.load(fh)

commands = set()
for groups in settings.get("hooks", {}).values():
    for group in groups:
        for hook in group.get("hooks", []):
            command = hook.get("command", "").strip()
            if command:
                commands.add(command.split()[0])

for command in sorted(commands):
    print(command)
' "$SETTINGS"
)

echo "🔍 Verificando hooks de Claude Code..."
echo "   citados en settings.json: ${#cited[@]}"

ghosts=()
for command in "${cited[@]}"; do
    # Solo interesan los hooks propios del repo. Un comando que apunte a otro
    # sitio (un binario del sistema, por ejemplo) no es responsabilidad nuestra.
    # El prefijo se compara como TEXTO literal tal y como aparece en el JSON:
    # no es una ruta a expandir, de ahí que el '~' vaya escapado.
    case "$command" in
        \~/.claude/hooks/*) ;;
        "\$HOME/.claude/hooks/"*) ;;
        *) continue ;;
    esac

    if [ ! -f "$HOOKS_DIR/${command##*/}" ]; then
        ghosts+=("$command")
    fi
done

# Huérfano = versionado que nadie cita. No rompe nada en otros servidores, así
# que se reporta pero no hace fallar el job.
orphans=()
for path in "$HOOKS_DIR"/*; do
    [ -f "$path" ] || continue
    name="${path##*/}"
    found=false
    for command in "${cited[@]}"; do
        if [ "${command##*/}" = "$name" ]; then
            found=true
            break
        fi
    done
    $found || orphans+=("$name")
done

if [ ${#orphans[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}⚠${NC}  Versionados que nadie cita (posible código muerto):"
    printf '   %s\n' "${orphans[@]}"
fi

if [ ${#ghosts[@]} -gt 0 ]; then
    echo -e "\n${RED}✗${NC} Hooks FANTASMA — citados en settings.json pero sin versionar:"
    printf '   %s\n' "${ghosts[@]}"
    cat <<'EOF'

En este servidor pueden existir en ~/.claude/hooks/, pero al no estar en el
repo, en cualquier otro Claude Code los invoca, no los encuentra y falla en
silencio.

Para arreglarlo, versionalos:
  cp ~/.claude/hooks/<hook> claude/.claude/hooks/
  chmod +x claude/.claude/hooks/<hook>
EOF
    exit 1
fi

echo -e "\n${GREEN}✓${NC} Los ${#cited[@]} hooks citados están versionados"
