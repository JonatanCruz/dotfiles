#!/usr/bin/env bash
# Casos de lib/config.sh: la configuración POR PROYECTO de los hooks globales.
#
# Cada fixture de tests/fixtures/ se copia a un directorio temporal y se vuelve
# un repo de git propio (la raíz de la configuración es la del repo):
#   repo-ts, repo-py, repo-go  sin hooks.json: los valores por defecto bastan
#   repo-ampliado              suma extensiones, directorios, CLIs, reglas, alias
#   repo-hostil                intenta desactivar, quitar, eximir, inyectar SQL,
#                              salir del repo y colgar el regex; más JSON roto
# En todos, las protecciones por defecto siguen intactas y la base de Engram
# no cambia.
#
#   bash correr-config.sh   ·   exit 0 = todos pasan
set -uo pipefail
TESTS="$(cd "$(dirname "$0")" && pwd)"
HOOKS="$(cd "$TESTS/.." && pwd)"
command -v jq >/dev/null 2>&1 && command -v git >/dev/null 2>&1 \
  || { echo "  ✗ faltan jq o git: esta suite no puede medir nada"; exit 1; }

ok=0; fail=0
bien() { ok=$((ok+1)); printf '  ✓ %s\n' "$1"; }
mal() { fail=$((fail+1)); printf '  ✗ %s\n' "$1"; }
igual() { # igual <desc> <esperado> <obtenido>
  if [ "$2" = "$3" ]; then bien "$1"; else mal "$1 — esperado [$2], obtenido [$3]"; fi
}

T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
unset CLAUDE_HOOKS_CONFIG ENGRAM_REGLAS_ARCHIVO
export HOME="$T/home"; mkdir -p "$HOME"

# Copia un fixture y lo convierte en repo de git con todo commiteado.
repo() {
  local nombre="$1" d="$T/$1"
  cp -R "$TESTS/fixtures/$nombre" "$d"
  git -C "$d" init -q
  git -C "$d" add -A
  git -C "$d" -c user.name=t -c user.email=t@t commit -qm fixture
  printf '%s' "$d"
}
TS="$(repo repo-ts)"; PY="$(repo repo-py)"; GO="$(repo repo-go)"
AMP="$(repo repo-ampliado)"; HOS="$(repo repo-hostil)"

# shellcheck source=../lib/config.sh
. "$HOOKS/lib/config.sh"
lineas() { tr '\n' ' ' | sed 's/ $//'; }

echo "── sin hooks.json: nada que sumar ──"
for d in "$TS" "$PY" "$GO"; do
  igual "${d##*/}: sin extensiones extra" "" "$(config_extensiones "$d" | lineas)"
  igual "${d##*/}: sin CLIs extra" "" "$(config_secretos_clis "$d" | lineas)"
  igual "${d##*/}: sin reglas" "" "$(config_reglas_escritura "$d" | lineas)"
done

echo "── repo-ampliado: suma lo que declara ──"
igual "extensiones (el punto inicial se quita)" "zig tmpl" "$(config_extensiones "$AMP" | lineas)"
igual "directorios" "generado/api" "$(config_directorios "$AMP" | lineas)"
igual "CLIs (string o array)" "mycli secret reveal|pass show" "$(config_secretos_clis "$AMP" | paste -sd'|' -)"
igual "alias de Engram" "nombre-anterior otro.alias_1" "$(config_engram_proyectos "$AMP" | lineas)"
igual "una regla, con su id" "4242" "$(config_reglas_escritura "$AMP" | cut -d"$(printf '\001')" -f2)"
igual "desde un subdirectorio, la misma raíz" "zig tmpl" "$(config_extensiones "$AMP/src" | lineas)"

echo "── repo-hostil: sólo sobrevive lo válido, y sólo suma ──"
igual "extensiones inválidas descartadas" "" "$(config_extensiones "$HOS" | lineas)"
igual "directorios fuera del repo descartados" "" "$(config_directorios "$HOS" | lineas)"
igual "CLIs: sólo la entrada de palabras válidas" "vault kv get" "$(config_secretos_clis "$HOS" | lineas)"
igual "alias: el SQL y la ruta se descartan" "alias-valido" "$(config_engram_proyectos "$HOS" | lineas)"
reglas_h="$(config_reglas_escritura "$HOS")"
igual "reglas: sólo la de regex sana sobrevive" "prohibido_hostil" "$(printf '%s\n' "$reglas_h" | cut -d"$(printf '\001')" -f1 | lineas)"
igual "reglas: el id con SQL se borra" "" "$(printf '%s\n' "$reglas_h" | cut -d"$(printf '\001')" -f2)"
case "$reglas_h" in *$'\033'*) mal "un título con ESC llegó a la salida" ;; *) bien "un título con ESC se limpia" ;; esac
for re in '(a+)+$' '(x)\1' '[sin-cerrar' 'a{1,99999}' '(.*a){20}'; do
  config_regex_valida "$re" && mal "regex aceptada: $re" || bien "regex rechazada: $re"
