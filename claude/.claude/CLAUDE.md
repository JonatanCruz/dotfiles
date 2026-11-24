# Instrucciones globales

Aplican a todos los proyectos. Lo de un proyecto va en el CLAUDE.md de ese proyecto.

## Credenciales

- Se usan sin filtrarse: `set -a; . ./.env.<x>; set +a;` y se pasan al cliente como opción
  de conexión. Su valor no queda en ningún log ni registro; lo vigila `no-filtrar-secretos.sh`.
- Usar una credencial no autoriza la acción: mutar prod pide la autorización del dueño.

## Memoria

- Los hechos entre sesiones (decisiones, bugs, descubrimientos, preferencias) van a Engram
  con `mem_save` y un `topic_key` estable. El protocolo de uso lo trae su plugin.
- Nunca memoria en archivos (`MEMORY.md`, `memory/*.md`); lo bloquea `block-harness-memory.sh`.
- `mem_session_start` usa el nombre del repo principal, no el del worktree:
  `basename "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"`.

## Indicaciones del dueño

Clasifícalas antes de guardarlas; nunca se copian textuales:

| Si la indicación… | Va a |
|---|---|
| prohíbe u obliga una acción sin excepciones | un hook o un check de CI |
| es un hecho del repo que aplica en casi toda tarea y se corrigió más de una vez | una línea en el CLAUDE.md del proyecto |
| es un procedimiento o aplica a una parte del código | una skill |
| explica el porqué de una decisión | el ADR o el mensaje de commit |
| es contexto, una preferencia o un dato con fecha | Engram |

## Código

- Para leer código, el índice `codebase-memory` (`search_graph`, `search_code`,
  `trace_path`); grep sólo para texto, configs y logs.
- Para editar por símbolo, Serena: como plugin o como servidor MCP, nunca ambos.

## Trabajo

- Nunca directo en `main`: una rama por tarea.
- Sin copias versionadas (`-v2`, `-new`): se refactoriza en su lugar.
- Sin mocks ni stubs en código de producción.
