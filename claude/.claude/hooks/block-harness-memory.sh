#!/usr/bin/env bash
# block-harness-memory.sh — Control DURO global: Engram es el ÚNICO sistema de memoria.
#
# Bloquea (exit 2) cualquier Write/Edit/MultiEdit al sistema de memoria de archivos
# del harness de Claude Code:
#   ~/.claude/projects/<slug>/memory/MEMORY.md
#   ~/.claude/projects/<slug>/memory/*.md
#
# Motivación: el system prompt del harness inyecta una instrucción "# Memory" que
# ordena escribir esos archivos. Eso ENTRA EN CONFLICTO con la regla "Engram ONLY"
# de ~/.claude/CLAUDE.md. Una regla de prosa no previene el "error competente"
# (el agente que cree que cumple). Este hook hace el conflicto estructuralmente
# imposible — patrón Meadows ya usado en guard-sensitive-exec.sh / Reglas #13/#14.
#
# Read NO se bloquea (el usuario puede pedir leer un archivo viejo sin migrar aún).
# Override consciente y auditable: export ENGRAM_MIGRATION=1 (para migrar/limpiar
# esos archivos a mano), NUNCA un bypass silencioso.

set -uo pipefail

# Override explícito para tareas de migración/limpieza del propio directorio.
if [[ "${ENGRAM_MIGRATION:-}" == "1" ]]; then
  exit 0
fi

# Leer el payload del hook (JSON por stdin).
input="$(cat 2>/dev/null || true)"

# Extraer el path destino del tool_input. Cubre Write (file_path),
# Edit/MultiEdit (file_path). jq si está disponible; fallback a grep.
target=""
if command -v jq >/dev/null 2>&1; then
  target="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
fi
if [[ -z "$target" ]]; then
  # Fallback sin jq: extraer "file_path":"..." del JSON crudo.
  target="$(printf '%s' "$input" | grep -oE '"(file_path|path)"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1 | sed -E 's/.*:[[:space:]]*"([^"]+)"/\1/' || true)"
fi

# La ruta protegida vive en UNA variable: es LA POLÍTICA, y no cambia acá.
#   .../.claude/projects/<algo>/memory/...  con archivo .md  (incluye MEMORY.md)
MEM_RE='\.claude/projects/[^/]+/memory/[^[:space:]"'"'"'<>|;&]*\.md'

# ── EL HUECO QUE ESTO CIERRA (medido el 2026-09-19) ─────────────────────────
# Este hook estaba registrado sólo en `Write|Edit|MultiEdit`. Una escritura hecha
# desde Bash no pasaba por acá. Probado contra un mock en /tmp con la MISMA
# estructura de ruta:
#
#   python3 - <<PY  →  open(".../memory/MEMORY.md","w")   → hook exit=0, archivo escrito
#   cat > .../memory/MEMORY.md <<EOF                      → hook exit=0, archivo escrito
#
# El encabezado de este archivo decía que la regla era "estructuralmente
# imposible" de violar. No lo era: se rodeaba cambiando de herramienta.
#
# POR QUÉ NO ALCANZA con tratar el comando como si fuera un file_path: un path
# suelto en medio de un comando no dice si se LEE o se ESCRIBE, y leer NUNCA
# estuvo bloqueado (`cat`, `git log`, `less` sobre esos archivos son legítimos).
# Bloquear por mencionar la ruta daría falsos positivos y entrenaría a esquivar
# el gate. Por eso el caso Bash exige DOS condiciones simultáneas:
#   (1) la ruta protegida, y (2) un operador de ESCRITURA sobre ella.
if [[ -z "$target" ]]; then
  cmd=""
  if command -v jq >/dev/null 2>&1; then
    cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
  fi
  [[ -z "$cmd" ]] && cmd="$input"
  [[ -z "$cmd" ]] && exit 0

  # (1) ¿Menciona siquiera la ruta protegida? Si no, no es nuestra incumbencia.
  printf '%s' "$cmd" | grep -qE "$MEM_RE" || exit 0

  # (2) ¿Y es una ESCRITURA? Redirección, edición in-place, tee, copia/mueve, o
  # una apertura en modo escritura desde un intérprete.
  if printf '%s' "$cmd" | grep -qE ">>?[[:space:]]*[^[:space:]|&;]*$MEM_RE|sed[[:space:]]+[^|;&]*-i[^|;&]*$MEM_RE|tee[[:space:]]+[^|;&]*$MEM_RE|(open|write_text|writeFileSync|File\.open)[^)]*$MEM_RE[^)]*[\"'][wa]|[\"'][wa][b+]*[\"'][^)]*$MEM_RE|(cp|mv)[[:space:]]+[^|;&]*$MEM_RE"; then
    target="$(printf '%s' "$cmd" | grep -oE "$MEM_RE" | head -1)"
  else
    exit 0
  fi
fi

# Sin nada que inspeccionar → no es nuestra incumbencia.
[[ -z "$target" ]] && exit 0

if printf '%s' "$target" | grep -qE "$MEM_RE"; then
  cat >&2 <<EOF
🚫 BLOQUEADO — Engram es el ÚNICO sistema de memoria (regla "Engram ONLY" de ~/.claude/CLAUDE.md).

Intentaste escribir un archivo de memoria del harness:
  $target

NO uses el sistema de memoria de archivos del harness (MEMORY.md / memory/*.md).
En su lugar:
  • Guardar  → mem_save (con topic_key estable)
  • Recordar → mem_search / mem_context
  • Sesión   → mem_session_start / mem_session_summary

(Para migrar/limpiar estos archivos a mano: export ENGRAM_MIGRATION=1)
EOF
  exit 2
fi

exit 0