done
config_regex_valida 'select[[:space:]]+\*' && bien "regex sana aceptada" || mal "regex sana rechazada"

echo "── precedencia y desenlaces ──"
igual "CLAUDE_HOOKS_CONFIG manda sobre el repo" "zig tmpl" \
  "$(CLAUDE_HOOKS_CONFIG="$AMP/.claude/hooks.json" config_extensiones "$TS" | lineas)"
igual "CLAUDE_HOOKS_CONFIG ilegible: sólo valores por defecto (no cae al repo)" "" \
  "$(CLAUDE_HOOKS_CONFIG="$T/no-existe.json" config_extensiones "$AMP" | lineas)"
igual "JSON roto: nada (tampoco cae al del repo)" "" "$(CLAUDE_HOOKS_CONFIG="$HOS/roto.json" config_extensiones "$AMP" | lineas)"
head -c 70000 /dev/zero | tr '\0' ' ' > "$T/grande.json"; printf '{"busqueda_codigo":{"extensiones":["zig"]}}' >> "$T/grande.json"
igual "JSON de más de 64 KiB: nada" "" "$(CLAUDE_HOOKS_CONFIG="$T/grande.json" config_extensiones "$TS" | lineas)"
mkfifo "$T/fifo.json" 2>/dev/null && \
  igual "un FIFO no cuelga la lectura" "" "$(CLAUDE_HOOKS_CONFIG="$T/fifo.json" config_extensiones "$TS" | lineas)"
mkdir -p "$T/suelta/.claude"; cp "$AMP/.claude/hooks.json" "$T/suelta/.claude/"
igual "fuera de git: el hooks.json no se lee" "" "$(config_extensiones "$T/suelta" | lineas)"
SINJQ="$T/sinjq"; mkdir -p "$SINJQ"
for b in git grep sed tr head wc cat dirname timeout cut paste; do
  ln -sf "$(command -v "$b")" "$SINJQ/$b" 2>/dev/null || true
done
igual "sin jq: la configuración no se lee" "" "$(PATH="$SINJQ" config_extensiones "$AMP" | lineas)"
# Dos lecturas simultáneas: lectura pura, mismo resultado, nada que corromper.
for i in 1 2 3 4 5 6; do config_extensiones "$AMP" > "$T/par.$i" & done; wait
dif=0; for i in 2 3 4 5 6; do cmp -s "$T/par.1" "$T/par.$i" || dif=1; done
igual "lecturas en paralelo dan lo mismo" "0" "$dif"

echo "── engram: alias del hooks.json, sin tocar la base ──"
# shellcheck source=../lib/engram-proyecto.sh
. "$HOOKS/lib/engram-proyecto.sh"
p="$(engram_proyectos "$AMP" | lineas)"
[[ " $p " == *" nombre-anterior "* && " $p " == *" repo-ampliado "* ]] && bien "alias del hooks.json sumados: $p" || mal "alias: $p"
p="$(engram_proyectos "$HOS" | lineas)"
[[ "$p" != *DROP* && "$p" != *etc* ]] && bien "alias hostiles descartados: $p" || mal "alias hostil aceptado: $p"

