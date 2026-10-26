#!/usr/bin/env bash
# Regresión de claude/.claude/hooks/no-leer-secretos-por-bash.sh.
#
# Cada bypass que encontró una revisión de seguridad queda aquí como caso, para
# que un cambio futuro del hook no lo reabra sin que nadie lo note. Las rutas
# son sólo texto: el hook recibe el comando como JSON y nada se ejecuta.
#
#   scripts/tests/hook-secretos.sh   → sale 1 si algún caso falla
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOOK="$RAIZ/claude/.claude/hooks/no-leer-secretos-por-bash.sh"
ok=0
mal=0

probar() {
  local esperado="$1" comando="$2" rc
  jq -nc --arg c "$comando" '{tool_name:"Bash",tool_input:{command:$c}}' \
    | bash "$HOOK" >/dev/null 2>&1
  rc=$?
  if [ "$rc" = "$esperado" ]; then
    ok=$((ok + 1))
  else
    mal=$((mal + 1))
    printf '✗ esperado=%s obtenido=%s :: %q\n' "$esperado" "$rc" "$comando"
  fi
}

# Entradas raras: nunca bloquean por accidente.
probar_crudo() {
  local esperado="$1" payload="$2" rc
  printf '%s' "$payload" | bash "$HOOK" >/dev/null 2>&1
  rc=$?
  if [ "$rc" = "$esperado" ]; then ok=$((ok + 1)); else
    mal=$((mal + 1)); printf '✗ esperado=%s obtenido=%s :: payload %q\n' "$esperado" "$rc" "$payload"; fi
}

# ── Permitidos (0) ──────────────────────────────────────────────────────────
probar 0 'ls ~/.ssh'
probar 0 'ls -l ~/.ssh/id_ed25519'
probar 0 'stat ~/.config/zsh/secrets.zsh'
probar 0 'ssh-keygen -l -f ~/.ssh/id_ed25519.pub'
probar 0 'ssh -i ~/.ssh/id_ed25519 host'
probar 0 'git commit -m "no leer .env ni ~/.ssh/id_rsa"'
probar 0 'git tag -a v1 -m "rota ~/.aws/credentials"'
probar 0 'rg secrets docs/'
probar 0 'git status'
probar 0 'cat .env.example'
probar 0 "grep -n 'a\|b' claude/.claude/hooks/no-leer-secretos-por-bash.sh"
probar 0 $'make \\\n  build'
probar 0 $'ls -la \\\n  /tmp'
probar_crudo 0 ''
probar_crudo 0 '{'
probar_crudo 0 '{"tool_input":{"command":null}}'
probar_crudo 0 '{"tool_input":{}}'

# ── Bloqueados (2): lectura directa ─────────────────────────────────────────
probar 2 'cat ~/.ssh/id_ed25519'
probar 2 'cat "$HOME/.ssh/id_rsa"'
probar 2 'less ~/.aws/credentials'
probar 2 'base64 < ~/.config/zsh/secrets.zsh'
probar 2 'cp .env /tmp/x'
probar 2 'source .env'

# ── Ronda 1: exenciones, pipes y redirecciones ──────────────────────────────
probar 2 'ssh -F ~/.ssh/id_rsa host'
probar 2 'file -f ~/.ssh/id_rsa'
probar 2 'echo x < ~/.ssh/id_rsa'
probar 2 'cat <(cat ~/.ssh/id_rsa)'
probar 2 'cat <<< ~/.ssh/id_rsa'
probar 2 'ls ~/.ssh/id_rsa | xargs cat'
probar 2 "printf '%s' ~/.ssh/id_rsa | sh"
probar 2 'bash -c "cat ~/.ssh/id_rsa"'

# ── Ronda 1-2: ofuscación ───────────────────────────────────────────────────
probar 2 'cat ~/.s\sh/id_rsa'
probar 2 "cat ~/.ss''h/id_rsa"
probar 2 "cat \$'\\x7e/.ssh/id_rsa'"
probar 2 "cat \$'\\x2e\\x73\\x73\\x68/id_rsa'"
probar 2 'cat ~/.{ssh,x}/id_rsa'
probar 2 'cat ~/.s{s,}h/id_rsa'
probar 2 'cat ~/.ss{h..h}/id_rsa'

# ── Ronda 3: texto entrecomillado sin intérprete de la lista ────────────────
probar 2 'watch -n1 "cat ~/.ssh/id_rsa"'
probar 2 'git commit -m "$(cat ~/.ssh/id_rsa)"'
probar 2 'git commit -m "x" ; cat ~/.ssh/id_rsa'
probar 2 'ssh -i ~/.ssh/id_rsa -o ProxyCommand="cat ~/.ssh/id_rsa" host'
probar 2 'sudo cat "x y" ~/.ssh/id_rsa'
probar 2 'nohup cat "$HOME/.aws/credentials"'

# ── Ronda 4: continuaciones de línea ────────────────────────────────────────
probar 2 $'cat ~/.s\\\nsh/id_rsa'
probar 2 $'cat ~/.ssh/id_\\\nrsa'
probar 2 $'cat ~/.a\\\nws/credentials'
probar 2 $'cat "~/.s\\\nsh/id_rsa"'

echo "hook-secretos: ok=$ok mal=$mal"
[ "$mal" -eq 0 ]
