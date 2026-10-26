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
# Hermética: el .claude/hooks.json del proyecto desde el que se corre no cuenta.
export CLAUDE_HOOKS_CONFIG="$RAIZ/.no-existe-hooks.json"
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

# ── Ronda 5: la unión de continuaciones no debe borrar un separador real ────
# En `\\⏎` la barra está escapada y el salto separa comandos: la excepción de
# git commit y la de comandos simples se evalúan sobre el comando original.
probar 2 $'git commit -m x \\\\\ncat ~/.ssh/id_rsa'
probar 2 $'git commit -m "a b" \\\\\nbash -c "cat ~/.ssh/id_rsa"'
probar 2 $'ls ~/.ssh \\\\\ncat ~/.ssh/id_rsa'
probar 2 $'git commit -m "no leer\n~/.ssh/id_rsa"'

# ── Heredoc que ESCRIBE texto (documentación) vs heredoc que ejecuta ────────
probar 0 $'cat > /tmp/pr.md <<\'EOF\'\nla ruta .env en una tabla, y ~/.ssh/id_rsa\nEOF'
probar 0 $'cat > /tmp/pr.md <<EOF\nla ruta .env sin sustituciones\nEOF'
probar 0 $'git commit -F - <<\'EOF\'\nfix: no leer ~/.ssh/id_rsa\nEOF'
probar 2 $'cat > /tmp/x <<EOF\n$(cat ~/.ssh/id_rsa)\nEOF'
probar 2 $'cat > /tmp/x <<EOF\n`cat .env`\nEOF'
probar 2 $'cat > /tmp/x <<\'EOF\'\ntexto\nEOF\ncat ~/.ssh/id_rsa'
probar 2 $'bash <<EOF\ncat .env\nEOF'
probar 2 $'cat > /tmp/x <<EOF ; cat .env\ntexto\nEOF'

# ── Secretos de proyecto (portados de la rama de gates) ─────────────────────
probar 2 'cat secrets/prod.key'
probar 2 'cat config/db-password.txt'
probar 2 'head -5 certs/server.pem'
probar 2 'cat .gcp-credentials.json'
probar 2 "python3 -c \"print(open('.env').read())\""
probar 2 'cat .e*'
probar 2 'cat .e?'
probar 2 'gcloud secrets versions access latest --secret=X'
probar 2 'gcloud --project p secrets versions access --secret=X latest'
probar 0 'gcloud secrets list'
# Falso positivo asumido: el texto citado cuenta (sólo un git commit simple es prosa).
probar 2 'echo "gcloud secrets versions access es el comando que lee"'
probar 0 'git commit -m "docs: gcloud secrets versions access es el comando que lee"'
probar 0 'cat pkg/auth/src/admin/reset-user-password.usecase.ts'
probar 0 'grep -n password logs/app.log'
probar 0 'wc -l .env'
probar 0 'ls *.sh'
probar 0 'grep -n x claude/.claude/hooks/tests/casos-no-leer-secretos-por-bash.txt'

# ── CLIs que devuelven el valor de un secreto, en un comando de varias líneas ─
probar 2 $'ls\naws secretsmanager get-secret-value --secret-id x'
probar 2 $'kubectl get secrets\nkubectl get secret x -o yaml'
probar 0 $'kubectl get secrets\naws secretsmanager list-secrets'

# Sin jq la tabla sigue aplicando (sobre el payload crudo).
SINJQ="$(mktemp -d)"
for b in bash cat grep sed tr awk head dirname git; do
  ln -sf "$(command -v "$b")" "$SINJQ/$b" 2>/dev/null || true
done
sinjq() {
  local esperado="$1" payload="$2" rc
  printf '%s' "$payload" | PATH="$SINJQ" bash "$HOOK" >/dev/null 2>&1
  rc=$?
  if [ "$rc" = "$esperado" ]; then ok=$((ok + 1)); else
    mal=$((mal + 1)); printf '✗ sin jq: esperado=%s obtenido=%s :: %s\n' "$esperado" "$rc" "$payload"; fi
}
sinjq 2 '{"tool_input":{"command":"vault kv get secret/x"}}'
sinjq 2 '{"tool_input":{"command":"gcloud secrets versions access latest --secret=X"}}'
sinjq 0 '{"tool_input":{"command":"vault kv list secret/"}}'
rm -rf "$SINJQ"

echo "hook-secretos: ok=$ok mal=$mal"
[ "$mal" -eq 0 ]