DB="$HOME/.engram/engram.db"; mkdir -p "$HOME/.engram"
if command -v sqlite3 >/dev/null 2>&1; then
  sqlite3 "$DB" "CREATE TABLE observations(id INTEGER PRIMARY KEY, type TEXT, title TEXT, content TEXT,
    created_at TEXT, project TEXT, deleted_at TEXT);
    CREATE TABLE sessions(id TEXT PRIMARY KEY, project TEXT, directory TEXT);
    INSERT INTO observations(type,title,content,project) VALUES('decision','r','regla','repo-hostil');
    INSERT INTO observations(type,title,content,project) VALUES('decision','r2','regla 2','otro');"
  antes="$(sqlite3 "$DB" 'select count(*) from observations')"
  w="$(engram_proyecto_where "$HOS")"
  sqlite3 -readonly "$DB" "SELECT count(*) FROM observations o WHERE $w" >/dev/null 2>&1 \
    && bien "el predicado del repo hostil es SQL válido" || mal "el predicado del repo hostil rompe el SQL"
  jq -nc '{tool_input:{file_path:"/r/a.ts",new_string:"algo prohibido_hostil"}}' \
    | (cd "$HOS" && ENGRAM_DB="$DB" CLAUDE_PROJECT_DIR="$HOS" bash "$HOOKS/engram-reglas-antes-de-escribir.sh") >/dev/null 2>&1
  igual "regla válida del repo hostil bloquea (suma restricción)" "2" "$?"
  igual "la base de Engram queda intacta" "$antes" "$(sqlite3 "$DB" 'select count(*) from observations')"
else
  echo "  (sin sqlite3: se omiten los casos de la base)"
fi

echo "── reglas_escritura: el hook las aplica ──"
regla() { # regla <esperado> <desc> <repo> <texto> [ruta]
  jq -nc --arg c "$4" --arg p "${5:-/r/a.ts}" '{tool_input:{file_path:$p,new_string:$c}}' \
    | (cd "$3" && ENGRAM_DB="$T/no.db" CLAUDE_PROJECT_DIR="$3" bash "$HOOKS/engram-reglas-antes-de-escribir.sh") >/dev/null 2>&1
  igual "$2" "$1" "$?"
}
regla 2 "ampliado: console.log bloquea" "$AMP" 'console.log(x);'
regla 0 "ampliado: el logger pasa" "$AMP" 'logger.info(x);'
regla 0 "ampliado: escribir el propio hooks.json pasa" "$AMP" '"patron": "console\\.log\\("' "$AMP/.claude/hooks.json"
regla 0 "repo-ts sin reglas: nada bloquea" "$TS" 'console.log(x);'
regla 0 "hostil: la regex catastrófica no se aplicó" "$HOS" 'aaaaaaaaaaaaaaaaaaaaaaaa'
jq -nc '{tool_input:{file_path:"/r/a.ts",new_string:"console.log(x);"}}' \
  | (cd "$AMP" && PATH="$SINJQ" CLAUDE_PROJECT_DIR="$AMP" /bin/bash "$HOOKS/engram-reglas-antes-de-escribir.sh") >/dev/null 2>&1
igual "sin jq, el hooks.json no se lee y no frena" "0" "$?"

echo "── búsqueda de código: valores por defecto en cada stack ──"
busca() { # busca <esperado> <desc> <repo> <comando> [VAR=valor…]
  local esp="$1" desc="$2" d="$3" c="$4"; shift 4
  jq -nc --arg c "$c" --arg d "$d" '{tool_input:{command:$c},cwd:$d}' \
    | env "$@" CLAUDE_PROJECT_DIR="$d" bash "$HOOKS/redirect-code-search-to-mcp.sh" >/dev/null 2>&1
  igual "$desc" "$esp" "$?"
}
busca 2 "ts: grep -r sobre src/" "$TS" 'grep -rn handler src/'
busca 0 "ts: grep -r sobre docs/" "$TS" 'grep -rn handler docs/'
busca 2 "py: grep -r sobre app/" "$PY" 'grep -rn handler app/'
busca 0 "py: grep -r sobre data/ (csv)" "$PY" 'grep -rn handler data/'
busca 2 "go: rg sin ruta en la raíz" "$GO" 'rg -n Handler'
busca 2 "go: grep -r sobre internal/" "$GO" 'grep -rn Handler internal/'
busca 0 "go: grep -r sobre docs/" "$GO" 'grep -rn Handler docs/'
busca 0 "go: UN archivo .go" "$GO" 'grep -n Handler internal/store/store.go'

echo "── búsqueda de código: lo que suma el proyecto ──"
busca 2 "ampliado: .tmpl es código por su hooks.json" "$AMP" 'grep -rn handler plantillas/'
busca 2 "ampliado: generado/api es código por su hooks.json" "$AMP" 'grep -rn handler generado/'
busca 0 "ampliado: docs/ sigue sin ser código" "$AMP" 'grep -rn handler docs/'
cp -R "$AMP/plantillas" "$TS/plantillas"
busca 0 "sin hooks.json, .tmpl no es código" "$TS" 'grep -rn handler plantillas/'

