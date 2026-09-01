# ==============================================================================
# GENERADO POR theme/apply.sh — NO EDITAR A MANO
# ==============================================================================
# Fuente: theme/palette.sh + theme/templates/gitconfig-colors.tpl
# Para cambiar colores: edita la paleta y corre `theme/apply.sh`.
# Incluido desde .gitconfig via [include].

[delta]
	features = catppuccin-mocha
	navigate = true
	light = false
	side-by-side = true
	line-numbers = true
	syntax-theme = Catppuccin-mocha
	max-line-length = 512
	hyperlinks = true

	file-style = bold "{{ TERTIARY }}"
	file-decoration-style = "{{ TERTIARY }}" ul

	line-numbers-left-format = "{nm:>4}┊"
	line-numbers-right-format = "{np:>4}│"
	line-numbers-left-style = "{{ MUTED }}"
	line-numbers-right-style = "{{ MUTED }}"

	hunk-header-style = file line-number syntax
	hunk-header-decoration-style = "{{ SECONDARY }}" box

[delta "catppuccin-mocha"]
	# Fondos de diff derivados: el color mezclado con el fondo base, para que
	# el resaltado no compita con el texto. Antes eran hex fijos sin origen.
	minus-style = syntax "{{ DELETED|mix BASE 78% }}"
	minus-emph-style = syntax "{{ DELETED|mix BASE 62% }}"
	plus-style = syntax "{{ ADDED|mix BASE 80% }}"
	plus-emph-style = syntax "{{ ADDED|mix BASE 68% }}"
	map-styles = "bold purple => syntax {{ SECONDARY }}, bold cyan => syntax {{ SKY }}"
