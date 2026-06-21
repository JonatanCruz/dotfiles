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

set -euo pipefail

# Override explícito para tareas de migración/limpieza del propio directorio.
if [[ "${ENGRAM_MIGRATION:-}" == "1" ]]; then
  exit 0
fi

# Leer el payload del hook (JSON por stdin).
input="$(cat)"

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

# Sin path → no es nuestra incumbencia.
[[ -z "$target" ]] && exit 0

# ¿El path cae bajo el directorio de memoria del harness?
#   .../.claude/projects/<algo>/memory/...  con archivo .md  (incluye MEMORY.md)
if printf '%s' "$target" | grep -qE '\.claude/projects/[^/]+/memory/.*\.md$'; then
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
