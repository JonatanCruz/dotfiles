#!/usr/bin/env bash
# Biblioteca compartida: ¿qué memorias de Engram son de ESTE proyecto?
#
# Los hooks de recall inyectan memorias en el contexto. Sin acotarlas al
# proyecto, una sesión en un repo recibe las decisiones de otro (otro dominio,
# otras reglas), que es contaminación aunque matcheen las palabras. Acotar por
# el nombre de la carpeta tampoco alcanza: las memorias de un mismo proyecto
# quedan guardadas con el nombre de cada worktree o con nombres viejos.
#
# El proyecto se deduce, sin nada escrito acá para ningún repo concreto:
#   1. el nombre del repo PRINCIPAL (`--git-common-dir`): igual desde cualquiera
#      de sus worktrees;
#   2. el nombre de cada worktree actual del repo;
#   3. los alias que el PROPIO proyecto declare en `engram.proyectos` de su
#      `.claude/hooks.json` (ver lib/config.sh): nombres viejos, worktrees ya
#      borrados. Por compatibilidad se lee también `<repo>/.claude/engram-proyectos`
#      (uno por línea, `#` comenta).
# Fuera de un repo de git: el nombre de la carpeta (la convención de
# mem_session_start).
#
# Los alias vienen del repo y un repo clonado no es de confianza: sólo se
# aceptan nombres `[A-Za-z0-9._-]{1,64}`, y salen hacia SQL ya escapados.
# Lo peor que puede hacer un alias ajeno es pedir memorias de otro nombre: el
# recall es de sólo lectura y no puede modificar la base.

_engram_cfg="$(dirname "${BASH_SOURCE[0]}")/config.sh"
# shellcheck source=config.sh
[ -r "$_engram_cfg" ] && . "$_engram_cfg"
unset _engram_cfg

# engram_proyectos [dir] → un nombre por línea, validados y sin repetir.
engram_proyectos() {
  local dir="${1:-$PWD}" comun raiz
  comun="$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
  case "$comun" in
    */.git) raiz="${comun%/.git}" ;;
    "") raiz="" ;;
    *) raiz="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true)" ;;
  esac
  {
    if [ -n "$raiz" ]; then
      printf '%s\n' "${raiz##*/}"
      git -C "$raiz" worktree list --porcelain 2>/dev/null | sed -n 's#^worktree .*/##p'
      [ -f "$raiz/.claude/engram-proyectos" ] && sed 's/#.*//' "$raiz/.claude/engram-proyectos"
      command -v config_engram_proyectos >/dev/null 2>&1 && config_engram_proyectos "$dir"
    else
      printf '%s\n' "${dir##*/}"
    fi
  } | tr -d ' \t\r' | grep -E '^[A-Za-z0-9._-]{1,64}$' | sort -u || true
}

# engram_proyectos_sql [dir] → "'a','b'" para un IN (). Vacío si no hay ninguno.
engram_proyectos_sql() {
  engram_proyectos "${1:-}" | sed "s/'/''/g; s/^/'/; s/\$/'/" | paste -sd, - 2>/dev/null || true
}

# Literal SQL para LIKE: comillas duplicadas y \ % _ escapados (ESCAPE '\').
_engram_like() { printf '%s' "$1" | sed "s/'/''/g; s/[\\\\%_]/\\\\&/g"; }

# engram_proyecto_where [dir] → predicado SQL sobre `o` (observations) que
# acepta sólo memorias de este proyecto. Vacío si no se pudo deducir nada.
#
# Además de los nombres de engram_proyectos, Engram registra en `sessions` el
# DIRECTORIO de cada sesión: un nombre de proyecto pertenece a este repo si sus
# sesiones se abrieron dentro de él, de uno de sus worktrees, o de un worktree
# hermano con la convención `<repo>-<nombre>`. Así, una memoria guardada desde un
# worktree ya borrado sigue siendo del proyecto sin declararla en ningún lado.
engram_proyecto_where() {
  local dir="${1:-$PWD}" nombres comun raiz d dirs="" cond=""
  nombres="$(engram_proyectos_sql "$dir")"
  [ -n "$nombres" ] || return 0
  comun="$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
  case "$comun" in
    */.git) raiz="${comun%/.git}" ;;
    "") raiz="" ;;
    *) raiz="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true)" ;;
  esac
  if [ -n "$raiz" ]; then
    dirs="$(printf '%s\n' "$raiz"; git -C "$raiz" worktree list --porcelain 2>/dev/null | sed -n 's/^worktree //p')"
    while IFS= read -r d; do
      [ -n "$d" ] || continue
      d="$(_engram_like "$d")"
      cond="${cond:+$cond OR }s.directory = '$d' OR s.directory LIKE '$d/%' ESCAPE '\\'"
    done <<<"$(printf '%s\n' "$dirs" | sort -u)"
    cond="$cond OR s.directory LIKE '$(_engram_like "$raiz")-%' ESCAPE '\\'"
  fi
  if [ -n "$cond" ]; then
    printf "(o.project IN (%s) OR o.project IN (SELECT DISTINCT s.project FROM sessions s WHERE s.project IS NOT NULL AND (%s)))" "$nombres" "$cond"
  else
    printf "o.project IN (%s)" "$nombres"
  fi
}