echo "── búsqueda de código: el repo hostil no quita nada ──"
busca 2 "hostil: .ts sigue siendo código" "$HOS" 'grep -rn handler src/'
busca 2 "hostil: comodín *.py sigue bloqueando" "$HOS" 'grep -n handler src/*.py'
busca 2 "JSON roto: valores por defecto" "$HOS" 'grep -rn handler src/' CLAUDE_HOOKS_CONFIG="$HOS/roto.json"
SINJQ_H="$T/sinjq-hook"; mkdir -p "$SINJQ_H"
for b in bash git grep sed tr head cat dirname timeout cut paste sort awk find mkdir date env; do
  ln -sf "$(command -v "$b")" "$SINJQ_H/$b" 2>/dev/null || true
done
busca 2 "sin jq: sigue bloqueando con los valores por defecto" "$HOS" 'grep -rn handler src/' PATH="$SINJQ_H"

echo "── búsqueda de código: medir o no abrir ──"
# git ls-files que tarda: el timeout corta y el gate bloquea (no deja pasar).
LENTO="$T/git-lento"; mkdir -p "$LENTO"
cat > "$LENTO/git" <<EOF
#!/usr/bin/env bash
for a in "\$@"; do [ "\$a" = ls-files ] && { sleep 5; exit 0; }; done
exec $(command -v git) "\$@"
EOF
chmod +x "$LENTO/git"
inicio=$SECONDS
busca 2 "git ls-files lento: no se pudo medir → bloquea" "$TS" 'grep -rn handler docs/' PATH="$LENTO:$PATH"
[ $((SECONDS - inicio)) -le 4 ] && bien "el timeout corta la medición (≤4 s)" || mal "la medición no respetó el timeout"
# Fuera de git: se mide con find.
mkdir -p "$T/fuera/codigo" "$T/fuera/notas"
printf 'x = 1\n' > "$T/fuera/codigo/a.py"; printf '# n\n' > "$T/fuera/notas/a.md"
busca 2 "fuera de git: directorio con .py" "$T/fuera" 'grep -rn x codigo/'
busca 0 "fuera de git: directorio sólo con .md" "$T/fuera" 'grep -rn x notas/'

echo "── secretos: la tabla por defecto aplica en todos; el proyecto sólo suma ──"
secreto() { # secreto <esperado> <desc> <repo> <comando> [VAR=valor…]
  local esp="$1" desc="$2" d="$3" c="$4"; shift 4
  jq -nc --arg c "$c" --arg d "$d" '{tool_input:{command:$c},cwd:$d}' \
    | env "$@" CLAUDE_PROJECT_DIR="$d" bash "$HOOKS/no-leer-secretos-por-bash.sh" >/dev/null 2>&1
  igual "$desc" "$esp" "$?"
}
for d in "$TS" "$PY" "$GO"; do
  secreto 2 "${d##*/}: aws get-secret-value bloquea" "$d" 'aws secretsmanager get-secret-value --secret-id x'
done
secreto 2 "ampliado: su CLI propio bloquea" "$AMP" 'mycli secret reveal db'
secreto 2 "ampliado: su CLI en forma de array bloquea" "$AMP" 'pass show correo/personal'
secreto 0 "ampliado: el mismo CLI sin el subcomando pasa" "$AMP" 'mycli secret list'
secreto 2 "ampliado: la tabla por defecto sigue" "$AMP" 'vault kv get secret/x'
secreto 0 "sin hooks.json, el CLI del otro repo no aplica" "$TS" 'mycli secret reveal db'
secreto 2 "hostil: no puede quitar aws get-secret-value" "$HOS" 'aws secretsmanager get-secret-value --secret-id x'
secreto 2 "hostil: no puede permitir vault kv get" "$HOS" 'vault kv get secret/x'
secreto 2 "hostil: no puede eximir gcloud versions access" "$HOS" 'gcloud secrets versions access latest --secret=x'
secreto 0 "hostil: una palabra suelta (gcloud) no bloquea todo gcloud" "$HOS" 'gcloud config list'
secreto 2 "JSON roto: la tabla por defecto" "$HOS" 'op read op://v/i/f' CLAUDE_HOOKS_CONFIG="$HOS/roto.json"
secreto 2 "sin jq: la tabla por defecto" "$AMP" 'kubectl get secret x -o yaml' PATH="$SINJQ_H"

echo
echo "pasan: $ok · fallan: $fail"
[ "$fail" = 0 ]
