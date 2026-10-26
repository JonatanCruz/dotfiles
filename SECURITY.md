# Política de seguridad

Este repositorio es configuración personal (dotfiles) pública. No contiene
servicios desplegados, pero sí hooks que se ejecutan en la máquina de quien lo
instala, así que un fallo en ellos es un fallo de seguridad real.

## Cómo reportar una vulnerabilidad

**No abras un issue público.** Usa el reporte privado de GitHub:
pestaña **Security → Report a vulnerability** de este repositorio.

Incluye, si puedes:

- el archivo y la línea afectados;
- el comando o la entrada que lo reproduce;
- qué permite (leer un secreto, ejecutar código, saltarse un hook…).

## Alcance

Sí son vulnerabilidades, por ejemplo:

- una forma de que un hook de `claude/.claude/hooks/` deje pasar lo que dice
  bloquear (leer un secreto, ejecutar un comando), o de inyectar código o SQL a
  través de su entrada o de la configuración de un repo;
- un script de instalación que descargue o ejecute algo sin verificarlo;
- un secreto publicado por error en el historial.

No lo son: preferencias de configuración, o que un hook bloquee de más (eso es
un falso positivo: abre un issue normal).

## Lo que ya está activo

- Escaneo de secretos con protección de push.
- Alertas y actualizaciones de seguridad de Dependabot.
- CodeQL sobre los workflows de GitHub Actions.
- `main` sólo cambia por pull request con el CI en verde; sin push forzado.
- Actions fijadas por SHA y limitadas a autores verificados.
