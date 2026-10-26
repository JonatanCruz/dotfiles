#!/usr/bin/env bash
# Casos de lib/engram-proyecto.sh y de los dos hooks de recall que la usan:
# sólo vuelven memorias de ESTE proyecto (repo principal, sus worktrees y sus
# alias declarados); nunca las de otro repo, y un alias ajeno no puede tocar SQL.
#
#   bash correr-engram-proyecto.sh   ·   exit 0 = todos pasan
set -uo pipefail
HOOKS="$(cd "$(dirname "$0")/.." && pwd)"
command -v sqlite3 >/dev/null 2>&1 && command -v jq >/dev/null 2>&1 \
  || { echo "  (sin sqlite3 o jq: se omite)"; exit 0; }
ok=0; fail=0
bien() { ok=$((ok+1)); printf '  ✓ %s\n' "$1"; }
mal() { fail=$((fail+1)); printf '  ✗ %s\n' "$1"; }

T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export HOME="$T/home"; mkdir -p "$HOME/.engram"
DB="$HOME/.engram/engram.db"

# Un repo "alfa" con un worktree, y otro repo "beta" sin relación.
git init -q "$T/alfa" && git -C "$T/alfa" -c user.name=t -c user.email=t@t commit -q --allow-empty -m x
git -C "$T/alfa" worktree add -q "$T/alfa-wt" -b wt 2>/dev/null
git init -q "$T/beta"
mkdir -p "$T/alfa/.claude"
cat > "$T/alfa/.claude/engram-proyectos" <<'EOF'
# alias de este proyecto
viejo-nombre
x'); DROP TABLE observations; --
../../etc
EOF

sqlite3 "$DB" "CREATE TABLE observations(id INTEGER PRIMARY KEY, type TEXT, title TEXT, content TEXT,
  created_at TEXT, project TEXT, deleted_at TEXT);
CREATE VIRTUAL TABLE observations_fts USING fts5(title, content, content='observations', content_rowid='id');
CREATE TABLE sessions(id TEXT PRIMARY KEY, project TEXT, directory TEXT);
INSERT INTO sessions VALUES('s1','wt-borrado','$T/alfa/.claude/worktrees/wt-borrado');
INSERT INTO sessions VALUES('s2','alfa-hermano','$T/alfa-hermano');
INSERT INTO sessions VALUES('s3','beta','$T/beta');"
# Memorias con las mismas palabras en cuatro proyectos, más relleno para el IDF.
for p in alfa alfa-wt viejo-nombre wt-borrado alfa-hermano beta; do
  sqlite3 "$DB" "INSERT INTO observations(type,title,content,created_at,project)
    VALUES('decision','MARCA-$p rotacion credenciales despliegue','rotacion credenciales despliegue canario','2026-10-26','$p');"
done
for i in $(seq 1 120); do
  printf "INSERT INTO observations(type,title,content,created_at,project) VALUES('discovery','relleno %s','texto comun numero %s','2026-10-01','alfa');\n" "$i" "$i"
done | sqlite3 "$DB"
sqlite3 "$DB" "INSERT INTO observations_fts(rowid,title,content) SELECT id,title,content FROM observations;"

# shellcheck source=../lib/engram-proyecto.sh
. "$HOOKS/lib/engram-proyecto.sh"
echo "── deducción del proyecto ──"
p="$(engram_proyectos "$T/alfa" | tr '\n' ' ')"
[[ "$p" == *"alfa "* && "$p" == *"alfa-wt "* && "$p" == *"viejo-nombre"* ]] && bien "repo, worktree y alias: $p" || mal "faltan nombres: $p"
[[ "$p" != *DROP* && "$p" != *etc* ]] && bien "alias inválidos descartados" || mal "aceptó un alias inválido: $p"
[ "$(engram_proyectos "$T/alfa-wt" | tr '\n' ' ')" = "$p" ] && bien "desde el worktree, el mismo proyecto" || mal "el worktree da otro proyecto"
[ "$(engram_proyectos "$T/beta")" = "beta" ] && bien "otro repo: sólo su nombre" || mal "beta: $(engram_proyectos "$T/beta")"
mkdir -p "$T/suelta"
[ "$(engram_proyectos "$T/suelta")" = "suelta" ] && bien "fuera de git: el nombre de la carpeta" || mal "fuera de git"

PROMPT='necesito revisar la rotacion de credenciales del despliegue canario'
echo "── autorecall ──"
out="$(jq -nc --arg p "$PROMPT" --arg c "$T/alfa" '{prompt:$p,cwd:$c}' | bash "$HOOKS/engram-autorecall.sh" 2>/dev/null)"
[[ "$out" == *MARCA-alfa* ]] && bien "trae lo del proyecto" || mal "no trajo lo del proyecto"
[[ "$out" != *MARCA-beta* ]] && bien "NO trae lo de otro repo" || mal "trajo memorias de otro repo"
out="$(jq -nc --arg p "$PROMPT" --arg c "$T/beta" '{prompt:$p,cwd:$c}' | bash "$HOOKS/engram-autorecall.sh" 2>/dev/null)"
[[ "$out" != *MARCA-alfa* ]] && bien "desde beta no trae lo de alfa" || mal "desde beta trajo lo de alfa"

echo "── recall al delegar ──"
out="$(jq -nc --arg p "$PROMPT y luego reporta" --arg c "$T/alfa" '{tool_input:{prompt:$p},cwd:$c}' \
  | bash "$HOOKS/engram-recall-antes-de-delegar.sh" 2>/dev/null)"
[[ "$out" == *MARCA-alfa* && "$out" == *MARCA-viejo-nombre* ]] && bien "trae lo del proyecto y sus alias" || mal "no trajo lo del proyecto"
[[ "$out" == *MARCA-wt-borrado* || "$out" == *MARCA-alfa-hermano* ]] && bien "trae lo de un worktree ya borrado (por directorio de sesión)" || mal "no reconoció el worktree borrado"
[[ "$out" != *MARCA-beta* ]] && bien "NO trae lo de otro repo" || mal "trajo memorias de otro repo"

[ "$(sqlite3 "$DB" 'select count(*) from observations')" = 126 ] && bien "la base sigue intacta" || mal "la base cambió"

echo
echo "pasan: $ok · fallan: $fail"
[ "$fail" = 0 ]
