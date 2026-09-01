# Tema — paleta única

Fuente de verdad de colores para todo el entorno. Adaptado del motor de temas
de [basecamp/omarchy](https://github.com/basecamp/omarchy), reducido a lo
portable a macOS.

## El problema que resuelve

Los hex de Catppuccin Mocha estaban copiados a mano en gitconfig, tmux,
starship, yazi y nvim. Cambiar de tema significaba editar N archivos y
encontrar todas las ocurrencias.

## Cómo funciona

```
theme/palette.sh          fuente de verdad (26 colores + roles semánticos)
theme/mix.sh              mix_color / to_rgb / strip_hash (awk puro)
theme/templates/*.tpl     plantillas con tokens {{ TOKEN }}
theme/apply.sh            renderiza plantilla -> destino
```

`apply.sh` lee la paleta, expande los tokens y escribe cada destino. Los
archivos generados llevan cabecera de "NO EDITAR".

## Uso

```bash
theme/apply.sh           # regenera todos los destinos
theme/apply.sh --check   # falla si algo está desincronizado (útil en CI)
```

Para cambiar de tema: edita los roles semánticos al final de `palette.sh`
(`ACCENT`, `SECONDARY`, `MUTED`…) y corre `theme/apply.sh`. Las plantillas
usan roles, no nombres de color, así que no hay que tocarlas.

## Tokens disponibles

| Token | Resultado |
|---|---|
| `{{ ACCENT }}` | `#89b4fa` |
| `{{ ACCENT\|strip }}` | `89b4fa` |
| `{{ ACCENT\|rgb }}` | `137,180,250` |
| `{{ BASE\|mix CRUST 25% }}` | mezcla al 25% |

Un token inexistente aborta con error en vez de emitir vacío.

## Destinos

| Plantilla | Destino | Conectado via |
|---|---|---|
| `gitconfig-colors.tpl` | `git/.gitconfig-colors` | `[include]` en `.gitconfig` |
| `tmux-colors.tpl` | `tmux/.tmux-colors.conf` | `source-file` en `.tmux.conf` |
| `claude-theme.tpl` | `claude/.claude/themes/catppuccin-mocha.json` | ver abajo |

### Activar el tema de Claude Code

No se activa solo, porque cambia los colores de las sesiones en curso.
Para activarlo:

```bash
# El paquete claude NO está stowed; copia el tema a mano
mkdir -p ~/.claude/themes
cp claude/.claude/themes/catppuccin-mocha.json ~/.claude/themes/

# Y activa en ~/.claude/settings.json
jq '.theme = "custom:catppuccin-mocha"' ~/.claude/settings.json > /tmp/s && \
  mv /tmp/s ~/.claude/settings.json
```

Claude Code observa `~/.claude/themes` y recarga en caliente: las sesiones
abiertas se retintan sin reiniciar.

## Fuera de alcance

- **nvim** mantiene su propia paleta en `nvim/.config/nvim/lua/utils/colors.lua`
  (mismos 26 colores, formato Lua). nvim carga Lua nativo, así que generarla
  por sed sería más frágil que mantener las dos en paralelo. Si cambias la
  paleta, actualiza también ese archivo.
- **starship** y **yazi** aún tienen sus hex a mano. Migrarlos es mecánico:
  crear la plantilla y añadir la entrada a `TARGETS` en `apply.sh`.
