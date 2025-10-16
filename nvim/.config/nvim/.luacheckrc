-- Configuración de luacheck para Neovim
globals = {
  "vim",
}

-- Ignorar warnings sobre líneas largas
max_line_length = false

-- Permitir variables no usadas que empiezan con _
unused_args = false
unused = false

-- Permitir re-definiciones de variables locales
redefined = false
