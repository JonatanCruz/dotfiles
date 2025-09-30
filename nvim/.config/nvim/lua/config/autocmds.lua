-- Grupo de autocomandos para una configuración limpia
local tmux_integration_group = vim.api.nvim_create_augroup("TmuxIntegration", { clear = true })

-- Autocomando que se ejecuta al ENTRAR a Neovim
vim.api.nvim_create_autocmd("VimEnter", {
  group = tmux_integration_group,
  pattern = "*",
  callback = function()
    -- Solo se ejecuta si estás dentro de una sesión de tmux
    if vim.env.TMUX then
      -- Envía el comando a tmux para ocultar la barra de estado
      vim.fn.system("tmux set-option -g status off")
    end
  end,
})

-- Autocomando que se ejecuta al SALIR de Neovim
vim.api.nvim_create_autocmd("VimLeave", {
  group = tmux_integration_group,
  pattern = "*",
  callback = function()
    if vim.env.TMUX then
      -- Envía el comando a tmux para volver a mostrar la barra de estado
      vim.fn.system("tmux set-option -g status on")
    end
  end,
})
